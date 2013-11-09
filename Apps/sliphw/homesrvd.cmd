/* HOMESRVD.CMD
SLIP server daemon 
Put this file in \TCPIP\BIN on the home machine.
Run this on the home machine to make it a SLIP server

Configuration: set the COM port speed in the Rexx variable below 
*/
modemspeed  = '115200'
modemhangup = 'ATH0S0=0'
/***********************************************************/
/* Set global vars */
env = 'OS2ENVIRONMENT'                   /* Description of environment */
etcpath = value('ETC',,env)                  /* Get env. var. ETC */

/* Set screen colors to blue on white */
'@sc bw'
'@cls'
say ''
say ''
say 'SLIP server daemon is starting ...'
say center('=',78,'=')
say ''

/* When SLIP session ends slip.exe terminates. */
/* It must be started over and over         */
do forever
   /* Start SLIP process and redirect output to logfile */
   '@slip -exit 0 -f homesrv.cfg -hangup +++'modemhangup' -p -speed 'modemspeed
end

exit 0
