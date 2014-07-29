/*
   analyze REXX file, format in plain ASCII
program:   orx_analyze_ascii.cmd
type:      Object REXX, REXXSAA 6.0
purpose:   formats results of analyzed REXX-program in ASCII-format
version:   1.00
date:      1995-11, 1996-05-09
changed:   1997-04-15, ---rgf, adapted for the new module structure

author:    Rony G. Flatscher
           Rony.Flatscher@wu-wien.ac.at
           (Wirtschaftsuniversitaet Wien, University of Economics and Business
           Administration, Vienna/Austria/Europe)

needs:     rgf_util.cmd, orx_analyze.cmd (which needs nls_util.cmd, orx_util.cmd, rgf_util.cmd)

usage:     orx_analyze_ascii some_rexx_file

           returns ASCII-formatted output to STDOUT:

comments:  almost finished :)

All rights reserved, copyrighted 1995 - 1997, no guarantee that it works without
errors, etc. etc.


You are granted the right to use this module under the condition that you don't charge money for this module (as you didn't write
it in the first place) or modules directly derived from this module, that you document the original author (to give appropriate
credit) with the original name of the module and that you make the unaltered, original source-code of this module available on
demand.  If that holds, you may even bundle this module (either in source or compiled form) with commercial software.


Please, if you find an error, post me a message describing it, I will
try to fix and rerelease it to the net.

*/

/* retrieve methods of classes defined in .environment ? */
.local ~ bQueryEnvClassMethods        = .false

/* HUGE performance penalty, HUGE html-files results */
.local ~ bShowEnvTilingWithMethodsEnv = .false     /* show methods while tiling classes of .environment ? */

/* perfomance penalty */
.local ~ bShowEnvMethods              = .false     /* show .environment class methods while tiling non .environment classes ? */

PARSE ARG start_file


CALL TIME "Reset"                               /* timer start */
ctl. = orx_analyze( start_file )                /* have file parsed */
PARSE VALUE TIME("Elapsed") WITH elapsed



.local ~ missing.class = ctl.eMissingClass      /* sentinel object, indicating a missing class */
.local ~ indent_step1 = 3
.local ~ indent_step2 = 3
.local ~ indent1      = COPIES( " ", .indent_step1 )
.local ~ indent2      = COPIES( " ", .indent_step2 )
.local ~ indent3      = .indent1 .indent2


CALL leadin elapsed
CALL require_structure ctl.eFileStart           /* start with file which we had to analyze */

CALL sayError
CALL sayError "Formatting summary ..."  /* summary results */
CALL file_statistics

CALL sayError "Formatting details ..."  /* details results */
CALL file_details

PARSE VALUE TIME("Elapsed") WITH elapsed
CALL leadin elapsed

EXIT

/* ------------------------------------------------------------------------------------- */
/* show header */
LEADIN: PROCEDURE EXPOSE ctl.
   PARSE ARG elapsed

   PARSE SOURCE op_sys call_type proc_name
   SAY DATE( "Standard" ) TIME( "Normal" ) "running" pp( proc_name ) "under" pp( op_sys )
   SAY

   SAY "Results of analyzing:" pp( ctl.eFileStart ~ name ) "analyze time:" pp( FORMAT( elapsed, , 2 ) ) "seconds"
   SAY
   RETURN
/* ------------------------------------------------------------------------- */


/* ------------------------------------------------------------------------- */
/* show dependency tree of encountered ::REQUIRES directives */
REQUIRE_STRUCTURE: PROCEDURE
   USE ARG tmpFile, level

   IF tmpFile ~ requires_files ~ items = 0 THEN         /* if no files are required, then return */
      RETURN

   SAY CENTER( " dependency tree, imposed by ::REQUIRES directives: ", 79, "-")
   SAY
   CALL show_requires_tree tmpFile
   SAY
   RETURN

SHOW_REQUIRES_TREE: PROCEDURE
   USE ARG tmpFile, level

   IF \VAR( "level" ) THEN              /* initial call ! */
   DO
      level = 1
   END

   indent = COPIES( " ", 4 * level - 1 )
   SAY indent pp( tmpFile ~ name )

   DO item OVER tmpFile ~ requires_files
      CALL show_requires_tree item, ( level + 1 )
   END
   RETURN
/* ------------------------------------------------------------------------- */




