/*
   Module to allow translation from characters to SGML-entities and vice-versa,
   used e.g. in HTML

program:   sgml_entities.cmd
type:      Object REXX, REXXSAA 6.0
purpose:   implements functions and classes for x-lating chars <--> SGML-entities (HTML)
version:   1.0
date:      1997-04-15

author:    Rony G. Flatscher
           Rony.Flatscher@wu-wien.ac.at
           (Wirtschaftsuniversitaet Wien, University of Economics and Business
           Administration, Vienna/Austria/Europe)

needs:     NLS_UTIL.CMD

usage:     call or require this module, which will set up tables for translating
           characters according to a code-page to the appropriate SGML-entities as
           they are used in HTML-files (being based on SGML); thereafter the following
           two routines are available:

             CPString2SGMLEntity( string [, [CodePage] [, "Reverse" ] ] )
                ... returns a string in which characters are translated according
                    to the given codepage (defaults to NLS_UTIL' default codepage);
                    if the third argument "R" is given then translation occurs from
                    SGML-entities to the appropriate characters according to the given
                    codepage

             CPFile2SGMLEntity( filename [, [CodePage] [, "Reverse" ] ] )
                ... works on the contents of the file denoted by "filename"; for
                    its work it uses CPString2SGMLEntity(), hence the second and
                    third argument are the same as above


comments:  prepared for the "8th International Rexx Symposium 1997", April 1997, Heidelberg/Germany


All rights reserved and copyrighted 1997 by the author,
no guarantee that it works without errors, etc. etc.

You are granted the right to use this module under the condition that you don't charge money for this module (as you didn't write
it in the first place) or modules directly derived from this module, that you document the original author (to give appropriate
credit) with the original name of the module and that you make the unaltered, original source-code of this module available on
demand.  If that holds, you may even bundle this module (either in source or compiled form) with commercial software.

If you find an error, please send me the description (preferably a *very* short example);
I'll try to fix it and re-release it to the net.

!!!!!!
If you extend the definitions with the codepage of *your* country, *please* send me those
definitions and I will extend this module and re-release it to the net.
!!!!!!
*/



/* initialize, setup CP 850 (Western Europe) and 437 (US)       */
/* Codepage 850 (Europe) */
cp850tab = .table ~ new                            /* create a table */

