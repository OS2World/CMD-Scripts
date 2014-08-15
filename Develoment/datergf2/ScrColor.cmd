/*
program: ScrColor.cmd
type:    REXXSAA-OS/2
purpose: set default ANSI screen colors and allow REXX-programs to query them
         (used e.g. by SHOWINI, CRONRGF, ATRGF)
version: 1.0.0.0.1 :)
date:    1993-09-20
changed: 1993-11-17, merely added documentation, no functional changes
author:  Rony G. Flatscher,
         Wirtschaftsuniversit„t/Vienna
         Rony.Flatscher@wu-wien.ac.at

usage:   ScrColor [some string]
         - if called from the command line the default background and
           foreground colors are set, additionally all defined colors
           are shown;
           if any argument is given on the command line, the
           ANSI-escape-sequences are shown in addition (e.g. "ScrColor ?");

           e.g. add to your OS/2-CMD-WPS-objects the parameter: "/K ScrColor.CMD"
           or change systemwide (change CONFIG.SYS):

               SET OS2_SHELL=C:\OS2\CMD.EXE /K SCRCOLOR.CMD

         - if called as a function, the entire set of defined colors is
           returned in a parsable string (see e.g. rxDecode.CMD, how a REXX-program
           can retrieve the presently active colors)

All rights reserved, copyrighted 1993 no guarantee that it works without
errors, etc. etc.

donated to the public domain granted that you are not charging anything
(money etc.) for it and derivates based upon it, as you did not write it,
etc. if that holds you may bundle it with commercial programs too

Please, if you find an error, post me a message describing it, I will
try to fix and rerelease it to the net.

**************

An excerpt from ANSI-escape-sequences as explained in:

 OS/2 Frequently Asked Questions List
 User's Edition
 Release 2.1C
 August 28, 1993
 Compiled by Timothy F. Sipples

For changes, suggestions, or additions please mail
sip1@kimbark.uchicago.edu or write:

  ESC[#;#;....;#m               Set display attributes where # is
                                 0 for normal display
                                 1 bold on
                                 4 underline (mono only)
                                 5 blink on
                                 7 reverse video on
                                 8 nondisplayed (invisible)
                                30 black foreground
                                31 red foreground
                                32 green foreground
                                33 yellow foreground
                                34 blue foreground
                                35 magenta foreground
                                36 cyan foreground
                                37 white foreground
                                40 black background
                                41 red background
                                42 green background
                                43 yellow background
                                44 blue background
                                45 magenta background
                                46 cyan background
                                47 white background

remark: one can set a list of screen-attributes; if so, they need to be
        delmited by a semi-colon (;); after the last sequence a little "m"
        has to be attached to tell ANSI.SYS that colors are meant
*/

ESC    = '1B'x || "["   /* define ANSI-ESCape character */

/* ANSI-values for colors */

black   = 0
red     = 1
green   = 2
yellow  = 3
blue    = 4
magenta = 5
cyan    = 6
white   = 7

/* ANSI-values for fore-/background */
foreground = 30         /* add color, e.g. 30 + 2 = 32 ==> green foreground */
background = 40         /* add color, e.g. 40 + 7 = 47 ==> white background */

/* additional ANSI-values which work on VGA */
normal    = 0           /* reset screen to white on black */
bold      = 1
/************************** end of ANSI-information **************************/



/*******************************************************/
/* default settings for WHITE TEXT on BLACK BACKGROUND */
/*******************************************************/

screen_normal  = normal || ";" || foreground + white  || ";" || background + black
screen_inverse = normal || ";" || foreground + black  || ";" || background + white
text_normal    = screen_normal
text_info      = screen_normal || ";" ||                foreground + cyan
text_highlight = screen_normal || ";" ||                foreground + yellow
text_alarm     = screen_normal || ";" || bold || ";" || foreground + red
/* inverse colors */
text_normal_inverse    = screen_inverse
text_info_inverse      = screen_inverse || ";" ||                foreground + cyan
text_highlight_inverse = screen_inverse || ";" ||                foreground + green
text_alarm_inverse     = screen_inverse || ";" || bold || ";" || foreground + red
/*******************************************************/



/*******************************************************/
/* default settings for BLACK TEXT on WHITE BACKGROUND */
/*******************************************************/

screen_normal  = normal || ";" || foreground + black  || ";" || background + white
screen_inverse = normal || ";" || foreground + white  || ";" || background + black
text_normal    = screen_normal
text_info      = screen_normal || ";" || bold || ";" || foreground + blue
text_highlight = screen_normal || ";" ||                foreground + green
text_alarm     = screen_normal || ";" || bold || ";" || foreground + red
/* inverse colors */
text_normal_inverse    = screen_inverse
text_info_inverse      = screen_inverse || ";" || bold || ";" || foreground + green
text_highlight_inverse = screen_inverse || ";" || bold || ";" || foreground + cyan
text_alarm_inverse     = screen_inverse || ";" || bold || ";" || foreground + red
/*******************************************************/




