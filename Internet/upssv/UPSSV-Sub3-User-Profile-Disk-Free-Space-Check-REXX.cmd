/***************************************************************************/
/*  UPSSV-Sub3-User-Profile-Disk-Free-Space-Check-REXX.cmd                 */
/*                                                                         */
/*  Copyright 2008 Rainer D. Stroebel                                      */ 
/*                                                                         */
/*                                                                         */
/*  Function:                                                              */
/*  1. Get the size of the biggest SPLite file of the Profile              */
/*  2. add savety margin                                                   */
/*  3. Check against Disk Free space --> negativ Return(3)                 */
/*                                                                         */
/*                                                                         */
/*  ARG variable                  value ( for example )                    */
/*  -------------------------------------------------------------------    */
/*  1  IN_User_Profile_Prod_Path  S:\mof-3000\mozilla\Firefox\Profiles\xxxx.default */
/*  2  IN_User_Profile_Save_Drive P:                                       */ 
/*                                                                         */
/*  External:                                                              */
/*  TMP      Environment Variable                                          */
/*                                                                         */
/*                                                                         */
/* History:                                                                */
/* 1.0  2008-07-26 12.00 Intial creation                                   */
/* 1.1  2008-07-30       Check TMP, IN_User_Profile_Save_Drive             */
/*                       drive space                                       */
/* 1.2  2008-08-04       Korr condition or message 006E, 007E 008E         */
/*                                                                         */
/***************************************************************************/

  Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs';
  Call SysLoadFuncs;

  Return_Code = 0
  
  Say " " 
  Say "UPSSV Sub3 User Profile Disk Free Space Check REXX Version 1.1 Rainer D. Stroebel"
  Say " "
  Say "Program Start: " GTS() 
  
  call time "R"


  PARSE UPPER ARG IN_User_Profile_Prod_Path, 
                  IN_User_Profile_Save_Drive 
   
  rc = sysfiletree(IN_User_Profile_Prod_Path|| "\*.sqlite", 'File_List_of_SQLite_Files_in_User_Profile_Stem.', 'FT');

  IF File_List_of_SQLite_Files_in_User_Profile_Stem.0 = 0 THEN,
                    DO
                     Say "UPSSV Sub3 001E Error: No SQLite Files found in User Profile";
                     Return_Code = 1
                     SIGNAL Program_End
                    END;


  Max_SQLite_File_Size_add_Safety_Value  = 10000000    /* in Bytes */  

  Max_SQLite_File_Size                   = 0

  Sum_SQLite_File_Size                   = 0 

  
  DO i = 1 to File_List_of_SQLite_Files_in_User_Profile_Stem.0;

    SQLite_ThisD             = File_List_of_SQLite_Files_in_User_Profile_Stem.i;
    SQLite_File_Time_Stamp   = subword(         SQLite_ThisD,1,1)
    SQLite_File_Time_Stamp_F = FTS(             SQLite_File_Time_Stamp)
    SQLite_File_Size         = subword(         SQLite_ThisD,2,1)
    SQLite_File_Name_abs     = subword(         SQLite_ThisD,4);
    SQLite_File_Name         = FILESPEC('name', SQLite_File_Name_abs)

    IF SQLite_File_Size > Max_SQLite_File_Size THEN,
                        DO
                          Max_SQLite_ThisD              =  SQLite_ThisD                            
                          Max_SQLite_File_Time_Stamp    =  SQLite_File_Time_Stamp      
                          Max_SQLite_File_Time_Stamp_F  =  SQLite_File_Time_Stamp_F 
                          Max_SQLite_File_Size          =  SQLite_File_Size
                          Max_SQLite_File_Name_abs      =  SQLite_File_Name_abs       
                          Max_SQLite_File_Name          =  SQLite_File_Name                      
                        END

    Sum_SQLite_File_Size = Sum_SQLite_File_Size  + SQLite_File_Size

  END i;

  Max_SQLite_Drive        = FILESPEC('drive', Max_SQLite_File_Name_abs)


