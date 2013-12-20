/******************************* REXX *********************************/
/*  This is a simple external REXX function that determines whether   */
/*  or not a passed year is a leap year or not.  If invoked without   */
/*  any operands, the determination is made on the current year.      */
/*  The function returns a "1" if it is a leap year, "0" if not.      */
/**********************************************************************/
Parse Arg year, .
If year = '' Then
   year = Left(Date('S'), 4)
jul_year = Right(year, 2)
jul_cent = Left(year, 2)
 
/**********************************************************************/
/*  Leap years are calculated as follows:  If the year is 0, and the  */
/*  century is divisible by 4, then it is a leap year (century        */
/*  divisible by 400).  Otherwise, if the year is divisible by 4, it  */
/*  is a leap year.  If the year is divisible by 100 and NOT          */
/*  divisible by 400, it is NOT a leap year.                          */
/**********************************************************************/
If ((jul_year = '00') & ,
   (jul_cent // 4 = 0)) | ,
   ((jul_year \= '00') & ,
   (jul_year // 4 = 0)) Then
   sw = 1
Else
   sw = 0
Return sw
