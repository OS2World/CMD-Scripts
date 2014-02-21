/********************************************************************************/
/*                              						*/
/* m!.cmd  Beta version 0.7.2  by Wolfgang Reinken        			*/
/* last update: May 3rd 2007							*/
/*						                                */
/* m! is a text based frontend for playing MIDI files				*/
/* It is written in REXX using the MCI REXX functions or timidity.exe		*/
/* M!'s look and feel is similar to the great mpeg player z!           		*/
/* 						                                */
/* - disclaimer - 								*/
/* this program comes with absolutely no guarantees. any problems, side effects,*/
/* or whatever is your responsibility.				                */
/*						                                */
/* Comments are welcome: wolfgang.reinken@t-online.de			        */
/*										*/
/********************************************************************************/

"@echo off"
"mode 80,25"

/* ---------------------------------------------------------------------------- */
/* meaning of some global variables:     			                */
/*										*/
/* ExeMode		mode of kind playing					*/
/*			 	    0 = use REXX MCI API (if supported by	*/
/*					sound sriver or timidity		*/
/*			 	    1 = use TIMIDITY.EXE (if no driver support)	*/
/* MS			switch "show main screen"				*/
/*			 	    1 = main screen	  			*/
/*			 	    2 = help screen	  			*/
/* KeyStr		return code of RxKbdCharIn				*/
/*         		  return code from KbdCharIn(), and, if zero, 		*/
/* 			  followed by these blank delimited values:		*/
/*       		  1) Character						*/
/*       		  2) Scan Code (hex)					*/
/*       		  3) NLS state (hex)					*/
/*        		  4) NLS shift (hex)					*/
/*       		  5) Shift Key state (hex)				*/
/*       		  6) Millisecond timestamp of keystroke			*/
/* c, plc 		parameter 1) of KeyStr in main or play screen		*/
/* s, pls 		parameter 2) of KeyStr in main or play screen		*/
/* sk, plsk 		parameter 5) of KeyStr in main or play screen		*/
/* ai			first directory entry to show				*/
/* ci			position of bar-cursor					*/
/* ix			lokale help variable for pointer			*/
/* iSong		current song to play					*/
/* FilTag		playlist vector						*/
/* FilTag.0		size of playlist vector = number of tagged songs	*/
/* ---------------------------------------------------------------------------- */



/* ---------------------------------------------------------------------------- */
/* load utilities								*/
/* ---------------------------------------------------------------------------- */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs
call rxfuncadd 'rxuinit','rxu','rxuinit'
call rxuinit 
Call RXFUNCADD "mciRxInit", "MCIAPI", "mciRxInit"

Call mciRxInit

signal on HALT name Abort

/* -------------------------------------------------------------- */
/* create screen						  */
/* -------------------------------------------------------------- */

f0='1b'X'[0;37;40m'			/* gray on black          */
f1='1b'X'[1;31;41m'			/* light red on dark red  */
f2='1b'X'[1;37;41m'			/* white on dark red 	  */
f3='1b'X'[1;33;41m'			/* yellow on dark red 	  */
f4='1b'X'[0;37;41m'			/* gray on dark red 	  */
f5='1b'X'[0;30;41m'			/* black on dark red      */
f6='1b'X'[1;31;44m'			/* light red on dark blue */
f7='1b'X'[0;37;44m'			/* gray on dark blue      */
f8='1b'X'[0;30;44m'			/* black on dark blue     */
f9='1b'X'[1;31;40m'			/* red on black	          */
f10='1b'X'[1;34;40m'			/* blue on black	  */
f11='1b'X'[1;37;40m'			/* white on black	  */
f12='1b'X'[1;36;40m'			/* cyan on black	  */
f13='1b'X'[1;32;40m'			/* green on black	  */
f14='1b'X'[1;32;41m'			/* green on dark red	  */
f15='1b'X'[1;32;44m'			/* green on blue	  */
f16='1b'X'[0;34;40m'			/* dark blue on black     */
f17='1b'X'[0;31;40m'			/* dark red on black      */
f18='1b'X'[0;36;40m'			/* dark cyan on black     */
f19='1b'X'[1;30;40m'			/* dark gray on black     */
f20='1b'X'[1;36;41m'			/* cyan on dark red	  */
f21='1b'X'[0;36;41m'			/* dark cyan on dark red  */
f22='1b'X'[1;37;44m'			/* white on dark blue 	  */
f23='1b'X'[1;35;40m'			/* pink on black	  */
f24='1b'X'[0;35;40m'			/* magenta on black       */
f25='1b'X'[1;34;41m'			/* blue on dark red	  */


  v.0=f19'úúúúúúúúúú'
  v.5=f18'ú'f19'úúúúúúúúú'
 v.10=f18'ş'f19'úúúúúúúúú'
 v.15=f18'şú'f19'úúúúúúúú'
 v.20=f18'şş'f19'úúúúúúúú'
 v.25=f18'şşú'f19'úúúúúúú'
 v.30=f18'şşş'f19'úúúúúúú'
 v.35=f18'şşşú'f19'úúúúúú'
 v.40=f18'şşşş'f19'úúúúúú'
 v.45=f18'şşşşú'f19'úúúúú'
 v.50=f18'şşşşş'f19'úúúúú'
 v.55=f18'şşşşş'f13'ú'f19'úúúú'
 v.60=f18'şşşşş'f13'ş'f19'úúúú'
 v.65=f18'şşşşş'f13'şú'f19'úúú'
 v.70=f18'şşşşş'f13'şş'f19'úúú'
 v.75=f18'şşşşş'f13'şşú'f19'úú'
 v.80=f18'şşşşş'f13'şşş'f19'úú'
 v.85=f18'şşşşş'f13'şşş'f9'ú'f19'ú'
 v.90=f18'şşşşş'f13'şşş'f9'ş'f19'ú'
 v.95=f18'şşşşş'f13'şşş'f9'şú'
v.100=f18'şşşşş'f13'şşş'f9'şş'

FilTag.0=0
volume=75		/* default value volume=70%			 	*/
NumMid=0		/* default value midi-files			 	*/
SuchFeld=''		/* default value for compare field SearchDirFileDrive 	*/
PlayForever=0		/* default value switch Play Forever		 	*/
PlayRandom=0		/* default value switch Play Random		 	*/
pauspl=0		/* default value switch pause			 	*/

/* ---------------------------------------------------------------------------- */
/* test the MIDI device								*/
/* ---------------------------------------------------------------------------- */

rc = mciRxSendString('open sequencer alias m shareable wait', 'RetStr', '0', '0')
if rc=5007 		/* invalid device					*/
  then ExeMode=1	/* use TIMIDITY.EXE					*/
  else ExeMode=0	/* use MMOS2						*/
if rc<>0 & rc<>5007 then
do
  MacRC = mciRxGetErrorString(rc, 'ErrStVar')
  say 'OPEN MIDI sequencer: ' ErrStVar
  wt=SysGetKey(noecho)
  exit
end
rc = mciRxSendString('close m wait', 'RetStr', '0', '0')


call SysCurState 'OFF'
call SysCls
call DisplayHead
/* ---------------------------------------------------------------------------- */
/* read and display first directory						*/
/* ---------------------------------------------------------------------------- */

InitDir=directory()
call ReadCurDir
ai=1			/* first directory enty to show				*/
call ShowPWD
call DispCurDir ''
ci=1			/* position of bar cursor				*/
call DispCursBar

