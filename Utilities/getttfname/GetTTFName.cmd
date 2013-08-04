/* Displays the font name of a True-Type Font File            */
/* by using the <name> table contained in TTF files           */
/* ---------------------------------------------------------- */
/* Syntax: GetTTFName <filespec> [/s]                         */
/*         where <filespec> is a file name (or wildcard)      */
/*           and /s optionally searches subdirectories        */
/* (So this works pretty much like the DIR command...)        */
/* ---------------------------------------------------------- */
/* Version 1.00 : Created 2004-01-12 by Th.Klein              */
/*                Should work flawlessly                      */
/*                Nevertheless: USE AT YOUR OWN RISK! ;)      */
/* .......................................................... */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

/*-------------------------*/
/* command-line parsing... */
/*-------------------------*/
   parse arg parameters

/* if no parameters specified: display syntax scheme (and quit) */
   if strip(parameters) = "" then signal Syntax

/* set up parameters for SysFileTree depending on whether /S is used */                      
   parHow = "FO"
   if wordpos("/S", translate(parameters)) \= 0 then parHow = "FOS"

/* get file list. */
   call SysFileTree word(parameters, 1), "Files", parHow

/* if no files found, display message (and quite) */
   if Files.0 = 0 then signal NoFiles

/* otherwise process all found files */
   do f = 1 to Files.0
      call ProcessFile Files.f
   end

/* unload rexxutil-funcs + quit */
   call SysDropFuncs  
   exit 0

/*------------------------*/
/* processing of ONE file */
/*------------------------*/
ProcessFile:
   parse arg fname

   /* load entire file into variable                   */
   /* this implies OPENing it (= using 1 file handle)  */
   /* thus, we must CLOSE it later to free that handle */
   /* or we'll run into troubles by exhausting handles */
   file=charin(fname, 1, chars(fname))

   /* get number of contained tables */
   numtables=shortchar(substr(file,5,2))

   /* search for the 'name' table */
   taboff = 0
   do toffset = 13 to ((numtables - 1) * 16 + 13) by 16
      table = substr(file, toffset, 16)
      if translate(substr(table, 1, 4)) = "NAME" then
       do
         taboff = longchar(substr(table, 9, 4))
         leave
       end
    end

   /* determine how to proceed with that file */
   if taboff = 0 then
     say fname ': <No name table found>'
   else
     call ProcessTable taboff

   /* Now close the current file to free the handle used */
   call stream fname, 'c', 'CLOSE'

/* return to parent routine */
return 0

/*------------------------------------------*/
/* Process the NAME table found in the file */
/*------------------------------------------*/
ProcessTable:
   parse arg off

   /* we currently hold the name table's header:                   */
   /* besides other stuff, it holds the number of records          */
   /* and the offset to the actual strings, but this is 'relative' */
   /* by referring to the start position of THIS TABLE             */

   /* get number of records in name table */
   numrecs = shortchar(substr(file, off + 3, 2))

   /* re-calculate the string offset from start of file  */
   /* thus, we'll have an ABSOLUTE position to work with */
   stringoff = off + shortchar(substr(file, off + 5, 2)) + 1

   /* process the name records:                                  */
   /* read Encoding flag, Language ID, name ID, length of string */
   /*      and the offset of string within string table          */
   recoff = off + 7
   do i = 1 to numrecs
      rec = substr(file, recoff, 12)
      nameenc.i = shortchar(substr(rec, 3, 2))
      namelang.i = shortchar(substr(rec, 5, 2))
      nameid.i = shortchar(substr(rec, 7, 2))
      namelen.i = shortchar(substr(rec, 9, 2))
      nameoff.i = shortchar(substr(rec, 11, 2))
      recoff = recoff + 12
   end

   /* initialize some variables */
   fontname=""
   fontfamily=""
   fontstyle=""

   /* scan all name records and check only entries that are in */
   /* ENGLISH ("0") or GERMAN ("2", if any...)                 */
   do e = 1 to numrecs
   if verify(namelang.e, "02") \= 0 then iterate
      /* okay, get the associated string from the string table */
      currname = substr(file, nameoff.e + stringoff, namelen.e)
      /* use string if its type is one of those required */
      select
       when nameid.e = 4
            then fontname = currname
       when nameid.e = 1
            then fontfamily = currname
       when nameid.e = 2
            then fontstyle = currname
       otherwise
            nop
      end
   end

   /* if no FONTNAME string was found, create the fontname based */
   /* upon FONTFAMILY and FONTSTYLE                              */
   if fontname = "" then fontname = fontfamily || " " || fontstyle

   /* if all fails, create some kind of "error-flagged" name: */
   if fontname = "" then fontname = "#?#"||filespec("N", fname)

   /* display the name (removing DBCS/unicode code byte first) */
   say fname ": <"ununi(fontname)">"

/* return to parent function */
return 0

/* returns the uShort value for a string (=2 bytes) */
shortchar:
 parse arg short
 hibyte = c2d(left(short,1))
 lobyte = c2d(right(short,1))
 return hibyte * 256 + lobyte

/* returns the uLong value for a string (=4 bytes) */
longchar:
 parse arg long
 hival = shortchar(left(long, 2))
 loval = shortchar(right(long, 2))
 return hival * 65536 + loval

/* removes DBCS-low values from a unicode string (I hope...) */
/* For some strange reason, this didn't work with            */
/*    SPACE(unicodestring, 0, "00"x)                         */
/* So we'll do it manually...                                */
ununi:
 parse arg unicodestring
 if c2d(left(unicodestring,1)) \= 0 then return unicodestring
 retval = ""
 do p = 2 to length(unicodestring) by 2
   retval = retval || substr(unicodestring, p, 1)
 end
 return new

/* Display syntax scheme and quits with return code 16 */
Syntax:
say "Syntax: GetTTFName <filespec> [/s]"
say "        where <filespec> is a file name (or wildcard)"
say "        and /s optionally searches in subdirectories"
exit 16

/* Displays message and quits with return code 8 */
NoFiles:
say "No files found matching your criteria..."
exit 8

