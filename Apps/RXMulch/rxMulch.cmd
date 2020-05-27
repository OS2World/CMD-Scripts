/* 
program: rxMulch.cmd
type:    REXXSAA-OS/2, version 2.x
purpose: find/change strings in a file, allow for hex-characters
         (program to find/replace characters (strings) in file; allows
         definition of hexadecimal or decimal value of single characters)

version: 1.0
date:    1994-01-08

author:  Rony G. Flatscher,
         Wirtschaftsuniversit„t/Vienna
         Rony.Flatscher@wu-wien.ac.at

needs:   DATERGF.CMD, all RexxUtil-function loaded (automatically loaded, if needed)
   
usage:
    rxMulch [infile] [outfile] {[-]controlfile | /[-]switch}
      infile:      if missing from STDIN:                         
   
      outfile:     if missing, RxMulch will replace infile;       
                   if no infile than output to STDOUT:            
   
      controlfile OR switch MUST be present:

      controlfile: change for every search-string/replace-string line the  
                   'search-string' into 'replace-string'; if more than one 
                   search/replace-line is given, subsequent search/replaces
                   start from the beginning.                      
                   If the controlfile is preceded with a minus (-) the  
                   meaning of the 'search-string' and 'replace-string' is  
                   swapped.                                       
                   If a line is empty or if there is a semi-colon (;) at the very
                   first column, the line is treated as a comment.
                                                                  
                                                                  
      switch:      If the switch is preceded with a minus (-) the meaning of  
                   the 'search-string' and 'replace-string' is swapped. 
   
                   'C'search-string/replace-string                
                   ... Change all occurrences of 'search-string' to  
                       'replace-string'.                          
   
                   '[L[1|2|3|4|5]][H[1|2]]'                       
                   ...  change low-/high-characters to any of the following
                        representations:                          
   
                        L: change all low-char values c2d(0-32)   
                            L .... defaults to L1                 
                            L1 ... char(0-32) to decimal          
                            L2 ... char(0-32) to hexadecimal      
                            L3 ... char(0-32) to control-sequence 
                            L4 ... char(0-32) to abbreviated comm-characters  
                            L5 ... char(0-32) to all representations above 
   
                        H: change all high-char values c2d(128-255)  
                            H  ... defaults to H1                 
                            H1 ... char(128-255) to decimal       
                            H2 ... char(128-255) to hexadecimal   
   
                        The appropriate search-string/replace-string pairs are
                        generated automatically.                  
   
                   'F'search-string/replace-string                
                   ... count the number of occurrences of 'search-string'  
   
      search-string/replace-string:                               
                  (delimiter)search-values(delimiter)replace-values(delimiter)
   
            delimiter:                                            
                   very first character in search-string/replace-string IMMEDIATELY
                   following switch-character
   
            search-values                                         
            replace-values:                                       
                   any ASCII-string intermixed with the following escape-codes
   
                   escape-codes:                                  
                       @C    ... CR                               
                       @L    ... LF                               
                       @T    ... TAB                              
                       @E    ... ESC                              
                       @Z    ... CTL-Z                            
                       @@    ... @ (escape for @)                 
                       @Xnn                                       
                       @Hnn  ... char with the hexadecimal of value 'nn'
                       @Dnnn ... char with the decimal value 'nnn'

   RxMulch can be called as a function from another REXX-program, e.g.

      some_variable = RxMulch(REXXstring, "[/][-]switch")

   
   examples:                                                          
   
       rxMulch infile outfile controlfile                            
           ... change 'infile' according to 'controlfile', place results into 
               'outfile'
   
       rxMulch infile controlfile                                    
           ... change 'infile' according to 'controlfile', place results into 
               'infile' (i.e. replace 'infile' itself)               
   
       rxMulch < some_in_file > some_out_file controlfile            
           ... change 'some_in_file' according to 'controlfile', place results
               into 'some_out_file'; 'some_in_file' and 'some_out_file' are
               redirected ('<' and '>'). rxMulch therefore can be used in pipes
               too.                                                  
   
       rxMulch infile outfile1 /C.Microsoft Excel.Lotus 1-2-3.       
           ... change 'infile' according to commandline switch (replace all
               occurrences of 'Microsoft Excel' with 'Lotus 1-2-3'), place 
               results into 'outfile1'                               
   
       rxMulch outfile1 outfile2 /-C.Microsoft Excel.Lotus 1-2-3.    
           ... change 'outfile1' according to commandline switch (replace all 
               occurrences of 'Lotus 1-2-3' with 'Microsoft Excel', note the  
               minus (-) right before the switch-character), place results into  
               'outfile2'; could be also expressed as:               
                     rxMulch outfile1 outfile2 /C.Lotus 1-2-3.Microsoft Excel.
   
       rxMulch infile /C.;.@c@l.                                     
           ... change 'infile' according to commandline switch (replace 
               semicolons (;) with a carriage-return/linefeed), replace 
               'infile'; could be also expressed as:                 
                     rxMulch infile /C.;.@xd@xa.                     
                     rxMulch infile /C.;.@x0d@x0a.                   
                     rxMulch infile /C.;.@d13@d10.                   
   
       rxMulch infile /C.@c@l@c@l.@c@l.                              
           ... change 'infile' according to commandline switch (replace 
               consecutive carriage-return/linefeeds with one        
               carriage-return/linefeed, i.e. remove one empty line), replace 
               'infile'; could be also expressed as:                 
                     rxMulch infile /C.@xd@xa@xd@xa.@xd@xa.          
                     rxMulch infile /C!@d13@d10@d13@d10!@d13@d10!    
                     rxMulch infile /C/@d13@d10@d13@d10/@c@l/        
   
       rxMulch infile /-C.@c@l@c@l.@c@l.                             
           ... change 'infile' according to commandline switch (replace a  
               carriage-return/linefeed with two consecutive         
               carriage-return/linefeeds, i.e. insert an empty line after each
               line), replace 'infile'; could be also expressed as:  
                     rxMulch infile /C,@c@l,@c@l@c@l,                
                     rxMulch infile /C=@x0d@x0a=@x0d@x0a@x0dx@0a=    
                     rxMulch infile /C=@d13@d10=@d13@d10@x0dx@0a=    
   
       rxMulch infile /C=@x00@x00@x00@x00=@x01@x01@x01@x01=          
           ... change 'infile' according to commandline switch (replace all
               hexadecimal strings of 0x00000000 with 0x01010101), replace 
               'infile'; could be also expressed as:                 
                     rxMulch infile /C=@x0@x0@x0@x0=@x1@x1@x1@x1=    
                     rxMulch infile /C/@d0@d0@d0@d0/@d1@d1@d1@d1/    
   
       rxMulch infile /F.OS/2.                                       
           ... count occurrences of string 'OS/2' in 'infile'          
   
       rxMulch infile /F.@c@l@c@l.                                   
           ... count number of lines in 'infile', which are immediately
               followed by a blank line  

   examples for calling RxMulch from a REXX-procedure:
       string1 = 'this is nice'
       string2 = RxMulch(string1, '/c.this.that.')  /* change 'this' to 'that' */
           ... string2 = 'that is nice'
       string2 = RxMulch(string2, '/-c.this.that.') /* change 'that' to 'this' */
           ... string2 = 'this is nice'
       occurrences = RxMulch(string2, 'f.this.')    /* count 'this' in string2 */
           ... occurrences = 1