/* ---------------------------------------------------------------------------- */
/* main cycle									*/
/* ---------------------------------------------------------------------------- */

MS=1						/* switch "show main screen"   	*/
						/* 	    1=main screen	*/
						/* 	    2=help screen	*/

do until (c='1B'X | c='03'X | c='q') & MS=1
  KeyStr = RxKbdCharIn(wait)		/* input of one character w/o echo; with analysing scan code */
  if substr(KeyStr,2,2)='  ' then 
  do
    c=translate(word(KeyStr,1))			/* character of input	 	*/
    s=translate(word(KeyStr,2))			/* scan code of input		*/
    sk=word(KeyStr,5)
  end
  else 
  do
    c=translate(word(KeyStr,2))			/* character of input	 	*/
    s=translate(word(KeyStr,3))			/* scan code of input		*/
    sk=word(KeyStr,6)
  end
  if substr(KeyStr,2,3)='   ' then c=' '
  SKpr=substr(x2b(right(sk,4,'0')),15,1)=1|substr(x2b(right(sk,4,'0')),16,1)=1      /* Shift Key gedrckt? */
  ix=ai-1+ci
  select
    when MS=2 & s <> '00' then 			/* move to main screen		*/
      do
	MS=1
	call DisplayHead    
	call DispCurDir
	call ShowPWD
	call DispCursBar
        c='00'X /* suppress cancel */
      end
    when ((c>='A' & c<='Z') | (c>='0' & c<='9') | pos(c,':.-_')>0) & SKpr=1 then    /* Buchst., Ziffer mit Shift */
      call SearchDirFileDrive c
    when c='Q' & SKpr=0 then c='q'				/* Q w/o Shift				*/
    when c='L' & SKpr=0 then call LoadPlayList	9,40,f2,f25'.'	/* L w/o Shift				*/
    when c='S' & SKpr=0 then call SavePlayList	9,40,f2,f25'.'	/* S w/o Shift				*/
    when c='C' & SKpr=0 then call ClearPlayList			/* C w/o Shift				*/
    when c='A' & SKpr=0 then call TagUntagAllVerz	/* A w/o Shift (Tag/Untag all)		*/
    when c=' ' & DTyp.ix='F' then call TagUntag 0	/* <SPACE> with MIDI file (Tag/Untag file)	*/
    when c='F' & SKpr=0 then call MCtogForever	/* F w/o Shift (Toggle Play Forever)		*/
    when c='R' & SKpr=0 then call MCtogRandom	/* F w/o Shift (Toggle Random Playback)		*/
    when c='0d'X & DTyp.ix='F' | c='P' & SKpr=0 & FilTag.0>0 then	/* <ENTER> bei MIDI-Datei oder 'P' ohne Shift: Abspielen */
      do
        if SuchFeld<>'' then do; SuchFeld=''; call SysCurPos 23,20; call charout ,f5'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'; end
        if FilTag.0=0 then do; FilTag.0=1; FilTag.1=datei.ix; DTag.ix=1; end
        if PlayRandom=1 then call Mischen
	PS=1
        do until PlayForever=0
          iSong=1
	  do while iSong <= FilTag.0   
	    select
	      when PS=1 then call DisplayHeadPlay iSong		/* state play screen 			*/
	      when PS=0 then do; call DispCurDir FilTag.iSong; call DispCursBar; end /* refresh main screen */
	      otherwise
	    end
	    call PlayMidi FilTag.iSong
	    if FilTag.0=0 | plc='B' then leave
	    iSong=iSong+1
	  end
	end
	if iSong>FilTag.0 | plc='1B'X | plc='Q' then call UntagAll
        call DisplayHead    
	call DispCurDir ''
	call ShowPWD
	call DispCursBar
      end
    when s='4B' then call MCleft			/* <LEFT> 			*/
    when (c='0d'X | s='4D') & DTyp.ix<>'F' then	call MCchdir /* <ENTER> or <RIGHT> with Dir and Drive */
    when s='50' then call MCdown			/* <DOWN>			*/
    when s='48' then call MCup				/* <UP>				*/
    when s='51' then call MCpgdn			/* <PGDN>			*/
    when s='49' then call MCpgup			/* <PGUP>			*/
    when s='47' then call MChome			/* <HOME>			*/
    when s='4F' then call MCend				/* <END>			*/
    when s='3B' then call MChelp			/* move to help screen		*/
    otherwise
  end
end

  call directory InitDir
  call charout ,f0
  call mciRxExit 
exit 

Abort:
  rc = mciRxSendString('close m wait', 'RetStr', '0', '0')
  call directory InitDir
  call charout ,f0
  call mciRxExit 
exit 

ShowPWD:

  /*											*/
  /* display current directory path							*/
  /*											*/
  AktDir=directory()
  call charout ,f1
  call SysCurPos 8,0; call charout ,' Ú'||copies('Ä',76)||'¿ '
  call charout ,f4
  call SysCurPos 8,6; call charout ,' Current Directory: ['Aktdir'] '

return

/* ---------------------------------------------------- */
/* create the vector DATEI.X by adding			*/
/* - subdirectories					*/
/* - MIDI files						*/
/* - local drives					*/
/* ---------------------------------------------------- */

ReadCurDir:

  dn=1							/* number of file entries 	*/
  /*											*/
  /* add subdirectories (DTyp=D)							*/
  /*											*/
  Datei.dn='.. (Parent Directory)'
  DTyp.dn='D'
  call SysFileTree '*', DateiAlle, 'OD'			/* read directories  		*/	
  do lvi=1 to DateiAlle.0
    dn=dn+1
    Datei.dn=DateiAlle.lvi
    DTyp.dn='D'
  end
  /*											*/
  /* add MIDI files (DTyp=F)								*/
  /*											*/
  NumMid=0
  call SysFileTree '*', DateiAlle, 'F'				/* read the files  	*/
  do lvi=1 to DateiAlle.0
    type = ""
    if  SysGetEA(subword(DateiAlle.lvi,5), ".type", "TYPEINFO") = 0 then 
    do
      parse var typeinfo 11 type
    end
    if translate(substr(DateiAlle.lvi,length(DateiAlle.lvi)-3,4))=".MID" then type="MIDI"
    if type="MIDI" then
    do
      dn=dn+1
      NumMid=NumMid+1
      Datei.dn=subword(DateiAlle.lvi,5)
      DSiz.dn=word(DateiAlle.lvi,3)
      if word(DateiAlle.lvi,3)>999 then DSiz.dn=insert('.',DSiz.dn,length(DSiz.dn)-3)
      if word(DateiAlle.lvi,3)>999999 then DSiz.dn=insert('.',DSiz.dn,length(DSiz.dn)-7)
      DTyp.dn='F'
      DTag.dn=0							/* state "untagged"	*/
      do lvj=1 to FilTag.0
        if Datei.dn=FilTag.lvj then DTag.dn=1
      end
    end
  end
  /* number of MIDI files								*/
  call SysCurPos 4,3; call charout ,f5'xxxxx'
  call SysCurPos 4,8-length(NumMid); call charout ,f2||NumMid
  /*											*/
  /* add local drives (DTyp=V)								*/
  /*											*/
  AlleLw=SysDriveMap()
  do lvi=1 to words(AlleLw)
    dn=dn+1
    Datei.dn=word(AlleLw,lvi)
    DTyp.dn='V'
  end
  
