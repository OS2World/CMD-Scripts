/*-w.cmd----------------------------------------*/
/* Word()-like Function (handles quoted strings)*/
/* Peter Flass <Flass@LBDC.Senate.State.NY.US>  */
/* May, 1998                                    */
/* Usage: result = W(string,word#)              */
/*----------------------------------------------*/

  /* Uncomment the following line if imbedding  */
/* ---
W:Procedure   
 ---*/
  Signal On Novalue
  Parse Arg str,num
  word     = 0
  i=1

  Do While(i<=Length(str))     
     HaveWord  = ''
     ThisWord  = ''
     quote     = ''
     c1        = ''

     /* Find Start of String */
     Do While(i<=Length(str))
        c1 = Substr(str,i,1)
        If c1<>' ' Then Leave
        i=i+1
        End /* do i */
     If i>Length(str) Then Return '' /*052798*/

     If c1="'" | c1='"' Then Do
        quote=c1
        i=i+1
        if i>Length(str) Then Return ''/* Single quote only */
        c1 = Substr(str,i,1)
        End /* quote */

     /* Scan string */
     Do Forever
        i=i+1
        if i>Length(str) Then Do
           If c1=quote Then Do
              HaveWord='Y'
              Leave /* Forever */
              End
           If quote<>'' Then Return '' /* No closing quote */
           ThisWord = ThisWord || c1
           HaveWord='Y'
           End /* i>Length(str) */
        If HaveWord<>'' Then Leave /* Forever */
        c2 = Substr(str,i,1) 

        /* Not a quoted string */
        If quote='' Then Do
           If c2=' ' Then Do
              ThisWord = ThisWord || c1
              HaveWord='Y'
              End /* c2=' ' */
           Else Do
              ThisWord = ThisWord || c1
              c1=c2
              Iterate
              End /* else */
           End /* quote='' */ 

        /* Quoted string */
        Else Do
           Select
              /* Quote-Quote -> Quote */
              When c1=quote & c2=quote Then Do
                 ThisWord = ThisWord || c1
                 i=i+1
                 If i>Length(str) Then Return '' /* ends with '' */
                 c1=Substr(str,i,1)
                 Iterate
                 End /* quote-quote */
              /* Quote-x: end of string */
              When c1=quote & c2<>quote Then Do 
                 HaveWord='Y'
                 End
              /* Quote-<EOS> */
              When c1=quote & i>=Length(str) Then Do
                 HaveWord='Y'
                 End 
              /* x-Anything */
              Otherwise Do
                 ThisWord = ThisWord || c1
                 c1=c2
                 Iterate
                 End /* otherwise */
              End /* Select */
           End /* Quoted string */

         If HaveWord<>'' Then Leave /* scan */

         End /* scan */

      word=word+1
      If word=num Then Return ThisWord

      End /* Do While(i) */

   Return ''

/*------------ End of 'W' --------------*/
