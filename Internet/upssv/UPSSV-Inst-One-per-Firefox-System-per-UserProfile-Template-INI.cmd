rem *******************************************************************                             
rem  UPSSV Installer This template requires your Modification
rem *******************************************************************
rem  File: UPSSV-Inst.ini.cmd-Installer-This-template-requires-your-Modification.cmd
rem *******************************************************************
rem  Copyright 2008 Rainer D. Stroebel 
rem *******************************************************************
rem
rem  Function:
rem  ---------
rem  Read only INI file for UPSSV ( by syntax of an CMD File !! )   
rem  Here the installer defines the customized options of UPSSV
rem        
rem
rem  Do the customizing, edit the template
rem
rem  and "save as"   UPSSV-Inst.ini.cmd
rem  ==================================
rem        
rem  Call by:
rem  UPSSV-WPS-Object-Creation-Main.cmd 
rem
rem  Version 1.0.0  2008-07-19 Initial release     
rem          1.0.1  2008-07-27 add  UPSSV_Cus_File_Name_Prefix
rem                                 UPSSV_Cus_User_Profile_Name_Xfix      
rem
rem  ------------------------------------------------------------
rem  Parameter / Options to be modified by the Installer 
rem  ------------------------------------------------------------
rem  param  variable                        value ( for example )
rem 
rem  1  UPSSV_Cus_Inst_Path                 S:\UPSSV-v-1-0        
rem  2  UPSSV_Cus_MOZILLA_DRIVE             S:
rem  3  UPSSV_Cus_MOZILLA_DIR               MoF-3000
rem  4  UPSSV_Cus_File_Name_Prefix          MoF-3000-P
rem  5  UPSSV_Cus_User_Profile_Prod_Path    S:\mof-3000\mozilla\Firefox\Profiles\xxxx.default
rem  6  UPSSV_Cus_User_Profile_Save_Drive   P:
rem  7  UPSSV_Cus_User_Profile_Save_Dir     MoF-3000-Save
rem  8  UPSSV_Cus_User_Profile_Name_Xfix    xxxx.default  
rem
rem  ------------------------------------------------------------------------
rem
rem  1  UPSSV_Cus_Inst_Path                 S:\UPSSV-v-1-0       
rem 
rem     program directory of UPSSV   
rem
rem  2  UPSSV_Cus_MOZILLA_DRIVE             S:
rem  3  UPSSV_Cus_MOZILLA_DIR               MoF-3000 
rem 
rem     Defines the location of the Lock File,
rem     the Vacuum Generation Log (VLG) Files 
rem     and the Vacuum Impact History File.
rem
rem  4  UPSSV_Cus_File_Name_Prefix          MoF-3000-P
rem
rem      Defines the File Name Prefix of the  
rem        Lock File 
rem        Vacuum Generation Log (VLG) Files 
rem        Vacuum Impact History File
rem        UPSSV-Lock-SysMod-Test File
rem        UPSSV-Lock-SysMod-Prod File
rem     This name has to be unique over all installed Firefox Systems.
rem     Otherwise the SysMod-Test SysMod-Prod does not work per System!
rem
rem  5  UPSSV_Cus_User_Profile_Prod_Path    S:\mof-3000\mozilla\Firefox\Profiles\xxxx.default
rem
rem     Defines the location of the FF 3.0 User Profile to be saved and 
rem     the SQLite File of the User Profile to be compacted ("Vacuum") 
rem 
rem  6  UPSSV_Cus_User_Profile_Save_Drive   P:
rem  7  UPSSV_Cus_User_Profile_Save_Dir     MoF-3000-Save
rem
rem     Defines the location of the generation directories of the 
rem     User Profile Backup. 
rem     You  have to create the directory, if it does not already exists!!
rem
rem  8  UPSSV_Cus_User_Profile_Name_Xfix    xxxx.default 
rem
rem     Defines the "mid-fix" Name for 
rem     the Vacuum Generation Log (VLG) Files 
rem     and the Vacuum Impact History File.
rem  
rem     Defines the prefix for the generation directories  
rem     of the User Profile Backup. 
rem   
rem ----------------------------------------------------------------------------------
rem *** Definition of Parameter/Options  -  Values required customizing ***
rem ---------------------------------------------------------------------------------- 
rem Warning: Make shure, ther are no trailing blank character at the end of the 
rem          option text!!! The line of the set statemant should end with the 
rem          last character of the option value!! 
rem
    set UPSSV_Cus_Inst_Path=S:\UPSSV-v-1-0
rem
    set UPSSV_Cus_MOZILLA_DRIVE=S:
    set UPSSV_Cus_MOZILLA_DIR=MoF-3000
rem
    set UPSSV_Cus_File_Name_Prefix=MoF-3000-P
rem
    set UPSSV_Cus_User_Profile_Prod_Path=S:\mof-3000\mozilla\Firefox\Profiles\xxxx.default
rem
    set UPSSV_Cus_User_Profile_Save_Drive=P:
    set UPSSV_Cus_User_Profile_Save_Dir=%UPSSV_Cus_MOZILLA_DIR%-Save
rem
    set UPSSV_Cus_User_Profile_Name_Xfix=xxxx.default
rem
rem *******************************************************************************
rem End of UPSSV-Installer-This-cmd-requires-your-Modification
rem *******************************************************************************