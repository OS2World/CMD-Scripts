/**
*** ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
*** º BuildSOM v1.0                                                      º
*** º                                                                    º
*** º This will process a meta language to create SOM objects on the     º
*** º desktop.                                                           º
*** º                                                                    º
*** º See the Notes section at the end of this file.                     º
*** º                                                                    º
*** º ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ º
*** º                                                                    º
*** º               Copyright (c) 1992,  Hilbert Computing               º
*** º                                                                    º
*** º ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ º
*** º                                                                    º
*** º  Send any comments to:                                             º
*** º                                                                    º
*** º       Gary Murphy                                                  º
*** º       1022 N. Cooper                                               º
*** º       Olathe, KS 66061                                             º
*** º                                                                    º
*** º       CIS: [73457,365]                                             º
*** º       BBS: 913-829-2450                                            º
*** º                                                                    º
*** ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
**/

arg MetaFile

/* Load the external DLLs for this program */

call LoadFunctions

/* Initalize the global variables */

Lex.           = ''     /* Lexical analysis global variables */
Lex.Line       = 0
Lex.StackLoc.0 = 0
Lex.State      = 'Inline'
Lex.Folder     = '<WP_DESKTOP>'
Lex.Location   = '<WP_DESKTOP>'
Opt.           = ''     /* Options */
Obj.           = ''     /* Current object */
Prf.           = ''     /* Profiles */


CurrentDirectory = directory()

call PushLocation

/* Open the file and process the statements */

TempDir = value("TEMP",,"OS2ENVIRONMENT")
if TempDir = '' then
   call Error 4002

Lex.File = Open(TempDir"\BuildSom.Out", 'WRITE')

MetaFile = Open(MetaFile)
if MetaFile = '' then
   call Error 1001 MetaFile

Statement = linein(MetaFile)
do while(lines(MetaFile) > 0)
   Lex.Line = Lex.Line + 1
   call ParseStatement Statement
   Statement = linein(MetaFile)
end
Lex.Line = Lex.Line + 1
call ParseStatement Statement

call Close(MetaFile)

call Close(Lex.File)

/* Process the intermediate file */

Lex.File = Open(Lex.File)
if Lex.File = '' then
   call Error 1001 Lex.File

do while(lines(Lex.File) > 0)
   Statement = linein(Lex.File)
   parse var Statement OpCode parm

   select
      when OpCode = "C" then Obj.Class    = parm
      when OpCode = "L" then Obj.Location = parm
      when OpCode = "T" then Obj.Title    = parm
      when OpCode = "S" then Obj.Setup    = parm
      when OpCode = "E" then Obj.Exists   = parm
      when OpCode = "." then
         do
         Code = SysCreateObject(Obj.Class,,
                                Obj.Title,,
                                Obj.Location,,
                                Obj.Setup,,
                                Obj.Exists)
         if Code = 0 then
            call Error 1013
         end
      otherwise
         nop
   end /* select */
end
call Close(Lex.File)

Code = directory(CurrentDirectory)
exit

/**
*** ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*** ³                      Lexical Analysis Routines                       ³
*** ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
**/

ParseStatement: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will parse a single statement in the meta language.
   **/

   parse arg Verb Arguments

   if Verb = '' then
      return

   parse upper var Verb Verb
   select
      when abbrev('BEGIN'      ,Verb,  3) then
         call ParseBeginStatement Arguments
      when abbrev('CREATE'     ,Verb,  3) then
         call ParseCreateStatement Arguments
      when abbrev('DIR'        ,Verb,  3) then
         call ParseSetupStartupDir Arguments
      when abbrev('END'        ,Verb,  3) then
         call ParseEndStatement Arguments
      when abbrev('ENVIRONMENT',Verb,  3) then
         call ParseEnvironment Arguments
      when abbrev('EXENAME'    ,Verb,  3) then
         call ParseSetupExeName Arguments
      when abbrev('ICONFILE'   ,Verb,  3) then
         call ParseSetupIconFile Arguments
      when abbrev('MINIMIZETO' ,Verb,  4) then
         call ParseSetupMinWin Arguments
      when abbrev('MINTO'      ,Verb,  5) then
         call ParseSetupMinWin Arguments
      when abbrev('MINWIN'     ,Verb,  3) then
         call ParseSetupMinWin Arguments
      when abbrev('PARAMETERS' ,Verb,  3) then
         call ParseSetupParameters Arguments
      when abbrev('PARMS'      ,Verb,  3) then
         call ParseSetupParameters Arguments
      when abbrev('PROGTYPE'   ,Verb,  3) then
         call ParseSetupProgType Arguments
      when abbrev('REM'        ,Verb,  3) then
         nop /* Comment */
      when abbrev('SESSIONTYPE',Verb,  4) then
         call ParseSetupProgType Arguments
      when abbrev('SETUP'      ,Verb,  4) then
         call ParseSetupSetup  Arguments
      when abbrev('STARTUPDIR' ,Verb,  7) then
         call ParseSetupStartupDir Arguments
      when abbrev('TYPE'       ,Verb,  4) then
         call ParseSetupProgType Arguments
      when abbrev('WORKINGDIR' ,Verb,  4) then
         call ParseSetupStartupDir Arguments
      when abbrev('#'          ,Verb,  1) then
         nop /* Comment */
      when abbrev('{'          ,Verb,  1) then
         call ParseNestStatement Arguments
      when abbrev('}'          ,Verb,  1) then
         call ParseUnnestStatement Arguments
      otherwise
         call Error 1002 Verb
   end /* select */
   return


