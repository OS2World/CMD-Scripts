/* This Rexx program creates a set of sample folder setup
   program objects that call recurse.cmd.  It must
   be passed one argument that contains the fully qualified path
   of recurse.cmd
*/
if (length(arg(1)) = 0) then
do
  SAY 'Please read Recurse.inf for info on how to install'
  exit
end

call RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
call SysLoadFuncs

exename = word(arg(1),1)
objsettings = 'EXENAME='exename';PROGTYPE=WINDOWABLEVIO;MINIMIZED=YES;'
objsettings = objsettings'NOAUTOCLOSE=NO^;ICONFILE=RECURSE.ICO'
folder='<RECURSE_FOLDER_SAMPLES>'
cr=x2c(A)

/* Create the folder on the desktop */
folderSetup = 'DEFAULTVIEW=ICON;ALWAYSSORT=YES;OBJECTID='folder
rc = SysCreateObject('WpFolder', 'Folder Setup Samples', '<WP_DESKTOP>',folderSetup, 'replace')

objsettings=objsettings";DEFAULTVIEW=SETTINGS"
/***************************************************************************/
/*  Create The Template                                                    */
/***************************************************************************/
title = 'Recursive Setting'cr'Template'
setup=objsettings";PARAMETERS=%* <put setting here>;TEMPLATE=YES"
rc = SysCreateObject('WpProgram', title, folder, setup, 'replace')

/***************************************************************************/
/*  Create Default View Objects                                            */
/***************************************************************************/
title = 'Default View Settings'
thisFolder='<RECURSE_SAMPLES_DEFAULT_VIEW>'
folderSetup = 'DEFAULTVIEW=ICON;ALWAYSSORT=YES;OBJECTID='thisFolder
rc = SysCreateObject('WpFolder', title, folder, folderSetup, 'replace')

title = 'Set Default View to'cr'Details View'
setup=objsettings";PARAMETERS=%* DEFAULTVIEW=DETAILS"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Default View to'cr'Icon View'
setup=objsettings";PARAMETERS=%* DEFAULTVIEW=ICON"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Default View to'cr'Tree View'
setup=objsettings";PARAMETERS=%* DEFAULTVIEW=TREE"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Default View to'cr'Default'
setup=objsettings";PARAMETERS=%* DEFAULTVIEW=DEFAULT"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

/***************************************************************************/
/*  Create View Setting Objects                                            */
/***************************************************************************/
title = 'View Settings'
thisFolder='<RECURSE_SAMPLES_VIEW>'
folderSetup = 'DEFAULTVIEW=ICON;ALWAYSSORT=YES;OBJECTID='thisFolder
rc = SysCreateObject('WpFolder', title, folder, folderSetup, 'replace')

title = 'Set Icon View to'cr'Mini Icons'
setup=objsettings";PARAMETERS=%* ICONVIEW=MINI"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Icon View to'cr'Normal Icons'
setup=objsettings";PARAMETERS=%* ICONVIEW=NORMAL"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Tree View to'cr'Mini Icons'
setup=objsettings";PARAMETERS=%* TREEVIEW=MINI"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Tree View to'cr'Normal Icons'
setup=objsettings";PARAMETERS=%* TREEVIEW=NORMAL"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Details View to'cr'Mini Icons'
setup=objsettings";PARAMETERS=%* DETAILSVIEW=MINI"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Details View to'cr'Normal Icons'
setup=objsettings";PARAMETERS=%* DETAILSVIEW=NORMAL"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set All Views to'cr'Mini Icons'
setup=objsettings";PARAMETERS=%* ICONVIEW=MINI^;TREEVIEW=MINI^;DETAILSVIEW=MINI"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set All Views to'cr'Normal Icons'
setup=objsettings";PARAMETERS=%* ICONVIEW=NORMAL^;TREEVIEW=NORMAL^;DETAILSVIEW=NORMAL"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set All Views to'cr'Default Icons'
setup=objsettings";PARAMETERS=%* ICONVIEW=DEFAULT^;TREEVIEW=DEFAULT^;DETAILSVIEW=DEFAULT"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