/* ------------------------------------------------------------------------- */
/* show statistical data of analyzed files (in alphabetical order ) */
FILE_STATISTICS: PROCEDURE EXPOSE ctl. stats.
   startFile = ctl.eFileStart

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


   sortedFiles = sort( ctl.eFiles )     /* returns array with sorted indices of .directory */

   maxFileLength = startFile ~ class ~ max_name_length + 2 /* get maximum file length, account for pp() brackets */

   SAY CENTER( " statistics about analyzed files: ", 79, "=")
   SAY

   DO i = 1 TO sortedFiles ~ items

      tmpFile = ctl.eFiles ~ entry( sortedFiles[ i ] )  /* get file object */

      /* if this is the file which got analyzed, indicate this fact and show accessible routines and classes */
      IF tmpFile = startFile THEN
      DO
         SAY LEFT( pp( tmpFile ~ name ) "<--- This file started the analysis !", 79, "-" )
      END
      ELSE
         SAY LEFT( pp( tmpFile ~ name ), 79, "-" )
      SAY

      /* indicate which files REQUIRE this one */
      SAY .indent1 "According to the analysis the following file(s) require(s) this one:"
      SAY

      IF tmpFile ~ required_by ~ items > 0 THEN
      DO

         tmpArray = sort_def_list( tmpFile ~ required_by, maxFileLength +2 , "FILE" )
         DO item OVER tmpArray
            SAY .indent1 .indent2 item
         END
      END
      ELSE
         SAY .indent1 .indent2 "--- none ---"

      SAY

      /* indicate which files are REQUIRED by this one */
      SAY .indent1 "According to the analysis this file requires the following file(s):"
      SAY

      IF tmpFile ~ requires_files ~ items > 0 THEN
      DO
         tmpArray = sort_def_list( tmpFile ~ requires_files, maxFileLength +2, "FILE" )
         DO item OVER tmpArray
            SAY .indent1 .indent2 item
         END
      END
      ELSE
         SAY .indent1 .indent2 "--- none ---"

      SAY


      /* indicate whether file may be called as a procedure / function */
      /* if so, show signatures and returns                            */

      IF tmpFile ~ IsProcedure | tmpFile ~ IsFunction THEN
      DO
         tmpString = "This file may be called as a procedure"
         IF tmpFile ~ IsFunction THEN tmpString = tmpString "*and* as a function (it returns values)"

         SAY .indent1 tmpString || ":"
         SAY

         /* show signatures */
         IF tmpFile ~ signatures ~ items > 0 THEN
         DO
            title_string = ""
            CALL dump_detail_dir2string tmpFile ~ signatures, .indent1, .indent2, title_string
         END

         /* show return expressions */
         IF tmpFile ~ returns ~ items > 0 THEN
         DO
            title_string = ""
            CALL dump_detail_dir2string tmpFile ~ returns, .indent1, .indent2, title_string
         END

         /* show exit expressions */
         IF tmpFile ~ returns ~ items > 0 THEN
         DO
            title_string = ""
            CALL dump_detail_dir2string tmpFile ~ exits, .indent1, .indent2, title_string
         END
      END


      /* show LOCs  pp_number() */

      /* total number of lines */
      stats.eLines.1      = pp( RIGHT( pp_number( tmpFile ~ total_loc ), 7) ) stats.eLines.1.eText
      stats.eLines.1.eSum = stats.eLines.1.eSum + tmpFile ~ total_loc    /* grand total */

      stats.eLines.2      = pp( RIGHT( pp_number( tmpFile ~ loc ), 7) ) stats.eLines.2.eText,
                            pp( RIGHT( format( (tmpFile ~ loc * 100 / MAX( tmpFile ~ total_loc, 1 )) , , 2), 6) "%" )
      stats.eLines.2.eSum = stats.eLines.2.eSum + tmpFile ~ loc          /* grand total */

      SAY .indent1 'Lines of code (total and stripped of comments, blank lines etc.)'
      SAY
      SAY .indent1 .indent2 stats.eLines.1
      SAY .indent1 .indent2 stats.eLines.2

      SAY

      /* show number of procedures, routines, classes and methods defined in this file */
      SAY .indent1 'The following statistics were gathered in addition:'
      SAY

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
         SAY .indent1 .indent2 pp( RIGHT( pp_number( stats.eFile.j ), 7 ) ) stats.eFile.j.eText
         stats.eFile.j.eSum = stats.eFile.j.eSum + stats.eFile.j
      END
      SAY


      /* show available ROUTINES ( all local and all public defined via requires ) */
      tmpDir = tmpFile ~ local_Routines ~ union( tmpFile ~ visible_routines )
      title_String = "The following routine(s) is (are) accessible for this file:"
      CALL dump_directory tmpDir, tmpFile, ctl.eRoutines2Files, title_string, .indent1, .indent2



      /* show available CLASSES ( all local and all public defined via requires ) */
      tmpDir = tmpFile ~ local_classes ~ union( tmpFile ~ visible_classes )
      title_String = "The following class(es) is (are) accessible for this file:"
      CALL dump_directory tmpDir, tmpFile, ctl.eClasses2Files, title_string, .indent1, .indent2
      SAY

      /* show available classes as tree(s), indicate metaclass trees */
      CALL dump_roots tmpFile, .indent1, .indent2

      /* show usage of metaclasses (display metaclasses and their classes) */
      CALL dump_classes_using_metaclasses tmpFile

      /* show order of tiled classes for every leaf class */
      CALL dump_tiled_classes tmpFile, tmpFile ~ Local_Leaf_Classes, .false


      /* show found errors */
      SAY
      SAY .indent1 "The following error(s) was (were) found during parsing:"
      SAY
      IF tmpFile ~ errors ~ items > 0 THEN
      DO
         stats.eFile.eError.eSum = stats.eFile.eError.eSum + tmpFile ~ errors ~ items
         CALL show_sorted_errors tmpFile ~ errors, .indent1 .indent2
      END
      ELSE
         SAY .indent1 .indent2 "--- none ---"

      SAY

      SAY LEFT( .indent1, 79, "-" )
   END


   /* --------------------------- grand totals ----------------------------- */
   /* total number of lines */
   SAY
   SAY CENTER( " Grand totals for" pp( sortedFiles ~ items ) "file(s): ", 79, "-" )
   SAY
   tmp1 = pp( RIGHT( pp_number( stats.eLines.1.eSum ), 7) ) stats.eLines.1.eText

   tmp2 = pp( RIGHT( pp_number( stats.eLines.2.eSum ), 7) ) stats.eLines.2.eText,
          pp( RIGHT( format( ( stats.eLines.2.eSum * 100 / MAX( stats.eLines.1.eSum, 1) ) , , 2), 6) "%" )

   SAY .indent1 'Lines of code (total and stripped of comments, blank lines etc.)'
   SAY
   SAY .indent1 .indent2 tmp1
   SAY .indent1 .indent2 tmp2
   SAY

   /* show number of procedures, routines, classes and methods defined in this file */
   SAY .indent1 'The following statistics were gathered in addition:'
   SAY
   DO j = 1 TO stats.eFile.0
      SAY .indent1 .indent2 pp( RIGHT( pp_number( stats.eFile.j.eSum ), 7 ) ) stats.eFile.j.eText
   END

   SAY

   /* show found errors */
   SAY .indent1 "Error(s) found during parsing:"
   SAY
   IF stats.eFile.eError.eSum > 0 THEN
      SAY .indent1 .indent2 pp( RIGHT( pp_number( stats.eFile.eError.eSum ), 7 ) ) "error(s)"
   ELSE
      SAY .indent1 .indent2 "--- none ---"
   SAY
   /* --------------------------- grand totals - end ----------------------- */

   SAY CENTER( " end of file statistics ", 79, "=" )
   SAY
   SAY

   RETURN

/* ------------------------------------------------------------------------- */






