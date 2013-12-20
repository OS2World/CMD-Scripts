mode 80,40
rem *******************************************************************                             
rem  Main UPSSV Firefox 3.0 User Profile Save and Vacuum of SQL Files    
rem *******************************************************************
rem  File: UPSSV-Main-User-Profile-Save-and-SQLite-Vacuum.cmd
rem *******************************************************************
rem  Copyright 2008 Rainer D. Stroebel 
rem *******************************************************************
rem
rem  Function:
rem  ---------
rem  1. Test and set Semaphore ( Lock-File ) for prevention of concurent execution
rem     of Firefox and UPSSV 
rem  2. If Test is negative --> Pause Error MSG --> entry any Key --> EXIT
rem  3. Save the User Profile ( Prod ) to Generation Directory (N=0 to 3 )  
rem  4. Vacuum all SQLite Files of the User Profile ( Prod )
rem  5. Write tempory Log File of the run to Generation Logs (N=0 to 2)
rem
rem  History 
rem  1.0.1  2007-07-11 xx.xx Intial release
rem  1.0.2  2008-07-14 07.00 IF NOT EXIST  dev-mode
rem  1.0.3  2008-07-16       Add Vacuum Impact History File  
rem                          N =3 for Gen Log File / now same as VLG (Vacuum Log File Gen) 
rem  1.0.4  2008-07-20 15.00 Dev-Mode add code for test with SQLite 3.6.0 
rem  1.0.5  2008-07-28 19.30 add UPSSV_Cus_File_Name_Prefix,
rem                              UPSSV_Cus_User_Profile_Name_Xfix logic  
rem                          rename the files for SysModTest SysModProd 
rem  1.0.6  2008-07-30       more more sophisticated diskspace checking
rem
rem  ---------------------------------------------------------------------------
rem  Input Parameter defiened either by  WPS Program Object/Call or "Hard Coded" for installation env path und Dpath 
rem  ---------------------------------------------------------------------------
rem  param  variable                      value ( for example )
rem
rem  x  UPSSV_Inst_Path=                  S:\UPSSV-v-1-0\   or in WPS Prog Object Working Dir 
rem  x  CAPS_Remove_DIR=                  %UPSSV_Inst_Path%UPSSV-Caps-Remove-Directory.cmd 
rem  x  CAPS_SQLite=                      %UPSSV_Inst_Path%UPSSV-Caps-SQLite3.cmd
rem
rem  1  MOZILLA_DRIVE=                    S:
rem  2  MOZILLA_DIR=                      MoF-3000
rem  3  UPSSV_Cus_File_Name_Prefix        MoF-3000-P
rem  4  User_Profile_Prod_Path=           S:\mof-3000\mozilla\Firefox\Profiles\xxxx.default
rem  5  User_Profile_Save_Drive=          P:
rem  6  User_Profile_Save_Dir=            MoF-3000-Save
rem  7  UPSSV_Cus_User_Profile_Name_Xfix  xxxx.default 
rem
rem  x  UPSSV_Sub1_UP_SQLite_Vacuum_CMD            %UPSSV_Inst_Path%UPSSV-Sub1-User-Profile-SQLite-Vacuum-the-DB-s.cmd
rem  x  UPSSV_Sub1_UP_SQLite_init_Option_File_SQL= %UPSSV_Inst_Path%UPSSV-Sub1-User-Profile-SQLite-init-Option-File.SQL
rem  x  UPSSV_Sub2_UP_Save_CMD=                    %UPSSV_Inst_Path%UPSSV-Sub2-User-Profile-Save-to-Generation-Dir.cmd
rem  x  UPSSV_Subx_CAFTC_CMD=                      %UPSSV_Inst_Path%UPSSV-Subx-Create-Append-File-with-Timestamp-as-Contents.cmd
rem  x  UPSSV_CAFTC_Blank_Line_File=               %UPSSV_Inst_Path%UPSSV-Subx-Leerzeile.txt
rem 
rem  x  VLG_minus-2=                               %UPSSV_Cus_File_Name_Prefix%-%UPSSV_Cus_User_Profile_Name_Xfix%-Vacuum-Log-Gen-minus-2
rem  x  VLG_minus-1=                               %UPSSV_Cus_File_Name_Prefix%-%UPSSV_Cus_User_Profile_Name_Xfix%-Vacuum-Log-Gen-minus-1 
rem  x  VLG_minus-0=                               %UPSSV_Cus_File_Name_Prefix%-%UPSSV_Cus_User_Profile_Name_Xfix%-Vacuum-Log-Gen-minus-0
rem  x  VLG_TMP_Run=                               %UPSSV_Cus_File_Name_Prefix%-%UPSSV_Cus_User_Profile_Name_Xfix%-Vacuum-Log-TMP-Run
rem 
rem  x  UPSSV_Lock_File_FN=                        %UPSSV_Cus_File_Name_Prefix%-Lock-File
rem
rem  x  UPSSV_Vacuum_Impact_History_File_FN=       %UPSSV_Cus_File_Name_Prefix%-%UPSSV_Cus_User_Profile_Name_Xfix%-Vacuum-Impact-History-File.txt
rem
rem
rem  -------------------------------------------------------------------------------
rem  Dev-Mode / Testcode to run the procedure on my development system configuration
rem  Condition: the current values of Path and DPath are delimited by a colon
rem  -------------------------------------------------------------------------------
     IF NOT EXIST S:\UPSSV-HIS\dev-mode  GOTO PRODSYS
