/***************************************************************************/
/*  UPSSV-WPS-Object-Creation-REXX.cmd                                     */
/*                                                                         */
/*  Copyright 2008 Uwe Jacobs, Rainer D. Stroebel                          */ 
/*                                                                         */
/*                                                                         */
/*  Function:                                                              */
/*  Create WPS Folder and Program Objects for UPSSV Package                */
/*                                                                         */
/*                                                                         */
/*  Agruments passed from caller:                                          */
/*  UPSSV-Installer-This-cmd-requires-your-Modification.cmd                */
/*                                                                         */
/*  ARG variable                  value ( for example )                    */
/*  -------------------------------------------------------------------    */
/*  1  IN_UPSSV_Inst_Path         S:\UPSSV-v-1-0                           */
/*  2  IN_MOZILLA_DRIVE           S:                                       */
/*  3  IN_MOZILLA_DIR             MoF-3000                                 */
/*  4  IN_File_Name_Prefix        MoF-3000-P                               */
/*  5  IN_User_Profile_Prod_Path  S:\mof-3000\mozilla\Firefox\Profiles\xxxx.default */
/*  6  IN_User_Profile_Save_Drive P:                                       */
/*  7  IN_User_Profile_Save_Dir   MoF-3000-Save                            */
/*  8  IN_User_Profile_Name_Xfix  xxxx.default                             */
/*  9  IN_Firefox_UPSSV_Get_Options_Proc                                   */
/*                                                                         */
/* History:                                                                */
/* 0.1  2008-07-12 23.00 Intial creation of sample by code by Uwe          */
/* 0.2  2008-07-13 09.30 sampel code adapted by Rainer                     */
/* 0.3  2008-07-13 16.00 code debuged by Uwe                               */
/* 0.4  2008-07-13 18.00 add code for parse source and test against arg    */
/* 0.5  2008-07-13 20.00 add STARTUPDIR to Program Objects                 */
/* 0.6  2008-07-13 23.00 add New_Line Zeilenumbruch im Titel String        */
/* 0.7  2008-07-14 17.00 add Error handling - display more Information     */
/* 0.8  2008-07-16       add Obj  for Vacuum-Impact-History-File.txt       */
/* 0.9  2008-07-16 15.35 parse source --> parse upper source               */
/*                       Feedback Christian H.                             */
/* 0.10 2008-07-19 16.00 add Register to trademark names                   */
/*                       change Name of the OBJECTID of the Folder mit     */
/*                       IN_MOZILLADIR as part of the ID                   */ 
/* 0.11 2008-07-27       IN_MOZILLADIR as part of the Folder Title         */
/*                       add ICON s for Debbugging with Output redirection */
/*                       add Object ID to Program Object                   */
/* 0.12 2008-07-28       add IN_File_Name_Prefix                           */
/*                           IN_User_Profile_Name_Xfix Logik               */
/* 0.13 2008-07-30       change Folder Object ID                           */
/* 0.14 2008-08-03       add parm IN_Firefox_UPSSV_Get_Options_Proc        */
/*                                                                         */
/***************************************************************************/

  Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs';
  Call SysLoadFuncs;

  Return_Code = 0 

  parse upper source . . IN_theFilePath
  
  IN_theDir=FILESPEC('drive', IN_theFilePath)||FILESPEC('path', IN_theFilePath)

  say arg(1)

  PARSE UPPER ARG IN_UPSSV_Inst_Path,
                  IN_MOZILLA_DRIVE,
                  IN_MOZILLA_DIR,
                  IN_File_Name_Prefix,
                  IN_User_Profile_Prod_Path,
                  IN_User_Profile_Save_Drive,
                  IN_User_Profile_Save_Dir,
                  IN_User_Profile_Name_Xfix,
                  IN_Firefox_UPSSV_Get_Options_Proc

 IF IN_UPSSV_Inst_Path || "\"  \=  IN_theDir then,
        DO
        SAY "UPSSV WPSR 001E Error UPSSV_Inst_Path =" """" ||IN_UPSSV_Inst_Path || """" 
        say "is not qual to the source dir of this Rexx Procedure"
        say """" || IN_TheDir || """"  
        say IN_theFilePath "- I am abborting!"
        Return_Code = 2
        Return (Return_Code)
        END 

