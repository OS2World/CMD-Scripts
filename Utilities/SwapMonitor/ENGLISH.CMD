/* swapmon.cmd  V. 0.35 * (c) 1998 Alessandro Cantatore * Team OS/2 Italy */
arg interval option

logo ="   Swap Monitor V 0.35 * (c) 1996-1998 Alessandro Cantatore - Team OS/2 Italy";
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs';
call SysLoadFuncs;

/* if interval is help request show help */
if interval = "-?" | interval = "?" | interval = "/H" | interval = "-H" then
   call showusage;

/* if the first char is "/" or "-" then is an option */
if left(interval, 1) = "/" | left(interval, 1) = "-" then
   option = interval;
temp = substr(option, 2, 1)
/* if in history ("S") mode look for the time suboption */
if temp = "S" then do
   logtime = substr(option, 3, 1)
   if \datatype(logtime, "N") then
      logtime = 10;
   end /* do */
option = temp

/* if interval argument is missing or invalid set it to 1 second */
if \datatype(interval, "N") then
   interval = 1

/* gets boot disk */
parse upper value value("path", , "OS2ENVIRONMENT") with "\OS2\SYSTEM" -2,
                  bdrv +2

/* gets swap file path (scans config.sys for SWAPPATH statements */
if 0 \= SysFileSearch("SWAPPATH", bdrv"\CONFIG.SYS", "statement") then do
   call beep 880, 200
   say " SysFileSearch() error #"rc
   say
   "@pause"
   exit
end /* do */

/* discards invalid statements (comments) */
do i = 1 to statement.0
   if "SWAPPATH" = left(statement.i, 8) then do
      parse var statement.i "=" swappath minfree initsize 
      leave
   end /* do */
end /* do */

if right(swappath, 1) = "\" then
   swappath = swappath || "SWAPPER.DAT"
else
   swappath = swappath || "\SWAPPER.DAT"

logfile = swapmon.log;
maxsize = 0;
bar = ""
call SysCurState "OFF"
say "1b"x || "[0;47;30m"
"@cls";
say; say;
say logo
say; say"1b"x || "[47;37;1m";
say copies("ßßßß", 20);
say "    " || "1b"x || "[40;32;1m " || date("L")" ";
parse value SysCurPos() with a b;
say;
say "1b"x || "[47;34;2m" || "    Maximum Size :"
say;
say                         "    Current Size :"
say;
say " " || "1b"x || "[0;47;30m" || "ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ";
say;
say " " || "1b"x || "[40;32;1m" || "ÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄ";
say "1b"x || "[47;37;1m" || " " || "1b"x || "[40;32;1m" || "MByte:  10        20        30        40        50        60        70        "
say "1b"x || "[0;47;30m " || "ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß" ;
say;
say "1b"x || "[47;30;1m" || copies("ßßßß", 20);
say "1b"x || "[47;34;1m" || "    Swappath : " || "1b"x || "[0;47;30m" || swappath
say "1b"x || "[47;34;1m" || "    MinFree  :" || "1b"x || "[0;47;30m" ||,
    format(minfree / 1024, 4) || " MByte            " ||,
    "1b"x || "[47;34;1m" || "    InitSize  :" || "1b"x || "[0;47;30m" ||,
    format(initsize / 1024, 4) || " MByte";
call time("E");
do forever
   call SysCurPos a-1, 65;
   say  "1b"x || "[40;32;1m " || time()" ";
   call SysFileTree swappath, "file", "F";
   parse var file.1 . . size . ;
   ffsize = format(size / (1024*1024), 3);
   bar = copies("Û", size % (1048576));
   /* overrange check */
   if length(bar) > 78 then do
      showbar = copies("Û", 78)
      showcol = "1b"x||"[40;31;1m"
      end /* do */
   else do
      showbar = bar
      showcol = "1b"x||"[40;32;1m"
      end /* do */
   select  
      when option = "A" then do  /* "append" mode */
         if ffsize > maxsize then do
            maxsize = ffsize;
            call lineout logfile, date() "-" time(),
                         " - swapper.dat - maximum size:" maxsize "MByte";
            call lineout logfile;
            end /* do */
         end /* do */
      when option = "S" then do /* history mode */
         if ffsize > maxsize then
            maxsize = ffsize;
         parse value time("E") with sec "." .;
         if (sec / 60)  >= logtime | sec < 1 then do
            call time("R");
            call lineout logfile, date() "-" time() ffsize "MB ("||,
                         maxsize"MB)" copies("Û", size % (1048576));
            call lineout logfile;
            end /* do */
         end /* do */
      otherwise do
         if ffsize > maxsize then do
            maxsize = ffsize;
            call lineout logfile, , 1;
            call lineout logfile, date() "-" time(),
                         " - swapper.dat - maximum size:" maxsize "MByte";
            call lineout logfile;
            end /* do */
         end /* do */
      end  /* select */
   call SysCurPos 9, 18;
   say "1b"x || "[47;31m " || maxsize  || " MByte"
   call SysCurPos 11, 18;
   say "1b"x || "[47;31m " || ffsize || " MByte";
   say;
   say 
   say " " || showcol || showbar || copies(" ", 78 - length(showbar));
   say;
   call SysSleep interval;
end /* do */
exit

showusage:
   say logo
   say
   say "  SWAPMON.CMD controls the current and the maximum dimension reached"
   say "  by the swap file, showing them on the screen and writing them in the"
   say "  swapmon.log file."
   say "  Usage:";
   say "  SWAPMON [interval] [/A|/S|/O]"
   say "  or:"
   say "  SWAPMON [/?|/h|/H]"
   say "  interval      means the interval during swap file size checks."
   say "                The default value is 1;"
   say "  The following options may be introduced both by ""-"" and by ""/""."
   say "  Log file options:"
   say "  /A            (append) add a new line, about the swap file size,"
   say "                each time the previous maximum value is surpassed"
   say "  /Sn           (history) write the swap file size in the log file"
   say "                every n minutes (default = 10)"
   say "  /O            (overwrite) only one line, with the maximum swap file size";
   say "                is written. This is the default if no option is specified!";
   say "  Help:"
   say "  /?, /H o /h   show this message."
exit;