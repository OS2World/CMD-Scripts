/*

   Testing RxMulch.CMD

   This procedure uses "asc0-255" and "TestText" to test the correct functionality
   of RxMulch.CMD.

   After all replacements it compares the resulting files with the original one (asc0-255).
   If everything went o.k., it will delete the intermediate files

   Rony G. Flatscher
   94-01-23

*/


"@CALL ECHO OFF"

filein = "asc0-255"             /* file, which contains all ASCII-characters */
ctl_file.1 = "commchar.ctl"
ctl_file.2 = "ctl_char.ctl"
ctl_file.3 = "dec_char.ctl"
ctl_file.4 = "hex_char.ctl"
ctl_file.0 = 4

"del" filein || ".L* 2>nul"    /* delete temporary files */
"del" filein || ".H* 2>nul"    /* delete temporary files */

SAY "======================================================================"
SAY "Calling RxMulch directly as a REXX-function from this REXX-procedure"

string = "Microsoft Excel is one of the bestsellers in the Windows market segment."
from = "Microsoft Excel"
to   = "Lotus 1-2-3"
SAY
SAY "Content of string to be worked on:"
SAY "[" || string || "]"
SAY
SAY "Count number of occurrences of '"from"' in this string:"
command = "/f." || from || "."
SAY RxMulch(string, command)
SAY

SAY "Replace '"from"' with '"to"' in this string:"
command = "/c." || from || "." || to || "."
string2 = RxMulch(string, command)
SAY "Replaced string:"
SAY "[" || string2 || "]"
SAY

SAY "Count number of occurrences of '"from"' in this string:"
SAY RxMulch(string2, "/f."from".")
SAY
SAY "Count number of occurrences of '"from"' in this string again:"
SAY RxMulch(string2, "f."from".")
SAY

SAY "Replace '"to"' with '"from"' in this string:"
string2 = RxMulch(string2, "/-c."from"."to".")
SAY "Replaced string:"
SAY "[" || string2 || "]"
SAY

/* ********************************************************** */

SAY "======================================================================"
SAY "Using built-in-translations with INPUT- and OUTPUT-file given:"
SAY
SAY "   PERMUTATING /L-switches:"
SAY


CALL do_it_2Files filein, "L"

DO i = 1 TO 5
   CALL do_it_2Files filein,  "L" || i
END

SAY
SAY
SAY
SAY "   PERMUTATING /H-switches:"
SAY

CALL do_it_2Files filein, "H"

DO i = 1 TO 2
   CALL do_it_2Files filein, "H" || i
END

SAY
SAY
SAY
SAY "   TESTING /HL-switch:"
SAY
CALL do_it_2Files filein, "HL"

SAY
SAY
SAY
SAY "   TESTING /LH-switch:"
SAY
CALL do_it_2Files filein, "LH"


SAY


/***********************************************************************/

filein_bkp = filein || ".bkp"
"copy" filein filein_bkp ">nul"        /* produce backup to work on */

SAY "======================================================================"
SAY "Using built-in-translations with INPUT-file given:"
SAY
SAY "   PERMUTATING /L-switches:"
SAY


CALL do_it_1File filein, "L"

DO i = 1 TO 5
   CALL do_it_1File filein,  "L" || i
END

SAY
SAY
SAY
SAY "   PERMUTATING /H-switches:"
SAY

CALL do_it_1File filein, "H"

DO i = 1 TO 2
   CALL do_it_1File filein, "H" || i
END

SAY
SAY
SAY
SAY "   TESTING /HL-switch:"
SAY
CALL do_it_1File filein, "HL"

SAY
SAY
SAY
SAY "   TESTING /LH-switch:"
SAY
CALL do_it_1File filein, "LH"


SAY
"DEL" filein_bkp  " 2>nul"      /* delete backup-file */


/* ********************************************************** */


SAY "======================================================================"
SAY "Using built-in-translations with STDIN and STDOUT given:"
SAY
SAY "   PERMUTATING /L-switches:"
SAY


CALL do_it_2Files_STDIO filein, "L"

DO i = 1 TO 5
   CALL do_it_2Files_STDIO filein,  "L" || i
END

SAY
SAY
SAY
SAY "   PERMUTATING /H-switches:"
SAY

CALL do_it_2Files_STDIO filein, "H"

