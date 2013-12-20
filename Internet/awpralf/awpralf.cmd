/* Auto WGet Daemon Global Plugin awpralf v0.3.1                  */
/* This product includes software developed by Dmitry A.Steklenev */
/* See Dmitry A.Steklenev's copyright notice at the end           */

signal on notready

G!.debug = 0

exposelist = "G!. job. urlcnt myURL myURLOpt debuglog"

parse source G!.sys G!.env G!.myname
parse value reverse( G!.myname ) with . "\" mypath
debuglog = reverse( mypath )||"\awpralf.log"

parse version version .

if version = "OBJREXX" then
   do
      G!.sysopen_read  = "OPEN READ SHAREREAD"
      G!.sysopen_write = "OPEN WRITE SHAREREAD"
   end
else
   do
      G!.sysopen_read  = "OPEN READ"
      G!.sysopen_write = "OPEN WRITE"
   end

rc = wlog( G!.myname "("G!.sys G!.env version") started" ) /* debug */

do forever

  inline = linein()
  parse var inline event +4 +1 info

  select
    when event == "INIT" then
       do
          rc = wlog( "<==" event info ) /* debug */
          if info \= "" & DirExist( info ) then
             G!.awgethome = info /* awget-homedir */
          else
             do
                rc = send( "ALRM Auto WGet Daemon home directory not found:" )
                rc = send( "FAIL '"info"' does not exist!" )
                exit 1
             end
          urlcnt = 0 /* URL-counter 0 on INIT */
          rc = send( awpralf_init() )
          rc = send( "DONE" )
       end

    when event == "STOP" then
       do
          rc = wlog( "<==" event info ) /* debug */
          exit 0
       end

    when event == "SCAN" then
       do
          rc = wlog( "<==" event info ) /* debug */
          if G!.use_desktop = 1 & G!.desktopdir \= "" & G!.obsolete_objects \= "" then
             do
                /* if awpralf_prescan() = 0 then */
                /*    rc = WpsRefresh( G!.desktopdir ) */
                rc = awpralf_prescan()
                rc = wlog( "awpralf_prescan() RC="rc )
             end
          rc = send( "DONE" )
       end

    when event == "CONF" then
       do
          rc = wlog( "<==" event info ) /* debug */
          rc = wlog( "Calling awpralf_init on event CONF" )
          if left( strip( awpralf_init() ), 4 ) == "ALRM" then
             rc = send( "ALRM Re-init of plugin '"G!.myname"' FAILED!" )
          rc = send( "DONE" )
       end

    when event == "SEXE" then
       do
          rc = wlog( "<==" event info ) /* debug */
          if left( strip( awpralf_init() ), 4 ) == "ALRM" then
             rc = send( "ALRM Re-init of plugin '"G!.myname"' FAILED!" )
          if G!.ext_download \= "" then
             rc = send( awpralf_ext_download( info ) )
          if G!.dupe_check == 1 | translate( G!.dupe_check ) == "YES" then
             rc = send( awpralf_dupecheck( info ) )
          rc = send( "DONE" )
       end

    when event == "SEND" then
       do
          rc = wlog( "<==" event info ) /* debug */
          rc = send( "DONE" )
       end

    otherwise
       rc = send( "FAIL Plugin '"G!.myname"' received unknown event:" event info )

  end /* select */

end /* do forever */

NOTREADY:
exit 1

/* $Id: awpralf.cmd,v 1.3 2001/07/06 16:36:40 esper Exp $ */

/*------------------------------------------------------------------*/
/* Read Job from file                                               */
JobRead: procedure expose (exposelist)

  parse arg pathname

  job.object               = ""
  job.url                  = ""
  job.download             = ""
  job.message_done         = ""
  job.message_error        = ""
  job.downloads_utility    = ""
  job.downloads_parameters = ""
  job.downloads_rc         = 0
  job.downloads_info       = ""

  rc = stream( pathname, "C", G!.sysopen_read )

  if rc \= "READY:" then do
     return 0
  end

  do while lines(pathname) > 0
     parse value linein(pathname) with command "=" argument

     command  = translate(strip(command))
     argument = strip(argument)

     select
        when command == "OBJECT",
           | command == "URL",
           | command == "DOWNLOAD",
           | command == "DOWNLOADS_UTILITY",
           | command == "DOWNLOADS_PARAMETERS",
           | command == "DOWNLOADS_SIMULTANEOUSLY",
           | command == "DOWNLOADS_RC",
           | command == "DOWNLOADS_INFO",
           | command == "MESSAGE_DONE",
           | command == "MESSAGE_ERROR" then
             job.command = argument
        otherwise
     end
  end

  rc = stream( pathname, "C", "CLOSE" )

