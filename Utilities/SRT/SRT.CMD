/* Author: Jerry Pedone 				*/
/* jpedone@flash.net					*/
/* Legal Stuff:                       			*/
/*     It's free - you get what you pay for 		*/
/* Load the REXX functions 				*/
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs
signal on failure name halt
signal on halt name halt
/* Set up variables			 		*/
Options 'EXMODE'
cr = '0d'x
lf = '0a'x
tab = '09'x
rem1 = 'REM **************************************************'
file_attempt = 0
/* Initialize stems        				*/
fs = 0
ex = 0
od = 0
lb = 0
st = 0
sw = 0
cn = 0
cd = 0
ds = 0
rn = 0
os = 0
dos = 0
dvi = 0
bd = 0
rk = 0
basedev.0 = 0
lib.0 = 0
setter.0 = 0
cdpg.0 = 0
cntry.0 = 0
devin.0 = 0
osdev.0 = 0
ffn.0 = 0
swp.0 = 0
doscom.0 = 0
dosdev.0 = 0
odos.0 = 0
runn.0 = 0
extr.0 = 0
rmk.0 = 0
/* Yes I know - 15 stems is a bit excessive 	*/
Parse Upper Arg drive rems
If rems = '?' Then Signal help
if rems = 'HELP' Then Signal help
if drive = ' ' Then Signal help
/* Check for existence of config.sys			*/
rc = SysFileTree(drive':\config.sys','config_sys.','F')
if config_sys.0 <> 1 Then Do
	halt_string = 'Could not find CONFIG.SYS'
	Signal halt
End
/* Delete any previously sorted file			*/
rc = SysSearchPath('.' , 'config.new')
if rc <> ' ' THEN DEL 'config.new'
/* Bring in the lines one at a time */
Current_Line_Number = 0
Do While Lines(drive":\config.sys")
	in_line = Linein(drive":\config.sys")
	in_line = Translate(in_line)
	test_part = substr(in_line,1,3)
	Call stem_find
end 
rc = Stream(drive":\config.sys","C","Close")
/* Output the sorted file				*/
rem2 = 'REM Base Devices'
Call rem_it
DO i = 1 TO basedev.0
	CALL CHAROUT 'config.new' , basedev.i
	CALL Endline
End
rem2 = 'REM Libraries'
Call rem_it
DO i = 1 TO lib.0
	CALL CHAROUT 'config.new' , lib.i
	CALL Endline
End
rem2 = 'REM Set Statements'
Call rem_it
DO i = 1 TO setter.0
	CALL CHAROUT 'config.new' , setter.i
	CALL Endline
End
rem2 = 'REM Code Page'
Call rem_it
DO i = 1 TO cdpg.0
	CALL CHAROUT 'config.new' , cdpg.i
	CALL Endline
End
rem2 = 'REM Country Code'
Call rem_it
DO i = 1 TO cntry.0
	CALL CHAROUT 'config.new' , cntry.i
	CALL Endline
End
rem2 = 'REM Device Info'
Call rem_it
DO i = 1 TO devin.0
	CALL CHAROUT 'config.new' , devin.i
	CALL Endline
End
rem2 = 'REM OS/2 Devices'
Call rem_it
DO i = 1 TO osdev.0
	CALL CHAROUT 'config.new' , osdev.i
	CALL Endline
End
rem2 = 'REM File Systems'
Call rem_it
DO i = 1 TO ffn.0
	CALL CHAROUT 'config.new' , ffn.i
	CALL Endline
End
rem2 = 'REM Swap Files'
Call rem_it
DO i = 1 TO swp.0
	CALL CHAROUT 'config.new' , swp.i
	CALL Endline
End
rem2 = 'REM DOS Commands'
Call rem_it
DO i = 1 TO doscom.0
	CALL CHAROUT 'config.new' , doscom.i
	CALL Endline
End
rem2 = 'REM DOS Devices'
Call rem_it
DO i = 1 TO dosdev.0
	CALL CHAROUT 'config.new' , dosdev.i
	CALL Endline
End
rem2 = 'REM Other DOS Stuff'
Call rem_it
DO i = 1 TO odos.0
	CALL CHAROUT 'config.new' , odos.i
	CALL Endline
