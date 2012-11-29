/* ------------------------------------------------------------------ */
/*                                                                    */
/*             sample program to show the use of RXLBOX               */
/*                                                                    */
/*   This program uses the queue to create dynamic menus on the fly   */
/*                                                                    */
/* 26.04.1997 /bs                                                     */
/*  - changed a bug in the handling of filenames with imbedded blanks */
/*                                                                    */
/*                                                                    */
/* ------------------------------------------------------------------ */

                    /* load REXXUTIL                                  */
                    /* note: REXXUTIL is only necessary for the       */
                    /*       functions to get the data for the        */
                    /*       dynamic menus!                           */
                    /*       RXLBOX does not use REXXUTIL!            */

  call rxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
  call SysLoadFuncs

                    /* search the program                             */
                    /* The routine SearchPrograms sets the variables  */
                    /* MENUPROG and MENUPROGPATH.                     */
  menuProgName = 'RXLBOX.CMD'
  call SearchProgram

                    /* collect the data for the menus                 */
  say 'Collecting the data for the menus. Please wait ...'

                    /* the nain menu is a menu of the existing drives */
  driveString = SysDriveMap()
  driveStem.0 = 0

                    /* ignore drives which are not ready              */
  do i = 1 to words( driveString )
    curDrive = word( driveString,i )
    driveDesc = SysDriveInfo( curDrive )
    if driveDesc <> '' then
    do
      j = driveStem.0 +1
      driveStem.j = driveDesc
      driveStem.0 = j
    end /* if driveDesc <> '' then */
  end /* do i = 1 to words( driveString ) */

                    /* the sub menus contain the files in the current */
                    /* directories of the existing drives             */
  do i = 1 to driveStem.0
    curDrive = word( driveStem.i, 1 )
    dirStemName = 'dirStem.' || curDrive || '.'
    call SysFileTree curDrive || '\*.*', dirStemName
  end /* do i = 1 to driveStem.0 */

                    /* flush the queue                                */
  do while queued() <> 0
    parse pull
  end /* do while queued() <> 0 */

                    /* create the menu definition for the main menu   */
  queue '[*DriveMenu*]'
  queue 'Title1=Detected drives on your system'
  queue 'Title2=Note that there is no help available'
  queue 'StatusLine=This is a dynamicly created menu'
  queue 'Title3 = Drv Free bytes   total bytes  volume label                       ' || 'FF'x


  do i = 1 to driveStem.0
    curDrive = word( driveStem.i, 1 )
    driveMenuName = 'Drive_' || curDrive

    queue 'MenuItem.# = ' || driveStem.i
    queue 'Action.# = ' || '#GOTOMenu() ' driveMenuName
  end /* do i = 1 to driveStem.0 */

                    /* create the menus for the directory listings    */
  do i = 1 to driveStem.0
    curDrive = word( driveStem.i, 1 )
    driveMenuName = 'Drive_' || curDrive

    queue '[*' || driveMenuName || '*]'
    queue 'Title1=Directory listing of the current directory of drive' curDrive
    queue 'Title2=Note that there is no help available'

    call setlocal
    tCurDir = directory( curDrive || '\' )

    if length( tCurDir ) > 50 then
      tTitle3 = 'Current dir is "' || substr( tCurDir, 50 ) || '"'
    else
      tTitle3 = 'Current dir is "' || directory( curDrive ) || '"'

    queue 'Title3=' tTitle3

    tStatusLine = "{'Current entry is ' || fileSpec( 'N', !curMenuEntry ) || ' (Attr.: ' || word( !curMenuAction,4 ) || ')' }"

    call endlocal
    queue 'StatusLine='tstatusLine

    do j = 1 to dirStem.curDrive.0
      queue 'MenuItem.# = ' || substr( dirStem.curDrive.j,38 )
      queue 'Action.# = ' || dirStem.curDrive.j
    end /* do j = 1 to dirStem.curDrive.0 */

  end /* do i = 1 to driveStem.0 */

                    /* temporary change the PATH                      */
                    /* (external REXX routines must be in a directory */
                    /*  in the PATH!)                                 */
  oldPath = value( 'PATH', , 'OS2ENVIRONMENT' )
  call value 'PATH', menuProgPath || ';' || oldPath, 'OS2ENVIRONMENT'

  userInput = RXLBOX( 'QUEUE:', 'DriveMenu' )

                    /* restore the PATH                               */
  call value 'PATH', oldPath, 'OS2ENVIRONMENT'

  say ''
  say 'Result of RxLBox is '
  say '  "' || userInput || '"'

                    /* flush the queue                                */
  do while queued() <> 0
    parse pull
  end /* do while queued() <> 0 */
exit

/* ------------------------------------------------------------------ */
/* sub routine to search the program RXLBOX.CMD                       */

SearchProgram:

                    /* search the program RXLBOX.CMD                  */
  menuProg = directory() || menuProgName
  if stream( menuProg , 'c', 'QUERY EXIST' ) = '' then
  do
    parse source . . thisProgram
    menuProg = fileSpec( 'D', thisProgram ) || ,
               fileSpec( 'P', thisProgram ) || ,
               menuProgName
  end /* if stream( menuProg , 'c', 'QUERY EXIST' ) = '' then */

  if stream( menuProg , 'c', 'QUERY EXIST' ) = '' then
  do 
    say 'Error: ' || menuProgName || ' not found!'
    exit 255
  end  /* if stream( menuProg , 'c', 'QUERY EXIST' ) = '' then */
  else
    menuProgPath = fileSpec( 'D', menuProg ) || ,
                   fileSpec( 'P', menuProg )

RETURN
/* ------------------------------------------------------------------ */