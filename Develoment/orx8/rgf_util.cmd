/*
program:   rgf_util.cmd
type:      Object REXX, REXXSAA 6.0
purpose:   collection of useful routines for Object REXX programs
version:   1.00.1
date:      1997-04-15
changed:   1997-06-26, rgf, changed some minorities

author:    Rony G. Flatscher
           Rony.Flatscher@wu-wien.ac.at
           (Wirtschaftsuniversitaet Wien, University of Economics and Business
           Administration, Vienna/Austria/Europe)
needs:     ---

usage:     call or require

comments:  prepared for the "8th International Rexx Symposium 1997", April 1997, Heidelberg/Germany
           Miscellaneous routines;


All rights reserved and copyrighted 1995-1997 by the author, no guarantee that
it works without errors, etc.  etc.

You are granted the right to use this module under the condition that you don't charge money for this module (as you didn't write
it in the first place) or modules directly derived from this module, that you document the original author (to give appropriate
credit) with the original name of the module and that you make the unaltered, original source-code of this module available on
demand.  If that holds, you may even bundle this module (either in source or compiled form) with commercial software.

If you find an error, please send me the description (preferably a *very* short example);
I'll try to fix it and re-release it to the net.

*/


/* add a directory for the purposes of the utilities defined herein           */

IF .rgf.util <> ".RGF.UTIL" THEN RETURN /* already defined, do not execute initialization
                                           code another time                    */

.local[ "RGF.UTIL" ] = .directory~new    /* define a directory in .local       */

PARSE SOURCE op_sys call_type script_path
.rgf.util ~ this_op_sys    = op_sys
.rgf.util ~ this_full_path = script_path
.rgf.util ~ this_call_type = call_type
.rgf.util ~ this_name      = FILESPEC("Name", script_path)

.rgf.util~debugLevel = 0          /* define debug_level, if 0 not debug information
                                  produced                                    */

.rgf.util~Log   = .monitor ~ new ~~INIT( .stdout )      /* define log-monitor */
.rgf.util~Error = .monitor ~ new ~~INIT( .stderr )      /* define log-monitor */
.rgf.util~Debug = .monitor ~ new ~~INIT( .stderr )      /* define Debug-monitor */

.rgf.util~indent = LEFT("", 3)          /* indent blanks                        */

.rgf.util ~ CR   = "0d"x
.rgf.util ~ LF   = "0a"x
.rgf.util ~ CRLF = "0d0a"x




/* give feedback of intitialization step, if DebugLevel level is defined           */
IF .rgf.util ~ DebugLevel > 0 THEN
DO
   PARSE VERSION version
   PARSE SOURCE  op_sys call_type this_file
   .rgf.util~log~lineout( pp(.rgf.util~this_name) "running on:" pp(op_sys),
                          "DebugLevel level:" pp(.rgf.util~DebugLevel),
                          "call type:" pp(call_type),
                        )
   .rgf.util~log~lineout( .rgf.util~indent "version:" pp(version) )
   .rgf.util~log~lineout( .rgf.util~indent pp("initialization --- end") )
END


/*
:: REQUIRES rgf_class.cmd               /* needs RGF-classes    */
*/


:: REQUIRES sort_util.cmd               /* sorting support              */
:: REQUIRES routine_find_file.cmd
:: REQUIRES routine_ok.cmd
:: REQUIRES routine_pp.cmd
:: REQUIRES routine_pp_number.cmd
:: REQUIRES routine_strip_quote.cmd




/******************************************************************************/
/*                                                                            */
/* name:    dump(object, title, output-stream, indent-chars)                  */
/*                                                                            */
/* purpose: dumps a directory                                                 */
/*                                                                            */
/* returns: ---                                                               */
/*                                                                            */
/* remarks: defaults, if no object supplied:                                  */
/*          title         ... "--- not given ---"                             */
/*          output-stream ... .rgf.util ~ debug                               */
/*          indent-chars  ... .rgf.util ~ indent                              */
/*                                                                            */
/* created: rgf, 95-09-30                                                     */

:: ROUTINE dump                  PUBLIC
   USE ARG object, title, stream, indent

   /* supply defaults */
   IF \VAR("TITLE")  THEN title  = "--- not given ---"

   IF \VAR("STREAM") THEN
      stream = .rgf.util ~ debug                /* use .rgf.util-debug monitor */

   IF \VAR("INDENT") THEN
      indent = .rgf.util ~ indent               /* use rgf.util-indention */

   max = 30                                     /* default */

   stream ~ LINEOUT( indent LEFT("begin of dump ...", 70, "-") )
   tmp = indent "got" pp(object ~ class ) "title" pp(title)
   IF object ~ hasmethod( "items" ) THEN
      tmp = tmp "items" pp(object~items)
   ELSE
      tmp = tmp "--- method ITEMS not available ---"

   stream ~ LINEOUT( tmp )
   stream ~ LINEOUT( "" )

   IF      IsA( object, .directory ) THEN CALL dumpDirectory  object, stream, indent
   ELSE IF IsA( object, .stem )      THEN CALL dumpStem       object, stream, indent
   ELSE IF IsA( object, .supplier )  THEN CALL dumpSupplier   object, stream, indent
   ELSE                                   CALL dumpOver       object, stream, indent

   stream ~ LINEOUT( indent LEFT("end of dump ..", 70, "-") )
