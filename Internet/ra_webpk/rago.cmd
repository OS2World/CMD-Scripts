/* REXX Scipt to start a windows viewer from WebEx */

parse arg filenmin
'COPY' filenmin 'f:\raplayer\RATEMP.RAM'

/* Call objst.exe, which will start the viewer.    */
/* The number is what you got when you dropped RAPlay on the FeelX icon */

'objst.exe 165578' 'f:\raplayer\RATEMP.RAM'
EXIT 0
