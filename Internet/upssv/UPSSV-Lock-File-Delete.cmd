@rem *******************************************************************                             
@echo  ----------------------
@echo  UPSSV Delete Lock File  V1.0.1 
@rem *******************************************************************
@rem  File: UPSSV-Lock-File-Delete.cmd 
@rem *******************************************************************
@echo  Copyright 2008 Rainer D. Stroebel 
@rem *******************************************************************
@echo off
rem
rem  Function:
rem  
rem  CMD to delete the lock file manually 
rem      in case of abend of Firefox session for UPSSV Produre
rem
rem  Version 1.0.0  2008-07-08  creation    
rem          1.0.1  2008-07-29  NEW UPSSV_Cus_File_Name_Prefix   
rem
rem  Input Parameter
rem  1    MOZILLA_DRIVE=               e.g.  S:
rem  2    MOZILLA_DIR=                 e.g.  MoF-3000
rem  3    UPSSV_Cus_File_Name_Prefix   e.g.  MoF-3000-Pref
rem
rem  The file name of the Lock file is %UPSSV_Cus_File_Name_Prefix%-Lock-File
rem
rem ************************************************************************
rem 
    set MOZILLA_DRIVE=%1
    set MOZILLA_DIR=%2
    set UPSSV_Cus_File_Name_Prefix=%3
rem
    set MoF_Lock_File=%MOZILLA_DRIVE%\%MOZILLA_DIR%\%UPSSV_Cus_File_Name_Prefix%-Lock-File
rem
    IF NOT EXIST %MoF_Lock_File% GOTO UserErr
rem
rem *********************************
rem delete Lock File  %MoF_Lock_File%                              
rem *********************************
rem 
    @echo on
    @echo ------------------------------------------------------------      
    @echo UPSSV DLOK 001A Log File: %MoF_Lock_File%
    @echo                  Really - Do you want to delete the file?
    Pause
    @echo UPSSP DLOK 002A Are your sure? 
    @echo                  No Firefox session is active
    @echo               or UPSSV procedure    is running?  
    @echo                  You can stop the process with Cntl + C!
    Pause 
    del %MoF_Lock_File%   
    @echo UPSSP DLOK 003I Lock File deleted!
    pause    
    @echo off
GOTO Ende

rem *********************************************
rem User Try to delete an non existing lock file 
rem *********************************************
:UserErr
    @echo on
    @echo ------------------------------------------------------------
    @echo UPSSP DLOK 004E There is no Lock File: "%MoF_Lock_File%" to delete!
    @echo                 What are you doing?
    pause 
    @echo off
rem ***************************
rem exit for all cases/branches
rem **************************
:Ende
  
