/******************************* REXX *********************************/
/*  REXX External function to calculate a relative day of the week.   */
/*  Input is the Julian date of the day in question (either           */
/*  yyddd or yyyyddd), output is a number from 1 - 7, with 1=Sunday,  */
/*  7=Saturday.                                                       */
/*                                                                    */
/*  Original program written by Jaime A. Cruz, Jr. and released to    */
/*  the public domain.  If you wish to contact the author, you may    */
/*  do so at 72267.1372@compuserve.com or jcruz@ibm.net.              */
/**********************************************************************/
/*        Argument passed must be in yyddd or yyyyddd format          */
/**********************************************************************/
Parse Upper Arg jul_date, .
Select
/**********************************************************************/
/*  If a five-digit Julian Date was passed, extract the century from  */
/*  the system.                                                       */
/**********************************************************************/
   When Length(jul_date) = 5 Then
      Do
         Parse Value jul_date With 1 jul_year 3 ,
                                   3 y 6
         jul_year = Left(Date('S'), 2) || jul_year
      End
/**********************************************************************/
/*  If a seven-digit Julian Date was passed, we will use the century  */
/*  the user specified.                                               */
/**********************************************************************/
   When Length(jul_date) = 7 Then
      Do
         Parse Value jul_date With 1 jul_year 5 ,
                                   5 y 8
      End
/**********************************************************************/
/*  If an unrecognized date format was used, then we'll default to    */
/*  today's date.                                                     */
/**********************************************************************/
   Otherwise
      Do
         y = Date('D')
         jul_year = Left(Date('S'), 4)
      End
End
/**********************************************************************/
/*    Calculate upon which day of the week the passed date falls.     */
/**********************************************************************/
x = jul_year - 1
z = Trunc(((x / 1) + (x / 4) - (x / 100) + (x / 400)), 0) + y
day = (z // 7) + 1
 
/**********************************************************************/
/*           Return this information back to the invoker.             */
/**********************************************************************/
Return day
