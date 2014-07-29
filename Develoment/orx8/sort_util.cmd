/* 
program:   sort_util.cmd
type:      Object REXX, REXXSAA 6.0
purpose:   some sort routines on different types of objects, doing NLS-comparisons
version:   1.0
date:      1997-04-11
changed:   ---

author:    Rony G. Flatscher
           Rony.Flatscher@wu-wien.ac.at
           (Wirtschaftsuniversitaet Wien, University of Economics and Business
           Administration, Vienna/Austria/Europe)
needs:     ---

usage:     call or require 

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


:: REQUIRES nls_util.cmd                /* requires NLS-support         */




/******************************************************************************/
/*                                                                            */
/* name:    sortStem( stem. )                                                 */
/*                                                                            */
/* purpose: sorts passed in stem in place                                     */
/*                                                                            */
/* returns: ---                                                               */
/*                                                                            */
/* remarks: this is supposedly derived from one of Knuth's algorithms         */
/*                                                                            */
/*          - expected layout of stem (as with some SysFunctions):            */
/*                                                                            */
/*            stem.0 ... contains total number of entries in stem             */
/*            stem.i ... where i > 0 and i <= stem.0                          */
/*                                                                            */
/*            stem-array will get sorted in place (no stem.-copy!)            */
/*                                                                            */
/* created: rgf, 95-09-29; 97-04-15                                           */

:: ROUTINE sortStem              PUBLIC
   USE ARG stem. , option

   bDesc = ( TRANSLATE( LEFT( option, 1 ) ) = "D" )     /* sort descending ?    */

   M = 1                           /* define M for passes           */
   DO WHILE (9 * M + 4) < stem.0
      M = M * 3 + 1
   END

   DO WHILE M > 0                  /* sort stem                     */
      K = stem.0 - M
      DO J = 1 TO K
         Q = J
         DO WHILE Q > 0
            L = Q + M
            /* make comparisons case-independent                    */
            IF bDesc THEN       /* descending sort              */        
            DO
               IF NLS_COLLATE( stem.Q )   > NLS_COLLATE( stem.L ) THEN LEAVE
            END
            ELSE 
            DO
               IF NLS_COLLATE( stem.Q ) <<= NLS_COLLATE( stem.L ) THEN LEAVE
            END


            tmp    = stem.Q        /* switch elements               */
            stem.Q = stem.L
            stem.L = tmp
            Q = Q - M
         END
      END
      M = M % 3
   END

   RETURN 
/******************************************************************************/






/******************************************************************************/
/*                                                                            */
/* name:    sort( CollObj [, "Descending" ] )                                 */
/*                                                                            */
/* purpose: creates a *single* array object from a collection object and      */
/*          sorts it by the index-value, which gets put into the single       */
/*          dimensioned array                                                 */
/*                                                                            */
/* returns: returns a *new*, sorted array-object                              */
/*                                                                            */
/* remarks: if object is not of type .array and array will be created via     */
/*          the MAKEARRAY message, else a copy of the passed in array object  */
/*          will be produced; the new .array object gets sorted via           */
/*          sortArray                                                         */
/*                                                                            */
/* needs:   routine sortArray()                                               */
/*                                                                            */
/* created: rgf, 95-09-15; 97-04-15                                           */

:: ROUTINE SORT                  PUBLIC
   USE ARG CollObj, option


/* old, unsafe way
   IF CollObj~class~id <> "Array" THEN
*/

   IF IsA( CollObj, .array ) THEN             /* safer, new way             */
   DO
      workArray = CollObj ~ copy              /* it's an array, create a copy */
   END
   ELSE
   DO
      /* if a "stem.-array" in hand, assign it to a real array  */
      IF IsA( CollObj, .stem ) & DATATYPE( CollObj[ 0 ], "W" ) THEN   
      DO
         workArray = .array ~ new
         DO i = 1 TO CollObj[ 0 ]
            workArray[ i ] = CollObj[ i ]
         END
      END


      ELSE IF CollObj ~ HasMethod( "MAKEARRAY" ) THEN   /* use MAKEARRAY      */
      DO
         workArray = CollObj ~ makearray
      END

      ELSE                                      /* build array by "hand"      */
      DO
         IF IsA(CollObj, .supplier) THEN        /* take care of a supplier    */
         DO
            i = 1
            workArray = .array ~ new
            DO WHILE CollObj ~ available
               workArray[i] = CollObj ~ index
               CollObj~next
               i = i + 1
            END
         END
         ELSE                           /* use OVER to assemble from keys     */
         DO
            i = 1
            workArray = .array ~ new
            DO item OVER CollObj
               workArray[i] = item
               i = i + 1
            END
         END
      END
   END

   RETURN sortArray( workArray, option )        /* do the actual sort   */



