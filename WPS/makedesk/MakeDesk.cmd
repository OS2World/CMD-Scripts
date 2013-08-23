/*
 Build desktop objects from a definition (.DEF) file

 Developed by Matthew Palcic - Copyright 1993.
 Released as freeware.  All rights reserved.
 */

call SetupAnsi
DefaultExt = 'def'

call RxFuncAdd SysLoadFuncs, RexxUtil, SysLoadFuncs; call SysLoadFuncs

DoAllFlag = 0
parse Arg AllArgs
DefFileSpec = ''
call GetArgs AllArgs

Ver = 'v1.40'
ProgTitle = 'MakeDesk 'Ver' - Copyright 1993, Matthew Palcic'
'@ECHO OFF'; say Ansi.Normal;'CLS'; say '';say Ansi.Bold||ProgTitle||Ansi.NoBold

if DefFileSpec = '' then
  call TellParameters
call ParseDefFile DefFileSpec
call CleanUp
exit

ParseDefFile: arg DefFile
  say
  if \lines(DefFile) then /* Invalid file */
    DefFile = AddDefExt(DefaultExt,DefFile)
  if \lines(DefFile) then /* Still invalid */
    call BadDefFile
  say 'Processing: 'DefFile
  say
  UserVar.0 = 0
  UserVal.0 = 0
  UserIndex = 0

  Var = '~LF~'
  Val = '0A'X
  call DefineVar
 
  do while lines(DefFile)
    DefLine = linein(DefFile)
    parse value DefLine with Cmd Rest
    Cmd = Translate(Cmd)
    select
      when SubStr(DefLine,1,1) = '*' then /* Comment specifier */
        say Ansi.BrightCyan||SubStr(DefLine,2)||Ansi.Normal
      when Cmd = 'DEFINE' then do /* Define command */
        parse value Rest with Var Val
        call DefineVar
        end
      when Cmd = 'TITLE' then do /* Title command */
        Rest = Replace(Rest)
        Title = Strip(Rest); Location=''; Setup=''
        Drop SetupStr SetupStr.
        SetupStr.0 = 0; Exists = 'U'; ObjectClass = ''; Done = 0; SetupStrX = 0
        do while (Done = 0) /* Loop until end of file or blank line to separate objects */
          ObjLine = linein(DefFile)
          parse value ObjLine with Cmd Rest
          Cmd = Translate(Cmd)
          Rest = Replace(Rest)
          if \Lines(DefFile) then
            Done = 1
          select
            when Length(ObjLine) = 0 then 
              Done = 1
            when SubStr(ObjLine,1,1) = '*' then
              nop /* Do nothing for a comment within an object block */
            when Cmd = 'CLASS' then       /* Class subcommand */
              ObjectClass = Strip(Rest)
            when Cmd = 'LOCATION' then    /* Location subcommand */
              parse upper value Strip(Rest) with Location
            when Cmd = 'OBJECTID' then    /* ObjectID subcommand */
              parse upper value Strip(Rest) with ObjectID
            when Cmd = 'SETUP' then do    /* Setup type subcommand */
              parse value Strip(Rest) with CreateFlag
              CreateFlag = Translate(SubStr(CreateFlag,1,1))
              end

            /* Add your own subcommands using this format.  Fill
               in your own processing between the do and end statements.

                 when Cmd = '' then then do
                   MyOwnProcessingCode
                   end
            */

            otherwise do /* Must be a Setup string */
              SetupStrX = SetupStrX + 1
              SetupStr.SetupStrX = Replace(ObjLine)
              if Substr(SetupStr.SetupStrX,Length(SetupStr.SetupStrX),1) \= ';' then
                SetupStr.SetupStrX = SetupStr.SetupStrX||';'
              end
            end
          end /* Finished with loop for this object */

        /* Process this definition */
        Setup = Setup||'OBJECTID='||ObjectID||';'
        do SetupLoop = 1 to SetupStrX
          Setup = Setup||SetupStr.SetupLoop
          end

        if 'Title' \= '' & ObjectClass \= '' & Location \= '' then do
          /* Have title, class & location, build it */
          if ObjectClass = 'WPShadow' then
            Setup = 'SHADOWID='ObjectID /* Shadows need this */
          call BldObj
          end
        else /* Not a valid title, class and location */
          say 'Bad object definition.'
        end

      /* Add your own main commands using this format.  Fill
         in your own processing between the do and end statements.
 
         when Cmd = '' then then do
           MyOwnProcessingCode
           end
      */

      otherwise /* Unknown command */
        nop
      end /* select */
    end
  return

AskAbout: parse arg Prompt
if DoAllFlag = 1 then do
  say
  return 'Y'
  end
CF = GetDefType(CreateFlag)
call charout ,Ansi.NoBold||CF' 'ObjectClass
call charout ,' 'Ansi.Bold||Prompt||Ansi.NoBold'? ['
call charout ,Ansi.Bold'Yes'Ansi.NoBold'/No/All/<Esc>] '
key = ''
do while (key \= 'Y') & (key \= 'N') & (C2D(key) \= 13) & (key \= 'A')
  parse upper value SysGetKey('NOECHO') with key
  if C2D(key) = 27 then do
    say 'Esc'
    call Escaped
    end
  end