/********************************************************************************************/
/* Erzeugen: UPSSV-Firefox-3-0-Start-with-Lock-File-Handling-<SysID>.cmd                    */
/* copy      UPSSV-Firefox-3-0-Start-with-Lock-File-Handling-SysID-Template.cmd to <Traget> */
/********************************************************************************************/
 

 UPSSV_FF_Start_SysID_Template_FN   = "UPSSV-Firefox-3-0-Start-with-Lock-File-Handling-SysID-Template.cmd"
 UPSSV_FF_Start_SysID_Template_Abs  =  IN_UPSSV_Inst_Path || "\" || UPSSV_FF_Start_SysID_Template_FN

 UPSSV_FF_Start_SysID_FN            = "UPSSV-Firefox-3-0-Start-with-Lock-File-Handling-" || IN_File_Name_Prefix  || ".cmd"
 UPSSV_FF_Start_SysID_Abs           =  IN_UPSSV_Inst_Path || "\" || UPSSV_FF_Start_SysID_FN

                         

IF   STREAM(UPSSV_FF_Start_SysID_Template_Abs,'C','QUERY EXISTS') = "" ,
     THEN DO 
           SAY " "
           SAY "UPSSV WPSR 009E Error Template File" UPSSV_FF_Start_SysID_Template_Abs "does not exists" 
           say "The WPS Objects are not created, you have get the original file from the inst package"
           say "and rerun the programm"
           Return_Code = 3
           Return (Return_Code)
         End  

IF   STREAM(UPSSV_FF_Start_SysID_Abs,'C','QUERY EXISTS') \= "" ,
     THEN DO 
           SAY " "
           SAY "UPSSV WPSR 010I Information: The File" UPSSV_FF_Start_SysID_Abs "do exists" 
           say "I will not create a new one"
          End  
     ELSE  
          DO
          SAY " "
           SAY "UPSSV WPSR 011I Information: The File" UPSSV_FF_Start_SysID_Abs "do not exists" 
           say "I will create a new one by copying from the Template File", 
                UPSSV_FF_Start_SysID_Template_Abs   

           copy UPSSV_FF_Start_SysID_Template_Abs,
                UPSSV_FF_Start_SysID_Abs  
       End  

