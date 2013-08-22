/* REXX - David J. Looney 20 November 1994        */
Call RxFuncAdd 'SysLoadFuncs','REXXUTIL','SysLoadFuncs';
Call SysLoadFuncs; 

Result=SysCreateObject("WPProgram","WIN-OS/2 Full Screen","<WP_PROMPTS>",,
"HELPPANEL=8022;"||,
"DEFAULTVIEW=RUNNING;"||,
"NOPRINT=YES;"||,
"ICONPOS=8 22;"||,
"EXENAME=*;"||,
"PROGTYPE=WIN;"||,
"SET KBD_ALTHOME_BYPASS=1;"||,
"SET KBD_CTRL_BYPASS=CTRL_ESC;"||,
"SET VIDEO_SWITCH_NOTIFICATION=1;"||,
"SET VIDEO_8514A_XGA_IOTRAP=0;"||,
"SET DPMI_MEMORY_LIMIT=64;"||,
"OBJECTID=<WP_WINFS>;",,
"Replace");

If Result=1 THEN say "Object: WIN-OS/2 Full Screen created/updated !"
ELSE Say "WIN-OS/2 Full Screen creation Failed."

Result = SysCreateObject("WPProgram","WIN-OS/2 Window","<WP_PROMPTS>",,
  "HELPPANEL=8022;"||,
  "DEFAULTVIEW=RUNNING;"||,
  "NOPRINT=YES;"||,
  "ICONPOS=19 7;"||,
  "EXENAME=PROGMAN.EXE;"||,
  "PROGTYPE=PROG_31_ENHSEAMLESSCOMMON;"||,
  "SET KBD_ALTHOME_BYPASS=1;"||,
  "SET KBD_CTRL_BYPASS=CTRL_ESC;"||,
  "SET VIDEO_SWITCH_NOTIFICATION=1;"||,
  "SET VIDEO_8514A_XGA_IOTRAP=0;"||,
  "SET DPMI_MEMORY_LIMIT=64;"||,
  "SET WIN_DDE=0;"||,
  "SET WIN_CLIPBOARD=0;"||,
  "OBJECTID=<WP_WIN2WIN>;",,
  "Replace");

IF Result=1 THEN SAY "Win-OS/2 Command Prompt Object Created."
ELSE SAY "Win-OS/2 Command Prompt Creation Failed."
 
Results=SysCreateObject("WPWinConfig","WIN-OS/2 Setup","<WP_CONFIG>",,
  "HELPPANEL=4203;"||,
  "DEFAULTVIEW=SETTINGS;"||,
  "NOCOPY=YES;"||,
  "NODELETE=YES;"||,
  "NOPRINT=YES;"||,
  "ICONPOS=6 42;"||,
  "OBJECTID=<WP_WINCFG>;",,
  "Replace"); 

IF Result=1 THEN SAY "WIN-OS/2 Setup Object Installed."
ELSE SAY "Win-OS/2 Setup Object Installation Failed."

