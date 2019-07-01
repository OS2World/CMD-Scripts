/********************************************************************************/
/*                              						*/
/* irxradio.cmd - Internet Rexx Radio version 2.0.  by Wolfgang Reinken    	*/
/* last update: March 16th 2019							*/
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
arg parm
"@mode 90,35"		/* text screen 90 columns, 35 rows */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

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

/* ---------------------------------------------------------------------------- */
/* initialize global variables							*/
/* ---------------------------------------------------------------------------- */
PID=0			/* procedd ID of mplayer.exe				*/
ICYinfo=''		/* ICY info string (rad by mplayer.exe)			*/
disp='D'		/* scale brightness dark (radio state switched off) 	*/
key=" "
lastkey=" "
station=''
keydelay=0
p=10			/* Scale position (overridden by irxradio.ini) 		*/
cachesize=0		/* standard cache size of mplayer			*/
proxy=""		/* proxy server 					*/
MoveLeft=0; MoveRight=0
recmode=0
recdelay=0

/* ---------------------------------------------------------------------------- */
/* read initial files (irxradio.cfg and irxradio.ini)				*/
/* ---------------------------------------------------------------------------- */
call ReadConfig
call ReadIni
call MakeRecDir
StationPos=p		/* Initialwert */

/* ---------------------------------------------------------------------------- */
/* paint variable parts of radio front						*/
/* ---------------------------------------------------------------------------- */
call MakeScale		/* configured by irxradio.cfg */
call DispEye
call DispRec
call DispPointer
call DispStDisplay

/* ---------------------------------------------------------------------------- */
/* load utilities								*/
/* ---------------------------------------------------------------------------- */
call rxfuncadd 'rxuinit','rxu','rxuinit'
signal on syntax name termrxu
call rxuinit
call rxfuncadd 'MousInit', 'RxMous', 'MousInit'
call MousInit 

signal off syntax
'@detach mplayer.exe 1>nul 2>nul'
if rc>0 then signal TermMplayer

/* ---------------------------------------------------------------------------- */
/* MAIN CYCLE (ends with key "q" pressed (quit radio key pressed twice)		*/
/* ---------------------------------------------------------------------------- */

if parm="SNAP" then
do
  '@del IRxRadio.snap 1>nul 2>nul'
  elaps=time("E")
  PsnapOld=""
  DsnapOld=""
  RsnapOld=0
  DumpSnap=""
  DISPsnapOld=""
  KEYSsnapOld=""
end

