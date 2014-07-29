/* 
program:   dump_cls.cmd
type:      Object REXX, REXXSAA 6.0, all platforms
purpose:   collection of useful routines for Object REXX programs
version:   1.00.00
date:      1999-06-24
changed:   -

author:    Rony G. Flatscher
           Rony.Flatscher@wu-wien.ac.at
           (Wirtschaftsuniversitaet Wien, University of Economics and Business
           Administration, Vienna/Austria/Europe)

needs:     "rgf_util.cmd" from the "orx8.zip"-package (cf. ::REQUIRES-directive below)

usage (1): dump_cls
           ... displays the present Object Rexx class hierarchy.

usage (2): dump_cls FILE_TO_CALL [ARGS]
           ... calls the given file with optional arguments and
               reports the classes and the methods defined by it.

comments:  -

Standard disclaimer (sometimes larger than the entire program! :) :

All rights reserved and copyrighted 1999 by the author, no guarantee that
it works without errors, etc.  etc.

You are granted the right to use this module under the condition that you don't
charge money for this module (as you didn't write it in the first place) or
modules directly derived from this module, that you document the original author
(to give appropriate credit) with the original name of the module and that you
make the unaltered, original source-code of this module available on demand.  If
that holds, you may even bundle this module (either in source or compiled form)
with commercial software.

If you find an error, please send me the description (preferably a *very* short
example); I'll try to fix it and re-release it to the net.
*/

PARSE ARG file args             /* retrieve file to analyze */

                /* configuration        */
.local ~ n.bSAM = .false        /* show all methods ? If .false, then only for new classes      */
/*
.local ~ n.bSAM = .true
*/


.local ~ n.nda = "(n/a)"        /* save "not in .local or .environment"         */
.local ~ n.new = ">>"           /* new-class indicator                          */
.local ~ n.new.string = COPIES(" ", LENGTH(.n.new))
.local ~ n.mc  = "(MC)"         /* indicator for metaclass class                */

.local ~ n.pointer = "->"       /* string to indicate pointer                   */

.local ~ n.length = 80          /* line-length for breaking up lines            */
.local ~ n.Indent = 5           /* blanks to indent, if line was broken up      */
.local ~ n.ind.bl = COPIES(" ", .n.indent)      /* blank-indentation string     */


                /* start of program     */
tmpSet1 = getSetOfClasses(.object)      /* get a set of all classes             */

IF file="" THEN                 /* no arguments, give usage-message     */
DO
   PARSE SOURCE . . thisFile
   SAY 
   SAY "Usage (1):" FILESPEC("N", thisFile) 
   SAY "           ... displays the present Object Rexx class hierarchy."
   SAY
   SAY "Usage (2):" FILESPEC("N", thisFile) "FILE_TO_CALL [ARGS]"
   SAY "           ... calls the given file with optional arguments and"
   SAY "               reports the classes and the methods defined by it."
   SAY
   SAY
   SAY "Object Rexx class tree as of:" "[" || date("s") time() || "]"
   SAY
           /* ---> show class-hierarchy    */
   CALL dump_sub_classes .object, 0, .set~new
   SAY
   SAY .n.nda "= not available through .local or .environment!"
   SAY .n.mc "= metaclass used for the listed class"
   SAY "There are" pp(tmpSet1~items) "distinct classes in the tree."
   SAY
   EXIT 0
END

        /* create Rexx call instruction, execute it, possibly new classes now available           */
tmpDat = "CALL (file)" args
INTERPRET tmpDat
tmpSet2 = getSetOfClasses(.object)      /* get a set of all classes             */

tmpSetNew = tmpSet2~difference(tmpSet1) /* extract new classes                  */

.local~n.SetPre = tmpSet1               /* classes before calling file          */
.local~n.SetNew = tmpSetNew             /* classes defined because of file      */
.local~n.SetAll = tmpSet2               /* all classes                          */

tmpRel = .relation~new
IF .n.bSAM THEN tmpSet = .n.SetAll      /* show all methods or only those of new classes */
           ELSE tmpSet = .n.SetNew
DO class OVER tmpSet
   class_Id = class~id
   MethSupp = class~methods(.nil)       /* get methods defined in class         */
   DO WHILE MethSupp~available          /* loop over all methods                */
      tmpRel[MethSupp~index]=class_id
      MethSupp~next
   END 
END

.local~n.M2C = tmpRel                   /* .n.c2m[method-name]=class_id         */



IF tmpSetNew~items=0 THEN               /* no new classes defined               */
DO
   SAY "File" pp( file ) "did not define new classes, aborting."
   EXIT -1
END

SAY "Analyzing classes and methods introduced by:" pp( file ) "[" || date("s") time() || "]"
SAY

        /* ---> show class-hierarchy    */
