# modelo knn para prediccion de congestion vehicular
# algoritmo ganador del analisis comparativo

rm(list = ls())
gc()
set.seed(123)

cat("=== cargando librerias ===\n")
library(caret)
library(dplyr)

cat("\n=== cargando datos ===\n")
detect_separator <- function(file_path, n_lines = 5) {
  lines <- readLines(file_path, n = n_lines)
  separators <- c(",", ";", "\t", "|")
  counts <- sapply(separators, function(sep) {
    mean(sapply(strsplit(lines, sep, fixed = TRUE), length))
  })
  return(separators[which.max(counts)])
}

file_path <- "Congestion_Santiago_05_2025-1.csv"
separator <- detect_separator(file_path)
data_raw <- read.csv(
  file_path,
  sep = separator,
  header = TRUE,
  na.strings = c("", "NA", "N/A", "null", "NULL", " "),
  stringsAsFactors = FALSE
)

cat(sprintf("dimensiones: %d filas x %d columnas\n", nrow(data_raw), ncol(data_raw)))

cat("\n=== preprocesamiento ===\n")
target_col <- "Duration_hrs"
data <- data_raw

# submuestreo para velocidad
if (nrow(data) > 10000) {
  set.seed(123)
  target <- data[[target_col]]
  target_quartiles <- cut(target, breaks = quantile(target, probs = seq(0, 1, 0.25), na.rm = TRUE), 
                           include.lowest = TRUE, labels = FALSE)
  sample_idx <- createDataPartition(target_quartiles, p = min(10000/nrow(data), 1), list = FALSE)
  data <- data[sample_idx, ]
  cat(sprintf("dataset reducido a %d observaciones\n", nrow(data)))
}

# eliminar columnas no utiles
cols_to_remove <- c("Fecha", "Hora.Inicio", "Hora.Fin", "Peak_Time")
for (col in names(data)) {
  if (col != target_col && (is.character(data[[col]]) || is.factor(data[[col]]))) {
    n_unique <- length(unique(data[[col]]))
    if (n_unique > 100) {
      cols_to_remove <- c(cols_to_remove, col)
    }
  }
}
data <- data[, !(names(data) %in% cols_to_remove)]

# separar features y target
y <- data[[target_col]]
X <- data[, names(data) != target_col, drop = FALSE]

# identificar numericas y categoricas
numeric_cols <- sapply(X, function(col) {
  is.numeric(col) || (!is.na(suppressWarnings(as.numeric(as.character(col[1])))) && 
                        mean(!is.na(suppressWarnings(as.numeric(as.character(col))))) > 0.5)
})
categorical_cols <- !numeric_cols

# convertir numericas
for (col in names(X)[numeric_cols]) {
  X[[col]] <- as.numeric(as.character(X[[col]]))
}

# convertir categoricas
for (col in names(X)[categorical_cols]) {
  X[[col]] <- as.character(X[[col]])
  X[[col]][is.na(X[[col]])] <- "Missing"
  X[[col]] <- as.factor(X[[col]])
}

cat("\n=== tratamiento de outliers ===\n")
outliers_count <- 0
for (col in names(X)[numeric_cols]) {
  values <- X[[col]]
  Q1 <- quantile(values, 0.25, na.rm = TRUE)
  Q3 <- quantile(values, 0.75, na.rm = TRUE)
  IQR_val <- Q3 - Q1
  lower_bound <- Q1 - 3 * IQR_val
  upper_bound <- Q3 + 3 * IQR_val
  outlier_mask <- !is.na(values) & (values < lower_bound | values > upper_bound)
  outliers_count <- outliers_count + sum(outlier_mask)
  X[[col]][outlier_mask] <- NA
}
cat(sprintf("outliers marcados: %d\n", outliers_count))

cat("\n=== one-hot encoding ===\n")
if (sum(categorical_cols) > 0) {
  dummies_list <- list()
  for (col in names(X)[categorical_cols]) {
    n_levels <- length(levels(X[[col]]))
    if (n_levels > 50) {
      top_levels <- names(sort(table(X[[col]]), decreasing = TRUE)[1:min(20, n_levels)])
      X[[col]] <- ifelse(X[[col]] %in% top_levels, as.character(X[[col]]), "Other")
      X[[col]] <- factor(X[[col]])
      n_levels <- length(levels(X[[col]]))
    }
    if (n_levels > 2) {
      dummy_matrix <- model.matrix(~ X[[col]] - 1)
      colnames(dummy_matrix) <- gsub("X\\[\\[col\\]\\]", paste0(col, "_"), colnames(dummy_matrix))
      if (ncol(dummy_matrix) > 1) {
        dummy_matrix <- dummy_matrix[, -1, drop = FALSE]
      }
      dummies_list[[col]] <- as.data.frame(dummy_matrix)
    } else if (n_levels == 2) {
      dummy_col <- as.numeric(X[[col]] == levels(X[[col]])[2])
      dummies_list[[col]] <- data.frame(dummy_col)
      names(dummies_list[[col]]) <- paste0(col, "_", levels(X[[col]])[2])
    }
  }
  X <- X[, !categorical_cols, drop = FALSE]
  if (length(dummies_list) > 0) {
    X <- cbind(X, do.call(cbind, dummies_list))
  }
}
cat(sprintf("features finales: %d\n", ncol(X)))

