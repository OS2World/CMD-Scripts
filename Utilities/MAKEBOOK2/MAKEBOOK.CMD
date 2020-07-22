/* 
        REXX utility that will search all available drives for OS/2 Online Reference Manuals (.INF files)
        MAKEBOOK.CMD
        Version 1.02
        By: Derek Berube

        03.16.93 v1.00
             *  Initial Release
        07.07.93 v1.01
             *  Fixed a problem with parameters field of the object that is created.  The drive on which the
                .INF file resides is not included in the parameters section; therefore, when you go to look at the
                book, you get an error that "Cannot open input files."
        07.27.93 v1.02
             *  Fixed a problem with Express setup option (it wouldn't recognize a capital letter 'Y').  The express
                setup option will no longer echo the option you choose to the screen.
*/
call RxFuncAdd "SysLoadFuncs","RexxUtil","SysLoadFuncs"
call SysLoadFuncs

/* Global Variable Declaration */
        bootdrive = Substr(Value('PATH',,'OS2ENVIRONMENT'),Pos('\OS2\SYSTEM',Value('PATH',,'OS2ENVIRONMENT'))-2,2)
        NADA=" is not an OS/2 on-line book"
        VERSION='1.02'
        VERSIONDATE='07.27.93'
/* End of Global Variable Declaration */

call SysCls
Title:
Say
Say "OS/2 Online Reference Manual Icon Creator - Version "VERSION
Say "By Derek Berube "VERSIONDATE

ExpressYN:
Say "Express Setup (Y/N) ?"
Express=SysGetKey('NOECHO')
Select
   when Express="y" then Express="Y"
   when Express="n" then Express="N"
   when Express="Y" then Express="Y"
   when Express="N" then Express="N"
otherwise Signal ExpressYN
end  /* select */
Say
Say "Searching the fixed disk for OS/2 Online reference manuals"

/* The following line searches the fixed disk for all .INF files and stores the path and filename
 * information in the file matrix.  file.0 is a numerical value  giving the total number of elements
 * in the array. */
/****************************************/
/* Get Drive Information                           */
/* DriveInfo    - stem to store drive information */
/* DriveInfo.0  - number of drives present        */
/* DriveInfo.1..x - drive letters present           */
/****************************************/
/* Get the number of drives on the system */
        Result=SysDriveMap()
        DriveInfo.0=Trunc(length(Result)/3)+1
do temp=1 to DriveInfo.0
   X=pos(':',Result)                        /* Get position of end of 1st drive */
   Y=length(Result)-X                     /* Get length from end of 1st drive to end of Result */
   DriveInfo.temp=DELSTR(Result,x,y)    /* Assign drive letter to DriveInfo */
   Result=DELSTR(Result,1,3)            /* Parse the Result variable */
end /* end do */

do temp=1 to DriveInfo.0
 call SysFileTree driveinfo.temp"\*.INF","file","FSO"
