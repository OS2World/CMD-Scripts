/* 
program:   class_rel.cmd
type:      Object REXX, REXXSAA 6.0
purpose:   defines specialized classes of .relation, including a tandem "anchor/ref" 
           (allowing for forward-referencing)
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

If you find an error, please send me the description (preferably a *very* short example);
I'll try to fix it and re-release it to the net.
*/



/********************************************************************************/
/* table-like (one entry per index only), but enhanced with .relation's methods */
/* injektiv, S1 -> S2                                                           */

:: CLASS RelTable       SUBCLASS Relation       PUBLIC
/* ----------------------------------------------- */
:: METHOD "[]="                 /* override             */

   FORWARD MESSAGE ( "PUT" )    /* let PUT do the work  */

/* ----------------------------------------------- */
:: METHOD "PUT"                 /* override             */
   USE ARG item , index

   self ~ remove( index )       /* remove index & associated item       */

   FORWARD CLASS (super)        /* now do the PUT !     */
/********************************************************************************/








/********************************************************************************/
/* one item may be associated with one index only,
   and one index is associated with one item only */
/*
    bijectiv, S1 -> S2  <==> S2 -> S1
*/
:: CLASS RelBijective   SUBCLASS Relation       PUBLIC
/* ----------------------------------------------- */
:: METHOD "[]="                 /* override             */
   FORWARD MESSAGE ( "PUT" )    /* let PUT do the work  */

/* ----------------------------------------------- */
:: METHOD  PUT                  /* override */
   USE ARG item , index

   self ~ remove( index )       /* remove index         */

                                /* remove item (with another index) */
   self ~ removeitem( item , self ~ index( item  ) )   

   FORWARD CLASS (super)        /* let super do the PUT ! */
/* -----------------------------------------------------------------------------*/
/********************************************************************************/







/********************************************************************************/
/* item and index may be exchanged, i.e. a item  for an index or item may just exist *once* either
   as an item or as an index ! */
/*
    bijektiv, S1 -> S2  == S2 -> S1; S1 geschnitten S2 = {}
*/

:: CLASS RelBijectiveSet   SUBCLASS Relation       PUBLIC
/* ----------------------------------------------- */
:: METHOD "[]="                 /* override             */
   FORWARD MESSAGE ( "PUT" )    /* let PUT do the work  */

/* ----------------------------------------------- */
:: METHOD PUT                   /* override             */
   USE ARG item , index

   IF item = index THEN         /* don't allow one element to be in both sets */
      RETURN
                                /* remove existing entries for item/index     */
   FORWARD MESSAGE ( "removeitem" ) CONTINUE    
   FORWARD CLASS (super)        /* now do the PUT !     */

/* ----------------------------------------------- */
:: METHOD REMOVEITEM            /* override */
   USE ARG item , index

   indexItem1 = self ~ remove( index )  /* remove index & associated item             */

                        /* remove index, if one of item  of new item exists   */
   indexItem2 = self ~ remove( item  )  

   /* now the other way around */
                        /* remove item, if one exists of the same item  of an index */
   itemItem1 = self ~ removeitem : super( index, self ~ index( index ) )
                        /* remove index based on item                               */
   itemItem2 = self ~ removeitem : super( item,  self ~ index( item  ) )

   tmpSet = .set ~ new
   IF indexItem1 <> .nil THEN tmpSet ~ put( indexItem1 )
   IF indexItem2 <> .nil THEN tmpSet ~ put( indexItem2 )
   IF itemItem1  <> .nil THEN tmpSet ~ put( itemItem1 )
   IF itemItem2  <> .nil THEN tmpSet ~ put( itemItem2 )

   RETURN tmpSet                        /* returns the set of removed items */



/* ----------------------------------------------- */
:: METHOD HASITEM               /* override */
   USE ARG item , index

   IF self ~ hasitem : super( item, index ) THEN RETURN .true
                                /* now the other way round      */
   RETURN self ~ hasitem : super( index, item )   


/* -----------------------------------------------------------------------------*/
/********************************************************************************/







/********************************************************************************/
/* .directory-like, because of enhancing with SETENTRY, ENTRY, HASENTRY */

:: CLASS RelDir         MIXINCLASS Relation     PUBLIC
/* ----------------------------------------------- */
:: METHOD  ENTRY
   USE ARG name
                                /* return an item associated with name */
   RETURN self ~ at( TRANSLATE( name ))

/* ----------------------------------------------- */
:: METHOD  HASENTRY
   USE ARG name
                                /* return an item associated with name */
   RETURN self ~ hasindex( TRANSLATE( name ))


/* ----------------------------------------------- */
:: METHOD  SETENTRY
   USE ARG name, value          /* index == name                        */

                                /* use the uppercase version of the string      */
   self ~ PUT( value, TRANSLATE( name ))

/* ----------------------------------------------- */
:: METHOD  UNKNOWN                      /* define an unknown method     */
   USE ARG messageName, messageArgs

                                /* setentry method ?                    */
   IF RIGHT( messageName, 1 ) = "=" THEN
   DO
                                /* remove trailing "="                  */
      index = LEFT( messageName, LENGTH( messageName ) - 1 )    
      FORWARD MESSAGE ( "SETENTRY" ) ARRAY ( index, messageArgs[ 1 ] )  
   END
   ELSE
      FORWARD MESSAGE ( "ENTRY" )    ARRAY ( messageName )

/* -----------------------------------------------------------------------------*/
/********************************************************************************/



/* --->
/* using multiple inheritance to add relDir's methods to testRel in addition to .Relation */
:: class testRel subclass RelBijectiveSet PUBLIC INHERIT relDir
<--- */


