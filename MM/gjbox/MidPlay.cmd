/***************************************************************************
 *      *** MIDPLAY - Grin's Simple MIDi Jukeboxx ***
 *
 *                      version 2.52
 *
 *  Copyright 1995-97, Peter Gervai.  Free for personal use.
 *
 * Usage:
 *   MidPlay [<file pattern>] [@<playlist name>] [<file pattern>] [switches]
 * 
 * Switches:  /V<vol>   Set global volume
 *            /R<vol>   Set right volume (stereo only)
 *            /L<vol>   Set left  volume (stereo only)
 *            /S        Shuffle play - randomize musics
 *            /P        Show full path and filename
 *            /D        Enable D key for DELETING midi files (WATCH OUT!)
 *            /F<fname> Save playlist into <fname> (default: playlist.data)
 *                      (appends to the existing old file if any)
 * Examples:
 *   MidPlay
 *     Plays all *.MID files in the current directory
 *
 *   MidPlay /S E:\TMP\MIDI\A*.MID M:\IDI\"C64 Evergreens"\*
 *     Plays the given files of the given directory, shuffled
 *
 *   MidPlay TheSatan.Mid @hellish.list
 *     Plays the Satan's song then all files in the playlist
 ***************************************************************
 *
 * (This program eats up very few CPU cycles. You can use it in the
 * background.)
 *
 * License
 *  If you are using the program in a non-commercial environment
 *  then you're free to use, copy, or delete it. You must not sell it.
 *  You can include it on CDRoms or in free(/share)ware catalogs.
 *  Commercial users should contact me about the license fees.
 *  
 *  This program is copyrighted material of Peter Gervai, Hungary.
 *  Please do not distribute modified versions without my approval. Thanks!
 *
 *
 *
 *  PLEASE tell me about your ideas about the program!
 *
 *
 * History:
 *   1.0  - Release the in-house version
 *   1.1  - Pause song, bad MIDi file handling
 *   1.2  - Error control, restart
 *   1.3  - Handle HPFS extreme filenames (space, comma, etc in names)
 *   1.99 - Seeking
 *   2.0  - New interface ;-) : direct keyboard, pos display, volumes
 *   2.1  - New interface strikes back: borders, volume, buttons'n'boxes
 *   2.2  - More paths on commandline (the song counter cheats, though!)
 *   2.21 - Use the more general "sequencer" device instead of "sequencerNN"
 *   2.3  - Don't close sequencer instance. This helps playing type0
 *          MIDis without exact channel programming (uses the already loaded
 *          intruments... <sigh>)
 *        - The INIT midi created
 *        - inet email address changed :(
 *   2.31 - volume won't change to 100% after play a new song
 *        - volume can be preset [now only in the source]
 *        - The INIT midi is searched where MidPlay resides. Hopefully. :)
 *        - nasty logical error fixed when multiple filenames on
 *          commandline were with spaces in them. It wasn't my fault... ;->
 *   2.40 - shuffle play
 *        - fix song counter to count every file 
 *        - using command line params for preset volume (are you happy, Costas? :))
 *        - email changed again.... hrrgh
 *   2.50 - colors! [It looks almost like a REAL MIDiplayer... ;-)]
 *        - fixed B_Plain for volbars and percent bars :)
 *        - using playlists! you can store favourite midis from all over your
 *          harddisk. Use full paths where needed. One name per line.
 *        - some minor fix
 *   2.51 - exit color now bw again. 
 *        - /P switch (not to) show full filenames [because long paths]
 *        - P and S switch inverts program default (so you can set default to
 *          show full path and suppress it with /P or vice versa)
 *        - fixed default filename (*.mid) usage when using switches
 *   2.60 - /D - enable DELETING midi files completely out of this cruel world
 *          (use your D(estroy|elete|ig into grave) button)
 *        - /F - save playlist into a file (append to old file)
 *        - (Hey! Another year passed! Haapppyyyy 1997! :-))
 *        - ("Good" news - Merlin is out and the new midi player still
 *           sucks hard! :-( GJBOXX have a future again.)
 *
 * TODO:
 *        - nicer error messages (eg. ~~~INI~~~ file not found, bad midi)
 *          (hmm, well, I like it this way :->)
 *        - compressed MIDi archieves (any idea what do to here? :))
 *        - travel subdirs looking for MIDis (anyone crazy enough to need that?)
 *        - fun about colors (oh no. I must be crazy when typed that :))
 *        - ? your ideas ?    [i know i know - you don't have any :)]
 *
 *
 * - - - - - - - - - - -  -  -   -    -     -    -   -  -  - - - - - - - - -
 * I would like to say my warmest thanks to Marko Macek, the author of the
 * best programmers' editor EVER on OS/2: FTE! This little wonder makes
 * everything I've ever wanted for a REXX editor. Sometimes I feel it would
 * even make my lunch if I found the correct button. ;-) THANKS!
 * (At least FTE made my program READABLE. :) For myself as well!)
 * - - - - - - - - - - -  -  -   -    -     -    -   -  -  - - - - - - - - -
 *
 * Author
 *  Peter "Grin" Gervai, 2:370/15@fidonet, 81:436/3@OS2Net,
 *                       grin@hajdu.hungary.net,
 *                       grin@lifeforce.fido.hu
 */
