# Comprobaciones de este bloque

Fecha de revisión: 25 de octubre de 2026.

## Resultado

La versión revisada reprodujo los resultados centrales de la entrega original
en un proceso de R limpio. Después se copió el proyecto a otra carpeta sin la
base descargada ni las salidas, se volvió a ejecutar y se compararon sus tablas.

| Referencia de la entrega | Original, redondeado | Reproducción |
|---|---:|---:|
| Coeficiente de concentración, MCO | 0,3601 | 0,3601203557 |
| Coeficiente de concentración, RE | 0,2090 | 0,2089934796 |
| Coeficiente de concentración, FE | 0,1689 | 0,1688589805 |
| Hausman, estadístico | 9,9967 | 9,9967275696 |
| Hausman, p-valor | 0,04048 | 0,0404828417 |

Se usó una tolerancia de 0,0001 en los coeficientes, acorde con el redondeo
publicado. Los nueve CSV generados fueron idénticos byte por byte entre las dos
carpetas de ejecución. Las comprobaciones de `tests/check_reproduction.R`
pasaron en ambas carpetas. Las tres figuras exportadas se inspeccionaron
visualmente.

## Archivo original y alcance

El análisis sintáctico del script exacto recibido devuelve:

```text
Script_EE3.R:162:1: unexpected '}'
```

Eso impide ejecutar íntegramente ese archivo mediante `source()`. No permite
concluir que los resultados de la entrega fueran inventados o que no se
hubieran obtenido ejecutando otra versión o partes del script. Los números
anteriores sí han sido reproducidos con los datos públicos.

Los hashes de los archivos originales permanecieron iguales después del
trabajo. No se sobrescribieron las entregas ni se incorporó su identificador
personal a la versión revisada.

## Entorno y límites de la comprobación

- R 4.3.3, Linux / Ubuntu 24.04, x86-64.
- Versiones detalladas en `results/sessionInfo.txt`; 43 registros de paquetes
  en `renv.lock`, incluidas dependencias transitivas.
- Se comprobaron descarga, hash, integridad de datos, ejecución, resultados
  numéricos, exportaciones y repetición en una carpeta nueva.
- La restauración completa de `renv.lock` en otro sistema operativo y la
  ejecución remota de GitHub Actions quedan sin comprobar. No se presentan
  como pruebas superadas.
- Se recuperó y leyó el enunciado del EE3. La correspondencia con sus ocho
  preguntas se documenta en `ENUNCIADO.md`. La pauta no está recuperada: no se
  emite una nueva calificación académica ni se audita cada afirmación del PDF
  original.
- Este bloque no comprueba todavía los otros cinco ejercicios ni el proyecto
  posterior sobre decisiones de crédito.
