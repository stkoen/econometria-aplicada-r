# Concentración y tarifas aéreas

**Khoen San Martín · Econometría aplicada con R · Panel 1997–2000**

¿Cuánto cambia la asociación entre la participación de la aerolínea líder y la
tarifa al controlar diferencias persistentes entre rutas? Este proyecto compara
MCO agrupado, efectos aleatorios y efectos fijos sobre una base pública de
Wooldridge. Deriva de una entrega de Econometría II, UDP, segundo semestre de
2025; la versión revisada para portafolio se prepara en 2026.

**Resultados y límites:** [informe generado](results/report.md).

![Comparación de modelos](results/figures/model_comparison.png)

## Qué contiene

- Panel balanceado de 1.149 rutas, cuatro años y 4.596 observaciones.
- Obtención de datos de una revisión fija, con validación por hash y controles
  de integridad antes de estimar.
- MCO, RE (Swamy–Arora) y FE; efectos de año y errores agrupados por ruta.
- Hausman clásico de la entrega, distinguiendo sus supuestos de la inferencia
  agrupada de los coeficientes.
- Tablas y gráficos exportados automáticamente.
- Comprobaciones contra coeficientes e inferencia publicados en la entrega.

Es una aplicación académica de métodos estándar. Se reportan asociaciones
condicionadas: FE no resuelve automáticamente la causalidad inversa ni todos los
factores omitidos que cambian en el tiempo.

## Ejecutar desde cero

Requisitos: R 4.3.3 o posterior compatible y acceso a Internet para instalar
dependencias y descargar la base en la primera ejecución. Abrir este directorio
como proyecto RStudio o usar una terminal situada en su raíz.

```bash
# Terminal
Rscript --vanilla scripts/install_dependencies.R
Rscript --vanilla run.R
Rscript --vanilla tests/check_reproduction.R
```

La descarga y las exportaciones se realizan dentro del proyecto. No se necesita
restaurar `.RData`, establecer rutas personales ni ejecutar líneas manualmente.
La base descargada se guarda como caché y se excluye de Git.

### Fijar las versiones verificadas

`renv.lock` registra las versiones de la comprobación. Para restaurarlas:

```bash
Rscript --vanilla -e 'install.packages("renv", repos="https://cloud.r-project.org")'
Rscript --vanilla -e 'renv::restore(prompt=FALSE)'
Rscript --vanilla -e 'renv::load(); source("run.R")'
Rscript --vanilla -e 'renv::load(); source("tests/check_reproduction.R")'
```

En Linux, algunas dependencias de R pueden requerir compilador y bibliotecas de
desarrollo. `results/sessionInfo.txt` registra la sesión realmente utilizada.
La ruta sencilla instala versiones actuales; la ruta con `renv` fija las
versiones documentadas.

## Salidas

| Archivo | Contenido |
|---|---|
| `results/report.md` | Informe generado y límites de interpretación |
| `results/concentration_effects.csv` | Coeficientes, errores e intervalos |
| `results/coefficients_cluster.csv` | Todos los coeficientes de cada modelo |
| `results/descriptive_by_year.csv` | Estadísticas anuales |
| `results/hausman_tests.csv` | Contraste clásico de Hausman |
| `results/pooled_ci_comparison.csv` | Intervalos usuales, HC1 y agrupados de MCO |
| `results/re_transformation.csv` | Parámetro de cuasidesvío de medias de RE |
| `results/reproduction_original.csv` | Comparación con referencias de 2025 |
| `results/distance_elasticities.csv` | Elasticidades parciales de distancia |
| `results/figures/` | Gráficos exportados |

## Trazabilidad

[Fuentes y diccionario](docs/FUENTES.md) ·
[Correcciones, ampliaciones y asistencia de IA](docs/REVISION.md) ·
[Comprobaciones efectivamente realizadas](docs/COMPROBACIONES.md) ·
[Correspondencia con el enunciado recuperado](docs/ENUNCIADO.md).

Las entregas originales se conservan por separado. La versión revisada no
incluye identificadores personales, capturas de notas ni bases de terceros.
El flujo de GitHub Actions queda preparado; su ejecución remota solo podrá
comprobarse después de publicar el repositorio.
