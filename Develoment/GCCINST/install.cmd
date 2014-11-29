/*  install.cmd */
/* Install emx and gcc 3.2.1  */
/* This will ask the user where to install emx and proceed doing so. */
/* It will also install make. */
/* Originally by Andy Willis, Improved by John Small */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

/* Check for presence of unzip.exe in the path */
rc = SysSearchPath('PATH', 'unzip.exe')
if rc == '' then
   do
      say "Error: UNZIP.EXE not found in the PATH"
      exit
   end

curdir = directory()

n = setlocal()

Say 'Where do you want to install emx?'
Say 'The format is C: or D:\compilers (etc.).  If you put C:\emx it will be in C:\emx\emx. Do not use relative path.'
Say 'If you specify a path where emx already exists it will overwrite files without prompting.  You have been warned.'
installpath = linein()
rc = GotoInstallDirectory()
If rc == '' then
   do
         Say 'Directory 'installpath' does not exist.'
         Say 'Do you want to create it? (Y/N)'
      do while (pos(key, 'YN') == 0)
         key = translate(SysGetKey(noecho))
         if key == 'N' then exit
      end /* do */
      temp = installpath || '\'
      index = pos('\', temp)
      do until index == 0
         index = pos('\', temp, index + 1)
         if index > 0 then
            do
               '@if not exist 'left(temp, index) || '. md 'left(installpath, index - 1)
               if rc \= 0 then
                  do
                     say "Unable to create directory: " || left(installpath, index - 1)
                     exit
                  end /* do */
            end
      end /* do */
      rc = GotoInstallDirectory()
      if rc == '' then exit
   end
'unzip -o ' curdir'\*.zip'
'unzip -o ' curdir'\dev\*.zip'
'unzip -o ' curdir'\dev\fix\*.zip'
call SysMkDir '.\emx\make'
call directory '.\emx\make'
'unzip -o -j ' curdir'\make\make-3_79_2a1-r2-bin.zip usr\bin\make.exe'
'unzip -o -j ' curdir'\make\gettext-0_11_5-r2-bin lib\intl.dll'
'unzip -o -j ' curdir'\make\os2_fileutils-3.16 fileutils-3.16\bin\*'
'unzip -o -j ' curdir'\make\os2_fileutils-3.16 fileutils-3.16\dll\*'
'set beginlibpath='installpath'\emx\dll;'installpath'\emx\make;'
'set path='installpath'\emx\bin;'installpath'\emx\make;%PATH%'
'path'
call directory installpath'\emx\lib'
'call omflibs'
call GotoInstallDirectory
'unzip -o ' curdir'\dev\fix\gcc\*.zip'
call directory installpath'\emx\bin.new'
'copy * ..\bin'
call directory installpath'\emx\lib'
'make'
call directory installpath'\emx\lib\gcc-lib\i386-pc-os2-emx\3.2.1'
'copy *.exe 'installpath'\emx\bin'
call directory installpath'\emx\bin'

         call Lineout 'setgcc.cmd','SET PATH='installpath'\emx\bin;%PATH%'
         call Lineout 'setgcc.cmd','SET BEGINLIBPATH='installpath'\emx\dll;%BEGINLIBPATH%'
         call Lineout 'setgcc.cmd','rem This is added in case it is needed for specific projects therefore it is shown but mostly is not needed'
         call Lineout 'setgcc.cmd','rem SET C_INCLUDE_PATH='installpath'/emx/lib/gcc-lib/i386-pc-os2-emx/3.2.1/include;'installpath'emx/include;'
         call Lineout 'setgcc.cmd','rem SET CPLUS_INCLUDE_PATH='installpath'/emx/include/c++/3.2.1;'installpath'/emx/lib/gcc-lib/i386-pc-os2-emx/3.2.1/include;'installpath'/include;'
         call Lineout 'setgcc.cmd','rem SET LIBRARY_PATH='installpath'/emx/lib;'
         call Lineout 'setgcc.cmd','SET GCCLOAD=5'
         call Lineout 'setgcc.cmd','SET GCCOPT=-pipe'
         call Lineout 'setgcc.cmd','SET EMXOPT=-c -n -h256'
         call Lineout 'setgcc.cmd','SET TERMCAP='installpath'/emx/etc/termcap.dat'
         call Lineout 'setgcc.cmd','rem SET TERM=ansi-color-3'
         call Lineout 'setgcc.cmd','SET TERM=os2'
         call Lineout 'setgcc.cmd','SET INFOPATH='installpath'/emx/info'
         call Lineout 'setgcc.cmd','SET EMXBOOK=emxdev.inf+emxlib.inf+emxgnu.inf+emxbsd.inf'
         call Lineout 'setgcc.cmd','SET BOOKSHELF='installpath'\emx\book;%BOOKSHELF%'
         call Lineout 'setgcc.cmd','SET HELPNDX=%HELPNDX%+emxbook.ndx'
         call Lineout 'setgcc.cmd','SET DPATH='installpath'\emx\book;%DPATH%'
         call stream 'setgcc.cmd', 'c', 'close'

'call emxinst.cmd'
Call SysCreateObject'WPProgram', 'GCC Prompt','<EM_emx_0.9d_FOLDER>', ,
                      'PROGTYPE=Default;EXENAME=cmd.EXE;PARAMETERS=/k 'installpath'\emx\bin\setgcc.cmd', ,
                      'update'

call directory curdir
n=endlocal()
exit

GotoInstallDirectory:
   if (length(installpath) == 2) then
      return directory(installpath || '\')
   else
      return directory(installpath)