return

/* ---------------------------------------------------- */
/* display max. 10 lines of vector DATEI.X		*/
/* - begin with line "ai"				*/
/* - flag of directories, file sizes and drives		*/
/* ---------------------------------------------------- */

DispCurDir:

  parse arg AALied

  do avi=1 to 10
    ix=ai-1+avi
    call SysCurPos 11+avi,5; call charout ,f1||' ³ Ã´ '
    DatNam=filespec('name',Datei.ix)
    DatNam=left(substr(DatNam,1,min(47,length(DatNam)))' 'f5,58,'.')
    select
      when ai-1+avi<=dn & DTyp.ix='D' 
        then call charout ,f4||DatNam'xxx'f4'<Dir>'f5'xxx'
      when ai-1+avi<=dn & DTyp.ix='F' then 
        do
	  call charout ,f4||DatNam'xxxxxxxxxxx'; 
	  call SysCurPos 11+avi,70-length(DSiz.ix)
 	  call charout ,f4||DSiz.ix
	  if DTag.ix=1 then 
	  do
	    call SysCurPos 11+avi,7
	    if AALied=datei.ix then call charout ,f2
			       else call charout ,f14
	    call charout ,'û'
	  end
	end
      when ai-1+avi<=dn & DTyp.ix='V' 
        then call charout ,f4||left(Datei.ix' 'f5,58,'.')'xx'f4'<Drive>'f5'xx'
      otherwise
        call charout ,f4||left(' ',59)
    end
    call SysCurPos 11+avi,70; call charout ,f1||'³  ³ '
  end
return

/* ---------------------------------------------------- */
/* display cursor bar (blue background)			*/
/* ---------------------------------------------------- */

DispCursBar:

  call charout ,f6
  call SysCurPos 11+ci,5
  call charout ,' ³ Ã´'||copies(' ',60)||'³  ³ '
  call charout ,f7
  ix=ai-1+ci
  DatNam=filespec('name',Datei.ix)
  DatNam=left(substr(DatNam,1,min(47,length(DatNam)))' 'f8,58,'.')
  select
    when DTyp.ix='D' then
      do; call SysCurPos 11+ci,11; call charout ,DatNam'xxx'f7'<Dir>'f8'xxx'; end
    when DTyp.ix='F' then 
      do
	call SysCurPos 11+ci,11
	call charout ,DatNam'xxxxxxxxxxx'; 
	call SysCurPos 11+ci,70-length(DSiz.ix)
	call charout ,f7||DSiz.ix
	if DTag.ix=1 then 
	do
	  call SysCurPos 11+ci,7
	  if PlayFile=datei.ix then call charout ,f22
				   else call charout ,f15
	  call charout ,'û'
	end
      end
    when DTyp.ix='V' then
      do; call SysCurPos 11+ci,11; call charout ,left(Datei.ix' 'f8,58,'.')'xx'f7'<Drive>'f8'xx'; end
    otherwise
  end


return

/* ---------------------------------------------------- */
/* reset of old cursor bar to normal color		*/
/* ---------------------------------------------------- */

ResCurBalk:

  call charout ,f1
  call SysCurPos 11+ci,5
  call charout ,' ³ Ã´'||copies(' ',60)||'³  ³ '
  call charout ,f4
  ix=ai-1+ci
  DatNam=filespec('name',Datei.ix)
  DatNam=left(substr(DatNam,1,min(47,length(DatNam)))' 'f5,58,'.')
  select
    when DTyp.ix='D' then
      do; call SysCurPos 11+ci,11; call charout ,DatNam'xxx'f4'<Dir>'f5'xxx'; end
    when DTyp.ix='F' then
      do
	call SysCurPos 11+ci,11
	call charout ,DatNam'xxxxxxxxxxx'; 
	call SysCurPos 11+ci,70-length(DSiz.ix)
	call charout ,f4||DSiz.ix
	if DTag.ix=1 then 
	do
	  call SysCurPos 11+ci,7
	  if PlayFile=datei.ix then call charout ,f2
				   else call charout ,f14
	  call charout ,'û'
	end
      end
    when DTyp.ix='V' then
      do; call SysCurPos 11+ci,11; call charout ,left(Datei.ix' 'f5,58,'.')'xx'f4'<Drive>'f5'xx'; end
    otherwise
  end

return

/* ---------------------------------------------------- */
/* display static information of main screen		*/
/* ---------------------------------------------------- */

DisplayHead:

  call SysCls
  call charout ,f1
  call SysCurPos 24,78
  call charout ,'    '
  call SysCurPos 0,0
  call charout ,' Ú'||copies('Ä',76)||'¿ '
  call charout ,' ³'||copies(' ',76)||'³ '
  call charout ,' À'||copies('Ä',76)||'Ù '
  call charout ,' ÚÄÄÄÄ 'f3'Statistics'f1' ÄÄÄÄ¿'
  call charout ,' ÚÄÄÄÄÄÄ 'f3'Selection Options'f1' ÄÄÄÄ¿'
  call charout ,' ÚÄÄÄÄ 'f3'Play Options'f1' ÄÄÄ¿ '
  call charout ,' ³ 'f5'xxxxx 'f4'MIDI listed'f1'  ³'
  call charout ,' ³   'f2'A'f1'   Ä 'f4'tag/untag 'f2'A'f4'll'f1'       ³'
  call charout ,' ³  'f2'P'f1'  Ä 'f2'P'f4'lay tagged'f1'   ³ '
  call charout ,' ³ 'f5'xxxxx 'f4'MIDI tagged'f1'  ³'
  call charout ,' ³ 'f2'Space'f1' Ä 'f4'tag/untag hilited'f1'   ³'
  call charout ,' ³  'f2'R'f1'  Ä 'f2'R'f4'andom play'f1'   ³ '
  call charout ,' ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
  call charout ,' ³ 'f2'Alt-R'f1' Ä 'f4'recursive tag'f1'       ³'
  call charout ,' ³  'f2'F'f1'  Ä 'f4'play 'f2'F'f4'orever'f1'  ³ '
  call charout ,'                       '
  call charout ,' ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
  call charout ,' ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ '
  call charout ,' Ú'||copies('Ä',76)||'¿ '
  do dhi=1 to 15
    call charout ,' ³'||copies(' ',76)||'³ '
  end
  call charout ,' À'||copies('Ä',76)||'Ù'
  call charout ,f5
  call SysCurPos 10,3
  call charout ,'Ú'||copies('Ä',72)||'¿'
  do dhi=1 to 12
    call SysCurPos 10+dhi,3
    call charout ,'³'||copies(' ',72)||'³'
  end
  call SysCurPos 10+dhi,3
  call charout ,'À'||copies('Ä',72)||'Ù'
  call charout ,f1
  call SysCurPos 11,6
  call charout ,'ÚÄ¿Ú'||copies('Ä',60)||'ÂÄÄ¿'
  do dhi=1 to 10
    call SysCurPos 11+dhi,6
    call charout ,'³ Ã´'||copies(' ',60)||'³  ³'
  end
  call SysCurPos 11+dhi,6
  call charout ,'ÀÄÙÀ'||copies('Ä',60)||'ÁÄÄÙ'
  call charout ,f3
  call SysCurPos 10,5; call charout ,' Tag '
  call SysCurPos 10,28; call charout ,f2''f3' Filename 'f2''f3
  call SysCurPos 10,60; call charout ,' Filesize '
  call charout ,f4
  call SysCurPos 1,10
  call charout ,'M! v0.7 - MIDI PLAYER FOR OS/2 - BY Wolfgang Reinken'
  /* number MIDI-Dateien		*/
  call SysCurPos 4,3; call charout ,f5'xxxxx'
  call SysCurPos 4,8-length(NumMid); call charout ,f2||NumMid
  /* number geTAGgter Dateien		*/
  call SysCurPos 5,3; call charout ,f5'xxxxx'
  call SysCurPos 5,8-length(FilTag.0); call charout ,f2||FilTag.0
  /* Display Play Forever 		*/
  call DispPlayForeverRandom

