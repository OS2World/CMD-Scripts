/* Fetch documents via HTTP or FTP by URL */
call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
call SysLoadFuncs
call RxFuncAdd 'SockLoadFuncs','RxSock','SockLoadFuncs'
signal on SYNTAX
nosock=1
call SockLoadFuncs 'q'
nosock=0
signal off SYNTAX

numeric digits 10
parse version rxversion
if word(rxversion,1)\='OBJREXX' then do
	say ''
	say 'HTTPGET.CMD requires Object REXX to function.'
	say ''
	say 'You are running: '||rxversion
	say ''
	say 'README.TXT contains more information.'
    exit 6
end
rxversion=rxversion~word(2)

do until stream(rfile,'c','query exists')=''
    tmp1=random(0,65535)
    tmp2=random(0,65535)
    rfile=tmp1~d2x~right(4,'0')||tmp2~d2x~right(4,'0')||'.tmp'
end

'@ver > '||rfile
call SysFileSearch 'Windows 95',rfile,'chk1.'
call SysFileSearch 'Win95',rfile,'chk2.'

if chk1.0>0 | chk2.0>0 then win95=.true
else win95=.false

call SysFileDelete rfile

.local['RXIVERSION']=0.16
/* The following is for writing quick debug messages */
.local['DEBUG']=.stream~new('debug.log')
exitval=-1
probtype=0
success=0
failure=0
sockfail=0
servfail=0

signal on HALT
signal on SYNTAX
signal on ERROR
signal on NOVALUE
signal on FAILURE

.local['XFS']='XFER_FINISHED'
.local['STFS']='STATUS_THREAD_EXIT'
parse source progpath
progpath=progpath~subword(3)
pdrive=filespec('drive',progpath)
ppath=filespec('path',progpath)
inifile=.stream~new(pdrive||ppath||'urlget.ini')
getem=.false
getfw=.false
getlog=.false
emadd=''
firewall=''
.local['LOGGING']=.false

emadd=SysIni(inifile~qualify, 'URLGET', 'EMAIL_ADDRESS')
if emadd='ERROR:' then getem=.true
firewall=SysIni(inifile~qualify, 'URLGET', 'FIREWALL')
if firewall='ERROR:' then getfw=.true
.local['LOGGING']=SysIni(inifile~qualify, 'URLGET', 'LOGGING')
if .logging='ERROR:' then getlog=.true

if getem then do
    ok=5
    do until ok=1
        call SysCls
        call SysCurState 'off'
        if ok=0 then do
            call SysCurPos 10,0
            say 'Invalid e-mail address (must contain "@").'
        end
        call SysCurPos 12,0
        say 'Please enter your e-mail address for anonymous FTP transfers:'
        call SysCurState 'on'
        parse pull emadd
        if emadd~pos('@')=0 then ok=0
        else ok=1
    end
    call SysIni inifile~qualify,'URLGET','EMAIL_ADDRESS',emadd
end
if getfw then do
    ok=5
    do until ok=1
        call SysCls
        call SysCurState 'off'
        if ok=0 then do
            call SysCurPos 10,0
            say 'Answer only Y or N.'
        end
        call SysCurPos 12,0
        say 'Are you connected to the Internet through a firewall or proxy server? (Y/N)'
        ans=SysGetKey('noecho')
        if ans~translate\='Y' & ans~translate\='N' then ok=0
        else do
            ok=1
            if ans~translate='Y' then firewall=.true
            else firewall=.false
        end
    end
    call SysIni inifile~qualify,'URLGET','FIREWALL',firewall
end
if getlog then do
    ok=5
    do until ok=1
        call SysCls
        call SysCurState 'off'
        if ok=0 then do
            call SysCurPos 10,0
            say 'Answer only Y or N.'
        end
        call SysCurPos 12,0
        say 'Enable logging? (Y/N)'
        ans=SysGetKey('noecho')
        if ans~translate\='Y' & ans~translate\='N' then ok=0
        else do
            ok=1
            if ans~translate='Y' then .local['LOGGING']=.true
            else .local['LOGGING']=.false
        end
    end
    call SysIni inifile~qualify,'URLGET','LOGGING',.logging
end

if \win95 then .local['STINTERVAL']=50
else .local['STINTERVAL']=100
.local['BLOCKSIZE']=10240
.local['MAXRETRIES']=1000
if \win95 then .local['COMMANDDELAY']=0.1
else .local['COMMANDDELAY']=1
.local['OVERWRITE']=.true

.local['NOERROR']=0
.local['SOCKERROR']=1
.local['SERVERROR']=2
.local['PATHERROR']=3
.local['AUTHERROR']=4
.local['NOIMPLEMENT']=5
.local['OTHERERROR']=6
.local['ARGERROR']=7
.local['USERABORT']=8
.local['OPTION']=9

urlstring=''
resume=.false
ignorepassive=.false
forceresume=.false
overwrite=.true
dupecheck=.true
quietmode=.false
.local['SUPERQUIET']=.false
addtourl=.false
parse arg argstring
if argstring~strip='' then do
    call usage 
    exit 2
end
if argstring~pos('"')>0 then do
    parse var argstring before '"' urlstring '"' after
    urlstring=urlstring~strip
    argstring=before~strip||' '||after~strip
