# Datos y referencias

## Enunciado docente

Mauricio Tejada. *Ejercicio Empírico 3: El Mercado de Rutas Aéreas*.
Departamento de Economía, Universidad Diego Portales. Documento de 4 páginas
proporcionado previamente por el autor como `Ejercicio Empírico 3.pdf`.
Véase `ENUNCIADO.md` para la correspondencia entre requisitos y resultados.

## Datos

- Base: `airfare`, 4.596 filas, 14 variables originales.
- Procedencia original: Domestic Airline Fares Consumer Report, U.S. Department
  of Transportation; recopilación facilitada por Jiyoung Kwon a Wooldridge.
- Documentación del mantenedor: https://justinmshea.github.io/wooldridge/reference/airfare.html
- Repositorio oficial del paquete: https://github.com/JustinMShea/wooldridge
- Revisión fijada: `e95144d3d70e54c2afb4a6d3575f63fc60bfa6ec`.
- Archivo: https://raw.githubusercontent.com/JustinMShea/wooldridge/e95144d3d70e54c2afb4a6d3575f63fc60bfa6ec/data/airfare.RData
- MD5: `da5f3d5264aeb420b1d216279316bc7a`.
- SHA-256: `cda45863cac8268763a15af16955e8fd6c0c40187f5b28f0b2264999210edd95`.

No se incorpora la base al repositorio ni se atribuye su autoría a Khoen. Se
descarga de la fuente y se valida su identidad. El paquete fuente declara GPL-3;
no se extiende esa declaración a materiales del curso ni a otros documentos.

## Variables usadas

| Variable | Definición | Unidad |
|---|---|---|
| id | Identificador de ruta | Identificador |
| year | Año de observación | 1997–2000 |
| fare | Tarifa media de ida | Dólares nominales |
| bmktshr | Participación de la mayor aerolínea en la ruta | Fracción entre 0 y 1 |
| dist | Distancia de la ruta | Millas |

`bmktshr` no es un índice HHI. Los datos y el diseño no se extrapolan sin
justificación a Chile o al mercado actual.

## Métodos y software

- Croissant, Y. y Millo, G. (2008). Panel Data Econometrics in R: The plm Package.
  Journal of Statistical Software, 27(2). https://doi.org/10.18637/jss.v027.i02
- Documentación de Hausman y distinción entre sus versiones:
  https://search.r-project.org/CRAN/refmans/plm/html/phtest.html
- Documentación de covarianzas para panel:
  https://search.r-project.org/CRAN/refmans/plm/html/vcovHC.plm.html
- R Core Team; plm; sandwich; lmtest; ggplot2. Versiones realmente utilizadas en
  `results/sessionInfo.txt` y `renv.lock`.