return

/* ---------------------------------------------------- */
/* display static info play screen			*/
/* ---------------------------------------------------- */

DisplayHeadPlay:

  parse arg ptrLied

  call SysCls
  call charout ,f9'ÚÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¿'
  call charout ,f9'³'f0'ÛÛÛÛÛ²²²²²²±±±±±±°°°°° M! v.0.7  midi player for OS/2!  °°°°°±±±±±±²²²²²²ÛÛÛÛÛ'f9'³'
  call charout ,f9'ÀÍÍÍÍÍÍÍÍÍÍÍÍÍÍ'f0' by Wolfgang Reinken 'f9'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÙ'
  say
  say f12' p'f10'laying 'f12'f'f10'ile'f13':'
  call SysCurPos 8,0
  say f12' t'f10'otal 'f12'p'f10'laying 'f12't'f10'ime ['f0'úú'f13':'f0'úú'f10']'
  say f12' t'f10'ime 'f12'e'f10'lapsed       ['f0'úú'f13':'f0'úú'f10']'
  call SysCurPos 15,0
  say f16' ['f9'P'f16']'
  say f19'  ÀÄ-'f12'p'f10'revious 'f12's'f10'ong'f13':'
  say      f12'       a'f10'ctual 'f12's'f10'ong'f13':'
  say f19'  ÚÄÄÄÄÄ-'f12'n'f10'ext 'f12's'f10'ong'f13':'
  say f16' ['f9'N'f16']'
  call SysCurPos 15,20; if ptrLied>2 then do; ptr=ptrLied-2; call charout ,f19||left(substr(FilTag.ptr,1,59),59); end
  call SysCurPos 16,20; if ptrLied>1 then do; ptr=ptrLied-1; call charout ,f19||left(substr(FilTag.ptr,1,59),59); end
  call SysCurPos 17,20; if ptrLied>0 then do; ptr=ptrLied-0; call charout ,f11||left(substr(FilTag.ptr,1,59),59); end
  call SysCurPos 18,20; if FilTag.0-ptrLied+1>1 then do; ptr=ptrLied+1; call charout ,f19||left(substr(FilTag.ptr,1,59),59); end
  call SysCurPos 19,20; if FilTag.0-ptrLied+1>2 then do; ptr=ptrLied+2; call charout ,f19||left(substr(FilTag.ptr,1,59),59); end

  call SysCurPos 22,0
  say f16' ['f9'Q'f16']'
  say f19'  ÀÄ-'f12'q'f10'uit 'f12'b'f10'ack 'f12't'f10'o 'f12'f'f10'ile 'f12'l'f10'isting'
  call SysCurPos 10,20; call charout ,f16'['f9'< 'f19'ş'f9' >'f16']'
  call SysCurPos 22,42; call charout ,f16'['f17'<'f9'space'f17'>'f16']'
  if pauspl=0
    then do; call SysCurPos 23,42; call charout ,f0'    ÀÄÄÄÄÄ-'f12'p'f10'ause 'f12'p'f10'layback'; end
    else do; call SysCurPos 23,42; call charout ,f0'    ÀÄÄÄÄÄ-'f12'r'f10'esume 'f12'p'f10'layback'; end
  call SysCurPos 24,68; call charout ,f19'('f18'f1'f19'='f18'help'f19')'
  call SysCurPos 8,51; call charout ,f12'v'f10'olume'f13': 'f11'  0'f13'%'
  call SysCurPos 9,51; call charout ,f16'[          ]'
  call SysCurPos 10,51; call charout ,f16'['f9'<'f17'- 'f19'-şş- 'f17'-'f9'>'f16']'
  call SysCurPos 12,1;  call charout ,f19'[şşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşşş]'
  ElaPosA=0		/* Merkwert fr altes ElaPos 	*/
  if pauspl=0
    then do; call SysCurPos 12,2+ElaPosA; call charout ,f12''; end
    else do; call SysCurPos 12,2+ElaPosA; call charout ,f18''; end
return

/* ---------------------------------------------------- */
/* play a MIDI file					*/
/* ---------------------------------------------------- */

