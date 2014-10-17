/*
    MAKEVIEW.CMD
    ------------
    
    Usage:
        MAKEVIEW -dDatabase [-oViewOwner] [-sSystemOwner] [-q] [-r]
    
    Copyright (c) 1994 by Watcom International Corporation
    All Rights Reserved.
*/
    debug = 0
    
    /*  Read table configuration
    */
    tables = charin( "tables.dat", ,chars( "tables.dat" ) );
    if( tables = "" ) then signal BadTablesDat
    tables = translate( tables, ';;', '0d0a'x );
    interpret tables

    /*  Parse command line
    */
    viewowner = "SYSIBM"
    systemowner = "SYSTEM"
    dbname = ""
    verbose = 1
    makeview = 1
    
    if( arg() = 0 ) then signal Usage
    do j = 1 to arg()
        do i = 1 to Words( arg(j) )
            parse upper value Word( arg(j), i ) with parm
            select
                when( Left( parm, 2 ) = "-D" ) then dbname = SubStr( parm, 3 )
                when( Left( parm, 2 ) = "-O" ) then viewowner = SubStr( parm, 3 )
                when( Left( parm, 2 ) = "-Q" ) then verbose = 0
                when( Left( parm, 2 ) = "-R" ) then makeview = 0
                when( Left( parm, 2 ) = "-S" ) then systemowner = SubStr( parm, 3 )
            otherwise
                say "Invalid argument:" parm
                say
                signal Usage
            end
        end
    end
    if( dbname = "" ) then signal Usage
    if( verbose ) then pipeto = ">con"
    else pipeto = ">nul"
    
   
    /*  Load REXX API
    */
    call RxFuncDrop 'SQLEXEC'
    call RxFuncAdd 'SQLEXEC', 'SQLAR', 'SQLEXEC'
    
    call RxFuncDrop 'SQLDBS'
    call RxFuncAdd 'SQLDBS', 'SQLAR', 'SQLDBS'


    /*  Start the database manager
    */ 
    if( verbose ) then do
        say "Starting database manager..."
    end
    call SQLDBS 'START DATABASE MANAGER'
    if( RESULT \= 0 ) then signal BadStartDBM
    if( SQLCA.SQLCODE \= 0 & SQLCA.SQLCODE \= -1026 & SQLCA.SQLCODE \= -1063 ) then signal BadStartDBM
    
    
    /*  Report settings
    */
    if( verbose ) then do
        say "Database is" dbname
        say "ViewOwner is" viewowner
        say "SystemOwner is" systemowner
    end


    /*  Connect
    */
    if( verbose ) then do
        say "Connecting..."
    end
    call SQLEXEC "CONNECT TO" dbname
    if( SQLCA.SQLCODE <> 0 ) then signal BadConnect
    
    
    /*  Create or drop system views...
    */
    
    /*  SYSTABLES
    */
    if( makeview ) then do
        stmt = "CREATE VIEW" viewowner || "." || "SYSTABLES"
        stmt = stmt "( CREATOR, NAME, TYPE, REMARKS )"
        stmt = stmt "AS SELECT"
        stmt = stmt systables.col.creator ","
        stmt = stmt systables.col.name ","
        stmt = stmt systables.col.type ","
        stmt = stmt systables.col.remarks
        stmt = stmt "FROM" systemowner || "." || systables.table
        if( verbose ) then do
            say "Creating systables..."
        end
    end; else do
        stmt = "DROP VIEW" viewowner || "." || "SYSTABLES"
        if( verbose ) then do
            say "Dropping systables..."
        end
    end
if( debug ) then do
    say stmt
end; else do
    call SQLEXEC "EXECUTE IMMEDIATE :stmt"
    if( SQLCA.SQLCODE <> 0 ) then call BadCreateorDropView
end
    
    /*  SYSCOLUMNS
    */
    if( makeview ) then do
        stmt = "CREATE VIEW" viewowner || "." || "SYSCOLUMNS"
        stmt = stmt "( TBCREATOR, TBNAME, NAME, REMARKS, COLTYPE, LENGTH, SCALE, NULLS, COLNO, KEYSEQ )"
        stmt = stmt "AS SELECT"
        stmt = stmt syscolumns.col.tbcreator ","
        stmt = stmt syscolumns.col.tbname ","
        stmt = stmt syscolumns.col.name ","
        stmt = stmt syscolumns.col.remarks ","
        stmt = stmt syscolumns.col.coltype ","
        stmt = stmt syscolumns.col.length ","
        stmt = stmt syscolumns.col.scale ","
        stmt = stmt syscolumns.col.nulls ","
        stmt = stmt syscolumns.col.colno ","
        stmt = stmt syscolumns.col.keyseq
        stmt = stmt "FROM" systemowner || "." || syscolumns.table
        if( verbose ) then do
            say "Creating syscolumns..."
        end
    end; else do
        stmt = "DROP VIEW" viewowner || "." || "SYSCOLUMNS"
        if( verbose ) then do
            say "Dropping syscolumns..."
        end
    end
