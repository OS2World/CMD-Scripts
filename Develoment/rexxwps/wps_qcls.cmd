/* Program name:  WPS_QCLS.CMD  Title: Figure 4              */
/* REXX Report              Issue: Summer '95, page 42-51    */
/* Article title: The Workplace Shell: Objects to the Core   */
/* Author: Rony G. Flatscher                                 */
/* Description: utilizing REXX to communicate with the       */
/*              Workplace Shell                              */
/* Program requirements: OS/2 Warp                           */
/*                                                           */


/* WPS_QCLS.CMD: query and display installed WPS object classes     */

/* load OS/2's RexxUtil functions, if not loaded already            */
IF RxFuncQuery('SysLoadFuncs') THEN
DO
    CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
    CALL SysLoadFuncs
END

CALL SysQueryClassList "ObjCls."   /* get a list of object classes  */
CALL sort                          /* sort in alphabetic order      */

SAY "The following WPS object classes are installed:"
DO i = 1 TO ObjCls.0
   PARSE VAR ObjCls.i classname classDLL
   SAY RIGHT(i, 4) LEFT(classname" ", 35, ".") classDLL
END
EXIT

/* one of Knuth's algorithms; sort object classes in stem ObjCls.   */
SORT: PROCEDURE EXPOSE ObjCls.
   M = 1                           /* define M for passes           */
   DO WHILE (9 * M + 4) < ObjCls.0
      M = M * 3 + 1
   END

   DO WHILE M > 0                  /* sort stem                     */
      K = ObjCls.0 - M
      DO J = 1 TO K
         Q = J
         DO WHILE Q > 0
            L = Q + M
            /* make comparisons case-independent                    */
            IF TRANSLATE(ObjCls.Q) <<= TRANSLATE(ObjCls.L) THEN
               LEAVE
            tmp      = ObjCls.Q    /* switch elements               */
            ObjCls.Q = ObjCls.L
            ObjCls.L = tmp
            Q = Q - M
         END
      END
      M = M % 3
   END
   RETURN