PlayMidi:

  parse arg PlayFile

  /*PS=1*/			/* switch "show play screen" 	  		*/
				/* 	    0=main screen	  	  	*/
				/* 	    1=play screen	  	  	*/
				/* 	    2=help screen of play screen  	*/
				/* 	    3=help screen of main screen  	*/

  LoadError=0 /* Error-switch    */

  if ExeMode=0 then
  do
    rc = mciRxSendString('open sequencer alias m shareable wait', 'RetStr', '0', '0')
    if rc <> 0 then
    do
      MacRC = mciRxGetErrorString(rc, 'ErrStVar')
      say 'OPEN: rc =' rc ', ErrStVar =' ErrStVar
      wt=SysGetKey(noecho)
    end

    rc = mciRxSendString('load m "'PlayFile'" wait', 'RetStr', '0', '0')
    if rc <> 0 then
    do
      MacRC = mciRxGetErrorString(rc, 'ErrStVar')
      say 'LOAD: rc =' rc ', ErrStVar =' ErrStVar
      rc = mciRxSendString('release m return ressource', 'RetStr', '0', '0')
      wt=SysGetKey(noecho)
      LoadError=1
    end
  end
  
  if LoadError=0 then
  do
    IF ExeMode=0 THEN
    DO
      rc = mciRxSendString('set m time format milliseconds wait', 'RetStr', '0', '0')
      rc = mciRxSendString('status m length wait', 'RetStr', '0', '0')
      LenPlay=RetStr%1000; LenSec=LenPlay//60+100; LenMin=LenPlay%60
    END
    ELSE
    DO
      do while queued()>0
        parse pull loe
      end
      '@timidity -idv -Ol "'PlayFile'" | find "time " | RxQueue '
      parse pull z
      zl=word(z,words(z)); zd=pos(":",zl)
      LenSec=substr(zl,zd+1,2); LenMin=substr(zl,1,zd-1); LenPlay=LenMin*60+LenSec; LenSec=" "LenSec
    END
    if PS=1 then
    do
      call SysCurPos 8,24; call charout ,f11||substr(LenSec,2,2)
      if LenMin<10 then do; call SysCurPos 8,22; call charout ,f11||LenMin; end
      		   else do; call SysCurPos 8,21; call charout ,f11||LenMin; end
      call SysCurPos 5,5; call charout ,f11||filespec("name",PlayFile)
    end
    IF ExeMode=0 THEN
    DO
      rc = mciRxSendString('play m', 'RetStr', '0', '0')
      if rc <> 0 then
      do
         MacRC = mciRxGetErrorString(rc, 'ErrStVar')
         say 'PLAY: rc =' rc ', ErrStVar =' ErrStVar
         wt=SysGetKey(noecho)
      end
    END
    ELSE
    DO
      '@detach timidity "'PlayFile'" 1>nul 2>nul '
       PID=GetPID()
    END
    elaps=0		/* elapsed time of song		*/
    pauspl=0		/* play paused (=1)		*/
    IF ExeMode=0 
      THEN rc = mciRxSendString('set m volume 'volume' wait', 'RetStr', '0', '0');
      ELSE volume="100"
    if PS=1 then
    do
      call SysCurPos 8,59; call charout ,f11||right(volume,3)
      call SysCurPos 9,52; call charout ,v.volume
    end

    IF ExeMode=1 THEN StatStr="playing"

    do until StatStr<>"playing" & StatStr<>"paused"
      SeekFlag=0				/* workaround because timidity	*/
						/* is not properly working	*/
						/* 0 = normally			*/
						/* 1 = after seek forw/back     */
						/*     StatStr must be set	*/
      KeyStr = RxKbdCharIn(nowait)
      abspix=ai-1+ci
      if substr(KeyStr,2,2)='  ' then 
      do
        plc=translate(word(KeyStr,1))		/* character of input	 	*/
        pls=translate(word(KeyStr,2))		/* scan code of input		*/
        plst=word(KeyStr,3)			/* state (00=no character)	*/
	plk=word(KeyStr,5)
      end
      else 
      do
        plc=translate(word(KeyStr,2))		/* character of input	 	*/
        pls=translate(word(KeyStr,3))		/* scan code of input		*/
        plst=word(KeyStr,4)			/* state (00=no character)	*/
	plk=word(KeyStr,6)
      end
      if substr(KeyStr,2,3)='   ' then plc=' '
      plSKpr=substr(x2b(right(plk,4,'0')),15,1)=1|substr(x2b(right(plk,4,'0')),16,1)=1 /* Shift Key? */
      select
        when PS=1 & (plc='1b'X | plc='Q') then 		/* cancel playing	*/
	  do
            IF ExeMode=0 
              then 
              do
                rc = mciRxSendString('stop m wait', 'RetStr', '0', '0');
              end
              else call KillPlay
	    FilTag.0=0
	    PlayForever=0
	  end
        when PS=1 & (plc='B') then	 	/* cancel play w/o deletion of play list */
	  do
            IF ExeMode=0 
              then 
              do
                rc = mciRxSendString('stop m wait', 'RetStr', '0', '0');
              end
              else call KillPlay
	    PlayForever=0
	  end
        when PS=1 & plc='N' then 			/* next song		*/
	  do
            IF ExeMode=0 
              then 
              do
                rc = mciRxSendString('stop m wait', 'RetStr', '0', '0');
              end
              else call KillPlay
	  end
        when PS=1 & plc='P' & FilTag.0>1 then 		/* previous song	*/
	  do
            IF ExeMode=0 
              then 
              do
                rc = mciRxSendString('stop m wait', 'RetStr', '0', '0');
              end
              else call KillPlay
            iSong=max(0,iSong-2)
	  end
        when PS=1 & plc='<' & ExeMode=0 then 		/* 5s backwards		*/
	  do
            if elaps>5 then elaps=elaps-5
	               else elaps=0
	    call DispElaps
            rc = mciRxSendString('seek m to 'elaps*1000' wait', 'RetStr', '0', '0');
	    rc = mciRxSendString('set m volume 'volume' wait', 'RetStr', '0', '0');
            rc = mciRxSendString('play m', 'RetStr', '0', '0')
            SeekFlag=1
          end
        when PS=1 & plc='>' & ExeMode=0 then 		/* 5s forward		*/
	  do
            if elaps<LenPlay-5 then elaps=elaps+5
	               	       else elaps=LenPlay
	    call DispElaps
            rc = mciRxSendString('seek m to 'elaps*1000' wait', 'RetStr', '0', '0');
	    rc = mciRxSendString('set m volume 'volume' wait', 'RetStr', '0', '0');
            rc = mciRxSendString('play m', 'RetStr', '0', '0')
            SeekFlag=1
          end
        when PS=1 & pls='4B' & ExeMode=0 then 		/* volume lower		*/
	  do
            if Volume>0 then volume=volume-5
            rc = mciRxSendString('set m volume 'volume' wait', 'RetStr', '0', '0');
	    call SysCurPos 8,59; call charout ,f11||right(volume,3)
	    call SysCurPos 9,52; call charout ,v.volume
          end
        when PS=1 & pls='4D' & ExeMode=0 then 		/* volume higher	*/
   	  do
            if Volume<100 then volume=volume+5
            rc = mciRxSendString('set m volume 'volume' wait', 'RetStr', '0', '0');
	    call SysCurPos 8,59; call charout ,f11||right(volume,3)
	    call SysCurPos 9,52; call charout ,v.volume
	  end
        when PS=1 & plc=' ' & ExeMode=0 then 		/* pause playing 	*/
          do
            if pauspl=0 then
  	    do
  	      call SysCurPos 12,2+ElaPos; call charout ,f18''
              rc = mciRxSendString('pause m wait', 'RetStr', '0', '0');
	      call SysCurPos 23,53; call charout ,f12'r'f10'esume 'f12'p'f10'layback'
	      pauspl=1
	    end
	    else
	    do
  	      call SysCurPos 12,2+ElaPos; call charout ,f12''
              rc = mciRxSendString('resume m wait', 'RetStr', '0', '0');
	      call SysCurPos 23,53; call charout ,f12'p'f10'ause 'f12'p'f10'layback '
	      pauspl=0
	    end
	  end
        when PS=1 & plc='09'X | PS=3 & pls<>'00' then 		/* move to main screen	*/
	  do
	    PS=0
	    call DisplayHead    
	    call DispCurDir PlayFile
	    call ShowPWD
	    call DispCursBar
	  end
        when PS=0 & (plc='09'X | plc='1b'X) then   /* move to play screen from main screen */
	  do
	    PS=1
	    call RestorePlay
	  end
        when PS=1 & pls='3B' then 			/* move to help screen		*/
	  do
	    PS=2					/* help mode 			*/
	    call DispHelpPlay
	  end
        when PS=2 & plst<>'00' then 	/* move tou play screen from help screen	*/
	  do
	    PS=1					/* help mode 			*/
	    call RestorePlay
	  end
        when PS=0 & plc='S' & SKpr=0 then call SavePlayList	9,40,f2,f25'.'	  /* S in main screen			*/
        when PS=1 & plc='S' & SKpr=0 then call SavePlayList	14,40,f11,f10'.'  /* S in play screen			*/
        when PS=0 & plc=' ' & DTyp.abspix='F' then call TagUntag iSong	/* <SPACE> bei MIDI-Datei (Tag/Untag Datei)	*/
        when PS=0 & plc='F' & SKpr=0 then call MCtogForever	/* F w/o Shift (Toggle Play Forever)		*/
        when PS=0 & pls='4B' then call MCleft		/* <LEFT> 			*/
	when PS=0 & (plc='0d'X | pls='4D') & DTyp.abspix<>'F' then	call MCchdir /* <ENTER> or <RIGHT> with Dir and Drive */
	when PS=0 & pls='50' then call MCdown		/* <DOWN>			*/
	when PS=0 & pls='48' then call MCup		/* <UP>				*/
	when PS=0 & pls='51' then call MCpgdn		/* <PGDN>			*/
	when PS=0 & pls='49' then call MCpgup		/* <PGUP>			*/
        when PS=0 & pls='47' then call MChome		/* <HOME>			*/
        when PS=0 & pls='4F' then call MCend		/* <END>			*/
        when PS=0 & pls='3B' then call AZhelp		/* move to help screen		*/
        when plst<>'00' then 				/* skip non relevant characters	*/
	  nop
       	otherwise					/* show elapsed time		*/
          call SysSleep 1
	  if pauspl=0 then
	  do
	    if elaps<LenPlay then elaps=elaps+1
 	    if PS=1 then call DispElaps
	  end
      end
      IF ExeMode=0 
        then
        do 
          if SeekFlag=1
            then StatStr="playing"
            else rc = mciRxSendString('status m mode wait', 'StatStr', '0', '0')
        end
        else
        do
          if GetPID()=0 then 
          do
            StatStr="stopped"
          end
        end
    end
    PlayFile=''
  end

  IF ExeMode=0 THEN
  DO
    rc = mciRxSendString('close m wait', 'RetStr', '0', '0')
    if rc <> 0 then
    do
       MacRC = mciRxGetErrorString(rc, 'ErrStVar')
       say 'CLOSE: rc =' rc ', ErrStVar =' ErrStVar
       wt=SysGetKey(noecho)
    end
  END



