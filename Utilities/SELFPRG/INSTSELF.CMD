/* Self prg Installer */

call RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
call SysLoadFuncs
gpara=""
Qask ='N'
'CLS'
Do until Qask ='Y'
 'CLS'
 SAY ''
 SAY ''
 SAY 'Enter the Name You wish to Call this Program (Example Dozip.cmd)'
 Parse Pull mname
 SAY 'Enter the Archiver You wish to Use (Example unzip unarj LH x)'
 PARSE Pull zipper
 SAY 'Enter the Extention for the Archived files (Example zip arj lhz)'
 PARSE Pull unext
 SAY unext
 SAY 'Enter PATH to the Archived Files Example C:\ZIPS)'
 SAY 'Directory must EXIST.'
 PARSE Pull dir
Cls
 SAY ''
 SAY ''
 SAY 'The file to be created is to be called'
 SAY mname
 SAY ''
 SAY 'The archiver to be used is called'
 SAY zipper
 SAY ''
 SAY 'The archived files extention is'
 SAY unext
 SAY ''
 SAY 'The drive and driectory to place this file is ' 
 SAY dir
 SAY ''
 SAY 'Enter (Y or y) if Correct (Q or q) to Quit any other key to Re-Enter'
       Pull Qask
   If Qask = 'Q' then Exit
 END

dira=dir
testname = insert(dir,'\')
dir = testname
'copy selfprg.dat' insert(dir,mname)
inname='selfprg.ico'
mnamel=length(mname)
mnamei=left(mname,mnamel-4)
inname2=insert(mnamei,'.ico')
copy 'selfprg.ico' inname2
copy inname2 dira
cmdline = insert(dir,mname)
iconset=insert(dir,inname2)
If \SysSetIcon(cmdline, iconset) then Say 'Setting Icon Failed'

CALL lineout insert(dir,mname),insert("unext='",unext)"'"
CALL lineout insert(dir,mname),insert("dir='",dir)"'"
CALL lineout insert(dir,mname),insert("zipper='",zipper)"'"
CALL lineout insert(dir,mname),'return'

sdrive = left(dira,2)
sdrive
'CD' dira

ototal =length(cmdline)-4
spos=lastpos("\", cmdline)
odir = substr(cmdline,1,spos-1)
oname = substr(cmdline, spos+1, ototal-spos)
'CLS'
SAY ''
SAY ''
SAY 'Object name is      ' oname
SAY 'File name path is   ' cmdline
SAY 'Directory is        ' odir
Nogo = SysCreateObject( "WPProgram", oname, "<WP_DESKTOP>", "EXENAME="cmdline";STARTUPDIR="odir";PARAMETERS="gpara)
if Nogo = 0 then say "The BUILD Object operation failed "
               else say mname 'Created and placed on Desktop'
EXIT
