# Comprobaciones efectivamente realizadas

- Ejecución de los seis bloques con R 4.3.3, Linux/Ubuntu 24.04.
- Segunda ejecución completa en otra carpeta sin resultados ni cachés de las bases públicas. La descarga de labsup y airfare también se repitió.
- Las 62 tablas CSV de la versión revisada coinciden byte por byte entre
  ambas carpetas, incluidas las ampliaciones del EE4.
- Las 14 referencias numéricas publicadas usadas en la auditoría coinciden dentro de sus tolerancias de redondeo. Se conservan los coeficientes clásicos y los procedimientos originales cuando la revisión añade otra especificación.
- tests/check_all.R pasó en ambas carpetas: comprobaciones de referencias, DiD manual, muestras AIC, transformación de pronósticos, definición del shock, nueve IRF y participaciones FEVD.
- Los cuatro originales recibidos se conservan fuera del repositorio. Dos
  XLSX de distribución se limpiaron de metadatos: las partes que contienen
  datos, fórmulas y estilos siguen idénticas. El manifiesto separa hashes
  recibidos y distribuidos. CSV y RData conservan sus bytes originales.
- Las figuras se generaron en R y se inspeccionaron visualmente. Los seis informes Markdown se producen desde los resultados, no como tablas transcritas.
- Dependencias y versiones registradas en renv.lock y sessionInfo.txt.

GitHub Actions completó también la instalación desde renv.lock, run_all.R y
tests/check_all.R, con R 4.3.3 en Linux.
[Ejecución verificada](https://github.com/stkoen/econometria-aplicada-r/actions/runs/40269256930).
La instalación en Windows y macOS no se presenta como comprobada. Se recuperaron los seis enunciados, las instrucciones generales y su rúbrica.
Las siete preguntas del EE4 tienen correspondencia explícita en el informe.
Esto permite revisar las exigencias docentes, pero no reconstruye la
calificación ni sustituye una corrección oficial del curso.

Las comprobaciones verifican los cálculos y la ejecución descritos; no demuestran exogeneidad, identificación causal o validez universal de los modelos. Ninguna nota del curso fue modificada.