/***************************************************************************/
/*  Create Background Setting Objects                                      */
/***************************************************************************/
title = 'Background Settings'
thisFolder='<RECURSE_SAMPLES_BACKGROUND>'
folderSetup = 'DEFAULTVIEW=ICON;ALWAYSSORT=YES;OBJECTID='thisFolder
rc = SysCreateObject('WpFolder', title, folder, folderSetup, 'replace')

title = 'Set Red Background'
setup=objsettings";PARAMETERS=%* BACKGROUND=(none),,,C,128 0 0"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Green Background'
setup=objsettings";PARAMETERS=%* BACKGROUND=(none),,,C,0 128 0"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Blue Background'
setup=objsettings";PARAMETERS=%* BACKGROUND=(none),,,C,0 0 128"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set White Background'
setup=objsettings";PARAMETERS=%* BACKGROUND=(none),,,C,255 255 255"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

/* Try and figure out the boot drive by looking at an environment
   variable.  This won't always work, but there aren't likely many
   machines where this has been fiddled with
*/
env = 'OS2ENVIRONMENT'
bootDrive = left(VALUE('SYSTEM_INI',,env),2)


title = 'Set Wood Background'
setup=objsettings";PARAMETERS=%* BACKGROUND="bootDrive"\os2\bitmap\wood.bmp,T,1,I"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

/***************************************************************************/
/*  Create Font Objects                                                    */
/***************************************************************************/
title = 'Font Settings'
thisFolder='<RECURSE_SAMPLES_FONTS>'
folderSetup = 'DEFAULTVIEW=ICON;ALWAYSSORT=YES;OBJECTID='thisFolder
rc = SysCreateObject('WpFolder', title, folder, folderSetup, 'replace')

title = 'Set Icon Font To'cr'12 Pt Helv'
setup=objsettings";PARAMETERS=%* ICONFONT=12.Helv"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Icon Font To'cr'12 Pt Helv Bold'
setup=objsettings";PARAMETERS=%* ICONFONT=12.Helv.Bold"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Icon Font To'cr'Default'
setup=objsettings";PARAMETERS=%* ICONFONT=Default"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Tree Font To'cr'12 Pt Helv'
setup=objsettings";PARAMETERS=%* TREEFONT=12.Helv"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Tree Font To'cr'12 Pt Helv Bold'
setup=objsettings";PARAMETERS=%* TREEFONT=12.Helv.Bold"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Tree Font To'cr'Default'
setup=objsettings";PARAMETERS=%* TREEFONT=Default"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Details Font To'cr'12 Pt Helv'
setup=objsettings";PARAMETERS=%* DETAILSFONT=12.Helv"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Details Font To'cr'12 Pt Helv Bold'
setup=objsettings";PARAMETERS=%* DETAILSFONT=12.Helv.Bold"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Details Font To'cr'Default'
setup=objsettings";PARAMETERS=%* DETAILSFONT=Default"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

/***************************************************************************/
/*  Create Complex Setup Objects                                           */
/***************************************************************************/
title = 'Complex Setup Objects'
thisFolder='<RECURSE_SAMPLES_COMPLEX>'
folderSetup = 'DEFAULTVIEW=ICON;ALWAYSSORT=YES;OBJECTID='thisFolder
rc = SysCreateObject('WpFolder', title, folder, folderSetup, 'replace')

title = 'Set Wood Background, Default Details View,'cr'Large Icons, Always Sort'cr'8 Pt. Italic Helv Font'
setup=objsettings";PARAMETERS=%* BACKGROUND="bootDrive"\os2\bitmap\wood.bmp,T,1,I^;"
setup=setup"DEFAULTVIEW=DETAILS^;DETAILSVIEW=NORMAL^;ALWAYSSORT=YES^;DETAILSFONT=8.Helv.Italic"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')

title = 'Set Default Background, Default Icon View'cr'Always Sort, Invisible Icons,'cr'Flowed View'
setup=objsettings";PARAMETERS=%* BACKGROUND=default^;DEFAULTVIEW=ICON^;"
setup=setup"ALWAYSSORT=YES^;ICONVIEW=INVISIBLE^,FLOWED"
rc = SysCreateObject('WpProgram', title, thisFolder, setup, 'replace')