do while key<>"q"
  /* -------------------------------------------------------------------------- */
  /* get info of pressed key							*/
  /* -------------------------------------------------------------------------- */
  if disp<>"P" then call KbdMouse	/* supress input when key "P" pressed in play mode */
  select
    when StationPos<p then
      do
	KeyS="4B"
	call SysSleep 0.01
      end
    when StationPos>p then
      do
	KeyS="4D"
	call SysSleep 0.01
      end
    otherwise
      call RadioKeys		/* Transform mouse actions into keyboard keys 	*/
      if disp<>"P" then call RadioScale 0	   /* Tune radio station if mouseclick was in scale but don't play (0) */
      if keys="4B" & p>10 then Stationpos=p-1
      if keys="4D" & p<79 then Stationpos=p+1
  end

  if keys="4D" then key="R"	/* right arrow pressed */
  if keys="4B" then key="L"	/* left arrow pressed  */
  if keys="01" then key="Q"	/* ESC   key   pressed */

  if keydelay=0 then		/* release radio arrow keys */
  do
    call charout ,'1b'X'[1;33;40m'	/* background black, foreground yellow 	*/
    call SysCurPos 31, 53; call charout ,"‹‹‹‹ "  /* radio right arrow key	*/
    call SysCurPos 31, 48; call charout ,"‹‹‹‹ "  /* radio left arrow key	*/
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
    when key="P" then
      /* ---------------------------------------------------------------------- */
      /* Play file mode								*/
      /* ---------------------------------------------------------------------- */
      do
	do
          call charout ,'1b'X'[1;33;40m'	/* background black, foreground yellow 	*/
          call SysCurPos 31, 38; call charout ,"     "  /* radio play key		*/
          call SysCurPos 31, 43; call charout ,copies('‹‹‹‹ ',4)
          if disp="D" then call Syssleep 2 /* wait 2 seconds for "warming up the vacuum tubes"	*/
	  disp="P"
          call DispScale
          call DispPointer
          call DispEye
          call syssleep 1 		/* wait 1 second until play file	*/
	  call PlayFile
	end
      end
    when keys="4D" & disp<>"P" then
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
    when keys="4B" & disp<>"P" then
      /* ---------------------------------------------------------------------- */
      /* scale pointer to the left						*/
      /* ---------------------------------------------------------------------- */
      do
        if lastkey<>"L" then
        do
          call charout ,'1b'X'[1;33;40m'  	/* bg black, fg yellow */
          call SysCurPos 31, 48; call charout ,"     "
					/* radio left arrow key pressed	*/
        end
        keydelay=15	/* wait 15 cycles to release radio left arrow key */
        call ClearPointer
        if p>10  then p=p-1
        call DispPointer
      end
    when key="I" & (disp="D" | disp="P") then
      /* ---------------------------------------------------------------------- */
      /* turn radio on (internet)						*/
      /* ---------------------------------------------------------------------- */
      do
        call charout ,'1b'X'[1;33;40m'   /* bg black, fg yellow 		*/
        call SysCurPos 31, 58; call charout ,"     "
					 /* radio "internet" key pressed	*/
        call SysCurPos 31, 33; call charout ,copies('‹‹‹‹ ',5)
        if disp="D" then 
	do
	  call SnapOut
	  call Syssleep 2 /* wait 2 seconds for "warming up the vacuum tubes"	*/
	end
        Disp='L'			 /* brightness of scale --> high	*/
        call DispScale
        call DispPointer
        call syssleep 1 	/* wait 1 second for "warming up the magic eye"	*/
        call DispEye
	call SnapOut
      end

      when key="R" then
        do
          call charout ,'1b'X'[1;33;40m'		/* background black, foreground yellow 	*/
          call SysCurPos 31, 43; call charout ,"     "  /* radio record key			*/
	  call syssleep 1
          call charout ,'1b'X'[1;33;40m'		/* background black, foreground yellow 	*/
          call SysCurPos 31, 43; call charout ,"‹‹‹‹ "  /* radio record key			*/
        end
    /* ------------------------------------------------------------------------ */
    /* turn radio off								*/
    /* ------------------------------------------------------------------------ */
    when key="Q" then call SwitchOff

    otherwise
      if disp<>"D" & disp<>"P" then
      do
        /* -------------------------------------------------------------------- */
        /* start playing if scale pointer 					*/
        /* -------------------------------------------------------------------- */
        call charout ,'1b'X'[1;33;40m'  /* bg black, fg yellow */
        do i=19 to 29
          if SysTextScreenRead(i,p-2,5)="‹‹‹‹‹" then
          do j=p-3 to 10 by -1
            c=SysTextScreenRead(i,j,1)
            if c2d(c)<160 
              then station=c||station
              else j=1
          end
        end
        if length(station)>0 then	/* scale pointer is in the middle of a stion bar */
        do
          station=strip(station)
          call play station
        end
      end
  end
  lastkey=key
  call SysSleep 0.01			      /* cycle delay 0.01s		*/
  if keydelay>0 then keydelay=keydelay-1      /* count down delay for releasing */
					      /* radio arrow keys		*/
  call SnapOut

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
  imax=29			/* last scale line	*/
  /* background black, foreground yellow */
  if disp='D' then call charout ,'1b'X'[0;33;40m' /* bg black, fg dark yellow 	*/
  if disp='L' then call charout ,'1b'X'[1;33;40m' /* bg black, fg yellow 	*/
  if disp='R' then call charout ,'1b'X'[1;33;40m' /* bg black, fg yellow 	*/
  if disp='P' then call charout ,'1b'X'[1;33;40m' /* bg black, fg yellow 	*/

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

  call SysCurPos 30, 28; call charout ,' Qu   He   Pl   Re  ƒ   ƒ  In '

return

/********************************************************************************/
/* Display radio scale created by MakeScale in different brightness		*/
/********************************************************************************/
DispScale:
  if disp='D' then call charout ,'1b'X'[0;33;40m'
  if disp='L' then call charout ,'1b'X'[1;33;40m'
  if disp='R' then call charout ,'1b'X'[1;33;40m'
  if disp='P' then call charout ,'1b'X'[1;33;40m'
  do i=19 to 29
    c=SysTextScreenRead(i,10,74)
    call SysCurPos i, 10; call charout ,c
  end
  call SysCurPos 30, 28; call charout ,' Qu   He   Pl   Re             In '
  if disp='D' then call charout ,'1b'X'[0;33;40m' /* bg black, fg dark yellow 	*/
  if disp='L' then call charout ,'1b'X'[1;33;40m' /* bg black, fg yellow 	*/
  if disp='R' then call charout ,'1b'X'[1;33;40m' /* bg black, fg yellow 	*/
  if disp='P' then call charout ,'1b'X'[0;33;40m' /* bg black, fg dark yellow 	*/
  call SysCurPos 30, 48; call charout ,'ƒ'
  call SysCurPos 30, 55; call charout ,'ƒ'
  if disp='D' then call charout ,'1b'X'[0;33;40m' /* bg black, fg dark yellow 	*/
  if disp='L' then call charout ,'1b'X'[0;33;40m' /* bg black, fg dark yellow 	*/
  if disp='R' then call charout ,'1b'X'[0;33;40m' /* bg black, fg dark yellow 	*/
  if disp='P' then call charout ,'1b'X'[1;33;40m' /* bg black, fg yellow 	*/
  call SysCurPos 30, 50; call charout ,''
  call SysCurPos 30, 54; call charout ,''