return

/* ----------------------------------------------------- */
/* tag/untag of MIDI files for playing			 */
/* ----------------------------------------------------- */

TagUntag:

  parse arg tuiSong
  
  if DTag.ix=0 then DTag.ix=1
	       else DTag.ix=0
  if DTag.ix=1 then
  do
    FilTag.0=FilTag.0+1
    dtix=FilTag.0
    FilTag.dtix=Datei.ix
  end
  else
  do
    dtgef=0
    do dti=1 to FilTag.0
      dti1=dti+1
      if dtgef=0 & FilTag.dti=Datei.ix then do; dtgef=1; dtigef=dti; end
      if dtgef=1 & dtigef=tuiSong then dtgef=0	/* song is playing at his moment */
      if dtgef=1 then FilTag.dti=FilTag.dti1
    end
    if dtgef=1 then FilTag.0=FilTag.0-1
	       else DTag.ix=1
    if dtigef<tuiSong then iSong=iSong-1
  end
  call DispCursBar
  /* number tagged files			*/
  call SysCurPos 5,3; call charout ,f5'xxxxx'
  call SysCurPos 5,8-length(FilTag.0); call charout ,f2||FilTag.0

return

TagUntagAllVerz:

  parse arg tuiSong
  
  dtTaggedAll=1						/* asumtion: all files are tagged	   */
  do dti=1 to dn					/* check this asumtion			   */
    if DTyp.dti="F" & DTag.dti=0 then dtTaggedAll=0	/* asumtion is wrong, since at least 1 file*/
  end							/* isn't tagged				   */
  if dtTaggedAll=0 then		
  do dti=1 to dn
    if DTyp.dti="F" & DTag.dti=0 then
    do
      DTag.dti=1
      FilTag.0=FilTag.0+1
      dtix=FilTag.0
      FilTag.dtix=Datei.dti
    end
  end
  else
  do dti=1 to dn
    if DTyp.dti="F" & DTag.dti=1 then
    do
      DTag.dti=0
      dtgef=0
      do dtj=1 to FilTag.0
        dtj1=dtj+1
        if dtgef=0 & FilTag.dtj=Datei.dti then dtgef=1
        if dtgef=1 then FilTag.dtj=FilTag.dtj1
      end
      if dtgef=1 then FilTag.0=FilTag.0-1
    end
  end
  call DispCurDir ''
  call DispCursBar
  /* number of tagged files			*/
  call SysCurPos 5,3; call charout ,f5'xxxxx'
  call SysCurPos 5,8-length(FilTag.0); call charout ,f2||FilTag.0

return

UntagAll:

  do uti=1 to dn
    DTag.uti=0
  end
  FilTag.0=0

return

/* ---------------------------------------------------- */
/* Display of elaped time as numbber and		*/
/* as note symbol in progress bar			*/
/* ---------------------------------------------------- */

DispElaps:

  ElaSec=elaps//60+100; call SysCurPos 9,24; call charout ,f11||right(ElaSec,2)
  ElaMin=elaps%60
  if ElaMin<10 then do; call SysCurPos 9,22; call charout ,f11||ElaMin; end
	       else do; call SysCurPos 9,21; call charout ,f11||ElaMin; end
  ElaPos=76*elaps%LenPlay
  if ElaPos<>ElaPosA then
  do
    call SysCurPos 12,2+ElaPosA; call charout ,f19'ş'
    if pauspl=0
      then do; call SysCurPos 12,2+ElaPos; call charout ,f12''; end
      else do; call SysCurPos 12,2+ElaPos; call charout ,f18''; end
    ElaPosA=ElaPos
  end
return

/* ---------------------------------------------------- */
/* search of directories, files and drives with		*/
/* keyboard (Shift-Key)					*/
/* ---------------------------------------------------- */

SearchDirFileDrive:
 
  parse arg SVDc

  SuchFeld=SuchFeld||SVDc
  do sui=1 to dn
    if DTyp.sui<>'V' then DatNam=translate(filespec('name',Datei.sui))
    		     else DatNam=translate(Datei.sui)
    if substr(DatNam,1,length(SuchFeld))=SuchFeld then
    do
      select
        when sui<ai then do; call ResCurBalk; ci=1; ai=sui; call DispCurDir ''; call DispCursBar; end
        when sui>ai+9 then do; call ResCurBalk; ci=10; ai=sui-9; call DispCurDir ''; call DispCursBar; end
        when sui<>ai+ci-1 then do; call ResCurBalk; ci=sui-ai+1; call DispCurDir ''; call DispCursBar; end
        otherwise
      end
      leave
    end
  end
  call SysCurPos 23,20; 
  if length(Suchfeld)>8 then sui=dn+1
  if SVDc<>'' then
  do
    if sui=dn+1 then do; SuchFeld=''; call charout ,f5'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'; end
	        else do; call charout ,f4' Search 'f21'['f20||left(Suchfeld,8)||f21'] '; end
  end
return

DispPlayForeverRandom:

  call SysCurPos 22,23
  select
    when PlayForever=1 & PlayRandom=1 then
      call charout ,f2' (random playback / play forever) '
    when PlayForever=1 then
      call charout ,f1'ÄÄÄÄÄÄÄ 'f2'(play forever)'f1' ÄÄÄÄÄÄÄÄÄÄÄ'
    when PlayRandom=1 then
      call charout ,f1'ÄÄÄÄÄÄ 'f2'(random playback)'f1' ÄÄÄÄÄÄÄÄÄ'
    otherwise
      call charout ,f1'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
  end

return

Mischen:

  do mii=1 to FilTag.0		/* initialize help vector RV				*/
    RV.mii=''
  end
  do mii=1 to FilTag.0		/* fill randomized with contents of vector FilTag	*/
    do until RV.mix=''
      mix=random(1,FilTag.0)
    end
    RV.mix=FilTag.mii
  end
  do mii=1 to FilTag.0		/* write back to vector FilTag				*/
    FilTag.mii=RV.mii
  end

  
