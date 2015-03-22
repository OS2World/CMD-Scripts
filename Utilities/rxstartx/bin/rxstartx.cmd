/* RxStartx 0.9 */
params="-bpp 16" /* X-SERVER Parameters */
wm="twm" /* Window manager */

fontserver=''  /* fontserver name */
fontserver.!port=7100 /* fontserver port */

/* Path to and name of user .xmodmap. Leave empty for default */
usermodmap='' 


Call Rxfuncadd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
Call SysLoadFuncs


/* Checking global variables */
env = 'OS2ENVIRONMENT'
x11root = VALUE('X11ROOT',,env)
IF x11root = '' THEN DO
	SAY "The environment variable X11ROOT is not set. XFree86/OS2 won't run without it."
	EXIT
END
xserver = translate(VALUE('XSERVER',,env),'\','/')
IF xserver = ''  THEN DO
	SAY "The environment variable XSERVER is not set. XFree86/OS2 won't run without it."
	EXIT
END
if RxFuncQuery("SockLoadFuncs") then
   do
      rc = RxFuncAdd("SockLoadFuncs","RxSock","SockLoadFuncs")
      rc = SockLoadFuncs()
   end
   
serversock  = SockSocket("AF_INET","SOCK_STREAM",0)
xserver.!family = "AF_INET"
xserver.!addr   = "INADDR_ANY"
xserver.!port=6000
if SockBind(serversock,xserver.!)<>0  then do  
 Say "It seems that another X-Server is currently running" SockPSock_Errno(ERRNO)
 call SockClose serversock
 exit  
end 
call SockClose serversock
/* FontServer processing */
if fontserver <>'' then do
 fontserver.!family = "AF_INET"
 fontserver.!addr   = "INADDR_ANY"
 fontsock  = SockSocket("AF_INET","SOCK_STREAM",0)
 if SockBind(fontsock,fontserver.!)<>0  then do 
  Say "FontServer port is busy"
  call SockClose fontsock
 end 
 else do
   say 'Starting fontserver'
  '@start /N "X FontServer"' fontserver
  call SockClose fontsock
 end
end
'@call '||x11root||'\XFree86\lib\X11\xinit\beforestart.cmd'
say 'Starting xserver ' xserver
'@start /fs /f "X Server" /N' xserver  params 
do 15 /* waiting 15 seconds for server start */
 serversock  = SockSocket("AF_INET","SOCK_STREAM",0)
 rc = SockConnect(serversock,xserver.!)
 if rc<>0 then say "Waiting for xserver" rc errno
 if rc=0 then leave
 call SockClose serversock
 call syssleep(1)
end
if rc<>0 then do
 say SockPSock_Errno(ERRNO) "Can`t start XServer"
 exit
end
call SockClose serversock
call VALUE 'DISPLAY',':0.0','OS2ENVIRONMENT'
Say 'Starting '||wm||' window manager.'
'@start "Window Manager" /min /N' wm
'@call '||x11root||'\XFree86\lib\X11\xinit\afterstart.cmd'
if usermodmap<>'' then do
 'xmodmap '||usermodmap
end
say 'Waiting for xserver shutdown'
serversock  = SockSocket("AF_INET","SOCK_STREAM",0)
do  forever
 if SockBind(serversock,xserver.!)=0  then leave
 call syssleep(5)
end 
'@call '||x11root||'\XFree86\lib\X11\xinit\afterexit.cmd'
say 'complete'
call SockClose serversock