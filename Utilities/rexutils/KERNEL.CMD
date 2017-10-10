/* KERNEL              by Gord Snider  0000/00/00  v00.01.00  0000/00/00     */
current = Strip( Directory(), 'T', '\')         /* save fully qualified current directory for return */
SAY current                                     /* say current directory */
CALL next current                               /* call to check for sub-directories and files */
EXIT 0

next: PROCEDURE                                 /* hide old set of variables, enable new set */
PARSE ARG nextdir,spacer                        /* spacer is each line's indenting characters */
CALL SysFileTree Strip( nextdir, 'T', '\') || '\' || '*', 'dir.', 'DO'  /* are subfolders here? */
DO dir = 1 TO dir.0                             /* if any, make a list of them and process it */
   IF dir < dir.0 THEN leader = D2C(195)
                  ELSE leader = D2C(192)
  SAY spacer || ' ' || leader || SUBSTR( dir.dir, LASTPOS('\', dir.dir) + 1)
  IF leader = D2C(195) THEN leader = D2C(179)
                       ELSE leader = ' '
  CALL next dir.dir, spacer || ' ' || leader    /* pivot point of the recursion */
END dir                                         /* back to top of dir loop */
RETURN                                          /* a leaf has been reached */
