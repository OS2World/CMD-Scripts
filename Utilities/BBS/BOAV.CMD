/* DISCLAIMER:  This software is provided "AS IS" without any warranty of any
kind, either expressed or implied.  USE IT AT YOUR OWN RISK.

The BBS OnLine Archive Viewer (BOAV) is an attempt at REXX programming
without a manual, since I got into OS/2 by way of the 2.01 beta offer by IBM.
BOAV will allow you to view the contents of ZIP, ARC, ZOO, LZH, and ARJ files,
and also allow you to extract these files for later download.  It is only a 
shell, you will need the following files for full operation:

UNARJ.ZIP  PKZ102-2.EXE  ARC2.EXE  LH2_214.ZIP  ZOO21E.EXE
     
           **** Support for PKZIP v2.xx *****
  UNZ50X32.ZIP (and UNZ50X16.ZIP) will provide BOAV with the capability to
  view and extract files compressed with PKZIP v2.xx for DOS.  If you
  want v2.xx support, you will need one of the 2 files listed above, 
  IN ADDITION TO PKZ102-2.EXE.  You will also need to change the variable
  to Unz='yes'.

  BOAVEXTR.ZIP is still compressed using PKZ102-2 to maintain compatability.

All of which can be found on The Cereal Port BBS, (603)899-3335, 1:132/152 or
any good OS/2 BBS.

Put BOAV.CMD in your MAX directory.  Make sure your archivers are in the path.

Modify your Max Menu.ctl file as follows:

     Xtern_Run Maxpipe.exe_%P_boav.cmd_%F   normal  "View a file"

If you're also going to use the extraction feature, you will want to make sure 
that extracted files are deleted after every caller.  To do this modify your 
spawnbbs.cmd file to perform the following command upon exit from the BBS:

     del drive:\pathname\BOAVEXTR.ZIP

Where drive\pathname point to the bbs file directory where you will have the
files extracted to.(preferably a separate file area).  You should also modify
the FILES.BBS for that area by adding "BOAVEXTR.ZIP  Files Extracted by the BBS 
Online Archive Viewer".  The entry in the FILES.BBS will report that the file 
is "offline" unless someone actually extracts a file(s).

As you can see, the extracted files will be compressed into ZIP format, and
the user can extract files, from different archives, and they will all be
added to the one file, BOAVEXTR.ZIP, for download.

Copywrite 1992 by Bill Esposito.  This program is FREEWARE, just let me know
how you like it.

There are 8 variables that you will need to modify, and there is a comment 
next to them explaining what they are for.
*/

extrdir='e:\max\av\'      /* the files will be extracted here 
                             MUST be a subdir off your Max dir 
                             each time BOAV is run it will delete all files
                             in this dir so BE CAREFUL and make this a separate
                             directory*/

chngdir='\max\av'         /* for changing to the extrdir for decompressing */

max='\max'                /* your MAX directory */

ext='yes'                 /* enable file extraction for download (yes or no) */

dldir='g:\opus\file28\'   /* Path to the BBS file area where BOAV will place 
                             the extracted files */

areaname='File Area 28'   /* Title to be displayed to the users reminding them
                             where to look for the extracted files. */
FourOs2='yes'             /* whether you're running 4OS2 or not (yes or no) */

Unz='yes'                /* whether your using pkz102 or unz50x 
                            ('yes' for Unz50x)*/


'@echo off'
call RxFuncAdd 'SysloadFuncs','RexxUtil','Sysloadfuncs'
call sysloadfuncs
arg path

if FourOs2='yes' 
   then
      '@del' extrdir'*.* /y>nul'
     else
        '@del' extrdir'*.* /n>nul'

