/*#! rexx */
/*****************************************************************
* OJulDate.cmd
*
* Julian date algorithms adapted to Rexx from:
*  'Numerical Recipes in C', Cambridge Press.
* Author Kurt A. Spaugh, Softlynks Inc.
* Fort Lauderdale FL.
* Copyleft (c) 1996
*
*
* ObjectRexx Adaptation
* Contructors:
*  .date~new(mm/dd/yyyy)
*  .date~new(jul)
*  .date~new(mm/dd/yy)      - dangerous convenience: assumes yy+1900
* Methods:
*  jul2Greg                 - converts and returns yyyymmdd
*  greg2Jul                 - converts and returns julianDay
*  setJul(julianDay)        - set internal date
*  setGreg(mm,dd,yyyy)      - same
*  setMMDDYY( mm,dd,yy)     - same adds 1900 to yy
*  getYear                  - gives year
*  getMonth                 - gives month
*  getDay                   - gives day
*  getJul                   - gives julianDay
*  julDow                   - gives 0-6 (sunday-Saturday)
*  whatDay                  - day name
*  ToDST                    - date Daylight Savings time begins
*  ToSTD                    - date Standar time begins
*  isDST                    - true id DST in effect
*  isLeap                   - true if self~year is a leap year
*
* Useful: The naval observatory abreviates the julian date in
* their time transmissions as julianDay-2400000.
* e.g. 10/13/1997 (2450735 Julian) is abbreviated as 50735
* ...why they picked 11/16/1858 is beyond me...
* Another common contraction subtracts  5/23/1968, or 2440000
*
* Bugs: they're yours to keep.  The code is free.
*       None observed to date.
*
* Suggestions:
* The code is a straight forward translation. Some economy
* can be had by folding expressions. Is is worth it?
* I used modulo arithmetic to int-ify real numbers.
* Is trunc(exp) better/faster than exp%1 ??
*
* Object notes: I chose to make all subroutines operate on self, as opposed to
* supplied arguments.  In practice, I found that when using methods, I usually
* needed a date object for the date of interest anyway. You might like it better
* with args to all methods ( as helpers ). Most of the time, greg to jul
*
*
* Notes:
* Because of the change to Gregorian calendar,
* Thursday Oct. 4,1582, is followed by Friday Oct. 15, 1582.
* Entering these dates will produce correct, but odd, results:
* 10/5/1582 is julian day 2299161.
* Julian day 2299161 when converted to gregorian will return
* 10/15/1582...this is normal, and correct, AFAIK
*****************************************************************/

/*****************************************************************************
* Modification History
* --------------------
* $Log: odate.cmd $
*****************************************************************************/
.local~array.day=.array~of('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')
::class date public
  /*****************************************/
  /* julian based date                     */
  /* no leap year worries                  */
  /*****************************************/
::method init
  /*********************************/
  /*override new to initialize with*/
  /*'mm/dd/yyyy' initializer or    */
  /*Julian date initialize         */
  /*or none (defaults to today)    */
  /*********************************/
  expose jul Month Day Year            /* all data for object */
  arg date
  if date = 'DATE' | date = '' then     /* empty */
    do
      date=date('S')                    /* get todays date */
      iyyy=date~left(4)
      id=date~right(2)
      mm=date~substr(5,2)
    end
  else
    parse value date with mm'/'id'/'iyyy

  if id='' & iyyy='' then
    self~setjul(mm)
  else
    if iyyy~length < 4 & iyyy > 0 then            /* really? */
       self~setmmddyy(mm,id,iyyy)
    else
       self~setgreg(mm,id,iyyy)
  return

::method setJul
  expose jul year month day
  use arg jul
  s=self~jul2greg(jul)
  If s < 0 Then
    parse var s year +5 month +2 day
  else
    parse var s year +4 month +2 day
  return

::method setGreg
  use arg mm,dd,iyyy
  self~setjul(self~greg2jul(mm,dd,iyyy))
  return

::method setMMDDYY
  use arg mm,dd,yy
  self~setgreg(mm,dd,yy+1900)
  return

::method jul2Greg
  use arg jul
  do
     /******************************************/
     /*Adapted from 'Numerical Recipes in 'C'  */
     /*...Can't explain this algorithm, it just*/
     /*works.  Trust me.                       */
     /******************************************/

     igreg=2299161
     if jul  >= igreg then
     do
        jalpha=((jul-1867216)-0.25)/36524.25%1
        ja=jul+1+jalpha-0.25*jalpha%1
     end /* do */
     else
       ja=jul
     jb=ja+1524
     jc=(6680+((jb-2439870)-122.1)/365.25)%1
     jd=(365*jc+(0.25*jc))%1
     je=(jb-jd)/30.6001%1
     id=jb-jd-30.6001*je%1
     mm=je-1
     if(mm>12) then
       mm=mm-12
     iyyy=jc-4715
     if( mm>2) then
       iyyy=iyyy-1
     if( iyyy <= 0 ) then
       iyyy=iyyy-1

     if iyyy < 0  then
       Do
         iyyy=iyyy * -1;
         retyear='-'iyyy~right(4,'0')
       End /* Do */
     else
       retyear=iyyy~right(4,'0')
     return retyear||mm~right(2,'0')||id~right(2,'0')
  end /* do */


/******************************************/
/*Adapted from 'Numerical Recipes in 'C'  */
/*...Can't eplain this algorithm, it just */
/*works.  Trust me.                       */
/******************************************/
::method greg2Jul
  use arg mm, id, iyyy
  igreg=(15+31*(10+12*1582))

  jy=iyyy;
  if jy = 0 then
  do
    say "there is no year 0"
    raise error 254
  end /* do */
  If jy < -4713 Then
  Do
    say "can't pre-Date first Julian day(1/1/-4713)"
    raise error 255
  End /* Do */
  if jy < 0 then jy=jy+1
  if mm > 2 then jm=mm+1
  else
  do
     jy=jy-1
     jm=mm+13
  end /* do */
  a1=365.25*jy%1
  a2=30.6001*jm%1
  jul=a1+a2+id+1720995
  if( id+31*(mm+12*iyyy) >= igreg) then
  do
     ja=.01*jy%1
     jul=jul+2-ja+0.25*ja%1
  end /* do */
  return jul

::method getYear
  expose year
  return year

::method getMonth
  expose month
  return month

::method getDay
  expose day
  return day

::method julDate
  expose jul
  return jul

::method gregDate
  expose Month Day Year
  return Month'/'Day'/'Year

::method toDST          /* when is first Sunday in April? */
  expose year
  day1=.date~new('4/1/'year)
  x=day1~julDow;
  if(x > 0) then
    x=7-x
  return day1~julDate+x

::method toSTD          /* when is last Sunday in October? */
  expose year
  day31=.date~new('10/31/'year)
  x=day31~julDow;
  return day31~julDate-x

::method isDST
  If self~juldate >= self~ToDST & self~juldate <= self~ToSTD Then
    return 1
  return 0

::method isLeapYear
  expose year
  If year = -1 Then
    adder=2          /* no year zero */
  else
    adder = 1
  If .date~new('1/1/'||year+adder)~juldate - .date~new('1/1/'||year)~juldate = 366 Then
    return 1
  return 0

::method julDow                             /* useful */
  expose jul
  return(jul+1)//7

::method whatDay
  return .local~array.day[self~julDow+1]
