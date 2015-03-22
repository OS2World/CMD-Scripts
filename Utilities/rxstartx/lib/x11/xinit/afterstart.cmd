/****** WARNING! *********
 * Below some programs are started minimized, some are started detached.
 * In general, those that spawn other shells are minimized, others may be
 * detached. You might be tempted to run the xterm's as well as detached.
 * This works, but leaves you with an independent xterm/cmd pair, when the 
 * server shuts down, which you can only see in watchcat, not the process list.
 * If you start and stop x11 multiple times, this will let you run out of
 * PTYs, and will lead to a large number of background sessions.
 */
env = 'OS2ENVIRONMENT'
x11root = VALUE('X11ROOT',,env)

xbitmapdir    = x11root'\XFree86\include\X11\bitmaps'
manpath       = VALUE('MANPATH',,env)
/* 'xsetroot -bitmap 'xbitmapdir'\xos2'
'start /min /c "Login Xterm" xterm -sb -geometry 80x25+0+0 -name login'
'@detach xclock.exe' */