/*********************************************************************/
/*                                                                   */
/*  MMFIX.CMD - version 1.1                                          */
/*  Copyright (C) R L Walsh 1997 - All Rights Reserved               */
/*                                                                   */
/*  email the author at rlwalsh@packet.net                           */
/*                                                                   */
/*********************************************************************/

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs
address cmd

/* show the intro message */

say ''
say ' **********************************************************'
say ' *  MMFIX.CMD - version 1.1                               *'
say ' *  Copyright (C) R L Walsh 1997 - All Rights Reserved    *'
say ' *                                                        *'
say ' *  email the author at rlwalsh@packet.net                *'
say ' **********************************************************'
say ''
say ' MMFIX lets you deregister selected WPS Multimedia classes'
say ' without having to deregister all of them.  It will make a'
say ' copy of MMPARTS.DLL and patch it.  You will have to edit'
say ' config.sys, then run MMDEREG.CMD.  This version supports'
say ' Warp v4 GA, or v4 with Fixpack 1 or Fixpack 3 applied'
say ''
say ' Do you want to continue?  If yes, press "Y" then "Enter"'

pull answer
if left( strip(answer), 1) \= 'Y' then
    do
        say ' Aborting...'
        exit
    end

/* get source and target info */

basedir = GetBaseDir()
srcfile = GetSrcFile(basedir)
destdir = GetDestDir(basedir)

/* copy the dll */

'@copy /b' srcfile '> NUL'

if rc \= 0 then
    do
        say ' Error!  Unable to copy' srcfile 'to' destdir
        say ' Aborting...'
        exit
    end

/* figure out which version we're patching */

patchfil = 'patchmm.fil'
version = GetVersion(patchfil)

say ''
if version = 23 then
    say ' Patching Warp v4 with no fixpacks'
else
if version = 24 then
    say ' Patching Warp v4 with Fixpack 1'
else
if version = 27 then
    say ' Patching Warp v4 with Fixpack 3'
else
do
    say ' Error!  This version of MMPARTS.DLL is not supported.'
    say ' MMFIX only supports Warp v4 with no fixpacks or with'
    say ' Fixpacks 1 or 3.  Read README.FIX for instructions on'
    say ' how to patch your version manually.  Aborting...'
    exit
end

/* create a patch file for the appropriate version */

call BuildPatchFile patchfil, version

/* do it, then get the result */

'@patch' patchfil '/a | RXQUEUE'
pull ok
say ' ' || ok
say ''

/* display result */

if ok = 'PATCHES APPLIED TO MMPARTS.DLL' then
    do
        say ' Now, edit config.sys and add "' || destdir || '"'
        say ' to the LIBPATH *before* "' || basedir || '\DLL"'
        say ' e.g.  LIBPATH=F:\MMOS2\TEMPDLL;.;F:\OS2\DLL;F:\MMOS2\DLL;'
        say ''
        say ' When you are done, run MMDEREG.CMD, then reboot'
    end
else
if (left(ok,7) = 'SYS1595') & (IsFilePatched(patchfil, version)) then
    do
        say ' Error!  You did not need to run MMFIX because'
        say ' ' || srcfile 'already has this patch!'
        say ' You can run MMDEREG.CMD at any time.'
    end
else
    do
        say ' Error!  The patch failed for unknown reasons.'
        say ' Aborting...'
    end

say ''

/* main exit */

exit

/*********************************************************************/

GetBaseDir: procedure

base = value('MMBASE',,'OS2ENVIRONMENT')

if base = '' then
    do
        say ''
        say ' Enter the path for your MMOS2 directory,'
        say ' then press "Enter" (leave blank to quit)'
        say ' e.g.  C:\MMOS2'
        pull answer
        base = strip(answer)
        if base = '' then
            do
                say ''
                say ' Nothing entered.  Aborting...'
                exit
            end
    end

