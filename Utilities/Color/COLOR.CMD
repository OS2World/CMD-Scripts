/*>>>>>>>>>>>>>>>>>>>>>>      REXX/2   COLOR.CMD     <<<<<<<<<<<<<<<<<<<<<<<<<*//*

After switching to OS/2, I found myself missing the convenience of ansi.sys
and decided to replace some of my batch files with REXX files.  This is my
first attempt.  Wish I had something more than just the online info. Oh well!

Minimal to non-existant error checking.  No provision for an Environment 
variable to maintain color selection between "cmd" files.

You may enter only the FG color at any prompt, & it will give you that 
foreground color with the default background - black.

Doubt this is necessary, but...  ANSI should be ON. 

There is probably a better & more REXX-like way to do this but.....   

I am not responsible for damage that might result from improper use or misuse
of this file.
                                                              Paul Smith
                                                           Catfish Bend BBS
                                                             319-752-0953     */
/*------------------------[ Code Starts Next Line ]---------------------------*/
'@echo off'

CALL RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
CALL SysLoadFuncs

ARG fg bg                                     

IF  fg <> "" THEN                             /* see if 2 commandline args */
  DO                                          /* no check for improper args */
    IF bg ='' then bg=0                       /* Lazy people get black background */
    IF fg > 15 | bg > 7 then SIGNAL Menu      /* Serious help needed here */
    IF fg > 7  THEN                           /* High intensity required */
           SAY "[1;"fg-8+30";"bg+40"m"
    ELSE                                      /* Normal intensity indicated */
           SAY"[0;"fg+30";"bg+40"m"
   
    CALL SYSDROPFUNCS
    CLS; EXIT                                 /* Colors set so exit */
  END                                         /* Last chance to get it right */

MENU:

CALL SysCurState OFF

SAY"[0m"; CLS; fg=29; hfg=29; Row=12; col=4; bg=40 /* Default color & set variables */
SAY"[1;37;44m>        рд╥ ждд ╥ ж ╥ ж     жд╥ ждд ждрд╥     жд╥ жд╥ р   жд╥ рд╥ жд╥       <"                   
SAY">        ╨ ╨ ╨   ╨ ╨ ╨ ╨     ╨   ╨     ╨       ╨   ╨ ╨ ╨   ╨ ╨ ╨ ╨ ╨         <"                   
SAY">        гд╫ гд  сд╥ сд╥     сд╥ гд    ╨  ддд  ╨   ╨ ╨ ╨   ╨ ╨ гд╫ сд╥       <"                   
SAY">        ╨ ╨ ╨   ╨ ╨ ╨ ╨       ╨ ╨     ╨       ╨   ╨ ╨ ╨   ╨ ╨ ╨ ╨   ╨       <"                   
SAY">        п с сдд ╫ с ╫ с     сд╫ сдд   п       сд╫ сд╫ сдд сд╫ п с сд╫       <[36;40m"                   
SAY
SAY
SAY"                        F  O  R  E  G  R  O  U  N  D"
SAY
SAY"[33m        0   1   2   3   4   5   6   7   8   9   10  11  12  13  14  15"
SAY"[36m  B[33m"
SAY"[36m  A[33m 0  "      
SAY"[36m  C[33m 1  "       
SAY"[36m  K[33m 2  "       
SAY"[36m  G[33m 3  "       
SAY"[36m  R[33m 4  "       
SAY"[36m  O[33m 5  "       
SAY"[36m  U[33m 6  "       
SAY"[36m  N[33m 7  "       
SAY"[36m  D[33m    "

DO 8                                                   /* Paint low intensity  colors */
   DO 8
     fg=fg+1; col=col+4; SAY"["row";"col"H[0;"fg";"bg"mIBM "
   END

   DO 8                                                /* Paint high intensity colors */
     hfg=hfg+1; col=col+4; SAY"["row";"col"H[1;"hfg";"bg"mIBM "
   END

   bg =bg+1; row=row+1; col=4; fg=29; hfg=29           /* reset variables */
END

SAY"[23H[1;33;44m Enter color selection as in [FG BG] Where FG is the foreground color   "
SAY"      and BG is the background color.  There must be a space between FG BG.  [20H"
SAY"[1;33;40m"

CALL SysCurState ON                                    /* Turn cursor back on */

PULL FG BG                                             /* Get user choices */

IF fg='' & bg='' THEN                                  /* No Choices entered so */
  DO
    SIGNAL Menu                                        /* Menu needed here */
  END

IF fg > 15 | bg > 7  THEN                              /* Clown Check & Exit */
  DO
     SIGNAL Menu
  END                                                 

IF BG='' THEN BG=0                                     /* Lazy man's black Backgroung */

IF fg > 7 THEN 
  DO
    SAY "[1;"fg-8+30";"bg+40"m"                       /* Choices entered so act */
  END

ELSE 
    SAY"[0;"FG+30";"BG+40"m"

CLS                                                    /* Colorize screen & clear */
CALL SYSDROPFUNCS
