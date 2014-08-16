/*

   MkBkObj - create a "book"/documentation object
   Version 0.21

   (C) 1994-95 by Ralf G. R. Bergs <rabe@rwth-aachen.de>
   Released as "Freeware"

   accepts as parameters path specs to doc files
   creates a program object that calls VIEW.EXE if the path specs points
     to an .INF files, otherwise calls E.EXE


   History:

   0.21   03/16/95   simplify stem/ext parsing algorithm (thanks to
                       Paul Gallagher <paulg@resmel.bhp.com.au> for
                       suggesting this)

   0.2    10/23/94   only load 'SysCreateObject' if not yet resident
                       (thanks to Jason B. Tiller
                       <jtiller@ringer.jpl.nasa.gov> for suggesting this)
                     use "lastpos" instead of "pos" to separate extension
                       (thanks to Jason B. Tiller
                       <jtiller@ringer.jpl.nasa.gov> for suggesting this)
                     use "substr" with a default argument (thanks to Jason
                       B. Tiller <jtiller@ringer.jpl.nasa.gov> for suggesting
                       this)
                     improved error check
                     give usage notice if necessary

   0.1    10/17/94   added "MINIMIZED=YES" to install program (thanks to
                       Don Hawkinson <don.hawkinson@twsubbs.twsu.edu>)
                     corrected minor bug in calculation of "ext" when
                       filename had no extension

   0.01   09/15/94   initial release

 */

'@echo off'

parse source progname
progname = word( progname, 3 )


if arg()>0 then do

  needfunc = RxFuncQuery( 'SysCreateObject' )
  if needfunc then do
    ret = RxFuncAdd( 'SysCreateObject', 'RexxUtil', 'SysCreateObject' )
    if ret then do
      say progname || ": Error: Registration of 'SysCreateObject' failed."
      exit 1
    end
  end /* if needfunc */

  do i=1 to words( arg( 1 ) )
    path = word( arg( 1 ), i )

    /* separate "stem" and extension
       example:
         C:\DOS\KEYB.COM: name="KEYB", ext="COM" */

/*
    name = filespec( "name", path )
    p = lastpos( ".", name )
    if p>0 then do
      stem = substr( name, 1, p-1 )
      ext = substr( name, p+1 )
    end
    else do
      stem = name
      ext = ''
    end
*/
    name = filespec("name", path)
    parse var name stem'.'ext

    if translate( ext ) = "INF" then do
      viewer = "VIEW.EXE"
    end
    else do
      viewer = "E.EXE"
    end

    ret = SysCreateObject( 'WPProgram', Name, '<WP_DESKTOP>', ,
        'OBJECTID=<Bk_' || Stem || '>;EXENAME=' || viewer || ';PARAMETERS=' ,
        || path, 'U' )
    if \ret then do
      say progname || ": Error: Creation of object <Bk_" || Stem || ,
                      "> failed."
      exit 1
    end

  end /* do i=1 to arg() */

  if needfunc then do
    ret = RxFuncDrop( 'SysCreateObject' )
    if ret then do
      say progname || ": Error: De-registration of 'SysCreateObject' failed."
      exit 1
    end
  end /* if needfunc */

end /* if arg()>0 */

else do
  say "Usage: " || progname || " <filespec> {<filespec>}"
end /* else */