/******************************************************************************/



/******************************************************************************/
/*                                                                            */
/* name:    dumpDirectory(directory, output-stream, indent-chars)             */
/*                                                                            */
/* purpose: dumps a directory                                                 */
/*                                                                            */
/* returns: ---                                                               */
/*                                                                            */
/* remarks: defaults, if no object supplied:                                  */
/*          output-stream ... .rgf.util ~ debug                               */
/*          indent-chars  ... .rgf.util ~ indent                              */
/*                                                                            */
/*          directory entries get always sorted !                             */
/*                                                                            */
/* created: rgf, 95-09-28                                                     */

:: ROUTINE dumpDirectory
   USE ARG object, stream, indent

   IF \VAR("STREAM") THEN
      stream = .rgf.util ~ debug                /* use .rgf.util-debug monitor */

   IF \VAR("INDENT") THEN
      indent = .rgf.util ~ indent               /* use rgf.util-indention */

   items = object~items
   width = LENGTH(items)                /* determine max length of index value*/

   aha = sort(object)                   /* returns a sorted .array object     */

   max = 0

   DO i over aha                        /* determine largest entry            */
      max = MAX(max, i ~ length)
      call trace off
   END
   max = max + 2                        /* account for brackets               */

   DO i over aha
      stream ~ LINEOUT( indent LEFT(pp(i), max) "entry" pp(object[i])   )
   END

/******************************************************************************/





/******************************************************************************/
/*                                                                            */
/* name:    dumpOver(object, output-stream, indent-chars)                     */
/*                                                                            */
/* purpose: dumps content of an object via "OVER"                             */
/*                                                                            */
/* returns: ---                                                               */
/*                                                                            */
/* remarks: defaults, if no object supplied:                                  */
/*          output-stream ... .rgf.util ~ debug                               */
/*          indent-chars  ... .rgf.util ~ indent                              */
/*                                                                            */
/* created: rgf, 95-09-30                                                     */

:: ROUTINE DumpOver
   USE ARG object, stream, indent

   width = LENGTH(object ~ items)
   a = 0
   DO i OVER object
      a = a + 1
      stream ~ LINEOUT( indent "index" pp(RIGHT(a, width)) "item" pp(i) )
   END

   RETURN
/******************************************************************************/




/******************************************************************************/
/*                                                                            */
/* name:    dumpStem(object, output-stream, indent-chars)                     */
/*                                                                            */
/* purpose: dumps content of a supplyable object                              */
/*                                                                            */
/* returns: ---                                                               */
/*                                                                            */
/* remarks: if object is not a supplier, a supplier will be produced of it by */
/*          sending it a "SUPPLIER" message                                   */
/*                                                                            */
/*          defaults, if no object supplied:                                  */
/*          output-stream ... .rgf.util ~ debug                               */
/*          indent-chars  ... .rgf.util ~ indent                              */
/*                                                                            */
/* created: rgf, 95-09-30                                                     */

:: ROUTINE DumpStem
   USE ARG object., stream, indent

   width = LENGTH(object.0)
   DO i = 1 TO object.0
      stream ~ LINEOUT( indent "index" pp(RIGHT(i, width)) "item" pp(object.i) )
   END

   RETURN
/******************************************************************************/




/******************************************************************************/
/*                                                                            */
/* name:    dumpSupplier(object, output-stream, indent-chars)                 */
/*                                                                            */
/* purpose: dumps content of a supplyable object                              */
/*                                                                            */
/* returns: ---                                                               */
/*                                                                            */
/* remarks: if object is not a supplier, a supplier will be produced of it by */
/*          sending it a "SUPPLIER" message                                   */
/*                                                                            */
/*          defaults, if no object supplied:                                  */
/*          output-stream ... .rgf.util ~ debug                               */
/*          indent-chars  ... .rgf.util ~ indent                              */
/*                                                                            */
/* created: rgf, 95-08-28                                                     */

:: ROUTINE DumpSupplier
   USE ARG supplier, stream, indent

   DO WHILE supplier~AVAILABLE
      stream ~ LINEOUT( indent "index" LEFT(pp(supplier~INDEX), 30) "item",
                      pp(supplier~ITEM) )
      supplier ~ NEXT
   END

   RETURN
/******************************************************************************/











/******************************************************************************/
/******************************************************************************/



:: ROUTINE sayLog                PUBLIC
   PARSE ARG arg
   .rgf.util~log~lineout( .rgf.util~indent arg )


:: ROUTINE sayError              PUBLIC
   PARSE ARG arg
   .rgf.util ~ error ~ lineout( .rgf.util~indent "***" arg )


:: ROUTINE sayDebug              PUBLIC
   PARSE ARG arg
   .rgf.util ~ debug ~ lineout( .rgf.util~indent arg )




