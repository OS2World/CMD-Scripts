/*
program:   nls_util.cmd
type:      Object REXX, REXXSAA 6.0
purpose:   implements functions and classes for easier dealing with NLS-support
version:   1.0.1
date:      1997-04-15
changed:   1997-06-26, rgf, changed a bug in NLS' SETENTRY and INIT methods
           1997-07-16, rgf, changed instance method "DUMP" of NLS to output
                       to the .error object.

author:    Rony G. Flatscher
           Rony.Flatscher@wu-wien.ac.at
           (Wirtschaftsuniversitaet Wien, University of Economics and Business
           Administration, Vienna/Austria/Europe)
needs:     Test_Util-module

usage:     see program :)

comments:  prepared for the "8th International Rexx Symposium 1997", April 1997, Heidelberg/Germany

All rights reserved and copyrighted 1997 by the author,
no guarantee that it works without errors, etc. etc.

You are granted the right to use this module under the condition that you don't charge money for this module (as you didn't write
it in the first place) or modules directly derived from this module, that you document the original author (to give appropriate
credit) with the original name of the module and that you make the unaltered, original source-code of this module available on
demand.  If that holds, you may even bundle this module (either in source or compiled form) with commercial software.

If you find an error, please send me the description (preferably a *very* short example);
I'll try to fix it and re-release it to the net.
*/


/* create the default NLS-object, using default country and actual codepage */
CALL set_nls_default_object     /* to be stored with the class object   */



:: REQUIRES is_util.cmd         /* for IsA() routine    */


:: ROUTINE GET_NLS_DEFAULT_OBJECT       PUBLIC  /* return the default NLS-object */
   RETURN .nls ~ default_NLS

:: ROUTINE SET_NLS_DEFAULT_OBJECT       PUBLIC  /* set the default NLS-object   */
   USE ARG country, codepage

   IF IsA( ARG( 1 ), .nls ) THEN        /* first argument not a country, but a NLS-object?*/
   DO
      .nls ~ default_NLS = ARG( 1 )     /* if so, use it as the default object          */
   END
   ELSE
   DO
      IF \VAR( "country" ) | country = .nil | "COUNTRY" = country
      THEN country = 0                  /* use default country  */
      ELSE country = STRIP( country )

      IF \VAR( "codepage" ) | codepage = .nil | "CODEPAGE" = codepage
      THEN codepage = 0                 /* use default codepage */
      ELSE codepage = STRIP( codepage )

      .nls ~ default_NLS = .nls ~ new( country , codePage )
   END

   RETURN .nls ~ default_NLS


:: ROUTINE NLS_UPPER                    PUBLIC          /* do a NLS uppercase */
   USE ARG string
   RETURN .nls ~ default_NLS ~ nls_upper( string )


:: ROUTINE NLS_LOWER                    PUBLIC          /* do a NLS lowercase */
   USE ARG string
   RETURN .nls ~ default_NLS ~ nls_lower( string )


:: ROUTINE NLS_COMPARE                  PUBLIC          /* do a NLS compare */
   USE ARG string1, string2
   RETURN .nls ~ default_NLS ~ nls_compare( string1, string2 )


:: ROUTINE NLS_COLLATE                  PUBLIC          /* translate string into NLS collate */
   USE ARG string
   RETURN .nls ~ default_NLS ~ nls_collate( string )





/* ========================================================================= */
:: CLASS NLS            PUBLIC

/* -------------------------------- class methods ------------------------- */
:: METHOD INIT CLASS
   EXPOSE nlsDirectory default_NLS

   nlsDirectory = .directory ~ new      /* directory to contain NLS-objects     */
   default_NLS  = .nil                  /* set default NLS-object to .nil       */

:: METHOD default_NLS CLASS ATTRIBUTE   /* may contain an NLS-object            */

:: METHOD supplier CLASS                /* return a supplier of NLS-objects created so far      */
   EXPOSE nlsDirectory

   RETURN nlsDirectory ~ supplier

:: METHOD entry CLASS                   /* look and return NLS object, if available */
   EXPOSE nlsDirectory
   USE ARG country, codepage

   IF \VAR( "country" ) | country = .nil | "COUNTRY" = country
   THEN country = 0
   ELSE country = STRIP( country )

   IF \VAR( "codepage" ) | codepage = .nil | "CODEPAGE" = codepage
   THEN codepage = 0
   ELSE codepage = STRIP( codepage )

   tmpKey = country codepage
   RETURN nlsDirectory ~ entry( tmpKey )


:: METHOD hasentry CLASS                /* query for the existence of a specific NLS-object     */
   EXPOSE nlsDirectory
   USE ARG country, codepage

   IF \VAR( "country" ) | country = .nil | "COUNTRY" = country
   THEN country = 0
   ELSE country = STRIP( country )

   IF \VAR( "codepage" ) | codepage = .nil | "CODEPAGE" = codepage
   THEN codepage = 0
   ELSE codepage = STRIP( codepage )

   tmpKey = country codepage
   RETURN nlsDirectory ~ entry( tmpKey )


