/* INSTALL.CMD - Create WPS object for Links browser */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

location=DIRECTORY()
say location
ret = SysCreateObject('WPProgram', 'Links', '<WP_DESKTOP>', 'OBJECTID=<Links_Program>;EXENAME='location'\linksWPS.cmd;STARTUPDIR='location';ASSOCFILTER=*.htm,*.html,*.url;ASSOCTYPE=HTML,text/html,UniformResourceLocator,WebExplorer_Url;', 'R')