rem
rem  set Path=%Path%S:\download\os2\rm;S:\download\os2\SQLite\V3-5-9;S:\UPSSV-v-1-0;
rem  set Path=%Path%S:\download\os2\rm;S:\download\os2\SQLite\V3-5-9;
     set Path=%Path%S:\download\os2\rm;S:\download\os2\SQLite\V3-6-0;
rem  set Dpath=%Dpath%S:\UPSSV-v-1-0;
rem  SET BEGINLIBPATH=S:\download\os2\SQLite\V3-5-9;S:\download\os2\libc063;
     SET BEGINLIBPATH=S:\download\os2\SQLite\V3-6-0;S:\download\os2\libc063;
     SET LIBPATHSTRICT=T
:PRODSYS
rem  -------------------------------------------------------------------------------
rem
rem  ===========================================================================
rem  How to Customize the Procedure - How to Change the Default option selection
rem  ===========================================================================
rem  You select/choose the parameter/values
rem  you want to pass by option to the procedure or  the "hard coded values" 
rem  If you only choose the "User_Profile_Prod_Path" to be passed by Call
rem  then it will be option 1 of your customized procedure!!
rem  
rem  Recommendation for security reason:
rem  -----------------------------------
rem  Pass "User_Profile_Prod_Path" by option, 
rem  so the "salted" Path - location of the user profile - is only stored in the WPS Object  
rem
rem -------------------------------------------------------------------------------
rem *** Definition of Parameter/Options for WPS/Call - default option selection ***
rem ------------------------------------------------------------------------------- 
rem set UPSSV_Inst_Path=%x
rem set CAPS_Remove_DIR=%x
rem set CAPS_SQLite=%x
rem
    set MOZILLA_DRIVE=%1
    set MOZILLA_DIR=%2
    set UPSSV_Cus_File_Name_Prefix=%3
    set User_Profile_Prod_Path=%4
    set User_Profile_Save_Drive=%5
    set User_Profile_Save_Dir=%6
    set UPSSV_Cus_User_Profile_Name_Xfix=%7
rem ***************************************************************************
rem set UPSSV_Sub1_UP_SQLite_Vacuum_CMD=%x
rem set UPSSV_Sub1_UP_SQLite_init_Option_File_SQL=%x
rem set UPSSV_Sub2_UP_Save_CMD=%x
rem set UPSSV_Subx_CAFTC_CMD=%x
rem set UPSSV_CAFTC_Blank_Line_File=%x
rem 
rem set VLG_minus-2=%x
rem set VLG_minus-1=%x 
rem set VLG_minus-0=%x
rem set VLG_TMP_Run_FN=%x
rem
rem set UPSSV_Lock_File_FN=%x
rem 
rem ----------------------------------------------------------------------------------
rem *** Definition of Parameter/Options "Hard Coded" - Values required customizing ***
rem ---------------------------------------------------------------------------------- 
rem set UPSSV_Inst_Path=S:\UPSSV-v-1-0\
rem                      null use current dir of the WPS Object
    set UPSSV_Inst_Path=
    set CAPS_Remove_DIR=%UPSSV_Inst_Path%UPSSV-Caps-Remove-Directory.cmd 