/*       VALUE sgml-entity: |  INDEX in form of the appr. CP-character     */
cp850tab ~ PUT( "&Ccedil;"  ,  D2C( 128 ) )
cp850tab ~ PUT( "&uuml;"    ,  D2C( 129 ) )     /* e.g. German umlaut-"u"       */
cp850tab ~ PUT( "&eacute;"  ,  D2C( 130 ) )
cp850tab ~ PUT( "&acirc;"   ,  D2C( 131 ) )
cp850tab ~ PUT( "&auml;"    ,  D2C( 132 ) )
cp850tab ~ PUT( "&agrave;"  ,  D2C( 133 ) )     /* e.g. french "a" with accent grave */
cp850tab ~ PUT( "&aring;"   ,  D2C( 134 ) )
cp850tab ~ PUT( "&ccedil;"  ,  D2C( 135 ) )
cp850tab ~ PUT( "&ecirc;"   ,  D2C( 136 ) )
cp850tab ~ PUT( "&euml;"    ,  D2C( 137 ) )
cp850tab ~ PUT( "&egrave;"  ,  D2C( 138 ) )
cp850tab ~ PUT( "&iuml;"    ,  D2C( 139 ) )
cp850tab ~ PUT( "&icirc;"   ,  D2C( 140 ) )
cp850tab ~ PUT( "&igrave;"  ,  D2C( 141 ) )
cp850tab ~ PUT( "&Auml;"    ,  D2C( 142 ) )
cp850tab ~ PUT( "&Aring;"   ,  D2C( 143 ) )     /* e.g. nordic "A" with a ring on top */
cp850tab ~ PUT( "&Eacute;"  ,  D2C( 144 ) )
cp850tab ~ PUT( "&aelig;"   ,  D2C( 145 ) )
cp850tab ~ PUT( "&AElig;"   ,  D2C( 146 ) )
cp850tab ~ PUT( "&ocirc;"   ,  D2C( 147 ) )
cp850tab ~ PUT( "&ouml;"    ,  D2C( 148 ) )
cp850tab ~ PUT( "&ograve;"  ,  D2C( 149 ) )
cp850tab ~ PUT( "&ucirc;"   ,  D2C( 150 ) )
cp850tab ~ PUT( "&ugrave;"  ,  D2C( 151 ) )
cp850tab ~ PUT( "&yuml;"    ,  D2C( 152 ) )
cp850tab ~ PUT( "&Ouml;"    ,  D2C( 153 ) )
cp850tab ~ PUT( "&Uuml;"    ,  D2C( 154 ) )
cp850tab ~ PUT( "&oslash;"  ,  D2C( 155 ) )
cp850tab ~ PUT( "&pound;"   ,  D2C( 156 ) )
cp850tab ~ PUT( "&Oslash;"  ,  D2C( 157 ) )
cp850tab ~ PUT( "&times;"   ,  D2C( 158 ) )
cp850tab ~ PUT( "&aacute;"  ,  D2C( 160 ) )
cp850tab ~ PUT( "&iacute;"  ,  D2C( 161 ) )
cp850tab ~ PUT( "&oacute;"  ,  D2C( 162 ) )
cp850tab ~ PUT( "&uacute;"  ,  D2C( 163 ) )
cp850tab ~ PUT( "&ntilde;"  ,  D2C( 164 ) )
cp850tab ~ PUT( "&Ntilde;"  ,  D2C( 165 ) )
cp850tab ~ PUT( "&ordf;"    ,  D2C( 166 ) )
cp850tab ~ PUT( "&ordm;"    ,  D2C( 167 ) )
cp850tab ~ PUT( "&iquest;"  ,  D2C( 168 ) )
cp850tab ~ PUT( "&reg;"     ,  D2C( 169 ) )
cp850tab ~ PUT( "&not;"     ,  D2C( 170 ) )
cp850tab ~ PUT( "&frac12;"  ,  D2C( 171 ) )
cp850tab ~ PUT( "&frac14;"  ,  D2C( 172 ) )
cp850tab ~ PUT( "&iexcl;"   ,  D2C( 173 ) )
cp850tab ~ PUT( "&laquo;"   ,  D2C( 174 ) )
cp850tab ~ PUT( "&raquo;"   ,  D2C( 175 ) )
cp850tab ~ PUT( "&Aacute;"  ,  D2C( 181 ) )
cp850tab ~ PUT( "&Acirc;"   ,  D2C( 182 ) )
cp850tab ~ PUT( "&Agrave;"  ,  D2C( 183 ) )
cp850tab ~ PUT( "&copy;"    ,  D2C( 184 ) )
cp850tab ~ PUT( "&cent;"    ,  D2C( 189 ) )
cp850tab ~ PUT( "&yen;"     ,  D2C( 190 ) )
cp850tab ~ PUT( "&atilde;"  ,  D2C( 198 ) )
cp850tab ~ PUT( "&Atilde;"  ,  D2C( 199 ) )
cp850tab ~ PUT( "&curren;"  ,  D2C( 207 ) )
cp850tab ~ PUT( "&eth;"     ,  D2C( 208 ) )
cp850tab ~ PUT( "&ETH;"     ,  D2C( 209 ) )
cp850tab ~ PUT( "&Ecirc;"   ,  D2C( 210 ) )
cp850tab ~ PUT( "&Euml;"    ,  D2C( 211 ) )
cp850tab ~ PUT( "&Egrave;"  ,  D2C( 212 ) )
cp850tab ~ PUT( "&Iacute;"  ,  D2C( 214 ) )
cp850tab ~ PUT( "&Icirc;"   ,  D2C( 215 ) )
cp850tab ~ PUT( "&Iuml;"    ,  D2C( 216 ) )
cp850tab ~ PUT( "&brkbar;"  ,  D2C( 221 ) )
cp850tab ~ PUT( "&Igrave;"  ,  D2C( 222 ) )
cp850tab ~ PUT( "&Oacute;"  ,  D2C( 224 ) )
cp850tab ~ PUT( "&szlig;"   ,  D2C( 225 ) )
cp850tab ~ PUT( "&Ocirc;"   ,  D2C( 226 ) )
cp850tab ~ PUT( "&Ograve;"  ,  D2C( 227 ) )
cp850tab ~ PUT( "&otilde;"  ,  D2C( 228 ) )
cp850tab ~ PUT( "&Otilde;"  ,  D2C( 229 ) )
cp850tab ~ PUT( "&micro;"   ,  D2C( 230 ) )
cp850tab ~ PUT( "&THORN;"   ,  D2C( 231 ) )
cp850tab ~ PUT( "&thorn;"   ,  D2C( 232 ) )
cp850tab ~ PUT( "&Uacute;"  ,  D2C( 233 ) )
cp850tab ~ PUT( "&Ucirc;"   ,  D2C( 234 ) )
cp850tab ~ PUT( "&Ugrave;"  ,  D2C( 235 ) )
cp850tab ~ PUT( "&yacute;"  ,  D2C( 236 ) )
cp850tab ~ PUT( "&Yacute;"  ,  D2C( 237 ) )
cp850tab ~ PUT( "&hibar;"   ,  D2C( 238 ) )
cp850tab ~ PUT( "&acute;"   ,  D2C( 239 ) )
cp850tab ~ PUT( "&plusmn;"  ,  D2C( 241 ) )
cp850tab ~ PUT( "&frac34;"  ,  D2C( 243 ) )
cp850tab ~ PUT( "&para;"    ,  D2C( 244 ) )
cp850tab ~ PUT( "&sect;"    ,  D2C( 245 ) )
cp850tab ~ PUT( "&divide;"  ,  D2C( 246 ) )
cp850tab ~ PUT( "&cedil;"   ,  D2C( 247 ) )
cp850tab ~ PUT( "&deg;"     ,  D2C( 248 ) )
cp850tab ~ PUT( "&uml;"     ,  D2C( 249 ) )
cp850tab ~ PUT( "&middot;"  ,  D2C( 250 ) )
cp850tab ~ PUT( "&sup1;"    ,  D2C( 251 ) )
cp850tab ~ PUT( "&sup3;"    ,  D2C( 252 ) )
cp850tab ~ PUT( "&sup2;"    ,  D2C( 253 ) )
.SGMLEntity ~ setentry( 850, cp850tab ) /* add codepage table to directory */




