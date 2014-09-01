/*
program: CrtWinEn.CMD
type:    REXXSAA-OS/2, OS/2 3.x
purpose: create enhanced windows session
version: 1.0
date:    1995-09-01
author:  Rony G. Flatscher (Rony.Flatscher@wu-wien.ac.at)
usage:   CRTWINENH [win-exe-file [parameters]]
         --- creates an enhanced, seemless, common WinOS2-session; starts given
             Windows program and supplies given parameters (e.g. a filename); if
             additional Windows programs are started, the existing WinOS2 
             session will be used
         --- if no Windows program is given, it defaults to program.exe

All rights reserved, copyrighted 1995, no guarantee that it works without
errors, etc. etc.

donated to the public domain granted that you are not charging anything (money
etc.) for it and derivates based upon it, as you did not write it,
etc. if that holds you may bundle it with commercial programs too

you may freely distribute this program, granted that no changes are made
to it; see also the '95 REXX Report from Miller & Freeman for REXX & WPS
*/

PARSE ARG exename param                         /* get arguments              */

progtype = "PROGTYPE=PROG_31_ENHSEAMLESSCOMMON;"
title    = "WinOS2 enhanced"
IF exename = "" THEN exename = "EXENAME=PROGMAN.EXE;"
                ELSE
                DO
                   title = title "(" || exename || ")"
                   exename = "EXENAME=" || exename || ";"
                END

IF param = "" THEN parameters = ""
              ELSE parameters = "PARAMETERS=" || STRIP(param) || ";"

objectid = "<RGF_WinEnhCommon>"

setup    = progtype || exename     || parameters || ,
           "SET WIN_ATM=1;"        ||,  /* make sure ATM is on                */
           "SET WIN_CLIPBOARD=1;"  ||,  /* allow clipboard exchange with OS/2 */
           "SET DPMI_MEMORY_LIMIT=128;" ||,/* make sure, enough memory defined*/
           "OPEN=DEFAULT;"         ||,
           "OBJECTID=" || objectid || ";"

location = "<WP_NOWHERE>"                       /* the "NOWHERE"-location     */

/* create object, if it exists already, replace it, finally open it           */
ok = SysCreateObject("WPProgram", title, location, setup, "R") 
SAY "creating -" ok(ok)

/* make sure, it is in the foreground                                         */
ok = SysSetObjectData(objectid, "Open=Default;")
SAY "setting  -" ok(ok)

EXIT

OK: PROCEDURE
   IF ARG(1) THEN RETURN "successful."
             ELSE RETURN "NOT succesful !"