All rights reserved, copyrighted 1994, no guarantee that it works without
errors, etc. etc.

donated to the public domain granted that you are not charging anything (money
etc.) for it and derivates based upon it, as you did not write it,
etc. if that holds you may bundle it with commercial programs too

you may freely distribute this program, granted that no changes are made
to it and that DATERGF.CMD is being distributed with it.

Please, if you find an error, post me a message describing it, I will
try to fix and rerelease it to the net.

*/


SIGNAL ON ERROR
SIGNAL ON HALT

global.         = ""            /* default for empty array-elements */
global.eTotalOfNeedles = 0      /* number of search/replace-needles */
global.eTotalOfChanges = 0      /* sum of all changes */
global.eDirection = 1           /* regular, i.e. first needle to be replaced with second */
delimiter = ""
mode = ""                       /* "F" find, "C" change, i.e. replacement */
writeFile = 1                   /* write results to file */
readFile  = 1                   /* read from file */

PARSE SOURCE op_sys global.eCall_type proc_name .

/* check whether RxFuncs are loaded, if not, load them */    
IF RxFuncQuery('SysLoadFuncs') THEN                          
DO                                                           
    /* load the load-function */                             
    CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
                                                             
    /* load all Sys* utilities in RexxUtil */
    CALL SysLoadFuncs
END                                                          


IF global.eCall_type = "FUNCTION" THEN
DO
   tmpVar1 = ARG(1)             /* data to be worked on */
   IF LEFT(ARG(2), 1) <> "/" THEN       /* in case "/" is not supplied */
      arg2 = ARG(2)
   ELSE
      arg2    = SUBSTR(ARG(2), 2)       /* command-string without leadin "/" */

   writeFile = 0                /* no file to be produced */
   readFile  = 0                /* do not read from file */
END
ELSE
   PARSE ARG arg1 "/"arg2          /* control-string on command-line ?     */


IF arg2 <> "" THEN              /* parse arguments with control-string on command-line */
DO
   full_control_string = "/" || arg2
   IF LEFT(arg2, 1) = "-" THEN
   DO
      global.eDirection = 0      /* inverse, i.e. swap meaning of from-needle and to-needle */
      arg2 = SUBSTR(arg2, 2)
   END

   tmp1 = TRANSLATE(LEFT(arg2, 1))

   IF tmp1 = "C" THEN        /* needle & replacement is given on command-line */
   DO
     active_switch = "C"
     delimiter = SUBSTR(arg2, 2, 1)
     /* without "C" */
     CALL parse_replacement_string SUBSTR(arg2, 2), "command line"
     mode = "C"
   END
   ELSE IF tmp1 = "F" THEN      /* count occurrences of given needle */
   DO
     delimiter = SUBSTR(arg2, 2, 1)                             /* get delimiter */
     tmp_string = SUBSTR(arg2, 2) || delimiter || delimiter     /* make sure, that enough delimiters are supplied */
     CALL parse_replacement_string tmp_string, "command"
     mode = "F"                 /* mode is "find" all occurrences */
     writeFile = 0              /* don't write to a file */
   END
   ELSE                         /* needles & replacements to built automatically */
   DO
      tmp2 = TRANSLATE(SUBSTR(arg2, 2, 1))
      tmp3 = TRANSLATE(SUBSTR(arg2, 3, 1))
      tmp4 = TRANSLATE(SUBSTR(arg2, 4, 1))

      tmpL = (tmp1 = 'L') | (tmp2 = 'L') | (tmp3 = 'L') 
      tmpH = (tmp1 = 'H') | (tmp2 = 'H') | (tmp3 = 'H') 

      IF tmpL THEN              /* replace low-chars: d2c(0-32) */
      DO
         arg2 = TRANSLATE(arg2)
         /* is "L" followed by a number ? If so, extract it */
         tmpLnr = SUBSTR(arg2, POS("L", SUBSTR(arg2, 1, 3)) + 1, 1)

         IF \DATATYPE(tmpLnr, "NUMERIC") THEN tmpLnr = ""

         CALL build_low tmpLnr          /* build the translation strings */
      END

      IF tmpH THEN              /* replace high-chars: d2c(128-255) */
      DO
         arg2 = TRANSLATE(arg2)
         /* is "H" followed by a number ? If so, extract it */
         tmpHnr = SUBSTR(arg2, POS("H", SUBSTR(arg2, 1, 3)) + 1, 1)

         IF \DATATYPE(tmpHnr, "NUMERIC") THEN tmpHnr = ""
         CALL build_high tmpHnr         /* build the translation strings */
      END

      IF \(tmpL | tmpH) THEN            /* wrong switch ! */
         SIGNAL usage

     mode = "CLH"
   END

   global.eControl = ""                 /* no control-file */
   PARSE VAR arg1 global.eFilein global.eFileout .
