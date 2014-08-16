/*

   Installs the MkBkObj utility on the Desktop

   (C) 1994-95 by Ralf G. R. Bergs <rabe@rwth-aachen.de>
   Released as "Freeware"

 */

'@echo off'

parse source progname
progname = word( progname, 3 )

Say "Where do you want to install MkBkObj? (<CR> to quit) "
pull dest
if dest="" then do
  exit
end
'copy' MkBkObj.cmd dest

/* strip trailing backslash in "?:\" or "?:\foobar\" style paths */
if lastpos( "\", dest ) = length( dest ) then do
  dest = left( dest, length( dest ) - 1 )
end

needfunc = RxFuncQuery( 'SysCreateObject' )
if needfunc then do
  ret = RxFuncAdd( 'SysCreateObject', 'RexxUtil', 'SysCreateObject' )
  if ret then do
    say progname || ": Error: Registration of 'SysCreateObject' failed."
    exit 1
  end
end /* if needfunc */

ret = SysCreateObject( 'WPProgram', 'Make Book^Object', '<WP_DESKTOP>', ,
        'OBJECTID=<MkBkObj>;EXENAME=' || dest || '\MkBkObj.CMD' || ,
        ';MINIMIZED=YES', 'U' )

if \ret then do
  say progname || ": Error: Creation of object <MkBkObj> failed."
  exit 1
end

if needfunc then do
  ret = RxFuncDrop( 'SysCreateObject' )
  if ret then do
    say progname || ": Error: De-registration of 'SysCreateObject' failed."
    exit 1
  end
end /* if needfunc */
