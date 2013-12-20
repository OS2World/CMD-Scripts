rem  ****************************************************************
rem  Sub1 UPSSV  Vacuum the SQLite Files of a User Profile for FF 3.0
rem  **************************************************************** 
rem  File: UPSSV-Sub1-User-Profile-SQLite-Vacuum-the-DB-s.cmd 
rem *****************************************************************
rem  Copyright 2008 Rainer D. Stroebel 
rem *****************************************************************
rem 
rem  Parameter:                     sample values
rem  1    User_Profile_Prod_Path=           S:\mof-3000\mozilla\Firefox\Profiles\xxxx.default
rem  2    User_Profile_Save_Drive=          P:
rem  3    User_Profile_Save_Dir=            mof-3000-Save
rem  4    UPSSV_Cus_User_Profile_Name_Xfix  MoF-300P
rem  5    MOF_Profile_save_CMD=             S:\UPSSV-V-1-0\UPSSV-Sub2-User-Profile-Save-to-Generation-Dir.cmd
rem  6    Prog_Remove_DIR_EXE=              S:\UPSSV-v-1-0\UPSSV-Caps-Remove-Dir.cmd 
rem  7    SQLite-CMD=                       S:\UPSSV-V-1-0\UPSSV-Caps-SQLite359.cmd
rem  8    SQLite-init-Option-File=          S:\UPSSV-V-1-0\UPSSV-Sub1-User-Profile-SQLite-init-Option-File.SQL
rem
rem  Externals: 
rem  all by parameter 1 to 7 
rem
rem  History:
rem  2008-07-07 11.00 V1.0   Inital
rem  2008-07.07 12.15 V1.0.1 SQLite342.cmd --> SQLite359,cmd
rem  2008-07-07 13.30 V1.0.2 SQLite-CMD-Options
rem  2008-07-08       V1.1.0 Productioncode with save profile to Gen DIR
rem  2008-07-28 20.30 V1.1.1 New: UPSSV_Cus_User_Profile_Name_Xfix  
rem
rem ***************************************************************************

    set User_Profile_Prod_Path=%1
    set User_Profile_Save_Drive=%2
    set User_Profile_Save_Dir=%3
    set UPSSV_Cus_User_Profile_Name_Xfix=%4
    set MOF_Profile_Save_CMD=%5
    set Prog_Remove_DIR_EXE=%6
    set SQLite-CMD=%7
    set SQLite-init-Option-File=%8
  
rem *** local var *************************************************************
    set SQLite-CMD-Options=-bail -batch -version -init %SQLite-init-Option-File%

rem **********************************************
rem Save the User Profile  to Generation Directory
rem **********************************************
rem Parameter NO =  N=5         1                        2                         3                       4                                  5 
    Call %MOF_Profile_Save_CMD% %User_Profile_Prod_Path% %User_Profile_Save_Drive% %User_Profile_Save_Dir% %UPSSV_Cus_User_Profile_Name_Xfix% %Prog_Remove_DIR_EXE%

rem ******************************************
rem Before Vacuum: Size of the SQLite DB Files
rem ******************************************

    dir %User_Profile_Prod_Path%\*.sqlite  /s

rem **************************
rem Vacuum the SQLite DB Files
rem **************************

    set SQLite_DB_01=%User_Profile_Prod_Path%\content-prefs.sqlite
    set SQLite_DB_02=%User_Profile_Prod_Path%\cookies.sqlite
    set SQLite_DB_03=%User_Profile_Prod_Path%\downloads.sqlite
    set SQLite_DB_04=%User_Profile_Prod_Path%\formhistory.sqlite
    set SQLite_DB_05=%User_Profile_Prod_Path%\permissions.sqlite
    set SQLite_DB_06=%User_Profile_Prod_Path%\places.sqlite
    set SQLite_DB_07=%User_Profile_Prod_Path%\search.sqlite
    set SQLite_DB_08=%User_Profile_Prod_Path%\urlclassifier3.sqlite
    set SQLite_DB_09=%User_Profile_Prod_Path%\OfflineCache\index.sqlite

    call %SQLite-CMD%  %SQLite-CMD-Options%   %SQLite_DB_01% .exit
    call %SQLite-CMD%  %SQLite-CMD-Options%   %SQLite_DB_02% .exit
    call %SQLite-CMD%  %SQLite-CMD-Options%   %SQLite_DB_03% .exit
    call %SQLite-CMD%  %SQLite-CMD-Options%   %SQLite_DB_04% .exit
    call %SQLite-CMD%  %SQLite-CMD-Options%   %SQLite_DB_05% .exit
    call %SQLite-CMD%  %SQLite-CMD-Options%   %SQLite_DB_06% .exit
    call %SQLite-CMD%  %SQLite-CMD-Options%   %SQLite_DB_07% .exit
    call %SQLite-CMD%  %SQLite-CMD-Options%   %SQLite_DB_08% .exit
    call %SQLite-CMD%  %SQLite-CMD-Options%   %SQLite_DB_09% .exit

rem ******************************************
rem After Vacuum: Size of the SQLite DB Files
rem ******************************************

   dir %User_Profile_Prod_Path%\*.sqlite /S

rem ************************************************************************* 
rem *** End of Firefox-3-0-UPSSV-Sub1-User-Profile-SQLite-Vacuum-the-DB-s.cmd
rem *************************************************************************