l=1
y=1
sw='0'
loop:
/* ansi on */
cls
noclr:
found=''
say '[1;36m'
say '               [33m  BBS OnLine Archive Viewer'
say '             [32m              v2.1'
say '                [35m     by Bill Esposito'
say
say '             [33m    ZIP, ARJ, LZH, ARC, ZOO'
say ''
loop1:
say ''
SAY '[36m Input the Filename (Filename.Ext) of the [35m Archive[36m'; 
say '                     (? for file list, Q to Quit)'; pull arcname
if arcname='?' then call dir
if arcname=''then call quit
if arcname='Q'then call quit
call sysfiletree path''arcname,'file','fo'
do i=1 to file.0 
found=rc
end
if found <> '0' then call nofile
if left(arcname,1)='\' then call loop
if left(arcname,2)=':' then call loop
if right(arcname,3)=lzh then call lzh
if right(arcname,3)=arj then call arj
if right(arcname,3)=arc then call arc
if right(arcname,3)=zoo then call zoo
if arcname='?'then call dir
if unz='yes' then if right(arcname,3)=zip then call zip2
if unz='no' then if right(arcname,3)=zip then call zip
    else call ziponly
call loop
what_to_do:
fileview = ''
filedl=''
say
say
if nofile='yes' then say '[35mThe File You Selected Was NOT Found.  Please make another Selection '
if nofile='yes' then say ''
if nofile='yes' then cd max
if nofile='yes' then nofile=''
if ext='yes' then say '[36mWould you like to[33m V[36m)iew or[33m E[36m)xtract a file for download?'
if ext='yes' then say 'Or would you like to select a [33mN[36m)ew archive or [33mQ[36m)uit[36m'

if ext='yes' then pull ve
if ext='no' then ve=v
if right(ve,1)='Q' then call quit
if right(ve,1)='N' then call loop
if right(ve,1)=v then say '[36mWhich file would you like to view? (filename.ext)'
if right(ve,1)=v then if ext='no' then say 'Or select a [33mN[36m)ew archive or [33mQ[36m)uit[36m'
if right(ve,1)=v then pull fileview
if right(ve,1)=v then if fileview='Q' then call quit
if right(ve,1)=v then if fileview='N' then call loop
s=1
if right(ve,1)=v then do until s=12
 if substr(fileview,s,1)=':' then call invalid
 if substr(fileview,s,1)='\' then call invalid
 if substr(fileview,s,1)='*' then call invalid
 if substr(fileview,s,1)='?' then call invalid
s=s+y
end
if right(ve,1)=v then return

if right(ve,1)=e then say
if right(ve,1)=e then say '[36mWhich file would you like to extract? (filename.ext)'
if right(ve,1)=e then say 
if right(ve,1)=e then pull filedl
if right(ve,1)=e then sw=1
s=1
if right(ve,1)=e then do until s=12
 if substr(filedl,s,1)=':' then call invalid
 if substr(filedl,s,1)='\' then call invalid
 if substr(filedl,s,1)='*' then call invalid
s=s+y
end

if right(ve,1)=e then return
else call loop


dir:
fileview='files.bbs'
'@COPY' PATH''FILES.BBS extrdir '>nul'
call read

zip:
cls
kind='zip'
fullname=(path''arcname)  
"pkunzip2 -v" fullname 
if rc=0
then call what_to_do
if fileview='Q' then call quit
if filedl='Q' then call quit
x=1
if right(ve,1)=v then pkunzip2 fullname fileview extrdir '>nul'
if right(ve,1)=v then if rc <> '0' then nofile='yes'
if right(ve,1)=v then if rc <> '0' then call zip
if right(ve,1)=v then call read 
if right(ve,1)=v then return
if right(ve,1)=e then pkunzip2 fullname filedl extrdir '>nul'
if right(ve,1)=e then if rc <> '0' then nofile='yes'
if right(ve,1)=e then if rc <> '0' then call zip
if right(ve,1)=e then pkzip2 dldir''boavextr extrdir''filedl '>nul'
if right(ve,1)=e then if rc = '0' then say 'File was Extracted to 'areaname
if right(ve,1)=e then if rc <> '0' then nofile='yes'
if right(ve,1)=e then if rc <> '0' then call zip
if right(ve,1)=e then del extrdir''filedl '>nul'
if right(ve,1)=e then do until x=6000
x=x+y
end
call zip

