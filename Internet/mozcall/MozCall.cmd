@ECHO OFF
Rem 
Rem *** OS/2 Batch program to launch MCall with
Rem     URIs among the command-line parameters
Rem
Rem *** Thanks for the idea fly out to Mark Crocker!!!!
Rem 
Rem *** init the environment variable for the parameters
SET REXXParms=

Rem *** copy the parameters to the environment variable
Rem     (use a loop to handle more than 9 parameters)

:PLOOP
IF "%1" == "" GOTO CALLREXX
SET REXXParms=%REXXPARMS% %1
SHIFT
GOTO PLOOP
 
:CALLREXX
Rem *** now call the REXX program
Rem *** and pass along the parameters, anyway :)
SET BATCHFILE=%0
MCall %REXXPARMS%
