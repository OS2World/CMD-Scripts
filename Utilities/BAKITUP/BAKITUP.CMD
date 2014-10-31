/* This is a REXX file to back up selected files to one diskette drive  */
/* while writing a log to the other drive */
cls

/* This is set up to log on A: and place backups on B:
 * If you want to reverse, change it here
 */
backupdisk = "B:"
logdisk    = "A:"

/* This can be used to change what external command is
 * executed by the program
 */
extcmd    = "backup"

say  "This procedure backs up selected files to drive" backupdisk
call getlogdisk 
call setupparms
call bakemup
EXIT

getlogdisk:
/* Set it up to be able to use SysFileTree */
rc = RxFuncQuery( 'SysDriveInfo' )
/* say "RxFuncQuery rc = " rc */
if rc = 1 then
  do
    rc = RxFuncAdd( 'SysDriveInfo', 'RexxUtil', 'SysDriveInfo' )
    /*   "RxFuncAdd rc = " rc  */
  end

/* Check success, and do the job 
 * rc can be 0 if SysDriveInfo is already registered or if it is
 * already registered successfully.
 */
if rc = 0 then do
  
  driveinfo = ""
  do while driveinfo = ""
      say  "Please put the log diskette in drive" logdisk "and press RETURN"
      pull newbie
      driveinfo = SysDriveInfo( logdisk )
  end
end
call RxFuncDrop( 'SysDriveInfo' )
return    /* getlogdisk  */

   
setupparms:
/* This variable governs directory searches later on */
          
dattribs = '*+-**'

/*  Attributes for directories:
        Archive   * (don't care)
         Directory + (yes)
         Hidden    - (no)
         Read only * (don't care )
         System    * (don't care )        */

say  "To start a new set enter N, otherwise anything else"   

parse upper pull newbie .
/* say "newbie = " newbie 
 * The dot ensures that blanks are stripped from around the first
 * word and collects any multiple word garbage that might be
 * entered to check robustness.
 */
new = substr(newbie, 1, 1 )

if new = "N" then  
  do
      parms = "/L:" || logdisk || "\backup.log"

      /*  New diskette set, no append, no check for modification
         Attributes are: (L to R )

         Archive   * (don't care)
         Directory - (no)
         Hidden    - (no)
         Read only * (don't care )
         System    - (no)         */

      attrib = "*--*-"
      'del a:backup.log 2> nul'
  end
else
  do
      parms = "/A /M /L:" || logdisk || "\backup.log"

      /*  Continue: append to current backup diskette,
          backup only modified files

         Attributes are: (L to R )
         Archive   + (must be set - selective backup)
         Directory - (no)
         Hidden    - (no)
         Read only * (don't care )
         System    - (no)         */

      attrib = "+--*-"
  end

/* say "parms =" parms " attrib =" attrib */
RETURN

bakemup:
/*  These are the selected files  */

/*  Each selection is made as a pair, paths. and files.
 *  The variable paths selects a root directory to be searched
 *  for files of various types.  
 *  The variable files contains the set of file extensions that
 *  will be searched for.
 *  To add/delete files, add/delete them in pairs.
 *
 *  Specify first the path to be backed up, then
 *  the string of files to be searched for in each
 *  subdirectory of the chosen directory, as well as the
 *  directory itself.  Then change the limit variable below:
 */
paths.0 = "e:\files"
files.0  = "*doc *wk1 *wk3 *wg2 *cdr *fm1 *fm3"

paths.1 = "e:\c600\binp" 
files.1 = "*.cmd" 

paths.2 = "e:\word55"
files.2 = "*.gly *.sty"

paths.3 = "d:\tk"
files.3 = "*.tk"

paths.4 = "d:\sw\songs"
files.4 = "*"

paths.5 = "d:\folks"
files.5 = "*.dt?"             

paths.6 = "d:\bridge"
files.6 = "*.dat"

paths.7 = "d:\windows"
files.7 = "*.crd"

paths.8 = "e:\usr\bin"
files.8 = "*.cmd"

paths.9 = "e:\prj" 
files.9 = "*.doc *.y *.lxi *.asm *.mak *,v *.c *.cpp *.cc *.h *.mk" 

limit = 9  /* Change this when more file
                      specs are added to the list.  The value 
                      should be the same as the highest number on
                      the files and paths variables.  */

/* This is a precaution, because this is the only
 * directory where we back up all files, and don't
 * want the .bak files.  
 * 2> means redirect stderr, to avoid a frequent
 * confusing message. 
 * Some users may not wish to have such a command executed.
 */
'del d:\sw\songs\*bak 2> nul'

/* Set it up to be able to use SysFileTree */
rc = RxFuncQuery( 'SysFileTree' )
/* say "RxFuncQuery rc = " rc */
if rc = 1 then
  do
    rc = RxFuncAdd( 'SysFileTree', 'RexxUtil', 'SysFileTree' )
    /* say "RxFuncAdd rc = " rc */
  end

/* Check success, and do the job */
if rc = 0 then do
    say "Starting backup by looking for files"
    do i = 0 to limit
      rc = SysFileTree( paths.i || "\*", 'dirs', 'SDO', dattribs )

      if rc = 0 then do
        pathcount = dirs.0
        dirs.0 = paths.i
        do j = 0 to pathcount
          dirs.j =  dirs.j || "\"
          /*  say "   dirs."j"=" dirs.j */
          temporary = files.i                           
          do while temporary \= ''
            parse var temporary pfeil temporary /* REXX idiom for pulling
                                                 * successive words out of a
                                                 * string in a hurry
                                                 */
            searcher =  dirs.j || pfeil
            rc = SysFileTree( searcher, 'fyles','FO', attrib ) 
            /* say searcher "  rc =" rc "fyles.0 =" fyles.0 */
            if (rc = 0) & (fyles.0 > 0) then do
              commandtodo = extcmd searcher backupdisk parms
              commandtodo
              if new = 'N' then do
                new = 'O'  /* Once only!  */
                parms = '/A' parms
                /* say "PARMS FIXED"   */
              end  /* if new = 'N'  */
              /*  pull newbie */
            end /* if ( rc = 0 ) & ( fyles.0 > 0 )  */
            drop fyles /* Economize our memory space */
          end  /* do k = 0 to filenamecount  */
          /* pull newbie  */
        end  /* do j = 0 to pathcount     */
      end  /* if rc = 0 then do      */
      else /* rc /= 0, SysFileTree failed */ do
        say "SysFileTree call failed - exiting!"
        return
      end
      drop dirs /* Ecnomize on space, probably not necessary */
    end  /* do i = 1 to limit      */
    /*  Now unload the entry point that was registered */

    call RxFuncDrop( 'SysFileTree' )
    say "Backup procedure completed"

  end /* of do   */

else  say "Unable to load SysFileTree - execution ended" 
RETURN        
