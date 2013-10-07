/**********************************************************************/
/*                                                                    */
/* /----------------------------------------------------------------\ */
/* | RxLBox.CMD - a textmode menu program for OS/2 written in REXX  | */
/* |                         Version 1.30                           | */
/* |        (c) Copyright 1996, 1997, 1998 by Bernd Schemmer        | */
/* \----------------------------------------------------------------/ */
/*                                                                    */
/* Author                                                             */
/* ======                                                             */
/*                                                                    */
/*   Bernd Schemmer                                                   */
/*   Baeckerweg 48                                                    */
/*   60316 Frankfurt                                                  */
/*   Germany                                                          */
/*   CompuServe: 100104,613                                           */
/*   Internet: 100104.613@compuserve.com                              */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* Description:                                                       */
/* ============                                                       */
/*                                                                    */
/* RXLBOX is a powerfull textmode menu program for OS/2 written       */
/* in plain REXX. RXLBOX supports cursor keys, function keys and a    */
/* command line for navigation. Nested menus are ok. RxLBox also      */
/* supports menus for user input.                                     */
/*                                                                    */
/* No additional DLLs are necessary, even REXXUTIL is not used!       */
/*                                                                    */
/* All with simple, plain REXX and ANSI sequences. Therefore you can  */
/* use RxLBOX even if booted from diskette. This is very useful for   */
/* CID installations for example.                                     */
/*                                                                    */
/* RXLBOX is completly configurable using a menu description file     */
/* (including menus, messages, online help screens, function keys     */
/* and macros). RXLBOX also supports an external message handling     */
/* routine.                                                           */
/*                                                                    */
/* Beginning with version 1.30 RXLBOX also supports the EXTPROC       */
/* feature of the CMD.EXE.                                            */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* Usage                                                              */
/* =====                                                              */
/*                                                                    */
/* Usage from within a REXX program:                                  */
/* ---------------------------------                                  */
/*                                                                    */
/*   userInput = RxLBox( {inputChannel} {,menuSections} {,quiet} )    */
/*                                                                    */
/* Usage from the command line:                                       */
/* ----------------------------                                       */
/*                                                                    */
/*   RxLBox {/I:inputChannel} {/S:quiet}                              */
/*          {/M:menuSection1} {...} {/M:MenuSection#}                 */
/*          {/EXTPROC}                                                */
/*                                                                    */
/*   Note:                                                            */
/*     If calling RxLBox from the command line, you must enclose all  */
/*     parameter that contain blanks in '"' or "'".                   */
/*     Example:                                                       */
/*                                                                    */
/*       RxLBox /I:"My Menu File" /M:"My Main Menu"                   */
/*                                                                    */
/*     or                                                             */
/*                                                                    */
/*       RxLBox "/I:My Menu File" "/M:My Main Menu"                   */
/*                                                                    */
/*     You can use the parameter in any order. For duplicate          */
/*     parameters RxLBox uses only the last parameter.                */
/*     (except the parameter '/M', see below)                         */
/*                                                                    */
/* Where:                                                             */
/* ------                                                             */
/*                                                                    */
/*   inputChannel                                                     */
/*     This is the file or queue with the menu descriptions           */
/*     for RxLBox. The format for this parameter is:                  */
/*                                                                    */
/*       fileName                                                     */
/*                                                                    */
/*     or                                                             */
/*                                                                    */
/*       QUEUE:{queueName}                                            */
/*                                                                    */
/*     'queueName' is the name of the queue; the default is the       */
/*     current active REXX queue. This part of the parameter is       */
/*     optional.                                                      */
/*                                                                    */
/*     The name of the input channel can not contain leading          */
/*     or trailing blanks but imbedded blanks are ok.                 */
/*                                                                    */
/*     The default input channel is the menu description file         */
/*     "MAIN.MEN" either in the current directory or in the           */
/*     directory with RXLBOX.CMD (in this order).                     */
/*     This parameter is optional.                                    */
/*                                                                    */
/*   menuSections                                                     */
/*   menuSection1 ... MenuSection#                                    */
/*     This parameter is used to init the internal menu stack.        */
/*     The values are treated as menu names and pushed onto the       */
/*     internal menu stack. The name of the last menu is the menu     */
/*     that RxLBox shows after startup.                               */
/*     The first occurence of this parameter specifies the main       */
/*     menu; this menu name is available about the variable           */
/*     '!curMainMenu' in the menu description file.                   */
/*                                                                    */
/*     Examples:                                                      */
/*                                                                    */
/*       RxLBox /I:TEST.MEM                                           */
/*     or                                                             */
/*       myRC = RxLbox( 'TEST.MEM' )                                  */
/*                                                                    */
/*     In this case RxLBox does not push a menu entry onto the        */
/*     internal stack. It shows the default menu 'MAINMENU' after     */
/*     startup. Pressing ESC within this menu ends the program.       */
/*                                                                    */
/*                                                                    */
/*       RxLBox /I:TEST.MEM /M:MYMENU                                 */
/*     or                                                             */
/*       myRC = RxLBox( 'TEST.MEM', 'MYMENU' )                        */
/*                                                                    */
/*     In this case RxLBox does not push a menu entry onto the        */
/*     internal stack. It shows the menu 'MYMENU' after               */
/*     startup. Pressing ESC within this menu ends the program.       */
/*                                                                    */
/*                                                                    */
/*       RxlBox /I:TEST.MEN /M:MainMenu /M:SubMenu                    */
/*     or                                                             */
/*       myRC = RxlBox( 'TEST.MEN', 'MainMenu,SubMenu' )              */
/*                                                                    */
/*     In this case, RxLBox pushs the menu entry 'MainMenu' onto the  */
/*     menu stack and starts with the menu 'SubMenu'. If the user     */
/*     presses ESC, RxLBox jumps back into the menu 'MainMenu'.       */
/*                                                                    */
/*                                                                    */
/*       RxLbox /I:TEST.MEM /M:MainMenu /M:SubMenu1 /M:SubMenu2       */
/*     or                                                             */
/*       myRC = RxLbox( 'TEST.MEM', 'MainMenu,SubMenu1,SubMenu2'      */
/*                                                                    */
/*     In this case, RxLBox pushs then menu entries 'MainMenu' and    */
/*     'SubMenu1' onto the stack and starts with the menu 'SubMenu2'. */
/*     The first ESC then brings the user back to the menu 'SubMenu1' */
/*     and a further ESC brings him back to the menu 'MainMenu'.      */
/*                                                                    */
/*                                                                    */
/*     Menu names can not contain leading or trailing blanks but      */
/*     imbedded blanks are ok. This parameter is optional.            */
/*     The only default menu used is the menu "MAINMENU".             */
/*                                                                    */
/*                                                                    */
/*   quiet                                                            */
/*     if 1: don't show in progress messages                          */
/*     any other value: show in progress messages (default)           */
/*     This parameter is optional.                                    */
/*                                                                    */
/*                                                                    */
/*   EXTPROC                                                          */
/*     use this parameter if you use the EXTPROC feature of the       */
/*     CMD.EXE. In this case you can omnit the parameter /I:.         */
/*                                                                    */
/*     To use this feature, use the extension .CMD for your menu      */
/*     file and use the EXTPROC statement as first line of the menu   */
/*     file. The format of the EXTPROC statement MUST be:             */
/*                                                                    */
/*          EXTPROC rxlbox_name %0 /EXTPROC {further_parms}           */
/*                                                                    */
/*     rxlbox_name is the name (with or without path) of RXLBOX.CMD   */
/*                                                                    */
/*     %0 is replaced by the CMD.EXE with the fully qualified name    */
/*     of the menu file.                                              */
/*                                                                    */
/*     /EXTPROC is a necessary keyword.                               */
/*                                                                    */
/*     further_parms may be additional static parameter for           */
/*     RXLBOX.CMD (This parameter is optional).                       */
/*                                                                    */
/*     NOTE: DO ONLY ADD FURTHER PARAMETER AFTER /EXTPROC!            */
/*                                                                    */
/*     To call the menu either use                                    */
/*                                                                    */
/*          menuFile                                                  */
/*                                                                    */
/*     or                                                             */
/*                                                                    */
/*          menuFile {furtherParameter}                               */
/*                                                                    */
/*     (see the SAMPLE5.CMD for an example)                           */
/*                                                                    */
/* RxLBox returns if called from within a REXX program:               */
/* ----------------------------------------------------               */
/*                                                                    */
/*   either the choosen entry value from the input channel            */
/*   or "WARNING: warningNo"                                          */
/*   or "ERROR: errorNo : errorText"                                  */
/*   or an empty string if the user didn't select an entry            */
/*                                                                    */
/*   Defined warning codes:                                           */
/*   ----------------------                                           */
/*                                                                    */
/*     warningNo   description                                        */
/*     --------------------------------------------------             */
/*        2          menu aborted by the user with CTRL-C             */
/*                                                                    */
/*   Defined error codes:                                             */
/*   --------------------                                             */
/*                                                                    */
/*       see below for the defined error numbers and messages         */
/*                                                                    */
/* RxLBox returns if called from the command line:                    */
/* -----------------------------------------------                    */
/*                                                                    */
/*   0 - okay                                                         */
/*   else error, in this case the error message is written to STDERR  */
/*                                                                    */
/*                                                                    */
/* Samples                                                            */
/* =======                                                            */
/*                                                                    */
/*   Take a look at the included samples SAMPLE?.CMD (where ? is a    */
/*   number between 1 and 5) to see how it works.                     */
/*   Use RXLBOX.MEN as template for other menus; RXLBOX.MEN contains  */
/*   all possible entries for a menu file. All entries are explained  */
/*   in this file.                                                    */
/*   Call RXLBOX without a parameter from the command line to test    */
/*   the examples.                                                    */
/*   See also the file SETVARS.INI for a real live menu used in our   */
/*   CID installations.                                               */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* Generell notes                                                     */
/* ==============                                                     */
/*                                                                    */
/*   This program needs the OS/2 program ANSI.EXE.                    */
/*   If the display is not in the 80x25 character mode,               */
/*   RxLBox uses the OS/2 program MODE.EXE to switch to the 80x25     */
/*   character mode at program start and to restore the display mode  */
/*   at program end.                                                  */
/*   RxLBox always turns the ANSI support on. But this should not     */
/*   be a great problem because by default ANSI is always on in       */
/*   OS/2 sessions.                                                   */
/*                                                                    */
/*                                                                    */
/*   The names of all internal routines in RXLBOX.CMD begin with the  */
/*   prefix I!.__.                                                    */
/*   The only exceptions are the routines 'ShowWorkingMessage',       */
/*   'EnvValue', and 'WaitForAKey'.                                   */
/*   These are the only routines that you can call in a REXX          */
/*   statement in the menu descriptions.                              */
/*   See the file RXLBOX.MEN for the usage description of this        */
/*   routines.                                                        */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* Technical information                                              */
/* =====================                                              */
/*                                                                    */
/*   see the file RXLBOX.MEN for the format and possible entries      */
/*   for a menu file.                                                 */
/*                                                                    */
/*   The programming style of this program is not a good one.         */
/*   That's because one main goal while developing RxLBox was         */
/*   avoiding a token image greater than 64K.                         */
/*   (Because the OS/2 REXX interpreter can only save the token       */
/*    image in the EAs if it's smaller than 64K.)                     */
/*                                                                    */
/*   Do not attach an icon to this file. You also shouldn't create    */
/*   Extended Attributes other then the EAs created by the REXX       */
/*   interpreter for this file. If you do attach EAs to this file,    */
/*   the REXX interpreter can not save the token image in the EAs     */
/*   of the file (the token image needs about 63.000 bytes in the     */
/*   EAs).                                                            */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* Messages                                                           */
/* ========                                                           */
/*                                                                    */
/* The following is a list of all messages used by RxLBox.            */
/*                                                                    */
/*                                                                    */
/* Hardcoded messages                                                 */
/* ------------------                                                 */
/*                                                                    */
/* Note: You can not override these messages!                         */
/*                                                                    */
/* Message                                                            */
/*  No    Message text                      Parameter                 */
/* ------------------------------------------------------------------ */
/*  97    ERROR: 97 : errortext             "errortext" is the value  */
/*                                          of !curRC                 */
/*                                                                    */
/*  98    ERROR: 98 : RXLBOX is an                                    */
/*        OS/2 REXX program                                           */
/*                                                                    */
/*                                                                    */
/* Userdefined messages                                               */
/* --------------------                                               */
/*                                                                    */
/* Note: You can override these messages with your own messages       */
/*       using an external message handling routine (see below)       */
/*       If you use 'Global.__BaseMsgNo', you must add that value to  */
/*       the message number!                                          */
/*       (see GETMSG.CMD for an example external message handling     */
/*        routine)                                                    */
/*                                                                    */
/* Message                                                            */
/*  No    Default message text              Parameter                 */
/* ------------------------------------------------------------------ */
/*   1    (not used)                        -                         */
/*                                                                    */
/*   2    Inputfile %1 not found            %1 = name of the input    */
/*                                               file                 */
/*                                                                    */
/*   3    Inputfile %1 is empty             %1 = name of the input    */
/*                                               file                 */
/*                                                                    */
/*   4    Error opening the input file %1   %1 = name of the input    */
/*                                               file                 */
/*                                                                    */
/*   5    InputQueue %1 does not exist      %1 = name of the input    */
/*                                               queue                */
/*                                                                    */
/*   6    InputQueue %1 is empty            %1 = name of the input    */
/*                                               queue                */
/*                                                                    */
/*   7    The line %1 of the input channel  %1 = line number          */
/*        is invalid (The line reads: %2)   %2 = line contents        */
/*                                                                    */
/*   8    Menu %1 not found                 %1 = name of the menu     */
/*                                                                    */
/*   9    Menu %1 is empty                  %1 = name of the menu     */
/*                                                                    */
/*  10    Line %1: Menu %2 already defined  %1 = line number          */
/*                                          %2 = name of the menu     */
/*                                                                    */
/*  11    (not used)                                                  */
/*                                                                    */
/*  12    Line %1: Macroname to long        %1 = line number          */
/*                                                                    */
/*  13    Invalid menu command found: %1    %1 = invalid menu command */
/*                                                                    */
/*  14    Line %1: Macro %2 already defined %1 = line number          */
/*                                          %2 = name of the macro    */
/*                                                                    */
/*  15    Line %1: Keyword missing          %1 = line number          */
/*                                                                    */
/*  16    Line %1: Invalid MENUITEM/ACTION  %1 = line number          */
/*        keyword found                                               */
/*                                                                    */
/*  17    Line %1: Invalid REXX statement,  %1 = line number          */
/*        the line reads: %2                %2 = line contents        */
/*                                                                    */
/*  18    Line %1: Onlinehelp %2 already    %1 = line number          */
/*        defined                           %2 = name of the online   */
/*                                               help topic           */
/*                                                                    */
/*  19    Line %1: Onlinehelp to large      %1 = line number          */
/*        (maximum is 14 lines)                                       */
/*                                                                    */
/*  20    Line %1: Invalid menu name        %1 = line number          */
/*                                                                    */
/*  21    Parameter %1 is invalid           %1 = invalid parameter    */
/*                                                                    */
/*  99    %1 error in line %2, rc = %3 %4   %1 = condition('C')       */
/*                                          %2 = line number          */
/*                                          %3 = rc                   */
/*                                          %4 = add. information     */
/*                                                                    */
/* 100    Checking the parameter ...        -                         */
/*                                                                    */
/* 101    Reading the menu description ...  -                         */
/*                                                                    */
/* 102    Creating the menu structure ...   -                         */
/*                                                                    */
/* 103    Preparing the menu ...            -                         */
/*                                                                    */
/* 104    %1                                %1 = error message from   */
/*                                          the #UserInput command    */
/*                                                                    */
/* 105    (not used)                        -                         */
/*                                                                    */
/* 106    (not used)                        -                         */
/*                                                                    */
/* 107    (not used)                        -                         */
/*                                                                    */
/* 108    (not used)                        -                         */
/*                                                                    */
/* 109    (not used)                        -                         */
/*                                                                    */
/* 110    List of all menu descriptions in  -                         */
/*                                                                    */
/* 111    Choose a menu from the list       -                         */
/*                                                                    */
/* 112    Your choice:                      -                         */
/*                                                                    */
/* 113    Press any key to continue         -                         */
/*                                                                    */
/* 114    List of all macros defined in     -                         */
/*                                                                    */
/* 115    *** Keyword %1 not defined for    %1 = keyword name         */
/*        this menu!                                                  */
/*                                                                    */
/* 116    List of all menus called so far   -                         */
/*                                                                    */
/* 117    Choose a macro from the list      -                         */
/*                                                                    */
/* 118    Error evaluating %1               %1 = invalid REXX         */
/*                                               statement            */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* History                                                            */
/* =======                                                            */
/*                                                                    */
/*   V1.00  - 01.04.1996 /bs                                          */
/*     - initial release                                              */
/*                                                                    */
/*   V1.10  - 01.09.1996 /bs                                          */
/*                                                                    */
/*    + corrections                                                   */
/*     - corrected a bug in the handling of number commands           */
/*     - in the previous version, entering a number greater or equal  */
/*       than the number of the last menu more than one time          */
/*       destroyed the status line. Fixed.                            */
/*     - in the previous version, RxLBox didn't recognize the keys    */
/*       ESC, ALT-F4 and ALT-X if entered after other keys. Fixed.    */
/*     - added code to check the length of a macro name (max is 25)   */
/*       (error message 12 is used in case of an invalid length)      */
/*                                                                    */
/*    + new features                                                  */
/*     - added a continuation char to split an entry over multiple    */
/*       lines                                                        */
/*     - added the keyword "InputVar"                                 */
/*     - added the keyword "OnInit"                                   */
/*     - added the keyword "OnExit"                                   */
/*     - added the keyword "OnMainInit"                               */
/*     - added the keyword "OnMainExit"                               */
/*     - added a level parameter to the #GOBACK command               */
/*       (e.g. now you can say "jump 2 menu levels back")             */
/*     - now you can return a string beginning with an asterix '*'    */
/*       or a dash '#' to the calling program                         */
/*       (Preceed the string with '^' to do this; use '^^' for        */
/*        strings beginning with '^').                                */
/*     - changed the behaviour of the REXXCMD and EXECUTECMD commands */
/*       (see the description in the file RXLBOX.MEN)                 */
/*     - RxLBox now clears the screen using the color from the key    */
/*       CLS before executing an OS/2 command                         */
/*     - added the variable !curMenu to REXX variables useable in     */
/*       REXX statements                                              */
/*     - now you can return strings in mixed case                     */
/*     - made imbedded REXX statements in menu descriptions more save */
/*       Now you can't read or change REXX variables used in RxLBOX   */
/*       in the REXX statements used in menu descriptions. The only   */
/*       REXX variables you can read (and change) in REXX statements  */
/*       in menu descriptions are !curMenu, !curMenuAction,           */
/*       and !curMenuEntry.                                           */
/*       These variables are set but not used by RxLBox               */
/*       For global REXX variables in REXX statements in menu         */
/*       descriptions you can use the stem 'MenuDesc.'.               */
/*                                                                    */
/*     - added a real life example menu file (SAMPLE3*.*)             */
/*                                                                    */
/*   V1.20  - 01.12.1996 /bs                                          */
/*                                                                    */
/*    + corrections                                                   */
/*     - corrected some spelling errors in the files                  */
/*     - In the previous version RxLBox ignored the key HelpForF1 in  */
/*       the DEFAULTMENU. Fixed.                                      */
/*     - added a list of the used messages and the parameter for the  */
/*       messages in the header of this file                          */
/*                                                                    */
/*    + new features                                                  */
/*     - added the command #UserInput                                 */
/*     - added the keyword StatusLine.# for every menu entry          */
/*     - added code to check for duplicate menu entry definitions     */
/*     - added the new error message number 104                       */
/*     - added further exported REXX variables:                       */
/*         !curPageNo                                                 */
/*         !totalPageCount                                            */
/*         !curLineNo                                                 */
/*         !curEntryNo                                                */
/*         !totalEntryCount                                           */
/*     - added the (exported) routine EnvValue                        */
/*     - enhanced the real life example menu file (SAMPLE3*.*)        */
/*                                                                    */
/*   V1.21  - 01.04.1997 /bs (internal release only)                  */
/*                                                                    */
/*    + corrections                                                   */
/*     - corrected some bugs in the CTRL-C handling                   */
/*     - in the previous version the description for the exported     */
/*       REXX routine 'ShowWorkingMessage' in the file 'RXLBOX.MEM'   */
/*       was wrong.                                                   */
/*                                                                    */
/*    + new features                                                  */
/*     - added the exported variable !curMenuEntry1                   */
/*     - added the variable "MenuDesc.__NoHalt"                       */
/*       to change the behaviour for CTRL-C                           */
/*     - added the (exported) routine WaitForAKey                     */
/*     - added some add. parameter for the routine ShowWorkingMessage */
/*     - added code to ignore keywords beginning with "PM_". These    */
/*       keywords are reserved for a future PM version.               */
/*                                                                    */
/*   V1.22  - 01.05.1997 /bs                                          */
/*                                                                    */
/*    + corrections                                                   */
/*                                                                    */
/*    + new features                                                  */
/*     - added the parameter for sub menus                            */
/*     - now the three title lines are also updated after each        */
/*       command execution or function key pressed                    */
/*     - added further exported REXX variables:                       */
/*         !curMainMenu                                               */
/*     - added code to redefine the ESC key also                      */
/*     - added the parameter -2 for the #GOBACK command               */
/*     - added a new example for RxLBox (SAMPLE4.CMD)                 */
/*       to show the usage of the additional /M parameter             */
/*                                                                    */
/*   V1.30 - 01.03.1998 /bs                                           */
/*     - added support for the EXTPROC feature of the CMD.EXE         */
/*     - added a new sample (SAMPLE5.CMD) to show the usage of the    */
/*       EXTPROC feature                                              */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* Terms for using this version of RXLBOX                             */
/* ======================================                             */
/*                                                                    */
/* This version is free for private use.                              */
/* (see the file README.DOC for my distribution policy)               */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* Warranty Disclaimer                                                */
/* ===================                                                */
/*                                                                    */
/* Bernd Schemmer makes no warranty of any kind, expressed or         */
/* implied, including without limitation any warranties of            */
/* merchantability and/or fitness for a particular purpose.           */
/*                                                                    */
/* In no event will Bernd Schemmer be liable to you for any           */
/* additional damages, including any lost profits, lost savings, or   */
/* other incidental or consequential damages arising from the use of, */
/* or inability to use, this software and its accompanying documen-   */
/* tation, even if Bernd Schemmer has been advised of the possibility */
/* of such damages.                                                   */
/*                                                                    */
/* ------------------------------------------------------------------ */
/* Copyright                                                          */
/* =========                                                          */
/*                                                                    */
/* RXLBOX, the documentation for RXLBOX and all other related files   */
/* are                                                                */
/* -- Copyright 1996-1998 by Bernd Schemmer.  All rights reserved. -- */
/*                                                                    */
/*                                                                    */
/* ------------------------------------------------------------------ */
/*                                                                    */
/**********************************************************************/