end
do i=1 to argstring~words
    badvar=.false
    currarg=argstring~word(i)~strip
    select
        when addtourl then do
            urlstring=urlstring||currarg
            addtourl=.false
        end
        when (currarg~left(7)~translate='HTTP://' |,
              currarg~left(6)~translate='FTP://') then do
            urlstring=currarg
            if currarg~right(1)=';' then addtourl=.true
        end
        when currarg~left(1)='@' then do
            parse var currarg '@' urllist
            urllist=urllist~strip
            ulist=.stream~new(urllist)
            if ulist~query('exists')='' then do
                say ''
                say 'URL list file not found!'
                exit 2
            end
            else urlstring='fromfile'
        end
        when (currarg~left(1)='/' | currarg~left(1)='-') then do
            select
                when currarg~length=2 then do
                    select
                        when currarg~right(1)~translate='Q' then quietmode=.true
                        when currarg~right(1)~translate='R' then resume=.true
                        when currarg~right(1)~translate='N' then overwrite=.false
                        when currarg~right(1)~translate='C' then dupecheck=.false
                        when currarg~right(1)~translate='P' then ignorepassive=.true
                        when currarg~right(1)~translate='L' then .local['LOGGING']=.true
                        when currarg~right(1)~translate='W' then firewall=.true
                        when currarg~right(1)~translate='F' then do
                            resume=.true
                            forceresume=.true
                        end
                        otherwise do
                            say ''
                            say 'Invalid switch, '||currarg||'.'
                            call usage
                            exit 2
                        end
                    end
                end
                when currarg~length=3 & currarg~right(2)~translate='QQ' then do
                    .local['SUPERQUIET']=.true
                    quietmode=.true
                end
                when currarg~left(2)~right(1)~translate='D' then do
                    .local['COMMANDDELAY']=currarg~right(currarg~length-2)
                    if .commanddelay~datatype('num')=0 then badvar=.true
                    else do
                        if win95 then do
                            if .commanddelay~datatype('w')=0 then badvar=.true
                            else if (.commanddelay<0 | .commanddelay>5) then badvar=.true
                        end
                        else if (.commanddelay<0 | .commanddelay>5) then badvar=.true
                    end
                    if badvar then do
                        say ''
                        say 'Invalid command delay, '||.commanddelay||'.'
                        exit 2
                    end
                end
                when currarg~left(2)~right(1)~translate='B' then do
                    .local['BLOCKSIZE']=currarg~right(currarg~length-2)
                    if .blocksize~datatype('W')=0 then badvar=.true
                    else if (.blocksize<512 | .blocksize>65535) then badvar=.true
                    if badvar then do
                        say ''
                        say 'Invalid blocksize, '||.blocksize||'.'
                        exit 2
                    end
                end
                when currarg~left(2)~right(1)~translate='T' then do
                    .local['STINTERVAL']=currarg~right(currarg~length-2)
                    if .blocksize~datatype('W')=0 then badvar=.true
                    else do
                        if win95 then do
                            if (.stinterval<1 | .stinterval>5) then badvar=.true
                            else .local['STINTERVAL']=.stinterval*100
                        end
                        else if (.stinterval<1 | .stinterval>500) then badvar=.true
                    end
                    if badvar then do
                        say ''
                        say 'Invalid status time interval, '||.stinterval||'.'
                        exit 2
                    end
                end
                when currarg~left(2)~right(1)~translate='M' then do
                    .local['MAXRETRIES']=currarg~right(currarg~length-2)
                    if .maxretries~datatype('W')=0 then badvar=.true
                    else if (.maxretries<0 | .maxretries>9999999999) then badvar=.true
                    if badvar then do
                        say ''
                        say 'Invalid maximum retries, '||.maxretries||'.'
                        exit 2
                    end
                end
                otherwise do
                    call qasay ''
                    call qasay 'Invalid parameter ('||currarg||').'
                    call usage 
                    exit 2
                end
            end
        end
        when currarg~left(1)=';' then do
            if currarg~length=1 then do
                addtourl=.true
                urlstring=urlstring||currarg
            end
            else urlstring=urlstring||currarg
        end
        otherwise do
            call qasay ''
            call qasay 'Invalid parameter ('||currarg||').'
            call usage 
            exit 2
        end
    end
end
    
urls=.queue~new

if urlstring='fromfile' then do 
    do while ulist~lines>0
        turl=ulist~linein~strip
        select
            when turl~left(2)='//' then nop
            when turl~left(1)='#' then nop
            when turl~left(1)=';' then nop
            when turl~left(2)='/*' then nop
            otherwise urls~queue(turl)
        end
    end
    ulist~close
end
else urls~queue(urlstring)
urls=urls~makearray
	
currdrive=directory()~left(2)
fatcheck=SysFileSystemType(currdrive)

srow=-1
.local['CRLF']='0d0a'x
.local['LF']='0a'x

if \.superquiet then call SysCurState 'off'
.local['LOG']=.logfile~new(pdrive||ppath||'\urlget.log')
.local['CON']=.estream~new('stdout')
if \quietmode then scs=.scrstatus~new
.local['PADDR']=''
.local['PDIR']=''
.local['PPROT']=''
.local['PUSER']=''

