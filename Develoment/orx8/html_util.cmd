/*
   Module to allow easier manipulation for generating HTML-files

program:   html_util.cmd
type:      Object REXX, REXXSAA 6.0
purpose:   implements functions and classes for easier dealing with HTML
version:   0.80
date:      1995-11
changed:   1997-04-12, split up a little bit for the "8th Int'l Rexx Symposium"

author:    Rony G. Flatscher
           Rony.Flatscher@wu-wien.ac.at
           (Wirtschaftsuniversitaet Wien, University of Economics and Business
           Administration, Vienna/Austria/Europe)
needs:     ---

usage:     see program :)

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



/*
a = "I am f<rO>Mm Au&s-tria ! "
b = "1You'rENot FRoM AusTRiA ?"

SAY "InitCap"
SAY
say "A" pp( a )
say " " pp( InitCap( a, "up", "low" ) )
say

say "B" pp( b )
say " " pp( InitCap( b, "up", "low"  ) )
SAY LEFT( "", 79, "-" )

SAY "CAPITALIZE"
SAY
say "A" pp( a )
say " " pp( capitalize( a, "up", "low"  ) )
say
say "B" pp( b )
say " " pp( capitalize( b, "up", "low"  ) )
SAY LEFT( "", 79, "-" )
*/




        /* create directory of tags, which must not have an end tag as per HTML 3.2,
           save it with environment .local      */
.local ~ html.util = .directory ~ new           /* create directory for HTML_UTIL       */
noEndTags = .directory ~ new
tmpString = "BR HR Image Input IsIndex"

DO WHILE tmpString <> ""
   PARSE VAR tmpString token tmpString
   noEndTags ~ setentry( token, token )
END
.html.util ~ noEndTags = noEndTags


:: REQUIRES sgmlentity_util.cmd /* load SGML-entity-translation support */
:: REQUIRES rgf_util.cmd        /* load miscellaneous utilities */
:: REQUIRES class_ref.cmd       /* load class definitions for basic anchor/refernce support     */


/*
        produce a HTML-string, i.e. embrace argument with tags given as additional arguments,
        ignore attributes on closing tag

        arg(1) ... string to work on

        arg(2) ... tags, including attributes (innermost)
        ...
        arg(n) ... last tag (outermost)
*/
:: ROUTINE WWW_TAG                      PUBLIC
   PARSE ARG string

/*
say "in WWW_TAG() ---- ARG(1)" pp( arg(1) ) "string" pp( string )
IF ARG( 2 ) <> "" THEN say "                  ARG(2)" pp( arg(2) )
IF ARG( 3 ) <> "" THEN say "                  ARG(3)" pp( arg(3) )
IF ARG( 4 ) <> "" THEN say "                  ARG(4)" pp( arg(4) )
*/

    IF ARG(2) = "" THEN RETURN ARG(1)           /* nothing to do */
    tmp = ""
    DO i = 2 TO ARG()
       tmp = tmp || "<" || ARG(i) || ">"
    END

    tmp = tmp || string
    noEndTags = .html.util ~ noEndTags          /* get directory of tags with no end tag */

    DO i = ARG() TO 2 BY -1                     /* don't use attributes, just the tag */
       tmpTag = WORD( ARG( i ), 1 )                /* get tag      */
       IF noEndTags ~ hasentry( tmpTag ) THEN ITERATE   /* tag must not have an end tag */
       tmp = tmp || "</" || tmpTag || ">"
    END


    RETURN tmp
/* ------------------------------------------------------------------------------ */






/* ------------------------------------------------------------------------------ */

/*
    InitCap( string, First_Char_Markup, Rest_Char_Markup )

                1) translate string to uppercase
                2) change fontsize of first letter of each word according to second argument
                3) change fontsize of the rest of the word (except the first char) according to third argument

                4) must be *plain*, i.e. *no* TAGs !


    First_Char_Markup = ARG(2)                  /* markup of first letter in word     */
    Rest_Char_Markup  = ARG(3)                  /* markup of rest of letters in word  */
