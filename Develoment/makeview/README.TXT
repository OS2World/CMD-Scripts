---------------------------------------------------------------------

                         Notes on using MAKEVIEW
                                                            01 Jul 95
---------------------------------------------------------------------

What is it?
    MAKEVIEW creates DB2/2 compatible views of system tables for
    SQL/DS databases.
    
    
Who needs it (and why)?
    If you are using the VX-REXX Client/Server Edition and you want
    to connect to a SQL/DS database, you need to run MAKEVIEW.
    
    If you connect to a SQL/DS system using the VX-REXX database objects, 
    the ListColumns and ListTables methods will not function correctly.
    Also, the VX-REXX SQL Editor will not list the tables or columns in 
    your database. The reason for this is that the VX-REXX database 
    controls assume the SQL/DS system tables are identical to those for 
    DB2/2, which is not the case.  The MAKEVIEW program creates a number 
    of database views that simulate the required system tables. After 
    running MAKEVIEW, the VX-REXX SQL Editor and the individual methods 
    listed above will function correctly.
    
    
What MAKEVIEW does NOT do:
    -- MAKEVIEW does NOT create new system tables. It creates _views_.
    -- The ListForeignKeys method will still not work because the
       database does not support it.
    -- The ListIndexes method will not work.


How to run MAKEVIEW
    1. Open an OS/2 command window
    
    2. Change to the drive/directory that contains MAKEVIEW.CMD and 
       the TABLES.DAT file.
       
    3. Run MAKEVIEW. The command line arguments are:
    
        MAKEVIEW -dDatabase [-oViewOwner] [-sSystemOwner] [-q] [-r]
        
       Where:
            Database       the name of a database
            ViewOwner      qualifier of the created views
            SystemOwner    qualifier of the current system tables
            -q             operate quietly
            -r             drop views

        By default, ViewOwner is SYSIBM and SystemOwner is SYSTEM.
        
	For example, to create views in an SQL/DS database named SAMPLE,
	use the following command:
	
	MAKEVIEW -dSAMPLE


Disclaimer:
    Watcom (Watcom International and all of its subsidiaries) makes no
    representation or warranty with respect to the adequacy of this
    documentation or the programs which it describes for any particular
    purpose or with respect to its adequacy to produce any particular
    result. In no event shall Watcom, its employees, or the authors of
    this documenation be liable for special, direct, indirect, or 
    consequential damages, losses, costs, claims, demands or claims for
    lost profits, fees, or expenses of any nature or kind.

