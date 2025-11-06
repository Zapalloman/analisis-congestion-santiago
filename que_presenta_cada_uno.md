# DIVISIÓN DE CONTENIDO - PRESENTACIÓN GRUPAL (4 PERSONAS)

## ⏱️ TIEMPO TOTAL: 15 MINUTOS
- **Presentación grupal:** 12 minutos (3 min por persona)
- **Exposición del script:** 3 minutos (Persona 4)

---

## 👤 PERSONA 1: INTRODUCCIÓN Y CONTEXTO (3 minutos)

### Slides a presentar: 1-5

**Slide 1: Portada**
- Presentar el equipo y saludar
- Mencionar el título del proyecto

**Slide 2-3: ¿Qué es el Aprendizaje Supervisado?**
- Explicar concepto de ML supervisado (datos etiquetados)
- Diferenciar clasificación vs regresión
- Mencionar que se usará regresión

**Slide 4: Algoritmos Utilizados**
- Nombrar los 5 algoritmos:
  1. Regresión Lineal (baseline)
  2. Árbol de Decisión (captura no linealidades)
  3. Red Neuronal (aproximador universal)
  4. SVM-ε (robusto a outliers)
  5. K-NN (basado en vecinos)
- Explicar brevemente cada uno (1 frase por algoritmo)

**Slide 5: Variables y Justificación**
- **Variable dependiente:** Duration_hrs (continua, 118 valores únicos)
- **Variables independientes:** Length_km, Commune, Latitud, Longitud, Speed_kmh, etc. (24 features finales)
- **Justificación regresión:** 118 valores únicos → continua, no categórica. Más útil predecir "2.5 horas" que clasificar en categorías

### Script sugerido:
> "Buenos días. Somos [nombres] y presentamos nuestro análisis de congestión vehicular en Santiago usando Machine Learning. El aprendizaje supervisado utiliza datos etiquetados para entrenar modelos predictivos. Comparamos 5 algoritmos: regresión lineal como baseline, árboles de decisión para capturar no linealidades, redes neuronales, SVM y K-NN. Nuestra variable objetivo es la duración de congestión en horas, que tiene 118 valores únicos, por eso elegimos regresión en lugar de clasificación. Las variables predictoras incluyen longitud del trayecto, comuna, coordenadas geográficas y velocidad."

**Transición:**
> "Ahora [Persona 2] mostrará los tiempos de entrenamiento y los resultados del modelo de regresión lineal."

---

## 👤 PERSONA 2: TIEMPOS Y REGRESIÓN LINEAL (3 minutos)

### Dashboard - Pestañas: Tiempos + Regresión Lineal

**⏱️ Pestaña: Tiempos de Entrenamiento (1.5 min)**
- Abrir dashboard en: https://zapallo.shinyapps.io/congestion-santiago-ml/
- Navegar a "⏱️ Tiempos Entrenamiento"
- Mostrar KPIs:
  - Tiempo total: ~33 segundos
  - Modelo más rápido: Decision Tree (0.30s)
  - Modelo más lento: SVM-ε (28s)
- Mostrar tabla de tiempos
- Mencionar especificaciones: 3-fold CV, 10,000 observaciones, procesador [tu modelo]

**📈 Pestaña: Regresión Lineal (1.5 min)**
- Navegar a "📈 Regresión Lineal"
- Mostrar tabla de coeficientes
- Explicar interpretación:
  - Coeficientes positivos → aumentan duración
  - Coeficientes negativos → disminuyen duración
  - Magnitud indica importancia
- Destacar top 3 coeficientes más grandes (ordenados en tabla)

### Script sugerido:
> "Comenzamos midiendo los tiempos de entrenamiento. Como pueden ver en el dashboard, el entrenamiento total tomó 33 segundos. El árbol de decisión fue el más rápido con 0.3 segundos, mientras que SVM tomó 28 segundos por su complejidad. La regresión lineal nos muestra los coeficientes de cada variable. Los valores positivos aumentan la duración de congestión, los negativos la reducen. Pueden ver la magnitud de impacto de cada feature ordenada en esta tabla interactiva."

