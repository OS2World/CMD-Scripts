/* Sample code to query the default printer port */
/* Lee S. Fields                                 */
/*                                               */
/* No guarantees, but it works for me.           */

call rxfuncadd sysloadfuncs, rexxutil, sysloadfuncs  
call sysloadfuncs                                    

defprn = SysIni('BOTH', 'PM_SPOOLER', 'PRINTER')
defprn = strip(defprn,,'00'x)
defprn = strip(defprn,,';')
defport = SysIni('BOTH', 'PM_SPOOLER_PRINTER', defprn)
defport = word(translate(defport, ' ', ';'), 1)

say 'Default printer port is:' defport

