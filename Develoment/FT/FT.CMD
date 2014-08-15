/* **************************************************************
   File name: FT.CMD

   Version: 1.0

   Description: Rexx Program which modifies the type of a file,
                by modifying the file's .TYPE EA

   Usage: FT [FileSpec] [/a "Type" "Type"...] [/r "Type" "Type"...] [/d "Type"] [/s] [/l] [/?]
          /a - Adds all following type(s)
          /r - Removes all following type(s)
          /d - Sets the default type
          /s - Process files in subdirectories
          /l - Lists the type(s) of each file
          /? - Help screen
  ************************************************************** */

/* Get the command line arguments */
parse arg FileSpec TheRest
TheRest = ArgToUpper(TheRest)
DefaultType = ""
DeleteTypes = ""
AddTypes = ""
List = 0
if Pos("/L", TheRest) \= 0 then
do
  List = 1
  parse var TheRest TheRest "/L" EndBit
  TheRest = TheRest || EndBit
end
if Pos("/S", TheRest) \= 0 then
do
  parse var TheRest TheRest "/S"
  FileTreeOptions = "FOS"
end
else
  FileTreeOptions = "FO"
if Pos("/D", TheRest) \= 0 then
  parse var TheRest TheRest "/D" DefaultType
if Pos("/R", TheRest) \= 0 then
  parse var TheRest TheRest "/R" DeleteTypes
if Pos("/A", TheRest) \= 0 then
  parse var TheRest TheRest "/A" AddTypes

/* Add the necessary support functions */
call RxFuncAdd "SysIni", "RexxUtil", "SysIni"
call RxFuncAdd "SysFileTree", "RexxUtil", "SysFileTree"
call RxFuncAdd "SysGetEA", "RexxUtil", "SysGetEA"
call RxFuncAdd "SysPutEA", "RexxUtil", "SysPutEA"
call RxFuncAdd "SysGetKey", "RexxUtil", "SysGetKey"

say "***** FT.CMD - File Type Modifier V1.0 *****"
say "Copyright (c) Lachlan O'Dea 1994"

if FileSpec = "" | FileSpec = "/?" then
do
  call DisplayHelp
  exit
end

/* Find all the file types defined in the system */
Result = SysIni("USER", "PMWP_ASSOC_TYPE", "ALL:", "AllTypes")

/* Check parameters to find types to add */
i = 0
do while AddTypes \= ""
  i = i + 1
  parse var AddTypes '"'Add.i'"' AddTypes  /* Removes the first type of AddTypes and puts it in Add.i */
  Add.i = FindType(Add.i)
  if Add.i = "" then
    i = i - 1
end
Add.0 = i

/* Check parameters to find types to delete */
i = 0
do while DeleteTypes \= ""
  i =i + 1
  parse var DeleteTypes '"'Delete.i'"' DeleteTypes
  Delete.i = FindType(Delete.i)
  if Delete.i = "" then
    i = i - 1
end
Delete.0 = i

/* Find the files which must be changed */
Result = SysFileTree(FileSpec, "Files", FileTreeOptions)

/* Make the appropriate changes to EAs of each file */
do i = 1 to Files.0
  say
  say "Processing: " || Files.i
  /* Extract existing type info */
  Result = SysGetEA(Files.i, ".TYPE", "OrigEA")

  /* Store original types in OrigEntry */
  if OrigEA = "" then
  do
    OrigEntry.0 = 0
    NewEA = "DFFF00000000"x
  end
  else
  do
    parse var OrigEA 5 NumEntriesLoChar 6
    OrigEntry.0 = C2D(NumEntriesLoChar)
    parse var OrigEA 7 TypeInfo
    do j = 1 to OrigEntry.0
      parse var TypeInfo . 3 LengthLoChar 4 . 5 TypeInfo
      Index = C2D(LengthLoChar)
      OrigEntry.j = SubStr(TypeInfo, 1, Index)
      TypeInfo = DelStr(TypeInfo, 1, Index)
    end  /* do j */
    NewEA = OrigEA
  end

  /* Add types not already present */
  NumEntriesAdded = 0
  do j = 1 to Add.0
    call Match Add.j
    if \Word(Result, 1) then
    do
      Index = Length(NewEA)
      NewEA = Insert("FDFF"x || D2C(Length(Add.j)) || "00"x || Add.j, NewEA, Index)
      NumEntriesAdded = NumEntriesAdded + 1
      say "  Added: " || Add.j
      OrigEntry.0 = OrigEntry.0 + 1
      Index = OrigEntry.0
      OrigEntry.Index = Add.j
    end
    else
      say '  * The type "'Add.j'" was not added, as it was already present'
  end

  /* Delete specified types if they are present */ 
  do j = 1 to Delete.0
    call Match Delete.j
    parse var Result IsMatch EntryNum
    if IsMatch then
    do
      call FindEntry NewEA, EntryNum
      parse var Result Index Size
      NewEA = DelStr(NewEA, Index, Size)
      NumEntriesAdded = NumEntriesAdded - 1
      say "  Deleted: " || Delete.j
      OrigEntry.0 = OrigEntry.0 - 1
      do k = EntryNum to OrigEntry.0
        Index = k + 1
        OrigEntry.k = OrigEntry.Index
      end  /* do k */
    end  /* if IsMatch */
    else
      say '  * The type "'Delete.j'" was not deleted, as it was not present'
  end  /* do j */

  /* Update number of entries, if necessary */
  if NumEntriesAdded \= 0 then
  do
    NewEA = DelStr(NewEA, 5, 2)   /* Removes the old Number of entries */
    NewEA = Insert(D2C(OrigEntry.0) || "00"x, NewEA, 4, 2)
  end

  if DefaultType \= "" then
  do
    parse var DefaultType '"'DefaultType'"'
    DefaultType = FindType(DefaultType)
    if DefaultType \= "" then
    do
      call Match DefaultType
      parse var Result IsMatch EntryNum
      if IsMatch then
      do
        call FindEntry NewEA, EntryNum
        parse var Result Index Size
        NewEA = DelStr(NewEA, Index, Size)
        NewEA = Insert("FDFF"x || D2C(Length(DefaultType)) || "00"x || DefaultType, NewEA, 6)
        say "  Set the default type to "DefaultType
        do j = EntryNum by -1 to 2
          k = j - 1
          OrigEntry.j = OrigEntry.k
        end
        OrigEntry.1 = DefaultType
      end
      else
        say "  * The type you specified as default is not associated with this file"
    end
  end  /*  if  */

  /* Now write out the modified EA */
  call SysPutEA Files.i, ".TYPE", NewEA

  if List then
  do
    say "  " || OrigEntry.0 || " Types present:"
    do j = 1 to OrigEntry.0
      say "    "OrigEntry.j
    end
  end