**Transición:**
> "Continuamos con [Persona 3] quien mostrará las visualizaciones de los modelos más complejos."

---

## 👤 PERSONA 3: MODELOS COMPLEJOS Y COMPARACIÓN (3 minutos)

### Dashboard - Pestañas: Árbol + Red Neuronal + Comparación

**🌳 Pestaña: Árbol de Decisión (1 min)**
- Navegar a "🌳 Árbol de Decisión"
- Mostrar visualización del árbol
- Explicar:
  - Cada nodo representa una decisión (ej: "Length_km < 5?")
  - Colores indican magnitud de predicción
  - Parámetro óptimo: cp (complexity parameter) elegido por CV

**🧠 Pestaña: Red Neuronal (1 min)**
- Navegar a "🧠 Red Neuronal"
- Mostrar arquitectura visual
- Explicar:
  - Capa de entrada (24 features)
  - Capa oculta (3 o 5 neuronas)
  - Capa de salida (Duration_hrs)
  - Conexiones representan pesos aprendidos

**📊 Pestaña: Comparación Modelos (1 min)**
- Navegar a "📊 Comparación Modelos"
- Mostrar gráfico de barras con RMSE
- Destacar:
  - **K-NN ganador:** RMSE = 0.9348 (menor es mejor)
  - Neural Network segundo: RMSE = 0.9499
  - SVM último: RMSE = 0.9966
- Mostrar tabla con todas las métricas y hiperparámetros óptimos

### Script sugerido:
> "El árbol de decisión visualizado aquí muestra cómo el modelo toma decisiones mediante reglas jerárquicas. Cada nodo pregunta sobre una variable, como si la longitud es menor a 5 km. La red neuronal tiene 24 entradas correspondientes a nuestras features, una capa oculta con 3 o 5 neuronas, y produce la predicción final. Al comparar todos los modelos, K-NN obtuvo el mejor desempeño con RMSE de 0.9348 horas, equivalente a ~56 minutos de error cuadrático medio. Esta tabla muestra todas las métricas y los hiperparámetros óptimos encontrados por validación cruzada."

**Transición:**
> "Finalmente, [Persona 4] presentará los resultados en datos de prueba y las conclusiones del proyecto."

---

## 👤 PERSONA 4: VALIDACIÓN TEST, CONCLUSIONES Y CÓDIGO (6 minutos)

### Dashboard - Pestañas: Validación Test + Gráficos + Código (3 min presentación + 3 min script)

**📋 Pestaña: Validación Test (1.5 min)**
- Navegar a "📋 Tabla Validación Test"
- Explicar importancia de test set (nunca visto durante entrenamiento)
- Mostrar KPIs del modelo ganador K-NN:
  - **RMSE:** 0.9348 horas (~56 min error cuadrático)
  - **MAE:** 0.5109 horas (~31 min error promedio) ← **Métrica más interpretable**
  - **R²:** 20.61% (varianza explicada)
  - **MAPE:** 77.35%
- Destacar que MAE de 31 minutos es útil para planificación

**📉 Pestaña: Residuales & Gráficos (1.5 min)**
- Navegar a "📉 Residuales & Gráficos"
- Mostrar gráfico de residuales:
  - Explicar: puntos cercanos a línea diagonal = buenas predicciones
  - Dispersión indica error
- Mostrar importancia de variables:
  - **Top 3:** Length_km, Commune_Santiago, Longitud
  - Interpretación de cada una

**Conclusiones (Solo verbal - regresar a slide 14 en PowerPoint si lo tienen)**
- Modelo ganador: K-NN con error promedio de 31 minutos
- Variables clave: longitud del trayecto y ubicación geográfica
- Limitaciones: R² bajo (20.6%) debido a aleatoriedad del tráfico (clima, accidentes)
- Aplicaciones: planificación urbana, información ciudadana
- Mejoras futuras: más variables (clima, eventos), dataset completo (76k obs)