/******************************************************************************/



/******************************************************************************/
/*                                                                            */
/* name:    sortArray( array [, "Descending" ] )                              */
/*                                                                            */
/* purpose: sorts passed in single-dimensioned array                          */
/*                                                                            */
/* returns: returns the sorted array                                          */
/*                                                                            */
/* remarks: this is supposedly derived from one of Knuth's algorithms         */
/*                                                                            */
/* created: rgf, 95-09-15; 97-04-15                                           */

:: ROUTINE sortArray             PUBLIC
   USE ARG array, option

   bDesc = ( TRANSLATE( LEFT( option, 1 ) ) = "D" )     /* sort descending ?    */

   M = 1                           /* define M for passes       */
   DO WHILE (9 * M + 4) < array~items
      M = M * 3 + 1
   END

   DO WHILE M > 0                  /* sort stem                 */
      K = array~items - M
      DO J = 1 TO K
         Q = J
         DO WHILE Q > 0
            L = Q + M
            /* make comparisons case-independent                */
            IF bDesc THEN       /* descending sort              */        
            DO
               IF NLS_COLLATE( array[Q] )   > NLS_COLLATE( array[L] ) THEN LEAVE
            END
            ELSE 
            DO
               IF NLS_COLLATE( array[Q] ) <<= NLS_COLLATE( array[L] ) THEN LEAVE
            END

            tmp      = array[Q]    /* switch elements           */
            array[Q] = array[L]
            array[L] = tmp
            Q = Q - M
         END
      END
      M = M % 3
   END

   RETURN array
/******************************************************************************/




/******************************************************************************/
/*                                                                            */
/* name:    sortCollection( collection [, [message] [, "Descending" ] ] )     */
/*                                                                            */
/* purpose: sorts objects in "collection" (retrieved via SUPPLIER), returns   */
/*          a sorted, two-dimensional array; the sort-keys are retrieved      */
/*          directly from the stored object                                   */
/*                                                                            */
/*          First the object of the iterated collection gets the "message"    */
/*          sent, the result is stored at subscript #1, the object itself     */
/*          is stored at subscript #2 in the resulting array, then a sort     */
/*          by subscript #1 is undertaken and the array returned.             */
/*                                                                            */
/*          "Message" may be a *plain string* denominating the message name,  */
/*          *a message object* or an *array* with the following layout:       */
/*              message[ 1 ] = name of the message                            */
/*              message[ 2 ] = optional; if given it contains an array        */
/*                             with all the arguments that are needed         */
/*                             for executing the message                      */
/*                                                                            */
/*          If optional "message" is left out, the key (index) is used as     */
/*          is, if it is a string, else Object's "STRING"-message is sent     */
/*          to the key (index) part of the collection.                        */
/*                                                                            */
/* returns: returns 2-dimensional array, sorted after keys stored in          */
/*          subscript #1 and the object being stored in subscript #2          */
/*                                                                            */
/* remarks: the sort routine is supposedly derived from one of Knuth's        */
/*          algorithms                                                        */
/*                                                                            */
/*          if no "message" is given, then in the case of a                   */
/*                                                                            */
/*          - two-dimensional array a copy of it gets directly sorted by      */
/*            subscript # 1                                                   */
/*                                                                            */
/*          - stem, a two-dimensional array is built, where the stem-index    */
/*            gets stored at subscript #1 and the associated object at #2     */
/*                                                                            */
/*          else a STRING-message is sent to the object and the result        */
/*          gets stored at subscript #1 (usually OBJECTNAME)                  */
/*                                                                            */
/* created: rgf, 96-09-09; 97-04-15                                           */