/*****************************************************/
/* Get Free Space on Disk drive of the User Profile  */         
/*****************************************************/

 Max_SQLite_Drive_SysDriveInfo   = SysDriveInfo(Max_SQLite_Drive) 

 Max_SQLite_Drive_FreeSpace      = subword(     Max_SQLite_Drive_SysDriveInfo,2,1)


 IF Max_SQLite_Drive_FreeSpace  < ( Max_SQLite_File_Size + Max_SQLite_File_Size_add_Safety_Value ) THEN,
    DO       
    Return_Code = 2
    SAY "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    SAY "UPSSV Sub3 002E Error: Free space on disk of the User Profile is to low"
    SAY "                       Free space on disk is       ="  RIGHT(Max_SQLite_Drive_FreeSpace            ,15)           
    SAY "                       Value of add Safty Margin   ="  RIGHT(Max_SQLite_File_Size_add_Safety_Value ,15)  
    SAY "                       Size of biggest SQLite file ="  RIGHT(Max_SQLite_File_Size                  ,15)
    SAY "                       Name of biggest SQLite file ="        Max_SQLite_File_Name  
    SAY "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    SIGNAL Program_End
    END

/*****************************************************/
/* Check  Free Space on Disk drive on TMP drive      */         
/*****************************************************/

 Env_TMP = value(TMP,,"OS2ENVIRONMENT")  

 IF Env_TMP = "" THEN, 
    DO       
    Return_Code = 3
    SAY "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    SAY "UPSSV Sub3 003E Error: I cannot find a Environment Variable "TMP" in your Enviroment"
    SAY "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    SIGNAL Program_End
    END

 Env_TMP_Drive                = Substr(      Env_TMP,1,2)

 Env_TMP_Drive_SysDriveInfo   = SysDriveInfo(Env_TMP_Drive) 

 Env_TMP_Drive_FreeSpace      = subword(     Env_TMP_Drive_SysDriveInfo,2,1)

 IF Env_TMP_Drive_FreeSpace  < Sum_SQLite_File_Size THEN,
    DO       
    Return_Code = 4
    SAY "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    SAY "UPSSV Sub3 004E Error: Free space on disk of the TMP Directory is to low"
    SAY "                       Free space on disk is       ="  RIGHT(Env_TMP_Drive_FreeSpace  ,15)           
    SAY "                       Sum of all files in your UP ="  RIGHT(Sum_SQLite_File_Size     ,15)  
    SAY "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    SIGNAL Program_End
    END

/********************************************************/
/* Check  Free Space on Disk of User Profile Save drive */
/********************************************************/

    User_Profile_Save_Drive_SysDriveInfo   = SysDriveInfo(IN_User_Profile_Save_Drive) 

    User_Profile_Save_Drive_FreeSpace      = subword(        User_Profile_Save_Drive_SysDriveInfo,2,1)

 IF User_Profile_Save_Drive_FreeSpace  < Sum_SQLite_File_Size THEN,
    DO       
    Return_Code = 5
    SAY "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    SAY "UPSSV Sub3 005E Error: Free space on disk of the User Profile Save Drive to low"
    SAY "                       Free space on disk is       ="  RIGHT(User_Profile_Save_Drive_FreeSpace ,15)           
    SAY "                       Sum of all files in your UP ="  RIGHT(Sum_SQLite_File_Size              ,15)  
    SAY "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    SIGNAL Program_End
    END

/*****************************************/
/* Check cases if the drive are the same */         
/*****************************************/

