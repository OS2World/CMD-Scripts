/* Fetch list of newsgroups */
call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
call SysLoadFuncs
call RxFuncAdd 'SockLoadFuncs','RxSock','SockLoadFuncs'
signal on SYNTAX
nosock=1
call SockLoadFuncs 'q'
nosock=0
signal off SYNTAX

.local['RXIVERSION']=0.16
parse version rxversion
if word(rxversion,1)\='OBJREXX' then do
    say ''
    say 'NGFETCH.CMD requires Object REXX to function.'
    say ''
    say 'You are running: '||rxversion
    say ''
    say 'README.TXT contains more information.'
    exit 4
end

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

signal on HALT

parse arg argstring

.local['BLOCKSIZE']=10240
if \win95 then .local['STINTERVAL']=50
else .local['STINTERVAL']=100
.local['MAXRETRIES']=1000
.local['WRITERAW']=.false
.local['SUPERQUIET']=.false
quietmode=.false
hostport=''
sort=.false

do i=1 to argstring~words
    badvar=.false
    currarg=argstring~word(i)~strip
    select
        when (currarg~left(1)='/' | currarg~left(1)='-') then do
            select
                when currarg~length=2 then do
                    select
                        when currarg~right(1)~translate='Q' then quietmode=.true
                        when currarg~right(1)~translate='W' then .local['WRITERAW']=.true
                        when currarg~right(1)~translate='S' then sort=.true
                        otherwise do
                            call qasay ''
                            call qasay 'Invalid switch, '||currarg||'.'
                            call usage
                            exit 5
                        end
                    end
                end
                when currarg~length=3 & currarg~right(2)~translate='QQ' then do
                    .local['SUPERQUIET']=.true
                    quietmode=.true
                end
                when currarg~left(2)~right(1)~translate='B' then do
                    .local['BLOCKSIZE']=currarg~right(currarg~length-2)
                    if .blocksize~datatype('W')=0 then badvar=.true
                    else if (.blocksize<512 | .blocksize>65535) then badvar=.true
                    if badvar then do
                        say ''
                        say 'Invalid blocksize, '||.blocksize||'.'
                        exit 5
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
                        exit 5
                    end
                end
                when currarg~left(2)~right(1)~translate='M' then do
                    .local['MAXRETRIES']=currarg~right(currarg~length-2)
                    if .maxretries~datatype('W')=0 then badvar=.true
                    else if (.maxretries<0 | .maxretries>9999999999) then badvar=.true
                    if badvar then do
                        say ''
                        say 'Invalid maximum retries, '||.maxretries||'.'
                        exit 5
                    end
                end
                otherwise do
                    call qasay ''
                    call qasay 'Invalid parameter ('||currarg||').'
                    call usage 
                    exit 5
                end
            end
        end
        otherwise do
            hostport=currarg
        end
    end
end

if .writeraw & sort then do
    call qasay ''
    call qasay 'Raw writing and sorting are mutually exclusive.'
    call usage
    exit 5
end

if hostport='' then do
    call qasay ''
    call qasay 'No host specified.'
    call usage
    exit 5
end

.local['CRLF']='0d0a'x
if \.superquiet then call SysCurState 'off'
.local['CON']=.estream~new('stdout')
listend='0d0a2e0d0a'x
lgroupm='2e0d0a'x
exitcode=0
.local['XFS']='XFER_FINISHED'
.local['STFS']='STATUS_THREAD_EXIT'

outfile=.stream~new('newsrc')

parse var hostport host ':' port
if port='' then port=119

sendstring='LIST'||.crlf

csock=.socket~new

if \.superquiet then call SysCls
.con~~charout(.crlf~copies(5))~flush
.con~~charout('Connecting to host '||host||' on port '||port||'... ')~flush
check=csock~connect(host||':'||port)
if check='HALT' then signal HALT
if check=-1 then do
    .con~~charout('Failed!'||.crlf||.crlf)~flush
    csock~shutdown('both')
    csock~close
    exit 1