/* Codepage 437 (US) , almost the same as 850, except ... */

cp437tab = cp850tab ~ copy      /* make a copy of cp850tab */

/* the following entries differ from 850, replace them: */

cp437tab ~ PUT( "&cent;"    ,  D2C( 155 ) )
cp437tab ~ PUT( "&yen;"     ,  D2C( 157 ) )

/* remove entries in code page "437" which do not have a corresponding SGML-entity,
   i.e. leave them verbatim in the text */

cp437tab ~ REMOVE( D2C( 158 )  )
cp437tab ~ REMOVE( D2C( 169 )  )
cp437tab ~ REMOVE( D2C( 181 )  )
cp437tab ~ REMOVE( D2C( 182 )  )
cp437tab ~ REMOVE( D2C( 183 )  )
cp437tab ~ REMOVE( D2C( 184 )  )
cp437tab ~ REMOVE( D2C( 189 )  )
cp437tab ~ REMOVE( D2C( 190 )  )
cp437tab ~ REMOVE( D2C( 198 )  )
cp437tab ~ REMOVE( D2C( 199 )  )
cp437tab ~ REMOVE( D2C( 208 )  )
cp437tab ~ REMOVE( D2C( 209 )  )
cp437tab ~ REMOVE( D2C( 210 )  )
cp437tab ~ REMOVE( D2C( 211 )  )
cp437tab ~ REMOVE( D2C( 212 )  )
cp437tab ~ REMOVE( D2C( 214 )  )
cp437tab ~ REMOVE( D2C( 215 )  )
cp437tab ~ REMOVE( D2C( 216 )  )
cp437tab ~ REMOVE( D2C( 221 )  )
cp437tab ~ REMOVE( D2C( 222 )  )
cp437tab ~ REMOVE( D2C( 224 )  )
cp437tab ~ REMOVE( D2C( 225 )  )
cp437tab ~ REMOVE( D2C( 226 )  )
cp437tab ~ REMOVE( D2C( 227 )  )
cp437tab ~ REMOVE( D2C( 228 )  )
cp437tab ~ REMOVE( D2C( 229 )  )
cp437tab ~ REMOVE( D2C( 231 )  )
cp437tab ~ REMOVE( D2C( 232 )  )
cp437tab ~ REMOVE( D2C( 233 )  )
cp437tab ~ REMOVE( D2C( 234 )  )
cp437tab ~ REMOVE( D2C( 235 )  )
cp437tab ~ REMOVE( D2C( 236 )  )
cp437tab ~ REMOVE( D2C( 237 )  )
cp437tab ~ REMOVE( D2C( 238 )  )
cp437tab ~ REMOVE( D2C( 239 )  )
cp437tab ~ REMOVE( D2C( 243 )  )
cp437tab ~ REMOVE( D2C( 244 )  )
cp437tab ~ REMOVE( D2C( 245 )  )
cp437tab ~ REMOVE( D2C( 247 )  )
cp437tab ~ REMOVE( D2C( 249 )  )
cp437tab ~ REMOVE( D2C( 251 )  )
cp437tab ~ REMOVE( D2C( 252 )  )
.SGMLEntity ~ setentry( 437, cp437tab ) /* add codepage table to directory */