/*
RxLBox:
*/
                    /* turn trace off                                 */
                    /* (-> ignore the value of the environment        */
                    /*     variable RXTRACE!                          */
  i = trace( 'OFF' )

/* --------------------------- */

                    /* These are the exported REXX variables          */
                    /* (-> exported REXX variables are REXX variables */
                    /*     that you can use in menu descriptions)     */
                    /*                                                */
  exportedREXXVariables = '!curMenu !curMenuAction !curMainMenu',
                          '!curMenuEntry !curMenuEntry1',
                          '!curRC !curCmd !curPageno !totalPageCount',
                          '!curLineNo !curEntryNo !totalEntryCount'

                    /* create a list of all global variables          */
  exposeList = 'Global. Menu. ansi. ascii. help. msgStr. inputLines.' ,
               '!ListMenu !HistoryMenu !MacroMenu !defaultMenu' ,
               '!MainMenu !thisMenu !NextMenu !BackLevel UserResponse' ,
               'MenuDesc.' exportedREXXVariables

                    /* init all global variables with ''              */
  interpret "parse value '' with " exposeList menuNames

  exposeList = exposeList 'exportedREXXVariables'

/* --------------------------- */

                    /* get the source, call type and program name     */
  parse source Global.__osV ,
               Global.__cType ,
               Global.__ProgName

                    /* check the operating system                     */
  if Global.__osV <> 'OS/2' then
  do
                    /* invalid operating system, print an error       */
                    /* message and end the program                    */
                    /*                                                */
                    /* Note: This is the only hardcode message in the */
                    /*       program!                                 */
    tLine = 'ERROR: 98 :' Global.__ProgName 'is an OS/2 REXX program'
    if Global.__cType <> 'COMMAND' then
      return tLine

                    /* the following two statements are only executed */
                    /* if RxLBox is called from the command line!     */
                    /* (-> only if global.__cType is 'COMMAND')       */
    call LineOut , tLine
    exit 255

  end /* if Global.__osV <> 'OS/2' then */

/* --------------------------- */

                    /* change & uncomment the next lines if you've    */
                    /* got an external message handling routine       */

                    /* uncomment the next lines to test the included  */
                    /* external message handling routine GETMSG       */
                    /* The external routine is called with            */
                    /*                                                */
                    /*   call GetMsg msgNo ,, mP1, mp2, ... , mp9     */
                    /*                                                */
                    /* (Note the empty parameter after the msgNo      */
                    /*  parameter!)                                   */
                    /*                                                */
                    /* msgNo is the message number; mp1 ... mp9 are   */
                    /* the parameter for the message. mp1 ... mp9     */
                    /* are optional (depending on the message).       */
                    /* Message numbers start at                       */
                    /*                                                */
                    /*   global.__BaseMsgNO+1                         */
                    /*                                                */
                    /* (see GETMSG.CMD for an example)                */
                    /*                                                */

                    /* 'Global.__GetMsgRoutine' contains the name of  */
                    /* the external message handling routine.         */
                    /* The external message handling routine can be   */
                    /*   - a REXX program in the current directory    */
                    /*   - a REXX program accessible about the PATH   */
                    /*     variable                                   */
                    /*   - a registered DLL routine                   */
                    /* or                                             */
                    /*   - a REXX routine in the macro space          */
/*
  Global.__GetMsgRoutine = 'GETMSG'
*/
                    /* 'Global.__BaseMsgNo' contains the base message */
                    /* number for the messages.                       */
                    /* So the first message number is                 */
                    /*                                                */
                    /*    Global.__BaseMsgNO + 1                      */
                    /*                                                */
                    /* You can change this variable to any value you  */
                    /* like. If Global.__BaseMsgNo is not defined,    */
                    /* RxLBox uses 0 as base message number.          */
                    /*                                                */
/*
  Global.__BaseMsgNo = '1800'
*/


/* --------------------------- */

                    /* init the global menu data                      */
  call I!.__IGData

                    /* save the name of the current queue             */
  global.__OldQ = RxQueue( 'G' )

                    /* save the name of the current environment       */
  global.__OldEnv = address()

                    /* make the CMD the current environment           */
  address 'CMD'

/* --------------------------- */

                    /* install some error handler                     */
  CALL   ON HALT NAME HALT1
  SIGNAL ON SYNTAX

  SIGNAL OFF ERROR
  SIGNAL OFF NOVALUE
  SIGNAL OFF FAILURE

/* --------------------------- */
                    /* get the parameter                              */
  if Global.__cType = 'COMMAND' then
  do
                    /* RxLBox was called from the command line        */
    parse upper arg thisArgs

                    /* check for EXTPROC statement                    */
    if pos( '/EXTPROC', thisArgs ) <> 0 then
    do
                    /* split the arguments into filename and other    */
                    /* arguments                                      */
      parse var thisArgs dataFile '/EXTPROC' thisArgs

      dataFile = strip( strip( dataFile ), 'B', '"' )
      if translate( right( dataFile, 4 ) ) <> '.CMD' then
        dataFile = dataFile || '.CMD'

      dataFileName = filespec( 'N', dataFile ) 
      if translate( right( dataFileName, 4 ) ) <> '.CMD' then
        dataFileName = dataFileName || '.CMD'

                    /* now remove the filename added by the CMD.EXE   */
      dataFileName = translate( datafilename )  
      i = pos( dataFileName, translate( thisArgs ) )
      j = length( dataFileName )
      thisArgs = strip( substr( thisArgs,1, i-1 ) || ,
                 substr( thisArgs,i+j ) )

                    /* now add the filename again                     */
                    /* using the /I: parameter                        */
      thisArgs = thisArgs '/I:' || '"'dataFile'"'
    end /* if pos( '/EXTRPOC', thisArgs ) <> 0 then */
    
    do while thisargs <> ''

      parse value strip( thisArgs, "B" ) WITH curArg ThisArgs

      parse var curArg tc +1 .
      if tc = '"' | tc = "'" then
        parse value curArg thisArgs WITH (tc) curArg (tc) ThisArgs

      parse var curArg '/' argType ':' aValue

      parse var aValue tc +1 .
      if tc = '"' | tc = "'" then
        parse value aValue thisArgs WITH (tc) aValue (tc) ThisArgs

      select

                    /* /I: - select the input channel                 */
        when argType = 'I' then
          Global.__iDevice = aValue

                    /* /M: - init the menu history list               */
        when argType = 'M' then
          menuNames = MenuNames || aValue || '00'x

                    /* /S: - turn quiet mode on or off                */
        when argType = 'S' then
          Global.__Quiet = (aValue = 1)

                    /* else invalid parameter                         */
        otherwise
          call I!.__AbortProgram 21, curArg

      end /* select */

    end /* do while thisArgs <> '' */

  end /* if callType = 'COMMAND' then */
  else
  do
                    /* RxLBox was called from another REXX program    */
    parse upper arg Global.__iDevice ,,
                    menuNameParam ,,
                    Global.__Quiet

                    /* process the parameter 'menuNameParam'          */

    do while menuNameParam <> ''
      parse var menuNameParam p1 ',' menuNameParam
      menuNames = menuNames || strip( p1 ) || '00'x
    end /* do forever */

  end /* else */

/* --------------------------- */
                    /* check the parameter                            */

                    /* show an in progress message                    */
  call ShowWorkingMessage I!.__GetMessage( 100 )

                    /* use the default main menu if the parameter for */
                    /* the main menu is missing                       */
  if menuNames = '' then
    menuNames = !MainMenu

                    /* check the parameter                            */
  Global.__iDevice = strip( Global.__iDevice )

                    /* use the default menu description file if the   */
                    /* parameter for the inputchannel is missing      */
  if Global.__iDevice = '' then
  do
                    /* search the default menu                        */
                    /* search order is:                               */
                    /*   1. current directory                         */
                    /*   2. directory with RXLBOX.CMD                 */
                    /*                                                */

    Global.__iDevice = directory() || '\' || Global.__defMenuName

    if stream( Global.__iDevice, 'c', 'QUERY EXIST' ) = '' then
      Global.__iDevice = fileSpec( 'D', Global.__ProgName ) || ,
                         fileSpec( 'P', Global.__ProgName ) || ,
                         Global.__defMenuName
  end /* if */

