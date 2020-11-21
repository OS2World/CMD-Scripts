/* pushd.cmd */

envvar = 'DIRSTACK.'translate(DosGetInfoBlocks(), '.', ' ')
qname = value(envvar,,'OS2ENVIRONMENT')

if qname = '' then do
   qname = RxQueue('Create', envvar)
   call value envvar, qname, 'OS2ENVIRONMENT'
   end

oldq = RxQueue('Set', qname)
queue directory()
if arg(1) \= '' then
   call directory arg(1)
call RxQueue 'Set', oldq
