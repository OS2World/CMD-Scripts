

User Profile Save and SQLite Vacuum ( UPSSV ) for Firefox© 3.0

Copyright 2008  Rainer D. Stroebel



UPSSV V 1.0 RC 3 
2008-08-05  13.50


Reame.txt 



0.    Summary

      Start with release 3.0 Firefox administer user profile data
      by SQLite databases. SQL databases requires maintenance schedules for
      physical reorganisation of the databases. This task -
      for some of the profile databases -  is triggered by Firefox ( online ),
      if an idle status of the system is detected.
      UPSSV offers the user a batch function of reorganisation (SQL Vaccum) 
      all of the database of the user profile at downtime of the
      browser at his own convenience. UPSSV required execution time 
      of about 120 sec on my test system (ThinkPad T23 1.13 GHz HPFS).  

      Warning:
      Read the Readme! Follow the installation procedure.
      UPSSV will only work, if you do the right steps! 

1.   Contents of the Package

      Change.log
      COPYING
      Readme.txt - this File
      UPSSV-Caps-Remove-Directory.CMD       
      UPSSV-Caps-SQLite3.cmd
      UPSSV-Firefox-3-0-Start-with-Lock-File-Handling-SysID-Template.cmd    
      UPSSV-Inst-One-per-Firefox-System-per-UserProfile-Template-INI.cmd

            Installer: Both Templates requires your Action !!

      UPSSV-Lock-File-Delete.cmd
      UPSSV-Main-User-Profile-Save-and-SQLite-Vacuum.cmd
      UPSSV-Messages-and-Codes.txt
      UPSSV-Sub1-User-Profile-SQLite-init-Option-File.SQL
      UPSSV-Sub1-User-Profile-SQLite-Vacuum-the-DB-s.cmd
      UPSSV-Sub2-User-Profile-Save-to-Generation-Dir.cmd
      UPSSV-Sub3-User-Profile-Disk-Free-Space-Check-REXX.cmd
      UPSSV-Subx-Create-Append-File-with-Timestamp-as-Contents.cmd      
      UPSSV-Subx-Leerzeile.txt
      UPSSV-SysModTest-SysId-Template
      UPSSV-WPS-Folder-for-Production-Example.jpg       
      UPSSV-WPS-Object-Creation-REXX.cmd
      UPSSV-WPS-Object-Creation.cmd


2.   Function

      1.  Test and set Semaphore ( Lock-File ) for prevention of concurrent processing
      2.  If the Test is negative --> Error MSG Pause --> entry any Key --> EXIT
      3.  Save the User Profile ( Prod ) to Generation Directory (N=0 to 3 )
      4.  Vacuum all SQLite Files of the FF 3.0 User Profile ( Prod )
      5.  Write Temporary Process Log File to Generation Logs (N=0 to  3) 
      6.  Append information to the current run to the "Vacuum Impact History" File

      A Semaphore ( Lock-File ) is realised to prevent the start of the browser
      during maintenance and
      the start of the maintenance during an active browser session.

      n generations of Backup of the Profile are automatically maintained. 
      N =3 (N=0 to 3)  is realised in code, can be adapted by adding two line of code
      for each additional  generation
 
      n generations of logs of a maintenance session are retained.
      N = 3 (N=0 to 3) are currently administrated

****  Multi Systems (Firefox versions ) and  User Profiles are supported
      new with RC 3 

3.   Dependences / Prerequisites

3.1  SQLite 3.5.9 OS/2 Port from Peter Weilbacher on Hobbes  

      http://hobbes.nmsu.edu/cgi-bin/h-search?sh=1&button=Search&key=Sqlite359&stype=all&sort=type&dir=%2F

      By default UPSSV expects to find SQLite by the current Path and LibPath 

     Tests with SQLite 3.6.0 do work. 