END
ELSE                            /* parse a control file ************************/
DO
   PARSE ARG global.eFilein global.eFileout global.eControl

   IF global.eControl = "" THEN         /* no control-file given ? */
   DO
      IF global.eFileout = "" THEN      /* no output-file given */
      DO
         IF global.eFilein = "" THEN    /* no input-file given, now we are in trouble */
         DO
            SIGNAL usage
         END
         ELSE                   /* assign files */
         DO
            global.eControl = global.eFilein    /* last file is control-file */
            global.eFilein  = ""        /* user wants to read/write stdin/stdout */
         END
      END
      ELSE
      DO
         global.eControl = global.eFileout                 /* last file is control-file */
         global.eFileout = ""                      /* user wants to overwrite global.eFilein */
      END
   END

   IF LEFT(global.eControl, 1) = "-" THEN
   DO
      global.eDirection = 0                /* inverse */
      global.eControl = SUBSTR(global.eControl, 2)         /* get rid of "-" */
   END

   IF global.eFileout = global.eFilein THEN global.eFileout = ""   /* replace input file */
END

/* remove leading & trailing spaces */
global.eFilein  = STRIP(global.eFilein)
global.eFileout = STRIP(global.eFileout)
global.eControl = STRIP(global.eControl)                   

IF readFile & (global.eFilein <> "") THEN       /* check, whether input file exists */
DO
   IF (STREAM(global.eFilein, "C", "QUERY EXISTS") = "") THEN
      CALL say_error global.eFilein || ": input-file does not exist !", -1
END

/* erase output-file, if it exists */
IF (global.eFileout <> "") & writeFile THEN
DO
   IF (STREAM(global.eFileout, "C", "QUERY EXISTS") <> "") THEN
   DO
      CALL BEEP 550, 250
      CALL say2stderr "Output file [" || global.eFileout || "] exists already !"
      CALL say2stderr "Overwrite it ? (Y/N)"
      IF TRANSLATE(SysGetKey()) <> "Y" THEN
         EXIT
   
      ADDRESS CMD "@del" global.eFileout
      CALL say2stderr 
      CALL say2stderr "Output File [" || global.eFileout || "] deleted."
      CALL say2stderr 
   END
END

IF global.eControl <> "" THEN           /* check whether control-file exists */
DO
   IF STREAM(global.eControl, "C", "QUERY EXISTS") = "" THEN
   DO
      /* control-file not found: 
           if control file was given *WITHOUT* path and drive, lookup the drive and
           path of RxMulch.CMD and try to get the control-file from there
      */
      IF FILESPEC("Name", global.eControl) = global.eControl THEN
      DO
         PARSE SOURCE . . this_proc
         global.eControl = FILESPEC("Drive", this_proc) || FILESPEC("PATH", this_proc) || global.eControl
      END

      IF STREAM(global.eControl, "C", "QUERY EXISTS") = "" THEN
         CALL say_error global.eFilein || ": control-file does not exist !", -2
   END
   CALL parse_control_file global.eControl      /* build search/replace-values from control-file */
END
/*
ELSE
   CALL parse_control_file global.eControl      /* build search/replace-values from control-file */
*/


IF readFile & global.eFilein <> "" THEN
DO
   CALL STREAM global.eFilein, "C", "OPEN READ"    /* open input-file */

   IF global.eFileout = "" & writeFile THEN
   DO
      global.eTmp = SysTempFileName("tmp???")
      global.eFileout     = global.eTmp
   END
END

IF global.eFileout <> "" & writeFile THEN
   CALL STREAM global.eFileout, "C", "OPEN WRITE"  /* open output-file */

start_read = DATE("S") TIME()

IF readFile & global.eFilein = "" THEN     /* read from stdin: */
DO
   tmpVar1 = ""
   DO WHILE STREAM('STDIN:','S') == 'READY'     /* read from stdin: */
        tmpVar1 = tmpVar1 || CHARIN("STDIN:", , 131072)     /* read 4096 * 32 = 128KB to speed things up */
   END

   IF tmpVar1 = "" THEN
      CALL say_error "no data from stdin: received", -100

  global.eFilein  = "STDIN:"
  global.eFileout = "STDOUT:"
END
ELSE IF readFile THEN  /* read entire file into variable */
    tmpVar1  = CHARIN(global.eFilein, 1, STREAM(global.eFilein, "C", "QUERY SIZE"))

end_read = DATE("S") TIME()

IF global.eCall_type <> "FUNCTION" THEN
DO
   IF readFile THEN
      CALL say2stderr RIGHT("Input-File:", 30)   "[" || global.eFilein  || "]"
   IF writeFile THEN
      CALL say2stderr RIGHT("Output-File:", 30)  "[" || global.eFileout || "]"
   
   IF global.eControl <> "" THEN
   DO
      CALL say2stderr RIGHT("global.eControl-File:", 30) "[" || global.eControl || "]"
      CALL say2stderr
      CALL say2stderr RIGHT("", 30) global.eTotalOfNeedles "needle(s) to be replaced."
   END
   ELSE
   DO
      CALL say2stderr RIGHT("global.eControl-Command Line:", 30) "[" || full_control_string || "]"
      IF \(delimiter == "") THEN
         CALL say2stderr RIGHT("", 30) "needle-delimiter: [" || delimiter || "]"
      CALL say2stderr 

      IF mode = "C" THEN                /* change mode */
      DO
         CALL say2stderr RIGHT("replacing:", 41) "[" || global.1.eDebug_In || "]"
         CALL say2stderr RIGHT("with:", 41) "[" || global.1.eDebug_Out || "]"
         CALL say2stderr 
         CALL say2stderr RIGHT("", 30) global.eTotalOfNeedles "needle(s) to be replaced."
      END
      ELSE IF mode = "CLH" THEN         /* automatic change mode, low/high values */
      DO
         CALL say2stderr RIGHT("replacing:", 41) "[CHAR(0-32) or/and CHAR(128-255)]"
         CALL say2stderr 
         CALL say2stderr RIGHT("", 30) global.eTotalOfNeedles "needle(s) to be replaced."
      END
      ELSE IF mode = "F" THEN   
      DO
         CALL say2stderr RIGHT("looking for:", 43) "[" || global.1.eDebug_In || "]"
      END
   END
