/* Remote file size checker by cygnus, 2:463/62.32 */

'@nolist /r check >nul 2>nul'

rc = RxFuncAdd("FtpLoadFuncs","rxFtp","FtpLoadFuncs")
rc = FtpLoadFuncs(quiet)
rc = RxFuncAdd("SysLoadFuncs","rexxutil","SysLoadFuncs")
rc = SysLoadFuncs()

signal on halt name logout

parse arg host user file pass

say 'Remote file size checker by cygnus, v1.0.8'

if file \= '' then
do
    if pass = '' then do
        call charout , 'Enter password for user '||'1B'x'[32;1;40m'||user||'1B'x'[0m: '
        call CharOut ,'1B'x'[8m'
        parse pull pass
        call CharOut ,'1B'x'[0m'
    end
    '@mode  80 5 2>nul'
    call SysCls
    call FtpSetUser host, user, pass
    '@icontalk Contacting' host 'as' user '2>nul'

    call SysCurState 'OFF'

    size	=	0
    size_old	=	0
    size_start	=	0
    flag	=	0
    zero	=	0
    fpath	=	''

    do forever
        rc=FtpDir(file, list.)
        If rc=-1 | list.0 = 0 then do			/* Errors */
            select
                when FtpErrNo = 'FTPHOST'
                then call CharOut ,'1B'x'[31;1;40m'||'Unknown host, wait'||'1B'x'[0m'||': '
                when FtpErrNo = 'FTPCONNECT'
                then call CharOut ,'1B'x'[31;1;40m'||'Unable to connect, wait'||'1B'x'[0m'||': '
                when FtpErrNo = 'FTPLOGIN'
                then call CharOut ,'1B'x'[31;1;40m'||'Unable to login, wait'||'1B'x'[0m'||': '
                when list.0 = 0
                then call CharOut ,'1B'x'[31;1;40m'||'File(s) ['file'] not found, wait'||'1B'x'[0m'||': '
                otherwise
                call CharOut ,'1B'x'[31;1;40m'||'Unknown error!, wait'||'1B'x'[0m'||': '
            end
            '@icontalk Error!'
        end
        else								/* Main submodule */
        do
            parse var list.1 with skip skip skip size skip skip skip fname

            rc=lastpos('/', fname)
            if rc \= 0 then
            do
                fpath=substr(fname,1,rc)
                plen = length(fpath)
                if plen > 12 then fpath=substr(fpath,1,5)||'~'||substr(fpath,plen-7)
            end
            sfname=substr(fname,rc+1)
            flen = length(sfname)
            if flen > 14 then sfname=substr(sfname,1,7)||'~'||substr(sfname,flen-7)

            if flag = 0 then size_start = size
            if size-size_old \= 0 then
            do
                call charout ,'+' sfname 'size=' || '1B'x'[32;1;40m' || format(size/1000,,3) || '1B'x'[0m' || ' Kb, added ' || '1B'x'[36;1;40m' || format((size-size_old)/1000,,3) || '1B'x'[0m' || ' Kb'
                '@icontalk +' fpath||sfname ':' size/1000 'Kb, +'format((size-size_old)/1000,,3) 'bytes'
                zero = 0
            end
            else
            do
                zero = zero + 1
                call charout ,'-' sfname 'size=' || '1B'x'[32;40m' || format(size_old/1000,,3) || '1B'x'[0m' || ' Kb, added ' || '1B'x'[36;40m' || '    0'|| '1B'x'[0m' || ' Kb, '||'1B'x'[30;47m'|| zero ||'1B'x'[0m'
                '@icontalk -' fpath||sfname ':' size/1000 'Kb,' zero'x0'
                if zero > 13 then
                do
                    call beep 400, 100
                    call beep 100, 100
                    call beep 400, 100
                end
            end
            parse value SysCurPos() with row col
            call SysCurPos row, 60
            call Charout , 'wait: '
            size_old = size
            flag = 1
        end

/* Change turns number&SysSleep value to change checking delay */

        do 10
            call SysSleep(2)
            call CharOut ,'#'
        end
        call CharOut ,'0D'x'0A'x
    end
end
else
    say 'Usage: check <host> <userid> <filename> [password]'
exit

logout:

/* Control Break */

    say '0d0a'x || 'Logging off'
    say 'Added' size-size_start 'bytes'
    call FtpLogoff
    say 'Good bye'
    '@pause >nul'
    '@exit'
