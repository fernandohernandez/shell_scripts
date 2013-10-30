Este script realiza las siguientes acciones sobre el directorio del theme o path que querramos subir a S3:

1- Realiza el minify (incremental) de los archivos CSS y JS creando los archivos correspondientes *.css.min y *.js.min 

2- Comprime (gzip, incremental) los archivos *.css.min y *.js.min creando los archivos correspondientes *.css.min.gz y *.js.min.gz

3- Upload a S3 con el header específico según la extensión del archivo de todos los archivos:
     Imágenes: *.jpg, *.gif, *.png
     Css y Js: *.css, *.js   
     Gziped: *.css.min.gz, *.js.min.gz
 
   Antes de realizar el upload chequea mediante un hash (MD5) que el archivo local difiera del remoto (S3) antes de subirlo.

REQUERIMIENTOS:
- /bin/bash
- php-cli (para ejecutar php en modo consola)
- java sun (para ejecutar el yuicompressor.jar)

INSTALACION Y CONFIGURACION:
Damos permiso de ejecucion a los scripts
$ chmod +x *.sh

Los headers utilizados en el upload a S3 se definen en headers.php

EJECUCIÓN:
$ ./update.sh [opciones] -l {ruta absoluta al directorio} -e {subruta local a sustraer de la ruta de S3 (nuestro path local)} [-b {bucket_name}]

Opciones (flags)
 -s Solo procesar los scripts *.css y *.js (no las imágenes)
 -n No Upload (Simulación)

Por ejemplo:
./update.sh -s -l /home/myuser/test/theme/ -e /home/myuser/test/ -b my_bucket

Esto esta subiendo a S3://my_bucket/theme
Solo los scripts *.css *.css.min.gz *.js *.js.mi.gz

En la primer ejecución el script pedirá los keys de amazon y se almacenarán en .amz_key y .secret_key respectivamente, si los keys fueron erróneos o se quiere usar otras credenciales hay que eliminar dichos archivos.

LOGS:
La ejecución genera 3 logs para cada etapa respectivamente:
- minify_cdn.log
- gzip_cdn.log
- upload_cdn.log
