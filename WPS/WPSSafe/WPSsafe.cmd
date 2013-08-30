@echo off
SetLocal
If (%1) == () Goto Help

Rem Env Var Name Usage/meaning                   Author's settings
Rem ------------ ------------------------------- -------------------------
Rem 'DeskVol'    The WPS desktop volume.         f:
Rem 'Desktop'    The WPS desktop directory root. f:/Desktop/*
Rem 'BootVol'    The OS/2 boot volume.           e:
Rem 'SafeDir'    The safe target directory.      f:\Tahko\
Rem 'DesktopTar' The TAR file name for desktop.  f:\Tahko\Desktop.%1.tar
Rem 'SourceINIs' The two main INI files to copy. e:\OS2\OS2???.ini
Rem 'TargetINIs' Target name for the two INIs.   f:\Tahko\OS2???.ini.%1

Rem Note: Only the 4 first environment variables below need
Rem       to be modified for succesful operation of WPSsafe.
Rem
Set DeskVol=f:
Set Desktop=%DeskVol%/Desktop/*
Set BootVol=e:
Set SafeDir=f:\Tahko\

Rem ...no need to modify these three...
Set DesktopTar=%SafeDir%Desktop.%1.tar
Set SourceINIs=%BootVol%\OS2\OS2???.ini
Set TargetINIs=%SafeDir%OS2???.ini.%1

If (%2) == (!) Goto RESTORE

:BACKUP
Tar -cppvf %DesktopTar% %Desktop%
Copy %SourceINIs% %TargetINIs% /v
Goto End

:RESTORE
Rem  Here the source and target _seem_
Rem  to be the wrong way. They are not.
%DeskVol%
cd\
Tar -xppvf %DesktopTar%
Copy %TargetINIs% %SourceINIs% /v
Goto End

:Help
Echo.
Echo WPSsafe.cmd - Backup/restore WPS desktop and INI files.  Requires GTAK!
Echo Release 1 of 17-Sep-93
Echo Localized for Kari Mattsson on 17-Sep-93.
Echo Copyright (c) 1993 Kari Mattsson. Released for Public Domain.
Echo.
Echo usage: WPSsafe {yymmdd} [!]
Echo.
Echo Note:  The option '!' restores the desktop and ini files.
Echo        See WPSsafe.txt for limitation on the restoration.

:End
EndLocal