/* define default SGMLEntity-table, if codepage is 0 */

processCodePage = SysQueryProcessCodePage()     /* get code page of current process     */

IF .SGMLEntity ~ hasentry( processCodePage ) THEN       /* use process' CP as default CP*/
   .SGMLEntity ~ setentry( 0, .SGMLEntity ~ entry( processCodePage) )
ELSE                                                    /* not found                    */
   .SGMLEntity ~ setentry( 0, cp850tab )                /* default to code page 850     */




:: REQUIRES nls_util.cmd        /* load national language support */

/* ---------------------------------------------------------------------------
CPFile2SGMLEntity( filename [, [CodePage] [, "Reverse" ] ] )
CPString2SGMLEntity( string [, [CodePage] [, "Reverse" ] ] )

        e.g. ( "h&ouml;her", "850", "Reverse" ) ... change string back, if possible
             SGML2Entity( "d:\aha.html", "850",, "File" )  ... change a file

--------------------------------------------------------------------------- */
/* work on a file                       */
:: ROUTINE CPFile2SGMLEntity    PUBLIC
   USE ARG filename, CodePage, Reverse

   IF \ VAR( "CodePage" ) THEN CodePage = get_nls_default_object() ~ codepage
   IF \ VAR( "Reverse" )  THEN Reverse  = ""

   /* read file into one variable, to treat it as a large string */
   stream = .stream ~ new( filename ) ~~ open       /* open for reading and writing */
   FileString = stream ~ charin( 1, stream ~ query( "Size" ) )
   stream ~ close
   FileString = CPString2SGMLEntity( FileString, CodePage, Reverse )
   stream ~~  open( "WRITE REPLACE" )           /* truncate file                */
   stream ~ charout( FileString, 1 )            /* write string back to file    */
   stream ~ close
   DROP FileString




/* work on a string                     */
:: ROUTINE CPString2SGMLEntity  PUBLIC
   USE ARG string, CodePage, Reverse

   IF \ VAR( "CodePage" ) THEN CodePage = get_nls_default_object() ~ codepage
   IF \ VAR( "Reverse" )  THEN Reverse  = ""

                                /* does given CP exist, if not use default CP   */
   cpTable = .SGMLEntity ~ entry( codepage )    /* try to retrieve CP-2-SGMLentity table  */
   IF cpTable = .nil THEN       /* SGMLentity-table for codepage not found, raise error */
   DO
      SIGNAL ON SYNTAX
      RAISE SYNTAX 40.904 ARRAY ( "CPString2SGMLEntity()", '2 ("CodePage")',,
                                  "supported SGMLEntity codepages", codepage )
   END
                                /* call proc according to third argument        */
   IF ( TRANSLATE( LEFT( Reverse, 1 ) ) = "R" ) THEN
      RETURN sgml2chars( string )       /* reverse      */
   ELSE
      RETURN chars2sgml( string )

/* --------------- procedure ----------------- */
CHARS2SGML :
   tmpSupp = cpTable ~ supplier /* get a supplier from table */
   DO WHILE tmpSupp ~ available
      string = CHANGESTR( tmpSupp ~ index, string, tmpSupp ~ item )         /* translate chars to HTML/SGML entities */
      tmpSupp ~ next
   END
   RETURN string


/* --------------- procedure ----------------- */
SGML2CHARS :
   tmpSupp = cpTable ~ supplier /* get a supplier from table */
   DO WHILE tmpSupp ~ available
      string = CHANGESTR( tmpSupp ~ item, string, tmpSupp ~ index )     /* translate chars to HTML/SGML entities */
      tmpSupp ~ next
   END
   RETURN string


SYNTAX : RAISE PROPAGATE        /* raise error in caller        */




/* ========================================================================= */

/* this class keeps known codepages <---> HTML translation tables at the class level,
   if the class is asked e.g. for codepages 850 or 437, then the table describing them will be
   returned;

   one can add any other table by adding (setentry), replacing (setentry) or removing (setentry)
   it at the class level ...
   (the UNKNOWN class method will forward it to the class object directory-variable )

*/

:: CLASS SGMLEntity           /* PUBLIC */

:: METHOD init CLASS
   EXPOSE cpDirectory

   cpDirectory = .directory ~ new       /* directory to contain codepages */



:: METHOD unknown       CLASS           /* forward messages to .directory */
   EXPOSE cpDirectory
   USE ARG mess_name, mess_args

   FORWARD MESSAGE (mess_name) ARGUMENTS (mess_args) TO ( cpDirectory )