:: METHOD setentry CLASS                /* set a new NLS-object, if it does not exist yet       */
   EXPOSE nlsDirectory
   USE ARG country, codepage, object

   IF \VAR( "country" ) | country = .nil | "COUNTRY" = country
   THEN country = 0
   ELSE country = STRIP( country )

   IF \VAR( "codepage" ) | codepage = .nil | "CODEPAGE" = codepage
   THEN codepage = 0
   ELSE codepage = STRIP( codepage )

   tmpKey = country codepage

   tmpObject = nlsDirectory ~ entry( tmpKey )
   IF tmpObject = .nil THEN             /* no entry yet         */
   DO
      IF VAR( "object" ) THEN           /* object given ?       */
      DO
         nlsDirectory ~ setentry( tmpKey, object )
         RETURN object
      END
      RETURN .nil
   END
   ELSE                                 /* entry available      */
   DO
      IF \ VAR( "object" ) THEN         /* no object given, hence delete old object     */
         nlsDirectory ~ setentry( tmpKey )      /* remove entry                 */
      ELSE
         nlsDirectory ~ setentry( tmpKey, object )

      RETURN tmpObject
   END

/* -------------------------------- instance methods ---------------------- */
:: METHOD INIT
   EXPOSE country codepage lowercase uppercase collating_table coll_lower coll_upper
   USE ARG country, codepage


   IF \VAR( "country" )  | country = .nil  | "COUNTRY" = country   THEN
      country = 0

   IF \VAR( "codepage" ) | codepage = .nil | "CODEPAGE" = codepage  THEN
      codepage = 0


   SIGNAL ON SYNTAX     /* build translate to uppercase tables, if wrong combination
                           of country and codepage a syntax error is raised     */
   collating_table = SysGetCollate( country, codepage )

   tmpObj = self ~ class ~ setentry( codepage, country, self )

   IF tmpObj <> self THEN       /* already set-up, return       */
   DO
      RETURN tmpObj
   END


   /* determine differing characters for plain lower/uppercase translation */
   lowercase = ""
   uppercase = ""

   all_chars = XRANGE( "0"x, "ff"x)     /* create all 256 Bytes */

   tmp_up = SysMapCase( all_chars, country, codepage )         /* build translate to uppercase tables */
   DO i = 1 TO LENGTH( all_chars )
      low   = SUBSTR( all_chars, i, 1 )
      upper = SUBSTR( tmp_up,    i, 1 )

      IF low <> upper THEN
      DO
         lowercase = lowercase || low
         uppercase = uppercase || upper
      END
   END


   /* determine differing characters for collating sequence */
   coll_lower = ""
   coll_upper = ""


   DO i = 1 TO LENGTH( all_chars )
      low   = SUBSTR( all_chars,       i, 1 )
      upper = SUBSTR( collating_table, i, 1 )

      IF low <> upper THEN
      DO
         coll_lower = coll_lower || low
         coll_upper = coll_upper || upper
      END
   END
   RETURN self

        /* illegal combination of country and codepage in SysGetCollate() */
SYNTAX : RAISE PROPAGATE        /* raise SYNTAX error in caller */


:: METHOD codepage                      ATTRIBUTE
:: METHOD coll_lower                    ATTRIBUTE
:: METHOD coll_upper                    ATTRIBUTE
:: METHOD collating_table               ATTRIBUTE
:: METHOD country                       ATTRIBUTE
:: METHOD lowercase                     ATTRIBUTE
:: METHOD uppercase                     ATTRIBUTE

:: METHOD makestring                    /* a string representation of a NLS-object      */
   EXPOSE country codepage

   RETURN "a" self ~ class ~ id  "[country=" || country || ",codepage=" || codepage || "]"

:: METHOD nls_upper                     /* no a NLS uppercase */
   EXPOSE uppercase lowercase
   USE ARG string

   RETURN TRANSLATE( string, uppercase, lowercase )

:: METHOD nls_lower                     /* do a NLS lowercase */
   EXPOSE uppercase lowercase
   USE ARG string

   RETURN TRANSLATE( string, lowercase, uppercase )


:: METHOD nls_compare                   /* do a case sensitive NLS-compare */
   EXPOSE country codepage
   USE ARG string1, string2

        /*  uses Collating Sequence (relatively slow, because of external function call)

            string1 < string2 ... -1
            string1 = string2 ...  0
            string1 > string2 ...  1
        */
   RETURN SysNationalLanguageCompare( string1, string2, country, codepage )

:: METHOD nls_collate                   /* translate string with collating table */
   EXPOSE coll_upper coll_lower
   USE ARG string

   RETURN TRANSLATE( string, coll_upper, coll_lower )


:: METHOD dump                          /* show effects on lower/uppercase and collating sequence       */

    .error ~ LINEOUT(  "NLS-object:" )
    .error ~ LINEOUT()
    .error ~ LINEOUT(  "   country:" pp( self ~ country ) "codepage:" pp( self ~ codepage ) )
    .error ~ LINEOUT() 
    .error ~ LINEOUT(  "lowercase:" pp( self ~ lowercase ) )
    .error ~ LINEOUT(  "uppercase:" pp( self ~ uppercase ) )
    .error ~ LINEOUT()

    .error ~ LINEOUT(  "effect of collating table:" )
    .error ~ LINEOUT()
   start  = 1
   length = 60
   coll_length = LENGTH( self ~ coll_lower )
   DO WHILE start < coll_length
      start = RIGHT( start, 3)
      end   = RIGHT( MIN( coll_length, start + length - 1 ), 3 )
       .error ~ LINEOUT(  " low ("start"-"end"):" pp( STRIP( SUBSTR( self ~ coll_lower, start, length ) ) ) )
       .error ~ LINEOUT(  "  up ("start"-"end"):" pp( STRIP( SUBSTR( self ~ coll_upper, start, length ) ) ) )
       .error ~ LINEOUT()
      start = start + length
   END
   RETURN

PP : PROCEDURE                          /* cheap :) pretty-print        */
   RETURN "[" || ARG( 1 ) || "]"


