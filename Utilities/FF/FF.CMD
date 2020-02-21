/*  scan for text or file  */
ARG P1
'@echo off'
'DIR F:\'||P1' /F/S/B > F:\TEMP\FF'
'DIR D:\'||P1' /F/S/B >> F:\TEMP\FF'
'CLS'
'ECHO.'
'TYPE F:\TEMP\FF'
'DEL F:\TEMP\FF'
