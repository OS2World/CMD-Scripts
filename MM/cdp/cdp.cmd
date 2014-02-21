/*  List/Backup/Restore all or selected CD Titles and tracks from Warp 4 CD-Player. */
/*  Author: Dirk C. Stuijfzand                                                      */
/*  21-11-97  Version 1.0 : First public release                                    */
/*  22-01-99  Version 1.1 : Omit albums without title                               */

'@echo off'

Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

Parse Upper Arg Mode Rest

IniDir= ''
IniFil= 'cdp.ini'
IniBak= 'cdp.ibk'
IniLck= 'cdp.!!!'

InpFil= 'cdp.inp'
OutFil= 'cdp.out'

KeyTit= 'IMMCDDiscTitle'
cAns= ''

Say ''

IniDir= Stream(IniFil,'C','Query Exist')
IF IniDir= '' THEN DO
  MmDir= Strip(Translate(Value('MMBASE',,'OS2ENVIRONMENT'),'',';'))||'\'
  rc= SysFileTree(MmDir||IniLck,Dummy,'FO')   /* Look up file, even when hidden */
  IF Dummy.0>0 THEN DO
    Say 'CD Player active! - Close first'
    Exit
  END
  IniDir= Stream(MmDir||IniFil,'C','Query Exist')
  IF IniDir= '' THEN DO
    Say 'File '||IniFil||' not found'
    Exit
  END
END

IniDir= Substr(IniDir,1,Length(IniDir)-Length(IniFil))  /* Strip file from path */
IniFil= IniDir||IniFil
IniBak= IniDir||IniBak
IniLck= IniDir||IniLck
Say 'Using '||IniFil
Say ''

IF Length(Mode)=0 THEN DO      /* Correct for default cmdline params */
  Mode= 'T'                    /* Default to Titles list when no params given */
END
IF Length(Rest)=0 THEN DO
  IF Pos(Substr(Mode,1,1),'-/')=0 THEN DO
    Rest= Mode
    Mode= 'T'                  /* Default to Titles list when the only param given is not an option */
  END
  ELSE DO
    Mode= Substr(Mode,2)
  END
END

SELECT
  WHEN Pos(Mode,'TLX')>0
    THEN CdpRd(Mode,Rest)
  WHEN Mode='A' 
    THEN CdpWrt()
OTHERWISE
  Say 'Usage: cdp    [searchkey] (list Titles)'
  Say '       cdp -l [searchkey] (list Tracks)'
  Say '       cdp -x [searchkey] (list Tracks and save in CDP.OUT)'
  Say '       cdp -a             (add from file CDP.INP)'
END

Exit


/************************************/
CdpRd:
Parse Arg cWrt, cNar   /* cWrt:  T=Titles  L=Track list  X=Extract */

IF cWrt='X' THEN 'if exist ' OutFil ' del ' OutFil '>nul'

rc = SysIni(IniFil,'ALL:','aAlb')  /* Query all cd codes, put in Album array */

DO x= 1 TO aAlb.0                  /* Query all Titles   */
  aTit.x= SysIni(IniFil,aAlb.x,KeyTit)
  IF aTit.x='ERROR:' THEN aTit.x= ''
END

DO x= 1 TO aAlb.0

  IF (aTit.x<>'') & ((cNar='') | (Pos(cNar,TransLate(aTit.x))>0)) THEN DO   /* Narrow the scope when needed */
    Say aTit.x

    IF cWrt\='T' THEN DO       /* Skip tracks when only Titles are asked */
      nTrk= 0
      rc= SysIni(IniFil,aAlb.x,'ALL:','aKey')    /* Query all key names for this cd */
      DO y= 1 TO aKey.0
        IF DataType(aKey.y,'N') THEN DO          /* We only want the numeric keys */
          cKey= SysIni(IniFil,aAlb.x,aKey.y)     /* Query value for key */
          nTrk= nTrk+1
          aTrs.nTrk= aKey.y    /* Track Seq nr */
          aTrk.nTrk= cKey      /* Track title  */
        END
      END
                               /* Write to file when in eXtract mode */
      IF cWrt='X' THEN rc= LineOut(OutFil,'['||aAlb.x||'] '||aTit.x)
      DO y= 1 TO nTrk
        Say Right(aTrs.y,3)||' - '||aTrk.y
        IF cWrt='X' THEN rc= LineOut(OutFil,Right(aTrs.y,2)||' '||aTrk.y)
      END
      Say ''
      IF cWrt='X' THEN rc= LineOut(OutFil,'')
    END

  END

END

IF cWrt='X' THEN rc= LineOut(OutFil)   /* Close file */

Return ''

/************************************/
CdpWrt:

IF Stream(InpFil,'C','Query Exist') = '' THEN DO
  Say 'File '||InpFil||' not found'
  Exit
END

'copy '||IniFil||' '||iniBak||'>NUL'

cCod= ''
cTit= ''
nTrk= 0
nLnr= 0

DO WHILE Lines(InpFil) > 0
  nLnr= nLnr+1
  InBuf= Strip(LineIn(InpFil))
  IF InBuf='' THEN DO    /* Empty line */
    IF cCod\='' THEN DO
      IniUpd()
      cCod= ''
      cTit= ''
      nTrk= 0
    END
  END
  ELSE DO                /* Non empty line */
    IF cCod='' THEN DO
      IF Substr(InBuf,1,1)='[' THEN DO
        Parse Var InBuf '['cCod']'cTit
        cTit= Strip(cTit)
        Say cCod cTit
      END
      ELSE DO
        Say InpFil||' ('||nLnr||') - "[" expected'
        Exit
      END
    END
    ELSE DO
      Parse Var InBuf nVlg cTrk
      IF Datatype(nVlg)\='NUM' THEN DO
        Say InpFil||' ('||nLnr||') - "'||nVlg||'" Number expected'
        Exit
      END
      IF Right(cTrk,1)=')' THEN DO    /* Del trailing (5:67) Tracktime if exist */
        p= LastPos('(',cTrk)
        IF p>0 THEN DO
          cTrk= Strip(Substr(cTrk,1,p-1))
        END
      END
      Say Right(nVlg,3)||' - '||cTrk
      nTrk= nTrk+1
      aVlg.nTrk= nVlg
      aTrk.nTrk= cTrk
    END
  END
END

IniUpd()

Return ''

/************************************/
IniUpd:

IF nTrk>0 THEN DO
  Say ''

  IF cAns \= 'A' THEN DO
    Say 'Ready to write to '||IniFil
    cAns= ''
    rc= CharOut(,'Continue?  Yes, Skip, All, Quit  ')
    DO UNTIL Pos(cAns,'YSAQ')>0
      cAns= TransLate(SysGetKey('NOECHO'))
    END
    Say cAns
    IF cAns = 'Q' THEN DO
      Exit
    END
  END

  IF cAns \= 'S' THEN DO
    Say 'Updating: '||cTit
    rc = SysIni(IniFil,cCod)                   /* Delete data for this cd if already exists */
    rc = SysIni(IniFil,cCod,KeyTit,cTit)       /* Add  cd code and Title */
    DO i=1 TO nTrk
      rc = SysIni(IniFil,cCod,aVlg.i,aTrk.i)   /* Add Track */
    END
  END

  Say ''
END

Return ''

