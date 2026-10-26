# Qué se conserva y qué cambia

## Entrega original

Trabajo académico de Khoen San Martín, Econometría II, Universidad Diego
Portales, segundo semestre de 2025. La nota de la evaluación académica no se
usa como prueba de ejecución ni como medida de validez causal.

La entrega original permanece en sus archivos originales y no se sobrescribe.
No se incorpora el PDF original a esta versión pública porque contiene un
identificador personal. Se genera un informe revisado desde resultados nuevos.

Identidad de los archivos recibidos (SHA-256):

- Script: `0fb67e96b0b8e7ab634f7f4c8035c43099368128d52d9c0e2068754732731dfe`.
- PDF: `8afe4af61ee14f7b0208332b3f9085617663219fa6a68593d503e02cd52bd921`.

## Correcciones necesarias para ejecución y coherencia

1. El script original incluye una llave de cierre sin apertura en la línea 162.
   El error se documenta mediante análisis sintáctico del archivo recibido.
   No permite inferir qué versión o selección de líneas se ejecutó al entregar.
2. Se eliminan bloques RE repetidos y se ordena una única ejecución de los modelos.
3. Los gráficos se producen desde el mismo script y se exportan automáticamente.
4. La base se obtiene de una revisión fija y se verifica por hash; se validan
   dimensiones, claves, rangos y balance antes de estimar.
5. Se exportan tablas desde los modelos: no se transcriben manualmente números.
6. Se reemplazan afirmaciones causales no identificadas por asociaciones
   condicionadas. FE no resuelve simultaneidad ni todos los factores omitidos.
7. Se distingue un mínimo de una parábola de un punto de inflexión, y se
   especifican las coordenadas logarítmicas de la relación con distancia. El
   enunciado también usa 'punto de inflexión': esta precisión no se atribuye
   como incumplimiento de la indicación docente por parte del estudiante.
8. Se corrige la expresión 'porcentaje más en log(fare)': el cambio porcentual
   reportado se refiere a la tarifa ajustada derivada de la especificación logarítmica.

## Ampliaciones para portafolio

- Distinción explícita entre el Hausman clásico y la inferencia agrupada de los
  coeficientes. No se presenta el contraste clásico como robustificado.
- Cambio porcentual exacto, junto con la aproximación original.
- Pruebas contra referencias numéricas publicadas en 2025.
- Dependencias fijadas, instrucciones de ejecución y comprobación automatizable.

El enunciado fue recuperado y leído después de preparar la primera versión.
`ENUNCIADO.md` vincula sus ocho preguntas con las salidas. Se incorporaron
comparaciones usual/HC1/agrupada, mínimos y máximos de distancia y el parámetro
de transformación RE. La pauta de corrección no se ha recuperado. Las mejoras
para portafolio se distinguen de los requisitos docentes.

## Autoría y asistencia

El proyecto deriva de un trabajo académico entregado por Khoen San Martín.
La entrega declara el uso de herramientas de IA como apoyo para el código y el formato. Esta revisión también las emplea en depuración, documentación y comprobaciones; los cambios y resultados fueron revisados por el autor.
La responsabilidad de revisar, entender y presentar el trabajo corresponde al
autor; no se atribuye originalidad a la base pública ni a los métodos estándar.

## Publicación

Esta aplicación forma parte del repositorio público
https://github.com/stkoen/econometria-aplicada-r desde el 26 de octubre de 2026.
Los datos se descargan de su fuente durante la primera ejecución y se excluyen
de Git. Las comprobaciones se documentan en los archivos de este proyecto y
en la documentación general del repositorio.