/*********************************************************************************************/


 UPSSV_ObjectID_FLD         =  "UPSSV" || IN_MOZILLA_DIR || IN_User_Profile_Name_Xfix || "LFD"

 UPSSV_ObjectID_PGM         =  "UPSSV" || IN_MOZILLA_DIR || IN_User_Profile_Name_Xfix 

 
 UPSSV_Titel_System_ID      =  IN_MOZILLA_DIR

 UPSSV_Titel_User_ID        =  IN_User_Profile_Name_Xfix
 
 UPSSV_Titel_System_User_ID =  UPSSV_Titel_System_ID     || "-" || UPSSV_Titel_User_ID


 New_Line="0A"X

 UPSSV_Folder_Titel = "UPSSV 1.0"    || New_Line  , 
                                     || "User Profile Save and SQLite Vacuum"              || New_Line,
                                     || "for Firefox© 3.0"                                 || New_Line,  
                                     || UPSSV_Titel_System_User_ID

                                          /* WPS Program Objects definieren,
                                             bitte ÅberflÅssige Daten entfernen.
                                             jedoch BITTE als letzten Eintrag
                                             ein leeres Item anbieten 
                                           */ 

 WPS_Prog_Titel.1 =  "UPSSV"         || New_Line  ,
                                     || UPSSV_Titel_System_User_ID || New_Line  ,                                    
                                     || "Save and Vacuum"
			 

 WPS_Prog_PGM.1   =  "EXENAME="      || IN_UPSSV_Inst_Path || "\",
                                     || "UPSSV-Main-User-Profile-Save-and-SQLite-Vacuum.cmd",
                                     ||  ";", 
                  || "PARAMETERS="   || IN_MOZILLA_DRIVE,
                                        IN_MOZILLA_DIR,
                                        IN_File_Name_Prefix, 
                                        IN_User_Profile_Prod_Path,
                                        IN_User_Profile_Save_Drive, 
                                        IN_User_Profile_Save_Dir,
                                        IN_User_Profile_Name_Xfix,
                                     || ";",
                  || "STARTUPDIR="   || IN_UPSSV_Inst_Path,
                                     || ";",
                  || "OBJECTID="     || "<" || UPSSV_ObjectID_PGM  || "1" || ">",
                                     || ";"


 WPS_Prog_Titel.2 =  "UPSSV"         || New_Line,
                                     || UPSSV_Titel_System_User_ID || New_Line,
                                     || "Execution Log last" 


 WPS_Prog_PGM.2   =  "EXENAME="      || "e.exe", 
                                     ||  ";", 
                  || "PARAMETERS="   || IN_MOZILLA_DRIVE           || "\",
                                     || IN_MOZILLA_DIR             || "\", 
                                     || IN_File_Name_Prefix        || "-",        
                                     || IN_User_Profile_Name_Xfix, 
                                     ||  "-Vacuum-Log-Gen-minus-0",
                                     || ";",
                  || "OBJECTID="     || "<" || UPSSV_ObjectID_PGM  || "2" || ">" ,
                                     || ";"  


 WPS_Prog_Titel.3 =  "UPSSV"         || New_Line  ,
                                     || UPSSV_Titel_System_User_ID || New_Line  ,
                                     || "Vacuum Impact History" 


 WPS_Prog_PGM.3   =  "EXENAME="      || "e.exe", 
                                     ||  ";" , 
                  || "PARAMETERS="   || IN_MOZILLA_DRIVE           || "\",
                                     || IN_MOZILLA_DIR             || "\", 
                                     || IN_File_Name_Prefix        || "-",
                                     || IN_User_Profile_Name_Xfix,
                                     || "-Vacuum-Impact-History-File.txt",
                                     || ";" ,
                  || "OBJECTID="     || "<" || UPSSV_ObjectID_PGM  || "3" || ">" ,
                                     || ";"  


 WPS_Prog_Titel.4 =  "UPSSV Support" || New_Line ,
                                     || UPSSV_Titel_System_User_ID || New_Line,  
                                     || "Execution Log temporary"  || New_Line,
                                     || "to check after abend"  


 WPS_Prog_PGM.4   =  "EXENAME="      || "e.exe", 
                                     ||  ";" , 
                  || "PARAMETERS="   || IN_MOZILLA_DRIVE           || "\",
                                     || IN_MOZILLA_DIR             || "\", 
                                     || IN_File_Name_Prefix        || "-", 
                                     || IN_User_Profile_Name_Xfix,
                                     || "-Vacuum-Log-TMP-Run",
                                     || ";" ,
                  || "OBJECTID="     || "<" || UPSSV_ObjectID_PGM  || "4" || ">" ,
                                     || ";"  

 
                                          
 WPS_Prog_Titel.5 =  "UPSSV Mod"     ||  New_Line ,
                                     ||  UPSSV_Titel_System_ID                   || New_Line , 
                                     ||  "Firefox© Start with Lock Procedure"    || New_Line ,
                                     ||  "Customization requried"  


 WPS_Prog_PGM.5   =  "EXENAME="      || "e.exe", 
                                     ||  ";" , 
                  || "PARAMETERS="   || UPSSV_FF_Start_SysID_Abs,
                                     || ";" ,
                  || "OBJECTID="     || "<" || UPSSV_ObjectID_PGM  || "6" || ">" ,
                                     || ";"  

              
 WPS_Prog_Titel.6 =  "UPSSV Mod"     ||  New_Line ,
                                     ||  UPSSV_Titel_System_ID                   || New_Line,
                                     ||  "Firefox© Start  with Lock Procedure"    
                                    
  
 WPS_Prog_PGM.6   =  "EXENAME="      || "*", 
                                     || ";" ,    
                 || "PROGTYPE="      || "WINDOWABLEVIO",
                                     || ";",
                 || "PARAMETERS="    || "/C ",
                                     || "set Firefox_UPSSV_Get_Options_Proc=",
                                     || IN_UPSSV_Inst_Path         || "\",                                     
                                     || IN_Firefox_UPSSV_Get_Options_Proc,
                                     || "&",                             
                                     || UPSSV_FF_Start_SysID_Abs,
                                     ||  ";" , 
                  || "STARTUPDIR="   || IN_MOZILLA_DRIVE           || "\",
                                     || IN_MOZILLA_DIR ,
                                     || ";" ,
                  || "OBJECTID="     || "<" || UPSSV_ObjectID_PGM  || "7" || ">" ,
                                     || ";"  

 
 WPS_Prog_Titel.7 =  "UPSSV Support" ||  New_Line , 
                                     ||  UPSSV_Titel_System_ID     || New_Line,
                                     || "Lock File Delete"  
          
			 
 WPS_Prog_PGM.7   =  "EXENAME="      || IN_UPSSV_Inst_Path         || "\",
                                     || "UPSSV-Lock-File-Delete.cmd",
                                     ||  ";" , 
                  || "PARAMETERS="   || IN_MOZILLA_DRIVE   ,
                                        IN_MOZILLA_DIR     ,
                                        IN_File_Name_Prefix,             
                                     || ";", 
                  || "STARTUPDIR="   || IN_MOZILLA_DRIVE           || "\",
                                     || IN_MOZILLA_DIR ,
                                     || ";" ,
                  || "OBJECTID="     || "<" || UPSSV_ObjectID_PGM  || "5" || ">" ,
                                     || ";"  



 WPS_Prog_Titel.8 =  "UPSSV Support" ||  New_Line  ,
                                     ||  UPSSV_Titel_System_User_ID       || New_Line,
                                     || "Save and Vacuum"                 || New_Line,
                                     || "with Output Redirection to File" || New_Line,
                                     || "for debugging"               
 

 WPS_Prog_PGM.8   =  "EXENAME="      || "*", 
                                     || ";" , 
                 || "PROGTYPE="      || "WINDOWABLEVIO",
                                     || ";",
                 || "PARAMETERS="    || "/C ",
                                     || IN_UPSSV_Inst_Path || "\",
                                     || "UPSSV-Main-User-Profile-Save-and-SQLite-Vacuum.cmd",
                                        IN_MOZILLA_DRIVE,
                                        IN_MOZILLA_DIR,
                                        IN_File_Name_Prefix, 
                                        IN_User_Profile_Prod_Path,
                                        IN_User_Profile_Save_Drive, 
                                        IN_User_Profile_Save_Dir,
                                        IN_User_Profile_Name_Xfix,
                                        ">" IN_MOZILLA_DRIVE              || "\", 
                                     ||     IN_MOZILLA_DIR                || "\",
                                     ||     IN_File_Name_Prefix           || "-",
                                     ||     IN_User_Profile_Name_Xfix     || "-",                                      
                                     || "console.txt 2>&1 ",
                                     || ";",
                  || "STARTUPDIR="   || IN_UPSSV_Inst_Path ,
                                     || ";" ,
                  || "OBJECTID="     || "<" || UPSSV_ObjectID_PGM  || "8" || ">" ,
                                     || ";"                    


 WPS_Prog_Titel.9 =  "UPSSV Support" ||  New_Line ,
                                     ||  UPSSV_Titel_System_User_ID       || New_Line  ,
                                     || "Save and Vacuum"                 || New_Line,
                                     || "Output File of the Redirection"                                       
                

 WPS_Prog_PGM.9   =  "EXENAME="      || "e.exe", 
                                     ||  ";" , 
                  || "PARAMETERS="   || IN_MOZILLA_DRIVE                  || "\",
                                     || IN_MOZILLA_DIR                    || "\", 
                                     || IN_File_Name_Prefix               || "-",
                                     || IN_User_Profile_Name_Xfix         || "-", 
                                     || "console.txt",
                                     || ";" ,
                  || "OBJECTID="     || "<" || UPSSV_ObjectID_PGM  || "9" || ">" ,
                                     || ";"    


