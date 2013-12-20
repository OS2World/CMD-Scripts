/***********************************************************************/
/*                                                                     */
/* (c) Copyright DynaComp Solutions 1995 - All rights reserved.        */
/*                                                                     */
/***********************************************************************/
/*                                                                     */
/* Written and maintained by David J. Martin (djmartin@nando.net).     */
/*                                                                     */
/***********************************************************************/
version = '1.2 26 Dec 95'  /* LAMTOMR2.CMD                             */
/***********************************************************************/
/*                                                                     */
/* Converts LaMail nickname file to MR2Ice Address Book format.  Will  */
/* also create folders in MR2Ice for all of your existing LaMail       */
/* folders and move or copy all of your existing mail into MR2Ice.     */
/*                                                                     */
/***********************************************************************/
/*                                                                     */
/* Change History:                                                     */
/*                                                                     */
/*  Change                                                             */
/*   Date   Int Ver Description                                        */
/* -------- --- --- -------------------------------------------------- */
/* 12/23/95 DJM 1.0 First release.                                     */
/* 12/24/95 DJM 1.1 The last minute change to default to Copying mail  */
/*                  didn't end up working as it should have.  Added    */
/*                  code to process the default of C and to only       */
/*                  accept the 3 characters that are valid at the      */
/*                  prompt (C, M, Q).                                  */
/* 12/26/95 DJM 1.2 Added code to change the file extension of mail    */
/*                  depending on whether or not a piece of mail was    */
/*                  sent or received.                                  */
/*                                                                     */
/***********************************************************************/
trace 'OFF'                       /* we don't want or need any tracing */
'@ECHO OFF'                       /* suppress echoing of host commands */
call RxFuncAdd 'SysCls'            , 'RexxUtil' , 'SysCls'
call RxFuncAdd 'SysCurPos'         , 'RexxUtil' , 'SysCurPos'
call RxFuncAdd 'SysCurState'       , 'RexxUtil' , 'SysCurState'
call RxFuncAdd 'SysDriveInfo'      , 'RexxUtil' , 'SysDriveInfo'
call RxFuncAdd 'SysDriveMap'       , 'RexxUtil' , 'SysDriveMap'
call RxFuncAdd 'SysFileDelete'     , 'RexxUtil' , 'SysFileDelete'
call RxFuncAdd 'SysFileTree'       , 'RexxUtil' , 'SysFileTree'
call RxFuncAdd 'SysGetKey'         , 'RexxUtil' , 'SysGetKey'
call RxFuncAdd 'SysMkDir'          , 'RexxUtil' , 'SysMkDir'
call RxFuncAdd 'SysPutEA'          , 'RexxUtil' , 'SysPutEA'
call RxFuncAdd 'SysRmDir'          , 'RexxUtil' , 'SysRmDir'
call RxFuncAdd 'SysTextScreenRead' , 'RexxUtil' , 'SysTextScreenRead'
parse source . . ourname .           /* find out our name to use later */
lpos = lastpos('\',ourname)                 /* find the last backslash */
ourname = substr(ourname,lpos + 1)                    /* just our name */
parse var ourname ourname '.' .            /* drop the cmd portion too */
logfile = ourname || '.log'                 /* log file for any errors */
cleanup = 0          /* assume we won't be moving mail and cleaning up */
eol     = x2c('0D0A')                          /* end of line sequence */
hex01   = '01'x                         /* constant to delimit entries */
keys    = '0D 43 4D 51 63 6D 71'     /* keys for Move/Copy/Quit prompt */
title   = 'LaMail to MR2Ice Migration Aid'             /* screen title */
call SysFileDelete logfile              /* erase any leftover log file */
call AnsiColor                        /* set things up for using color */
/***********************************************************************/
/* Tell user to hang on while we gather some data for later use.       */
/***********************************************************************/
call SysCurState 'OFF'                          /* turn off the cursor */
call charout , s.normvid  /* make sure video is normal before we go on */
call SysCls                                        /* clear the screen */
call build_box 9,13,7,64
call show_title 3 7 64
call SysCurPos 10,9
call charout , pfcolor || 'Please stand by while I determine your' ,
               'LaMail folder names as ' || s.normvid
call SysCurPos 11,9
call charout , pfcolor || 'well as how much disk space the mail you' ,
               'currently have stored' || s.normvid
call SysCurPos 12,9
call charout , pfcolor || 'in LaMail occupies.  This make take a' ,
                            'minute or 2.            ' || s.normvid
call SysCurPos 12,57
call LaMailFolders    /* gather LaMail folder info and mail byte count */
/***********************************************************************/
/* When we come back from LaMailFolders the stem LAMFOLDERS will       */
/* contain entries for each LaMail folder name that exists.  The       */
/* variable LAMBYTES will contain the number of bytes of mail that is  */
/* currently stored in ALL of the LaMail folders.  The variable        */
/* LAMFOLDERS will have the full path to where the LaMail folders are. */
/***********************************************************************/
/* While we've got a message displayed get LaMail nickname details.    */
/***********************************************************************/
call LaMailNicks                     /* gather LaMail nickname details */
/***********************************************************************/
/* When we come back from LaMailNicks the stem LAMNICKS will contain   */
/* all of the information in the LaMail nickname file.                 */
/***********************************************************************/
/* Now find out where MR2Ice has been installed.                       */
/***********************************************************************/
drives = SysDriveMap(,'LOCAL')                 /* list of local drives */
drives = translate(drives,'',':')                     /* remove colons */
if words(drives) = 1                             /* only 1 local drive */
  then do
         mr2idrive = drives                 /* move into real variable */
         signal drive_no_ask     /* don't ask the user where MR2Ice is */
       end                                     /* if words(drives) = 1 */
call SysCurState 'ON'                            /* turn on the cursor */
call SysCls                                        /* clear the screen */
call build_box 5,7,20,36
call show_title 3 7 63
call SysCurPos 6,22
call charout , pfcolor || 'What drive is MR2Ice installed on?' || ,
               s.normvid
call SysCurPos 11,22
call charout , pfcolor || 'Enter QUIT if you want to stop now' || ,
               s.normvid
drive_again:              /* label for branch if the entry is invalid */
call SysCurPos 9,28
call charout , s.blink || s.revvid || 'MR2Ice Drive ==> ____'
call SysCurPos 9,45
mr2idrive = translate(strip(translate(linein(),'',':')))
call charout , s.normvid
select                        /* decide what to do based on the entry */
  when mr2idrive = 'QUIT'                   /* user wants to stop now */
      then call stopping 'Stopping this program at your request.  Bye' ,
                         'for now...'
  when wordpos(mr2idrive,drives) == 0            /* not a valid drive */
      then do
             out = s.blink || s.revvid || 'Invalid choice.  Must be'
             do lp = 1 to words(drives)      /* add each drive letter */
               out = out word(drives,lp) || ','   /* add drive letter */
             end                     /* of do lp = 1 to words(drives) */
             out = out 'or Quit.  Please try again.' || s.normvid
             call SysCurPos 13,0
             call charout , center(out,92)            /* show message */
             signal drive_again  /* go back and give them another try */
           end              /* of when wordpos(mr2idrive,drives) == 0 */
  otherwise nop         /* what was entered is at least a valid drive */
end                              /* of select based on the entry made */
drive_no_ask:         /* we'll come here if there's only 1 hard drive */
call SysFileTree mr2idrive || ':\MR2IC.INI','temp','FSO' /* chk 4 ini */
select    /* decide how to proceed based on what we found (or didn't) */
  when temp.0 == 0               /* couldn't find the MR2Ice ini file */
      then do
             msg = 'Could not find MR2IC.INI.  Please make sure that'  ,
                   'you entered the correct drive letter and that you' ,
                   'have installed and configured MR2Ice before using' ,
                   'the' ourname 'command.  To install and configure'  ,
                   'MR2Ice just run MR2I once after unzipping the code.'
             call Logger logfile,msg,,1
             call stopping msg
           end                                 /* of when temp.0 == 0 */
  when temp.0 > 1
      then do
             out = ''                     /* clear variable for output */
             do lp = 1 to temp.0                /* go through each hit */
               last1 = lastpos('\',temp.lp)
               out = out substr(temp.lp,3,last1 - 3)
             end                             /* of do lp = 1 to temp.0 */
             msg = 'There appears to be multiple copies of MR2Ice'     ,
                   'installed on the' mr2idrive 'drive.  Before using' ,
                    ourname 'please rename MR2IC.INI in the MR2Ice'    ,
                   'directory that you do NOT want LaMail information' ,
                   'migrated to.  I found a MR2IC.INI file in the'     ,
                   'following directories:' out
             call Logger logfile,msg,,1
             call stopping msg
           end                                   /* of when temp.0 > 1 */
  otherwise mr2loc = temp.1          /* looks OK so stash the location */
end                         /* of select based on results of searching */
mr2loc = substr(mr2loc,1,lastpos('\',mr2loc))   /* just directory info */
/***********************************************************************/
/* Make sure there's enough room on target drive to copy/move stuff.   */
/***********************************************************************/
mr2driveleft = SysDriveInfo(mr2idrive)         /* get info about drive */
parse var mr2driveleft . mr2driveleft .        /* just need bytes free */
if mr2driveleft - lambytes < 5000000  /* leave at least 5 meg on drive */
  then do
         msg = 'There is not enough room on the' mr2idrive 'drive to'   ,
               'move or copy the mail you already have filed in'        ,
               'LaMail.  You may make more space available on the'      ,
                mr2idrive 'drive or install MR2Ice on a disk with more' ,
               'space then run' ourname 'again.'
         call Logger logfile,msg,,1
         call stopping msg
       end                  /* of if mr2driveleft - lambytes < 5000000 */
/***********************************************************************/
/* Set up full file paths to everything we'll need.                    */
/***********************************************************************/
mr2iadr  = mr2loc || 'MR2I.ADR'                   /* address book file */
mr2igrp  = mr2loc || 'MR2I.GRP'                          /* group file */
mr2inew  = mr2loc || 'MAIL\'          /* new directories go under here */
mr2indx  = mr2loc || 'MAIL\FOLDERS.NDX'         /* MR2Ice folder index */
/***********************************************************************/
/* Now find out if we'll be moving notes or copying them.              */
/***********************************************************************/
call SysCurState 'ON'                            /* turn on the cursor */
call SysCls                                  /* clear the screen again */
call build_box 9,12,18,44
call show_title 3 7 63
call SysCurPos 10,20
call charout , pfcolor || 'Do you want to '    || s.blink || s.revvid || ,
                   'C' || pfcolor || 'opy or ' || s.blink || s.revvid || ,
                   'M' || pfcolor || 'ove your mail from' || s.normvid
call SysCurPos 11,20
call charout , pfcolor || 'LaMail folders into MR2Ice folders?      ' || ,
                          ' ' || s.normvid
call SysCurPos 14,32
call charout , s.blink || s.revvid || 'Your Choice ==> C'  || s.normvid
call SysCurPos 16,24
call charout , pfcolor || 'Enter a' s.blink || s.revvid || 'Q' || ,
               pfcolor    'if you want to stop now.' || s.normvid
call charout , s.blink || s.revvid
key = translate(Get_key(14 48))                  /* go get a keystroke */
call charout , s.normvid                            /* reset the color */
select                                /* decide what we're going to do */
  when key = 'Q'
      then call stopping 'Stopping this program at your request.  Bye' ,
                         'for now...'
  when key = 'C'
      then do
             dowhat  = 'COPY'
             dowhate = 'Copying'
           end
  when key = 'M'
      then do
             dowhat  = 'MOVE'
             dowhate = 'Moving'
             call ask_about_cleanup
           end
  otherwise nop            /* should never hit here because of Get_Key */
end                                                       /* of select */
call SysCurState 'OFF'                    /* make the cursor disappear */
/***********************************************************************/
/* Finally;  Get things going by creating the MR2Ice nickname entries. */
/* We need to stuff whatever we've already found into the nickinf.     */
/* stem for the routine we'll call to write the stuff for MR2Ice.      */
/***********************************************************************/
do lp = 1 to lamnicks.0 /* go through each LaMail nickname/group entry */
  nickinf.lp = lamnicks.lp                /* copy over to correct stem */
end                                      /* of do lp = 1 to lamnicks.0 */
nickinf.0 = lamnicks.0                /* copy the total count over too */
call SysCls
call build_box 8,12,11,54
call show_title 3 7 63
call SysCurPos 9,13
call charout , pfcolor || 'Migration of LaMail nicknames' ,
                          'to MR2Ice has started.' || s.normvid
call SysCurPos 11,13
call charout , pfcolor || center('A total of' nickinf.0 'entries will' ,
                          'be written.',52) || s.normvid
if WriteMR2Ice()   /* write nicknames; non-zero return means a problem */
  then do
         msg = 'An error occurred while opening or writing to the'      ,
               'address book or group files for MR2Ice.  Please report' ,
               'this error to the author and provide as many details'   ,
               'about your setup as possible.'
         call Logger logfile,msg,,1
         call stopping msg
       end                                      /* of if WriteMR2Ice() */
call SysCurPos 11,0
/***********************************************************************/
/* And now on with building folders and moving/copying existing mail.  */
/***********************************************************************/
call SysCurPos 9,13
call charout , pfcolor || center('Building MR2Ice folders and' dowhate ,
                               'mail',52) || s.normvid
call syscurpos 20,0
/*

   Each line of the folders.ndx file for MR2Ice is composed of 4 parts.
   The 4 parts are:

      Name of folder - displayed on the main folder tab
      Name on tab    - tab name used when folder is open
      Directory name - this is the actual name of the directory
      Y/N            - Y for auto open when MR2Ice starts  N don't open

   Each value is separated by '01'x.  Directory names start with upper
   case F followed by a right adjusted, zero filled, number that is
   incremented with each new folder.

   Since LaMail has no tab names for folders all we can do is plug in
   the actual folder name as the tab name.  Of course the user may
   change the tab name later if they want to.

   Before we start going through the LaMail folders we need to read and
   process the existing folders.ndx if it exists so we don't get a
   directory clash.

*/
call MR2IceFolderInfo  /* get highest folder number already being used */
frc = stream(mr2indx,'c','open write')             /* open output file */
if substr(frc,1,5) \= 'READY'            /* something bad has happened */
  then do
         msg = 'Unexpected return code of' frc 'trying to open' mr2indx ,
               'for writing.'
         call Logger logfile,msg,,1
         call stopping msg
       end                         /* of if substr(frc,1,5) \= 'READY' */
if length(lamfolders.0) < 3                   /* less than 100 folders */
  then foldlong = 3       /* default to 3 positions in directory names */
  else foldlong = length(lamfolders.0)   /* else max digits for length */
do lp = 1 to lamfolders.0  /* go through each folder we need to create */
  lamf  = translate(lamfolders.lp)   /* get a folder name & upper case */
  call SysCurPos 11,13
  call charout , pfcolor || center('Building folder' lamf 'and' ,
                                    dowhate 'mail items',52) ||    ,
                 s.normvid
  out.0 = 0                              /* clear stem of index output */
  newdir = 'F' || right(mr2ilast + lp,foldlong,'0')    /* new dir name */
  call lineout mr2indx,lamf || hex01 || lamf || hex01 || newdir || ,
                               hex01 || 'N'      /* update folders.ndx */
  call SysMkDir mr2inew || newdir          /* create the new directory */
  lamindex    = lamfolders || lamfolders.lp || '.NDX'  /* LaMail index */
  ldir        = lamfolders || lamfolders.lp || '\'     /* LaM dir root */
  pdir        = mr2inew    || newdir          /* MR2Ice directory name */
  folderindex = pdir || '\FOLDER.NDX'         /* same name in each dir */
  call SysFileTree lamindex,'temp','F'          /* get index file info */
  if temp.0 == 0                      /* no index file for some reason */
    then iterate lp                              /* next folder please */
  parse var temp.1 . . fbytes .    /* we just need the number of bytes */
  ndxin = charin(lamindex,1,fbytes)                /* read entire file */
  call stream lamindex,'c','close'                 /* close index file */
  if length(ndxin) == 0            /* no index; just need place holder */
    then call stream folderindex,'c','open write'  /* for 0 byte index */
    else call Copy_Index     /* otherwise copy over the index from LaM */
  /* The out. stem is filled in the Copy_Index subroutine if it's been */
  /* called.  Otherwise out.0 will be 0 and nothing will get written.  */
  do ilp = 1 to out.0                   /* go through each output line */
    call lineout folderindex,out.ilp          /* write the index entry */
  end                                        /* of do ilp = 1 to out.0 */
  call stream folderindex,'c','close'       /* close folder index file */
  folderea = 'FEFF0400'x || build_eas(out.0)    /* build EAs for index */
  call SysPutEA folderindex,'MessageCtr',folderea         /* store EAs */
end                                    /* of do lp = 1 to lamfolders.0 */
call stream mr2indx,'c','close'              /* close folders.ndx file */
/* We're all done so show the closing screen before we leave for good. */
call SysCls
call build_box 6,14,2,74
call show_title 3 7 63
call SysCurPos 7,4
call charout , pfcolor || center('A total of' lamnicks.0 'nicknames' ,
                                'were written',72) || s.normvid
call SysCurPos 9,4
call charout , pfcolor || center('A total of' lamfolders.0 'folders' ,
                                 'were created',72) || s.normvid
call SysCurPos 11,4
call charout , s.blink || s.revvid || center('Conversion of LaMail'   ,
               'nicknames and folders to MR2Ice format is'            ,
               'complete.',72) || s.normvid
call SysCurPos 13,4
call charout , s.blink || s.revvid || center('Please restart MR2Ice to' ,
               'see your nicknames and folders.',72) || s.normvid
call SysCurPos 16,0
common_exit:                                   /* single point of exit */
exit                                               /* that's all folks */
/***********************************************************************/
stopping:             /* we've encountered an error and can't continue */
  parse arg errmsg                  /* get the message to be displayed */
  call SysFileTree logfile,'temp','FO'              /* log file exist? */
  if temp.0 \= 0                                          /* sure does */
    then errmsg = errmsg ' The file' ourname'.log also contains the' ,
                         'text of this message for reference.'
  call SysCls                                      /* clear the screen */
  say                                                    /* blank line */
  say                                                    /* blank line */
  say '****************************************************************'
  say '*                                                              *'
  outlength = 61                       /* maximum record length plus 1 */
  errmsg = errmsg' '             /* make sure there's a trailing blank */
  do forever until errmsg = ''       /* go until we run out of message */
    xpos = outlength               /* so set the length to the maximum */
    xpos = min(xpos,lastpos(' ',errmsg,outlength))    /* where's blank */
    say '*' left(substr(errmsg,1,xpos - 1),outlength) || '*'
    errmsg = delstr(errmsg,1,xpos)                      /* remove text */
  end                               /* of do forever until errmsg = '' */
  do lp = 1 to 3                             /* sound a warble 3 times */
    call beep 262,050                                     /* low  note */
    call beep 523,150                                     /* high note */
  end                                             /* of do lp = 1 to 3 */
  say '*                                                              *'
  say '****************************************************************'
  say                                                    /* blank line */
  say                                                    /* blank line */
  signal common_exit                /* branch to the common exit point */
return                               /* end of the STOPPING subroutine */
/***********************************************************************/
build_eas: procedure          /* build correct EA value for folder.ndx */
  parse arg ncount .  /* we get passed the numb of notes in the folder */
  nchex    = d2x(ncount,8)                 /* convert the count to hex */
  folderea = ''                              /* clear our return value */
  do lp = (length(nchex)-1) to 1 by -2    /* backwards through the hex */
    folderea = folderea || substr(nchex,lp,2)         /* back to front */
  end                       /* of do lp = (length(nchex)-1) to 1 by -2 */
return x2c(folderea)                /* end of the BUILD_EAS subroutine */
/***********************************************************************/
ask_about_cleanup: /* if moving see if we should clean up dirs and ndx */
                   /* cleanup is initialize to 0 when we get here      */
  call SysCls                                /* clear the screen again */
  call build_box 6,13,9,60
  call show_title 3 7 63
  call SysCurPos 7,11
  call charout , pfcolor || 'You have decided to MOVE all of your' ,
                            'LaMail data over to  ' || s.normvid
  call SysCurPos 8,11
  call charout , pfcolor || 'MR2Ice.  Do you want me to clean up your' ,
                            'LaMail folders as' || s.normvid
  call SysCurPos 9,11
  call charout , pfcolor || 'mail is being moved?  Cleaning up' ,
                            'includes removing the   ' || s.normvid
  call SysCurPos 10,11
  call charout , pfcolor || 'LaMail directories as well as the LaMail' ,
                            'index files.     ' || s.normvid
  call SysCurPos 12,33
  call charout , s.blink || s.revvid || 'Y(es) or N(o) _'  || s.normvid
  call SysCurPos 15,24
  call charout , pfcolor || 'Enter a' s.blink || s.revvid || 'Q' || ,
                 pfcolor    'if you want to stop now.' || s.normvid
  clean_again:                    /* label for branch if invalid entry */
  call charout , s.blink || s.revvid
  call SysCurPos 12,47
  key = translate(substr(linein(),1)) /* get 1 character from keyboard */
  call charout , s.normvid
  if key = 'Q'
    then call stopping 'Stopping this program at your request.  Bye' ,
                       'for now...'
  if key \= 'Y' & key \= 'N'                          /* not yes or no */
    then do
           call SysCurPos 17,12
           call charout , s.blink || s.revvid || 'Invalid choice. ' ,
                          'Must be Y, N, or Q.  Please try again.' || ,
                          s.normvid
           signal clean_again                  /* back for another key */
         end                          /* of if key \= 'Y' & key \= 'N' */
  if key = 'Y'            /* wants us to clean up the LaMail structure */
    then cleanup = 1             /* turn on the cleanup flag for later */
return                      /* end of the ASK_ABOUT_CLEANUP subroutine */
/***********************************************************************/
build_box: procedure expose box. c. s.
  /*        1st row , last row , 1st column , column length            */
  parse arg srow , erow , scol , long
  call SysCurPos srow,scol                          /* position cursor */
  call charout , s.revvid || c.fcyan || c.bblack
  call charout , box.uplc || copies(box.hside,long) || box.uprc
  do lp = (srow + 1) to (erow - 1)
    call SysCurPos lp,scol                          /* position cursor */
    call charout , box.vside || copies(' ',long) || box.vside
  end
  call SysCurPos erow,scol                          /* position cursor */
  call charout , box.lolc || copies(box.hside,long) || box.lorc
  call charout , s.normvid
return                              /* end of the BUILD_BOX subroutine */
/***********************************************************************/
show_title: procedure expose title s.           /* show our title line */
  parse arg row start long           /* what row, start col, box width */
  tcol = ((long - length(title)) % 2) + start           /* calc column */
  call SysCurPos row,tcol                           /* position cursor */
  call charout , s.blink || s.revvid title s.normvid     /* show title */
return                             /* end of the SHOW_TITLE subroutine */
/***********************************************************************/
get_key: procedure expose keys          /* get a key from the keyboard */
  /* Waits for a valid key to be entered.  Valid keys are listed in    */
  /* the variable named KEYS which is exposed on entry to this routine.*/
  /* The row and column where we'll look for the key are passed to     */
  /* this routine as arguments.  The Enter key is the only valid       */
  /* action key that will cause this routine to return.  On return the */
  /* character that was entered will be returned so the caller can do  */
  /* something based on what was entered.                              */
  parse arg krow kcol                            /* key row and column */
  more_keys:                          /* label to wait for another key */
  call SysCurPos krow,kcol                      /* position the cursor */
  key = c2x(SysGetKey('noecho'))       /* wait for a key to be pressed */
  if key = '00'                                        /* extended key */
    then key = '00' || c2x(SysGetKey('noecho'))        /* get 2nd byte */
  if key = 'E0'                                        /* extended key */
    then key = '00' || c2x(SysGetKey('noecho'))        /* get 2nd byte */
  if wordpos(key,keys) = 0                              /* invalid key */
    then do
           call beep 523,150                              /* high note */
           call beep 262,050                              /* low  note */
           signal more_keys                 /* go back for another key */
         end                            /* of if wordpos(key,keys) = 0 */
  call SysCurPos krow,kcol                        /* reposition cursor */
  call charout , x2c(key)                     /* show what was entered */
  if key \= '0D'                                  /* not the enter key */
    then signal more_keys                /* go back and wait for enter */
return SysTextScreenRead(krow,kcol,1) /* end of the GET_KEY subroutine */
/***********************************************************************/
Copy_Index:             /* copy LaMail index file to MR2Ice index file */
  /*********************************************************************/
  /* Since MR2Ice uses the same index file structure as LaMail all we  */
  /* have to do is clear out the first 27 bytes and put it in the      */
  /* correct directory with the correct name for MR2Ice.               */
  /*********************************************************************/
  do forever until ndxin == ''          /* go until we run out of data */
    parse var ndxin lamin (eol) ndxin            /* get a line of data */
    lamin = overlay(copies(' ',27),lamin,1)    /* blank first 27 chars */
    lamin = overlay('Y',lamin,78)                 /* mark note as read */
    parse var lamin . 28 fn 36 .   ,                 /* file name      */
                      37 ft 44 .                     /* file extension */
    fn    = strip(fn)                           /* clean off file name */
    ft    = strip(ft)                           /* clean off file type */
    if ft \= ''                              /* if we have a file type */
      then ifile = ldir || fn || '.' || ft  /* full from file name.ext */
      else ifile = ldir || fn               /* else just use file name */
    if ft == ''                     /* mail that was sent from LaMail) */
      then oft = 'out'                           /* use OUT for MR2Ice */
      else oft = 'rcv'                           /* use RCV for MR2Ice */
    ofile = pdir || '\' || fn || '.' || oft   /* build output file inf */
    out.0 = out.0 + 1                    /* bump count of output lines */
    point = out.0              /* move new count into the stem pointer */
    out.point = lamin                   /* stash data where it belongs */
    '@COPY' ifile ofile '/V > NUL 2>NUL'                /* always copy */
    if rc \= 0           /* something happened trying to copy the file */
      then call Logger logfile,'Error: Return code' rc dowhate ifile ,
                               'to' ofile,,1
      else if dowhat = 'MOVE'                   /* we're moving things */
             then call SysFileDelete ifile          /* delete original */
  end                               /* of do forever until ndxin == '' */
  if cleanup                     /* we're moving stuff and cleaning up */
    then do
           call SysFileDelete lamindex            /* remove index file */
           call SysRmDir lamfolders || lamfolders.lp     /* delete dir */
           if rc \= 0
             then call Logger logfile,'Error: Return code' rc ,
                                            'removing' lamfolders || ,
                                             lamfolders.lp,,1
         end                                          /* of if cleanup */
return                             /* end of the Copy_Index subroutine */
/***********************************************************************/
AnsiColor:                       /* set things up for the use of color */
'ANSI ON | RXQUEUE'                /* make sure ANSI is on and enabled */
'RXQUEUE /clear'         /* trash anything that might have been queued */
esccode    = '1B'x   || "["          /* escape sequence for ANSI codes */
s.blink    = esccode || "5m"                                  /* Blink */
s.revvid   = esccode || "7m"                          /* Reverse video */
s.normvid  = esccode || "0m"                     /* All attributes off */
c.bcyan    = esccode || "36m"                       /* background cyan */
c.fcyan    = esccode || "46m"                       /* foreground cyan */
c.bblack   = esccode || "30m"                      /* background black */
c.fgreen   = esccode || "42m"                      /* foreground green */
Box.UpLc   = 'DA'x                      /* upper left corner  of a box */
Box.LoLc   = 'C0'x                      /* lower left corner  of a box */
Box.UpRc   = 'BF'x                      /* upper right corner of a box */
Box.LoRc   = 'D9'x                      /* lower right corner of a box */
Box.HSide  = 'C4'x                      /* horizontal side    of a box */
Box.VSide  = 'B3'x                      /* vertical side      of a box */
entryfield = s.revvid || c.fcyan || c.bblack      /* entry field color */
pfcolor    = s.blink || s.revvid || c.fgreen            /* F key color */
return                              /* end of the AnsiColor subroutine */
/***********************************************************************/
LaMailNicks: procedure expose lamnicks.       /* process nickname file */
call RxFuncAdd 'SysFileTree','RexxUtil','SysFileTree'
call RxFuncAdd 'SysIni'     ,'RexxUtil','SysIni'
lamini     = SysIni('USER','LAM','LAMIniPath')   /* get LaMail ini loc */
lamnames   = SysIni(lamini,'LAM','NAMES')   /* get LaMail nickname loc */
lamnicks.  = ''         /* our exposed array with all nickname entries */
lamnicks.0 = 0                /* count of nickname entries we've found */
hex01      = '01'x                      /* constant to delimit entries */
eol        = x2c('0D0A')                       /* end of line sequence */
out.       = ''                    /* initialize temporary output stem */
call SysFileTree lamnames,'temp.','f'     /* get nickname file details */
if temp.0 == 0                               /* no nickname file found */
  then signal exit_LaMailNicks                     /* we can leave now */
parse var temp.1 . . fbytes .      /* we just need the number of bytes */
lamin = charin(lamnames,1,fbytes)                  /* read entire file */
call stream lamnames,'c','close'         /* close LaMail nickname file */
do forever until lamin == ''            /* go until we run out of data */
  parse var lamin line (eol) lamin         /* break off a line of data */
  parse upper var line ':' tag '.' .                /* extract the tag */
  parse var line . '.' tvalue               /* extract the actual data */
  select                   /* decide what to do based on the tag value */
    when tag = 'NICK'
        then do
               if out.2 \= '' & ,             /* we have a user ID and */
                  out.3 \= '' | ,            /* we have a host name or */
                  out.7 \= ''                /* we have a :list. value */
                 then do
                        lamnicks.0 = lamnicks.0 + 1      /* bump count */
                        pointer    = lamnicks.0   /* pointer into stem */
                        lamnicks.pointer = out.1 || hex01
                        do lp = 2 to 7     /* maximum number of values */
                          lamnicks.pointer = lamnicks.pointer || ,
                                                       out.lp || hex01
                        end                       /* of do lp = 2 to 7 */
                      end           /* of if out.2 \= '' & out.3 \= '' */
               out. = ''                /* clear temporary output stem */
               out.1 = tvalue                        /* stash nickname */
             end                               /* of when tag = 'NICK' */
    when tag = 'USERID'
        then out.2 = tvalue
    when tag = 'NODE'
        then out.3 = tvalue
    when tag = 'NAME'
        then out.4 = tvalue            /* stash full name (case as-is) */
    when tag = 'PHONE'
        then out.5 = tvalue                /* stash phone number value */
    when tag = 'ADDR'
        then out.6 = tvalue                     /* stash address value */
    when tag = 'LIST'            /* list of addresses and/or nicknames */
        then out.7 = tvalue
    otherwise nop             /* must not be a tag we're interested in */
  end                              /* of select based on the tag value */
end                                    /* of forever until lamin == '' */
exit_LaMailNicks:                 /* label for branch to leave quickly */
return                            /* end of the LaMailNicks subroutine */
/***********************************************************************/
LaMailFolders: procedure expose lambytes lamfolders. lamfolders
call RxFuncAdd 'SysFileTree','RexxUtil','SysFileTree'
call RxFuncAdd 'SysIni'     ,'RexxUtil','SysIni'
lamini     = SysIni('USER','LAM','LAMIniPath')
lamfolders = strip(SysIni(lamini,'LAM','FoldersDir'),'T','00'x) || '\'
call SysFileTree lamfolders || '*.*','temp','DO'/* dirs only (folders) */
lamfolders.0 = 0               /* clear stem of folder names in LaMail */
lambytes     = 0       /* initialize bytes of mail currently in LaMail */
do lp = 1 to temp.0              /* go through each directory we found */
  lastback = lastpos('\',temp.lp)            /* last backslash in name */
  dname    = substr(temp.lp,lastback + 1)      /* drop drive/path info */
  if translate(dname) = 'INBOX' | ,     /* we don't need either one of */
     translate(dname) = 'OUT' /* these since most mail clients have em */
    then iterate                              /* next directory please */
  lamfolders.0 = lamfolders.0 + 1    /* bump count of folders we found */
  point  = lamfolders.0               /* stash a pointer into the stem */
  lamfolders.point = dname                 /* store the directory name */
  call SysFileTree lamfolders || dname || '\*.*','mtemp','F'
  if mtemp.0 == 0                            /* no mail in this folder */
    then iterate lp                           /* next directory please */
  do ilp = 1 to mtemp.0                  /* go through each file found */
    parse var mtemp.ilp . . bytes .         /* extract number of bytes */
    lambytes = lambytes + bytes         /* add it to the overall total */
  end                                      /* of do ilp = 1 to mtemp.0 */
end                                          /* of do lp = 1 to temp.0 */
return                          /* end of the LaMailFolders subroutine */
/***********************************************************************/
WriteMR2Ice: procedure expose mr2iadr mr2igrp nickinf.
out.     = ' '                         /* start off with a clean slate */
sendback = 0                           /* assume everything will go OK */
written  = 0                  /* initialize count of nicknames written */
frc = stream(mr2iadr,'c','open write')             /* open output file */
if substr(frc,1,5) \= 'READY'            /* something bad has happened */
  then do
         sendback = 1      /* turn on flag to show there was a problem */
         signal exit_WriteMR2Ice                          /* leave now */
       end                         /* of if substr(frc,1,5) \= 'READY' */
frc = stream(mr2igrp,'c','open write')             /* open output file */
if substr(frc,1,5) \= 'READY'            /* something bad has happened */
  then do
         sendback = 1      /* turn on flag to show there was a problem */
         signal exit_WriteMR2Ice                          /* leave now */
       end                         /* of if substr(frc,1,5) \= 'READY' */
do lp = 1 to nickinf.0            /* go through each line passed to us */
  parse var nickinf.lp alias '01'x ,      /* break up the line of data */
                       user  '01'x ,
                       host  '01'x ,
                       name  '01'x ,
                       phone '01'x ,
                       notes '01'x ,
                       group '01'x .
  if group \= ''                /* must be a distribution list (group) */
    then do
           out = '!'   || ,                                /* constant */
                 alias || ,                        /* alias (nickname) */
                 '\'   || ,                                /* constant */
                 name  || ,  /* name for To: line of distribution list */
                 '\'   || ,                                /* constant */
                 'N'                /* No display on RMB (our default) */
           if lineout(mr2igrp,out)   /* write a line to the group file */
             then do
                    sendback = 1               /* turn on problem flag */
                    signal exit_WriteMR2Ice               /* leave now */
                  end                       /* if lineout(mr2igrp,out) */
           out = ''             /* clear the output field for a moment */
           if phone \= ''                    /* we have a phone number */
             then out = 'Phone number:' phone   /* describe what it is */
           if note \= ''           /* there are some notes to be added */
             then out = out notes                     /* add the notes */
           out = strip(out,'L')           /* remove any leading blanks */
           if out \= ''    /* looks like we've got some notes to write */
             then do
                    nlong = length(out) /* how many bytes in the notes */
                    if lineout(mr2igrp,'#' || nlong)   /* notes length */
                      then do
                             sendback = 1  /* turn on the problem flag */
                             signal exit_WriteMR2Ice      /* leave now */
                           end             /* if lineout(mr2igrp,blah) */
                    if lineout(mr2igrp,out)         /* write the notes */
                      then do
                             sendback = 1  /* turn on the problem flag */
                             signal exit_WriteMR2Ice      /* leave now */
                           end              /* if lineout(mr2igrp,out) */
                  end                               /* of if out \= '' */
           do ilp = 1 to words(group)       /* go through each address */
             if lineout(mr2igrp,'+' || word(group,ilp))  /* write addr */
               then do
                      sendback = 1         /* turn on the problem flag */
                      signal exit_WriteMR2Ice             /* leave now */
                    end                    /* if lineout(mr2igrp,blah) */
           end               /* of do ilp = 1 to words(group) */
           iterate lp                   /* go to the next line of data */
         end                                    /* of when group \= '' */
  /* If we got here the entry wasn't a list of IDs (group) so we'll    */
  /* create a "normal" entry in the address book.                      */
  out = name || '\' || ,                               /* persons name */
        user || '@' || ,                                    /* user ID */
        host || '\' || ,                                  /* host name */
        'N'  || '\' || ,             /* default to not show on the RMB */
        alias                               /* nickname for this entry */
  if lineout(mr2iadr,out)          /* write a line to the address book */
    then do
           sendback = 1    /* turn on flag to show there was a problem */
           signal exit_WriteMR2Ice                        /* leave now */
         end                                /* if lineout(mr2iadr,out) */
  out = ''                      /* clear the output field for a moment */
  if phone \= ''                             /* we have a phone number */
    then out = 'Phone number:' phone          /* describe what this is */
  if notes \= ''                   /* there are some notes to be added */
    then out = out notes                              /* add the notes */
  out = strip(out,'L')                    /* remove any leading blanks */
  if out \= ''             /* looks like we've got some notes to write */
    then do
           nlong = length(out)          /* how many bytes in the notes */
           if lineout(mr2iadr,'01'x || nlong)     /* notes length info */
             then do
                    sendback = 1           /* turn on the problem flag */
                    signal exit_WriteMR2Ice               /* leave now */
                  end                      /* if lineout(mr2iadr,blah) */
           if lineout(mr2iadr,out)            /* and finally the notes */
             then do
                    sendback = 1           /* turn on the problem flag */
                    signal exit_WriteMR2Ice               /* leave now */
                  end                       /* if lineout(mr2iadr,out) */
         end                                        /* of if out \= '' */
end                                       /* of do lp = 1 to nickinf.0 */
exit_WriteMR2Ice:          /* label for branch if we run into problems */
call stream mr2iadr,'c','close'         /* close the address book file */
call stream mr2igrp,'c','close'                /* close the group file */
return sendback                   /* end of the WriteMR2Ice subroutine */
/***********************************************************************/
MR2IceFolderInfo: procedure expose mr2ilast mr2indx
hex01    = '01'x                        /* constant to delimit entries */
eol      = x2c('0D0A')                         /* end of line sequence */
mr2ilast = 0                /* assume no folders created in MR2Ice yet */
call RxFuncAdd 'SysFileTree','RexxUtil','SysFileTree'
call SysFileTree mr2indx,'temp.','f'             /* index file details */
if temp.0 == 0                               /* no folders created yet */
  then signal exit_MR2IceFolderInfo                /* we can leave now */
parse var temp.1 . . fbytes .      /* we just need the number of bytes */
ndxin = charin(mr2indx,1,fbytes)                   /* read entire file */
call stream mr2indx,'c','close'             /* close folder index file */
do forever until ndxin == ''            /* go until we run out of data */
  parse var ndxin . (hex01) . (hex01) foldnum (hex01) (eol) ndxin
  foldnum = substr(foldnum,2)  /* just the numeric part of folder name */
  if foldnum > mr2ilast                  /* highest we've seen so far? */
    then mr2ilast = foldnum               /* sure is so keep the value */
end                                 /* of do forever until ndxin == '' */
exit_MR2IceFolderInfo:              /* label for branch for quick exit */
return                       /* end of the MR2IceFolderInfo subroutine */
/***********************************************************************/
logger: procedure               /* writes a line of data to a log file */
parse arg outfile , outmsg , splitat , closeit        /* get arguments */
if arg(3,'Omitted')                          /* split value not passed */
  then splitat = 0                                /* trigger for later */
if arg(4,'Omitted')              /* whether or not to close not passed */
  then closeit = 0                /* default to not close the log file */
sendback = 0           /* assume we'll write the message without error */
if closeit \= 0 & ,                    /* closeit value isn't zero and */
   closeit \= 1                                        /* it isn't one */
  then do
         sendback = 1      /* turn on return flag to indicate an error */
         signal exit_logger                               /* leave now */
       end                        /* of if closeit \= 0 & closeit \= 1 */
timestamp = date('S') time()    /* consistent time stamp for log lines */
if splitat = 0                         /* we don't need to split lines */
  then do
         call lineout outfile , timestamp outmsg  /* write the message */
         signal exit_logger                               /* leave now */
       end                                         /* of if slitat = 0 */
outmsg = outmsg' '               /* make sure there's a trailing blank */
do forever until outmsg = ''         /* go until we run out of message */
  xpos = splitat                      /* set the length to the maximum */
  xpos = min(xpos,lastpos(' ',outmsg,splitat))   /* where's the blank? */
  call lineout outfile , timestamp ,           /* write a line of data */
                         left(substr(outmsg,1,xpos - 1),splitat)
  outmsg = delstr(outmsg,1,xpos)               /* remove what we wrote */
end                                 /* of do forever until outmsg = '' */
exit_logger:                      /* label for branch to leave quickly */
if closeit                  /* flag to close the log file is turned on */
  then call stream outfile , 'C' , 'Close'           /* close the file */
return sendback                        /* end of the LOGGER subroutine */
/***********************************************************************/