return

/********************************************************************************/
/* Display radio scale pointer at position p					*/
/********************************************************************************/
DispPointer:
  if disp='D' then call charout ,'1b'X'[0;31;40m'      /* bg black, fg dark red */
  if disp='L' then call charout ,'1b'X'[1;31;40m'      /* bg black, fg red 	*/
  if disp='R' then call charout ,'1b'X'[1;31;40m'      /* bg black, fg red 	*/
  if disp='P' then call charout ,'1b'X'[1;31;40m'      /* bg black, fg red 	*/
  do i=19 to 29
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
  if disp='P' then call charout ,'1b'X'[1;33;40m'   /* bg black, fg yellow 	*/
  do i=19 to 29
    c=SysTextScreenRead(i,p,1)			/* read screen character	*/
    call SysCurPos i, p; call charout ,c	/* display in (dark) yellow	*/
  end
return

/********************************************************************************/
/* Display magic eye in one of 3 states:					*/
/* - disp='D' (radio switched off): colour gray					*/
/* - disp='P' (play file mode):	    colour gray					*/
/* - disp='L' (radio switched on):  colour dark green				*/
/* - disp='R' (radio playing):      colour light green				*/
/********************************************************************************/
DispEye:
  if disp='D' then call charout ,'1b'X'[1;30;43m'  /* bg dark yellow, fg gray	    */
  if disp='L' then call charout ,'1b'X'[0;32;43m'  /* bg dark yellow, fg dark green */
  if disp='R' then call charout ,'1b'X'[0;32;43m'  /* bg dark yellow, fg dark green */
  if disp='P' then call charout ,'1b'X'[1;30;43m'  /* bg dark yellow, fg gray	    */
  call SysCurPos 11, 10; call charout ,' ‹‹‹‹‹‹‹‹‹‹‹‹‹ '
  call SysCurPos 12, 10; call charout ,' ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ '
  call charout ,'1b'X'[1;32;43m'		  /* bg dark yellow, fg light green */
  if disp='L' then 
  do
    /*call SysCurPos 11, 17; call charout ,'‹'*/
    /*call SysCurPos 12, 17; call charout ,'ﬂ'*/
    call SysCurPos 11, 11; call charout ,'‹'
    call SysCurPos 11, 23; call charout ,'‹'
    call SysCurPos 12, 11; call charout ,'ﬂ'
    call SysCurPos 12, 23; call charout ,'ﬂ'
  end
  if disp='R' then 
  do
    /*call SysCurPos 11, 12; call charout ,'‹‹‹‹‹‹‹‹‹‹‹'*/
    /*call SysCurPos 12, 12; call charout ,'ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ'*/
    call SysCurPos 11, 11; call charout ,'‹‹‹‹‹‹'
    call SysCurPos 11, 18; call charout ,'‹‹‹‹‹‹'
    call SysCurPos 12, 11; call charout ,'ﬂﬂﬂﬂﬂﬂ'
    call SysCurPos 12, 18; call charout ,'ﬂﬂﬂﬂﬂﬂ'
  end
return

/********************************************************************************/
/* Display record indicator in one of 3 states:					*/
/* - recmode 0: 		colour gray					*/
/* - recmode 1, recdelay>=0	    colour light red				*/
/* - recmode 1, recdelay<0	    colour darkred				*/
/********************************************************************************/
DispRec:
  if recmode=0 then call charout ,'1b'X'[1;30;43m'  		 /* bg dark yellow, fg gray	 */
  if recmode=1 & recdelay>=0 then call charout ,'1b'X'[1;31;43m' /* bg dark yellow, fg light red */
  if recmode=1 & recdelay<0 then call charout ,'1b'X'[0;31;43m'  /* bg dark yellow, fg dark red  */
  call SysCurPos 11, 76; call charout ,' ‹‹ '
  call SysCurPos 12, 76; call charout ,' ﬂﬂ '
  if recmode=1 then
  do 
    if recdelay<-4 
      then recdelay=5
      else recdelay=recdelay-1
  end
return

