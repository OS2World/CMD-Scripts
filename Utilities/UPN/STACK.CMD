/* Stack Class*/

/* Ein paar Tests */
/*
s = .Stack~new
s1 = .Stack~new

s~push(1)
s~push("Gaga")
s1~push('abc')
s~push(s1)
s~push(99)
s~push(11)


s~dump

s~Swap

WHILE \s~isEmpty DO
   say s~pop
END

exit

*/

::CLASS Stack PUBLIC

::METHOD Init
  EXPOSE theStack
  
  /* Initialisierung des Objektes, leere Liste anlegen */
    theStack = .List~new


::METHOD Push
   EXPOSE theStack 
   USE ARG value
   /* ein neues Objekt auf den Stack legen (bzw. zuvorderst in die Liste) */

   theStack~insert(value, .nil)

::METHOD Pop
   EXPOSE theStack

   /* oberstes (erstes) Element holen, aus Liste löschen und zurückliefern */

   IF self~isEmpty THEN DO
      RETURN .nil
   END 
   ELSE DO
      idx = theStack~First
      item = theStack~at(idx)
      theStack~remove(idx)
      return item
   END

::METHOD Drop
/* oberstes Element fallen lassen */
   self~pop

::METHOD Swap
   EXPOSE theStack

   /* die obersten zwei Elemente tauschen */
   item1 = self~pop
   item2 = self~pop
   self~~push(item1)~push(item2)


::METHOD isEmpty
   EXPOSE theStack

   /* ist der Stack leer ? */
   i = theStack~Items
   IF i = 0 THEN 
      return .TRUE
   ELSE
      return .FALSE


::METHOD Dump
   EXPOSE theStack
   /* eigene Ausgaberoutine 
      gibt jedes Element des Stacks aus */

   IF self~isEmpty THEN DO
     SAY "Stack ()"
   END
   ELSE DO
      SAY "Stack ("
      DO item OVER theStack
         SAY "       "item
      END
      SAY "      )"
   END
