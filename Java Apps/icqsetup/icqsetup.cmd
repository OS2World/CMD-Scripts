/*    Setup script for ICQjava under OS/2

      Creates OS/2 desktop object for ICQjava
*/

Call Init

Setup:
call getkeypress
if proceed = "QUIT" then signal end
if proceed = "NO" then signal setup

Lets_Go:
say red||'     * Please wait while desktop objects are created.'||white
say ' '

say green||'     Creating WPS objects'||white
call CreateObjects

End:
say ' '
say magenta||'     ALL DONE!'||white
say ' '



return

/* ===================================================== */
/*               procedures below here.                  */
/* ===================================================== */

Init :

  call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  call SysLoadFuncs

/* Define Variables */
ICQhome=directory()
JavaHome='C:\Java11'     /* Add search code to locate this */
ClassPath=JavaHome'\lib\classes.zip'

/*  Icons for ICQjava  (change on line below)                            */
/*      ICQjava.ico  is the Flower with JAVA                             */
/*      ICQjava2.ico is the Flower going round the globe   (default)     */
ICQicon = ICQhome'\icqjava2.ico'

/* definitions for ANSI Colors */

red = '1B'x || '[31;40m' || '1B'x || '[1m'
green = '1B'x || '[32;40m' || '1B'x || '[1m'
yellow = '1B'x || '[33;40m' || '1B'x || '[1m'
blue = '1B'x || '[34;40m' || '1B'x || '[1m'
magenta = '1B'x || '[35;40m' || '1B'x || '[1m'
cyan = '1B'x || '[36;40m' || '1B'x || '[1m'
darkcyan = '1B'x || '[0m' || '1B'x || '[36;40m'
white = '1B'x || '[0m'

/* trace ?r */
return

getkeypress:
call greeting
say ' '
key = SysGetKey(NOECHO)
say ' '
keyhex = C2X(key)
if keyhex='0D'
   then  /* if key is RETURN */
     proceed = "YES"
   else
    do
      key = translate(key)
      if key = 1
         then
           do
             Say '    Enter Full path to ICQjava, without the trailing \'
             Say '    ie  c:\ICQjava     or  c:\internet\ICQjava'
             Say ' '
             result=charout(,'    Path : ')
             string = '                                                                                '
             Parse Upper Pull string .
             dir = string
             Call Directory_Check
             ICQhome=dir
           end
         else
           if key = 2
              then
                do
                Say '    Enter the directory name for your Java 1.1.4 or higher installation.'
                Say '    IE. c:\java11  with NO trailing \'
                Say ' '
                result=charout(,'    Java Path : ')
                string = '                                                                                '
                Parse Pull string .
                JavaHome = String
                ClassPath = JavaHome'\lib\classes.zip'
                end
              else
                if key = 'Q'
                   then
                     proceed = "QUIT"
    end
return

greeting:

call SysCls
Say ' '
Say ' '
say blue||'     ICQjava OS/2 Desktop Installation.'
say ' '
Say cyan||'     This Script will will create a ICQjava Desktop Object for you.'
Say ' '
Say green||'     Current Settings for installation :'
Say ' '
Say green||'        1) ICQjava Home : '||yellow||ICQhome
Say green||'        2)    Classpath : '||yellow||ClassPath
Say ' '
Say cyan||'     Press Enter to Install with above Settings, or # to change. Q to Quit.'||white
proceed = "NO"
return

Directory_Check:
       /* Check the DRIVE exists */
       testdrive=substr(dir,1,2)
       info = SysDriveInfo(testdrive)
       if info = ''
         then /* No Drive, then lets go back for a new KEY Press */
           do
             say '     Destination Drive Doesn'"'"'t Exist.'
             say '     Resetting to current path'
             dir = directory()
             say '     Press any key to continue'
             key = SysGetKey()
           end
         else
           do
             /* in case user entered a trailing /  Strip it. */
             dir = strip(dir,'T','/')
             dir = strip(dir,'T','\')
           end
return

CreateObjects:
/*
REXX has a BUGLET.  What happens is that if a ; appears in a string that is
used in the setup part of SysCreateObject.  The ; is treated as a divider
for the parts of the setup.  This causes the string to be truncated at the
;.  As a result the sting below is using a ? instead, and the user must
REPLACE the ? with a ; in the object created on the desktop.  If anyone
comes up with a way to create it with the ;. I would very much like to know
about HOW.

prcatt@netrover.com
*/
prgname = javahome'\bin\javaPM.exe'
ICQparms = '-classpath 'ClassPath'^;'ICQhome'\ICQ.jar Mirabilis.ICQ.NetAware.CNetAwareApp -path 'ICQhome

          If SysCreateObject('WPProgram', 'ICQ Java', '<WP_DESKTOP>', 'EXENAME='prgname';STARTUPDIR='ICQhome';PROGTYPE=PM;ICONFILE='icqicon';PARAMETERS='ICQparms, 'REPLACE')  Then
          do
               Say '     Program object has been created'
          end
          Else
               Say '     * Could not create program object'

/* create updated icq.cmd file as alternate method */

DestFile = 'icq.cmd'
'@del ' DestFile
SAY '     Writing Updated Version of' DestFile

call lineout DestFile, 'set classpath='||javahome||'\lib\classes.zip'
call lineout DestFile, 'set ICQ_HOME='||ICQhome
call lineout DestFile, javahome||'\bin\javapm -classpath %CLASSPATH%;%ICQ_HOME%\ICQ.jar Mirabilis.ICQ.NetAware.CNetAwareApp -path %ICQ_HOME%'
call stream  DestFile, 'command', 'close'

return

