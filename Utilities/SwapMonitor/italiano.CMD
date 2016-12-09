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
   say " SysFileSearch() errore #"rc
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
say "1b"x || "[47;34;2m" || "  dimensione massima  :";
say;
say                         "  dimensione corrente :"
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
                         " - swapper.dat - dimensione massima:" maxsize "MByte";
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
                         " - swapper.dat - dimensione massima:" maxsize "MByte";
            call lineout logfile;
            end /* do */
         end /* do */
      end  /* select */
   call SysCurPos 9, 23;
   say "1b"x || "[47;31m " || maxsize  || " MByte"
   call SysCurPos 11, 23;
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
   say;
   say "  SWAPMON.CMD monitorizza la dimensione corrente e quella massima";
   say "  raggiunte dal file di swap, mostrandone i dati sullo schermo e";
   say "  scrivendo la dimensione massima nel file swapmon.log.";
   say "  Uso:";
   say "  SWAPMON [interval] [/A|/S|/O]";
   say "  oppure:"
   say "  SWAPMON [/?|/h|/H]";
   say "  interval      rappresenta l'intervallo tra due monitorizzazioni";
   say "                successive, in secondi. Il valore di default Š 1;";
   say "  Le seguenti opzioni possono essere introdotte sia da ""-"" che da ""/"".";
   say "  Opzioni di scrittura del file di log:";
   say "  /A            (append) aggiunge una nuova riga con le dimensioni";
   say "                del file di swap ogni volta che vien superato il";
   say "                il valore massimo precedente";
   say "  /Sn           (history) scrive le dimensioni del file di swap nel";
   say "                swapmon.log ogni n minuti (default = 10)";
   say "  /O            (overwrite) la scrittura della dimensione del file di";
   say "                swap viene effettuata sovrascrivendo la precedente";
   say "                il default Š overwrite!";
   say "  Help:"
   say "  /?, /H o /h   mostra questo messaggio.";
exit;