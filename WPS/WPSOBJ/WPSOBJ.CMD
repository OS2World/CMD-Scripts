/*******************************************************************/
/*** Rexx Exec for Creating a new WPS Object  -  By Tony Nadalin ***/
/*******************************************************************/
trace 'o'
parse arg WPSClass WPSLocation  WPSName

if WPSClass = '?' | WPSClass = '' then
  do
    Say 'WPSOBJ class_name location object_name'
    Say ''
    Say 'Valid class names are: WPClock, WPCountry, WPKeyboard, WPMouse'
    Say '    WPPalette,  WPPrinter,  WPProgram,  WPShadow,   WPShredder'
    Say '    WPSound, WPSpecialNeeds, WPSPooler, WPSystem, WPFileSystem'
    Say '    WPDataFile,    WPInstall,  WPFolder,   WPDesktop,   WPDisk'
    Say '    WPStartup, WPTemplates, WPDrives'
    Say ''
    Say 'Valid locations are:  WP_NOWHERE, WP_DESKTOP, WP_OS2SYS'
    Say '       WP_TEMPS,WP_CONFIG, WP_START, WP_INFO, WP_DRIVES'
    exit
  end

call RxFuncadd 'SysLoadFuncs','RexxUtil','SysloadFuncs'
call SysLoadFuncs
call SysRegisterObjectClass WPSClass, 'PMWP'
call SysCreateObject WPSClass, WPSName, '<'||WPSLocation||'>'
Exit