/* --------------------------- */
                    /* show an in progress message                    */
  call ShowWorkingMessage I!.__GetMessage( 101 )

                    /* read the lines from the input channel          */
  call I!.__ReadMenuD Global.__iDevice

                    /* show an in progress message                    */
  call ShowWorkingMessage I!.__GetMessage( 102 )

                    /* process the menu definitions                   */
  menusFound = I!.__CreateMenues()

/* --------------------------- */
                    /* install an error handler for CTRL-C            */
  CALL   ON HALT

/* --------------------------- */
                    /* show an in progress message                    */
  call ShowWorkingMessage I!.__GetMessage( 103 )

                    /* create the initial menu stack                  */
  i = 0
  do until menuNames = ''
    parse upper var MenuNames !thisMenu '00'x menuNames
    if !thisMenu = '' then
      iterate

                    /* check if the menu exist                        */
    if Menu.!thisMenu.__NoOfEntries = '' then
      call I!.__AbortProgram 8, !thisMenu

                    /* check if the menu is not empty                 */
    if Menu.!thisMenu.__NoOfEntries <= 0 then
      call I!.__AbortProgram 9, !thisMenu

                    /* add the menu to the menu stack                 */
    i = i + 1
    menuStack.i = strip( !thisMenu )

  end /* do until menuNames = '' */
  menuStack.0 = i

/* --------------------------- */
                    /* turn ANSI support on and                       */
                    /* change the ANSI status                         */
  call I!.__ChgAnsiStatus

/* --------------------------- */
                    /* save the OnMainInit & OnMainExit code          */
  !curMainMenu = menuStack.1
  !curMenu = !thisMenu

  !MainExitCode = menu.!curMainMenu.__OnMainExit
  !MainInitCode = menu.!curMainMenu.__OnMainInit

                    /* execute the OnMainInit code                    */
  call I!.__ILine '?',, !MainInitCode
  if !curRC <> '' then
  do
    global.__rc = 'ERROR: 97 :' !curRC
    signal I!.__RxLBoxEnd1
  end /* if !curRC <> '' then */


/* --------------------------- */
                    /* menu loop                                      */

                    /* menIsNew:                                      */
                    /*   1 - user has choosen another menu            */
                    /*   0 - show the same menu again                 */
  menuIsNew = 1


  do forever
                    /* default entries used if after processing the   */
                    /* OnInit command !curRc is not equal ''          */
    !NextMenu = '0001'x
    !Backlevel = 1

                    /* save the name of the current menu              */

                    /* execute the OnInit statements if any exist     */
    call I!.__ILine '?',, menu.!thisMenu.__OnInit

                    /* check the return code                          */
    if !curRC = '' then
    do
      !NextMenu = ''

                    /* show the listbox                               */
      ListBoxResult = I!.__ShowListBox( menuIsNew )
    end /* if !curRC = '' then */

                    /* execute the OnExit statements if any exist     */
    call I!.__ILine '?',, menu.!thisMenu.__OnExit

                    /* check the return code                          */
    if !curRC <> '' then
      iterate       /* error: show the same menu again                */

    menuIsNew = 1

                    /* check the result of I!.__ShowListBox           */
    select

      when !NextMenu = '0001'x then
      do
                    /* go one or more menu levels back                */

                    /* check the no. of menu levels to go back        */
        if datatype( !BackLevel ) <> 'NUM' then
          !BackLevel = 1    /* if !Backlevel is invalid go back one   */
                            /* menu                                   */

                    /* handle the special menus correct               */
        if menu.__special.!thisMenu <> 1 then
        do
                    /* user defined menu                              */

                    /* if !Backlevel = -2, go one level back if there */
                    /* are at least 2 menus on the menu stack         */
/*
          if !Backlevel = -2 & MenuStack.0 > 1 then
            !Backlevel = 1
*/

          if !backlevel = -2 then
            if MenuStack.0 > 1 then
              !Backlevel = 1
            else
            do
              menuIsNew = 0
              !backLevel = 0
            end /* else */


                    /* if !Backlevel = -1, go back to the first menu  */
          i = 1
          if !Backlevel >= 0 then
            i = MenuStack.0 - !BackLevel

          if i <= 0 then
            leave   /* exit the program                               */

        end /* if */
        else
          i = MenuStack.0

        !thisMenu = MenuStack.i
        MenuStack.0 = i

      end /* when */

      when !NextMenu = '' then
      do
                    /* it's all done - leave the program              */
        global.__rc = ListBoxResult
        leave
      end /* when */

      otherwise
      do
                    /* we should call another menu                    */
        menuIsNew = 0

                    /* check if the menu exist & is not empty         */
        select

                    /* menu exist?                                    */
          when  Menu.!NextMenu.__NoOfEntries = '' then
            call I!.__ShowErrorMessage 8, !NextMenu

                    /* menu not empty?                                */
          when  Menu.!NextMenu.__NoOfEntries <= 0 then
            call I!.__ShowErrorMessage 9, !NextMenu

          otherwise
          do
                    /* menu is okay                                   */
                    /* check, if the new menu is the same menu than   */
                    /* the current menu                               */
            if !thisMenu <> !NextMenu then
            do
              !thisMenu = !NextMenu

              if menu.__special.!thisMenu <> 1 then
              do
                    /* the new menu is a user defined menu            */
                    /* -> save the menu in the menu stack             */
                i = menuStack.0
                if menuStack.i <> !thisMenu then
                do
                  i = i +1
                  menuStack.i = !thisMenu
                  menuStack.0 = i
                end /* if */
              end /* if menu.__special.!thisMenu <> 1 then */

                    /* set the marker for a new menu                  */
              menuIsNew = 1
            end /* if */

          end /* otherwise */

        end /* select */

      end /* otherwise */

    end /* select */

  end /* do forever */


/* ------------------------------------------------------------------ */
                    /* execute OnMainExitCode                         */

I!.__RxLBoxEnd1:
  call I!.__ILine '?',, !MainExitCode

/* ------------------------------------------------------------------ */
                    /* exit point of the routine in ALL cases         */

I!.__RxLBoxEnd:
                    /* house keeping                                  */

                    /* clear the screen if necessary                  */
  if Global.__CLS <> '' then
    call I!.__Cls Global.__CLS

                    /* restore the ADDRESS environment if necessary   */
  if global.__OldEnv <> address() then
    address global.__OldEnv

                    /* restore ANSI status if necessary               */
  if Global.__AnsiStatusChanged = 1 then
    call I!.__ResetAnsiStatus

  if Global.__iDeviceIsQueue = 1 then
  do
                    /* flush the current queue                        */
    do while queued() <> 0
      parse pull
    end /* do while queued() <> 0 */

                    /* restore the queue if necessary                 */
    if global.__OldQ <> '' then
      if RxQueue( 'G' ) <> global.__OldQ then
        call RxQueue 'S', global.__OldQ

  end /* if RxQueue( 'G' ) <> global.__OldQ */
  else
    if Global.__iDevice <> '' then
    do
                    /* close the input file                           */
/* ???
      signal off notready
*/
      call stream Global.__iDevice, 'c', 'CLOSE'
    end /* if Global.__iDevice <> '' then */

  if Global.__cType <> 'COMMAND' then
    exit global.__rc

                    /* the next statements are only executed if       */
                    /* RxLBox was called from the command line        */
                    /* (-> if Global.__cType = 'COMMAND')             */
  if word( global.__rc,1 ) <> 'ERROR:' then
    exit 0

                    /* the next statements are only executed in case  */
                    /* of an error                                    */
  call LineOut 'STDERR:', ascii.__CRLF || ,
                          Global.__ProgName ,
                          ascii.__CRLF || ,
                          '  ' || global.__rc
exit 255

/* ------------------------------------------------------------------ */

/* ------------------------------------------------------------------ */
/* function: wait for a key from the standard input                   */
/*                                                                    */
/* call      call WaitForAKey {ShowPrompt}                            */
/*                                                                    */
/* where:    ShowPrompt - if 1 WaitForAKey shows the default prompt   */
/*                        message of the PAUSE command                */
/*                                                                    */
/* returns:  -                                                        */
/*                                                                    */
/* Note:     This is an exported routine!                             */
/*                                                                    */
/*           You can not use global variables in this routine         */
/*           because they are not available if called from within     */
/*           the menu descriptions!                                   */
/*                                                                    */
WaitForAKey: PROCEDURE expose (exposeList) menuDesc.__NoHalt

  SIGNAL OFF ERROR

  if arg( 1 ) = '1' then
    '@cmd /c pause'
  else
    '@cmd /c pause>NUL'

                    /* CTRL-C pressed                                 */
  if rc = 255 then
    call halt
return ''


/* ------------------------------------------------------------------ */
/* error handler                                                      */

Halt:
  if symbol( 'MENU.__CTRLCPRESSED' ) = 'VAR' then
  do
                    /* CTRL-C to abort the program is only possible   */
                    /* while RxLBox is active - not while executing   */
                    /* REXX code from the menu definition file!       */
    menu.__CtrlCPressed = 1

    if MenuDesc.__NoHalt <> '' then
      return

    global.__rc = 'WARNING: 2'
    signal I!.__RxLBoxEnd
  end /* if */

Halt1:
  return

Failure:
Error:
Syntax:
NoValue:
  call I!.__AbortProgram 99, condition('C'), sigl, rc, ', condition(D) =' condition( 'D' )

exit

/* ------------------------------------------------------------------ */
/* function: set or get an environment variable                       */
/*                                                                    */
/* call      curEnvValue = EnvValue( envVar {, newEnvValue } )        */
/*                                                                    */
/* returns:  current value of the environment variable                */
/*                                                                    */
/* Note:     This is an exported routine!                             */
/*                                                                    */
/*           You can not use global variables in this routine         */
/*           because they are not available if called from within     */
/*           the menu descriptions!                                   */
/*                                                                    */
EnvValue: PROCEDURE
  parse arg e1, e2

  if arg( 2, 'E' ) then
    return value( e1, e2, 'OS2ENVIRONMENT' )
  else
    return value( e1, , 'OS2ENVIRONMENT' )

/* ------------------------------------------------------------------ */
/* function: Show working message                                     */
/*                                                                    */
/* call:     ShowWorkingMessage message {, wait } {, noCls }          */
/*                                                                    */
/* where:    message - message to show                                */
/*           wait - if 1 wait for a key else not                      */
/*                  (def.: do not wait for a key)                     */
/*           noCls - do not clear the screen before displaying the    */
/*                   message if this parameter is set to 0            */
/*                   (def.: clear the screen)                         */
/*                                                                    */
/* returns:  -                                                        */
/*                                                                    */
/* Note:     This is an exported routine!                             */
/*                                                                    */
/*           You can not use global variables in this routine         */
/*           because they are not available if called from within     */
/*           the menu descriptions!                                   */
/*                                                                    */
ShowWorkingMessage: PROCEDURE expose (exposeList) menuDesc.__NoHalt
  if Global.__Quiet = 1 then
    return

  parse arg wrkMsg +76, qMode, qCls

  l = length( wrkMsg )

  s1 = copies( 'Ä', l+2 )

  sESC = '1B'x || '['

  if qCls <> 0 then
    call CharOut , sESC || '1;1H' || sESC || '2J'

  call CharOut, ,
      sESC || '36;40;1;m' || ,
      sESC || '10;' || (76-l) % 2 || ';HÚ'  || s1         ||  '¿' || ,
      sESC || '11;' || (76-l) % 2 || ';H³ ' || wrkMsg     || ' ³' || ,
      sESC || '12;' || (76-l) % 2 || ';HÀ'  || s1         ||  'Ù' || ,
      sESC || '0;m'

  if qMode = 1 then
    call WaitForAKey

RETURN ''

/* ------------------------------------------------------------------ */
/* function: Process the lines from the inputchannel                  */
/*                                                                    */
/* call:     I!.__CreateMenues                                        */
/*                                                                    */
/* returns:  a list of all found menus as string separated with       */
/*           null bytes ('00'x)                                       */
/*                                                                    */
/*                                                                    */
I!.__CreateMenues: PROCEDURE expose (exposeList)

  inputLineIndex = 1
  menuNames = '00'x

/* --------------------------- */
                    /* init the menu with the default values          */
  call I!.__InitDefaultMenuEntry

/* --------------------------- */
                    /* init the stem for the menu list                */

                    /* init the menu descriptions                     */
  call I!.__InitMenuEntry !ListMenu

  menu.!ListMenu.__Title1 =            I!.__GetMessage( 110 )
  menu.!ListMenu.__Title2 =            Global.__iDevice
  menu.!ListMenu.__Title3 =            ''
  menu.!ListMenu.__StatusLine =        I!.__GetMessage( 111 )
  menu.!ListMenu.__InputPrompt =       I!.__GetMessage( 112 )
  menu.!ListMenu.__ErrorPrompt =       I!.__GetMessage( 113 )
  menu.!ListMenu.__HelpForF1 =         'MENULISTONLINEHELP'
  menu.!ListMenu.__HelpForALT_F1 =     'INTERNALMENU_INPUTLINEHELP'
  menu.!ListMenu.__HelpForCTRL_F1 =    'INTERNALMENU_KEYHELP'

/* --------------------------- */
                    /* init the stem for the macro list               */

                    /* init the menu descriptions                     */
  call I!.__InitMenuEntry !MacroMenu

  menu.!MacroMenu.__Title1 =            I!.__GetMessage( 114 )
  menu.!MacroMenu.__Title2 =            Global.__iDevice
  menu.!MacroMenu.__Title3 =            ''
  menu.!MacroMenu.__StatusLine =        I!.__GetMessage( 117 )
  menu.!MacroMenu.__InputPrompt =       I!.__GetMessage( 112 )
  menu.!MacroMenu.__ErrorPrompt =       I!.__GetMessage( 113 )
  menu.!MacroMenu.__HelpForF1 =         'MACROLISTONLINEHELP'
  menu.!MacroMenu.__HelpForALT_F1 =     'INTERNALMENU_INPUTLINEHELP'
  menu.!MacroMenu.__HelpForCTRL_F1 =    'INTERNALMENU_KEYHELP'