ParseSetupIconFile: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will parse the ICONFILE statement
   **/

   arg FileName .

   /* Make sure the state is valid */

   select
      when Lex.State = "BeginF" then
         nop
      when Lex.State = "BeginP" then
         nop
      otherwise
         call Error 1010
   end /* select */

   /*  See if the file exists */

   FullName = ScanForFile(FileName, ".I")
   if FullName = '' then
      call Error 1009 FileName

   Obj.Setup = Obj.Setup";ICONFILE="FullName
   return


ParseSetupSetup: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will parse the SETUP statement.  This will pass the parameters
   ***  unchecked to setup string.  This is coded to allow for parameters
   ***  that I haven't coded special routines for yet.
   **/

   arg Setup .

   /* Make sure the state is valid */

   select
      when Lex.State = "BeginF" then
         nop
      when Lex.State = "BeginP" then
         nop
      otherwise
         call Error 1010
   end /* select */

   Obj.Setup = Obj.Setup";"Setup
   return


ParseSetupMinWin: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will parse the MINWIN statement
   **/

   arg MinimizeTo .

   /* Make sure the state is valid */

   select
      when Lex.State = "BeginF" then
         nop
      when Lex.State = "BeginP" then
         nop
      otherwise
         call Error 1010
   end /* select */

   select
      when abbrev('DESKTOP',Verb,  1) then Minimize = 'DESKTOP'
      when abbrev('VIEWER', Verb,  1) then Minimize = 'VIEWER'
      when abbrev('HIDE',   Verb,  1) then Minimize = 'HIDE'
      otherwise
         call Error 1012

   Obj.Setup = Obj.Setup";MINWIN="MinimizeTo
   return


ParseSetupExeName: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will parse the EXENAME statement
   **/

   arg FileName .

   /* Make sure the state is valid */

   select
      when Lex.State = "BeginP" then
         nop
      otherwise
         call Error 1010
   end /* select */

   /*  See if the file exists */

   FullName = ScanForFile(FileName, ".P")
   if FullName = '' then
      call Error 1009 FileName

   Obj.Setup = Obj.Setup";EXENAME="FullName
   return


ParseSetupParameters: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will parse the PARAMETERS statement
   **/

   parse arg Parms

   Parms = strip(Parms)

   /* Make sure the state is valid */

   select
      when Lex.State = "BeginP" then
         nop
      otherwise
         call Error 1010
   end /* select */

   Obj.Setup = Obj.Setup";PARAMETERS="Parms
   return


