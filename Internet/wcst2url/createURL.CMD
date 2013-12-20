/*
 *
 * createURL v1.0 - (c) 1997
 * Create URL Objects out of WarpCast News and place them in date-ordered
 * subfolders inside the NEW and UPDATED folders created by createFOLDER
 *
 * G.Aprile A.Resmini P.Rossi
 * resmini@netsis.it
 *
 * Needless to say, this is absolutely FREEWARE, comes with no
 * warranties whatsoever, and does not work in Windows.
 * Actually, you would need some 10MBs program to do this, in Windows.
 * ;)
 *
 * G.Aprile and A.Resmini are members of teamOS2 Italy
 *
 * This Rexx procedure works within PMMail 1.9x.
 * You need to set it as a rexx command for incoming mail.
 * Open your account or utilities settings depending on your version of
 * the program, get to the Rexx tab and enter the name of this file
 * under the 'Message receive exit', complete with path.
 * Mark the checkbox also, or it won't  work. ;)
 *
 * You will need the FILEREXX rexx extensions, available on Hobbes as
 * filerx.zip in the \rexx directory.
 *
 */

    call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
    call SysLoadFuncs
    call RxFuncAdd 'FileLoadFuncs', 'FILEREXX', 'FileLoadFuncs'
    call FileLoadFuncs

 /* Let's set a bunch of variables and explain their use */

 /* This parses the file handle passed by PMMail */

    arg msgfile

 /* The msgline variables are used to handle lines in the message */

    msgline.0 = 3
    msgline.1 = ''
    msgline.2 = ''
    msgline.3 = ''
    lSubj = 0
    lNew  = 0
    lUpdated = 0

 /* This string lets you choose if you want URL objects or just a dat
  * file for HTMLBuilder. Note that you always create the dat file
  * and that if you choose no URLs, the folders created by createFOLDER
  * are quite useless. Nothing gets written there.
  * And if you do not want a dat file, do not use this program.
  * Default is create them URLs.
  *
  * 0 = Create the URL objects
  * 1 = No, thanks, I'll go for the dat file only
  */

  URLorDAT = 0

 /*
  * This value lets you choose between standard or Warp 4 URL folders
  * for your URLs to be stored in. Default is standard folders.
  *
  * 0 = Standard folder
  * 1 = URL folder
  */

  FolderType = 0

 /*
  * This is the name of the dat file we will use to generate the HTML
  * with HTMLBuilder. Better leave it alone.
  * Or rememeber you will have to change the reference in both files.
  */

  datFile = 'wcastidx.dtf'

 /*
  * These are the strings this script is looking for.
  * Mind you that SUBJSTR is the one string which makes of a Warpcast msg
  * a Warpcast URL message. If there is no such string, we are not  going
  * to be bothered with it.
  */

    subjStr = '[WarpCast] New and Updated Links at the Supersite for'
    updStr =  'Monitored sites updated in the past 24 hours:'
    newStr =  'New Sites recently added:'


  /*
   * Start of program
   * Do not modify anything below this line unless you know what you are
   * doing.
   */ 

    If FolderType = 0 then 
       cNameFolder = 'WPFolder'
    else
      cNameFolder = 'WPURLFolder'	

 /*
  * Create the datFile used by HTMLBuilder
  * This file is written ex novo every time a Warpcast URL message comes in
  */

    handle = 0
    handle = FileOpen(datFile,'rw','on')
    if handle = 0 then
     do
       if FileClose(handle) = 0 then handle = 0
       say ' Ah, we have an OS error while creating the file ' || datFile
     end

     do while lines(msgfile)
       msgline.2=linein(msgfile)

 /* Let's start checking the incoming message subject string */

       do while lSubj = 0 & lines(msgfile)

          if pos('Subject:',msgline.2) > 0 then
             do
               if pos(subjStr,msgline.2) > 0 then
                do
                lSubj = 1
                msgline.1 = msgline.2
                msgline.2 = linein(msgfile)
                VarDate = Substr(msgline.2,7,16)
                FolderDate = Substr(VarDate, 1, 1) || Substr(VarDate, 6, 2),
                             || Substr(VarDate, 9, 1) || Substr(VarDate, 15, 2)
                err = FilePuts(handle, VarDate )
                end
               else
                exit
             end
        msgline.1 = msgline.2
        msgline.2 = linein(msgfile)
       end

 /* Wow, it's the right message. Check if it has updated links */

       do while lUpdated=0 & lNew = 0 & lines(msgfile)
          if pos(updStr,msgline.2) > 0 then
             do
             msgline.3 = '<WCASTUPD>'
             lUpdated = 1
              objectID  = '<UPD' || FolderDate || '>'
              location  = '<WCASTUPD>'
              Call CreateFolder
             end
          msgline.1 = msgline.2
          msgline.2 = linein(msgfile)
       end

 /* Well, we have the updated ones. Now check for the new string */

       do while lUpdate > 0 & lines(msgfile)

          if pos(newStr,msgline.2) > 0 then
             do
               msgline.3= '<WCASTNEW>'
               lNew = 1
               lUpdated = 0
               objectID  = '<NEW' || FolderDate || '>'
               location  = '<WCASTNEW>'
               Call CreateFolder
               leave
             end
          if pos('All Links',msgline.2) > 0 then exit
          if pos('http:',msgline.2) > 0 then
             do
               err = FilePuts(handle, msgline.1 )
               err = FilePuts(handle, msgline.2 )
               err = FilePuts(handle, 'UpDated' )
               if URLorDAT = 0 then
                 do
                  location = '<UPD' || FolderDate || '>'
                  call createUrl
                 end
             end
          msgline.1 = msgline.2
          msgline.2 = linein(msgfile)
       end

 /*
  * Here come the new ones. Check for URLs up to the end of file
  * but avoid the self referencing URLs at the end.
  * We don't want to have a thousand OS2SS URLs. ;)
  */

       do while lNew > 0 & lines(msgfile)

          if pos('All Links',msgline.2) > 0 then exit

          if pos('http:',msgline.2) > 0 then
             do
               err = FilePuts(handle, msgline.1 )
               err = FilePuts(handle, msgline.2 )
               err = FilePuts(handle, 'New' )
               if URLorDAT = 0 then
                  do
                   location = '<NEW' || FolderDate || '>'
                   call createUrl
                  end
             end

          msgline.1 = msgline.2
          msgline.2 = linein(msgfile)
       end

    end

    call FileDropFuncs
    exit

 /* This is the procedure which actually creates the URL objects */

 CreateUrl:

       title  = msgline.1
   className  = 'WPURL'
       setup  = 'URL='|| msgline.2 || ';'
   UpdateFlag = 'F'

    rc = SysCreateObject( className, title, location, setup , updateFlag )
    if rc <> 1 then
    do
      say ' Wow, could not create the URL object for ' || title || '.' || '07'x
      say ' Either the object already exists or an error occurred.'
      say ''
    end

    else
      ExitCode = 0

return

  /* And this is the procedure which creates a new folder for each day */

CreateFolder:

     if URLorDAT = 0 then
      do
       title = VarDate
       className = cNameFolder  
      /*  if FolderType = 1 then classname = 'WPURLFolder' */
       setup = 'OBJECTID=' || objectID || ';'
       UpdateFlag = 'F'

       rc = SysCreateObject( className, title, location, setup, updateFlag )
       if rc <> 1 then
         do
          say ' Wow, could not create the folder object for ' || Vardate || '.' || '07'x
          say ' Either the object already exists or an error occurred.'
          say ''
       end
      else
      ExitCode = 0
     end

return
