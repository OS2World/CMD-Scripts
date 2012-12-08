/********************************************************************************/
/*                              						*/
/* irxradio.cmd - Internet Rexx Radio version 1.4  by Wolfgang Reinken    	*/
/* last update: June 22nd 2007							*/
/*						                                */
/* irxradio is a text based frontend for playing sound streams with mplayer.exe */
/*          as backend.								*/
/* irxradio's look and feel is similar to an old style radio with vacuum tubes.	*/
/* 						                                */
/* - disclaimer - 								*/
/* this program comes with absolutely no guarantees. any problems, side effects,*/
/* or whatever is your responsibility.				                */
/*						                                */
/* Comments are welcome: wolfgang.reinken@t-online.de			        */
/*										*/
/********************************************************************************/
"@mode 90,35"		/* text screen 90 columns, 35 rows */

signal on HALT name Abort

/* ---------------------------------------------------------------------------- */
/* paint static parts of radio front						*/
/* ---------------------------------------------------------------------------- */
call SysCurState "OFF"
call charout ,'1b'X'[0;37;40m'	/* background black, foreground white 	*/
call SysCls			/* blank screen				*/

/* 						*/
/* paint the wooden chassis of the radio	*/
/* 						*/
call charout ,'1b'X'[0;30;41m'	/* background dark red */
call SysCurPos 0, 0; call charout ,copies('±',90)
call SysCurPos 1, 0; call charout ,copies('±',90)
do i=2 to 32
  call SysCurPos i,  0; call charout ,'±±±±'
  call SysCurPos i, 86; call charout ,'±±±±'
end
call SysCurPos 33, 0; call charout ,copies('±',90)
call SysCurPos 34, 0; call charout ,copies('±',89)

/* 						*/
/* paint the bright wooden frames at the front	*/
/* 						*/
call charout ,'1b'X'[1;30;43m'	/* background dark yellow, foreground gray */
call SysCurPos 2, 4; call charout ,copies('±',82)
do i=3 to 31
  call SysCurPos i,  4; call charout ,'±±'
  call SysCurPos i, 84; call charout ,'±±'
end
call SysCurPos 15, 4; call charout ,copies('±',82)
call SysCurPos 32, 4; call charout ,copies('±',82)

/* 						*/
/* paint the loudspeaker area			*/
/* 						*/
call charout ,'1b'X'[1;33;43m'	/* background dark yellow, foreground yellow */
do i=3 to 14
  call SysCurPos i, 6; call charout ,copies('∞±',39)
end
call SysCurPos 5, 31; call charout ,' ÕÕÕÕÕÕÕIÕRÕXÕRÕAÕDÕIÕOÕÕÕÕÕÕ '
 

/* 						*/
/* paint the keys and key descriptions		*/
/* 						*/
call SysCurPos 32, 28; call charout ,copies('€€€€›',7)
call charout ,'1b'X'[1;33;40m'	/* background black, foreground yellow */
call SysCurPos 31, 28; call charout ,copies('‹‹‹‹ ',7)
call SysCurPos 30, 28; call charout ,' Qu   He   Di   ƒ      ƒ   In '

/* ---------------------------------------------------------------------------- */
/* initialize global variables							*/
/* ---------------------------------------------------------------------------- */
PID=0			/* procedd ID of mplayer.exe				*/
ICYinfo=''		/* ICY info string (rad by mplayer.exe)			*/
disp='D'		/* scale brightness dark (radio state switched off) */
stdisp=0		/* station display off */
key=" "
lastkey=" "
station=''
keydelay=0
p=10			/* Scale position (overridden by irxradio.ini) 		*/

/* ---------------------------------------------------------------------------- */
/* read initial files (irxradio.cfg and irxradio.ini)				*/
/* ---------------------------------------------------------------------------- */
call ReadConfig
call ReadIni