ParseSetupProgType: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will parse the PROGTYPE statement
   **/

   arg Type .

   /* Make sure the state is valid */

   select
      when Lex.State = "BeginP" then
         nop
      otherwise
         call Error 1010
   end /* select */

   select
      when abbrev('DOSFULLSCREEN',Type,  4) then ProgType = 'VDM'
      when abbrev('DOSWINDOW'    ,Type,  4) then ProgType = 'WINDOWEDVDM'
      when abbrev('OS2FULLSCREEN',Type,  4) then ProgType = 'FULLSCREEN'
      when abbrev('OS2WINDOW'    ,Type,  4) then ProgType = 'WINDOWABLEVIO'
      when abbrev('WINFULLSCREEN',Type,  4) then ProgType = 'WIN'
      when abbrev('WINWINDOWED'  ,Type,  4) then ProgType = 'WINDOWEDWIN'
      when abbrev('PM'           ,Type,  2) then ProgType = 'PM'

      when abbrev('WINDOWABLEVIO',Type,  9) then ProgType = 'WINDOWABLEVIO'
      when abbrev('FULLSCREEN'   ,Type,  3) then ProgType = 'FULLSCREEN'
      when abbrev('WINDOWEDWIN'  ,Type,  9) then ProgType = 'WINDOWEDWIN'
      when abbrev('SEPARATEWIN'  ,Type,  3) then ProgType = 'SEPARATEWIN'
      when abbrev('SEAMLESS'     ,Type,  3) then ProgType = 'SEPARATEWIN'
      when abbrev('WIN'          ,Type,  3) then ProgType = 'WIN'
      when abbrev('WINDOWEDVDM'  ,Type,  9) then ProgType = 'WINDOWEDVDM'
      when abbrev('VDM'          ,Type,  3) then ProgType = 'VDM'
      otherwise
         call Error 1011
   end /* select */

   Obj.Setup = Obj.Setup";PROGTYPE="ProgType
   return


