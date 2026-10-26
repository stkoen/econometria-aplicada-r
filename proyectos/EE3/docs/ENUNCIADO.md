# Correspondencia con el enunciado recuperado

Referencia docente: Mauricio Tejada, *Ejercicio Empírico 3: El Mercado de Rutas
Aéreas*, Departamento de Economía, Universidad Diego Portales, 4 páginas.
El autor había proporcionado este archivo como `Ejercicio Empírico 3.pdf`.
Se ha leído el documento completo. El PDF docente se conserva por separado.

| Pregunta | Requisito | Dónde se aborda |
|---|---|---|
| 1 | Promedio, mínimo y máximo anuales de tarifa, concentración y distancia | `descriptive_by_year.csv` y figuras anuales |
| 2 | MCO agrupado con efectos de año; cambio de concentración de 0,1 | `coefficients_cluster.csv` y `concentration_effects.csv` |
| 3 | Comparar intervalo usual MCO con errores robustos | `pooled_ci_comparison.csv`; HC1 y agrupación por ruta se identifican por separado |
| 4 | Relación cuadrática en log(distancia), vértice y soporte observado | `distance_minimum.csv`, `distance_elasticities.csv` e informe |
| 5 | RE con efectos de año y efecto de un aumento de 0,1 | Tablas de modelos y efectos |
| 6 | FE, comparación con RE e interpretación de lambda | Tablas de modelos, `re_transformation.csv` e informe |
| 7 | Dos ejemplos de heterogeneidad fija y posible correlación | Apartado de alcance del informe |
| 8 | Valoración de la relación y elección apoyada en Hausman | `hausman_tests.csv` y discusión de identificación |

Todas las rutas de resultados de esta tabla están bajo `results/`.

## Precisiones de la revisión

El enunciado llama punto de inflexión al vértice de la cuadrática. La revisión
usa el término mínimo/vértice por precisión matemática. La terminología usada
en la entrega, por tanto, seguía la indicación docente; no se presenta como un
incumplimiento del estudiante.

Aunque la descripción de `bmktshr` menciona porcentajes, la base la almacena
como fracción entre 0 y 1 y las preguntas usan un cambio de 0,1. Se interpreta
como aumento de 10 puntos porcentuales, no de 0,1 puntos porcentuales.

El enunciado pide inferencia robusta pero no impone un Hausman auxiliar robusto,
validación predictiva ni un diseño causal adicional. No se convierten esas
ampliaciones potenciales en requisitos de la entrega. La revisión para
portafolio explicita límites de identificación y documenta la ejecución.
