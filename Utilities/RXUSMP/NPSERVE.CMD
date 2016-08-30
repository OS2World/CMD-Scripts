/* rexx */

/* named-pipe server */

pipename = '\pipe\mypipe'
openmode = 'WIN'
pipemode = 'WTR'
instance_count = 1
outbuf = 4096
inbuf = 4096
timeout = -1

dosrc = rxcreatenpipe('hpipe',pipename,openmode,pipemode,instance_count,
                     ,outbuf,inbuf,timeout)
if dosrc <> 0 then
  do
  say 'RxCreateNPipe failed with rc =' dosrc
  exit
  end

say;say 'Waiting for data to read ...';say

dosrc = rxconnectnpipe(hpipe)
if dosrc <> 0 then
  do
  say 'RxConnectNPipe failed with rc =' dosrc
  exit
  end

readbufsize = 100
dosrc = rxread('data',hpipe,readbufsize)
do while word(dosrc,1) = 0 & word(dosrc,2) > 0
  say 'Data read >'data'<'
  dosrc = rxread('data',hpipe,readbufsize)
end

call rxcloseh hpipe

exit