end
else .con~~charout('Done'||.crlf)~flush

total=0
data=''
groups=0
glist=.queue~new
check=csock~receive(.blocksize)
if check='HALT' then signal HALT
total=total+check[1]~length
if check[1]~word(1)='400' then do
    call qasay ''
    call qasay 'News server disconnected (probably exceeded per host connection limit).'
    call qasay ''
    csock~shutdown('both')
    csock~close
    exit 2
end
else do
    if outfile~open('write replace')\='READY:' then do
        call qasay ''
        call qasay 'Unable to open '||outfile~qualify||' for writing.'
        csock~close
        exit 4
    end
    if .writeraw then outfile~charout(check[1])
end

.con~~charout('Requesting group list... ')~flush
check=csock~send(sendstring)
if check='HALT' then signal HALT
if check=-1 then do
    .con~~charout('Failed!'||.crlf||.crlf)~flush
    csock~shutdown('both')
    csock~close
    exit 1
end
else .con~~charout('Done'||.crlf)~flush

.con~~charout('Receiving group list... '||.crlf||.crlf)~flush
call time 'r'

.local['SQ']=.queue~new
.local['TQ']=.queue~new
.local['GQ']=.queue~new
scs=.scrstatus~new
.sq~queue(total)
.gq~queue(groups)
retries=0

if \quietmode then scs~template
if \quietmode then scs~begin

headgone=.false
do until check[1]~right(5)=listend
    check=csock~receive(.blocksize)
    if check='HALT' then signal HALT
    rvar=check[2]
    if rvar<0 then do
        if retries>.maxretries then do
            call qasay ''
            call qasay ''
            call qasay 'Maximum retries reached, transfer failed.'
            csock~close
            exit 2
        end
        else retries=retries+1
    end
    total=total+check[1]~length
    if \.superquiet then .sq~queue(total)
    data=data||check[1]
    if .writeraw then do
        outfile~charout(data)
        data=''
    end
    else do
        if \headgone then if data~word(1)='215' then do
            parse var data '215' . (.crlf) data
            headgone=.true
        end
        do while data~pos(.crlf)>0
            parse var data group ' ' (.crlf) data
            if sort then glist~queue(group)
            else outfile~lineout(group)
            groups=groups+1
            .gq~queue(groups)
            if data~left(3)=lgroupm then leave
        end        
    end
end 
ct=time('e')
if \quietmode then .sq~queue(total)
if \quietmode then .gq~queue(groups)
if \quietmode then .sq~queue(.xfs)
if \quietmode then do
    stcheck=''
    do until stcheck=.stfs
        stcheck=.tq~pull
    end
end
rate=total%ct
if \sort then outfile~close 
if \quietmode then do
    call qasay ''
    call qasay ''
end
call qasay codel(total)||' bytes transferred in '||codel(ct~format(,2))||' seconds ('||,
    codel(rate)||' bytes/sec.)'
call qasay ''
if \.writeraw | sort then do
    call qasay codel(groups)||' groups received.'
    call qasay ''
end

csock~shutdown('both')
csock~close

if sort then do
    .con~~charout('Sorting groups... ')~flush
    .local['QSARRAY']=glist~makearray
    call QuickSort 1, glist~items
    .con~~charout('Done'||.crlf)~flush
    .con~~charout('Writing groups... ')~flush
    do i=1 to .qsarray~items
        outfile~lineout(.qsarray[i])
    end
    outfile~close
    .con~~charout('Done'||.crlf)~flush
end    

exit 0

HALT:

if datatype(grow,'NUM')=1 then call SysCurPos grow,70
call qasay ''
call qasay ''
call qasay 'Aborting!'
if csock~objectname='a socket' then do
    csock~shutdown('both')
    csock~close
end
if \quietmode then .sq~queue(.xfs)
exit 3

SYNTAX:

if nosock=1 then do
    call qasay ''
    call qasay 'Failed to load REXX Socket functions.'
    call qasay ''
    call qasay 'Program cannot continue.'