*/
:: ROUTINE InitCap                     PUBLIC
    PARSE ARG string, First_Char_Markup, Rest_Char_Markup

    tmp_in = NLS_UPPER( string )                /* change everything into uppercase */
    crlf   = .rgf.util ~ CRLF                   /* get the representation of CR-LF */

    IF First_Char_Markup = "" & Rest_Char_Markup = "" THEN
       Rest_Char_Markup = "FONT SIZE=-1"        /* default markup, leave capitals alone lower rest by 1 pt */

    ucase = get_nls_default_object() ~ uppercase            /* get NLS uppercase letters */
    tmp_out = ""                                /* result string */
    non_valid = ""

    DO WHILE tmp_in <> ""
       /* check and process non-valid chars-string */
       non_valid = ""

       char_pos = VERIFY( tmp_in, UCASE, "M" )  /* get position of a valid capital letter */

       IF char_pos > 0 THEN                     /* starts with non-valid letters */
       DO
          non_valid = SUBSTR( tmp_in, 1, char_pos - 1 )     /* extract non-valid char_pos */
          tmp_in    = SUBSTR( tmp_in, char_pos )/* store rest of string, containing valid letters */
       END
       ELSE
       DO
          non_valid = tmp_in                    /* no valid capital letters available */
          tmp_in    = ""
       END

       /* look for blank_pos and insert CRLF, if present */
       IF \( non_valid == "" ) THEN             /* string of non-valid chars */
       DO
          /* give non-valid chars size of capital letter */
          pos = LASTPOS( " ", non_valid )       /* find a blank to insert a CRLF */
          IF pos > 0 THEN                       /* insert a CRLF */
          DO
             non_valid = SUBSTR( non_valid, 1, pos - 1 ) || crlf ||,
                         SUBSTR( non_valid, pos + 1 )
          END
          tmp_out = tmp_out || www_tag( x2bare(non_valid), First_Char_Markup )
       END

       /* change font-sizes for capitalizing according to arguments */
       not_a_letter_pos = VERIFY( tmp_in, UCASE )                       /* look for a non-char */
       IF not_a_letter_pos > 0 THEN
       DO
          chars_first = SUBSTR( tmp_in, 1, 1 )                          /* first letter    */
          chars_rest  = SUBSTR( tmp_in, 2, not_a_letter_pos - 1 - 1 )   /* rest of letters */
          tmp_in      = SUBSTR( tmp_in, not_a_letter_pos )              /* rest of string  */
          tmp_out = tmp_out || www_tag( x2bare(chars_first), First_Char_Markup )/* markup first char */
          tmp_out = tmp_out || www_tag( x2bare(chars_rest),  Rest_Char_Markup  )/* markup rest of chars */
       END
       ELSE     /* only letters left    */
       DO
          IF tmp_in <> "" THEN
          DO
             IF tmp_out = "" THEN       /* nothing processed so far, just a word in hand        */
             DO
                tmp_out = www_tag( x2bare( SUBSTR( tmp_in, 1, 1) ), First_Char_Markup )/* markup first char */

                IF LENGTH( tmp_in > 1 ) THEN    /* more than one letter ?       */
                   tmp_out = tmp_out || www_tag( x2bare( SUBSTR(tmp_in, 2) ),  Rest_Char_Markup  )/* markup rest of chars */
             END
             ELSE
             DO
                tmp_out = tmp_out || www_tag( x2bare(tmp_in),  Rest_Char_Markup  )/* markup rest of chars */
             END
          END
          tmp_in = ""
       END
    END

    RETURN tmp_out
/* ------------------------------------------------------------------------------ */






/*
    capitalize( string, First_Char_Markup, Rest_Char_Markup )

                1) show all letters as is (i.e. preserve lower/uppercase letters) in capitals
                   by showing uppercase letters in a larger font-size

                2) must be *plain*, i.e. *no* TAGs !

    First_Char_Markup = ARG(2)                  /* markup of uppercase letters     */
    Rest_Char_Markup  = ARG(3)                  /* markup of lowercase letters     */

*/
:: ROUTINE CAPITALIZE                   PUBLIC
    PARSE ARG string, First_Char_Markup, Rest_Char_Markup

    /* handle special markup relevant chars, part 1 */
    Table_In  = '&<>"'                            /* chars with special meaning to HTML */
    Table_Out = '01020304'x                       /* illegal HTML-chars                 */
    string = TRANSLATE( string, Table_Out, Table_In )   /* translate to non-supported HTML-chars */


    tmp_in = NLS_UPPER( string )                /* change everything into uppercase */
    crlf   = .rgf.util ~ CRLF                   /* get the representation of CR-LF */

    IF (First_Char_Markup = "" & Rest_Char_Markup = "") THEN
       Rest_Char_Markup = "FONT SIZE=-1"        /* default markup, leave capitals alone lower rest by 1 pt */


    ucase = get_nls_default_object() ~ uppercase            /* get NLS uppercase letters */
    lcase = get_nls_default_object() ~ lowercase            /* get NLS lowercase letters */

    tmp_out = ""                                /* result string */

    DO WHILE tmp_in <> ""

       /* check and process non-valid chars-string */
       posLetter = VERIFY( tmp_in, UCASE, "M" ) /* get first position of a letter */

       IF posLetter = 0 THEN                            /* no letters found */
       DO
          tmp_out = tmp_out || www_tag( x2bare(tmp_in), First_Char_Markup )  /* give non-valid chars size of capital letter */
          LEAVE
       END

       /* save string which has no letters */
       non_valid_letters = SUBSTR( tmp_in, 1, posLetter - 1)    /* extract non-valid letters */

       posBlank = LASTPOS( " ", non_valid_letters )             /* try to find a blank to replace with a CRLF */
       IF posBlank > 0 THEN
       DO
          non_valid_letters = SUBSTR( non_valid_letters, 1, posBlank - 1) || crlf ||,
                              SUBSTR( non_valid_letters, posBlank + 1 )
       END

       tmp_out = tmp_out || www_tag( x2bare( non_valid_letters ), First_Char_Markup )/* give non-valid chars size of capital letter */
       tmp_in = SUBSTR( tmp_in, posLetter )             /* get rid of no letters */
       string = SUBSTR( string, posLetter )

       posNoLetter = VERIFY( tmp_in, UCASE, "N" )       /* get first position of a non-letter */

       IF posNoLetter = 0 THEN                          /* string is built of letters only */
       DO
          tmp_out = capitalize_word( tmp_in, string, tmp_out )
          LEAVE                                         /* done */
       END

       tmp_out = capitalize_word( SUBSTR( tmp_in, 1, posNoLetter - 1),,
                                  SUBSTR( string, 1, posNoLetter - 1), tmp_out )

       tmp_in = SUBSTR( tmp_in, posNoLetter )
       string = SUBSTR( string, posNoLetter )
    END

    /* handle special markup relevant chars, part 2, reversal */
    tmp_out = CHANGESTR( "01"x, tmp_out, "&amp;"  )
    tmp_out = CHANGESTR( "02"x, tmp_out, "&lt;"   )
    tmp_out = CHANGESTR( "03"x, tmp_out, "&gt;"   )
    tmp_out = CHANGESTR( "04"x, tmp_out, "&quot;" )

    RETURN tmp_out

