/*
   Module for supplying basic Is*-routines

program:   Is_Util.cmd
type:      Object REXX, REXXSAA 6.0
purpose:   implements routines and methods for testing, e.g. IsClassObject, IsDescendedFrom,
           IsA. IsInstanceOf, IsA2 (cf. comments in code)
version:   1.0.1
date:      1997-04-15
changed:   1997-06-27, ---rgf, removed pp() which should not have been in here anyway

author:    Rony G. Flatscher
           Rony.Flatscher@wu-wien.ac.at
           (Wirtschaftsuniversitaet Wien, University of Economics and Business
           Administration, Vienna/Austria/Europe)

needs:     ---

usage:     call or require this module

comments:  prepared for the "8th International Rexx Symposium 1997,
           sponsored by the Rexx Language Association"

All rights reserved and copyrighted 1997 by the author,
no guarantee that it works without errors, etc. etc.

You are granted the right to use this module under the condition that you don't charge money for this module (as you didn't write
it in the first place) or modules directly derived from this module, that you document the original author (to give appropriate
credit) with the original name of the module and that you make the unaltered, original source-code of this module available on
demand.  If that holds, you may even bundle this module (either in source or compiled form) with commercial software.

If you find an error, please send me the description (preferably a *very* short example);
I'll try to fix it and re-release it to the net.
*/



:: ROUTINE get_methods_FROM_is_util PUBLIC  /* return the method-directory  */
   RETURN .methods


/* ANSI-Vorschlag von rgf, 96-11 */


/* <----------          -----------> */
/* floating method for determining whether self is a class object */
:: METHOD IsClassObject
   RETURN IsClassObject( self )


/******************************************************************************/
/*                                                                            */
/* name:    IsClassObject( object )                                           */
/*                                                                            */
/* purpose: determines whether argument is a class object                     */
/*                                                                            */
/*                                                                            */
/* returns: .true if argument is a class object, .false else                  */
/*                                                                            */
/* remarks: ---                                                               */
/*                                                                            */
/*          rgf, 96-11-15                                                     */

/* determine whether an object is a class object, PUBLIC ROUTINE      */
:: ROUTINE IsClassObject      PUBLIC
   USE ARG instance

   RETURN DetIsClassObject( instance ~ class )

/* determine class-object property:
   a class object is one which belongs to a (sub)class which
   is defined on its own terms, i.e. its metaclass is the class itself;

   returns .true if instance is a class object, .false else
*/
DetIsClassObject : PROCEDURE          /* recursively check    */
   USE ARG class

   IF class = .object THEN RETURN .false
   IF class = class ~ metaclass THEN RETURN .true
   RETURN DetIsClassObject( class ~ SUPERCLASSES[ 1 ] )
/******************************************************************************/






/* <----------          -----------> */
/* floating method for determining whether self is a class object */
:: METHOD IsDescendedFrom
   USE ARG SuperClass

   RETURN IsDescendedFrom( self, SuperClass )


/******************************************************************************/
/*                                                                            */
/* name:    IsDescendedFrom( ClassObject1, ClassObject2 )                     */
/*                                                                            */
/* purpose: generic test, whether first argument is either of the same class  */
/*          or a subclass of the second argument's class                      */
/*                                                                            */
/* returns: .true if first argument (a class object) is the same as the       */
/*          second argument (a class object) or one of its subclasses         */
/*                                                                            */
/* remarks: modelled after "somDescendedFrom"                                 */
/*                                                                            */
/* needs:   ROUTINE IsDescendedFrom                                           */
/*          rgf, 96-11-16                                                     */

:: ROUTINE IsDescendedFrom                   PUBLIC
   USE ARG ClassO1, ClassO2

   IF \ IsClassObject( ClassO1 ) THEN   /* 1st argument not a class object !  */
   DO
      SIGNAL ON SYNTAX
      RAISE SYNTAX 93.914 ARRAY ( "# 1", "the class objects", ClassO1 ~ string )
   END

   IF \ IsClassObject( ClassO2 ) THEN   /* 2nd argument not a class object !  */
   DO
      SIGNAL ON SYNTAX
      RAISE SYNTAX 93.914 ARRAY ( "# 2", "the class objects", ClassO2 ~ string )
   END

   RETURN DetIsDescendedFrom( ClassO1, ClassO2 )

SYNTAX :
   RAISE PROPAGATE              /* show caller's error position */

DetIsDescendedFrom : PROCEDURE
   USE ARG ClassO1, ClassO2

   IF ClassO1 = ClassO2 THEN RETURN .true

   SCArray = ClassO1 ~ SUPERCLASSES        /* get superclasses     */
   DO tmpClass OVER SCArray             /* test immediate superclasses  */
      IF tmpClass = ClassO2 THEN RETURN .true
   END

   /* not found, maybe one of the superClasses preceding the immediate ones ? */
   DO tmpClass OVER SCArray             /* test immediate superclasses  */
      IF DetIsDescendedFrom( tmpClass, ClassO2 ) THEN RETURN .true
   END

   RETURN .false