do i=1 to urls~items
    if \.superquiet then call SysCls
    passivefail=.false
    .local['SIZE']=0
    if \quietmode then .local['SQ']=.queue~new
    if \quietmode then .local['TQ']=.queue~new
    currxfail=.false
    retries=0
    .local['RESTART']=0
    newname=0
    headend=.array~new
    headend[1]=.crlf||.crlf
    headend[2]=.lf||.lf
    parse value urls[i] with ustring ';' .
    .local['CURRURL']=ustring
    parse value urls[i] with prot '://' host '/' path ';' lfile
    prot=prot~strip~translate
    if prot\='HTTP' & prot\='FTP' then do
        if .logging then .log~failed(.argerror,'invalid URL')
        if urls~items>1 then do
            failure=1
            iterate i
        end
        else do
            call usage
            exit 2
        end
    end
    host=host~strip
    if host='' | host~pos(' ')>0 then do
        if .logging then .log~failed(.argerror,'invalid URL')
        if urls~items>1 then do
            failure=1
            iterate i
        end
		else do
            call usage
            exit 2
		end
    end
    if prot='HTTP' then do
        parse var host host ':' port
        port=port~strip
        if port='' then port=80
    end
    else do
        if host~pos('@')>0 then do
            parse var host userpass '@' host
            if userpass~pos(':')>0 then parse var userpass user ':' pass
            else do
                if .logging then .log~failed(.argerror,'invalid FTP URL')
                if urls~items>1 then do 
                    failure=1
                    iterate i
                end
                else do
                    call qasay ''
                    call qasay 'Invalid FTP URL supplied.'
                    exit 2
                end
            end
            user=user~strip
            pass=pass~strip
            parse value .currurl with before (pass) after
            .local['CURRURL']=before||'*'~copies(pass~length)||after
            parse var host host ':' port
            port=port~strip
            if port='' then port=21
            host=host~strip
        end
        else do
            user='anonymous'
            pass=emadd
            parse var host host ':' port
            port=port~strip
            if port='' then port=21
            host=host~strip
        end
    end
	if path~pos('/')>0 then do
		rpath=path~reverse
		parse var rpath file '/' dirpath
		file=file~reverse~strip
        dirpath='/'||dirpath~reverse~strip
	end
	else do
		file=path~strip
		dirpath='/'
	end
	lfile=lfile~strip
    if file='' then do
        if lfile='' then do
            if .logging then .log~failed(.argerror,'invalid URL')
            if urls~items>1 then do
                failure=1
                iterate i
            end
            else do
                call usage
                exit 2
            end
        end
    end
	if lfile='' then lfile=file
    if dirpath~pos(' ')>0 & prot='HTTP' then do until dirpath~pos(' ')=0
        parse var dirpath before ' ' after
        dirpath=before||'%20'||after
    end
	longea=0
    dfile=file
    if file~pos(' ')>0 & prot='HTTP' then do until file~pos(' ')=0
        parse var file before ' ' after
        file=before||'%20'||after
    end
    ldrive=filespec('drive',lfile)
    if ldrive\='' then do
        fatcheck=SysFileSystemType(ldrive)
    end
    if fatcheck='FAT' & win95=.false then do
        ldrive=filespec('drive',lfile)
        if ldrive='' then ldrive='DEF'
        lpath=filespec('path',lfile)
        if lpath='' then lpath='DEF'
        lname=filespec('name',lfile)
        parse var lname basename '.' ext
        parse value lname~reverse with ext2 '.' basename2
		select 
			when ext\=ext2~reverse then newname=1
			when basename\=basename2~reverse then newname=1
			when basename~length>8 then newname=1
			when ext~length>3 then newname=1
			when basename~pos(' ')>0 then newname=1
			when ext~pos(' ')>0 then newname=1
            otherwise newname=0
		end
		if newname=1 then do
			if ext~length<=3 then shext='.'||ext
            else shext='.UGF'
		end
		done=0
		if newname=1 then do until done=1
			p1=right(d2x(random(65535)),4,'0')
			p2=right(d2x(random(65535)),4,'0')
            select
                when ldrive='DEF' & lpath='DEF' then ltot=p1||p2||shext
                when ldrive='DEF' then ltot=lpath||p1||p2||shext
                when lpath='DEF' then ltot=ldrive||p1||p2||shext
                otherwise ltot=ldrive||lpath||p1||p2||shext
            end
            outfile=.stream~new(ltot)
			if outfile~query('exists')='' then do
				done=1
				longea=1
                longval='FDFF'x||filespec('name',lfile)~length~d2c||,
                        '00'x||filespec('name',lfile)
                lname=filespec('name',outfile~qualify)
                select
                    when ldrive='DEF' & lpath='DEF' then lfile=lname
                    when ldrive='DEF' then lfile=lpath||lname
                    when lpath='DEF' then lfile=ldrive||lname
                    otherwise lfile=ldrive||lpath||lname
                end
            end
		end
		else outfile=.stream~new(lfile)
	end
	else outfile=.stream~new(lfile)

    if \overwrite & \(prot='FTP' & resume) then do
        if outfile~query('exists')\='' then do
            call qasay ''
            call qasay 'Local file exists, not overwriting.'
            if .logging then .log~failed(.option,'overwrite disabled, file exists')
            iterate i
        end
    end

	servport=host||':'||port

    if prot='HTTP' then user=''

    if (servport=.paddr & prot='FTP' & user=.puser) then cconn=.true
    else do
        cconn=.false
        if .pprot='FTP' then do
            if fs~defaultname='a FTPSESSION' then do
                foobar=fs~logoff
                csock~shutdown('both')
                csock~close
            end
        end
    end

    .local['PPROT']=prot
    .local['PADDR']=servport
    if prot='FTP' then .local['PUSER']=user

    if cconn then do
        call qasay ''
        call qasay ''
        .con~~charout('Using current connection...'||.crlf)~flush
        if dirpath=.pdir then do
            .con~~charout('Current directory is correct...'||.crlf)~flush
        end
        else do
            .con~~charout('Changing to directory '||dirpath||'... ')~flush
            rval=fs~chdir(dirpath)
            if rval='HALT' then signal HALT
            if rval\=.noerror then do
                call qasay ''
                call qasay 'Failed to change working directory.'
                failure=1
                select
                    when rval=.sockerror then sockfail=1
                    when rval=.patherror then do
                        servfail=1
                        call qasay 'Directory does not exist or access denied.'
                        iterate i
                    end
                    otherwise do
                        call qasay 'Error = '||rval
                        iterate i
                    end
                end
            end
            else do
                .con~~charout('Done'||.crlf)~flush
                .local['PDIR']=dirpath
            end
        end
    end

    if \cconn then do

        csock=.socket~new

        call qasay ''
        call qasay ''
        .con~~charout('Connecting to host '||host||' on port '||port||'... ')~flush
        check=csock~connect(servport)
        if check='HALT' then signal HALT
        if check=-1 then do
            if .logging then .log~failed(.sockerror,'host connection failed')
            .con~~charout('Failed!'||.crlf)~flush
            call sockclean('control')
            sockfail=1
            failure=1
            iterate i
        end
        else .con~~charout('Done'||.crlf)~flush
    
        if prot='HTTP' then httpsendstring='GET '||dirpath||'/'||file||' HTTP/1.0'||.crlf||,
                           'Accept: */*'||.crlf||,
                           'Accept-Encoding: */*'||.crlf||,
                           'User-Agent: URLGet/'||.rxiversion||'  Object REXX/'||rxversion||.crlf||,
                           .crlf
    end
    
    if prot='HTTP' then do
        .con~~charout('Sending request string... ')~flush
        check=csock~send(httpsendstring)
        if check='HALT' then signal HALT
        if check=-1 then do
            if .logging then .log~failed(.sockerror,'HTTP send request failed')
            .con~~charout('Failed!'||.crlf)~flush
            call sockclean('control')
            sockfail=1
            failure=1
            iterate i            
        end
        else .con~~charout('Done'||.crlf)~flush
    end

    else do 
        if \cconn then do
            fs=.FTPSession~new(csock)
            .con~~charout('Logging in')~flush
            if user='anonymous' then .con~~charout('... ')~flush
            else .con~~charout(' as '||user||'... ')~flush
            rval=fs~login(user,pass)
            if rval='HALT' then signal HALT
            if rval\=.noerror then do
                failure=1
                .con~~charout('Failed!'||.crlf)~flush
                call qasay ''
                select
                    when rval=.sockerror then do
                        sockfail=1
                        call qasay 'Socket error logging in.'
                    end
                    when rval=.serverror then do
                        servfail=1
                        call qasay 'Login not allowed.'
                    end
                    otherwise nop
                end
                iterate i
            end
            else .con~~charout('Done'||.crlf)~flush
            .con~~charout('Setting binary transfer mode... ')~flush
            rval=fs~setbinary
            if rval='HALT' then signal HALT
            if rval\=.noerror then do
                .con~~charout('Failed!'||.crlf)~flush
                call qasay ''
                call qasay 'Failed to set binary transfer mode.'
                failure=1
                if rval=.sockerror then sockfail=1
                else servfail=1
                iterate i
            end
            else .con~~charout('Done'||.crlf)~flush
            .con~~charout('Changing to directory '||dirpath||'... ')~flush
            rval=fs~chdir(dirpath)
            if rval='HALT' then signal HALT
            if rval\=.noerror then do
                call qasay ''
                call qasay 'Failed to change working directory.'
                failure=1
                select
                    when rval=.sockerror then sockfail=1
                    when rval=.patherror then do
                        servfail=1
                        call qasay 'Directory does not exist or access denied.'
                        iterate i
                    end
                end
            end
            else do
                .con~~charout('Done'||.crlf)~flush
                .local['PDIR']=dirpath
            end
        end
        if file\='' then do
            .con~~charout('Retrieving file size... ')~flush
            rval=fs~getsize(file)
            if rval='HALT' then signal HALT
            if rval\=.noerror then do
                select
                    when rval=.sockerror then do
                        sockfail=1
                        failure=1
                        call qasay ''
                        call qasay 'Socket error while getting file size.'
                        iterate i
                    end
                    when rval=.falseimplement then do
                        if forceresume then do
                            servfail=1
                            failure=1
                            if .logging then .log~failed(.serverror,'resume required, cannot determine remote file size')
                            call qasay ''
                            call qasay 'Cannot determine remote size.'
                            iterate i
                        end
                        resume=.false
                        fs~setresume(.false)
                        .local['SIZE']=0
                    end
                    otherwise .con~~charout('Failed!'||.crlf)~flush
                end
            end
            else do 
                .local['SIZE']=fs~size 
                .con~~charout('Done'||.crlf)~flush
                if .size=outfile~query('size') & dupecheck then do
                    call qasay ''
                    call qasay 'Local file exists, and is not smaller than server copy.'
                    call qasay 'Not overwriting.'
                    if .logging then .log~failed(.option,'dupe checking enabled, local copy same size as server copy')
                    iterate i
                end
            end
        end
        else .local['size']=0
        if firewall then do
            .con~~charout('Setting passive mode... ')~flush
            rval=fs~setpassive
            if rval='HALT' then signal HALT
            if rval\=.noerror then do
                select
                    when rval=.sockerror then do
                        sockfail=1
                        call qasay 'Socket error setting passive mode.'
                    end
                    when rval=.autherror then do
                        if ignorepassive then do
                            passivefail=.true
                            .con~~charout('Failed!'||.crlf)~flush
                        end
                        else do
                            failure=1
                            servfail=1
                            if .logging then .log~failed(.serverror,'passive mode required, but denied: '||.passdenycode)
                            call qasay ''
                            call qasay 'Server refused passive connection.'
                            iterate i
                        end
                    end
                    otherwise .con~~charout('Failed!'||.crlf)~flush
                end
            end
            else .con~~charout('Done'||.crlf)~flush
        end
        if (\firewall | (firewall & passivefail)) then do
            .con~~charout('Sending data port... ')~flush
            rval=fs~sendport
            if rval='HALT' then signal HALT
            if rval\=.noerror then do
                failure=1
                call qasay ''
                select
                    when rval=.sockerror then do
                        sockfail=1
                        call qasay 'Socket error sending data port.'
                    end
                    otherwise do
                        servfail=1
                        call qasay 'Unable to send data port.'
                    end
                end
                iterate i
            end
            else .con~~charout('Done'||.crlf)~flush
        end
        if resume & file\='' then do
            if outfile~query('exists')\='' then do
                .con~~charout('Setting restart marker... ')~flush
                rval=fs~setrestart(outfile)
                if rval='HALT' then signal HALT
                if rval\=.noerror then do
                    select
                        when rval=.sockerror then do
                            sockfail=1
                            failure=1
                            .con~~charout('Failed!'||.crlf)~flush
                            call qasay ''
                            call qasay 'Socket error setting restart marker.'
                            iterate i
                        end
                        otherwise do
                            if forceresume then do
                                failure=1
                                servfail=1    
                                if .logging then .log~failed(.serverror,'resume required, not supported by server')
                                .con~~charout('Failed!'||.crlf)~flush
                                call qasay ''
                                call qasay 'Server does not support resume, aborting transfer.'
                                iterate i
                            end
                            else .con~~charout('Failed!'||.crlf)~flush
                        end
                    end
                end
                else do
                    .local['RESTART']=fs~restart
                    .con~~charout('Done'||.crlf)~flush
                end
            end
        end
        .con~~charout('Sending retrieve request... ')~flush
        if file='' then rval=fs~retrievelisting
        else rval=fs~retrieve
        if rval='HALT' then signal HALT
        if rval~objectname\='an Array' then do
            failure=1
            call qasay ''
            select
                when rval=.sockerror then do
                    sockfail=1
                    call qasay 'Socket error on retrieve.'
                end
                otherwise do
                    servfail=1
                    call qasay 'Unable to retrieve.'
                end
            end
            iterate i
        end
        else do
            dsock=rval[2]
            if dsock~objectname~translate\='A SOCKET' then do
                failure=1
                if .logging then .log~failed(.othererror,'error with data socket')
                call qasay ''
                call qasay 'Error with data socket.'
                iterate i
            end
            else .con~~charout('Done'||.crlf)~flush
        end 
    end        

    total=0
    if \quietmode then .sq~queue(total)
    nofile=0     
    headgone=0
    security=0
	dumbserver=0
    .local['FINISHED']=.false
    fileopen=.false
    call time 'r'

    do until .finished
        if prot='HTTP' then check=csock~receive(.blocksize)
        else check=dsock~receive(.blocksize)
		if check='HALT' then signal HALT
        rvar=check[2]
        if rvar<0 then do
            if \headgone then do
                if retries>.maxretries then .local['FINISHED']=.true
                else retries=retries+1
            end
            else do
                if total+resume < size then do
                    if retries>.maxretries then .local['FINISHED']=.true
                    else retries=retries+1
                end
                else .local['FINISHED']=.true
            end
		end
        else if rvar=0 then .local['FINISHED']=.true
        data=check[1]
        if \headgone then do
            if prot='HTTP' & data~word(2)='404' then nofile=1
            else if prot='HTTP' & data~word(2)='403' then security=1
            else if prot='HTTP' & data~word(2)='406' then dumbserver=1
            else if (data~pos(headend[1])>0 | data~pos(headend[2])>0) |,
                     prot='FTP' then do
				headgone=1
                if prot='HTTP' then do
                    if data~pos(headend[1])>0 then do
                        he=headend[1]
                        le=.crlf
                    end
                    else do
                        he=headend[2]
                        le=.lf
                    end
                    parse var data header (he) bufdata
                    if header~pos('ength:')>0 then do
                        header=header||le
                        parse var header 'ength:' stemp (le)
                        .local['SIZE']=stemp~strip
                        if .size~datatype='NUM' then nop
                        else .local['SIZE']=0
                    end
                    else .local['SIZE']=0
                end
                else bufdata=data
                if .size\=0 then do
                    if .size=outfile~query('size') & dupecheck then do
                        call qasay ''
                        call qasay 'Local file exists, and is not smaller than server copy.'
                        call qasay 'Not overwriting.'
                        if .logging then .log~failed(.option,'dupe checking enabled, local copy same size as server copy')
                        iterate i
                    end
                end
                total=total+bufdata~length
                if \quietmode then .sq~queue(total)
			end
		end
		else do
            if \fileopen then do
                if (prot='HTTP' | (prot='FTP' & .restart=0)) then do
                    if outfile~open('write replace')\='READY:' then do
                        call qasay ''
                        call qasay ''
                        call qasay 'Unable to open file '||outfile~qualify||' for writing!'
                        failure=1
                        iterate i
                    end
                end
                else do
                    if outfile~open('write append')\='READY:' then do
                        call qasay ''
                        call qasay ''
                        call qasay 'Unable to open file '||outfile~qualify||' for writing!'
                        failure=1
                        iterate i
                    end
                end
                fileopen=.true
                call qasay 'Receiving URL:'
                call qasay ''
                if .currurl~length>79 then call qasay .currurl~left(78)||'>'
                else call qasay .currurl
                call qasay ''
                if lfile\=file then do
                    call qasay 'Stored locally as '||lfile||'...'
                    call qasay ''
                end
                if (prot='FTP' & .restart>0) then do
                    call qasay 'Resuming from byte '||codel(.restart)||...
                    call qasay ''
                end
                if \quietmode then scs~template
                if \quietmode then do
                    if .size>0 then scs~size(.size)
                    else scs~sizeunknown
                end
                else do
                    if .size=0 then call qasay 'Total size: UNKNOWN'
                    else call qasay 'Total size: '||codel(.size)
                    call qasay ''
                end
                if \quietmode then scs~begin
                if outfile~charout(bufdata)\=0 then do
                    if \quietmode then do
                        .sq~queue(.xfs)
                        stcheck=''
                        do until stcheck=.stfs
                            stcheck=.tq~pull
                        end
                    end
                    call qasay ''
                    call qasay ''
                    call qasay 'Error writing data to '||outfile~qualify||'.'
                    outfile~close
                    failure=1
                    iterate i
                end
            end
            if outfile~charout(data)\=0 then do
                if \quietmode then do
                    .sq~queue(.xfs)
                    stcheck=''
                    do until stcheck=.stfs
                        stcheck=.tq~pull
                    end
                end
                call qasay ''
                call qasay ''
                call qasay 'Error writing data to '||outfile~qualify||'.'
                outfile~close
                failure=1
                iterate i
            end
            total=total+data~length
            if \quietmode then .sq~queue(total)
		end
        if .finished then do
			ct=time('e')
            if ct=0 then ct=0.01
            if \quietmode then .sq~queue(total)
            if \quietmode then .sq~queue(.xfs)
            if \quietmode then do
                stcheck=''
                do until stcheck=.stfs
                    stcheck=.tq~pull
                end
            end
            if .size>0 then do
                if (total+.restart)<.size then do
                    if .logging then .log~failed(.sockerror,'maximum retries exceeded')
                    call qasay ''
                    call qasay ''
                    call qasay 'Maximum retries reached - transfer failed!'
                    sockfail=1
                    failure=1
                    currxfail=.true
				end
			end
            rate=total%ct
            if \quietmode then do
                call qasay ''
                call qasay ''
			end
            call qasay codel(total)||' bytes received in '||codel(ct~format(,2))||,
					' seconds ('||codel(rate)||' bytes/sec.)'
            if .logging & \currxfail then do
                if .restart>0 then .log~transfer(total,ct,.restart)
                else .log~transfer(total,ct)
            end
		end
		if nofile=1 then do
            if .logging then .log~failed(.serverror,"remote file doesn't exist")
            call qasay ''
            call qasay ''
            call qasay "Remote file doesn't exist!"
			longea=0
		end
		if dumbserver=1 then do
            if .logging then .log~failed(.serverror,'improper server returned 406')
            call qasay ''
            call qasay ''
            call qasay "Incorrect protocol usage at remote server, returned 406!"
			longea=0
		end
        if security=1 then do
            if .logging then .log~failed(.serverror,'no access or other error')
            call qasay ''
            call qasay ''
            call qasay "No permission or other access error!"
            longea=0
        end
        if nofile=1 | dumbserver=1 | security=1 then leave
	end
    if nofile\=1 then do
        success=1
        outfile~close 
    end
	if longea=1 then call SysPutEA outfile~qualify,'.LONGNAME',longval

    if prot='FTP' then do
        fs~transconf
        dsock~shutdown('both')
        dsock~close
        if i=urls~items then do
            foobar=fs~logoff
            csock~shutdown('both')
            csock~close
        end
    end
    if prot='HTTP' then do
        csock~shutdown('both')
        csock~close
    end
