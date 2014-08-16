/* REXX */
/* Procedure to test 'w()' function     */
/* Put in same directory as w.cmd       */
/*    and type 'testw' (without quotes) */

Say "Enter string to parse or 'exit' to terminate"
Say " Displays the first 9 'words' of string entered"
Do Forever
   Say '?'
   Parse Pull temp
   If Translate(temp)='EXIT' Then Return
   Do i=1 To 9
      Say i':' W(temp,i)
      End /* Do i */
   End /* Forever */
Return