END


start_replace = DATE("S") TIME()

/*
   save space on large files, hence minimize usage of variable assignments
*/
bDirty = 0                               /* bDirty, if replacements happened */
IF mode = "F" THEN                      
DO
   DO i = 1 TO global.eTotalOfNeedles   /* find all search/replace-strings */
      CALL find_needles global.i.eNeedle_In, global.i.eNeedle_Out
   END
END
ELSE
DO
   tmpVar2 = ""
   bWorkOnTmpVar1 = 1                   /* work on variable "tmpVar1" or "tmpVar2" */
   DO i = 1 TO global.eTotalOfNeedles   /* process all search/replace-strings */
      IF bWorkOnTmpVar1 THEN
         CALL work_on_tmpVar1 global.i.eNeedle_In, global.i.eNeedle_Out
      ELSE
         CALL work_on_tmpVar2 global.i.eNeedle_In, global.i.eNeedle_Out
   
      IF bDirty THEN
         bWorkOnTmpVar1 = \bWorkOnTmpVar1
   END
END

end_replace = DATE("S") TIME()

IF readFile THEN
   CALL STREAM global.eFilein, "C", "CLOSE"     /* close input file */

start_write = DATE("S") TIME()


IF global.eCall_type = "FUNCTION" THEN          /* was called as a function */
DO
   IF mode <> "F" THEN
   DO
     IF bWorkOnTmpVar1 THEN             /* result in variable "tmpVar1" */
        RETURN tmpVar1
     ELSE                               /* result in variable "tmpVar2" */
        RETURN tmpVar2
   END

   RETURN global.eTotalOfChanges        /* return number of occurrences found */
END

IF writeFile THEN                       /* write output file */
DO
   IF mode <> "F" THEN
   DO
     IF global.eTotalOfChanges <> 0 THEN
     DO
        IF bWorkOnTmpVar1 THEN             /* result in variable "tmpVar1" */
           CALL CHAROUT global.eFileout, tmpVar1
        ELSE                               /* result in variable "tmpVar2" */
           CALL CHAROUT global.eFileout, tmpVar2
     END
     ELSE       /* no replacements took place, erase output-file */
     DO
        IF STREAM(global.eFileout) = "READY" THEN
           CALL STREAM global.eFileout, "C", "CLOSE"    /* close output file */

        ADDRESS CMD "@del" global.eFileout
     END
   END
   
   IF STREAM(global.eFileout) = "READY" THEN
      CALL STREAM global.eFileout, "C", "CLOSE"    /* close output file */
END

end_write = DATE("S") TIME()

IF global.eTmp <> "" & writeFile THEN   /* output file was temporary, replacement of input file sought */
DO
   CALL SysFileDelete(global.eFilein)           /* delete input file */
   ADDRESS CMD "@ren" global.eFileout global.eFilein    /* rename output to input name */
END

total_time   = calc_time(start_read, end_write)
read_time    = calc_time(start_read, end_read)

IF writeFile THEN
   write_time   = calc_time(start_write, end_write)

replace_time = calc_time(start_replace, end_replace)

IF mode <> "F" THEN
   CALL say2stderr RIGHT("", 30) global.eTotalOfChanges "occurrence(s) replaced."
ELSE
   CALL say2stderr RIGHT("", 30) global.eTotalOfChanges "occurrence(s) found."

CALL say2stderr 
CALL say2stderr RIGHT("time for reading file:", 30)  read_time

IF mode <> "F" THEN
   CALL say2stderr RIGHT("time for replacing:", 30)     replace_time

IF writeFile THEN
   CALL say2stderr RIGHT("time for writing file:", 30)  write_time

CALL say2stderr
CALL say2stderr RIGHT("total time:", 30)             total_time

EXIT




/*********************************************************************************
   search string and replace it, if found, return tmpVar2 string

   EXPOSE both strings, so no copies of them need to be produced in this procedure
   (could be deadly on multi-MB-files in terms of speed)
*/
WORK_ON_TMPVAR1: PROCEDURE EXPOSE global. tmpVar1 tmpVar2 bDirty
    from_needle  = ARG(1)
    to_needle    = ARG(2)

    from_needle_length = LENGTH(from_needle)      /* get length of search-string */
    start = 1           /* start position in tmpVar1 */
    bDirty = 0           /* does a change occur ? */
    tmpVar2   = ""

    DO FOREVER
       pos = POS(from_needle, tmpVar1, start)         /* get position of search-string */
       IF pos = 0 THEN                          /* search-string not found */
       DO
          IF bDirty THEN
             tmpVar2 = tmpVar2 || SUBSTR(tmpVar1, start)
          LEAVE            /* done, no from_needle found */
       END

       tmpVar2 = tmpVar2 || SUBSTR(tmpVar1, start, pos-start) || to_needle
       global.eTotalOfChanges = global.eTotalOfChanges + 1
       start = pos + from_needle_length
       bDirty = 1                /* change occurred ! */
    END

    RETURN


WORK_ON_TMPVAR2: PROCEDURE EXPOSE global. tmpVar2 tmpVar1 bDirty
    from_needle = ARG(1)
    to_needle   = ARG(2)

    from_needle_length = LENGTH(from_needle)      /* get length of search-string */
    start = 1           /* start position in tmpVar2 */
    bDirty = 0           /* does a change occur ? */
    tmpVar1   = ""

    DO FOREVER
       pos = POS(from_needle, tmpVar2, start)         /* get position of search-string */

       IF pos = 0 THEN                          /* search-string not found */
       DO
          IF bDirty THEN
             tmpVar1 = tmpVar1 || SUBSTR(tmpVar2, start)
          LEAVE            /* done, no from_needle found */
       END

       tmpVar1 = tmpVar1 || SUBSTR(tmpVar2, start, pos-start) || to_needle
       global.eTotalOfChanges = global.eTotalOfChanges + 1
       start = pos + from_needle_length
       bDirty = 1                /* change occurred ! */
    END

    RETURN



