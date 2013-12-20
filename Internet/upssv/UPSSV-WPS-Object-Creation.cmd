mode 100,80
rem *******************************************************************                             
rem  UPSSV WPS Object Creation base on the values of UPSSV-Inst-INI.cmd 
rem *******************************************************************
rem  File: UPSSV-WPS-Object-Creation.cmd
rem *******************************************************************
rem  Copyright 2008 Rainer D. Stroebel 
rem *******************************************************************
rem
rem  Function:
rem  ---------
rem  1. Get the customized parameter / options 
rem        of UPSSV from UPSSV_Get_Options_Proc 
rem     by default name or as parmeter 1 
rem     
rem  2. The option values will be check
rem          --> Error --> Message --> Pause--> any Key--> Exit
rem
rem  3. call  UPSSV_WPS_Proc to 
rem       Create of a WPS Folder for the Package  
rem       Create of a WPS Porgram Objects 
rem              
rem  External:
rem    UPSSV_Get_Options_Proc   UPSSV-Inst-INI.cmd
rem    UPSSV_WPS_Proc           UPSSV-WPS-Object-Creation-REXX.cmd
rem
rem  Version 1.0.1  2008-07-13 Intial release     
rem  Version 1.0.2  2008-07-14 Correct Errorlevel test condition
rem  Version 1.0.3  2008-07-19 add get Parameter / Options of UPSSV for external
rem  Version 1.0.4  2008-07-28 get input via default cmd or with parameter 1  
rem
rem  Parameter 1:  UPSSV-inst-INI.CMD file to be used,
rem                if not pressent the default name "UPSSV-inst-INI.CMD" is used 
rem
rem  ----------------------------------------------------------------------------
rem  env var passe by default cmd  "UPSSV-Inst-INI.cmd" or by CMD as  parameter 1  
rem  ----------------------------------------------------------------------------
rem  param  variable                      value ( for example )
rem
rem  1  UPSSV_Inst_Path=                  S:\UPSSV-v-1-0        
rem  2  MOZILLA_DRIVE=                    S:
rem  3  MOZILLA_DIR=                      MoF-3000
rem  4  UPSSV_Cus_File_Name_Prefix        MoF-3000-P
rem  5  User_Profile_Prod_Path=           S:\mof-3000\mozilla\Firefox\Profiles\xxxx.default
rem  6  User_Profile_Save_Drive=          P:
rem  7  User_Profile_Save_Dir             MoF-3000-Save
rem  8  User_Profile_Name_Xfix            xxxx.default  
rem
rem ****************************************************************************************
rem
    set UPSSV_WPS_Proc=UPSSV-WPS-Object-Creation-REXX.cmd
rem
rem **************************************************************
rem overwrite the default value with parameter 1 value, if present
rem ************************************************************** 

       set UPSSV_Get_Options_Proc=UPSSV-Inst-INI.cmd  

    IF %1. ==  .  GOTO NoOverw

       set UPSSV_Get_Options_Proc=%1

:NoOverw
rem *******************************************************************************************
rem Test, can the externals be found ? 
rem *******************************************************************************************
    IF  EXIST %UPSSV_WPS_Proc%          GOTO  NP1pass
    @echo ---------------------------------------------------------------------------------------------
    @echo UPSSV WPSE 006E Error UPSSV_WPS_Proc = "%UPSSV_WPS_Proc% is not found
    @echo ---------------------------------------------------------------------------------------------
    Pause
    GOTO ENDE
:NP1pass
rem
    IF  EXIST %UPSSV_Get_Options_Proc%  GOTO  NP2pass
    @echo ---------------------------------------------------------------------------------------------
    @echo UPSSV WPSE 007E Error UPSSV_Get_Options_Proc = "%UPSSV_Get_Options_Proc% not found!
    @echo                       Do you follow the customizing instructions?
    @echo ---------------------------------------------------------------------------------------------
    Pause
    GOTO ENDE
:NP2pass
rem -----------------------------------------------------------------------------------------------
rem *** Get the parameter/options defined at the installation customizing step by the installer ***
rem ---------------------------------------------------------------------------------- ------------
rem
    call %UPSSV_Get_Options_Proc% 
rem
    set UPSSV_Inst_Path=%UPSSV_Cus_Inst_Path%
    set MOZILLA_DRIVE=%UPSSV_Cus_MOZILLA_DRIVE%
    set MOZILLA_DIR=%UPSSV_Cus_MOZILLA_DIR%
    set UPSSV_File_Name_Prefix=%UPSSV_Cus_File_Name_Prefix%
    set User_Profile_Prod_Path=%UPSSV_Cus_User_Profile_Prod_Path%
    set User_Profile_Save_Drive=%UPSSV_Cus_User_Profile_Save_Drive%
    set User_Profile_Save_Dir=%UPSSV_Cus_User_Profile_Save_Dir%
    set User_Profile_Name_Xfix=%UPSSV_Cus_User_Profile_Name_Xfix%