end

select 
    when success=1 & failure=0 then exitval=0
    when success=1 & failure=1 then exitval=1
    when urls~items=1 & sockfail=1 then exitval=3
    when urls~items=1 & servfail=1 then exitval=4
    when urls~items>1 & sockfail=1 & servfail=1 & success=0 then exitval=30
    otherwise exitval=255
end

exit exitval

SYNTAX:
if nosock=1 then do
    call qasay ''
    call qasay 'Failed to load REXX Socket functions.'
    call qasay ''
    call qasay 'Program cannot continue.'
    exit 6
end
probtype='SYNTAX'
probline=sigl
signal handler
ERROR:
probtype='ERROR'
probline=sigl
signal handler
NOVALUE:
probtype='NOVALUE'
probline=sigl
signal handler
FAILURE:
probtype='FAILURE'
probline=sigl
signal handler
handler:
call qasay ''
call qasay ''
call qasay 'Problem of type '||probtype||' on source line #'||probline||'!'
call qasay ''
if symbol('rc')='VAR' then call qasay 'Cause of error: '||rc||' - '||errortext(rc)
call qasay ''
call qasay 'Source line content:'
call qasay sourceline(probline)
call qasay ''
call qasay 'Please notify thanny@home.com about this, with as much possible detail.'
exitval=6
HALT: 
if symbol('quietmode')='VAR' then if quietmode\=1 then do
    if srow=-1 | datatype(srow,'num')=0 then do
		parse value SysCurPos() with row col
		srow=row+2
	end
	call SysCurPos srow,75