End
rem2 = 'REM Programs to Run'
Call rem_it
DO i = 1 TO runn.0
	CALL CHAROUT 'config.new' , runn.i
	CALL Endline
End
rem2 = 'REM Anything Else'
Call rem_it
DO i = 1 TO extr.0
	CALL CHAROUT 'config.new' , extr.i
	CALL Endline
End
rem2 = 'REM Informational Remarks'
If rems = 'ALL' Then Do
	Call rem_it
	DO i = 1 TO rmk.0
		CALL CHAROUT 'config.new' , rmk.i
		CALL Endline
	End
End
Call done
/* Program is done - these are procedures			*/
rem_it:
If rems = 'ALL' Then call rem_it2
IF rems = 'SOME' Then Call rem_it2
Return
rem_it2:
Call CHAROUT 'config.new' , rem1
Call Endline
Call CHAROUT 'config.new' , rem2
Call Endline
Call CHAROUT 'config.new' , rem1
Call Endline
Return
Endline:
CALL CHAROUT 'config.new' , cr
CALL CHAROUT 'config.new' , lf	
Return
stem_find:
If test_part = 'BAS' Then Do
	bd = bd+1
	basedev.0 = bd
	basedev.bd = in_line
	Return
End
If test_part = 'LIB' Then Do
	lb = lb+1
	lib.0 = lb
	lib.lb = in_line
	Return
End
If test_part = 'SET' Then Do
	st = st+1
	setter.0 = st
	setter.st = in_line
	Return
End
If test_part = 'COD' Then Do
	cd = cd+1
	cdpg.0 = cd
	cdpg.cd = in_line
	Return
End
If test_part = 'COU' Then Do
	cn = cn+1
	cntry.0 = cn
	cntry.cn = in_line
	Return
End
If test_part = 'IFS' Then Do
	fs = fs + 1
	ffn.0 = fs
	ffn.fs = in_line
	Return
End
If test_part = 'SWA' Then Do
	sw = sw+1
	swp.0 = sw
	swp.sw = in_line
	Return
End
If test_part = 'BRE' Then Do
	ds = ds+1
	doscom.0 = ds
	doscom.ds = in_line
	Return
End
If test_part = 'DOS' Then Do
	od = od+1
	odos.0 = od
	odos.od = in_line
	Return
End
If test_part = 'FCB' Then Do
	od = od+1
	odos.0 = od
	odos.od = in_line
	Return
End
If test_part = 'FIL' Then Do
	od = od+1
	odos.0 = od
	odos.od = in_line
	Return
End
If test_part = 'LAS' Then Do
	od = od+1
	odos.0 = od
	odos.od = in_line
	Return
End
If test_part = 'RMS' Then Do
	od = od+1
	odos.0 = od
	odos.od = in_line
	Return
End
If test_part = 'SHE' Then Do
	od = od+1
	odos.0 = od
	odos.od = in_line
	Return
End
If test_part = 'RUN' Then Do
	rn = rn+1
	runn.0 = rn
	runn.rn = in_line
	Return
End
If test_part = 'CAL' Then Do
	rn = rn+1
	runn.0 = rn
	runn.rn = in_line
	Return
End
test_part2 = substr(in_line,1,9)
If test_part2 = 'PROTECTON' Then Do
	od = od+1
	odos.0 = od
	odos.od = in_line
	Return
End
If test_part = 'DEV' Then Do
	Call Devices
	Return
End
If test_part = 'REM' Then Do
	Call Remarking
	Return
End
test_part2 = substr(in_line,1,1)
If test_part2 <> ' ' Then Do
	ex = ex+1
	extr.0 = ex
	extr.ex = in_line
	Return
End
Return
Devices:
test_part2 = substr(in_line,1,7)
If test_part2 = 'DEVINFO' Then Do
	dvi = dvi + 1
	devin.0 = dvi
	devin.dvi = in_line
	Return
End
test_part2 = substr(in_line,15,5)
If test_part2 <> 'MDOS\' Then Do
	os = os + 1
	osdev.0 = os
	osdev.os = in_line
	Return
End
If test_part2 = 'MDOS\' Then Do
	dos = dos + 1
	dosdev.0 = dos
	dosdev.dos = in_line
	Return
