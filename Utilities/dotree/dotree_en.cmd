/* REXX
 *
 * dotree.cmd executes any shell command on all files and directories
 * of a specified path. Files/directories can be specified by a placeholder.
 *
 * Error codes: 0 - success
 *              1 - usage
 *              2 - command execution failed
 *
 * Author: Heiko Nitzsche
 * Date  : 10-September-2004
 * Since : 
 */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

/******************* Parse and validate parameters. ******************/

SIGNAL ON NOVALUE

parse arg fullOptions

/* Single character non case sensitive character for the placeholder. */
PLACEHOLDER = '%'

sourcePath  = ''
COMMAND     = ''
fullOptions = strip(fullOptions)
options     = fullOptions

/* check that at least 2 arguments exist */
numOptions = words(fullOptions)
if (numOptions < 2) then
do
   call usage "Error: Missing options."
   exit 1
end

/* Look for pathname with white spaces encapsulated by "path". */
beginPathPos = 0
endPathPos   = lastpos('"', options)

/* if trailing " found ... */
if (endPathPos = length(options)) then
do
   /* ... look for leading " */
   beginPathPos = lastpos('"', options, endPathPos - 1)

   /* and if found ... */
   if (beginPathPos > 0) then
   do
      /* extract source path and strip options */
      lengthPath = endPathPos - beginPathPos - 1
      if (lengthPath > 0) then
      do
         sourcePath = substr(options, beginPathPos + 1, lengthPath)
         options    = left(options, beginPathPos - 1)

         /* update numOptions but add 1 because the analyzer loop below expects a filename */
         numOptions = words(options) + 1
      end
      else
      do
         call usage "Error: Incomplete name of working directory."
         exit 1
      end
   end
   else
   do
      call usage "Error: Incomplete name of working directory."
      exit 1
   end
end

/* check for additional options */
fileOnlySearchMask = 'FO'
dirOnlySearchMask  = 'DO'
fileDirSearchMask  = 'BO'
recurseOption      = 'S'
searchMask         = fileDirSearchMask

/* convert to capital letters */
capOptions = translate(options)

hasSoption = 0 /* show command     */
hasCoption = 0 /* command          */
hasFoption = 0 /* files only       */
hasDoption = 0 /* directories only */
hasRoption = 0 /* recursive        */

beginWordPos = 0

/* Loop over all option words minus the one for the directory at the end */
do i = 1 to (numOptions - 1)

   option = word(capOptions, i)

   /* calulate startpos of current word */
   beginWordPos = beginWordPos + length(option)

   /* Check for /S or -S options (show command) */
   isSoption = ((option = '/S') | (option = '-S'))

   /* Check for /C or -C options (command) */
   isCoption = ((option = '/C') | (option = '-C'))

   /* Check for /F or -F options (files only) */
   isFoption = ((option = '/F') | (option = '-F'))

   /* Check for /D or -D options (directories only) */
   isDoption = ((option = '/D') | (option = '-D'))

   /* Check for /R or -R options (recursive) */
   isRoption = ((option = '/R') | (option = '-R'))

   if ((isSoption = 0) & (isCoption = 0) & (isFoption = 0) & (isDoption = 0) & (isRoption = 0)) then
   do
      call usage 'Error: Unknown option "'word(options, i)'" specified.'
      exit 1
   end

   /* Check for multiple command options. */
   if (hasCoption & isCoption) then
   do
      call usage "Error: Only one command can be specified."
      exit 1
   end

   /* Check for /S or -S options (command) */
   hasSoption = hasSoption | isSoption

   /* Check for /C or -C options (command) */
   hasCoption = hasCoption | isCoption

   /* Check for /F or -F options (files only) */
   hasFoption = hasFoption | isFoption

   /* Check for /D or -D options (directories only) */
   hasDoption = hasDoption | isDoption

   /* Check for /R or -R options (recursive) */
   hasRoption = hasRoption | isRoption

   /* Extract command. */
   if (isCoption) then
   do
      beginCmdPos = pos("'", capOptions, beginWordPos + length(option))
      endCmdPos   = 0

      if (beginCmdPos = 0) then
      do
         call usage "Error: No command specified."
         exit 1
      end
      else
      do
         endCmdPos = pos("'", capOptions, beginCmdPos + 1)
         if (endCmdPos = 0) then
         do
            call usage "Error: Incomplete command."
            exit 1
         end

         /* delete command from string including '' to allow further word parsing */
         COMMAND = substr(options, beginCmdPos, endCmdPos - beginCmdPos + 1)
         i       = i + words(COMMAND)
      end
   end