end
else do
    call qasay ''
    call qasay ''
end
call qasay ''
call qasay ''
call qasay 'Aborting!'
if symbol('.log')='VAR' & probtype=0 then .log~failed(.userabort,'program halted')
call sockclean
if exitval=-1 then do
    select
        when success=0 then exitval=5
        when success=1 then do
            select
                when failure=0 then exitval=0
                when symbol('urls')='VAR' then do
                    if symbol('i')='VAR' then do
                        if urls~items>=i then exitval=1
                    end
                    else exitval=0
                end
            end
        end
    end
end
if \quietmode then .sq~queue(.xfs)
exit exitval

sockclean: procedure expose csock dsock

if symbol('csock')='VAR' then if csock~objectname~translate='A SOCKET' then do
    csock~shutdown('both')
    csock~close
end
if symbol('dsock')='VAR' then if dsock~objectname~translate='A SOCKET' then do
    dsock~shutdown('both')
    dsock~close
end
return

/* Socket class - work in progress **************************************/
/*                                                                      */
::class socket

::method init
expose portnum
use arg type,proto
if symbol('type')='LIT' then type='SOCK_STREAM'
if symbol('proto')='LIT' then proto=0
if type~datatype('num')=1 then portnum=type
else portnum=SockSocket('AF_INET',type,proto)
return