WPS_Prog_Titel.10 =  "UPSSV"         ||  New_Line ,
                                     ||  "ReadMe"

WPS_Prog_PGM.10   =  "EXENAME="      || "e.exe", 
                                     ||  ";" , 
                  || "PARAMETERS="   || IN_UPSSV_Inst_Path  || "\",
                                     || "readme.txt", 
                                     || ";" ,
                  || "OBJECTID="     || "<" || UPSSV_ObjectID_PGM  || "10" || ">" ,
                                     || ";"  


 WPS_Prog_Titel.11 = ""
 WPS_Prog_PGM.11   = ""

                                                           /* Folder anlegen  */

 WPS_Shadow_Daten.1 = IN_UPSSV_Inst_Path  || "\README.TXT"  
 WPS_Shadow_Daten.2 = ""

 Return_Code = 0 


  FolderRef             = "OBJECTID=" ||"<" || UPSSV_ObjectID_FLD || ">"|| ";"   

say " "
say "FolderRef=" FolderRef

  if SysCreateObject("WPFolder",
                     ,UPSSV_Folder_Titel,
                     ,"<WP_DESKTOP>",
                     ,"OBJECTID=" ||"<" || UPSSV_ObjectID_FLD || ">"|| ";",
                     ,"R"),
   Then                                                                     /*  Programme anlegen */ 
    DO i = 1 to 15
      if WPS_Prog_PGM.i    = "" then LEAVE 
      rc=SysCreateObject("WPProgram",WPS_Prog_Titel.i,"<" || UPSSV_ObjectID_FLD || ">",WPS_Prog_PGM.I,"R");
      if rc = 0 then do
                     Say "UPSSV WPSR 002S Error SysCreateObject " WPS_Prog_Titel.i WPS_Prog_PGM.I
                     Return_Code = 3
                     Return (Return_Code)
                     end;
    End i;
  else
    DO
    SAY "UPSSV WPSR 004S Error Create Folder rc=" rc
    Return_Code = 3
    Return (Return_Code) 
    end;