ParseSetupStartupDir: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will parse the STARTUPDIR statement
   **/

   arg FileName .

   /* Make sure the state is valid */

   select
      when Lex.State = "BeginP" then
         nop
      otherwise
         call Error 1010
   end /* select */

   /*  See if the file exists */

   FullName = ScanForFile(FileName, "\")
   if FullName = '' then
      call Error 1009 FileName

   Obj.Setup = Obj.Setup";STARTUPDIR="FullName
   return


ParseCreateStatement: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will parse the CREATE statement
   **/

   parse arg ObjType Arguments

   parse upper var ObjType ObjType
   select
      when abbrev('PROGRAM', ObjType,  4) then
         call ParseCreateProgramStatement Arguments
      when abbrev('PGM'    , ObjType,  3) then
         call ParseCreateProgramStatement Arguments
      when abbrev('FOLDER' , ObjType,  3) then
         call ParseCreateFolderStatement Arguments
      otherwise
         call Error 1002 "CREATE" ObjType
   end /* select */
   return


ParseCreateProgramStatement: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will parse the CREATE PROGRAM statements.
   ***
   ***      CREATE PROGRAM [ "title" [ id ]]
   **/

   parse arg '"' ObjTitle '"' ObjectID

   if ObjTitle = '' then
      ObjTitle = 'Program'

   parse upper var ObjectID ObjectID
   ObjectID = strip(ObjectID)

   if ObjectID = '' then
      ObjectID = GenerateID("Program")

   Obj.Class    = "WPProgram"
   Obj.Location = Lex.Location
   Obj.Title    = ObjTitle
   Obj.Setup    = "OBJECTID=<"ObjectID">"

   Lex.State = "Program"
   return


ParseCreateFolderStatement: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will parse the CREATE FOLDER statements.
   ***
   ***      CREATE FOLDER [ "title" [ id ]]
   **/

   parse arg '"' ObjTitle '"' ObjectID

   if ObjTitle = '' then
      ObjTitle = 'Folder'

   parse upper var ObjectID ObjectID
   ObjectID = strip(ObjectID)

   if ObjectID = '' then
      ObjectID = GenerateID("Folder")

   Obj.Class    = "WPFolder"
   Obj.Location = Lex.Location
   Obj.Title    = ObjTitle
   Obj.Setup    = "OBJECTID=<"ObjectID">"

   Lex.Folder = "<"ObjectID">"
   Lex.State = "Folder"
   return


ParseBeginStatement: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will do a syntax and semantic check on the BEGIN statement
   ***
   ***      BEGIN
   **/

   parse arg Empty

   if Empty <> '' then
      call Error 4001 Empty

   /* Semantic check.  Make sure this is in the correct context */

   select
      when Lex.State = "Program" then
         Lex.State = "BeginP"
      when Lex.State = "Folder" then
         Lex.State = "BeginF"
      otherwise
         call Error 1003
   end /* select */

   return


ParseEndStatement: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will do a syntax and semantic check on the END statement
   ***
   ***      END
   **/

   parse arg Empty

   if Empty <> '' then
      call Error 4001 Empty

   /* Semantic check.  Make sure this is in the correct context */

   select
      when Lex.State = "BeginP" then
         Lex.State = "Program"
      when Lex.State = "BeginF" then
         Lex.State = "Folder"
      otherwise
         call Error 1005
   end /* select */

   /* Output the current object info */

   call OutputObject

   return


ParseNestStatement: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will do a syntax and semantic check on the '{' statement
   ***
   ***      {
   **/

   parse arg Empty

   if Empty <> '' then
      call Error 4001 Empty

   /* Semantic check.  Make sure this is in the correct context */

   select
      when Lex.State = "Folder" then
         Lex.State = "Inline"
      otherwise
         call Error 1006
   end /* select */

   /* Save the current folder on the stack */

   call PushLocation
   return


ParseUnnestStatement: procedure expose Obj. Opt. Prf. Lex.
   /**
   ***  This will do a syntax and semantic check on the '}' statement
   ***
   ***      }
   **/

   parse arg Empty

   if Empty <> '' then
      call Error 4001 Empty

   /* Semantic check.  Make sure this is in the correct context */

   call PopLocation
   return


ParseTitle: procedure
   /**
   ***  This will parse a title as an optionally quote-delimited string
   ***  value
   **/

   parse arg RawTitle

   First = left(RawTitle, 1)
   select
      when First = '"' then
         parse var RawTitle '"' Title '"' Empty
      when First = "'" then
         parse var RawTitle "'" Title "'" Empty
      otherwise
         parse var RawTitle Title Empty
   end /* select */

   /* Check for extraneous characters */

   if Empty <> '' then
      call Error 4001 Empty
   return Title


OutputObject: procedure expose Obj. Lex.
   /**
   ***  This will dump the intermediate lexical code to a temp file
   **/

   call lineout Lex.File, "C" Obj.Class
   call lineout Lex.File, "L" Obj.Location
   call lineout Lex.File, "T" Obj.Title
   call lineout Lex.File, "S" Obj.Setup
   call lineout Lex.File, "E FailIfExists"
   call lineout Lex.File, "."
   return


ParseEnvironment: procedure expose Lex.
   /**
   ***  This will parse the ENVIRONMENT verb and set the environment
   ***  variable as appropriate
   **/

   parse arg variable value

   value = strip(value)
   Ret = value(variable, value,"OS2ENVIRONMENT")
   return


PushLocation: procedure expose Lex.
   /**
   ***  This will push a new folder location on the stack.  The stem variable
   ***  Lex.Location is always the same as the top of the stack and makes
   ***  refers to the current folder into which things are being placed.
   **/

   Lex.StackLoc.0 = Lex.StackLoc.0 + 1
   i = Lex.StackLoc.0

   Lex.StackLoc.i = Lex.Folder
   Lex.Location = Lex.Folder
   return


PopLocation: procedure expose Lex.
   /**
   ***  This will pop the folder from the stack
   **/

   if Lex.StackLoc.0 > 1 then
      Lex.StackLoc.0 = Lex.StackLoc.0 - 1
   else
      call Error 1004

   i = Lex.StackLoc.0
   Lex.Location = Lex.StackLoc.i
   Lex.Folder   = Lex.StackLoc.i
   return


GenerateID: procedure
   /**
   ***  This will generate a name for the object if none is specified
   **/

   arg ObjectType .

   NextID = SysIni('USER', 'BuildSOM', 'NextObjID')
   if NextID = 'ERROR:' then
      NextID = 0

   NextID = NextID + 1
   Code = SysIni('USER', 'BuildSOM', 'NextObjID', NextID)
   if Code <> '' then
      call Error 1008

   ObjectID = "UWP_"ObjectType || right(NextID, 4, '0')
   return ObjectID


ScanForFile: procedure
   /**
   ***  This will scan for the filename passed in the places that were
   ***  listed in the second parameter.  The syntax is:
   ***
   ***        FullName = ScanForFile(Name, "[.][D][P][L]")
   ***
   ***   where:
   ***        .   - Check for existence as is
   ***        \   - Check for existence of the directory
   ***        D   - Check for existence in DPATH
   ***        P   - Check for existence in PATH
   ***        I   - Check for existence in ICONS
   ***        L   - Check for existence in LIBPATH (Not Implemented yet)
   ***
   **/

   arg FileName, Locs

   FullName = FileName

   do i = 1 to length(Locs)
      Location = substr(Locs, i, 1)
      select
         when Location = "." then
            do
            if Exists(FileName) then
               FullName = FileName
            else
               FullName = ''
            end
         when Location = "\" then
            do
            Current  = directory()
            FullName = directory(FileName)
            Current  = directory(Current)
            end
         when Location = "P" then
            FullName = SysSearchPath('PATH', FileName)
         when Location = "D" then
            FullName = SysSearchPath('DPATH', FileName)
         when Location = "I" then
            FullName = SysSearchPath('ICONS', FileName)
         otherwise
            nop
      end /* select */

      if FullName <> '' then
         return FullName
   end /* do */

   return FullName


/**
*** ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*** ³                      Error Handling Routines                       ³
*** ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
**/

Error: procedure expose Opt. Lex.
   /**
   *** Error handling routine
   **/

   parse arg Code Arguments

   select
      when Code = 1001 then
         say "Error["Code"]: Can't open" Arguments"."
      when Code = 1002 then
         say "Error["Code"]: Syntax error.  Invalid verb" Arguments "at line" Lex.Line"."
      when Code = 1003 then
         say "Error["Code"]: Unexpected BEGIN at line" Lex.Line"."
      when Code = 1004 then
         say "Error["Code"]: Nesting Error at" Lex.Line"."
      when Code = 1005 then
         say "Error["Code"]: Unexpected END at line" Lex.Line"."
      when Code = 1006 then
         say "Error["Code"]: Unexpected '{' at line" Lex.Line"."
      when Code = 1007 then
         say "Error["Code"]: The object ID is missing at line" Lex.Line"."
      when Code = 1008 then
         say "Error["Code"]: Error querying the INI file. Object IDs may be incorrectly generated"
      when Code = 1009 then
         say "Error["Code"]: Cannot find file '"Arguments"' at line" Lex.Line"."
      when Code = 1010 then
         say "Error["Code"]: Statement valid only between BEGIN/END at line" Lex.Line"."
      when Code = 1011 then
         say "Error["Code"]: Invalid session type at line" Lex.Line"."
      when Code = 1012 then
         say "Error["Code"]: Invalid 'minimize to' value at line" Lex.Line"."
      when Code = 1013 then
         say "Error["Code"]: Create of" Obj.Title "failed."
      when Code = 4001 then
         say "Warning["Code"]: Extra characters after verb found. ("Arguments") at" Lex.Line"."
      when Code = 4002 then
         do
         say "Warning["Code"]: The 'BuildSom.out' file is placed in root.  Set the TEMP"
         say "   environment variable to the directory you want the intermediate file"
         say "   placed in."
         end
      otherwise
         say "Error["Code"]:" Arguments"."
   end /* select */

   /* This will get more sophisticated later, but for now terminate on */
   /* errors and pass on warnings.                                     */

   if Code < 4000 then
      exit
   return


/**
*** ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*** ³                      General Purpose Routines                      ³
*** ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
**/


Open: procedure

   parse arg file rw

   file_ = stream(file,c,'QUERY EXIST')

   /* If the file is opened for WRITE access, delete it first */

   if (file_ \= '') then
      do
      if (rw = 'WRITE') then
         '@erase' file
      file = file_
      end

   message = stream(file,c,'OPEN' rw)
   if (message \= 'READY:') then
      do
      say 'Error: Open failure on' file'.' message
      exit
      end
   return file


Close: procedure

   parse arg file
   message = stream(file,c,'CLOSE')
   if (message \= 'READY:') & (message \= '') then
      do
      say 'Error: Close failure on' file'.' message
      exit
      end
   return file


Exists: procedure

   parse arg file

   file = stream(file,c,'QUERY EXIST')
   if (file = '') then
      return 0
   else
      return 1

LoadFunctions: procedure
   /**
   ***   This will load the DLL for the Rexx system functions supplied
   ***   with OS/2 v2.0
   **/
   call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
   call SysLoadFuncs
   return

/**
*** ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
*** º There are a couple of anomolies in this program that will be         º
*** º handled in future releases.  In the meantime, here are some          º
*** º circumventions.                                                      º
*** º                                                                      º
*** º    o  If you specify "*" for a program name (to invoke either the    º
*** º       OS/2, DOS or Windows shell), you MUST also specify a           º
*** º       SESSIONTYPE for that object well.                              º
*** º    o  The BEGIN/END pairs are required after a CREATE PROGRAM or     º
*** º       CREATE FOLDER statement.  There is no problem having nothing   º
*** º       between the BEGIN and the END statements.  I will make the     º
*** º       parser smarter in the next release.                            º
*** º                                                                      º
*** º ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ º
*** º                                                                      º
*** º Change Log                                                           º
*** º                                                                      º
*** º    10/23/1992   v1.0   Base code                                     º
*** º                                                                      º
*** ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
**/
