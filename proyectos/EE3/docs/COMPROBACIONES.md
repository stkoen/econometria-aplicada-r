# Comprobaciones de EE3

La revisión local del 25 de octubre de 2026 se realizó con R 4.3.3 en Linux/Ubuntu 24.04. Se ejecutó el análisis en dos carpetas independientes, repitiendo la descarga de la base y la generación de resultados.

| Referencia de la entrega | Original, redondeado | Reproducción |
|---|---:|---:|
| Coeficiente de concentración, MCO | 0,3601 | 0,3601203557 |
| Coeficiente de concentración, RE | 0,2090 | 0,2089934796 |
| Coeficiente de concentración, FE | 0,1689 | 0,1688589805 |
| Hausman, estadístico | 9,9967 | 9,9967275696 |
| Hausman, p-valor | 0,04048 | 0,0404828417 |

La tolerancia de coeficientes fue 0,0001, acorde con el redondeo publicado. Los nueve CSV coincidieron byte por byte y `tests/check_reproduction.R` pasó en ambas carpetas. Las tres figuras se inspeccionaron visualmente.

La revisión también identificó y corrigió una llave de cierre sin apertura en la línea 162 del script recibido. Las identidades de los archivos originales se documentan en [REVISION.md](REVISION.md).

Versiones del entorno: `results/sessionInfo.txt` y `renv.lock`. La ejecución remota posterior y las comprobaciones del conjunto de seis ejercicios se registran en [la documentación general](../../../docs/COMPROBACIONES.md).

Estas comprobaciones verifican ejecución y coincidencia numérica; la identificación econométrica se discute en el informe.