3.2  RM on Hobbes

     A clone of the UNIX RM utility 	2000/01/04  by  Don Hawkinson

     http://hobbes.nmsu.edu/pub/os2/util/file/rm.zip 

     Function:
      A command line file and directory removal program.
      It will remove subdirectories and files including those
      that are marked as read-only and hidden.
      The subdirectories do not need to be empty.     

      By default UPSSV expects to find rm.exe  via env Path 


3.3  The package has been tested with OS/2 MCP2 Fixpak 05,
     Firefox 3.0 GA and 3.01 GA.

     If you replace the RM function with a Windows implemented function
     "Remove a Directory with Contents" the code should run Windows too.
     The creation of WPS Objects is for OS/2 only. 
        

3.4   Directory Structure of the Firefox Installation on your system

      example:

      s:\MoF-3000\mozilla\firefox\.......      

      We recommend to use the "MoF-3000" directory as location
      for the lock file, the log files and the Vaccum Impact Histroy 
      File of UPSSV. ( see 5.2 )

3.5   Firefox 3.0 GA version performance issue   

      This applies only for the 3.0 GA version.

      Firefox 3.0.1  contains the improvement.  

      https://bugzilla.mozilla.org/show_bug.cgi?id=439340
 
      Change the preference  

          urlclassifier.updatecachemax from -1 to 104857600

         (via using about:config).

      This is not required for running UPSSV. It is
      recommendation for your Firefox 3.0 GA configuration. 


4.    Resource Requirements - Execution Time and HDD Disk Space 

4.1   Test environment / test bed
      
       Current Size of my Firefox 3.0 User Profile is
 
         56 MB ( without the FF disk cache data )

       Size after Vacuum function

       2008-07-09  12.02    4.603.904           0  places.sqlite
       2008-07-08  12.02   30.810.112           0  urlclassifier3.sqlite

4.2    Execution Time - Performance on a Thinkpad T23 1.13 GHz - HPFS

          Start of Job Systemzeit: 12.02.13,48
          End   of Job Systemzeit: 12.03.00,51
          Execution Time of Job  : 00.00.47,03

          The execution time is the "empty" execution time.
          This is done on a well physical organized, compacted SQLite DB s.
          The vacuum job has been run for testing of 
          the Vacuum and Backup Function of the procedure several times before.

          The current execution time is 120 sec with the additional SQL statements

           -- PRAGMA integrity_check; 
           ANALYZE;
 
4.3    Disk requirement of the Procedure:

4.3.1  Temporary working space for the vacuum function:
       on the same drive as the profile
         max size from any of SQLite files = 

         about   55 MB  

4.3.2  Disk space for 4 generations of User Profile Backup:

         56 MB x 4 = 224 MB

4.3.3  The available disk space is checked by the subroutine 

       UPSSV-Sub3-User-Profile-Disk-Free-Space-Check-REXX.cmd

       UPSSV Save and Vacuum checks the free disk space.
       Insufficient space will be reported and the program terminated.        


5.    Installation

5.1    Unzip the package to a program directory 
            
       Example:

           unzip UPSSV-v-1-0.zip -D S:\UPSSV-v-1-0

5.2    Options of UPSSV

