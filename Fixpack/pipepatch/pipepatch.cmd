/* Patch OS/2's CMD.EXE to use a reasonable large pipe buffer size
   when using the pipe operator '|'.
*/

IF RxFuncAdd("SysLoadFuncs", "RexxUtil", "SysLoadFuncs") = 0 THEN
   CALL SysLoadFuncs

PARSE ARG param

origexe = SysSearchPath('PATH', 'CMD.EXE')
IF origexe = '' THEN
   CALL Error 40, "Failed to locate CMD.EXE"

tmpexe = VALUE('TEMP', , 'OS2ENVIRONMENT')
IF tmpexe = '' THEN
   /* use local directory */
   tmpexe = DIRECTORY()

/* create subfolder to avoid complications */
IF RIGHT(tmpexe, 1) \= '\' THEN
   tmpexe = tmpexe'\'
tmpexe = tmpexe'pipe_pch.tmp'
CALL SysMkDir(tmpexe)

/* Check if it is not the same as cmd.exe's directory */
IF ABBREV(origexe, tmpexe) THEN
   CALL Error 34, "Cannot run in the same directory where CMD.EXE resides."

IF RIGHT(tmpexe, 1) \= '\' THEN
   tmpexe = tmpexe'\'
tmpexe = tmpexe'CMD.EXE'

bakexe = FILESPEC('D', origexe)FILESPEC('P', origexe)'CMD.BAK'

/* fetch our name */
PARSE SOURCE dummy dummy self


/* Well it is a little bit tricky to replace CMD.EXE of a running system,
   especially if the patch depends on CMD.EXE itself. */
SELECT
WHEN VERIFY(param, '0123456789') = 0 THEN DO
   /* Stage 1, do the patch and run stage 2 in a separate task */
   IF param = '' THEN
      param = 65024 /* 63,5kiB */
   ELSE IF param < 512 | param > 65535 THEN
      CALL Error 32, "Pipe buffer size is out of the range [512, 65535]."
   stage2param = '@STAGE2'
   /* copy original file */
   CALL CheckedExec 'copy "'origexe'" "'tmpexe'"'
   /* uncompress file */
   CALL CheckedExec 'lxlite /f /mrn /mln /mfn "'tmpexe'"'
   /* Read file */
   IF STREAM(tmpexe, 'C', 'OPEN READ') \= 'READY:' THEN
      CALL Error 20, "Failed to open "tmpexe" for reading."
   data = CHARIN(tmpexe, , 10000000) /* sufficienty large ... */
   CALL STREAM tmpexe, 'C', 'CLOSE'
   /* Search location */
   p = POS('1EFF76FA8B46FA40401E506A009A000000000BC074'x, data)
   IF p = 0 THEN DO
      /* not found: already patched? */
      DO FOREVER
         p = POS('1E8B46FA5040401E5068'x, data, p+1)
         IF p = 0 THEN
            CALL Error 19, "Failed to locate patch position. Maybe your CMD.EXE version is not supported."
         IF SUBSTR(data, p+12, 9) = '909A000000000BC074'x THEN /* second part of match */
            LEAVE
         END
      SAY origexe" is already patched." 
      stage2param = '@STAGE2_NB' /* do not backup an already patched one */
      END
   ELSE IF STREAM(bakexe, 'C', 'QUERY EXISTS') \= '' THEN
      CALL Error 38, "The file '"bakexe"' already exists. You must remove or rename this file first."
   /* Generate patch */
   patch = '1E8B46FA5040401E5068'x||REVERSE(D2C(param, 2))||'909A000000000BC074'x
   IF SUBSTR(data, p, LENGTH(patch)) = patch THEN
      CALL Error 10, "Nothing to do."
   /* Apply patch */
   data = SUBSTR(data, 1, p-1)patch||SUBSTR(data, p+LENGTH(patch))
   IF CHAROUT(tmpexe, data, 1) \= 0 THEN
      CALL Error 27, "Failed to rewrite '"tmpexe"'."
   CALL STREAM tmpexe, 'C', 'CLOSE'
   /* run stage 2 */
   CALL CheckedExec 'start "Replace CMD.EXE" /N /F 'tmpexe' 'FILESPEC('D', tmpexe)FILESPEC('P', tmpexe)' /K "'self' 'stage2param'"' 
   END

WHEN param = "@STAGE2" THEN DO
   /* Stage 2, replace CMD.EXE */
   SAY
   /* backup the original one */
   SAY "Making backup of '"origexe"'."
   n = 0
   DO FOREVER
      SAY "Waiting ..."
      CALL SysSleep 1
      'ren "'origexe'" CMD.BAK'
      IF RC = 0 THEN
         LEAVE
      IF RC \= 1 THEN
         CALL Error 29, "Failed to raname '"origexe"'."
      n = n +1
      IF n > 10 THEN
         CALL Error 23, "Failed to rename '"origexe"' within 10 seconds."||"0D0A"x||" Most likely there is still an instance of CMD.EXE running."
      END
   /* Replace CMD.EXE */
   CALL ReplaceCMD_EXE
   END

WHEN param = "@STAGE2_NB" THEN DO
   /* Stage 2, replace CMD.EXE */
   SAY
   /* delete an already patched one */
   SAY "Removing already patched version '"origexe"'."
   n = 0
   DO FOREVER
      SAY "... waiting ..."
      CALL SysSleep 1
      'del "'origexe'"'
      IF RC = 0 THEN
         LEAVE
      IF RC \= 1 THEN
         CALL Error 29, "Failed to remove '"origexe"'."
      n = n +1
      IF n > 10 THEN
         CALL Error 23, "Failed to remove '"origexe"' within 10 seconds."||"0D0A"x||" Most likely there is still an instance of CMD.EXE running."
      END
   /* Replace CMD.EXE */
   CALL ReplaceCMD_EXE
   END

OTHERWISE
   CALL Error 49, "Syntax error. Usage: "self" [pipe buffer size in bytes]"
   END

EXIT 0


ReplaceCMD_EXE:
   /* Replace CMD.EXE */
   'copy "'tmpexe'" "'origexe'"'
   IF RC \= 0 THEN DO
      SAY "Failed to put the patched CMD.EXE in place. Return Code: "RC
      SAY "Trying to restore the original one."
      'ren "'bakexe'" CMD.EXE'
      IF RC \= 0 THEN DO
         SAY "RESTORE FAILED!"
         SAY "Something went really wrong!"
         SAY "YOU HAVE TO PUT THE ORIGINAL CMD.EXE BACK TO '"origexe"'."
         SAY "Otherwise your system may stop working."
         END
      EXIT 29
      END
   SAY origexe" is successully patched and replaced."
   SAY "You may close this window by entering 'EXIT'."
   SAY
   SAY "However, it is a good advise to test if the new one is working."
   SAY "Simply start an OS/2 command promt, but NOT from THIS window."
   SAY
   SAY "Sometimes REXX stops working after patching. Even REXXTRY does nothing."
   SAY "This can be cured by restarting the PMSHELL."  
   RETURN

CheckedExec: PROCEDURE
   cmd = ARG(1) /* execute program */
   cmd
   IF RC \= 0 THEN
      CALL Error 25, "Failed to execute external command '"cmd"'. Return code: "RC
   RETURN

Error: PROCEDURE
   SAY ARG(2)
   EXIT ARG(1)

