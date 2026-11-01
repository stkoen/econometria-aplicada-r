# Revisión metodológica

Los ejercicios de Econometría II (2025) se revisaron en 2026 para organizar su ejecución, corregir problemas de código y ampliar el análisis. Las entregas originales se conservan por separado.

## EE1 · Fertilidad y oferta laboral

- Descarga reproducible de `labsup` y corrección de la definición de `nonmomi`.
- Distinción entre el F global de primera etapa y el F del instrumento excluido.
- Estimaciones convencionales y HC1; cálculo instrumental con matrices n por k.
- Interpretación del intervalo instrumental que incluye cero y discusión de los supuestos de exogeneidad y exclusión.

## EE2 · Anuncio de Metro y vivienda

- Identificación del caso como ficticio y de la muestra como cortes transversales repetidos.
- Estimaciones en niveles y logaritmos con HC1; conversión explícita de coeficientes logarítmicos.
- Balance y placebo como diagnósticos complementarios al supuesto de tendencias paralelas.

## EE3 · Concentración y tarifas aéreas

- Corrección de una llave de cierre, eliminación de bloques repetidos y exportación automática de tablas y figuras.
- Comparación de inferencia usual, HC1 y agrupada por ruta; inclusión del parámetro de transformación de RE.
- Distinción entre el vértice de la cuadrática y un punto de inflexión.
- Correspondencia entre las ocho preguntas del ejercicio y sus resultados.

## EE4 · Pronóstico del IPM

- Verificación de fechas y selección de órdenes sobre una muestra común.
- Uso consistente de MCO en la estimación y el pronóstico revisados; comparación con el procedimiento original y con Yule–Walker.
- Distinción entre media y mediana transformadas e intervalos que incorporan la covarianza de crecimientos.
- Evaluación temporal con 24 orígenes y referencias simples.
- Separación de variación interanual, diciembre/diciembre y crecimiento de promedios anuales.
- Cobertura de las siete preguntas, equivalencia con `dynlm` y formulación correcta de la hipótesis F.

## EE5 · Shock petrolero y producción industrial

- Corrección del conteo de parámetros del AIC y selección de rezagos 0–12 sobre muestra común.
- Órdenes seleccionados: 12 para logaritmo del nivel y 11 para crecimiento; se mantienen las conclusiones ADF al 5%.
- Comparación de la ventana de 36 meses del archivo con la definición de 12 meses del enunciado, también sobre muestra común.
- Inferencia Newey–West y discusión de endogeneidad por demanda estadounidense.
- Interpretación limitada al periodo observado, 1955–2013.

## EE6 · VAR

- Corrección de la extracción de impulso y respuesta; nueve combinaciones con bandas bootstrap.
- Separación de seis contrastes direccionales de Granger y tres conjuntos.
- Comprobación de estabilidad y sensibilidad a otro orden Cholesky.
- Explicación de las unidades y de la convención de identificación contemporánea.

## Herramientas de apoyo

Las entregas originales declararon asistencia de IA en código e informes. La revisión también utilizó estas herramientas para depuración, documentación y automatización de comprobaciones, bajo revisión del autor.

Las verificaciones de ejecución y resultados se documentan en [COMPROBACIONES.md](COMPROBACIONES.md).