rem
rem *******************************************************************************************
rem End   Test_Mode /DEV_Mode  code run to the procedure on my development system configuration
rem *******************************************************************************************
rem
@echo --------------------------------------------------------------
@echo Code values to pass to WPS Creation procedure
@echo --------------------------------------------------------------
@echo UPSSV_Cus_Inst_Path               1 ="%UPSSV_Inst_Path%"
@echo UPSSV_Cus_MOZILLA_DRIVE           2 ="%MOZILLA_DRIVE%" 
@echo UPSSV_Cus_MOZILLA_DIR             3 ="%MOZILLA_DIR%"
@echo UPSSV_Cus_File_Name_Prefix        4 ="%UPSSV_File_Name_Prefix%"
@echo UPSSV_Cus_User_Profile_Prod_Path  5 ="%User_Profile_Prod_Path%"
@echo UPSSV_Cus_User_Profile_Save_Drive 6 ="%User_Profile_Save_Drive%"
@echo UPSSV_Cus_User_Profile_Save_Dir   7 ="%User_Profile_Save_Dir%"
@echo UPSSV_Cus_User_Profile_Name_Xfix  8 ="%User_Profile_Name_Xfix%"
@echo --------------------------------------------------------------
@echo UPSSV WPSE 008A: Abort with Crtl+ C if you like to correct the values
Pause
rem  
    set MOZILLA_DRIVE_DIR=%MOZILLA_DRIVE%\%MOZILLA_DIR% 
    set User_Profile_Save_Path=%User_Profile_Save_Drive%\%User_Profile_Save_Dir%
rem
rem *****************************************
rem  Start Pausibility checking of the values
rem *****************************************
rem
    IF  EXIST %UPSSV_Inst_Path%\readme.txt  GOTO  N01pass
    @echo ---------------------------------------------------------------------------------------------
    @echo UPSSV WPSE 001E Error UPSSV_Inst_Path = "%UPSSV_Inst_Path% does not exist or readme.txt missing
    @echo ---------------------------------------------------------------------------------------------
    Pause
    GOTO ENDE
:N01pass
rem =========================
    copy %UPSSV_Inst_Path%\readme.txt %MOZILLA_DRIVE%\%MOZILLA_DIR%\readme.temp
    IF   EXIST                        %MOZILLA_DRIVE%\%MOZILLA_DIR%\readme.temp GOTO N02pass
    @echo ---------------------------------------------------------------------------------------------
    @echo UPSSV WPSE 002E Error MOZILLA_DRIVE\MOZILLA_DIR = %MOZILLA_DRIVE%\%MOZILLA_DIR% does not exist 
    @echo ---------------------------------------------------------------------------------------------
    Pause
    GOTO ENDE
:N02pass
    del %MOZILLA_DRIVE%\%MOZILLA_DIR%\readme.temp
rem ========================= 
    IF  EXIST %User_Profile_Prod_Path%\places.sqlite GOTO  N03pass
    @echo ---------------------------------------------------------------------------------------------
    @echo UPSSV WPSE 003E Error User_Profile_Prod_Path = "%User_Profile_Prod_Path% does not exist or places.SQLite are missing
    @echo ---------------------------------------------------------------------------------------------
    Pause
    GOTO ENDE
:N03pass
:N01pass
rem =========================
    copy %UPSSV_Inst_Path%\readme.txt %User_Profile_Save_Path%\readme.temp
    IF   EXIST                        %User_Profile_Save_Path%\readme.temp GOTO N04pass
    @echo ---------------------------------------------------------------------------------------------
    @echo UPSSV WPSE 004E Error User_Profile_Save_Drive\User_Profile_Save_Dir = %User_Profile_Save_Drive%\%User_Profile_Save_Dir% does not exist 
    @echo ---------------------------------------------------------------------------------------------
    Pause
    GOTO ENDE
:N04pass
    del %User_Profile_Save_Path%\readme.temp
rem
rem *****************************************
rem  End   Pausibility checking of the values
rem *****************************************
rem
rem *********************************
rem Call UPSSV WPS Creation Procedure
rem *********************************
rem Parameter-No  No= 09   1                 2               3             4                        5                         6                        7                       8                        9
    call %UPSSV_WPS_Proc% %UPSSV_Inst_Path% %MOZILLA_DRIVE% %MOZILLA_DIR% %UPSSV_File_Name_Prefix% %User_Profile_Prod_Path% %User_Profile_Save_Drive% %User_Profile_Save_Dir% %User_Profile_Name_Xfix% %1
    IF NOT ERRORLEVEL 1 GOTO WPSDone
rem
    @echo ------------------------------------------------------------------------------------------
    @echo UPSSV WPSE 005S Sever Error Return code not 0 : Error in ReXX UPSSV-WPS-Object-Creation-REXX.cmd
    @echo ------------------------------------------------------------------------------------------
    pause
    GOTO Ende

:WPSDone 
    @echo ---------------------------------------------------------------------------
    @echo UPSSV WPSE 000I Information: Creation of UPSSV WPS Objects succesfully done
    @echo ---------------------------------------------------------------------------
    pause
    GOTO Ende
rem ***************************

rem ***************************
rem exit for all cases/branches
rem ***************************
:Ende
@echo UPSSV WPSE 009A Pause: Do you check the above messages? Press any key to end the procedure. 
Pause
  