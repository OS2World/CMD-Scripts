rem  ****************************************************************  
rem  Sub2  UPSSV User Profile save to Generation Directory for FF 3.0
rem  ****************************************************************
rem  File: UPSSV-Sub2-User-Profile-Save-to-Generation-Dir.cmd
rem *****************************************************************
rem  Copyright 2008 Rainer D. Stroebel 
rem *****************************************************************
rem
rem
rem 
rem  Parameter
rem                                 example values  
rem  1   User_Profile_Prod_Path=    S:\MoF-3000\Mozilla\Firefox\Profiles\xxxxxxx.default  
rem  2   User_Profile_Save_Drive=   P:
rem  3   User_Profile_Save_Dir=     MoF-3000-Save
rem  4   User_Profile_Name_Prefix   xxxx.default
rem  5   Caps_Remove_DIR=           s:\UPSSV-v-1-0\UPSSV-Casp-Remove-Dir.cmd 
rem
rem  Externals:
rem  via Paramater 4 
rem  rm.zip vom hobbles rm.exe : remove a directory with/out files and subdirs
rem
rem  History: 
rem  2008-07-08 19.00 V1.0.0 Initial Release  
rem  2008-07-28 20.43 V1.0.1 add  User_Profile_Name_Prefix
rem
rem ************************************************************
    set  User_Profile_Prod_Path=%1
    set  User_Profile_Save_Drive=%2
    set  User_Profile_Save_Dir=%3
    set  User_Profile_Name_Prefix=%4
    set  User_Profile_Save_Path=%User_Profile_Save_Drive%\%User_Profile_Save_Dir%
    set  Caps_Remove_DIR=%5
rem *************************************************************
rem 
rem *********************************************
rem Save the User Profile to Generation Directory
rem *********************************************
rem Step 1: delete oldest Generation Directory
rem *********************************************
rem Parameter N=3          1                         2                       3  
    CALL %Caps_Remove_DIR% %User_Profile_Save_Drive% %User_Profile_Save_Dir% %User_Profile_Name_Prefix%-Gen-minus-3   
rem
rem *********************************************
rem Step 2: rename N-minus-(x) to N-minus-(x+1) 
rem *********************************************
    rename  %User_Profile_Save_Path%\%User_Profile_Name_Prefix%-Gen-minus-2  %User_Profile_Name_Prefix%-Gen-minus-3
    rename  %User_Profile_Save_Path%\%User_Profile_Name_Prefix%-Gen-minus-1  %User_Profile_Name_Prefix%-Gen-minus-2
    rename  %User_Profile_Save_Path%\%User_Profile_Name_Prefix%-Gen-minus-0  %User_Profile_Name_Prefix%-Gen-minus-1
rem *********************************************
rem Step 3: xcopy Prod to N-minus-(0) 
rem *********************************************
    xcopy   %User_Profile_Prod_Path%\*.*  %User_Profile_Save_Path%\%User_Profile_Name_Prefix%-Gen-minus-0\*.*  /s /e /h /v 
rem
    IF NOT EXIST %User_Profile_Save_Path%\%User_Profile_Name_Prefix%-Gen-minus-0\cache\_CACHE_MAP_ GOTO NoDelete 
rem
    del %User_Profile_Save_Path%\%User_Profile_Name_Prefix%-Gen-minus-0\cache\*.* /N  
rem
:NoDelete 
rem
rem **********************************************************************************
rem End of UPSSV-Sub2-User-Profile-Save-to-Generation-Dir.cmd
rem **********************************************************************************