/* --------------------------- */

  do until InputLineIndex > inputLines.0

    parse upper var inputLines.InputLineIndex nextLine
    inputLineIndex = inputLineIndex + 1


                    /* split the line into firstChar, LastChar and   */
                    /* the chars between                             */
    parse var nextline sChar1 +1 1 sChar1 +2 . '' -2 sChar2 1 (sChar1) sSection (sChar2)
    sSection = strip( sSection )

                    /* ignore comments, empty lines and invalid      */
                    /* sections                                      */

    if nextLine sSection = '' | sChar1 = ';' then
      iterate

                    /* check for the start of the next section        */
    if nextLine  = '[MACROLIST]' then
    do
                    /* section with macro definitions found           */
      inputLineIndex = I!.__ReadMacros( inputLineIndex )
      iterate
    end /* if */

                    /* check for online help sections                 */
    if sChar1 || sChar2 = '[<>]' then
    do
                    /* help section found                             */

                    /* check for duplicate definitions                */
      if help.sSection.0 <> '' then
        call I!.__AbortProgram 18, inputLineIndex-1, sSection

                    /* create the stem entry for the online help      */
      inputLineIndex = I!.__CreateOnlineHelp( inputLineIndex, sSection )

      iterate

    end /* if */

                    /* check for menu sections                        */
    if sChar1 || sChar2 = '[**]' then
    do
                    /* menu entry found                               */

                    /* check the first char of the menu name for      */
                    /* invalid characters                             */
      if pos( left( sSection,1 ), '!_' ) <> 0 then
        call I!.__AbortProgram 20, inputLineIndex-1

                    /* check for duplicate menu sections              */
      if menu.sSection.__LastLine = '' then
      do
                    /* new menu, create the menu entry                */
        menuNames = menuNames || sSection || '00'x

                    /* add the menu to the menu list                  */
        i = menu.!ListMenu.__NoOfEntries + 1
        menu.!ListMenu.i.__Entry = sSection
        menu.!ListMenu.i.__Action = '#GotoMenu() ' sSection
        menu.!ListMenu.__NoOfEntries = i
      end /* else */
      else          /* duplicate menu definition                      */
        if sSection <> !defaultMenu then
          call I!.__AbortProgram 10, inputLineIndex-1, sSection

                    /* create the stem entry for the menu             */
      inputLineIndex = I!.__CreateMenu( inputLineIndex, sSection )

    end /* if */

  end /* do until InputLineIndex > inputLines.0 */

                    /* convert the colors of the default menu to      */
                    /* ANSI ESC sequences                             */
  call I!.__ConvertColorStrings !defaultMenu

                    /* copy the default colors to the internal menus  */
  call I!.__InitMenuEntry !ListMenu, 1
  call I!.__InitMenuEntry !MacroMenu, 1

                    /* ???                                            */
  drop InputLines.
RETURN menuNames

/* ------------------------------------------------------------------ */
/* Function: Create a menu                                            */
/*                                                                    */
/* Usage:    I!.__CreateMenu inputLineIndex, curMenuName              */
/*                                                                    */
/* where:    inputLineIndex - index for the stem inputLines.          */
/*           curMenuName - name of the menu                           */
/*                                                                    */
/* Returns:  the index of the next line in the stem inputLines.       */
/*                                                                    */
I!.__CreateMenu: PROCEDURE expose (exposeList)
  parse arg inputLineIndex , curMenuName

                    /* init the menu description                      */
  call I!.__InitMenuEntry curMenuName

  MenuItemFound = 0

  do curLineNo = inputLineIndex to inputLines.0

                    /* get the next line                              */
    curLine = inputLines.curLineNo

                    /* check for section starts                       */
    parse var curLine s1 +1 '' -1 s2

                    /* ignore comments and empty lines                */
    if curLine = '' | s1 = ';' then
      iterate

    if s1 || s2 = '[]' then
    do
                    /* start of next section found                    */
      inputLineIndex = curLineNo
      leave
    end /* if left( ... */

                    /* split the line into keyword and keyvalue       */
    parse var curLine keyword '=' keyvalue

                    /* translate keyword to uppercase and split the   */
                    /* keyword also into subKeyword and itemNo        */
                    /* (subKeyword and itemNo are only used for the   */
                    /* keywords MENUITEM and ACTION)                  */
    keyword = strip( keyword )
    parse upper var keyword keyword 1 subKeyword '.' itemNo 1 pmKey +3

                    /* ignore entries for the PM version              */   
    if PMKey = 'PM_' then
      iterate

    itemNo = strip( itemNo )
    itemNoType = datatype( itemNo, 'NUM' )

                    /* empty keywords are not possible!               */
    if keyWord = '' then
      call I!.__AbortProgram 15, curLineNo

                    /* help variable to read/write the stem entry     */
    nKeyWord = '__' || keyWord

                    /* leading blanks for keyValues are not possible  */
    keyValue = strip( keyValue, 'L' )

                    /* check if the value is a REXX statement         */
    parse var KeyValue firstKeyChar +1 . '' -1 lastKeyChar
    if firstKeyChar || lastKeyChar = '()' then
      call I!.__ILine curLineNo, 'keyValue', 'keyValue = ' || keyValue

    select

      when wordPos( keyword, menu.__menuMessages ) <> 0 then
      do

        maxLen = menu.__MenuMsgLength
        if keyword = 'INPUTPROMPT' then
          maxLen = menu.__MenuPromptLength

                        /* firstKeyChar = left char of keyValue       */
        if firstKeyChar <> '{' then
          menu.curMenuName.nkeyword = strip( left( keyValue, maxLen ) )
        else
          menu.curMenuName.nKeyWord = keyvalue

      end /* when */

      when wordPos( keyword, menu.__menuHelpTexts ) <> 0 then
        parse upper var keyValue menu.curMenuName.nkeyword

      when wordPos( keyword, menu.__menuOptions ) <> 0 then
        menu.curMenuName.nkeyword = keyValue

      when subKeyWord = 'MENUITEM' then
      do
        if itemNoType <> 1 then
        do

          if itemNo <> '#' then
            call I!.__AbortProgram 16, curLineNo

          itemNo = menu.curMenuName.__NoOfEntries + 1
        end /* if datatype( ... */

        if itemNo = 0 | menu.curMenuName.itemNo.__Entry <> '' | keyValue = '' then
          call I!.__AbortProgram 16, curLineNo

        if menu.curMenuName.__NoOfEntries < itemNo then
          menu.curMenuName.__NoOfEntries = itemNo

        if firstKeyChar <> '{' then
          menu.curMenuName.itemNo.__Entry = ,
               strip( left( keyValue, menu.__MenuMsgLength ) )
        else
          menu.curMenuName.itemNo.__Entry = keyvalue

      end /* when */

      when wordPos( subKeyWord, 'ACTION STATUSLINE' ) <> 0 then
      do
        if itemNoType <> 1 then
          if itemNo = '#' then
            itemNo = menu.curMenuName.__NoOfEntries

        if menu.curMenuName.itemNo.__Entry = '' then
          call I!.__AbortProgram 16, curLineNo

        if menu.curMenuName.__NoOfEntries < itemNo then
          menu.curMenuName.__NoOfEntries = itemNo

        tsubKeyWord = '__' || subKeyWord

        if menu.curMenuName.itemNo.tsubKeyWord <> '' then
          call I!.__AbortProgram 16, curLineNo

        menu.curMenuName.itemNo.tsubKeyWord = keyValue
        
      end /* when */

      otherwise
        call I!.__AbortProgram 7, curLineNo, inputLines.curLineNo

    end /* select */

  end /* do curLineNo = inputLineIndex to inputLines.0 */

                    /* convert the colors to ANSI ESC sequences       */
                    /* (only for non-default menus)                   */
  if curMenuName <> !defaultMenu then
    call I!.__ConvertColorStrings curMenuName

RETURN inputLineIndex

/* ------------------------------------------------------------------ */
/* Function: Process an online help section                           */
/*                                                                    */
/* Usage:    I!.__CreateOnlineHelp inputLineIndex, curTopic           */
/*                                                                    */
/* where:    inputLineIndex - index for the stem inputLines.          */
/*           curTopic - name of the menu where the online help is for */
/*                                                                    */
/* Returns:  the index of the next line in the stem inputLines.       */
/*                                                                    */
I!.__CreateOnlineHelp: PROCEDURE expose (exposeList)
  parse arg inputLineIndex , curTopic

                    /* init the description                           */
  help.CurTopic.0 = 0

  curHelpLineNo = 1

  do curLineNo = inputLineIndex to inputLines.0

                    /* get the next line                              */
    curLine =  inputLines.curLineNo

                    /* check for section starts                       */
    parse var curLine s1 +1 '' -1 s2

    if s1 || s2 = '[]' then
    do
                    /* start of next section found                    */
      inputLineIndex = curLineNo
      leave
    end /* if left( ... */

    if curHelpLineNo > menu.__EntriesPerPage then
      call I!.__AbortProgram 19, curLineNo

    help.CurTopic.curHelpLineNo = left( curLine , menu.__MenuMsgLength )
    curHelpLineNo = curHelpLineNo + 1

  end /* do curLineNo = inputLineIndex to inputLines.0 */

                    /* save the no. of lines for this topic           */
  help.CurTopic.0  = curHelpLineNo

RETURN inputLineIndex

/* ------------------------------------------------------------------ */
/* Function: Process a macro section                                  */
/*                                                                    */
/* Usage:    I!.__ReadMacros inputLineIndex                           */
/*                                                                    */
/* where:    inputLineIndex - index for the stem inputLines.          */
/*                                                                    */
/* Returns:  the index of the next line in the stem inputLines.       */
/*                                                                    */
I!.__ReadMacros: PROCEDURE expose (exposeList)
  parse arg inputLineIndex .

  do curLineNo = inputLineIndex to inputLines.0

                    /* get the next line                              */
    curLine = inputLines.curLineNo

    parse var curLine s1 +1 '' -1 s2

                    /* ignore empty lines and comment lines           */
    if curLine = '' | s1 = ';' then
      iterate

                    /* check for section starts                       */

    if s1 || s2 = '[]' then
    do
                    /* start of next section found                    */
      inputLineIndex = curLineNo
      leave
    end /* if left( ... */

                    /* split the line into keyword and keyvalue       */
    parse var curLine keyword '=' keyvalue

                    /* translate the keyword to uppercase and delete  */
                    /* leading and trailing blanks                    */
    parse upper var keyword keyword
    keyword = strip( keyword )

                    /* check for invalid lines in the macro section   */
    if keyWord = '' then
      call I!.__AbortProgram 15, curLineNo

    if length( keyWord ) > 25 then
      call I!.__AbortProgram 12, curLineNo

                    /* check for duplicate macro definitions          */
    if Menu.__Macros.0.keyWord <> '' then
      call I!.__AbortProgram 14, curLineNo, keyword

                    /* save the macro in the macro stem               */
    i = Menu.__Macros.0 + 1
    Menu.__Macros.i = keyWord
    Menu.__Macros.0 = i

                    /* check if the value is a REXX statement         */
    parse var KeyValue firstKeyChar +1 . '' -1 lastKeyChar
    if firstKeyChar || lastKeyChar = '()' then
      call I!.__ILine curLineNo, 'keyValue', 'keyValue = ' keyValue

                    /* add the macro to the macro menu                */
    tline = keyWord '-' keyValue

    if length( tLine ) > menu.__MenuLineLength-8 then
      tLine = left( tLine, menu.__MenuLineLength-8 ) '...'

    i = menu.!MacroMenu.__NoOfEntries + 1
    menu.!MacroMenu.i.__Entry = tLine

    if firstKeyChar <> '#' then
      menu.!MacroMenu.i.__Action = '#ExecuteCmd() ' keyValue
    else
      menu.!MacroMenu.i.__Action = keyValue

    menu.!MacroMenu.__NoOfEntries = i

    Menu.__Macros.0.keyWord = keyValue

  end /* do */

RETURN inputLineIndex

/* ------------------------------------------------------------------ */
/* Function: Init a stem for a menu                                   */
/*                                                                    */
/* Usage:    I!.__InitMenuEntry menuName                              */
/*                                                                    */
/* where:    menuName - name of the menu                              */
/*                                                                    */
/* Returns:  -                                                        */
/*                                                                    */
I!.__InitMenuEntry: PROCEDURE expose (exposeList) menuStack.
  parse arg newMenu, colorsOnly

                    /* init the menu descriptions                     */
  if colorsOnly = '' then
    thisEntries = menu.__menuOptions 'FKEYA1 FKEYC1 LASTLINE LASTPAGE'
  else
    thisEntries = menu.__MenuColors

  do i = 1 to words( thisEntries )
    cK = '__' || word( thisEntries, i )
    menu.NewMenu.ck = menu.!defaultMenu.ck
  end /* do i = 1 words( thisEntries ) */

  if colorsOnly = '' then
    menu.NewMenu.__NoOfEntries = 0

RETURN

/* ------------------------------------------------------------------ */
/* Function: Init the stem with the default menu values               */
/*                                                                    */
/* Usage:    I!.__InitDefaultMenuEntry                                */
/*                                                                    */
/* where:    -                                                        */
/*                                                                    */
/* Returns:  -                                                        */
/*                                                                    */
/* Notes:    This menu contains the default values for all other      */
/*           menus.                                                   */
/*           You can redefine this menu any time in the menu          */
/*           descriptions.                                            */
/*                                                                    */
I!.__InitDefaultMenuEntry: PROCEDURE expose (exposeList)

                    /* init the menu descriptions                     */
                    /* Note: By default all entries are '' at the     */
                    /*       time this routine is called!             */

  menu.!defaultMenu.__NoOfEntries =       0
  menu.!defaultMenu.__AcceptAllInput =    0

/*
  menu.!defaultMenu.__InputVar       =   ''
*/

                    /* default key definitions                        */
  menu.!defaultMenu.__Fkey1  =            '#SHOWHELP()'
  menu.!defaultMenu.__FKeyA1 =            '#SHOWLINEHELP()'
  menu.!defaultMenu.__FkeyC1 =            '#SHOWKEYHELP()'

  menu.!defaultMenu.__ESC    =            '#GOBACK()'

/*
  menu.!defaultMenu.__Fkey2  =            ''
*/

  menu.!defaultMenu.__Fkey3  =            '#REPEAT()'

/*
  menu.!defaultMenu.__Fkey4  =            ''
  menu.!defaultMenu.__FKey5  =            ''
  menu.!defaultMenu.__Fkey6  =            ''
  menu.!defaultMenu.__Fkey7  =            ''
*/

  menu.!defaultMenu.__Fkey8  =            '#SHOWMACROLIST()'
  menu.!defaultMenu.__Fkey9  =            '#REFRESH()'
  menu.!defaultMenu.__Fkey10 =            '#QUIT()'
  menu.!defaultMenu.__Fkey11 =            '#SHOWMENULIST()'
  menu.!defaultMenu.__Fkey12 =            '#SHOWHISTORY()'

  menu.!defaultMenu.__Title1 =            I!.__GetMessage( 115, 'title1' )
  menu.!defaultMenu.__Title2 =            I!.__GetMessage( 115, 'title2' )
  menu.!defaultMenu.__Title3 =            I!.__GetMessage( 115, 'title3' )
  menu.!defaultMenu.__StatusLine =        I!.__GetMessage( 115, 'statusline')

/*
  menu.!defaultMenu.__HelpStatusLine =    ''
*/

  menu.!defaultMenu.__InputPrompt =       I!.__GetMessage( 112 )
  menu.!defaultMenu.__HelpPrompt =        I!.__GetMessage( 113 )
  menu.!defaultMenu.__ErrorPrompt =       I!.__GetMessage( 113 )

  menu.!defaultMenu.__FrameColor =        'HIGHLIGHT GREEN ON BLACK'
  menu.!defaultMenu.__ItemColor =         'HIGHLIGHT CYAN ON BLACK'
  menu.!defaultMenu.__SelectedItemColor = 'HIGHLIGHT YELLOW ON MAGNENTA'
  menu.!defaultMenu.__Title1Color =       'HIGHLIGHT CYAN ON BLACK'
  menu.!defaultMenu.__Title2Color =       'HIGHLIGHT CYAN ON BLACK'
  menu.!defaultMenu.__Title3Color =       'BLUE ON WHITE'
  menu.!defaultMenu.__StatuslineColor =   'HIGHLIGHT YELLOW ON BLACK'
  menu.!defaultMenu.__ErrorTextColor =    'HIGHLIGHT YELLOW ON RED'
  menu.!defaultMenu.__InputLineColor =    'HIGHLIGHT YELLOW ON MAGNENTA'
  menu.!defaultMenu.__CLS =               'WHITE ON BLACK'

