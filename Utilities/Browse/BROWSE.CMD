/* ================================================================== */
/* REXX BROWSE - View a text file line by line.                       */
/* Copyright (c) 1992 Bruce E. H”gman.  All Rights Reserved.          */
BrowseVersion='ÄVÄ920810Ä';
/* ================================================================== */
InFileSpec=""; Browse_RC=0; parse upper arg InFileSpec ProcOpts;
InFileSpec=Strip(InFileSpec);

/* ================================================================== */
/* Check to see if all REXX utility functions have been Loaded        */
/* NOTE:  RxFuncQuery tests for REXX load.                            */
/* ================================================================== */
if 0 < RxFuncQuery('SysLoadFuncs') THEN DO; Call rxfuncadd 'SysLoadFuncs','REXXUTIL','SysLoadFuncs'; Call SysLoadFuncs; END;

/* ================================================================== */
/* Obtain the current video screen size for reset after if needed.    */
/* DEfine keyboard mapping for user interaction.                      */
/* Display the short copyright notice.                                */
/* ================================================================== */
Call GetVideoSize; zMaxRow=gMaxRow; zMaxCol=gMaxCol; bVideoReset=0;
if gMaxCol\=80 | gMaxRow\=25 then do; gMaxCol=80; gMaxRow=25;
   '@mode con1 80,25';
   bVideoReset=1;
end;
Call Copyright_S;
Call SETKN;
irc=SETLOCAL();  /* Save the CWD, etc. that existed on entry to the REXX */
gCDir=Directory();
if zMaxRow\=gMaxRow | zMaxCol\=gMaxCol then do;
   gMaxRow=zMaxRow; gMaxCol=zMaxCol;
   bVideoReset=1;
end;
/* ================================================================== */
/* Define global symbols                                              */
/* ================================================================== */
bHexDisplay=0; /* 1: display data in hexadecimal */
OUTR='~'||'fa'x||'fa'x||'fa'x||'fa'x||'fa'x||'fa'x||'fa'x||'fa'x;
INTR=''||'06'x||'07'x||'08'x||'09'x||'0a'x||'0b'x||'0c'x||'0d'x;

/* ================================================================== */
/* Set processing options from those specified by the user.           */
/* /A  bShowBlank=1          Show all blank lines, not suppress.      */
/* /B  sFileType=BINARY      Process input file as binary, not text.  */
/* /H  bHelp=1               Display Help Info.                       */
/* /I  bDeleteIni=1          Delete all SysIni data.                  */
/* /Q  bQuiet=1              Don't display copyright notice.          */
/* /W  bFoldLines=0          Don't fold long lines.                   */
/* ================================================================== */
c=substr(InFileSpec,1,1);
if c='-'|c='/' then do; ProcOpts=InFileSpec ProcOpts; InFileSpec=""; end;
sFileType='TEXT'; if 0<pos('/B',ProcOpts) then sFileType='BINARY';
bShowBlank=0;     if 0<pos('/A',ProcOpts) then bShowBlank=1;
bFoldLines=1;     if 0<pos('/W',ProcOpts) then bFoldLines=0;
bDeleteIni=0;     if 0<pos('/I',ProcOpts) then bDeleteIni=1;
bQuite=0;         if 0<pos('/Q',ProcOpts) then bQuiet=1;
bHelp=0;
if 0<pos('/H',ProcOpts) | 0<pos('/?',ProcOpts) then bHelp=1;
if bDeleteIni>0 then do;
   say "You've requested DELETE: of all INI file profile data.";
   say "Are you sure?";
   parse upper pull ReplyStr;
   if 'Y'=substr(ReplyStr,1,1) then do;
      irc=SysIni('USER','BROWSE','DELETE:');
      say 'BROWSE INI profile data deleted.';
   end;
end;
TxtEditor='E';
Call IniParms 'Get';
if DirScrnRow='' | 1>DATATYPE(DirScrnRow,'n') then do;
   DirScrnRow=gMaxRow; TxtScrnRow=gMaxRow;
   DirScrnCol=gMaxCol; TxtScrnCol=gMaxCol;
   bShowBlank=0; if 0<pos('/A',ProcOpts) then bShowBlank=1;
   bFoldLines=1; if 0<pos('/W',ProcOpts) then bFoldLines=0;
   Call GetVidValidModes;
   TxtEditor='E';
   Call IniParms 'PUT';
end;

/* ================================================================== */
/* Set BROWSE global values from OS2.INI                              */
/* Note:  value is 1st byte - null terminated string.                 */
/* Full value is x'3100' for '1', for example.                        */
/* We have to strip off trailing null byte.                           */
/* ================================================================== */
TimeFmt=Strip(SysIni('USER','PM_National','iTime'),'t','00'x); /* 0=12hr, 1=234hr */
TimeSep=Strip(SysIni('USER','PM_National','sTime'),'t','00'x); /* single char     */
DateFmt=Strip(SysIni('USER','PM_National','iDate'),'t','00'x); /* 0/1/2: mdy/dmy/ymd */
DateSep=Strip(SysIni('USER','PM_National','sDate'),'t','00'x); /* single char     */
LZero  =Strip(SysIni('USER','PM_National','iLzero'),'t','00'x); /* single char     */

/* ================================================================== */
/* Set default colors, call internal IniColors to get or record them. */
/* ================================================================== */
ColrTxtBg=""; Call IniColors 'GET';
if ColrTxtBg="" | ColrTxtBg<30 | ColrTxtBg>47 THEN DO;
   Call COPYRIGHT; /* Display full notice on 1st use of program. */
   ColrTxt=30 /* Black */;         ColrTxtBg=47; /* White*/
   BriteTxt=0; BriteHd=0; ColrHd=30; ColrHdBg=46;
   Call IniColors 'Put';
END;

/* ================================================================== */
/* Display help information if the user requested it.                 */
/* ================================================================== */
if bHelp>0 then do;
   Call BROWSE_HELP; Call Copyright; signal COMMON_EXIT;
end;
/* ================================================================== */
/* OK, so does input file exist?  If file named does not exist, take  */
/* user to display of directory.                                      */
/* Note the use of signal below to alter path of program execution.   */
/* Non-structured signal use is flagged.                              */
/* ================================================================== */
If InFileSpec="" then do
   InFileSpec=Directory()||'\*.*';
end;
signal LOOK_DIR;               /* +++++++++++++++++++++++ */