5.2.1  Definition of the Options requiering Customizition

       The following options has to be customized for running UPSSV.
       The rest of options are the hard coded and uses default values.
      
       For every System (Firefox Installation ) and  User Profile 
       a set of options is required!

        NO  Internal Name                     sample value
        -------------------------------------------------------------------------------- 
         1  UPSSV_Cus_Inst_Path               S:\UPSSV-v-1-0
         2  UPSSV_Cus_MOZILLA_DRIVE           S:
         3  UPSSV_Cus_MOZILLA_DIR             MoF-3000
         4  UPSSV_Cus_File_Name_Prefix        MoF-3000-Pre
         5  UPSSV_Cus_User_Profile_Prod_Path  S:\mof-3000\mozilla\Firefox\Profiles\xxxx.default
         6  UPSSV_Cus_User_Profile_Save_Drive P:
         7  UPSSV_Cus_User_Profile_Save_Dir   MoF-3000-Save
         8  User_Profile_Name_Xfix            User.default  

        ================================================================

         1  UPSSV_Cus_Inst_Path               S:\UPSSV-v-1-0       
 
            Program directory of UPSSV  

         2  UPSSV_Cus_MOZILLA_DRIVE           S:
         3  UPSSV_Cus_MOZILLA_DIR             MoF-3000 
 
            Defines the location of the Lock File,
            the Vacuum Generation Log (VLG) Files 
            and the Vacuum Impact History File.

         4  UPSSV_Cus_File_Name_Prefix        MoF-3000-Pre

            Defines the File Name Prefix of the
 
               Lock File 
               Vacuum Generation Log (VLG) Files 
               Vacuum Impact History File
               UPSSV-Lock-SysMod-Test File
               UPSSV-Lock-SysMod-Prod File

            This name has to be unique over all installed Firefox Systems.
            --------------------------------------------------------------
            Otherwise the SysModTest SysModProd test does not work per System!
            The function SysMod is documented above in paragraph 5.5.
            The value is used as <Sysid>.
 

         5  UPSSV_Cus_User_Profile_Prod_Path    

            Defines the input, the location of the
            FF 3.0 User Profile to be saved and 
            the SQLite File of the User Profile to be compacted ("Vacuum") 

         6  UPSSV_Cus_User_Profile_Save_Drive   P:
         7  UPSSV_Cus_User_Profile_Save_Dir     MoF-3000-Save

            Defines the output, the location of the
            generation directories of the User Profile Backup.
  
            If the directory does not exits, you have to create/make it!  
            ------------------------------------------------------------

         8  UPSSV_Cus_User_Profile_Name_Xfix    xxxx.default 
   
            Defines the "mid-fix" Name for 
 
                the Vacuum Generation Log (VLG) Files 
                and the Vacuum Impact History File.
      
            Defines the "prefix" for the generation directories  
            of the User Profile Backup. 

           This value has to be unique within <SysID>!
           -------------------------------------------
           the value is used as <UserID>

    
5.2.2  Howto define this options 
       +++++++++++++++++++++++++

       Customize the Template 
     
           UPSSV-Inst-One-per-Firefox-System-per-UserProfile-Template-INI.cmd

       and save/create a file 

            UPSSV-Inst-<SysId>-<UserID>-INI.cmd
        
       in the UPSSV program directory
       for every System / User Profile you want to process with UPSSV 


5.3    WPS: Create an Folder and the following Program Objects

       Creation of WPS Objects for each System/UserProfile with the input of
       the UPSSV...INI.CMD file
       
        Execute from the UPSSV directory as current dir

         UPSSV-WPS-Object-Creation.cmd  UPSSV-Inst-<SysId>-<UserID>-INI.cmd

       The ...INI.cmd file is parameter 1 to the ... Creation.cmd execution.  

       UPSSV-WPS-Object-Creation.cmd get read the       
       customized option values of "UPSSV-Inst-<SysId>-<UserID>-INI.cmd"
       and do plausibility tests.
 
       If the tests are positive, the values are passed to the Module

           "UPSSV-WPS-Object-Creation-REXX.cmd" 

       The module  creates a Folder 

             "UPSSV 1.0 User Profile Save and SQLite Vacuum for Firefox 3.0 <SysId>-<UserID>"

       on the desktop. 

       The Folder contains the following Objects based on the values, you entered in
       Module "UPSSV-Inst-<SysId>-<UserID>-INI.cmd". 
 
       A file UPSSV-SysModTest-<SysID> is created from the template, it the file does not exist.    
       If the the File UPSSV-SysModProd-<SysID> exist, the file is deleted.    

       If the File UPSSV-Firefox-3-0-Start-with-Lock-File-Handling-<SysId>.cmd  does not exist,
       the file is created for the template.


       This installation method is a balance between investment for packaging and usability
       of the installation process. The next release may make use of WarpIn :-).  



