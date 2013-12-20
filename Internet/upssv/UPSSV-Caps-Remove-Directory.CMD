rem  **************************************************  
rem  UPSSV Caps Remove Directory
rem  **************************************************
rem  File: UPSSV-Caps-Remove-Directroy.cmd
rem ***************************************************
rem  Copyright 2008 Rainer D. Stroebel 
rem ***************************************************
rem
rem  Function:
rem
rem  Capsel for the Function "Remove Directory"  with/out files and subdirs
rem 
rem  Parameter
rem  1   User_Profile_Save_Drive=  e.g.  P:
rem  2   User_Profile_Save_Dir=    e.g.  MoF-3000-Save
rem  3   Directory_Name=           e.g   Profile-Gen-minus-3
rem
rem  Externals:
rem  rm.zip vom hobbles rm.exe : remove a directory with/out files and subdirs
rem
rem  History: 
rem  2008-07-11 01.00 V1.0.0 Initial Release  
rem
rem ***************************************************
    set  User_Profile_Save_Drive=%1
    set  User_Profile_Save_Dir=%2
    set  Directory-Name=%3
rem 
rem *** Has to be Customized - Location of RM *****************
rem -----------------------------------------------------------
rem set Prog_Remove_DIR_EXE_Opt=s:\download\os2\rm\rm.exe -r -f
    set Prog_Remove_DIR_EXE_Opt=rm.exe -r -f 
rem ***********************************************************
rem
    setlocal
rem 
rem ***************************************************
rem delete the directory 
rem ***************************************************
rem     
       %User_Profile_Save_Drive%
    cd \%User_Profile_Save_Dir%
rem 
    rename %Directory-Name%  VarAux
rem                                    rm does not like the name "Profile-Gen-minus-3"
rem                                    with rename to "VarAux" it works - why???
rem                                    2008-07-08 23.00 Rainer 
rem                                    e.g. s:\download\os2\rm\rm.exe -r -f    
    %Prog_Remove_DIR_EXE_Opt%   VarAux
    echo off 
    IF EXIST                    VarAux\*.SQLite  ECHO  UPSSV CAPRM 001E Error +++ GEN-3 aka VarAux: Remove DIR Failed!! +++
    echo on
rem    
    endlocal
rem
rem ***************************************************
rem End of UPSSV-Caps-Remove-Directory.CMD
rem ***************************************************