# Correspondencia con el enunciado recuperado

Se revisaron las dos páginas de `2025_S2_ejercicio_empirico_4.pdf`, el informe
original de Khoen San Martín y las instrucciones generales de Econometría II.
Los PDF de origen no se publican como parte del repositorio de código.

| Pregunta | Evidencia de la versión revisada |
|---|---|
| 1. Logaritmo, diferencia y patrones | `results/figures/series_log_y_diferencia.png`, descriptivos e interpretación sin afirmar que el gráfico demuestra estacionariedad |
| 2. Ocho AR con dynlm y AIC | `results/seleccion_AR_muestra_comun.csv` y `results/verificacion_dynlm.csv`; se preserva también la selección original con muestras variables |
| 3. Significancia conjunta | `results/contrastes_F_enunciado.csv`; modelo elegido, AR(6) y los seis primeros coeficientes dentro del AR(8), con hipótesis diferenciadas |
| 4. Crecimiento septiembre-diciembre | Cuatro filas de `results/pronosticos_revisados.csv`, con intervalos predictivos |
| 5. Recuperar logaritmo y nivel | Acumulación de crecimientos desde agosto y exponenciación; se distinguen mediana y media lognormal |
| 6. Promedio de crecimientos interanuales de 2025 | `results/crecimiento_interanual_serie_completa.csv` y primera fila de `results/tres_medidas_de_crecimiento.csv` |
| 7. ar y forecast | `results/comparacion_ar_forecast.csv` y `results/seleccion_automatica_Yule_Walker.csv` |

## Inconsistencias del enunciado y decisiones

- La pregunta 3 describe como nula que el pasado es útil. La prueba F usual
  plantea coeficientes de rezagos iguales a cero bajo la nula. Se usa esa
  hipótesis y se interpreta su rechazo correctamente.
- Esa misma pregunta menciona seis rezagos, aunque la pregunta 2 permite
  seleccionar entre uno y ocho. El modelo elegido tiene ocho; se informa su
  prueba y se muestran dos contrastes adicionales que permiten interpretar
  la mención de seis sin sustituir silenciosamente el modelo principal.
- La pregunta 7 muestra un ejemplo con tres pasos y `order.max=12`, y un punto
  sobrante después de una llamada. Se ejecutan cuatro pasos conforme al
  horizonte septiembre-diciembre, con máximo ocho para la selección.
- Se indica `level=95` explícitamente para los intervalos del paquete forecast.
  El AIC relativo de ar y el AIC de las regresiones no se comparan como si
  fueran la misma cifra; Yule-Walker y MCO son estimadores distintos.

## Instrucciones generales y alcance del portafolio

El informe generado incluye descripción de datos, descriptivos, respuestas,
conclusión y reflexión. El código comentado se entrega por separado y los
gráficos se generan directamente, sin pantallazos de consola. El curso pidió
PDF para la entrega académica; los seis informes del portafolio se distribuyen
en Markdown para su lectura en GitHub. Esto no se presenta como una nueva
entrega académica ni como una evaluación oficial bajo la rúbrica.

Las ampliaciones de validación temporal, comparación con referencias y
transformaciones lognormales se identifican como revisión para portafolio.