/*********************************************************************************
   find string for number of occurences
*/
FIND_NEEDLES: PROCEDURE EXPOSE global. tmpVar1 bDirty
    from_needle  = ARG(1)

    from_needle_length = LENGTH(from_needle)      /* get length of search-string */
    start = 1           /* start position in tmpVar1 */
    bDirty = 0           /* does a change occur ? */

    DO FOREVER
       pos = POS(from_needle, tmpVar1, start)         /* get position of search-string */
       IF pos = 0 THEN                          /* search-string not found */
       DO
          LEAVE            /* done, no from_needle found anymore */
       END

       global.eTotalOfChanges = global.eTotalOfChanges + 1
       start = pos + from_needle_length
       bDirty = 1                /* changes occurred ! */
    END

    RETURN




/*********************************************************************************
    parse control file, setup needle_in-/needle_out-array
    ARG(1) ... control-file-name
*/
PARSE_CONTROL_FILE: PROCEDURE EXPOSE global.
    linecount = 0
    DO WHILE LINES(ARG(1)) > 0
/*                                      allow a blank as a delimiter !
       line = STRIP(LINEIN(ARG(1)))
*/
       line = LINEIN(ARG(1))

       linecount = linecount + 1        /* count processed lines */
       IF line = "" THEN ITERATE
       delimiter = LEFT(line, 1)        /* get delimiter character */
       IF delimiter = ";" THEN iterate  /* comment encountered */
       CALL parse_replacement_string line, linecount
    END

    CALL STREAM ARG(1), "C", "CLOSE"    /* close the control file */

    RETURN


/*
   parse the replacement string in hand, extract replacement-strings
*/
PARSE_REPLACEMENT_STRING: PROCEDURE EXPOSE global. 
    line      = ARG(1)
    linecount = ARG(2)
    delimiter = LEFT(line, 1)        /* get delimiter character */

    /* get last delimiter and check whether it truly is a delimiter */
    PARSE VAR line (delimiter) needle_in (delimiter) needle_out (delimiter) +0 checkDelimiter +1 .

    IF checkDelimiter <> delimiter THEN
    DO
       IF global.eCall_type <> "FUNCTION" THEN
       DO
          CALL say2stderr "Delimiter error in control-string:"
          CALL say2stderr "   line # ["linecount"]"
          CALL say2stderr "   line   ["line"]"
       END
       CALL say_error  "   last delimiter (" || delimiter || ") is missing !", -5
    END

    i = global.eTotalOfNeedles + 1


    IF global.eDirection THEN        /* regular */
    DO
       global.i.eNeedle_In  = parse_needle(needle_in, linecount, "search-string")
       global.i.eNeedle_Out = parse_needle(needle_out, linecount, "replace-string")
       global.i.eDebug_in  = needle_in
       global.i.eDebug_out = needle_out
    END
    ELSE                             /* inverse (switch strings) */
    DO
       global.i.eNeedle_In  = parse_needle(needle_out, linecount, "search-string")
       global.i.eNeedle_Out = parse_needle(needle_in, linecount, "replace-string")
       global.i.eDebug_in  = needle_out
       global.i.eDebug_out = needle_in
    END

    global.eTotalOfNeedles = i

    RETURN


/*********************************************************************************
    parse needles and replaces the special character-sequences ... with:
       @C    ... CR
       @L    ... LF
       @T    ... TAB
       @E    ... ESC
       @Z    ... CTL-Z
       @@    ... @ (escape for @)
       @Xnn  ... with the hexadecimal "nn" value
       @Hnn  ... with the hexadecimal "nn" value
       @Dnnn ... with the decimal "nnn" value

    ARG(1)   ... contains string to be parsed
    ARG(2)   ... contains linenumber in control-file
    ARG(3)   ... contains hint which part is in error
*/
PARSE_NEEDLE: PROCEDURE
     needle = ARG(1)
     error_msg_string = ARG(3) "[" || ARG(1) || "] in line [" || ARG(2) || "] in error !"

     new_needle = ""
     DO FOREVER
        PARSE VAR needle left_side "@" needle
        new_needle = new_needle || left_side

        IF needle <> "" THEN
        DO
           a = TRANSLATE(LEFT(needle, 1))       /* translate into uppercase */
           value = ""
           needle = SUBSTR(needle, 2)           /* remove lead-in */
           SELECT
              WHEN a = "C" THEN value = "0D"X   /* CR */
              WHEN a = "L" THEN value = "0A"X   /* LF */
              WHEN a = "T" THEN value = "09"X   /* TAB */
              WHEN a = "E" THEN value = "1B"X   /* ESCape */
              WHEN a = "Z" THEN value = "1A"X   /* CTL-Z == EOF */
              WHEN a = "@" THEN value = "@"     /* character "@" itself */
              WHEN a = "H" | a = "X" THEN       /* get character from hex-value */
                   DO
                      /* check whether a valid hex-string, two hex-digits mandatory ! */
                      i = 2
                      tmp = TRANSLATE(SUBSTR(needle, 1, i))

                      IF VERIFY(tmp, "0123456789ABCDEF") <> 0 THEN      /* hexadecimal value ? */
                         CALL say_error "looking for 2-hex-digits, not a hex-value:" error_msg_string, -10

                      value = X2C(tmp)
                      needle = SUBSTR(needle, i + 1)
                   END

              WHEN a = "D" THEN                 /* get character from decimal-value */
                   DO
                      /* check for numeric datatype, 3-digits a must ! */
                      i = 3
                      tmp = TRANSLATE(SUBSTR(needle, 1, i))

                      IF \DATATYPE(SUBSTR(needle, 1, i), "N") THEN      /* numeric value ? */
                         CALL say_error "looking for 3-digits, not a decimal-value:" error_msg_string, -10

                      value = D2C(tmp)
                      needle = SUBSTR(needle, i + 1)
                   END
              OTHERWISE 
                      CALL say_error "unknown control-value:" error_msg_string, -10

           END
              new_needle = new_needle || value
        END
        ELSE
           LEAVE

     END

     RETURN new_needle