cat("\n=== imputacion de nas ===\n")
original_numeric <- sapply(names(X), function(n) {
  !grepl("_", n) || grepl("km|hrs|Latitud|Longitud", n)
})

for (col in names(X)[original_numeric]) {
  if (any(is.na(X[[col]]))) {
    median_val <- median(X[[col]], na.rm = TRUE)
    X[[col]][is.na(X[[col]])] <- median_val
  }
}

for (col in names(X)[!original_numeric]) {
  if (any(is.na(X[[col]]))) {
    mode_val <- as.numeric(names(sort(table(X[[col]]), decreasing = TRUE)[1]))
    X[[col]][is.na(X[[col]])] <- mode_val
  }
}

# preparar target
y <- as.numeric(as.character(y))
valid_idx <- !is.na(y)
X <- X[valid_idx, ]
y <- y[valid_idx]

cat(sprintf("datos limpios: %d obs, %d features\n", nrow(X), ncol(X)))

cat("\n=== division train/test 80/20 ===\n")
train_idx <- createDataPartition(seq_along(y), p = 0.8, list = FALSE)
X_train <- X[train_idx, ]
X_test <- X[-train_idx, ]
y_train <- y[train_idx]
y_test <- y[-train_idx]

cat(sprintf("train: %d obs\n", nrow(X_train)))
cat(sprintf("test: %d obs\n", nrow(X_test)))

cat("\n=== estandarizacion ===\n")
numeric_features <- names(X_train)[original_numeric]
scaling_params <- list()
for (col in numeric_features) {
  scaling_params[[col]] <- list(
    mean = mean(X_train[[col]], na.rm = TRUE),
    sd = sd(X_train[[col]], na.rm = TRUE)
  )
  if (scaling_params[[col]]$sd > 0) {
    X_train[[col]] <- (X_train[[col]] - scaling_params[[col]]$mean) / scaling_params[[col]]$sd
  }
}

for (col in numeric_features) {
  if (scaling_params[[col]]$sd > 0) {
    X_test[[col]] <- (X_test[[col]] - scaling_params[[col]]$mean) / scaling_params[[col]]$sd
  }
}
cat("estandarizacion completada\n")

cat("\n=== entrenando modelo knn ===\n")
train_control <- trainControl(
  method = "cv",
  number = 3,
  savePredictions = "final",
  verboseIter = FALSE,
  allowParallel = FALSE
)

train_data <- X_train
train_data$target_variable <- y_train

knn_model <- train(
  target_variable ~ .,
  data = train_data,
  method = "knn",
  trControl = train_control,
  tuneGrid = expand.grid(k = c(5, 7)),
  metric = "RMSE"
)

cat("\nmejor k seleccionado:\n")
print(knn_model$bestTune)

cat("\nresultados de validacion cruzada:\n")
print(knn_model$results)

cat("\n=== evaluando en test ===\n")
predictions <- predict(knn_model, newdata = X_test)

rmse <- sqrt(mean((predictions - y_test)^2))
mae <- mean(abs(predictions - y_test))
ss_res <- sum((y_test - predictions)^2)
ss_tot <- sum((y_test - mean(y_test))^2)
r2 <- 1 - ss_res / ss_tot
mape <- mean(abs((y_test - predictions) / (y_test + 1e-10))) * 100

cat(sprintf("\nmetricas en test:\n"))
cat(sprintf("  rmse: %.4f\n", rmse))
cat(sprintf("  mae: %.4f\n", mae))
cat(sprintf("  r2: %.4f\n", r2))
cat(sprintf("  mape: %.2f%%\n", mape))

cat("\n=== generando visualizacion ===\n")
library(ggplot2)

residuals <- y_test - predictions
plot_data <- data.frame(Predicted = predictions, Residuals = residuals)

p <- ggplot(plot_data, aes(x = Predicted, y = Residuals)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red", size = 1) +
  geom_smooth(method = "loess", color = "darkgreen", se = TRUE) +
  labs(title = "knn - residuales vs prediccion",
       x = "valores predichos",
       y = "residuales") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave("knn_residuales.png", plot = p, width = 10, height = 6, dpi = 300)
cat("grafico guardado: knn_residuales.png\n")

cat("\n=== guardando modelo ===\n")
saveRDS(list(
  model = knn_model,
  scaling_params = scaling_params,
  numeric_features = numeric_features,
  rmse = rmse,
  mae = mae,
  r2 = r2,
  mape = mape
), "knn_modelo.rds")
cat("modelo guardado: knn_modelo.rds\n")

cat("\n=== resumen del modelo ===\n")
cat(sprintf("algoritmo: k-nearest neighbors (knn)\n"))
cat(sprintf("mejor k: %d\n", knn_model$bestTune$k))
cat(sprintf("metrica principal (rmse): %.4f\n", rmse))
cat(sprintf("error absoluto medio (mae): %.4f horas (~%.0f minutos)\n", mae, mae * 60))
cat(sprintf("varianza explicada (r2): %.2f%%\n", r2 * 100))
cat("\nmodelo listo para usar en predicciones futuras\n")

cat("\n=== ejemplo de uso del modelo guardado ===\n")
cat("# cargar modelo:\n")
cat("saved_model <- readRDS('knn_modelo.rds')\n")
cat("# predecir nuevos datos:\n")
cat("predicciones <- predict(saved_model$model, newdata = nuevos_datos_preprocesados)\n")