/* markup a string consisting of letters only */
CAPITALIZE_WORD: PROCEDURE EXPOSE First_Char_Markup Rest_Char_Markup UCASE LCASE CRLF
    USE ARG tmp_in, string, tmp_out

    DO WHILE tmp_in <> ""
       posUpper = VERIFY( string, ucase, "M" )  /* find a capital letter */

       IF posUpper = 0 THEN                     /* no capital letter found anymore */
       DO
          tmp_out = tmp_out || www_tag( x2bare(tmp_in),  Rest_Char_Markup  )/* markup lowercase chars */
          LEAVE
       END

       IF posUpper > 1 THEN                     /* take care of possible leading lowercase chars */
       DO
          tmp_out  = tmp_out || www_tag( x2bare(SUBSTR( tmp_in, 1, posUpper - 1)) ,  Rest_Char_Markup )  /* markup lowercase chars */
       END

       PosNextLow = VERIFY( string, lcase, "M", posUpper )      /* find next lowercase letter */
       IF PosNextLow = 0 THEN                   /* only uppercase letters left */
       DO
          tmp_out = tmp_out || www_tag( x2bare(SUBSTR( tmp_in, posUpper )) , First_Char_Markup )    /* markup first char */
          LEAVE
       END

       /* handle uppercase letters */
       tmp_out = tmp_out || www_tag( x2bare( SUBSTR(tmp_in, posUpper, PosNextLow - posUpper )) , First_Char_Markup )

       tmp_in  = SUBSTR( tmp_in, PosNextLow )   /* get unhandled string portion */
       string  = SUBSTR( string, PosNextLow )   /* get unhandled string portion */
    END


    RETURN tmp_out                              /* make a line break after this word */





/* ------------------------------------------------------------------------------ */
/* first do an X2BARE on plain text and then do a BreakLines, so result is readable
   with editors which can't handle large lines (i.e. > 255);
   makes result easier readable for humans too */
:: ROUTINE PlainText           PUBLIC          /* plain text, do a X2BARE and a BreakLines on it */
   USE ARG plainText, lineLength

   IF \VAR( "lineLength" ) THEN lineLength = 100
   RETURN BreakLines( X2BARE( plainText ), lineLength )



/* ------------------------------------------------------------------------------ */
/* plain text needs "&", "<", ">" and sometimes " itself escaped;
   that's what this routine is for */
:: ROUTINE X2BARE               PUBLIC
   PARSE ARG plainText

   plainText = CHANGESTR( "&" , plainText,  "&amp;" )   /* translate ampersand */
   plainText = CHANGESTR( "<" , plainText,  "&lt;" )    /* translate smaller */
   plainText = CHANGESTR( ">" , plainText,  "&gt;" )    /* translate larger */
   plainText = CHANGESTR( '"' , plainText,  "&quot;" )  /* translate to quote */
   RETURN plainText

/* ------------------------------------------------------------------------------ */
/* translate blanks into non-breaking space &nbsp;      */
:: ROUTINE X2BLANK              PUBLIC
   PARSE ARG plainText

   RETURN CHANGESTR( " " , plainText,  "&nbsp;" )       /* translate blank to non-breaking space */





/* ------------------------------------------------------------------------------ */
:: ROUTINE htmlComment                         /* produce a HTML-comment from passed in string */
   RETURN "<!--" ARG( 1 ) "-->"


/* ------------------------------------------------------------------------------ */
:: ROUTINE BreakLines                  PUBLIC  /* break a string into lines */
   USE ARG string, lineChars

   IF \VAR( "lineChars" ) THEN lineChars = 100

   tmpString = ""
   crlf = .rgf.util ~ crlf                      /* get CRLF */
   filler = LEFT( "", 5 )

   DO WHILE string <> ""
      IF LENGTH( string ) <= lineChars THEN
      DO
         tmpString = tmpString crlf filler string
         LEAVE
      END

      pos = LASTPOS( " ", string, lineChars + 1 )       /* look for a blank to break */
      IF pos < 70 THEN                                  /* not found */
      DO
         pos = POS( " ", string, lineChars )            /* look for a blank towards the end */
         IF pos = 0 THEN                                /* no more blanks left ! */
         DO
            tmpString = tmpString crlf filler string
            LEAVE
         END
      END

      tmpString = tmpString crlf filler SUBSTR( string, 1, pos )/* insert CRLF */
      string = SUBSTR( string, pos + 1 )                /* remove part already handled */
   END
   RETURN tmpString


