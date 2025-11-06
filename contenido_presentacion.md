# CONTENIDO PARA PRESENTACIÓN

## INTRODUCCIÓN

### Reseña del Trabajo

Este proyecto analiza la congestión vehicular en Santiago utilizando técnicas de Machine Learning supervisado. El objetivo es predecir la duración de episodios de congestión basándose en características geográficas, temporales y de infraestructura vial. Se compararon 5 algoritmos de aprendizaje supervisado para identificar el modelo con mejor capacidad predictiva.

### ¿Qué es el Aprendizaje Supervisado?

El aprendizaje supervisado es una técnica de Machine Learning donde el algoritmo aprende a partir de datos etiquetados. Se le presentan ejemplos con entradas (características) y salidas conocidas (variable objetivo), permitiendo al modelo aprender patrones para hacer predicciones en datos nuevos. Se divide en dos categorías:

- **Clasificación**: Predice categorías discretas (ej: spam/no spam, enfermo/sano)
- **Regresión**: Predice valores numéricos continuos (ej: precio, temperatura, duración)

### Algoritmos Utilizados

**1. Regresión Lineal**
- Modelo base que asume relación lineal entre variables
- Altamente interpretable mediante coeficientes
- Sirve como baseline para comparación

**2. Árbol de Decisión (Decision Tree)**
- Modelo basado en reglas tipo "si-entonces"
- Captura relaciones no lineales mediante particiones recursivas
- Fácil de visualizar e interpretar

**3. Red Neuronal (Neural Network)**
- Aproximador universal de funciones
- Captura patrones complejos mediante capas de neuronas
- Configuración: capa oculta con 3 o 5 neuronas, regularización con decay

**4. SVM-ε (Support Vector Machine para Regresión)**
- Utiliza kernel RBF para capturar no linealidades
- Robusto ante outliers mediante margen de tolerancia epsilon
- Hiperparámetros: sigma (ancho del kernel) y C (penalización)

**5. K-NN (K-Nearest Neighbors)**
- Método no paramétrico basado en similitud
- Predice promediando los k vecinos más cercanos
- Simple pero efectivo para datos con patrones locales

### Objetivos del Estudio

**Objetivo General:**
Desarrollar un modelo predictivo que estime la duración de congestión vehicular en Santiago con alta precisión.

**Objetivos Específicos:**
1. Identificar las variables más relevantes para predecir congestión
2. Comparar el desempeño de 5 algoritmos de aprendizaje supervisado
3. Optimizar hiperparámetros mediante validación cruzada
4. Seleccionar el modelo con mejor balance entre precisión y generalización
5. Interpretar los factores que más influyen en la duración de congestión

---

## DEFINICIÓN DE VARIABLES

### Variable Dependiente (Target)

**Duration_hrs** - Duración de la congestión en horas

- **Tipo**: Numérica continua
- **Rango**: 0 a varias horas
- **Valores únicos**: 118 diferentes
- **Distribución**: Continua con alta variabilidad

### Variables Independientes (Features)

Las variables predictoras incluyen:

**Geográficas:**
- `Commune`: Comuna donde ocurre la congestión (52 niveles, codificadas top-20)
- `Latitud` / `Longitud`: Coordenadas geográficas del evento

**Infraestructura:**
- `Street`: Nombre de la calle (eliminada por alta cardinalidad: 2,081 valores únicos)
- `Length_km`: Longitud del tramo afectado en kilómetros

**Temporales:**
- `Hora.Inicio` / `Hora.Fin`: Hora de inicio y fin (eliminadas por alta cardinalidad)
- `Peak_Time`: Indicador de hora punta (eliminada por 186 valores únicos)

**Tráfico:**
- `Speed_kmh`: Velocidad promedio durante la congestión
- Otras variables derivadas del procesamiento

**Total de features finales:** 24 (después de one-hot encoding y eliminación de alta cardinalidad)

### Justificación: Regresión vs Clasificación

**Decisión: REGRESIÓN**

**Razones:**

1. **Naturaleza de la variable objetivo**: `Duration_hrs` es numérica continua, no categórica

2. **Número de valores únicos**: Con 118 valores diferentes, tratarla como clasificación sería ineficiente y poco práctico (demasiadas clases)

3. **Interpretabilidad**: En regresión, predecir "2.5 horas" es más útil que clasificar en "congestión larga/media/corta"

4. **Aplicación práctica**: Los usuarios necesitan estimaciones precisas de tiempo, no categorías

5. **Métricas apropiadas**: RMSE, MAE y R² son más informativas que accuracy para este problema