/********************************************************************************/
/* Process irxradio.cfg								*/
/* Syntax of irxradio.cfg:							*/
/* - line starting with #<keyword>		configuration line		*/
/* - line starting at line position 1 (w/o #): 	station name (ShortName)	*/
/* - following line (first character = " "):	station url			*/
/*   - if following line is missing, only station name is displayed at scale	*/
/********************************************************************************/
ReadConfig:
  i=0
  do while lines("irxradio.cfg")>0
    c=linein("irxradio.cfg")
    select
      when translate(word(c,1))="#PROXY" 	/* line with proxy server url	*/
	then proxy="http_proxy://"word(c,2)"/"
      when translate(word(c,1))="#CACHE" then	/* line with cache parameter	*/
        if word(c,2) >= 32 & word(c,2) <= 3000 
    	  then cachesize=word(c,2)
          else cachesize=0
      when left(c,1)="#" 			/* line with invalid parameter	*/
        then nil
      when left(c,1)<>" " then			/* line with station name	*/
        do
          i=i+1
          ShortName.i=strip(c)
        end
      otherwise					/* line with station url	*/
        url.i=strip(c)
    end  /* select */
  end
  ShortName.0=i
  RC = STREAM("irxradio.cfg",'C','CLOSE')
  /* call linein "irxradio.cfg"  close */
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
  RC = STREAM("irxradio.ini",'C','CLOSE')
return

/********************************************************************************/
/* Make record directory IRxRadio.REC						*/
/********************************************************************************/
MakeRecDir:

  call SysFileTree "IRxRadio.REC", recdir, "DO"
  if recdir.0=0 then
  do
    call SysMkDir "IRxRadio.REC"
  end    

return

/********************************************************************************/
/* Write values of variables to inifile irxradio.ini				*/
/* - scalepos : actual position of scale pointer 				*/
/********************************************************************************/
WriteIni:
  '@DEL irxradio.ini 1>nul 2>nul '
  call lineout "irxradio.ini","scalepos "p
  RC = STREAM("irxradio.ini",'C','CLOSE')
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
/* Play a radio station (url) with mplayer.exe					*/
/********************************************************************************/
Play:

  recmode=0
  stopplay=0
  ICYinfoOld=ICYinfo
  do i=1 to Shortname.0
    /* ShortName was read from irxradio.cfg				*/
    /* station is text left of station bar of actual pointer position 	*/
    if Shortname.i=station then 
    do
      if word(url.i,1)="-playlist" 
	then do; playlst="-playlist"; n=2; end
        else do; playlst=""; n=1; end
      urli=word(url.i,n)
      /*caci=word(url.i,n+1)*/
      ICYinfoCFG=subword(url.i,n+1)
    end
  end
  rc=stream('irxradio.wrk','c','open')	/* test if workfile is writable */	
  if rc<>'READY:' 
    then call SysSleep 2		/* prevents a NOT READY error of the following detach command */
    else rc=stream('irxradio.wrk','c','close')

  /* -------------------------------------------------------------------------- */
  /* start mplayer.exe in background, redirect output to workfile irxradio.wrk	*/
  /* -------------------------------------------------------------------------- */
  if cachesize>0 
    then cacheparm="-cache "cachesize
    else cacheparm=""
  '@detach mplayer.exe -ao kai:dart -quiet 'cacheparm' 'playlst' 'proxy||urli' 1>irxradio.wrk 2>nul '
  PID=GetPidF()		/* process id of mplayer.exe for later kill operation	*/
  PIDa=PID
  if parm="SNAP" then
  do
    datum=insert("-",insert("-",date("S"),4),7)"_"translate(time("N"),"-",":")
    DumpSNAP="SNAP\"datum"_"SNAP
    '@detach mplayer.exe -ao kai:dart -quiet 'cacheparm' 'playlst' 'proxy||urli' -dumpstream -dumpfile 'DumpSNAP' 1>nul 2>nul '
  end
  call DispEye
  call DispStDisplay
  cdelay=10			   /* delay to reduce system load while playing */

  /* -------------------------------------------------------------------------- */
  /* PLAY CYCLE									*/
  /* cycle until ...								*/ 
  /* - operator intervention (press a key) or 					*/
  /* - end of transmission (PID=0)						*/
  /* -------------------------------------------------------------------------- */
  ICYincr = 1              					/* scroll-direction */
  do until (stopplay=1 | KeyS='4B'| KeyS='4D' | Key="P" | Key='Q' ) 
    call KbdMouse
    call RadioKeys
    select
