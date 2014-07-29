/*
program:   orx_analyze_html.cmd
type:      Object REXX, REXXSAA 6.0
purpose:   formats analyzed REXX-program for HTML
version:   1.00
date:      1995-11
changed:   1997-04-15; ---rgf, adapted for the new module structure

author:    Rony G. Flatscher
           Rony.Flatscher@wu-wien.ac.at
           (Wirtschaftsuniversitaet Wien, University of Economics and Business
           Administration, Vienna/Austria/Europe)
needs:     ---

usage:     orx_analyze_html some_rexx_file

           ... produces HTML-files, main file being named "HTML_Summary.html"

comments:  not finished yet

All rights reserved, copyrighted 1995-1997, no guarantee that it works without
errors, etc. etc.

You are granted the right to use this module under the condition that you don't charge money for this module (as you didn't write
it in the first place) or modules directly derived from this module, that you document the original author (to give appropriate
credit) with the original name of the module and that you make the unaltered, original source-code of this module available on
demand.  If that holds, you may even bundle this module (either in source or compiled form) with commercial software.

If you find an error, please send me the description (preferably a *very* short example); I'll try to fix it and re-release it to
the net.

*/

/* retrieve methods of classes defined in .environment ? */
.local ~ bQueryEnvClassMethods        = .false

/* HUGE performance penalty, HUGE html-files results, if methods are shown too (> 800K) !! */
.local ~ bShowEnvTilingWithMethodsEnv = .false  /* show methods while tiling classes of .environment ? */

/* perfomance penalty */
.local ~ bShowEnvMethods              = .false  /* show .environment class methods while tiling non .environment classes ? */


/* --- rgf : delete: */
.local ~ bQueryEnvClassMethods        = .true
.local ~ bShowEnvTilingWithMethodsEnv = .true   /* show methods while tiling classes of .environment ? */
/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */





PARSE ARG start_file

CALL TIME "Reset"                               /* time start */
ctl. = orx_analyze( start_file )                /* have file parsed */
PARSE VALUE TIME("Reset") WITH analyzeTime

.local ~ missing.class = ctl.eMissingClass      /* sentinel object, indicating a missing class */

/* not a time saver ...
.local ~ kappitalize = .directory ~ new         /* stores smartCap'ped or Capitalize'd strings
... */
                                                   for faster retrieval */

/*
icon_path = "/orx/icons/"
*/

icon_path = get_icon_path( "RedDot.gif" )       /* try to locate the gif-s */

.local ~ Blu.Dot = '<IMG SRC="'  || icon_path || 'BluDot.gif" WIDTH=14 HEIGHT=14 ALIGN=TOP>'
.local ~ Grn.Dot = '<IMG SRC="'  || icon_path || 'GrnDot.gif" WIDTH=14 HEIGHT=14 ALIGN=TOP>'
.local ~ Org.Dot = '<IMG SRC="'  || icon_path || 'OrgDot.gif" WIDTH=14 HEIGHT=14 ALIGN=TOP>'
.local ~ Pnk.Dot = '<IMG SRC="'  || icon_path || 'PinkDot.gif" WIDTH=14 HEIGHT=14 ALIGN=TOP>'
.local ~ Prp.Dot = '<IMG SRC="'  || icon_path || 'PurDot.gif" WIDTH=14 HEIGHT=14 ALIGN=TOP>'
.local ~ Red.Dot = '<IMG SRC="'  || icon_path || 'RedDot.gif" WIDTH=14 HEIGHT=14 ALIGN=TOP>'
.local ~ Whi.Dot = '<IMG SRC="'  || icon_path || 'WhiteDot.gif" WIDTH=14 HEIGHT=14 ALIGN=TOP>'
.local ~ Yel.Dot = '<IMG SRC="'  || icon_path || 'YelDot.gif" WIDTH=14 HEIGHT=14 ALIGN=TOP>'


CALL create_html_file_names             /* determine names to be given to the analyzed files */
CALL build_stats                        /* build "stats."-stem to contain text for statistical */

htmlDoc = .html_doc ~ new( .html.Summary, ,             /* create HTML-file */
                         "Summary results of analyzing:" pp( ctl.eFileStart ~ name ), ,
                         .true )     /* replace file, if it exists */

CALL sayError
CALL sayError "Formatting summary ..."  /* summary results */
CALL file_statistics htmlDoc

CALL sayError "Formatting details ..."  /* details results */
CALL file_details

PARSE VALUE TIME("Elapsed") WITH formatTime
CALL leadin htmlDoc, analyzeTime, formatTime, start_file
htmlDoc ~ close                         /* close HTML-summary file */
/*
call x2cp .html.Summary                 /* use SGML-entities for chars > x7F    */
*/
CALL CPFile2SGMLEntity .html.Summary    /* use SGML-entities for chars > x7F    */

.html.reference ~ sayStatistics         /* show # of references    */

EXIT