rem
    set CAPS_SQLite=%UPSSV_Inst_Path%UPSSV-Caps-SQLite3.cmd
rem
rem set MOZILLA_DRIVE=S:
rem set MOZILLA_DIR=MoF-3000
rem set UPSSV_Cus_File_Name_Prefix=MoF-3000-P
rem set User_Profile_Prod_Path=S:\mof-3000\mozilla\Firefox\Profiles\xxxx.default
rem set User_Profile_Save_Drive=P:
rem set User_Profile_Save_Dir=%MOZILLA_DIR%-Save
rem set UPSSV_Cus_User_Profile_Name_Xfix=xxxx.default
rem *****************************************************************************
    set UPSSV_Sub1_UP_SQLite_Vacuum_CMD=%UPSSV_Inst_Path%UPSSV-Sub1-User-Profile-SQLite-Vacuum-the-DB-s.cmd
    set UPSSV_Sub1_UP_SQLite_init_Option_File_SQL=%UPSSV_Inst_Path%UPSSV-Sub1-User-Profile-SQLite-init-Option-File.SQL
rem set UPSSV_Sub1_UP_SQLite_init_Option_File_SQL=s:\UPSSV-v-1-0\UPSSV-Sub1-User-Profile-SQLite-init-Option-File.SQL
    set UPSSV_Sub2_UP_Save_CMD=%UPSSV_Inst_Path%UPSSV-Sub2-User-Profile-Save-to-Generation-Dir.cmd
    set UPSSV_Sub3_Free_Space_CMD=%UPSSV_Inst_Path%UPSSV-Sub3-User-Profile-Disk-Free-Space-Check-REXX.cmd
    set UPSSV_Subx_CAFTC_CMD=%UPSSV_Inst_Path%UPSSV-Subx-Create-Append-File-with-Timestamp-as-Contents.cmd
    set UPSSV_CAFTC_Blank_Line_File=%UPSSV_Inst_Path%UPSSV-Subx-Leerzeile.txt
rem 
    set VLG_Drive=%MOZILLA_DRIVE%
    set VLG_Path=%MOZILLA_DIR%
    set VLG_Drive_Path=%VLG_Drive%\%VLG_Path%
rem
    set VLG_minus-3=%UPSSV_Cus_File_Name_Prefix%-%UPSSV_Cus_User_Profile_Name_Xfix%-Vacuum-Log-Gen-minus-3
    set VLG_minus-2=%UPSSV_Cus_File_Name_Prefix%-%UPSSV_Cus_User_Profile_Name_Xfix%-Vacuum-Log-Gen-minus-2
    set VLG_minus-1=%UPSSV_Cus_File_Name_Prefix%-%UPSSV_Cus_User_Profile_Name_Xfix%-Vacuum-Log-Gen-minus-1
    set VLG_minus-0=%UPSSV_Cus_File_Name_Prefix%-%UPSSV_Cus_User_Profile_Name_Xfix%-Vacuum-Log-Gen-minus-0
    set VLG_TMP_Run_FN=%UPSSV_Cus_File_Name_Prefix%-%UPSSV_Cus_User_Profile_Name_Xfix%-Vacuum-Log-TMP-Run
    set VLG_TMP_Run_Abs=%VLG_Drive_Path%\%VLG_TMP_Run_FN%