return 1

/*------------------------------------------------------------------*/
/* Save Job to file                                                 */
JobSave: procedure expose (exposelist)

  parse arg pathname

  if arg( 1, "omitted" ) | pathname == "" then do
     pathname = SysTempFileName( dir.jobs"\?????.job" )
     body.0   = 0
     end
  else do
     rc = stream( pathname, "C", G!.sysopen_read )

     do i = 1 while lines(pathname) > 0
        body.i = linein(pathname)
     end
     body.0 = i - 1
     rc = stream( pathname, "C", "CLOSE" )
  end

  key_list = "OBJECT "               ||,
             "URL "                  ||,
             "DOWNLOAD "             ||,
             "MESSAGE_DONE "         ||,
             "MESSAGE_ERROR "        ||,
             "DOWNLOADS_UTILITY "    ||,
             "DOWNLOADS_PARAMETERS " ||,
             "DOWNLOADS_RC "         ||,
             "DOWNLOADS_INFO "

  do i = 1 to words(key_list)
     key = word(key_list,i)

     do j = 1 to body.0
        if left( strip( body.j ), 1 ) == "#" then
           iterate

        parse value body.j with command "="
        command = translate(strip(command))

        if key == command then
           leave
     end j

     body.j = key "=" job.key

     if j > body.0 then
        body.0 = j
  end i

  if stream( pathname, "C", "QUERY EXISTS" ) \= "" then
     '@del "'pathname'" /F'

  rc = stream( pathname, "C", G!.sysopen_write )

  if rc \= "READY:" then do
     return ""
  end

  do j = 1 to body.0
     call lineout pathname, body.j
  end

  rc = stream( pathname, "C", "CLOSE" )

return pathname


/*------------------------------------------------------------------*/
/* Check valid URL file                                             */
IsURLFile: procedure expose (exposelist)

  parse arg filename

  thissize = stream( filename, "c", "query size" )
  if thissize == "" | thissize < 7 then
     return 0
  if thissize > 17 then
     thissize = 18

  rc  = stream( filename, "c", G!.sysopen_read )
  url = translate( strip( charin( filename, 1, thissize ) ) )
  rc  = stream( filename, "c", "close" )

return substr( url, 1,  7 ) == "HTTP://" |,
       substr( url, 1,  6 ) == "FTP://"  |,
       substr( url, 1, 18 ) == "[INTERNETSHORTCUT]"