if( debug ) then do
    say stmt
end; else do
    call SQLEXEC "EXECUTE IMMEDIATE :stmt"
    if( SQLCA.SQLCODE <> 0 ) then call BadCreateorDropView
end
    

    /*  SYSRELS
    */
    if( sysrels.table \= "" ) then do
        if( makeview ) then do
            stmt = "CREATE VIEW" viewowner || "." || "SYSRELS"
            stmt = stmt "( CREATOR, TBNAME, REFTBCREATOR, REFTBNAME, RELNAME, FKCOLNAMES, PKCOLNAMES )"
            stmt = stmt "AS SELECT"
            stmt = stmt sysrels.col.creator ","
            stmt = stmt sysrels.col.tbname ","
            stmt = stmt sysrels.col.reftbcreator ","
            stmt = stmt sysrels.col.reftbname ","
            stmt = stmt sysrels.col.rename ","
            stmt = stmt sysrels.col.fkcolnames ","
            stmt = stmt sysrels.col.pkcolnames
            stmt = stmt "FROM" systemowner || "." || sysrels.table
            if( verbose ) then do
                say "Creating sysrels..."
            end
        end; else do
            stmt = "DROP VIEW" viewowner || "." || "SYSRELS"
            if( verbose ) then do
                say "Dropping sysrels..."
            end
        end
if( debug ) then do
        say stmt
end; else do
        call SQLEXEC "EXECUTE IMMEDIATE :stmt"
        if( SQLCA.SQLCODE <> 0 ) then call BadCreateorDropView
end
    end

    /*  SYSINDEXES
    */
    if( sysindexes.table \= "" ) then do
        if( makeview ) then do
            stmt = "CREATE VIEW" viewowner || "." || "SYSINDEXES"
            stmt = stmt "( CREATOR, NAME, COLNAMES, UNIQUERULE, TBCREATOR, TBNAME )"
            stmt = stmt "AS SELECT"
            stmt = stmt sysindexes.col.creator ","
            stmt = stmt sysindexes.col.name ","
            stmt = stmt sysindexes.col.colnames ","
            stmt = stmt sysindexes.col.uniquerule ","
            stmt = stmt sysindexes.col.tbcreator ","
            stmt = stmt sysindexes.col.tbname
            stmt = stmt "FROM" systemowner || "." || sysindexes.table
            if( verbose ) then do
                say "Creating sysindexes..."
            end
        end; else do
            stmt = "DROP VIEW" viewowner || "." || "SYSINDEXES"
            if( verbose ) then do
                say "Dropping sysindexes..."
            end
        end
if( debug ) then do
        say stmt
end; else do
        call SQLEXEC "EXECUTE IMMEDIATE :stmt"
        if( SQLCA.SQLCODE <> 0 ) then call BadCreateorDropView
end
    end
   
    
    /*  Disconnect
    */
    if( verbose ) then do
        say "Disconnecting..."
    end
    call SQLEXEC "CONNECT RESET"
    
    if( verbose ) then do
        if( makeview ) then say "System views created successfully."
        else say "System views dropped."
    end


    /*  Normal termination
    */
    exit
    
    /*  Error messages
    */
Usage:
    say "Create system views"
    say "MAKEVIEW -dDatabase [-oViewOwner] [-sSystemOwner] [-q] [-r]"
    say "where:"
    say "    Database       the name of a database"
    say "    ViewOwner      qualifier of the created views"
    say "    SystemOwner    qualifier of the current system tables"
    say "                   (this is the collection name for SQL/400)"
    say "    -q             operate quietly"
    say "    -r             drop views"
    say
    say "By default, ViewOwner is SYSIBM and SystemOwner is SYSTEM"
    exit
    
BadTablesDat:
    say "Error: Unable to read tables.dat"
    exit
    
BadStartDBM:
    say "Error: Could not start the database manager."
    say SQLMSG
    exit 
    
BadConnect:
    say "Error: Unable to connect to database."
    say SQLMSG
    exit

BadCreateorDropView:
    if( makeview ) then do
        
        /*  Terminate now if we could not create a view
        */
        say "Error: Unable to create view."
        say SQLMSG
        call SQLEXEC "CONNECT RESET"
        exit
    end; else do
    
        /*  Keep going -- attempt to remove all views
        */
        say "Warning: Unable to drop view, continuing."
        return
    end