End
halt_string = 'Unknown Device'
signal halt
Return
Remarking:
If rems = 'ALL' Then Do
	test_part2 = substr(in_line,5,3)
	If test_part2 = 'BAS' Then Do
		bd = bd+1
		basedev.0 = bd
		basedev.bd = in_line
		Return
	End
	If test_part2 = 'LIB' Then Do
		lb = lb+1
		lib.0 = lb
		lib.lb = in_line
		Return
	End
	If test_part2 = 'SET' Then Do
		st = st+1
		setter.0 = st
		setter.st = in_line
		Return
	End
	If test_part2 = 'COD' Then Do
		cd = cd+1
		cdpg.0 = cd
		cdpg.cd = in_line
		Return
	End
	If test_part2 = 'COU' Then Do
		cn = cn+1
		cntry.0 = cn
		cntry.cn = in_line
		Return
	End
	If test_part2 = 'DEV' Then Do
		Call Device2
		Return
	End
	If test_part2 = 'IFS' Then Do
		fs = fs + 1
		ffn.0 = fs
		ffn.fs = in_line
		Return
	End
	If test_part2 = 'SWA' Then Do
		sw = sw+1
		swp.0 = sw
		swp.sw = in_line
		Return
	End
	If test_part2 = 'BRE' Then Do
		ds = ds+1
		doscom.0 = ds
		doscom.ds = in_line
		Return
	End
	If test_part2 = 'DOS' Then Do
		od = od+1
		odos.0 = od
		odos.od = in_line
		Return
	End
	If test_part2 = 'FCB' Then Do
		od = od+1
		odos.0 = od
		odos.od = in_line
		Return
	End
	If test_part2 = 'FIL' Then Do
		od = od+1
		odos.0 = od
		odos.od = in_line
		Return
	End
	If test_part2 = 'LAS' Then Do
		od = od+1
		odos.0 = od
		odos.od = in_line
		Return
	End
	If test_parts = 'RMS' Then Do
		od = od+1
		odos.0 = od
		odos.od = in_line
		Return
	End
	If test_part2 = 'SHE' Then Do
		od = od+1
		odos.0 = od
		odos.od = in_line
		Return
	End
	If test_part2 = 'RUN' Then Do
		rn = rn+1
		runn.0 = rn
		runn.rn = in_line
		Return
	End
	If test_part2 = 'CAL' Then Do
		rn = rn+1
		runn.0 = rn
		runn.rn = in_line
		Return
	End
	rk = rk+1
	rmk.0 = rk
	rmk.rk = in_line
	Return
End
Return
Device2:
test_part2 = substr(in_line,5,7)
If test_part2 = 'DEVINFO' Then Do
	dvi = dvi + 1
	devin.0 = dvi
	devin.dvi = in_line
	Return
End
test_part2 = substr(in_line,20,5)
If test_part2 <> 'MDOS\' Then Do
	os = os + 1
	osdev.0 = os
	osdev.os = in_line
	Return
End
If test_part2 = 'MDOS\' Then Do
	dos = dos + 1
	dosdev.0 = dos
	dosdev.dos = in_line
	Return
End
halt_string = 'Unknown Device Remark'
signal halt
Return
help:
say tab
say tab
say tab 'USAGE:'
say tab
say tab tab 'SRT drive remark_level'
say tab
say tab tab 'drive is the drive containing your CONFIG.SYS file'
say tab
say tab tab 'remark_level is one of the following:'
say tab
say tab tab 'ALL = Seperator remarks and present remarks'
say tab tab '        will be placed in config.new'
say tab
say tab tab 'SOME = Only seperator remarks will be placed in config.new'
say tab
say tab tab 'anything else (or nothing else) = No remarks will be'
say tab tab '     placed in config.new'
say tab
halt_string = ' '
Call halt
halt:
say tab
Say tab halt_string
rc = Stream("config.new","C","Close")
rc = Stream(drive":\config.sys","C","Close")
exit
done:
say tab
say tab tab 'Your sorted CONFIG.SYS file is stored as'
say tab tab 'CONFIG.NEW in this directory'
rc = Stream("config.new","C","Close")
rc = Stream(drive":\config.sys","C","Close")
exit
