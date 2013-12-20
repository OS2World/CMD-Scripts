/***********************************************************************/
/*                                                                     */
/* (c) Copyright DynaComp Solutions 1995 - All rights reserved.        */
/*                                                                     */
/***********************************************************************/
/*                                                                     */
/* Written and maintained by David J. Martin (djmartin@nando.net).     */
/*                                                                     */
/***********************************************************************/
version = '1.3 29 Dec 95'  /* PMMTOMR2.CMD                             */
/***********************************************************************/
/*                                                                     */
/* Converts PMMail address and group information to MR2Ice format.     */
/* Will also create folders in MR2Ice for all of your existing PMMail  */
/* folders and move or copy all of your existing mail into MR2Ice.     */
/*                                                                     */
/***********************************************************************/
/*                                                                     */
/* Change History:                                                     */
/*                                                                     */
/*  Change                                                             */
/*   Date   Int Ver Description                                        */
/* -------- --- --- -------------------------------------------------- */
/* 12/24/95 DJM 1.0 First release.                                     */
/* 12/26/95 DJM 1.1 Added code to change the file extension of mail    */
/*                  depending on whether or not a piece of mail was    */
/*                  sent or received.                                  */
/* 12/27/95 DJM 1.2 Fixed bug that would cause a failure if only 1     */
/*                  drive is installed.  Left a trailing blank in the  */
/*                  list of drives after removing the colon(s).        */
/* 12/29/95 DJM 1.3 Fixed a bug in the PMMailNicks subroutine that     */
/*                  could cause problems elsewhere in the code.  I had */
/*                  forgotten to close each of the PMMail address      */
/*                  books as I processed them.  Same close problem     */
/*                  when processing PMMail group files.                */
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
hexDE   = 'DE'x                         /* constant to delimit entries */
keys    = '0D 43 4D 51 63 6D 71'     /* keys for Move/Copy/Quit prompt */
title   = 'PMMail to MR2Ice Migration Aid'             /* screen title */
call SysFileDelete logfile              /* erase any leftover log file */
call AnsiColor                        /* set things up for using color */
drives = SysDriveMap(,'LOCAL')                 /* list of local drives */
drives = translate(drives,'',':')                     /* remove colons */
/***********************************************************************/
/* Find out where PMMail has been installed.                           */
/***********************************************************************/
if words(drives) = 1                             /* only 1 local drive */
  then do
         pmmdrive = strip(drives)           /* move into real variable */
         signal no_pmm_drive     /* don't ask the user where PMMail is */
       end                                     /* if words(drives) = 1 */
call SysCurState 'ON'                            /* turn on the cursor */
call SysCls                                        /* clear the screen */
call build_box 5,7,20,36
call show_title 3 7 63
call SysCurPos 6,22
call charout , pfcolor || 'What drive is PMMail installed on?' || ,
               s.normvid
call SysCurPos 11,22
call charout , pfcolor || 'Enter QUIT if you want to stop now' || ,
               s.normvid