/*
      when MoveLeft>0 then
        do
	  KeyS="4B"
	  MoveLeft=MoveLeft-1
	  call SysSleep 0.01
        end
      when MoveRight>0 then
        do
	  KeyS="4D"
	  MoveRight=MoveRight-1
	  call SysSleep 0.01
        end
      when KeyS="4B" then MoveLeft=1
      when KeyS="4D" then MoveRight=1
*/
      when StationPos<p then
        do
	  KeyS="4B"
	  call SysSleep 0.01
        end
      when StationPos>p then
        do
	  KeyS="4D"
	  call SysSleep 0.01
        end
      when KeyS="4B" & p>10 then StationPos=p-1
      when KeyS="4D" & p<79 then Stationpos=p+1
      otherwise
        call RadioScale 1   /* Tune radio station if mouseclick was in scale and start playing (1) */
    end

    if keydelay>0 then keydelay=keydelay-4 
    if keydelay<1 then					/* release radio arrow keys 		*/
    do
      call charout ,'1b'X'[1;33;40m'			/* background black, foreground yellow 	*/
      call SysCurPos 31, 53; call charout ,"‹‹‹‹ "  	/* radio right arrow key		*/
      call SysCurPos 31, 48; call charout ,"‹‹‹‹ "  	/* radio left arrow key			*/
      keydelay=0
    end

    if disp="L" then
    do
      openrc = RxOpen('wrkf.', 'irxradio.wrk', 'O', 'n')    	/* open mplayer listing 	*/
      if openrc=0 & wrkf.2='Existed' then		    	/* in shared mode	    	*/	
      do
        hfile=wrkf.1					/* file handle for further operation	*/
        dosrc = RxDosRead(wrkc, hfile, 100000 )		/* read the whole file (max 100000 chars*/
        playpos=pos('Starting playback...',wrkc)	/* pos. of playing-info			*/
        if playpos>0 then
        do
	  disp='R'
	  call DispEye
	  call DispStDisplay
        end
        closerc = RxCloseH(hfile)
        drop wrkc					/* very important if file grows!!!	*/
      end
    end

    if KeyS="01" then Key="Q"				/* ESC   key   pressed 			*/  

    /* display help										*/
    if key="H" | KeyS="3B" then
    do
      call charout ,'1b'X'[1;33;40m'			/* background black, foreground yellow 	*/
      call SysCurPos 31, 33; call charout ,"     "  	/* radio help key			*/
      call syssleep 1
      '@start view irxradio.hlp'
      call SysCurPos 31, 33; call charout ,"‹‹‹‹ "  	/* radio help key			*/
    end

    /* start and stop record radio station							*/
    if key="R" then
    do 
      if recmode=0 then
      do
	recdelay=5					/* counter for blinking record indicator */
        call charout ,'1b'X'[1;33;40m'		/* background black, foreground yellow 	*/
        call SysCurPos 31, 43; call charout ,"     "  /* radio record key			*/
	recmode=1
	datum=insert("-",insert("-",date("S"),4),7)"_"translate(time("N"),"-",":")
	stationR=translate(station,"_"," ")
	DumpFile="IRxRadio.REC\"datum"_"stationR
	'@detach mplayer.exe -ao kai:dart -quiet 'cacheparm' 'playlst' 'proxy||urli' -dumpstream -dumpfile 'DumpFile' 1>nul 2>nul '
  	PIDR=GetPidL()			/* process id of mplayer.exe for later kill operation	*/
      end
      else
      do
        call charout ,'1b'X'[1;33;40m'		/* background black, foreground yellow 	*/
        call SysCurPos 31, 43; call charout ,"‹‹‹‹ "  /* radio record key			*/
	recmode=0
	killrc = RxKillProcess(PIDR)
      end
    end

    /* display long ICYinfo    		 							*/
    if Disp="R" & ICYlen>40 then
    do
      call charout ,'1b'X'[1;32;40m'	   		/* bg black, fg light green		*/
      select
        when ICYdelay>0 then ICYdelay=ICYdelay-1
        when ICYdelay=0 & ICYlen-ICYpointer>=40 then
          do
            ICYpointer=ICYpointer+ICYincr
            if ICYpointer < 1 then,
             do
              ICYdelay=10
              ICYpointer=1
              ICYincr=1
             end
            call SysCurPos 11, 31
            call charout ,substr(ICYinfo,ICYpointer,40)
          end
        when ICYdelay=0 & ICYlen-ICYpointer=39 then ICYdelay=ICYdelay-1
        when ICYdelay<0 & ICYdelay>-10 then ICYdelay=ICYdelay-1
        when ICYdelay<(-9) then
          do
            ICYdelay=1
            ICYincr=-1
            ICYpointer=ICYpointer+ICYincr
            call SysCurPos 11, 31
            call charout ,substr(ICYinfo,ICYpointer,40)
          end
        otherwise
      end
    end

    /* Test if mplayer.exe is still running */
    PID=GetPidF()

    if PID<>PIDa then
    do

      if PID=0 then
      do
	disp='L'
	stopplay=1
      end
      call DispEye
      call DispStDisplay
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
        if icypos>0 & ICYinfoCFG="" then
        do
          cc=substr(wrkc,icypos)
          ICYinfo=substr(cc,pos('StreamTitle=',cc)+13)
          ICYinfo=left(ICYinfo,pos("';",ICYinfo)-1)	/* get streamtitle			*/
        end
	else
	do
	  /*ICYinfo=''*/
	  ICYinfo=ICYinfoCFG
	end
        closerc = RxCloseH(hfile)
        drop wrkc					/* very important if file grows!!!	*/
      end

      if ICYinfoOld<>ICYinfo then 		
      do
        call DispStDisplay
        ICYinfoOld=ICYinfo
      end
      cdelay=20
    end
    else cdelay=cdelay-1
    recdelay=recdelay-1					/* for blinking record indicator */
    call disprec

    call SysSleep 0.2
    if Key='Q' | KeyS="01" then call SwitchOff

    call SnapOut
  end			/* END PLAY CYCLE */


  /* -------------------------------------------------------------------------- */
  /* clean up playing routine							*/
  /* -------------------------------------------------------------------------- */
  station=''
  if disp="R" then disp="L"
  if key="P" then disp="P"
  ICYinfo=''
  do until PID=0
    killrc = RxKillProcess(PID)
    call syssleep 0.05
    PID=GetPidF()
    if parm="SNAP" then DumpSnap=""
  end
  call charout ,'1b'X'[1;33;40m'
  call DispEye
  call DispStDisplay

  /* terminate record mode */
  call charout ,'1b'X'[1;33;40m'	/* background black, foreground yellow 	*/
  call SysCurPos 31, 43; call charout ,"‹‹‹‹ "  /* radio record key	*/
  recmode=0
  call disprec

  if c='Q' then
  do
    call SwitchOff
    key="Q"
  end

  /*call SnapOut*/