BAD_SPEC:;                     /* +++++++++++++++++++++++ */
   signal off syntax;
   say "Bad syntax in file_spec.  I will assume you meant '*.*'";
   irc=SysGetKey('noecho');
   If InFileSpec\="" then do;
      InDrive=FILESPEC('d',InFileSpec);
      InPath =FILESPEC('p',InFileSpec);
      InFileSpec=InDrive||InPath;
   end;
   InFileSpec=InFileSpec||'*.*';
   signal LOOK_DIR;            /* +++++++++++++++++++++++ */

BAD_DRIVE:;                    /* +++++++++++++++++++++++ */
   signal off error;  say "Bad drive or path or filename.";
   say "Terminating.";  exit 8;

LOOK_DIR:;                     /* +++++++++++++++++++++++ */
InDrive=""; InDrive=FILESPEC('drive',InFileSpec);
DList.0=0; drop DList.;
signal on syntax NAME BAD_SPEC;/* +++++++++++++++++++++++ */
If InFileSpec="" then InFileSpec='*.*';
InFullSpec=""; InFullSpec=Stream(InFileSpec,'c','query exists');
signal off syntax;
if InFullSpec="" then do;
   if '..\*.*'=right(InFileSpec,6) then do;
      InFileSpec=InDrive||'\*.*'; SIGNAL LOOK_DIR;
   end;
   say "No files found for" InFileSpec; Call SysSleep(2);
   InFileSpec=InDrive||'..\*.*'; signal on error NAME BAD_DRIVE;
   signal LOOK_DIR;            /* +++++++++++++++++++++++ */
end;
signal off error;

irc=SysFileTree(InFullSpec,'DList','BT');
InDrive=""; InDrive=FILESPEC('drive',InFileSpec);
InPath="";   InPath=FILESPEC('path',InFileSpec);
InName="";   InName=FILESPEC('name',InFileSpec);
CDir=Directory(InDrive||InPath);
if InFullSpec="" | DList.0<1 THEN DO;
   Call Charout , "[2JNo files found in " InFullSpec;
   Call SysSleep(2);
   InFileSpec=gCDir;
   if '\'\=right(gCDir,1) then InFileSpec=InFileSpec||'\';
   InFileSpec=InFileSpec||'*.*';
   signal LOOK_DIR;
END;
DirFirst=1; CurrDirNr=1;

/* ================================================================== */
/* NOTE:  If you signal syntax or errors, do it with "clean" REXX.    */
/* Don't trap errors before you debug the REXX.                       */
/* ================================================================== */
/*signal on error   NAME ERROR_DISPLAY; */
/*signal on novalue NAME ERROR_DISPLAY;*/
/*signal on syntax  NAME ERROR_DISPLAY;*/
signal on halt    NAME ERROR_DISPLAY;

/* ================================================================== */
/* Get a map of the used hard drives, A:-Z: and add their names to    */
/* the current list of directories.                                   */
/* ================================================================== */
DriveMap=SysDriveMap('A:');
if DList.0 > 1 then do;
   iNrDirDrives=0;
   DO i=1 to length(DriveMap) by 3;  /* a: b: c: d: e: ... format */
      DriveLtr=substr(DriveMap,i,2);
      DList.0=DList.0+1; DLx=DList.0;
      DList.DLx=DATE('o')'/'substr(TIME(),1,5) '0' '-D---' ' 'DriveLtr'\';
      iNrDirDrives=iNrDirDrives+1;
   end;
   DList.0=DList.0+1; DLx=DList.0;
   DList.DLx=DATE('o')'/'substr(TIME(),1,5) '0' '-D---' ' ..\'
   iNrDirDrives=iNrDirDrives+1;
end;
DirLast=DList.0;

/* ================================================================== */
/* Adjust directory listing based on user .ini national values.       */
/* ================================================================== */
FDOffset=9+6+9+2; FLOffset=FDOffset+6; FNOffset=FLOffset+1;
do i=1 to DList.0;
   parse value DList.i with FDT FSize FAttr FName;
   parse value FileDateTime(FDT) with FDate FTime;
   FAttr=TRANSLATE(FAttr,"Ä","-");
   L=Length(FTime);
   if L<7 then do;
      if L>5 then FTime=' 'FTime;
      else if L<5 then FTime=' 'FTime;
   end;
   DList.i=FDate FTime FORMAT(FSize,8) FAttr FName;
end;

/* ================================================================== */
/* Sort the list of files.                                            */
/* ================================================================== */
if DList.0>80 then say "Sorting directory listing of" DList.0 "items.";
iLo=1; iHi=DList.0;
do forever;
   if iLo>iHi then leave;
   i=iLo;
   cLo=substr(DList.iLo,FLOffset,1)||substr(DList.iLo,FDOffset,1)||substr(DList.iLo,FNOffset);
   cHi=substr(DList.iHi,FLOffset,1)||substr(DList.iHi,FDOffset,1)||substr(DList.iHi,FNOffset);
   do forever;
      if i>iHi then leave;
      cX = substr(DList.i,FLOffset,1)||substr(DList.i,FDOffset,1)||substr(DList.i,FNOffset);
      iSwap=0;
      if cX<cLo then do;
         iSwap=1;
         cExch=DList.i; DList.i=DList.iLo; DList.iLo=cExch;
         cLo=substr(DList.iLo,FLOffset,1)||substr(DList.iLo,FDOffset,1)||substr(DList.iLo,FNOffset);
         cX =substr(DList.i,FLOffset,1)||substr(DList.i,FDOffset,1)||substr(DList.i,FNOffset);
      end;
      if cX>cHi then do;
         iSwap=1;
         cExch=DList.i; DList.i=DList.iHi; DList.iHi=cExch;
         cHi=substr(DList.iHi,FLOffset,1)||substr(DList.iHi,FDOffset,1)||substr(DList.iHi,FNOffset);
         cX =substr(DList.i,FLOffset,1)||substr(DList.i,FDOffset,1)||substr(DList.i,FNOffset);
      end;
      if iSwap<1 then i=i+1;
   end;
   iLo=iLo+1; iHi=iHi-1;
end;