5.3.1  WPS Objects for normal production execution: 

           "UPSSV <SysId>-<UserID>  Save and Vacuum "

           "UPSSV <SysId>-<UserID>  Execution Log last"

           "UPSSV <SysId>-<UserID>  Vacuum Impact History File"
 
 
5.3.2  WPS Object for your start Firefox modification

           "UPSSV Mod <SysId> - Firefox© Start with Lock Procedure"

           "UPSSV Mod <SysId> - Firefox© Start with Lock Procedure
                              - Customization requried"


5.3.2  WPS Object for Support 

          "UPSSV Readme" 

          "UPSSV Support <SysId>-<UserID> Execution Log Temporary to check after ABEND"
                           "
          "UPSSV Support <SysId> Delete Lock File"

          "UPSSV Support <SysId>-<UserID> Save and Vacuum
                                          with Output Redirection to File
                                          for debugging" 

          "UPSSV Support <SysId>-<UserID> Save and Vacuum
                                          Output File of the Redirection"  
                

5.3.4  After creation of the folder and the program objects, please arrange the objects
       in the folder according to the JPG in the UPSSSV program directory .
       The icons are positioned by functional groups/view.


5.4    Encapsulate your Firefox start - add "Test and Set Semaphore (Lock-File)" Function
   
       Use the created copy of the template and add/modify your Firefox start statements.    

       The Object "UPSSV Mod  <SysId> Firefox© Start with Lock Procedure - Customization requried" 
       calls the System Editor for modification of 

             "UPSSV-<SysId> Firefox-3-0-Start-with-Lock-File-Handling-<SysId>.cmd"   

       This procedure reads the options by exeucting the UPSSV-Inst-<SysId>-<UserID>-INI.cmd
       you created in 5.2.2. 


5.5    Test the Lock Mechanismus

       The USPPV and the Firefox Start Procedure are running in "SysModTest"
       by default after the installation.
       In "SysModTest" the Lock will be  set and the execution stops with a pause.
       The main task "Save and Vacuum"  or "Firefox Browser" are not executed 
       in "SysModTest", only in "SysModProd"!

       A addtional, new User <UserID> of an existing System <SysID> will reset the
       system <SysID> to SysModTest at creation of the WPS Objects for the <SysID>-<UserID>


5.5.1  Test 1: USPSSV Running and attempting to start Firefox

       Start the "UPSSV "UPSSV <...> User Profile Save and SQLite Vacuum for FF 3.0"
       procedure.

       The procedure will stop/pause with the Lock (Semaphore) set!

           UPSSV FFSRT 002A SysModTest Stopping for "Start Test of UPSSV Save and Vacuum"
                                       The UPSSV Start should be denied!

      Now you can start/test your new encapsulated start procedure for FF 3.0.

      The FF start procedure should display the message:

           UPSSV FFSRT 003I Lock file exists - File: "%MoF_Lock_File%"     
                            You just try to Start this CMD while a concurrent CMD is running!

       and the procedure will end after quitting the msg.
 
       Before ending the UPSSV  procedure just scroll the windows 10 lines up 
       by  scrollbar and check the displayed program options.
       Are the values correct? No, than delete the UPSSV Folder
       and go back to 5.3.

       Now end the "UPSSV Save and Vacuum"  procedure ( in active waiting mode ) by entering any key.


5.5.2  Test 2: Firefox running and attempting to start UPSSV   

       Start the our new "encapsulated  Firefox 3.0 start procedure"

       In SysModTest the browser is not started! 
      
       The procedure will stop with the Lock (Semaphore) set.
       Now you can start UPSSV.

       The UPSSV start procedure should display a message and after quitting the message 
       the procedure ended.
       Now end the Firefox start procedure ( in "active" waiting mode ) by entering any key.
 
5.5.3  Switching the System from Test to Production Mode
 
       If and only if  Test 1 and Test 2 are positive, than you can switch the system
       from SysModTest to SysModProd.
 
       If the tests failed, you have to debug the procedure!

       In the UPSSV program directory rename  the file "UPSSV-SysModTest-<SysID>" to "UPSSV-SysModProd-<SysID>".
   
       After the rename the system is in Production Mode.       