CALL dump_sub_classes .object, 0, tmpSetNew
SAY
SAY .n.nda "= not in .local or .environment!"
SAY pp(.n.SetNew~items) "new classes - prefixed with" pp(.n.new) "- were introduced by" pp(file) 
SAY

SAY COPIES("=", .n.length)


        /* ---> show classes in alpha together with their methods in alpha 
               (show superclasses, if they have the same method-name    */
SAY
SAY pp( file )": Classes and their methods (showing superclasses with the same method):"
SAY

tmpArr = sortCollection(.n.SetAll, "ID")        /* sort set by "ID" of the class objects */
DO i = 1 TO .n.SetAll~items
   CALL class2methods i, tmpArr[i, 1], tmpArr[i, 2]     /* show class and its messages   */ 
END
SAY
SAY COPIES("=", .n.length)



        /* ---> show methods in alpha together with the classes in alpha */
SAY
SAY pp( file )": Methods and Classes, which define them:"

tmpSupp = .n.m2c~supplier
tmpArr  = .array~new
null    = "01"x
i=1
DO WHILE tmpSupp~available
   tmpArr[i]=tmpSupp~index || null || tmpSupp~item      /* index=methodname, item=class_id      */
   i=i+1
   tmpSupp~next
END
SAY "(total of" pp(tmpArr~items) "methods)"
SAY

tmpArr = sortArray(tmpArr)                              /* sort array                           */
tmpString = ""
bNew   = .true
MsgWidth = 30
.local ~ n.ind.bl = COPIES(" ", MsgWidth+1)             /* to be used by break_and_say as a lead-in     */
PARSE VALUE tmpArr[1] WITH OldMethod (null)
DO i = 1 TO tmpArr~items
   PARSE VALUE tmpArr[i] WITH newMethod (null) class_id
   bNew = (OldMethod \== newMethod)
   IF bNew THEN
   DO
      call break_and_say LEFT(pp(oldMethod)" ", MAX(MsgWidth, LENGTH(oldMethod)), '.') STRIP( STRIP(tmpString, "T", "," ))
      tmpString = ""
      OldMethod = newMethod
   END
   tmpString = tmpString class_id","
END
IF tmpString <> "" THEN
   call break_and_say LEFT(pp(oldMethod)" ", MAX(MsgWidth, LENGTH(oldMethod)), '.') STRIP( STRIP(tmpString, "T", "," ))

SAY
SAY COPIES("=", .n.length)



::REQUIRES "rgf_util.cmd"       /* loads all bunch of utility-routines, using pp() and sorting-routines */


        /* show class and a list of its methods; if method by the same name exists
           in superclass, then show it in order of resolution (takes care of multiple
           inheritance) */
::ROUTINE class2methods
  USE ARG idx, class_id, class

  tmpSC = class~superclasses    /* get superclasses     */
  tmpMC = class~metaclass       /* get metaclass        */
  tmpMArr = sortArray(.n.m2c~allindex(class_id))   /* get all methods of class_id  */

  CALL say_class                /* build and show class infos   */
/*
  CALL say_methods tmpMArr      /* simple message-listing       */
*/
  CALL say_methods_with_super tmpMArr, class
  RETURN

  say_class :                   /* build and show class infos   */
     tmpString = LEFT(class_id, MAX(20, LENGTH(class_id)), ".")
     IF .n.SetNew~hasindex(class) THEN tmpString = .n.new        || tmpString
                                  ELSE tmpString = .n.new.string || tmpString

     IF tmpSC~items <> 0 THEN
     DO
        IF class~querymixinclass THEN tmpString = tmpString "MIXINCLASS" tmpSC[1]~id
                                 ELSE tmpString = tmpString "SUBCLASS  " tmpSC[1]~id 
     END

     IF tmpMC <> .class THEN tmpString = tmpString "METACLASS" tmpMC~id
     IF tmpSC~items > 1 THEN    /* multiple inheritance?        */
     DO
        tmpString = tmpString "INHERIT"         /* build inherit list   */
        DO i=2 TO tmpSC~items
           tmpString = tmpString tmpSC~at(i)~id
        END
     END
     IF tmpMArr~items <> 0 THEN SAY     /* insert empty line before class, if it has methods */
     SAY tmpString
     RETURN

  say_methods_with_super : PROCEDURE    /* show methods and superclasses, if they have that method too */
     USE ARG methArr, class

     CResList = createSuper(class)      /* create class-resolution list */
     tmpString=""
     DO item OVER methArr
        tmpString = tmpString pp(item) 
        bSkip = 1; /* bNotFirst = 0 */
        do citem over CResList
           if bSkip then                /* first element in list is class itself, skip it */
           do 
              bSkip=0;iterate
           end 
           tmpCID = citem~id
           if .n.m2c~hasitem(tmpCID,item) then
           do
              tmpString = tmpString || .n.pointer || tmpCID
           end
        end 
        tmpString = tmpString","
     END
     IF tmpString <> "" THEN 
     DO
        call break_and_say .n.ind.bl || STRIP( STRIP(tmpString, "T", "," ))
        SAY
     END
     return

  createSuper: procedure                /* create list of superclass-resolution, take care of multiple inheritance */
     use arg class

     CResList = .list ~ new             /* class resolution list        */
     last = CResList ~ last             /* get last entry, everything has to be inserted right after it */
     CALL get_hierarchy_up Class, .set~new, CResList, last

