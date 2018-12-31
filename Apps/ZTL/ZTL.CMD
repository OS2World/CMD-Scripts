/**/signal STARTZTL/*---> ZTL /? for help <----*/
/*
    ÉÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊ»
    ¹              Zip to Lzh 1.7               Ì
    ¹            ------------------             Ì
    ¹   (or Any archive to Any other archive)   Ì
    ¹                ----------                 Ì
    ¹                    ZTL                    Ì
    ÈËËËËËËËËËËËËËËËËËËËËËËËËËËËËËËËËËËËËËËËËËËË¼

    ---------------------------------------------
   [ totally freeware by Tim Middleton 1:250/202 ]
    ---------------------------------------------

*** Modify the following few variables to reflect the names and
*** command lines of your archivers.  Any number of archivers is
*** supported but must have the format:

    EXT.1='archiver unarchive_command'
    EXT.2='archiver archive_command'

        EXT is the extension of the archive format.
        See defaults directly below and all should be clear.

                    Archiver Definitions . . .                  */
ARCHIVERS:

    ZIP.1='gnuunzip'
    ZIP.2='pkz2'
    ARJ.1='unarj e'
    ARJ.2=''             /* there is no arj compression for os/2 YET */
    LZH.1='lh x /o'
    LZH.2='lh a /o'

             /* end of archiver defintions */
return
PROCESS: procedure                /* MODIFY THIS!!!!!!!! */
/********************************************************
 ***  This routine is run on the unarchived files     ***
 ***  Add here any files you might like deleted.      ***
 ***  If you don't use McAfee's Scan.exe then delete  ***
 ***  That line.... add whatever you want in quotes.  ***
 ********************************************************/

    'Os2Scan *.* /nomem /nopause /noexpire'
    'del toxic.doc >nul'
    'del readme.ros >nul'