5.6    Make a backup of your user profile 

       Just to be on the safe side.
       I have not needed my backup during the development and test phase.
       The backup can be deleted after a positive check of the UPSSV results. 
                                          
5.7    Run UPSSV and control the results   
    
5.7.1  Now UPSSV execute in "Production mode" 

5.7.2  Check for the existence of <SysId>-<UserID> TMP Run log in %UPSSV_Cus_MOZILLA_DIR% 
 
         If present, the procedure is not terminated normaly.
  
         There are bugs in the installation process! 
      
         Failed delete/rename of generation files are okay up to the 4 th success full run
 
         Check the log, identify the problem and correct it

         You may have to delete the lock file before the next test.


5.7.3  Check the <SysId>-<UserID> gen-minus-0 log for Error 

         Failed delete rename of generation files are okay up to the 4 th success full run
 
         Check the log, does error exists, identify the problem and correct it
 
        
5.7.4  Check the output

        are the generation log file written?
        are the generation save user Profile directories present? 
        are the Vacuum Impact History File created / appended?

        example:
 
          [S:\mof-3000]dir *log*

          16.07.08  15.11      55408           0  MoF-3000-Pref-User...Vacuum-Log-Gen-minus-0
          16.07.08  15.09      55370           0  MoF-3000-Pref-User...Vacuum-Log-Gen-minus-1
          16.07.08  15.05     166185           0  MoF-3000-Pref-User...Vacuum-Log-Gen-minus-2
          16.07.08  11.23      55413           0  MoF-3000-Pref-User...Vacuum-Log-Gen-minus-3


          [S:\mof-3000]dir *impact*

          16.07.08  15.11      19572           0  MoF-3000-Pref-User..Vacuum-Impact-History-File.txt

  
          [P:\]dir mof-3000-save

          16.07.08  15.10      <DIR>           0  User...-Gen-minus-0
          16.07.08  15.08      <DIR>           0  User...-Gen-minus-1
          16.07.08  15.04      <DIR>           0  User...-Gen-minus-2
          16.07.08  15.01      <DIR>           0  User...-Gen-minus-3
        
  
8. Tips and Hints 

8.1  Debug UPPSV 

     Execute the main procedure with output redirection 

     There are two WPS Pbjects to support this test:


       "UPSSV Support <SysId>-<UserID> Save and Vacuum
                                       with Output Redirection to File
                                       for debugging" 

       "UPSSV Support <SysId>-<UserID> Save and Vacuum
                                       Output File of the Redirection"  
            
     Run the procedure and check contents of the output file console.txt,
     identify the problem and correct it.
     While running the "Save and Vacuum" with Redirection, a blank screen is display,
     If the system does not have HDD I/O, just do "blind" enter to end the procedure.  
        

8.2  Encapsulation of the Remove Directory Function

     Module: UPSSV-Caps-Remove-Directory.CMD       
    
     If your system supports the remove of a full directory,
     your can replace "rm.exe" and use your system function. 


8.3  Encapsulation of SQLite

      Module: UPSSV-Caps-SQLite3.cmd

     For example by modification you can   
       
         Test with a different SQLite version, 
       
         SQLite is not part of the standard path and libpath
    
     You can modify the current module or 
     make an copy, change the code according your requirements or
     call a new, different module by changing
     the value of the parameter"CAPS_SQLite" in the main procedure.   


8.4  Encapsulation of User Profile Backup

     Module: UPSSV-Sub2-User-Profile-Save-to-Generation-Dir.cmd

     Currently the User Profile is copied to the generation backup by
     the "xcopy" function. If your disk cache is part of the profile
     director (Which is the FF standard ), the cache subdir is part
     of the xcopy. The cache dir of the Backup is then deleted.

     This can be improved. A task for the next release :-)