zip2:
cls
kind='zip2'
fullname=(path''arcname) 
"unzip2 -v" fullname
if rc=0
then call what_to_do
if fileview='Q' then call quit
if filedl='Q' then call quit
x=1
cd chngdir
if right(ve,1)=v then 'unzip2' fullname extrdir fileview '>nul'
if right(ve,1)=v then if rc <> '0' then nofile='yes'
if right(ve,1)=v then if rc <> '0' then call zip2
if right(ve,1)=v then cd max
if right(ve,1)=v then call read 
if right(ve,1)=v then return
if right(ve,1)=e then 'unzip2' fullname filedl '>nul'
if right(ve,1)=e then if rc <> '0' then nofile='yes'
if right(ve,1)=e then if rc <> '0' then call lzh
if right(ve,1)=e then pkzip2 dldir''boavextr extrdir''filedl '>nul'
if right(ve,1)=e then if rc = '0' then say 'File was Extracted to 'areaname
if right(ve,1)=e then if rc <> '0' then nofile='yes'
if right(ve,1)=e then if rc <> '0' then call zip2
if right(ve,1)=e then del filedl '>nul'
if right(ve,1)=e then do until x=6000
x=x+y
end
cd max
call zip2

lzh:
cls
kind='lzh'
fullname=(path''arcname) 
"lh /v" fullname
if rc=0
then call what_to_do
if fileview='Q' then call quit
if filedl='Q' then call quit
x=1
cd chngdir
if right(ve,1)=v then 'lh x' fullname extrdir fileview '>nul'
if right(ve,1)=v then if rc <> '0' then nofile='yes'
if right(ve,1)=v then if rc <> '0' then call lzh
if right(ve,1)=v then cd max
if right(ve,1)=v then call read 
if right(ve,1)=v then return
if right(ve,1)=e then 'lh x' fullname filedl '>nul'
if right(ve,1)=e then if rc <> '0' then nofile='yes'
if right(ve,1)=e then if rc <> '0' then call lzh
if right(ve,1)=e then pkzip2 dldir''boavextr extrdir''filedl '>nul'
if right(ve,1)=e then if rc = '0' then say 'File was Extracted to 'areaname
if right(ve,1)=e then if rc <> '0' then nofile='yes'
if right(ve,1)=e then if rc <> '0' then call lzh
if right(ve,1)=e then del filedl '>nul'
if right(ve,1)=e then do until x=6000
x=x+y
end
cd max
call lzh 

/* Unarj, Zoo, UNZ50X and Arc do not support exit errorlevels, therefore these 
routines act a bit different than zip and lzh.  I have left the errorlevel
checking routines in, with the hope that later versions of said archivers will
support it. */

arj:
cls
kind='arj'
fullname=(path''arcname) 
"unarj" fullname 
if rc=0
then call what_to_do
if fileview='' then if filedl='' then call loop
if filedl='' then if fileview='' then call loop
if fileview='Q' then call quit
if filedl='Q' then call quit
x=1
cd chngdir
if right(ve,1)=v then unarj e fullname fileview '>nul'
if right(ve,1)=v then if rc <> '0' then nofile='yes'
if right(ve,1)=v then if rc <> '0' then call arj
if right(ve,1)=v then cd max
if right(ve,1)=v then call read 
if right(ve,1)=v then return
if right(ve,1)=e then unarj e fullname filedl '>nul'
if right(ve,1)=e then if rc <> '0' then nofile='yes'
if right(ve,1)=e then if rc <> '0' then call arj
if right(ve,1)=e then pkzip2 dldir''boavextr extrdir''filedl '>nul'
if right(ve,1)=e then if rc = '0' then say 'File was Extracted to 'areaname
if right(ve,1)=e then if rc <> '0' then nofile='yes'
if right(ve,1)=e then if rc <> '0' then call arj
if right(ve,1)=e then del filedl '>nul'
if right(ve,1)=e then do until x=6000
x=x+y
end
cd max
call arj 