::method sock
expose portnum
return portnum

::method connect
use arg servname
signal on HALT
parse var servname hostname ':' host.!port
parse var hostname o1 '.' o2 '.' o3 '.' o4
if o1~datatype='NUM' & o2~datatype='NUM' & o3~datatype='NUM' &,
   o4~datatype='NUM' then do
	if o1~datatype('w')=1 & o2~datatype('w')=1 & o3~datatype('w')=1 &,
	   o4~datatype('w')=1 then do
		if (o1>=0 & o1<=255) & (o2>=0 & o2<=255) & (o3>=0 & o3<=255) &,
		   (o4>=0 & o4<=255) then do
			stype='IP'
			host.!addr=hostname
		end
	end
end
else stype='NAME'            
if stype='NAME' then call SockGetHostByName hostname,'host.!'
host.!family='AF_INET'
rc=SockConnect(self~sock,'host.!')
return rc
HALT:
return 'HALT'

::method send
use arg sendstring
signal on HALT
rc=SockSend(self~sock,sendstring)
return rc
HALT:
return 'HALT'

::method receive
use arg length
signal on HALT
if length='LENGTH' then length=1024
check=SockRecv(self~sock,'sockdata',length)
return .array~new~~put(sockdata,1)~~put(check,2)
HALT:
return 'HALT'

::method bind
host.!addr=SockGetHostId()
host.!port=self~sock
host.!family='AF_INET'
rval=SockBind(self~sock,'host.!')
return rval

::method listen
rval=SockListen(self~sock, 65536)
return rval

::method accept
use arg goodaddr
newsock=SockAccept(self~sock)
return newsock

::method shutdown
use arg how
select
	when how~translate='FROM' then how=0
	when how~translate='TO' then how=1
	otherwise how=2
end
call SockShutDown self~sock,how
return

::method close
call SockClose self~sock
return
/*                                                                      */
/************************************************************************/

/* FTP session object ***************************************************/
/*                                                                      */
::class FTPSession

::method init
expose fsize marker dsock lsock csock passivemode
signal on HALT
use arg csock
marker=0
passivemode=.false
return

::method size
expose fsize
signal on HALT
return fsize

::method login
use arg user,pass
signal on HALT
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'
    when rval[1]=-1 then do
        if .logging then .log~failed(.sockerror,'waiting for FTP server')
        return .sockerror
    end
    when rval[2]\='220' then do
        if .logging then .log~failed(.serverror,'not accepting users: '||rval[2])
        return .serverror
    end
    otherwise nop
end
rval=self~send('USER '||user)
select
    when rval='HALT' then return 'HALT'
    when rval=-1 then do
        if .logging then .log~failed(.sockerror,'sending user name')
        return .sockerror
    end
    otherwise nop
end
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'    
    when rval[1]=-1 then do
        if .logging then .log~failed(.sockerror,'awaiting password request')
        return .sockerror
    end
    when rval[2]\='331' then do
        if .logging then .log~failed(.serverror,'user not allowed: '||rval[2])
        return .serverror
    end
    otherwise nop
end
rval=self~send('PASS '||pass)
select
    when rval='HALT' then return 'HALT'
    when rval=-1 then do
        if .logging then .log~failed(.sockerror,'sending password')
        return .sockerror
    end
    otherwise nop
end
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'
    when rval[1]=-1 then do
        if .logging then .log~failed(.sockerror,'awaiting password acceptance')
        return .sockerror
    end
    when rval[2]\='230' then do 
        if .logging then .log~failed(.serverror,'password denied: '||rval[2])
        return .autherror
    end
    otherwise return .noerror
end

::method logoff
signal on HALT
rval=self~send('QUIT')
select
    when rval='HALT' then return 'HALT'
    when rval=-1 then return .sockerror
    otherwise nop
end
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'    
    when rval[1]=-1 then return .sockerror
    when rval[2]\='226' then return .serverror
    otherwise return .noerror
end

::method transconf
signal on HALT
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'
    otherwise nop
end

::method setbinary
signal on HALT
rval=self~send('TYPE I')
select
    when rval='HALT' then return 'HALT'
    when rval=-1 then do
        if .logging then .log~failed(.sockerror,'sending binary mode request')
        return .sockerror
    end
    otherwise nop
end
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'
    when rval[1]=-1 then do
        if .logging then .log~failed(.sockerror,'awaiting binary mode confirmation')
        return .sockerror
    end
    when rval[2]\='200' then do
        if .logging then .log~failed(.serverror,'could not set binary transfer mode: '||rval[2])
        return .serverror
    end
    otherwise return .noerror
end

::method chdir
use arg dirpath
signal on HALT
rval=self~send('CWD '||dirpath)
select
    when rval='HALT' then return 'HALT'
    when rval=-1 then do
        if .logging then .log~failed(.sockerror,'sending directory change')
        return .sockerror
    end
    otherwise nop
end
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'
    when rval[1]=-1 then do
        if .logging then .log~failed(.sockerror,'awaiting directory change confirmation')
        return .sockerror
    end
    when (rval[2]='550' | rval[2]='450') then do
        if .logging then .log~failed(.serverror,'bad path or no access: '||rval[2])
        return .patherror
    end
    when rval[2]='250' then return .noerror
    otherwise do
        return .othererror
    end        
end

::method setpassive
expose passivemode dsock
signal on HALT
rval=self~send('PASV')
select
    when rval='HALT' then return 'HALT'
    when rval=-1 then do
        if .logging then .log~failed(.sockerror,'sending passive mode request')
        return .sockerror
    end
    otherwise nop
end
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'
    when rval[1]=-1 then do
        if .logging then .log~failed(.sockerror,'awaiting passive mode confirmation')
        return .sockerror
    end
    when rval[2]='425' then do
        .local['PASSDENYCODE']=rval[2]
        return .autherror
    end
    when rval[2]='227' then do
        recd=rval[3]
        parse var recd . '(' hostport ')' .
        parse var hostport h1 ',' h2 ',' h3 ',' h4 ',' p1 ',' p2
        host=h1||'.'||h2||'.'||h3||'.'||h4
        port=(p1~d2c||p2~d2c)~c2d
        servport=host||':'||port
        dsock=.socket~new
        check=dsock~connect(servport)                                                                                             
        if check='HALT' then return HALT                                    
        if check=-1 then do
            if .logging then .log~failed(.sockerror,'could not establish data connection')
            return .sockerror
        end
        passivemode=.true
        return .noerror
    end
    otherwise return .othererror
end

::method setrestart
expose resume marker 
signal on HALT
use arg ofile
if ofile='' then return .othererror
if fsize='' | fsize=0 then return .othererror
if ofile~query('exists')\='' then do
    marker=ofile~query('size')
    if fsize<=marker then return .falseimplement