/* ------------------------------------------------------------------------- */
/* show details of analyzed files (in alphabetical order ) */
FILE_DETAILS: PROCEDURE EXPOSE ctl. stats.
   startFile = ctl.eFileStart

   sortedFiles = sort( ctl.eFiles )     /* returns array with sorted indices of .directory */

   maxFileLength = startFile ~ class ~ max_name_length + 2 /* get maximum file length, account for pp() brackets */

   SAY CENTER( " details about analyzed files: ", 79, "=")
   SAY

   DO i = 1 TO sortedFiles ~ items

      tmpFile = ctl.eFiles ~ entry( sortedFiles[ i ] )  /* get file object */
      CALL sayError "   details for" pp( tmpFile ~ Name ) "..."

      /* if this is the file which got analyzed, indicate this fact and show accessible routines and classes */
      IF tmpFile = startFile THEN
         SAY LEFT( pp( tmpFile ~ name ) "<--- this file started the analysis !", 79, "-" )
      ELSE
         SAY LEFT( pp( tmpFile ~ name ), 79, "-" )

      SAY


      /* indicate which files require this one */
      SAY .indent1 "According to the analysis the following file(s) require(s) this one:"
      SAY

      IF tmpFile ~ required_by ~ items > 0 THEN
      DO

         tmpArray = sort_def_list( tmpFile ~ required_by, maxFileLength +2 , "FILE" )
         DO item OVER tmpArray
            SAY .indent1 .indent2 item
         END
      END
      ELSE
         SAY .indent1 .indent2 "--- none ---"

      SAY


      /* indicate which files are required by this one */
      SAY .indent1 "According to the analysis this file requires the following file(s):"
      SAY

      IF tmpFile ~ requires_files ~ items > 0 THEN
      DO
         tmpArray = sort_def_list( tmpFile ~ requires_files, maxFileLength +2, "FILE" )
         DO item OVER tmpArray
            SAY .indent1 .indent2 item
         END
      END
      ELSE
         SAY .indent1 .indent2 "--- none ---"

      SAY


      /* show LOCs  pp_number() */

      /* total number of lines */
      tmpTotLines         = pp( RIGHT( pp_number( tmpFile ~ total_loc ), 7) ) stats.eLines.1.eText

      tmpRealLines        = pp( RIGHT( pp_number( tmpFile ~ loc ), 7) ) stats.eLines.2.eText,
                            pp( RIGHT( format( (tmpFile ~ loc * 100 / MAX( tmpFile ~ total_loc, 1 ) ) , , 2), 6) "%" )


      SAY .indent1 'LOCs  [without remarks, empty lines, but joined (,) and split (;) where appropriate]:'
      SAY
      SAY .indent1 .indent2 tmpTotLines
      SAY .indent1 .indent2 tmpRealLines
      SAY


      /* show number of procedures, routines, classes and methods defined in this file */
      SAY .indent1 'The following statistics were gathered in addition:'
      SAY

      nrProcedures         = ctl.eProcedures2Files ~ allat( tmpFile ) ~ items
      nrLabels             = ctl.eLabels2Files     ~ allat( tmpFile ) ~ items
      nrRequires           = ctl.eRequires2Files   ~ allat( tmpFile ) ~ items
      nrRoutines           = ctl.eRoutines2Files   ~ allat( tmpFile ) ~ items
      nrClasses            = ctl.eClasses2Files    ~ allat( tmpFile ) ~ items
      nrMethods            = ctl.eMethods2Files    ~ allat( tmpFile ) ~ items


      SAY .indent1 .indent2 pp( RIGHT(pp_number( nrProcedures ), 7) ) "procedure(s) found"
      SAY .indent1 .indent2 pp( RIGHT(pp_number( nrLabels     ), 7) ) "label(s)     found"
      SAY .indent1 .indent2 pp( RIGHT(pp_number( nrRequires   ), 7) ) "::REQUIRES   found"
      SAY .indent1 .indent2 pp( RIGHT(pp_number( nrRoutines   ), 7) ) "::ROUTINE(s) found"
      SAY .indent1 .indent2 pp( RIGHT(pp_number( nrClasses    ), 7) ) "::CLASS(es)  found"
      SAY .indent1 .indent2 pp( RIGHT(pp_number( nrMethods    ), 7) ) "::METHOD(s)  found"



      /* show available routines ( all local and all public defined via requires ) */
      tmpDir = tmpFile ~ local_Routines ~ union( tmpFile ~ visible_routines )
      title_String = "The following routine(s) is (are) accessible for this file:"
      CALL dump_directory tmpDir, tmpFile, ctl.eRoutines2Files, title_string, .indent1, .indent2, .true
      SAY


      /* show available classes ( all local and all public defined via requires ) */
      tmpDir = tmpFile ~ local_classes ~ union( tmpFile ~ visible_classes )
      title_String = "The following class(es) is (are) accessible for this file:"
      CALL dump_directory tmpDir, tmpFile, ctl.eClasses2Files, title_string, .indent1, .indent2, .true
      SAY

      /* show available classes as tree(s), indicate metaclass trees */
      CALL dump_roots tmpFile, .indent1, .indent2


      /* show usage of metaclasses (display metaclasses and their classes) */
      CALL dump_classes_using_metaclasses tmpFile


      /* indicate whether file may be called as a procedure / function */
      /* if so, show signatures and returns                            */

      tmpString = ""
      IF tmpFile ~ IsProcedure | tmpFile ~ IsFunction THEN
      DO
         tmpString = "This file may be called as a procedure"
         IF tmpFile ~ IsFunction THEN tmpString = tmpString "*and* as a function (it returns values)"

         SAY .indent1 tmpString || ":"
         SAY
      END
      SAY

      title_string = ""
      /* show signatures */
      title_string = "The following attempt(s) for argument parsing was (were) found:"
      CALL dump_detail_dir2string tmpFile ~ signatures, .indent3, .indent2, title_string

      /* show returns */
      title_string = "The following RETURN statements was (were) found:"
      CALL dump_detail_dir2string tmpFile ~ returns, .indent3, .indent2, title_string

      /* show exit expressions */
      title_string = "The following EXIT statements was (were) found:"
      CALL dump_detail_dir2string tmpFile ~ exits, .indent3, .indent2, title_string

      /* show labels within main body */
      title_string = "This file contains the following label(s) in its main body:"
      CALL dump_detail_dir2proclikes tmpFile ~ local_labels, .indent1, .indent2, title_string, .true


/* show procedures for file, including labels */
      title_string = "Procedures defined for file:"
      CALL dump_detail_dir2proclikes tmpFile ~ local_procedures, .indent1, .indent2, title_string, .true

/* show routines for file, including labels, procedures */
      title_string = "::ROUTINE(s) defined within file:"
      CALL dump_detail_dir2proclikes tmpFile ~ local_routines, .indent1, .indent2, title_string, .true


/* show floating methods for file including labels & procedures */
      title_string = "::METHOD(s) *not* attached to a specific class ('floating')"
      CALL dump_detail_dir2methods tmpFile ~ local_methods, .indent1, .indent2, title_string, .true


