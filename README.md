# Econometría aplicada en R

**Khoen San Martín · Ingeniería Comercial, mención Economía · Universidad Diego Portales**

Portafolio de seis ejercicios de Econometría II (2025), revisados y organizados para consulta pública en 2026. Incluye código en R, resultados e interpretación económica. Las entregas académicas originales se mantienen por separado.

## Aplicaciones destacadas

| Aplicación | Métodos | Resultado principal |
|---|---|---|
| [Pronóstico del IPM de Chile](proyectos/EE4/results/informe.md) | Modelos autorregresivos y evaluación temporal con 24 pronósticos | RMSE de 4,64, frente a 4,88 para la referencia estacional. Es una comparación histórica, no una garantía de desempeño futuro. |
| [Concentración y tarifas aéreas](proyectos/EE3/results/report.md) | MCO, efectos aleatorios y fijos; errores agrupados por ruta | Para 10 puntos porcentuales adicionales de participación, la asociación estimada pasa de 3,67% en MCO a 1,70% con efectos fijos. No se identifica un efecto causal. |
| [Fertilidad y oferta laboral](proyectos/EE1/results/informe.md) | MCO, variables instrumentales y diagnóstico de primera etapa | El intervalo convencional del estimador instrumental incluye cero; la relevancia del instrumento no prueba su exogeneidad. |

![Evaluación histórica del pronóstico del IPM](proyectos/EE4/results/figures/validacion_temporal.png)

## Otros ejercicios

- [EE2 · Anuncio de Metro y precios de vivienda](proyectos/EE2/results/informe.md): diferencias en diferencias con datos ficticios.
- [EE5 · Shock petrolero y producción industrial](proyectos/EE5/results/informe.md): rezagos distribuidos e inferencia HAC.
- [EE6 · Dinámica macroeconómica de un caso docente](proyectos/EE6/results/informe.md): VAR, causalidad de Granger, funciones impulso-respuesta y descomposición de varianza.

Los informes incluyen especificaciones, resultados, supuestos y límites de interpretación. Son aplicaciones académicas de métodos establecidos, no investigaciones originales sobre los mercados actuales.

## Código y reproducibilidad

Los seis análisis se ejecutan desde la raíz del proyecto con R 4.3.3 y las dependencias indicadas. La reproducción y las pruebas se completaron en Linux mediante [GitHub Actions](https://github.com/stkoen/econometria-aplicada-r/actions/runs/40306063209).

```bash
Rscript --vanilla scripts/install_dependencies.R
Rscript --vanilla run_all.R
Rscript --vanilla tests/check_all.R
```

Para ejecutar solo un ejercicio: `Rscript --vanilla run_all.R EE4`.

Las fuentes públicas de EE1 y EE3 se descargan en la primera ejecución. Las demás bases de trabajo están en `data/originales/`. `renv.lock` registra versiones de paquetes; Windows y macOS no se presentan como entornos verificados.

Documentación técnica: [fuentes y datos](docs/FUENTES.md), [cambios metodológicos](docs/CAMBIOS.md) y [comprobaciones](docs/COMPROBACIONES.md). Los registros adicionales se conservan en `docs/` para trazabilidad, sin ser necesarios para una primera lectura.

## Autoría y alcance

Los ejercicios y sus scripts corresponden al trabajo académico de **Khoen San Martín**. Los enunciados, datos y bibliotecas de terceros se atribuyen a sus respectivas fuentes. La versión para portafolio incorpora organización, correcciones y automatización de comprobaciones con herramientas de apoyo; esas herramientas no se presentan como coautoras.

La revisión no reemplaza las entregas originales ni modifica sus calificaciones. La reproducibilidad de los cálculos no demuestra, por sí sola, identificación causal ni validez de los supuestos de cada modelo.
