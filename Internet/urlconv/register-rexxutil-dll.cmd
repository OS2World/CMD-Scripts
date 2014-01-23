/* $Id: register-rexxutil-dll.cmd,v 1.1 1999-01-31 10:36:17-05 rl Exp $ */

/*************************************************************************
 *                                                                       *
 * register-rexxutil-dll.cmd                                             *
 * Register Rexx System Utilities Library from RexxUtil.dll              *
 *                                                                       *
 *************************************************************************/

rc = rxFuncAdd( 'sysLoadFuncs', 'rexxUtil', 'SysLoadFuncs' )

if rc \= 0 then
  say 'Cannot (re-)register RexxxUtil functions, may be registered already'
else
  do
  call sysLoadFuncs
  say 'RexxUtil.dll functions registered'
  end

exit 0