/*******************************************************************/
/* Erzeugen SysModTest-<SysID>                                     */
/* copy SysModTest-SysID-Template to  SysModTest-<SysId>           */
/*******************************************************************/

 UPSSV_SysModTest_SysID_Template_FN   = "UPSSV-SysModTest-SysID-Template"
 UPSSV_SysModTest_SysID_Template_Abs  =  IN_UPSSV_Inst_Path || "\" || UPSSV_SysModTest_SysID_Template_FN

 UPSSV_SysModTest_SysID_FN            = "UPSSV-SysModTest-" || IN_File_Name_Prefix
 UPSSV_SysModTest_SysID_Abs           =  IN_UPSSV_Inst_Path || "\" || UPSSV_SysModTest_SysID_FN

 UPSSV_SysModProd_SysID_FN            = "UPSSV-SysModProd-" || IN_File_Name_Prefix
 UPSSV_SysModProd_SysID_Abs           =  IN_UPSSV_Inst_Path || "\" || UPSSV_SysModProd_SysID_FN


IF   STREAM(UPSSV_SysModTest_SysID_Template_Abs,'C','QUERY EXISTS') = "" ,
     THEN DO 
           SAY " "
           SAY "UPSSV WPSR 005E Error Template File" UPSSV_SysModTest_SysID_Template_Abs "does not exists" 
           say "The WPS Object are created, you have get the original file from the inst package"
           say "delete the WPS Folder and rerun the programm"
           Return_Code = 2
           Return (Return_Code)
         End  

IF   STREAM(UPSSV_SysModProd_SysID_Abs,'C','QUERY EXISTS') \= "" ,
     THEN DO 
           SAY " "
           SAY "UPSSV WPSR 006I Information: The File" UPSSV_SysModProd_SysID_Abs "do exists" 
           say "I am deleteing the File"
           del UPSSV_SysModProd_SysID_Abs
         End  

IF   STREAM(UPSSV_SysModTest_SysID_Abs,'C','QUERY EXISTS') \= "" ,
     THEN DO 
           SAY " "
           SAY "UPSSV WPSR 007I Information: The File" UPSSV_SysModTest_SysID_Abs "do exists" 
           say "I will not create a new one"
          End  
     ELSE  
          DO
          SAY " "
           SAY "UPSSV WPSR 008I Information: The File" UPSSV_SysModTest_SysID_Abs "do not exists" 
           say "I will create a new one by copying from the Template File", 
                UPSSV_SysModTest_SysID_Template_Abs   
           copy UPSSV_SysModTest_SysID_Template_Abs,
                UPSSV_SysModTest_SysID_Abs  
       End  

/**************************************************************************************************/


Return (Return_Code)  /* end of main procedure */ 

/************************************************************************************/
/* Overview of the Information / Warning / Errors / Sever Error Messages of program */ 
/************************************************************************************/
/*
    "UPSSV WPSR 001E Error UPSSV_Inst_Path =" """" ||IN_UPSSV_Inst_Path || """" 
                           "is not qual to the source dir of this Rexx Procedure"
                            """" || IN_TheDir || """"  
                            IN_theFilePath "- I am abborting!"

    "UPSSV WPSR 002S Error SysCreateObject " WPS_Prog_Titel.i WPS_Prog_PGM.I

    "UPSSV WPSR 004S Error Create Folder rc=" rc

    "UPSSV WPSR 005E Error Template File" UPSSV_SysModTest_SysID_Template_Abs "does not exists"  

    "UPSSV WPSR 006I Information: The File" UPSSV_SysModProd_SysID_Abs "do exists" 
                             "I am deleteing the File"
    "UPSSV WPSR 007I Information: The File" UPSSV_SysModTest_SysID_Abs "do exists" 
                             "I will not create a new one"
    "UPSSV WPSR 008I Information: The File" UPSSV_SysModTest_SysID_Abs "do not exists" 
                             "I will create a new one by copying from the Template File", 

    "UPSSV WPSR 009E Error Template File" UPSSV_FF_Start_SysID_Template_Abs "does not exists" 
                             "The WPS Objects are not created, you have get the original file from the inst package"
                             "and rerun the programm"

    "UPSSV WPSR 010I Information: The File" UPSSV_FF_Start_SysID_Abs "do exists" 
                            "I will not create a new one"

    "UPSSV WPSR 011I Information: The File" UPSSV_FF_Start_SysID_Abs "do not exists" 
                            "I will create a new one by copying from the Template File", 
*/
/************************************************************************************/
/* End of Code                                                                      */ 
/************************************************************************************/