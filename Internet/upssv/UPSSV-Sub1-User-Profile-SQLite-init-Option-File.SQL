-- ************************************************************************
-- File: UPSSV-Sub1-User-Profile-SQLite-init-Option-File.SQL
-- SQL Statemets for Vacuum a Database
-- Version: 
-- 1.01  2008-07-07 13.50 Rainer D. Stroebel
-- 1.02  2008-07-07 19.00 PRAGMA temp_store_directory set deleted 
--                        inquirey remains - System will use OS/2 defaults                                
-- 1.03  2008-07-19 14.00 add inquired of PRAGMA default_cache_size;       
--                  19.15 add PRAGMA page_size;  
--                  20.07 add PRAGMA main.page_count; works with 3.6.0 !!
--                            PRAGMA integrity_check;
--                        add ANALYZE; SELECT .....
-- 1.04  2008-07-21       Edit und Reihenfolge 
-- *************************************************************************
.echo on
-- ------------------------------------
-- Phase 1: Collecting information 
-- ------------------------------------
PRAGMA temp_store_directory;
PRAGMA legacy_file_format; 
PRAGMA database_list;
PRAGMA page_size;
PRAGMA default_cache_size; 
PRAGMA main.page_count;
PRAGMA main.freelist_count;
-- SELECT rowid, *  FROM sqlite_stat1 ORDER BY rowid; 
-- ------------------------------------
-- Phase 2: Processing before Vaccum
-- ------------------------------------
-- PRAGMA integrity_check;  
-- ------------------------------------
-- Phase 3: Change Settings 
-- ------------------------------------
--   
-- ------------------------------------
-- Phase 4: Do the Vacuum 
-- ------------------------------------
vacuum;
-- ------------------------------------
-- Phase 5: Processing after Vaccum
-- ------------------------------------
-- PRAGMA integrity_check; 
ANALYZE;
-- ------------------------------------
-- Phase 6: Colleting Info after Vaccum
-- ------------------------------------
PRAGMA main.page_count;
PRAGMA main.freelist_count;
SELECT rowid, *  FROM sqlite_stat1 ORDER BY rowid;
-- .SCHEMA
-- ----------------------------------------------------------------
-- End of File: UPSSV-Sub1-User-Profile-SQLite-init-Option-File.SQL
-- ----------------------------------------------------------------