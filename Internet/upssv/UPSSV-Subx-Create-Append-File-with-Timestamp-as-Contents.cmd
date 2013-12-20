rem ******************************************************************
rem Subx  UPSSV Create Append File with Timestamp as Contents (CAFTC)
rem ******************************************************************
rem File: UPSSV-Subx-Create-Append-File-with-Timestamp-as-Contents.cmd
rem ******************************************************************
rem Copyright 2008 Rainer D. Stroebel 
rem ******************************************************************
rem
rem  Parameter 
rem  1 CAFTC_Drive
rem  2 CAFTC_Dir
rem  3 CAFTC_Filename
rem  4 CAFTC_File_Blank_Line
rem
rem  External: env TMP  = %TMP% 
rem
rem  History:
rem  2008-07-11  V1.0.0   Inital
rem  2008-07-12  V1.0.1   Add TMP_Blank_Line_FIle
rem ******************************************************************
rem
    set CAFTC_Drive=%1
    set CAFTC_Dir=%2
    set CAFTC_Filename=%3
    set CAFTC_Blank_Line_File=%4
rem 
    set CAFTC_Drive_Path_Filename=%CAFTC_Drive%\%CAFTC_Dir%\%CAFTC_Filename%
rem
    set TMP_Blank_Line_File=%TMP%\UPSSV-Blank-Line-File
rem
    copy %CAFTC_Blank_Line_File%  %TMP_Blank_Line_File%
rem 
    setlocal
rem
    %CAFTC_Drive%   
    cd     \%CAFTC_Dir%
    date >> %CAFTC_Filename%                         <NUL 
    copy    %CAFTC_Filename% + %TMP_Blank_Line_File%
    time >> %CAFTC_Filename%                         <NUL
    copy    %CAFTC_Filename% + %TMP_Blank_Line_File%
    set CAFTC_Drive_Path_Filename>> %CAFTC_Filename%
    copy    %CAFTC_Filename% + %TMP_Blank_Line_File%
rem 
    endlocal
rem
    del %TMP_Blank_Line_File%
rem *******************************************************************
rem End of UPSSV-Subx-Create-Append-File-with-Timestamp-as-Contents.cmd
rem *******************************************************************