/* Once all the files are found, the following procedure creates the icons in a folder called "MAKEBOOK.CMD - Find Results" */
if file.0 >0 then
 do  
 Say "Making icons for online books found on drive "DriveInfo.temp"..."
 rc=SysCreateObject("WPFolder","MAKEBOOK.CMD - Find Results","<WP_DESKTOP>","OBJECTID=<MAKEBOOK>;")
    do i=1 to file.0
      file.i=Translate(file.i)
      BookName=SUBSTR(file.i,LASTPOS("\",file.i)+1)     /* This line strips the path from the OS/2 file.i string and stores thename of the INF in BookName */
/* This section will assign names to know .INF files */
      Select
         when BookName="A3ALANOR.INF" then BookName="OS/2 LAN Online Reference (Administrator)"
         when BookName="A3ALANCR.INF" then BookName="OS/2 LAN Online Reference (Commands)"
         when BookName="BBSFILES.INF" then BookName="IBM NSC BBS Files Available for Download"
         when BookName="BBSLIST.INF" then BookName="The IBM PCC Bulliten Board File Listing"
         when BookName="BM2IPF.INF" then BookName="BM2IPF User's Guide"
         when BookName="BMHLP03.INF" then BookName="BackMaster On-line Help"
         when BookName="CMCMDREF.INF" then BookName="CM/2 Command Reference"
         when BookName="CMDREF.INF" then BookName="OS/2 Command Reference"
         when BookName="CMMSGREF.INF" then BookName="CM/2 Message Reference"
         when BookName="CONTACT.INF" then BookName="Contact List for Help Desk"
         when BookName="CYBERLNK.INF" then BookName="CyberLink"
         when BookName="CYBERTIP.INF" then BookName="CyberTips"
         when BookName="DBMSG.INF" then BookName="Database Manager Messages"
         when BookName="DRM.INF" then BookName="DRM Technical and Warranty Support Plan"
         when BookName="GAMMA.INF" then BookName="Gamma Tech Utilities"
         when BookName="GG243730.INF" then BookName="OS/2 Redbook: Volume 1 Control Program"
         when BookName="GG243731.INF" then BookName="OS/2 Redbook: Volume 2 DOS and Windows Settings"
         when BookName="GG243732.INF" then BookName="OS/2 Redbook: Volume 3 PM and Workplace Shell"
         when BookName="GG243774.INF" then BookName="OS/2 Redbook: Volume 4 Application Development"
         when BookName="GUIREF20.INF" then BookName="Control Program Reference"
         when BookName="HELPTIPS.INF" then BookName="HelpCenter Tips and Techniques"
         when BookName="HLYGRAIL.INF" then BookName="Monty Python and The Holy Grail"
         when BookName="HUMOR.INF" then BookName="Humor In Support"
         when BookName="INEWS001.INF" then BookName="Idle News No.1 July 1991"
         when BookName="IPF.INF" then BookName="Information Presentation Facility Sample"
         when BookName="IPFC20.INF" then BookName="IPFC Reference"
         when BookName="IPFCEXMP.INF" then BookName="IPFC Examples"
         when BookName="KILLER4.INF" then BookName="Help for Killer4 Program (BUFFER)"
         when BookName="LOADRAM2.INF" then BookName="LoadRAM User's Guide"
         when BookName="MCIREXX.INF" then BookName="MultiMedia REXX"
         when BookName="MEMORY.INF" then BookName="Blake Payne's Memory Management Handbook"
         when BookName="NSCBOOKS.INF" then BookName="Technical Support Group On-Line Books"
         when BookName="NSCDATA.INF" then BookName="NSC Database"
         when BookName="NSCPROC.INF" then BookName="NSC Procedures Reference"
         when BookName="OPSYSREF.INF" then BookName="Operating Systems Reference and Tutorial"
         when BookName="OPSYSTRN.INF" then BookName="Operating Systems Training Manual"
         when BookName="OS2TECHG.INF" then BookName="A Technical Guide to OS/2 2.0"
         when BookName="OS2TNT.INF" then BookName="OS/2 Tips and Techniques"
         when BookName="OVERVIEW.INF" then BookName="CM/2 Overview"
         when BookName="PHONE.INF" then BookName="Phone List"
         when BookName="PKZIP.INF" then BookName="PKZip Reference Manual"
         when BookName="PMCOMM.INF" then BookName="PM Comm User's Guide"
         when BookName="PMFUN.INF" then BookName="PM Reference"
         when BookName="PMGPI.INF" then BookName="PM Reference: Graphics Functions"
         when BookName="PMHOK.INF" then BookName="PM Reference: Graphics Orders"
         when BookName="PMMSG.INF" then BookName="PM Reference: Message Processing"
         when BookName="PMREL.INF" then BookName="PM Reference: Miscellaneous Reference"
         when BookName="PMWIN.INF" then BookName="PM Reference: Window Functions"
         when BookName="PMWKP.INF" then BookName="PM Reference: Workplace"
         when BookName="PS2A_GEN.INF" then BookName="IBM PS General Assistant"
         when BookName="PS2A_MKT.INF" then BookName="IBM PS Marketing Assistant"
         when BookName="PS2A_SVC.INF" then BookName="IBM PS Service Assistant"
         when BookName="PS2A_TEC.INF" then BookName="IBM PS Technical Assistant"
         when BookName="PS1A_TSP.INF" then BookName="IBM PS Tech Specs Assistant #1"
         when BookName="PS2A_TSP.INF" then BookName="IBM PS Tech Specs Assistant #2"
         when BookName="PS2A_TTL.INF" then BookName="PS/2 Assistant"
         when BookName="REXX.INF" then BookName="REXX Information"
         when BookName="REXXAPI.INF" then BookName="REXX Program Reference"
         when BookName="REXXEA.INF" then BookName="Extended Attribute functions for REXX"
         when BookName="ROISTUB.INF" then BookName="OS/2 LAN Online Reference"
         when BookNAme="SCENARIO.INF" then BookName="Call Scenario for Socrates Help Desk"
         when BookName="SOM.INF" then BookName="System Object Model (SOM) Reference"
         when BookName="TOOLINFO.INF" then BookName="Tools Reference"
         when BookName="TRAPIPF.INF" then BookName="Trap Error Guide"
         when BookName="TREKLIST.INF" then BookName="Star Trek: The Original Episodes"
         when BookName="VREXX.INF" then BookName="Visual Rexx"
         when BookName="WHYOS2.INF" then BookName="Why OS/2 2.0"
      otherwise BookName=BookName
      end  /* select */
      Select
/* The following lines are files that I know which are not OS/2 Online Books */
         when BookName="APPS.INF" then BookName="APPS.INF"NADA
         when BookName="CONTROL.INF" then Say "CONTROL.INF"NADA
         when BookName="DRVMAP.INF" then Say "DRVMAP.INF"NADA
         when BookName="INSTDOS.INF" then Say "INSTDOS.INF"NADA
         when BookName="OEMSETUP.INF" then Say "OEMSETUP.INF"NADA
         when BookName="OEM0.INF" then Say "OEM0.INF"NADA
         when BookName="PMCONTRL.INF" then Say "PMCONTRL.INF"NADA
         when BookName="PMSETUP.INF" then Say "PMSETUP.INF"NADA
         when BookName="SETUP.INF" then Say "SETUP.INF"NADA
         when BookName="TRIST100.INF" then Say "TRIST100.INF "NADA
         when BookName="WWORD20.INF" then Say "WWORD20.INF is a Microsoft Word for Windows INF."
      otherwise
      do
         If Express="Y" then rc=SysCreateObject("WPProgram",""BookName"","<MAKEBOOK>","EXENAME=VIEW.EXE;PARAMETERS="file.i";STARTUPDIR=\OS2\BOOK;")
         else
         do
            Say
            Say "Working with "BookName"."
            Say "What do you want to call this book [ENTER keeps same name] ? "
            PULL BookTitle
            If BookTitle=" " then BookTitle=BookName
            rc=SysCreateObject("WPProgram",""BookTitle"","<MAKEBOOK>","EXENAME=VIEW.EXE;PARAMETERS=DriveInfo.temp"file.i";STARTUPDIR=\OS2\BOOK;")
         end /* do */
      end /* do */
      end /* select */
    end /* do */
 end /* do */
else Say "No files found on drive "DriveInfo.temp" to set up! "
end /* do - this one is overall loop for different drives found */
Say
Say "Je suis fini!"