:: ROUTINE sortCollection        PUBLIC
   USE ARG collection, msgArg, option 

   SIGNAL ON SYNTAX

   IF \ VAR( "msgArg" ) THEN    /* no message-argument supplied */
   DO
      MsgObj     = .nil         /* no message-object available  */
   END
   ELSE
   DO           /* create the desired message object to be sent to the index-object */
      IF IsA( msgArg, .message ) THEN   /* a message object ?           */
      DO
         MsgObj = msgArg        /* save message-object                  */
      END

                                /* create message object from array     */
      ELSE IF IsA( msgArg, .array ) THEN      
      DO
         IF msgArg[ 2 ] = .nil THEN   /* method without arguments       */
            MsgObj = .message ~ new( .nil, msgArg[ 1 ] )
         ELSE                   /* array of arguments supplied          */
            MsgObj = .message ~ new( .nil, msgArg[ 1 ], "A", msgArg[ 2 ] )
      END


      ELSE                      /* create message object from string    */
      DO
         MsgObj = .message ~ new( .nil, msgArg )
      END
   END


   bDesc = ( TRANSLATE( LEFT( option, 1 ) ) = "D" )     /* sort descending ?    */
      

   /* first generate a 2-dimensional array, where the key is stored in [ n, 1 ] and
      the object in [ n, 2 ]                                                    */
   bBuildArray = .true
   IF MsgObj = .nil THEN
   DO
      IF IsA( collection, .array ) THEN         /* already an array in hand ?   */
      DO
         IF collection ~ dimension = 2 THEN     /* [ x, 1 ] key, [ x, 2 ] object*/
         DO
            array = collection ~ copy   /* use a copy of the passed in array    */
            bBuildArray = .false
         END
      END

                /* *any* stem gets sorted by its indices                */
      ELSE IF IsA( collection, .stem ) THEN     /* sort a stem, using index as key */
      DO
         i = 0
         array = .array ~ new
         DO index OVER collection
            i = i + 1
            array[ i, 1 ] = index
            array[ i, 2 ] = collection[ index ] /* get associated object        */
         END

         bBuildArray = .false
      END
   END
      
   IF bBuildArray THEN
   DO
      array = .array ~ new                 /* create a new array object            */
      i = 0
      IF IsA( collection, .stem ) THEN     /* .stem is supplied with a message, non-msg
                                              version already handled above        */
      DO
         DO index OVER collection
            i = i + 1                      /* another item to be added to array    */
            object = collection[ index ] 
            array[ i, 1 ] = MsgObj ~ copy ~ send( object ) 
            array[ i, 2 ] = object         /* save object          */
         END
      END
      ELSE
      DO
         tmpSupp = collection ~ SUPPLIER   /* loop over objects in collection      */
         DO WHILE tmpSupp ~ AVAILABLE
            i = i + 1                      /* another item to be added to array    */

            object = tmpSupp ~ ITEM
   
            IF MsgObj = .nil THEN          /* if no message-object exists, do default */
               array[ i, 1 ] = object ~ string     /* send the object the STRING-message   */
            ELSE           /* retrieve value to sort by via the message object     */
              array[ i, 1 ] = MsgObj ~ copy ~ send( object ) 

            array[ i, 2 ] = object         /* save object          */
              
            tmpSupp ~ NEXT                 /* get next item        */
         END
      END
   END

   IF array ~ items = 0 THEN RETURN .array ~ new   /* nothing to sort      */
   total_Items = ( array ~ items / 2 )     /* get # of items to sort       */


        /* Knuth's algorithm ...                */
   M = 1                           /* define M for passes           */
   DO WHILE (9 * M + 4) < total_Items 
      M = M * 3 + 1
   END

   DO WHILE M > 0                  /* sort stem                     */

      K = total_Items - M

      DO J = 1 TO K
         Q = J
         DO WHILE Q > 0
            L = Q + M

            /* make comparisons case-independent                    */
            IF bDesc THEN       /* descending sort              */        
            DO
               IF NLS_COLLATE( array[Q, 1] )   > NLS_COLLATE( array[L, 1] ) THEN LEAVE
            END
            ELSE                /* ascending sort               */
            DO
               IF NLS_COLLATE( array[Q, 1] ) <<= NLS_COLLATE( array[L, 1] ) THEN LEAVE
            END

            tmp1        = array[Q, 1]   /* store key                    */
            tmp2        = array[Q, 2]   /* store object                 */
                        
            array[Q, 1] = array[L, 1]   /* exchange key                 */
            array[Q, 2] = array[L, 2]   /* exchange object              */
                        
            array[L, 1] = tmp1          /* exchange key                 */
            array[L, 2] = tmp2          /* exchange object              */

            Q = Q - M
         END
      END
      M = M % 3
   END

   RETURN array