/* show classes for file, including methods, which:
        show class & instance methods including labels & procedures */
      title_string = "::CLASS(es) defined:"
      CALL dump_detail_dir2classes tmpFile ~ local_classes, .indent1, .indent2, title_string, .true


      /* show order of tiled classes for *every* class, including methods (!) */
      tmp = tmpFile ~ Local_Classes ~ supplier

      tmpList = .list ~ new                     /* produce list containing def_classes only */
      DO WHILE tmp ~ available
         tmpList ~ insert( tmp ~ item )
         tmp ~ next
      END
      CALL dump_tiled_classes tmpFile, tmpList, .true





      /* show found errors */
      SAY
      SAY .indent1 "The following error(s) was (were) found during parsing:"
      SAY

      IF tmpFile ~ errors ~ items > 0 THEN
         CALL show_sorted_errors tmpFile ~ errors, .indent1 .indent2
      ELSE
         SAY .indent1 .indent2 "--- none ---"

      SAY

      SAY LEFT( .indent1, 79, "-" )
   END

   SAY CENTER( " end of file statistics ", 79, "=" )
   SAY
   SAY

   RETURN



/* ------------------------------------------------------------------------- */

/* show all metaclasses and classes using it */
DUMP_CLASSES_USING_METACLASSES: PROCEDURE
    USE ARG tmpFile, line_nr

    IF \VAR( "line_nr" ) THEN line_nr = .false   /* default to not show line numbers */

    tmpDir = tmpFile ~ Local_MetaClasses                /* show metaclass usage */
    IF tmpDir ~ items = 0 THEN RETURN                   /* no metaclasses used in this file */

   indent1 = .indent1
   indent2 = .indent2
   indent3 = indent1 indent2
   indent4 = indent3 indent2


    title_string = "Usage of metaclasses (display metaclasses and classes using it):"
    SAY indent1 title_string                  /* display title */
    SAY

    tmpArr = sort( tmpDir )
    max_width = MAX( 3, LENGTH( tmpArr ~ items ) + 1 )
    /* get maximum length of name, account for brackets */

    max_name_width =  tmpDir ~ entry( tmpArr[ 1 ] ) ~ class ~ max_name_length + 2

    DO i = 1 TO tmpArr ~ items                  /* display metaclasses */
       tmpObject = tmpDir ~ entry( tmpArr[ i ] )
       tmpString = RIGHT( i, max_width) "metaclass"

       tmpString = tmpString LEFT( pp( tmpObject ~ name), max_name_width )

       IF line_nr THEN
       DO
          IF tmpObject ~ LineNr <> .nil THEN
             tmpString = tmpString pp_lineNr( tmpObject ~ LineNr )
       END

       IF tmpObject ~ IsMetaClass THEN
          SAY indent2 tmpString "is used by:"           /* show name */
       ELSE
          SAY indent2 tmpString "*** error *** (class is *not* a metaclass!)"   /* show name */

       IF tmpObject ~ MetaUsedBySet ~ items > 0 THEN    /* show classes using this metaclass */
       DO
          SAY
          tmpUseDir = .directory ~ new                  /* build a directory of classes using this metaclass */
          DO item OVER tmpObject ~ MetaUsedBySet
             tmpUseDir ~ setentry( item ~ name, item )
          END

          tmpUseArr = sort( tmpUseDir )                 /* sort entries */
          DO j = 1 TO tmpUseArr ~ items
             aClass = tmpUseDir ~ entry( tmpUseArr[ j ] )       /* get class */

             tmpString = LEFT( pp( aClass ~ name), max_name_width  )

             IF aClass ~ IsMetaClass THEN               /* ha, a metaclass is using a metaclass ! */
             DO
                tmpString = tmpString "(metaclass)"
             END

             SAY  indent3 tmpString
          END
       END
       ELSE
       DO
          IF tmpObject ~ IsMetaClass THEN
             SAY  indent3 "--- no class ! ---"
       END
       SAY
    END

    RETURN





