/*
program:   class_ref.cmd
type:      Object REXX, REXXSAA 6.0
purpose:   allows for defining anchor- and reference-objects with the ability to refer to
           objects, even if the anchors are explicitly produced thereafter (i.e. forward-referencing)
version:   1.0
date:      1997-04-15
changed:   ---

author:    Rony G. Flatscher
           Rony.Flatscher@wu-wien.ac.at
           (Wirtschaftsuniversitaet Wien, University of Economics and Business
           Administration, Vienna/Austria/Europe)
needs:     ---

usage:     call or require & see code

comments:  prepared for the "8th International Rexx Symposium 1997", April 1997, Heidelberg/Germany


All rights reserved and copyrighted 1995-1997 by the author, no guarantee that
it works without errors, etc.  etc.

You are granted the right to use this module under the condition that you don't charge money for this module (as you didn't write
it in the first place) or modules directly derived from this module, that you document the original author (to give appropriate
credit) with the original name of the module and that you make the unaltered, original source-code of this module available on
demand.  If that holds, you may even bundle this module (either in source or compiled form) with commercial software.

If you find an error, please send me the description (preferably a *very* short example); I'll try to fix it and re-release it to
the net.
*/


:: REQUIRES class_rel.cmd       /* RelTab is needed     */
:: REQUIRES routine_usify.cmd

:: ROUTINE pp; RETURN "[" || ARG( 1 ) || "]"

:: ROUTINE sayError
   PARSE ARG tmpString
   .error ~ lineout( "==>" tmpString )
   RETURN


/********************************************************************************/
/* an anchor-object contains various object-variables for storing anchor-objects
   together with the associated (anchored) object with the given prefix; if no
   prefix is given, than the ID-value of the object's class object is used;

   there will be one anchor object created *per* prefix; if explicitly an anchor-
   object is created, using a prefix which already exists, then a new, unique

bla, bla, bla
*/


/* a class for serving as an anchor name factory */
:: CLASS anchor                 PUBLIC

/* ----------------------------------------------- */
:: METHOD init          CLASS
   EXPOSE  AnchorDir

   AnchorDir = .directory ~ new         /* contains used AnchorPrefixes */

/* ----------------------------------------------- */
:: METHOD AnchorDir     ATTRIBUTE CLASS /* directory of all prefixes and
                                                 their anchor objects   */



/* ----------------------------------------------- */
:: METHOD init
   EXPOSE  AnchorPrefix ObjCounter AnchObjTable
   USE ARG AnchorPrefix

   IF ARG( 1, "O" ) THEN                /* generate a system supplied AnchorPrefix */
      AnchorPrefix = "ORX"
   ELSE         /* make sure an AnchorPrefix just contains US-characters and numbers */
      AnchorPrefix = USify( AnchorPrefix )

        /* is there already an anchor object defined, if so return it instead   */
   AnchClassDir = self ~ class ~ AnchorDir
   IF AnchClassDir ~ hasentry( AnchorPrefix ) THEN
      RETURN AnchClassDir ~ entry( AnchorPrefix )

        /* save the prefix and appropriate anchor-object with the class object  */
   AnchClassDir ~ setentry( AnchorPrefix, self )

        /* initialize object variables                          */
   ObjCounter   = 0                     /* reset ObjCounter     */
   AnchObjTable = .relTable  ~ new        /* table like relation, contains objects and
                                           appr. anchor-surrogate string, e.g.
                                           AnchObjTable[ Object ] = surrogate-string      */



/* ----------------------------------------------- */
:: METHOD getAnchorName                 /* generate a new, unique anchor name, i.e.
                                           a USIfied' surrogate-string  */
   EXPOSE AnchorPrefix ObjCounter AnchObjTable
   USE ARG object

   IF ARG( 1, "O" ) THEN RETURN .nil    /* sorry, need an object to work on */

                /* try to get the anchor name, if it exists already */
   anchorName = AnchObjTable[ object ]

                /* create a new anchor name for this object */
   IF anchorName = .nil THEN
   DO
      ObjCounter = ObjCounter + 1       /* increase anchor name ObjCounter      */
      anchorName = AnchorPrefix || "_" || ObjCounter    /* produce anchor name  */

      AnchObjTable[ object ] = anchorName /* associate object with its surrogate-string   */
/*
call sayerror ".anchor: created -> anchorName ==>" pp( anchorName )
*/
   END
/*
else
   call sayerror ".anchor: FOUND ! -> anchorName ==>" pp( anchorName )
*/

   RETURN anchorName            /* return new anchor Name (surrogate-string)    */


