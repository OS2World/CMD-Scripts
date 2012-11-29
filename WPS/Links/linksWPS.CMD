@echo off
Rem Workaround to pass parameters cointaining // to linksRexx.cmd
Rem Taken from "Rexx Tips & Tricks 3.00"

Rem Enables drag-and-drop of HTML files, URL objects
Rem and Windows Internet shortcuts onto the Links program object.

REM *** init the environment variable for the parameters
 SET LinksREXXParms=
REM *** copy the parameters to the environment variable
 REM     (use a loop to handle more than 9 parameters)
 REM
:PLOOP
 IF '%1' == '' GOTO CALLREXX
      SET LinksREXXParms=%LinksREXXParms% %1
      SHIFT
 GOTO PLOOP
 
:CALLREXX
Rem For 640x480 with links in a window and WarpCenter on
 mode 110,35 
REM *** now call the REXX program
 LinksRex LinksREXXParms
