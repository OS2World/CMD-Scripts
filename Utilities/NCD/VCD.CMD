/* ================================================================== */
/* REXX VCD - A Norton Change Directory Utility for OS/2              */
/* Copyright (c) 1992 Larry Wasserman.  All Rights Reserved.          */
/* CompuServe  [76666,1043]                                           */
/*                                                                    */
/* Usage : VCD [ [/R] | [partial last node] ]                         */
/* ================================================================== */
SAY 'VCD ver 1.0 Copyright 1993 L. Wasserman'
'@echo off'
PARSE UPPER ARG var1;
var1 = STRIP(var1);

/* ================================================================== */
/* Check to see if all REXX utility functions have been Loaded        */
/* ================================================================== */
IF 0 < RxFuncQuery('SysLoadFuncs') THEN 
   DO
      CALL RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'; 
      CALL SysLoadFuncs; 
   END;
/* ================================================================== */
/* Load the Virtual REXX utility functions                            */
/* ================================================================== */
CALL RxFuncAdd 'VInit', 'VREXX', 'VINIT'
initcode = VInit();
IF initcode = 'ERROR' THEN
   SIGNAL bailout;
SIGNAL ON FAILURE NAME bailout
SIGNAL ON HALT NAME bailout
SIGNAL ON SYNTAX NAME bailout
/* ================================================================== */
/* Check to see if this is just a rebuild                             */
/* ================================================================== */
IF COMPARE(var1, '/R') = 0 THEN
   DO
      CALL REBUILD_TREE '\REXTREE.NCD';
      SIGNAL bailout;
   END
/* ================================================================== */
/* If REXTREE.NCD does not exist, rebuild it and open it at the top   */
/* ================================================================== */
myfile = STREAM('\REXTREE.NCD', 'C', 'QUERY EXISTS');
IF LENGTH(myfile) = 0 THEN
   DO
     myfile = '\REXTREE.NCD';
     CALL REBUILD_TREE myfile;
     LINEIN(myfile,1,0);
   END

/* ================================================================== */
/* Read the Directory Tree. If the <arglen> characters of the last    */
/* node = the var1 parameter, enter the entire path in an array       */
/* ================================================================== */
dups = 1;
arglen = LENGTH(var1);
DO WHILE LINES(myfile) > 0
   dirpath = LINEIN(myfile);
   IF arglen = 0 THEN
      DO
         dir.dups = dirpath;
         dups = dups + 1;
      END
   ELSE   
      DO
         len = LENGTH(dirpath);
         x = LASTPOS('\',dirpath);
         str = RIGHT(dirpath, len - x);
         strcmp = LEFT(str,arglen);
         IF COMPARE(var1, strcmp) = 0 THEN 
            DO
               dir.dups = dirpath;
               dups = dups + 1;
            END
      END
END
dups = dups - 1;

/* =================================================================== */
/* If no matches were found, tell the user                             */
/* =================================================================== */
IF dups = 0 THEN
   DO
   msg.0 = 1
   msg.1 = ' Directory matching 'var1 'does not exist '
   CALL VDialogPos 50, 50
   rb = VMsgBox('VCD', msg, 1)
   SIGNAL bailout;
   END
/* =================================================================== */
/* If only one match was found, go directly to it                      */
/* =================================================================== */
IF dups = 1 THEN
   DO
      cdstring = dir.1;
      SIGNAL SWITCH;
   END

/* =================================================================== */
/* Show the list of duplicate matches, and find out which one to CD    */
/* =================================================================== */
list.0 = dups
DO i = 1 to dups
   list.i = dir.i;
   END
list.vstring = list.1          /* default selection */
CALL VDialogPos 50, 0
button = VListBox('Select a Directory', list, 40, 8, 3)
IF button = 'CANCEL' THEN
   SIGNAL bailout
cdstring = list.vstring

/* ================================================================== */
/* CD to the new directory, and exit                                  */
/* ================================================================== */
SWITCH:;
'@CD' cdstring;

BAILOUT:;
CALL VExit;
EXIT;

REBUILD_TREE:PROCEDURE
ARG myfile

SAY '';
rc = CHAROUT(STDOUT, '   Building Directory Tree ');

/* =================================================================== */
/* Get the list of directories on the current disk                     */
/* =================================================================== */
IF SysFileTree('\*.*', 'dirlst', 'DSO') > 0 THEN
   DO
      SAY 'Not enough memory to read the directory tree...terminating';
      SIGNAL bailout;
   END

/* ================================================================== */
/* Sort the list of directories                                       */
/* ================================================================== */
iLo = 1; iHi = dirlst.0;
DO FOREVER;
   IF iLo > iHi THEN LEAVE;
   i = iLo;
   cLo = SUBSTR(dirlst.iLo,3,LENGTH(dirlst.iLo)-2)
   cHi = SUBSTR(dirlst.iHi,3,LENGTH(dirlst.iHi)-2)
   DO FOREVER;
      IF i > iHi THEN LEAVE;
      cX = SUBSTR(dirlst.i,3,LENGTH(dirlst.i)-2)
      iSwap = 0;
      IF cX < cLo THEN DO;
         iSwap = 1;
         cExch = dirlst.i; dirlst.i = dirlst.iLo; dirlst.iLo = cExch;
         cLo = SUBSTR(dirlst.iLo,3,LENGTH(dirlst.iLo)-2)
         cX  = SUBSTR(dirlst.i,3,LENGTH(dirlst.i)-2)
      end;
      IF cX > cHi THEN do;
         iSwap = 1;
         cExch = dirlst.i; dirlst.i = dirlst.iHi; dirlst.iHi = cExch;
         cHi = SUBSTR(dirlst.iHi,3,LENGTH(dirlst.iHi)-2)
         cX  = SUBSTR(dirlst.i,3,LENGTH(dirlst.i)-2)
      end;
      IF iSwap < 1 THEN i = i+1;
   end;
   iLo = iLo+1; iHi = iHi-1;
   rc = CHAROUT(STDOUT, '.');
end;
SAY '';

/* =================================================================== */
/* Open (or create) the REXTREE.NCD file and write it                  */
/* =================================================================== */
CALL LINEOUT myfile, dirlst.1, 1;  /* opens file and overwrites first line */
DO i = 2 to dirlst.0
   CALL LINEOUT myfile, dirlst.i;
   IF RESULT = 1 THEN
      DO
         SAY 'Unable to write treefile...terminating';
         SIGNAL bailout;
      END
END
rc = LINEOUT(myfile);    /* closes file */
RETURN;