/*------------------------------------------------------------------*/
/* Converts directory to canonical form                             */
DirCanonical: procedure expose (exposelist)

  parse arg path

  path = translate( path, "\", "/" )

  if right( path, 1 ) == "\" & pos( ":", path ) \= length(path) - 1 then
     path = left( path, length(path)-1 )

return path


/*------------------------------------------------------------------*/
/* Returns path to file                                             */
DirPath: procedure expose (exposelist)

  parse arg pathname

return DirCanonical( filespec( "drive", pathname )||,
                     filespec( "path" , pathname ))


/*------------------------------------------------------------------*/
/* Create directory                                                 */
DirCreate: procedure expose (exposelist)

  parse arg path

  path = DirCanonical( path )
  rc   = SysMkDir( path )

  if rc == 3 & pos( "\", path ) \= 0 then
     do
        parent = left( path, length(path) - pos( "\", reverse(path)))
        rc = DirCreate( parent )
        if rc == 0 then rc = SysMkDir( path )
     end
return rc


/*------------------------------------------------------------------*/
/* Checks existence of the directory                                */
DirExist: procedure expose (exposelist)

  parse arg path

  if path == "" then return 0
  path = DirCanonical( path )

  setlocal
  path = directory( path )
  endlocal

return path \= ""


/*------------------------------------------------------------------*/
/* Get URL from file                                                */
GetURLFromFile: procedure expose (exposelist)

  parse arg filename

  rc  = stream( filename, "c", G!.sysopen_read )
  signal off notready
  url = linein( filename )
  signal on notready

  if translate( strip( url ) ) == "[INTERNETSHORTCUT]" then
     do
        signal off notready
        parse value linein( filename ) with 'URL='url
        signal on notready
     end

  rc = stream( filename, "c", "close" )

return strip( url )


/*------------------------------------------------------------------*/
/* Moves the WPS object                                             */
WpsMove: procedure expose (exposelist)

  parse arg file_from, file_to, touch

  file_long = WpsGetEA( file_from, ".LONGNAME" )

  if file_long == "" then
     rc = WpsPutEA( file_from, ".LONGNAME", filespec( "name", file_from ) )

  if stream( file_to, "c", "query exists" ) \= "" then do

     path = filespec( "drive", file_to )||filespec( "path", file_to )
     name = filespec( "name" , file_to )
     dot  = lastpos( ".", name )
     ext  = ""

     if dot > 0 then do
        ext  = substr( name, dot      )
        name = substr( name, 1, dot-1 )
     end

     if length( name ) > 8 then
        name = name"???"
     else do
        if length( name ) < 3 then
           name = substr( name, 1, 3, "!" )

        name = substr( name, 1, 5, "?" )
        name = substr( name, 1, 8, "?" )
     end

     file_to = SysTempFileName( path||name||ext )
  end

  if abbrev( "touch", touch, 1 ) then
     'copy "'replace(file_from,"%","%%")'" + ,, "'replace(file_to,"%","%%")'" 1> nul 2> nul'
  else
     'copy "'replace(file_from,"%","%%")'" "'replace(file_to,"%","%%")'" 1> nul 2> nul'

  if rc == 0 then
     call WpsDestroy file_from
  else
     file_to = ""

return file_to


/*------------------------------------------------------------------*/
/* Destroys the WPS object                                          */
WpsDestroy: procedure expose (exposelist)

  parse arg file

  if stream( file, "C", "QUERY EXISTS" ) \= "" then
     return SysDestroyObject( file )

return 1


/*------------------------------------------------------------------*/
/* Write a named ascii extended attribute to a file                 */
WpsPutEA: procedure expose (exposelist)

  parse arg file, name, ea_string
  ea = ""

  if pos( '00'x, ea_string ) > 0 then do
     do ea_count = 0 while length( ea_string ) > 0
       parse value ea_string with string '00'x ea_string
       ea = ea||'FDFF'x||,
            substr( reverse( d2c(length(string))), 1, 2, '00'x )||,
            string
     end
     ea = 'DFFF'x||'0000'x||,
          substr( reverse( d2c(ea_count)), 1, 2, '00'x )||ea
     end
  else
     ea = 'FDFF'x||,
          substr( reverse( d2c(length(ea_string))), 1, 2, '00'x )||,
          ea_string

return SysPutEA( file, name, ea )


/*------------------------------------------------------------------*/
/* Read a named ascii extended attribute from a file                */
WpsGetEA: procedure expose (exposelist)

  parse arg file, name

  if file == "" then return ""

  if SysGetEA( file, name, "ea" ) \= 0 then
     return ""

  ea_type   = substr( ea, 1, 2 )
  ea_string = ""

  select
    when ea_type == 'FDFF'x then
      ea_string = substr( ea, 5 )

    when ea_type == 'DFFF'x then do
      ea_count = c2d( reverse( substr( ea, 5, 2 )))
      say "count: "ea_count
      ea_pos   = 7
      do ea_count while substr( ea, ea_pos, 2 ) == 'FDFF'x
         ea_length = c2d( reverse( substr( ea, ea_pos+2, 2 )))
         ea_string = ea_string||substr( ea, ea_pos+4, ea_length )||'00'x
         ea_pos    = ea_pos + 4 + ea_length
      end
      end

    otherwise
  end

return ea_string


/*------------------------------------------------------------------*/
/* Refresh Folder                                                   */
WpsRefresh: procedure expose (exposelist)

  parse arg path

return SysSetObjectData( path, "MENUITEMSELECTED=503" )


/*------------------------------------------------------------------*/
/* Get filename from URL                                            */
GetFileFromURL: procedure expose (exposelist)

  /* generic-RL syntax consists of six components:           */
  /* <scheme>://<net_loc>/<path>;<params>?<query>#<fragment> */

  parse arg url
  url = strip(url)

  i = lastpos( "#", url )
  if i > 0 then url = substr( url, 1, i-1 )

  i = pos( ":", url )
  if i > 0 then url = substr( url, i+1 )

  if left(url,2) == "//" then do
     i = pos( "/", url, 3 )
     if i > 0 then
        url = substr( url, i )
     else
        url = ""
  end

  i = lastpos( "?", url )
  if i > 0 then url = substr( url, 1, i-1 )

  i = lastpos( ";", url )
  if i > 0 then url = substr( url, 1, i-1 )

  i = lastpos( "/", url )
  if i > 0 then url = substr( url, i+1 )

  if url == "" then url = "index.html"

return DecodeURL(url)


/*------------------------------------------------------------------*/
/* Decode URL                                                       */
DecodeURL: procedure expose (exposelist)

  parse arg url

  do while pos( "%", url ) > 0

     i = pos( "%", url )

     url = substr( url, 1, i-1      )||,
           x2c(substr( url, i+1, 2 ))||,
           substr( url, i+3         )
  end

return url


/*------------------------------------------------------------------*/
/* Search and replace string                                        */
replace: procedure expose (exposelist)

  parse arg source, string, substitute
  string = translate(string)

  i = pos( string, translate(source))

  do while i \= 0
     source = substr( source, 1, i-1 )||substitute||,
              substr( source, i+length(string))

     i = pos( string, translate(source), i + length(substitute))
  end

return source


/*------------------------------------------------------------------*/
/*------------------------------------------------------------------*/

/*------------------------------------------------------------------*/
/* awpralf_init()                                                   */
/* Gets called on events INIT, CONF and SEXE                        */
/* Returns: "ALRM ..." on error, otherwise "INFO ..."               */
awpralf_init: PROCEDURE expose (exposelist)

   rc = wlog( "awpralf_init started" ) /* debug */

   G!.sep  = d2c(255)
   G!.crlf = '0d0a'x
   G!.pmpoptitle = "awpralf AWGet plugin" /* title for pmpopup2.exe */
   G!.config_file = value( "ETC",, "OS2ENVIRONMENT" )"\awpralf.cfg"
   rc = wlog( "G!.config_file =" G!.config_file ) /* debug */

   aw_config_file = value( "ETC",, "OS2ENVIRONMENT" )"\awget.cfg"
   rc = wlog( "aw_config_file =" aw_config_file ) /* debug */

   /* read in .cfg */
   if stream( G!.config_file, "c", "QUERY EXIST" ) \= "" then
      do
         if awpralf_cfgread() \= 0 then
            do
               rc = send( "ALRM No options found in '"G!.config_file"'!" )
               return "ALRM So why are you using" G!.myname"?"
            end
      end
   else
      return "ALRM '"G!.config_file"' NOT FOUND!"

  /* read in some keys from awget.cfg */
  G!.use_desktop = ""
  G!.downloaddir = ""
  if stream( aw_config_file, "c", "QUERY EXIST" ) \= "" then
     do
        rc = wlog( aw_config_file "found." )
        rc = stream( aw_config_file, "C", G!.sysopen_read )
        do while lines( aw_config_file ) > 0
           parse value linein( aw_config_file ) with command "=" argument
           command  = translate( strip( command ) )
           argument = strip( argument )
           select
           when command == "USE_DESKTOP" then
              do
                 G!.use_desktop = (argument == "1")
                 rc = wlog( aw_config_file": USE_DESKTOP =" G!.use_desktop )
              end
           when command == "DOWNLOAD" then
              do
                 G!.downloaddir = strip( argument, "T", "\" )
                 rc = wlog( aw_config_file": DOWNLOAD =" G!.downloaddir )
              end
           otherwise
              nop
           end /* select */
           if G!.use_desktop \= "" & G!.downloaddir \= "" then
              leave /* fast reading cancel */
        end /* do while lines( aw_config_file ) > 0 */
        rc = stream( aw_config_file, "C", "CLOSE" )
     end /* if stream( aw_config_file, "c", "QUERY EXIST" ) \= "" */
   else
     rc = send( "EVNT '"aw_config_file"' not found!" )

   /* get dir of <WP_DESKTOP> (using AwGetObjectPath() from awget.dll) */
   /* if USE_DESKTOP = 1 */
   G!.desktopdir = ""
   if G!.use_desktop = 1 then
      do
         G!.desktopdir = AwGetObjectPath( "<WP_DESKTOP>" )
         if G!.desktopdir = "" then /* oops, not found */
            do
               G!.use_desktop = 0 /* don't use prescanning... */
               rc = send( "ALRM Path of <WP_DESKTOP> not found!" )
            end
         else
            rc = wlog( "<WP_DESKTOP> =" G!.desktopdir )
      end

   rc = wlog( "awpralf_init ended normally" )

return "INFO Plugin '"G!.myname"' initialized"


/*------------------------------------------------------------------*/
/* awpralf_cfgread()                                                */
/* Read in .cfg                                                     */
/* Returns: 0 on success, 255 on error                              */
awpralf_cfgread: procedure expose (exposelist)

  rc = wlog( "awpralf_cfgread started" )

  thisRC = 255

  G!.ext_download     = ""
  G!.obsolete_objects = ""
  G!.obsolete_ext     = ""
  G!.secure_ext       = ""
  G!.dupe_check       = 0

  rc = stream( G!.config_file, "C", G!.sysopen_read )

  do while lines( G!.config_file ) > 0

     thisline = strip( linein( G!.config_file ) )

     if thisline = "" | pos( "=", thisline ) < 1 | left( thisline, 1 ) = "#" then
        iterate

     parse var thisline key "=" argument

     key      = translate( strip( key ) )
     argument = strip( argument )

     select
     when key == "OBSOLETE_OBJECTS" then
        do
           G!.obsolete_objects = strip( argument, "T", "\" )
           thisRC = 0
           rc = wlog( "OBSOLETE_OBJECTS =" argument )
        end
     when key == "OBSOLETE_EXT" then
        do
           G!.obsolete_ext = ","||argument||","
           thisRC = 0
           rc = wlog( "OBSOLETE_EXT =" argument )
        end
     when key == "SECURE_EXT" then
        do
           G!.secure_ext = ","||argument||","
           thisRC = 0
           rc = wlog( "SECURE_EXT =" argument )
        end
     when key == "EXT_DOWNLOAD" then
        do
           if pos( ",", argument ) > 0 then
              do
                 parse var argument thisext "," thispath
                 G!.ext_download = G!.ext_download||strip( thisext )||,
                                   ","||strip( thispath )||G!.sep
                 if G!.ext_download \= "" then
                    thisRC = 0
              end
        end
     when key == "DUPE_CHECK" then
        do
           G!.dupe_check = argument
           rc = wlog( "DUPE_CHECK =" argument )
        end
     otherwise
        nop
     end  /* select */
  end /* do while lines( G!.config_file ) > 0 */

  rc = stream( G!.config_file, "C", "CLOSE" )

  rc = wlog( "EXT_DOWNLOAD =" G!.ext_download )

  rc = wlog( "awpralf_cfgread ended normally" )

return thisRC


/*------------------------------------------------------------------*/
/* awpralf_prescan()                                                */
/* Scan desktop, move URL-objects if necessary                      */
/* Returns: 0 on success, 255 on error, 1 if no files found         */
awpralf_prescan: PROCEDURE expose (exposelist)

   rc = wlog( "awpralf_prescan started" )

   if \DirExist( G!.obsolete_objects ) then /* OBSOLETE_OBJECTS not found */
      do
         rc = wlog( G!.obsolete_objects "not found" )
         rc = DirCreate( G!.obsolete_objects )
         rc = wlog( "DirCreate( "G!.obsolete_objects" ) RC="rc )
         if rc \= 0 then /* dir creation failed */
            do
               rc = send( "ALRM '"G!.obsolete_objects"' does not exist and "||,
                             "could not be created!" )
               return 255
            end /* if rc \= 0 */
         else /* change to WPUrlFolder */
            do
               address cmd ' @rd "'||G!.obsolete_objects||'"'
               rc = wlog( ' @rd "'||G!.obsolete_objects||'" RC='rc )
               web_folder_id = "<AWPRALF_OOBJECTS>"
               parse value reverse( G!.obsolete_objects ) with web_folder_title "\" web_folder_location
               web_folder_location = reverse( web_folder_location )
               web_folder_title = reverse( web_folder_title )
               setupstring =,
                     "DEFAULTVIEW=DETAILS;"||,
                     "DETAILSCLASS=WPUrl;"||,
                     "DETAILSTODISPLAY=0,1,9,10,12;"||,
                     "SHOWALLINTREEVIEW=YES;"||,
                     "SORTCLASS=WPUrl;"||,
                     "ALWAYSSORT=YES;"||,
                     "DEFAULTSORT=11;"||,
                     "OBJECTID="||web_folder_id||";"
               scorc = SysCreateObject(,
                     "WPURLFolder",,          /* Object type */
                     web_folder_title,,       /* Title */
                     web_folder_location,,    /* Location */
                     setupstring,,            /* Setup */
                     "U" )                    /* "Update" */
               rc = wlog( "SysCreateObject(...) RC="scorc )
               if scorc \= 1 then
                  do
                     rc = send( "EVNT Changing '"G!.obsolete_objects"' "||,
                                "to WPUrlFolder failed" )
                     rc = send( "EVNT SysCreateObject() RC =" scorc )
                  end /* if scorc \= 1 */
            end /* else */
      end /* if \DirExist( G!.obsolete_objects ) */

   sftrc = SysFileTree( G!.desktopdir||"\*" , 'desktop', 'FO' )
   rc = wlog( "SysFileTree( "G!.desktopdir"\* , 'desktop', 'FO' ) RC="sftrc )
   rc = wlog( "desktop.0 =" desktop.0 )

   if desktop.0 < 1 then /* no files found */
      do
         rc = wlog( "No files, returning with 1" )
         return 1
      end

   rc = wlog( desktop.0 "files found in" G!.desktopdir )
   do i = 1 to desktop.0
      if IsURLFile( desktop.i ) then
         do
            rc = send( "INFO File: '"desktop.i"'" )
            thisUrl = GetURLFromFile( desktop.i ) /* get URL */
            rc = send( "INFO URL: '"thisUrl"'" )

            /* get URL 'extension', upper case */
            UrlExt = ""
            parse value reverse( thisUrl ) with UrlExt "." .
            UrlExt = translate( reverse( UrlExt ) )

            /* get basename of URL object */
            parse value reverse( desktop.i ) with thisFilename "\" .
            thisFilename = reverse( thisFilename )

            select
            when right( thisUrl, 1 ) == "/" then
               do
                  rc = send( "INFO URL ends in '/'" )
                  rc = WpsMove( desktop.i, G!.obsolete_objects||"\"||thisFilename )
                  rc = send( "EVNT '"desktop.i"' moved to '"rc"'" )
               end
            when pos( ","||UrlExt||",", translate( G!.secure_ext ) ) > 0 then
               rc = send( "INFO '"UrlExt"' is a secure extension" )
            when pos( ","||UrlExt||",", translate( G!.obsolete_ext ) ) > 0 then
               do
                  rc = send( "INFO '"UrlExt"' is a obsolete extension" )
                  rc = WpsMove( desktop.i, G!.obsolete_objects||"\"||thisFilename )
                  rc = send( "EVNT '"desktop.i"' moved to '"rc"'" )
               end
            otherwise
               do
                  address cmd G!.awgethome||'\pmpopup2.exe ',
                              '"Download~'thisUrl'?" ',
                              '"'||G!.pmpoptitle||'" ',
                              '/B1:"~Yes" ',
                              '/B2:"~No" ',
                              '/F:"8.Helv" ',
                              '/A:C ',
                              '/SM'
                  if rc = 20 then
                     do
                        rc = WpsMove( desktop.i, G!.obsolete_objects||"\"||thisFilename )
                        rc = send( "EVNT '"desktop.i"' moved to '"rc"' on user request" )
                     end
               end /* otherwise */
            end /* select */
         end /* if IsURLFile( desktop.i ) */
      else
         rc = wlog( "File" desktop.i "is no URL-file" )
   end i /* do i = 1 to desktop.0 */

   rc = wlog( "awpralf_prescan ended normally" )

return 0


/*------------------------------------------------------------------*/
/* awpralf_ext_download( jobfile )                                  */
/* Replaces dwonload directory in jobfile when necessary            */
/* and checks for dupes                                             */
/* Returns: string to display by awget                              */
awpralf_ext_download: PROCEDURE expose (exposelist)

   rc = wlog( "awpralf_ext_download started" )

   parse arg jobfile

   rc = wlog( "jobfile =" jobfile )

   if stream( jobfile, "c", "query exist" ) == "" then
      return "ALRM Jobfile '"jobfile"' not found!"

   rc = wlog( "Reading jobfile" )
   call JobRead jobfile /* Read in jobfile */

   rc = wlog( "Calling GetFileFromURL( "job.url" )" )
   filename = GetFileFromURL( job.url ) /* get the filename */
   rc = wlog( "Filename from URL =" filename )

   /* get the extension of filename */
   parse value reverse( filename ) with url_ext "." .
   url_ext = translate( reverse( url_ext ) )

   if pos( ".", filename ) < 1 | url_ext == "" then
      rc = send( "INFO URL has no 'extension'" )
   else
      do
         /* find extension/path in EXT_DOWNLOAD */
         extlist = G!.ext_download
         do while extlist \= ""
            ext_from_list = ""
            dir_from_list = ""
            found_ext = ""
            parse var extlist ext_from_list "," dir_from_list (G!.sep) extlist
            ext_from_list = translate( strip( ext_from_list ) )
            dir_from_list = strip( dir_from_list )
            if ext_from_list == url_ext & dir_from_list \= "" then
               do
                  found_ext = ext_from_list
                  leave
               end
         end /* do while extlist \= "" */

         if found_ext = "" then /* no match */
            rc = send( "INFO '"url_ext"' not known, "||,
                 "using standard download directory" )
         else /* get/create new download path */
            do
               rc = wlog( "Ext '"url_ext"' found in G!.ext_download" )
               dir_from_list = strip( dir_from_list )
               if pos( ":\", dir_from_list ) < 1 then /* relative path */
                  job.download = G!.downloaddir||"\"||dir_from_list
               else
                  job.download = dir_from_list

               rc = send( "INFO New download directory: '"job.download"'" )

               if \DirExist( job.download ) then
                  do
                     rc = wlog( job.download "does not exist" )
                     rc = DirCreate( job.download )
                     if rc \= 0 then
                        return "ALRM '"job.download"' does not exist and "||,
                               "could NOT be created!"
                     else
                        rc = wlog( job.download "created" )
                  end

               call JobSave jobfile /* save new download dir */

            end /* else */

      end /* else */

   rc = wlog( "awpralf_ext_download ended normally" )

return "INFO URL will be saved to '"job.download"'"


/*------------------------------------------------------------------*/
/* awpralf_dupecheck( jobfile )                                     */
/* checks for dupes before awget downloads URL                      */
/* Returns: string to display by awget                              */
awpralf_dupecheck: PROCEDURE expose (exposelist)

   rc = wlog( "awpralf_dupecheck started" )

   rc = send( "INFO Beginning dupecheck" )

   parse arg jobfile

   rc = wlog( "jobfile =" jobfile )

   if stream( jobfile, "c", "query exist" ) == "" then
      return "ALRM Jobfile '"jobfile"' not found!"

   rc = wlog( "Reading jobfile" )
   call JobRead jobfile /* Read in jobfile */

   rc = wlog( "Calling GetFileFromURL( "job.url" )" )
   filename = GetFileFromURL( job.url ) /* get the filename */
   rc = wlog( "Filename from URL =" filename )

   fullname = job.download||'\'||filename

   if stream( fullname, "c", "query exist" ) = "" then /* found no dupe */
      return "INFO No dupe found"

   thisRC = "INFO Dupecheck ended"

   rc = send( "INFO '"fullname"' already exists" )

   /* get a backup-name */
   rc = wlog( "Finding new name" )
   nameloop = 1
   ph = '_AWGetBkp_' /* backup name */
   if pos( '.', filename) > 0 then /* split at "." */
      do
         Parse Value Reverse( filename ) With fileExt '.' fileBase
         fileExt = reverse( fileExt )
         fileBase = reverse( fileBase )
         newfilename = fileBase||ph||nameloop||'.'||fileExt
         do while stream( job.download||'\'||newfilename, "c", "query exist" ) \= ""
            nameloop = nameloop + 1
            newfilename = fileBase||ph||nameloop||'.'||fileExt
         end /* do */
      end
   else
      do
         newfilename = filename||ph||nameloop
         do while stream( job.download||'\'||newfilename, "c", "query exist" ) \= ""
            nameloop = nameloop + 1
            newfilename = filename||ph||nameloop
         end /* do */
      end /* else */
   newfullname = job.download||'\'||newfilename
   rc = wlog( "New full name =" newfullname )

   /* if any URL already stored -> seek matching URLs */
   thisUrlcnt = 0
   if urlcnt > 0 then
      do i = 1 to urlcnt
         if job.url == myURL.urlcnt then /* matched! */
            do
               thisUrlcnt = i /* cnt of matching URL */
               leave i /* leave loop on match */
            end
      end i /* do */

   pmprc = 0 /* pmpopup2-returncode: */
             /* 10 = "continue" */
             /* 20 = "from scratch" */
             /* 30 = "cancel" */

   if thisUrlcnt > 0 then /* if a stored URL matched */
      do                  /* -> check for stored option */
         select
         when myURLOpt.thisUrlcnt == "SCRA" then
            do
               pmprc = 20 /* "from scratch" */
               rc = send( "INFO Dupe option already set: begin download from scratch" )
            end
         when myURLOpt.thisUrlcnt == "CONT" then
            do
               pmprc = 10 /* "continue" */
               rc = send( "INFO Dupe option already set: continue download" )
            end
         when myURLOpt.thisUrlcnt == "CANC" then
            do
               pmprc = 30 /* "cancel" */
               rc = send( "INFO Dupe option already set: cancel download" )
            end
         otherwise
            nop
         end /* select */
      end /* if thisUrlcnt > 0 */
   else /* no match -> new URL-entry */
      do
         urlcnt = urlcnt + 1
         thisUrlcnt = urlcnt
         myURL.urlcnt = job.url
         rc = wlog( "URL no." urlcnt "stored:" myURL.urlcnt )
      end /* else */

   rc = wlog( "pmprc before pmpopup2 =" pmprc )

   if pmprc < 10 | pmprc > 30 then
      do
         /* ask user */
         address cmd G!.awgethome||'\pmpopup2.exe ',
                   '"~'||filename||'~exists!" ',
                   '"'||G!.pmpoptitle||'" ',
                   '/B1:"~Continue" ',
                   '/B2:"~From scratch" ',
                   '/B3:"~Cancel" ',
                   '/F:"8.Helv" ',
                   '/A:C ',
                   '/SM'
         pmprc = rc
      end

   rc = wlog( "pmprc after pmpopup2 =" pmprc )

   select
   when pmprc = 20 then /* "from scratch" */
      do
         myURLOpt.thisUrlcnt = "SCRA"
         rc = send( "EVNT Moving: '"fullname"'" )
         rc = send( "EVNT      => '"newfullname"'" )
         address cmd ' @copy "'||fullname||'" "'||newfullname||'"'
         if rc \= 0 then
            thisRC = "ALRM Copy failed, RC =" rc
         else
            address cmd ' @del "'||fullname||'" /F'
      end
   when pmprc = 10 then /* "continue" */
      do
         myURLOpt.thisUrlcnt = "CONT"
         rc = send( "EVNT Copying: '"fullname"'" )
         rc = send( "EVNT       => '"newfullname"'" )
         address cmd ' @copy "'||fullname||'" "'||newfullname||'"'
         if rc \= 0 then
            thisRC =  "ALRM Copy failed, RC =" rc
      end
   when pmprc = 30 then /* "cancel" */
      do
         address cmd ' @del "'||job.object||'" /F'
         job.object = ""
         call JobSave jobfile
         myURLOpt.thisUrlcnt = "CANC"
         thisRC = "EVNT Job cancelled by user via '"G!.myname"'"
      end
   otherwise /* error with pmprc */
      do
         rc = send( "ALRM Error with pmprc, pmprc="pmprc||,
                       " (should be 10, 20 or 30)" )
         rc = send( "EVNT Copying: '"fullname"'" )
         rc = send( "EVNT       => '"newfullname"'" )
         address cmd ' @copy "'||fullname||'" "'||newfullname||'"'
      end
   end /* select */

   rc = wlog( "awpralf_dupecheck ended normally" )

return thisRC


/*------------------------------------------------------------------*/
/* send( string )                                                   */
/* Sends a string to awget daemon process and writes string to      */
/* debuglog if G!.debug == 1                                        */
send: PROCEDURE expose (exposelist)

   parse arg strg

   if G!.debug == 1 then
      rc = wlog( "==>" strg )

   call lineout, strg

return 0


/*------------------------------------------------------------------*/
/* wlog( string )                                                   */
/* Writes string to debuglog if G!.debug == 1                       */
wlog: PROCEDURE expose (exposelist)

   parse arg strg

   if G!.debug \= 1 then return 1

   do while stream( debuglog, "c", G!.sysopen_write ) \= "READY:"
      call syssleep 1
   end
   call lineout debuglog, date() time()":" strg
   rc = stream( debuglog, "c", "close" )

return 0


/* Copyright (C) 2001 Dmitry A.Steklenev
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgment:
 *    "This product includes software developed by Dmitry A.Steklenev".
 *
 * 4. Redistributions of any form whatsoever must retain the following
 *    acknowledgment:
 *    "This product includes software developed by Dmitry A.Steklenev".
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR OR CONTRIBUTORS "AS IS"
 * AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * AUTHOR OR THE CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

