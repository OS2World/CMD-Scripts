/* Install for HL_News */


/*
this file requires rexxlib!
It makes two directorys one is sites directory
the other is loads directory for use by HL_News.

*/

Parse arg Quiet
if Quiet=1 then '@echo off'
/*   Rexx Function Extensions:  */

/*      Add Extended REXX Functions.  */
junk='Found RexxUtil DLL already available.'
If RxFuncQuery('SysLoadFuncs')=1 Then
  Do
    rexxutils=1
    junk='Loaded RexxUtils DLL functions locally.'
    If RxFuncAdd('SysLoadFuncs','RexxUtil','SysLoadFuncs')=0 Then Call SysLoadFuncs
     Else
      Do
        Say 'HL_News Unable to register OS/2 RexxUtils DLL functions.'
        Say
        Exit
      End
  End
if Quiet<>1 then say junk

/*      Add Quercus REXXLIB Functions.  */
text='Found RexxLib DLL already available.'
If RxFuncQuery('rexxlibregister')=1 Then
  Do
    quercuslib=1
    text='Loaded RexxLib DLL functions locally.'
    If RxFuncAdd('rexxlibregister','rexxlib','rexxlibregister')=0 Then Call RexxLibRegister
     Else
      Do
        Say 'HL_News Unable to register Quercus RexxLib DLL functions.'
        Say
        If rexxutils Then Call SysDropFuncs
        Exit 
      End
  End

if Quiet<>1 then say text



rc=dosisdir('SITES')
if rc=0 then cd=dosmkdir('SITES')
if quiet<>1 then do
if cd=1  then say 'SITES dir created ok'
else say 'SITES dir not created '
end

rc=dosisdir('LOADS')
if rc=0 then cd=dosmkdir('LOADS')
if Quiet<>1 then do
if cd=1 then say 'LOADS dir created ok'
else say 'LOADS dir not created '
end
