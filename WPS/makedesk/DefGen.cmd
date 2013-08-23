/* Create a MakeDesk definition for INI.RC to allow
   rebuilding stock objects. */

/* Modified from ReCreate.CMD by Greg Czaja - Jul 29, 1992 */
/* This version by Matthew Palcic - 10 Feb 93 */

Ver='v1.21'

say 'DefGen 'Ver' - Copyright 1993, Matthew J. Palcic'
say

Parse arg DefArgs
IniFile = '\OS2\INI.RC'

call GetArgs DefArgs

if Lines(file_name) = 0 then do
  say 'Could not locate file: 'file_name
  exit
  end
else
  if OutFile <> '' then
    call lineout OutFile,,1
say 'Converting "'file_name'" into "'OutFile'"'
Do While Lines(file_name) > 0
   Title = ''; Object = ''; ObjID = ''; ShadID = ''; RepFlag = 'Update';
   line=Linein(file_name);
   If line='' Then Iterate;        /* skip blanks   */
   Parse Var line '"PM_InstallObject"' line;
   If line='' Then Iterate;
   Parse Var line '"'head'" 'line; /* get header */

   /* gc this Parse will strip of " - important for Parse below */
   Parse Var line '"'setup'"' .;   /* get setup string */

   Parse Var head title';'object';'location;
   call lineout OutFile,'Title     'Title
   call lineout OutFile,'Class     'Object

   PARSE VAR Location Location ';' RepFlag
   call lineout OutFile,'Location  'Location

   If Right(setup,1) <> ';'   /* ending ; there ? */
      Then setup=setup';'     /* no - append      */
   Parse Var setup part1 'SHADOWID=' ShadID ';' part2;
   setup=part1||part2;
   Parse Var setup part1 'OBJECTID=' ObjID ';' part2;
   setup=part1||part2;
   if ShadID <> '' then do
     ObjID = ShadID
     end

   if ObjID <> '' then /* We have an ObjectID */
     call lineout OutFile,'ObjectID  'ObjID
   if RepFlag = 'REPLACE' then
     call lineout OutFile,'Setup     Replace'
   else
     call lineout OutFile,'Setup     Update'
   do while Setup <> ''
     Parse VAR Setup SetVal ';' Setup
     call lineout OutFile,SetVal
     end /* do */
   call lineout OutFile,''
   End

rc=Stream(file_name,'C','Close');
Return

BootDrive:
  return filespec('drive',value('RUNWORKPLACE',,'OS2ENVIRONMENT'))

ShowParams:
  say '  Description:'
  say '     OS/2 profile resource (.RC) to MakeDesk (.DEF) converter'
  say
  say '  Syntax:'
  say '     DefGen drive|infile outfile'
  say
  say '  Parameters:'
  say '     drive      Drive letter containing \OS2\INI.RC'
  say '                Default - boot drive'
  say '                Example - E:'
  say '     infile     Filename to process'
  say '                Default extension - (.rc)'
  say '                Example: E:\OS2\WIN_30.RC'
  say
  say '     outfile    Object definition file to create.'
  say '                Default extension - (.def)'
  say '                Example: D:\Defs\Win_30.def'
  exit
  return

GetArgs:
  parse arg ARG1 ARG2
  parse arg Args

  do ArgNum = 1 to Words(Args)
    select
      when WordPos(Word(Args,ArgNum),'-? /?') > 0 then
        call ShowParams
      otherwise
        nop
      end
    end

  ALen = length(ARG1)
  select
    when ALen = 2 then do
      parse upper var ARG1 DriveLetter':'Blah
      if ((DriveLetter >= 'A') & (DriveLetter <='Z')) then
        file_Name = DriveLetter':'IniFile
      else
        file_name = BootDrive()||IniFile
      end
    when ALen > 2 then
      file_name = AddDefExt('rc',ARG1)
    otherwise
      call ShowParams
      nop
    end  /* select */

  if length(ARG2) > 0 then
    OutFile = AddDefExt('def',ARG2)
  else
    call ShowParams
  return

AddDefExt: procedure
  parse arg DefExt,FileName
  LastDot = lastpos('.',FileName)
  if LastDot > 0 then
    NewFileName = FileName /*NewFileName = overlay(DefExt,FileName,LastDot+1)*/
  else
    NewFileName = FileName'.'DefExt
  return NewFileName

