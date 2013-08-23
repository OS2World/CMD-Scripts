/*------------------------------------------------------------------*/
/* Run Java App  -- put jarfile.jar and any options for the app     */
/* in the "Parameters" field of the program object                  */
/* e.g. the program object for this script should be:               */
/* "path and file name" = location of this script                   */
/* "Parameters" = java_app.jar  java_app.init -v                    */
/* "working directory" = path to this script                        */
/* Just run this script from the same directory as the *.jar file   */
/*                                                                  */
/* Contact Cary at crenquis@pacbell.net if you have problems        */
/*------------------------------------------------------------------*/
versionstring = "Carys java_13.cmd ver 20020714"
crlf = '0D0A'X
jar_file=''
java_arg=''

rxload = RxFuncQuery('SysLoadFuncs')          /* load Rexx libs if            */
If rxload Then                                /* not loaded                   */
   Do
      Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
      Call sysloadfuncs
   End

/* Check to make sure that some parmeters were passed                      */
if arg()=0 then
   do
     Call usage
     exit
   end /* if */

/* Parse the arguments (Parameters) for the jarfile and any options        */
/* that may follow the jarfile -- params are stored in stem var argpart.   */
/* argpart.0 stores the number of argument elements                        */
Parse arg params                              /* pass the arg() to params     */
Call argparse params                          /* call the argparse procedure  */

/* Build the argument for java.exe                                         */
do j = 1 to argpart.0                         /* process the argparts         */ 
   java_arg = java_arg||' '||argpart.j        /* catentate the argparts into  */
                                              /* java_arg                     */
   if left(argpart.j,4) = '-jar' then do      /* test each argpart for the    */
                                              /* '-jar' flag                  */
      Parse var argpart.j jar_junk '-jar' jar_file;   /* store the argument   */
                                              /* following '-jar into jar_file*/ 
   end; /* if */   
end /* do */   

/* if no '-jar' flag was found in the argpart list then must have been     */ 
/* started with a double click on a .jar or started with an object         */
/* created with an earlier version of run_java                             */
if jar_file = '' then do
  java_arg = '-jar '||params;                 /* generate a java_arg - assumes*/
                                              /* that the arguement passed to */
					      /* this script is of the form:  */
					      /*x:\jarpth\jarfile.jar [jaropt]*/
  Parse var params jar_file ' ' jar_init;     /* Parse the arguments for the  */
                                              /* jarfile and any options that */
                                              /* may follow the jarfile       */ 
end; /* if */

/* find the location of the jarfile - this is used to set the classpath    */
jar_path = Filespec('D',jar_file) || Strip(Filespec('P',jar_file),'T','\')

/* Look for the location of Java131 in the os2.ini file                 */
/* Since most OS/2 users don't have java13x their default java, a          */
/* standard "java -fullversion" query doesn't work                         */
jpth = SysIni(,'Java131','USER_HOME')
if jpth = "ERROR:" then do                    /* Java131 not found            */
      say "Java131 not found";
      jpth = SysIni(,'Java13','USER_HOME');   /* look for Java13              */
      if jpth = "ERROR:" then do              /* Java13 not found             */
         say "Java13 not found -- require at least Java13";
         exit 1;
      end; /* then-do */
      else
         do
         jbase =getjavabase(jpth);
      end; /* else-do */
   end; /* then-do */
   else do
      jbase = getjavabase(jpth);
   end; /* else-do */

/* launch the app                                                          */
jbase ||'jre\bin\java.exe -cp '|| jar_path ||' '||java_arg

Exit 0

/* Parse the arg list -- separates the arguement into parts.  Separation   */
/* is made at eact occurance of ' -' in the arguement.                     */
/*     e.g. -Xsxm80 -jar e:\net\spambot.jar -v start                       */
/*          part1 = -Xsxmm80
            part2 = -jar e:\net\spambot.jar
	    part3 = -v start                                               */
argparse: procedure expose argpart.
Parse arg args
i=1
arg_tmp = ''
argpart.0 = 0
Parse var args argpart.i ' -' arg_tmp
do while arg_tmp \= '' 
   i=i+1;
   parse var arg_tmp argpart.i ' -' arg_tmp;
   argpart.i = '-'||argpart.i;
   argpart.0 = i;
end; /* do while */  
return argpart.

/* Where is java13x located                                                */
getjavabase: procedure
arg pth
parse upper var pth jp 'JRE' junk;            /* trunc path before "jre"      */
return jp

/* Return help message if there is no argument passed                      */
usage: procedure expose versionstring crlf
say crlf||versionstring||crlf
say "Usage: java_13 [java options] [-jar] jarpath\jarfile.jar [jar options]"crlf
say "java_13 is used to run java13x based programs"crlf
say "The only required parameter is a valid .jar file"
say "   e.g. e:\net\spambot\spambot.jar "crlf
say "  optional parameters:"
say "  java options:             any valid option(s) for java.exe"
say "     e.g. -Xmx86M "crlf
say "  -jar:                     optional if only parameter is the .jar file"crlf
say "  jar options:              any valid option(s) for the .jar file"
say "                            consult the documentation for the .jar file"
say crlf
return