/* ----------------------------------------------- */
:: METHOD ObjCounter            /* return # of anchor names already produced */
   EXPOSE ObjCounter
   RETURN ObjCounter

/* ----------------------------------------------- */
:: METHOD AnchObjTable    ATTRIBUTE /* allow access to table of objects<-->surrogate-strings      */

/* -----------------------------------------------------------------------------*/








/* =============================================================================*/
/*
        purpose: allow for generating unique anchor names, using the classId as stem

                 work is done in class methods; thereby relieving the user to give a
                 specific instance

        this class manages references for Object REXX objects, utilizing automatic
        anchor-name production using the class ID as AnchorPrefix, if no explicit
        prefix is given;

        all work is done with class methods !!!
*/

:: CLASS ref                            PUBLIC  /* an Anchor-manager    */

/* ---------------------------------- */
:: METHOD INIT CLASS
   EXPOSE AnchorObjectDir setOfAnchorNames setOfReferences


   AnchorObjectDir = .directory ~ new   /* relates instance to specific prefix  */
   setOfAnchorNames = .set ~ new        /* set of objects for which surrogate-strings were created */
   setOfReferences = .set ~ new         /* set of objects for which surrogate-strings were asked for */

/* ---------------------------------- */
:: METHOD AnchorObjectDir       CLASS   ATTRIBUTE       PRIVATE
:: METHOD setOfAnchorNames      CLASS   ATTRIBUTE /* explicitly created via createReference */
:: METHOD setOfReferences       CLASS   ATTRIBUTE /* explicitly asked for via getReference  */


/* ---------------------------------- */
/* create a new object for a new class          */
:: METHOD getAnchorObject       CLASS   PRIVATE
   EXPOSE  AnchorObjectDir
   USE ARG anObject, prefix

   IF ARG( 2, "O" ) THEN
      prefix = anObject ~ class ~ id            /* prefix omitted               */

   tmpAnchObject = AnchorObjectDir ~ entry( prefix )    /* get anchor object    */

   IF tmpAnchObject = .nil THEN                 /* no AnchorObject as of yet    */
   DO
      tmpAnchObject = .anchor ~ new( prefix )   /* create new AnchorObject      */
      AnchorObjectDir ~ setentry( prefix, tmpAnchObject ) /* save anchor object */
   END

   RETURN tmpAnchObject


/* ---------------------------------- */
:: METHOD Reference  CLASS           /* retrieve a reference name, else create it */

   USE ARG anObject, prefix

   IF ARG( 2, "O" )     THEN            /* prefix omitted               */
      AnchorObject = self ~ getAnchorObject( anObject )
   ELSE
      AnchorObject = self ~ getAnchorObject( anObject, prefix )

   /* now get appropriate anchor (i.e. surrogate-string)        */
   anchorName = AnchorObject ~ getAnchorName( anObject )   /* get anchor name */

   RETURN anchorName


/* ---------------------------------- */
:: METHOD createReference    CLASS      /* keeps track of explicitly produced references */
   EXPOSE setOfAnchorNames

   setOfAnchorNames ~ put( ARG( 1 ) )   /* save object in set   */
   FORWARD MESSAGE "Reference"          /* let method Reference do the work     */

/* ---------------------------------- */
:: METHOD getReference       CLASS      /* keeps track of explicitly queried references */
   EXPOSE setOfReferences

   setOfReferences ~ put( ARG( 1 ) )    /* save object in set   */
   FORWARD MESSAGE "Reference"          /* let method Reference do the work     */

/* ---------------------------------- */
:: METHOD SayStatistics      CLASS      /* tells, if name-set <> reference-set  */
   EXPOSE setOfReferences setOfAnchorNames

   tmpString = "class" pp( self ~ id )
   CALL SayError tmpString "references created explicitly:" pp( setOfAnchorNames ~ items ),
                 "references used:" pp( setOfReferences ~ items )

   notReferenced  = setOfAnchorNames ~ DIFFERENCE( setOfReferences ) ~ items
   notExplCreated = setOfReferences ~ DIFFERENCE( setOfAnchorNames ) ~ items

   IF notReferenced > 0 THEN
      CALL SayError LEFT( "", LENGTH( tmpString ) ) pp( notReferenced ),
           "object-references were created, but never referred to!"

   IF notExplCreated > 0 THEN
      CALL SayError LEFT( "", LENGTH( tmpString ) ) pp( notExplCreated ),
           "object-references were created implicitly."


/* -----------------------------------------------------------------------------*/
/********************************************************************************/