/* ---------------------------------------------------------------------------- */
/* paint variable parts of radio front						*/
/* ---------------------------------------------------------------------------- */
call MakeScale		/* configured by irxradio.cfg */
call DispEye
call DispPointer

/* ---------------------------------------------------------------------------- */
/* load utilities								*/
/* ---------------------------------------------------------------------------- */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs
call rxfuncadd 'rxuinit','rxu','rxuinit'
signal on syntax name termrxu
call rxuinit
call RxFuncAdd 'RxExtra', 'RxExtras', 'RxExtra'
signal on syntax name termrxextras
call RxExtra 'Load'
signal off syntax
'@detach mplayer.exe 1>nul 2>nul'
if rc=1 then signal TermMplayer

/* ---------------------------------------------------------------------------- */
/* MAIN CYCLE (ends with key "Q" pressed (quit radio) 				*/
/* ---------------------------------------------------------------------------- */
do while key<>"Q"
  /* -------------------------------------------------------------------------- */
  /* get info of pressed key							*/
  /* -------------------------------------------------------------------------- */
  KeyStr = RxKbdCharIn(nowait)	/* information of last pressed key	*/
  Key=translate(word(KeyStr,words(KeyStr)-5))	/* ascii key code	*/
  Keys=translate(word(KeyStr,words(KeyStr)-4))	/* key scan code	*/
  Keysk=word(KeyStr,words(KeyStr)-2)		/* Byte contains shift key info */
  if substr(KeyStr,2,3)='   ' then Key=' '	/* space bar pressed	*/
  SKpr=substr(x2b(right(Keysk,4,'0')),15,1)=1|substr(x2b(right(Keysk,4,'0')),16,1)=1      /* Shift Key gedrÅckt? */

  if keys="4D" then key="R"	/* right arrow pressed */
  if keys="4B" then key="L"	/* left arrow pressed  */

  if keydelay=0 then		/* release radio arrow keys */
  do
    call charout ,'1b'X'[1;33;40m'	/* background black, foreground yellow 	*/
    call SysCurPos 31, 53; call charout ,"‹‹‹‹ "  /* radio right arrow key	*/
    call SysCurPos 31, 43; call charout ,"‹‹‹‹ "  /* radio left arrow key	*/
  end

  /* -------------------------------------------------------------------------- */
  /* process info of pressed key						*/
  /* -------------------------------------------------------------------------- */
  select			
    when key="H" | keys="3B" then
      /* ---------------------------------------------------------------------- */
      /* display help								*/
      /* ---------------------------------------------------------------------- */
      do
        call charout ,'1b'X'[1;33;40m'	/* background black, foreground yellow 	*/
        call SysCurPos 31, 33; call charout ,"     "  /* radio help key		*/
        call syssleep 1
	'@start view irxradio.hlp'
        call SysCurPos 31, 33; call charout ,"‹‹‹‹ "  /* radio help key		*/
      end
    when keys="4D" then
      /* ---------------------------------------------------------------------- */
      /* scale pointer to the right						*/
      /* ---------------------------------------------------------------------- */
      do
        if lastkey<>"R" then
        do
          call charout ,'1b'X'[1;33;40m' /* bg black, fg yellow */
          call SysCurPos 31, 53; call charout ,"     " 
			/* radio right arrow key pressed	*/
        end
        keydelay=15	/* wait 15 cycles to release radio right arrow key */
        call ClearPointer
        if p<79 then p=p+1
        call DispPointer
      end
    when keys="4B" then
      /* ---------------------------------------------------------------------- */
      /* scale pointer to the left						*/
      /* ---------------------------------------------------------------------- */
      do
        if lastkey<>"L" then
        do
          call charout ,'1b'X'[1;33;40m'  	/* bg black, fg yellow */
          call SysCurPos 31, 43; call charout ,"     "
					/* radio left arrow key pressed	*/
        end
        keydelay=15	/* wait 15 cycles to release radio left arrow key */
        call ClearPointer
        if p>10  then p=p-1
        call DispPointer
      end
    when key="I" & disp="D" then
      /* ---------------------------------------------------------------------- */
      /* turn radio on (internet)						*/
      /* ---------------------------------------------------------------------- */
      do
        call charout ,'1b'X'[1;33;40m'  /* bg black, fg yellow */
        call SysCurPos 31, 58; call charout ,"     "
					/* radio "internet" key pressed		*/
        call Syssleep 2     /* wait 2 seconds for "warming up the vacuum tubes"	*/
        Disp='L'			/* brightness of scale --> high		*/
        call DispScale
        call DispPointer
        call syssleep 1 /* wait 1 second for "warming up the magic eye"		*/
        call DispEye
      end
    when (key=" " | Keys="50" | key="0d"x ) & disp<>"D"  then
      /* ---------------------------------------------------------------------- */
      /* start playing								*/
      /* ---------------------------------------------------------------------- */
      do
        call charout ,'1b'X'[1;33;40m'  /* bg black, fg yellow */
        call SysCurPos 31, 48; call charout ,"     "
        do i=19 to 29
          if SysTextScreenRead(i,p-2,5)="‹‹‹‹‹" then
          do j=p-3 to 10 by -1
            c=SysTextScreenRead(i,j,1)
            if c2d(c)<160 
              then station=c||station
              else j=1
          end
        end
        if length(station)>0 then
        do
          call SysCurPos 31, 53; call charout ,"‹‹‹‹ "
          call SysCurPos 31, 43; call charout ,"‹‹‹‹ "
          station=strip(station)
          call play station
        end
        else
        do
          call charout ,'1b'X'[1;33;40m'  /* bg black, fg yellow */
          call SysCurPos 31, 48; call charout ,"‹‹‹‹ "
        end
      end

    /* ------------------------------------------------------------------------ */
    /* switch station display on and off					*/
    /* ------------------------------------------------------------------------ */
    when key="D" then call DispRemoveDisplay

    /* ------------------------------------------------------------------------ */
    /* turn radio off								*/
    /* ------------------------------------------------------------------------ */
    when key="Q" then call SwitchOff

    otherwise
  end
  lastkey=key
  Call RxNap 10				      /* cycle delay 0.01s		*/
  if keydelay>0 then keydelay=keydelay-1      /* count down delay for releasing */
					      /* radio arrow keys		*/