/*
  menu.!defaultMenu.__HelpForF1 =         ''
  menu.!defaultMenu.__HelpForALT_F1 =     ''
  menu.!defaultMenu.__HelpForCTRL_F1 =    ''
*/

  menu.!defaultMenu.__LastLine =          0
  menu.!defaultMenu.__LastPage =          1
RETURN

/* ------------------------------------------------------------------ */
/* Function: Convert the color strings of a menu to ANSI ESC          */
/*           sequences                                                */
/*                                                                    */
/* Usage:    I!.__ConvertColorStrings menuName                        */
/*                                                                    */
/* where:    menuName - name of the menu                              */
/*                                                                    */
/* Returns:  -                                                        */
/*                                                                    */
/*                                                                    */
I!.__ConvertColorStrings: PROCEDURE expose (exposeList)
  parse arg MenuN

  do i = 1 to words( menu.__menuColors )
    menuV = '__' || word( menu.__menuColors,i )

    menu.MenuN.MenuV = I!.__GetColorString( menu.MenuN.MenuV )
  end /* do i = 1 to words( menu.__menuColors ) */

RETURN

/* ------------------------------------------------------------------ */
/* Function: Create the history menu                                  */
/*                                                                    */
/* Usage:    I!.__CreateHistoryMenu                                   */
/*                                                                    */
/* where:    -                                                        */
/*                                                                    */
/* Returns:  !HistoryMenu                                             */
/*                                                                    */
I!.__CreateHistoryMenu: PROCEDURE expose (exposeList) menuStack.

                    /* init the menu descriptions                     */
  call I!.__InitMenuEntry !HistoryMenu

  menu.!HistoryMenu.__Title1 =            I!.__GetMessage( 116 )
  menu.!HistoryMenu.__Title2 =            '(' Global.__iDevice ')'

/*
  menu.!HistoryMenu.__Title3 =            ''
*/

  menu.!HistoryMenu.__StatusLine =        I!.__GetMessage( 111 )
  menu.!HistoryMenu.__InputPrompt =       I!.__GetMessage( 112 )
  menu.!HistoryMenu.__ErrorPrompt =       I!.__GetMessage( 113 )
  menu.!HistoryMenu.__HelpForF1 =         'HISTORYLISTONLINEHELP'
  menu.!HistoryMenu.__HelpForALT_F1 =     'INTERNALMENU_INPUTLINEHELP'
  menu.!HistoryMenu.__HelpForCTRL_F1 =    'INTERNALMENU_KEYHELP'

                    /* create an entry for each element on the menu   */
                    /* stack                                          */
  do j = 1 to MenuStack.0
                    /* add the menu to the menu list                  */
    i = menu.!HistoryMenu.__NoOfEntries + 1
    menu.!HistoryMenu.i.__Entry = MenuStack.j
    menu.!HistoryMenu.i.__Action = '#GotoMenu() ' MenuStack.j
    menu.!HistoryMenu.__NoOfEntries = i
  end /* do j = 1 to MenuStack.0 */

RETURN !HistoryMenu

/* ------------------------------------------------------------------ */
/* function: interpret a line of the menu descriptions                */
/*                                                                    */
/* call:     I!.__ILine iLineNo, gVar, lineToInterpret                */
/*                                                                    */
/* where:    iLineNo - no. of the line in the menu description        */
/*           gVar - name(s) of additional global variable(s)          */
/*           lineToInterpret - line to interpret                      */
/*                                                                    */
/* returns:  nothing                                                  */
/*                                                                    */
I!.__ILine:
  parse arg iLineNo, gVar, ILine

  !curCmd = UserResponse
  !curRC = ''
  gVar1 = gvar exportedREXXVariables

  if I!.__ILine1( iLine ) then
    if iLineNo <> '?' then
      call I!.__AbortProgram 17, iLineNo, ILine
    else
    do
      call CharOut , ansi.__ESC || '21;1H' || menu.!thismenu.__FrameColor || ,
                     ansi.__WordWrapOn || substr( Menu.__MenuMask, 20*80+1 ) || ansi.__WordWrapOff

      call I!.__ShowErrorMessage 118, ILine
    end /* else */
RETURN 0

/* ------------------------------------------------------------------ */
/* sub routine of I!.__ILine to interpret the REXX statement.         */
/* Note that this routine don't know the global variables (except     */
/* the "exported REXX variables"; see RXLBOX.MEM)                     */
/*                                                                    */
I!.__ILine1: PROCEDURE expose (gvar1) menuDesc.

  parse arg iLIne

                    /* install temporary error handler                */
  SIGNAL ON  SYNTAX    NAME I!.__IError
  SIGNAL OFF NOVALUE

/* ???
  SIGNAL ON  ERROR     NAME I!.__IError
  SIGNAL ON  FAILURE   NAME I!.__IError
  SIGNAL ON  NOTREADY  NAME I!.__IError
*/

  interpret ILine

RETURN 0

I!.__IError:

RETURN 1

/* ------------------------------------------------------------------ */
/* function: Read the lines from the input channel                    */
/*                                                                    */
/* call:     I!.__ReadMenuD inputChannel                              */
/*                                                                    */
/* where:    inputChannel - name of the file or QUEUE:                */
/*                                                                    */
/* returns:  nothing                                                  */
/*                                                                    */
I!.__ReadMenuD: PROCEDURE expose (exposeList)

  parse upper arg inputChannel 1 qKeyWord 7 QueueName

  if qKeyWord = 'QUEUE:' then
  do
                    /* input channel is a REXX queue                  */
    Global.__iDeviceIsQueue = 1

    inputChannel = qKeyWord

    QueueName =  strip( QueueName )

    OldQueueName = rxQueue( 'G' )

                    /* input channel is a privat queue                */
                    /* make the input queue the current queue         */
    if QueueName <> '' then
      call rxQueue 'S', QueueName

                      /* check the no. of queue entries               */
    if queued() = 0 then
      call I!.__AbortProgram 6, QueueName

  end /* if qKeyWord = 'QUEUE:' then */
  else
  do
                    /* input channel is a file                        */

                    /* check if the file exist                        */
    if stream( inputChannel, 'c', 'QUERY EXIST' ) = '' then
      call I!.__AbortProgram 2, inputChannel

                    /* check if the file is empty or a device         */
    tcheck = stream( inputChannel, 'c', 'QUERY SIZE' )
    if tcheck = 0 | tcheck = '' then
      call I!.__AbortProgram 3, inputChannel

    if stream( inputChannel, 'c', 'OPEN READ' ) <> 'READY:' then
      call I!.__AbortProgram 4, inputChannel

                    /* read the complete file using Charin()          */
    iFile = charIN( inputChannel, 1, chars( inputChannel ) )

                    /* close the file                                 */
    call stream inputChannel, "c", "CLOSE"

                    /* split the file into lines by hand              */
    startpos = 1

  end /* else */

                    /* init the stem with the lines of the file       */
  j = 1
  k = 1

  do i = 1

    if Global.__iDeviceIsQueue = 1 then
    do
                    /* get the next line from the queue               */
      if queued() = 0 then
        leave

      curLine = lineIN( 'QUEUE:' )
    end /* if Global.__iDeviceIsQueue = 1 then */
    else
    do
                    /* get the next line from the file                */
      curpos = pos( '0D0A'x, iFile, startpos )
      if curpos = 0 then
        leave

      lineLen = ( curpos - startpos )

      curLine = substr( iFile, startpos, linelen )

      startpos = curpos + 2

    end /* else */

    curLine = strip( curLine )

    parse var inputLines.j '' -1 _1endChar '' -2 _2endChars

    select

      when curLine = '' then
        iterate

      when _1endChar <> '\' then
        j = i

      when _2endChars = '^\' then
      do
        inputLines.j = dbrright( inputLines.j, 2 ) || '\'
        j = i
      end /* when */

      otherwise
        inputLines.j = dbrright( inputLines.j, 1 )

    end /* select */

    inputLines.j = inputLines.j || curLine
  end /* do forever */

                    /* save the no. of lines                          */
  inputLines.0 = j

                    /* restore the old queue                          */
  if Global.__iDeviceIsQueue = 1 & queueName <> '' then
    call rxQueue 'S', OldQueueName
  Global.__iDeviceIsQueue = 0

RETURN

/* ------------------------------------------------------------------ */
/* function: Show the listbox                                         */
/*                                                                    */
/* call:     I!.__ShowListBox curMenuName {,MenuIsNew}                */
/*                                                                    */
/* where:    menuIsNew - 1 : new menu                                 */
/*                       0 : same menu                                */
/*                       (default: 1)                                 */
/*                                                                    */
/* returns:  the value of the choosen entry                           */
/*           or "WARNING: 1" if the user aborts the menu with F10     */
/*           The global variable !NextMenu contains the name of the   */
/*           next menu if the users selects a GOTOMENU command        */
/*                                                                    */
/* input:    !thisMenu - menu to show                                 */
/*                                                                    */
I!.__ShowListBox: PROCEDURE expose (exposeList) MenuStack.
  parse arg menuIsNew


  Menu.__MenusCalled = Menu.__MenusCalled +1

                    /* init the return code and the variables for the */
                    /* current menu entry                             */
  parse value '' with thisRC !curMenuEntry1 !curMenuEntry !curMenuAction !curCmd

/* --------------------------- */
                    /* save marker to clear the screen after          */
                    /* the menu                                       */
  Global.__CLS = menu.!thisMenu.__CLS