/* ---------------------------------------------------------------------------------------- */
/* purpose: capitalize or initcap plain text, replace blanks by &nbsp; (non-breaking space) by default */
/*          works with defaults: lowercase letters are FONT SIZE=-1                     */
/* capitalize, translate to html of **PLAIN TEXT** string, blanks will be translated into &nbsp; ! */
:: ROUTINE SmartCap                     PUBLIC
  USE ARG string, type, bBlanks

  bBlanks = ( bBlanks <> .false )               /* default: translate blanks into &nbsp; */

  IF TRANSLATE( LEFT( type, 1 ) ) = "I" THEN type = "I" /* InitCap desired */
                                        ELSE type = "C" /* default to capitalize */

  IF bBlanks THEN
     string = CHANGESTR( " ", string, "00"x )

  IF type = "C" THEN
      string = CAPITALIZE( string )                     /* capitalize string */
  ELSE
      string = INITCAP( string )                        /* initcap string */


  IF bBlanks THEN                                       /* translate blanks into &nbsp; ! */
     string = CHANGESTR( "00"x, string,  "&nbsp;" )     /* translate blank to non-breaking space */
  ELSE
     string = CHANGESTR( "00"x, string,  " "      )     /* translate blank to non-breaking space */

  RETURN string



/* ---------------------------------------------------------------------------------------- */
/* put text into given anchor-name-definition */
:: ROUTINE A_NAME               PUBLIC
  PARSE ARG name, text

  RETURN '<A NAME="' || name || '">'    text    "</A>"


/* ---------------------------------------------------------------------------------------- */
/* put text into given anchor-name-definition */
:: ROUTINE A_HREF               PUBLIC
  PARSE ARG doc, name, text

  RETURN '<A HREF="' || doc || "#" || name || '">' || text || "</A>"






/* ================================================================================================ */




/* ================================================================================================ */
/* ------------------------------------------------------------------------------------------------ */
/* a class for producing HTML-docs */
:: CLASS HTML_DOC               PUBLIC

/* ----------------------------------------------- */
:: METHOD init
   EXPOSE file stream bClosed additionalHeader additionalFooter
   USE ARG file, title, bReplace, additionalHeader, additionalFooter

   IF \VAR( "file" )                            THEN RAISE SYNTAX 3.901 ARRAY ( file )   /* file missing */
   IF \VAR( "title" )                           THEN title = "No title supplied !"
   IF \VAR( "bReplace") | bReplace = "BREPLACE" THEN bReplace = .false
   IF \VAR( "additionalHeader" )                THEN additionalHeader = ""
   IF \VAR( "additionalFooter" )                THEN additionalFooter = ""

   stream = .stream ~ new( file )
   IF \bReplace THEN                                    /* file replacement o.k. ? */
   DO
      IF stream ~ query( "exists" ) <> "" THEN          /* file exists, abort, pretend problems writing to it */
      DO
         stream ~ close                                 /* make sure, it's closed */
         RAISE SYNTAX 3.902 ARRAY ( file )
      END
   END

   stream = .stream ~ new( file ) ~~ open( "write replace" )    /* open file for writing, replace existing one */
   bClosed = .false
   self ~ HTML_header( title )
   RETURN



/* ----------------------------------------------- */
/* assumptions:        method_name     ... 1st tag
                       argument[1]     ... string to work on
                       argument[2]     ... attribute for 1st tag, empty else
                       argument[3 ..n] ... additional tags including attributes
*/

:: METHOD UNKNOWN               /* treat unknown message as HTML-tag(s), except for LINEOUT */
   EXPOSE stream file bClosed
   USE ARG mess_name, mess_args

   IF \ bClosed THEN
   DO
      IF mess_name = "LINEOUT" THEN             /* forward LINEOUT to stream */
      DO
         FORWARD MESSAGE (mess_name) ARGUMENTS ( mess_args ) TO ( stream ) CONTINUE
      END
      ELSE                                      /* build and execute arguments for www_tag */
      DO
         /* build string to interpret, encompass string limit by using stem. for substitution */
         IF mess_args ~ items = 0 | mess_args[ 1 ] = .nil THEN          /* no content given */
            a.1 = htmlComment( "empty" )
         ELSE                                   /* use verbatim */
            a.1 = mess_args[ 1 ]

         i = 1
         tmpString = "tmp = www_tag( a.1 ,"

         IF mess_args[ 2 ] <> .nil THEN         /* message name is first tag */
         DO
            a.2 = mess_args[ 2 ]                /* get second argument, interpreted as attribute for message-tag */
            tmpString = tmpString "mess_name a.2"
            i = 2
         END
         ELSE
            tmpString = tmpString "mess_name"


         DO i = 3 TO mess_args ~ size           /* build tags */
            a.[i + 1] = mess_args[ i ]
            tmpString = tmpString ", a."|| i + 1   /* save rest of arguments as additional tags */
         END
         tmpString = tmpString ")"              /* supply closing bracket */

         INTERPRET tmpString                    /* execute contents, i.e. call www_tag() */
         FORWARD MESSAGE ("LINEOUT") ARRAY ( tmp ) TO ( stream ) CONTINUE
      END

      stream ~ lineout( "" )                    /* insert empty line */
   END
   ELSE                                         /* file closed already ! */
      RAISE SYNTAX 3.902 ARRAY ( pp( file) "was closed already!" )

   RETURN