/* ------------------------------------------------------------------------- */
/* show order of tiled classes for classes, passed in via every a collection

     tmpFile  - File (local classes being shown)
     collObj  - Collection of local [leaf] classes
     bDetail  - indicate whether methods should be shown (and aligned)
     bTopDown - indicate whether tiling should show class first and .object last (.true) or
                                               show .object first and class last (.false)

     Remarks: while building the class-tree for a a leaf-class the starting class has a "level" of
              0, a meta-class, a level of "-1", a meta-class for a meta-class, a level of "-2", etc.
*/
DUMP_TILED_CLASSES : PROCEDURE EXPOSE ctl.
   USE ARG tmpFile, collObject, bDetail, bObjectClassAtTop

   IF \ VAR( bObjectClassAtTop) THEN bObjectClassAtTop = .false   /* default, determines order of shown "tiling" */

   indent1 = .indent1
   indent2 = .indent2

   IF collObject ~ items = 0 THEN RETURN        /* nothing to show */


   IF \ .bShowEnvTilingWithMethodsEnv THEN      /* do a detailed tiling on .environment classes ? */
   DO
      /* too large ! 800KB with environment tiling !!! */
      IF bDetail & tmpFile = ctl.eFileEnvironment THEN
         RETURN
   END

   indent = indent1 indent2

   /* build a list of superclasses, starting with leaves, remember top of every */
   tmpLeafDir  = .directory ~ new

   /* turn set into directory, store class leaves */
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

   DO i = 1 TO tmpArr ~ items                           /* produce and display tiled classes */
      tmpSetDir = .directory ~ new                      /* directory to contain sets for different class/metaclass levels */
      tmpSetDir ~ setentry( "1", .set ~ new )           /* set to contain classes already processed */

      HighestLevel = 0

      tmpList = tmpLeafDir ~ entry( tmpArr[ i ] )       /* process list, setup tiling, print it */
      tmpHierarchyList = .list ~ new


      next  = tmpList ~ first                           /* get first list entry */
      aClass = tmpList ~ at( next )                  /* get class-def */
      last = tmpHierarchyList ~ last                 /* get last entry, everything has to be inserted right after it */
      /* "HighestLevel" gets set in routine */
      CALL get_hierarchy_up aClass, tmpSetDir, tmpHierarchyList, last, 1 /* create tiled tree */


      /* now dump tiling */
      firstItem = tmpList ~ firstItem                   /* get first list item */
      tmpClass  = tmpList ~ firstItem                   /* get def_class object */

      tmpString = pp( tmpClass ~ name )
      tmpAttrString = tmpClass ~ dumpAttributes( .false )
      IF tmpAttrString <> "" THEN tmpString = tmpString pp( tmpAttrString )

      IF \bDetail THEN                                  /* show summary */
      DO
         SAY
         tmpString = tmpString "- tiling for this leaf class (i.e. summary view):"
         SAY indent1 tmpString
         SAY indent1 COPIES( "=", LENGTH( tmpString ) )
         SAY

         IF bObjectClassAtTop THEN next = tmpHierarchyList ~ last
                     ELSE next = tmpHierarchyList ~ first

         ind1 = LEFT("", 8)                             /* indention blanks */

         tmp_length = max_length + 25
         DO WHILE next <> .nil
            tmpItem = tmpHierarchyList ~ at( next )
            list_Item = tmpItem[ 1 ]                    /* get def_class object */
            tmpLevel  = HighestLevel - tmpItem[ 2 ]     /* level this class was found at, calculate indention */

            tmpString = ""
            tmpHint   = ""
            IF      list_item = .missing.class THEN tmpHint = "<-- MISSING"
            ELSE IF list_item ~ IsMetaClass    THEN tmpHint = "(metaclass)"

            /* check whether defined in a different file, if so, display it ! */
            sourceFile = ctl.eClasses2Files ~ index( list_item )

            IF tmpFile <> sourceFile THEN
               tmpString = LEFT(pp( list_item ~ name ) || " ", tmp_length, ".") STRIP( tmpHint) pp( sourceFile ~ name )
            ELSE
               tmpString = LEFT(pp( list_item ~ name ), tmp_length) tmpHint

            IF list_item ~ errors ~ items > 0 THEN tmpString = tmpString "** errors found ! **"

            IF tmpLevel > 0 THEN
               SAY indent COPIES(ind1, tmpLevel) "|" tmpString
            ELSE
               SAY indent "|" tmpString

            IF bObjectClassAtTop THEN next = tmpHierarchyList ~ previous( next )
                        ELSE next = tmpHierarchyList ~ next( next )
         END
      END





      ELSE                                              /* show detail (aligned methods) */
      DO
         SAY
         tmpString = tmpString "- tiling (i.e. detail view):"
         SAY indent1 tmpString
         SAY indent1 COPIES( "=", LENGTH( tmpString ) )
         SAY
         ind1 = LEFT("", 15)

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
            tmpLevel  = HighestLevel - tmpItem[ 2 ]     /* level this class was found at, calculate indention */
            oriLevel  = tmpItem[ 2 ]                    /* original level */

            bIsMetaClass = list_item ~ IsMetaClass

            IF      list_item = .missing.class THEN tmpString = "MISSING -->" pp( list_item ~ name )
            ELSE IF bIsMetaClass               THEN tmpString = pp( list_item ~ name ) "(metaclass)"
            ELSE                                    tmpString = pp( list_item ~ name )

            /* check whether defined in a different file, if so, display it ! */
            sourceFile = ctl.eClasses2Files ~ index( list_item )

            IF tmpFile <> sourceFile THEN
               tmpString = tmpString "---> defined in" pp( sourceFile ~ name )

            IF list_item ~ errors ~ items > 0 THEN tmpString = tmpString "** errors found ! **"

            SAY indent || COPIES(ind1, tmpLevel) || "|" tmpString "L#" pp( oriLevel )

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
               methIndent = indent || COPIES(ind1, tmpLevel)

        /* dump *class* methods */
               tmpClassDir = list_item ~ Local_Class_Methods
               tmpClassArr = sort( tmpClassDir )
               IF tmpClassArr ~ items > 0 THEN SAY

               DO k = 1 TO tmpClassArr ~ items
                  tmpMethObj = tmpClassDir ~ entry( tmpClassArr[ k ] )
                  tmpString = "::METHOD" pp( tmpMethObj ~ name )

                  tmpAttributes = STRIP( tmpMethObj ~ DumpAttributes( .false ) )
                  IF tmpAttributes <> "" THEN tmpString = tmpString pp( tmpAttributes )

                  IF oriLevel = 1  THEN                 /* class methods only reachable if at level 1 */
                  DO
                     tmpName = tmpMethObj ~ name                            /* get method's name */
                     IF  tmpClassMethDir ~ entry( tmpName ) = .nil THEN     /* not recorded as of yet */
                     DO
                        IF \ bObjectClassAtTop THEN
                           tmpString = tmpString "<--- 'direct' access for" pp( tmpRootClass ~ name )
                        tmpClassMethDir ~ setentry( tmpName, tmpName )
                     END
                  END
                  SAY methIndent || "|" tmpString
               END

               methindent = methindent || ind1     /* indent more */

        /* dump *instance* methods */
               tmpClassDir = list_item ~ Local_Instance_Methods
               tmpClassArr = sort( tmpClassDir )
               IF tmpClassArr ~ items > 0 THEN SAY

               DO k = 1 TO tmpClassArr ~ items
                  tmpMethObj = tmpClassDir ~ entry( tmpClassArr[ k ] )
                  tmpString = "::METHOD" pp( tmpMethObj ~ name )

                  tmpAttributes = STRIP( tmpMethObj ~ DumpAttributes( .false ) )
                  IF tmpAttributes <> "" THEN tmpString = tmpString pp( tmpAttributes )


                  IF oriLevel <= 2 THEN
                  DO
                     /* indicate whether class method is directly accessible from starting class */
                     tmpName = tmpMethObj ~ name                   /* get method's name */

                     IF oriLevel = 1 THEN                               /* instance method in same column */
                     DO
                        IF  tmpInstanceMethDir ~ entry( tmpName ) = .nil THEN  /* not recorded as of yet */
                        DO
                           IF \ bObjectClassAtTop THEN
                              tmpString = tmpString "<--- 'direct' access for" pp( tmpRootClass ~ name )
                           tmpInstanceMethDir ~ setentry( tmpName, tmpName )
                        END
                     END
                     ELSE
                     DO
                        IF tmpClassMethDir ~ entry( tmpName ) = .nil THEN      /* not recorded as of yet */
                        DO
                           IF \ bObjectClassAtTop THEN
                              tmpString = tmpString "<--- 'direct' access for" pp( tmpRootClass ~ name )
                           tmpClassMethDir ~ setentry( tmpName, tmpName )
                        END
                     END
                  END

                  SAY methIndent || "|" tmpString
               END
            END

            SAY indent LEFT( "", MAX( max_length, 100 ), "-" )
            SAY

            IF bObjectClassAtTop THEN next = tmpHierarchyList ~ previous( next )
                        ELSE next = tmpHierarchyList ~ next( next )
         END
      END
   END

   SAY
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
      RETURN


   HighestLevel = MAX( level, HighestLevel )            /* store highest level (deepness w.r.t. metaclasses) */
   listIndex = tmpHierarchyList ~ insert( .array ~ of( aClass, level) , position_in_list) /* insert class in front, remember level */
   tmpSet ~ put( aClass )                               /* indicate that class has been handled at this level */