/* ================================================================== */
/* If there is more than one file in list, then display directory     */
/* list and let user choose from the files displayed.                 */
/* ================================================================== */
DISPLAY_FILE_LIST:;
CurrDirNr=1;
CurrDrvName=FILESPEC('d',Stream(InFullSpec,'c','query exists'));
CurrDirName=FILESPEC('p',Stream(InFullSpec,'c','query exists'));
if TxtScrnRow\=DirScrnRow | zMaxRow\=DirScrnRow then do;
   '@mode con1' DirScrnCol','DirScrnRow;
   bVideoReset=1; Call GetVideoSize;
end;

/* ================================================================== */
/* DO loop until user does a selection, then we interpret what the    */
/* user selected.                                                     */
/* ================================================================== */
DFg=67-ColrTxt; DBg=87-ColrTxtBg;
gbDirList=0; gbQUIT=0;
ReplyStr="";
DateLine="Directory: "CurrDrvName||CurrDirName;
sListSection='DIR';
if DList.0>1 then do;
   sFileType='TEXT'; /* reset file type */
   if DirLast<gMaxRow & gMaxRow>25 then '@mode con1' gMaxCol','MAX(DirLast,25);
   Call DirDisplay DirFirst; DirLine=1; bDoDisplay=0;
   gbDirList=1;
   do while ReplyStr\="EXIT";
      Call SysCurState 'OFF';
      CurrLineText=SysTextScreenRead(DirLine,0,gMaxCol);
      Call charout ,'['DirLine+1';1H['1-BriteTxt';'Dfg';'DBg'm'CurrLineText;
      Call KeyStroke;
      SELECT;
      WHEN ReplyStr="COLR" THEN DO;
         Call ReplyStrCOLR; Call DirDisplay DirFirst;
      END;
      WHEN ReplyStr="CURS" THEN DO;
         SELECT /* Action when ReplyStr=CURS */;
         WHEN Action="BF" then do;
            DirFirst=DirLast; DirLine=1; bDoDisplay=1; end;
         WHEN Action="DN" THEN DO;
            Call NormalText DirLine;
            DirLine=DirLine+1;
            If DirLine>LastScrnLine-1 then do;
               DirLine=1; DirFirst=DirFirst+LinesPerPage;
               if DirFirst>DirLast then DirFirst=DirLast;
               bDoDisplay=1;
            end;
         END;
         WHEN Action="PB" THEN DO;
            DirFirst=DirFirst-LinesPerPage;
            if DirFirst<1 then DirFirst=1;
            DirLine=1; bDoDisplay=1;
         END;
         WHEN Action="PF" THEN DO;
            DirFirst=DirFirst+LinesPerPage;
            if DirFirst>DirLast-1 then DirFirst=DirLast-1;
            DirLine=1; bDoDisplay=1;
         END;
         WHEN Action="TF" then do;
            DirFirst=1; DirLine=1; bDoDisplay=1;
         end;
         WHEN Action="UP" THEN DO;
            Call NormalText DirLine;
            DirLine=DirLine-1;
            if DirLine<1 then do;
               bDoDisplay=1;
               DirFirst=DirFirst-LinesPerPage;
               if DirFirst<1 then do;
                  DirLine=LinesPerPage+DirFirst-1;
                  if DirLine<1 then DirLine=1;
                  DirFirst=1;
               end;
               else DirLine=LinesPerPage;
            end;
         END;
         OTHERWISE NOP;
         END; /* end select */
         if bDoDisplay>0 then do;
            bDoDisplay=0; Call DirDisplay DirFirst;
         end;
      END;
      WHEN ReplyStr="EDIT" THEN DO;
         signal off error; signal off syntax;
         parse value CurrLineText with FDate FTime FSize FAttr FName;
         TxtEditor FName;
         SIGNAL AFTER_EDIT;
      END;
      WHEN ReplyStr="EXIT" THEN signal COMMON_EXIT;
      WHEN ReplyStr="FILE" THEN SIGNAL FILE_DIALOG;
      WHEN ReplyStr="HEAD" THEN do;
         Call ReplyStrHEAD; Call DirDisplay DirFirst;
      end;
      WHEN ReplyStr="HELP" THEN do;
         Call BROWSE_HELP; Call DirDisplay DirFirst; end;
      WHEN ReplyStr="PARM" THEN Call ReplyStrPARM;
      WHEN ReplyStr="PICK" THEN DO;
         CurrDirNr=DirFirst+DirLine-1; ReplyStr='EXIT';
      end;
      WHEN ReplyStr="SCRN" THEN Call ReplyStrSCRN;
      WHEN ReplyStr="SRCH" THEN Call SrchFile;
      OTHERWISE nop;
      end; /* select */
      if bDoDisplay>0 then do;
         bDoDisplay=0; Call DirDisplay DirFirst;
      end;
   END; /* DO */
END; /* DO */
else gbQUIT=1;

