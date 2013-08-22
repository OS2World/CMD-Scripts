/*          
 * whichdll.cmd
 * Which DLL is used?
 * 1997-10-26
 */


parse arg opt
topt = translate( opt )

RET_NO_ERR = 0
RET_NO_DLL = 1
RET_NO_LIBPATH = 2
RET_HELP = 4
RET_NO_CONFIGSYS = 5

/* Help */
if ('' = opt) | (pos('-H',topt) <> 0)  then
  do
  say ''
  say 'whichdll -- V1.1, 1997-11-22, Rolf Lochbuehler <rolobue@ibm.net>'
  say 'Purpose:'
  say '  Determine which DLL is actually used because it resides in a directory'
  say '  that is listed before others in the LIBPATH search path.'
  say 'Usage:'
  say '  whichdll [-h]'
  say '  whichdll [-b DRIVE] [DLL]'
  say 'Arguments:'
  say '  (none)     Print this information'
  say '  -b DRIVE   Letter of bootdrive (default: -b C)'
  say '  -h         Print this information'
  say '  DLL        Name of the DLL file to search for'
  say 'Examples:'
  say '  whichdll rexxutil'
  say '  whichdll pmgpi.dll'
  exit RET_HELP
  end

/* Boot drive */
i = pos( '-B', topt )
if i <> 0 then
  do
  bootdrive = word( opt, i+1 )
  dllfile = word( opt, i+2 )
  end
else
  do
  bootdrive = 'C'
  dllfile = opt
  end

/* Add file name extension if necessary */
if 0 = pos('.DLL',dllfile) then
  dllfile = dllfile'.DLL'

call rxfuncadd 'sysfiletree', 'rexxutil', 'sysfiletree'

/* Read value of LIBPATH from CONFIG.SYS */
configsys = bootdrive':\config.sys'
if '' = stream(configsys,'command','query exists') then
  signal configsyserr
call stream configsys, 'command', 'open read'
do until pos('LIBPATH',translate(ln))
  ln = linein( configsys )
  if 0 = lines(configsys) then
    do
    call stream configsys, 'command', 'close'
    signal libpatherr
    end
end
call stream configsys, 'command', 'close'

/* Strip "LIBPATH = " */
ln = strip( ln )
ln = delstr( ln, 1, 7 )
ln = strip( ln, 'leading' )
ln = delstr( ln, 1, 1 )
ln = strip( ln, 'leading' )
ln = translate( ln, ' ', ';' )

/* Parse LIBPATH and search for DLL file */
dlldir.0 = words( ln )
do i = 1 to dlldir.0
  dlldir.i = word( ln, i )
end
found = 0
do i = 1 to dlldir.0 while 0 = found
  file = dlldir.i || '\'dllfile
  if 0 < length(stream(file,'command','query exist')) then
    do
    say file
    found = 1
    end
end
if 0 = found then
  signal dllerr

exit RET_NO_ERR


/* Error handling */

libpatherr:
  say 'No LIBPATH variable found in' configsys'.'
  exit RET_NO_LIBPATH

dllerr:
  say 'No' dllfile 'found in' ln'.'
  exit RET_NO_DLL

configsyserr:
  say 'There is no' configsys'.'
  exit RET_NO_CONFIGSYS