return

MCdown:
      do
        if ci<10 & ai-1+ci<dn then do; call ResCurBalk; ci=ci+1; call DispCursBar; end
        else
        if ai+9<dn then do; ai=ai+1; call DispCurDir PlayFile; call DispCursBar; end
      end
return

MCup:
      do
        if ci>1 then do; call ResCurBalk; ci=ci-1; call DispCursBar; end
        else
        if ai>1 then do; ai=ai-1; call DispCurDir PlayFile; call DispCursBar; end
      end
return

MCpgdn:
      do
        if ai+9<dn then do; ci=1; ai=ai+10; call DispCurDir PlayFile; call DispCursBar; end
      end
return

MCpgup:
      do
        if ai>1 then do; ci=1; ai=max(1,ai-10); call DispCurDir PlayFile; call DispCursBar; end
      end
return

MCchdir:
  do
    if SuchFeld<>'' then do; SuchFeld=''; call SysCurPos 23,20; call charout ,f5'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'; end
    ix=ai-1+ci
    if DTyp.ix='D' then call directory word(datei.ix,1)
		   else call directory word(datei.ix,1)'\'
    if ix=1 then			/* cd ..					*/
    do
      call ReadCurDir
      SuchFeld=translate(filespec('name',AktDir))
      call SearchDirFileDrive ''	/* set the original directory			*/
      SuchFeld=''
      call ShowPWD
    end
    else 				/* change to subdirectory			*/
    do
      call ReadCurDir
      call ShowPWD	
      ai=1				/* firstdirectory entry to display		*/
      call DispCurDir PlayFile
      ci=1				/* position of bar cursor			*/
      call DispCursBar
    end
  end
return

MCleft:
  ai=1; ci=1				/* values to set ix to 1 			*/
  call MCchdir
return

MChome:
      do
        if ai>1 then do; ci=1; ai=1; call DispCurDir PlayFile; call DispCursBar; end
        else
        if ci>1 then do; call ResCurBalk; ci=1; call DispCursBar; end
      end
return

MCend:
      do
        if dn>10 then do; ci=10; ai=dn-9; call DispCurDir PlayFile; call DispCursBar; end
        else
        if ci<dn then do; call ResCurBalk; ci=dn; call DispCursBar; end
      end
return

MCtogForever:
      do
        if PlayForever=0 then PlayForever=1
		         else PlayForever=0
	call DispPlayForeverRandom
      end
return

MCtogRandom:
      do
        if PlayRandom=0 then PlayRandom=1
		        else PlayRandom=0
	call DispPlayForeverRandom
      end
return

MChelp:							/* move to help screen		*/
      do
        MS=2
	call DispMainHelp
      end
return

AZhelp:							/* move to help screen		*/
      do
        PS=3
	call DispMainHelp
      end
return

LoadPlayList:			/* load of play list from a file			*/
				/* parameter: line, length, color of char., fill char. 	*/
	parse arg lpLine, lpLen, lpColor, lpFill
	do
	  call SysCurPos lpLine,3; call charout ,f2'playlist filename: 'f25||copies('.',40)
          call SysCurPos lpLine,22
          PListName = ReadKbdString(lpLen, lpColor, lpFill)
	  if PListName <> '' then
	  do
	    call UntagAll
            spli=0 
	    rc=stream(PListName, "C", "OPEN READ")
	    do while lines(PListName)>0
	      spli=spli+1
	      FilTag.spli=linein(PListName)
            end
	    FilTag.0=spli
	    rc=stream(PListName, "C", "CLOSE")
	  end
          call SysCurPos lpLine,3; call charout ,copies(' ',70)
	  call ReadCurDir
	  call DisplayHead    
	  call DispCurDir ''
	  call ShowPWD
	  call DispCursBar
	end
return 

SavePlayList:			/* save a playlist into a file				*/
				/* parameter: line, length, color of char., fill char. 	*/
	parse arg spLine, spLen, spColor, spFill
	if FilTag.0>0 then
	do
	  call SysCurPos spLine,3; call charout ,spColor'playlist filename: 'copies(spFill,40)
          call SysCurPos spLine,22
          PListName = ReadKbdString(spLen, spColor, spFill)
	  if PListName <> '' then
	  do
	    '@DEL 'PListName' 1>nul 2>nul '
	    rc=stream(PListName, "C", "OPEN WRITE")
	    do spli=1 to FilTag.0
	      call lineout PListName, FilTag.spli
            end
	    rc=stream(PListName, "C", "CLOSE")
	  end
          call SysCurPos spLine,3; call charout ,copies(' ',70)
	end
return 

ClearPlayList:				/* load a play list from a file			*/
	call UntagAll
	FilTag.0=0
	call ReadCurDir
	call DisplayHead    
	call DispCurDir ''
	call ShowPWD
	call DispCursBar
return 

ReadKbdString:				/* input string via keyboard	      		*/
					/* parameter: length, color of char., fill char.*/
	parse arg rksLen, rksColor, rksFill
	rksBuf=''			/* input buffer 				*/
	rksBufL=0			/* current length input buffer			*/
	rksi=0				/* input position input buffer 			*/
        call SysCurState 'ON'
	do until rksc='03'X | rksc='1B'X | rksc='0D'X
	  parse value SysCurPos() with rksZeile rksSpalte
	  KeyStr = RxKbdCharIn(wait)		/* input of character w/o echo; with analysing scan code */
  	  if substr(KeyStr,2,2)='  ' then 
	  do
    	    rksc=word(KeyStr,1)				/* character of input	 	*/
    	    rkss=translate(word(KeyStr,2))		/* scan code of input		*/
    	    rkssk=word(KeyStr,5)
  	  end
  	  else 
  	  do
    	    rksc=word(KeyStr,2)				/* character of input	 	*/
    	    rkss=translate(word(KeyStr,3))		/* scan code of input		*/
    	    rkssk=word(KeyStr,6)
  	  end
  	  if substr(KeyStr,2,3)='   ' then rksc=' '
          select
	    when rksc='03'X | rksc='1B'X then		/* cancel input			*/
	      rksBuf=''
	    when rksc='0D'X then			/* end input			*/
	      nop
	    when rksc>' ' & rksc<='z' then	/	* character for file name	*/
	      if rksBufL<rksLen then 
	      do
   		if rksi=rksBufL then
		do					/* add character		*/
		  rksBuf=rksBuf||rksc
		  rksBufL=rksBufL+1; rksi=rksi+1
		  call charout ,rksColor||rksc
		  /*if rksi>=rksLen then call SysCurPos rksZeile, rksSpalte */
		end
		else
		do					/* insert character		*/
		  rksBuf=insert(rksc,rksBuf,rksi)	
		  rksBufL=rksBufL+1; rksi=rksi+1
		  call charout ,rksColor||substr(rksBuf,rksi)
		  call SysCurPos rksZeile, rksSpalte+1
		end
	      end
	    when rkss='53' then					/* DEL		    	*/
	      if rksi>=0 & rksi<rksBufL then
	      do
		rksBuf=delstr(rksBuf,rksi+1,1)
		call charout ,rksColor||substr(rksBuf,rksi+1)||rksFill
		rksBufL=rksBufL-1
		call SysCurPos rksZeile, rksSpalte
	      end
	    when rkss='0E' | rksc='08'X then			/* ^H		    	*/
	      if rksi>0 then
	      do
		rksBuf=delstr(rksBuf,rksi,1)
		call SysCurPos rksZeile, rksSpalte-1
		call charout ,rksColor||substr(rksBuf,rksi)||rksFill
		rksBufL=rksBufL-1; rksi=rksi-1
		call SysCurPos rksZeile, rksSpalte-1
	      end
	    when rkss='4B' then					/* arrow left	 	*/
	      if rksi>0 then do; rksi=rksi-1; call SysCurPos rksZeile, rksSpalte-1; end
	    when rkss='4D' then					/* arrow right		*/
	      if rksi<rksBufl /*& rksi<rksLen*/ then do; rksi=rksi+1; call SysCurPos rksZeile, rksSpalte+1; end
    	    otherwise
          end
        end
	call SysCurState 'OFF'
