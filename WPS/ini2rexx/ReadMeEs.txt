¨Qu‚ es INI2Rexx?
-----------------
INI2Rexx es una herramienta que facilita la congelaci¢n, edici¢n y
mantenimiento de archivos INI cuyo comportamiento se quiere ajustar exactamente
al gusto.

Funciona generando un programa rexx capaz de recrear nuevamente el archivo INI
original cuando es ejecutado. ¨Qu‚ ventajas tiene esto entonces?
-Se puede editar el programa rexx con cualquier editor de texto ASCII.
-El archivo INI se genera de forma autom tica una vez que se ha finalizado la
edici¢n, lo que puede resultar muy £til para tareas automatizadas.

Con la idea de facilitar la edici¢n, el programa rexx generado contiene tanto
texto como resulte posible. Tambi‚n se vuelcan las claves binarias en
hexadecimal con un comentario que contiene la transcripci¢n ASCII
correspondiente, y se hace un volcado mixto (esta vez sin transcripci¢n hexa
-> ASCII) de las claves con valores mixtos.

Requerimientos:
---------------
FastINI.DLL, incluida en el archivo de distribuci¢n. Es copyright de Dennis
Bareis. http://www.ozemail.com.au/~dbareis

Errores / limitaciones conocidas.
---------------------------------
Un usuario ha informado que tuvo que ejecutar dos veces el script rexx para
recrear un archivo INI con el mismo nombre que el archivo INI del sistema.

Historia:
---------
Versi¢n 0.1, revisi¢n 2:
~~~~~~~~~~~~~~~~~~~~~~~~
-Ahora se utiliza RxFuncQuery para ver si es necesario realizar una llamada
a SysLoadFuncs y otras funciones externas. Tambi‚n se utiliza en los programas
rexx generados.
-Eliminada la molestia de los comentarios que se cerraban involuntariamente al
hacer un volcado hexadecimal.

Versi¢n 0.1, revisi¢n 1:
~~~~~~~~~~~~~~~~~~~~~~~~
Primera versi¢n p£blica.


Espero que el programa sea de utilidad a alguien...

Cualquier tipo de comentario ser  MUY apreciado.

Alfredo Fern ndez D¡az, alfredo arroba netropolis-si punto com
