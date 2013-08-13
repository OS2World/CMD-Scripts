/* Simple popuplog.os2 statistics */
/* hsn@cybermail.net */

parse arg file
 if file='' then file='c:\popuplog.os2'
 if 'READY:'\=stream(file,'C','OPEN READ') then return
 pred=0;
 pocet=0;
 do while chars(file)>0
  ln=linein(file)
  if substr(ln,3,1)='-' then
   if substr(ln,6,1)='-' then
     if substr(ln,11,2)='  ' then 
      do
       pred=1;
       iterate;
      end
  if pred=1 then do 
                   /* najdi pozici */
                   do i=1 to pocet
                     if jm.i=ln then do
                                       po.i=po.i+1;
                                       pred=0;
                                       leave;
                                     end
                   end                    
                   if pred=0 then iterate;
                   pocet=pocet+1;
                   jm.pocet=ln
                   po.pocet=1;
                   pred=0;
                 end;
 end                   
 say 'Results:'
 say '========='
 do i=1 to pocet
  say jm.i po.i
 end 
return 
       