/* --------------------------- */
                    /* calculate the pages                            */
  curNoOfEntries = menu.!thisMenu.__NoOfEntries
  noOfDigits = length( curNoOfEntries )
  curEntryLineLength = menu.__MenuLineLength - noOfDigits -2

  Pages.0 = curNoOfEntries % Menu.__EntriesPerPage + ( ( curNoOfEntries // Menu.__EntriesPerPage ) <> 0 )

                    /* show the menu frame only for changed or        */
                    /* new menus                                      */
  if MenuIsNew = 1 then
    call I!.__DisplayEmptyFrame

  do i = 1 to pages.0
    pages.i.low = ( (i-1) * Menu.__EntriesPerPage ) + 1
    pages.i.high = min( i * Menu.__EntriesPerPage, curNoOfEntries )
  end /* do i = 1 to pages.0 */

  curPageIndex = 1
  curCursorLine = 0

                    /* use previous menu entry if possible            */
  if menu.!thisMenu.__LastLine <= curNoOfEntries then
    curCursorLine = menu.!thisMenu.__LastLine

  if menu.!thisMenu.__LastPage <= pages.0 then
    curPageIndex = menu.!thisMenu.__LastPage

  response = ''
  lastCursorLine = -1

  do until MenuOK = 1
    MenuOK = 0


    lineNo = Menu.__FirstMenuLine
  
    do i = pages.curPageIndex.low to pages.curPageIndex.low + Menu.__EntriesPerPage-1

      if i <= pages.curPageIndex.high then
        call CharOut , ansi.__ESC || lineNo || ';3H' ||,
                       menu.!thisMenu.__ItemColor || ,
                       format( i, noOfDigits+1 )  || ' : ' || ,
                       left( I!.__EvaluateString( curEntryLineLength, menu.!thisMenu.i.__Entry ), curEntryLineLength )
      else
        call charOut , ansi.__ESC || lineNo || ';1H' || menu.!thisMenu.__FrameColor || menu.__emptyLine

      lineNo = lineNo + 1
    end /* do i = ...*/

                    /* no. of entries on this page -1                 */
    noOfPageEntries = pages.curPageIndex.High - pages.CurPageIndex.Low

    numberUsed = 0

    do forever
      curI = pages.curPageIndex.low + curCursorLine

                    /* set the exported REXX variables                */

      !curMenuEntry = menu.!thisMenu.curI.__Entry
      !curMenuEntry1 = strip( left( I!.__EvaluateString( curEntryLineLength, menu.!thisMenu.CurI.__Entry ), curEntryLineLength ) )

      !curMenuAction = menu.!thisMenu.curI.__Action

      !curPageNo = curPageIndex
      !curLineNo = curCursorLine+1
      !curEntryNo = curI

      !curPageNo = curPageIndex
      !curLineNo = curCursorLine+1
      !totalPageCount = pages.0
      !totalEntryCount = curNoOfEntries
      !curMenu = !thisMenu
      !curMainMenu = menuStack.1

                    /* update the messages in the mask                */
      call I!.__DisplayEmptyFrame1

                    /* save the current action                        */
      curMenuActionLine = !curMenuAction

                    /* create the user prompt                         */
      curMessage = I!.__EvaluateString( menu.__MenuPromptLength, menu.!thisMenu.__InputPrompt ) || ,
                   ' (ALT-F4: quit'

                    /* add the possible keystrokes to the prompt      */
      if pages.curPageIndex.low + curCursorLine <> 1 then
        curMessage = curMessage  || ', ' || Menu.__CUpKey
      if pages.curPageIndex.low + curCursorLine <> curNoOfEntries then
        curMessage = curMessage || ', ' || Menu.__CDownKey

      if curPageIndex < pages.0 then
        curMessage = curMessage || ', ' || menu.__PageDownKey
      if curPageIndex > 1 then
        curMessage = curMessage || ', ' || menu.__PageUpKey

      if menu.!thisMenu.__InputVAR = '' then
        curMessage = curMessage || ', ' || ,
                     pages.curPageIndex.Low || '...' || ,
                     pages.curPageIndex.High || '): '
      else
        curMessage = curMessage || '): '

      if lastCursorLine <> curCursorLine then
      do
        if lastCursorLine <> -1 then
        do

                      /* unmark the previous selected line              */
          i = pages.curPageIndex.low + lastCursorLine
          call CharOut , ansi.__ESC || ,
               Menu.__FirstMenuLine + lastCursorLine || ';3H' || ,
               menu.!thisMenu.__ItemColor || ,
               left( format( i, noOfDigits+1 )  || ' : ' ||,
               I!.__EvaluateString( curEntryLineLength, menu.!thisMenu.i.__Entry ) , Menu.__ScreenCols-4)
        end /* if lastCursorLine <> -1 then */

                      /* mark the new selected line                     */
        call CharOut , ansi.__ESC || ,
             Menu.__FirstMenuLine + curCursorLine || ';3H' || ,
             menu.!thisMenu.__SelectedItemColor || ,
             left( format( curI, noOfDigits+1 )  || ' : ' || ,
               I!.__EvaluateString( curEntryLineLength, menu.!thisMenu.curI.__Entry ), Menu.__ScreenCols-4 ) || ,
               menu.!thisMenu.__FrameColor
      end /* if */

      global.__StatusLine = menu.!thisMenu.curI.__StatusLine
      if global.__StatusLine = '' then
        global.__StatusLine = menu.!thisMenu.__StatusLine

      call I!.__DisplayStatusLine

      call CharOut , ansi.__ESC || '24;4H' || Menu.!thisMenu.__InputLineColor || ,
                     left( curMessage, menu.__MenuLineLength ) || ,
                     menu.!thisMenu.__FrameColor || ' º '  || ,
                     menu.!thisMenu.__InputLineColor  || ,
                     ansi.__ESC || '24;' || length( curMessage ) +4 || 'H'

                    /* get the user input                             */
      fkeyName = ''; fkeyNo = ''
      if numberUsed = 0 then
      do
        do until menu.__CtrlCPressed = 0 
                    /* close STDIN to avoid a bug in the CTRL-C       */
                    /* handling                                       */
          call stream 'STDIN', 'c', 'close'
          menu.__CtrlCPressed = 0
          UserResponse = lineIn();
                    /* close STDIN to avoid a bug in the CTRL-C       */
                    /* handling                                       */
          call stream 'STDIN', 'c', 'close'
        end /* do until() */

                    /* check for function keys                        */
        parse upper var UserResponse '~' fkeyName '~' 1 '~F' fkeyNo '~'

                    /* save all user input (except function keys) for */
                    /* the #REPEAT command                            */
        if fkeyName = '' then
          menu.__CurResponse = UserResponse

      end /* if numberUsed = 0 then */

      UserResponse = strip( UserResponse )

      numberUsed = 0
      returnPressed = 0

      call CharOut , Menu.!thisMenu.__FrameColor

      if UserResponse = '' then
      do
        UserResponse = curMenuActionLine
        returnPressed = 1
        if datatype( UserResponse ) = 'NUM' then
          UserResponse = '^' || UserResponse
      end /* if UserResponse = '' then */

                    /* check, if this is a REXX statement             */
      call I!.__EvaluateCmd 'UserResponse' , UserResponse

      parse upper var UserResponse UserResponseInUpperCase

/* --------------------------- */
                    /* check for the function keys                    */
                    /* ESC, ALTX, F1 - F12, CTRL-F1, ALT-F1           */
      if FkeyNo <> '' then
      do

        select

          when FKeyNo = 'ESC' then
            UserResponse = menu.!thisMenu.__ESC

          when FKeyNo = 'ALTX' then
            UserResponse = '#QUIT'

          otherwise

                    /* check for redefined function keys              */
            curKeyName = '__FKEY' || fkeyNo
            UserResponse = strip( menu.!thisMenu.curKeyName )

            if UserResponse = '' then
              iterate

        end /* select */

        if I!.__EvaluateCmd( 'UserResponse', UserResponse ) <> 0 then
          iterate

        parse var UserResponse _1char +1 UserResponse1
        if _1Char = '~' then
          UserResponse = UserResponse1
        else
          if _1Char <> '#' then
            UserResponse = '*' || UserResponse

        parse upper var UserResponse UserResponseInUpperCase

      end /* if FKeyNo <> '' then */

/* --------------------------- */
                    /* repeat is a special command and must come      */
                    /* first!                                         */
      if UserResponseInUpperCase = '#REPEAT()' then
      do
                    /* do not repeat the #REPEAT command!             */
        menu.__CurResponse = menu.__OldResponse

        if menu.__OldResponse <> '' then
        do
          UserResponse = menu.__OldResponse
          numberUsed = 1
        end /* if */

        iterate
      end /* if */

/* --------------------------- */
                    /* save the user input for the #REPEAT command    */
      menu.__OldResponse = menu.__CurResponse

/* --------------------------- */
                    /* check for macros                               */
      parse var UserResponseInUpperCase cMacro +25
      if Menu.__Macros.0.cMacro <> '' then
      do

        UserResponse = menu.__macros.0.cMacro

        if I!.__EvaluateCmd( 'UserResponse', UserResponse ) <> 0 then
          iterate

        parse var UserResponse _1char +1
        if _1Char <> '#' then
          UserResponse = '*' || UserResponse

        parse upper var UserResponse UserResponseInUpperCase
      end /* if ... */

/* --------------------------- */

                    /* parse the command into name, options           */
                    /* and parameters                                 */
      parse var UserResponse _1char +1 RxLBox_CMD '(' rxlbox_opt ')' rxlbox_parm

      if _1Char = '#' then
      do
                    /* process RxLBox commands                        */

       parse upper var RxLBox_CMD RxLBox_CMD
       parse upper var rxlbox_opt rxlbox_opt

       RxLBox_CMD  = strip( RxLBox_CMD )
       rxlbox_opt  = strip( rxlbox_opt )
       rxlbox_parm = strip( rxlbox_parm )

       if I!.__EvaluateCmd( 'rxlBox_Parm', rxlBox_Parm ) <> 0 then
         RxLBox_CMD = ''

                    /* check for RxLBox commands to show the          */
                    /* online help                                    */
        hFound = 1
        select

          when RxLBox_CMD = 'SHOWHELP' then
            curHelpTopic = menu.!thisMenu.__HelpForF1

          when RxLBox_CMD = 'SHOWLINEHELP' then
            curHelpTopic = menu.!thisMenu.__HelpForALT_F1

          when RxLBox_CMD = 'SHOWKEYHELP' then
            curHelpTopic = menu.!thisMenu.__HelpForCTRL_F1

          otherwise
            curHelpTopic = ''
            hFound = 0

        end /* select */

        if hFound = 1 then
        do
          if curHelpTopic <> '' then
          do
            if I!.__EvaluateCmd( 'curHelpTopic' , curHelpTopic ) = 0 &,
               Help.curHelpTopic.0 <> '' then
            do
              call I!.__ShowOnlineHelp curHelpTopic
              leave
            end /* if */
          end /* if */

          iterate
        end /* if */

/* --------------------------- */
                    /* check for further RxLBox commands              */

        if RxLBox_CMD = 'USERINPUT' then
        do
          if wordPos( 'BLANK_OK', RxLBox_Opt ) <> 0 then
            if pos( 'MENUDESC.', translate( rxlbox_parm ) ) = 1 then
              call I!.__ILine '?',, rxlbox_parm '= "" ' 
            else
              call value strip( rxlbox_parm ), '', 'OS2ENVIRONMENT'
          iterate
        end /* */

        if RxLBox_CMD = 'REXXCMD' | RxLBox_CMD = 'EXECUTECMD' then
        do
                    /* execute an OS/2 command                        */
          if RxLBox_CMD = 'EXECUTECMD' then
            call I!.__ExecuteUserCommand RxLBox_Parm,0

                    /* execute a REXX statement                       */
          if RxLBox_CMD = 'REXXCMD' then
            if I!.__ILine( '?',, RxLBox_Parm ) <> 0 then
              RxLBox_CMD = 'REFRESH'

                    /* process the options for the REXXCMD and        */
                    /* EXECUTECMD commands                            */
          select
            when wordpos( 'GOBACK', RXLBox_Opt ) <> 0 then
              RxLBox_CMD = 'GOBACK'

            when wordpos( 'QUIT', RXLBox_Opt ) <> 0 then
              RxLBox_CMD = 'QUIT'

            when wordPos( 'PAUSE', RxLBox_Opt ) <> 0 then
            do
              call WaitForAKey
              RxLBox_CMD = 'REFRESH'
            end /* when */

            when wordPos( 'NOP', RxLBox_Opt ) <> 0 then
              RxLBox_CMD = 'NOP'

            otherwise
              RxLBox_CMD = 'REFRESH'

          end /* select */

        end /* if */

/* --------------------------- */

        if RxLBox_CMD = 'REFRESH' then
        do
                    /* refresh the display                            */
          call I!.__DisplayEmptyFrame
/*
          UserResponseInUpperCase = '~HOME~'
*/
          leave
        end /* if */

/* --------------------------- */

        if RxLBox_CMD = 'NOP' then
          iterate

/* --------------------------- */

        !NextMenu = ''

                    /* show the menu with a list of a menus called    */
                    /* so far                                         */
        if RxLBox_CMD = 'SHOWHISTORY' then
          !NextMenu = I!.__CreateHistoryMenu()

                    /* show the menu with all menus defined in the   */
                    /* menu descriptions                             */
        if RxLBox_CMD = 'SHOWMENULIST' then
          !NextMenu = !ListMenu

                    /* show the menu with a list of all macros        */
                    /* defined in the menu descriptions               */
        if RxLBox_CMD = 'SHOWMACROLIST' then
          !NextMenu = !MacroMenu

                    /* switch to another menu defined in the menu     */
                    /* descriptions                                   */
        if RxLBox_CMD = 'GOTOMENU' then
          parse upper var rxlbox_parm !NextMenu

        if RxLBox_CMD = 'GOBACK' then
        do
                    /* go one menu level back                         */
          !NextMenu = '0001'x
          !BackLevel = RxLBox_Parm
        end /* if */

        if RxLBox_CMD = 'QUIT' | !NextMenu <> '' then
        do
                    /* leave the program (or call another menu if the */
                    /* command was used by another command, see       */
                    /* above)                                         */
          MenuOK = 1
          thisRC = ''
          leave
        end /* if */

                    /* invalid command found                          */
        menuIsNew = 0
        call I!.__ShowErrorMessage 13, RxLBox_CMD
        leave

      end /* if RxLBox_CMD = 'QUIT' | !NextMenu <> '' then */

/* --------------------------- */
                    /* check for function keys                        */
/*
      parse upper var UserResponseInUpperCase '~' fKeyName '~'
*/
      if fkeyName <> '' then
      do
                    /* Cursor Up                                      */
        if fKeyName = 'CUP' then
          if curCursorLine <= 0 then
            fKeyName = 'PGUP'
          else
          do
            lastCursorLine = curCursorLine
            curCursorLine = curCursorLine -1
            iterate
          end /* else */

                    /* Cursor Down                                    */
        if fKeyName = 'CDN' then
          if curCursorLine >= noOfPageEntries then
            fkeyName = 'PGDN'
          else
          do
            lastCursorLine = curCursorLine
            curCursorLine = curCursorLine + 1
            iterate
          end /* else */

                    /* PgDn                                           */
        if fkeyName = 'PGDN' then
          if curPageIndex < pages.0 then
          do
            curPageIndex = curPageIndex + 1
            lastCursorLine = -1
            curCursorLine = 0
            leave
          end /* if */
          else
            fkeyName = 'CEND'

                    /* PgUp                                           */
        if fkeyName = 'PGUP' then
          if curPageIndex > 1 then
          do
            curPageIndex = curPageIndex - 1

            lastCursorLine = -1
            curCursorLine = pages.curPageIndex.High - pages.CurPageIndex.Low
            leave
          end
          else
            fkeyName = 'CHOME'

                    /* Home                                           */
        if fKeyName =  'HOME' then
          if curPageIndex <> 1 then
          do
            lastCursorLine = -1
            curCursorLine = 0
            curPageIndex = 1
            leave
          end
          else
            fkeyName = 'CHOME'

                    /* Ctrl-Home                                      */
        if fkeyName = 'CHOME' then
        do
          if curCursorLIne = 0 then
            iterate

          lastCursorLine = curCursorLine
          curCursorLine = 0
          iterate

        end /* if */

                    /* End                                            */
        if fkeyName = 'END' then
          if curPageIndex <> pages.0 then
          do
            lastCursorLine = -1
            curPageIndex = pages.0
            curCursorLine = pages.curPageIndex.High - pages.CurPageIndex.Low
            leave
          end
          else
            fkeyName = 'CEND'

                    /* Ctrl-End                                       */
        if fkeyName = 'CEND' then
        do
          if curCursorLine = noOfPageEntries then
            iterate

          lastCursorLine = CurCursorLine
          curCursorLine = noOfPageEntries
          iterate

        end /* if */

      end /* if fkeyName <> '' then */

/* --------------------------- */

      parse var UserResponse _1Char +1 _userCmd
      if _1Char = '*' then
      do
                    /* OS/2 command                                   */
        call I!.__ExecuteUserCommand _userCmd
        leave
      end /* if left( ... */

/* --------------------------- */

      envVar = ''
      envValue = userResponse

      parse var curMenuActionLine tcurcmd '(' tcurOpt ')' tcurParm

      if translate( tcurCmd ) = '#USERINPUT' then
      do
        if envValue <> '' then
        do
          parse var tcurParm envVar '#' checkStmt '#' errMsg
          envVar = strip( envVar )

          call I!.__EvaluateCmd 'envVar', envVar

          if checkStmt <> '' then
          do
            tRC = 0
            call I!.__ILine '?' , 'envValue tRC', 'tRC = 'checkStmt
            if tRC = 0 then
            do
              call I!.__ShowErrorMessage 104 , I!.__EvaluateString( , errMsg )
              envVar = ''
              leave
            end /* if tRC = 0 then */
          end /* if checkStmt <> '' then */
        end /* if envValue <> '' then */
      end /* if tcurCmd = '#USERINPUT' then */
      else
        if menu.!thisMenu.__InputVAR <> '' then
          call I!.__EvaluateCmd 'envVar', menu.!thisMenu.__InputVAR

      if envVar <> '' then
      do
                    /* check for control chars                        */
        parse var envValue _1Char +1 envValue1
        if _1Char = '^' then
          envValue = envValue1

        if wordpos( 'UPPER', tcurOpt ) <> 0 then
          envValue = translate( envValue )

        if envVar <> '' then
          if pos( 'MENUDESC.', translate( envVar ) ) = 1 then
            call I!.__ILine '?',, envVar || '="' || envValue || '"' 
          else
            call value envVar, envValue, 'OS2ENVIRONMENT'
        else
          call CharOut, ascii.__Bel

        leave
      end /* if envVar <> '' then */

/* --------------------------- */
                /* convert relative positions to absolute positions   */

      continueMenu = 0

      if pos( left( UserResponseInUpperCase, 1 ), '+-' ) <> 0 then
        if datatype( UserResponseInUpperCase, 'NUM' ) == 1 then
        do
          UserResponseInUpperCase = pages.curPageIndex.low + UserResponseInUpperCase + curCursorLine
          ContinueMenu = 1
        end /* if */

      if datatype( UserResponseInUpperCase, 'NUM' ) == 1 then
      do
        if UserResponseInUpperCase >= pages.curPageIndex.low & ,
           UserResponseInUpperCase <= pages.curPageIndex.high & ,
           continueMenu <> 1 then
        do
                /* position is on this page - end the program         */
                /* if the action is not empty                         */

          if menu.!thisMenu.UserResponseInUpperCase.__Entry = '' then
            iterate     /* no action for this entry - continue prog.  */

          thisRC = I!.__EvaluateString( , menu.!thisMenu.UserResponseInUpperCase.__Action )
          if pos( left( thisRC,1 ), '#*' ) <> 0 then
          do

            UserResponseInUpperCase = thisRC
            userResponse = thisRC

            numberUsed = 1
            iterate
          end /* if */

                        /* the next two statements are only executed  */
                        /* if the IF statement is false               */
          MenuOK = 1
          leave
        end
        else
        do
                /* position is on another page - show that page       */
          if UserResponseInUpperCase <= 0 then
            UserResponseInUpperCase = 1
          if UserResponseInUpperCase >= curNoOfEntries then
            UserResponseInUpperCase = curNoOfEntries

          lastPageIndex = curPageIndex
          lastCursorLine = curCursorLine

          curPageIndex = ( UserResponseInUpperCase % menu.__EntriesPerPage )
          curCursorLine = (UserResponseInUpperCase // menu.__EntriesPerPage )
          if curCursorLine <> 0 then
            curPageIndex = curPageIndex + 1

          if curCursorLine = 0 then
            curCursorLine = menu.__EntriesPerPage-1
          else
            curCursorLine = curCursorLine -1

          if lastPageIndex = curPageIndex then
            iterate

                        /* the next two statements are only executed  */
                        /* if the IF statement is false               */
          lastCursorLine = -1
          leave

        end /* else */
      end /* if datatype( UserResponseInUpperCase, 'NUM' ) == 1 then */

/* --------------------------- */
                    /* any other input                                */
      if menu.!thisMenu.__AcceptAllInput = 'YES' | returnPressed = 1 then
      do
        thisRC = I!.__EvaluateString( , UserResponse )
        menuOk = 1
        leave
      end /* if menu.!thisMenu.__AcceptAllInput = 'YES' then */

                        /* the next statement is only executed        */
                        /* if the IF statement is false               */
      call charOut, ascii.__BEL

    end /* do forever */

  end /* do until MenuOK = 1 */

                    /* save the current page and entry of this menu   */
  menu.!thisMenu.__LastLine = curCursorLine
  menu.!thisMenu.__LastPage = curPageIndex

/* --------------------------- */
                    /* check for control chars                        */
  parse var thisRC _1Char +1 thisRC1
  if _1Char = '^' then
    thisRC = thisRC1

/* --------------------------- */

RETURN thisRC

/* ------------------------------------------------------------------ */
/* function: Evaluate an string from the menu description             */
/*                                                                    */
/* call:     I!.__EvaluateString { maxStringLength }, lineToEval      */
/*                                                                    */
/* where:    maxStringLength - max. length for the result string      */
/*           lineToEval - string to evaluate                          */
/*                                                                    */
/*                                                                    */
/* returns:  -                                                        */
/*                                                                    */
I!.__EvaluateString: PROCEDURE expose (exposeList)
  parse arg mLen , tStr

  call I!.__EvaluateCmd 'tStr', tStr

/*
  if mLen <> '' then
    if length( tStr ) > mLen then
      tStr = left( tStr, mLen )
*/

 mlen = 0 || mlen
 parse var tStr +(mLen)

RETURN tStr

/* ------------------------------------------------------------------ */
/* function: Evaluate a command before executing if necessary         */
/*                                                                    */
/* call:     I!.__EvaluateCmd varName, lineToEval                     */
/*                                                                    */
/* where:    varName - name of the variable for the result            */
/*           lineToEval - string to evaluate                          */
/*                                                                    */
/* returns:  0 - ok                                                   */
/*           else error                                               */
/*                                                                    */
I!.__EvaluateCmd:
  parse arg rx.__varN . , rx.__VarV, rx.__chkCmd

  tRC = 0
  rx.__VarV = strip( rx.__VarV )

  parse var rx.__VarV s1 +1 . '' -1 s2 1 (s1) rx.__VarV1 (s2)
  if s1 || s2 = '{}' then
    tRC = ( I!.__ILine( '?', rx.__VarN,  rx.__VarN ' = ' rx.__VarV1 ) <> 0 )
  else
    call value rx.__VarN, rx.__VarV

  drop rx.

RETURN tRC

/* ------------------------------------------------------------------ */
/* function: Display the empty menu frame                             */
/*                                                                    */
/* call:     I!.__DisplayEmptyFrame                                   */
/*                                                                    */
/* returns:  -                                                        */
/*                                                                    */
I!.__DisplayEmptyFrame:

                      /* clear the screen                             */
  call I!.__Cls menu.!thisMenu.__FrameColor

  call CharOut , ansi.__ESC || '1;1H' || menu.!thisMenu.__FrameColor || ,
                 ansi.__WordWrapON || Menu.__MenuMask || ansi.__WordWrapOff

I!.__DisplayEmptyFrame1:
  if menu.!thisMenu.__Title1 <> '' then
    call CharOut , ansi.__ESC || '2;4H' || menu.!thisMenu.__Title1Color || ,
                 center( I!.__EvaluateString( menu.__MenuMsgLength, menu.!thisMenu.__Title1 ) ,,
                 menu.__MenuMsgLength ) || ,
                 menu.!thisMenu.__FrameColor

  if menu.!thisMenu.__Title2 <> '' then
    call CharOut , ansi.__ESC || '3;4H' || menu.!thisMenu.__Title2Color || ,
                 center( I!.__EvaluateString( menu.__MenuMsgLength, menu.!thisMenu.__Title2 ) ,,
                 menu.__MenuMsgLength ) || ,
                 menu.!thisMenu.__FrameColor

  if menu.!thisMenu.__Title3 <> '' then
    call CharOut , ansi.__ESC || '5;4H' || menu.!thisMenu.__Title3Color || ,
                 center( I!.__EvaluateString( menu.__MenuMsgLength, menu.!thisMenu.__Title3 ),,
                 menu.__MenuMsgLength ) || ,
                 menu.!thisMenu.__FrameColor

/* no RETURN because we've to show the status line */

/* ------------------------------------------------------------------ */
/* function: Display the status lines                                 */
/*                                                                    */
/* call:     I!.__DisplayStatusLine                                   */
/*                                                                    */
/* returns:  -                                                        */
/*                                                                    */
/* note:     DO NOT MOVE THIS ROUTINE!!!                              */
/*                                                                    */
I!.__DisplayStatusLine:
/*
  call CharOut , ansi.__ESC || '22;4H' || menu.!thisMenu.__StatusLineColor || ,
                 center( I!.__EvaluateString( menu.__MenuMsgLength, menu.!thisMenu.__StatusLine ), menu.__MenuMsgLength ) || ,
                 menu.!thisMenu.__FrameColor
*/

  call CharOut , ansi.__ESC || '22;4H' || menu.!thisMenu.__StatusLineColor || ,
                 center( I!.__EvaluateString( menu.__MenuMsgLength, global.__StatusLine ), menu.__MenuMsgLength ) || ,
                 menu.!thisMenu.__FrameColor

  call CharOut , ansi.__ESC || '24;4H' || menu.!thisMenu.__InputLineColor || ,
                 center( ' ', menu.__MenuMsgLength ) || ,
                 menu.!thisMenu.__FrameColor

RETURN

/* ------------------------------------------------------------------ */
/* function: Show an error message                                    */
/*                                                                    */
/* call:     I!.__ShowErrorMessage errorNo {, errorComment}           */
/*                                                                    */
/* where:    errorNo - number of the error                            */
/*           errorComment - additional error comment                  */
/*                                                                    */
/* returns:  -                                                        */
/*                                                                    */
I!.__ShowErrorMessage: PROCEDURE expose (exposeList)
  parse arg errorNo, errCmt

  if Menu.__MenusCalled = 0 then
    call I!.__DisplayEmptyFrame

  errorMsg = I!.__GetMessage( errorNo , errCmt )
  if length( errorMsg ) > menu.__MenuMsgLength then
    errorMsg = left( errorMsg, menu.__MenuMsgLength-5 ) '...'

  call CharOut , ansi.__ESC || '22;4H' || menu.!thisMenu.__ErrorTextColor || ,
                 center( errorMsg , menu.__MenuMsgLength ) || ,
                 menu.!thisMenu.__FrameColor || ascii.__bel

  call CharOut , ansi.__ESC || '24;4H' || menu.!thisMenu.__InputLineColor || ,
                 center( I!.__EvaluateString( menu.__MenuMsgLength, menu.!thisMenu.__ErrorPrompt ),,
                 menu.__MenuMsgLength ) || ,
                 menu.!thisMenu.__FrameColor || ' º '  || ,
                 menu.!thisMenu.__InputLineColor  || ,
                 menu.!thisMenu.__FrameColor

  call WaitForAKey

RETURN

/* ------------------------------------------------------------------ */
/* Function: Show an entry of the online help                         */
/*                                                                    */
/* Usage:    I!.__ShowOnlineHelp curTopic                             */
/*                                                                    */
/* where:    curTopic - name of the menu where the online help is for */
/*                                                                    */
/* Returns:  -                                                        */
/*                                                                    */
I!.__ShowOnlineHelp: PROCEDURE expose (exposeList)
  parse arg curTopic

  do i = 1 to Menu.__EntriesPerPage
    call CharOut, ansi.__ESC || i+menu.__FirstMenuLine-1 || ';3H' || ,
                  menu.!thisMenu.__StatusLineColor || ' ' || ,
                  center( strip( help.curTopic.i ) , menu.__MenuMsgLength ) || ' '
  end /* do i = 1 to Menu.__EntriesPerPage */

  call CharOut , ansi.__ESC || '22;4H' || menu.!thisMenu.__StatusLineColor || ,
               center( I!.__EvaluateString( menu.__MenuMsgLength, menu.!thisMenu.__HelpStatusLine ),,
               menu.__MenuMsgLength ) || ,
               menu.!thisMenu.__FrameColor

  call CharOut , ansi.__ESC || '24;4H' || menu.Topic.__InputLineColor || ,
                 center( I!.__EvaluateString( menu.__MenuMsgLength, menu.!thisMenu.__HelpPrompt ),,
                 menu.__MenuMsgLength ) || ,
                 menu.!thisMenu.__FrameColor || ' º '

  call WaitForAKey

RETURN

/* ------------------------------------------------------------------ */
/* function: Execute an user defined command                          */
/*                                                                    */
/* call:     I!.__ExecuteUserCommand userCommand {,displayFrame}      */
/*                                                                    */
/* where:    userCommand - command to execute                         */
/*           displayFrame - if 0 do not redisplay the frame           */
/*                          else do, default is redisplay the frame   */
/*                                                                    */
/* returns:  -                                                        */
/*                                                                    */
I!.__ExecuteUserCommand: PROCEDURE expose (exposeList)

  parse arg wfc +1 UserCmd, dispFrame
                     /* wfC = * -> wait after command                  */

  call I!.__Cls global.__cls
  call I!.__ResetAnsiStatus

/* ???
  SIGNAL OFF ERROR
  SIGNAL OFF FAILURE
  SIGNAL OFF NOTREADY
*/

  SIGNAL ON SYNTAX Name  I!.__ExUserCmdExt

  if wfC <> '*' then
    '@cmd /c' wfc || UserCmd
  else
    '@cmd /c' UserCmd

I!.__ExUserCmdExt:
  SIGNAL OFF SYNTAX

  if wfC = '*' then
    call WaitForAKey 1

  call I!.__ChgAnsiStatus

  if dispFrame <> 0 then
    call I!.__DisplayEmptyFrame

RETURN

/* ------------------------------------------------------------------ */
/* Function: Change the ANSI status and redefine the keys             */
/*                                                                    */
/* Call:     I!.__ChgAnsiStatus                                       */
/*                                                                    */
I!.__ChgAnsiStatus: PROCEDURE expose (exposeList)

  Global.__AnsiStatusChanged = 1

/* ???
  SIGNAL OFF FAILURE
  SIGNAL OFF ERROR
*/

                    /* turn ANSI support on                           */
  '@ANSI ON 2>NUL 1>NUL'

                    /* turn word wrapping off                         */
  call CharOut , ansi.__WordWrapOff

                    /* redefine the neccessary keys                   */
  do i = 1 to ansi.__newKeys.0
    call CharOut , ansi.__ESC || ansi.__newKeys.i.code || ,
                                 ';"~' || ansi.__newKeys.i.new || '~";13;p'

  end /* do i = 1 to ansi.__newKeys.0 */

  parse value I!.__GetDisplaySize() with cols rows

  if cols <> menu.__ScreenCols | rows <> menu.__ScreenRows then
  do
                    /* save the current display size and set the      */
                    /* the display size to 80x25                      */
    Global.__OldDisplaySize = cols rows
    call CharOut , ansi.__esc || '3h'
  end /* if cols <> menu.__ScreenCols | ... */

RETURN

/* ------------------------------------------------------------------ */
/* Function: Reset the ANSI status                                    */
/*                                                                    */
/* Call:     I!.__ResetAnsiStatus                                     */
/*                                                                    */
I!.__ResetAnsiStatus: PROCEDURE expose (exposeList)

                    /* ignore errors of external programs             */
/* ???
  SIGNAL OFF ERROR
  SIGNAL OFF FAILURE
*/

                    /* restore the definition of the redefined        */
                    /* keys                                           */
  if symbol( "ansi.__newKeys.0" ) = 'VAR' then
    do i = 1 to ansi.__newKeys.0
      call CharOut , ansi.__ESC || ansi.__newKeys.i.code || ansi.__newKeys.i.code || ';p'
    end /* do i = 1 to ansi.__newKeys.0 */

                    /* turn word wrapping on                          */
                    /* and reset the display attributes               */
  call CharOut , ansi.__WordWrapOn || ansi.__AttrOff

                    /* restore the display size if necessary          */
  if Global.__OldDisplaySize <> '' then
    '@mode ' Global.__OldDisplaySize '2>NUL 1>NUL'

  Global.__AnsiStatusChanged = 0

RETURN

/* ------------------------------------------------------------------ */
/* function: convert a colorString into ANSI sequences                */
/*                                                                    */
/* call:     I!.__GetColorString colorString                          */
/*                                                                    */
/* returns:  ANSI sequences to set the colors                         */
/*                                                                    */
I!.__GetColorString: PROCEDURE expose (exposeList)

                    /* get the parameter                              */
  parse upper arg fgColor 'ON' bgColor

  if fgColor bgColor = '' then
    RETURN ''

                    /* init the return code                           */
  thisRC = ansi.__AttrOff

                    /* first round: use foreground colors             */
  cC = '__FG'
  do 2

    do i = 1 to words( fgColor )
      cWd = word( fgColor, i )
      thisRC = thisRC || ansi.cC.cWd || ansi.__attr.cWd
    end /* do i = 1 to words( fgColor ) */

                    /* second round: use background colors           */
    fgColor = bgColor
    cC = '__BG'
  end /* do 2 */

RETURN thisRC

/* ------------------------------------------------------------------ */
/* Function: Clear the screen                                         */
/*                                                                    */
/* Call:     I!.__Cls {newColor}                                      */
/*                                                                    */
/* where:    newColor - color for the screen                          */
/*                                                                    */
I!.__Cls: /* PROCEDURE expose (exposeList) */
  call CharOut , ansi.__ESC || '1;1H' || arg(1) || ansi.__ClrScr
RETURN

/* ------------------------------------------------------------------ */
/* function: Get the current display size                             */
/*                                                                    */
/* call:     I!.__GetDisplaySize                                      */
/*                                                                    */
/* returns:  columns rows                                             */
/*                                                                    */
/* note:     This function works only for display sizes up to 200 for */
/*           columns or rows. The upper left corner is 1,1.           */
/*           The REXXUTIL function SysCurPos uses zero based values   */
/*           (the upper left corner is 0,0).                          */
/*                                                                    */
I!.__GetDisplaySize: PROCEDURE expose (exposeList)

  uChars = ':;<=>?@ABCD'

                    /* save current cursor position                   */
  call CharOut , ansi.__ESC || '6n'
  pull curPos

                    /* try to set the cursor to the position 200,200  */
  call CharOut , ansi.__ESC || '200;200H'

                    /* get cursor position                            */
  call CharOut , ansi.__ESC || '6n'
  pull tPos

                    /* restore current cursor position                */
  call CharOut , left( curPos, length( curPos)-1) || 'H'

  parse var tPos 3 y1 +1 y2 +1 3 rows +2 6 x1 +1 x2 +1 6 cols +2 .

  if pos( y1, uChars ) <> 0 then
    rows = 10 || y2

  if pos( x1, uChars ) <> 0 then
    cols = 10 || x2

RETURN cols rows

/* ------------------------------------------------------------------ */
/* function: Create the error string and end the program              */
/*                                                                    */
/* call:     I!.__AbortProgram  errorNo {{,arg1} {...} {,arg9}}       */
/*                                                                    */
/* where:    errorNo - number of the error                            */
/*           arg1 .. arg9 - values for the placeholder in the         */
/*                          errormessages                             */
/*                                                                    */
/* returns:  nothing                                                  */
/*                                                                    */
/* Note:     This routine ends the program with a jump to the         */
/*           label RxListBoxEnd                                       */
/*                                                                    */
I!.__AbortProgram: PROCEDURE expose (exposeList)
  parse arg errorNo, a1, a2, a3, a4, a5, a6, a7, a8, a9

  global.__rc = I!.__GetMessage( errorNo ,,
                     a1, a2, a3, a4, a5, a6, a7, a8, a9 )


signal I!.__RxLBoxEnd

/* ------------------------------------------------------------------ */
/* function: Init the global menu data                                */
/*                                                                    */
/* call:     I!.__IGData                                              */
/*                                                                    */
/* returns:  -                                                        */
/*                                                                    */
I!.__IGData: /* PROCEDURE expose (exposeList) */

                    /* ASCII codes                                    */
  ascii.__BEL =  '07'x
  ascii.__BS  =  '08'x
  ascii.__TAB =  '09'x
  ascii.__CRLF = '0D0A'x

/* --------------------------- */
                    /* init the ANSI esc sequences for the            */
                    /*   - display control                            */
                    /*   - the key redefinitions                      */
                    /* and                                            */
                    /*   - the colors                                 */
  ansi.__ESC = '1B'x || '['

  do i = 1 to 8

                    /* define ANSI codes for various actions          */
    if i <= 7 then
      call value 'ANSI.__' || word( 'DELEOL CLRSCR SAVEPOS RESTPOS ATTROFF WORDWRAPOFF WORDWRAPON',i ),,
                ansi.__ESC || word( 'K 2J s u 0;m 7l 7h', i )

                    /* define color attributes                        */
    if i <= 5 then
      call value 'ANSI.__ATTR.' || word( 'HIGHLIGHT NORMAL BLINK INVERS INVISIBLE', i ) ,,
                     ansi.__ESC || word( '1;m 2;m 5;m 7;m 8;m',i )

    cColor = word( 'BLACK RED GREEN YELLOW BLUE MAGNENTA CYAN WHITE',i )

                    /* define foreground color variables              */
    call value 'ANSI.__FG.' || cColor, ansi.__ESC || 29+i || ';m'

                    /* define background color variables              */
    call value 'ANSI.__BG.' || cColor, ansi.__ESC || 39+i || ';m'
  end /* do i = 1 to 8 */

                    /* create the stem with the keycodes              */
  ansi.__Newkeys.1.code = '27'              /* ESC                    */
  ansi.__Newkeys.1.new  = 'FESC'            /* go back                */

  keyCodes  = '45 59 94 104 60 61 62 107 63 64 65 66 67 68 133 134 71 72 73 79 80 81 118 132 119 117'
  nKeyCodes = 'FALTX F1 FC1 FA1 F2 F3 F4 FALTX F5 F6 F7 F8 F9 F10 F11 F12 HOME CUP PGUP END CDN PGDN CPGDN CPGUP CHOME CEND'

  do i = 2 to words( keyCodes )+1
    ansi.__NewKeys.i.code = '0;' || word( keyCodes,i-1 )
    ansi.__NewKeys.i.New = word( nKeyCodes,i-1 )
  end /* do i = 1 to words( keyCodes ) */

  ansi.__Newkeys.0 = 27

/* --------------------------- */

                    /* cursor key names                               */
  Menu.__CDownKey    = '19'x
  Menu.__CUpKey      = '18'x
  menu.__PageDownKey = 'PgDn'
  menu.__PageUpKey   = 'PgUp'

                    /* default menu description file                  */
  Global.__defMenuName = 'MAIN.MEN'

                    /* internal menus                                 */
                    /* Caution: The leading and trailing blanks are   */
                    /*          part of the menuname!                 */
  !ListMenu =      ' MENULIST '
  !HistoryMenu =   ' MENUHISTORY '
  !MacroMenu =     ' MACROMENU '

  !defaultMenu =   'DEFAULTMENU'
  !MainMenu =      'MAINMENU'

                    /* stem with the internal menu marker             */
  menu.__special.!HistoryMenu = 1
  menu.__special.!ListMenu = 1
  menu.__special.!MacroMenu = 1

                    /* function keys                                  */
  menu.__menuFKeys = ,
                'ESC'                ,
                'FKEY1'              ,
                'FKEY2'              ,
                'FKEY3'              ,
                'FKEY4'              ,
                'FKEY5'              ,
                'FKEY6'              ,
                'FKEY7'              ,
                'FKEY8'              ,
                'FKEY9'              ,
                'FKEY10'             ,
                'FKEY11'             ,
                'FKEY12'

                    /* colors for the parts of the menu               */
  menu.__menuColors  = ,
                'FRAMECOLOR'         ,
                'ITEMCOLOR'          ,
                'SELECTEDITEMCOLOR'  ,
                'TITLE1COLOR'        ,
                'TITLE2COLOR'        ,
                'TITLE3COLOR'        ,
                'STATUSLINECOLOR'    ,
                'INPUTLINECOLOR'     ,
                'ERRORTEXTCOLOR'     ,
                'CLS'

                    /* messages for the menu                          */
  menu.__menuMessages = ,
                 'TITLE1'            ,
                 'TITLE2'            ,
                 'TITLE3'            ,
                 'STATUSLINE'        ,
                 'INPUTPROMPT'       ,
                 'HELPPROMPT'        ,
                 'ERRORPROMPT'       ,
                 'HELPSTATUSLINE'

                    /* online help sections                           */
  menu.__menuHelpTexts = ,
                 'HELPFORF1'         ,
                 'HELPFORCTRL_F1'    ,
                 'HELPFORALT_F1'

                    /* possible options for a menu                    */
  menu.__menuOptions = ,
                'ACCEPTALLINPUT'     ,
                'INPUTVAR'           ,
                'ONINIT'             ,
                'ONEXIT'             ,
                'ONMAININIT'         ,
                'ONMAINEXIT'         ,
                menu.__menuMessages  ,
                menu.__menuColors    ,
                menu.__menuFKeys     ,
                menu.__menuHelpTexts

  Menu.__MenusCalled = 0

  Menu.__Macros.0 = 0

  Menu.__EntriesPerPage = 14
  Menu.__FirstMenuLine = 7

  Menu.__ScreenCols = 80
  Menu.__ScreenRows = 25

  Menu.__MenuLineLength = 74
  menu.__MenuMsgLength = 74
  Menu.__MenuPromptLength = 15

  Menu.__emptyLine = ' º' || copies( ' ', 76 ) || 'º '

  eL  = copies( 'Í', 76 )
  eL1 = copies( 'Ä', 74 )

  Menu.__MenuMask = ,
     ' É'  || el                 || '» '  || ,
     Menu.__emptyLine                     || ,
     Menu.__emptyLine                     || ,
     ' º ' || el1               || ' º '  || ,
     Menu.__emptyLine                     || ,
     ' Ì'  || el                 || '¹ '  || ,
     copies( Menu.__emptyLine, 14 )       || ,
     ' Ì'  || el                 || '¹ '  || ,
     Menu.__emptyLine                     || ,
     ' º ' || el1               || ' º '  || ,
     Menu.__emptyLine                     || ,
     ' È'  || el                 || '¼'

  drop el el1
                    /* create the var with the messages               */

                    /* message 1 to 98 are error messages             */
                    /* message 99 and above are normal messages       */
  msgStr.1   = ,
/*  1 */     '_' ,
/*  2 */     'Inputfile_"%1"_not_found' ,
/*  3 */     'InputFile_"%1"_is_empty' ,
/*  4 */     'Error_opening_the_inputFile_"%1"' ,
/*  5 */     'InputQueue_"%1"_does_not_exist' ,
/*  6 */     'InputQueue_"%1"_is_empty' ,
/*  7 */     'The_line_%1_of_the_input_channel_is_invalid_(The_line_reads:_%2)' ,
/*  8 */     'Menu_"%1"_not_found' ,
/*  9 */     'Menu_"%1"_is_empty' ,
/* 10 */     'Line_%1:_Menu_%2_already_defined' ,
/* 11 */     '_' ,
/* 12 */     'Line_%1:_Macroname_to_long' ,
/* 13 */     'Invalid_menu_command_found:_"%1"' ,
/* 14 */     'Line_%1:_Macro_"%2"_already_defined' ,
/* 15 */     'Line_%1:_Keyword_missing' ,
/* 16 */     'Line_%1:_Invalid_MENUITEM/ACTION_keyword_found' ,
/* 17 */     'Line_%1:_Invalid_REXX_statement,_the_line_reads_"%2"' ,
/* 18 */     'Line_%1:_Onlinehelp_%2_already_defined' ,
/* 19 */     'Line_%1:_Onlinehelp_to_large_(maximun_is_14_lines)' ,
/* 20 */     'Line_%1:_Invalid_menu_name' ,
/* 21 */     'Parameter_"%1"_is_invalid' ,
/* 99 */     '%1_error_in_line_%2,_rc_=_%3_%4' ,
/*100 */     'Checking_the_parameter_...' ,
/*101 */     'Reading_the_menu_description_...' ,
/*102 */     'Creating_the_menu_structure_...' ,
/*103 */     'Preparing_the_menu_...' ,
/*104 */     '%1' ,
/*105 */     '_' ,
/*106 */     '_' ,
/*107 */     '_' ,
/*108 */     '_' ,
/*109 */     '_' ,
/*110 */     'List_of_all_menu_descriptions_in' ,
/*111 */     'Choose_a_menu_from_the_list' ,
/*112 */     'Your_choice:' ,
/*113 */     'Press_any_key_to_continue' ,
/*114 */     'List_of_all_macros_defined_in' ,
/*115 */     '***_Keyword_"%1"_not_defined_for_this_menu!_***_' ,
/*116 */     'List_of_all_menus_called_so_far' ,
/*117 */     'Choose_a_macro_from_the_list' ,
/*118 */     'Error_evaluating_"%1"'

RETURN

/* ------------------------------------------------------------------ */
/* function: get a string                                             */
/*                                                                    */
/* call:     I!.__GetMessage msg_no {{,arg1} {...} {,arg9}}           */
/*                                                                    */
/* where:    msg_no - the message number                              */
/*           arg1 .. arg9 - values for the placeholder in the         */
/*                          messages                                  */
/*                                                                    */
/* returns:  the message text                                         */
/*                                                                    */
/*                                                                    */
I!.__GetMessage: PROCEDURE expose (exposeList)
  parse arg msgNo , mP1, mP2, mP3, mP4, mP5, mP6, mP7, mP8, mP9

                    /* install a local error handler                  */
  SIGNAL ON SYNTAX Name I!.__GetMessage1

                    /* first check for an external GETMSG routine     */
                    /* try to call the user defined GetMsg routine    */
  if Global.__GetMsgRoutine <> '' then
  do
    interpret 'call "' || Global.__GetMsgRoutine || ,
                   '" Global.__BaseMsgNo+msgNo,,'   ,
                   ' mP1, mP2, mP3, mP4, mP5, mP6, mP7, mP8, mP9 '

                    /* the next statement is only executed, if the   */
                    /* interpret statement above didn't cause an     */
                    /* error                                         */


    return result   /* external routine found and executed, return    */
                    /* the result                                     */
  end /* if Global.__GetMsgRoutine <> '' then */

I!.__GetMessage1:
                    /* This code is only executed if either there's   */
                    /* no GetMsgRoutine defined or the call of the    */
                    /* GetMsgRoutine caused an error                  */

                    /* reinstall the error handler                    */
  SIGNAL ON SYNTAX

                    /* no external routine found or executed, use the */
                    /* builtin messages                               */

  j = MsgNo
  if MsgNo >= 99 then
    j = MsgNo - 77

  msgText = translate( word( msgStr.1, j ), ' ', '_' )

                    /* replace the placeholder with the values        */
  if pos( '%', msgText ) <> 0 then
    do j = 1 to 9
      pString = '%' || j

      do forever
        if pos( pString, msgText ) = 0 then
          leave
        parse var msgText part1 ( pString ) part2
        msgText = part1 || arg( j+1 ) || part2
      end /* do forever */

    end /* do j = 1 to 9 */

  if msgNo < 100 then
    return 'ERROR:' msgNo ':' msgText

                    /* the next statement is only executed if the     */
                    /* previous IF statement is false                 */
RETURN MsgText

/* ------------------------------------------------------------------ */
/* ----------- the following code is for developing only ------------ */

/**DEBUG** Delete this line before using the debugging routines!!!

/* ------------------------------------------------------------------ */
/* function: show all variables defined for the routine calling       */
/*           this routine.                                            */
/*                                                                    */
/* call:     ShowDefinedVariables {N} {,varMask} {,outpufFile}        */
/*                                                                    */
/* where:    N - no pause if the screen is full                       */
/*           varMask - mask for the variables                         */
/*           outputFile - write the variable list to this file        */
/*                                                                    */
/* returns:  nothing                                                  */
/*                                                                    */
/* note:     This routine needs the Dave Boll's DLL RXU.DLL!          */
/*           Be aware that the special REXX variables SIGL, RC and    */
/*           RESULT are changed if you call this routine!             */
/*                                                                    */
/*                                                                    */
ShowDefinedVariables:
  sdv.__dummy = trace('OFF')

  parse upper arg SDV.__pauseMode, SDV.__varMask, SDV.__outPut

  if SDV.__outPut <> '' then
    if SDV.__pauseMode = '' then
      SDV.__pauseMdoe = 'N'

                                /* install a local error handler      */
  signal on syntax name SDV.__RXUNotFound

                                /* load the necessary DLL function    */
  call rxFuncDrop 'RxVLIst'
  call rxFuncAdd 'RxVlist', 'RXU', 'RxVList'

  call rxFuncDrop 'RxPullQueue'
  call rxFuncAdd 'RxPullQueue', 'RXU', 'RxPullQueue'

                                /* create a queue for the variables   */
  SDV.__newQueue = rxqueue( 'create' )

                                /* the 'D' parameter of the RxVList   */
                                /* functions won't pause if the       */
                                /* screen is full                     */
  SDV.__thisRC = RxVList( SDV.__varMask, 'V' , SDV.__newQueue )

                                /* ignore local variables of this     */
                                /* routine                            */
  SDV.__thisRC = SDV.__thisRC

  call LineOut SDV.__outPut , '  ' || copies( 'Ä',76 )

  if SDV.__thisRC <> 0 then
  do

    call LineOut SDV.__outPut , '  Defined variable(s) and their values:'
    SDV.__i = 0

    do SDV.__n = 1 to SDV.__ThisRC
      if SDV.__i >= 23 & ,
         SDV.__pauseMode <> 'N' then
      do
        ADDRESS 'CMD' 'PAUSE'
        SDV.__i = 0
      end /* if */
      SDV.__varName = RxPullQueue( SDV.__newQueue, 'Nowait', 'SDV.__dummy' )
      SDV.__varValue = RxPullQueue( SDV.__newQueue, 'Nowait', 'SDV.__dummy' )

                                /* ignore local variables of this     */
                                /* routine                            */
      if left( SDV.__varName, 6 ) <> 'SDV.__' then
      do
        call LineOut SDV.__outPut , '     ' || SDV.__varName || ' = "' || SDV.__varValue || '"'
        SDV.__i = SDV.__i+1
      end /* if right( ... */

    end /* do */

                        /* delete the queue for the variables         */
    call rxqueue 'Delete', SDV.__newQueue
  end
  else
    call LineOut SDV.__outPut , '  No variables defined.'

  call LineOut SDV.__outPut , '  ' || copies( 'Ä',76 )

  call LineOut SDV.__outPut                                  

                        /* delete local variables                     */
  drop SDV.
RETURN ' '                                                  

                        /* error exit for ShowDefinedVariables        */
SDV.__RXUNotFound:
  call LineOut SDV.__outPut , 'ShowDefinedVariables: RXU.DLL not found'
RETURN 255

/* ------------------------------------------------------------------ */

   Delete this line before using the debugging routines!!!    **DEBUG**/
/* ------------------------------------------------------------------ */