8.5  Adaption of the Main Procedure to meet your special requirements  

      Module: UPSSV-Main-User-Profile-Save-and-SQLite-Vacuum.cmd

    The see code section for customization. The code is designed to be adaptable.  


8.6  Location of the cache directory for a user - best practice

     The cache data are volatile and no need for save/backup.
     To maintain on a separate drive for volatile files is recommended.
     The system drive should be mostly "read only".
     So the physical files system organisation is maintained at the best
     performance level and it not "polluted" by creation and delete operation of 
     temporary files.

     Hwoto define the location of the cache directory?

     Use/add the preference

             browser.cache.disk.parent_directory 
	     Type: string
	     value e.g. "X:\cache-MoF-3001\RainerStroebel"

     and create the directories

            md X:\cache-MoF-3001
            md X:\cache-MoF-3001\RainerStroebel


8. Support and Feedback

   Please send feedback to RainerStroebelxyz@xyzt-online.de

   Remove the strings xyz from the mail address string


9.  Known Problems

9.1 SQLite statement PRAGMA main.page_count;

    The command requires SQLite 3.6.0
    It does not show results with SQLite 3.5.9 

9.2 Insufficent disk space cause all kind of trouble.

    UPSSV now checks the aviability of sufficend HDD space. 

9.3 SQLite Statement PRAGMA integrity_check; 

    urlclassifier3.sqlite increase up to 53 MB with 707.703 records

    At a size between 25 and 45 MB, the interrity_check statement
    suddenly need 18 min with continues I/O ( before about seconds )
    Tested with SQLite 3.6.0  


10. References

 Bug 439340 Background cleanup actions block desktop on OS/2
 https://bugzilla.mozilla.org/show_bug.cgi?id=439340
 
 Firefox 3.0: Blockien des Systems durch minutenlange hohe HDD I/O AktivitÑt" - Workaround
 http://de.os2.org/forum/diskussion/index.php3?all=116554

 Warpzilla -Mozilla for OS/2
 http://www.mozilla.org/ports/os2/ 

 Tips for Warpzilla - Mozilla for OS/2  maintained by Steve Wendt 
 http://www.os2bbs.com/os2news/Warpzilla.html
 
 SQLite Home Page
 http://www.sqlite.org/

 VACUUM  SQL As Understood By SQLite 
 http://www.sqlite.org/lang_vacuum.html

 sqlite3: A command-line access program for SQLite databases
 http://www.sqlite.org/sqlite.html  

 The SQLite Database Browser Project Home Page
 http://sqlitebrowser.sourceforge.net/index.html

 The SQLiteBrowser OS/2 Port by RÅdiger Ihle
 http://hobbes.nmsu.edu/cgi-bin/h-search?key=SQLitebrowser&pushbutton=Search


11. Copyright

User Profile Save and SQLite Vacuum  UPSSV is
Copyrigth (C) 2008 Rainer D. Stroebel    

This file is part of UPSSV.

    UPSSV is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation  version 3 of the License.

    UPSSV is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with UPSSV.  If not, see <http://www.gnu.org/licenses/>.


12. Trademarks:

 Firefox is a registered trademark of the Mozilla Foundation

 OS/2 is a registered trademark of International Business Machines Corporation 


13. Acknowledgment  

 Thanks for your contribution (ideas, criticism and testing) 

      Chirstian Hennecke 
      RÅdiger Ihle  
      Uwe Jacobs 
      Peter Weilbacher 
      Bernd Schemmer ( for REXX Tips & Tricks, Version 2.80 )
      All the others I might have forgotten here 


14. Messages and Code Project UPSSV

    see Module "UPSSV-Messages-and-Codes.txt"


15. todo  Status: 2008-08-05 12.00 
-----------------------------------

0. Read me 

   Proof reading of the total document

1. Testing the package by third party.

   The creator of a product is not the best tester! :-)

2. Do improvements based on feed back

3. Warpin installation         --> next release ? 

4. Backup process improvements   
   Cache Directory handling    --> next release ?   


