# Propiedades de los archivos de distribución

Las dos bases XLSX se distribuyen como copias con propiedades reducidas a
título del archivo, nombre del responsable de esta copia y fecha de revisión.
Se retiraron las propiedades de aplicación, última edición, rutas absolutas,
identificadores de colaboración y miniaturas. Las hojas, sus celdas, fórmulas,
estilos y datos se conservaron byte por byte dentro del paquete XLSX.

El nombre en las propiedades identifica al responsable de preparar la copia;
no atribuye la autoría de los datos. Sus fuentes se declaran en FUENTES.md.
Las bases recibidas originalmente se conservan fuera del repositorio. El
manifiesto separa el SHA-256 de la copia distribuida del archivo recibido.
Las otras dos bases mantienen los mismos bytes del archivo proporcionado.

Los gráficos PNG contienen resolución de imagen y no campos de autor,
comentarios, rutas o software. Los archivos R, CSV, JSON y Markdown son texto:
su documentación y las versiones de paquetes son contenido visible para
permitir la reproducción, no propiedades ocultas del archivo.

Las copias PDF entregadas aparte conservan solo título, fecha y, para el
informe propio, autor. Los enunciados de terceros no se atribuyen al usuario.
Se verificó igualdad del texto y de los píxeles de las 17 páginas. El cambio
de metadatos no corrige ni elimina información visible del informe original.

Los ZIP de distribución se reconstruyen sin comentarios ni campos extra de
sus miembros, con nombres relativos y permisos estándar. No incluyen rutas
del entorno de trabajo. Los metadatos que una plataforma o sistema operativo
añada después de la descarga quedan fuera de esta comprobación.
