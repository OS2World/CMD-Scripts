/* OS/2 warpamp list */
/* Written by Stephen Hobbie <shobbie@ibm.net> 7MAR1998 */

say "Making warpamp play list for all .mp3 files in current directory"
qname="SMHMP3"
buffout=""
listname="SMHLIST.LST"

/* create a private queue */
call rxqueue "Create", qname
call rxqueue "Set", qname

/* process the queued list of filenames */
'@echo off'
'dir *.mp* /f /on |rxqueue 'qname
'if exist 'listname 'del 'listname
buffout ='[playlist]'
'echo 'buffout'>>'listname
i =0
do while queued()>0
  pull aline
  i =i +1
  buffout ='File'i'='aline
  'echo 'buffout'>>'listname              
end

/* delete private queue */
call rxqueue 'Delete', qname

/* last line of file */
buffout ='NumberOfEntries='i
'echo 'buffout'>>'listname
say "Done!"
exit