/**/
   tmpListOfSuperClasses = aClass ~ ListOfSuperClasses
   next = tmpListOfSuperClasses ~ last
   DO WHILE next <> .nil
      item = tmpListOfSuperClasses ~ at( next )

      IF \tmpSet ~ HASINDEX( item ) THEN      /* class not handled as of yet */
         CALL get_hierarchy_up item, tmpSetDir, tmpHierarchyList, listIndex, level

      next = tmpListOfSuperClasses ~ previous( next )
   END

/**/

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
            CALL get_hierarchy_up aMetaClass, tmpSetDir, tmpHierarchyList, listIndex, level

      END
   END

   RETURN






/* ------------------------------------------------------------------------- */
DUMP_ROOTS: PROCEDURE   EXPOSE ctl.
   USE ARG tmpFile, indent1, indent2


   IF tmpFile ~ Local_Root_classes ~ items = 0 THEN RETURN      /* nothing to show */

   SAY indent1 "Show available classes as tree(s), indicating metaclass being used:"
   SAY

   tmpRootDir  = .directory ~ new
   /* turn set into directory */
   DO aClass OVER tmpFile ~ Local_Root_Classes
      tmpRootDir ~ setentry( aClass ~ name, aClass )
   END

   max_name_width =  aClass ~ class ~ max_name_length + 2 /* get maximum length of name, account for brackets */

   tmpArray = sort( tmpRootDir )                /* sort directory */
   DO i = 1 TO tmpArray ~ items                 /* dump in sorted root-order */
      tmpClass = tmpRootDir ~ entry( tmpArray[i] )
      CALL dump_sub_classes tmpClass, 1, tmpClass ~ IsMetaClass
      SAY
   END
   RETURN



/* dump class tree recursively */
DUMP_SUB_CLASSES: PROCEDURE EXPOSE indent1 indent2 max_name_width
  USE ARG class, level, IsMetaClass

  name = pp( class ~ name )

  tmpString = indent1  COPIES( indent2, level )
  tmpString = tmpString name

  /* if this class has a metaclass defined with it, show it */
  IF ( level = 1 & IsMetaClass = .true ) | ( class ~ MetaClassObject <> .nil ) THEN
  DO
     max = 60
     tmpWidth = MAX( LENGTH( tmpString ), max )                 /* define gap */

     IF tmpWidth = max THEN tmpWidth = tmpWidth - LENGTH( tmpString )
     filler = RIGHT( "",  tmpWidth, "." )

     IF class ~ MetaClassObject <> .nil THEN
         tmpString = tmpString filler pp( class ~ MetaClassObject ~ name )
     ELSE               /* no explicit metaclass, but subclassing .class */
     DO
        IF class ~ SuperClassObject ~ SuperClassObject <> .nil THEN     /* make sure .object is not shown */
           tmpString = tmpString filler pp( class ~ SuperClassObject ~ name )
     END
  END

  SAY tmpString         /* show class */

  subClassSet = class ~ SetOfSubclasses
  tmpDir  = .directory ~ new
  /* turn set into directory */
  DO aClass OVER SubClassSet
     tmpDir ~ setentry( aClass ~ name, aClass )
  END

  tmpArray = sort( tmpDir )                    /* sort directory */
  DO i = 1 TO tmpArray ~ items                 /* dump in sorted root-order */
     tmpClass = tmpDir ~ entry( tmpArray[i] )
     CALL dump_sub_classes tmpClass, level + 1, IsMetaClass /* call recursively */
  END

  RETURN




/* ------------------------------------------------------------------------- */

/* dump detail of a directory pointing to strings ( LABELS, PROCEDURES, ROUTINES ) */
DUMP_DETAIL_DIR2PROCLIKES: PROCEDURE EXPOSE ctl
   USE ARG tmpDir, indent1, indent2, title_string, line_nr

   IF \VAR( "line_nr" ) THEN line_nr = .false   /* default to not show line numbers */

   indent3 = indent1 indent2
   indent4 = indent3 indent2


   /* show labels, procedures, routines stored with directory */
   IF tmpDir ~ items > 0 THEN
   DO
      SAY indent1 title_string                  /* display title */
      SAY

      tmpArr = sort( tmpDir )
      max_width = MAX( 3, LENGTH( tmpArr ~ items ) + 1 )
      max_name_width =  tmpDir ~ entry( tmpArr[ 1 ] ) ~ class ~ max_name_length /* get maximum length of name */

      DO i = 1 TO tmpArr ~ items                        /* display entries */
         tmpObject = tmpDir ~ entry( tmpArr[ i ] )
         tmpString = indent1 indent2 RIGHT( i, max_width)

         tmpName = pp( LEFT( tmpObject ~ name, max_name_width ) )

         IF      tmpObject ~ class ~ id = "DEF_PROCEDURE" THEN tmpName = tmpName ": PROCEDURE"
         ELSE IF tmpObject ~ class ~ id = "DEF_LABEL"     THEN tmpName = tmpName ":"
         ELSE IF tmpObject ~ class ~ id = "DEF_ROUTINE"   THEN tmpName = tmpObject ~ type tmpName

         tmpAttributes = tmpObject ~ dumpAttributes     /* show attributes (EXPOSE, PUBLIC) */

         IF tmpAttributes <> "" THEN
            tmpString = tmpString pp( tmpName tmpAttributes )
         ELSE
            tmpString = tmpString pp( tmpName )

         IF line_nr THEN
         DO
            IF tmpObject ~ LineNr <> .nil THEN
               tmpString = tmpString pp_lineNr( tmpObject ~ LineNr )
         END

         SAY tmpString                          /* show name */
         SAY

         IF tmpObject ~ errors ~ items > 0 THEN /* show errors */
         DO
            SAY indent1 indent2 "The following error(s) was (were) recorded:"
            SAY
            CALL show_sorted_errors tmpObject ~ errors, indent3 indent2
            SAY
         END

         IF tmpObject ~ signatures ~ items > 0 THEN     /* show signatures */
         DO
            title_string = ""
            CALL dump_detail_dir2string tmpObject ~ signatures, indent4, indent2, title_string
         END

         IF tmpObject ~ returns    ~ items > 0 THEN     /* show return statements */
         DO
            title_string = ""
            CALL dump_detail_dir2string tmpObject ~ returns, indent4, indent2, title_string
         END

         IF tmpObject ~ exits      ~ items > 0 THEN     /* show exit-statements */
         DO
            title_string = ""
            CALL dump_detail_dir2string tmpObject ~ exits, indent4, indent2, title_string
         END


         IF tmpObject ~ hasmethod( "local_labels" ) THEN
         DO
            IF tmpObject ~ local_labels ~ items > 0 THEN           /* show labels, but recurse */
            DO
               title_string = "Locally defined LABEL(s):"
               CALL dump_detail_dir2proclikes tmpObject ~ local_labels, indent4, indent2, title_string, line_nr
            END
         END

         IF tmpObject ~ hasmethod( "local_procedures" ) THEN
         DO
            IF tmpObject ~ local_procedures ~ items > 0 THEN       /* show procedures, but recurse */
            DO
               title_string = "Locally defined PROCEDURE(s):"
               CALL dump_detail_dir2proclikes tmpObject ~ local_procedures, indent4, indent2, title_string, line_nr
            END
         END
      END
      SAY
    END
    RETURN