/*  case:  a = b = c  all on the same drive */
/********************************************/

 IF  Max_SQLite_Drive = Env_TMP_Drive,
   & Max_SQLite_Drive = IN_User_Profile_Save_Drive,
   THEN,
    DO    

     Max_Required_Drive_FreeSpace  =   Max_SQLite_File_Size + Max_SQLite_File_Size_add_Safety_Value, 
                                     + Sum_SQLite_File_Size, 
                                     + Sum_SQLite_File_Size        

     IF Max_SQLite_Drive_FreeSpace   <  Max_Required_Drive_FreeSpace  THEN,
       DO       
         Return_Code = 6
         SAY "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
         SAY "UPSSV Sub3 006E Error: Free space on disk of the User Profile / TMP / Save  drive to low"
         SAY "                       Free space on disk is       ="  RIGHT(Max_SQLite_Drive_FreeSpace            ,15)           
         SAY "                       Estimated space requirement ="  RIGHT(Max_Required_Drive_FreeSpace          ,15)
         SAY "                       Value of add Safty Margin   ="  RIGHT(Max_SQLite_File_Size_add_Safety_Value ,15)  
         SAY "                       Size of biggest SQLite File ="  RIGHT(Max_SQLite_File_Size                  ,15)
         SAY "                       Name of biggest SQLite File ="        Max_SQLite_File_Name  
         SAY "                       Sum of all files in your UP ="  RIGHT(Sum_SQLite_File_Size                  ,15)  
         SAY "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
         SIGNAL Program_End
       END
    END

/*  case:  a = b          on the same drive */
/*  case:  a = c          on the same drive */
/********************************************/

 IF    Max_SQLite_Drive = Env_TMP_Drive ,
    |  Max_SQLite_Drive = IN_User_Profile_Save_Drive THEN,
    DO 

     Max_Required_Drive_FreeSpace  =   Max_SQLite_File_Size + Max_SQLite_File_Size_add_Safety_Value, 
                                    + Sum_SQLite_File_Size, 
                                    + Sum_SQLite_File_Size        

    IF Max_SQLite_Drive_FreeSpace   <  Max_Required_Drive_FreeSpace  THEN,
       DO       
         Return_Code = 7
         SAY "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
         SAY "UPSSV Sub3 007E Error: Free space on disk of the User Profile / TMP or UP / Save drive to low"
         SAY "                       Free space on disk is       ="  RIGHT(Max_SQLite_Drive_FreeSpace        ,15)           
         SAY "                       Estimated space requirement ="  RIGHT(Max_Required_Drive_FreeSpace      ,15)
         SAY "                       Sum of all files in your UP ="  RIGHT(Sum_SQLite_File_Size              ,15)  
         SAY "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
         SIGNAL Program_End
       END
    END

/*  case:  b = c          on the same drive */
/********************************************/
 IF    Env_TMP_Drive    = IN_User_Profile_Save_Drive THEN,
    DO 

     Max_Required_Drive_FreeSpace  =  Sum_SQLite_File_Size, 
                                    + Sum_SQLite_File_Size        

    IF User_Profile_Save_Drive_FreeSpace   <  Max_Required_Drive_FreeSpace  THEN,
       DO       
         Return_Code = 8
         SAY "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
         SAY "UPSSV Sub3 008E Error: Free space on disk of the User Profile Save / TMP Drive to low"
         SAY "                       Free space on disk is       ="  RIGHT(User_Profile_Save_Drive_FreeSpace ,15)           
         SAY "                       Estimated space requirement ="  RIGHT(Max_Required_Drive_FreeSpace      ,15)
         SAY "                       Sum of all files in your UP ="  RIGHT(Sum_SQLite_File_Size              ,15)  
         SAY "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
         SIGNAL Program_End
       END
    END

 
/*++++++++++++++++++++*/
Program_End:
/*++++++++++++++++++++*/


Say  "Program End  : " GTS()  "Execution Time:" time("E") "sec"  "RC =" Return_Code

Return (Return_Code)

/*************************/
/* End of Main Procedure */ 
/*************************/

/****************************************/
FTS:  /* Format TimeStamp               */      
/****************************************/

TimeStamp_Raw = Arg(1)

PARSE VALUE TimeStamp_Raw  WITH FTS_jj "/" FTS_mm "/" FTS_tt "/" FTS_min "/" FTS_sec 

FTS_jjjj = 20 || substr(TimeStamp_Raw,1,2)

TimeStamp_Formated =  FTS_jjjj  || "-" || FTS_mm  || "-" || FTS_tt || " " || FTS_min || ":" ||  FTS_sec 