return rksBuf

DispHelpPlay:

  call SysCls
  say f13'    %,    %,         '
  say f13'     %%     %        '
  say f13'     %%%,    %,      '
  say f13"     %%%'%    %%     "
  say f13"     %%% '%. .%%%    "
  say f13'    %%%%   % % %%%   '
  say f13'    %%%%   %%%  %%%  '
  say f13'   %%%%%   %%   %%%% '
  say f13'  %%%%%    %%   %%%% '
  say f13'.%%%%%    .%%  .%%%% '
  say f13"%%%%%     %%'  %%%%' "
  yp=0
  yp=yp+0; call SysCurPos yp,23; call charout ,f12'- 'f18'c o m m a n d  l i s t i n g 'f12'-'
  yp=yp+2; call SysCurPos yp,23; call charout ,f23'p 'f24'l a y b a c k  'f23'f 'f24'u n c t i o n s'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'n'f16'. 'f0'next song'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'p'f16'. 'f0'previous song'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'q, <ESC>'f16'. 'f0'quit to the tagger (clears the playlist)'
  yp=yp+1;
  if ExeMode=0 then 
  do
    call SysCurPos yp,23; call charout ,f10'space'f16'. 'f0'pause playback'
  end
  else
  do
    call SysCurPos yp,23; call charout ,f10'space'f16'. 'f19'pause playback'
    call SysCurPos yp,63; call charout ,f11'not available *)'
  end
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'tab'f16'. 'f0'go to the tagger (while playing)'
  yp=yp+1; 
  if ExeMode=0 then 
  do
    call SysCurPos yp,23; call charout ,f10'<>'f16'. 'f0'skip backward/forward 5 seconds'
  end
  else
  do
    call SysCurPos yp,23; call charout ,f10'<>'f16'. 'f19'skip backward/forward 5 seconds'
    call SysCurPos yp,63; call charout ,f11'not available *)'
  end
  yp=yp+1; 
  if ExeMode=0 then 
  do
    call SysCurPos yp,23; call charout ,f10'<- ->'f16'. 'f0'change the volume'
  end
  else
  do
    call SysCurPos yp,23; call charout ,f10'<- ->'f16'. 'f19'change the volume'
    call SysCurPos yp,63; call charout ,f11'not available *)'
  end
  yp=yp+2; call SysCurPos yp,23; call charout ,f23'm 'f24'i s c.  'f23's 'f24't u f f'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10's'f16'. 'f0'save playlist'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'<del>'f16'. 'f19'delete file'
           call SysCurPos yp,63; call charout ,f18'(not implemented)'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'alt-p'f16'. 'f19'playlist editor'
           call SysCurPos yp,63; call charout ,f18'(not implemented)'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'alt-r'f16'. 'f19'randomize the unplayed tracks'
           call SysCurPos yp,63; call charout ,f18'(not implemented)'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'b'f16'. 'f0"same as q but doesn't clear playlist"
  if ExeMode=1 then 
  do
    yp=21; call SysCurPos yp,33; call charout ,f11"*) Your sound driver doesn't support MIDI"
    yp=22; call SysCurPos yp,36; call charout ,f11"and TIMIDITY.EXE doesn't allow interaction" 
  end
  call SysCurPos 24,67; call charout ,f0'<hit a key!>'

return

DispMainHelp:

  call SysCls
  say f13'    %,    %,         '
  say f13'     %%     %        '
  say f13'     %%%,    %,      '
  say f13"     %%%'%    %%     "
  say f13"     %%% '%. .%%%    "
  say f13'    %%%%   % % %%%   '
  say f13'    %%%%   %%%  %%%  '
  say f13'   %%%%%   %%   %%%% '
  say f13'  %%%%%    %%   %%%% '
  say f13'.%%%%%    .%%  .%%%% '
  say f13"%%%%%     %%'  %%%%' "
  yp=0
  yp=yp+0; call SysCurPos yp,23; call charout ,f12'- 'f18'c o m m a n d  l i s t i n g 'f12'-'
  yp=yp+2; call SysCurPos yp,23; call charout ,f23'p 'f24'l a y l i s t  'f23'f 'f24'u n c t i o n s'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'l. 'f11'load playlist'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10's. 'f11'save playlist'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'c. 'f11'clear playlist/tagged files'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'alt-p. 'f19'playlist editor'
           call SysCurPos yp,63; call charout ,f18'(not implemented)'
  yp=yp+2; call SysCurPos yp,23; call charout ,f23't 'f24'a g g i n g  'f23'o 'f24'p t i o n s'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10' . 'f11'move up and down'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'space. 'f11'tag file to play'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'alt-r. 'f19'recurse into sub-dir and tag all'
           call SysCurPos yp,63; call charout ,f18'(not implemented)'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'a. 'f11'tag all files'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'r. 'f11'toggle random playback'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'f. 'f11'toggle forever play'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'p. 'f11'play tagged files'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'tab. 'f11'return to playscreen (if playing)'
  yp=yp+2; call SysCurPos yp,23; call charout ,f23'm 'f24'i s c.  'f23's 'f24't u f f'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'q, <ESC>. 'f11'quit m! (or return to mainscreen)'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'n. 'f19'rename file'
           call SysCurPos yp,63; call charout ,f18'(not implemented)'
  yp=yp+1; call SysCurPos yp,23; call charout ,f10'shift-X. 'f11'goes to 1st file in the listing starting with'
  yp=yp+1; call SysCurPos yp,32; call charout  ,f11'character "X"'
  call SysCurPos 24,67; call charout ,f0'<hit a key!>'

return

RestorePlay:
	    call DisplayHeadPlay iSong
	    call SysCurPos 8,24; call charout ,f11||substr(LenSec,2,2)
	    if LenMin<10 then do; call SysCurPos 8,22; call charout ,f11||LenMin; end
	    		 else do; call SysCurPos 8,21; call charout ,f11||LenMin; end
	    call SysCurPos 5,5; call charout ,f11||filespec("name",PlayFile)
	    call SysCurPos 8,59; call charout ,f11||right(volume,3)
	    call SysCurPos 9,52; call charout ,v.volume
	    call DispElaps
return

KillPlay:
            killrc = RxKillProcess(PID)
            StatStr="stopped"
            call SysSleep 1
return

GetPID:
      GetPIDNr=0
      call RxQProcStatus proc.
      do przi=1 to proc.0p.0
        if right(proc.0p.przi.6,12)="TIMIDITY.EXE" then GetPIDNr=x2d(proc.0p.przi.1)
      end
return GetPIDNr
