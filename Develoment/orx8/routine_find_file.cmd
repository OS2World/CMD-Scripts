/******************************************************************************/
/*
program:   routine_find_file.cmd
type:      Object REXX, REXXSAA 6.0
purpose:   filters a string to contain English alphanumeric chars only; embedded non-alphanum chars are
           translated into an underscore ("_")
version:   1.0
date:      1997-04-15
changed:   ---

author:    Rony G. Flatscher
           Rony.Flatscher@wu-wien.ac.at
           (Wirtschaftsuniversitaet Wien, University of Economics and Business
           Administration, Vienna/Austria/Europe)
needs:     ---

usage:     call or require & see code, resp. comments
           (also, you might copy & paste the code to the desired module, given its size)

comments:  prepared for the "8th International Rexx Symposium 1997", April 1997, Heidelberg/Germany


All rights reserved and copyrighted 1995-1997 by the author, no guarantee that
it works without errors, etc.  etc.

You are granted the right to use this module under the condition that you don't charge money for this module (as you didn't write
it in the first place) or modules directly derived from this module, that you document the original author (to give appropriate
credit) with the original name of the module and that you make the unaltered, original source-code of this module available on
demand.  If that holds, you may even bundle this module (either in source or compiled form) with commercial software.

If you find an error, please send me the description (preferably a *very* short example);
I'll try to fix it and re-release it to the net.
*/



/*                                                                            */
/* name:    Find_File( name[, env_var] [, extensions] )                       */
/*                                                                            */
/* purpose: find file and return fully qualified name                         */
/*                                                                            */
/* returns: .nil if not found, fully qualified name else                      */
/*                                                                            */
/* remarks: "env_var" ... environment variable containing list of paths,      */
/*                        default: "path"                                     */
/*                                                                            */
/*          "extensions" ... blank delimited list of extensions to be added,  */
/*                        if file was not found; default: ".cmd .orx .rex"    */
/*                                                                            */
/* needs:   ---                                                               */
/*          rgf, 96-09-17                                                     */

:: ROUTINE Find_File     PUBLIC
  USE ARG file_name, path, extensions

  IF \ VAR( "path" )       THEN path = ".;" || VALUE( "path", , "ENVIRONMENT" )
  IF \ VAR( "extensions" ) THEN extensions = ".cmd .orx .rex .cls"

  name = FILESPEC("Name", file_name)    /* retrieve filename itself     */

  IF name = "" THEN                     /* indicate file not found      */
     RETURN .nil
 
  foundName = search_path( name, path )
  IF foundName = .nil THEN              /* not found so far             */
  DO
     DO WHILE extensions <> ""
        PARSE VAR extensions tmpExtension extensions

        foundName = search_path( name || tmpExtension, path )
        IF foundName <> .nil THEN       /* file found                   */
           RETURN foundName
     END

     RETURN .nil
  END
  ELSE
     RETURN foundName

SEARCH_PATH : PROCEDURE
  USE ARG name, path

  DO WHILE path <> ""           /* loop thru paths, try to find file */
     PARSE VAR path cur_path ";" path

     IF RIGHT( cur_path, 1 ) = "\" THEN tmp_file = cur_path || name
                                   ELSE tmp_file = cur_path || "\" || name
     tmp_file = STREAM(tmp_file, "C", "QUERY EXISTS")
     IF tmp_file <> "" THEN
        RETURN tmp_file
  END
  RETURN .nil                   /* file not found               */
/******************************************************************************/
