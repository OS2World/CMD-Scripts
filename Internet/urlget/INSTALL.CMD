/*
**                       UrlGet Install Script
**                     copyright 1997 Ed Blackman
**
** Acknowledgments:
**  Originally by edgewood@pobox.com (Ed Blackman)
**
** Change log:
**  Who:   When:        What was done:
**  EBB    1997/Mar/31  initial version
**  EBB    1997/Apr/01  added code to allow choice of URL object class
**  EBB    1997/Apr/01  now checks to see if URL object classes are installed
**  EBB    1997/Apr/01  added code to allow choice of .INI file placement
**  EBB    1997/Apr/02  reworked initial install choices
**                      - doesn't prompt for install if already installed
**                      - allows modifying a current installation
*/

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

userapp='URLCommander'
app='URLGet'
urlpath='<WP_NEWURL>'

call SysCls
call install
exit

queryclass: procedure
    objclass.0 = 2
    objclass.1 = "WebExplorer_Url"
    objclass.2 = "WPUrl"
    
    call SysQueryClassList 'class.'
    found = 0
    do i = 1 to class.0
        parse upper var class.i classname .
        do j = 1 to objclass.0            
            if classname = translate(objclass.j) then
                found = 1
        end j
    end i
    if \found then
    do
        say
        say "URLGet creates URL objects.  In order for it to be able to do so,"
        say "at least one of the following object classes must be registered"
        say "with the WPS: "
        do i = 1 to objclass.0
            say "        " || objclass.i
        end i    
        call quit "None of these classes are registered on your system."
    end
    return

install: procedure expose userapp app urlpath 
    inifile = SysIni("USER", userapp, "IniFile")

    say "                             UrlGet Install"
    say "                       copyright 1997 Ed Blackman"
    say
    call queryclass

    say "This is the install script for URLGet.  URLGet parses text files passed"
    say "to it on the command line, finding valid URLs and using them to create"
    say "URL objects in a folder on the Desktop."
    say

    if(inifile == 'ERROR:') then
    do
        call charout ,"Would you like to continue installing URLGet? "
        key = translate(SysGetKey("noecho"))
        if key \= 'Y' then
            call quit
    end
    else /* already installed */
    do
        say "URLGet is already installed."
        call charout ,"Would you like to uninstall URLGet? "
        key = translate(SysGetKey("noecho"))
        if key == 'Y' then
            call uninstall inifile
        else
        do
            say
            say "Modifying the existing URLGet installation..."
        end /* do */
    end /* do */

    if inifile == "ERROR:" then
        inifile = getini()
    
    call getmode inifile
    call urlclass inifile
    call urlpath inifile
    say
    say "Install completed.  Copy URLGET.CMD to a directory on your path."
return

getini: procedure expose userapp
    say
    do until \SysFileTree(inipath, 'f.', 'DO') & f.0 == 1
        say "Please enter a directory where URLGet can keep its .INI file:"
        inipath = linein()
    end /* do until */

    inifile = inipath || "\URLCOMM.INI"
    
    if(SysIni("USER", userapp, 'IniFile', inifile) == 'ERROR:') then
        call quit "Could not write URLGet .INI file path to OS2.INI"
    return inifile

    
getmode: procedure expose app
    parse arg inifile
    key=''
    say
    say "In interactive mode, URLGet displays the URL and prompts the user for"
    say "a description.  If the user enters a description, it creates a URL"
    say "object, using the description and the current date and time as the"
    say "title of the URL object."
    say
    say "In batch mode, all of the valid URLs in the file are turned into URL"
    say "objects."
    say
    do until key=='B' | key=='I'
        call charout ,"Would you like URLGet to run in batch or interactive mode? (B/I) "
        key = translate(SysGetKey("noecho"))
        say
    end /* do */
    if key=='B' then mode='BATCH'
    else /* key=='I' */ mode='INTERACTIVE'

    if(SysIni(inifile, app, 'Mode', mode) == 'ERROR:') then
        call quit "Could not write URLGet mode to" inifile
    return

urlclass: procedure expose app
    parse arg inifile
    key=''
    do until key=='E' | key=='4'
        say "Would you like URLGet to create WebExplorer URL objects, or Warp"
        call charout ,"4 URL objects? (E/4) "
        key = translate(SysGetKey("noecho"))
        say
    end /* do */
    if key=='E' then do; objclass='WebExplorer_URL'; setupstr='LOCATOR='; end;
    else /* key=='4' */ do; objclass='WPUrl'; setupstr='URL='; end;

    if(SysIni(inifile, app, 'ObjectClass', objclass) == 'ERROR:') then
        call quit "Could not write URLGet object class to" inifile
    if(SysIni(inifile, app, 'SetupString', setupstr) == 'ERROR:') then
        call quit "Could not write URLGet setup string to" inifile
    return

urlpath: procedure expose urlpath app
    parse arg inifile
    if \SysSaveObject(urlpath, 1) then /* object doesn't exist */
    do
        say "Creating a folder on the Desktop to hold new URL objects..."
        if(\SysCreateObject("WPFolder", "New URLs", "<WP_DESKTOP>", "OBJECTID="urlpath, "replace")) then
            call quit "Could not create URL object folder"
    end
    if(SysIni(inifile, app, 'URLPath', urlpath) == 'ERROR:') then
        call quit "Could not write URLGet URL folder path to" inifile
    return
   
uninstall: procedure expose userapp app
    parse arg inifile
    call SysIni inifile, app, 'DELETE:'
    say
    say "Application keys for" app "deleted from" inifile
    
    call SysINI inifile, 'ALL:', 's.'
    if(s.0 = 0) then
    do
        call SysFileDelete inifile
        say "There are no more application keys in" inifile
        say inifile "deleted"

        call SysIni "USER", userapp, 'DELETE:'
        say "The reference to" inifile "in OS2.INI has been removed"
    end
    else
    do
        say "There are" s.0 "application keys remaining in" inifile
        say inifile "not deleted"
        say "The reference to" inifile "in OS2.INI has not been removed"
    end
    call quit
    return
    
quit: procedure
    parse arg message
    if message \= "" then
        say message
    say
    say "Quitting URLGet install..."
    exit
    