base = strip(base, T, ';')
base = strip(base, T, '\')

return base

/*********************************************************************/

GetSrcFile: procedure

ARG base

src = base || '\DLL\MMPARTS.DLL'

ok = stream( src, 'c', 'query exists')
if ok = '' then
    do
        say ' Error!  Unable to locate' src
        say ' Aborting...'
        exit
    end

return src

/*********************************************************************/

GetDestDir: procedure

ARG base

dest = base || '\TEMPDLL'

rc = SysMkDir(dest)

if (rc \= 0) & (rc \= 5) then
    do
        say ' Error!  Unable to create' dest
        say ' Aborting...'
        exit
    end

if directory(dest) = '' then
    do
        say ' Error!  Unable to change the directory to' dest
        say ' Aborting...'
        exit
    end

return dest

/*********************************************************************/

GetVersion: procedure

ARG filename

line. = ''
line.1 = 'FILE MMPARTS.DLL'
line.2 = 'VER 1743BD   402349424D3A392E3233234000'

call WritePatchFile
'@patch' filename '/a | RXQUEUE'
pull ok

if left(ok,7) = 'SYS1600' then
    return 23

if left(ok,7) \= 'SYS1595' then
    return 0

line.2 = 'VER 1752ED   402349424D3A392E3234234000'

call WritePatchFile
'@patch' filename '/a | RXQUEUE'
pull ok

if left(ok,7) = 'SYS1600' then
    return 24

if left(ok,7) \= 'SYS1595' then
    return 0

line.2 = 'VER 174D85   402349424D3A392E3237234000'

call WritePatchFile
'@patch' filename '/a | RXQUEUE'
pull ok

if left(ok,7) = 'SYS1600' then
    return 27
else
    return 0

/*********************************************************************/

BuildPatchFile: procedure

ARG filename, ver

line. = ''
line.1 = 'FILE MMPARTS.DLL'

if ver = 23 then
    do
        line.2 = 'VER 1743BD   402349424D3A392E3233234000'
        line.3 = 'VER 17466E   0D534F4D496E69744D6F64756C6501'
        line.4 = 'CHA 17466E   0D54'
    end
else
if ver = 24 then
    do
        line.2 = 'VER 1752ED   402349424D3A392E3234234000'
        line.3 = 'VER 17559E   0D534F4D496E69744D6F64756C6501'
        line.4 = 'CHA 17559E   0D54'
    end
else
if ver = 27 then
    do
        line.2 = 'VER 174D85   402349424D3A392E3237234000'
        line.3 = 'VER 175036   0D534F4D496E69744D6F64756C6501'
        line.4 = 'CHA 175036   0D54'
    end
else
    do
        say ' Error!  Invalid parameter passed to BuildPatchFile'
        say ' Aborting...'
        exit
    end

call WritePatchFile

return

/*********************************************************************/

IsFilePatched: procedure

ARG filename, ver

line. = ''
line.1 = 'FILE MMPARTS.DLL'

if ver = 23 then
    line.2 = 'VER 17466E   0D54'
else
if ver = 24 then
    line.2 = 'VER 17559E   0D54'
else
if ver = 27 then
    line.2 = 'VER 175036   0D54'
else
    do
        say ' Error!  Invalid parameter passed to IsFilePatched'
        say ' Aborting...'
        exit
    end

call WritePatchFile
'@patch' filename '/a | RXQUEUE'
pull ok

if left(ok,7) = 'SYS1600' then
    return 1
else
    return 0

/*********************************************************************/

WritePatchFile:

rc = SysFileDelete(filename)

rc = lineout(filename, line.1, 1)

if rc = 0 then
    do
        x = 2
        do while line.x <> ''
            rc = lineout(filename, line.x)
            if rc \= 0 then leave
            x = x + 1
        end
    end

rc2 = lineout(filename)

if rc \= 0 then
    do
        say ' Error!  Unable to write' filename
        say ' Aborting...'
        exit
    end

return

/*********************************************************************/