end					/* END MAIN CYCLE			*/

/* ---------------------------------------------------------------------------- */
/* clean up the program and end							*/
/* ---------------------------------------------------------------------------- */
call WriteIni			/* save program state */

call charout ,'1b'X'[0;37;40m'	/* background black   */
call SysCls

exit

/********************************************************************************/
/* Create and display the radio scale 						*/
/* - process the values of irxradio.cfg						*/
/* - find correct positions for station name (ShortName) and station bar ‹‹‹‹‹  */ 
/********************************************************************************/
MakeScale:
  i=19				/* first scale line    	*/
  j=10  			/* left scale position 	*/
  imax=26			/* last scale line	*/
  /* background black, foreground yellow */
  if disp='D' then call charout ,'1b'X'[0;33;40m' /* bg black, fg dark yellow 	*/
  if disp='L' then call charout ,'1b'X'[1;33;40m' /* bg black, fg yellow 	*/
  if disp='R' then call charout ,'1b'X'[1;33;40m' /* bg black, fg yellow 	*/

  do k=1 to ShortName.0		/* cycle per entry in irxradio.cfg		*/
    LenShortName=length(ShortName.k)+8 	/* 8 = 5 bytes station bar + 1 space left + 2 spces right */ 
    if j+LenShortName>80 then 	/* no space on actual scale line left 	*/
    do
      i=i+1			/* next scale line			*/
      select
	when i>imax then leave		/* config file is too long	*/
        when i-19<5 then j=10-19+i	/* initial left position 	*/
        when i-19>4 then j=10-24+i	/* in scal line			*/
        otherwise
      end
    end
    do l=19 to i-1		/* check if position of station bar is already used above */
      if pos(" ‹‹‹‹‹",SysTextScreenRead(l,j+length(ShortName.k),6))=1 then 
      do			/* if used then ... */
        j=j+1			/* ... increment left position  */
        l=18			/* ... restart comparisn	*/
      end
    end
    call SysCurPos i, j; say ShortName.k" ‹‹‹‹‹"  /* display station name and station bar */
    j=j+LenShortName
  end