---

### 🖥️ EXPOSICIÓN DEL SCRIPT (3 minutos)

**Abrir VSCode o RStudio y mostrar:**

1. **Archivo: `analisis_completo.R` (1 min)**
   - Mostrar estructura general (scroll rápido)
   - Destacar secciones clave:
     * Carga de librerías (líneas 1-23)
     * Preprocesamiento (detección de outliers, one-hot encoding)
     * Medición de tiempos de entrenamiento (mostrar código de `Sys.time()`)
     * Entrenamiento de 5 modelos con `caret::train()`
     * Generación de visualizaciones (árbol con `rpart.plot`, red neuronal con `plotnet`)

2. **Archivo: `knn_modelo.R` (1 min)**
   - Explicar que es el modelo ganador standalone
   - Mostrar sección de entrenamiento K-NN
   - Mostrar que genera `knn_modelo.rds` para reutilización

3. **Archivo: `app.R` (1 min)**
   - Explicar brevemente estructura Shiny (ui + server)
   - Mostrar cómo carga los datos (líneas de `read.csv`, `readRDS`)
   - Mostrar ejemplo de una pestaña (ej: código de gráfico de tiempos con Plotly)
   - Mencionar que está desplegado en ShinyApps.io

**Cierre:**
> "Todos los archivos están documentados y reproducibles con `set.seed(123)`. El proyecto está disponible en nuestro repositorio GitHub y el dashboard en https://zapallo.shinyapps.io/congestion-santiago-ml/. ¿Preguntas?"

---

## 📊 RESUMEN DE DISTRIBUCIÓN

| Persona | Contenido | Tiempo | Herramientas |
|---------|-----------|--------|--------------|
| **1** | Introducción, algoritmos, variables | 3 min | PowerPoint/Canva (Slides 1-5) |
| **2** | Tiempos + Regresión Lineal | 3 min | Dashboard (2 pestañas) |
| **3** | Árbol + Red + Comparación | 3 min | Dashboard (3 pestañas) |
| **4** | Validación + Conclusiones + Código | 3 min + 3 min | Dashboard (2 pestañas) + VSCode |

---

## 🎯 TIPS PARA COORDINACIÓN

### Transiciones suaves:
- Persona 1 → 2: "Ahora veremos los resultados técnicos en el dashboard..."
- Persona 2 → 3: "Continuamos con modelos más complejos..."
- Persona 3 → 4: "Finalmente, validación y conclusiones..."

### Durante Q&A:
- Persona 1: preguntas teóricas (algoritmos, metodología)
- Persona 2: preguntas sobre tiempos, eficiencia
- Persona 3: preguntas sobre modelos complejos
- Persona 4: preguntas sobre resultados, código, conclusiones

---

## ✅ CHECKLIST PRE-PRESENTACIÓN

**Persona 1:**
- [ ] Slides 1-5 en PowerPoint/Canva listos
- [ ] Memorizar concepto de aprendizaje supervisado
- [ ] Practicar explicación de 5 algoritmos (1 frase cada uno)

**Persona 2:**
- [ ] Dashboard abierto en navegador
- [ ] Practicar navegación pestaña "Tiempos" y "Regresión Lineal"
- [ ] Memorizar datos del procesador

**Persona 3:**
- [ ] Practicar explicación visual de árbol y red neuronal
- [ ] Saber destacar modelo ganador en gráfico comparativo
- [ ] Memorizar RMSE del ganador (0.9348)

**Persona 4:**
- [ ] Tener VSCode/RStudio abierto con archivos listos
- [ ] Practicar scroll rápido en `analisis_completo.R`
- [ ] Memorizar conclusiones clave (MAE 31 min, R² 20.6%)
- [ ] Tener URL del dashboard lista para mencionar

---