return

/********************************************************************************/
/* Play recorded files								*/
/********************************************************************************/
PlayFile:

  call SysFileTree "IRxRadio.REC\*", "RecFile", "FO"
  RFnum=RecFile.0
  if RFnum>0 then
  do
    call charout ,'1b'X'[1;32;40m'	   	/* bg black, fg light green	*/
    call SysCurPos 10, 32; call charout ,left(filespec("Name",RecFile.RFnum),38)
  end
  if RFnum>1 then
  do
    RFnum1=RFnum-1
    call charout ,'1b'X'[0;32;40m'	   	/* bg black, fg dark green	*/
    call SysCurPos 11, 32; call charout ,left(filespec("Name",RecFile.RFnum1),38)
  end

  call snapout

  /* ------------------------------------------------------------------------ */
  /* start mplayer.exe in background, redirect output to workfile irxradio.wrk*/
  /* ------------------------------------------------------------------------ */
  '@detach mplayer.exe -ao kai:dart -quiet 'RecFile.RFnum' 1>nul 2>nul '
  PID=GetPidF()	/* process id of mplayer.exe for later kill operation	*/
  PIDa=PID

  /* -------------------------------------------------------------------------- */
  /* PLAY CYCLE									*/
  /* cycle until ...								*/ 
  /* - operator intervention (press a key) or 					*/
  /* - end of transmission (PID=0)						*/
  /* -------------------------------------------------------------------------- */
  do until (Key="I" | Key='Q' | KeyS="01") 
    call KbdMouse
    call RadioKeys
    select
      when KeyS="48" then 
	do
	  if RFnum<RecFile.0 then RFnum=RFnum+1
	  killrc = RxKillProcess(PID)
          call charout ,'1b'X'[1;33;40m'  	/* bg black, fg yellow */
          call SysCurPos 31, 48; call charout ,"     "	/* radio left arrow key pressed	*/
	  call snapout
	  call syssleep 0.5
	  '@detach mplayer.exe -ao kai:dart -quiet 'RecFile.RFnum' 1>nul 2>nul '
	  PID=GetPidF()	/* process id of mplayer.exe for later kill operation	*/
	  PIDa=PID
          call charout ,'1b'X'[1;33;40m'  	/* bg black, fg yellow */
          call SysCurPos 31, 48; call charout ,"‹‹‹‹ "  /* radio left arrow key pressed	*/
	  if RFnum>0 then
	  do
	    call charout ,'1b'X'[1;32;40m'	   	/* bg black, fg light green	*/
	    call SysCurPos 10, 32; call charout ,left(filespec("Name",RecFile.RFnum),38)
	  end
	  if RFnum>1 then
	  do
	    RFnum1=RFnum-1
	    call charout ,'1b'X'[0;32;40m'	   	/* bg black, fg dark green	*/
	    call SysCurPos 11, 32; call charout ,left(filespec("Name",RecFile.RFnum1),38)
	  end
	  else 
	  do
	    call SysCurPos 11, 32; call charout ,left(" ",38)
	  end
	end
      when KeyS="50" then 
	do
	  if RFnum>1 then RFnum=RFnum-1
	  killrc = RxKillProcess(PID)
          call charout ,'1b'X'[1;33;40m'  	/* bg black, fg yellow */
          call SysCurPos 31, 53; call charout ,"     "	/* radio left arrow key pressed	*/
	  call snapout
	  call syssleep 0.5
	  '@detach mplayer.exe -ao kai:dart -quiet 'RecFile.RFnum' 1>nul 2>nul '
	  PID=GetPidF()	/* process id of mplayer.exe for later kill operation	*/
	  PIDa=PID
          call charout ,'1b'X'[1;33;40m'  	/* bg black, fg yellow */
          call SysCurPos 31, 53; call charout ,"‹‹‹‹ "  /* radio left arrow key pressed	*/
	  if RFnum>0 then
	  do
	    call charout ,'1b'X'[1;32;40m'	   	/* bg black, fg light green	*/
	    call SysCurPos 10, 32; call charout ,left(filespec("Name",RecFile.RFnum),38)
	  end
	  if RFnum>1 then
	  do
	    RFnum1=RFnum-1
	    call charout ,'1b'X'[0;32;40m'	   	/* bg black, fg dark green	*/
	    call SysCurPos 11, 32; call charout ,left(filespec("Name",RecFile.RFnum1),38)
	  end
	  else 
	  do
	    call SysCurPos 11, 32; call charout ,left(" ",38)
	  end
	end
      otherwise
    end

    /* display help								*/
    if key="H" | KeyS="3B" then
    do
      call charout ,'1b'X'[1;33;40m'	/* background black, foreground yellow 	*/
      call SysCurPos 31, 33; call charout ,"     "  /* radio help key		*/
      call syssleep 1
      '@start view irxradio.hlp'
      call SysCurPos 31, 33; call charout ,"‹‹‹‹ "  /* radio help key		*/
    end

    /* record key pressed							*/
    if key="R" then				    /* Dummy operation 		*/
    do
      call charout ,'1b'X'[1;33;40m'		/* background black, foreground yellow 	*/
      call SysCurPos 31, 43; call charout ,"     "  /* radio record key			*/
      call syssleep 1
      call charout ,'1b'X'[1;33;40m'		/* background black, foreground yellow 	*/
      call SysCurPos 31, 43; call charout ,"‹‹‹‹ "  /* radio record key			*/
    end

    /* Test if mplayer.exe is still running */
    PID=GetPidF()
    if PID<>PIDa & RFnum>0 then
    do
      call charout ,'1b'X'[0;32;40m'	   	/* bg black, fg dark green	*/
      call SysCurPos 10, 32; call charout ,left(filespec("Name",RecFile.RFnum),38)
    end

    call SysSleep 0.2

    call SnapOut

  end

  /* -------------------------------------------------------------------------- */
  /* clean up playing routine							*/
  /* -------------------------------------------------------------------------- */
  do until PID=0
    killrc = RxKillProcess(PID)
    call syssleep 0.05
    PID=GetPidF()
  end
  call charout ,'1b'X'[1;33;40m'
  call DispStDisplay
  call charout ,'1b'X'[1;33;40m'	/* background black, foreground yellow 	*/
  call SysCurPos 31, 38; call charout ,"‹‹‹‹ "  /* radio play key		*/

  if Key='Q' | KeyS="01" then
  do
    call SwitchOff
    key="Q"
  end
  else
  do
    call charout ,'1b'X'[1;33;40m'	/* background black, foreground yellow 	*/
    call SysCurPos 31, 58; call charout ,"     "  /* radio internet key		*/
  end

  call SnapOut

