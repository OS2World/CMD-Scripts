/* REXX * OS2 * URLOPEN.CMD ***************************************************/
/* Purpous...:  Extension of the Open-Menu of URL-Objects                     */
/* Parameter.:  -, /h, <programURL>#<URL:>                                    */
/* Defaults..:  -                                                             */
/* Created...:  18.02.00, Norbert Kohl                                        */
/* Verson....:  0.1                                                           */
/******************************************************************************/

'@ECHO OFF'
'ECHO [47;31m'
'CLS'

PARSE ARG prg '#' datei

IF prg = '' then call create

IF prg = '/h' then do
   call exthelp
   EXIT(0)
end /* do */

IF datei = '' then call error
ELSE
/******************************************************************************/
excute:
/******************************************************************************/
DO zeilennr=1 BY 1 UNTIL LINES(datei)=0
   zeile=LINEIN(datei)
END

/* Ist filetyp (z.B. http://) angegeben? */
PARSE VAR zeile urlh ':/' urlz
IF urlz <> '' THEN DO
  'START' prg zeile
END
ELSE DO
  'START' prg 'http://' || zeile
END
EXIT(0)

/******************************************************************************/
create:
/******************************************************************************/
IF RxFuncQuery('SysLoadFuncs') THEN DO
   call rxFuncAdd "SysLoadFuncs", "REXXUTIL", "SysLoadFuncs"
   call SysLoadFuncs
END

wdir = DIRECTORY()

CALL help
CALL CharOut , "Press Y to continue creating a new Object"
IF translate( SysGetKey( "NOECHO" ) ) <> "Y" THEN EXIT(1)
SAY ''
SAY 'Please insert Titel'
SAY 'He will be displayed in the OPEN Submenu of the URL-Object'
PARSE PULL title

SAY 'Please insert Programmdirectory\name'
PARSE PULL prog

Class    = "WPProgram"
Setup    = "EXENAME=" || wdir ||"\URLOT.CMD;" ||,
              "PROGTYPE=WINDOWABLEVIO;" ||,
              "PARAMETERS=" || prog || "#%* ;" ||,
              "STARTUPDIR=" || FILESPEC("D",prog) || FILESPEC("P",prog) ||";" ||,
              "ASSOCTYPE=UniformResourceLocator,,;" ||,
              "TITLE=" || title || ";MINIMIZED=YES;NOPRINT=YES;MENUS=DEFAULT;" ||,
              "HIDEBUTTON=DEFAULT;MINWIN=DESKTOP;CCVIEW=DEFAULT;" ||,
              "DEFAULTVIEW=DEFAULT;OBJECTID=<urlot_" || title || ">;"
location = "<WP_CFG-URLOT>"


                        /* now create the objects                     */

if SysCreateObject( class       ,,
                     title       ,,
                     location    ,,
                     setup       ,,
                     "UPDATE" ) <> 1 then
    do
      say "Warning: Can not create the object"
    end /* if SysCreateObject( ... */
EXIT(0)

/******************************************************************************/
help:
/******************************************************************************/
'@CLS'
SAY ""
SAY "ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
SAY "บ The URLObjectTool will enhance the 'open'-menu of URL-Objects   บ"
SAY "บ                                                                 บ"
SAY "บ You will be able to start programs by the usual OS/2-way:       บ"
SAY "บ right MB -> open -> additional program                          บ"
SAY "บ                                                                 บ"
SAY "บ You will have to tell URLOT a title of the program              บ"
SAY "บ   (Example: Get files with WGet )                               บ"
SAY "บ and the path/programmname (programURL)                          บ"
SAY "บ   (Example: /C WGET.EXE -c )                                    บ"
SAY "บ                                                                 บ"
SAY "บ Call URLOT /h for extendet help                                 บ"
SAY "ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
SAY ""
RETURN

/******************************************************************************/
exthelp:
/******************************************************************************/
CALL help
'@PAUSE'
'@CLS'
SAY ""
SAY "ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
SAY "บ Usage of URLObjectTool:                                         บ"
SAY "บ                                                                 บ"
SAY "บ URLOT.CMD <options>                                             บ"
SAY "บ Options: none: URLOT shows first part of helpscreen and -after  บ"
SAY "บ                asking- goes on creating a new openmenu-item     บ"
SAY "บ                                                                 บ"
SAY "บ          /h:   this extended helpscreen                         บ"
SAY "บ                                                                 บ"
SAY "บ          <programURL>#<URL:>                                    บ"
SAY "บ                execute the <programURL> with the URL            บ"
SAY "บ                for example: URLOT netscape#http://www.leo.org   บ"
SAY "บ                                                                 บ"
SAY "ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ"
RETURN

/******************************************************************************/
error:
/******************************************************************************/
SAY 'This Object does not seem to have an URL'
EXIT(1)