/******************************************************************************/




/* <----------          -----------> */
/* floating method for determining whether self is an instance of class object*/
:: METHOD IsA
   USE ARG SuperClass

   RETURN IsA( self, SuperClass )


/******************************************************************************/
/*                                                                            */
/* name:    IsA( object, class object )                                       */
/*                                                                            */
/* purpose: generic test, whether first argument is either of the same class  */
/*          or a subclass of the second argument's class                      */
/*                                                                            */
/* returns: .true if first argument is either of the same class or a subclass */
/*          of the second argument's class, .false else                       */
/*                                                                            */
/* remarks: first argument's class object is tested against the second        */
/*          argument, which must be a class object;                           */
/*          modelled after "somIsA"                                           */
/*                                                                            */
/* needs:   ROUTINE IsClassObject                                             */
/*          rgf, 96-11-15                                                     */

:: ROUTINE IsA                   PUBLIC
   USE ARG Object1, ClassObject2


   IF \ IsClassObject( ClassObject2 ) THEN
   DO
      SIGNAL ON SYNTAX
      RAISE SYNTAX 93.914 ARRAY( "# 2", "[the class objects]",,
                                 ClassObject2 ~ string )
   END

   RETURN DetIsA( Object1 ~ class, ClassObject2 )

SYNTAX :
   RAISE PROPAGATE              /* show caller's error position */

DetIsA : PROCEDURE
   USE ARG ClassObject1, SuperClass

   IF ClassObject1 = SuperClass THEN RETURN .true

   SCArray = ClassObject1 ~ SUPERCLASSES       /* get superclasses      */
   DO tmpClass OVER SCArray             /* test immediate superclasses  */
      IF tmpClass = SuperClass THEN RETURN .true
   END

   /* not found, maybe one of the superclasses preceding the immediate ones ? */
   DO tmpClass OVER SCArray             /* test immediate superclasses  */
      IF DetIsA( tmpClass, SuperClass ) THEN RETURN .true
   END

   RETURN .false
/******************************************************************************/






/* <----------          -----------> */
/* floating method for determining whether self is an instance of class object*/
:: METHOD IsInstanceOf
   USE ARG Class

   RETURN IsInstanceOf( self, Class )


/******************************************************************************/
/*                                                                            */
/* name:    IsInstanceOf( object, class object )                              */
/*                                                                            */
/* purpose: generic test, whether first argument is an instance of second     */
/*          argument which is a class object                                  */
/*                                                                            */
/* returns: .true if first argument is instance of second argument (a         */
/*          class object)                                                     */
/*                                                                            */
/* remarks: modelled after "somInstanceOf"                                    */
/*                                                                            */
/*          rgf, 96-11-16                                                     */

:: ROUTINE IsInstanceOf                   PUBLIC
   USE ARG Object, Class

   RETURN ( Object ~ class = Class )
/******************************************************************************/





/* <----------          -----------> */
/* floating method for determining whether self is a class object */
:: METHOD IsA2
   USE ARG SuperClass

   RETURN IsA2( self, SuperClass )


/******************************************************************************/
/*                                                                            */
/* name:    IsA2( object, class object )                                      */
/*                                                                            */
/* purpose: generic test, whether first argument is either of the same class  */
/*          or a subclass of the second argument                              */
/*                                                                            */
/* returns: .true if first argument is either of the same class or a subclass */
/*          of the second argument's class, .false else                       */
/*                                                                            */
/* remarks: this is a "relaxed" version, folding e.g. "somIsA" and            */
/*          "somDescendedFrom" into one function;                             */
/*          each argument is tested whether it is a class object, if not      */
/*          its class object is used in the test                              */
/*                                                                            */
/* needs:   ROUTINE IsClassObject                                             */
/*          rgf, 96-11-15                                                     */

:: ROUTINE IsA2                   PUBLIC
   USE ARG ClassObject1, ClassObject2

   IF \ IsClassObject( ClassObject1 ) THEN ClassObject1 = ClassObject1 ~ class
   IF \ IsClassObject( ClassObject2 ) THEN ClassObject2 = ClassObject2 ~ class

   RETURN DetIsA2( ClassObject1, ClassObject2 )


DetIsA2 : PROCEDURE
   USE ARG ClassObject1, SuperClass

   IF ClassObject1 = SuperClass THEN RETURN .true

   SCArray = ClassObject1 ~ SUPERCLASSES       /* get superclasses      */
   DO tmpClass OVER SCArray             /* test immediate superclasses  */
      IF tmpClass = SuperClass THEN RETURN .true
   END

   /* not found, maybe one of the superclasses preceding the immediate ones ? */
   DO tmpClass OVER SCArray             /* test immediate superclasses  */
      IF DetIsA2( tmpClass, SuperClass ) THEN RETURN .true
   END

   RETURN .false
/******************************************************************************/

