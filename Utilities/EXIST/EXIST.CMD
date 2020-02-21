/*  IF EXISTS

CALL EXIST fn type                                           'fn = DIR or FN.EXT   type = D dir -or- F file
IF RESULT = 0 THEN SIGNAL FOUND
IF RESULT = 1 THEN SIGNAL NOT FOUND
IF RESULT = 2 THEN SIGNAL BAD CALL
 */

CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
CALL SysLoadFuncs
ARG FN TYPE
IF TYPE = '' THEN TYPE = 'F'
IF FN = '' THEN SIGNAL BAD
SAY 'CHECKING FOR 'FN
RC = SysFileTree(FN, 'FILE', TYPE)
OK = RC
IF FILE.0 = 0 THEN OK = 1
EXIT OK

BAD:
SAY 'SYNTAX:  CALL EXIST [fn | dir] type         type = D (dir) -or- F (file)'
EXIT 2
