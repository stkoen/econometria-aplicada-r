# Comprobaciones de reproducibilidad

Las siguientes comprobaciones corresponden a la revisión técnica de octubre de 2026, con R 4.3.3 en Linux/Ubuntu 24.04:

- Ejecución de los seis ejercicios en dos carpetas independientes, incluida la descarga inicial de `labsup` y `airfare`.
- Coincidencia byte por byte de las 62 tablas CSV entre ambas ejecuciones.
- Coincidencia de 14 referencias numéricas de las entregas, dentro de las tolerancias de redondeo.
- Ejecución de `tests/check_all.R`: referencias, DiD manual, muestras AIC, transformación de pronósticos, definición del shock, nueve IRF y participaciones FEVD.
- Generación automática de los seis informes e inspección visual de las figuras.
- Registro de dependencias en `renv.lock` y `sessionInfo.txt`.
- Verificación de integridad de datos y de las copias XLSX descrita en [METADATOS.md](METADATOS.md).

GitHub Actions completó la restauración de dependencias, `run_all.R` y `tests/check_all.R`: [ejecución registrada](https://github.com/stkoen/econometria-aplicada-r/actions/runs/40269256930).

La verificación cubre Linux. La reproducibilidad numérica no verifica exogeneidad ni los supuestos de identificación de cada modelo.
