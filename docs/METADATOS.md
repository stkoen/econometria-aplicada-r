# Integridad de los archivos

Las dos bases XLSX se distribuyen con propiedades reducidas a título, responsable de la copia y fecha de revisión. Se retiraron rutas absolutas, identificadores de colaboración, miniaturas y propiedades de aplicación y última edición.

Las partes que contienen hojas, celdas, fórmulas, estilos y datos se conservaron byte por byte. El responsable de la copia no se atribuye la autoría de los datos; las fuentes se documentan en [FUENTES.md](FUENTES.md).

`data/manifest.json` registra los hashes SHA-256 de las versiones recibidas y distribuidas. Las bases CSV y RData conservan sus bytes originales. El registro técnico se mantiene en `auditoria_metadatos.json`.

Los PNG conservan información de resolución. La documentación y las versiones de paquetes en archivos de texto forman parte del contenido visible necesario para reproducir los análisis.