return

/********************************************************************************/
/* Display radio scale created by MakeScal in different brightness		*/
/********************************************************************************/
DispScale:
  if disp='D' then call charout ,'1b'X'[0;33;40m'
  if disp='L' then call charout ,'1b'X'[1;33;40m'
  if disp='R' then call charout ,'1b'X'[1;33;40m'
  do i=19 to 29
    c=SysTextScreenRead(i,10,74)
    call SysCurPos i, 10; call charout ,c
  end
return

/********************************************************************************/
/* Display radio scale pointer at position p					*/
/********************************************************************************/
DispPointer:
  if disp='D' then call charout ,'1b'X'[0;31;40m'      /* bg black, fg dark red */
  if disp='L' then call charout ,'1b'X'[1;31;40m'      /* bg black, fg red 	*/
  if disp='R' then call charout ,'1b'X'[1;31;40m'      /* bg black, fg red 	*/
  do i=19 to 27
    c=SysTextScreenRead(i,p,1)			/* read screen character	*/
    call SysCurPos i, p; call charout ,c	/* display in (dark) red	*/
  end
return

/********************************************************************************/
/* Clear radio scale pointer at position p					*/
/********************************************************************************/
ClearPointer:
  if disp='D' then call charout ,'1b'X'[0;33;40m'   /* bg black, fg dark yellow */
  if disp='L' then call charout ,'1b'X'[1;33;40m'   /* bg black, fg yellow 	*/
  if disp='R' then call charout ,'1b'X'[1;33;40m'   /* bg black, fg yellow 	*/
  do i=19 to 27
    c=SysTextScreenRead(i,p,1)			/* read screen character	*/
    call SysCurPos i, p; call charout ,c	/* display in (dark) yellow	*/
  end
return

/********************************************************************************/
/* Display magic eye in one of 3 states:					*/
/* - disp='D' (radio switched off): colour gray					*/
/* - disp='L' (radio switched on):  colour dark green				*/
/* - disp='R' (radio playing):      colour light green				*/
/********************************************************************************/
DispEye:
  if disp='D' then call charout ,'1b'X'[1;30;43m'  /* bg dark yellow, fg gray	    */
  if disp='L' then call charout ,'1b'X'[0;32;43m'  /* bg dark yellow, fg dark green */
  if disp='R' then call charout ,'1b'X'[0;32;43m'  /* bg dark yellow, fg dark green */
  call SysCurPos 11, 10; call charout ,' ‹‹‹‹‹‹‹‹‹‹‹‹‹ '
  call SysCurPos 12, 10; call charout ,' ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ '
  call charout ,'1b'X'[1;32;43m'		  /* bg dark yellow, fg light green */
  if disp='L' then 
  do
    call SysCurPos 11, 17; call charout ,'‹'
    call SysCurPos 12, 17; call charout ,'ﬂ'
  end
  if disp='R' then 
  do
    call SysCurPos 11, 12; call charout ,'‹‹‹‹‹‹‹‹‹‹‹'
    call SysCurPos 12, 12; call charout ,'ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ'
  end
return

