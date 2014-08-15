/* Color.CMD
   Written by Jack Tan
   May 17, 1993

   This REXX script sets the foreground and background colors
   Type "Color.CMD" for help

   Revision history:
      1.0   17 May 93   Initial program
                        Color foreground/background, use of "A on B",
                        "A B", "A", "on B"
      1.1   18 May 93   Environmental variable support, use of "on B" and "A"
                        now keeps previous value (via environmental variable)
      1.2   21 May 93   Corrected bug with background as PURPLE
      1.3    6 Aug 93   Code cleanup, user-definable color schemes
*/
"@Echo OFF"
VERSION        = "1.3"
DEFAULT_FG     = "GRAY"
DEFAULT_BG     = "BLACK"
env            = "OS2ENVIRONMENT"

/* Have the environmental variables been previously set?
   If not, then them now.  Default foreground/background
   is gray on black.  This is also the default NORMAL
   color scheme.
*/
if VALUE("TEXT_FG", , env)=="" then do
   call VALUE "TEXT_FG", DEFAULT_FG, env
   call VALUE "TEXT_BG", DEFAULT_BG, env
end  /* Do */
if VALUE("NORMAL_TEXT_FG", , env)=="" then do
   call VALUE "NORMAL_TEXT_FG", DEFAULT_FG, env
   call VALUE "NORMAL_TEXT_BG", DEFAULT_BG, env
end  /* Do */

oldForeground = VALUE("TEXT_FG", , env)
oldBackground = VALUE("TEXT_BG", , env)

/* Find the real prompt: discard old color escape
   sequence (if any) embedded in the prompt
*/
oldPrompt = VALUE("PROMPT", , env)
initPos = POS("$e", oldPrompt)
if initPos<>0 then do
   lastPos = POS("m", oldPrompt, initPos+2)
   oldPrompt = DELSTR(oldPrompt, initPos, LastPos-initPos+1)
end  /* Do */


/* Get the colors from the command line */
ARG arguments
if STRIP(arguments)=="" then
   label = ""
else
   label = WORD(arguments, WORDS(arguments))

/* No args; refresh the current settings */
if label=="" then do
   foreground = oldForeground
   background = oldBackground
end  /* Do */

/* Check for a user-defined label: Color <label> */
else if (WORDS(arg(1))=1) & (VALUE(label||"_TEXT_FG", , env)<>"") & (VALUE(label||"_TEXT_BG", , env)<>"") then do
   foreground = VALUE(label||"_TEXT_FG", , env)
   background = VALUE(label||"_TEXT_BG", , env)
end  /* Do */

/* Colors given on the command line */
else do
   parse value arguments with one two three .
   if one=="ON" then do              /* Color ON <bg> */
      foreground = oldForeground
      background = two
   end  /* Do */
   else do                          /* Color <fg> [ON] <bg>  or  Color <fg> */
      foreground = one
      select
         when two==""   then background = oldBackground   /* Color <fg>      */
         when two=="ON" then background = three        /* Color <fg> ON <bg> */
      otherwise
         background = two                                /* Color <fg> <bg> */
      end  /* select */
   end  /* Do */
end  /* Do */


/******************************/
/*                            */
/*  Set the foreground color  */
/*                            */
/******************************/

forestring = ""
if POS("BLINK", foreground)==1 then do
   foreground = SUBSTR(foreground, 6)
   forestring = "5;"||forestring
end  /* Do */
else
   forestring = "0;"||forestring
select
/*****************/
/*  Dark colors  */
/*****************/
   when foreground=="BLACK"       then forestring = forestring||"30"
   when foreground=="RED"         then forestring = forestring||"31"
   when foreground=="GREEN"       then forestring = forestring||"32"
   when foreground=="BLUE"        then forestring = forestring||"34"
   when (foreground=="PURPLE") | (foreground=="MAGENTA")
                                 then forestring = forestring||"35"
   when foreground=="CYAN"        then forestring = forestring||"36"
   when (foreground=="GREY") | (foreground=="GRAY") | (foreground=="NORMAL")
                                 then forestring = forestring||"37"