/* find path for icons on local drive */
GET_ICON_PATH : PROCEDURE
    USE ARG icon_name

    CALL SysFileTree icon_name, "files.", "FSO"         /* search a gif, starting with local directory */

    IF files.0 = 0 THEN                                 /* not found, start search from root */
       CALL SysFileTree "\" || icon_name, "files.", "FSO"

    IF files.0 = 0 THEN                                 /* not found, return empty string */
       RETURN ""

    act_dir = FILESPEC( "Path", DIRECTORY() || "\" )    /* get present directory */
    found = FILESPEC( "Path", files.1 )                 /* extract path-name */

    IF ABBREV( found, act_dir ) THEN
    DO
       IF found = act_dir THEN                          /* icons in present directory, no path necessary */
          found = ""
       ELSE
          found = SUBSTR( found, LENGTH( act_dir ) + 1 )/* keep path relative ! */
    END

    found = TRANSLATE( found, "/", "\" )                /* bug in WebExplorer; if full path given, forward slashes ! */

    RETURN found


/* ---------------------------------------------------------------------------------------- */
/* create names for html-files (summary plus details)   */
CREATE_HTML_FILE_NAMES: PROCEDURE EXPOSE ctl.

    stem  = "HTML"
    trail = "html"

    .local ~ html.Summary = stem || "_Summary." || trail

    i = 0
    DO File OVER ctl.eFiles        /* iterate over directory */
       i = i + 1
       tmpFile = ctl.eFiles ~ entry( File )  /* get file object */

       FileName = stem || "_Detail_" || i || "." || trail
       tmpFile ~ User_Slot ~ setentry( "HTMLFileName", FileName ) /* store with object data */
    END
    RETURN



/* ---------------------------------------------------------------------------------------- */
/* show header */
LEADIN: PROCEDURE EXPOSE ctl.
   USE ARG html, analyzeTime, formatTime, fileName

   PARSE SOURCE op_sys call_type proc_name

   html ~ h5( "File" smartCap( pp( fileName ) ) )
   html ~~ lineout( pp( DATE( "Sorted" ) ),
           pp( TIME( "Normal" )  ) "running" smartCap( pp( proc_name ) ),
          "under" pp( smartCap( op_sys ) ) ) ~~ p

   IF VAR( "analyzeTime" ) THEN         /* if analyze time given ... */
   DO
      html ~~ p( "Times given for analyzing and formatting <STRONG>all</STRONG> files:" ) ~~ br ~~ br
      html ~~ lineout( "Time to analyze:" pp( FORMAT( analyzeTime, , 2  ) ) "seconds" ) ~~ br
   END

   html ~~ lineout( "Time to format:" pp( FORMAT( formatTime, , 2  ) ) "seconds" ) ~~ hr
   RETURN
/* ------------------------------------------------------------------------- */


/* ------------------------------------------------------------------------- */
/* show dependency tree of encountered ::REQUIRES directives */
REQUIRE_STRUCTURE: PROCEDURE  EXPOSE ctl.
   USE ARG html, tmpFile, level

   IF tmpFile ~ requires_files ~ items = 0 THEN         /* if no files are required, then return */
      RETURN

   html ~ h2( "Required Files", "ALIGN=CENTER")


   htmlTable = .html_Table ~ new( "BORDER CELLPAD=3 ALIGN=CENTER WIDTH=100%" )     /* a table with no borders */
   htmlTable ~~ putColumn( "Dependency tree, imposed by ::REQUIRES directives:") ~~ newRow( 8 )


   CALL show_requires_tree htmlTable, tmpFile

   html ~ lineout( htmlTable ~ htmlText )               /* write table to HTML-file */
   html ~ hr( , "WIDTH=75%" )

   RETURN

SHOW_REQUIRES_TREE: PROCEDURE
   USE ARG htmlTable, tmpFile, level

   IF \VAR( "level" ) THEN              /* initial call ! */
      level = 0

   tmpString = a_href( tmpFile ~ User_Slot ~ entry( "HTMLFileName") ,,
                       "Start" ,,               /* anchor in HTMLFileName */
                       tmpFile ~ name )



/* rgf was here -------- */
   do i = 1 to level
       htmlTable ~~ putColumn( "&nbsp;", "WIDTH=5%" )
   end
   htmlTable ~~ putColumn( pp( tmpString )) ~~ newRow( MAX( 8, level ) )
/* rgf was here -------- */


/*
   htmlTable ~~ skipColumn( level ) ~~ putColumn( pp( tmpString ) ) ~~ newRow( MAX( 8, level ) )
*/

   DO item OVER tmpFile ~ requires_files
      CALL show_requires_tree htmlTable, item, ( level + 1 )
   END
   RETURN
/* ------------------------------------------------------------------------- */



/* ---------------------------------------------------------------------------------------- */
BUILD_STATS : PROCEDURE EXPOSE stats. ctl.
   stats.         = 0

   stats.eLines.1.eText = "Total lines of code         " pp( format( 100, , 2 ) "%" )
   stats.eLines.2.eText = "LOCs (lines of code, edited)"
   stats.eLines.0      = 2

   i = 1

   stats.eFile.i.eText  = "procedure(s) found"           /* 1 */
   i = i + 1
   stats.eFile.i.eText  = "label(s)     found"           /* 2 */
   i = i + 1

   stats.eFile.i.eText  = "::REQUIRES   found"           /* 3 */
   i = i + 1

   stats.eFile.i.eText  = "::ROUTINE(s) found"           /* 4 */
   i = i + 1

   stats.eFile.i.eText  = "::CLASS(es)  found"           /* 5 */
   i = i + 1

   stats.eFile.i.eText  = "::METHOD(s)  found"           /* 6 */
   i = i + 1

   stats.eFile.0       = i - 1
   RETURN






/* ---------------------------------------------------------------------------------------- */
/* show statistical data of analyzed files (in alphabetical order ) */
FILE_STATISTICS: PROCEDURE EXPOSE ctl. stats.
   USE ARG html

   CALL time "Reset"
   startFile = ctl.eFileStart                           /* determine file to start */
   CALL require_structure html, ctl.eFileStart          /* start with file which we had to analyze */

   sortedFiles = sort( ctl.eFiles )     /* returns array with sorted indices of .directory */

   html ~ h2( A_NAME( "Start", smartCap( "Summary results of analyzing:" pp( ctl.eFileStart ~ name ) ) ), "ALIGN=CENTER")

   htmlList = .html_List ~ new( "OL" )
   DO item OVER sortedFiles
      tmpFile = ctl.eFiles ~ entry( item )              /* get file object */
      tmpString = smartCap( pp( tmpFile ~ Name ) )

      IF tmpFile = startFile THEN
         tmpString = tmpString .Yel.Dot x2bare( "<--- (started the analysis !)" )

      tmpString = a_href( tmpFile ~ User_Slot ~ entry( "HTMLFileName") ,,
                          "Start" ,,               /* anchor in HTMLFileName */
                          tmpString )

      htmlList ~ item( tmpString )
   END
   html ~ LINEOUT( htmlList ~ htmlText )
   html ~ hr( , "size=3" )


   DO i = 1 TO sortedFiles ~ items
      html ~ hr( , "SIZE=5" )

      tmpFile = ctl.eFiles ~ entry( sortedFiles[ i ] )  /* get file object */

      /* if this is the file which got analyzed, indicate this fact and show accessible routines and classes */

      tmpString = "File" smartCap( pp( tmpFile ~ name ) )

      tmpString = a_href( tmpFile ~ User_Slot ~ entry( "HTMLFileName") ,,
                          "Start" ,,               /* anchor in HTMLFileName */
                          tmpString )

      IF tmpFile = startFile THEN
      DO
         html ~ h2( www_tag( tmpString ) .Yel.Dot x2bare( "<--- (started the analysis !)" ) )
      END
      ELSE
         html ~ h2( tmpString )

      html ~ hr

      /* indicate which files REQUIRE this one */
      htmlTable = .html_Table ~ new( "ALIGN=CENTER WIDTH=100%" )
      tmpString = "According to the analysis the following file(s) require(s) this one:"
      html ~ h4( tmpString )

      IF tmpFile ~ required_by ~ items > 0 THEN
      DO
         CALL sort_def_list htmlTable, tmpFile ~ required_by
      END
      ELSE
         htmlTable ~ putColumn( "--- none ---", "ALIGN=CENTER" )

      html ~ LINEOUT( htmlTable ~ htmlText )
      html ~ hr( , "WIDTH=75%" )

      /* indicate which files are REQUIRED by this one */
      htmlTable = .html_Table ~ new( "ALIGN=CENTER WIDTH=100%" )
      tmpString = "According to the analysis this file requires the following file(s):"
      html ~ h4( tmpString )

      IF tmpFile ~ requires_files ~ items > 0 THEN
      DO
         CALL sort_def_list htmlTable, tmpFile ~ requires_files
      END
      ELSE
         htmlTable ~ putColumn( "--- none ---", "ALIGN=CENTER" )

      html ~ LINEOUT( htmlTable ~ htmlText )
      html ~ hr( , "WIDTH=75%" )


  /* indicate whether file may be called as a procedure / function */
  /* if so, show signatures and returns                            */

      IF tmpFile ~ IsProcedure | tmpFile ~ IsFunction THEN
      DO
         tmpString = "This file may be called as a procedure"
         IF tmpFile ~ IsFunction THEN tmpString = tmpString www_tag("and", "EM") "as a function (it returns values)"

         html ~ h4( tmpString )
         htmlTable = .html_Table ~ new( "ALIGN=CENTER WIDTH=100%" )

         /* show signatures */
         IF tmpFile ~ signatures ~ items > 0 THEN
         DO
            title_string = ""
            CALL dump_detail_dir2string htmlTable, tmpFile ~ signatures, title_string
         END

         /* show return expressions */
         IF tmpFile ~ returns ~ items > 0 THEN
         DO
            title_string = ""
            CALL dump_detail_dir2string htmlTable, tmpFile ~ returns, title_string
         END

         /* show exit expressions */
         IF tmpFile ~ returns ~ items > 0 THEN
         DO
            title_string = ""
            CALL dump_detail_dir2string htmlTable, tmpFile ~ exits, title_string
         END
         html ~ LINEOUT( htmlTable ~ htmlText )
         html ~ hr( , "WIDTH=75%" )

      END


/* show statistics */

      /* total number of lines */
      stats.eLines.1      = pp( RIGHT( pp_number( tmpFile ~ total_loc ), 7) ) stats.eLines.1.eText
      stats.eLines.1.eSum = stats.eLines.1.eSum + tmpFile ~ total_loc    /* grand total */

      stats.eLines.2      = pp( RIGHT( pp_number( tmpFile ~ loc ), 7) ) stats.eLines.2.eText,
                            pp( RIGHT( format( (tmpFile ~ loc * 100 / MAX( tmpFile ~ total_loc, 1 )) , , 2), 6) "%" )
      stats.eLines.2.eSum = stats.eLines.2.eSum + tmpFile ~ loc          /* grand total */

      htmlTable = .html_Table ~ new( "BORDER ALIGN=CENTER CELLPADDING=3 WIDTH=60%" )
      htmlTable ~ setcaption( "Statistics", "ALIGN=TOP" )

      PARSE VAR stats.eLines.1 "[" tot_loc "]" tot_text "[" tot_perc "]"
      PARSE VAR stats.eLines.2 "[" net_loc "]" net_text "[" net_perc "]"

      htmlTable ~~ ,
               putColumn( tot_loc, "ALIGN=RIGHT WIDTH=15%"  ) ~~ ,
               putColumn( tot_text ) ~~ ,
               putColumn( tot_perc, "ALIGN=RIGHT WIDTH=15%") ~~,
               newRow

      htmlTable ~~ ,
               putColumn( net_loc, "ALIGN=RIGHT") ~~,
               putColumn( net_text ) ~~,
               putColumn( net_perc, "ALIGN=RIGHT") ~~,
               newRow

      htmlTable ~~ putColumn( "&nbsp;", "COLSPAN=3" ) ~~ newRow

      j = 1
      stats.eFile.j = ctl.eProcedures2Files ~ allat( tmpFile ) ~ items
      j = j + 1
      stats.eFile.j = ctl.eLabels2Files     ~ allat( tmpFile ) ~ items
      j = j + 1
      stats.eFile.j = ctl.eRequires2Files   ~ allat( tmpFile ) ~ items
      j = j + 1
      stats.eFile.j = ctl.eRoutines2Files   ~ allat( tmpFile ) ~ items
      j = j + 1
      stats.eFile.j = ctl.eClasses2Files    ~ allat( tmpFile ) ~ items
      j = j + 1
      stats.eFile.j = ctl.eMethods2Files    ~ allat( tmpFile ) ~ items

      DO j = 1 TO stats.eFile.0
         htmlTable ~~,
               putColumn( pp_number( stats.eFile.j ), "ALIGN=RIGHT" ) ~~,
               putColumn( stats.eFile.j.eText, "COLSPAN=2" ) ~~ newRow

         stats.eFile.j.eSum = stats.eFile.j.eSum + stats.eFile.j
      END

      htmlTable ~~ putColumn( "&nbsp;", "COLSPAN=3" ) ~~ newRow

      tmpHint = ""
      IF tmpFile ~ errors ~ items > 0 THEN tmpHint = .Red.Dot

      htmlTable ~~,
               putColumn( pp_number( tmpFile ~ errors ~ items ), "ALIGN=RIGHT" ) ~~,
               putColumn( "Error(s) found" tmpHint, "COLSPAN=2" ) ~~,
               newRow

      html ~ LINEOUT( "<CENTER>" )
      html ~ LINEOUT( htmlTable ~ htmlText )
      html ~ LINEOUT( "</CENTER>" )
      html ~ hr( , "WIDTH=75%" )


 /* show available ROUTINES ( all local and all public defined via requires ) */
      tmpDir = tmpFile ~ local_Routines ~ union( tmpFile ~ visible_routines )
      title_String = "The following routine(s) is (are) accessible for this file:"
      CALL dump_directory html, tmpDir, .nil, ctl.eRoutines2Files, title_string


 /* show available CLASSES ( all local and all public defined via requires ) */
      tmpDir = tmpFile ~ local_classes ~ union( tmpFile ~ visible_classes )
      title_String = "The following class(es) is (are) accessible for this file:"

      CALL dump_directory html, tmpDir, .nil, ctl.eClasses2Files, title_string, , .true /* with hyperlinks */

 /* show available classes as tree(s), indicate metaclass trees */
      CALL dump_roots html, tmpFile

 /* show usage of metaclasses (display metaclasses and their classes) */
      CALL dump_classes_using_metaclasses html, tmpFile

 /* show order of tiled classes for every leaf class */
      CALL dump_tiled_classes html, tmpFile, tmpFile ~ Local_Leaf_Classes, .false

 /* show found errors */
      htmlTable = .html_Table ~ new( "ALIGN=CENTER WIDTH=100%" )
      tmpString = "The following error(s) was (were) found during parsing:"
      html ~ h4( tmpString )

      IF tmpFile ~ errors ~ items > 0 THEN
      DO
         stats.eFile.eError.eSum = stats.eFile.eError.eSum + tmpFile ~ errors ~ items
         CALL show_sorted_errors htmlTable, tmpFile ~ errors
      END
      ELSE
        htmlTable ~ putColumn( "--- none ---", "ALIGN=CENTER" )

      html ~ lineout( htmlTable ~ htmlText )
   END

   html ~ hr( , "SIZE=5" )

   html ~ hr( , "WIDTH=75%" )


/* --------------------------- grand totals ----------------------------- */
/* total number of lines */
   tmp1 = pp( RIGHT( pp_number( stats.eLines.1.eSum ), 7) ) stats.eLines.1.eText

   tmp2 = pp( RIGHT( pp_number( stats.eLines.2.eSum ), 7) ) stats.eLines.2.eText,
          pp( RIGHT( format( ( stats.eLines.2.eSum * 100 / MAX( stats.eLines.1.eSum, 1) ) , , 2), 6) "%" )

   htmlTable = .html_Table ~ new( "BORDER ALIGN=CENTER CELLPADDING=3 WIDTH=60%" )
   htmlTable ~ setcaption( "Grand Totals - Statistics", "ALIGN=TOP" )

   PARSE VAR tmp1 "[" tot_loc "]" tot_text "[" tot_perc "]"
   PARSE VAR tmp2 "[" net_loc "]" net_text "[" net_perc "]"

   htmlTable ~~,
            putColumn( pp_number( sortedFiles ~ items ), "ALIGN=RIGHT" ) ~~,
            putColumn( "File(s) (including 1x environment) processed:", "COLSPAN=2" ) ~~,
            newRow

   htmlTable ~~ putColumn( "&nbsp;", "COLSPAN=3" ) ~~ newRow

   htmlTable ~~ ,
            putColumn( tot_loc, "ALIGN=RIGHT WIDTH=15%"  ) ~~ ,
            putColumn( tot_text ) ~~ ,
            putColumn( tot_perc, "ALIGN=RIGHT WIDTH=15%") ~~,
            newRow

   htmlTable ~~ ,
            putColumn( net_loc, "ALIGN=RIGHT") ~~,
            putColumn( net_text ) ~~,
            putColumn( net_perc, "ALIGN=RIGHT") ~~,
            newRow

   htmlTable ~~ putColumn( "&nbsp;", "COLSPAN=3" ) ~~ newRow

   DO j = 1 TO stats.eFile.0
      htmlTable ~~,
            putColumn( pp_number( stats.eFile.j.eSum ), "ALIGN=RIGHT" ) ~~,
            putColumn( stats.eFile.j.eText, "COLSPAN=2" ) ~~ newRow
   END

   htmlTable ~~ putColumn( "&nbsp;", "COLSPAN=3" ) ~~ newRow


   tmpHint = ""
   IF stats.eFile.eError.eSum > 0 THEN tmpHint = .Red.Dot

   htmlTable ~~,
            putColumn( pp_number( stats.eFile.eError.eSum ), "ALIGN=RIGHT" ) ~~,
            putColumn( "Error(s) found" tmpHint, "COLSPAN=2" ) ~~,
            newRow


   html ~ LINEOUT( "<CENTER>" )
   html ~ LINEOUT( htmlTable ~ htmlText )
   html ~ LINEOUT( "</CENTER>" )
   html ~ hr
   PARSE VALUE TIME("Elapsed") WITH formatTime
   CALL leadin html, , formatTime, "Summary document"

   html ~ hr( ,"SIZE=5" )
   RETURN

/* ------------------------------------------------------------------------- */






/* ========================================================================== */






/* ---------------------------------------------------------------------------------------- */
/* show details of analyzed files (in alphabetical order ) */
FILE_DETAILS: PROCEDURE EXPOSE ctl. stats.

   startFile = ctl.eFileStart           /* determine file to start with */
   sortedFiles = sort( ctl.eFiles )     /* returns array with sorted indices of .directory */

   DO i = 1 TO sortedFiles ~ items
      CALL TIME "Reset"                 /* reset clock */

      tmpFile = ctl.eFiles ~ entry( sortedFiles[ i ] )  /* get file object */
      CALL sayError "   details for" pp( tmpFile ~ Name ) "..."

      htmlFName = tmpFile ~ User_Slot ~ entry( "HTMLFileName" ) /* get HTML-file name */

      html = .html_doc ~ new(  htmlFName , ,                    /* create HTML-file */
                               "Results of analyzing:" pp( tmpFile ~ name ), ,
                               .true )     /* replace file, if it exists */

      html ~ LINEOUT( a_href( .html.Summary, "Start", "Back to Summary" ) )
      html ~ hr
/*----------------------------------- */
/* if this is the file which got analyzed, indicate this fact and show accessible routines and classes */
      tmpString = "File" smartCap( pp( tmpFile ~ name ) )

      IF tmpFile = startFile THEN
         tmpString = tmpString .Yel.Dot x2bare( "<--- (started the analysis !)" )

      html ~ h2( A_NAME( "Start", tmpString ) )         /* define anchor name with title */

      html ~ hr

/*----------------------------------- */
/* indicate which files REQUIRE this one */
      htmlTable = .html_Table ~ new( "ALIGN=CENTER WIDTH=100%" )
      tmpString = "According to the analysis the following file(s) require(s) this one:"
      html ~ h4( tmpString )

      IF tmpFile ~ required_by ~ items > 0 THEN
      DO
         CALL sort_def_list htmlTable, tmpFile ~ required_by
      END
      ELSE
         htmlTable ~ putColumn( "--- none ---", "ALIGN=CENTER" )

      html ~ LINEOUT( htmlTable ~ htmlText )
      html ~ hr( , "WIDTH=75%" )



/*----------------------------------- */
/* indicate which files are REQUIRED by this one */
      htmlTable = .html_Table ~ new( "ALIGN=CENTER WIDTH=100%" )
      tmpString = "According to the analysis this file requires the following file(s):"
      html ~ h4( tmpString )

      IF tmpFile ~ requires_files ~ items > 0 THEN
      DO
         CALL sort_def_list htmlTable, tmpFile ~ requires_files
      END
      ELSE
         htmlTable ~ putColumn( "--- none ---", "ALIGN=CENTER" )

      html ~ LINEOUT( htmlTable ~ htmlText )
      html ~ hr( , "WIDTH=75%" )




/*----------------------------------- */
/* show statistics */

      /* total number of lines */
      tmpTotLines         = pp( RIGHT( pp_number( tmpFile ~ total_loc ), 7) ) stats.eLines.1.eText

      tmpRealLines        = pp( RIGHT( pp_number( tmpFile ~ loc ), 7) ) stats.eLines.2.eText,
                            pp( RIGHT( format( (tmpFile ~ loc * 100 / MAX( tmpFile ~ total_loc, 1 ) ) , , 2), 6) "%" )

      htmlTable = .html_Table ~ new( "BORDER ALIGN=CENTER CELLPADDING=3 WIDTH=60%" )
      htmlTable ~ setcaption( "Statistics", "ALIGN=TOP" )

      PARSE VAR tmpTotLines  "[" tot_loc "]" tot_text "[" tot_perc "]"
      PARSE VAR tmpRealLines "[" net_loc "]" net_text "[" net_perc "]"

      htmlTable ~~ ,
               putColumn( tot_loc, "ALIGN=RIGHT WIDTH=15%"  ) ~~ ,
               putColumn( tot_text ) ~~ ,
               putColumn( tot_perc, "ALIGN=RIGHT WIDTH=15%") ~~,
               newRow

      htmlTable ~~ ,
               putColumn( net_loc, "ALIGN=RIGHT") ~~,
               putColumn( net_text ) ~~,
               putColumn( net_perc, "ALIGN=RIGHT") ~~,
               newRow

      htmlTable ~~ putColumn( "&nbsp;", "COLSPAN=3" ) ~~ newRow


      nrProcedures         = pp_number( ctl.eProcedures2Files ~ allat( tmpFile ) ~ items )
      htmlTable ~~ putColumn( nrProcedures, "ALIGN=RIGHT" ) ~~,
                   putColumn( stats.eFile.1.eText, "COLSPAN=2" ) ~~ newRow

      nrLabels             = pp_number( ctl.eLabels2Files     ~ allat( tmpFile ) ~ items )
      htmlTable ~~ putColumn( nrLabels, "ALIGN=RIGHT" ) ~~,
                   putColumn( stats.eFile.2.eText, "COLSPAN=2" ) ~~ newRow

      nrRequires           = pp_number( ctl.eRequires2Files   ~ allat( tmpFile ) ~ items )
      htmlTable ~~ putColumn( nrRequires, "ALIGN=RIGHT" ) ~~,
                   putColumn( stats.eFile.3.eText, "COLSPAN=2" ) ~~ newRow

      nrRoutines           = pp_number( ctl.eRoutines2Files   ~ allat( tmpFile ) ~ items )
      htmlTable ~~ putColumn( nrRoutines, "ALIGN=RIGHT" ) ~~,
                   putColumn( stats.eFile.4.eText, "COLSPAN=2" ) ~~ newRow

      nrClasses            = pp_number( ctl.eClasses2Files    ~ allat( tmpFile ) ~ items )
      htmlTable ~~ putColumn( nrClasses, "ALIGN=RIGHT" ) ~~,
                   putColumn( stats.eFile.5.eText, "COLSPAN=2" ) ~~ newRow

      nrMethods            = pp_number( ctl.eMethods2Files    ~ allat( tmpFile ) ~ items )
      htmlTable ~~ putColumn( nrMethods, "ALIGN=RIGHT" ) ~~,
                   putColumn( stats.eFile.6.eText, "COLSPAN=2" ) ~~ newRow

      htmlTable ~~ putColumn( "&nbsp;", "COLSPAN=3" ) ~~ newRow

      tmpHint = ""
      IF tmpFile ~ errors ~ items > 0 THEN tmpHint = .Red.Dot

      htmlTable ~~,
               putColumn( pp_number( tmpFile ~ errors ~ items ), "ALIGN=RIGHT" ) ~~,
               putColumn( "Error(s) found" tmpHint, "COLSPAN=2" ) ~~,
               newRow

      html ~ lineout( "<CENTER>" )
      html ~ LINEOUT( htmlTable ~ htmlText )
      html ~ lineout( "</CENTER>" )
      html ~ hr( , "WIDTH=75%" )


/*----------------------------------- */
/* indicate whether file may be called as a procedure / function */
/* if so, show signatures and returns                            */

      IF tmpFile ~ IsProcedure | tmpFile ~ IsFunction THEN
      DO
         tmpString = "This file may be called as a procedure"
         IF tmpFile ~ IsFunction THEN tmpString = tmpString www_tag("and", "EM") "as a function (it returns values)"

         html ~ h4( tmpString )

         htmlTable = .html_Table ~ new( "ALIGN=CENTER WIDTH=100%" )

         /* show signatures */
         IF tmpFile ~ signatures ~ items > 0 THEN
         DO
            title_string = "The following attempt(s) for argument parsing was (were) found:"
            CALL dump_detail_dir2string htmlTable, tmpFile ~ signatures, title_string
         END

         /* show return expressions */
         IF tmpFile ~ returns ~ items > 0 THEN
         DO
            title_string = "The following RETURN statements was (were) found:"
            CALL dump_detail_dir2string htmlTable, tmpFile ~ returns, title_string
         END

         /* show exit expressions */
         IF tmpFile ~ returns ~ items > 0 THEN
         DO
            title_string = "The following EXIT statement(s) was (were) found:"
            CALL dump_detail_dir2string htmlTable, tmpFile ~ exits, title_string
         END

         /* show labels within main body */
         title_string = "This file contains the following label(s) in its main body:"
         CALL dump_detail_dir2proclikes htmlTable, tmpFile ~ local_labels, title_string, .true

         html ~ LINEOUT( htmlTable ~ htmlText )
         html ~ hr( , "WIDTH=75%" )
      END


/*----------------------------------- */
 /* show available ROUTINES ( all local and all public defined via requires ) */
      tmpDir = tmpFile ~ local_Routines ~ union( tmpFile ~ visible_routines )
      title_String = "The following routine(s) is (are) accessible for this file:"
      CALL dump_directory html, tmpDir, tmpFile, ctl.eRoutines2Files, title_string


/*----------------------------------- */
 /* show available CLASSES ( all local and all public defined via requires ) */
      tmpDir = tmpFile ~ local_classes ~ union( tmpFile ~ visible_classes )
      title_String = "The following class(es) is (are) accessible for this file:"
      CALL dump_directory html, tmpDir, tmpFile, ctl.eClasses2Files, title_string, , .true /* with hyperlinks */


/*----------------------------------- */
 /* show available classes as tree(s), indicate metaclass trees */
      CALL dump_roots html, tmpFile


/*----------------------------------- */
/* show usage of metaclasses (display metaclasses and their classes) */
      CALL dump_classes_using_metaclasses html, tmpFile


/*----------------------------------- */
/* show procedures for file, including labels */
      htmlTable = .html_Table ~ new( "BORDER ALIGN=CENTER WIDTH=100%" )
      html ~ h4( "Procedures defined for file" )
      title_string = ""
      CALL dump_detail_dir2proclikes htmlTable, tmpFile ~ local_procedures, title_string, .true
      html ~ LINEOUT( htmlTable ~ htmlText )

/*----------------------------------- */
/* show routines for file, including labels, procedures */
      htmlTable = .html_Table ~ new( "BORDER ALIGN=CENTER WIDTH=100%" )
      html ~ h4( "::ROUTINE(s) defined within file" )
      title_string = ""
      CALL dump_detail_dir2proclikes htmlTable, tmpFile ~ local_routines, title_string, .true
      html ~ LINEOUT( htmlTable ~ htmlText )


/*----------------------------------- */
/* show floating methods for file including labels & procedures */
      IF tmpFile ~ local_methods ~ items > 0 THEN
      DO
         html ~ h4( "::METHOD(s) *not* attached to a specific class (floating)" )
         htmlTable = .html_Table ~ new( "BORDER ALIGN=CENTER WIDTH=100%" )
         title_string = ""
         CALL dump_detail_dir2methods htmlTable, tmpFile ~ local_methods, title_string, .true
         html ~ LINEOUT( htmlTable ~ htmlText )
      END



/*----------------------------------- */
/* show classes for file, including methods, which:
        show class & instance methods including labels & procedures */

      title_string = "::CLASS(es) defined, detail view"
      CALL dump_detail_dir2classes html, tmpFile ~ local_classes, title_string, .true


/*------------------------------------------------------------------------------ */
      /* show order of tiled classes for *every* class, including methods (!) */
      tmp = tmpFile ~ Local_Classes ~ supplier

      tmpList = .list ~ new                     /* produce list containing def_classes only */
      DO WHILE tmp ~ available
         tmpList ~ insert( tmp ~ item )
         tmp ~ next
      END
      CALL dump_tiled_classes html, tmpFile, tmpList, .true




/*----------------------------------- */
/* show found errors */
      htmlTable = .html_Table ~ new( "ALIGN=CENTER WIDTH=100%" )
      tmpString = "The following error(s) was (were) found during parsing:"
      html ~ h4( tmpString )

      IF tmpFile ~ errors ~ items > 0 THEN
      DO
         stats.eFile.eError.eSum = stats.eFile.eError.eSum + tmpFile ~ errors ~ items
         CALL show_sorted_errors htmlTable, tmpFile ~ errors
      END
      ELSE
        htmlTable ~ putColumn( "--- none ---", "ALIGN=CENTER" )

      html ~ lineout( htmlTable ~ htmlText )
      html ~ hr( , "SIZE=3" )

      PARSE VALUE TIME("Elapsed") WITH formatTime
      CALL leadin html, , formatTime, tmpFile ~ name

      html ~ LINEOUT( a_href( .html.Summary, "Start", "Back to Summary" ) )
      html ~ hr

      html ~ close                              /* close html-file */
      CALL CPFile2SGMLEntity htmlFName          /* use SGML-entities for chars > x7F    */

   END

   RETURN





/* ========================================================================== */








/* ---------------------------------------------------------------------------------------- */

/* show all metaclasses and classes using it */

DUMP_CLASSES_USING_METACLASSES: PROCEDURE EXPOSE ctl.
    USE ARG html, tmpFile, line_nr

    IF \VAR( "line_nr" ) THEN line_nr = .false   /* default to not show line numbers */

    tmpDir = tmpFile ~ Local_MetaClasses                /* show metaclass usage */

    IF tmpDir ~ items = 0 THEN RETURN                   /* no metaclasses used in this file */

    tmpArr = sort( tmpDir )

    htmlTable = .html_Table ~ new( "BORDER CELLPADDING=1 ALIGN=CENTER WIDTH=100%" )
    tmpString = "Metaclass(es) being explicitly used by:"
    skipLevel = 4
    html ~ h4( tmpString )

    DO i = 1 TO tmpArr ~ items                  /* display metaclasses */
       tmpObject = tmpDir ~ entry( tmpArr[ i ] )

       tmpName        = "Metaclass" smartCap( pp( tmpObject ~ name) )
       tmpErrorString = ""


       IF tmpObject ~ IsMetaClass THEN
          tmpName   = tmpName   "is used by:"
       ELSE
          tmpErrorString = .Red.Dot "** error ** (" || www_tag( "not", "EM" ) || "a metaclass!)"   /* show name */

       tmpLine = ""
       IF line_nr THEN
          tmpLine = tmpLine smartCap( pp_lineNr( tmpObject ~ LineNr ) )

       htmlTable ~~ putColumn( tmpName, "COLSPAN=" || skipLevel + 1 ) ~~ putColumn( tmpErrorString )
       htmlTable ~~ putColumn( tmpLine ) ~~ newRow

       bNone = .true
       nrItems = tmpObject ~ MetaUsedBySet ~ items
       IF  nrItems > 0 THEN                             /* show classes using this metaclass */
       DO
          bNone = .false
          tmpUseDir = .directory ~ new                  /* build a directory of classes using this metaclass */
          DO item OVER tmpObject ~ MetaUsedBySet
             tmpUseDir ~ setentry( item ~ name, item )
          END

          tmpUseArr = sort( tmpUseDir )                 /* sort entries */
          DO j = 1 TO tmpUseArr ~ items
             aClass = tmpUseDir ~ entry( tmpUseArr[ j ] )       /* get class */
             tmpString = smartCap( pp( aClass ~ name) )
             tmpHint = ""
             tmpMetaClassObject = aClass ~ MetaClassObject

             IF aClass <> tmpMetaClassObject THEN       /* don't show a metaclass defined by itself */
             DO
                IF aClass ~ IsMetaClass THEN            /* ha, a metaclass is using a metaclass as its metaclass ? */
                DO
                   tmpHint = "(metaclass)"
                END

                htmlTable ~~ putColumn("&nbsp;", "ALIGN=RIGHT" ) ~~ putColumn( tmpString, "COLSPAN=" || skipLevel )
                htmlTable ~~ putColumn( tmpHint, "ALIGN=CENTER" ) ~~ newRow
             END
             ELSE
               bNone = nrItems = 1                      /* indicate no other classes, if only class itself exists */
          END
       END

       IF bNone THEN                                    /* no class usages given */
       DO
          IF tmpObject ~ IsMetaClass THEN
          DO
             htmlTable ~~ putColumn("&nbsp;", "ALIGN=RIGHT" ) ~~ putColumn( "--- no class ! ---" , "COLSPAN=" || skipLevel )
          END
       END
       htmlTable ~~ newRow ~~ putColumn ~~ putColumn ~~ putColumn ~~ newRow

    END

    html ~ lineout( htmlTable ~ htmlText )
    html ~ hr( , "WIDTH=75%" )

    RETURN





/* ---------------------------------------------------------------------------------------- */
/* show order of tiled classes for classes, passed in via every a collection

     tmpFile  - File (local classes being shown)
     collObj  - Collection of local [leaf] classes
     bDetail  - indicate whether methods should be shown (and aligned)
     bBottomUp - indicate whether tiling should show class first and .object last (.true) or
                                               show .object first and class last (.false)

     Remarks: while building the class-tree for a a leaf-class the starting class has a "level" of
              0, a meta-class, a level of "-1", a meta-class for a meta-class, a level of "-2", etc.
*/
DUMP_TILED_CLASSES : PROCEDURE EXPOSE ctl.
   USE ARG html, tmpFile, collObject, bDetail, bObjectClassAtTop

   IF collObject ~ items = 0 THEN RETURN        /* nothing to show */

   IF \ VAR( bObjectClassAtTop) THEN bObjectClassAtTop = .false   /* default, determines order of shown "tiling" */

   IF \ .bShowEnvTilingWithMethodsEnv THEN      /* do a detailed tiling on .environment classes ? */
   DO
      /* too large ! 800KB with environment tiling !!! */
      IF bDetail & tmpFile = ctl.eFileEnvironment THEN
         RETURN
   END

   /* build a list of superclasses, starting with leaves, remember top of every */
   tmpLeafDir  = .directory ~ new

   /* turn set into directory, store class leaves, i.e. every class ---> a leaf, its superclasses in list */
   DO aClass OVER collObject
      IF tmpFile = .Env.FileObj THEN            /* if dumping environment, don't show classes given in .ignoreClasses */
      DO
        IF WORDPOS( SUBSTR( aClass ~ name, 2 ), .ignoreClasses ) > 0 THEN       /* remove leading dot */
           ITERATE
      END

      tmpList = .list ~ new
      tmpLeafDir ~ setentry( aClass ~ name, tmpList )

      /* build list of superclasses (last entry is root class) */
      tmpList ~ insert( aClass )                        /* store starting class  */

   END

   def_Class = aClass ~ class                           /* save class-object for def_class */
   max_length = def_Class ~ max_name_length + 2         /* get maximum classname length, account for brackets */

   /* sort directory of lists */
   tmpArr = sort( tmpLeafDir )

/* -------------------------------------------- */
   DO i = 1 TO tmpArr ~ items                           /* produce and display tiled classes */
      htmlTable = .html_Table ~ new( "BORDER CELLPADDING=1 ALIGN=CENTER WIDTH=100%" )

      tmpSetDir = .directory ~ new                      /* directory to contain sets for different class/metaclass levels */
      tmpSetDir ~ setentry( "1", .set ~ new )           /* set to contain classes already processed */

      HighestLevel = 0

      tmpList = tmpLeafDir ~ entry( tmpArr[ i ] )       /* process list, setup tiling, print it */
      tmpHierarchyList = .list ~ new


      next  = tmpList ~ first                           /* get first list entry */
/**/
      aClass = tmpList ~ at( next )                  /* get class-def */
      last = tmpHierarchyList ~ last                 /* get last entry, everything has to be inserted right after it */
      /* "HighestLevel" gets set in routine */
      CALL get_hierarchy_up aClass, tmpSetDir, tmpHierarchyList, last, 1 /* create tiled tree */
/**/




      /* now dump tiling */
      firstItem = tmpList ~ firstItem                   /* get first list item */
      tmpClass  = tmpList ~ firstItem                   /* get def_class object */

      tmpString = pp( tmpClass ~ name )
      tmpAttrString = tmpClass ~ dumpAttributes( .false )
      IF tmpAttrString <> "" THEN tmpString = tmpString pp( tmpAttrString )

/* -------------------------------------------- */
      IF \bDetail THEN                                  /* show summary */
      DO
         tmpClass = "Summary view of the tiling of leaf class:" www_tag( smartCap( pp( tmpClass ~ name) ), "EM" )
         html ~ h4( tmpClass )

         IF bObjectClassAtTop THEN next = tmpHierarchyList ~ last
                     ELSE next = tmpHierarchyList ~ first

         tmp_length = max_length + 25
         DO WHILE next <> .nil
            tmpItem = tmpHierarchyList ~ at( next )
            list_Item = tmpItem[ 1 ]                    /* get def_class object */
            tmpLevel  = HighestLevel - tmpItem[ 2 ]     /* level this class was found at, calculate indention */

            tmpClassString = smartCap( pp( list_item ~ name ) )
            tmpHint   = ""
            sourceFileName = ""

            IF      list_item = .missing.class THEN tmpHint = x2bare( "<-- MISSING" )
            ELSE IF list_item ~ IsMetaClass    THEN tmpHint = "(metaclass)"

            /* check whether defined in a different file, if so, display it ! */
            sourceFile = ctl.eClasses2Files ~ index( list_item )
            IF tmpFile <> sourceFile THEN sourceFileName = smartCap( pp( sourceFile ~ name ) )

            IF list_item ~ errors ~ items > 0 THEN tmpHint = tmpHint .Red.Dot "in error !"

            additionalCols = 3                  /* -3rd: hint, -2nd: "defined in:", -1st: file */

            /* rgf was here */
            DO tmpLevel
               htmlTable ~~ putColumn("&nbsp;", "WIDTH=20%" )
            END
            /*
            htmlTable ~~ skipColumn( tmpLevel )
            */
            /* rgf was here */

            htmlTable ~~ putColumn( tmpClassString, "WIDTH=20%" )

            /* rgf was here */
            DO ( highestLevel - tmpLevel - 1)       /* if a gap, then skip */
               htmlTable ~ putColumn( "&nbsp;", "WIDTH=20%" )
            END
            /*
            htmlTable ~~ SkipColumn( highestLevel - tmpLevel - 1)       /* if a gap, then skip */
            */
            /* rgf was here */

            htmlTable ~~ putColumn( tmpHint, "WIDTH=10%" )

            IF sourceFileName <> "" THEN
            DO
               htmlTable ~~ putColumn( "from:", "ALIGN=RIGHT WIDTH=10%" )
               htmlTable ~~ putColumn( sourceFileName, "WIDTH=15%" )
            END
            htmlTable ~~ newRow( HighestLevel + additionalCols )

            IF bObjectClassAtTop THEN next = tmpHierarchyList ~ previous( next )
                        ELSE next = tmpHierarchyList ~ next( next )
         END
      END




/* -------------------------------------------- */
      ELSE                                              /* show detail (aligned methods) */
      DO                                                /* per level 2 columns (class/instance methods) */
         tmpClass = pp( i ) "Details view of the tiling of class:" www_tag( smartCap( pp( tmpClass ~ name) ), "EM" )
         html ~ h4( tmpClass )


         /* create temporary set to save methods already directly accessible */
         tmpClassMethDir     = .directory ~ new     /* save seen class methods */
         tmpInstanceMethDir  = .directory ~ new     /* save seen instance methods */

         IF bObjectClassAtTop THEN next = tmpHierarchyList ~ last
                     ELSE next = tmpHierarchyList ~ first

         tmpRootClass = tmpHierarchyList ~ at( next )[1]/* save root class */
         IsRootClassMeta = tmpRootClass ~ IsMetaClass   /* get metaclass indicator */

         DO WHILE next <> .nil
            tmpItem = tmpHierarchyList ~ at( next )
            list_Item = tmpItem[ 1 ]                    /* get def_class object */
            tmpLevel  = HighestLevel - tmpItem[ 2 ]     /* level this class was found at, calculate indentation */
            oriLevel  = tmpItem[ 2 ]                    /* original level */

            tmpClassString = smartCap( pp( list_item ~ name ) )
            tmpHint   = ""
            sourceFileName = ""

            IF      list_item = .missing.class THEN tmpHint = x2bare( "<-- MISSING" )
            ELSE IF list_item ~ IsMetaClass    THEN tmpHint = "(metaclass)"
            IF list_item ~ errors ~ items > 0  THEN tmpHint = tmpHint .Red.Dot "in error !"

            IF tmpHint <> "" THEN tmpHint = www_tag( tmpHint, "FONT SIZE=-1" )


            /* check whether defined in a different file, if so, display it ! */
            sourceFile = ctl.eClasses2Files ~ index( list_item )

            IF tmpFile <> sourceFile THEN
               sourceFileName = Capitalize( pp( sourceFile ~ shortName ), "FONT SIZE=-1", "FONT SIZE=-2" )


            bIsMetaClass = list_item ~ IsMetaClass

            additionalCols = 3                  /* -3rd: hint, -2nd: "defined in:", -1st: file */


            DO tmpLevel
               htmlTable ~~ putColumn( "&nbsp;", "WIDTH=20%" )
            END

            htmlTable ~~ putColumn( www_tag( tmpClassString, "STRONG WIDTH=20%" ) )
            htmlTable ~~ SkipColumn( highestLevel - tmpLevel + ( highestLevel <> tmpLevel ) )

            htmlTable ~~ putColumn( tmpHint, "WIDTH=15%" )

            IF sourceFileName <> "" THEN
            DO
               htmlTable ~~ putColumn( www_tag( "from:", "FONT SIZE=-1"), "ALIGN=RIGHT WIDTH=10%" )
               htmlTable ~~ putColumn( sourceFileName, "WIDTH=15%" )
            END
            htmlTable ~~ newRow( HighestLevel * 2 + additionalCols )


            bShowMethods = ( list_item <> .missing.class )

            IF bShowMethods THEN
            DO
               IF \ .bShowEnvMethods THEN               /* show .environment class methods while tiling non .environment classes ? */
               DO       /* don't show methods, if they belong to an .environment class */

                  bShowMethods = \ ctl.eEnvClassSet ~ HASINDEX( list_item )
               END
            END


            /* now show methods */
            IF bShowMethods THEN
            DO
     /* dump *class* methods */
               tmpClassDir = list_item ~ Local_Class_Methods
               tmpClassArr = sort( tmpClassDir )
               classArray = .array ~ new( 0, 0 )                /* array to contain formatted methods */

               DO k = 1 TO tmpClassArr ~ items
                  tmpMethObj = tmpClassDir ~ entry( tmpClassArr[ k ] )
                  tmpString = tmpMethObj ~ name
                  tmpAttributes = STRIP( tmpMethObj ~ DumpAttributes( .false ) )
                  tmpString = smartCap( ( tmpString tmpAttributes ), "Cap", .false )

                  IF oriLevel = 1  THEN                 /* class methods only reachable if at level 1 */
                  DO
                        tmpName = tmpMethObj ~ name                            /* get method's name */
                        IF  tmpClassMethDir ~ entry( tmpName ) = .nil THEN     /* not recorded as of yet */
                        DO
                           IF \ bObjectClassAtTop THEN
                              tmpString = tmpString .Yel.Dot                       /* hint for direct access */
                           tmpClassMethDir ~ setentry( tmpName, tmpName )
                        END
                  END
                  classArray[ k, 1 ] = tmpLevel                 /* columns to skip */
                  classArray[ k, 2 ] = tmpString                /* string to show  */

               END


     /* dump *instance* methods */
               tmpClassDir = list_item ~ Local_Instance_Methods
               tmpClassArr = sort( tmpClassDir )
               instArray = .array ~ new( 0, 0 )                /* array to contain formatted methods */

               DO k = 1 TO tmpClassArr ~ items
                  tmpMethObj = tmpClassDir ~ entry( tmpClassArr[ k ] )
                  tmpString = tmpMethObj ~ name
                  tmpAttributes = STRIP( tmpMethObj ~ DumpAttributes( .false ) )
                  tmpString = smartCap( (tmpString tmpAttributes), "Cap", .false )



                  IF oriLevel <= 2 THEN
                  DO
                     /* indicate whether class method is directly accessible from starting class */
                     tmpName = tmpMethObj ~ name                   /* get method's name */

                     IF oriLevel = 1 THEN                               /* instance method in same column */
                     DO
                        IF  tmpInstanceMethDir ~ entry( tmpName ) = .nil THEN  /* not recorded as of yet */
                        DO
                           IF \ bObjectClassAtTop THEN
                              tmpString = tmpString .Yel.Dot                       /* hint for direct access */
                           tmpInstanceMethDir ~ setentry( tmpName, tmpName )
                        END
                     END
                     ELSE               /* oriLevel = 2: instance method is class method for class being tiled */
                     DO
                        IF tmpClassMethDir ~ entry( tmpName ) = .nil THEN      /* not recorded as of yet */
                        DO
                           IF \ bObjectClassAtTop THEN
                              tmpString = tmpString .Yel.Dot                       /* hint for direct access */
                           tmpClassMethDir ~ setentry( tmpName, tmpName )
                        END
                     END
                  END

                  instArray[ k, 1 ] = tmpLevel + 1             /* columns to skip */
                  instArray[ k, 2 ] = tmpString                /* string to show  */
               END

               /* write methods to table */
               DO k = 1 TO MAX( classArray ~ items, instArray ~ items ) / 2
                  bSkipped = .false
                  /* write class method */
                  IF classArray[ k, 1 ] <> .nil THEN
                  DO
                     /* rgf was here */
                     DO classArray[ k, 1 ]
                        htmlTable ~~ putColumn( "&nbsp;", "WIDTH=10%" )
                     END
                     /*
                     htmlTable ~~ skipColumn( classArray[ k, 1 ] ),
                     */
                     /* rgf was here */
                     htmlTable ~~  putColumn( www_tag( classArray[ k, 2 ], "FONT SIZE=-1 WIDTH=25%" ) )
                     bSkipped = .true                              /* already skipped from the beginning */
                  END

                  IF instArray[ k, 1 ] <> .nil THEN
                  DO
                     IF \ bSkipped THEN
                     DO
                        /* rgf was here */
                        DO instArray[ k, 1 ]
                           htmlTable ~~ putColumn( "&nbsp;", "WIDTH=20%" )
                        END
                        /*
                        htmlTable ~~ skipColumn( instArray[ k, 1 ] )
                        */
                        /* rgf was here */
                     END

                     htmlTable ~~  putColumn( www_tag( instArray[ k, 2 ], "FONT SIZE=-1 WIDTH=25%" ) )
                  END
                  htmlTable ~~ newRow
               END

               htmlTable ~~ putColumn() ~~ newRow

            END

            IF bObjectClassAtTop THEN next = tmpHierarchyList ~ previous( next )
                        ELSE next = tmpHierarchyList ~ next( next )
         END
      END
/* -------------------------------------------- */

      html ~ lineout( htmlTable ~ htmlText )
   END
   html ~ hr( , "WIDTH=75%" )

   RETURN




/* ---------------------------------------------------------------------------------------- */
/* produce a hierarchy list with starting class */
/* insert aCLASS into TMPHIERARCHYLIST, if it is not in TMPSET, position in list is
   indicated by POSITION_IN_LIST */
GET_HIERARCHY_UP: PROCEDURE EXPOSE ctl. HighestLevel
   USE ARG aClass, tmpSetDir, tmpHierarchyList, position_in_list, level

   IF aClass = .missing.class THEN                      /* leave missing class in list to indicate error */
   DO
      tmpHierarchyList ~ insert( .array~ of(aClass, level) , position_in_list )     /* insert class in front */
      RETURN
   END

   tmpSet = tmpSetDir ~ entry( level )                  /* get appropriate set to contain classes already processed at this level */

   IF tmpSet ~ hasindex( aClass ) THEN                  /* already handled */
   do
      RETURN
   end


   HighestLevel = MAX( level, HighestLevel )            /* store highest level (deepness w.r.t. metaclasses) */
   listIndex = tmpHierarchyList ~ insert( .array ~ of( aClass, level) , position_in_list) /* insert class in front, remember level */
   tmpSet ~ put( aClass )                               /* indicate that class has been handled at this level */

   tmpListOfSuperClasses = aClass ~ ListOfSuperClasses
   next = tmpListOfSuperClasses ~ last
   DO WHILE next <> .nil
      item = tmpListOfSuperClasses ~ at( next )

      IF \tmpSet ~ HASINDEX( item ) THEN      /* class not handled as of yet */
      DO
         CALL get_hierarchy_up item, tmpSetDir, tmpHierarchyList, listIndex, level
      END

      next = tmpListOfSuperClasses ~ previous( next )
   END

   aMetaClass = aClass ~ MetaClassObject                /* now resolve metaclass by putting it in front */
   IF aMetaClass <> .nil THEN
   DO
      IF \tmpSet ~ HASINDEX( aMetaClass) THEN           /* this class was not handled at this level as of yet */
      DO
         tmpSet ~ put( aMetaClass )                     /* indicate that class has been handled at this level */
         level = level + 1                              /* generate a new level */

         tmpSet = tmpSetDir ~ entry( level )            /* get the set of the next level and check whether metaclass was handled already */

         bRecurse = .false
         IF tmpSet = .nil THEN                          /* does a set for this metaclass level exist already ? */
         DO
            tmpSetDir ~ setentry( level, .set ~ new )   /* create an empty set for this new level */
            bRecurse = .true
         END
         ELSE
            bRecurse = \ tmpSet ~ HASINDEX( aMetaClass) /* only recurse if not handled at that level already ! */



         /* recurse, build a hierarchy for this metaclass at this new level */
         IF bRecurse THEN
         do
            CALL get_hierarchy_up aMetaClass, tmpSetDir, tmpHierarchyList, listIndex, level
         end
      END
   END

   RETURN



/* ---------------------------------------------------------------------------------------- */
DUMP_ROOTS: PROCEDURE   EXPOSE ctl.
   USE ARG html, tmpFile

   IF tmpFile ~ Local_Root_classes ~ items = 0 THEN RETURN      /* nothing to show */

   table1 = .html_table ~ new( "BORDER WIDTH=100% ALIGN=CENTER" )
   tmpString = "Show available root class(es) and founding metaclass(es) as tree(s):"
   html ~ h4( tmpString )


   tmpRootDir  = .directory ~ new
   /* turn set into directory */
   DO aClass OVER tmpFile ~ Local_Root_Classes
      tmpRootDir ~ setentry( aClass ~ name, aClass )
   END

   max_name_width =  aClass ~ class ~ max_name_length + 2 /* get maximum length of name, account for brackets */

   tmpArray = sort( tmpRootDir )                /* sort directory */
   DO i = 1 TO tmpArray ~ items                 /* dump classes in sorted root-order */
      tmpClass = tmpRootDir ~ entry( tmpArray[i] )
      CALL dump_sub_classes table1, tmpClass, 0, tmpClass ~ IsMetaClass
      table1 ~~ emptyColumn ~~ newRow
   END
   html ~ lineout( table1 ~ htmlText )
   html ~ hr( , "WIDTH=75%" )
   RETURN



/* ---------------------------------------------------------------------------------------- */
/* dump class tree recursively */
DUMP_SUB_CLASSES: PROCEDURE EXPOSE .ctl
  USE ARG htmlTable, class, level, IsMetaClass

  ClassName     = pp( class ~ name )
  MetaClassName = ""

  tmpHint = ""
  /* if this class has a metaclass defined with it, show it */
  IF ( level = 0 & IsMetaClass = .true ) | ( class ~ MetaClassObject <> .nil ) THEN
  DO
     IF class ~ MetaClassObject <> .nil THEN
     DO
         metaClassName = pp( class ~ MetaClassObject ~ name )
         tmpHint = "metaclass"
     END
     ELSE               /* no explicit metaclass, but subclassing .class ? */
     DO
        IF class ~ SuperClassObject ~ SuperClassObject <> .nil THEN     /* make sure .object is not shown */
        DO
           metaClassName = pp( class ~ SuperClassObject ~ name )
           tmpHint = "metaclass"
        END
     END
  END

  DO level
     htmlTable ~ putColumn( "&nbsp;", "WIDTH=5%" )
  END

  htmlTable ~ putColumn( smartCap( ClassName ), "WIDTH=10%" )
  nextCol = MAX( level + 1, 10 )

  htmlTable ~ skipColumn( MAX( 0, nextCol - level - 1 ) )

  IF MetaClassName <> "" THEN
     htmlTable ~ putColumn( tmpHint smartCap( MetaClassName ), "WIDTH=25%" )
  ELSE
     htmlTable ~ putColumn

  htmlTable ~ newRow

  subClassSet = class ~ SetOfSubclasses
  tmpDir  = .directory ~ new


  /* turn set into directory */
  DO aClass OVER SubClassSet
     tmpDir ~ setentry( aClass ~ name, aClass )
  END

  tmpArray = sort( tmpDir )                    /* sort directory */
  DO i = 1 TO tmpArray ~ items                 /* dump in sorted root-order */
     tmpClass = tmpDir ~ entry( tmpArray[i] )
     CALL dump_sub_classes htmlTable, tmpClass, level + 1, IsMetaClass /* call recursively */
  END

  RETURN


/* ---------------------------------------------------------------------------------------- */
/* recursively dump proc-like data ( LABELS, PROCEDURES, ROUTINES )                */
/* dump detail of a directory pointing to strings ( LABELS, PROCEDURES, ROUTINES ) */
DUMP_DETAIL_DIR2PROCLIKES: PROCEDURE EXPOSE ctl.
   USE ARG htmlTable, tmpDir, title_string, line_nr

   IF \VAR( "line_nr" ) THEN line_nr = .false   /* default to not show line numbers */

   colSpan = 8

   /* show labels, procedures, routines stored with directory */
   IF tmpDir ~ items > 0 THEN
   DO
      htmlTable ~~ putColumn( www_tag( x2bare( title_string ),  "STRONG"), "COLSPAN=" || colSpan + 1 ) ~~ newRow

      tmpArr = sort( tmpDir )

      DO i = 1 TO tmpArr ~ items                        /* display entries */
         tmpObject = tmpDir ~ entry( tmpArr[ i ] )

         tmpString = ""

         tmpName = pp( tmpObject ~ name )

         IF      tmpObject ~ class ~ id = "DEF_PROCEDURE" THEN tmpName = tmpName ": PROCEDURE"
         ELSE IF tmpObject ~ class ~ id = "DEF_LABEL"     THEN tmpName = tmpName ":"
         ELSE IF tmpObject ~ class ~ id = "DEF_ROUTINE"   THEN tmpName = tmpObject ~ type tmpName

         tmpAttributes = tmpObject ~ dumpAttributes     /* show attributes (EXPOSE, PUBLIC) */
         extRange = \( tmpAttributes = "" )             /* account for missing attribute ? */


         tmpLine = ""
         IF line_nr THEN                                /* show line # */
            tmpLine = pp_lineNr( tmpObject ~ LineNr )

         htmlTable ~~ putColumn( i, "ALIGN=RIGHT WIDTH=5%" ) ~~,
                      putColumn( smartCap( tmpName ), "COLSPAN=" || colSpan / (extRange + 1) )

         IF tmpAttributes <> "" THEN
            htmlTable ~~ putColumn( smartCap( tmpAttributes ), "COLSPAN=" || colSpan / 2 )

         htmlTable ~~ putColumn( tmpLine, "ALIGN=RIGHT WIDTH=10%" ) ~~ newRow


         bDirty = .false
         htmlTable1 = .html_Table ~ new( "BORDER ALIGN=CENTER WIDTH=100%" )

         IF tmpObject ~ errors ~ items > 0 THEN
         DO
            htmlTable ~~ skipColumn( level )
            htmlTable ~~ putColumn( www_tag( "The following error(s) was (were) recorded:", "STRONG"),,
                                    "COLSPAN=" || MAX( 1, colSpan - level )  ) ~~ newRow
            CALL show_sorted_errors htmlTable1, tmpObject ~ errors, level, colSpan
            bDirty = .true
         END


         IF tmpObject ~ signatures ~ items > 0 THEN     /* show signatures */
         DO
            title_string = ""
            CALL dump_detail_dir2string htmlTable1, tmpObject ~ signatures, title_string
            bDirty = .true
         END

         IF tmpObject ~ returns    ~ items > 0 THEN     /* show return statements */
         DO
            title_string = "The following RETURN statements was (were) found:"
            title_string = ""
            CALL dump_detail_dir2string htmlTable1, tmpObject ~ returns, title_string
            bDirty = .true
         END

         IF tmpObject ~ exits      ~ items > 0 THEN     /* show exit-statements */
         DO
            title_string = "The following EXIT statement(s) was (were) found:"
            title_string = ""
            CALL dump_detail_dir2string htmlTable1, tmpObject ~ exits, title_string
            bDirty = .true
         END


         IF tmpObject ~ hasmethod( "local_labels" ) THEN
         DO
            IF tmpObject ~ local_labels ~ items > 0 THEN           /* show labels, but recurse */
            DO
               title_string = "Locally defined LABEL(s):"
               CALL dump_detail_dir2proclikes htmlTable1, tmpObject ~ local_labels, title_string, line_nr

               bDirty = .true
            END
         END

         IF tmpObject ~ hasmethod( "local_procedures" ) THEN
         DO
            IF tmpObject ~ local_procedures ~ items > 0 THEN       /* show procedures, but recurse */
            DO
               title_string = "Locally defined PROCEDURE(s):"
               CALL dump_detail_dir2proclikes htmlTable1, tmpObject ~ local_procedures, title_string, line_nr

               bDirty = .true
            END
         END

         IF bDirty THEN                                    /* was htmlTable1 written to ? */
            htmlTable ~~ skipColumn( 1 ) ~~ putColumn( htmlTable1 ~ htmlText, "COLSPAN=" || colSpan + 1 ) ~~ newRow
         ELSE
            htmlTable ~~ newRow

      END
    END
    RETURN



/* ---------------------------------------------------------------------------------------- */
/* dump detail of a directory pointing to strings ( METHOD ) */
DUMP_DETAIL_DIR2METHODS: PROCEDURE EXPOSE ctl.
   USE ARG htmlTable, tmpDir, title_string, line_nr

   IF tmpDir ~ items = 0 THEN RETURN            /* nothing to do */
   IF \VAR( "line_nr" ) THEN line_nr = .false   /* default to not show line numbers */

   /* show methods */
   methSpan = 8
   htmlTable ~~ putColumn( www_tag( x2bare( title_string ), "STRONG"), "COLSPAN=" || methSpan + 1 ) ~~ newRow

   tmpArr = sort( tmpDir )

   DO i = 1 TO tmpArr ~ items                        /* display entries */
      tmpObject = tmpDir ~ entry( tmpArr[ i ] )

      tmpName = "::method" pp( tmpObject ~ name )

      tmpAttributes = ( tmpObject ~ dumpAttributes )

      tmpLine = ""

      IF line_nr THEN                           /* show line numbers ? */
         tmpLine = smartCap( pp_lineNr( tmpObject ~ LineNr ) )

      htmlTable ~~ putColumn( i, "ALIGN=RIGHT WIDTH=5%" )

      IF tmpAttributes <> "" THEN
      DO
         htmlTable ~~ putColumn( smartCap( tmpName ), "COLSPAN=" || methspan / 2 )
         htmlTable ~~ putColumn( smartCap( tmpAttributes, "Cap", .false ), "COLSPAN=" || methspan / 2 )
      END
      ELSE
         htmlTable ~~ putColumn( smartCap( tmpName ), "COLSPAN=" || methspan )

      IF tmpLine <> "" THEN
         htmlTable ~~ putColumn( tmpLine, "ALIGN=RIGHT WIDTH=5%" )

      htmlTable ~~ newRow

      bDirty = .false
      htmlTable1 = .html_Table ~ new( "BORDER CELLPADDING=1 ALIGN=CENTER WIDTH=100%" )

      IF tmpObject ~ errors ~ items > 0 THEN
      DO
         CALL show_sorted_errors htmlTable1, tmpObject ~ errors, 1, methSpan
         bDirty = .true
      END


      IF tmpObject ~ expose ~ items > 0 THEN         /* show EXPOSE string */
      DO
         htmlTable1 ~~ putColumn( smartCap( pp( tmpObject ~ exposeAsString ) ), "COLSPAN=" || methSpan + 1) ~~ newRow
         htmlTable1 ~~ putColumn ~~ newRow
         bDirty = .true
      END

      IF tmpObject ~ signatures ~ items > 0 THEN     /* show signatures */
      DO
         title_string = ""
         CALL dump_detail_dir2string htmlTable1, tmpObject ~ signatures, title_string, 1
         htmlTable1 ~~ putColumn ~~ newRow
         bDirty = .true
      END

      IF tmpObject ~ returns    ~ items > 0 THEN     /* show return-statements */
      DO
         title_string = "Return Values"
         title_string = ""
         CALL dump_detail_dir2string htmlTable1, tmpObject ~ returns, title_string, 1
         htmlTable1 ~~ putColumn ~~ newRow
         bDirty = .true
      END

      IF tmpObject ~ exits      ~ items > 0 THEN     /* show exit-statements */
      DO
         title_string = ""
         CALL dump_detail_dir2string htmlTable1, tmpObject ~ exits, title_string, 1
         htmlTable1 ~~ putColumn ~~ newRow
         bDirty = .true
      END

      IF tmpObject ~ local_labels ~ items > 0 THEN           /* show labels */
      DO
         title_string = "Locally defined LABEL(s):"
         CALL dump_detail_dir2proclikes htmlTable1, tmpObject ~ local_labels, title_string, line_nr
         htmlTable1 ~~ putColumn ~~ newRow
         bDirty = .true
      END

      IF tmpObject ~ local_procedures ~ items > 0 THEN       /* show procedures */
      DO
         title_string = "Locally defined PROCEDURE(s):"
         CALL dump_detail_dir2proclikes htmlTable1, tmpObject ~ local_procedures, title_string, line_nr
         htmlTable1 ~~ putColumn ~~ newRow
         bDirty = .true
      END

      IF bDirty THEN                                    /* was htmlTable1 written to ? */
         htmlTable ~~ skipColumn( 1 ) ~~ putColumn( htmlTable1 ~ htmlText, "COLSPAN=" || methSpan + 1 ) ~~ newRow
      ELSE
         htmlTable ~~ newRow

      htmlTable ~~ putColumn ~~ newRow
    END

    RETURN




/* ---------------------------------------------------------------------------------------- */
/* dump detail of a directory pointing to strings ( CLASS ) */
DUMP_DETAIL_DIR2CLASSES: PROCEDURE EXPOSE ctl.
   USE ARG html, tmpDir, title_string, line_nr

   IF tmpDir ~ items = 0 THEN RETURN            /* nothing to do */

   IF \VAR( "line_nr" ) THEN line_nr = .false   /* default to not show line numbers */

   html ~ h4( title_string )
   classSpan = 8

   tmpArr = sort( tmpDir )

   DO i = 1 TO tmpArr ~ items                           /* display entries */
      level = 0

      htmlTable = .html_Table ~ new( "BORDER CELLPADDING=3 ALIGN=CENTER WIDTH=100%" )

      tmpObject = tmpDir ~ entry( tmpArr[ i ] )
      tmpName = smartCap( pp(tmpObject ~ name) )

      html ~ h4( .html.reference ~ A_Name( tmpObject, tmpName ) )

      tmpName = www_tag( tmpName, "STRONG" )

      tmpAttributes = tmpObject ~ dumpAttributes

      tmpLine = ""
      IF line_nr THEN
         tmpLine = smartCap( pp_lineNr( tmpObject ~ LineNr ) )


      htmlTable ~~ skipColumn( level ) ~~ putColumn( i, "ALIGN=RIGHT WIDTH=5%" )

      IF tmpAttributes = "" THEN
         htmlTable ~~ putColumn( tmpName , "COLSPAN=" || classSpan + 1 )
      ELSE
         htmlTable ~~ putColumn( tmpName, "COLSPAN=2" ) ~~ putColumn( smartCap( tmpAttributes ), "COLSPAN="||classSpan - 1 )

      IF tmpLine <> "" THEN
         htmlTable ~~ putColumn( tmpLine, "ALIGN=RIGHT WIDTH=10%" )

      htmlTable ~~ newRow

      IF tmpObject ~ errors ~ items > 0 THEN
      DO
         htmlTable ~~ skipColumn( level )
         htmlTable ~~ putColumn( "The following error(s) was (were) recorded:",,
                                 "COLSPAN=" || MAX( 1, classSpan - level )  ) ~~ newRow
         CALL show_sorted_errors htmlTable, tmpObject ~ errors, level, classSpan
      END


/* process methods */
      bDirty = .false
      htmlTable1 = .html_Table ~ new( "BORDER ALIGN=CENTER WIDTH=100%" )
   /* CLASS scope */
      IF tmpObject ~ ExposeClass ~ items > 0 THEN     /* show object variables at class scope */
      DO
         title_String = "CLASS-level object variable(s):"
         CALL dump_detail_dir2string2cols htmlTable1, tmpObject ~ ExposeClass, title_string, .false, 1
         htmlTable1 ~~ putColumn ~~ newRow
         bDirty = .true
      END

      IF tmpObject ~ local_Class_Methods ~ items > 0 THEN     /* show object variables at class scope */
      DO
         title_string = "CLASS METHOD(s):"
         CALL dump_detail_dir2methods htmlTable1, tmpObject ~ local_class_methods, title_string, .true
         htmlTable1 ~~ putColumn ~~ newRow
         bDirty = .true
      END

   /* INSTANCE scope */
      IF tmpObject ~ ExposeInstance ~ items > 0 THEN     /* show object variables at Instance scope */
      DO
         title_String = "INSTANCE-level object variable(s):"
         CALL dump_detail_dir2string2cols htmlTable1, tmpObject ~ ExposeInstance, title_string, .false, 1
         htmlTable1 ~~ putColumn ~~ newRow
         bDirty = .true
      END

      IF tmpObject ~ local_Instance_Methods ~ items > 0 THEN     /* show object variables at Instance scope */
      DO
         title_string = "INSTANCE METHOD(s):"
         CALL dump_detail_dir2methods htmlTable1, tmpObject ~ local_Instance_methods, title_string, .true
         htmlTable1 ~~ putColumn ~~ newRow
         bDirty = .true
      END

      IF bDirty THEN                                    /* was htmlTable1 written to ? */
         htmlTable ~~ skipColumn( 1 ) ~~ putColumn( htmlTable1 ~ htmlText, "COLSPAN=" || classSpan + 2 ) ~~ newRow

      htmlTable ~~ putColumn ~~ newRow
      html ~ lineout( htmlTable ~ htmlText )
   END

   RETURN




/* ---------------------------------------------------------------------------------------- */
/* dump detail of a directory pointing to strings ( SIGNATURES, RETURNS ) */
DUMP_DETAIL_DIR2STRING: PROCEDURE EXPOSE ctl.
   USE ARG htmlTable, tmpDir, title_string, skipLevel

    /* show strings stored with directory */
    IF tmpDir ~ items = 0 THEN RETURN

    IF \ VAR( "skipLevel" ) THEN skipLevel = 0
    dirSpan = 8
    skipLevel = 0

    IF title_string <> "" THEN
       htmlTable ~~ putColumn( www_tag( title_string, "STRONG"), "COLSPAN=" || dirSpan + 1 ) ~~ newRow

    tmpArr = sort( tmpDir )

    DO i = 1 TO tmpArr ~ items                        /* display entries */
       htmlTable ~~ putColumn( i, "ALIGN=RIGHT WIDTH=5%" ) ~~ ,
                    putColumn( smartCap( pp( tmpDir ~ entry( tmpArr[ i ] ) ), "Cap", .false ), "COLSPAN=" || dirSpan ) ~~ newRow
    END
    RETURN


/* ---------------------------------------------------------------------------------------- */
/* dump detail of a directory pointing to strings ( Object variables ), use two cols */
DUMP_DETAIL_DIR2STRING2COLS: PROCEDURE EXPOSE ctl.
   USE ARG htmlTable, tmpDir, title_string, skipLevel

    /* show strings stored with directory */
    IF tmpDir ~ items = 0 THEN RETURN

    IF \ VAR( "skipLevel" ) THEN skipLevel = 0
    dirSpan = 9
    cols = 3
    dirSpanCols = dirSpan / cols - 1            /* account for # col */

    IF title_string <> "" THEN
       htmlTable ~~ putColumn( www_tag( title_string, "STRONG"), "COLSPAN=" || dirSpan + 1 ) ~~ newRow

    tmpArr = sort( tmpDir )
    maxItems = tmpArr ~ items

    step = (maxItems - 1 ) % cols + 1

    DO i = 1 TO maxItems FOR step                       /* display entries */
       DO k = 0 TO cols - 1
          m = i + k * step
          IF m > maxItems THEN LEAVE
          htmlTable ~~ putColumn( m, "ALIGN=RIGHT WIDTH=5%" ) ~~ ,
                       putColumn( smartCap( pp( tmpDir ~ entry( tmpArr[ m ] ) ), "CAP", .false ), "COLSPAN=" || dirSpanCols )
       END
       htmlTable ~~ newRow
    END

    RETURN




/* ---------------------------------------------------------------------------------------- */
/* dump directory of same objects */
DUMP_DIRECTORY: PROCEDURE EXPOSE ctl.
   USE ARG html, tmpDir, tmpFile, Object2Files, title_string, with_line_nrs, bHyperLinks

   IF \var( "with_line_nrs" ) THEN with_line_nrs = .false
   IF \var( "bHyperLinks" ) THEN bHyperLinks = .false

   IF tmpDir ~ items = 0 THEN RETURN            /* nothing to do */

   tmpArray = sort( tmpDir )                 /* sort directory */
   maxArray    = tmpArray ~ items            /* get maximum array-elements */

   htmlTable = .html_Table ~ new( "ALIGN=CENTER WIDTH=100%" )
   html ~ h4( title_string )

   DO k = 1 TO maxArray
      tmpObject      = tmpDir ~ entry( tmpArray[ k ] )       /* get first token object accessible */
      tmpObjectFile  = Object2Files ~ index( tmpObject )     /* get file-object in which token is defined in */

      htmlTable ~ putColumn( k, "ALIGN=RIGHT WIDTH=5%" )              /* put nr. of item */

      IF tmpObject = ctl.eMissingClass THEN                  /* missing class in hand ? */
         tmpString = pp( k "->" tmpObject ~ name )           /* indicate missing class ! */
      ELSE
      DO
         tmpString = pp( tmpObject ~ name )                  /* get name of object */
      END

      tmpString = smartCap( tmpString )

      IF bHyperLinks THEN                                    /* get anchor name from object */
      DO
         IF tmpObjectFile <> tmpFile THEN                    /* in another file ! */
            tmpObjectFileHtml = tmpObjectFile ~ User_Slot ~ entry( "HTMLFileName" )     /* return HTML-file for file object */
         ELSE
            tmpObjectFileHtml = ""

         /* define a hyper link to tmpObject in question */
         tmpString = .html.reference ~ A_HREF( tmpObject,  tmpString, tmpObjectFileHTML )
      END

      htmlTable ~ putColumn( tmpString, "WIDTH=25%" )                     /* write name of tmpObject */

      IF tmpObjectFile <> tmpFile THEN                       /* if files differ, indicate source-file */
      DO
         IF tmpObjectFile <> .nil then                       /* e.g. def_class for missing-class has not file */
         DO
            htmlTable ~~ putColumn( "from:", "WIDTH=10%" )

            IF bHyperLinks THEN                              /* get anchor name from object */
               htmlTable ~~ putColumn( a_href( tmpObjectFileHTML, "Start", smartCap( pp( tmpObjectFile ~ shortName ) ) ), "WIDTH=25%" )
            ELSE
               htmlTable ~~ putColumn( smartCap( pp( tmpObjectFile ~ shortName ) ), "WIDTH=25%" )
         END
      END
      ELSE
         htmlTable ~ SkipColumn( 2 )

      IF with_line_nrs THEN
         htmlTable ~ putColumn( pp_lineNr( x2bare( tmpObject ~ LineNr ) ), "ALIGN=RIGHT WIDTH=25%" )
      ELSE
         htmlTable ~ SkipColumn

      htmlTable ~ newRow( 5 )                                /* total of 5 columns to fixup */
   END
   html ~ LINEOUT( htmlTable ~ htmlText )
   html ~ hr( , "WIDTH=75%" )
   RETURN



/* ---------------------------------------------------------------------------------------- */
SORT_DEF_LIST: PROCEDURE  EXPOSE ctl.
   USE ARG htmlTable, def_list

   tmpArray = .array ~ new                      /* create empty array */

   tmpSupp = def_list ~ supplier                /* get a supplier for list */
   delimiter = "ff"x
   i = 1
   DO WHILE tmpSupp ~ available
      tmpName = tmpSupp ~ item ~ name
                                                /* store name in array */
      tmpArray[ i ] = tmpName || delimiter || FILESPEC( "Name", tmpName )

      tmpSupp ~ next
      i = i + 1
   END

   tmpArray = sort( tmpArray )                  /* sort by filename only */

   DO item OVER tmpArray
      PARSE VAR item fullName ( delimiter ) shortName

      /* define a hyperlink to file, pointing to anchor "Start" */
      HtmlFile = ctl.eFiles ~ entry( fullName ) ~ User_Slot ~ entry( "HTMLFileName" )
      tmpShortName  = a_href( HtmlFile, "Start", smartCap( shortName ) )

      htmlTable ~~ putColumn( tmpShortName, "WIDTH=25%" ) ~~,
                   putColumn( smartCap( fullName  ), "WIDTH=50%" ) ~~ newRow
   END

   RETURN

/* ---------------------------------------------------------------------------------------- */

/* return the line number in edited form */
pp_lineNr : PROCEDURE  EXPOSE ctl.
   USE ARG arg
   IF arg = .nil THEN RETURN ""         /* line number absent ? */
   RETURN "@ l#" pp( ARG(1) )



/* ---------------------------------------------------------------------------------------- */
SHOW_SORTED_ERRORS: PROCEDURE  EXPOSE ctl.
   USE ARG htmlTable, container, skipNrCols, spanCols

   IF \VAR( "skipNrCols" ) THEN skipNrCols = 0          /* no columns to skip for indentation   */
   IF \VAR( "spanCols"   ) THEN spanCols   = 1          /* span # of cols                       */

   sorted = sort( container )

   DO i = 1 TO sorted ~ items
      htmlTable ~~ skipColumn( skipNrCols ) ~~ putColumn( .Red.Dot x2bare( sorted[ i ] ),,
                                               "COLSPAN=" || MAX(1, spanCols - skipNrCols )  ) ~~ newRow
   END

   RETURN






/* ---------------------------------------------------------------------------------------- */
GET_HTML_FILE_NAME : PROCEDURE EXPOSE ctl.
   USE ARG object, presentFile

   IF \ VAR( "presentFile" ) THEN presentFile = .nil

   tmpFile = ctl.eToken2Files ~ allindex( object )[ 1 ]         /* get file object of object */

   IF presentFile = tmpFile THEN RETURN ""                      /* local reference */

   RETURN tmpFile ~ User_Slot ~ entry( "HTMLFileName" )         /* return HTML-file for file object */





/* ---------------------------------------------------------------------------------------- */

:: REQUIRES rgf_util.cmd
:: REQUIRES nls_util.cmd
:: REQUIRES html_util.cmd


