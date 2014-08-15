/*#! rexx*/
/*****************************************************************
* Juldate.cmd
* Author Kurt A. Spaugh, Softlynks Inc.
* Fort Lauderdale FL.
* Copyleft (c) 1996
* 
* call greg2jul(gregdate) for julian day
* call jul2greg(juldate) to convert julian day to gregorian date
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
* Is trunc(exp) better/faster than epx%1 ??
*
* Notes:
* Because of the change to Gregorian calendar,
* Thursday Oct. 4,1582, is followed by Friday Oct. 15, 1582.
* Entering these dates will produce correct, but odd, results:
* 10/5/1582 is julian day 2299161.
* Julian day 2299161 when converted to gregorian will return
* 10/15/1582...this is normal, and correct, AFAIK
*****************************************************************/
/* sample main to try code */
parse arg mm '/' dd '/' yy   /* must put in full year- eg 1999 */
jul= greg2jul( mm,dd,yy)
say 'Stardate:' jul

greg = jul2greg(jul)
say greg 'is a' whatday(jul,'text')

DST=todst(yy)
std=TOstd(yy)
say 'In' yy||', DST starts on:' WHATDAY(dst,'t')||',' jul2greg(dst)
say 'In' yy||', EST starts on:' WHATDAY(std,'t')||',' jul2greg(std)

if isleap(yy) then 
  say yy 'is a leap year.'
else
  say yy 'is not a leap year.'

return

/*********************************************/
/* Adapted from 'Numerical Recipes In C'     */
/* Cambridge Press                           */
/* Adaptation by Kurt Spaugh, Softlynks Inc. */
/* Comments omitted. Some Math Buddah figured*/
/* this out. It just works. Go Figure.       */
/*********************************************/
greg2jul: procedure
do
  parse arg mm,id,iyyy
  igreg=(15+31*(10+12*1582))

  jy=iyyy;
  if jy = 0 then
  do
    say "there is no year 0"
    exit 255
  end /* do */
  if jy < 0 then jy=jy+1
  if mm > 2 then jm=mm+1
  else
  do
     jy=jy-1
     jm=mm+13
  end /* do */
  jul=(365.25*jy)%1+(30.6001*jm)%1+id+1720995
  if( id+31*(mm+12*iyyy) >= igreg) then
  do
     ja=(.01*jy)%1
     jul=jul+(2-ja+(0.25*ja)%1)
  end /* do */
  return jul
end
/****************************************************************/
/*jul2greg(juldate)  Also adapted from 'Numerical Recipes in C' */
/*Adaptation by Kurt Spaugh, Softlynks Inc.                     */ 
/****************************************************************/
jul2greg: procedure 
do
   igreg=2299161
   parse arg julian
   if julian  >= igreg then
   do
      jalpha=(((julian-1867216)-0.25)/36524.25)%1
      ja=julian+1+jalpha-(0.25*jalpha)%1
   end /* do */
   else
     ja=julian
   jb=ja+1524
   jc=(6680+((jb-2439870)-122.1)/365.25)%1
   jd=(365*jc+(0.25*jc))%1
   je=(((jb-jd)/30.6001))%1
   id=jb-jd-(30.6001*je)%1
   mm=je-1
   if(mm>12) then
     mm=mm-12
   iyyy=jc-4715
   if( mm>2) then
     iyyy=iyyy-1
   if( iyyy <= 0 ) then
     iyyy=iyyy-1
   return mm||'/'||id||'/'||iyyy
end /* do */

whatday:procedure
parse arg jul,mode	/* if mode='' then just the remainder is returned */
 x=(jul+1)//7
 if mode \= '' then
 select
   when x=0 then return 'Sunday'
   when x=1 then return 'Monday'
   when x=2 then return 'Tuesday'
   when x=3 then return 'Wednesday'
   when x=4 then return 'Thursday'
   when x=5 then return 'Friday'
   when x=6 then return 'Saturday'
 end
 else
   return x

/*
*  when is first Sunday in April? 
*/
ToDST:procedure        
do
   parse arg year
   day1=greg2jul(4,1,year)
   x=whatday(day1,'');
   if(x > 0) then
     x=7-x
   return day1+x
end /* do */

/*
*  when is last Sunday in October?
*/
ToSTD: procedure        
do
   parse arg year
   day31=greg2jul(10,31,year)
   x=whatday(day31,'');
   return day31-x
end /* do */

IsLeap: procedure
do
  parse arg year
  if year = -1 then
    adder=2
  else
     adder=1
  if greg2jul(1,1,year+adder)-greg2jul(1,1,year) = 366 then
/*  if greg2jul(1,1,year+1)-greg2jul(1,1,year) = 366 then*/
    return 1
  return 0
end