/* ----------------------------------------------- */
:: METHOD close                                         /* close stream, invalidate */
   EXPOSE bClosed

   IF \ bClosed THEN
   DO
      self ~ html_footer_close                          /* insert closing tags, close stream */
      bClosed = .true                                   /* indicate that closing took place already */
   END


/* ----------------------------------------------- */
:: METHOD uninit                                        /* make sure file is closed */
   self ~ close                                         /* write footer, close file */


/* ----------------------------------------------- */
:: METHOD html_header           PRIVATE         /* insert opening HTML-tags */
   EXPOSE stream  additionalHeader
   USE ARG title, htmlVersion

   IF \VAR( "htmlVersion" ) THEN htmlVersion = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'

   stream ~ lineout( htmlVersion )
   stream ~ lineout( "<HTML>" )
   stream ~ lineout( "<HEAD>" )

   tmpString = "produced with Object REXX using HTML_UTIL.CMD (author: Rony G. Flatscher)"
   stream ~ lineout( htmlComment( tmpString ) )

   stream ~ lineout( htmlComment( "production started at:" DATE( "S" ) TIME() ) )

   stream ~ lineout( www_tag( x2bare( title ), "TITLE" ) )

   IF additionalHeader <> "" THEN               /* write additional header */
      stream ~ lineout( additionalHeader )

   stream ~ lineout( "</HEAD>" )
   stream ~ lineout( "<BODY>" )


/* ----------------------------------------------- */
:: METHOD html_footer_close     PRIVATE         /* insert closing HTML-tags */
   EXPOSE stream  additionalFooter

   IF additionalFooter <> "" THEN               /* write additional footer */
      stream ~ lineout( additionalFooter )

   stream ~ lineout( "</BODY>" )
   stream ~ lineout( "</HTML>" )                     /* write closing tag */

   stream ~ lineout( htmlComment( "production ended at:" DATE( "S" ) TIME() ) )

   stream ~ close                                    /* close stream */
/* ------------------------------------------------------------------------------------------------ */



/* ================================================================================================ */
/* define a class for HTML-table handling */
:: CLASS HTML_table             PUBLIC
/* ----------------------------------------------- */
:: METHOD INIT          CLASS                   /* counter to count # of lists generated */
   EXPOSE counter

   counter = 0

/* ----------------------------------------------- */
:: METHOD counter       CLASS                   /* counter to count # of lists generated */
   EXPOSE counter

   counter = counter + 1                        /* increment counter */
   RETURN counter


/* ----------------------------------------------- */
:: METHOD INIT
   EXPOSE tabArray tabAttributes Caption CaptionAttr,
          lastRow lastCol bEditable htmlText TableNumber maxCol bSkipActive

   USE ARG  tabAttributes

   /* check & set defaults if necessary */
   IF \VAR( "tabAttributes" ) THEN tabAttributes = "TABLE BORDER CELLPADDING=5" /* default for table */
                              ELSE tabAttributes = "TABLE" tabAttributes

   caption = .nil                       /* no caption */
   captionAttr = .nil                   /* no caption position */
   lastRow = 1                          /* last row used, default to row # 1 */
   lastCol = 0                          /* last col used */
   maxCol = 0                           /* maximum nr. of columns on line */
   bEditable = .true                    /* allow table to edit (until close or attach is sent) */
   bSkipActive = .false                 /* indicate that nextRow should insert COLSPAN= */
   htmlText = .nil                      /* no HTML-text of table produced as of yet */
   tabArray = .array ~ new              /* create an array to contain table elements */
   TableNumber = self ~ class ~ counter /* get # of table */


/* ----------------------------------------------- */
:: METHOD setCaption
   EXPOSE  Caption CaptionAttr
   USE ARG Caption, CaptionAttr

   IF \VAR( "CaptionAttr" ) THEN CaptionAttr  = "CAPTION ALIGN=bottom"
                            ELSE CaptionAttr  = "CAPTION" CaptionAttr

/* ----------------------------------------------- */
:: METHOD putColumn                                     /* put a new column into table */
   EXPOSE tabArray lastRow lastCol bEditable maxCol
   USE ARG string, attributes

   IF \ bEditable THEN RETURN                           /* don't do anything anymore */
   IF \ VAR( "string" ) | string = "" THEN string = htmlComment( "empty" )
   IF \VAR( "attributes" ) THEN attributes = "TD"       /* default for missing argument, i.e. plain table cell */
                           ELSE attributes = "TD" attributes

   lastCol = lastCol + 1                                /* insert next column */
   tmpArr = .array ~ of( string, attributes )
   tabArray[ lastRow, lastCol ] = tmpArr                /* insert array containing infos into main array */
   maxCol = MAX( maxCol, lastCol )                      /* save highest column nr. of row */

/* ----------------------------------------------- */
:: METHOD putHeader                                     /* put a new header column into table */
   EXPOSE tabArray lastRow lastCol bEditable maxCol
   USE ARG string, attributes

   IF \ bEditable THEN RETURN                           /* don't do anything anymore */
   IF \VAR( "attributes" ) THEN attributes = "TH"       /* default for missing argument, i.e. table header cell */
                           ELSE attributes = "TH" attributes

   lastCol = lastCol + 1                                /* insert next column */
   tmpArr = .array ~ of( string, attributes )
   tabArray[ lastRow, lastCol ] = tmpArr                /* insert array containing infos into main array */
   maxCol = MAX( maxCol, lastCol )                      /* save highest column nr. of row */


