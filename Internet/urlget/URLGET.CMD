/*
**                             UrlGet 1.0
**                     copyright 1997 Ed Blackman
**
** Acknowledgments:
**  Originally by mortenf@login.dknet.dk (Morten Frederiksen)
**  Complete rewrite by edgewood@pobox.com (Ed Blackman)
**
** Change log:
**  Who:   When:        What was done:
**  EBB    1996/Oct/16  removed requirement of 4OS2
**  EBB    1996/Oct/16  removed use of unnecessary temp files
**  EBB    1996/Nov/05  creates WebEx URL objects instead of writing a text file
**  EBB    1997/Mar/05  added "batch" mode capability
**                      - creates objects for all valid URLs in the input file
**                      - the name of the URL is used as the description: 
**                        the user is not prompted
**  EBB    1997/Mar/31  added install script
**  EBB    1997/Apr/01  added choice of creating Warp 4 URL objects
**  EBB    1997/Apr/15  fixed backspacing bug
*/

arg msgfile

if msgfile == "" then
    call usage

app='URLCommander'
urlpath=''
mode=''                      
objclass=''
setupstr=''

/* Load RexxUtil functions if not already loaded */
if RxFuncQuery('SysLoadFuncs') then do
    say "Loading RexxUtil functions"
    call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
    call SysLoadFuncs
end /* do */

call readini

prefix.0 = 4                            /* URL prefixes to search for */
prefix.1 = 'http://'
prefix.2 = 'https://'
prefix.3 = 'ftp://'
prefix.4 = 'gopher://'
        
do while lines(msgfile)
    msgline=linein(msgfile)
    do i = 1 to prefix.0
        if pos(prefix.i,msgline)>0 then
        do
            urltmp=substr(msgline,pos(prefix.i,msgline))
            goodurl=1
            n=1
            url=''
            do while goodurl
                ch=substr(urltmp,n,1)
                if ch=' ' | ch='>' | ch='<' | ch='"' then
                    goodurl=0
                else
                    url=url||ch
                n=n+1
            end

            if mode = 'INTERACTIVE' then
                desc = getdesc(url)
            else
                desc = url
            
            if desc <> '' then
            do
                title=desc || d2c(10) || date() time()
                if SysCreateObject(objclass, title, urlpath,,
                        setupstr || url) == 0 then
                    call create_failed
            end
        end
    end i
end

exit

create_failed:
    call SysQueryClassList 'class.'
    found = 0
    do i = 1 to class.0
        if left(class.i, length(objclass)) = objclass then
            found = 1
    end i
    if \found then
        say objclass 'is not registered.'
    say 'Cannot create object for url' url
    return

getdesc: procedure
    parse arg url .
    call charout ,'['||url||']: '
    desc = ''
    key = SysGetKey("noecho")
    do while key \= d2c(13)
        select
            when key = d2c(8) then /* backspace */
            if length(desc) > 0 then
                do
                    call erase 1
                    desc = substr(desc, 1, length(desc) - 1)
                end
            when key = d2c(27) then /* escape */
            do
                call erase length(desc)
                desc = ''
            end
            otherwise
            do
                call charout , key
                desc = desc || key
            end /* do */
        end /* select */

        key = SysGetKey("noecho")
    end /* do while */
    say
    return desc

readini: 
    inifile = SysIni("USER", app, "IniFile")
    if inifile == "ERROR:" then
    do
        say "Can't find path to .INI file"
        exit
    end
    urlpath = SysIni(inifile, "URLGet", "URLPath")
    mode = SysIni(inifile, "URLGet", "Mode")
    objclass = SysIni(inifile, "URLGet", "ObjectClass")
    setupstr = SysIni(inifile, "URLGet", "SetupString")

    concat = urlpath||mode||objclass||setupstr
    if pos("ERROR:", concat) > 0 then
    do
        say "Missing keys in" inifile
        exit
    end
    drop concat inifile
return

usage:
    say "Usage: URLGet <file>"
    say "    where <file> is the name of a text file containing URLs"
    exit
    
erase:              /* erase n characters on screen */
    parse arg n
    if n > 0 then
        do i = 1 to n
            call charout , d2c(8) || ' ' || d2c(8)
        end i
    return