pmm_drive_again:           /* label for branch if the entry is invalid */
call SysCurPos 9,28
call charout , s.blink || s.revvid || 'PMMail Drive ==> ____'
call SysCurPos 9,45
pmmdrive = translate(strip(translate(linein(),'',':')))
call charout , s.normvid
select                        /* decide what to do based on the entry */
  when pmmdrive = 'QUIT'                    /* user wants to stop now */
      then call stopping 'Stopping this program at your request.  Bye' ,
                         'for now...'
  when wordpos(pmmdrive,drives) == 0             /* not a valid drive */
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
no_pmm_drive:         /* we'll come here if there's only 1 hard drive */
call SysFileTree pmmdrive || ':\PMMAIL.INI','temp','FSO' /* chk 4 ini */
select    /* decide how to proceed based on what we found (or didn't) */
  when temp.0 == 0               /* couldn't find the MR2Ice ini file */
      then do
             msg = 'Could not find PMMAIL.INI.  Please make sure that' ,
                   'you entered the correct drive letter and that you' ,
                   'have installed and configured PMMAIL before using' ,
                   'the' ourname 'command.'
             call Logger logfile,msg,,1
             call stopping msg
           end                                 /* of when temp.0 == 0 */
  when temp.0 > 1
      then do
             out = ''                     /* clear variable for output */
             do lp = 1 to temp.0                /* go through each hit */
               last1 = lastpos('\',temp.lp)     /* find last backslash */
               out = out substr(temp.lp,3,last1 - 3)  /* just the path */
             end                             /* of do lp = 1 to temp.0 */
             msg = 'There appears to be multiple copies of PMMail'      ,
                   'installed on the' pmmdrive 'drive.  Before using'   ,
                    ourname 'please rename PMMAIL.INI in the PMMAIL'    ,
                   'directory that you do NOT want migrated to MR2Ice. ',
                   'I found a PMMAIL.INI file in the following'         ,
                   'directories:' out
             call Logger logfile,msg,,1
             call stopping msg
           end                                   /* of when temp.0 > 1 */
  otherwise pmmroot = temp.1         /* looks OK so stash the location */
end                         /* of select based on results of searching */
pmmroot = substr(pmmroot,1,lastpos('\',pmmroot))     /* directory info */
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
               'PMMail folder names as ' || s.normvid
call SysCurPos 11,9
call charout , pfcolor || 'well as how much disk space the mail you' ,
               'currently have stored' || s.normvid
call SysCurPos 12,9
call charout , pfcolor || 'in PMMail occupies.  This make take a' ,
                            'minute or 2.            ' || s.normvid
call SysCurPos 12,57
call PMMailFolders    /* gather PMMail folder info and mail byte count */
/***********************************************************************/
/* When we come back from PMMailFolders the stem PMMFOLDERS will       */
/* contain entries for each PMMail folder name that exists.  The       */
/* variable PMMBYTES will contain the number of bytes of mail that is  */
/* currently stored in ALL of the PMMail folders.  The stem            */
/* PMMDIRNAMES will have the directory name of each PMMail folders.    */
/***********************************************************************/
/* While we've got a message displayed get PMMail nickname details.    */
/***********************************************************************/
call PMMailNicks                     /* gather PMMail nickname details */
/***********************************************************************/
/* When we come back from PMMailNicks the stem PMMNICKS will contain   */
/* all of the information in the PMMail address and group books.       */
/***********************************************************************/
/* Now find out where MR2Ice has been installed.                       */
/***********************************************************************/
if words(drives) = 1                             /* only 1 local drive */
  then do
         mr2idrive = strip(drives)          /* move into real variable */
         signal no_mr2i_drive    /* don't ask the user where MR2Ice is */
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
mr2i_drive_again:         /* label for branch if the entry is invalid */
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
             signal mr2i_drive_again /* go back & give em another try */
           end              /* of when wordpos(mr2idrive,drives) == 0 */
  otherwise nop         /* what was entered is at least a valid drive */
end                              /* of select based on the entry made */
no_mr2i_drive:        /* we'll come here if there's only 1 hard drive */
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
                   'directory that you do NOT want PMMail information' ,
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
if mr2driveleft - pmmbytes < 5000000  /* leave at least 5 meg on drive */
  then do
         msg = 'There is not enough room on the' mr2idrive 'drive to'   ,
               'move or copy the mail you already have filed in'        ,
               'PMMail.  You may make more space available on the'      ,
                mr2idrive 'drive or install MR2Ice on a disk with more' ,
               'space then run' ourname 'again.'
         call Logger logfile,msg,,1
         call stopping msg
       end                  /* of if mr2driveleft - pmmbytes < 5000000 */
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
call charout , pfcolor || 'PMMail folders into MR2Ice folders?      ' || ,
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
do lp = 1 to pmmnicks.0 /* go through each PMMail nickname/group entry */
  nickinf.lp = pmmnicks.lp                /* copy over to correct stem */
end                                      /* of do lp = 1 to pmmnicks.0 */
nickinf.0 = pmmnicks.0                /* copy the total count over too */
call SysCls
call build_box 8,12,11,54
call show_title 3 7 63
call SysCurPos 9,13
call charout , pfcolor || 'Migration of PMMail addresses' ,
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
/***********************************************************************/
/*                                                                     */
/* Each line of the folders.ndx file for MR2Ice is composed of 4       */
/* parts.  The 4 parts are:                                            */
/*                                                                     */
/*    Name of folder - displayed on the main folder tab                */
/*    Name on tab    - tab name used when folder is open               */
/*    Directory name - this is the actual name of the directory        */
/*    Y/N            - Y for auto open - N don't auto open             */
/*                                                                     */
/* Each value is separated by '01'x.  Directory names start with upper */
/* case F followed by a right adjusted, zero filled, number that is    */
/* incremented with each new folder.                                   */
/*                                                                     */
/* Since PMMail has no tab names for folders all we can do is plug in  */
/* the actual folder name as the tab name.  Of course the user may     */
/* change the tab name later if they want to.                          */
/*                                                                     */
/* Before we start going through the PMMail folders we need to read    */
/* and process the existing folders.ndx if it exists so we don't get a */
/* directory clash.                                                    */
/*                                                                     */
/***********************************************************************/
call MR2IceFolderInfo  /* get highest folder number already being used */
frc = stream(mr2indx,'c','open write')             /* open output file */
if substr(frc,1,5) \= 'READY'            /* something bad has happened */
  then do
         msg = 'Unexpected return code of' frc 'trying to open' mr2indx ,
               'for writing.'
         call Logger logfile,msg,,1
         call stopping msg
       end                         /* of if substr(frc,1,5) \= 'READY' */
if length(pmmfolders.0) < 3                   /* less than 100 folders */
  then foldlong = 3       /* default to 3 positions in directory names */
  else foldlong = length(pmmfolders.0)   /* else max digits for length */
do lp = 1 to pmmfolders.0  /* go through each folder we need to create */
  pmmf  = translate(pmmfolders.lp)   /* get a folder name & upper case */
  call SysCurPos 11,13
  call charout , pfcolor || center('Building folder' pmmf 'and' ,
                                    dowhate 'mail items',52) ||    ,
                 s.normvid
  out.0 = 0                              /* clear stem of index output */
  newdir = 'F' || right(mr2ilast + lp,foldlong,'0')    /* new dir name */
  call lineout mr2indx,pmmf || hex01 || pmmf || hex01 || newdir || ,
                               hex01 || 'N'      /* update folders.ndx */
  call SysMkDir mr2inew || newdir          /* create the new directory */
  pmmindex    = pmmroot || pmmdirnames.lp || '.BAG'    /* PMMail index */
  fromdir     = pmmroot || 'FOLDERS\' || pmmdirnames.lp || '\'
  pdir        = mr2inew || newdir             /* MR2Ice directory name */
  folderindex = pdir    || '\FOLDER.NDX'      /* same name in each dir */
  call SysFileTree pmmindex,'temp','F'          /* get index file info */
  if temp.0 == 0                      /* no index file for some reason */
    then iterate lp                              /* next folder please */
  parse var temp.1 . . fbytes .    /* we just need the number of bytes */
  ndxin = charin(pmmindex,1,fbytes)                /* read entire file */
  call stream pmmindex,'c','close'                 /* close index file */
  parse var ndxin mcount (eol) ndxin        /* drop first line (count) */
  if mcount == 0     /* no mail in this folder; just need place holder */
    then call stream folderindex,'c','open write'  /* for 0 byte index */
    else call Build_Index      /* build MR2Ice index from PMMail index */
  /* The out. stem is filled in the Build_Index subroutine if it's     */
  /* been called.  Otherwise out.0 will be 0 and nothing will get      */
  /* written.                                                          */
  do ilp = 1 to out.0                   /* go through each output line */
    call lineout folderindex,out.ilp          /* write the index entry */
  end                                        /* of do ilp = 1 to out.0 */
  call stream folderindex,'c','close'       /* close folder index file */
  folderea = 'FEFF0400'x || build_eas(out.0)    /* build EAs for index */
  call SysPutEA folderindex,'MessageCtr',folderea         /* store EAs */
end                                    /* of do lp = 1 to pmmfolders.0 */
call stream mr2indx,'c','close'              /* close folders.ndx file */
/* We're all done so show the closing screen before we leave for good. */
call SysCls
call build_box 6,14,2,74
call show_title 3 7 63
call SysCurPos 7,4
call charout , pfcolor || center('A total of' pmmnicks.0 'nicknames' ,
                                'were written',72) || s.normvid
call SysCurPos 9,4
call charout , pfcolor || center('A total of' pmmfolders.0 'folders' ,
                                 'were created',72) || s.normvid
call SysCurPos 11,4
call charout , s.blink || s.revvid || center('Conversion of PMMail'   ,
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
                            'PMMail data over to  ' || s.normvid
  call SysCurPos 8,11
  call charout , pfcolor || 'MR2Ice.  Do you want me to clean up your' ,
                            'PMMail folders as' || s.normvid
  call SysCurPos 9,11
  call charout , pfcolor || 'mail is being moved?  Cleaning up' ,
                            'includes removing the   ' || s.normvid
  call SysCurPos 10,11
  call charout , pfcolor || 'PMMail directories as well as the PMMail' ,
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
  if key = 'Y'            /* wants us to clean up the PMMail structure */
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
Build_Index:         /* build MR2Ice index file from PMMail index file */
  /*********************************************************************/
  /* The first line of the PMMail folder index files has a count of    */
  /* how many index entries there are.  We'll ignore that line.  The   */
  /* delimiter between the values is hex DE ('DE'x).  The lines are    */
  /* laid out as follows:                                              */
  /*                                                                   */
  /* Date      - in yy-mm-dd format                                    */
  /* Time      - in hh:mm:ss format                                    */
  /* Subject   - Free form                                             */
  /* From/To   - Who the note was from/to                              */
  /* Name      - Persons name                                          */
  /* File info - filename.ext of the note                              */
  /* Read flag - Y for yes it's been read - we'll force read to Yes    */
  /*                                                                   */
  /* Immediately following the read flag is the value hex E1 ('E1'x).  */
  /*                                                                   */
  /*********************************************************************/
  do forever until ndxin == ''          /* go until we run out of data */
    parse var ndxin idate (hexDE) ,                  /* date           */
                    itime (hexDE) ,                  /* time           */
                    isubj (hexDE) ,                  /* subject        */
                    ifrom (hexDE) ,                  /* from/to        */
                    iname (hexDE) ,                  /* persons name   */
                    ifile (hexDE) ,                  /* note file name */
                    . (eol) ndxin                    /* end-of-line    */
    idate = strip(translate(idate,'/','-'))   /* change date separator */
    parse upper var ifile fn '.' ft  /* break up file name & extension */
    if ft == 'SNT' | ,                   /* sent mail (from PMMail) or */
       ft == ''                          /* sent mail (from LaMail)    */
      then oft = 'out'                           /* use OUT for MR2Ice */
      else oft = 'rcv'                           /* use RCV for MR2Ice */
    ofile = pdir || '\' || fn || '.' || oft   /* build output file inf */
    ndxout = copies(' ',26) ,              /* build MR2Ice index entry */
             left(fn,8)     ,
             left(oft,3)    ,
             copies(' ',12) ,
             idate          ,
             itime          ,
             copies(' ',8)  ,
             'Y    '        ,
             iname ||       ,
             hex01 ||       ,
             isubj ||       ,
             hex01 ||       ,
             hex01 ||       ,
             ifrom
    out.0 = out.0 + 1                    /* bump count of output lines */
    point = out.0              /* move new count into the stem pointer */
    out.point = ndxout                  /* stash data where it belongs */
    '@COPY' fromdir || ifile ofile '/V > NUL 2>NUL'     /* always copy */
    if rc \= 0           /* something happened trying to copy the file */
      then call Logger logfile,'Error: Return code' rc dowhate ,
                                      fromdir || ifile 'to' ofile,,1
      else if dowhat = 'MOVE'                   /* we're moving things */
             then call SysFileDelete fromdir || ifile   /* delete orig */
  end                               /* of do forever until ndxin == '' */
  if cleanup                     /* we're moving stuff and cleaning up */
    then do
           call SysFileDelete pmmindex            /* remove index file */
           call SysRmDir pmmroot || '\FOLDERS\' || pmmdirnames.lp
           if rc \= 0
             then call Logger logfile,'Error: Return code' rc ,
                                            'removing' pmmfolders || ,
                                            '\' || pmmdirnames.lp,,1
         end                                          /* of if cleanup */
return                            /* end of the Build_Index subroutine */
/***********************************************************************/
PMMailFolders: procedure expose pmmroot pmmfolders. pmmbytes pmmdirnames.
call RxFuncAdd 'SysFileTree','RexxUtil','SysFileTree'
if substr(pmmroot,length(pmmroot),1) \= '\'   /* no trailing backslash */
  then pmmroot = pmmroot || '\'                          /* so add one */
eol           = x2c('0D0A')                    /* end of line sequence */
pmmbytes      = 0          /* number of bytes mail is currently taking */
pmmfolders.   = ''                  /* initialize stem of folder names */
pmmfolders.0  = 0     /* zero element will have count of what we found */
pmmdirnames.  = ''        /* initialize stem of folder directory names */
pmmdirnames.0 = 0     /* zero element will have count of what we found */
pmmfldini = pmmroot || 'FOLDERS.INI'                /* folder ini file */
call SysFileTree pmmfldini,'temp.','f'      /* get folders.ini details */
if temp.0 == 0          /* doesn't look like PMMail has ever been used */
  then signal exit_PMMailFolders                          /* leave now */
parse var temp.1 . . fbytes .      /* we just need the number of bytes */
fldin = charin(pmmfldini,1,fbytes)                 /* read entire file */
call stream pmmfldini,'c','close'            /* close folders.ini file */
do forever until fldin == ''            /* go until we run out of data */
  parse var fldin name (eol) dirnam (eol) . (eol) fldin   /* data 4 us */
  if translate(dirnam) == 'INBOX'    | ,   /* don't count the inbox or */
     translate(dirnam) == 'OUTQUEUE' | ,             /* the out box or */
     translate(dirnam) == 'SENT'               /* the sent already box */
    then iterate                          /* next group of info please */
  pmmfolders.0 = pmmfolders.0 + 1               /* bump count of names */
  pointer      = pmmfolders.0                 /* pointer into the stem */
  pmmfolders.pointer  = name                  /* stash the folder name */
  pmmdirnames.pointer = dirnam             /* stash the directory name */
end                                 /* of do forever until fldin == '' */
pmmdirnames.0 = pmmfolders.0    /* copy count of folders to other stem */
do lp = 1 to pmmdirnames.0           /* go through each directory name */
  pmmdir = pmmroot || 'FOLDERS\' || pmmdirnames.lp
  call SysFileTree pmmdir || '\*.*','temp.','f'   /* list of all files */
  if temp.0 == 0                                     /* no files there */
    then iterate                              /* next directory please */
  do ilp = 1 to temp.0                /* go through each file we found */
    parse var temp.ilp . . fbytes .        /* just the number of bytes */
    pmmbytes = pmmbytes + fbytes        /* add it to the overall total */
  end                                       /* of do ilp = 1 to temp.0 */
end                                   /* of do lp = 1 to pmmdirnames.0 */
exit_PMMailFolders:               /* label for branch to leave quickly */
return                          /* end of the PMMailFolders subroutine */
/***********************************************************************/
PMMailNicks: procedure expose pmmroot pmmnicks.
call RxFuncAdd 'SysFileTree','RexxUtil','SysFileTree'
if substr(pmmroot,length(pmmroot),1) \= '\'   /* no trailing backslash */
  then pmmroot = pmmroot || '\'                          /* so add one */
adrbooks.  = ''            /* initialize stem of address books we find */
adrbooks.0 = 0    /* the count will be in the zero element of the stem */
hex01      = '01'x                      /* constant to delimit entries */
eol        = x2c('0D0A')                       /* end of line sequence */
pmmadrini  = pmmroot || 'ADDRESS\ADDRBOOK.INI'     /* address book ini */
pmmgrpini  = pmmroot || 'ADDRESS\GROUP.INI'          /* group list ini */
pmmnicks.  = ''                /* initialize stem of info we'll gather */
pmmnicks.0 = 0                  /* count of entries we find and gather */
call SysFileTree pmmadrini,'temp.','f'     /* get addrbook.ini details */
if temp.0 == 0                           /* no addrbook.ini file found */
  then signal exit_PMMailNicks                     /* we can leave now */
parse var temp.1 . . fbytes .      /* we just need the number of bytes */
adrin = charin(pmmadrini,1,fbytes)                 /* read entire file */
call stream pmmadrini,'c','close'           /* close addrbook.ini file */
do forever until adrin == ''            /* go until we run out of data */
  parse var adrin line (eol) adrin         /* break off a line of data */
  parse upper var line w1 '\' adrname    /* break up the line a little */
  if w1 \= 'ADDRESS'          /* this must be a address book name line */
    then iterate                                   /* next line please */
  adrbooks.0 = adrbooks.0 + 1       /* bump count of books we've found */
  pointer    = adrbooks.0                     /* pointer into the stem */
  adrbooks.pointer = pmmroot || line        /* stash full name of book */
end                                 /* of do forever until adrin == '' */
do lp = 1 to adrbooks.0   /* now go through each address book we found */
  adrbk = adrbooks.lp            /* fully qualified path and file name */
  call SysFileTree adrbk,'temp.','f'       /* get address book details */
  parse var temp.1 . . fbytes .    /* we just need the number of bytes */
  adrin = charin(adrbk,1,fbytes)                   /* read entire file */
  call stream adrbk,'c','close'              /* close the address book */
  do forever until adrin == ''          /* go until we run out of data */
    parse var adrin name (eol) addr (eol) comp (eol) fone (eol) note ,
                         (eol) adrin
    parse var addr uid '@' host                    /* break up address */
    if comp \= ''                          /* company name isn't blank */
      then note = note 'Company name:' comp     /* add it to the notes */
    pmmnicks.0 = pmmnicks.0 + 1                          /* bump count */
    pointer    = pmmnicks.0                       /* pointer into stem */
    pmmnicks.pointer =         hex01 || ,      /* no nickname or alias */
                       uid  || hex01 || ,   /* user ID part of address */
                       host || hex01 || ,      /* host part of address */
                       name || hex01 || ,                 /* full name */
                       fone || hex01 || ,              /* phone number */
                       note || hex01 || ,                     /* notes */
                               hex01
  end                               /* of do forever until adrin == '' */
end                                      /* of do lp = 1 to adrbooks.0 */
/* Now that we're done with address books process the groups (if any)  */
call SysFileTree pmmgrpini,'temp.','f'        /* get group.ini details */
if temp.0 == 0          /* no group ini file found (no groups defined) */
  then signal exit_PMMailNicks                     /* we can leave now */
parse var temp.1 . . fbytes .      /* we just need the number of bytes */
grpin = charin(pmmgrpini,1,fbytes)                 /* read entire file */
call stream pmmgrpini,'c','close'           /* close addrbook.ini file */
do forever until grpin == ''            /* go until we run out of data */
  parse var grpin line (eol) grpin         /* break off a line of data */
  parse upper var line w1 '\' .              /* get first word of line */
  if w1 \= 'ADDRESS'                 /* this must be a group name line */
    then do
           parse var line grpname .      /* respect case of group name */
           pmmnicks.0 = pmmnicks.0 + 1                   /* bump count */
           pointer    = pmmnicks.0                /* pointer into stem */
           pmmnicks.pointer = grpname || hex01 || hex01 || hex01 || ,
                              grpname || hex01 || hex01 || hex01
           iterate                               /* read the next line */
         end                                  /* of if w1 \= 'ADDRESS' */
  groupfile = pmmroot || line              /* stash full name of group */
  call SysFileTree groupfile,'temp.','f'     /* get group file details */
  parse var temp.1 . . fbytes .    /* we just need the number of bytes */
  group = charin(groupfile,1,fbytes)               /* read entire file */
  call stream groupfile,'c','close'            /* close the group file */
  names = ''            /* initialize variable to hold group addresses */
  do forever until group == ''          /* go until we run out of data */
    parse var group addr (eol) group /* each line should be an address */
    names = names addr                  /* add the address to the list */
  end                               /* of do forever until group == '' */
  pmmnicks.pointer = pmmnicks.pointer || strip(names,'L') || hex01
end                                 /* of do forever until grpin == '' */
exit_PMMailNicks:                 /* label for branch to leave quickly */
return                            /* end of the PMMailNicks subroutine */
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
