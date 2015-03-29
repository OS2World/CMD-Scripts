/* Maak een Systeem Klok Object */

call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
call SysLoadFuncs

call SysCreateObject 'WPClock', '<WP_CONFIG>', 'System Clock 2', 'OBJECTID=<WP_CLOCK2>;', 'F'
