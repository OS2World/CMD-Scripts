/* rexx biff open pmmail - D C Saville January 2002
   dave.saville@ntlworld.com */

IF RxFuncQuery('SysLoadFuncs') THEN DO
  Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  Call SysLoadFuncs
END

/* edit following path to find pmmail */

call sysopenobject 'd:\apps\southside\pmmail\pmmail.exe', 0, 1