/* ----------------------------------------------- */
:: METHOD newRow                                /* change to next row of the table */
   EXPOSE lastRow lastCol tabArray maxCol bSkipActive bEditable
   USE ARG Fixup                                /* if bFixup = true, then gaps will be closed via COLSPAN statements */


   IF \ bEditable THEN RETURN                           /* don't do anything anymore */
   IF \VAR( "Fixup" ) THEN bFixup = .nil        /* if .nil, then use maxCol to determine maximum amount of cols */

   IF bSkipActive & bFixup = .nil THEN          /* if a column was skipped, make sure COLSPAN= is inserted */
      bFixup = maxCol

   IF Fixup <> .nil THEN                        /* fixup column definitions by adding COLSPAN= to close gaps */
   DO
      IF DATATYPE( Fixup, "W") THEN
      DO
         maxCol = MAX( maxCol, Fixup )          /* use whatever is higher */
      END

      startCol = 0
      endCol   = 0

      DO col = 1 TO maxCol                              /* find first non-empty entry */
         IF tabArray[ lastRow, col ] <> .nil THEN
         DO
            startCol = col
            LEAVE
         END
      END

      IF startCol > 1 THEN                              /* empty columns from beginning */
      DO
        tabArray[ lastRow, 1 ] = .array ~ of( htmlComment( "empty cell, from newRow" ), "TD COLSPAN=" || startCol - 1 )    /* empty column, it was skipped */
      END

      DO col = col TO maxCol
         IF tabArray[ lastRow, col ] = .nil THEN        /* skip until an entry was found */
            ITERATE

         IF col - startCol > 1 THEN                     /* gap found */
            CALL fixup col                              /* fixup in procedure  */

         startCol = col                                 /* save present column */
      END

      IF startCol > 0 & startCol <> maxCol THEN         /* fixup to the end     */
         CALL fixup maxCol + 1
   END


   lastRow = lastRow + 1                                /* increase row counter */
   lastCol = 0                                          /* reset lastCol */
   maxCol  = 0                                          /* reset maxCol for row */
   bSkipActive = .false
   RETURN

FIXUP :
   USE ARG tmpCol

   tmpArray = tabArray[ lastRow, startCol ]
   attribute = tmpArray[ 2 ]
   attribute = attribute "COLSPAN=" || ( tmpCol - startCol )    /* add spanning attribute */
   tmpArray[ 2 ] = attribute
   tabArray[ lastRow, startCol ] = tmpArray     /* insert array containing infos into main array */
   RETURN



/* ----------------------------------------------- */
:: METHOD skipColumn                            /* skip column, use with newRow( some_content ) */
   EXPOSE tabArray lastRow lastCol maxCol bSkipActive bEditable
   USE ARG nrOfCols

   IF \ bEditable THEN RETURN                           /* don't do anything anymore */
   IF \DATATYPE( nrOfCols, "W" ) THEN nrOfCols = 1      /* whole number given ? */

   IF nrOfCols < 1 THEN RETURN  /* don't skip, if not a positive number given ...       */

   lastCol = lastCol + nrOfCols
   maxCol = MAX( maxCol, lastCol )                      /* save highest column nr. of row */
   bSkipActive = .true

/* ----------------------------------------------- */
:: METHOD emptyColumn                           /* add empty column(s) */
   EXPOSE tabArray lastRow lastCol maxCol bEditable
   USE ARG nrOfCols

   IF \ bEditable THEN RETURN                           /* don't do anything anymore */
   IF \DATATYPE( nrOfCols, "W" ) THEN nrOfCols = 1      /* whole number given ? */
   IF nrOfCols = 0 THEN RETURN                          /* don't do anything, if explicitly asked to skip no column */

   tmpString = htmlComment( "empty" )
   DO i = 1 TO nrOfCols
      lastCol = lastCol + 1
      tabArray[ lastRow, lastCol ] = .array ~ of( tmpString, "TD" )    /* empty column, it was skipped */
   END
   maxCol = MAX( maxCol, lastCol )                      /* save highest column nr. of row */


/* ----------------------------------------------- */
:: METHOD close                                 /* close editing of table */
   EXPOSE bEditable

   bEditable = .false                           /* no editing of table allowed anymore */
   self ~ htmlText                         /* produce HTML text */