DO i = 1 TO 2
   CALL do_it_2Files_STDIO filein, "H" || i
END

SAY
SAY
SAY
SAY "   TESTING /HL-switch:"
SAY
CALL do_it_2Files_STDIO filein, "HL"

SAY
SAY
SAY
SAY "   TESTING /LH-switch:"
SAY
CALL do_it_2Files_STDIO filein, "LH"

SAY


/* ********************************************************** */

SAY "======================================================================"
SAY "Using control-file-translations with input-/output-files given"
SAY

DO i = 1 TO ctl_file.0
   SAY "Testing control-file [" || ctl_file.i || "]"
   CALL do_it_2Files_ctl_file filein, ctl_file.i
END

SAY


/* ********************************************************** */

SAY "======================================================================"
SAY "Using control-file-translations with input-file given (to be replaced):"
SAY
filein_bkp = filein || ".bkp"
"copy" filein filein_bkp  ">nul"      /* produce backup to work on */

DO i = 1 TO ctl_file.0
   SAY "Testing control-file [" || ctl_file.i || "]"
   CALL do_it_1File_ctl_file filein, ctl_file.i
END

SAY
SAY
"DEL" filein_bkp " 2>nul"       /* delete backup-file */

/* ********************************************************** */

SAY "======================================================================"
SAY "Using control-file-translations with STDIN/STDOUT"
SAY

DO i = 1 TO ctl_file.0
   SAY "Testing control-file [" || ctl_file.i || "]"
   CALL do_it_2Files_ctl_file_STDIO filein, ctl_file.i
END

SAY


/* ********************************************************** */

SAY "======================================================================"
SAY

SAY "Using /F-switch to determine number of lines in a file:"
SAY
   tmp = "rxMulch testtext /F.@c@l."
   "call" tmp
SAY
SAY


SAY "Using command-line to replace Microsoft with Lotus in file" testtext
SAY
SAY "Content BEFORE changes:"
   "type testtext"
   tmp = "rxMulch testtext /c.Microsoft.Lotus."
   "call" tmp
SAY "Content AFTER changes:"
   "type testtext"
SAY
SAY

SAY "Using command-line to replace Excel with 1-2-3"
SAY
SAY "Content BEFORE changes:"
   "type testtext"
   tmp = "rxMulch testtext /c/Excel/1-2-3/"
   "call" tmp
SAY "Content AFTER changes:"
   "type testtext"
SAY
SAY

SAY "Using command-line to replace 1-2-3 with Excel"
SAY
SAY "Content BEFORE changes:"
   "type testtext"
   tmp = "rxMulch testtext /-c/Excel/1-2-3/"
   "call" tmp
SAY "Content AFTER changes:"
   "type testtext"
SAY
SAY

SAY
SAY "Using command-line to replace Louts with Microsoft"
SAY
SAY "Content BEFORE changes:"
   "type testtext"
   tmp = "rxMulch testtext /c.Lotus.Microsoft."
   "call" tmp
SAY "Content AFTER changes:"
   "type testtext"
SAY
SAY



EXIT


/*********************************************/
DO_IT_2FILES: PROCEDURE
   filein = ARG(1)
   switch = ARG(2)

   fileout1 = filein || "." || switch
   tmp = "RxMulch" filein fileout1 "/" || switch
   SAY "  " tmp
   "CALL" tmp "2>nul"

   fileout2 = filein || "." || switch || "R"
   tmp = "RxMulch" fileout1 fileout2 "/-" || switch
   SAY "  " tmp
   "CALL" tmp  "2>nul"
   "echo n | comp" filein fileout2 

    IF rc <> "5" THEN           /* files did compare o.k. */
    DO
       "DEL" fileout1 "2>nul"
       "DEL" fileout2 "2>nul"
    END
    ELSE                        /* files did NOT compare o.k. */
    DO
       SAY "************ RC of comp ["rc"]"
       SAY "*ERROR* - FILES DO NOT COMPARE !"
       "PAUSE"
    END


   RETURN


