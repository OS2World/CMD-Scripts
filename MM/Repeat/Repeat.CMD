/*-----------------------------------------------------------------------------

  Name:                   REPEAT.cmd

  OS/2 REXX command file that uses MultiMedia REXX functions
  to play a file a certain number of times (or continuously).

 -----------------------------------------------------------------------------*/

address cmd      /* Send commands to OS/2 command processor.  */
signal on error   /* When commands fail, call "error" routine. */

trace off
/*trace ?r*/

parse arg arguments        /* Fetch command line parms */
arguments = STRIP(arguments)

if (arguments='' | arguments='?' | arguments='/?') then
   do
     call Help
     exit 0
   end

/****** Special argument parsing routine *******

        Examine the argument string character by character:
        extract the individual arguments, considering
        strings delimited by single- or double-quote characters as a unit.
        This is needed to accommodate filenames with spaces in them.
*******/

n   = 0       /* counts # of arguments */
pos = 1       /* counts characters in the argument string */
if LENGTH(arguments) > 0 then do
  n = 1
  arg.n = ''  /* Results in arg.1, arg.2, ... */

  do while pos <= LENGTH(arguments)
    char = SUBSTR(arguments, pos, 1)

    if (char = '"') | (char = '''') then do    /* Find corresponding ending delimiter */
      delimiter = char

      do FOREVER   /* until delimiter encountered not directly followed by another delimiter */
        do FOREVER /* until delimiter encountered */
          pos = pos + 1
          if pos > LENGTH(arguments) then LEAVE
          char = SUBSTR(arguments, pos, 1)
          if char = delimiter then LEAVE
          arg.n = arg.n || char
        end
        if pos > LENGTH(arguments) then LEAVE   /* End of string encountered without ending delimiter */
        pos = pos + 1                           /* Skip ending delimiter */
        if pos > LENGTH(arguments) then LEAVE   /* End of string encountered */
        char = SUBSTR(arguments, pos, 1)        /* Get character after ending delimiter */
        if char <> delimiter then LEAVE         /* If two delimiters in a row, continue... */
        arg.n = arg.n || char                   /* ...including one delimiter in the argument */
      end

      ITERATE
    end

    if char = ' ' then do
      n = n + 1
      arg.n = ''
      do until (pos > LENGTH(arguments)) | (SUBSTR(arguments, pos, 1) <> ' ')
        pos = pos + 1
      end
      ITERATE
    end

    arg.n = arg.n || char
    pos = pos + 1
  end
end

do i = n + 1 to 6
   arg.i = ''
end

parse var arg.1 arg1a'='arg1b
parse var arg.2 arg2a'='arg2b
parse var arg.3 arg3a'='arg3b
parse var arg.4 arg4a'='arg4b
parse var arg.5 arg5a'='arg5b
parse var arg.6 arg6a'='arg6b

/* initialize variables */
FILE=''
FROM=''
TO=''
DEV=''
TIMEFMT=''
COUNT=''

/* Set the variables. */
call keyword arg1a, arg1b
call keyword arg2a, arg2b
call keyword arg3a, arg3b
call keyword arg4a, arg4b
call keyword arg5a, arg5b
call keyword arg6a, arg6b

/* Load the DLL, initialize MCI REXX support */
rc = RXFUNCADD('mciRxInit','MCIAPI','mciRxInit')
InitRC = mciRxInit()
MciCmd = 'open'

/*
** Check to see if the FILE && DEV variables are valid.
*/
     if FILE<>'' then
        do
          if DEV<>'' then
             MciCmd = MciCmd '"'||FILE||'"' 'type' DEV
          else
             MciCmd = MciCmd '"'||FILE||'"'
        end
     else if DEV<>'' then
        MciCmd = MciCmd DEV
     else
           do
             call Help
             exit 0
           end

/*
** Append the rest of the command line.
*/
    MciCmd = MciCmd 'alias rexxalias wait'

/*
** Issue the open command.
*/
    MacRC = SendString(MciCmd)
     if MacRC <> 0 then signal ErrExit
     else
     do
       if DEV='' then    /* device not specified */
         do     /* determine the device type */
          MacRC = SendString("capability rexxalias device type wait")
          if MacRC <> 0 then
              do
                 junk = SendString("close rexxalias wait")
                 signal ErrExit
              end
         end
       else   /* set the device specified as the device type */
         RetSt = DEV

       /* If a wave file is to be played then do a status length */
       /* to determine if the wave file exists.  A wave file is  */
       /* the only type of device that if it doesn't exist and   */
       /* you play it, it won't come back as file not found      */
       if TRANSLATE(RetSt) = 'WAVEAUDIO' then
         do
            MacRC = SendString("status rexxalias length wait")      /* If length is 0 no file exists */
             if MacRC <> 0 then
              do
                 junk = SendString("close rexxalias wait")
                 signal ErrExit
              end
             if RetSt = 0 then
              do
                 junk = SendString("close rexxalias wait")
                 ErrRC = 70555
                 MacRC = mciRxGetErrorString(ErrRC, 'ErrStVar')
                 say 'mciRxGetErrorString('ErrRC') =' ErrStVar
                 signal ErrExit
              end
         end
     end

/*
** Exercise mciRxGetDeviceID function
*/
DeviceID = mciRxGetDeviceID(""rexxalias"")

/*
**  Check to see if a time format was given.
*/
if TIMEFMT <> '' then
do
    MciCmd = 'set rexxalias time format' TIMEFMT 'wait'
    MacRC = SendString(MciCmd)
     if MacRC <> 0 then
        do
         junk = SendString("close rexxalias wait")
         signal ErrExit
        end
end

/*
** Formulate the play command.
*/
MciCmd = 'play rexxalias'

/*
** check to see if an origin was set.
*/
 if FROM<>'' then
        MciCmd = MciCmd 'from' FROM
 else   MciCmd = MciCmd 'from 1'

/*
** check to see if a terminating point was given.
*/
 if TO<>'' then
        MciCmd = MciCmd 'to' TO

/*
** append a wait onto the end of the play string.
*/
MciCmd = MciCmd 'wait'

/*
** actually send the play string.
*/

do while (COUNT = '') | (COUNT > 0)
   MacRC = SendString(MciCmd)
     if MacRC <> 0 then
        do
         junk = SendString("close rexxalias wait")
         signal ErrExit
        end
     if COUNT <> '' then COUNT = COUNT - 1
end

/*
** close the instance.
*/
MacRC = SendString("close rexxalias wait")
if MacRC <> 0 then signal ErrExit

/*
** Exit, return code = 0.
*/
exit 0

/*   --- SendString --
** Call DLL function.  Pass the command to process and the
** name of a REXX variable that will receive textual return
** information.
*/
SendString:
   arg CmndTxt
   /* Last two parameters are reserved, must be set to 0           */
   /* Future use of last two parms are for notify window handle    */
   /* and userparm.                                                 */
   MacRC = mciRxSendString(CmndTxt, 'RetSt', '0', '0')
   if MacRC<>0 then
      do
      ErrRC = MacRC
      say 'MciCmd=' CmndTxt
      say 'Err:mciRxSendString RC=' ErrRC RetSt
      MacRC = mciRxGetErrorString(ErrRC, 'ErrStVar')
      say 'mciRxGetErrorString('ErrRC') =' ErrStVar
      MacRC = ErrRC /* return the error rc */
      end
   return MacRC

/* -- keywords --
**
** Parse the arguments according to the keywords.
*/
keyword:
        arg key, value
        if key='FILE' then
            FILE=value
        else if key='DEV' then
            DEV=value
        else if key='FROM' then
             FROM=value
        else if key='TO' then
              TO=value
        else if key='TIMEFMT' then
                TIMEFMT=value
        else if key='COUNT' then
                COUNT=value

return

/*  -- help --
** Display help text
*/
Help:
   say
   say 'This command file plays a file or device a number of times in a row'
   say 'using the MultiMedia REXX string interface.'
   say
   say 'repeat [FILE=filename] [DEV=device] [TIMEFMT=timefmt]'
   say '         [FROM=from_position] [TO=to_position]'
   say '         [COUNT=no_of_repetitions]'
   say
   say 'If COUNT is omitted, the file is played continuously.'
return

/*  --- ErrExit --
** Common routine for error clean up/program exit.
** Gets called when commands to DLL fail.
*/
ErrExit:
   MacRC = mciRxExit()   /* Tell the DLL we're going away        */
   exit 1;               /* exit, tell caller things went poorly */


/*   ---- error --
** Routine gets control when any command to the external
** environment (usually OS/2) returns a non-zero RC.
** This routine does not get called when the macapi.dll
** returns non-zero as it is a function provider rather
** than a command environment.
*/
error:
   ErrRC = rc
   say 'Error' ErrRC 'at line' sigl ', sourceline:' sourceline(sigl)
   MacRC = mciRxExit()       /* Tell the DLL we're going away */
   exit ErrRC                /* exit, tell caller things went poorly */