/* ----------------------------------------------- */
:: METHOD htmlText
   EXPOSE tabArray tabAttributes Caption CaptionAttr lastRow lastCol bEditable htmlText TableNumber bSkipActive

   IF htmlText <> .nil THEN RETURN htmlText     /* return HTML-text of this table, was already produced */
   IF bSkipActive THEN self ~ newRow            /* make sure a row with skipped column(s) is handled properly */

   bEditable = .false                           /* no editing of table allowed anymore */
   crlf = .rgf.util ~ CRLF                      /* get CR-LF */

   tmpSupp = tabArray ~ supplier                /* get a supplier of the array */
   rowDim  = tabArray ~ dimension( 1 )          /* get "row" dimensionality */
   colDim  = tabArray ~ dimension( 2 )          /* get "col" dimensionality */
   rowWidth = LENGTH( rowDim )
   colWidth = LENGTH( colDim )
   tmp_String = ""
   EmptyCell = htmlComment( "empty" )

   /* produce caption */
   IF caption <> .nil THEN tmp_string = crlf www_tag( Caption, CaptionAttr )


   oldRow = 0
   oldCol = 0
   tmpRow = ""

   DO WHILE tmpSupp ~ AVAILABLE
      tmp = tmpsupp ~ INDEX - 1
      row = tmp %  colDim + 1                   /* get row from index */
      col = tmp // colDim + 1                   /* get col from index */

      IF oldRow = 0 THEN
      DO
         oldRow = row
      END

      tmpArray = tabArray[ row, col ]           /* get array object */

      IF oldRow <> row THEN                     /* a new row arrived */
      DO
         tmp_String = tmp_String crlf www_tag( crlf || tmpRow" ", "TR" ) crlf
         tmpRow = htmlComment( "empty" )

         DO oldRow = oldRow + 1 TO row - 1          /* empty rows in between ? */
            tmp_String = tmp_String crlf www_tag( tmpRow , "TR" ) crlf
         END
         tmpRow = ""
         oldRow = row
      END

      /* add cell */
      tmpRow = tmpRow rowCol() www_tag( tmpArray[ 1 ], tmpArray[ 2 ] ) crlf
      oldCol = col

      tmpSupp ~ next                            /* get next array element */
   END

   tmp_String = tmp_String crlf www_tag( crlf || tmpRow" ", "TR" ) crlf

   htmlText = www_tag( tmp_string, tabAttributes )

   /* make HTML text a little more readable */
   htmlText = crlf crlf || htmlComment( "Begin of" pp( tabAttributes ) "table #" pp( TableNumber ) || "..." ) crlf htmlText crlf ||,
              htmlComment( "end of" pp( tabAttributes ) "table #" pp( TableNumber ) || "." ) crlf

   RETURN htmlText

rowCol :                                        /* indicate row/col in form of a comment */
   RETURN htmlComment( "row=" || RIGHT( row, rowWidth ) || ", col=" || RIGHT( col, colWidth ) )

misty : procedure
   RETURN mist
/* ------------------------------------------------------------------------------------------------ */




/* ================================================================================================ */
/* define a class for HTML-list handling (un/numbered and definition lists) */

:: CLASS HTML_list              PUBLIC
/* ----------------------------------------------- */
:: METHOD INIT          CLASS                   /* counter to count # of lists generated */
   EXPOSE counter

   counter = 0

/* ----------------------------------------------- */
:: METHOD counter       CLASS                   /* counter to count # of lists generated */
   EXPOSE counter

   counter = counter + 1                        /* increment counter */
   RETURN counter

/* ----------------------------------------------- */
:: METHOD INIT
   EXPOSE bEditable htmlText htmlList typeChanged ListNumber

   USE ARG  ListTagOpen, ListTagItem, ListTagDescription

   FORWARD MESSAGE ("SetListType") CONTINUE     /* let SetListType */

   bEditable = .true                            /* allow table to edit (until close or attach is sent) */
   htmlText = .nil                              /* no HTML-text of table produced as of yet */
   htmlList  = .list  ~ new                     /* create a list to contain table elements */
   typeChanged = .false
   ListNumber = self ~ class ~ counter          /* get counter number for this list object */

/* ----------------------------------------------- */
:: METHOD SetListType
   EXPOSE ListTagOpen  ListTagItem  ListTagDescription typeChanged

   USE ARG  ListTagOpen, ListTagItem, ListTagDescription

   /* check & set defaults if necessary */
   IF \VAR( "ListTagOpen" ) THEN                /* default to an unnumbered list */
   DO
      ListTagOpen        = "UL"                 /* unordered list */
      ListTagItem        = "LI"                 /* list-item */
      ListTagDescription  = "LI"                 /* list-item */
   END
   ELSE IF \VAR( "ListTagItem" ) THEN           /* try to determine desired list-type, use LI by default */
   DO
      IF TRANSLATE( WORD( ListTagOpen, 1 ) ) = "DL" THEN        /* a definition list ? */
      DO
         ListTagItem        = "DT"              /* definition term */
         ListTagDescription  = "DD"              /* definition description */
      END
      ELSE                                      /* default to LI, "list item" */
      DO
         ListTagItem        = "LI"              /* list-item */
         ListTagDescription  = "LI"              /* list-item */
      END
   END
   ELSE IF \VAR( "ListTagDescription" ) THEN     /* use ListTagItem for ListTagDescription */
      ListTagDescription = ListTagItem

   typeChanged = .true                          /* indicate that type may have been changed */


/* ----------------------------------------------- */
:: METHOD Item                                          /* put a new listitem into table */
   EXPOSE  bEditable htmlList
   USE ARG string, attributes

   IF \ bEditable THEN RETURN                           /* don't do anything anymore */

   IF \VAR( "attributes" ) THEN
      attributes = ""                                   /* indicate missing attribute */

   tmpArr = .array ~ of( string, "1", attributes )
   htmlList ~ insert( tmpArr )                          /* insert array containing infos into list */

/* ----------------------------------------------- */
:: METHOD Term                                          /* put a definition term into list */
   EXPOSE  bEditable  htmlList
   USE ARG string, attributes

   IF \ bEditable THEN RETURN                           /* don't do anything anymore */

   IF \VAR( "attributes" ) THEN
      attributes = ""                                   /* indicate missing attribute */

   tmpArr = .array ~ of( string, "2", attributes )
   htmlList ~ insert( tmpArr )                          /* insert array containing infos into list */

