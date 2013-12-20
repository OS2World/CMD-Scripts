mode 80,80
rem *************************************************************************************                             
rem UPSSV: Firefox-3-0-Start-with-Lock-File-Handling-Template.cmd
rem Copyright 2008 Rainer D. Stroebel 
rem *************************************************************************************
rem  
rem
rem External:
rem  env var                   : Firefox_UPSSV_Get_Options_Proc            
rem
rem  UPSSV_Get_Options_Proc    =%UPSSV_Inst_Path%\UPSSV-Inst-<SysID>-<User-ID>-INI.cmd 
rem  File_Blank_Line           =%UPSSV_Inst_Path%\UPSSV-Subx-Leerzeile.txt
rem  CAFFC_CMD                 =%UPSSV_Inst_Path%\UPSSV-Subx-Create-Append-File-with-Timestamp-as-Contents.cmd
rem 
rem  Version 
rem  1.0.0  2008-07-11  Creation of Template for Locking current access   
rem  1.0.1  2008-07-19  Make use of UPSSV_Get_Options_Proc        
rem  1.0.2  2008-07-31  Firefox crach.log
rem  1.0.3  2008-08-03  Get the value for Firefox_UPSSV_Get_Options_Proc for WPS 
rem
rem *********************************************************************************
rem  The value of the env var "Firefox_Mode_UPSSV_Get_Options_Proc" is set by
rem  the WPS Program Object for the Firefox Start Procedure   
rem *********************************************************************************

    set UPSSV_Get_Options_Proc=%Firefox_UPSSV_Get_Options_Proc%

rem -----------------------------------------------------------------------------------------------
rem *** Get the parameter/options defined at the installation customizing step by the installer ***
rem -----------------------------------------------------------------------------------------------
rem
    call %UPSSV_Get_Options_Proc% 
rem
rem ----------------------------------------------
rem *** example values from UPSSV Custiomizing ***
rem ----------------------------------------------
rem  
rem   UPSSV_Cus_Inst_Path=s:\UPSSV-V-1-0
rem   UPSSV_Cus_MOZILLA_DRIVE=S:
rem   UPSSV_Cus_MOZILLA_DIR=MoF-3000
rem   UPSSV_Cus_File_Name_Prefix=MoF-3000-Pref
rem   MoF_Lock_File=s:\MoF-3000\MOF-3000-Pref-Lock-File
rem
rem -----------------------------------------------
rem
    set UPSSV_Inst_Path=%UPSSV_Cus_Inst_Path%
rem
    set MOZILLA_DRIVE=%UPSSV_Cus_MOZILLA_DRIVE%
    set MOZILLA_DIR=%UPSSV_Cus_MOZILLA_DIR%
rem
    set MoF_Lock_File=%MOZILLA_DRIVE%\%MOZILLA_DIR%\%UPSSV_Cus_File_Name_Prefix%-Lock-File
rem
    set File_Blank_Line=%UPSSV_Inst_Path%\UPSSV-Subx-Leerzeile.txt
    set CAFFC_CMD=%UPSSV_Inst_Path%\UPSSV-Subx-Create-Append-File-with-Timestamp-as-Contents.cmd
rem ***************************************************************************************
     
    IF EXIST %MoF_Lock_File% GOTO NOstart 

rem **********************************
rem create Lock File  %MoF_Lock_File%
rem **********************************

    call  %CAFFC_CMD% %MOZILLA_DRIVE% %MOZILLA_DIR% %MoF_Lock_File% %File_Blank_Line%

rem ********************************************************
rem Start of Code to be protected from concurrent processing
rem ********************************************************
rem
IF NOT EXIST %UPSSV_Inst_Path%\UPSSV-SysModTest-%UPSSV_Cus_File_Name_Prefix%.  GOTO NoPause
@echo ------------------------------------------------------------------------------
@echo UPSSV FFSRT 002A SysModTest Stopping for "Start Test of UPSSV Save and Vacuum"
@echo                             The UPSSV Start should be denied!
@echo ------------------------------------------------------------------------------
Pause 
GOTO EndCritical     
:NoPause         
rem
echo %UPSSV_Inst_Path%\UPSSV-SysModTest-%UPSSV_Cus_File_Name_Prefix%
Pause
rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rem +++ Begin of your Firefox Start Code +++++++++++++++++++
rem     example for a firefox startup sequence
rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    set MOZILLA_HOME=%MOZILLA_DRIVE%\%MOZILLA_DIR%

    SET MOZ_NO_REMOTE=1
rem set MOZ_NO_RWS=1
    set NSPR_OS2_NO_HIRES_TIMER=1

    SET PATH=%MOZILLA_HOME%\mozilla\firefox;%PATH%

    SET BEGINLIBPATH=%MOZILLA_HOME%\mozilla\firefox;S:\download\os2\libc063;

    SET LIBPATHSTRICT=T

    %MOZILLA_DRIVE%
    cd \%MOZILLA_DIR%\mozilla\firefox

rem firefox -safe-mode  %1 %2 %3 %4

    firefox             %1 %2 %3 %4    >> %MOZILLA_DRIVE%\%MOZILLA_DIR%\crash.log

rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rem +++ End of your Firefox Start Code +++++++++++++++++++++
rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rem 
:EndCritical  
rem ********************************************************
rem End   of Code to be protected from concurrent processing
rem ********************************************************

rem *********************************************
rem delete Lock File  %MoF_Lock_File%
rem *********************************************

    del %MoF_Lock_File%

    GOTO Ende

rem **********************
rem doppelter Startversuch
rem **********************
:NOstart
    
    @echo  ---------------------------------------------------------------- 
    @echo  UPSSV FFSRT 003I Lock file exists - File: "%MoF_Lock_File%"     
    @echo  ---------------------------------------------------------------- 
    @echo  You just try to Start this CMD while a concurrent CMD is running!
    pause 

rem ***************************
rem exit for all cases/branches
rem ***************************
:Ende
  