/*****************************************************/
/* BUILD_C.CMD : Build WATCOM C/C++ Desktop objects */
/*****************************************************/

address CMD

'@echo off'

call RXFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
call SysLoadFuncs

call setlocal

target_dir   = ''
szVideoMode = ''

parse arg target_dir szVideoMode

if( target_dir = '?' | target_dir = '/?') then
    call Usage

if (szVideoMode \= "1024x768" & szVideoMode \= "800x600" & szVideoMode \= "640x480") then do
   szVideoMode = "640x480"
end

if (szVideoMode = "") then do
   szVideoMode = "640x480"
end

folder_title = 'Watcom C/C++'

default_dir = directory()

if( target_dir = '' )then
    target_dir = directory()
else do
    if( lastpos( "\", target_dir ) = length( target_dir ) ) then do
        target_dir = left( target_dir, length( target_dir ) - 1 )
    end
end

if( directory( target_dir ) = '' )then
    call Usage

target_dir = directory( target_dir )

bldDemo = 0
if( FileExists( target_dir || '\TUTBOOK.INF' ) )then do
    bldDemo = 1
end

/* call AddTemplate */

/* Accomodate for different resolution modes */


o_x = 5;

if (szVideoMode = "1024x768") then do
   y = 45;
   o_y = 45;
   nDeltaY = -11;
   nDeltaX = 8;
end
if (szVideoMode = "640x480") then do
   y = 60;
   o_y = 60;
   nDeltaY = -15;
   nDeltaX = 15;
end
if (szVideoMode = "800x600") then do
   y = 60;
   o_y = 60;
   nDeltaY = -15;
   nDeltaX = 15;
end

/* Create main folder object */

say 'Building Workplace Shell Watcom 10.5 Objects...'

classname = 'WPFolder'
title     = folder_title
location  = '<WP_DESKTOP>'
iconparm  = 'ICONFILE=' || default_dir || '\watcom2.ico;'
setup     = 'OBJECTID=<WATCOM_FOLDER>;' || iconparm

call SysCreateObject classname, title, location, setup, 'r'


/* Getting Started Help */

x = o_x;
classname = 'WPProgram'
title     = "Getting Started" || "0a"x || "Help"
location  = '<WATCOM_FOLDER>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\readc10.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* Read Me */

x = x + nDeltaX;
classname = 'WPProgram'
title     = "Read Me"
location  = '<WATCOM_FOLDER>'
setup     = 'EXENAME=e.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\readme.txt;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* Create the IDE icon */

x = x + nDeltaX;;
classname = 'WPProgram'
title     = 'IDE'
location  = '<WATCOM_FOLDER>'
setup     = 'EXENAME=' || target_dir || '\binp\ide.exe;'||,
            'PROGTYPE=PM;' ||,
            'ICONPOS=' || x || ',' || y || ';' ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* Create Source Browser */

    x = x + nDeltaX;
    classname = 'WPProgram'
    title     = 'Source Browser'
    location  = '<WATCOM_FOLDER>'
    setup     = 'EXENAME=' || target_dir || '\binp\wbrw.exe;' ||,
                'PROGTYPE=PM;' ||,
                'ICONPOS=' x || "," || y || ";" ||,
                'STARTUPDIR=' || target_dir || ';'
    call SysCreateObject classname, title, location, setup, 'r'

/* Create Profiler */

    x = x + nDeltaX;
    classname = 'WPProgram'
    title     = 'Profiler'
    location  = '<WATCOM_FOLDER>'
    setup     = 'EXENAME=' || target_dir || '\binp\wprof.exe;' ||,
                'PROGTYPE=PM;' ||,
                'ICONPOS=' x || "," || y || ";" ||,
                'STARTUPDIR=' || target_dir || ';'
    call SysCreateObject classname, title, location, setup, 'r'

/* Windowed Debugger */

    x = x + nDeltaX;
    classname = 'WPProgram'
    title     = 'Windowed' || '0a'x || 'Debugger'
    location  = '<WATCOM_FOLDER>'
    setup     = 'EXENAME=' || target_dir || '\binp\wdw.exe;'||,
                'PROGTYPE=PM;' ||,
                'ICONPOS=' x || "," || y || ";" ||,
                'STARTUPDIR=' || target_dir || ';'
    call SysCreateObject classname, title, location, setup, 'r'

/* Create Debugger */

    x = x + nDeltaX;
    classname = 'WPProgram'
    title     = 'Debugger'
    location  = '<WATCOM_FOLDER>'
    setup     = 'EXENAME=' || target_dir || '\binp\wd.exe;' ||,
                'PROGTYPE=WINDOWABLEVIO;' ||,
                'ICONPOS=' x || "," || y || ";" ||,
                'STARTUPDIR=' || target_dir || ';'
    call SysCreateObject classname, title, location, setup, 'r'

/* Create Dialog Editor */

    x = x + nDeltaX;
    classname = 'WPProgram'
    title     = 'Dialog Editor'
    location  = '<WATCOM_FOLDER>'
    setup     = 'EXENAME=' || target_dir || '\binp\dlgedit.exe;' ||,
                'PROGTYPE=PM;' ||,
                'ICONPOS=' x || "," || y || ";" ||,
                'STARTUPDIR=' || target_dir || ';'
    call SysCreateObject classname, title, location, setup, 'r'

/* Create Font Editor */

    y = y + nDeltaY;
    x = o_x;
    classname = 'WPProgram'
    title     = 'Font Editor'
    location  = '<WATCOM_FOLDER>'
    setup     = 'EXENAME=' || target_dir || '\binp\fontedit.exe;' ||,
                'PROGTYPE=PM;' ||,
                'ICONPOS=' x || "," || y || ";" ||,
                'STARTUPDIR=' || target_dir || ';'
    call SysCreateObject classname, title, location, setup, 'r'

/* Create Icon Editor */

    x = x + nDeltaX;
    classname = 'WPProgram'
    title     = 'Icon Editor'
    location  = '<WATCOM_FOLDER>'
    setup     = 'EXENAME=' || target_dir || '\binp\iconedit.exe;' ||,
                'PROGTYPE=PM;' ||,
                'ICONPOS=' x || "," || y || ";" ||,
                'STARTUPDIR=' || target_dir || ';'
    call SysCreateObject classname, title, location, setup, 'r'

/* Create OS/2 VDM Remote Link */

    x = x + nDeltaX;
    classname = 'WPProgram'
    title     = 'OS/2 VDM' || '0a'x || 'Remote Link'
    location  = '<WATCOM_FOLDER>'
    setup     = 'EXENAME=' || target_dir || '\binw\vdmservw.exe;' ||,
                'PROGTYPE=PM;' ||,
                'ICONPOS=' x || "," || y || ";" ||,
                'STARTUPDIR=' || target_dir || ';'
    call SysCreateObject classname, title, location, setup, 'r'

/* Create Named Pipe Remote Link */

    x = x + nDeltaX;
    classname = 'WPProgram'
    title     = 'Named Pipe' || '0a'x || 'Remote Link'
    location  = '<WATCOM_FOLDER>'
    setup     = 'EXENAME=' || target_dir || '\binw\nmpservw.exe;' ||,
                'PROGTYPE=PM;' ||,
                'ICONPOS=' x || "," || y || ";" ||,
                'STARTUPDIR=' || target_dir || ';'
    call SysCreateObject classname, title, location, setup, 'r'

/* Additional help */
folder_title = 'Watcom C/C++ Additional Help'

classname = 'WPFolder'
title     = folder_title
location  = '<WP_DESKTOP>'
iconparm  = 'ICONFILE=' || default_dir || '\watcom2.ico;'
setup     = 'OBJECTID=<WATCOM_C_C++_ADDITIONAL_HELP>;' || iconparm

call SysCreateObject classname, title, location, setup, 'r'

x = o_x;
y = o_y;

/* REXX Reference */

classname = 'WPProgram'
title     = 'REXX Reference'
location  = '<WATCOM_C_C++_ADDITIONAL_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\rexxapi.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* IPFC Reference */

x = x + nDeltaX + nDeltaX / 4;
classname = 'WPProgram'
title     = 'IPFC Reference'
location  = '<WATCOM_C_C++_ADDITIONAL_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\ipfc20.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* SOM Reference */

x = x + nDeltaX + nDeltaX / 4;
classname = 'WPProgram'
title     = 'SOM Reference'
location  = '<WATCOM_C_C++_ADDITIONAL_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\som.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* Tools Reference */

x = x + nDeltaX + nDeltaX / 4;
classname = 'WPProgram'
title     = 'Tools Reference'
location  = '<WATCOM_C_C++_ADDITIONAL_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\toolinfo.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* PM Reference */

x = x + nDeltaX + nDeltaX / 2;
classname = 'WPProgram'
title     = 'PM Reference'
location  = '<WATCOM_C_C++_ADDITIONAL_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=pmref;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* CP Reference */

x = x + nDeltaX + nDeltaX / 6;
classname = 'WPProgram'
title     = 'CP Reference'
location  = '<WATCOM_C_C++_ADDITIONAL_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=progref20;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* Add-In Tools Guide */

x = x + nDeltaX + nDeltaX / 3;
classname = 'WPProgram'
title     = 'Add-In Tools Guide'
location  = '<WATCOM_C_C++_ADDITIONAL_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\isvfor.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* Tools Help */

folder_title = 'Watcom C/C++ Tools Help'

classname = 'WPFolder'
title     = folder_title
location  = '<WP_DESKTOP>'
iconparm  = 'ICONFILE=' || default_dir || '\watcom2.ico;'
setup     = 'OBJECTID=<WATCOM_C_C++_TOOLS_HELP>;' || iconparm

call SysCreateObject classname, title, location, setup, 'r'

/* Source Browser Help */

x = o_x;
y = o_y;

classname = 'WPProgram'
title     = "Source Browser" || "0a"x || "Help"
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\wbrw.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* Profiler Help */

x = x + nDeltaX + nDeltaX / 4;
classname = 'WPProgram'
title     = "Profiler Help"
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\wprof.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* IDE Help */

x = x + nDeltaX;
classname = 'WPProgram'
title     = "IDE Help"
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\ide.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* Debugger Help */

x = x + nDeltaX;
classname = 'WPProgram'
title     = "Debugger Help"
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\wd.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* C Language Reference */

x = x + nDeltaX + nDeltaX / 2;
classname = 'WPProgram'
title     = "C Language Reference"
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\clr.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* C Library Reference */

x = x + nDeltaX + nDeltaX / 2;
classname = 'WPProgram'
title     = "C Library Reference"
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\clib.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* C++ Library Reference */

x = x + nDeltaX + nDeltaX;
classname = 'WPProgram'
title     = "C++ Library Reference"
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\cpplib.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* User's Guide */
x = o_x;
y = y + nDeltaY;
classname = 'WPProgram'
title     = "Watcom" || "0a"x || "User's Guide"
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\cguide.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* Programmer's Guide */

x = x + nDeltaX + nDeltaX / 2;
classname = 'WPProgram'
title     = "Programmer's Guide"
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\pguide.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* Linker Guide */

x = x + nDeltaX + nDeltaX / 2;

classname = 'WPProgram'
title     = "Linker Guide"
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\lguide.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* Tools Guide */

x = x + nDeltaX;
classname = 'WPProgram'
title     = "Tools Guide"
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\tools.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

x = x + nDeltaX + nDeltaX / 2;
classname = 'WPProgram'
title     = "Tools Reference"
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\toolinfo.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* C/C++ Master Index */

x = o_x;
y = y + nDeltaY;
classname = 'WPProgram'
title     = 'C/C++ MASTER Index'
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\cmix.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* C Error Messages*/

x = x + nDeltaX + nDeltaX;
classname = 'WPProgram'
title     = 'C Error Messages'
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\wccerrs.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

/* C++ Error Messages */

x = x + nDeltaX + nDeltaX;
classname = 'WPProgram'
title     = 'C++ Error Messages'
location  = '<WATCOM_C_C++_TOOLS_HELP>'
setup     = 'EXENAME=view.exe;' ||,
            'PROGTYPE=PM;' ||,
            'PARAMETERS=' || target_dir || '\binp\help\wpperrs.INF;' ||,
            'ICONPOS=' x || "," || y || ";" ||,
            'STARTUPDIR=' || target_dir || ';'
call SysCreateObject classname, title, location, setup, 'r'

say 'For some reason the folders created by this script are positioned in'
say 'South America when the folder is first opened.  Be sure to use the scroll'
say 'bar to scroll to the top of the window and your icons will be there.'
say 'Alternatively you can use the Arrange option to automatically position'
say 'the icons.'

exit
  
/*
 * FileExists
 */
    
FileExists:
    return( stream( arg(1), 'c', 'query exists' ) <> '' )

/*
 * Usage
 */

Usage:
    say ''
    say 'Usage: build_c [target_dir] [resolution]'
    say ''
    say '    target_dir   = path where Watcom C/C++ V10.5 has been installed'
    say '    resolution   = 640x480, 800x600, 1024x768 where 640x480 is the default'
    say ''
    say 'This program builds/rebuilds the various Workplace Shell objects'
    say 'needed to run WATCOM C/C++ V10.5 .'
    exit