/* ----------------------------------------------- */
:: METHOD Description                                   /* put a description for a term into list */
   EXPOSE  bEditable htmlList
   USE ARG string, attributes

   IF \ bEditable THEN RETURN                           /* don't do anything anymore */

   IF \VAR( "attributes" ) THEN
      attributes = ""                                   /* indicate missing attribute */

   tmpArr = .array ~ of( string, "3", attributes )
   htmlList ~ insert( tmpArr )                          /* insert array containing infos into list */


/* ----------------------------------------------- */
:: METHOD close                                 /* close editing of table */
   EXPOSE bEditable typeChanged

   bEditable = .false                           /* no editing of table allowed anymore */
   typeChanged = .true
   self ~ htmlText                         /* produce HTML text */


/* ----------------------------------------------- */
:: METHOD htmlText
   EXPOSE ListTagOpen  ListTagItem  ListTagDescription bEditable htmlText htmlList typeChanged ListNumber

   IF bEditable THEN                            /* was in edit-mode */
   DO
      bEditable = .false                        /* no editing of list itself allowed anymore */
      typeChanged = .true                       /* have a htmlText generated */
   END

   IF \ typeChanged THEN RETURN htmlText       /* return HTML-text of this table, was already produced */
   typeChanged = .false                         /* no need to build string a second time */

   crlf = .rgf.util ~ CRLF                      /* get CR-LF */

   tmpSupp = htmlList ~ supplier                /* get a supplier of the list */
   tmp_String = ""

   /* check whether Item and Descriptions are different tags, if so, then we have a defintion list */
   bDefinition = \( TRANSLATE(WORD( ListTagItem, 1  )) = TRANSLATE( WORD( ListTagDescription, 1) ) )

   termPending = .false

   i = 0
   DO WHILE tmpSupp ~ AVAILABLE
      item = tmpSupp ~ item
      i = i + 1
      SELECT
         WHEN item[ 2 ] = 1 THEN                /* an item in hand */
         DO
            IF bDefinition THEN                 /* a definition list ? */
            DO
               IF termPending THEN              /* is a term (e.g. DT ) pending ? */
               DO
                  tmp_String = tmp_String crlf htmlComment( "*Error*: a [" || ListTagItem || "] term without a description! ") crlf
               END
               termPending = .true              /* deal as if a term has been supplied ! */
            END

            tmpTag = ListTagItem                /* a Listtag-Item in hand */
         END

         WHEN item[ 2 ] = 2 THEN                /* a term in hand */
         DO
            IF bDefinition THEN                 /* a definition list ? */
            DO
               IF termPending THEN              /* is a term (e.g. DT ) pending ? */
               DO
                  tmp_String = tmp_String crlf htmlComment( "*Error*: a [" || ListTagItem || "] term without a description! ") crlf
               END
               termPending = .true              /* to be handled with a description */
            END

            tmpTag = ListTagItem                /* a Listtag-Item in hand */
         END

         OTHERWISE                              /* a description in hand */
         DO
            IF bDefinition THEN                 /* a definition list ? */
            DO
               IF \ termPending THEN            /* is a term (e.g. DT ) pending ? */
               DO
                  tmp_String = tmp_String crlf htmlComment( "*Error*: a [" || ListTagItem ||,
                               "] description, but term is missing!" ) crlf
               END
               termPending = .false             /* handled */
            END

            tmpTag = ListTagDescription         /* a Listtag-Item in hand */
         END
      END

      /* was an attribute given to this listelement ? */
      IF item[ 3 ] <> "" THEN tmpTag = WORD( tmpTag, 1 ) item[ 3 ]

      tmp_String = tmp_String crlf htmlComment( "list entry #" i) www_tag( item[ 1 ], tmpTag )
      IF bDefinition THEN
      DO
         IF item[ 2 ] = 3 THEN                  /* a description in hand, insert a crlf */
           tmp_String = tmp_String crlf
      END

      tmpSupp ~ next
   END

   htmlText = www_tag( tmp_string crlf, ListTagOpen )
   /* make HTML text a little more readable */
   htmlText = crlf crlf || htmlComment( "Begin of" pp( ListTagOpen ) "list #" pp( ListNumber ) || "..." ) crlf htmlText crlf ||,
              htmlComment( "end of" pp( ListTagOpen ) "list #" pp( ListNumber ) || "." ) crlf

   RETURN htmlText
/* ------------------------------------------------------------------------------------------------ */






/* ================================================================================================ */
/* define a class for HTML-list handling (un/numbered and definition lists) */

:: CLASS html.reference SUBCLASS ref  PUBLIC    /* subclass the anchor-manager */

:: METHOD A_Name        CLASS                   /* retrieve a reference name, else create it */
   USE ARG anObject, text

   RETURN '<A NAME="' || self ~ createReference( anObject ) || '">'  text  "</A>"


/* ---------------------------------- */
:: METHOD A_Href        CLASS                   /* retrieve a reference name, else create it */
   USE ARG anObject,  text, htmlFile

   IF ARG( 3, "O" ) THEN htmlFile = ""          /* supply default empty string  */

   RETURN '<A HREF="' || htmlFile || "#" || self ~ getReference( anObject ) || '">' || text || "</A>"
/* ------------------------------------------------------------------------------------------------ */

