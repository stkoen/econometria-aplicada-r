# Fuentes, unidades y trazabilidad

## Origen académico

Trabajo de Khoen San Martín para Econometría II, Universidad Diego Portales, segundo semestre de 2025. Los seis enunciados y las instrucciones del curso se contrastaron con los análisis revisados.

Los PDF docentes y las entregas originales se conservan fuera del repositorio. Sus identificadores y hashes están en `inventario_originales.csv`.

## Bases docentes

| Archivo | Filas | Cobertura y unidad |
|---|---:|---|
| datos_vivienda_did.csv | 30.000 | Transacciones ficticias, 10.000 por periodo; precios en UF, distancia en km |
| ipm_chile.xlsx | 416 | Enero de 1991 a agosto de 2025; índice IPM, base no precisada en el archivo |
| oil_shocks.xlsx | 708 | Enero de 1955 a diciembre de 2013; INDPRO, precio WPU0561 y shock suministrado |
| datos_ecobaldur.RData | 100 | Trimestres 1995:1–2019:4; series de un caso docente |

Las cuatro bases conservan sus datos. Las copias XLSX tienen propiedades de archivo reducidas; CSV y RData mantienen sus bytes originales. `data/manifest.json` distingue los hashes del archivo recibido y del distribuido. Detalle en [METADATOS.md](METADATOS.md). Los archivos docentes no incluyen una licencia abierta explícita.

Discrepancias relevantes:

- EE2: el enunciado describe 3.000 transacciones; el archivo contiene 30.000.
- EE5: el shock suministrado usa una ventana de 36 meses; el enunciado define 12. Se comparan ambas medidas.
- EE6: la serie denominada desempleo contiene valores negativos. Su interpretación se limita a la representación docente.

## Bases públicas

EE1 utiliza `labsup`, de Angrist y Evans (1998), distribuida en `wooldridge`. EE3 utiliza `airfare`, facilitada por Jiyoung Kwon a Wooldridge a partir del Domestic Airline Fares Consumer Report del U.S. Department of Transportation.

- [Documentación de labsup](https://justinmshea.github.io/wooldridge/reference/labsup.html)
- [Documentación de airfare](https://justinmshea.github.io/wooldridge/reference/airfare.html)
- [Repositorio del paquete wooldridge](https://github.com/JustinMShea/wooldridge)

Las bases se descargan de revisiones fijas y se excluyen de Git. Revisiones y hashes: `data/public_sources.json` y [fuentes de EE3](../proyectos/EE3/docs/FUENTES.md).

`nonmomi` mide ingresos del hogar distintos de los de la madre, en miles de dólares. `bmktshr` se almacena como fracción entre cero y uno.

## Software y métodos

- [AER: variables instrumentales](https://search.r-project.org/CRAN/refmans/AER/html/ivreg.html)
- [plm: contraste de Hausman](https://search.r-project.org/CRAN/refmans/plm/html/phtest.html)
- [urca: ADF](https://search.r-project.org/CRAN/refmans/urca/html/ur.df.html)
- [vars: impulso-respuesta](https://search.r-project.org/CRAN/refmans/vars/html/irf.html) y [Cholesky](https://search.r-project.org/CRAN/refmans/vars/html/Psi.html)
- [sandwich: Newey–West](https://search.r-project.org/CRAN/refmans/sandwich/html/NeweyWest.html)
- [dynlm](https://search.r-project.org/CRAN/refmans/dynlm/html/dynlm.html)
- [forecast](https://search.r-project.org/CRAN/refmans/forecast/html/forecast.Arima.html)
- [R: modelos AR](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/ar.html) y [AIC](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/AIC.html)

Versiones utilizadas: `renv.lock` y `sessionInfo.txt` de cada ejercicio.