/********************************************************************************/
/* Process irxradio.cfg								*/
/* Syntax of irxradio.cfg:							*/
/* - line starting at line position 1: 		station name (ShortName)	*/
/* - following line (first character = " "):	station url			*/
/*   - if following line is missing, only station name is displayed at scale	*/
/*   - following is used al parameter for mplayer.exe (peceeded by "-playlist"	*/
/*						       if necessary)		*/
/********************************************************************************/
ReadConfig:
  i=0
  do while lines("irxradio.cfg")>0
    c=linein("irxradio.cfg")
    if left(c,1)<>" " then 
    do
      i=i+1
      ShortName.i=strip(c)
    end
    else url.i=strip(c)
  end
  ShortName.0=i
  call linein "irxradio.cfg"	/* close */
return

/********************************************************************************/
/* Read inifile irxradio.ini and get initial values				*/
/* - scalepos : position of scale pointer in previos run of the program		*/
/********************************************************************************/
ReadIni:
  i=0
  do while lines("irxradio.ini")>0
    c=linein("irxradio.ini")
    if word(c,1)="scalepos " then p=word(c,2)
    i=i+1
  end
  call linein "irxradio.ini"	/* close */
return

/********************************************************************************/
/* Write values of variables to inifile irxradio.ini				*/
/* - scalepos : actual position of scale pointer 				*/
/********************************************************************************/
WriteIni:
  '@DEL irxradio.ini 1>nul 2>nul '
  call lineout "irxradio.ini","scalepos "p
  call linein "irxradio.ini"	/* close */
return

/********************************************************************************/
/* Display station display on the loudspeaker area				*/
/* - first line:  station name (centerd)					*/
/* - second line: ICY-info "Titlename" if available (centerd, cut if longer 40)	*/
/********************************************************************************/
DispStDisplay:
  call charout ,'1b'X'[0;30;43m'	   	/* bg dark yellow, fg black	*/
  call SysCurPos  9, 30; call charout ,' ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ '
  call SysCurPos 10, 30; call charout ,' €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ '
  call SysCurPos 11, 30; call charout ,' €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ '
  call SysCurPos 12, 30; call charout ,' ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ '
  if disp="R" then 
  do
    call charout ,'1b'X'[1;32;40m'	   	/* bg black, fg light green	*/
    lpos=(40-length(station))%2
    call SysCurPos 10, 31+lpos; call charout ,station
    lpos=(40-length(ICYinfo))%2
    if lpos<0 then lpos=0
    ICYlen=length(ICYinfo)
    ICYpointer=1
    ICYdelay=10
    call SysCurPos 11, 31+lpos
    if lpos=0 
      then call charout ,left(ICYinfo,40)
      else call charout ,ICYinfo
  end
return

/********************************************************************************/
/* Remove station display from the loudspeaker area				*/
/********************************************************************************/
RemoveStDisplay:
  call charout ,'1b'X'[1;33;43m'		/* bg dark yellow, fg yellow */
  do i=9 to 12
    call SysCurPos i, 30; call charout ,copies('∞±',22)
  end
return