end
rval=self~send('REST '||marker)
select
    when rval='HALT' then return 'HALT'
    when rval=-1 then do
        if .logging then .log~failed(.sockerror,'sending restart marker')
        return .sockerror
    end
    otherwise nop
end
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'
    when rval[1]=-1 then do
        if .logging then .log~failed(.sockerror,'receiving restart confirmation')
        return .sockerror
    end
    when rval[2]='350' then return .noerror
    otherwise return .falseimplement
end

::method restart
expose marker
signal on HALT
return marker

::method getsize
expose fsize file
use arg file
signal on HALT
rval=self~send('SIZE '||file)
select
    when rval='HALT' then return 'HALT'
    when rval=-1 then do
        if .logging then .log~failed(.sockerror,'requesting file size')
        return .sockerror
    end
    otherwise nop
end
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'
    when rval[1]=-1 then do
        if .logging then .log~failed(.sockerror,'receiving file size info')
        return .sockerror
    end
    when rval[2]='213' then do
        parse value rval[3] with '213 ' fsize (.crlf)
        fsize=fsize~strip
        if fsize~datatype('W')=0 then fsize=0
    end
    otherwise nop
end
if fsize\=0 then return .noerror        
rval=self~send('STAT '||file)
select
    when rval='HALT' then return 'HALT'
    when rval=-1 then do
        if .logging then .log~failed(.sockerror,'requesting file status info')
        return .sockerror
    end        
    otherwise nop
end
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'
    when rval[1]=-1 then do
        if .logging then .log~failed(.sockerror,'receiving file status info')
        return .sockerror
    end
    when rval[2]='213' then do
        recd=rval[3]
        do until recd~pos(.crlf)=0
            parse var recd begin (.crlf) recd
            if begin~translate~pos(file~translate)>0 then do
                if begin~left(4)=sval||'-' then nop
                else do
                    fsize=begin~word(5)
                    if fsize~datatype('W')=0 then fsize=begin~word(4)
                    recd=''
                end
            end
        end
        if fsize~datatype('W')=0 then fsize=0
    end
    otherwise nop
end
if fsize\=0 then return .noerror
else return .falseimplement
        
::method sendport
expose lsock
signal on HALT
lsock=.socket~new
lsock~bind
lsock~listen
haddr=SockGetHostId()
parse var haddr p1 '.' p2 '.' p3 '.' p4
haddr=p1||','||p2||','||p3||','||p4
lport=lsock~sock
lport=lport~d2x~right(4,'0')
lport=lport~left(2)~x2d||','||lport~right(2)~x2d
pstring=haddr||','||lport
rval=self~send('PORT '||pstring)
select
    when rval='HALT' then return 'HALT'
    when rval=-1 then do
        if .logging then .log~failed(.sockerror,'sending data port')
        return .sockerror
    end
    otherwise nop
end
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'
    when rval[1]=-1 then do
        if .logging then .log~failed(.sockerror,'receiving data port confirmation')
        return .sockerror
    end
    when rval[2]='200' then return .noerror
    otherwise do
        if .logging then .log~failed(.serverror,'data port not accepted: '||rval[2])
        return .serverror
    end
end

::method retrieve
expose file dsock lsock passivemode
signal on HALT
rval=self~send('RETR '||file)
select
    when rval='HALT' then return 'HALT'
    when rval=-1 then do
        if .logging then .log~failed(.sockerror,'sending retrieve request')
        return .sockerror
    end
    otherwise nop
end
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'
    when rval[1]=-1 then do
        if .logging then .log~failed(.sockerror,'receiving retrieve request confirmation')
        return .sockerror
    end
    when (rval[2]='125' | rval[2]='150') then do
        if \passivemode then dsock=.socket~new(lsock~accept)
        ret=.queue~new
        ret~queue(.noerror)
        ret~queue(dsock)
        ret=ret~makearray
        return ret
    end
    otherwise do
        if .logging then .log~failed(.serverror,'retrieve request denied: '||rval[2])
        return .serverror
    end
end

::method retrievelisting
expose dsock lsock passivemode
signal on HALT
rval=self~send('LIST')
select
    when rval='HALT' then return 'HALT'
    when rval=-1 then do
        if .logging then .log~failed(.sockerror,'sending retrieve request')
        return .sockerror
    end
    otherwise nop
end
rval=self~receive(.blocksize)
select
    when rval='HALT' then return 'HALT'
    when rval[1]=-1 then do
        if .logging then .log~failed(.sockerror,'receiving retrieve request confirmation')
        return .sockerror
    end
    when (rval[2]='125' | rval[2]='150') then do
        if \passivemode then dsock=.socket~new(lsock~accept)
        ret=.queue~new
        ret~queue(.noerror)
        ret~queue(dsock)
        ret=ret~makearray
        return ret
    end
    otherwise do
        if .logging then .log~failed(.serverror,'retrieve request denied: '||rval[2])
        return .serverror
    end
end

::method send
expose csock
signal on HALT
use arg sendstring
if sendstring='' then return .othererror
call SysSleep .commanddelay
check=csock~send(sendstring||.crlf)
return check

::method receive
expose csock
signal on HALT
call SysSleep .commanddelay
check=csock~receive(.blocksize)
ret=.queue~new
if check='HALT' then return 'HALT'
if check[2]=-1 then do
    ret~queue(check[2])
    ret=ret~makearray
    return ret
end
sval=check[1]~left(3)
ret~queue(check[2])
ret~queue(sval)
recd=check[1]
if check[1]~left(4)=sval||'-' then do until done=1
    bend=sval||' '
    parse var recd (bend) stuff
    if stuff\='' & stuff~right(2)=.crlf then leave        
    scrap=check[1]
    call SysSleep .commanddelay
    check=csock~receive(.blocksize)
    if check='HALT' then return HALT
    if check[2]=-1 then return .sockerror
    recd=recd||check[1]
    scrap=scrap||check[1]
    do until scrap~pos(.crlf)=0
        parse var scrap begin (.crlf) scrap
        if begin~left(4)=sval||' ' then pdone=1
        else pdone=0
    end
    if scrap='' & pdone=1 then done=1
end
ret~queue(recd)
ret=ret~makearray
return ret

HALT:
return 'HALT'
/*                                                                      */
/************************************************************************/

/* Log object ***********************************************************/
/*                                                                      */
::class logfile

::method init
expose lf filename
use arg filename
if symbol('filename')\='VAR' then filename='urlget.log'
lf=.stream~new(filename)
return