return

/********************************************************************************/
/* Scan Mouse and keyboard							*/
/* if key pressed: enthÑlt KeyS contains the character, Keys the key's ScanCode	*/
/* if Mousekey 1 or 2 was pressed, enthÑlt MouseLine contains the line number	*/
/********************************************************************************/
KbdMouse:
  KeyStr = RxKbdCharIn(nowait)		/* information of last pressed key	*/
  if substr(KeyStr,2,2)='  ' 
    then do;Key='00'X;KeyS=word(KeyStr,2); end
    else do;Key=word(KeyStr,2);KeyS=word(KeyStr,3);end
  if substr(KeyStr,2,3)='   ' then Key=' '
  Key=translate(Key)
  KeyS=translate(KeyS)
  if word(KeyStr,words(KeyStr))>0 then action=1		/* no key pressed	*/
  MousePos  = ClickPos()				/* scan mouse action	*/
  MouseLine = word(MousePos,1)
  MouseCol  = word(MousePos,2)
return

/********************************************************************************/
/* Transform mouse actions into keyboard keys					*/
/********************************************************************************/
RadioKeys:
  if MouseLine>30 & MouseLine<33 then 
  select
    when MouseCol>27 & MouseCol<32 then Key="Q"			/* quit  	*/
    when MouseCol>32 & MouseCol<37 then Key="H"			/* help  	*/
    when MouseCol>37 & MouseCol<42 then Key="P"			/* play file 	*/
    when MouseCol>42 & MouseCol<47 then Key="R"			/* record	*/
    when MouseCol>47 & MouseCol<52 & Disp<>"P" then KeyS="4B"	/* left  	*/
    when MouseCol>47 & MouseCol<52 & Disp="P"  then KeyS="48"	/* up    	*/
    when MouseCol>52 & MouseCol<57 & Disp<>"P" then KeyS="4D"	/* right 	*/
    when MouseCol>52 & MouseCol<57 & Disp="P"  then KeyS="50"	/* down  	*/
    when MouseCol>57 & MouseCol<62 then Key="I"			/* internet	*/
    otherwise
  end