call RxFuncAdd "SysFileTree", "RexxUtil", "SysFileTree"
call RxFuncAdd "SysSleep",    "RexxUtil", "SysSleep"
call RxFuncAdd "SysCls",      "RexxUtil", "SysCls"
call RxFuncAdd "SysGetKey",   "RexxUtil", "SysGetKey"
call RxFuncAdd "SysCurPos",   "RexxUtil", "SysCurPos"

/* Record error and get back to work*/
Call on failure name error1
Call on halt name error2
/*signal on syntax name error3*/


/*******************************************************************
 * Character Schemes
 *
 * Usually you are supposed to use the PC charset, but 
 * some national codepage just fucks up the box chars...
 *
 */
/*         12345678901234567       graph schemes for tables and buttons */
B_Plain = "+-+|+-+| ++++#*<>"
B_Pc    = "ÚÄ¿³ÀÄÙ³ Ã´ÂÁ±°"

/*******************************************************************
 * Color Schemes
 *
 *      
 *   0(8) =black  1(9) =red   2(10)=green   3(11)=brown  4(12)=blue 
 *   5(13)=purple 6(14)=cyan  7(15)=white  
 */
 /* 1 background, 2 statusline, 3 counter, 4 songbar, 5 totalsec, 6 secbar,
  * 7 actualsec, 8 total header, 9 volbar, 10 volheader, 
  * 11 buttonborder, 12 buttonchar, 13 buttonshadow, 14 pausebg, 
  * 15 errorcol */

/* My colours. Cold and blue of course! */
C_Grin  = '15,4 14,4 7,4 15,4 6,4 12,4',
          '11,4 14,4 13,4 6,4',
          '14,4 15,4 8,0 0,4',
          '9,0'

/* This set is called: "Ouch!" :) */
C_Test  = '15,4 14,5 1,6 15,2 3,7 4,7',
          '0,4 13,1 13,4 6,4',
          '15,1 0,2 8,0 14,7',
          '9,0'

/* Here follows some of Costas Papadopoulos :) */
C_Ark1  = '9,0 10,0 10,0 14,0 14,0 14,0',              /* WPS bright */
          '14,0 10,0 14,0 10,0',
          '10,0 14,0 8,0 9,0',
          '9,0'

C_Ark2  = '4,0 6,0 1,0 1,0 2,0 5,0',                   /* midnight (d)ark :) */
          '2,0 1,0 6,0 1,0',
          '1,0 2,0 8,0 9,0',
          '9,0'

C_Ark3  = '0,1 2,1 10,1 10,1 0,1 0,1',                 /* inverse brownish */
          '10,1 2,1 0,1 2,1',
          '2,1 0,1 8,0 9,2',
          '9,0'

C_Ark4  = '0,6 4,6 1,6 1,6 0,6 0,6',                   /* _nice_ cyanosys */
          '1,6 4,6 0,6 4,6',
          '4,6 0,6 8,0 1,6',
          '9,0'


ProgVersion = "2.60"

/*******************************************************************
 *******************************************************************
 ***
 **  You can change these
 **
 **/
 
/* we use PC characters to display graphics :) */
styp = B_Pc

/* use my favourite color scheme :) */
ctyp = C_Grin

/* use colors (if you set it to 0 you will get no ANSI colors at all) */
C_UseColors = 1

/* use 90% as the starting volume [value: 0-100] */
lvol = 90
rvol = 90

/* verbose mode */
VerboseMode = 1

/**
 **  ...do not change after that.
 *** 
 *******************************************************************
 *******************************************************************/

LastLeftVol  = -1
LastRightVol = -1
LastTotalsBar = -1
StereoUnchecked = 1

shufflePlay = 0                         /* default: do not shuffle play */
nameWithoutPath = 1                     /* default: show names w/o path */
enableDeleteFiles = 0                   /* default: do not enable D key */
savePlaylist = 0                        /* default: do not save playlist */
savePlaylistName = 'playlist.data'

initfilename = '~~init~~.mid'           /* this IS case sensitive! */
file.0 = 0

globals = 'SupportStereoVol LastTotalsBar LastPercent LastLeftVol',
          'LastRightVol C_UseColors colors. oldchar oldbg VerboseMode',
          'styp ctyp lvol rvol nameWithoutPath'

/* Send commands to OS/2 command processor.  */
address cmd      

FILE=''
Parse Arg pattern