end /* do */

/* check for placeholder in command */
if (pos(PLACEHOLDER, COMMAND) = 0) then
do
   call usage "Error: Missing or unknown placeholder."
   exit 1
end

/* Check for exclusive options */
if (hasFoption & hasDoption) then
do
   call usage "Error: The option /f and /d are mutual exclusive."
   exit 1
end

/* set search mask for SysFileTree (files only) */
if (hasFoption) then
do
   searchMask = fileOnlySearchMask
end

/* set search mask for SysFileTree (directories only) */
if (hasDoption) then
do
   searchMask = dirOnlySearchMask
end

/* add search mask recursive option for SysFileTree if requested */
if (hasRoption) then
do
   searchMask = searchMask''recurseOption
end

/* get sourcepath directory (the rest) */
beginPathPos = wordindex(fullOptions, numOptions-1) + wordlength(fullOptions, numOptions-1)
sourcePath   = right(fullOptions, length(fullOptions) - beginPathPos)

/* strip white spaces enclosing the path if specified */
sourcePath = strip(sourcePath)

/* strip "s enclosing the path if specified */
sourcePath = strip(sourcePath,,'"')

/* strip 's enclosing the command */
COMMAND = strip(COMMAND,,"'")


/****************************** Execute ****************************/

/* Find all files by pattern. */
retVal = SysFileTree(sourcePath, 'filenames', searchMask)
if (\ (retVal = 0)) then
do
   call usage "Error: Illegal directory specified."
   exit 1
end

/* Check if any files were found. */
if (filenames.0 > 0) then
do
   say

   /* Remove EAs */
   do i = 1 to filenames.0
      execCommand = replace_placeholders(filenames.i)

      /* say '"'filenames.i'"' */
      if (hasSoption) then
      do
         say
         say "-> " || execCommand
      end

      address CMD '@ ' || execCommand
      if (\ (rc = 0)) then
      do
         say
         say "Error: Command execution failed (rc=" || rc || ")."
         exit 2
      end
   end
end
else
do
   say
   say "No matching files/directories found."
end

say
say "Operation complete."
exit 0


/******************************************************/
/* Replaces all placeholders by the specified string. */
/******************************************************/
replace_placeholders:procedure expose COMMAND PLACEHOLDER

   parse arg replacement

   fullCommand = ''

   /* loop over all placeholders */
   numChars = length(COMMAND)

   do i = 1 to numChars

      c = substr(COMMAND, i, 1)

      if (c = PLACEHOLDER) then
      do
         fullCommand = fullCommand || replacement
      end
      else
      do
         fullCommand = fullCommand || c
      end
   end /* do */

   return strip(fullCommand)


/*********************************************************/
/* Prints usage with error message as function argument. */
/*********************************************************/
usage:procedure expose PLACEHOLDER

   parse arg errorMessage

   GENERAL_CMD = "'command "  || '["]' || PLACEHOLDER || '["]' || "'"
   TYPE_CMD    = "'type "     || PLACEHOLDER || " | more'"
   DIR_CMD     = "'dir "      || PLACEHOLDER || "'"
   COPY_CMD    = "'copy "     || '"' || PLACEHOLDER || '"' || " " || '"' || PLACEHOLDER || ".bak" || '"' || "'"

   say
   say errorMessage
   say
   say 'This program executes any shell command on files/directories of the'
   say 'defined working directory. An optional file mask can be specified.'
   say 'As placeholder for the file/directory name ' || PLACEHOLDER || ' is used.'
   say 'If white spaces are part of the file/directory names, "%" can be used.'
   say
   say 'Usage: dotree.cmd [/s] [/f] [/d] [/r] /c ' || GENERAL_CMD || ' <directory\mask>'
   say
   say '  /s - show the fully expanded command that is executed'
   say '  /c - defines the command to be executed'
   say '  /f - operate on files only'
   say '  /d - operate on directories only'
   say '  /r - include subdirectories (recursive)'
   say
   say '  If /f and /d are not specified, all files and directories are analyzed.'
   say '  The options /f and /d are mutual exclusive.'
   say
   say '  Examples:'
   say '    dotree /f /r /c ' || TYPE_CMD || ' x:\doc\*.txt'
   say '    dotree /d /c '    || DIR_CMD  || ' x:\'
   say '    dotree /f /c '    || COPY_CMD || ' x:\*.jpg'
   say
   say '(Copyright: Heiko Nitzsche, Version: 1.0, 10-September-2004)'

   return