/*
say "first:" CResList~firstitem~id "last:" CResList~lastitem~id 
tmpString =""
do item over CResList
   tmpString = tmpString "-->"item~id
end 
say tmpString
*/
     return CResList

/* ---------------------------------------------------------------------------------------- */
/* produce a hierarchy list with starting class, taking care of multiple inheritance    */
/* insert aClass into CResList, if it is not in tmpSet,
   position in list is indicated by POSITION_IN_LIST */

GET_HIERARCHY_UP: PROCEDURE 
   USE ARG aClass, tmpSet, CResList, position_in_list

   IF tmpSet ~ hasindex( aClass ) THEN RETURN   /* already handled */
                                                /* insert class after given entry       */
   listIndex = CResList ~insert(aClass, position_in_list)
   tmpSet ~ put( aClass )                       /* indicate that class has been handled */

   arrSC = aClass ~ SuperClasses                /* get all superclasses of aClass       */
   DO i=arrSC~items TO 1 BY -1                  /* work from right to left              */
      item = arrSC ~ at(i)                      /* retrieve superclass                  */
      IF \tmpSet ~ HASINDEX(item) THEN          /* class not handled as of yet          */
      DO
         CALL get_hierarchy_up item, tmpSet, CResList, listIndex
      END
   END
   RETURN




  say_methods : PROCEDURE       /* show plain methods   */
     USE ARG methArr

     tmpString=""
     DO item OVER methArr
        tmpString = tmpString pp(item) 
     END
     IF tmpString <> "" THEN 
     DO
       call break_and_say .n.ind.bl || STRIP( tmpString )
       SAY
     END
     return



::ROUTINE break_and_say
  USE ARG line, 

  compLength = .n.length+1
  DO WHILE line <> ""
     IF LENGTH(line) < compLength THEN
     DO
        SAY line
        LEAVE
     END

     ELSE
     DO
        pos = LASTPOS(" ", line, compLength)
                /* no blanks in string so far=oversized line? (exclude leadin blanks!)  */
        IF pos<=.n.indent THEN pos = POS(" ", line, compLength)
        IF pos=0 THEN pos=length(line)+1        /* no blank in oversized line   */

        SAY SUBSTR(line, 1, pos-1)              /* extract string up to but not including blank   */
        line=.n.ind.bl || SUBSTR(line, pos+1)
     END
  END
     
     


::ROUTINE dump_sub_classes
  USE ARG class, level, tmpSetNew

  class_id = class~id
  tmpString = class_id
                                /* not directly available thru .local or .environment?  */
  IF (.local~entry(class_id) = .nil) & (.environment~entry(class_id) = .nil) THEN tmpString = tmpString .n.nda

                                /* newly added class?                   */
  IF tmpSetNew~hasindex(class) THEN tmpString = .n.new        || tmpString 
                               ELSE tmpString = .n.new.string || tmpString  /* insert blank (s) */

  IF class~SuperClasses~items > 1 THEN  /* class employing multiple inheritance?        */
  DO
     superclasses = class~SuperClasses
     tmpString2 = "[subclass" SuperClasses[1]~id "inherit"
     DO i=2 TO superclasses~items       /* create list of multiple inherited classes    */
        tmpString2 = tmpString2 superclasses~at(i)~id
     END
     tmpString = tmpString tmpString2 || "]"
  END

/*
  SAY LEFT(LEFT("", level * 4) || tmpString, MAX( 58, LENGTH(tmpString)+level*4), ".") class~metaclass~string 
*/
  SAY LEFT(LEFT("", level * 4) || tmpString, MAX( 63, LENGTH(tmpString)+level*4), ".") .n.mc  class~metaclass~id

  subclasses = sortArray(class~SUBCLASSES)      /* sort array of subclasses of class in hand */

  DO subclass OVER subclasses
     CALL dump_sub_classes subclass, level + 1, tmpSetNew
  END
  RETURN



  /* create a Set which contains the passed in class and all of its subclasses  */
::ROUTINE getSetOfClasses
  USE ARG class
  tmpSet = .set~new
  CALL gsoc class, tmpSet
  RETURN tmpSet

  gsoc: PROCEDURE               /* does the work, recursively   */
     use arg class,tmpSet
     tmpSet~put(class)
     subclasses = class~subclasses
     DO sclass OVER subclasses
        call gsoc sclass, tmpSet
     END
     RETURN


