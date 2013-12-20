/* REXX */
   trace 'n'

   /* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
   /* Convert Compuserve address-book to PMMAIL address-book                                 */
   /*                                                                                        */
   /* Based on Bernhard Hofmann's (100331,632) original 'addr2htm.cmd'                       */
   /*                                                                                        */
   /* Per Jessen, per@ibm.net, 19980404.                                                     */
   /* ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */

   arg cisbook .

   addrdb='.\ADDR.DB'
   booksdb='.\BOOKS.DB'

   if cisbook='' then,
   do  
      call arguments
      exit
   end
  
   if stream(cisbook,'c','query exists')='' then,
   do
      say 'Unable to find 'cisbook
      exit
   end

   Size = stream(cisbook, 'c', 'query size')

   do 5
      ch = charin(cisbook)
      Size = Size - 1
   end

   do n=1 while lines(booksdb)>0
      f=linein(booksdb)
   end 
   rc=stream(booksdb,'c','close')
   
   rc=lineout(booksdb,'CIS:internetÞ0Þ0Þ'n'Þ')
   rc=lineout(booksdb,'CIS:ccmailÞ0Þ0Þ'n+1'Þ')
   rc=lineout(booksdb,'CIS:nativeÞ0Þ0Þ'n+2'Þ')

   rc=stream(booksdb,'c','close')

   internet=0
   ccmail=0
   cis=0
   skip=0

   do num=1 while Size > 0

      FieldLength = c2d(charin(cisbook))
      Size = Size - 1
      Name = ''
      do FieldLength
         Name = Name || charin(cisbook)
         Size = Size - 1
      end

  FieldLength = c2d(charin(cisbook))
  Size = Size - 1
  Addr = ''
  do FieldLength
    Addr = Addr || charin(cisbook)
    Size = Size - 1
  end

  FieldLength = c2d(charin(cisbook))
  Size = Size - 1
  Descr = ''
  do FieldLength
    Ch = charin(cisbook)
    Descr = Descr || Ch
    Size = Size - 1
  end
  descr=translate(descr,x2c('e3e2'),x2c('0d0a'))

  parse upper var addr prefix ':' .

  select
     when prefix='INTERNET' then,
     do
        parse var addr . ':' addr
        bknum=n
        internet=internet+1
     end
     when prefix='CCMAIL' then,
     do
        addr=translate(addr,xrange('a','z'),xrange('A','Z'))
        parse var addr . ':' name 'at' loc .
        addr=translate(strip(name),'_',' ')'@'loc'.ccmail.compuserve.com'
        bknum=n+1
        ccmail=ccmail+1
     end
     when prefix='TELEX' then,
     do
        skip=skip+1
     end
     when prefix='FAX' then,
     do
        skip=skip+1
     end
     when prefix='POSTAL' then,
     do
        skip=skip+1
     end
     when prefix='X400' then,
     do
        skip=skip+1
     end
     when prefix='NIFTY' then,
     do
        skip=skip+1
     end
     when prefix='MCIMAIL' then,
     do
        skip=skip+1
     end
     when prefix='NOTES' then,
     do
        skip=skip+1
     end
     when prefix='MHS' then,
     do
        skip=skip+1
     end
     otherwise,
     do
        addr=translate(addr,'.',',')
        addr=addr||'@compuserve.com'   
        bknum=n+2
        cis=cis+1
     end
  end  /* select */

  descr=descr||x2c('e3e2')||'--- This entry was added by CIS2PM on 'date()' at 'time()' ---'

  alias=name
  sep=x2c('de')
  call lineout addrdb, addr||sep||,
                       alias||sep||,
                       name||sep||,
                       '0ÞáÞáÞáÞáÞáÞáÞáÞáÞáÞáÞáÞáÞáÞáÞáÞáÞáÞáÞ'||,
                       descr||sep||,
                       bknum'ÞáÞáÞ'
  do 2
    ch = charin(cisbook)
    Size = Size - 1
  end
end

   say right(cis,6)' Compuserve-addresses.'
   say right(internet,6)' Internet-addresses.'
   say right(ccmail,6)' CC:Mail-addresses.'
   say '------'
   say right(num,6)' entries from 'cisbook' converted.'
   
   say right(skip,6)' entries from 'cisbook' not converted.'

   rc=stream(cisbook,'c','close')
   rc=stream(addrdb,'c','close')

exit
/**************************************************/
arguments:
procedure 
   say 'arguments: 'x2c('0a0c')||,
       'cis2pm <cis-addrbook-file>'
return