/********************************************************************************/
/* Play a radio station (url) with mplayer.exe					*/
/********************************************************************************/
Play:
  ICYinfoOld=ICYinfo
  do i=1 to Shortname.0
    /* ShortName was read from irxradio.cfg				*/
    /* station is text left of station bar of actual pointer position 	*/
    if Shortname.i=station then urli=url.i
  end
  rc=stream('irxradio.wrk','c','open')	/* test if workfile is writable */	
  if rc<>'READY:' 
    then call SysSleep 2		/* prevents a NOT READY error of the following detach command */
    else rc=stream('irxradio.wrk','c','close')

  /* -------------------------------------------------------------------------- */
  /* start mplayer.exe in background, redirect output to workfile irxradio.wrk	*/
  /* -------------------------------------------------------------------------- */
  '@detach mplayer.exe -quiet 'urli' 1>irxradio.wrk 2>nul '
  PID=GetPID()		/* process id of mplayer.exe for later kill operation	*/
  PIDa=PID
  if PID>0 then 
  do
    disp="R"
  end
  call DispEye
  if stdisp=1 then call DispStDisplay
  cdelay=1			   /* delay to reduce system load while playing */

  /* -------------------------------------------------------------------------- */
  /* PLAY CYCLE									*/
  /* cycle until ...								*/ 
  /* - operator intervention (press a key) or 					*/
  /* - end of transmission (PID=0)						*/
  /* -------------------------------------------------------------------------- */
  do until (c=' ' | s='4B'| s='4D' | s='50' | c='Q' | c='0d'x | disp='L') 
    KeyStr = RxKbdCharIn(nowait)		/* input of one character w/o echo; with analysing scan code */
    c=translate(word(KeyStr,words(KeyStr)-5))	/* ascii key code	*/
    s=translate(word(KeyStr,words(KeyStr)-4))	/* key scan code	*/
    sk=word(KeyStr,words(KeyStr)-2)		/* Byte contains shift key info */
    if substr(KeyStr,2,3)='   ' then c=' '	/* space bar pressed	*/
    SKpr=substr(x2b(right(sk,4,'0')),15,1)=1|substr(x2b(right(sk,4,'0')),16,1)=1      /* Shift Key gedrÅckt? */

    /* Switch display on / off */
    if c='D' then call DispRemoveDisplay

    /* display help								*/
    if c="H" | s="3B" then
    do
      call charout ,'1b'X'[1;33;40m'	/* background black, foreground yellow 	*/
      call SysCurPos 31, 33; call charout ,"     "  /* radio help key		*/
      call syssleep 1
      '@start view irxradio.hlp'
      call SysCurPos 31, 33; call charout ,"‹‹‹‹ "  /* radio help key		*/
    end

    /* display long ICYinfo	*/
    if stdisp=1 & ICYlen>40 then
    do
      select
        when ICYdelay>0 then ICYdelay=ICYdelay-1 
        when ICYdelay=0 & ICYlen-ICYpointer>=40 then 
          do
            ICYpointer=ICYpointer+1
            call SysCurPos 11, 31
            call charout ,substr(ICYinfo,ICYpointer,40)
          end
        when ICYdelay=0 & ICYlen-ICYpointer=39 then ICYdelay=ICYdelay-1
        when ICYdelay<0 & ICYdelay>-10 then ICYdelay=ICYdelay-1
        when ICYdelay<(-9) then 
          do 
            ICYdelay=10
            ICYpointer=1
            call SysCurPos 11, 31
            call charout ,substr(ICYinfo,1,40)
          end
        otherwise
      end
    end

    /* Test if mplayer.exe is still running */
    PID=GetPID()
    if PID<>PIDa then
    do
      if PID=0
        then disp='L'
        else disp='R'
      call DispEye
      if stdisp=1 then call DispStDisplay
    end

    /* refresh ICYinfo and stationdisplay every 4s (20*200ms) */
    if cdelay<1 then					
    do
      openrc = RxOpen('wrkf.', 'irxradio.wrk', 'O', 'n')    	/* open mplayer listing 	*/
      if openrc=0 & wrkf.2='Existed' then		    	/* in shared mode	    	*/	
      do
        hfile=wrkf.1					/* file handle for further operation	*/
        dosrc = RxDosRead(wrkc, hfile, 100000 )		/* read the whole file (max 100000 chars*/
        icypos=lastpos('ICY',wrkc)			/* pos. of last ICY-info		*/
        if icypos>0 then
        do
          cc=substr(wrkc,icypos)
          ICYinfo=substr(cc,pos('StreamTitle=',cc)+13)
          ICYinfo=left(ICYinfo,pos("';",ICYinfo)-1)	/* get streamtitle			*/
        end
        else ICYinfo=''
        closerc = RxCloseH(hfile)
        drop wrkc					/* very important if file grows!!!	*/
      end

      if ICYinfoOld<>ICYinfo & stdisp=1 then 		
      do
        call DispStDisplay
        ICYinfoOld=ICYinfo
      end
      cdelay=20
    end
    else cdelay=cdelay-1

    Call RxNap 200
  end			/* END PLAY CYCLE */

  /* -------------------------------------------------------------------------- */
  /* clean up playing routine							*/
  /* -------------------------------------------------------------------------- */
  station=''
  disp="L"
  ICYinfo=''
  killrc = RxKillProcess(PID)
  call charout ,'1b'X'[1;33;40m'
  call SysCurPos 31, 48; call charout ,"‹‹‹‹ "
  call DispEye
  if stdisp=1 then call DispStDisplay
  if c='Q' then
  do
    call SwitchOff
    key="Q"
  end
