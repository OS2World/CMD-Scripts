/* REXX
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³                            EditProject Version 1.00                          ³
³                                                                              ³
³                          Makefile maintenance utility                        ³
³                                                                              ³
³                               Bernhard Bablok                                ³
³                                                                              ³
³                                November, 1994                                ³
³                                                                              ³
³   See the file license.txt for details on the legal stuff. See the file      ³
³   epro.doc for details on usage.                                             ³
³                                                                              ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

SIGNAL ON ERROR   NAME cleanup
SIGNAL ON FAILURE NAME cleanup
SIGNAL ON HALT    NAME cleanup
SIGNAL ON SYNTAX  NAME cleanup

PARSE ARG Project.file
CALL startup
CALL VDialogPos 50, 50

IF Project.file = '' THEN
  CALL SelectProject
ELSE DO
  Project.file = STRIP(Project.file)
  CALL SysFileTree Project.file, 'count', 'FO'
  IF count.0 = 0 THEN DO                       /* project file doesn't exist! */
    extension = SUBSTR(Project.file,LASTPOS('.',Project.file)+1)
    IF extension = Project.file THEN
       Project.file = Project.file'.emx'       /* default extension is emx    */
    SelectProject.template = Project.file
    CALL SelectProject
    IF RESULT > 0 THEN DO
      Project.name = '.unnamed'
      SelectProject.template = '*.emx'
      main.vstring = 1
    END
  END
  ELSE DO
     CALL ReadProject
     IF RESULT > 0 THEN DO
       Project.name = '.unnamed'
       SelectProject.template = '*.emx'
       main.vstring = 1
     END
  END
END
CALL MainMenu
CALL cleanup                     /* exits this REXX!  ----------------------- */

/*----------------------------------------------------------------------------*/
/* PutLine: Write a line to the project file                                  */
/*----------------------------------------------------------------------------*/
PutLine:

PARSE ARG text
IF text = '' THEN
  text = ' '

DO WHILE LENGTH(text) > 78
  splitpos = LASTPOS(' ',text,78)
  CALL LINEOUT Project.file, SUBSTR(text,1,splitpos-1) '\'
  text = COPIES(' ',11) SUBSTR(text,splitpos+1)
END
CALL LINEOUT Project.file, text
RETURN

/*----------------------------------------------------------------------------*/
/* FindIncludes: Search file for all included user files                      */
/*----------------------------------------------------------------------------*/
FindIncludes: PROCEDURE EXPOSE user_includes Project.dir

ARG name