/*********************************************/
DO_IT_1FILE: PROCEDURE
   filein_stem = ARG(1)
   switch = ARG(2)

   filein = filein_stem || ".bkp"

   tmp = "RxMulch" filein "/" || switch
   SAY "  " tmp
   "CALL" tmp "2>nul"

   tmp = "RxMulch" filein "/-" || switch
   SAY "  " tmp
   "CALL" tmp "2>nul"
   "echo n | comp" filein_stem filein 

    IF rc = "5" THEN           /* files did NOT compare o.k. */
    DO
       SAY "************ RC of comp ["rc"]"
       SAY "*ERROR* - FILES DO NOT COMPARE !"
       "PAUSE"
    END

   RETURN



/*********************************************/
DO_IT_2FILES_STDIO: PROCEDURE
   filein = ARG(1)
   switch = ARG(2)

   fileout1 = filein || "." || switch
   tmp = "RxMulch" "<" filein ">" fileout1 "/" || switch
   SAY "  " tmp
   "CALL" tmp "2>nul"

   fileout2 = filein || "." || switch || "R"
   tmp = "RxMulch" "<" fileout1 ">" fileout2 "/-" || switch
   SAY "  " tmp
   "CALL" tmp "2>nul"
   "echo n | comp" filein fileout2 

    IF rc <> "5" THEN           /* files did compare o.k. */
    DO
       "DEL" fileout1 "2>nul"
       "DEL" fileout2 "2>nul"
    END
    ELSE                        /* files did NOT compare o.k. */
    DO
       SAY "************ RC of comp ["rc"]"
       SAY "*ERROR* - FILES DO NOT COMPARE !"
       "PAUSE"
    END

   RETURN


/*********************************************/
DO_IT_2FILES_CTL_FILE: PROCEDURE
   filein = ARG(1)
   ctl_file = ARG(2)
   switch = LEFT(ctl_file, 2)

   fileout1 = filein || "." || switch
   "del" fileout1 || "* 2>nul"
   tmp = "RxMulch" filein fileout1 ctl_file
   SAY "  " tmp
   "CALL" tmp "2>nul"

   fileout2 = filein || "." || switch || "R"
   tmp = "RxMulch" fileout1 fileout2 "-" || ctl_file
   SAY "  " tmp
   "CALL" tmp "2>nul"
   "echo n | comp" filein fileout2 

    IF rc <> "5" THEN           /* files did compare o.k. */
    DO
       "DEL" fileout1 "2>nul"
       "DEL" fileout2 "2>nul"
    END
    ELSE                        /* files did NOT compare o.k. */
    DO
       SAY "************ RC of comp ["rc"]"
       SAY "*ERROR* - FILES DO NOT COMPARE !"
       "PAUSE"
    END

   RETURN



/*********************************************/
DO_IT_1FILE_CTL_FILE: PROCEDURE
   filein_stem = ARG(1)
   ctl_file = ARG(2)

   filein = filein_stem || ".bkp"

   tmp = "RxMulch" filein ctl_file
   SAY "  " tmp
   "CALL" tmp "2>nul"

   tmp = "RxMulch" filein "-" || ctl_file
   SAY "  " tmp
   "CALL" tmp "2>nul"
   "echo n | comp" filein_stem filein 

    IF rc = "5" THEN           /* files did NOT compare o.k. */
    DO
       SAY "************ RC of comp ["rc"]"
       SAY "*ERROR* - FILES DO NOT COMPARE !"
       "PAUSE"
    END
   RETURN



/*********************************************/
DO_IT_2FILES_CTL_FILE_STDIO: PROCEDURE
   filein = ARG(1)
   ctl_file = ARG(2)
   switch = LEFT(ctl_file, 2)

   fileout1 = filein || "." || switch
   "del" fileout1 || "* 2>nul"
   tmp = "RxMulch" "<" filein ">" fileout1 ctl_file
   SAY "  " tmp
   "CALL" tmp "2>nul"

   fileout2 = filein || "." || switch || "R"
   tmp = "RxMulch" "<" fileout1 ">" fileout2 "-" || ctl_file
   SAY "  " tmp
   "CALL" tmp "2>nul"
   "echo n | comp" filein fileout2

    IF rc <> "5" THEN           /* files did compare o.k. */
    DO
       "DEL" fileout1 "2>nul"
       "DEL" fileout2 "2>nul"
    END
    ELSE                        /* files did NOT compare o.k. */
    DO
       SAY "************ RC of comp ["rc"]"
       SAY "*ERROR* - FILES DO NOT COMPARE !"
       "PAUSE"
    END

   RETURN


