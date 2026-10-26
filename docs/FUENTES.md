# Fuentes, unidades y trazabilidad

## Materiales de origen

Entregas académicas de Khoen San Martín, Econometría II, Universidad Diego
Portales, segundo semestre de 2025. Enunciados de Mauricio Tejada recuperados
y leídos: EE1 a EE6, además de las instrucciones generales y su rúbrica. El
EE4 del IPM se contrastó con sus siete preguntas, el script y el informe
entregados; las inconsistencias de su redacción se documentan por separado. El otro
EE4 encontrado, sobre crédito y `loanapp`, corresponde a un ejercicio diferente
y no se mezcla con el IPM.

Los PDF docentes y los informes originales se conservan fuera del repositorio.
Sus identidades y las de los scripts recibidos figuran en
`inventario_originales.csv`; las entregas no se sobrescriben.

## Bases docentes recibidas

| Archivo | Filas | Cobertura y unidad |
|---|---:|---|
| datos_vivienda_did.csv | 30.000 | Transacciones ficticias, 10.000 por periodo; precios en UF, distancia en km |
| ipm_chile.xlsx | 416 | Meses de enero de 1991 a agosto de 2025; índice IPM, base no precisada en el archivo |
| oil_shocks.xlsx | 708 | Meses de enero de 1955 a diciembre de 2013; INDPRO, índice de precio WPU0561 y shock suministrado |
| datos_ecobaldur.RData | 100 | Trimestres de 1995:1 a 2019:4 según el enunciado; series de un caso docente |

Las cuatro bases conservan sus datos. Las dos XLSX son copias con metadatos
reducidos: las hojas y sus celdas no se reexportan ni modifican. Las otras dos
bases mantienen los mismos bytes recibidos. `data/manifest.json` registra
SHA-256 del archivo fuente y del distribuido; METADATOS.md describe el alcance. No se sustituyen NA por ceros ni se recodifican
valores para aproximar resultados. Los archivos no aportan una licencia abierta
explícita; no se les asigna una licencia de terceros inventada. El ZIP de trabajo
no implica que los materiales docentes hayan sido publicados en un servicio
externo.

En EE2, el enunciado describe 3.000 transacciones y el archivo trae 30.000. En
EE5, la medida suministrada coincide con una ventana de 36 meses y el enunciado
define 12. En EE6, el enunciado da las diferencias como cambios porcentuales y
estacionarios, pero la serie llamada desempleo contiene valores negativos; se
limita su interpretación a la representación docente, sin reconstruir una tasa
bruta real desconocida.

## Bases públicas

EE1 utiliza `labsup`, de Angrist y Evans (1998), distribuida en el paquete
`wooldridge`. EE3 utiliza `airfare`, originalmente facilitada por Jiyoung Kwon a
Wooldridge a partir del Domestic Airline Fares Consumer Report del U.S.
Department of Transportation. Las revisiones de archivos y sus hashes quedan
fijados en `data/public_sources.json` para labsup y en
`proyectos/EE3/docs/FUENTES.md` para airfare.

- https://justinmshea.github.io/wooldridge/reference/labsup.html
- https://justinmshea.github.io/wooldridge/reference/airfare.html
- https://github.com/JustinMShea/wooldridge

Las bases públicas se descargan en la primera ejecución y se excluyen de Git.
`nonmomi` significa ingresos del hogar distintos de los de la madre, en miles
de dólares; `bmktshr` se almacena como fracción entre cero y uno. Se preservan
esas definiciones al interpretar los modelos.

## Software y métodos

- AER, MC2E: https://search.r-project.org/CRAN/refmans/AER/html/ivreg.html
- plm, Hausman: https://search.r-project.org/CRAN/refmans/plm/html/phtest.html
- urca, ADF: https://search.r-project.org/CRAN/refmans/urca/html/ur.df.html
- vars, IRF: https://search.r-project.org/CRAN/refmans/vars/html/irf.html
- vars, Cholesky: https://search.r-project.org/CRAN/refmans/vars/html/Psi.html
- sandwich, Newey–West: https://search.r-project.org/CRAN/refmans/sandwich/html/NeweyWest.html
- dynlm: https://search.r-project.org/CRAN/refmans/dynlm/html/dynlm.html
- forecast, ar: https://search.r-project.org/CRAN/refmans/forecast/html/forecast.Arima.html
- R, ar: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/ar.html
- R, AIC: https://stat.ethz.ch/R-manual/R-devel/library/stats/html/AIC.html

Las versiones realmente utilizadas están en `renv.lock` y en el archivo
`sessionInfo.txt` de cada ejercicio. Los informes separan los supuestos de
identificación de las correcciones de covarianza e inferencia.