RETURN(TimeStamp_Formated) 

/****************************************/
GTS:  /* Get    TimeStamp               */      
/****************************************/


 Date_Option_S  = Date("S")  /* Date Format jjjjmmtt */

 Date_jjjjj     = SubStr(Date_Option_S,1,4)  
 Date_mm        = SubStr(Date_Option_S,5,2)  
 Date_tt        = SubStr(Date_Option_S,7,2)  


 Time_Option_N  = Time("N")  /* Time Format ss:mm:ss */


 TimeStamp_Formated =  Date_jjjjj || "-" || Date_mm  || "-" || Date_tt || " " || Substr(Time_Option_N,1,5) 


RETURN(TimeStamp_Formated) 

/************************************************************************************/
/* Overview of the Information / Warning / Errors / Sever Error Messages of program */ 
/************************************************************************************/
/*
  
   "UPSSV Sub3 001E Error: No SQLite Files found in User Profile"

   "UPSSV Sub3 002E Error: Free space on disk of the User Profile is to low"
   "                       Free Space on Disk is       ="  RIGHT(Max_SQLite_Drive_FreeSpace            ,15)           
   "                       Value of add Safty Margin   ="  RIGHT(Max_SQLite_File_Size_add_Safety_Value ,15)  
   "                       Size of biggest SQLite file ="  RIGHT(Max_SQLite_File_Size                  ,15)
   "                       Name of biggest SQLite file ="        Max_SQLite_File_Name  

   "UPSSV Sub3 003E Error: I cannot find a Environment Variable "TMP" in your Enviroment"

   "UPSSV Sub3 004E Error: Free space on disk of the TMP Directory is to low"
   "                       Free space on disk is       ="  RIGHT(Env_TMP_Drive_FreeSpace  ,15)           
   "                       Sum of all files in your UP ="  RIGHT(Sum_SQLite_File_Size     ,15)  

   "UPSSV Sub3 005E Error: Free space on disk of the User Profile Save Drive to low"
   "                       Free space on disk is       ="  RIGHT(User_Profile_Save_Drive_FreeSpace  ,15)           
   "                       Sum of all files in your UP ="  RIGHT(Sum_SQLite_File_Size               ,15) 

   "UPSSV Sub3 006E Error: Free space on disk of the User Profile / TMP / Save drive to low"
   "                       Free space on disk is       ="  RIGHT(Max_SQLite_Drive_FreeSpace            ,15)           
   "                       Estimated space requirement ="  RIGHT(Max_Required_Drive_FreeSpace          ,15)
   "                       Value of add Safty Margin   ="  RIGHT(Max_SQLite_File_Size_add_Safety_Value ,15)  
   "                       Size of biggest SQLite File ="  RIGHT(Max_SQLite_File_Size                  ,15)
   "                       Name of biggest SQLite File ="        Max_SQLite_File_Name  
   "                       Sum of all files in your UP ="  RIGHT(Sum_SQLite_File_Size     

   "UPSSV Sub3 007E Error: Free space on disk of the User Profile / TMP or UP / Save drive to low"
   "                       Free space on disk is       ="  RIGHT(User_Profile_Save_Drive_FreeSpace ,15)           
   "                       Estimated space requirement ="  RIGHT(Max_Required_Drive_FreeSpace      ,15)
   "                       Sum of all files in your UP ="  RIGHT(Sum_SQLite_File_Size              ,15)  
 
   "UPSSV Sub3 008E Error: Free space on disk of the User Profile Save / TMP drive to low"
   "                       Free space on disk is       ="  RIGHT(User_Profile_Save_Drive_FreeSpace ,15)           
   "                       Estimated space requirement ="  RIGHT(Max_Required_Drive_FreeSpace      ,15)
   "                       Sum of all files in your UP ="  RIGHT(Sum_SQLite_File_Size              ,15)  

*/
/************************************************************************************/
/* End of Code                                                                      */ 
/************************************************************************************/