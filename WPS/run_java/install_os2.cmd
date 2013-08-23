/*Create Java Object Install*/
/* Just copy the install_os2.cmd, create_jv1x.cmd, create_jv1x.ico,
   java_1x.cmd, and java_1x.ico files to a directory and run
   install_os2.cmd to create program objects on Your Desktop.
*/


call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs
jv_ver=5
current = directory()

Call getjavas jv_ver
say "jv_ver = "||jv_ver

if jv_ver = 5 then do
   say "java 1.3 or java 1.4 not found";
   exit;
   end; /* if-then */

if jv_ver = 3 then do
   Call java13 current;
   Call java14 current;
   Call runjar("query") current;
   end;
   else
   if jv_ver = 1 then do
      Call java13 current;
      Call runjar("java_13") current;
   end;
   else if jv_ver = 2 then do
      Call java14 current;
      Call runjar("java_14") current;
   end; /* else-if */

Exit 0

java13: procedure expose current
title = "Create Java13 Object"
classname = 'WPProgram'
location = '<WP_DESKTOP>'
PGMname = current'\create_jv13.cmd'
ICNname = current'\create_jv13.ico'
OBJid = '<create_jv13>'
parms ='%*'

setup = 'OBJECTID='OBJid';EXENAME='PGMname';STARTUPDIR='current';ICONFILE=',
        ICNname';PARAMETERS='parms';MINIMIZED=YES;MINWIN=HIDE'
rc=SysCreateObject(classname,title,location,setup,replace)

if rc then say "Java13 Installation complete."
   else say "Java13 Installation failed!!!"
return /* java13 */

java14: procedure expose current
title = "Create Java14 Object"
classname = 'WPProgram'
location = '<WP_DESKTOP>'
PGMname = current'\create_jv14.cmd'
ICNname = current'\create_jv14.ico'
OBJid = '<create_jv14>'
parms ='%*'

setup = 'OBJECTID='OBJid';EXENAME='PGMname';STARTUPDIR='current';ICONFILE=',
        ICNname';PARAMETERS='parms';MINIMIZED=YES;MINWIN=HIDE'
rc=SysCreateObject(classname,title,location,setup,replace)

if rc then say "Java14 Installation complete."
   else say "Java14 Installation failed!!!"
return /* java14 */

runjar: procedure expose current
Parse arg jvers ' ' junk;

if jvers = "query" then do
   say ;
   say "Both java13 and java14 are installed.";
   say "Which version do you want to associate with .jar files?";
   say "Enter:  (e.g. 1 <enter>)";
   say "1 for java13";
   say "2 for java14";
   pull jq_ver;
   if jq_ver = 1 then jvers = "java_13";
   if jq_ver = 2 then jvers = "java_14";
end; /* if-then */
say "jversion jar = "||jvers
title = "Run Jars"
classname = 'WPProgram'
location = '<WP_DESKTOP>'
PGMname = current||'\'||jvers||'.cmd'
ICNname = current||'\jar_run.ico'
OBJid = '<jar_run>'
parms = '%*'
assoc = '*.jar,.jar,jar'
setup = 'OBJECTID='OBJid';EXENAME='PGMname';STARTUPDIR='current';ICONFILE=',
        ICNname';PARAMETERS='parms';ASSOCFILTER='assoc';MINIMIZED=YES;MINWIN=HIDE'

rc=SysCreateObject(classname,title,location,setup,replace)

if rc then say "RunJars Installation complete."
   else say "RunJars Installation failed!!!"
return /* runjars */


/* Where is java1x located                                                   */
getjavas: procedure expose jv_ver
jv13=1
jv14=2
jpth = SysIni(,'Java131','USER_HOME')
if jpth = "ERROR:" then do                    /* Java131 not found            */
      say "Java131 not found";
      jpth = SysIni(,'Java13','USER_HOME');   /* look for Java13              */
      if jpth = "ERROR:" then do              /* Java13 not found             */
         say "Java13 not found";
         jv13=0;
      end; /* then-do */
end /* then-do */

jver = SysIni(,'OS2 Kit for Java','CurrentVersion')
jpth = SysIni(,'OS2 Kit for Java',jver)
if jpth = "ERROR:" then do                    /* Java14 runtime not found     */
      say "Java14 runtime not found";
      jver = SysIni(,'OS2 Kit for Java SDK','CurrentVersion')
      jpth = SysIni(,'OS2 Kit for Java SDK',jver);   /* look for Java14 SDK   */
      if jpth = "ERROR:" then do              /* Java14 SDK not found         */
         say "Java14 not found";
         jv14=0;
      end; /* then-do */
end /* then-do */

jv_ver = jv13 + jv14
say "jv total = "||jv_ver
return jv_ver
