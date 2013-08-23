/*Java14 object creator*/
/*------------------------------------------------------------------*/
/* Just copy the create_jv13.cmd, install.cmd, java_14.cmd, 
   and generic_java.ico files to a directory and run install.cmd.
   This will create a "Java Object" program file on your Desktop.
   Now, all you have to do is drop a .jar file on the "Java Obect"
   and it will create a program object for the .jar file.
   Initially, the new program object for the .jar file will have a
   generic icon -- you can change it to whatever is appropriate for
   the app.
   Your java app may also require additional commands to follow the
   .jar file -- just add these after the .jar file entry in the "Parameters"
   field of the new program object.
   e.g.
      Parameters
          e:\net\spambot\spambot.jar
      change it to
          e:\net\spambot\spambot.jar -v start
  refer to the documentation for your java app for such required
  options.*/
/*------------------------------------------------------------------*/


call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

current = directory()

Parse arg filename                            /* get the contents of the arg */ 

say 'the filename is ' || filename

jar_path = Filespec('D', filename) || Strip(Filespec('P', filename), 'T', '\')
jar_file = Filespec('N', filename)
Parse var jar_file app_name '.jar' junk   /* everything after .jar is junked */   
app_obj_id = 'jv14_'||app_name
app_name = app_name||"__jv14"

say 'The jar path is ' || jar_path            /* for debug purposes */
say 'The jar file is ' || jar_file            /* for debug purposes */
say 'The current dir is ' || current          /* for debug purposes */
say 'The program name will be ' || app_name   /* for debug purposes */
say 'The object id will be ' || app_obj_id    /* for debug purposes */


title = app_name
classname = 'WPProgram'
location = '<WP_DESKTOP>'
PGMname = current||'\java_14.cmd'
ICNname = current||'\generic_java.ico'
OBJid = '<' || app_obj_id || '>'
parms = '-jar '||filename

setup = 'OBJECTID='OBJid';EXENAME='PGMname';STARTUPDIR='jar_path';ICONFILE=',
        ICNname';PARAMETERS='parms';MINIMIZED=YES;MINWIN=HIDE'

rc=SysCreateObject(classname,title,location,setup,replace)

if rc then say "Installation complete."
   else say "Installation failed!!!"