/*********************************************************************************
  build low-control needles (00x --> 20x)
*/
BUILD_LOW: PROCEDURE EXPOSE global.
   type = ARG(1)        /* should it be decimal (1), hexadecimal (2),
                                        control-sequence (3),
                                        abbreviation of comm-characters (4) or
                                        all representations (5)
                         */

   /* default to 1 */
   IF type <> "1" & type <> "2" & type <> "3" & type <> "4" & type <> "5" THEN
      type = 1

   set.   = ""                  /* default to empty string */
   /*      decimal pure : decimal : hexadecimal : control-chars : comm-chars */
   set.0  = "32 d032 x20 ^  SP"    /* at first place, so no space-replacements take place at the end */
   set.1  = " 1 d001 x01 ^A SOH"
   set.2  = " 2 d002 x02 ^B STX"
   set.3  = " 3 d003 x03 ^C ETX"
   set.4  = " 4 d004 x04 ^D EOT"
   set.5  = " 5 d005 x05 ^E ENQ"
   set.6  = " 6 d006 x06 ^F ACK"
   set.7  = " 7 d007 x07 ^G BEL"
   set.8  = " 8 d008 x08 ^H BS"
   set.9  = " 9 d009 x09 ^I HT"
   set.10 = "10 d010 x0A ^J LF"
   set.11 = "11 d011 x0B ^K VT"
   set.12 = "12 d012 x0C ^L FF"
   set.13 = "13 d013 x0D ^M CR"
   set.14 = "14 d014 x0E ^N SO"
   set.15 = "15 d015 x0F ^O SI"
   set.16 = "16 d016 x10 ^P DLE"
   set.17 = "17 d017 x11 ^Q DC1"
   set.18 = "18 d018 x12 ^R DC2"
   set.19 = "19 d019 x13 ^S DC3"
   set.20 = "20 d020 x14 ^T DC4"
   set.21 = "21 d021 x15 ^U NAK"
   set.22 = "22 d022 x16 ^V SYN"
   set.23 = "23 d023 x17 ^W ETB"
   set.24 = "24 d024 x18 ^X CAN"
   set.25 = "25 d025 x19 ^Y EM"
   set.26 = "26 d026 x1A ^Z SUB"
   set.27 = "27 d027 x1B ^[ ESC"
   set.28 = "28 d028 x1C ^\ FS"
   set.29 = "29 d029 x1D ^] GS"
   set.30 = "30 d030 x1E ^^ RS"
   set.31 = "31 d031 x1F ^_ US"
   set.32 = " 0 d000 x00 ^@ NUL"

   DO i=0 TO 32
      representation = ""

      set = SUBSTR(set.i, 4)            /* get encoding strings */
      iChar = WORD(set.i, 1)            /* get decimal value of char in hand */

      SELECT 
         WHEN type = 5 THEN representation = "<@" || set || ">"       /* all meaningful infos */
         OTHERWISE representation = "<@" || WORD(set, type) || ">"
      END  

      j = global.eTotalOfNeedles + 1

      IF global.eDirection THEN         /* from char ---> representation */
      DO
         global.j.eNeedle_In  = D2C(iChar)
         global.j.eNeedle_Out = representation
      END
      ELSE
      DO
         global.j.eNeedle_In  = representation
         global.j.eNeedle_Out = D2C(iChar)
      END
      global.eTotalOfNeedles = j
   END

   RETURN


/*********************************************************************************
  build high-char needles (80x-FFx)
*/
BUILD_HIGH: PROCEDURE EXPOSE global.
   type = ARG(1)                /* should it be decimal (1) or hexadecimal (2) ? */
   IF type <> "1" & type <> "2" THEN
      type = 1

   DO i=128 TO 255
      IF type = 1 THEN          /* decimal representation */
         representation = "<@d" || RIGHT(i, 3, 0) || ">"
      ELSE
         representation = "<@x" || d2x(i) || ">"

      j = global.eTotalOfNeedles + 1

      IF global.eDirection THEN         /* from char ---> representation */
      DO
         global.j.eNeedle_In  = D2C(i)
         global.j.eNeedle_Out = representation
      END
      ELSE
      DO
         global.j.eNeedle_In  = representation
         global.j.eNeedle_Out = D2C(i)
      END
      global.eTotalOfNeedles = j
   END

   RETURN




/*********************************************************************************
    display errormessage and exit
    ARG(1) ... message
    ARG(2) ... error-level
*/
SAY_ERROR: 
    CALL BEEP 550, 250
    CALL say2stderr ARG(1)
    EXIT ARG(2)

/*********************************************************************************/
HALT:
   IF global.eFilein <> "" THEN
      IF STREAM(global.eFilein, "STATUS") = "READY" THEN
         CALL STREAM global.eFilein, "C", "CLOSE"          /* close input file */

   IF global.eFileout <> "" THEN
      IF STREAM(global.eFileout, "STATUS") = "READY" THEN
         CALL STREAM global.eFileout, "C", "CLOSE"         /* close output file */
   
   IF global.eControl <> "" THEN
      IF STREAM(global.eControl, "STATUS") = "READY" THEN
         CALL STREAM global.eFileout, "C", "CLOSE"         /* close output file */
   
   IF global.eTmp <> "" THEN                    /* output file was temporary */
      IF STREAM(global.eTmp, "STATUS") = "READY" THEN
          CALL SysFileDelete(global.eTmp)           /* delete temporary file */
   ELSE
      IF global.eFileout <> "" THEN
         CALL SysFileDelete(global.eFileout)            /* delete output file */

   CALL say2stderr "CTL-C pressed, aborting..."
   EXIT
 