CALL SysFileSearch '#include', name,'includes.'         /* search for include */
DO j = 1 TO includes.0                                  /* in all files       */
  word2 = WORD(includes.j,2)
  IF SUBSTR(word2,1,1) = '"' &,                         /* user include file  */
                 VERIFY(word2,'/\','M') = 0 THEN DO     /* in project dir     */
    include_file = STRIP(word2,'B','"')
    IF WORDPOS(include_file,user_includes) = 0 THEN DO  /* add only if not    */
       user_includes = user_includes include_file       /* already in list    */
       CALL FindIncludes Project.dir||include_file      /* recursive call     */
    END
  END
END

extension = SUBSTR(name,LASTPOS('.',name)+1)
IF WORDPOS(extension,'C CC CPP CXX H HPP') = 0 THEN DO  /* the rest is for    */
                                                        /* resource files only*/
  DROP includes.
  CALL SysFileSearch 'RCINCLUDE', name,'includes.'      /* RCINCLUDE          */
  DO j = 1 TO includes.0
     word2 = WORD(includes.j,2)
     IF VERIFY(word2,'/\ ','M') = 0 THEN DO             /* in project dir     */
       include_file = STRIP(word2,'B','"')
       IF WORDPOS(include_file,user_includes) = 0 THEN DO
          user_includes = user_includes include_file
          CALL FindIncludes Project.dir||include_file
       END
    END
  END

  DROP includes.
  CALL SysFileSearch 'DLGINCLUDE', name,'includes.'     /* DLGINCLUDE         */
  DO j = 1 TO includes.0
     word3 = WORD(includes.j,3)
     IF VERIFY(word3,'/\ ','M') = 0 THEN DO             /* in project dir     */
       include_file = STRIP(word3,'B','"')
       IF WORDPOS(include_file,user_includes) = 0 THEN DO
          user_includes = user_includes include_file
          CALL FindIncludes Project.dir||include_file
       END
    END
  END

  DROP includes.
  CALL SysFileSearch 'BITMAP', name,'includes.'         /* BITMAP             */
  DO j = 1 TO includes.0
     lastword = WORD(includes.j,WORDS(includes.j))
     IF VERIFY(lastword,'/\ ','M') = 0 THEN DO          /* in project dir     */
       include_file = STRIP(lastword,'B','"')
       IF WORDPOS(include_file,user_includes) = 0 THEN DO
          user_includes = user_includes include_file
          CALL FindIncludes Project.dir||include_file
       END
    END
  END

  DROP includes.
  CALL SysFileSearch 'ICON', name,'includes.'           /* ICON               */
  DO j = 1 TO includes.0
     lastword = WORD(includes.j,WORDS(includes.j))
     IF VERIFY(lastword,'/\ ','M') = 0 THEN DO          /* in project dir     */
       include_file = STRIP(lastword,'B','"')
       IF WORDPOS(include_file,user_includes) = 0 THEN DO
          user_includes = user_includes include_file
          CALL FindIncludes Project.dir||include_file
       END
    END
  END

  DROP includes.
  CALL SysFileSearch 'POINTER', name,'includes.'        /* POINTER            */
  DO j = 1 TO includes.0
     lastword = WORD(includes.j,WORDS(includes.j))
     IF VERIFY(lastword,'/\ ','M') = 0 THEN DO          /* in project dir     */
       include_file = STRIP(lastword,'B','"')
       IF WORDPOS(include_file,user_includes) = 0 THEN DO
          user_includes = user_includes include_file
          CALL FindIncludes Project.dir||include_file
       END
    END
  END

END

RETURN

/*----------------------------------------------------------------------------*/
/* startup: Initialize functions and variables                                */
/*----------------------------------------------------------------------------*/
startup:

EditProject.version  = 1.00
EditProject.make     = 'make'
UserAddedCode.0      = 0

main.0       = 10
main.1       = 'Select project'
main.2       = 'Select target type'
main.3       = 'Resource file'
main.4       = 'Module definition file'
main.5       = 'Add files'
main.6       = 'Delete files'
main.7       = 'Build options'
main.8       = 'Compiler options'
main.9       = 'Link options'
main.10      = 'Make'

SelectProject.title    = 'Select project'
SelectProject.template = '*.emx'

SelectTargetType.title   = 'Select target type'
SelectTargetType.0       = 4
SelectTargetType.1       = 'EXE'
SelectTargetType.2       = 'PM-EXE'
SelectTargetType.3       = 'DLL'
SelectTargetType.4       = 'LIB'
SelectTargetType.vstring = SelectTargetType.1

ResourceFile.title    = 'Resource File'
ResourceFile.width    = 40
ResourceFile.0        = 2
ResourceFile.1        = 'Enter the name of the resource file  '
ResourceFile.2        = 'or clear the entry field:'

ModuleFile.title    = 'Module definition file'
ModuleFile.width    = 45
ModuleFile.0        = 2
ModuleFile.1        = 'Enter the name of the module definition  '
ModuleFile.2        = 'file or clear the entry field: '

AddFiles.title    = 'Add file'
AddFiles.template = '*.c'

sources.0      = 0
sources.title  = 'Added files'
sources.back   = 'BLUE'
sources.fore   = 'WHITE'
sources.type   = 'SYSTEM'                             /* font                 */
sources.size   = 10                                   /* pitch                */
sources.left   = 1                                    /* position of window   */
sources.bottom = 5
sources.right  = 20
sources.top    = 95
sources.diff   = 25                                   /* distance betw. lines */
sources.all    = ''                                   /* all sources          */

DeleteFiles.title  = 'Delete files'
DeleteFiles.width  = 20
DeleteFiles.height = 10

BuildOption.title  = 'Build-Mode'
BuildOption.0      = 2
BuildOption.1      = 'Debug'
BuildOption.2      = 'Production'

CompilerOptions.title    = 'Compiler options'
CompilerOptions.prompt.0 = 3
CompilerOptions.prompt.1 = 'Global options:'
CompilerOptions.prompt.2 = 'Debug options:'
CompilerOptions.prompt.3 = 'Production options:'

CompilerOptions.width.0  = 3
CompilerOptions.width.1  = 60
CompilerOptions.width.2  = 60
CompilerOptions.width.3  = 60

CompilerOptions.hide.    = 0
CompilerOptions.hide.0   = 3

CompilerOptions.return.0 = 3

LinkOptions.title    = 'Link options'
LinkOptions.prompt.0 = 3
LinkOptions.prompt.1 = 'Global options:'
LinkOptions.prompt.2 = 'Debug options:'
LinkOptions.prompt.3 = 'Production options:'

LinkOptions.width.0  = 3
LinkOptions.width.1  = 60
LinkOptions.width.2  = 60
LinkOptions.width.3  = 60

LinkOptions.hide.    = 0
LinkOptions.hide.0   = 3

LinkOptions.return.0 = 3

/*----------------------------------------------------------------------------*/
/* Definitions for message boxes                                              */
/*----------------------------------------------------------------------------*/

SaveProject.title  = 'Save project'
SaveProject.0      = 2
SaveProject.1      = 'Project information has changed.'
SaveProject.2      = 'Save information?'

NotImplemented.title = 'Sorry!'
NotImplemented.0     = 1
NotImplemented.1     = 'Option not implemented'

WrongVersion.title = 'Sorry!'
WrongVersion.0     = 1
WrongVersion.1     = 'No EditProject makefile or wrong version'
WrongVersion.2     = 'wrong version'

DeleteFileProblem.title = 'Problem!'
DeleteFileProblem.0 = 2
DeleteFileProblem.1 = 'Could not delete old makefile!'
DeleteFileProblem.2 = 'Change access flags and try again.'

UnnamedProject.title = 'Problem!'
UnnamedProject.0     = 2
UnnamedProject.1     = 'No name defined for project!'
UnnamedProject.2     = 'Define a name and try again.'

/*----------------------------------------------------------------------------*/
/* Initialize REXX-function-package                                           */
/*----------------------------------------------------------------------------*/

IF RxFuncQuery('SysLoadFuncs') THEN DO
  CALL RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
  CALL SysLoadFuncs
END

/*----------------------------------------------------------------------------*/
/* Initialize VREXX-function-package                                          */
/*----------------------------------------------------------------------------*/

CALL RxFuncAdd 'VInit', 'VREXX', 'VInit'
RC = VInit()
IF RC = 'ERROR' THEN
  SIGNAL cleanup

OK       = 1
CANCEL   = 2
OKCANCEL = 3
YES      = 4
NO       = 5
YESNO    = 6

RETURN

/*----------------------------------------------------------------------------*/
/* SetDefaults: Set project-defaults for a new project                        */
/*----------------------------------------------------------------------------*/
SetDefaults:

Project.mode                      = SUBSTR(BuildOption.1,1,1)
Project.TargetType                = 'EXE'
Project.ResourceFile              = ''
Project.ModuleFile                = ''
Project.GlobalCompilerOptions     = ''
Project.DebugCompilerOptions      = ''
Project.ProductionCompilerOptions = ''
Project.GlobalLinkOptions         = ''
Project.DebugLinkOptions          = ''
Project.ProductionLinkOptions     = ''
Project.status                    = 'SAVED'          /* no changes yet!       */
sources.all                       = ''
sources.0                         = 0

RETURN 0

/*----------------------------------------------------------------------------*/
/* SetupRules: Define rules (depending on compiler)                           */
/*----------------------------------------------------------------------------*/
SetupRules: PROCEDURE EXPOSE target.

ARG environment

SELECT
   WHEN environment = 'EMX' THEN DO
      TT = 'MAKE_VARS'
      target.TT.1  = 'ifeq ($(findstring -Zomf,$($(MODE)_CFLAGS)',
                                                           '$(G_CFLAGS)),-Zomf)'
      target.TT.2  = 'O  = .obj'
      target.TT.3  = 'AR = emxomfar'
      target.TT.4  = 'else'
      target.TT.5  = 'O = .o'
      target.TT.6  = 'AR = ar'
      target.TT.7  = 'endif'
      target.TT.8  = 'CC = gcc'
      target.TT.0  = 8

      TT = 'PM-EXE'
      target.TT.1  = 'main_target : $(PROJECT).exe'
      target.TT.2  = 'ifeq ($(O),.obj)'
      target.TT.3  = '$(PROJECT).exe :: $(OBJECTS) $(MODULE_FILE)'
      target.TT.4  = '	$(CC) $(OBJECTS:%=$(OBJ_DIR)%) $(G_LFLAGS)',
                            '$($(MODE)_LFLAGS) $(MODULE_FILE) -o $(PROJECT).exe'
      target.TT.5  = '$(PROJECT).exe :: $(RES_FILE)'
      target.TT.6  = '	rc $(RES_FILE) $(PROJECT).exe'
      target.TT.7  = 'else'
      target.TT.8  = '$(PROJECT).exe : $(PROJECT).out $(RES_FILE)',
                                                                 '$(MODULE_FILE)'
      target.TT.9  = '	emxbind -b -d$(MODULE_FILE)',
                                               '-r$(RES_FILE) $(PROJECT).out'
      target.TT.10 = ' '
      target.TT.11 = '$(PROJECT).out : $(OBJECTS)'
      target.TT.12 = '	$(CC) $(OBJECTS:%=$(OBJ_DIR)%) $(G_LFLAGS)',
                                           '$($(MODE)_LFLAGS) -o $(PROJECT).out'
      target.TT.13 = 'endif'
      target.TT.0  = 13

      TT = 'EXE'
      target.TT.1  = 'main_target : $(PROJECT).exe'
      target.TT.2 = '$(PROJECT).exe : $(OBJECTS) $(MODULE_FILE)'
      target.TT.3 = '	$(CC) $(OBJECTS:%=$(OBJ_DIR)%) $(G_LFLAGS)',
                            '$($(MODE)_LFLAGS) $(MODULE_FILE) -o $(PROJECT).exe'
      target.TT.0 = 3

      TT = 'DLL'
      target.TT.1  = 'main_target : $(PROJECT).dll'
      target.TT.2 = '$(PROJECT).dll : $(OBJECTS) $(MODULE_FILE)'
      target.TT.3 = '	$(CC) $(OBJECTS:%=$(OBJ_DIR)%) $(G_LFLAGS)',
                            '$($(MODE)_LFLAGS) $(MODULE_FILE) -o $(PROJECT).dll'
      target.TT.0 = 3

      TT = 'LIB'
      target.TT.1  = 'main_target : $(PROJECT).lib'
      target.TT.2 = '$(PROJECT).lib : $(OBJECTS)'
      target.TT.3 = '	$(AR) rc $(PROJECT).lib $?'
      target.TT.0 = 3

      TT = 'RESOURCE'
      target.TT.1 = '%.RES : %.rc'
      target.TT.2 = '	rc -r $<'
      target.TT.0 = 2

      TT = 'OBJECTS'
      target.TT.1 = '	$(CC) $(G_CFLAGS) $($(MODE)_CFLAGS) -c $< -o $(OBJ_DIR)$(@F)'
      target.TT.0 = 1
   END
   WHEN environment = 'GCC' THEN DO
      TT = 'MAKE_VARS'
      target.TT.1  = 'O  = .obj'
      target.TT.2  = 'AR = glib'
      target.TT.3  = 'CC = gcc'
      target.TT.0  = 3

      TT = 'PM-EXE'
      target.TT.1  = 'main_target : $(PROJECT).exe'
      target.TT.2  = '$(PROJECT).exe :: $(OBJECTS) $(MODULE_FILE)'
      target.TT.3  = '	$(CC) $(OBJECTS:%=$(OBJ_DIR)%) $(G_LFLAGS)',
                            '$($(MODE)_LFLAGS) $(MODULE_FILE) -o $(PROJECT).exe'
      target.TT.4  = '$(PROJECT).exe :: $(RES_FILE)'
      target.TT.5  = '	rc $(RES_FILE) $(PROJECT).exe'
      target.TT.0  = 5

      TT = 'EXE'
      target.TT.1  = 'main_target : $(PROJECT).exe'
      target.TT.2 = '$(PROJECT).exe : $(OBJECTS) $(MODULE_FILE)'
      target.TT.3 = '	$(CC) $(OBJECTS:%=$(OBJ_DIR)%) $(G_LFLAGS)',
                            '$($(MODE)_LFLAGS) $(MODULE_FILE) -o $(PROJECT).exe'
      target.TT.0 = 3

      TT = 'DLL'
      target.TT.1  = 'main_target : $(PROJECT).dll'
      target.TT.2 = '$(PROJECT).dll : $(OBJECTS) $(MODULE_FILE)'
      target.TT.3 = '	$(CC) $(OBJECTS:%=$(OBJ_DIR)%) $(G_LFLAGS)',
                            '$($(MODE)_LFLAGS) $(MODULE_FILE) -o $(PROJECT).dll'
      target.TT.0 = 3

      TT = 'LIB'
      target.TT.1  = 'main_target : $(PROJECT).lib'
      target.TT.2 = '$(PROJECT).lib : $(OBJECTS)'
      target.TT.3 = '	$(AR) $(PROJECT).lib $(patsubst %,-a %,$?)'
      target.TT.0 = 3

      TT = 'RESOURCE'
      target.TT.1 = '%.RES : %.rc'
      target.TT.2 = '	rc -r $<'
      target.TT.0 = 2

      TT = 'OBJECTS'
      target.TT.1 = '	$(CC) $(G_CFLAGS) $($(MODE)_CFLAGS) -c $< -o $(OBJ_DIR)$(@F)'
      target.TT.0 = 1
   END
   WHEN environment = 'ICC' THEN DO
      TT = 'MAKE_VARS'
      target.TT.1  = 'O  = .obj'
      target.TT.2  = 'AR = lib'
      target.TT.3  = 'CC = icc'
      target.TT.0  = 3

      TT = 'PM-EXE'
      target.TT.1  = 'main_target : $(PROJECT).exe'
      target.TT.2  = '$(PROJECT).exe :: $(OBJECTS) $(MODULE_FILE)'
      target.TT.3  = '	$(CC) $(G_LFLAGS) $($(MODE)_LFLAGS) /Fe$(PROJECT).exe',
                          '$(subst /,\,$(OBJECTS:%=$(OBJ_DIR)%)) $(MODULE_FILE)'
      target.TT.4  = '$(PROJECT).exe :: $(RES_FILE)'
      target.TT.5  = '	rc $(RES_FILE) $(PROJECT).exe'
      target.TT.0  = 5

      TT = 'EXE'
      target.TT.1  = 'main_target : $(PROJECT).exe'
      target.TT.2 = '$(PROJECT).exe : $(OBJECTS) $(MODULE_FILE)'
      target.TT.3  = '	$(CC) $(G_LFLAGS) $($(MODE)_LFLAGS) /Fe$(PROJECT).exe',
                          '$(subst /,\,$(OBJECTS:%=$(OBJ_DIR)%)) $(MODULE_FILE)'
      target.TT.0 = 3

      TT = 'DLL'
      target.TT.1  = 'main_target : $(PROJECT).dll'
      target.TT.2 = '$(PROJECT).dll : $(OBJECTS) $(MODULE_FILE)'
      target.TT.3  = '	$(CC) $(G_LFLAGS) $($(MODE)_LFLAGS) /Fe$(PROJECT).dll',
                          '$(subst /,\,$(OBJECTS:%=$(OBJ_DIR)%)) $(MODULE_FILE)'
      target.TT.0 = 3

      TT = 'LIB'
      target.TT.1  = 'main_target : $(PROJECT).lib'
      target.TT.2 = '$(PROJECT).lib : $(OBJECTS)'
      target.TT.3 = '	$(AR) /NOI /NOLOGO $(PROJECT).lib',
                                          '$(patsubst %,-+%,$(subst /,\,$?)),,;'
      target.TT.0 = 3

      TT = 'RESOURCE'
      target.TT.1 = '%.RES : %.rc'
      target.TT.2 = '	rc -r $<'
      target.TT.0 = 2

      TT = 'OBJECTS'
      target.TT.1 = '	$(CC) /C+ $(G_CFLAGS) $($(MODE)_CFLAGS)',
                                                         '/Fo$(OBJ_DIR)$(@F) $<'
      target.TT.0 = 1
   END
   WHEN environment = 'BCC' THEN DO
      TT = 'MAKE_VARS'
      target.TT.1  = 'O  = .obj'
      target.TT.2  = 'AR = tlib'
      target.TT.3  = 'CC = bcc'
      target.TT.0  = 3

      TT = 'PM-EXE'
      target.TT.1  = 'main_target : $(PROJECT).exe'
      target.TT.2  = '$(PROJECT).exe :: $(OBJECTS) $(MODULE_FILE)'
      target.TT.3  = '	$(CC) $(G_LFLAGS) $($(MODE)_LFLAGS) -e$(PROJECT)',
                      '$(subst /,\,$(OBJECTS:%=$(OBJ_DIR)%)) -sD=$(MODULE_FILE)'
      target.TT.4  = '$(PROJECT).exe :: $(RES_FILE)'
      target.TT.5  = '	rc $(RES_FILE) $(PROJECT).exe'
      target.TT.0  = 5

      TT = 'EXE'
      target.TT.1  = 'main_target : $(PROJECT).exe'
      target.TT.2 = '$(PROJECT).exe : $(OBJECTS)'
      target.TT.3  = '	$(CC) $(G_LFLAGS) $($(MODE)_LFLAGS) -e$(PROJECT)',
                                         '$(subst /,\,$(OBJECTS:%=$(OBJ_DIR)%))'
      target.TT.0 = 3

      TT = 'DLL'
      target.TT.1  = 'main_target : $(PROJECT).dll'
      target.TT.2 = '$(PROJECT).dll : $(OBJECTS) $(MODULE_FILE)'
      target.TT.3  = '	$(CC) $(G_LFLAGS) $($(MODE)_LFLAGS) -e$(PROJECT)',
                      '$(subst /,\,$(OBJECTS:%=$(OBJ_DIR)%)) -sD=$(MODULE_FILE)'
      target.TT.0 = 3

      TT = 'LIB'
      target.TT.1  = 'main_target : $(PROJECT).lib'
      target.TT.2 = '$(PROJECT).lib : $(OBJECTS)'
      target.TT.3 = '	$(AR) /C $(PROJECT).lib',
                                          '$(patsubst %,-+%,$(subst /,\,$?)),,;'
      target.TT.0 = 3

      TT = 'RESOURCE'
      target.TT.1 = '%.RES : %.rc'
      target.TT.2 = '	rc -r $<'
      target.TT.0 = 2

      TT = 'OBJECTS'
      target.TT.1 = '	$(CC) -c $(G_CFLAGS) $($(MODE)_CFLAGS)',
                                              '-o$(OBJ_DIR)$(basename $(@F)) $<'
      target.TT.0 = 1
   END
   OTHERWISE
      NOP
END
RETURN

/*----------------------------------------------------------------------------*/
/* ReadProject: Read makefile of existing project                             */
/*----------------------------------------------------------------------------*/
ReadProject:

DROP UserAddedCode.
UserAddedCode.0 = 0

line = LINEIN(Project.file)
line = LINEIN(Project.file)
IF WORD(line,5) <> 'EditProject' | WORD(line,7) < 0.6 THEN DO
  CALL VMsgBox WrongVersion.title, WrongVersion, OK
  DROP makefile.
  RETURN 16
END

CALL SetDefaults
DO WHILE LINES(Project.file) > 0
  line = LINEIN(Project.file)
  IF LENGTH(line) = 0 THEN
    ITERATE
  DO WHILE SUBSTR(line,LENGTH(line),1) = '\'
     line = SUBSTR(line,1,LENGTH(line)-1) LINEIN(Project.file)
  END
  SELECT
    WHEN WORD(line,1) = 'MODE' THEN
      Project.mode = SUBSTR(line,WORDINDEX(line,3),1)

    WHEN WORD(line,1) = 'G_CFLAGS' THEN DO
      IF WORD(line,3) <> '' THEN
        Project.GlobalCompilerOptions = SUBSTR(line,WORDINDEX(line,3))
      ELSE
        Project.GlobalCompilerOptions = ''
    END
    WHEN WORD(line,1) = 'D_CFLAGS' THEN DO
      IF WORD(line,3) <> '' THEN
        Project.DebugCompilerOptions = SUBSTR(line,WORDINDEX(line,3))
      ELSE
        Project.DebugCompilerOptions = ''
    END
    WHEN WORD(line,1) = 'P_CFLAGS' THEN DO
      IF WORD(line,3) <> '' THEN
        Project.ProductionCompilerOptions = SUBSTR(line,WORDINDEX(line,3))
      ELSE
        Project.ProductionCompilerOptions = ''
    END

    WHEN WORD(line,1) = 'G_LFLAGS' THEN DO
      IF WORD(line,3) <> '' THEN
        Project.GlobalLinkOptions = SUBSTR(line,WORDINDEX(line,3))
      ELSE
        Project.GlobalLinkOptions = ''
    END
    WHEN WORD(line,1) = 'D_LFLAGS' THEN DO
      IF WORD(line,3) <> '' THEN
        Project.DebugLinkOptions = SUBSTR(line,WORDINDEX(line,3))
      ELSE
        Project.DebugLinkOptions = ''
    END
    WHEN WORD(line,1) = 'P_LFLAGS' THEN DO
      IF WORD(line,3) <> '' THEN
        Project.ProductionLinkOptions = SUBSTR(line,WORDINDEX(line,3))
      ELSE
        Project.ProductionLinkOptions = ''
    END

    WHEN WORD(line,1) = 'RC_FILE' THEN DO
      IF WORD(line,3) <> '' THEN
        Project.ResourceFile = SUBSTR(line,WORDINDEX(line,3))
      ELSE
        Project.ResourceFile = ''
    END

    WHEN WORD(line,1) = 'MODULE_FILE' THEN DO
      IF WORD(line,3) <> '' THEN
        Project.ModuleFile = SUBSTR(line,WORDINDEX(line,3))
      ELSE
        Project.ModuleFile = ''
    END

    WHEN WORD(line,1) = 'TARGET_TYPE' THEN DO
      IF WORD(line,3) <> '' THEN
        Project.TargetType = SUBSTR(line,WORDINDEX(line,3))
      ELSE
        Project.TargetType = ''
    END

    WHEN WORD(line,1) = 'SOURCES' THEN DO
      IF WORD(line,3) <> '' THEN
        sources.all = SPACE(SUBSTR(line,WORDINDEX(line,3)))
      ELSE
        sources.all = ''
      sources.0 = STRIP(WORDS(sources.all))
      DO i = 1 TO sources.0
        sources.i = STRIP(WORD(sources.all,i))
      END
    END

    WHEN WORD(line,1) = 'VPATH' THEN DO
      Project.dir = TRANSLATE(WORD(line,3)'/','\','/')
    END

    WHEN POS('User added code after this line is preserved.',line) > 0 THEN DO
      i = 0
      DO WHILE LINES(Project.file) > 0
         i = i + 1
         UserAddedCode.i = LINEIN(Project.file)
      END
      UserAddedCode.0 = i
    END
    OTHERWISE NOP
  END
END
CALL LINEOUT Project.file

main.vstring   = main.5
Project.name   = FILESPEC("name",Project.file)
PARSE VALUE Project.name WITH Project.Project '.' Project.environment
Project.environment = TRANSLATE(Project.environment)
CALL SetupRules Project.environment
SelectProject.template = Project.dir'*.'Project.environment

RETURN 0

/*----------------------------------------------------------------------------*/
/* cleanup: Release of VREXX-resources                                        */
/*----------------------------------------------------------------------------*/
cleanup:

IF CONDITION() <> '' THEN DO
   SAY 'Internal error in REXX. Please communicate the following information'
   SAY 'as well as any information on how to reproduce the error to the author:'
   SAY '  B.Bablok, Internet: ua302cb@sunmail.lrz-muenchen.de'
   SAY 'Thank you!'
   SAY 'Error in line' SIGL '(RC='RC'):' ERRORTEXT(RC)
   SAY 'Condition:  ' CONDITION('C')
   SAY 'Description:' CONDITION('D')
   TRACE ?R
END
CALL VExit
EXIT

/*----------------------------------------------------------------------------*/
/* MainMenu: Show a dialog-box until CANCEL                                   */
/*----------------------------------------------------------------------------*/
MainMenu:

DO FOREVER
  CALL VRadioBox  'Project 'project.name, main, OKCANCEL
  IF RESULT = 'CANCEL' THEN DO
    IF project.status = 'CHANGED' THEN DO
      CALL VMsgBox SaveProject.title, SaveProject, YESNO
      IF RESULT = 'YES' THEN DO
        CALL WriteProject
        IF RESULT = 0 THEN
          LEAVE
      END
      ELSE
        LEAVE
    END
    ELSE
      LEAVE
  END
  ELSE DO
    SELECT
      WHEN main.vstring = main.1 THEN
        CALL SelectProject
      WHEN main.vstring = main.2 THEN
        CALL SelectTargetType
      WHEN main.vstring = main.3 THEN
        CALL ResourceFile
      WHEN main.vstring = main.4 THEN
        CALL ModuleFile
      WHEN main.vstring = main.5 THEN
        CALL AddFiles
      WHEN main.vstring = main.6 THEN
        CALL DeleteFiles
      WHEN main.vstring = main.7 THEN
        CALL DefineBuildOption
      WHEN main.vstring = main.8 THEN
        CALL DefineCompilerOptions
      WHEN main.vstring = main.9 THEN
        CALL DefineLinkOptions
      WHEN main.vstring = main.10 THEN
        CALL ExecuteMakefile
      OTHERWISE DO
        CALL VMsgBox NotImplemented.title, NotImplemented, OK
      END    /* OTHERWISE DO */
    END    /* SELECT */
  END    /* ELSE DO */
END    /* DO FOREVER */

RETURN

/*----------------------------------------------------------------------------*/
/* SelectProject: Display a file selection box for the makefile               */
/*----------------------------------------------------------------------------*/
SelectProject:

IF project.status = 'CHANGED' THEN DO
  CALL VMsgBox SaveProject.title, SaveProject, YESNO
  IF RESULT = 'YES' THEN DO
    CALL WriteProject
    IF RESULT > 0 THEN
      RETURN
  END
END

Project.vstring = Project.file
CALL VFileBox SelectProject.title, SelectProject.template, 'Project'
IF RESULT <> 'CANCEL' THEN DO
   Project.status = 'CHANGED'
   Project.file   = Project.vstring

   Project.name   = FILESPEC("name",Project.vstring)
   PARSE VALUE Project.name WITH Project.project '.' Project.environment
   Project.environment = TRANSLATE(Project.environment)

   Project.dir    = FILESPEC("drive",Project.vstring) ||,
                    FILESPEC("path",Project.vstring)
   SelectProject.template = Project.dir'*.'Project.environment

   CALL SysFileTree Project.file, 'count', 'FO'
   IF count.0 = 0 THEN DO                      /* project file doesn't exist! */
     CALL SetDefaults
     CALL SetupRules Project.environment
   END
   ELSE DO
     CALL ReadProject
     IF RESULT > 0 THEN DO
       Project.name = '.unnamed'
       SelectProject.template = '*.emx'
       main.vstring = 1
     END
   END
   DROP count.
   RETURN 0
END
RETURN 1

/*----------------------------------------------------------------------------*/
/* SelectTargetType: Select type of target                                    */
/*----------------------------------------------------------------------------*/
SelectTargetType:

SelectTargetType.vstring = Project.TargetType
CALL VRadioBox  SelectTargetType.title, SelectTargetType, OKCANCEL
IF RESULT <> 'CANCEL' THEN DO
   Project.status = 'CHANGED'
   Project.TargetType = SelectTargetType.vstring
END

RETURN

/*----------------------------------------------------------------------------*/
/* ResourceFile: Select resource file for the application                     */
/*----------------------------------------------------------------------------*/
ResourceFile:

ResourceFile.vstring = Project.ResourceFile
CALL VInputBox ResourceFile.title,'ResourceFile', ResourceFile.width, OKCANCEL
IF RESULT <> 'CANCEL' THEN DO
   Project.status = 'CHANGED'
   Project.ResourceFile = FILESPEC("name",ResourceFile.vstring)
   IF POS('.RC',TRANSLATE(Project.ResourceFile)) = 0 THEN
     Project.ResourceFile = Project.ResourceFile'.rc'
END
RETURN

/*----------------------------------------------------------------------------*/
/* ModuleFile: Select module definition file for the application              */
/*----------------------------------------------------------------------------*/
ModuleFile:

ModuleFile.vstring = Project.ModuleFile
CALL VInputBox ModuleFile.title,'ModuleFile', ModuleFile.width, OKCANCEL
IF RESULT <> 'CANCEL' THEN DO
   Project.status = 'CHANGED'
   Project.ModuleFile = FILESPEC("name",ModuleFile.vstring)
   IF POS('.DEF',TRANSLATE(Project.ModuleFile)) = 0 THEN
     Project.ModuleFile = Project.ModuleFile'.def'
END
RETURN

/*----------------------------------------------------------------------------*/
/* AddFiles: Add source-files to the project                                  */
/*----------------------------------------------------------------------------*/
AddFiles:

sources.id = VOpenWindow(sources.title,sources.back,sources)
CALL VSetFont sources.id, sources.type, sources.size
sources.linenr = 1000

CALL VForeColor sources.id, sources.fore
DO i = 1 TO sources.0
  sources.linenr = sources.linenr - sources.diff
  CALL VSay sources.id, 5, sources.linenr, sources.i
END

DO FOREVER
   CALL VFileBox AddFiles.title, Project.dir||AddFiles.template, 'AddFiles'
   IF RESULT = 'CANCEL' THEN
     LEAVE
   ELSE IF WORDPOS(FILESPEC("name",AddFiles.vstring),sources.all) = 0 THEN DO
     Project.status = 'CHANGED'
     sources.0      = sources.0 + 1
     i              = sources.0
     sources.i      = FILESPEC("name",AddFiles.vstring)
     sources.all    = sources.all sources.i
     sources.linenr = sources.linenr - sources.diff
     CALL VForeColor sources.id, sources.fore
     CALL VSay       sources.id, 5, sources.linenr, sources.i
     AddFiles.template = "*" || SUBSTR(sources.i,LASTPOS(".",sources.i))
   END   /* ELSE DO */
END    /* DO FOREVER */

CALL VCloseWindow sources.id
RETURN

/*----------------------------------------------------------------------------*/
/* DeleteFiles: Remove files from project list                                */
/*----------------------------------------------------------------------------*/
DeleteFiles:

DO FOREVER
  IF words(sources.all) = 0 THEN
    LEAVE
  CALL VListBox DeleteFiles.title, sources, DeleteFiles.width,,
                DeleteFiles.height, OKCANCEL
  IF RESULT = 'CANCEL' THEN
    LEAVE
  ELSE DO
    Project.status = 'CHANGED'
    IF WORDS(sources.all) = 1 THEN
      sources.all = ''
    ELSE
      sources.all = DELWORD(sources.all,WORDPOS(sources.vstring,sources.all),1)
    DO i=1 TO sources.0
      IF sources.i <> sources.vstring THEN
        ITERATE
      ELSE DO
        IF sources.0 = 1 THEN DO
          sources.0 = 0
          sources.1 = ''
        END
        ELSE DO
          sources.0 = sources.0 - 1
          DO i=i TO sources.0
            nexti = i + 1
            sources.i = sources.nexti
          END
        END          /* ELSE DO (IF sources.0 = 1)               */
        LEAVE        /* DO i=1 TO sources.0                      */
      END          /* ELSE DO  (IF sources.i <> sources.vstring) */
    END          /* DO i=1 TO sources.0                          */
  END          /* ELSE DO                                        */
END          /* DO FOREVER                                       */

RETURN

/*----------------------------------------------------------------------------*/
/* DefineBuildOption: Choose between debug- and production-mode               */
/*----------------------------------------------------------------------------*/
DefineBuildOption:

IF Project.mode = 'D' THEN
  BuildOption.vstring = BuildOption.1
ELSE
  BuildOption.vstring = BuildOption.2
CALL VRadioBox BuildOption.title, BuildOption, OKCANCEL
IF RETURN <> 'CANCEL' THEN DO
  Project.status = 'CHANGED'
  IF BuildOption.vstring = BuildOption.1 THEN
    Project.mode = 'D'
  ELSE
    Project.mode = 'P'
END
RETURN

/*----------------------------------------------------------------------------*/
/* DefineCompilerOptions: Define compiler options (global, debug, production) */
/*----------------------------------------------------------------------------*/
DefineCompilerOptions:

CompilerOptions.return.1 = Project.GlobalCompilerOptions
CompilerOptions.return.2 = Project.DebugCompilerOptions
CompilerOptions.return.3 = Project.ProductionCompilerOptions

CALL VMultBox CompilerOptions.title, CompilerOptions.prompt, CompilerOptions.width,,
              CompilerOptions.hide, CompilerOptions.return, OKCANCEL
IF RESULT <> 'CANCEL' THEN DO
  Project.status                    = 'CHANGED'
  Project.GlobalCompilerOptions     = CompilerOptions.return.1
  Project.DebugCompilerOptions      = CompilerOptions.return.2
  Project.ProductionCompilerOptions = CompilerOptions.return.3
END
RETURN

/*----------------------------------------------------------------------------*/
/* DefineLinkOptions: flags and libs for the linker                           */
/*----------------------------------------------------------------------------*/
DefineLinkOptions:

LinkOptions.return.1 = Project.GlobalLinkOptions
LinkOptions.return.2 = Project.DebugLinkOptions
LinkOptions.return.3 = Project.ProductionLinkOptions

CALL VMultBox LinkOptions.title, LinkOptions.prompt, LinkOptions.width,,
              LinkOptions.hide, LinkOptions.return, OKCANCEL
IF RESULT <> 'CANCEL' THEN DO
  Project.status                = 'CHANGED'
  Project.GlobalLinkOptions     = LinkOptions.return.1
  Project.DebugLinkOptions      = LinkOptions.return.2
  Project.ProductionLinkOptions = LinkOptions.return.3
END
RETURN

/*----------------------------------------------------------------------------*/
/* WriteProject: Generate the makefile                                        */
/*----------------------------------------------------------------------------*/
WriteProject:

IF Project.name = '.unnamed' THEN DO
  CALL VMsgBox UnnamedProject.title, UnnamedProject, OK
  RETURN 1
END

/* check for user-includes   ------------------------------------------------ */

DO i = 1 TO sources.0
  user_includes = ''
  CALL FindIncludes Project.dir||sources.i
  dependents.i = sources.i user_includes
END

/* check for includes and dlgincludes   ------------------------------------- */

IF Project.ResourceFile <> '' THEN DO
   user_includes = ''
   CALL FindIncludes Project.dir||Project.ResourceFile
   ResourceDependents = Project.ResourceFile user_includes
END

IF SysFileDelete(Project.file) > 2 THEN DO
  CALL VMsgBox DeleteFileProblem.title, DeleteFileProblem, OK
  RETURN 1
END

CALL PutLine '# ============== Do not edit between these lines! ================'
CALL PutLine '# Makefile generated by EditProject Version' EditProject.version
CALL PutLine '# Project:' Project.project
CALL PutLine '# Date:   ' DATE()
CALL PutLine '# Time:   ' TIME()
CALL PutLine ' '
CALL PutLine 'PROJECT =' Project.project
CALL PutLine 'MODE =' Project.mode

CALL PutLine 'G_CFLAGS =' Project.GlobalCompilerOptions
CALL PutLine 'D_CFLAGS =' Project.DebugCompilerOptions
CALL PutLine 'P_CFLAGS =' Project.ProductionCompilerOptions

CALL PutLine 'G_LFLAGS =' Project.GlobalLinkOptions
CALL PutLine 'D_LFLAGS =' Project.DebugLinkOptions
CALL PutLine 'P_LFLAGS =' Project.ProductionLinkOptions

TT = 'MAKE_VARS'                    /*  make-variables (environment specific) */
DO i = 1 TO target.TT.0
  CALL PutLine target.TT.i
END

CALL PutLine 'SOURCES =' sources.all
CALL PutLine 'RC_FILE =' Project.ResourceFile
CALL PutLine 'RES_FILE = $(subst .rc,.RES,$(RC_FILE))'
CALL PutLine 'MODULE_FILE =' Project.ModuleFile
CALL PutLine 'TARGET_TYPE =' Project.TargetType

CALL PutLine 'C_OBJECTS   = $(patsubst %.c,%$(O),$(filter %.c,$(SOURCES)))'
CALL PutLine 'CC_OBJECTS  = $(patsubst %.cc,%$(O),$(filter %.cc,$(SOURCES)))'
CALL PutLine 'CPP_OBJECTS = $(patsubst %.cpp,%$(O),$(filter %.cpp,$(SOURCES)))'
CALL PutLine 'OBJECTS    := $(C_OBJECTS) $(CC_OBJECTS) $(CPP_OBJECTS)'

CALL PutLine 'VPATH   =' STRIP(TRANSLATE(Project.dir,'/','\'),'T','/')
CALL PutLine 'OBJ_DIR = $(VPATH)/obj$(MODE)/'
CALL PutLine 'vpath %$(O) $(OBJ_DIR)'
CALL PutLine ' '
CALL PutLine '# ============== Do not edit between these lines! ================'
CALL PutLine ' '

CALL PutLine '.PHONY : all main_target'
CALL PutLine 'all:'
CALL PutLine '	$(MAKE) -f' project.name '-C $(VPATH) main_target'
CALL PutLine ' '

TT = Project.TargetType            /* main target rule (environment specific) */
DO i = 1 TO target.TT.0
  CALL PutLine target.TT.i
END

TT = 'OBJECTS'                         /* object rules (environment specific) */
IF POS(".c ",sources.all" ") > 0 THEN DO
   CALL PutLine ' '
   CALL PutLine '$(C_OBJECTS) : %$(O) : %.c'
   DO i = 1 TO target.TT.0
     CALL PutLine target.TT.i
   END
END
IF POS(".cc ",sources.all" ") > 0 THEN DO
   CALL PutLine ' '
   CALL PutLine '$(CC_OBJECTS) : %$(O) : %.cc'
   DO i = 1 TO target.TT.0
     CALL PutLine target.TT.i
   END
END
IF POS(".cpp ",sources.all" ") > 0 THEN DO
   CALL PutLine ' '
   CALL PutLine '$(CPP_OBJECTS) : %$(O) : %.cpp'
   DO i = 1 TO target.TT.0
     CALL PutLine target.TT.i
   END
END

IF Project.ResourceFile <> '' THEN DO
   TT = 'RESOURCE'
   CALL PutLine ' '
   DO i = 1 TO target.TT.0
     CALL PutLine target.TT.i
   END
   CALL PutLine ' '
   CALL PutLine,
            SUBSTR(Project.ResourceFile,1,LASTPOS('.',Project.ResourceFile)) ||,
                                                      "RES :" ResourceDependents
END

DO i=1 TO sources.0                      /* generated dependencies            */
  CALL PutLine ' '
  CALL PutLine SUBSTR(sources.i,1,LASTPOS('.',sources.i)-1)'$(O) :' dependents.i
END

CALL PutLine ' '
CALL PutLine '# == Do not delete this line.',
                              'User added code after this line is preserved. =='
IF UserAddedCode.0 > 0 & UserAddedCode.1 <> '' THEN
   CALL PutLine ' '
DO i = 1 TO UserAddedCode.0
  CALL PutLine UserAddedCode.i
END
CALL LINEOUT Project.file

Project.status = 'SAVED'
RETURN 0

/*----------------------------------------------------------------------------*/
/* ExecuteMakeFile: Run MAKE with current build option                        */
/*----------------------------------------------------------------------------*/
ExecuteMakeFile:

IF project.status = 'CHANGED' THEN DO
  CALL VMsgBox SaveProject.title, SaveProject, YESNO
  IF RESULT = 'YES' THEN DO
    CALL WriteProject
    IF RESULT > 0 THEN
      RETURN
  END
END

"START /c /win" EditProject.make,
      "-k -f" TRANSLATE(Project.file,'/','\') "MODE="Project.mode
RETURN