SYNTAX : RAISE PROPAGATE        /* show position in caller      */
/******************************************************************************/



/******************************************************************************/
/*                                                                            */
/* name:    BinFindArray( array, searchKey )                                  */
/*                                                                            */
/* purpose: find a Key in a sorted, 1- or 2-dimensional array, where the key  */
/*          to sort by is stored in subscript # 1                             */
/*                                                                            */
/* returns: return position in array containing the searchKey                 */
/*                                                                            */
/*          - if key was not found, .nil is returned                          */
/*                                                                            */
/*          - if duplicate keys in array, the very first key is searched and  */
/*            returned                                                        */
/*                                                                            */
/* remarks: deals with multiple, sorted key-entries too                       */
/*          array         ... array object                                    */
/*          searchKey     ... key to search for                               */
/*                                                                            */
/*          if key was not found, .nil is returned.                           */
/*                                                                            */
/*          if duplicate keys in array, the very first key is searched and    */
/*          returned.                                                         */
/*                                                                            */
/*                                                                            */
/* created: rgf, 96-09-09                                                     */

:: ROUTINE BinFindArray          PUBLIC
   USE ARG array, searchKey, bReturnArray

   dimension = array ~ dimension                /* get dimension of array               */
   IF dimension > 2 THEN 
   DO
      SIGNAL ON SYNTAX
      RAISE SYNTAX 40.4 ARRAY ( "BinaryFindInArray", "array-dimension must be <= 2 !" )
   END

   total_Items = ( array ~ items / array ~ dimension )  /* determine # of rows          */

   bFound = .false
   lowerBound = 1
   upperBound = total_items
   index      = .nil                            /* to contain index to searched key     */

   DO WHILE lowerBound <= upperBound
      tmpPosition = ( upperBound + lowerBound ) % 2     /* halve the range              */

      IF dimension = 1 THEN arrayKey = array[ tmpPosition    ]  /* 1 dimension          */
                       ELSE arrayKey = array[ tmpPosition, 1 ]  /* 2 dimensions         */

      tmpCompare  = NLS_COMPARE( arrayKey, searchKey )

      SELECT 
         WHEN tmpCompare =  1 THEN              /* arrayKey > searchKey, search first half      */
              upperBound = tmpPosition - 1

         WHEN tmpCompare = -1 THEN              /* arrayKey < searchKey, search second half     */
              lowerBound = tmpPosition + 1

         OTHERWISE                              /* strings are identical              */
              DO
                 index  = tmpPosition           /* save found position                */

                 IF lowerBound = upperBound | tmpPosition = 1 THEN      /* no more searches possible    */
                    LEAVE

                 /* check whether multiple keys in array, move one entry backward     */
                 tmpIndex = tmpPosition - 1
                 IF dimension = 1 THEN tmpArrayKey = array[ tmpIndex    ]  /* 1 dimension       */
                                  ELSE tmpArrayKey = array[ tmpIndex, 1 ]  /* 2 dimensions      */

                 IF NLS_COMPARE( tmpArrayKey, searchKey ) <> 0 THEN     /* first entry found    */
                    LEAVE

                 upperBound = tmpPosition - 1   /* search in first half               */
              END
      END  
   END

   IF bReturnArray = .true THEN /* array-object: [1] index or .nil      */
      RETURN .array ~ of( index, tmpPosition )  /*  [2] position        */  

   RETURN index                 /* first position of keyword in array or .nil if not found */

SYNTAX : RAISE PROPAGATE        /* show position in caller      */
/******************************************************************************/