/* dump detail of a directory pointing to strings ( METHOD ) */
DUMP_DETAIL_DIR2METHODS: PROCEDURE EXPOSE ctl
   USE ARG tmpDir, indent1, indent2, title_string, line_nr

   IF \VAR( "line_nr" ) THEN line_nr = .false   /* default to not show line numbers */

   indent3 = indent1 indent2
   indent4 = indent3 indent2

   /* show methods */
   IF tmpDir ~ items > 0 THEN
   DO
      SAY indent1 title_string                  /* display title */
      SAY

      tmpArr = sort( tmpDir )
      max_width = MAX( 3, LENGTH( tmpArr ~ items ) + 1 )
      max_name_width =  tmpDir ~ entry( tmpArr[ 1 ] ) ~ class ~ max_name_length /* get maximum length of name */
      DO i = 1 TO tmpArr ~ items                        /* display entries */
         tmpObject = tmpDir ~ entry( tmpArr[ i ] )
         tmpName = tmpObject ~ type LEFT( pp(tmpObject ~ name), max_name_width)
         tmpString = indent1 indent2 RIGHT( i, max_width)
         tmpAttributes = tmpObject ~ dumpAttributes

         IF tmpAttributes <> "" THEN
            tmpString = tmpString pp( tmpName STRIP( tmpAttributes, "Trailing" ) )
         ELSE
            tmpString = tmpString pp( tmpName )


         IF line_nr THEN
         DO
            IF tmpObject ~ LineNr <> .nil THEN
               tmpString = tmpString pp_lineNr( tmpObject ~ LineNr )
         END

         SAY tmpString                          /* show name */

         IF tmpObject ~ errors ~ items > 0 THEN /* show errors */
         DO
            SAY
            SAY indent1 indent2 "The following error(s) was (were) recorded:"
            SAY
            CALL show_sorted_errors tmpObject ~ errors, indent3 indent2
         END

         IF tmpObject ~ expose ~ items > 0 THEN         /* show EXPOSE string */
         DO
            SAY
            SAY indent4 indent2 pp( tmpObject ~ exposeAsString )
            SAY
         END


         IF tmpObject ~ signatures ~ items > 0 THEN     /* show signatures */
         DO
            SAY
            title_string = ""
            CALL dump_detail_dir2string tmpObject ~ signatures, indent4, indent2, title_string
         END

         IF tmpObject ~ returns    ~ items > 0 THEN     /* show return-statements */
         DO
            SAY
            title_string = ""
            CALL dump_detail_dir2string tmpObject ~ returns, indent4, indent2, title_string
         END

         IF tmpObject ~ exits      ~ items > 0 THEN     /* show exit-statements */
         DO
            title_string = ""
            SAY
            CALL dump_detail_dir2string tmpObject ~ exits, indent4, indent2, title_string
         END

         IF tmpObject ~ local_labels ~ items > 0 THEN           /* show labels */
         DO
            SAY
            title_string = "Locally defined LABEL(s):"
            CALL dump_detail_dir2proclikes tmpObject ~ local_labels, indent4, indent2, title_string, line_nr
         END

         IF tmpObject ~ local_procedures ~ items > 0 THEN       /* show procedures */
         DO
            SAY
            title_string = "Locally defined PROCEDURE(s):"
            CALL dump_detail_dir2proclikes tmpObject ~ local_procedures, indent4, indent2, title_string, line_nr
         END
      END
      SAY
    END
    RETURN