/* ================================================================== */
/* Obtain file date, time and format them as user wants.              */
/* ================================================================== */
LISTFILE:;
parse value DList.CurrDirNr with FDate FTime FSize FAttr FName;
FName=Strip(FName);
if 0<pos('D',FAttr) then do;
   gCDir=Directory();
   if FName='..\' then do;
      CDir=Directory(); iLC=length(CDir);
      if '\' \= right(CDir,1) then CDir=CDir||'\';
      iLC=Length(CDir);  CDir=Left(CDir,iLC-1);
      if ':'=Right(CDir,1) then do;
         CDir=CDir||'\'; InFileSpec=CDir'*.*'; SIGNAL LOOK_DIR;
      end;
      iPS=Lastpos('\',CDir);
      CDir=Left(CDir,iPS-1); if ':'=right(CDir,1) then CDir=CDir||'\';
      InFileSpec=Directory(CDir);
      if '\'\=right(InFileSpec,1) then InFileSpec=InFileSpec||'\';
      InFileSpec=InFileSpec||'*.*';
      Signal LOOK_DIR;
   end;
   InFileSpec=FName;
   CDir=Directory(InFileSpec);
   if '\'\=right(InFileSpec,1) then InFileSpec=InFileSpec'\';
   InFileSpec=InFileSpec'*.*'; Call SysCls;
   signal LOOK_DIR;
end;
DateLine=FILESPEC('N',FName) FDate FTime FSize;

/* ================================================================== */
/* If the file type is not set, test the type of file by reading the  */
/* first 80 bytes.  Scan the 80 byte block, ignoring CRLF, FF         */
/* and count the number of chars less than '20'x.  If the majority    */
/* is less than '20'x then set sFileType='BINARY'.  The test for an   */
/* .exe file is 'MZ' bytes 1+2, then '00'x in 1st 8 positions.        */
/* ================================================================== */
if sFileType\='BINARY' then do;
   xArray=charin(FName,1,80); xCount=0; cCount=0;
   if 'MZ'=substr(xArray,1,2) then do i=3 to 8;
      if '00'x=substr(xArray,i,1) then do;
         sFileType='BINARY'; leave;
      end;
   end;
   else do;
      do i=1 to 80;
         c=substr(xArray,i,1);
         if c<'20'x then xCount=xCount+1; else cCount=cCount+1;
      end;
      if xCount>cCount then sFileType='BINARY';
   end;
   xArray=charin(FName,1,0); drop xArray; /* point file to start */
end;

/* ================================================================== */
/* Read the file into storage as array LineArray.                     */
/* Display odometer every 1000 lines.  Capture high-water length.     */
/* Don't collect blank lines in groups of 2 or more.                  */
/* Fold lines at zMaxCol size, continuing a line into the next array  */
/* item.  If the drive is a: | b:, then trip Odo every 100 lines.     */
/* ================================================================== */
if TxtScrnRow\=DirScrnRow | zMaxRow\=TxtScrnRow then do;
   '@mode con1 80,25';
   bVideoReset=1; Call GetVideoSize;
end;
say "[1;5;31;40m[2JWorking...[0;1;36;40m";
Drv=FILESPEC('d',FName);
if Drv='A:' | Drv='B:' then OdoTrip=99; else OdoTrip=999;
InBytes=0; LineLast=0; LineFirst=1; Odo=0; MaxLineLen=0;
bBlankLast=0; InBlanks=0; InLines=0;
do forever;
   if 1>Lines(FName) then leave;
   LineLast=LineLast+1; InLines=InLines+1;
   if sFileType='TEXT' then LineArray.LineLast=LINEIN(FName);
   else                     LineArray.LineLast=CHARIN(FName,,80);
   LLen=LENGTH(LineArray.LineLast);
   Odo=Odo+1; InBytes=InBytes+LLen;  MaxLineLen=MAX(MaxLineLen,LLen);

   if bFoldLines>0 then do while LLen>zMaxCol;
      LP1=LineLast+1;
      LineArray.LP1=substr(LineArray.LineLast,zMaxCol+1);
      LineArray.LineLast=substr(LineArray.LineLast,1,zMaxCol);
      LineLast=LP1;
      LLen=LENGTH(LineArray.LineLast);
   end;
   else nop;

   if bShowBlank<1 then do;
      if LineArray.LineLast="" | LineArray.LineLast=COPIES('20'x,LLen) then do;
         if bBlankLast>0 then do;
            LineLast=LineLast-1; InBlanks=InBlanks+1;
         end;
         bBlankLast=1;
      end;
      else bBlankLast=0;
   end;
   if Odo>OdoTrip THEN DO; Odo=0;
      irc=charout(,"[s"InLines "lines," InBytes"/"FSize "bytes," InBlanks "lines dropped," InLines-InBlanks "kept.[u");
   END;

END; /* do forever */
irc=stream(FName,'c','close');

if TxtScrnRow\=DirScrnRow | zMaxRow\=TxtScrnRow then do;
   '@mode con1' TxtScrnCol','TxtScrnRow;
   bVideoReset=1; Call GetVideoSize;
end;
MaxScr=(LineLast+LinesPerPage-1)%LinesPerPage;

sListSection='FILE';
ReplyStr="";
if LineLast<gMaxRow & gMaxRow>25 then '@mode con1' gMaxCol','MAX(LineLast,25);
CurrScr=1; Call DataDisplay LineFirst; bDoDisplay=0;
do while ReplyStr\="EXIT";
   Call KeyStroke; parse value SysCurPos() with CRow CCol;
   SELECT;
   WHEN ReplyStr="COLR" THEN DO;
      Call ReplyStrCOLR; Call DataDisplay LineFirst;
   end;
   WHEN ReplyStr="CURS" THEN DO;
      bDoDisplay=1; /* assume we redo display most of the time */
      SELECT /* Action when ReplyStr=CURS */;
      WHEN Action="BF" then  LineFirst=LineLast-1;
      WHEN Action="DN" THEN DO;
         LineFirst=LineFirst+1;
         If LineFirst>LineLast then LineFirst=LineLast;
         else bDoDisplay=0;
      END;
      WHEN Action="PB" THEN DO;
         LineFirst=LineFirst-LinesPerPage;
         if LineFirst<1 then LineFirst=1;
      END;
      WHEN Action="PF" THEN DO;
         LineFirst=LineFirst+LinesPerPage;
         if LineFirst>LineLast-1 then LineFirst=LineLast-1;
      END;
      WHEN Action="TF" then LineFirst=1;
      WHEN Action="UP" THEN DO;
         LineFirst=LineFirst-1;
         If LineFirst<0 then LineFirst=1;
         else bDoDisplay=0;
      END;
      OTHERWISE NOP;
      END;
      if bDoDisplay=1 then call DataDisplay LineFirst;
   END;
   WHEN ReplyStr="EDIT" then do;
      say "Editor:" TxtEditor; irc=sysgetkey();
      TxtEditor FName;
      SIGNAL AFTER_EDIT;
   end;
   WHEN ReplyStr="EXIT" THEN do;
      say "[0;1;36;40m[2J"; leave;
   END;
   WHEN ReplyStr="FILE" THEN SIGNAL FILE_DIALOG;
   WHEN ReplyStr="HEAD" THEN DO;
      Call ReplyStrHEAD; Call DataDisplay LineFirst;
   end;
   WHEN ReplyStr="HELP" THEN DO;
      Call BROWSE_HELP;
   END;
   WHEN ReplyStr="PARM" THEN DO; Call ReplyStrPARM; end;
   WHEN ReplyStr="SCRN" THEN DO; Call ReplyStrSCRN; end;
   WHEN ReplyStr="SRCH" THEN DO;
      Call SrchText; bDoDisplay=1; end;
   OTHERWISE NOP;
   END; /* SELECT */
   Call DataDisplay LineFirst;
END; /* DO */
if gbQUIT<1 then signal DISPLAY_FILE_LIST;
/* ================================================================== */
COMMON_EXIT:;
if bVideoReset>0 then '@mode con1' zMaxCol','zMaxRow;
else Call SysCls;
Call SysCurState 'ON';
exit Browse_RC;

/* ================================================================== */
AFTER_EDIT:;
      Call CharOut , "[0;1;36;40m[2J[5BEdit complete.  Returning to directory.";
      SIGNAL LOOK_DIR;

/* ================================================================== */
BROWSE_ERROR:;
say "[0;5;1;31;40m";
say '*** BROWSE CMD HAS TERMINATED WITH ERROR(S) ***'; Browse_RC=8;
say '[0;1;36;40m'; signal COMMON_EXIT;

/* ================================================================== */
BROWSE_HALT:;
say "[0;5;1;31;40m";
say '*** BROWSE CMD TERMINATED BY USER ***'; Browse_RC=0;
say '[0;1;36;40m'; signal COMMON_EXIT;

/* ================================================================== */
BROWSE_HELP:;
'@mode con1 80,25';
irc=CHAROUT(,"["ColrHd";"ColrHdBg"m[2J"); iR=1;
Call ScrDisplay iR  "     BROWSE Command HELP INFORMATION" BrowseVersion; iR=iR+1;
Call ScrDisplay iR  "Command Syntax: browse [filespec] [/a] [/b] [/h] [/i] [/w]";iR=iR+1;
Call ScrDisplay iR  "  /a=show blank lines, /b=binary file, /h=help"; iR=iR+1;
Call ScrDisplay iR  "  /i=init saved parms, /w=don't fold long lines."; iR=iR+1;
Call ScrDisplay iR  "Navigation keys:       (Col 1 Notes: +=planned)"; iR=iR+1;
Call ScrDisplay iR  "  Position to top  of file: . . . . . . .  HOME"; iR=iR+1;
Call ScrDisplay iR  "  Position to bottom of file:               END"; iR=iR+1;
Call ScrDisplay iR  "  Scroll to next     page:  . . . . . . .  PgDn"; iR=iR+1;
Call ScrDisplay iR  "  Scroll to previous page:                 PgUp"; iR=iR+1;
Call ScrDisplay iR  "  HELP display: . . . . . . . . . . . . . .  F1"; iR=iR+1;
Call ScrDisplay iR  "  Save Current parameters:                   F2"; iR=iR+1;
Call ScrDisplay iR  "  Change text foreground color: . . . . . .  F5"; iR=iR+1;
Call ScrDisplay iR  "  Change text background color:              F6"; iR=iR+1;
Call ScrDisplay iR  "  Change head foreground color: . . . . . .  F7"; iR=iR+1;
Call ScrDisplay iR  "  Change head background color:              F8"; iR=iR+1;
Call ScrDisplay iR  "+ Toggle Hexadecimal data display:[future]   F9"; iR=iR+1;
Call ScrDisplay iR  "  Set screen size & select editor:          F10"; iR=iR+1;
Call ScrDisplay iR  "  Toggle NOFOLD of long lines:              F11"; iR=iR+1;
Call ScrDisplay iR  "  Select higlighted directory/file:       ENTER"; iR=iR+1;
Call ScrDisplay iR  "  EDIT file selected or being browsed         E"; iR=iR+1;
Call ScrDisplay iR  "  Set new directory/file to browse            F"; iR=iR+1;
Call ScrDisplay iR  "+ Search for text (partially implemented)     S"; iR=iR+1;
Call ScrDisplay iR  "  EXIT/END:         ALT-F4 / F3           / ESC"; iR=iR+1;
Call ScrDisplay iR  "*** Hit any key to continue ***";
irc=SysGetKey('noecho');
'@mode con1' gMaxCol','gMaxRow;
return 0;

/* ================================================================== */
COPYRIGHT:;
   if bQuiet>0 then return;
   Call Copyright_S;
   TAB="     ";
   say tab TAB"This program is published as shareware by the author, who ";
   say tab TAB"ascribes to the principles and practices of the Association";
   say tab TAB"of Shareware Professionals. If you use this program, please";
   say tab TAB"support the shareware principles by registering this program";
   say tab TAB"with the author for a suggested fee of $2. The author will";
   say tab TAB"send you the next published version at no additional cost.";
   say tab TAB"You may copy this program freely and distribute it as long";
   say tab TAB"as there is no fee charged for this program by itself.";
   say " [0;1;33;44m[1B";
   say TAB TAB TAB TAB TAB" Bruce E. H”gman";
   say TAB TAB TAB TAB TAB" 629 S. 24th St.";
   say TAB TAB TAB TAB TAB" Arlington VA 22202-2525";
   irc=SysGetKey('noecho');
   return;

/* ================================================================== */
Copyright_S:;
   if bQuiet>0 then return;
   Call charout ,'[1;44m[2J';
   call charout ,'[1;33;43m';
   call charout ,'[4;17H';
   call charout ,' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿';
   call charout ,'[5;17H';
   call charout ,' ³ Author: Bruce E. H”gman BIX: bhogman      ³';
   call charout ,'[6;17H';
   call charout ,' ³ (C) Copyright 1992. All Rights Reserved.  ³';
   call charout ,'[7;17H';
   call charout ,' ³ NaSpa: HogmBru3 CompuServ: 72050,1327     ³';
   call charout ,'[8;17H';
   call charout ,' ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'BrowseVersion'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ';
   call charout ,'[0;1;37;44m[2B[80D';
   call SysSleep(1);
   return;

/* ================================================================== */
      LineArray.LineLast=TRANSLATE(CHARIN(FName,,80),OUTR,INTR);
DataDisplay:;
   Call SysCurState 'off';
   if LineFirst < 1 then LineFirst=1;   j=LineFirst;
   CurrScr = (LineFirst + LinesPerPage - 1) % LinesPerPage;
   NrScrRow = Min(LinesPerPage,LineLast);
   EndNr = MIN(LineLast,LineFirst + LinesPerPage -1);
   MaxScr = (LineLast + LinesPerPage -1) % LinesPerPage;
   if sFileType='BINARY' then sBin='/B';   else sBin='';
   if bFoldLines=0 then sNF='/W';   else sNF='';
   Call ScrDisplay 1 DateLine "-"  CurrScr"/"MaxScr" pages. Lines" LineFirst"-"EndNr "of" LineLast"."sBin||sNF;
   if bHexDisplay<1 then;
      do i=1 to NrScrRow;
         if j>LineLast then LineArray.j="";
         Call ScrDisplay i+1 TRANSLATE(LineArray.j,OUTR,INTR);
         j=j+1;
      END;
   else do /* Translate data into vertical hex */ ;
      iLastHexLine=(NrScrRow%3); HexLine1=""; HexLine2="";
      do i=1 to iLastHexLine by 3;
         if j>LineLast then leave; j=j+1;
         Call ScrDisplay i+1 TRANSLATE(LineArray.j,OUTR,INTR);
         HexDataLine=LineArray.j;
         Call HexTranslate;
         Call ScrDisplay i+2 HexLine1;
         Call ScrDisplay i+3 HexLine2;
      end;
   END;
   return;

/* ================================================================== */
DirDisplay:;
   Call SysCurState 'ON';  if DirFirst<1 then DirFirst=1;
   CurrScr = (DirFirst + LinesPerPage - 1) % LinesPerPage;
   NrScrRow = Min(LinesPerPage,DirLast);  j=DirFirst;
   EndNr = MIN(DirLast,DirFirst + LinesPerPage - 1);
   MaxScr = (DirLast + LinesPerPage - 1) % LinesPerPage;
   Call ScrDisplay 1 DateLine "-"  CurrScr"/"MaxScr" pages. Files" DirFirst"-"EndNr "of" DirLast".";
   do i=1 to NrScrRow;
      if j > DirLast then DList.j="";
      Call ScrDisplay i+1 DList.j; j=j+1;
   END;
   return;

/* ================================================================== */
ERROR_DISPLAY:;
  Call SysCurState 'ON';
  if condition('c')='HALT' then signal BROWSE_HALT;
  say 'BROWSE SIGNAL TRAP at line'SIGL;
  say condition('c') condition('i') condition('d') condition('s');
  signal BROWSE_ERROR;

/* ================================================================== */
/* returns filedate filetime  given format: yy/mm/dd/hh/mm */
/* ================================================================== */
FileDateTime:;
   parse arg FDT;
   TODHr=substr(FDT,10,2); TODMn=substr(FDT,13,2);
   YY=substr(FDT,1,2); MM=substr(FDT,4,2); DD=substr(FDT,7,2);
   SELECT;
      WHEN TimeFmt='0' THEN DO;
         AMPM='AM';
         if TODHr>11 THEN DO;
            AMPM='PM'; if TODHr>12 then TODHr=TODHr-12;
         END;
         if length(TODHr)<2 then if Lzero=1 then TODHr="0"TODHr;
         UTime=TODHr||TimeSep||TODMn||AMPM;
      END;
      WHEN TimeFmt='1' THEN DO;
         TODHr=TODHr+0;
         if length(TODHr)<2 then if Lzero=1 then TODHr="0"TODHr;
         UTime=TODHr||TimeSep||TODMn;
      END;
      OTHERWISE NOP;
   END; /* select */
   SELECT;
      WHEN DateFmt='0' then  UDate=MM||DateSep||DD||DateSep||YY;
      WHEN DateFmt='1' then  UDate=DD||DateSep||MM||DateSep||YY;
      WHEN DateFmt='2' then  UDate=YY||DateSep||MM||DateSep||DD;
      OTHERWISE nop;
   END; /* select */
   return UDate UTime;

/* ================================================================== */
FILE_DIALOG:
   dTxt='Enter new filespec: [d:] [\path] filename (wild cards OK)';
   Call WinOpen dTxt;
   call charout , "[u[1B>";
   parse upper pull InFileSpecTst;
   if InFileSpecTst\="" then InFileSpec=InFileSpecTst;
   SIGNAL LOOK_DIR;

/* ================================================================== */
GetVideoSize:;
   parse value SysTextScreenSize() with gMaxRow gMaxCol;
   LinesPerPage=gMaxRow-2;
   return;

/* ================================================================== */
/* Notes on video modes set using mode command:                       */
/* Modes with lines less than 25 produce larger characters and may be */
/* useful to sight-impaired users.                                    */
/* ================================================================== */
GetVidValidModes:;
   Call SysCls;
   say "About to test video for valid mode range using 80-col display.";
   say "Hit any key to continue...";
   irc=SysGetKey(); Call SysCls; bVidError=0;
   ValidVideoModes="";
   do i=60 to 14 by -1;
      bVidError=0; call on error name erropt;
      '@mode con1 80,'i;
      if bVidError<1 then do;
         ValidVideoModes=ValidVideoModes i;
      end;
   end;
   '@mode con1 80,25';
   Say 'valid video modes are: 80x';
   say ValidVideoModes; irc=SysGetKey(); Call SysCls;
   irc=SysIni('USER','BROWSE','ValidVideoModes',ValidVideoModes);
   call off error;
   return;
   erropt: bVidError=1; return;

/* ================================================================== */
/* Translate line of data into hexadecimal for vertical display.      */
/* Returns HexLine1 and HexLine2.                                     */
/* Input is HexDataLine.                                              */
/* ================================================================== */
HexTranslate:;
   HexLine1=""; HexLine2="";
   do ix=1 to LENGTH(HexDataLine);
      sHex=c2x(substr(HexDataLine,ix,1));
      HexLine1=HexLine1||substr(sHex,1,1);
      HexLine2=HexLine2||substr(sHex,2,1);
   end;
   return;

/* ================================================================== */
IniColors:;
   parse upper arg Operation;
   if Operation="GET" THEN DO;
      ColrTxtBg =SysIni('USER','BROWSE','ColorTextBg');
      ColrHdBg  =SysIni('USER','BROWSE','ColorHeadBg');
      ColrTxt   =SysIni('USER','BROWSE','ColorText');
      ColrHd    =SysIni('USER','BROWSE','ColorHead');
      BriteTxt  =SysIni('USER','BROWSE','BriteText');
      BriteHd   =SysIni('USER','BROWSE','BriteHead');
   END;
   else do;
      irc       =SysIni('USER','BROWSE','ColorTextBg',ColrTxtBg);
      irc       =SysIni('USER','BROWSE','ColorHeadBg',ColrHdBg);
      irc       =SysIni('USER','BROWSE','ColorText',ColrTxt);
      irc       =SysIni('USER','BROWSE','ColorHead',ColrHd);
      irc       =SysIni('USER','BROWSE','BriteText',BriteTxt);
      irc       =SysIni('USER','BROWSE','BriteHead',BriteHd);
   END;
   return;

/* ================================================================== */
IniParms:;
   parse upper arg Operation;
   if Operation="GET" THEN DO;
      DirScrnRow     =SysIni('USER','BROWSE','DirScrnRow');
      DirScrnCol     =SysIni('USER','BROWSE','DirScrnCol');
      TxtEditor      =SysIni('USER','BROWSE','TxtEditor');
      TxtScrnRow     =SysIni('USER','BROWSE','TxtScrnRow');
      TxtScrnCol     =SysIni('USER','BROWSE','TxtScrnCol');
      bShowBlank     =SysIni('USER','BROWSE','bShowBlank');
      bFoldLines     =SysIni('USER','BROWSE','bFoldLines');
      ValidVideoModes=SysIni('USER','BROWSE','ValidVideoModes');
   END;
   else do;
      irc       =SysIni('USER','BROWSE','DirScrnRow',DirScrnRow);
      irc       =SysIni('USER','BROWSE','DirScrnCol',DirScrnCol);
      irc       =SysIni('USER','BROWSE','TxtEditor',TxtEditor);
      irc       =SysIni('USER','BROWSE','TxtScrnRow',TxtScrnRow);
      irc       =SysIni('USER','BROWSE','TxtScrnCol',TxtScrnCol);
      irc       =SysIni('USER','BROWSE','bShowBlank',bShowBlank);
      irc       =SysIni('USER','BROWSE','bFoldLines',bFoldLines);
      irc=SysIni('USER','BROWSE','ValidVideoModes',ValidVideoModes);
   END;
   return;

/* ================================================================== */
KeyStroke:;
do forever;
   parse value SysCurPos() with VidRow VidCol;
   Action=""; key=SysGetKey('noecho');
   if c2x(key)='1B' THEN DO; ReplyStr="EXIT"; Action="ES"; return; END;
   kv=c2d(key);
   if c2x(key)='E0' THEN DO;
      kv=1000; key=SysGetkey('noecho'); kv=kv+c2d(key);
   END;
   else do;
      if kv=0 THEN DO; kv=1000; key=SysGetKey('noecho'); kv=kv+c2d(key);
      END;
   END;
   if "K." \= substr(k.kv,1,2) THEN DO;
      SELECT;
      when k.kv="UCURS"  THEN DO; ReplyStr="CURS"; Action="UP"; return; END;
      when k.kv="DCURS"  THEN DO; ReplyStr="CURS"; Action="DN"; return; END;
      when k.kv="HOME"   THEN DO; ReplyStr="CURS"; Action="TF"; return; END;
      when k.kv="END"    THEN DO; ReplyStr="CURS"; Action="BF"; return; END;
      when k.kv="INS"    THEN DO; ReplyStr="CURS"; Action="HI"; return; END;
      when k.kv="DEL"    THEN DO; ReplyStr="CURS"; Action="LO"; return; END;
      when k.kv="PGUP"   THEN DO; ReplyStr="CURS"; Action="PB"; return; END;
      when k.kv="PGDN"   THEN DO; ReplyStr="CURS"; Action="PF"; return; END;
      when k.kv="EDIT"   THEN DO; ReplyStr="PICK"; Action="ED"; return; END;
      when k.kv="ENTER"  THEN DO; ReplyStr="PICK"; Action="LV"; return; END;
      when k.kv="F1"     THEN DO; ReplyStr="HELP"; Action="F1"; return; END;
      when k.kv="F2"     THEN DO; ReplyStr="PARM"; Action="SV"; return; END;
      when k.kv="F3"     THEN DO; ReplyStr="EXIT"; Action="F3"; return; END;
      when k.kv="ALT-F4" THEN DO; ReplyStr="EXIT"; Action="QU"; return; END;
      when k.kv="F5"     THEN DO; ReplyStr="COLR"; Action="FG"; return; END;
      when k.kv="F6"     THEN DO; ReplyStr="COLR"; Action="BG"; return; END;
      when k.kv="F7"     THEN DO; ReplyStr="HEAD"; Action="FG"; return; END;
      when k.kv="F8"     THEN DO; ReplyStr="HEAD"; Action="BG"; return; END;
      when k.kv="F9"     THEN DO; ReplyStr="SCRN"; Action="HX"; return; END;
      when k.kv="F10"    THEN DO; ReplyStr="SCRN"; Action="SZ"; return; END;
      when k.kv="F11"    THEN DO; ReplyStr="SCRN"; Action="NF"; return; END;
      when k.kv="F"      THEN DO; ReplyStr="FILE"; Action="IO"; return; END;
      when k.kv="S"      THEN DO; ReplyStr="SRCH"; Action="IO"; return; END;
      when k.kv="E"      THEN DO; ReplyStr="EDIT"; Action="EX"; return; END;
      otherwise nop;
      END;
   END;
   if Action \= "" then return;
END;
return;

/* ================================================================== */
NormalText:;
   parse arg CurrScrnLn;
   CurrLineText=SysTextScreenRead(CurrScrnLn,0,gMaxCol);
   Call charout ,'['CurrScrnLn+1';1H['BriteTxt';'ColrTxt';'ColrTxtBg'm'CurrLineText;
   return;

/* ================================================================== */
PullScreenSize:;
   parse arg VTTxt;
   Call WinOpen VTTxt;
   irc=charout(,'[u[1B >[s __ __ <[u');
   parse pull iCol iRow;
   if 0<DATATYPE(iCol,'n') & 0<DATATYPE(iRow,'n') then do;
      if 0<pos(iRow,ValidVideoModes) then do;
         if 0<iCol & 0<iRow then do;
            '@mode con1' iCol','iRow;
            call GetVideoSize;
         end;
      end;
      else do;
         Call SysCls;
         say 'Video mode' iCol','iRow '(col,row) invalid.'
         say "Valid video modes are";
         say ValidVideoModes;
         irc=SysGetKey();
      end;
   end;
   drop VTTxt tTLen iWinCol iWinRow tColrTxt tColrTxtBg iCol iRow;
   return;

WinOpen:;
   parse arg VTTxt;
   parse value SysTextScreenSize() with iRow iCol;
   tTLen=LENGTH(VTTxt);
   iWinCol=(iCol-tTLen)%2; iWinRow=iRow%3;
   tColrTxt=37-ColrTxt+30; tColrTxtBg=47-ColrTxtBg;
   irc=charout(,'[0;'tColrTxt';'tColrTxtBg'm');
   do i=1 to iWinRow;
      irc=charout(,'['iWinRow+i';'iWinCol'H'copies(' ',tTLen+2));
   end;
   i=iWinRow%2;
   irc=charout(,'['iWinRow+i';'iWinCol+1'H');
   irc=charout(,'[s'VTTxt);
   return;

/* ================================================================== */
PullTxtEditor:;

/* ================================================================== */
ReplyStrCOLR:;
   if Action="FG" THEN DO;
      ColrTxt=ColrTxt+BriteTxt; if ColrTxt=38 then ColrTxt=30;
      if BriteTxt=0 then BriteTxt=1; else BriteTxt=0;
   END;
   else do; ColrTxtBg=ColrTxtBg+1; if ColrTxtBg=48 then ColrTxtBg=40; END;
   bDoDisplay=1;
   return;

ReplyStrHEAD:;
   if Action="FG" THEN DO;
      ColrHd=ColrHd+BriteHd; if ColrHd=38 then ColrHd=30;
      if BriteHd=0 then BriteHd=1; else BriteHd=0;
   END;
   else do; ColrHdBg=ColrHdBg+1; if ColrHdBg=48 then ColrHdBg=40; end;
   Return;

ReplyStrPARM:;
   Call IniColors 'Put'; Call IniParms 'Put';
   '@mode con1 80,25';  Call Copyright;
   irc=charout(,"[1;1H[0;5;31;47mCurrent Values Saved[0;36;40m");
   Call SysSleep(1); '@mode con1 ' gMaxCol','gMaxRow;
   bDoDisplay=1;
   Return;

ReplyStrSCRN:; /* Input:  sListSection=DIR/FILE */
   SELECT;
   WHEN Action="SZ" then do;
      dTxt='Enter \DIR list screen size as Cols Rows or 0 to Quit';
      Call PullScreenSize dTxt; drop dTxt;
      DirScrnRow=gMaxRow; DirScrnCol=gMaxCol;
      if sListSection='FILE' then  Call DataDisplay LineFirst;
      else                         Call DirDisplay DirFirst;
      fTxt='Enter FILE list screen size as Cols Rows or 0 to Quit';
      Call PullScreenSize fTxt; drop fTxt;
      TxtScrnRow=gMaxRow; TxtScrnCol=gMaxCol;
      if sListSection='DIR' then '@mode con1' DirScrnCol','DirScrnRow;
      if sListSection='FILE' then  Call DataDisplay LineFirst;
      else                         Call DirDisplay DirFirst;
      eTxt='Enter full path and filename of editor program';
      Call WinOpen eTxt;
      call charout ,"[u[1B";
      parse upper pull TxtEditor;
      if '.EXE'\=Right(TxtEditor,4) then do;
         TstEditName=TxtEditor||'.EXE';
         FExists=Stream(TstEditName,'c','query exists');
         if FExists\="" then do;
            TxtEditor=TstEditName; say " OK";
         end;
         else do;
            TstEditName=TxtEditor||'.COM';
            FExists=Stream(TstEditName,'c','query exists');
            if FExists\="" then do;
               TxtEditor=TstEditName; say " OK";
            end;
            else do;
               call charout ,"[1B[80DUnable to locate" TxtEditor;
               irc=sysgetkey();
               TxtEditor='E';
            end;
         end;
      end;
      else do;
         FExists=Stream(TxtEditor,'c','query exists');
         if FExists="" then do;
            call charout ,"[1B[80DUnable to locate" TxtEditor;
            irc=sysgetkey(); TxtEditor='E';
         end;
         else say " OK";
      end;
   end;
   WHEN Action="NF" then do;
      if bFoldLines=0 then bFoldLines=1; else bFoldLines=0;
   end;
   OTHERWISE NOP;
   END; /* select */
   bDoDisplay=1;
   Return;

/* ================================================================== */
ScrDisplay:;
parse arg RowNr LineData;
if RowNr<2 THEN DO; SFgColr=ColrHd; Bright=BriteHd; SBgColr=ColrHdBg; END;
else do; SFgColr=ColrTxt; Bright=BriteTxt; SBgColr=ColrTxtBg; END;
irc=CHAROUT(,"["RowNr";1H["Bright";"SFgColr";"SBgColr"m[K"LineData"["RowNr";1H");
LastScrnLine=RowNr;
return;


/* ================================================================== */
SrchFile:;
   dTxt="Search text at directory level is not yet implemented.";
   Call WinOpen dTxt;
   call charout , "[u[1BHit any key to return";
   irc=sysgetkey(); bDoDisplay=1;
   return;

/* ================================================================== */
SrchText:;
   dTxt="Enter text to search for.  Case is not important.";
   Call WinOpen dTxt; call SysCurState ON;
   call charout , "[u[1B>";
   parse pull SrchString;
   Call SysFileSearch SrchString,FName,'Srch','n';
   if Srch.0<1 then do;
      Call DataDisplay;
      dTxt="No lines found with text" SrchString;
      Call WinOpen dTxt;
      call charout , "[u[1B[5CHit any key to continue.";
      irc=SysGetKey();
   end;
   else do;
      CDir=Directory();
      'ERASE' CDir'\BROWSE.TMP';
      do i=1 to Srch.0;
         irc=Lineout(CDir'\BROWSE.TMP',Srch.i);
      end;
      irc=Stream(CDir'\BROWSE.TMP','c','close');
      call browse CDir'\browse.tmp /Q';
      'ERASE' CDir'\BROWSE.TMP';
   end;
   return;

/* ================================================================== */
SETKN:;
k.70='F'; k.102='F';k.83='S'; k.115='S'; k.69='E'; k.101='E';
k.1059='F1'; k.1060='F2'; k.1061='F3';   k.1062='F4';   k.1063='F5';
k.1064='F6'; k.1065='F7';    k.1066='F8';   k.1067='F9';   k.1068='F10';
k.1071='HOME'; k.1072='UCURS'; k.1073='PGUP'; k.1075='LCURS';
k.1077='RCURS';
k.1081='PGDN';
k.1079='END'; k.1080='DCURS'; k.1082='INS';  k.1083='DEL';
k.1107='ALT-F4'; k.1133='F11';   k.1134='F12';  k.13='ENTER';  return;