Zoo:
cls
kind='zoo'
fullname=(path''arcname) 
"zoo v" fullname 
if rc=0
then call what_to_do
if fileview='Q' then call quit
if filedl='Q' then call quit
x=1
cd chngdir
if right(ve,1)=v then 'zoo -e' fullname fileview '>nul'
if right(ve,1)=v then if rc <> '0' then nofile='yes'
if right(ve,1)=v then if rc <> '0' then call zoo
if right(ve,1)=v then cd max
if right(ve,1)=v then call read 
if right(ve,1)=v then return
if right(ve,1)=e then 'zoo -e' fullname filedl '>nul'
if right(ve,1)=e then if rc <> '0' then nofile='yes'
if right(ve,1)=e then if rc <> '0' then call zoo
if right(ve,1)=e then pkzip2 dldir''boavextr extrdir''filedl '>nul'
if right(ve,1)=e then if rc = '0' then say 'File was Extracted to 'areaname
if right(ve,1)=e then if rc <> '0' then nofile='yes'
if right(ve,1)=e then if rc <> '0' then call zoo
if right(ve,1)=e then del filedl '>nul'
if right(ve,1)=e then do until x=6000
x=x+y
end
cd max
call zoo 

arc:
kind='arc'
cls
fullname=(path''arcname) 
"arc2 l" fullname
if rc=0
then call what_to_do
if fileview='Q' then call quit
if filedl='Q' then call quit
x=1
cd chngdir
if right(ve,1)=v then 'arc2 x' fullname fileview '>nul'
if right(ve,1)=v then if rc <> '0' then nofile='yes'
if right(ve,1)=v then if rc <> '0' then call arc
if right(ve,1)=v then cd max
if right(ve,1)=v then call read 
if right(ve,1)=v then return
if right(ve,1)=e then 'arc2 x' fullname filedl '>nul'
if right(ve,1)=v then if rc <> '0' then nofile='yes'
if right(ve,1)=v then if rc <> '0' then call arc
if right(ve,1)=e then pkzip2 dldir''boavextr extrdir''filedl '>nul'
if right(ve,1)=e then if rc = '0' then say 'File was Extracted to 'areaname
if right(ve,1)=e then if rc <> '0' then nofile='yes'
if right(ve,1)=e then if rc <> '0' then call arc
if right(ve,1)=e then del filedl '>nul'
if right(ve,1)=e then do until x=6000
x=x+y
end
cd max
call arc 

ziponly:
cls
say ''
say ''
say '' 
say 'This program supports ZIP, ZOO, LZH, ARJ, and ARC files.'
say 'Be sure to include the complete filename (Filename.zip)'
call loop1
exit:
exit

/* Read */
read: 
x=1
loop:
y='1'

newq = rxqueue('create')
oq = rxqueue('set',newq)
l=l+y
'@copy' extrdir''fileview extrdir''display''l''.doc '>nul'
if rc <> '0' then nofile='yes'
if rc <> '0' then if kind='zip2' then call zip2
if rc <> '0' then if kind='zip' then call zip
if rc <> '0' then if kind='lzh' then call lzh
if rc <> '0' then if kind='arj' then call arj
if rc <> '0' then if kind='arc' then call arc
if rc <> '0' then if kind='zoo' then call zoo

'@del' extrdir''fileview '>nul'
file=extrdir''display''l''.doc
linein(file,1,0)
loop2:
do until x > 20
say ''linein(file)''
if lines(file)=''0'' then say 'Press the <ENTER> key to continue'
if lines(file)=''0'' then pull enter
if lines(file)=''0'' then call qdel
x=x+y
end
more:
  x=1
   say 'more? (Y,n)'
    pull yn
    if yn='N' then call qdel
     else
call loop2
call qdel
qdel:
call rxqueue 'delete',newq
call rxqueue 'set',oq 
if kind='zip2' then call zip2
if kind='zip' then call zip
if kind='lzh' then call lzh
if kind='arj' then call arj
if kind='arc' then call arc
if kind='zoo' then call zoo
call loop

invalid:
cls
say
say
say ' [33m Please Do Not Enter Pathnames or WIldcards.  Just enter the Filename.Ext'
cd max
call loop1
nofile:
cls
say
say
say ' [33m The File You Selected Was NOT Found.  Please make another Selection             or hit ''Q'' to Quit'
cd max
call loop1
quit:
exit:
cls
say
say
if sw=1 then say '   The files that you just extracted can be downloaded from'
if sw=1 then say '                     [32m 'areaname
if sw=1 then say '[36m   by downloading the file BOAVEXTR.ZIP' 
if sw=1 then say
if sw=1 then say
if sw=1 then say
if sw=1 then say
if sw=1 then say 'press the <ENTER> key to return to BBS.'
if sw=1 then pull enter
exit
