/* popd.cmd */

envvar = 'DIRSTACK.'translate(DosGetInfoBlocks(), '.', ' ')
qname = value(envvar,,'OS2ENVIRONMENT')
if qname = '' then do
   say 'Directory stack empty!'
   exit 1
   end
   
oldq = RxQueue('Set', qname)
if queued() = 0 then
   say 'Directory stack empty!'
else do
   pull dir
   call directory dir
end
call RxQueue 'Set', oldq
