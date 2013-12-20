/*
 *
 * createFOLDER v1.0 - Dec. 1997
 * Simple script which creates two folders for NEW and UPDATED
 * links from Warpcast and then shadows them on the WPS.
 *
 * G.Aprile A.Resmini and P.Rossi
 * You may get in touch with A.Resmini at resmini@netsis.it
 *
 * Needless to say, this is absolutely FREEWARE, comes with no
 * warranties whatsoever, and does not work in Windows.
 * Actually, you would need some 10MBs program to do this, in Windows.
 * ;)
 *
 * G.Aprile and A.Resmini are members of teamOS2 Italy
 *
 *
 * The script will let you choose drive and directory names.
 * If you do not specify them it will default to the OS/2 system drive
 * and to [Warpcast New Links] and [Warpcast Updated Links].
 *
 *
 *
 */

    call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
    call SysLoadFuncs

    newFolder= '[Warpcast New links]'
    updFolder= '[Warpcast Updated links]'

    aesc='1B'x
    yellow=aesc||'[33;m'
    red=aesc||'[31;m'
    white=aesc||'[37;m'
    green=aesc||'[32;m'
    bright=aesc||'[1;m'
    dull=aesc||'[2;m'
    normal=aesc||'[0;m'
    bold=aesc||'[1;m'

    '@cls'
    '@Ansi >ansitemp.$$$$$'

    AnsiStatus = Right(Linein('ansitemp.$$$$$'), 3)
    err = stream('ansitemp.$$$$$','c','close')
    '@del ansitemp.$$$$$'
    if AnsiStatus = 'ff.' then '@Ansi on'

    say ' '
    say bright yellow '   createFOLDER v1.0 - December 1997' normal
    say ' '
    say ' This script will create folders for Warpcast URLs on a selected'
    say ' hard disk and then it will shadow them on your Workplace Shell.'
    say ' '

    say bright yellow ' Enter drive for the NEW Sites folder or ENTER for boot drive'
    call CharOut , '   ==> ' normal
     parse pull new

      if new = '' then new = Left(SysSearchPath('PATH','CMD.EXE') , 1 )
      newDrive = left( new, 1)

    say bright yellow ' Enter drive for the UPDATED Sites folder or ENTER for boot drive'
    call CharOut , '   ==> ' normal
     parse pull upd

     if upd = '' then upd = Left(SysSearchPath('PATH','CMD.EXE') , 1 )
     updDrive = left( upd, 1)

    say  bright yellow ' Enter the NEW URLs dirname or press ENTER for [Warpcast New Links]'
    call CharOut , '   ==> ' normal
     parse pull newPull

     if newPull = '' then
        newPull = newFolder

    say bright yellow ' Enter the UPDATED URLs dirname or press ENTER for [Warpcast Updated Links]'
    call CharOut , '   ==> ' normal
     parse pull updPull

     if updPull = '' then updPull = updFolder

     newDir = newDrive || ':\' || newPull
     updDir = updDrive || ':\' || updPull

    objectIDN  = '<WCASTNEW>'
        title  = newFolder
    className  = 'WPFolder'
     location  =  newDrive || ':\'
        setup  = 'OBJECTID=' || objectIDN || ';'
    UpdateFlag = 'F'

    rc = SysCreateObject( className, title, location, setup, updateFlag )
    if rc <> 1 then
    do
      say bright red ' '
      say ' Whoops, could not create ' || title '.' || '07'x
      say ' Either the folder already exists or an error occurred.'
      say ' ' normal
    end
    else

    objectIDU  = '<WCASTUPD>'
        title  = updFolder
    className  = 'WPFolder'
     location  =  updDrive || ':\'
        setup  = 'OBJECTID=' || objectIDU || ';'
    UpdateFlag = 'F'

    rc = SysCreateObject( className, title, location, setup, updateFlag )
    if rc <> 1 then
    do
      say bright red ' '
      say ' Whoops, could not create ' || title '.' || '07'x
      say ' Either the folder already exists or an error occurred.'
      say ' ' normal
    end
    else

 /* A dummy title string to pass to SysCreateObject */

    title = 'faketitle'

 /* Now let's create them shadows*/

     className = 'WPShadow'
      location = '<WP_DESKTOP>'
         setup = 'SHADOWID= <WCASTNEW>'
    UpdateFlag = 'F'

    rc = SysCreateObject( className, title, location, setup, updateFlag )
    if rc <> 1 then
    do
      say bright red ' '
      say ' Oops, could not create the shadow for the NEW folder.' || '07'x
      say ' Either the object already exists or an error occurred.'
      say ' ' normal
    end
    else

    className  = 'WPShadow'
     location  = '<WP_DESKTOP>'
        setup  = 'SHADOWID= <WCASTUPD>'
    UpdateFlag = 'F'

    rc = SysCreateObject( className, title, location, setup , updateFlag )
    if rc <> 1 then
    do
      say bright red ' '
      say ' Oops, could not create the shadow for the UPDATED folder.' || '07'x
      say ' Either the object already exists or an error occurred.'
      say ' ' normal
    end

  /*
   * In order to complete installation, ask the user if he/she/it wants
   * an object on the WPS for the rexx script HTMLBuilder.
   */

    say bright yellow ' Would you like to have an object for HTMLBuilder on your WPS (Y/N)?'
    call CharOut , '   ==> ' normal

    answer = Translate( CharIn() )
      if answer =  'Y' then  call makeObj
    
    say bright green ' '
    say ' All done. Enjoy.' normal

    if AnsiStatus = 'ff.' then '@Ansi off'
    call SysDropFuncs
    exit

 /* This is the function the creates the HTMLBuilder WPS object. Nothing new. */

    makeOBJ:

     dir = directory() || '\'
     rc=SysCreateObject('WPProgram', 'HTMLBuilder', '<WP_DESKTOP>','EXENAME=' || dir || 'HTMLBuilder.cmd;STARTUPDIR=' || dir )
    return