if C2D(key) = 13 then
  Answer = 'Y'
else
  do
  if key = 'A' then do
    DoAllFlag = 1
    say 'All'
    return 'Y'
    end
  else
    Answer = key
  end
select
  when Answer = 'N' then
    say 'No'
  when Answer = 'Y' then
    say 'Yes'
  otherwise
    nop
  end
return Answer

SaySuccess:
  call charout ,'Success.'
  return

SayFail:
  call charout ,Ansi.BrightRed'Failed!'Ansi.Normal
  return

/* Build Object */
BldObj:
DispTitle = translate(Title,' ',XRANGE('0'x,'1F'x),' ')
ObjId = ObjectID
if AskAbout(DispTitle) = 'N' then do
  call WipePrompt
  call charout ,'Skipping 'ObjectClass Title', 'ObjectID; say
  return
  end
call WipePrompt
call charout ,'Processing 'ObjectClass DispTitle', 'ObjectID'  '
RC = SysCreateObject(ObjectClass, Title, Location, Setup, CreateFlag)
If RC = 1 Then
  call SaySuccess
Else
  call SayFail
say
return

Escaped:
  beep(262,70);
  say; say Ansi.Bold'Program terminated with <Esc>.'Ansi.NoBold
  call CleanUp
  exit
  return

DefineVar:
  UserIndex = UserIndex + 1
  UserVar.UserIndex = Var
  UserVal.UserIndex = Val
  return

SetupAnsi:
  Ansi.Bold = '[0;37;44;1m'
  Ansi.NoBold = '[0;37;44m'
  Ansi.BrightRed = '[0;44;31;1m'
  Ansi.Cyan = '[0;36;44m'
  Ansi.BrightCyan = '[0;36;44;1m'
  Ansi.Normal = Ansi.NoBold
  Ansi.Plain = '[0m'
  Ansi.Up1AndClear = '[1A[K'
  return

DropAnsi:
  Ansi.Bold = ''
  Ansi.NoBold = ''
  Ansi.BrightRed = ''
  Ansi.Cyan = ''
  Ansi.BrightCyan = ''
  Ansi.Normal = Ansi.NoBold
  Ansi.Plain = ''
  Ansi.Up1AndClear = ''
  return

WipePrompt:
  call charout ,Ansi.Up1AndClear
  return

Replace: parse arg Haystack
  do x = 1 to UserIndex
    RepDone = 0
    NSpot = 1
    do while RepDone = 0
      NSpot = Pos(UserVar.x,Haystack,NSpot)
      if NSpot = 0 then
        RepDone = 1
      else
        do
        Haystack = DelStr(Haystack,NSpot,Length(UserVar.x))
        Haystack = Insert(UserVal.x, HayStack, NSpot-1)
        NSpot = NSpot + Length(UserVal.x) - 1
        end
      end
    end
  return Haystack

GetBootDrive: procedure
  call charout , 'Drive your machine boots from? '
  parse upper value SysGetKey('NOECHO') with btdrv
  if C2D(btdrv) = 27 then call Escaped
  say btdrv':'
  return btdrv

TellParameters:
  say; say '  Description:'
  say '    Process Workplace Shell objects from a .DEF file'
  say
  say '  Syntax:'
  say '    MakeDesk [/a,/d] deffile'
  say
  say '  Parameters:'
  say '    /a        process all objects in definition file without prompts'
  say '    /d        disable ANSI colorization of display'
  say '    deffile   Definition (.DEF) file to process'
  say '              Example - System.def'
  call CleanUp
  exit
  return

GetDefType: procedure; arg CFlag
  select
    when CFlag = 'U' then
      CF = 'Update'
    when CFlag = 'R' then
      CF = 'Replace'
    otherwise
      CF = 'Create'
    end
  return CF

AddDefExt: procedure
  parse arg DefExt,FileName
  LastDot = lastpos('.',FileName)
  if LastDot > 0 then
    NewFileName = overlay(DefExt,FileName,LastDot+1)
  else
    NewFileName = FileName'.'DefExt
  return NewFileName

BadDefFile:
  say '  The definition file "'DefFile'" is invalid.'
  say '  Check the file and try again.'
  call CleanUp
  exit
  return

CleanUp:
  say Ansi.BrightCyan; say 'Thank you for using MakeDesk 'Ver' by Matthew J. Palcic'Ansi.Plain
  call SysDropFuncs
  return

GetArgs: arg Args
  do ArgNum = 1 to Words(Args)
    select
      when WordPos(Word(Args,ArgNum),'-a -A /a /A') > 0 then
        DoAllFlag = 1 /* Do all objects in the definition file */
      when WordPos(Word(Args,ArgNum),'-d -D /d /D') > 0 then
        call DropAnsi
      otherwise
        DefFileSpec = Word(Args,ArgNum)
      end
    end
  return
