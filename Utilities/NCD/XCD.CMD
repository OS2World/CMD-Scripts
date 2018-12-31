/* ================================================================== */
/* REXX XCD - A Norton Change Directory Utility for OS/2              */
/* Copyright (c) 1992 Larry Wasserman.  All Rights Reserved.          */
/* CompuServe  [76666,1043]                                           */
/*                                                                    */
/* Usage : XCD [ [/R] | [partial last node] ]                         */
/* ================================================================== */
SAY 'XCD ver 1.0 Copyright 1993 L. Wasserman'
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
/* Check to see if this is just a rebuild                             */
/* ================================================================== */
IF COMPARE(var1, '/R') = 0 THEN
   DO
      CALL REBUILD_TREE '\REXTREE.NCD';
      SIGNAL bailout;
   END

/* ================================================================== */
/* If \REXTREE does not exist, rebuild it and open it at the top      */
/* ================================================================== */
myfile = STREAM('\REXTREE.NCD', 'C', 'QUERY EXISTS');
IF LENGTH(myfile) = 0 THEN
   DO
     myfile = '\REXTREE.NCD';
     CALL REBUILD_TREE myfile;
     LINEIN(myfile,1,0);
   END

/* ================================================================== */
/* Read the Directory Tree. If no var1 parameter wa supplied then     */
/* enter all directory paths in the dir. stem, otherwise, if the      */
/* <arglen> characters of the last node = the var1 parameter, enter   */
/* the entire path in the dir. stem                                   */
/* ================================================================== */
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
/* Show the list of duplicate matches, and find out which one to CD    */
/* =================================================================== */
IF dups = 0 THEN
   DO
      SAY ''
      SAY 'XCD: Directory matching 'var1 'does not exist';
      SIGNAL bailout;
   END
IF dups = 1 THEN
   DO
      answer = 1;
      SIGNAL SWITCH;
   END
fini = 0;
DO UNTIL fini = 1
   SAY '';
   DO i = 1 to dups
      SAY '   ' i'. ' dir.i;
   END
   SAY '';
   x = CHAROUT(, '    To which directory do you want to switch? ');
   answer = SysGetKey();
   SAY ''
   IF C2X(answer) = 1B THEN
      SIGNAL bailout;
   IF ((DATATYPE(answer, 'W') = 0) | (answer < 1) | (answer > dups)) THEN
      DO
        SAY '';
        SAY '' ;
        SAY 'Invalid input...Enter a number from 1 to 'dups;
      END
   ELSE
      fini = 1
END

/* ================================================================== */
/* CD to the new directory, and exit                                  */
/* ================================================================== */
SWITCH:;
/* SAY ''; */
/* SAY 'Changing directory to 'dir.answer; */
'@CD' dir.answer;

BAILOUT:;
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
      SAY '';
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
