/* DISCLAIMER:  This software is provided "AS IS" without any warranty of any
kind, either expressed or implied.  USE IT AT YOUR OWN RISK.

The USBBS Lister was written specifically to interface with the national
USBBS list published by Darwin.

You will also need a copy of the USBBS list, USBBS???.ZIP, available everywhere
or from the source at 916-929-7511 (BOBsBBS).

Put BBSLIST.CMD in your Max directory, and put the help file and USBBS list
anywhere you want them, just be sure to define them below.

Modify your Max Menu.ctl file as follows:

     Xtern_Run Maxpipe.exe_%P_BBSLIST.CMD   normal  "Darwin BBS list"

Your users will be presented with three (3) options. #1 will allow a search
of the USBBSXXX.LST.  It's a string search so no wildcards are needed.  
#2 just displays some info about the BBS List.  And #3 quit's back to the BBS.



Copywrite 1993 by Bill Esposito.  This program is FREEWARE, just let me know
how you like it. (The Cereal Port BBS, 1:132/152, 603-899-3335)

*/
l=1
y=1

bbsfile='g:\max\usbbs\usbbs103.lst' /* enter the full path/name of the
                                        USBBS list file */
file='g:\max\usbbs\usbbslst.hlp'    /* enter the full file/path the help file */

'@echo off'
call RxFuncAdd 'SysloadFuncs','RexxUtil','Sysloadfuncs'
call sysloadfuncs

menu:
/* ansi on */
cls
noclr:
say '[1;36m'
say '               [33m      USBBS List Viewer'
say '             [32m             v1.0'
say '                [35m     by Bill Esposito'
say
say '             [32m    '
say ''
say '              1.  Search the USBBS List'
say
say '              2.  Info about the USBBS List' 
SAY
say '              3.  Quit back to BBS'
pull todo
if todo=1 then call find
if todo=2 then call read
if todo=3 then exit
if todo=Q then exit
call menu
/* find */
find:
count=0
i=0
say
say 'What do you want to search for? (any text or numbers,[35m no wildcards[32m)'
say '                                (ex. "NH" "603" "Esposito" "Espo" "Cereal")'
say
pull what
if what='' then call menu
call sysfilesearch what, bbsfile, 'file.'
head:
say 'PHONE        STATE  CITY      SYSOP          T/S      |    NAME, FEATURES'
say '-------------------------------------------------------------------------'  
return: 
do i=1 to file.0
say file.i
count = count + 1

if count=20 then call more1
end
say 'Press <enter> to continue'
pull enter

call menu
/* Read */
read: 
x=1
loop:
y='1'

newq = rxqueue('create')
oq = rxqueue('set',newq)
l=l+y
linein(file,1,0)
loop2:
do until x > 23
say ''linein(file)''
if lines(file)=''0'' then say 'Press the <ENTER> key to continue'
if lines(file)=''0'' then pull enter
if lines(file)=''0'' then call qdel
x=x+y
end
more:
  x=1
   say 'more? (Y,n)'
    pull yn
    if yn='N' then call qdel
     else
call loop2
call qdel
qdel:
call rxqueue 'delete',newq
call rxqueue 'set',oq 
call menu
more1:
say 'more? (Y,n)'
pull yn
if yn='N' then call menu
say 'PHONE        STATE  CITY      SYSOP          T/S      |    NAME, FEATURES'
say '-------------------------------------------------------------------------'  
count = 0
return
