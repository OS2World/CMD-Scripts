/* Install Program References for Repeat.CMD */

call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject'

parse arg arguments                         /* Fetch command line parms */
arguments  = STRIP(arguments)
parse upper var arguments arguments_upcase  /* convert to upper case */

if (arguments='' | arguments='?' | arguments='/?') then
   do
     call Help
     exit 0
   end

curdir = directory()
newdir = directory(arguments_upcase)
parse upper var curdir curdir_upcase
parse upper var newdir newdir_upcase

if newdir_upcase = arguments_upcase then
  do
    say 'Found directory ''' || arguments || ''''
    newdir = directory(curdir)
  end
else
  do
    say 'Can''t find directory ''' || arguments || ''''
    call Help
    exit 0
  end

if newdir_upcase <> curdir_upcase then do
   copy Repeat.CMD arguments
end

If SysCreateObject("WPProgram",,
                   "Drag and drop a multimedia file here" || '0d'x || '0a'x ||,
                   "to play it continuously",,
                   "<WP_DESKTOP>",,
                   "EXENAME=PMREXX.EXE;PARAMETERS=" || arguments || "\Repeat.cmd file='%*'")  Then
   Say 'Program 1 has been created'

If SysCreateObject("WPProgram",,
                   "Drag and drop a multimedia file here" || '0d'x || '0a'x ||,
                   "to play it n times",,
                   "<WP_DESKTOP>",,
                   "EXENAME=PMREXX.EXE;PARAMETERS=" || arguments || "\Repeat.cmd file='%*' count=[How many times?]")  Then
   Say 'Program 2 has been created'

/*
** Exit, return code = 0.
*/
exit 0


/*  -- help --
** Display help text
*/
Help:
   say
   say 'This command copies Repeat.CMD to your MMOS2 directory'
   say 'and installs two Program References for it on your desktop.'
   say
   say 'Usage:'
   say
   say '        Install d:\dir'
   say
   say 'where'
   say '        d:\dir       Drive and directory in which MMOS2'
   say '                     is installed; e.g. C:\MMOS2'
return


