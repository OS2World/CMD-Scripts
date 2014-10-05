/* install OS2ENDIVE    */
/* 5.14.2002 by kadzsol */

/* get boot drive */
parse arg bdrv

/* check */
if bdrv = '' | stream(bdrv'\config.sys', 'c', 'query exists') = '' then do
	say
	say 'OS2ENDIVE installation script'
	say 'Usage: install.cmd <boot drive>'
	say 'Example: install c:'
	exit 1
end
else do
	say
	say 'This script will install OS2ENDIVE on your system using OS/2 on drive 'bdrv
	say 'Press ENTER to continue, CTRL-C to abort.'
	'@pause > nul'
end

/* read config */
found. = 0
i=1
do while lines(bdrv'\config.sys')
	l.i=linein(bdrv'\config.sys')
	if translate(l.i) = 'SET C1=SDDGRADD'     then found.c1 = 1
	if translate(l.i) = 'SET GREEXT=SDDGREXT' then found.gr = 1
	i=i+1
end
call lineout bdrv'\config.sys'
l.0=i-1

/* check */
if found.c1 = 0 then do
	say
	say 'Warning: the setting SET C1=SDDGRADD was not found in your config.sys.'
	say 'Did you install Scitech Display Doctor 7.04 or higher on this system?'
	say 'Exiting...'
	exit 2
end

/* copy files */
say
say 'Copying files...'
'@copy HWENDIVE.DLL 'bdrv'\os2\dll\.'
'@copy GREHOOK.DLL  'bdrv'\os2\dll\.'

/* save config */
say
say 'Backing up config.sys to config.edv...'
'@copy 'bdrv'\config.sys 'bdrv'\config.edv'
'@del 'bdrv'\config.sys'

/* write config */
say
say 'Writing new config.sys...'
do i=1 to l.0
	if translate(l.i) = 'SET C1=SDDGRADD'     then l.i = 'SET C1=SDDGRADD,HWENDIVE'
	if translate(l.i) = 'SET GREEXT=SDDGREXT' then l.i = 'SET GREEXT=SDDGREXT,GREHOOK'
	call lineout bdrv'\config.sys', l.i
end
if found.gr = 0 then call lineout bdrv'\config.sys', 'SET GREEXT=GREHOOK'
call lineout bdrv'\config.sys'

/* done */
say
say 'Installation completed. Now read the file readme.txt! :-)'

exit