/******************/
/*  Light colors  */
/******************/
   when foreground=="LIGHTRED"    then forestring = forestring||"1;31"
   when foreground=="LIGHTGREEN"  then forestring = forestring||"1;32"
   when (foreground=="YELLOW") | (foreground=="LIGHTYELLOW")
                                 then forestring = forestring||"1;33"
   when foreground=="MEDBLUE"     then forestring = forestring||"1;34"
   when foreground=="PINK"        then forestring = forestring||"1;35"
   when foreground=="LIGHTBLUE"   then forestring = forestring||"1;36"
   when (foreground="WHITE") | (foreground="LIGHTWHITE") | (foreground="BRIGHTWHITE")
                                  then forestring = forestring||"1;37"
   when foreground==""            then do
                                    SAY "No foreground color specified"
                                    exit 1
                                 end  /* Do */
   otherwise
      SAY "Unrecognized foreground color:  "foreground
      exit 1
end  /* select */


/******************************/
/*                            */
/*  Set the background color  */
/*                            */
/******************************/
backstring=""
select
   when background=="BLACK"       then backstring = backstring||"40"
   when background=="RED"         then backstring = backstring||"41"
   when background=="GREEN"       then backstring = backstring||"42"
   when background=="BROWN"       then backstring = backstring||"43"
   when background=="BLUE"        then backstring = backstring||"44"
   when (background=="PURPLE") | (background=="MAGENTA")
                                  then backstring = backstring||"45"
   when background=="CYAN"        then backstring = backstring||"46"
   when background=="WHITE"       then backstring = backstring||"5;47"
   when (background=="GREY") | (background=="GRAY")
                                  then backstring = backstring||"47"
   when background==""            then do
                                    SAY "No background color specified"
                                    exit 1
                                 end  /* Do */
   otherwise
      SAY "Unrecognized background color:  "background
      exit 2
end  /* select */

if backstring=="" then
   colorstring = "["||forestring||"m"
else
   colorstring = "["||forestring";"backstring"m"

/* Change the environmental variables
   TEXT_FG, TEXT_BG, and PROMPT
*/
call VALUE "TEXT_FG", foreground, env
call VALUE "TEXT_BG", background, env
call VALUE "PROMPT", "$e"colorstring||oldPrompt, env

if label=="" then
   call printHelp

do i=1 to ARG()
   if WORD(arguments, i)="/?" then
      call printHelp
end /* do */

SAY D2C(27)||colorstring
exit 0

printHelp: procedure expose VERSION
   gap = "   "
   SAY
   SAY gap||"Color.CMD, version "VERSION
   SAY gap||"Written by Jack Tan"
   SAY gap||"Syntax:  Color <foreground> [[ON] <background>]"
   SAY gap||"         Color ON <background>"
   SAY gap||"         Color <label>"
   SAY
   SAY gap||"Valid foreground colors:"
   SAY gap||"   BLACK          GRAY (GREY)              MEDBLUE            GREEN"
   SAY gap||"   BLUE           PURPLE (MAGENTA)         LIGHTBLUE          LIGHTGREEN"
   SAY gap||"   RED            LIGHTRED                 PINK               CYAN"
   SAY gap||"   WHITE (BRIGHTWHITE/LIGHTWHITE)          YELLOW"
   SAY gap||"   Foreground colors may be prefixed with BLINK (e.g., BLINKRED)"
   SAY gap||"   In a window, BLINK- may cause the background to become a LIGHT- color"
   SAY
   SAY gap||"Valid background colors:"
   SAY gap||"   BLACK          GRAY (GREY)              RED                GREEN"
   SAY gap||"   BLUE           PURPLE (MAGENTA)         CYAN               BROWN"
   SAY gap||"   WHITE (uses BLINK)"
   SAY
   SAY gap||"If the environmental variables 'label_TEXT_FG' and 'label_TEXT_BG'"
   call charout , gap||"are set, the variable values will be used for the colors."
return