/* dump detail of a directory pointing to strings ( CLASS ) */
DUMP_DETAIL_DIR2CLASSES: PROCEDURE EXPOSE ctl
   USE ARG tmpDir, indent1, indent2, title_string, line_nr

   IF \VAR( "line_nr" ) THEN line_nr = .false   /* default to not show line numbers */

   indent3 = indent1 indent2
   indent4 = indent3 indent2

   /* show classes */
   IF tmpDir ~ items > 0 THEN
   DO
      SAY indent1 title_string                  /* display title */
      SAY

      tmpArr = sort( tmpDir )
      max_width = MAX( 3, LENGTH( tmpArr ~ items ) + 1 )
      max_name_width =  tmpDir ~ entry( tmpArr[ 1 ] ) ~ class ~ max_name_length /* get maximum length of name */
      DO i = 1 TO tmpArr ~ items                        /* display entries */
         tmpObject = tmpDir ~ entry( tmpArr[ i ] )

         IF tmpObject = ctl.eMissingClass THEN          /* missing class in hand ? */
            tmpName   = pp( i "->" tmpObject ~ name )   /* indicate missing class ! */
         ELSE
            tmpName = tmpObject ~ type LEFT( pp( tmpObject ~ name ), max_name_width + 2)

         tmpString = indent1 indent2 RIGHT( i, max_width)
         tmpAttributes = tmpObject ~ dumpAttributes

         IF tmpAttributes <> "" THEN
            tmpString = tmpString pp( tmpName STRIP( tmpAttributes, "Trailing" ) )
         ELSE
            tmpString = tmpString pp( tmpName )

         IF line_nr THEN
         DO
            IF tmpObject ~ LineNr <> .nil THEN
               tmpString = tmpString pp_lineNr( tmpObject ~ LineNr )
         END

         SAY tmpString                          /* show name */

         IF tmpObject ~ errors ~ items > 0 THEN /* show errors */
         DO
            SAY
            SAY indent1 indent2 "The following error(s) was (were) recorded:"
            SAY
            CALL show_sorted_errors tmpObject ~ errors, indent3 indent2
            SAY
         END

         /* CLASS scope */
         IF tmpObject ~ ExposeClass ~ items > 0 THEN     /* show object variables at class scope */
         DO
            SAY
            title_String = "The following object variable(s) was (were) found at CLASS scope:"
            CALL dump_detail_dir2string tmpObject ~ ExposeClass, indent4, indent2, title_string
         END

         IF tmpObject ~ local_Class_Methods ~ items > 0 THEN     /* show object variables at class scope */
         DO
            SAY
            title_string = "CLASS METHOD(s):"
            CALL dump_detail_dir2methods tmpObject ~ local_class_methods, indent4, indent2, title_string, .true
         END

         /* INSTANCE scope */
         IF tmpObject ~ ExposeInstance ~ items > 0 THEN     /* show object variables at Instance scope */
         DO
            SAY
            title_String = "The following object variable(s) was (were) found at INSTANCE scope:"
            CALL dump_detail_dir2string tmpObject ~ ExposeInstance, indent4, indent2, title_string
         END

         IF tmpObject ~ local_Instance_Methods ~ items > 0 THEN     /* show object variables at Instance scope */
         DO
            SAY
            title_string = "INSTANCE METHOD(s):"
            CALL dump_detail_dir2methods tmpObject ~ local_Instance_methods, indent4, indent2, title_string, .true
         END
      END
      SAY
    END
    RETURN




/* ------------------------------------------------------------------------- */
/* dump detail of a directory pointing to strings ( SIGNATURES, RETURNS ) */
DUMP_DETAIL_DIR2STRING: PROCEDURE EXPOSE ctl.
   USE ARG tmpDir, indent1, indent2, title_string

   /* show strings stored with directory */
   IF tmpDir ~ items > 0 THEN
   DO
      IF title_string <> "" THEN
      DO
         SAY indent1 title_string               /* display title */
         SAY
      END

      tmpArr = sort( tmpDir )
      max_width = MAX( 3, LENGTH( tmpArr ~ items ) + 1 )
      DO i = 1 TO tmpArr ~ items                        /* display entries */
         SAY indent1 indent2 RIGHT( i, max_width) pp( tmpDir ~ entry( tmpArr[ i ] ) )
      END
      SAY
    END

    RETURN







/* ------------------------------------------------------------------------- */
/* dump directory of same objects */
DUMP_DIRECTORY: PROCEDURE EXPOSE ctl.
   USE ARG tmpDir, tmpFile, Object2Files, title_string, indent1, indent2, line_nr

   IF \var( "line_nr" ) THEN line_nr = .false

   IF tmpDir ~ items > 0 THEN               /* tokens available for this file ? */
   DO
      tmpArray = sort( tmpDir )             /* sort directory */

                                                  /* account for pp's "[" and "]" ... */
      tmpIndentLength = tmpDir  ~ entry( tmpArray[ 1 ]  ) ~ class ~ max_name_length + 2 /* get maximum width info from class method */
      tmpIndent = COPIES( " ", tmpIndentLength )

      maxArray    = tmpArray ~ items                            /* get maximum array-elements */

      maxArrWidth = MAX( 3, LENGTH( maxArray ), LENGTH( pp_number( maxArray ) ) )
      IF maxArray > 0 THEN
      DO
         SAY indent1 title_string
         SAY
      END

      DO tmpI = 1 TO maxArray

         tmpObject     = tmpDir ~ entry( tmpArray[ tmpI ] )     /* get first token object accessible */
         tmpObjectFile  = Object2Files ~ index( tmpObject )     /* get file-object in which token is defined in */

         IF tmpObject = ctl.eMissingClass THEN          /* missing class in hand ? */
            tmpString = pp( tmpI "->" tmpObject ~ name )        /* indicate missing class ! */
         ELSE
            tmpString = LEFT( pp( tmpObject ~ name ), tmpIndentLength ) /* get name of object */

         IF tmpObjectFile <> tmpFile THEN                       /* if files differ, indicate source-file */
         DO
            IF tmpobjectfile <> .nil then                       /* e.g. def_class for missing-class has not file */
               tmpString = tmpString "defined in:" pp( tmpObjectFile ~ name )
         END

         IF line_nr THEN
         DO
            IF tmpObject ~ LineNr <> .nil THEN
               tmpString = tmpString pp_lineNr( tmpObject ~ LineNr )
         END

         SAY indent1 indent2 RIGHT( tmpI, maxArrWidth ) tmpString
      END
      SAY
   END
   RETURN



/* ------------------------------------------------------------------------- */
SORT_DEF_LIST: PROCEDURE
   USE ARG def_list, maxLength, type

   tmpArray = .array ~ new                      /* create empty array */

   tmpSupp = def_list ~ supplier                /* get a supplier for list */
   i = 1
   DO WHILE tmpSupp ~ available
      IF type = "FILE" THEN
      DO
         tmpName = tmpSupp ~ item ~ name
                                                /* store name in array */
         tmpArray[ i ] = LEFT( pp( FILESPEC( "Name", tmpName) ) || " ", maxLength + 1, "." ) pp( tmpName )

      END
      ELSE
         tmpArray[ i ] = pp( tmpSupp ~ item ~ name )    /* store name in array */

      tmpSupp ~ next
      i = i + 1
   END

   RETURN sort( tmpArray )

/* ------------------------------------------------------------------------- */

/* return the line number in edited form */
pp_lineNr : PROCEDURE
   RETURN "@ l#" pp( ARG(1) )


/* ------------------------------------------------------------------------- */
SHOW_SORTED_ERRORS: PROCEDURE
   USE ARG container, indent

   sorted = sort( container )

   DO i = 1 TO sorted ~ items
      SAY indent sorted[ i ]
   END

   RETURN




/* ------------------------------------------------------------------------------------- */

::REQUIRES rgf_util.cmd


