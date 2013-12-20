/* -------------------------------- REXX --------------------------- */
/* 96-12-20 or convert Umail addressbook to Netscape 2.02            */
/* ----------------------------------------------------------------- */
   say
   say 'ADRUM2NS 1996-12-21'

   ofile='address.htm'
/* ----------------------------------------------------------------- */
   parse upper arg ifile ofi rest
   if left(ifile,1)='"' then do
                               ifile=ifile ofi
                               ofi  =rest
                               end
   if ifile = ''       then                                   exit 0
   if ofi  \= ''       then ofile=ofi
   ifile=strip(translate(ifile,' ','"'))

   say 'converting:' ifile
/* ----------------------------------------------------------------- */
   j=0
   o=0
   call stream ifile,'c','close'
   do while chars(ifile)>1
     parse value linein(ifile) with type '.' rest
     select
       when type=':nick'   then do
                                 if o then do
                                   o.j='<DT><A HREF="mailto:'ui.j'@'no.j'" NICKNAME="'nn.j'">'nm.j'</A> <DD>'fo.j
                                   end
                                 o=1
                                 j=j+1
                                 nn.j=rest
                                 end
       when type=':name'   then do
                                 nm.j=rest
                                 end
       when type=':userid' then do
                                 ui.j=rest
                               end
       when type=':node'   then do
                                 no.j=rest
                               end
       when type=':folder' then do
                                 fo.j=rest
                               end
       otherwise               nop
       end
     end
   call stream ifile,'c','close'
   if j>0 then                     o.j='<DT><A HREF="mailto:'ui.j'@'no.j'" NICKNAME="'nn.j'">'nm.j'</A> <DD>'fo.j

   '@erase' ofile '2>NUL'
   call lineout ofile,'<!DOCTYPE NETSCAPE-Addressbook-file-1> '
   call lineout ofile,'<!-- This is an automatically generated file.'
   call lineout ofile,'It will be read and overwritten.'
   call lineout ofile,'Do Not Edit! -->'
   call lineout ofile,'<TITLE>Converted Address book</TITLE>'
   call lineout ofile,'<H1>Converted Address book</H1>'
   call lineout ofile,'<DL><p>'
   do i=1 to j
     call lineout ofile,'  'o.i
     end
   call lineout ofile,'</DL><p>'
   call stream ofile,'c','close'

   say j 'entries converted'

   'start /F e' ofile
/* ----------------------------------------------------------------- */
