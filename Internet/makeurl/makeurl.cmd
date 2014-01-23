/* */
Call RxFuncAdd 'SysLoadFuncs','REXXUTIL','SysLoadFuncs';
Call SysLoadFuncs;

exp = 'explore.ini'

/*	Get the physical location of the desktop directory
	This is the only way I know how				*/
a = 'FolderWorkareaRunningObjects'
call SysIni 'BOTH', a, 'ALL:', 'list.'
if result = 'ERROR:' then
do
  say "Cannot find desktop"
  exit
end
desktop = left(list.1, 10);

/*	Create a folder on the desktop	*/

where = '<WP_DESKTOP>'
ftitle = "URL's"
vals = 'OBJECTID=<Test>'
ret = SysCreateObject(WPFolder, ftitle, where, vals);
obj.path = desktop || '\' || ftitle

/*	Find the location of the explore.ini file	*/

env = 'OS2ENVIRONMENT'
expfile = value('etc',,env)
if file = '' then
do
  say 'Cannot find the TCP/IP etc environment'
  exit
end
expfile = expfile || '\' || exp

do forever
  x = linein(expfile);
  if x = "[quicklist]" then
    leave
end
count = 0;
bad.0 = 0;
bcount = 0;
do forever
  obj.title = linein(expfile);
  obj.url   = linein(expfile);
  if obj.title = "" then
    leave;
  count = count + 1;
  parse var obj.title 'quicklist= ' obj.title
  nfixed = translate(obj.title,'!','/');
  nfixed = translate(nfixed,'!',':');
  ofile = obj.path || '\' || nfixed;
  rc=SysCreateObject("WebExplorer_Url", obj.title, obj.path);
  if STREAM(ofile,'C','QUERY EXISTS') = "" then
  do
    bcount = bcount + 1;
    bad.bcount = obj.title
  end
  xx = charout(ofile, obj.url );

  if xx \= 0 then
  do
    say "cannot write to " ofile
    bcount = bcount + 1;
    bad.bcount = obj.title
  end
  call stream ofile, 'C', 'CLOSE'
end
say "Created " count "URL's from the explore.ini file"
exit

if bcount = 0 then
  exit;
say bcount "URL's were created that did not have their links added to them"
say "These URL's are:"

do x = 1 to bcount
  say '  'bad.x
end


