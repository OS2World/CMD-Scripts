/* Fetch documents via HTTP */
call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
call SysLoadFuncs
call RxFuncAdd 'SockLoadFuncs','RxSock','SockLoadFuncs'
call SockLoadFuncs 'q'

parse arg parm
if parm~strip~left(1)='@' then do
    parse var parm '@' urllist ' ' .
    ulist=.stream~new(urllist)
    if ulist~query('exists')='' then do
        say ''
        say 'URL list file not found!'
        exit
    end
    else host='fromfile'
end
else if parm~translate~left(7)='HTTP://' then host='fromparm'
else do
    call usage
    exit
end
urls=.queue~new

if host='fromfile' then do while ulist~lines>0
    urls~queue(ulist~linein)
end
else urls~queue(parm)
urls=urls~makearray
    
currdrive=directory()~left(2)
fatcheck=SysFileSystemType(currdrive)

crlf='0d0a'x
headend=crlf||crlf
blocksize=10240
call SysCurState 'off'
con=.stream~new('stdout')

do i=1 to urls~items
    newname=0
    parse value urls[i] with '://' host '/' path ';' lfile
    host=host~strip
    if host='' then
        if urls~items>1 then iterate
        else do
            call usage
            exit
        end
    parse var host host ':' port
    if port~strip='' then port=80
    rpath=path~reverse
    parse var rpath file '/' .
    file=file~reverse~strip
    if file~pos(' ')>0 then
        if urls~items>1 then iterate
        else do
            call usage
            exit
        end
    lfile=lfile~strip
    rfile=file~reverse
    parse var rpath (rfile) '/' dirpath
    dirpath=dirpath~reverse
    if file='' then 
        if urls~items>1 then iterate
        else do
            call usage
            exit
        end
    if lfile='' then lfile=file
    if fatcheck='FAT' then do
        parse var lfile basename '.' ext
        parse value lfile~reverse with ext2 '.' basename2
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
            else shext='.HTF'
        end
        done=0
        longea=0
        if newname=1 then do until done=1
            p1=right(d2x(random(65535)),4,'0')
            p2=right(d2x(random(65535)),4,'0')
            outfile=.stream~new(p1||p2||shext)
            if outfile~query('exists')='' then do
                done=1
                longea=1
                longval='FDFF'x||d2c(lfile~length)||'00'x||lfile
                lfile=filespec('name',outfile~qualify)
            end
        end
        else outfile=.stream~new(lfile)
    end
    else outfile=.stream~new(lfile)
    call SysFileDelete outfile~qualify

    servport=host||':'||port

    sendstring='GET /'||dirpath'/'file||' HTTP/1.0'||crlf||crlf

    csock=.socket~new

    say ''

    say 'Connecting to host '||host||' on port '||port||'...'
    check=csock~connect(servport)
    if check=-1 then do
        say 'Connection to host '||host||' on port '||port||' failed!'
        csock~shutdown
        csock~close
        exit
    end
    say ''

    say 'Requesting file '||file||'...'
    check=csock~send(sendstring)
    if check=-1 then do
        say 'Failed to send file request!'
        csock~shutdown
        csock~close
        exit
    end
    say ''

    say 'Receiving file '||file||'...'
    say 'Stored locally as '||lfile||'...'
    say ''
    parse value SysCurPos() with row col
    headgone=0
    total=0
    calc=0
    next=0
    freq=10240
    freq2=1024
    call time 'r'
    do until rvar<=0
        check=csock~receive(blocksize)
        call SysCurPos row,0
        con~charout('Bytes received: ')
        call SysCurPos row,32
        con~charout('Bytes/second: ')
        rvar=check[2]
        data=check[1]
        if headgone=0 then do
            if data~pos(headend)>0 then do
                headgone=1
                parse var data . (headend) data
                outfile~charout(data)
                total=total+data~length
                if total>=next | rvar<=0 then do
                    ct=time('e')
                    next=total+freq2
                    call SysCurPos row,16
                    con~charout(codel(total)~left(12))
                end
                if total>=calc | rvar<=0 then do
                    rate=total%ct
                    calc=total+freq
                    call SysCurPos row,46
                    con~charout(rate~left(12))
                end
            end
        end
        else do
            outfile~charout(data)
            total=total+data~length
            if total>=next | rvar<=0 then do
                ct=time('e')
                next=total+freq2
                call SysCurPos row,16
                con~charout(codel(total)~left(12))
                if total>50000 then freq2=rate/2
            end
            if total>=calc | rvar<=0 then do
                rate=total%ct
                calc=total+freq
                if total>50000 then freq=rate/2
                call SysCurPos row,46
                con~charout(codel(rate)~left(12))
            end
        end
    end
    outfile~close 
    if longea=1 then call SysPutEA outfile~qualify,'.LONGNAME',longval
    say ''
    say ''
    
    say 'Shutting down socket...'
    csock~shutdown('both')
    say 'Closing socket...'
    csock~close
    say 'Done!'
end

/* Socket class - work in progress **********************************/
/*                                                                  */
::class 'socket'

::method init
expose portnum
portnum=SockSocket('AF_INET','SOCK_STREAM',0)
return

::method sock
expose portnum
return portnum

::method connect
use arg servname
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

::method send
use arg sendstring
rc=SockSend(self~sock,sendstring)
return rc

::method receive
use arg length
if length='LENGTH' then length=1024
check=SockRecv(self~sock,'sockdata',length)
return .array~new~~put(sockdata,1)~~put(check,2)

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
/*                                                                  */
/********************************************************************/

/* Comma deliminator routine ****************************************/
/*                                                                  */
::routine codel
use arg RNum
if RNum~length<3 then return RNum
RNum=RNum~reverse
FNum=''
do while RNum~length>3
    parse var RNum TriDig +3 RNum
    FNum=FNum||TriDig||','
end
FNum=FNum||RNum
return FNum~reverse
/*                                                                  */
/********************************************************************/

/* Display usage information ****************************************/
/*                                                                  */
::routine usage
say ''
say 'Usage:'
say ''
say 'httpget.cmd <URL name ;[local name] | @[filename]>'
say ''
say '<URL name> - URL (only HTTP) of file to get'
say ''
say '[local name] - local name to store file as'
say ''
say "@[filename] - text file with multiple URL's, one on a line"
say ''
say 'e.g. httpget http://www.somewhere.com/index.html'
return
/*                                                                  */
/********************************************************************/
