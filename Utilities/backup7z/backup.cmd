/*
  Backup script for 7-Zip.
  ------------------------

  Usage: BACKUP.CMD <listfile> <outputName> [historyFiles]"

    listfile          Read source path/file names from listfile.
    outputName        Path and base name for archive. You can point extension
                      7z or zip, default is 7z.
    historyFiles      Number of history archive files.

  listfile example:
    --- Begin of file ---
    ; Comment
    C:\config.sys
    C:\config.os4
    C:\MPTN\ETC\crontab
    C:\Programs\NDFS\volumes.cfg
    ; Next line is empty, it's ok.

    D:\HOME\backup.lst
    D:\home\Documents\*
    ;D:/home/Mozilla\*
    D:/home/PsiData\*
    D:/home/Thunderbird\*
    D:/home/.cache\*
    D:/home/.config\*
    D:/home/.local\*

    G:\projects\*
    --- End of file ---

  For outputName "D:\path\name.zip" It will creates files like:
    name_D.zip
    name_D.1.zip
    name_D.2.zip
  where "D" is a drive where source files placed, 1 and 2 is history files
  (renamed previous archives).

  You should have 7z.exe at your PATH.

  Example:
    backup.cmd D:\HOME\backup.lst G:\backup\local\MyBackup 2

  Digi, 2017.
*/


debugOutput = 1
defHistoryFiles = 2
dirCur = directory()
pathTemp = value( "temp",, "OS2ENVIRONMENT" )
file7zEXE = "7z.exe" /* Without path. */

parse arg fileList outputPathName historyFiles

if fileList = "" | wordpos( fileList, "-? -h -H /? /h /H" ) \= 0 | ,
   outputPathName = "" then
  call Help

if historyFiles = "" then
  historyFiles = defHistoryFiles
else if verify( historyFiles, "1234567890" ) \= 0 then
  call Help
call Debug "History archives: " || historyFiles

/* Get default drive letter for pathnames in the user's flielist. */
defaultDisk = filespec( "drive", fileList )
if defaultDisk = "" then
  defaultDisk = dirCur
defaultDisk = translate( left( defaultDisk, 1 ) )
call Debug "Default source drive: [" || defaultDisk || ":]"

/* Parse output file path, name and (optional) type (7z or zip). */

outputDir = filespec( "drive", outputPathName ) || ,
            filespec( "path", outputPathName )
outputFile = filespec( "name", outputPathName )