/********* Okay, don't modify any more!! ************/
rc=0
return
HELP:
cls;say;say id;say
say'The command structure is:';say
say'ZTL [<filespec>] [/b] [/d] [/i] [/t<archive-type>] [/w<drive>] [/?]'
say;say'    <filespec> - The file(s) to convert. (default is *.zip)'
say'            /b - Update FILES.BBS with new extension.'
say'            /d - do NOT delete the original archive'
say'            /i - do NOT convert internal archives'
say'            /t - extension of target archive. (default is LZH)'
say'            /w - is an optional work drive (ie. E:)'
say'            /? - this screen';say
say'                (for more details see the ZTL.DOC'
say'           to change archiver commands see program listing)'
exit
STARTZTL:
echo off
call ARCHIVERS
commandline=arg(1)
id='ZTL Archive Converter v1.7  (ZTL /? for help)'
if pos(commandline,' /?')>0 then signal HELP
filemask=subword(commandline,1,1)
if substr(filemask,1,1)='/'|filemask='' then filemask='*.zip'
if right(filemask,1)='*' then filemask=filemask'.zip'
call RxFuncAdd 'SysLoadfuncs','RexxUtil','SysLoadFuncs'
call SysLoadFuncs
oaext=right(filemask,3)
parse upper var oaext oaext
x=pos('/t',commandline)+pos('/T',commandline)
if x=0 then x='LZH'
if x<>'LZH' then x=substr(commandline,x+2,3)
parse upper var x taext
oacmd=value(oaext'.1')
tacmd=value(taext'.2')
say;say 'Getting directory......'
call GETFILES
pth=left(word(file.1,5),lastpos('\',word(file.1,5))-1)
sd=directory()
x=pos('/w',commandline)+pos('/W',commandline)
if x>0 then call WORKDRV
call WORKDIR
do l=1 to file.0
say;say id;say
file=word(file.l,5)
type='main'
call CONVERT
x=pos('/b',commandline)+pos('/B',commandline)
if x>0 then call BBS
x=pos('/d',commandline)+pos('/D',commandline)+rc
if oaext=taext then x=x+1
if x=0 then say "Now DELETING original archive..."
if x=0 then call sysfiledelete(pth'\'root'.'oaext)
end
DONE:
cd..
rd ztl.ztl
x=directory(sd)
filemask=left(filemask,length(filemask)-4)'.'taext
call sysfiletree filemask, 'dir', 'f'
ototal=0; ttotal=0; total=0
say;say 'ZTL Summary:';say
say '  Before     After   Result   Filename'
say ' --------  --------  ------   -----------'
do l=1 to file.0
do x=1 to dir.0
filemask=filespec('name',left(word(file.l,5),length(word(file.l,5))-4)'.'taext)
if filemask<>filespec('name',word(dir.x,5)) then iterate
file=format(word(file.l,3),9)' 'format(word(dir.x,3),9)' '
file=file' 'format(word(file.l,3)-word(dir.x,3),6)
say file'   'filespec('name',word(dir.x,5))
ototal=ototal+word(file.l,3)
ttotal=ttotal+word(dir.x,3)
total=total+1
end
end
say ' ========  ========  ======   ==========='
file=format(ototal,9)' 'format(ttotal,9)' '
say file' 'format(ototal-ttotal,6)'   ('total' files)';say
exit
BBS: procedure expose root oaext taext pth
call sysfiletree pth'\files.bbs','dir','F'
if dir.0<>0 then do
status=stream(pth'\files.bbs','C','open')
if status="READY:" then do while lines(pth'\files.bbs')=1&status<>"UNKNOWN"
file=linein(pth'\files.bbs')
parse upper var file file
if pos(root'.'oaext,file)>0 then do
rc=stream(pth'\files.bbs','C', 'SEEK -'length(file)+2)
rc=charout(pth'\files.bbs',root'.'taext)
if rc>0 then say '------> error writing to 'pth'\FILES.BBS <------'
status=stream(pth'\files.bbs','C','close')
status=stream(pth'\files.bbs','S')
end
end
if status<>"UNKNOWN" then do
say '------> 'root'.'oaext' not found in 'pth'\FILES.BBS <------'
status=stream(pth'\files.bbs','C','close')
end
end
if dir.0=0 then say '------> 'pth'\FILES.BBS not found! <------'
return
CHECKINT: procedure expose oaext taext oacmd tacmd id commandline
filemask='*.*'
call GETFILES
pth='..'
l=1
do x=1 to file.0
if right(file.x,3)=oaext then do
say '!! INTERNAL ARCHIVE DETECTED !!'
call WORKDIR
file=file.x
type=internal
call CONVERT
'cd..'
'rd ztl.ztl'
call SysFileDelete(word(file,5))
l=l+1
end
end
return
CONVERT:
say 'Getting file to convert...'
root=left(filespec('name',file),length(filespec('name',file))-4)
say 'Converting' type 'archive #'l': 'root'.'oaext' -> 'root'.'taext;say
interpret 'oacmd pth"\"root'
if RC>0 then do
call ERROR
return;end
if (pos('/i',commandline)+pos('/I',commandline))=0 then call CHECKINT
call PROCESS
interpret 'tacmd pth"\"root "*.*"'
if RC>0 then do
call ERROR
return;end
'del *.* /y /q >nul'
return
DIREXISTS:
Say 'Work directory already exists: now deleting!'
'del .\ztl.ztl /y >nul'
'rd ztl.ztl'
return
ERROR:
say;say '************ ERROR *************'
say ' Skipping 'pth'\'root'.'oaext
say '********************************';say
'del *.* /y /q'
return
say 'Exiting ZTL...'
exit
GETFILES:
call sysfiletree filemask,'file','F'
if file.0=0 then signal NOFILES
return
NOFILES:
say
say There do not seem to be any files to convert.
exit
WORKDIR: procedure
call sysfiletree 'ztl.ztl','x','D'
if x.0=1 then call DIREXISTS
'md ztl.ztl'
'cd ztl.ztl'
return
WORKDRV:
wd=substr(commandline,x+2,2)
if right(wd,1)<>':' then do
say '`'wd'` is not a valid work drive.'
say
exit
end
wd
if rc<>0 then do
say '`'wd'` is not a valid work drive.'
say
exit
end
'cd\'
return

/*=================================================================*/
/* Hope you find this useful.  Send me any suggestions via NetMail.*/
/* Tim Middleton 1:250\202              Toronto, Canada, Feb. 1993 */
/*-----------------------------------------------------------------*/