parse source . . myself
mypath = SubStr(myself,1,LastPos('\',myself))

Do while pattern \== ''
/* first word --> pattern
 * rest       --> restpattern
 */
  call ParseNextName
  
  select
    when Left(pattern,1) = '/' then do
    /* command line switch */
      swChar = Translate(SubStr(pattern,2,1))
      swArg  = SubStr(pattern,3)
      select
        when swChar = 'R' then do
        /* right volume */
          if swArg<0 | swArg>100 then call ArgError 'Illegal volume' swArg
          rvol = swArg
        end
        
        when swChar = 'L' then do
        /* left volume */
          if swArg<0 | swArg>100 then call ArgError 'Illegal volume' swArg
          lvol = swArg
        end
        
        when swChar = 'V' then do
        /* global volume (have priority) */
          if swArg<0 | swArg>100 then call ArgError 'Illegal volume' swArg
          lvol = swArg
          rvol = swArg
        end
        
        when swChar = 'S' then do
        /* set shuffle play */
          shufflePlay = 1 - shufflePlay
        end
        
        when swChar = 'P' then do
        /* do not show full path */
          nameWithoutPath = 1 - nameWithoutPath
        end
        
        when swChar = 'D' then do
        /* enable D key - deleting midi files */
          enableDeleteFiles = 1 - enableDeleteFiles
        end
        
        when swChar = 'F' then do
        /* save playlist into file */
          if swArg == '' then swArg = 'playlist.data'
          savePlaylistName = swArg
          savePlaylist = 1 
        end
        
        when swChar = 'H' | swChar = '?' then do
        /* help */
          Call ShowHelp
          exit 1;
        end
        otherwise call ArgError 'Unknown switch' swChar
      end
    end
    
    when Left(pattern,1) = '@' then do
      /* playlists */
      if VerboseMode then say 'Processing playlist' SubStr(pattern,2)'...'
      call ReadPlaylist SubStr(pattern,2)
    end
    
    otherwise do
    /* filename pattern */
      if pattern=='' then pattern='*.MID'
      call ReadFilePattern
    end
  end
  
  /* read the rest of the command line */
  pattern = restPattern
end; /* do while pattern\==''*/



/*
 * if there was switch but neither filename, nor listfile, read default
 */
if pattern=='' & file.0=0 then do
  pattern='*.MID'
  call ReadFilePattern
end

/*
 * verify
 */

If file.0 = 0 Then Do
/*  Call SysCls*/
  Call ShowHelp
  exit 1;
  
  Say ' '
  Say 'You selected no MIDi files and there is no MIDi files'
  Say 'in the actual directory.'
  Say ' '
  Say 'USAGE: '
  Say '  MIDPLAY [<file pattern>]'
  Say ' '
  Say 'Examples:'
  Say '  MIDPLAY                               plays the MIDis in the actual dir'
  Say '  MIDPLAY M:\IDI\"James Bond"\g*.MID    plays the given MIDis'
  Say ' '
  exit 1;
  return;
end;

/*
 * if God commanded us to save the playlist, do it and sacrifice us
 */
if savePlaylist then do
  Call SysCls
  say "Saving Playlist into" savePlaylistName"..."
  call stream savePlaylistName,'c','open write'          /* app&     :) */
  do i=1 to file.0
    call lineout savePlaylistName,SubStr(file.i,38,Length(file.i)-37)
  end
  call stream savePlaylistName,'c','close'
  say "Seems to be done. I think."
  say ""
  say "Thank you for listening to Grin's Simple MIDi JukeBoxx v"ProgVersion"!"
  exit 0;
end


/*
 * init screen 
 */
if \ANSICheck() then C_UseColors = 0
Call InitColor
CALL SysCls
Call SetupScreen

/* Load the DLL, initialize MCI REXX support */
rc = RXFUNCADD('mciRxInit','MCIAPI','mciRxInit')
InitRC = mciRxInit()


/*
 ** Open it
 */
MciCmd = 'open sequencer alias rexxalias shareable wait'
MacRC = SendString(MciCmd)

/* Check if your sequencer doesn't support stereo volumes */
If StereoUnchecked Then Call CheckStereoVol
  
Call MIDiVol lvol,rvol,0,0

/*=================================================================
 * The INIT MIDi file. If you don't need 'em don't use 'em....
 *   (comment out that stuff if you don't want to have it)
 */
MciCmd = 'load rexxalias "'mypath||initfilename'" wait'
MacRC = SendString(MciCmd)
MciCmd = 'play rexxalias wait'
MacRC = SendString(MciCmd)
/*
 *=================================================================
 */

if shufflePlay then 
  Call Shuffle file.0

/*  
 *  Play files 
 */
do SongNum=1 to file.0
nextmusic:
  MIDiName = SubStr(file.SongNum,38,Length(file.SongNum)-37)
  Call ScrMidiName MIDiName
  Call ScrSeqNumber SongNum,file.0,styp
  CALL PlayMIDi MIDiName
  pressed = Result
  /**  Keys:
   ** S = Stop                V = Prev            Enter=next
   ** P = Pause               
   ** [ = -1min               ] = +1min           1 = left vol.up
   ** < = -30sec              > = +30sec          2 = left vol.dn
   ** - = -10sec              + = +10sec          3 = right vol.up
   ** 8 = global vol.up       9 = glob.vol.dn     4 = right vol.dn
   ** D = DELETE midi file
   */
  Select
    When pressed='A' Then SongNum=SongNum-1;
    When pressed='S' Then Do
    /*
     ** close the instance.
     */
      MacRC = SendString("close rexxalias wait")
      if MacRC <> 0 then signal ErrExit
      
      call charout ,'1b'x'[0m'
      Call SysCls
      say "Thank you for using Grin's Simple MIDi JukeBoxx v"ProgVersion"!"
      exit;
      End;
    When pressed='V' & SongNum>1 Then Do
      SongNum=SongNum-2;
      End;
    when pressed='D' & enableDeleteFiles Then Do
      Call StrXY 6,24,'[0mTO DELETE' Substr(MIDiName,1,30) 'PRESS "Y"! IF NOT PRESS "N".'
      do while chars()=0
        nop
      end
      
      choice1 = TRANSLATE(SysGetKey('noecho'))

      if choice1='Y' then do
        rc = SendString("close rexxalias wait")
        '@del "'MIDiName'"'
        do i=Songnum to file.0-1
          i1 = i+1
          file.i = file.i1
        end
        file.0 = file.0 - 1
        SongNum = SongNum - 1
      end

      Call StrXY 0,24,copies(' ',79)

      MciCmd = 'open sequencer alias rexxalias shareable wait'
      MacRC = SendString(MciCmd)
      
      End;
    Otherwise Nop;
  end;
end;
/*
 *  End of "play files"
 */

  MacRC = SendString("close rexxalias wait")

  call charout ,'1b'x'[0m'
  Call SysCls
  say "Thank you for listening to Grin's Simple MIDi JukeBoxx v"ProgVersion"!"
  exit 0;
return
  

/*
 * read the filename pattern 
 */
ReadFilePattern:  
  if VerboseMode then say 'Scanning pattern' pattern'...'
  CALL SysFileTree pattern,'filebuf','F'
  
  if filebuf.0 = 0 then say 'Warning, no MIDi found at' pattern'!'
  /*
   * append filebuf. to file.
   */
  counter = file.0
  do i=1 to filebuf.0
    if pos(initfilename,filebuf.i)=0 then do
    /* I don't want to listen the INIT twice... */
      counter = counter + 1
      file.counter = filebuf.i
    end
  end
  file.0 = counter
return
  
  /******************************************************************
   **     Play the MIDi file
   **/
PlayMIDi:
  Parse Arg FileName
  LastPercent = -1;
  /*
   ** Open it
   */
   
   /* The Mci interface don't really like spaces in names.
    * we quote it, and hope that it liked that way, since
    * it's not documented. :( (we killed internal quotes earlier.)
    */
  MciCmd = 'load rexxalias "'FileName'" wait'
  MacRC = SendString(MciCmd)
  
  MciCmd = 'play rexxalias'
  
  /*
   ** actually send the play string.
   */
  MacRC = SendString(MciCmd)
  if MacRC <> 0 then
  do
    /* junk = SendString("close rexxalias wait")*/
    signal ErrExit
  end
  
  /* Set time format to milliseconds */
  State = SendString('SET rexxalias time format ms wait')
  /* ...and get total music length */
  State = SendString('STATUS rexxalias length wait')
  TotalLen = RetSt
  Call ScrTotalTime TotalLen/1000
  
  /******************************************************************
   **     Play and parse keybored
   **/
  choice=''
  do forever
    State = SendString('STATUS rexxalias mode wait')
    if RetSt<>'playing' Then Signal FinishedSong
    State = SendString('STATUS rexxalias position wait')
    LastPos = RetSt
    State = SendString('STATUS rexxalias volume wait')
    LastVol = RetSt
    Parse Var lastVol lvol':'rvol
    
    Call ScrPercent LastPos/1000,TotalLen/1000
    Call ScrVolumes lvol,rvol
    Do While Chars()>0
      choice = TRANSLATE(SysGetKey('noecho'))
      Select
        When choice='P' Then CALL PauseSong
        When choice='-' Then CALL MIDISeek LastPos-10000
        When choice='+' Then CALL MIDISeek LastPos+10000
        When choice='<' Then CALL MIDISeek LastPos-30000
        When choice='>' Then CALL MIDISeek LastPos+30000
        When choice='[' Then CALL MIDISeek LastPos-60000
        When choice=']' Then CALL MIDISeek LastPos+60000
        
        When SupportStereoVol & choice='1' Then CALL MIDIVol  lvol,rvol, 10,  0
        When SupportStereoVol & choice='2' Then CALL MIDIVol  lvol,rvol,-10,  0
        When SupportStereoVol & choice='3' Then CALL MIDIVol  lvol,rvol,  0, 10
        When SupportStereoVol & choice='4' Then CALL MIDIVol  lvol,rvol,  0,-10
        When choice='8' Then CALL MIDIVol  lvol,rvol, 10, 10
        When choice='9' Then CALL MIDIVol  lvol,rvol,-10,-10
        When choice='0d'x | choice='A' | choice='S' | choice='V' Then Signal FinishedSong
        when choice='D' & enableDeleteFiles Then Signal FinishedSong
        Otherwise Nop;
      end;
      /* this is here for updating even if the user sleeps on the keybored :) */
      State = SendString('STATUS rexxalias mode wait')
      if RetSt<>'playing' Then Signal FinishedSong
      State = SendString('STATUS rexxalias position wait')
      LastPos = RetSt
      State = SendString('STATUS rexxalias volume wait')
      LastVol = RetSt
      Parse Var lastVol lvol':'rvol
      Call ScrPercent LastPos/1000,TotalLen/1000
      Call ScrVolumes lvol,rvol
    end;
    CALL SysSleep 1;
  end;
  
FinishedSong:
  /*
   ** close the instance.
   */
  /*MacRC = SendString("close rexxalias wait")
  if MacRC <> 0 then signal ErrExit*/
  
ErrExit:
  Return choice;
  
  /******************************************************************
   **     Seek in MIDi file (jump)
   **/
MIDIseek: Parse Arg newpos
  If newpos<0 then newpos = 0
  State = SendString('SEEK rexxalias to' newpos 'wait')
  State = SendString('PLAY rexxalias')
return;
  
  /******************************************************************
   **     Set volume
   **/
MIDiVol: Procedure Expose (globals)
  Parse Arg lvol,rvol,ldif,rdif
  
  lvol = lvol+ldif
  rvol = rvol+rdif
  If lvol>100 then lvol=100
  If rvol>100 then rvol=100
  If lvol<0   then lvol=0
  If rvol<0   then rvol=0
  If SupportStereoVol Then Do
    State = SendString('SET rexxalias audio volume left'  lvol 'wait')
    State = SendString('SET rexxalias audio volume right' rvol 'wait')
  end
  Else
    State = SendString('SET rexxalias audio volume ' lvol 'wait')
return;
  
  /******************************************************************
   **     Pause song
   **/
PauseSong:
  MacRC = SendString("PAUSE rexxalias wait")
  if MacRC <> 0 then signal ErrExit
  
  styp1 = Overlay(SubStr(styp,14,1),styp,9)  /* "shaded" button fill pattern */
  
  /* Fancy button flash ;-) */
  Do Forever
    if C_UseColors then call SetColor colors.14
    Call DrawBorder PauseButX,PauseButY,PauseButX+PauseButSize,PauseButY+3,styp1
    if C_UseColors then call SetColor colors.1
    Call SysSleep 1
    If Chars()>0 Then Leave
    Call ButtPutt  PauseButX,PauseButY,PauseButSize,styp,'[P]','pause'
    Call SysSleep 1
    If Chars()>0 Then Leave
  end;
  Do While Chars()>0
    Call SysGetKey('noecho')
  end;
  
  MacRC = SendString("RESUME rexxalias wait")
  if MacRC <> 0 then signal ErrExit
  Call ButtPutt  PauseButX,PauseButY,PauseButSize,styp,'[P]','pause'
  Return;
  
  /*   --- SendString --
   ** Call DLL function.  Pass the command to process and the
   ** name of a REXX variable that will receive textual return
   ** information.
   */
SendString:
  Parse Arg CmndTxt
  /* Last two parameters are reserved, must be set to 0           */
  /* Future use of last two parms are for notify window handle    */
  /* and userparm.                                                 */
  MacRC = mciRxSendString(CmndTxt, 'RetSt', '0', '0')
  if MacRC<>0 then
  do
    ErrRC = MacRC
    /*say 'MciCmd=' CmndTxt
    say 'Err:mciRxSendString RC=' ErrRC RetSt*/
    MacRC = mciRxGetErrorString(ErrRC, 'ErrStVar')
    /*say 'mciRxGetErrorString('ErrRC') =' ErrStVar*/
    if C_UseColors then call SetColor colors.15
    Call StrXY 6,23,' Error @' CmndTxt' '
    Call StrXY 7,24,' 'ErrRC':' ErrStVar' ' 
    MacRC = ErrRC             /* return the error rc */
  end
return MacRC
  
  /******************************************************************
   * argument errors
   */
ArgError:
  parse arg st
  call charout ,'1b'x'[0m'
  say '*** Argument error:' st
  exit;
return
  
  /******************************************************************
   **     Pause song
   **/
error1:
  if C_UseColors then call SetColor colors.15
  Call StrXY 1,1,Left('*** Error Failure - next',70)
  signal errorquit
error2:
  if C_UseColors then call SetColor colors.15
  Call StrXY 1,1,Left('*** Error HALT - next',70)
  signal errorquit
error3:
  if C_UseColors then call SetColor colors.15
  Call StrXY 1,1,Left('*** Bad MIDi file - next   [/REXX Syntax error]',70)
  
errorquit:
/*
 ** close the instance.
 */
  /*MacRC = SendString("close rexxalias wait")*/
  
  SongNum=SongNum+1
  signal nextmusic
  
  /******************************************************************
   **     Check volume setting ability :-(
   **/
CheckStereoVol:
  /* It's set to 90% because some patterns got distorted at 100% */
  CmndTxt = 'SET rexxalias audio left volume 90'
  SupportStereoVol = (mciRxSendString(CmndTxt, 'RetSt', '0', '0') = 0)
  If \SupportStereoVol Then Do
    Do i=0 to 3
      Call StrXY VolButX, VolButY+i,Copies(' ',VolButSize+1)
      Call StrXY VolBut2X,VolButY+i,Copies(' ',VolButSize+1)
      Call StrXY VolBut3X,VolButY+i,Copies(' ',VolButSize+1)
      Call StrXY VolBut4X,VolButY+i,Copies(' ',VolButSize+1)
    end;
  end;
  /* we don't want to set volume to 90% EVERYTIME, do we? */
  StereoUnchecked = 0
return;
  
  /******************************************************************
   **     Draw a border (box)
   **/
DrawBorder: Procedure Expose (globals)
  Parse Arg x1,y1,x2,y2,typ
  /* upper horiz */
  Call SysCurPos y1,x1
  Call CharOut ,SubStr(typ,1,1)
  If x2-x1>1 Then Call CharOut ,Copies(SubStr(typ,2,1),x2-x1-1)
  If x2-x1>0 Then Call CharOut ,SubStr(typ,3,1)
  /* lower horiz */
  Call SysCurPos y2,x1
  Call CharOut ,SubStr(typ,5,1)
  If x2-x1>1 Then Call CharOut ,Copies(SubStr(typ,6,1),x2-x1-1)
  If x2-x1>0 Then Call CharOut ,SubStr(typ,7,1)
  /* vert */
  Do i=y1+1 to y2-1
    Call SysCurPos i,x1
    Call CharOut ,SubStr(typ,8,1)
    Call CharOut ,Copies(SubStr(typ,9,1),x2-x1-1)
    Call CharOut ,SubStr(typ,4,1)
  end;
return;
  
  /******************************************************************
   **     Horizontal line connected to the border
   **/
DrawHCLine: Procedure Expose (globals)
  Parse Arg x1,x2,y,typ
  Call SysCurPos y,x1
  Call CharOut ,SubStr(typ,10,1)
  If x2-x1>1 Then Call CharOut ,Copies(SubStr(typ,2,1),x2-x1-1)
  If x2-x1>0 Then Call CharOut ,SubStr(typ,11,1)
return;
  
  /******************************************************************
   **     Vertical line connected to the border
   **/
DrawVCLine: Procedure expose (globals)
  Parse Arg y1,y2,x,typ
  
  Call SysCurPos y1,x
  Call CharOut ,SubStr(typ,12,1)
  Do i=y1+1 to y2-1
    Call SysCurPos i,x
    Call CharOut ,SubStr(typ,4,1)
  end;
  Call SysCurPos y2,x
  Call CharOut ,SubStr(typ,13,1)
return;
  
  /******************************************************************
   **     Write String @ x,y
   **/
StrXY: Procedure expose (globals)
  Parse Arg x,y,st
  Call SysCurPos y,x
  Call CharOut ,st
return;
  
  /******************************************************************
   **     Write String @ x,y, centered
   **/
StrXYCenter: Procedure expose (globals)
  Parse Arg x1,x2,y,st
  Call SysCurPos y,x1+( ( x2-x1-Length(st)+1 ) % 2 )
  Call CharOut ,st
return;
  
  /******************************************************************
   **     Setup Main Screen
   **/
SetupScreen:
  scry = 23
  if C_UseColors then call SetColor colors.1
  Call DrawBorder 5,0,75,scry,styp
  st = 'MIDi Jukeboxx v'ProgVersion
  Call StrXYCenter 5,75,0,st
  st = '(C)Copyright Grin, 1995-96, Free for non-commercial use'
  Call StrXYCenter 5,75,scry,st
  
  diffy = 1
  Call DrawHCLine 5,75,diffy+1,styp
  if C_UseColors then call SetColor colors.2
  Call StrXY 6,diffy,'Now Playing: INITIALISING'
  if C_UseColors then call SetColor colors.1

  diffy = diffy+2
  Call DrawHCLine 5,75,diffy+1,styp
  
  diffy = diffy+1
  Call DrawHCLine 5,75,diffy+3,styp
  Call DrawVCLine diffy,diffy+3,8,styp
  if C_UseColors then call SetColor colors.5
  Call StrXY 6,diffy+2,'0s'
  if C_UseColors then call SetColor colors.1
  Call DrawVCLine diffy,diffy+3,60,styp
  Call DrawVCLine diffy,diffy+3,68,styp
  Call StrXY 61,diffy+2,'0000.0s'
  Call StrXY 69,diffy+2,'000.0%'
  if C_UseColors then call SetColor colors.8
  Call StrXY 61,diffy+1,' total '
  Call StrXY 69,diffy+1,' pos '
  if C_UseColors then call SetColor colors.1
  
  diffy = diffy+3
  Call DrawHCLine 5,75,diffy+3,styp
  Call DrawVCLine diffy,diffy+3,40,styp
  if C_UseColors then call SetColor colors.10
  Call StrXYCenter 5,40,diffy+1,'Left volume'
  Call StrXYCenter 40,75,diffy+1,'Right volume'
  
  /* first row */
  butSize=10
  butInc = 13
  butX = 9
  butY = diffy+4
  Call ButtPutt  ButX,ButY,ButSize,styp,'[S]','stop'
  butX = butX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,'[V]','prev.'
  butX = butX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,'[P]','pause'
  PauseButX = ButX
  PauseButY = ButY
  PauseButSize = ButSize
  butX = butX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,'[ENTER]','next'
  butX = butX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,'[A]','again'
  
  /* second row */
  butSize = 9
  butInc = 11
  butX = 8
  butY = butY+4
  Call ButtPutt  ButX,ButY,ButSize,styp,'[1]','l.vol.up'
  VolButX = ButX
  VolButY = ButY
  VolButSize = ButSize
  butX = ButX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,'[2]','l.vol.dn'
  VolBut2X = ButX
  butX = ButX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,'[8]','vol.up'
  butX = ButX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,'[9]','vol.dn'
  butX = ButX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,'[3]','r.vol.up'
  VolBut3X = ButX
  butX = ButX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,'[4]','r.vol.dn'
  VolBut4X = ButX
  
  /* third row */
  butSize = 9
  butInc = 11
  butX = 8
  butY = butY+4
  Call ButtPutt  ButX,ButY,ButSize,styp,'[','-1min'
  butX = ButX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,'[<]','-30sec'
  butX = ButX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,'[-]','-10sec'
  butX = ButX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,'[+]','+10sec'
  butX = ButX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,'[>]','+30sec'
  butX = ButX + ButInc
  Call ButtPutt  ButX,ButY,ButSize,styp,']','+1min'
  
  if C_UseColors then call SetColor colors.1
return;
  
  /******************************************************************
   **     Put a nice butt :-)
   **/
ButtPutt: Procedure expose (globals)
  Parse Arg x,y,sx,styp,st1,st2
  sy = 3
  if C_UseColors then call SetColor colors.11
  Call DrawBorder  x,y,x+sx,y+sy,styp
  if C_UseColors then call SetColor colors.12
  Call StrXYCenter x,x+sx,y+1,st1
  Call StrXYCenter x,x+sx,y+2,st2
  /* button shadow .13 */
  if C_UseColors then call SetColor colors.1
return;
  
  /******************************************************************
   **     Refreshing parts of the screen
   **/
ScrMidiName: Procedure expose (globals)
  Parse Arg st
  
  if nameWithoutPath then do
    st = SubStr(st,lastpos('\',st)+1)
  end
  
  st = Left(st,56)
  if C_UseColors then call SetColor colors.4
  Call StrXY 18,1,st
  if C_UseColors then call SetColor colors.1
return;
  
ScrSeqNumber: Procedure Expose (globals)
  Parse Arg actualMid,totalMid,styp
  perc = 100 * actualMid / totalMid
  stlen = Length(totalMid)
  if C_UseColors then call SetColor colors.3
  Call StrXY 6,3,Right(actualMid,stlen) 'of' totalMid
  if C_UseColors then call SetColor colors.1
  Call DrawVCLine 2,4,6+stlen*2+5,styp
  if C_UseColors then call SetColor colors.6
  LastTotalsBar = PutPercentBar(LastTotalsBar,perc,6+stlen*2+6,3,74,SubStr(styp,15,1),0)
  if C_UseColors then call SetColor colors.1
return;
  
ScrTotalTime: Procedure Expose (globals)
  Parse Arg totaltime
  st = Format(totaltime,4,1) || 's'
  if C_UseColors then call SetColor colors.5
  Call StrXYCenter 61,67,6,st
  if C_UseColors then call SetColor colors.1
return;
  
ScrPercent: Procedure Expose (globals)
  Parse Arg actualsec,totalsec
  
  /* actual time */
  st = '   ' || Format(actualsec,,1) || 's   '
  if C_UseColors then call SetColor colors.7
  Call StrXYCenter 9,59,5,st
  
  /* percent */
  If totalsec>0 Then 
    percent = 100 * actualsec / totalsec
  else 
    percent = 0
  st = Format(percent,3,1) || '%'
  if C_UseColors then call SetColor colors.5
  Call StrXY 69,6,st
  
  if C_UseColors then call SetColor colors.6
  LastPercent = PutPercentBar(LastPercent,percent,9,6,59,SubStr(styp,14,1),0)
  Call SysCurPos 24,79
  if C_UseColors then call SetColor colors.1
return;
  
ScrVolumes: Procedure Expose (globals)
  Parse Arg lvol, rvol
  /*Call StrXY 7,8,Right(lvol,3)
   Call StrXY 71,8,Right(rvol,3)*/
  if C_UseColors then call SetColor colors.9
  lastLeftVol = PutPercentBar(LastLeftVol,lvol,6,9,39,SubStr(styp,16,1),1)
  lastRightVol = PutPercentBar(LastRightVol,rvol,41,9,74,SubStr(styp,17,1),0)
  if C_UseColors then call SetColor colors.1
return;
  
  /******************************************************************
   **     Draw a percent bar
   **
   ** lastbar: the last length (in characters)
   ** perc   : percent value of the bar
   ** x1,y1  : start of the bar
   ** x2     : end of the bar (max,100%)
   ** fillchr: texture of the bar
   ** rightbar: if true, the bar goes from right to left
   **/
PutPercentBar: Procedure Expose (globals)
  Parse Arg lastbar,perc,x1,y1,x2,fillchr,rightbar
  xs = x2-x1+1
  newPos = perc % (100 / xs)
  If newPos \= lastbar Then Do
    If \rightbar Then 
      Call StrXY x1,y1,Left(Copies(fillchr,newPos),xs)
    else
      Call StrXY x1,y1,Right(Copies(fillchr,newPos),xs)
    return newPos;
  end;
return lastbar;

/******************************************************************
 **     Parse name on commandline
 **
 ** the problem is about the quoted filenames containing space
 ** PARSE will parse them separately what is bad for me. :(
 **/
ParseNextName:
  parse var pattern param.1 param.2
  
  /* if it doesn't contain quotes then it's all right */
  If Pos('"',param.1) = 0 Then Do
    pattern = param.1
    restPattern = param.2
    drop param.
    return
  end
  
  /* quote status. when we have an open quote it equals 1 */
  flipflop = 0
  param.0 = ''
  
  do ForEver
    inpos = 1
    /* count quotes in first word */
    do while pos('"',param.1,inpos)>0
      inpos = pos('"',param.1,inpos)
      /* del quote */
      param.1 = DelStr(param.1,inpos,1)
      flipflop = 1-flipflop
    end
    
    /* if we have even number of quotes it's finished */
    if \flipflop then do
      pattern = param.0 || param.1
      restPattern = param.2
      drop param.
      return
    end
    
    /* ..and if not we look after the closing quote in next words */
    param.0 = param.0 || param.1 || ' '
    If param.2 == '' then do
      say "Ehm... non matched quote!!"
      pattern = param.0
      restPattern = param.2
      drop param.
      return
    end
      
    parse var param.2 param.1 param.2
  end
return

/**************************************************************
 * Show help
 */
ShowHelp:
  parse source . . selfPath
  
  lin = linein(selfPath)
  lin = linein(selfPath)
  do while Left(lin,5)\=' ****'
    say SubStr(lin,3)
    lin = linein(selfPath)
  end
  drop selfPath lin
return
    
/**************************************************************
 * Shuffle file.N
 */
Shuffle: parse arg shuffleNumber
  do shuffleNumber
    pos1 = random(1,file.0)
    do until pos2\=pos1
      pos2 = random(1,file.0)
    end
    tmp = file.pos1
    file.pos1 = file.pos2
    file.pos2 = tmp
  end
  drop tmp pos1 pos2 shuffleNumber
return
  
/**************************************************************
 * Set Color (ANSI)
 */
/* 0=black 1=red green brown blue purple cyan 7=white 8=brightblack ..*/
SetColor: parse arg char ',' bg
  ret = ''
  if oldchar \= char then do
    ret = '1b'x || '['
    select
      when oldchar>7 & char>7 then      ret = ret || 30+char-8
      when char>7 then                  ret = ret || '1;' || 30+char-8
      when oldchar>7 then               ret = ret || '0;' || 30+char
      otherwise                         ret = ret || 30+char
    end
    ret = ret || 'm' 
  end
  oldchar = char
  
  if oldbg \= bg then do
    ret = ret || '1b'x || '['|| 40+bg || 'm'
  end
  
  if ret\='' then call charout ,ret
  drop ret
return
    
InitColor:
  oldchar = 7
  oldbg   = 0
  call charout ,'1b'x'[0m'
  
  counter = 0
  do until ctyp == ''
    counter = counter + 1
    parse var ctyp colors.counter ctyp
  end
  colors.0 = counter
  drop counter
return
  
  /**************************************************************
   * ANSI check
   *
   * TRUE if supported
   */
ANSIcheck:
  say '1b'x'[2J'
  return SysCurPos() = '1 0'  
  
  /**************************************************************
   *
   * Playlist stuff
   */
ReadPlaylist: 
  parse arg listfile
   
  call stream listfile,'c','open read'
  do while stream(listfile,'s')=='READY'
    lin = LineIn(listfile)
    if lin\='' then do
      fname = stream(lin,'c','query exists')
      if fname \='' then do
      /* if exists then add to the list */
        if VerboseMode then say '   addig file' fname
        count = file.0 + 1
        file.count = copies(' ',37)||fname
        file.0 = count
      end 
      else do
        if VerboseMode then say '   not exist ' fname
      end
    end
  end
  
  drop lin fname count
return
  
   