rem
    set UPSSV_Lock_File_Drive=%MOZILLA_DRIVE%
    set UPSSV_Lock_File_Path=%MOZILLA_DIR%
    set UPSSV_Lock_File_Drive_Path=%MOZILLA_DRIVE%\%MOZILLA_DIR%
    set UPSSV_Lock_File_FN=%UPSSV_Cus_File_Name_Prefix%-Lock-File
    set UPSSV_Lock_File_Abs=%UPSSV_Lock_File_Drive_Path%\%UPSSV_Lock_File_FN%
    
    set UPSSV_Vacuum_Impact_History_File_Drive=%MOZILLA_DRIVE%
    set UPSSV_Vacuum_Impact_History_File_Path=%MOZILLA_DIR%
    set UPSSV_Vacuum_Impact_History_File_Drive_Path=%MOZILLA_DRIVE%\%MOZILLA_DIR%
    set UPSSV_Vacuum_Impact_History_File_FN=%UPSSV_Cus_File_Name_Prefix%-%UPSSV_Cus_User_Profile_Name_Xfix%-Vacuum-Impact-History-File.txt
    set UPSSV_Vacuum_Impact_History_File_Abs=%UPSSV_Vacuum_Impact_History_File_Drive_Path%\%UPSSV_Vacuum_Impact_History_File_FN%

rem *******************************************************************************

    call %UPSSV_Sub3_Free_Space_CMD% %User_Profile_Prod_Path% %User_Profile_Save_Drive%
    IF NOT ERRORLEVEL 1 GOTO FSGood

    Echo UPSSV MAIN 001S Error: No sufficent disk space, I am abborting
    pause   
    goto Ende

:FSGood

rem testcode echo  UPSSV_Lock_File_Abs = "%UPSSV_Lock_File_Abs%"
rem testcode dir  %UPSSV_Lock_File_Abs%
rem testcode Pause

    IF EXIST %UPSSV_Lock_File_Abs% GOTO NoStart 

rem testcode echo hier
rem testcode pause

rem **************************************
rem create Lock File %UPSSV_Lock_File_Abs%  
rem **************************************

    call  %UPSSV_Subx_CAFTC_CMD% %UPSSV_Lock_File_Drive% %UPSSV_Lock_File_Path% %UPSSV_Lock_File_FN% %UPSSV_CAFTC_Blank_Line_File%

rem ************************************************
rem create the Vacuum Log File Gen Temporary the Run  
rem ************************************************
 
    call  %UPSSV_Subx_CAFTC_CMD% %VLG_Drive% %VLG_Path% %VLG_TMP_Run_FN% %UPSSV_CAFTC_Blank_Line_File%
  
rem **************************************************************
rem append the before Info to the UPSSV_Vacuum_Impact_History_File
rem **************************************************************

    @echo +++ Start of Vaccumm +++++++++++++++ >>  %UPSSV_Vacuum_Impact_History_File_Abs%

    call  %UPSSV_Subx_CAFTC_CMD% %UPSSV_Vacuum_Impact_History_File_Drive% %UPSSV_Vacuum_Impact_History_File_Path% %UPSSV_Vacuum_Impact_History_File_FN% %UPSSV_CAFTC_Blank_Line_File%

    dir %User_Profile_Prod_Path%\*.sqlite  /s >>  %UPSSV_Vacuum_Impact_History_File_Abs%

rem ****************************************************
rem the actions to be protected by concurrent processing
rem ****************************************************
@echo -------------------------------------------------------------------------------
@echo Absolut File Name of Lock and Logs Files used
@echo -------------------------------------------------------------------------------
@echo UPSSV_Lock_File_Abs        ="%UPSSV_Lock_File_Abs%"
@echo VLG_TMP_Run_Abs            ="%VLG_TMP_Run_Abs%"   
@echo VLG_Drive_Path\VLG_minus-0 ="%VLG_Drive_Path%\%VLG_minus-0%"
@echo -------------------------------------------------------------------------------
@echo Values passed as option          NO  Value from the WPS Program Object
@echo -------------------------------------------------------------------------------
@echo MOZILLA_DRIVE                    1 ="%MOZILLA_DRIVE%" 
@echo MOZILLA_DIR                      2 ="%MOZILLA_DIR%"
@echo UPSSV_Cus_File_Name_Prefix       3 ="%UPSSV_Cus_File_Name_Prefix%"
@echo User_Profile_Prod_Path           4 ="%User_Profile_Prod_Path%"
@echo User_Profile_Save_Drive          5 ="%User_Profile_Save_Drive%"
@echo User_Profile_Save_Dir            6 ="%User_Profile_Save_Dir%"
@echo UPSSV_Cus_User_Profile_Name_Xfix 7 ="%UPSSV_Cus_User_Profile_Name_Xfix%"
@echo -------------------------------------------------------------------------------
@echo ++ Estimated Execution Time of Procedure: about 120 sec ++
@echo -------------------------------------------------------------------------------
IF NOT EXIST  UPSSV-SysModProd-%UPSSV_Cus_File_Name_Prefix%  GOTO  NoExec
    call %UPSSV_Sub1_UP_SQLite_Vacuum_CMD% %User_Profile_Prod_Path% %User_Profile_Save_Drive% %User_Profile_Save_Dir% %UPSSV_Cus_User_Profile_Name_Xfix% %UPSSV_Sub2_UP_Save_CMD% %CAPS_Remove_DIR% %CAPS_SQLite% %UPSSV_Sub1_UP_SQLite_init_Option_File_SQL% >>%VLG_TMP_Run_Abs% 2>>&1