return

/********************************************************************************/
/* Tune into radio station with mouseclick					*/
/********************************************************************************/
RadioScale:

  arg shift
  if MouseLine>18 & MouseLine<27 then 
  do
    MouseChar=SysTextScreenRead(MouseLine,MouseCol,1)
    if MouseChar="‹" then
    do
      StationArea=SysTextScreenRead(MouseLine,MouseCol-4,5)
      StationPos=MouseCol-3+pos("‹",StationArea)
    end
  end
return

/********************************************************************************/
/* Get the process id of first mplayer.exe instance				*/
/********************************************************************************/
GetPidF:
      GetPIDNr=0
      call RxQProcStatus proc.
      do przi=1 to proc.0p.0
        if right(proc.0p.przi.6,11)="MPLAYER.EXE" then GetPIDNr=x2d(proc.0p.przi.1)
      end
return GetPIDNr

/********************************************************************************/
/* Get the process id of last mplayer.exe instance				*/
/********************************************************************************/
GetPidL:
      GetPIDNr=0
      call RxQProcStatus proc.
      do przi=proc.0p.0 to 1 by -1
        if right(proc.0p.przi.6,11)="MPLAYER.EXE" then GetPIDNr=x2d(proc.0p.przi.1)
      end
return GetPIDNr

/********************************************************************************/
/* Switch off radio:								*/
/* - release all radio keys							*/
/* - switch scale and magic eye to dark brightness 				*/
/* - kill mplayer.exe (stop playing)						*/
/* - switch station display off							*/
/********************************************************************************/
SwitchOff:
      do
	if disp="D" then key="q"	/* terminate main cycle	*/
        call charout ,'1b'X'[1;33;40m'
        call SysCurPos 31, 28; call charout ,"     "
        call SysCurPos 31, 33; call charout ,copies('‹‹‹‹ ',6)
        Disp='D'
	recmode=0
        call DispScale
        call DispPointer
        call DispEye
	call DispStDisplay
	call DispRec
        killrc = RxKillProcess(PID)
	if parm="SNAP" then DumpSNAP=""
	call SnapOut
        call Syssleep 1
        call charout ,'1b'X'[1;33;40m'
        call SysCurPos 31, 28; call charout ,"‹‹‹‹ "
        call Syssleep 2
      end
return


SnapOut:

    if parm="SNAP" then
    do
      Psnap=p
      Dsnap=disp
      if recmode=0 then Rsnap=0
      if recmode=1 & recdelay>=0 then Rsnap=1
      if recmode=1 & recdelay<0  then Rsnap=2
      DISPsnap=SysTextScreenRead(10,31,40)"/"SysTextScreenRead(11,31,40)
      KEYSsnap=SysTextScreenRead(31,28,35)
      if Psnap<>PsnapOld | Dsnap<>DsnapOld | Rsnap<>RsnapOld | DISPsnap<>DISPsnapOld | KEYSsnap<>KEYSsnapOld then
      do
        elaps=time("E")
        if disp="R" 
	  then call lineout "IRxRadio.snap",elaps" "Psnap" "Dsnap" "Rsnap" "DumpSNAP
          else call lineout "IRxRadio.snap",elaps" "Psnap" "Dsnap" "Rsnap
        call lineout "IRxRadio.snap"," "DISPsnap
        call lineout "IRxRadio.snap"," "KEYSsnap
        PsnapOld=Psnap
        DsnapOld=Dsnap
	RsnapOld=Rsnap
        DISPsnapOld=DISPsnap
        KEYSsnapOld=KEYSsnap
      end
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
  call SysCurPos 29, 10; call charout ,"Please obtain the most recent from: http://hobbes.nmsu.edu/cgi-bin/h-browse?dir=/pub/os2/apps/mmedia/video/players"
  call SysCurPos 33, 5
  exit 