end  /* do i */

say
say "*** Finished ***"
exit


/* ************************************************************** */
/* Function: FindType */
FindType:
  procedure expose AllTypes.
  parse arg Key

  BestIndex = 0
  NumEqual = 1
  do i = 1 to AllTypes.0
    Index = Compare(Key, AllTypes.i)
    if Index = 0 then
      return AllTypes.i
    if Index > BestIndex then
    do
      BestIndex = Index
      BestMatch = i
      NumEqual = 1
      EqualStr.1 = AllTypes.i
    end
    else
      if Index = BestIndex then
      do
        NumEqual = NumEqual + 1
        EqualStr.NumEqual = AllTypes.i
      end
  end  /* do i */
  if NumEqual > 1 then
  do
    say '  *** The type you specified, "'Key'", has 'NumEqual' possibilities:'
    EqualStr.0 = "None"
    Index = 0
    InKey = "0D"x
    do until InKey = "0D"x
      do i = Index to NumEqual
        if (i - Index) >= 20 | (Index \=0 & i = NumEqual) then
        do
          if (i - Index) < 20 then
            say "    ("NumEqual") " || EqualStr.NumEqual
          say "    * U: previous screen  D: next screen  <Enter>: Make a choice"
          InKey = SysGetKey("NOECHO")
          select
            when (Inkey = "U" | InKey = 'u') & Index >= 20 then
              Index = Index - 20
            when (Inkey = "D" | Inkey = "d") & Index <= NumEqual - 20 then
              Index = Index + 20
            otherwise
              nop
          end
          leave
        end
        say "    ("i") " || EqualStr.i
      end
    end
    say "  Enter a selection"
    pull Choice
    if Choice \= 0 then
      return EqualStr.Choice
    else
      return ""
  end
  return AllTypes.BestMatch
/* ************************************************************** */


/* ************************************************************** */
/* Subroutine: FindEntry */
FindEntry:
  procedure
  parse arg EA, EntryNum

  Index = 1
  do EntryNum
    Index = Pos("FDFF"x, EA, Index+1)
    if Index = 0 then
      return 0
  end
  Size = C2D(SubStr(EA, Index+2, 1)) + 4  /* Add 4 for type and size info */
  return Index Size
/* ************************************************************** */


/* ************************************************************** */
/* Function: Match */
Match:
  procedure expose OrigEntry.
  parse arg SearchEntry

  do i = 1 to OrigEntry.0
    if OrigEntry.i = SearchEntry then
      return 1 i
  end
  return 0
/* ************************************************************** */


/* ************************************************************** */
/* Function: ArgToUpper */
ArgToUpper:
  procedure
  parse arg str

  MakeUpper = 1
  RetStr = ""
  do i = 1 to Length(str)
    chr = SubStr(str, i, 1)
    if chr = '"' then
      if MakeUpper then
        MakeUpper = 0
      else
        MakeUpper = 1
    if MakeUpper & chr >= 'a' & chr <= 'z' then
      chr = D2C(C2D(chr) - 32)
    RetStr = RetStr || chr
  end /* do i */
  return RetStr
/* ************************************************************** */


/* ************************************************************** */
/* Function: DisplayHelp */
DisplayHelp:
  say "Usage:"
  say '   FT [/a "Type" "Type"...] [/r "Type" "Type"...] [/d "Type"] [/s] [/l] [/?]'
  say "   /a Specifies the types to add"
  say "   /r Specifies the types to remove"
  say "   /d Specifies a default type (must be already associated with file)"
  say "   /s Process files in subdirectories"
  say "   /l Lists the types associated with the file after processing"
  say "   /? for this help message"
  say "   Type names must be enclosed in quotes"
  say "   If type name is not complete, it is matched with the closest one"
  return
/* ************************************************************** */