::method transfer
use arg size,time,restart
wstring='['||date()||' - '||time()||'] - Successful transfer for:'||.crlf
wstring=wstring||.currurl||.crlf
wstring=wstring||'Received '||codel(size)||' bytes in '||codel(time~format(,2))||' seconds'
wstring=wstring||' ('||codel(size%time)||' bytes/second).'||.crlf
if symbol('restart')='VAR' then do
    wstring=wstring||'Total size is '||codel(size+restart)||' bytes, resumed '
    wstring=wstring||'from byte '||codel(restart)||'.'||.crlf
end
wstring=wstring||'-'~copies(75)||.crlf
self~write(wstring)
return

::method failed
use arg reason,detail
wstring='['||date()||' - '||time()||'] - Transfer failed for:'||.crlf
wstring=wstring||.currurl||.crlf
wstring=wstring||'Failure cause: '
select
    when reason=.sockerror then wstring=wstring||'socket error'
    when reason=.serverror then wstring=wstring||'server error'
    when reason=.argerror then wstring=wstring||'argument error'
    when reason=.userabort then wstring=wstring||'transfer aborted'
    when reason=.option then wstring=wstring||'option prevents transfer'
    otherwise wstring=wstring||'unknown error'
end
wstring=wstring||' ('||detail||').'||.crlf
wstring=wstring||'-'~copies(75)||.crlf
self~write(wstring)
return

::method write
expose lf
use arg wstring
reply
written=.false
do until written
    if lf~open('write')\='READY:' then iterate
    else do
        lf~charout(wstring)
        lf~close
        written=.true
    end
end
return
/*                                                                      */
/************************************************************************/

/* Screen status object *************************************************/
/*                                                                      */
::class scrstatus

::method init
expose row srow col
return

::method template
expose row srow col
parse value SysCurPos() with row col
srow=row+2
call SysCurPos row,0
.con~~charout('Bytes stored: ')~flush
call SysCurPos row,32
.con~~charout('Bytes/second: ')~~charout(.crlf||.crlf)~flush
call SysCurPos srow,0
.con~~charout('Total size: ')~flush
call SysCurPos srow,36
.con~~charout('Progress: ')~flush
return

::method sizeunknown
expose row srow col
call SysCurPos srow,12
.con~~charout('UNKNOWN')~flush
call SysCurPos srow,46
.con~~charout('UNKNOWN')~flush
return

::method size
expose row srow col
use arg size
call SysCurPos srow,12
.con~~charout(codel(size)||' bytes')~flush
call SysCurPos srow,49
.con~~charout('%')~flush
return

::method begin
expose srow
reply
lastt=0.01
currt=0.01
tdiff=0.01
lastb=-1
currb=0
ctotal=0
pval=0
lastp=-1
stdone=.false
do until stdone
    do while .sq~items>0
        ctotal=.sq~pull
        if ctotal=.xfs then do
            stdone=.true
            ctotal=lntotal
        end
        else lntotal=ctotal           
    end
    if time('e')<0.1 then iterate
    if ctotal>lastb then self~stored(ctotal+.restart)
    currt=time('e')
    if currt=0 then currt=0.01
    currb=ctotal-lastb
    tdiff=currt-lastt
    if tdiff=0 then tdiff=0.01
    crate=currb%(tdiff)
    self~rate(crate)
    lastt=currt
    lastb=ctotal
    if .size>0 then do
        pval=(ctotal/.size*100)~format(,0)
        if pval>lastp then self~percent(pval)
        lastp=pval
    end
    call SysSleep (.stinterval/100)
end
call SysCurPos srow,0
.tq~queue(.stfs)
return
    
::method stored
expose row srow col
use arg bstored
call SysCurPos row,14
.con~~charout(codel(bstored)~left(12))~flush
return

::method rate
expose row srow col
use arg rval
call SysCurPos row,46
.con~~charout(codel(rval)~left(12))~flush
return

::method percent
expose row srow col
use arg pval
call SysCurPos srow,46
.con~~charout(pval~right(3))~flush
return
/*                                                                      */
/************************************************************************/

/* Comma deliminator routine ********************************************/
/*                                                                      */
::routine codel
use arg RNum
if RNum~length<3 then return RNum
if RNum~pos('.')>0 then do
    parse var RNum RNum '.' Fract
    Fract='.'||Fract
end
else Fract=''
RNum=RNum~reverse
FNum=''
do while RNum~length>3
	parse var RNum TriDig +3 RNum
	FNum=FNum||TriDig||','
end
FNum=FNum||RNum
return FNum~reverse||Fract
/*                                                                      */
/************************************************************************/

/* Display usage information ********************************************/
/*                                                                      */
::routine usage
call qasay ''
call qasay 'URL file fetcher v'||.rxiversion
call qasay ''
call qasay 'Usage:'
call qasay ''
call qasay 'urlget.cmd [options] <URL[ ; local name] | @filename> [options]'
call qasay ''
call qasay 'URL - URL of file to get'
call qasay ''
call qasay 'local name - local name to store file as'
call qasay ''
call qasay "@filename - text file with multiple URL's, one on a line"
call qasay ''
call qasay 'Options:'
call qasay ''
call qasay '/q - operate in quiet mode'
call qasay '/qq - operate in super quiet mode (no output at all)'
call qasay '/r - attempt FTP resume if file exists and is smaller than server copy'
call qasay '/f - attempt FTP resume, and abort transfer if not supported'
call qasay "/n - don't overwrite local files (no comparison with server copy)"
call qasay '/c - clobber local files even if same size as server copy (default is to abort)'
call qasay '/p - attempt transfer even if passive mode denied while behind firewall'
call qasay '/w - act as if behind firewall (use passive mode)'
call qasay '/l - enable logging, regardless of configuration setting'
if \win95 then call qasay '/d# - delay time for FTP commands in seconds (0.0 - 5.0); default=0.1'
else call qasay '/d# - delay time for FTP commands in seconds (0 - 5); default=1' 
call qasay '/b# - transfer block size (512-65535); default=10240'
if \win95 then call qasay '/t# - status timing interval in 1/100th seconds (1-100); default=50'
else call qasay '/t# - status timing interval in seconds (1-5); default=1' 
call qasay '/m# - maximum retries on error (0-9999999999); default=1000'
call qasay ''
call qasay 'e.g. urlget http://www.somewhere.com/index.html'
return
/*                                                                      */
/************************************************************************/

/* Enhanced stream object ***********************************************/
/*                                                                      */
::class estream subclass stream

::method charout
use arg string,start
if .superquiet then return 0
else do
    if symbol('START')='VAR' then return self~charout:super(string,start)
    else return self~charout:super(string)
end

::method lineout
use arg string,line
if .superquiet then return 0
else do
    if symbol('LINE')='VAR' then return self~lineout:super(string,line)
    else return self~lineout:super(string)
end
/*                                                                      */
/************************************************************************/

/* Quiet aware say ******************************************************/
/*                                                                      */
::routine qasay
use arg string
if .superquiet then return
else say string
/*                                                                      */
/************************************************************************/
