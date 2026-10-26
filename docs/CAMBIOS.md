# Correcciones y ampliaciones

## EE1

Se añade una carga reproducible de `labsup`, se corrige el significado de
`nonmomi` y se distinguen el F global de primera etapa y el F del instrumento
excluido. Se conservan estimaciones convencionales para la reproducción y se
añade HC1. Su cálculo instrumental utiliza matrices n por k, evitando construir
una matriz de proyección n por n innecesaria. Se evita concluir un signo causal
confirmado cuando el intervalo instrumental incluye cero o deducir el sentido
del sesgo solo de la diferencia entre MCO y MC2E.

## EE2

Se identifica como caso ficticio sobre el anuncio de una estación futura. Se
verifica que los ID son únicos y se trata como cortes transversales repetidos.
Se conserva la estimación MCO y HC1, equivalente a la especificación del script
original, con tablas completas y conversión explícita de coeficientes
logarítmicos. El balance y un placebo no significativo no se presentan como
demostración de identificación causal. El cambio de unidad en niveles y logs
se hace explícito.

## EE3

Se corrige la llave suelta de la línea 162, se eliminan duplicaciones, se
exportan gráficos y se vinculan las ocho preguntas del enunciado con sus
salidas. Se distinguen el intervalo usual, HC1 y agrupado por ruta. Se incluye
theta de RE y se precisa que FE no resuelve toda la endogeneidad. La expresión
punto de inflexión aparecía también en el enunciado: su sustitución por
mínimo/vértice es una precisión matemática, no un incumplimiento docente que
se atribuya al estudiante.

## EE4

Se verifica la fecha de cada fila, se seleccionan órdenes con la misma muestra
y se mantiene consistente el estimador del pronóstico revisado. Se reconstruye
por separado el procedimiento original, que elige por MCO y pronostica con
arima, y se compara con Yule–Walker sin presentarlos como métodos idénticos.
Se distinguen mediana y media transformada, e intervalos predictivos que
propagan la covarianza de crecimientos. Se corrigen las confusiones entre
promedio de tasas interanuales, diciembre/diciembre y promedios anuales. Se
añade una evaluación temporal con 24 orígenes y referencias simples. Las
tablas publicadas se generan desde resultados, sin transcripción manual.
Tras recuperar el enunciado se muestran explícitamente sus siete preguntas,
los gráficos de logaritmo y diferencia, la equivalencia con dynlm, la prueba
F, la serie interanual completa y la comparación ar más forecast. Se explican
la inversión de la nula y la mención de seis rezagos en el enunciado.

## EE5

El AIC original contaba las cuatro columnas de un resumen como parámetros y
comparaba muestras distintas. Se reemplaza por selección 0–12 sobre ventana
común. Los órdenes seleccionados pasan a 12 para el logaritmo del nivel y 11
para el crecimiento; las conclusiones ADF al 5% permanecen: no se rechaza raíz
unitaria en el nivel y sí en el crecimiento. Se conservan valores críticos ADF.
La serie petrolera suministrada usa 36 meses, frente a 12 en el enunciado; se
reproduce la primera y se comparan ambas medidas, incluyendo una muestra
común. Se mantiene Newey–West de la entrega y se incorpora explícitamente la
pregunta sobre endogeneidad por demanda estadounidense. Se retira la referencia
a 2020, que no forma parte de la muestra.

## EE6

Se corrige la extracción de IRF: nombres de lista son impulsos y columnas son
respuestas. Se producen las nueve combinaciones con bandas bootstrap y se
separan los seis contrastes direccionales de Granger de los tres conjuntos.
Se comprueba estabilidad y se analiza sensibilidad a otro orden Cholesky.
Se mantiene el orden impuesto y se explica la diferencia entre la convención
del paquete y la interpretación de endogeneidad del enunciado. Se aceptan los
supuestos de estacionariedad de diferencias y unidades que el enunciado sí
entrega; no se atribuye al estudiante su falta de comprobación como si fuera
un requisito docente omitido.

## Alcance común

Reproducir cifras no equivale a certificar todas las interpretaciones del PDF
original. Los errores corregidos y las mejoras para portafolio se mantienen
separados de los requisitos evaluados. Las notas académicas no se alteran ni
se someten a una nueva calificación. El proyecto no ofrece predicciones de
éxito empresarial ni recomendaciones de inversión o de política causalmente
identificadas a partir de estas regresiones.

## Herramientas de apoyo

Las entregas originales declararon el uso de herramientas de IA para apoyar
la preparación del código y los informes. Esta revisión también utilizó
herramientas de IA en depuración, documentación y comprobaciones.
Las verificaciones realizadas se describen en COMPROBACIONES.md.