/*********************************************************************************/
ERROR:
   myrc = RC                                                                   
   CALL say2stderr 'REXX error' myrc 'in line' SIGL':' ERRORTEXT(myrc)
   CALL say2stderr SUBSTR('     ',1,6-LENGTH(SIGL))(SIGL)' *-*   'SOURCELINE(SIGL)
   EXIT -999

/*
   calculate elapsed time
*/
CALC_TIME: PROCEDURE
   start = ARG(1)
   end   = ARG(2)
   diff = DATERGF(end, "-S", start)
   
   IF diff >= 1 THEN day = diff % 1 "day(s) "
                ELSE day = ""
   
   RETURN day || DATERGF(diff, "FR")



/*
   replacement for SAY, which uses stdout:
   =
   use stderr: rather than stdout:, so redirection works
*/
SAY2STDERR: PROCEDURE
   CALL LINEOUT "STDERR:", ARG(1)
   RETURN

USAGE:
   CALL say2stderr "rxMulch.cmd: program to find/replace characters (strings) in file; allows"
   CALL say2stderr "             definition of hexadecimal or decimal value of single  "
   CALL say2stderr "             characters                                            "
   CALL say2stderr 
   CALL say2stderr "usage:"
   CALL say2stderr
   CALL say2stderr " rxMulch [infile] [outfile] {[-]controlfile | /[-]switch}      "
   CALL say2stderr "   infile:      if missing from STDIN:                         "
   CALL say2stderr 
   CALL say2stderr "   outfile:     if missing, RxMulch will replace infile;       "
   CALL say2stderr "                if no infile than output to STDOUT:            "
   CALL say2stderr 
   CALL say2stderr "   controlfile OR switch MUST be present:"
   CALL say2stderr 
   CALL say2stderr "   controlfile: change for every search-string/replace-string line the  "
   CALL say2stderr "                'search-string' into 'replace-string'; if more than one "
   CALL say2stderr "                search/replace-line is given, subsequent search/replaces"
   CALL say2stderr "                start from the beginning.                      "
   CALL say2stderr "                If the controlfile is preceded with a minus (-) the  "
   CALL say2stderr "                meaning of the 'search-string' and 'replace-string' is  "
   CALL say2stderr "                swapped.                                       "
   CALL say2stderr "                If a line is empty or if there is a semi-colon (;) at the very"
   CALL say2stderr "                first column, the line is treated as a comment."
   CALL say2stderr "                                                               "
   CALL say2stderr "                                                               "
   CALL say2stderr "   switch:      If the switch is preceded with a minus (-) the meaning of  "
   CALL say2stderr "                the 'search-string' and 'replace-string' is swapped. "
   CALL say2stderr 
   CALL say2stderr "                'C'search-string/replace-string                "
   CALL say2stderr "                ... Change all occurrences of 'search-string' to  "
   CALL say2stderr "                    'replace-string'.                          "
   CALL say2stderr 
   CALL say2stderr "                '[L[1|2|3|4|5]][H[1|2]]'                       "
   CALL say2stderr "                ...  change low-/high-characters to any of the following"
   CALL say2stderr "                     representations:                          "
   CALL say2stderr 
   CALL say2stderr "                     L: change all low-char values c2d(0-32)   "
   CALL say2stderr "                         L .... defaults to L1                 "
   CALL say2stderr "                         L1 ... char(0-32) to decimal          "
   CALL say2stderr "                         L2 ... char(0-32) to hexadecimal      "
   CALL say2stderr "                         L3 ... char(0-32) to control-sequence "
   CALL say2stderr "                         L4 ... char(0-32) to abbreviated comm-characters  "
   CALL say2stderr "                         L5 ... char(0-32) to all representations above "
   CALL say2stderr 
   CALL say2stderr "                     H: change all high-char values c2d(128-255)  "
   CALL say2stderr "                         H  ... defaults to H1                 "
   CALL say2stderr "                         H1 ... char(128-255) to decimal       "
   CALL say2stderr "                         H2 ... char(128-255) to hexadecimal   "
   CALL say2stderr 
   CALL say2stderr "                     The appropriate search-string/replace-string pairs are"
   CALL say2stderr "                     generated automatically.                  "
   CALL say2stderr 
   CALL say2stderr "                'F'search-string/replace-string                "
   CALL say2stderr "                ... count the number of occurrences of 'search-string'  "
   CALL say2stderr 
   CALL say2stderr "   search-string/replace-string:                               "
   CALL say2stderr "               (delimiter)search-values(delimiter)replace-values(delimiter)"
   CALL say2stderr 
   CALL say2stderr "         delimiter:                                            "
   CALL say2stderr "                very first character in search-string/replace-string "
   CALL say2stderr 
   CALL say2stderr "         search-values                                         "
   CALL say2stderr "         replace-values:                                       "
   CALL say2stderr "                any ASCII-string intermixed with the following escape-codes"
   CALL say2stderr 
   CALL say2stderr "                escape-codes:                                  "
   CALL say2stderr "                    @C    ... CR                               "
   CALL say2stderr "                    @L    ... LF                               "
   CALL say2stderr "                    @T    ... TAB                              "
   CALL say2stderr "                    @E    ... ESC                              "
   CALL say2stderr "                    @Z    ... CTL-Z                            "
   CALL say2stderr "                    @@    ... @ (escape for @)                 "
   CALL say2stderr "                    @Xnn                                       "
   CALL say2stderr "                    @Hnn  ... char with the hexadecimal of value 'nn'"
   CALL say2stderr "                    @Dnnn ... char with the decimal value 'nnn'"
   CALL say2stderr 
   CALL say2stderr "RxMulch can be called as a function from another REXX-program, e.g."
   CALL say2stderr 
   CALL say2stderr '   some_variable = RxMulch(REXXstring, "[/][-]switch")'
   CALL say2stderr 
   CALL say2stderr "examples:                                                          "
   CALL say2stderr 
   CALL say2stderr "    rxMulch infile outfile controlfile                            "
   CALL say2stderr "        ... change 'infile' according to 'controlfile', place results into "
   CALL say2stderr "            'outfile'"
   CALL say2stderr 
   CALL say2stderr "    rxMulch infile controlfile                                    "
   CALL say2stderr "        ... change 'infile' according to 'controlfile', place results into "
   CALL say2stderr "            'infile' (i.e. replace 'infile' itself)               "
   CALL say2stderr 
   CALL say2stderr "    rxMulch < some_in_file > some_out_file controlfile            "
   CALL say2stderr "        ... change 'some_in_file' according to 'controlfile', place results"
   CALL say2stderr "            into 'some_out_file'; 'some_in_file' and 'some_out_file' are"
   CALL say2stderr "            redirected ('<' and '>'). rxMulch therefore can be used in pipes"
   CALL say2stderr "            too.                                                  "
   CALL say2stderr 
   CALL say2stderr "    rxMulch infile outfile1 /C.Microsoft Excel.Lotus 1-2-3.       "
   CALL say2stderr "        ... change 'infile' according to commandline switch (replace all"
   CALL say2stderr "            occurrences of 'Microsoft Excel' with 'Lotus 1-2-3'), place "
   CALL say2stderr "            results into 'outfile1'                               "
   CALL say2stderr 
   CALL say2stderr "    rxMulch outfile1 outfile2 /-C.Microsoft Excel.Lotus 1-2-3.    "
   CALL say2stderr "        ... change 'outfile1' according to commandline switch (replace all "
   CALL say2stderr "            occurrences of 'Lotus 1-2-3' with 'Microsoft Excel', note the  "
   CALL say2stderr "            minus (-) right before the switch-character), place results into  "
   CALL say2stderr "            'outfile2'; could be also expressed as:               "
   CALL say2stderr "                  rxMulch outfile1 outfile2 /C.Lotus 1-2-3.Microsoft Excel."
   CALL say2stderr 
   CALL say2stderr "    rxMulch infile /C.;.@c@l.                                     "
   CALL say2stderr "        ... change 'infile' according to commandline switch (replace "
   CALL say2stderr "            semicolons (;) with a carriage-return/linefeed), replace "
   CALL say2stderr "            'infile'; could be also expressed as:                 "
   CALL say2stderr "                  rxMulch infile /C.;.@xd@xa.                     "
   CALL say2stderr "                  rxMulch infile /C.;.@x0d@x0a.                   "
   CALL say2stderr "                  rxMulch infile /C.;.@d13@d10.                   "
   CALL say2stderr 
   CALL say2stderr "    rxMulch infile /C.@c@l@c@l.@c@l.                              "
   CALL say2stderr "        ... change 'infile' according to commandline switch (replace "
   CALL say2stderr "            consecutive carriage-return/linefeeds with one        "
   CALL say2stderr "            carriage-return/linefeed, i.e. remove one empty line), replace "
   CALL say2stderr "            'infile'; could be also expressed as:                 "
   CALL say2stderr "                  rxMulch infile /C.@xd@xa@xd@xa.@xd@xa.          "
   CALL say2stderr "                  rxMulch infile /C!@d13@d10@d13@d10!@d13@d10!    "
   CALL say2stderr "                  rxMulch infile /C/@d13@d10@d13@d10/@c@l/        "
   CALL say2stderr 
   CALL say2stderr "    rxMulch infile /-C.@c@l@c@l.@c@l.                             "
   CALL say2stderr "        ... change 'infile' according to commandline switch (replace a  "
   CALL say2stderr "            carriage-return/linefeed with two consecutive         "
   CALL say2stderr "            carriage-return/linefeeds, i.e. insert an empty line after each"
   CALL say2stderr "            line), replace 'infile'; could be also expressed as:  "
   CALL say2stderr "                  rxMulch infile /C,@c@l,@c@l@c@l,                "
   CALL say2stderr "                  rxMulch infile /C=@x0d@x0a=@x0d@x0a@x0dx@0a=    "
   CALL say2stderr "                  rxMulch infile /C=@d13@d10=@d13@d10@x0dx@0a=    "
   CALL say2stderr 
   CALL say2stderr "    rxMulch infile /C=@x00@x00@x00@x00=@x01@x01@x01@x01=          "
   CALL say2stderr "        ... change 'infile' according to commandline switch (replace all"
   CALL say2stderr "            hexadecimal strings of 0x00000000 with 0x01010101), replace "
   CALL say2stderr "            'infile'; could be also expressed as:                 "
   CALL say2stderr "                  rxMulch infile /C=@x0@x0@x0@x0=@x1@x1@x1@x1=    "
   CALL say2stderr "                  rxMulch infile /C/@d0@d0@d0@d0/@d1@d1@d1@d1/    "
   CALL say2stderr 
   CALL say2stderr "    rxMulch infile /F.OS/2.                                       "
   CALL say2stderr "        ... count occurrences of string 'OS/2' in 'infile'          "
   CALL say2stderr 
   CALL say2stderr "    rxMulch infile /F.@c@l@c@l.                                   "
   CALL say2stderr "        ... count number of lines in 'infile', which are immediately"
   CALL say2stderr "            followed by a blank line  "
   CALL say2stderr 
   CALL say2stderr 
   CALL say2stderr "examples for calling RxMulch from a REXX-procedure:"
   CALL say2stderr 
   CALL say2stderr "    string1 = 'this is nice'"
   CALL say2stderr "    string2 = RxMulch(string1, '/c.this.that.')  /* change 'this' to 'that' */"
   CALL say2stderr "        ... string2 = 'that is nice'"
   CALL say2stderr "    string2 = RxMulch(string2, '/-c.this.that.') /* change 'that' to 'this' */"
   CALL say2stderr "        ... string2 = 'this is nice'"
   CALL say2stderr "    occurrences = RxMulch(string2, 'f.this.')    /* count 'this' in string2 */"
   CALL say2stderr "        ... occurrences = 1"

   EXIT


            
