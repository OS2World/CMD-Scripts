/* WPS installer for WhoIs (with broken PMRexx I/O) */

CALL RxFuncAdd 'SysCreateObject','RexxUtil','SysCreateObject'

SAY
SAY 'Creating WPS object for WhoIs (with PMRexx I/O)...'
SAY
SAY "Despite a few known bugs regarding PMRexx, this uses PMRexx' interface"
SAY "to display WHOIS.EXE's output in a scrollable PM window. The output of"
SAY "WHOIS.EXE may not fit in a typical 80x25 VIO window. It is possible to" 
SAY "enter some of WHOIS.EXE's options in front of the domain name."
SAY
SAY "Close the PMRexx window to quit, or enter another domain name. There's"
SAY "essentionally no error checking, this is just some kind of I/O wrapper" 
SAY "for WHOIS.EXE."
SAY

IF Stream('WhoIs.CMD','C','QUERY EXISTS')='' THEN DO
   SAY 'Error: file WhoIs.CMD not found in' Directory() 
   SAY
   EXIT
END
IF Stream('WhoIs.EXE','C','QUERY EXISTS')='' THEN DO
   SAY 'Error: file WhoIs.EXE not found in' Directory() 
   SAY
   EXIT
END

setup='EXENAME=PMREXX.EXE;PARAMETERS='||Directory()||'\WhoIs.CMD [Which domain name?];STARTUPDIR='||Directory()
IF SysCreateObject('WPProgram','WhoIs (PMRexx I/O)','<WP_DESKTOP>',setup,'U')=0 THEN DO
   SAY 'Error creating WPS object for WhoIs (PMRexx I/O)'
   SAY
   EXIT
END

SAY
SAY 'WPS object created for WhoIs (PMRexx I/O)'
SAY

EXIT