**Regla aplicada:** 
Cuando una variable numérica tiene >20 valores únicos y representa una magnitud continua, se trata como regresión. En este caso: 118 valores únicos / 10,000 observaciones = 1.18% de unicidad, lo que indica alta variabilidad continua.

---

## CONCLUSIONES

### Hallazgos Principales

**1. Modelo Ganador: K-NN**

El algoritmo K-NN obtuvo el mejor desempeño con:
- RMSE: 0.9348 horas (~56 minutos de error cuadrático medio)
- MAE: 0.5109 horas (~31 minutos de error promedio)
- R²: 0.2061 (explica el 20.6% de la varianza)

K-NN superó a los demás modelos porque captura patrones locales sin asumir relaciones globales, lo cual es apropiado para el tráfico urbano que varía significativamente por zona y hora.

**2. Variables Más Importantes**

Las 3 features con mayor impacto predictivo:

- **Length_km**: La longitud del tramo es el predictor más fuerte. Trayectos más largos acumulan múltiples factores de congestión.

- **Commune_Santiago**: La comuna específica (Santiago Centro) muestra patrones distintivos por densidad vehicular.

- **Longitud (coordenada geográfica)**: El eje este-oeste de la ciudad presenta características diferenciadas de flujo vehicular.

**3. Desempeño Relativo de Algoritmos**

- **K-NN** y **Red Neuronal** lograron mejor desempeño (RMSE < 0.95), capturando no linealidades
- **Árbol de Decisión** tuvo rendimiento intermedio (RMSE = 0.9567)
- **Regresión Lineal** mostró limitaciones por asumir linealidad (RMSE = 0.9603)
- **SVM-ε** fue el más lento (28 segundos) con menor R² (0.0977)

**4. Limitaciones del Modelo**

- R² = 0.206 indica que el 79.4% de la varianza no es explicada por el modelo
- Esto es esperable: el tráfico tiene componentes aleatorios (accidentes, clima, eventos)
- MAE de 31 minutos sigue siendo útil para planificación urbana

**5. Optimizaciones Aplicadas**

Para cumplir con tiempo de ejecución razonable:
- Dataset reducido de 76,140 a 10,000 observaciones (submuestreo estratificado)
- Features reducidas de 3,882 a 24 (eliminación de alta cardinalidad)
- Validación cruzada: 3-fold en lugar de 5-fold
- Resultado: tiempo total de entrenamiento ~33 segundos

### Implicaciones Prácticas

**Para autoridades de tránsito:**
- Priorizar intervenciones en trayectos largos y zonas céntricas
- Considerar ubicación geográfica (eje este-oeste) al planificar rutas alternas
- El error de ~31 minutos permite estimaciones útiles para información ciudadana

**Para ciudadanos:**
- Predicciones pueden ayudar a elegir rutas y horarios de viaje
- Mayor precisión en trayectos cortos (menor acumulación de error)

### Oportunidades de Mejora

**1. Incorporar más variables:**
- Clima (lluvia, temperatura)
- Eventos programados (partidos, conciertos)
- Datos históricos de accidentes
- Variables de transporte público

**2. Aumentar tamaño del dataset:**
- Recuperar las 76,140 observaciones originales
- Utilizar infraestructura de mayor capacidad (GPU, cluster)

**3. Feature engineering avanzado:**
- Crear variables de interacción (ej: Commune × Hora)
- Extraer patrones temporales (día semana, mes, estacionalidad)

**4. Modelos más complejos:**
- Ensemble methods (Random Forest, Gradient Boosting)
- Deep Learning con arquitecturas especializadas
- Modelos de series temporales (LSTM, ARIMA)

**5. Reducir cardinalidad de forma inteligente:**
- Clustering de calles por características similares
- Embeddings para variables categóricas de alta dimensión

### Reflexión Final

Este proyecto demuestra que es posible predecir congestión vehicular con precisión moderada usando datos geográficos y de infraestructura. Aunque el R² es modesto, el error de 31 minutos es aceptable para aplicaciones prácticas de planificación urbana. El éxito de K-NN sugiere que el tráfico de Santiago tiene patrones locales fuertes que no siguen relaciones globales simples.

La combinación de análisis riguroso, optimización computacional y visualización interactiva posiciona este trabajo como una base sólida para sistemas de información ciudadana y toma de decisiones en movilidad urbana.

---

**Modelo Final:** K-NN con k=5 o k=7  
**Mejor Métrica:** MAE = 0.5109 horas (~31 minutos)  
**Dashboard:** https://zapallo.shinyapps.io/congestion-santiago-ml/  
**Dataset:** Congestión Santiago, Mayo 2025