return

/********************************************************************************/
/* Get the process id of mplayer.exe						*/
/********************************************************************************/
GetPID:
      GetPIDNr=0
      call RxQProcStatus proc.
      do przi=1 to proc.0p.0
        if right(proc.0p.przi.6,11)="MPLAYER.EXE" then GetPIDNr=x2d(proc.0p.przi.1)
      end
return GetPIDNr

/********************************************************************************/
/* Display station display if switched off					*/
/* Remove station display if switched on					*/
/********************************************************************************/
DispRemoveDisplay:
      do
        select
          when stdisp=0 then 
            do
              call charout ,'1b'X'[1;33;40m'
              call SysCurPos 31, 38; call charout ,"     "
              stdisp=1
              call DispStDisplay
            end
          when stdisp=1 then 
            do
              call charout ,'1b'X'[1;33;40m'
              call SysCurPos 31, 38; call charout ,"‹‹‹‹ "
              stdisp=0
              call RemoveStDisplay
            end
          otherwise
        end
      end
return

/********************************************************************************/
/* Switch off radio:								*/
/* - release all radio keys							*/
/* - switch scale and magic eye to dark brightness 				*/
/* - kill mplayer.exe (stop playing)						*/
/* - switch station display off							*/
/********************************************************************************/
SwitchOff:
      do
        call charout ,'1b'X'[1;33;40m'
        call SysCurPos 31, 28; call charout ,"     "
        call SysCurPos 31, 33; call charout ,copies('‹‹‹‹ ',6)
        Disp='D'
        call DispScale
        call DispPointer
        call DispEye
        killrc = RxKillProcess(PID)
        call RemoveStDisplay
        call Syssleep 1
        call charout ,'1b'X'[1;33;40m'
        call SysCurPos 31, 28; call charout ,"‹‹‹‹ "
        call Syssleep 2
      end
return


/********************************************************************************/
/* End program if <CTRL>-C was pressed						*/
/********************************************************************************/
Abort:
  call SwitchOff
  /* -------------------------------------------------------------------------- */
  /* clean up the program and end						*/
  /* -------------------------------------------------------------------------- */
  call WriteIni				/* save program state */

  call charout ,'1b'X'[0;37;40m'	/* background black   */
  call SysCls
  exit

TermRXU:
  call charout ,'1b'X'[0;37;40m'	/* background black   */
  call SysCurPos 28, 10; call charout ,"Library RXU is missing"
  call SysCurPos 29, 10; call charout ,"Please obtain from: http://hobbes.nmsu.edu/pub/os2/dev/rexx/rxu1a.zip"
  call SysCurPos 33, 5
  exit

TermRxExtras:
  call charout ,'1b'X'[0;37;40m'	/* background black   */
  call SysCurPos 28, 10; call charout ,"Library RXEXTRAS is missing"
  call SysCurPos 29, 10; call charout ,"Please obtain from: http://hobbes.nmsu.edu/pub/os2/dev/rexx/rxx1g.zip"
  call SysCurPos 33, 5
  exit 

TermMplayer:
  call charout ,'1b'X'[0;37;40m'	/* background black   */
  call SysCurPos 28, 10; call charout ,"Program MPLAYER is missing"
  call SysCurPos 29, 10; call charout ,"Please obtain from: http://users.on.net/~psmedley/os2ports/mplayer.html"
  call SysCurPos 33, 5
  exit 
