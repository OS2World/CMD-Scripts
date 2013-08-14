/***********************************************************/
/*  killart.cmd  Copyright 1996 Ward Kaatz                 */
/*               FREEWARE                                  */
/*  Brings down the useless, artchron register program     */
/*  Place in STARTUP folder or call from startup.cmd       */
/*  Note: requires grep and kill, and Warp 4 (Merlin)      */
/***********************************************************/
parse source . . SourceFile;
say "Executing" filespec("name", SourceFile) "Copyright 1996 - Ward Kaatz";
address cmd '@echo off'
address cmd 'ps | grep -i "' || 'artchron' || '" > tmp';
line = linein("tmp");
call stream "tmp", "C", "CLOSE";
'del tmp';
parse var line pid foo;
if pid \= "" then do
	say "Process" pid "a.k.a. ARTCHRON.EXE will die!"
	'kill' pid;
	say "r.i.p.  --  ARTCHRON.EXE  --  r.i.p."
	end
else
	say "ARTCHRON.EXE not alive, next time it WILL DIE!"

/* you can uncomment this next line to close command session */
/* exit */