rem Parameter-No  No= 8                    1                        2                         3                       4                                  5                        6                 7             8
:NoExec
rem
IF NOT EXIST  UPSSV-SysModTest-%UPSSV_Cus_File_Name_Prefix%  GOTO  NoPause
@echo --------------------------------------------------------------------------------
@echo UPSSV MAIN 002A SysModTest: The CMD has stopped with the Lock File created!
@echo --------------------------------------------------------------------------------
@echo Now you have time to test of your Firefox start - The FF start should be denied!
@echo --- Do an additional check: 
@echo        Move the Scroll bar  10 lines up and
@echo        check the options - you passed with the WPS
@echo --------------------------------------------------------------------------------
Pause
:NoPause         
rem
rem **************************************
rem write End of Job Timestamp to Log File
rem **************************************

    call  %UPSSV_Subx_CAFTC_CMD% %VLG_Drive% %VLG_Path% %VLG_TMP_Run_FN% %UPSSV_CAFTC_Blank_Line_File%
  
rem *********************************************************************************
rem delete Vacuum Log File Gen TMP for the Run by rename and save via Generation File                             
rem *********************************************************************************
rem 
   del     %VLG_Drive_Path%\%VLG_minus-3%     
   rename  %VLG_Drive_Path%\%VLG_minus-2%     %VLG_minus-3%
   rename  %VLG_Drive_Path%\%VLG_minus-1%     %VLG_minus-2%
   rename  %VLG_Drive_Path%\%VLG_minus-0%     %VLG_minus-1%               
   rename  %VLG_Drive_Path%\%VLG_TMP_Run_FN%  %VLG_minus-0%

rem *************************************************************
rem append the after Info to the UPSSV_Vacuum_Impact_History_File
rem *************************************************************

    dir %User_Profile_Prod_Path%\*.sqlite  /s >>  %UPSSV_Vacuum_Impact_History_File_Abs%

    call  %UPSSV_Subx_CAFTC_CMD% %UPSSV_Vacuum_Impact_History_File_Drive% %UPSSV_Vacuum_Impact_History_File_Path% %UPSSV_Vacuum_Impact_History_File_FN% %UPSSV_CAFTC_Blank_Line_File%

    @echo +++ End   of Vaccumm +++++++++++++++ >>  %UPSSV_Vacuum_Impact_History_File_Abs%


rem ***************************************
rem delete Lock File  %UPSSV_Lock_File_Abs%                              
rem ***************************************
rem 
    del %UPSSV_Lock_File_Abs%   

    GOTO Ende

rem *****************
rem Concurrent Access
rem *****************
:NoStart

    @echo  ---------------------------------------------------------------- 
    @echo  UPSSV MAIN 003I  Lock file exists - File: "%UPSSV_Lock_File_Abs%"     
    @echo  ---------------------------------------------------------------- 
    @echo  You just try to Start this CMD while a concurrent CMD is running!
    pause 

echo off
rem ***************************
rem exit for all cases/branches
rem **************************
:Ende
  