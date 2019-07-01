/*
  Convert media files to mp3 (with CUE support).
  If <same name>.cue file present in source directory it will be used to split
  output  mp3 files.

  Necessary tools should be present in %PATH% or current directory
  or script-directory: ffmpeg.exe, lame.exe, mp3splt.exe

  Example:
    >tomp3.cmd myFile.flac

  myFile.cue will be used (if exists) to split mp3 files.
*/

LameOpt		= "--priority 2 -q 0 -b 320 --cbr"

fWinLame = 0

Prog_ffmpeg	= "ffmpeg.exe"
Prog_lame	= "lame.exe"
Prog_lame_win	= "lame_win.exe"
Prog_mp3splt	= "mp3splt.exe"

CALL RxFuncAdd SysLoadFuncs, rexxutil, sysloadfuncs
CALL SysLoadFuncs


parse SOURCE rubbish rubbish FScript
i = lastpos( "\", FScript )
if i > 0 then
do
  ScriptPath = left( FScript, i - 1 )
  FScript = substr( FScript, i + 1 )
end
else
  ScriptPath = "."
drop rubbish i

parse arg FInput
FInput = strip( strip( FInput, 'B', '"' ), 'B' )
if FInput = "" | FInput = "-h" | FInput = "-H" | FInput = "-?" then
do
  say "Usage: " || FScript || " <input file>"
  exit
end


FProg_ffmpeg	= GetProg( Prog_ffmpeg )
if fWinLame then
  FProg_lame	= "pec " || GetProg( Prog_lame_win )
else
  FProg_lame	= GetProg( Prog_lame )
FProg_mp3splt	= GetProg( Prog_mp3splt )

FPath = filespec( "drive", FInput ) || filespec( "path", FInput )
FName = filespec( "name", FInput )
extPos = lastpos( ".", FName )
if extPos \= 0 then
do
  FExt = translate( substr( FName, extPos + 1 ) )
  FName = left( FName, extPos - 1 )
end
else
  FExt = ""

FOutput = FPath || FName || ".mp3"

call time "E"

if FExt \= "MP3" then
do
  if FProg_lame = "" then
  do
    say Prog_lame || " not found!"
    return 1
  end

  if stream( FOutput, "c", "query exists" ) \= "" then
  do
    say "File " || FOutput || " already exists!"
    exit
  end

  if FExt \= "WAV" then
  do
    if FProg_ffmpeg = "" then
    do
      say Prog_ffmpeg || " not found!"
      return 1
    end

    FTemp = SysTempFileName( "tomp3_??.wav" )

    FProg_ffmpeg || " -i """ || FInput || """ """ || FTemp || """"
    if rc \= 0 then
      exit

    FProg_lame || " " || LameOpt || " """ || FTemp || """ """ || FOutput || """"

    call SysFileDelete FTemp
  end
  else
    FProg_lame || " " || LameOpt || " """ || FInput || """ """ || FOutput || """"
end

Fcue = FPath || FName || ".cue"
if stream( Fcue, "c", "query exists" ) \= "" then
do
  if FProg_mp3splt = "" then
  do
    say "Cannot split the tracks with " || FName || ".cue"
    say Prog_mp3splt || " not found."
  end
  else
  do
    FOutputPath = strip( FPath, "T", "\" )
    if FOutputPath = "" then
      FOutputPath = "."
/*
    if strSwitch = "-n"
      strTitlesSw = "@n"
    else
      strTitlesSw = """@n @t"""

    FProg_mp3splt || " -d """ || FOutputPath || """ -o " || strTitlesSw || " -c """ ,*
*/
    FProg_mp3splt || " -f -d """ || FOutputPath || """ -o ""@n @t"" -c """ ,
      || Fcue || """ """ || FOutput || """"
    if rc = 0 then
    do
      call SysFileDelete FOutput
    end
  end
end


say "Elapsed: " || time('R') || " sec."
EXIT


GetProg: procedure expose ScriptPath
  FProg = arg(1)

  if stream( FProg, "c", "query exists" ) \= "" then
    return FProg

  if stream( ScriptPath || "\" || FProg, "c", "query exists" ) \= "" then
    return ScriptPath || "\" || FProg

  return SysSearchPath( "PATH", FProg )
