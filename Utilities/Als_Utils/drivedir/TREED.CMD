/* #! /usr/bin/regina */
/* TRE.CMD     REXX CMD  by  Gord Snider  v1.0                               */
/* Treed.cmd   v1.1 Modified by Al Heath for Linux compatibility             */

C179 = d2c(179)
C192 = d2c(192)
C195 = d2c(195)

parse source OpSys . exname .
fsSeparator = '\'
if OpSys = 'UNIX' then do
   fsSeparator = '/'
   C179 = '│'
   C192 = '└'
   C195 = '├'
end

say ''
call rxfuncadd "sysloadfuncs", RexxUtil, "sysloadfuncs"
call sysloadfuncs

current = STRIP( DIRECTORY(), 'T', fsSeparator)
SAY SUBSTR(current, LASTPOS(fsSeparator, current) + 1)     /* Current directory name sans leading '\'. */
CALL next current                                          /* Pass the current directory name. */

say ''
EXIT 0                                                     /* When done the whole branch come here. */

NEXT: PROCEDURE expose fsSeparator C179 C192 C195
PARSE ARG nextdir,spacer                                   /* Pick up current directory name */
CALL SysFileTree nextdir||fsSeparator||'*', 'dir.', 'DO'   /* Pick up subdirectories of current directory. */
DO dir = 1 TO dir.0                                        /* Loop through all subdirectories. */
   IF dir < dir.0 THEN leader = C195    /* 195  */         /* Do something with each subdirectory name ... */
                  ELSE leader = C192    /* 192  */         /* output one screen line. */
   SAY spacer || ' ' || leader || SUBSTR( dir.dir, LASTPOS(fsSeparator, dir.dir) + 1)  /* Do something else. */
   IF leader = C195                                        /* Vertical Line? */
      THEN leader = C179                                   /* ?,? */
      ELSE leader = ' '                                    /* ' ' */
   CALL next dir.dir, spacer || ' ' || leader              /* Call 'NEXT' with lowest directory number left. */
END dir
RETURN
