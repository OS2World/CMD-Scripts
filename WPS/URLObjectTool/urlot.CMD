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
SAY "浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様�"
SAY "� The URLObjectTool will enhance the 'open'-menu of URL-Objects   �"
SAY "�                                                                 �"
SAY "� You will be able to start programs by the usual OS/2-way:       �"
SAY "� right MB -> open -> additional program                          �"
SAY "�                                                                 �"
SAY "� You will have to tell URLOT a title of the program              �"
SAY "�   (Example: Get files with WGet )                               �"
SAY "� and the path/programmname (programURL)                          �"
SAY "�   (Example: /C WGET.EXE -c )                                    �"
SAY "�                                                                 �"
SAY "� Call URLOT /h for extendet help                                 �"
SAY "藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様�"
SAY ""
RETURN

/******************************************************************************/
exthelp:
/******************************************************************************/
CALL help
'@PAUSE'
'@CLS'
SAY ""
SAY "浜様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様�"
SAY "� Usage of URLObjectTool:                                         �"
SAY "�                                                                 �"
SAY "� URLOT.CMD <options>                                             �"
SAY "� Options: none: URLOT shows first part of helpscreen and -after  �"
SAY "�                asking- goes on creating a new openmenu-item     �"
SAY "�                                                                 �"
SAY "�          /h:   this extended helpscreen                         �"
SAY "�                                                                 �"
SAY "�          <programURL>#<URL:>                                    �"
SAY "�                execute the <programURL> with the URL            �"
SAY "�                for example: URLOT netscape#http://www.leo.org   �"
SAY "�                                                                 �"
SAY "藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様�"
RETURN

/******************************************************************************/
error:
/******************************************************************************/
SAY 'This Object does not seem to have an URL'
EXIT(1)