/*                        CHANGE COLORS FROM HERE                            */
/*                                                                           */
/*                  ||||||||||||||||||||||||||||||||||||                     */
/*                  VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV                     */

/****************** change according to your preferences *********************/
/* attention: the following settings take effect !                           */
/*            just copy the default you wish and change the colors           */
/*****************************************************************************/

/*******************************************************/
/* default settings for WHITE TEXT on BLACK BACKGROUND */
/*******************************************************/

screen_normal  = normal || ";" || foreground + white  || ";" || background + black
screen_inverse = normal || ";" || foreground + black  || ";" || background + white
text_normal    = screen_normal
text_info      = screen_normal || ";" ||                foreground + cyan
text_highlight = screen_normal || ";" ||                foreground + yellow
text_alarm     = screen_normal || ";" || bold || ";" || foreground + red
/* inverse colors */
text_normal_inverse    = screen_inverse
text_info_inverse      = screen_inverse || ";" ||                foreground + cyan
text_highlight_inverse = screen_inverse || ";" ||                foreground + green
text_alarm_inverse     = screen_inverse || ";" || bold || ";" || foreground + red
/*******************************************************/







/*******************************************************************************/
/* add ESCape to begin and "m" to the end to complete the ANSI-Escape-sequence */
screen_normal      = ESC || screen_normal       || "m"
screen_inverse     = ESC || screen_inverse      || "m"
text_normal        = ESC || text_normal         || "m"
text_info          = ESC || text_info           || "m"
text_highlight     = ESC || text_highlight      || "m"
text_alarm         = ESC || text_alarm          || "m"
text_normal_inverse    = ESC || text_normal_inverse     || "m"
text_info_inverse      = ESC || text_info_inverse       || "m"
text_highlight_inverse = ESC || text_highlight_inverse  || "m"
text_alarm_inverse     = ESC || text_alarm_inverse      || "m"

PARSE SOURCE . called_as .

IF called_as = "COMMAND" THEN           /* called from command-line ? */
DO
   CALL CHAROUT ,screen_normal          /* set screen */
   "Cls"                                /* Clear Screen via OS/2's CMD.EXE */
   IF ARG(1) <> "" THEN                 /* if argument given, then show escape sequences */
   DO
      SAY
      CALL CHAROUT ,screen_normal          /* set screen */
      SAY RIGHT("screen_normal <ESC", 40)  || SUBSTR(screen_normal, 2)  || ">"
      CALL CHAROUT ,text_normal
      SAY RIGHT("text_normal <ESC", 40)    || SUBSTR(text_normal, 2)    || ">"
      CALL CHAROUT ,text_info
      SAY RIGHT("text_info <ESC", 40)      || SUBSTR(text_info, 2)      || ">"
      CALL CHAROUT ,text_highlight
      SAY RIGHT("text_highlight <ESC", 40) || SUBSTR(text_highlight, 2) || ">"
      CALL CHAROUT ,text_alarm
      SAY RIGHT("text_alarm <ESC", 40)     || SUBSTR(text_alarm, 2)     || ">"
      CALL CHAROUT ,screen_inverse
      SAY RIGHT("screen_inverse <ESC", 40) || SUBSTR(screen_inverse, 2) || ">"
      CALL CHAROUT ,screen_normal

      CALL CHAROUT ,text_normal_inverse
      SAY RIGHT("text_normal_inverse <ESC", 40) || SUBSTR(text_normal_inverse, 2) || ">"
      CALL CHAROUT ,text_info_inverse
      SAY RIGHT("text_info_inverse <ESC", 40) || SUBSTR(text_info_inverse, 2) || ">"
      CALL CHAROUT ,text_highlight_inverse
      SAY RIGHT("text_highlight_inverse <ESC", 40) || SUBSTR(text_highlight_inverse, 2) || ">"
      CALL CHAROUT ,text_alarm_inverse
      SAY RIGHT("text_alarm_inverse <ESC", 40) || SUBSTR(text_alarm_inverse, 2) || ">"
   END
   CALL CHAROUT ,screen_normal          /* set screen */
END
ELSE RETURN screen_normal screen_inverse,
            text_normal text_info,
            text_highlight text_alarm,
            text_normal_inverse text_info_inverse,
            text_highlight_inverse text_alarm_inverse