if outputDir = "" then
  outputDir = strip( dirCur, "t", "\" ) || "\"
else
do
  if left( outputDir, 1 ) = "\" then             /* path begins with "\"  */
    outputDir = left( dirCur, 1 ) || ":" || outputDir
  else if substr( outputDir, 2, 1 ) \= ":" then  /* path w/o drive letter */
    outputDir = strip( dirCur, "t", "\" ) || "\" || outputDir

  if directory( left( outputDir, length(outputDir) - 1 ) ) = "" then
    call Error "Invalid output path: " || outputDir
end

if pos( ".", outputFile ) \= 0 then
do
  parse var outputFile outputFile "." outputExt
  outputExt = translate( outputExt, "zip", "ZIP" )
  if wordpos( outputExt, "7z zip" ) = 0 then
    call Error "Invalid output file type, should be '7z' or 'zip'"
end
else
  outputExt = "7z"
call Debug "Output path: " || outputDir
call Debug "Output base name: " || outputFile
call Debug "Archive type: " || outputExt
/*
   Second argument "D:\path\fileName" parsed to:
     outputDir:  "D:\path\"
     outputFile: "fileName"
     outputExt:  "7z" or "zip" (default is "7z")
*/

if left( stream( fileList, "c", "open read" ), 9 ) = "NOTREADY:" then
  call Error "Can't open file list: " || fileList

prog7zEXE = SysSearchPath( "PATH", file7zEXE )
if prog7zEXE = "" then
  call Error file7zEXE || " not found."
call Debug "7-Zip program file: " || prog7zEXE

/* Reset by-drive lists: list.A.0 = 0, list.B.0 = 0 .. list.Z.0 = 0 */
do diskLtrCode = 65 to 90 /* A..Z */
  call value "list." || d2c( diskLtrCode ) || ".0", 0
end

/* Read list to list.<DSIK>.<1..N> */

do lineNum = 1 while lines( fileList ) \= 0
  line = translate( strip( linein( fileList ) ), "/", "\" )

  /* Skip empty line or comment. */
  if line = "" | left( line, 1 ) = ";" then
    iterate

  /* Extract disk letter from path. */
  if substr( line, 2, 2 ) = ":/" then
    parse upper var line disk ":/" line
  else
    disk = defaultDisk

  diskFilesCount = list.disk.0 + 1
  list.disk.0 = diskFilesCount
  list.disk.diskFilesCount = line
end
call stream fileList, "c", "close"

/* Create achives. */

call time "R"

tempListFile = pathTemp || "bkplst$.$$$"
tempArchName = "bkp$." || outputExt
tempArchFile = outputDir || tempArchName

do diskLtrCode = 65 to 90 /* A..Z */
  disk = d2c( diskLtrCode )
  if list.disk.0 = 0 then
    iterate /* no files listed for this disk */

  /* Build listfile for 7-Zip. */
  "@del " || tempListFile || ">nul"
  call Debug "List for drive " || disk || ":"
  do fileIdx = 1 to list.disk.0
    call Debug "  " || list.disk.fileIdx
    call lineout tempListFile, list.disk.fileIdx
  end
  call stream tempListFile, "c", "close"

  /* Archive files to bkp$$$.7za or bkp$$$.zip */

  if directory( disk || ":\" ) = "" then
  do
    call Warning "Can't change current drive to " || disk || ":"
    iterate
  end

  '@if exist "' || tempArchFile || '" del "' || tempArchFile || '" 2>nul'

  cmd = prog7zEXE' a -t'outputExt' -mx7 -i@"'tempListFile'" "'tempArchFile'"'
  if Run( cmd ) \= 0 then
    call Warning "Error code from 7-Zip: " || rc

  /* Rotate archives and rename a new archive. */

  newArchBase = outputFile || "_" || disk
  newArchFile = outputDir || newArchBase || "." || outputExt

  if historyFiles \= 0 then
  do
    call Run 'del "'outputDir || newArchBase'.'historyFiles'.'outputExt'" 2>nul'
    do idx = historyFiles - 1 to 1 by -1
      cmd = 'ren "'outputDir || newArchBase'.'idx'.'outputExt || ,
            '" "'newArchBase'.' || (idx+1) || '.'outputExt'" 2>nul'
      call Run cmd
    end
    cmd = 'ren "'newArchFile'" "'newArchBase'.1.'outputExt'" 2>nul'
    call Run cmd
  end
  else
    call Run 'del "'outputDir || newArchBase'.'outputExt'" 2>nul'
  cmd = 'ren "'tempArchFile'" "'newArchBase'.'outputExt'"'
  if Run( cmd ) \= 0 then
    call Warning 'Can''t rename "'tempArchFile'" to "'newArchBase'.'outputExt'"'
end

"@del " || tempListFile || ">nul"
call directory dirCur

say "Done. Elapsed time: " || strip( time( "E" ), "t", 0 ) || " sec."
EXIT


Run:
  call Debug "Run: " || arg( 1 )
  "@" || arg( 1 )
  return rc

Error:
  call Log "[Error] " || arg( 1 )
  exit 1

Warning:
  call Log "[Warning] " || arg( 1 )
  exit 1

Debug:
  if debugOutput = 1 then
    call Log "[Debug] " || arg( 1 )
  return

Log:
  say arg( 1 )
  return

Help:
  parse upper source OS2 runType scriptFile
  say "Usage: " || filespec( "name", scriptFile ) || ,
      " <listfile> <outputName> [historyFiles]"
  say ""
  say "  listfile          Read source path/file names from listfile."
  say "  outputName        Path and base name for archive. You can point extension"
  say "                    7z or zip, default is 7z."
  say "  historyFiles      Number of history archive files, default is " || ,
      defHistoryFiles"."
  exit 1
/* 7z a -ir@d:\home\backup1.lst G:\arch */