end
exit 4

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
.con~~charout('Bytes received: ')~flush
call SysCurPos row,32
.con~~charout('Bytes/second: ')~~charout(.crlf||.crlf)~flush
call SysCurPos srow,0
if \.writeraw then do
    call SysCurPos srow,5
    .con~~charout('Groups received: ')~flush
end     
return

::method begin
expose srow
reply
lastt=0.01
currt=0.01
tdiff=0.01
lastb=-1
lastg=0
currb=0
ctotal=0
gtotal=0
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
    do while .gq~items>0
        gtotal=.gq~pull
    end
    if time('e')<0.1 then iterate
    if ctotal>lastb then self~stored(ctotal)
    currt=time('e')
    if currt=0 then currt=0.01
    currb=ctotal-lastb
    tdiff=currt-lastt
    if tdiff=0 then tdiff=0.01
    crate=currb%(tdiff)
    self~rate(crate)
    lastt=currt
    lastb=ctotal
    if gtotal>lastg then self~groups(gtotal)
    lastg=gtotal
    call SysSleep (.stinterval/100)
end
call SysCurPos srow,0
.tq~queue(.stfs)
return
    
::method stored
expose row srow col
use arg bstored
call SysCurPos row,16
.con~~charout(codel(bstored)~left(12))~flush
return

::method rate
expose row srow col
use arg rval
call SysCurPos row,46
.con~~charout(codel(rval)~left(12))~flush
return

::method groups
expose row srow col
use arg gval
call SysCurPos srow,23
.con~~charout(codel(gval)~left(8))~flush
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

/** QuickSort implementation for Object REXX ****************************/
/*                                                                      */
/*  This QuickSort implementation assumes that the array to be sorted   */
/*  is a local environment object called .qsarray, since passing the    */
/*  array around and keeping track of changes would be a pain.          */
/*                                                                      */
/*  This particular implementation uses randomization to avoid the      */
/*  nasty consequences to trying to sort an array that's already        */
/*  sorted, or has many identical values.                               */
/*                                                                      */
::routine QuickSort
use arg first,last
if first<last then do
    pivot_index=RandomizedPartition(first,last)
    call QuickSort first,pivot_index-1
    call QuickSort pivot_index+1,last
end

::routine RandomizedPartition
use arg first,last
i=random(first,last)
temp=.qsarray[first]
.qsarray[first]=.qsarray[i]
.qsarray[i]=temp
pivot_index=Partition(first,last)
return pivot_index

::routine Partition
use arg first,last
pivot=.qsarray[first]
lastS1=first
first_unknown=first+1
do while first_unknown<=last
    if .qsarray[first_unknown]<pivot then do
        lastS1=lastS1+1
        temp=.qsarray[first_unknown]
        .qsarray[first_unknown]=.qsarray[lastS1]
        .qsarray[lastS1]=temp
    end
    first_unknown=first_unknown+1
end
temp=.qsarray[first]
.qsarray[first]=.qsarray[lastS1]
.qsarray[lastS1]=temp
pivot_index=lastS1
return pivot_index
/*                                                                      */
/************************************************************************/

/* Program usage ********************************************************/
/*                                                                      */
::routine usage
call qasay ''
call qasay 'News group list fetcher v'||.rxiversion
call qasay ''
call qasay 'Usage: ngfetch.cmd <host[:port]> [options]'
call qasay ''
call qasay 'host - hostname of news server'
call qasay 'port - port of news server (default is 119)'
call qasay ''
call qasay 'Options:'
call qasay ''
call qasay '/w - write all received info without parsing'
call qasay '/q - operate in quiet mode'
call qasay '/qq - operate in super quiet mode'
call qasay '/s - sort the groups (rather slow)'
call qasay '/b# - transfer block size (512-65535); default=10240'
if \win95 then call qasay '/t# - status timing interval in 1/100th seconds (1-100); default=50'
else call qasay '/t# - status timing interval in seconds (1-5); default=1' 
call qasay '/m# - maximum retries on error (0-9999999999); default=1000'
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
