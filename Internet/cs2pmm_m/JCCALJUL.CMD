/******************************* REXX *********************************/
/*        REXX Function to calculate and return Julian Dates          */
/*  This is a port of an ANSI COBOL program which calculated Julian   */
/*  dates based on passed Gregorian dates.  The original program and  */
/*  REXX port were both done by Jaime A. Cruz, Jr.  This program is   */
/*  released to the public domain.  You may contact the author at     */
/*  72267.1372@compuserve.com, or jcruz@ibm.net                       */
/**********************************************************************/
/*                   Table of days in each month.                     */
/**********************************************************************/
month.0 = 12
month.1 = 31
month.2 = 28
month.3 = 31
month.4 = 30
month.5 = 31
month.6 = 30
month.7 = 31
month.8 = 31
month.9 = 30
month.10 = 31
month.11 = 30
month.12 = 31

/**********************************************************************/
/*     Argument passed must be in mm/dd/yy or mm/dd/yyyy format.      */
/**********************************************************************/
Parse Upper Arg greg_date, .
Select
/**********************************************************************/
/*  If a two digit year was passed, extract the century from the      */
/*  system, and set a flag indicating the short form was used         */
/**********************************************************************/
   When Length(greg_date) = 8 Then
      Do
         Parse Value greg_date With 1 greg_month 3 ,
                                    4 greg_day 6 ,
                                    7 greg_year 9
         greg_cent = Left(Date('S'), 2)
         short = 1
      End
/**********************************************************************/
/*  If a four digit year was passed, use the century the user         */
/*  specified.  Set a flag indicating the long form was used.         */
/**********************************************************************/
   When Length(greg_date) = 10 Then
      Do
         Parse Value greg_date With 1 greg_month 3 ,
                                    4 greg_day 6 ,
                                    7 greg_cent 9 ,
                                    9 greg_year 11
         short = 0
      End
/**********************************************************************/
/*  If an unrecognized date was passed, we'll default to today's      */
/*  date in the long form.                                            */
/**********************************************************************/
   Otherwise
      Do
         Parse Value Date('S') With 1 greg_cent 3 ,
                                    3 greg_year 5 ,
                                    5 greg_month 7 ,
                                    7 greg_day 9
         short = 0
      End
End

If JCLepYer(greg_cent || greg_year) Then
   month.2 = 29

/**********************************************************************/
/*                     Calculate the Julian Date                      */
/**********************************************************************/
jul_date = greg_year * 1000
Do x = 1 To (greg_month - 1)
   jul_date = jul_date + month.x
End
jul_date = jul_date + greg_day
jul_date = Right(jul_date, 5, '0')

/**********************************************************************/
/*       If the long form was requested, include the century.         */
/**********************************************************************/
If \ short Then
   jul_date = greg_cent || jul_date

/**********************************************************************/
/*         Return the calculated Julian date to the invoker.          */
/**********************************************************************/
Return jul_date
