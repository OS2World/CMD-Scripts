/* REXX */
'@ECHO OFF'
PARSE SOURCE os2 type invocation
lastslash = LASTPOS('\',invocation)
path = SUBSTR(invocation,1,lastslash-1)
'set CSFUTILPATH='path
'set CSFCDROMDIR='path
path'\SERVICE.EXE'
