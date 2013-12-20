/* pmmaconv.cmd,v 1.5 1998-10-16 00:18:04-04 rl Exp */

/**************************************************************************
 *                                                                        *
 * pmmaconv.cmd                                                           *
 * Convert PMMail address book format                                     *
 * 1998-07-25, Rolf Lochbuehler                                           *
 *                                                                        *
 **************************************************************************/

SEP = d2c(222)
NULL = d2c(225)
HTML_EMPTY = '-'
DEFAULT_TOOLS = 'e:\southsde\tools'
INDENT = '  '
PROGRAM = 'PmmaConv'
PROGRAM_CALL = 'pmmaconv'
VERSION = '1.5'
AUTHOR = 'Rolf Lochbuehler'
HTML_AUTHOR = 'Rolf Lochb&uuml;hler'
EMAIL = '<rolf@together.net>'

parse arg opts
opts1 = translate( opts )

if (wordpos('/H',opts1) > 0) | (wordpos('-H',opts1) > 0) | (length(opts) = 0)  then 
  call help

csv = 0
if (wordpos('/CSV',opts1) > 0) | (wordpos('-CSV',opts1) > 0) then 
  csv = 1

html = 0
if (wordpos('/HTML',opts1) > 0) | (wordpos('-HTML',opts1) > 0) then
  html = 1

text = 0
if (wordpos('/TEXT',opts1) > 0) | (wordpos('-TEXT',opts1) > 0) then 
  text = 1

toolsDir = ''
if (wordpos('/TOOLS',opts1) > 0) | (wordpos('-TOOLS',opts1) > 0) then
  do
  n = wordpos( '/TOOLS', opts1 )
  if n = 0 then
    n = wordpos( '-TOOLS', opts1 )
  toolsDir = word( opts, n + 1 )
  if 0 < verify(toolsDir,'"','match') then
    parse var opts . '"' toolsDir '"' .
  end

if html + text + csv > 1 then
  do
  say ''
  say 'Error: Invalid arguments'
  call help
  end

if 0 = length(toolsDir) then
  toolsDir = DEFAULT_TOOLS
if length(toolsDir) <> lastpos('\',toolsDir) then
  toolsDir = toolsDir'\'

addrFile = toolsDir'addr.db'
booksFile = toolsDir'books.db'

if '' = stream(addrFile,'command','query exists') then
  do
  say ''
  say 'Error: Cannot find file' addrFile
  exit 1
  end
if '' = stream(booksFile,'command','query exists') then
  do
  say ''
  say 'Error: Cannot find file' booksFile
  exit 1
  end

curDir = directory()
call directory toolsDir

call readAddr addrFile /* book. SEP */
call readBooks booksFile /* addr. SEP */

select
  when text then 
    call printText /* addr. book. */
  when html then 
    call printHtml /* addr. book. */
  when csv  then 
    call printCsv /* addr. book. */
  otherwise 
    nop
end

call directory curDir

exit 0


/**************************************************************************
 *                                                                        *
 * help()                                                                 *
 * Print help for user                                                    *
 *                                                                        *
 **************************************************************************/
help : procedure expose PROGRAM PROGRAM_CALL VERSION AUTHOR EMAIL DEFAULT_TOOLS

  say ''
  say PROGRAM' 'VERSION', 'AUTHOR' 'EMAIL
  say 'Purpose:'
  say '  Convert format of PMMail addressbook'
  say 'Usage:'
  say '  'PROGRAM_CALL' [/h] [/csv|/html|/text] [/tools Dir] [> Outfile]'
  say 'Arguments:'
  say '  /csv      Convert to comma separated value format'
  say '  /h        Print this help screen and abort (default)'
  say '  /html     Convert to HTML'
  say '  /text     Convert to plain text'
  say '  Dir       Tools directory of PMMail installation'
  say '            (default: 'DEFAULT_TOOLS')'
  say '  Outfile   Name of output file. Use >>Outfile to append to Outfile.'
  say '            (default: print to standard output)'
  say 'Examples:'
  say '  'PROGRAM_CALL' /text > addresses'
  say '  'PROGRAM_CALL' /html -tools d:\mailtools > addr.html'

  exit 1


/**************************************************************************
 *                                                                        *
 * printText()                                                            *
 * Print address book in text format                                      *
 *                                                                        *
 **************************************************************************/
printText : procedure expose addr. book. INDENT NULL

  do i = 1 to book.0
  
    say ''
    say ''
  
    say '-- Book:' book.i.bookName '--'
  
    do k = 1 to addr.0
  
      if addr.k.inBookNum = book.i.bookNum then
        do
  
        say ''
        if addr.k.realName <> NULL then 
          say addr.k.realName
        if addr.k.alias <> NULL then 
          say '(alias' addr.k.alias')'
        if addr.k.emailAddr <> NULL then 
          say addr.k.emailAddr
        if addr.k.company <> NULL then 
          say addr.k.company
        if addr.k.title <> NULL then 
          say addr.k.title
        if addr.k.notes <> NULL then 
          say addr.k.notes
  
        if (addr.k.busiStreet <> NULL) | (addr.k.busiBldg <> NULL) | (addr.k.busiCity <> NULL) | (addr.k.busiState <> NULL) ,
          | (addr.k.busiZip <> NULL) | (addr.k.busiCountry <> NULL) | (addr.k.busiPhone <> NULL) | (addr.k.busiExt <> NULL) ,
          | (addr.k.busiFax <> NULL) then
          do
          say 'Business address:'
          call printTextPops addr.k.busiStreet, addr.k.busiBldg, addr.k.busiCity, addr.k.busiState, addr.k.busiZip, addr.k.busiCountry 
          call printTextPots addr.k.busiPhone, addr.k.busiExt, addr.k.busiFax 
          end
  
        if (addr.k.homeStreet <> NULL) | (addr.k.homeBldg <> NULL) | (addr.k.homeCity <> NULL) | (addr.k.homeState <> NULL) ,
          | (addr.k.homeZip <> NULL) | (addr.k.homeCountry <> NULL) | (addr.k.homePhone <> NULL) | (addr.k.homeExt <> NULL) ,
          | (addr.k.homeFax <> NULL) then
          do
          say 'Home address:'
          call printTextPops addr.k.homeStreet, addr.k.homeBldg, addr.k.homeCity, addr.k.homeState, addr.k.homeZip, addr.k.homeCountry 
          call printTextPots addr.k.homePhone, addr.k.homeExt, addr.k.homeFax 
          end
  
        end   /* end if */
  
    end   /* end do */
  
  end   /* end do */
  
  return


/**************************************************************************
 *                                                                        *
 * readAddr()                                                             *
 * Read address book file                                                 *
 *                                                                        *
 **************************************************************************/
readAddr : procedure expose addr. SEP

  parse arg addrFile

  call stream addrFile, 'command', 'open read'

  do i = 1 while lines( addrFile ) 
    ln = linein( addrFile ) 
    parse var ln ,
      addr.i.emailAddr (SEP) ,
      addr.i.alias (SEP) ,
      addr.i.realName (SEP) ,
      . (SEP) ,
      addr.i.company (SEP) ,
      addr.i.title (SEP) ,
      addr.i.homeStreet (SEP) ,
      addr.i.homeBldg (SEP) ,
      addr.i.homeCity (SEP) ,
      addr.i.homeState (SEP) ,
      addr.i.homeZip (SEP) ,
      addr.i.homePhone (SEP) ,
      addr.i.homeExt (SEP) ,
      addr.i.homeFax (SEP) ,
      addr.i.busiStreet (SEP) ,
      addr.i.busiBldg (SEP) ,
      addr.i.busiCity (SEP) ,
      addr.i.busiState (SEP) ,
      addr.i.busiZip (SEP) ,
      addr.i.busiPhone (SEP) ,
      addr.i.busiExt (SEP) ,
      addr.i.busiFax (SEP) ,
      addr.i.notes (SEP) ,
      addr.i.inBookNum (SEP) ,
      addr.i.homeCountry (SEP) ,
      addr.i.busiCountry (SEP)
  end
  addr.0 = i - 1

  call stream addrFile, 'command', 'close'

  return


/**************************************************************************
 *                                                                        *
 * readBooks()                                                            *
 * Read address books file                                                *
 *                                                                        *
 **************************************************************************/
readBooks : procedure expose book. SEP

  parse arg booksFile

  call stream booksFile, 'command', 'open read'

  do i = 1 while lines( booksFile ) 
    ln = linein( booksFile )
    parse var ln book.i.bookName (SEP) . (SEP) . (SEP) book.i.bookNum (SEP)
  end
  book.0 = i - 1

  call stream booksFile, 'command', 'close'

  return


/**************************************************************************
 *                                                                        *
 * printTextPops()                                                        *
 * Print address for plain old post service                               *
 *                                                                        *
 **************************************************************************/
printTextPops : procedure expose INDENT NULL

  parse arg street, bldg, city, state, zip, country

  if street <> NULL then 
    say INDENT || street

  if bldg <> NULL then 
    say INDENT || bldg

  if city <> NULL then 
    say INDENT || city

  if (state <> NULL) | (zip <> NULL) then 
    do
    ln = INDENT
    if state <> NULL then 
      ln = ln || state
    if zip <> NULL then 
      ln = ln zip
    say ln
    end

  if country <> NULL then 
    say INDENT || country

  return


/**************************************************************************
 *                                                                        *
 * printTextPots()                                                        *
 * Print address for plain old telephone service                          *
 *                                                                        *
 **************************************************************************/
printTextPots : procedure expose INDENT NULL

  parse arg phone, ext, fax

  if (phone <> NULL) | (ext <> NULL) then 
    do
    ln = INDENT
    if phone <> NULL then 
      ln = ln || phone
    if ext <> NULL then 
      if length(ln) > 0 then
        ln = ln 'x' ext
      else
        ln = 'x' ext
    say ln
    end

  if fax <> NULL then 
    say INDENT || 'fax: 'fax

  return


/**************************************************************************
 *                                                                        *
 * printHtml()                                                            *
 * Print address book in HTML format                                      *
 *                                                                        *
 **************************************************************************/
printHtml : procedure expose addr. book. NULL HTML_EMPTY PROGRAM VERSION HTML_AUTHOR EMAIL toolsDir

  do i = 1 to book.0
  
    say ''
    say ''
  
    say '<!-- Table from PMMail addressbook in' toolsDir 'generated by' PROGRAM VERSION',' HTML_AUTHOR EMAIL '-->'
    say '<h1>' htmlChar(book.i.bookName) '</h1>'
    say '<p>'
    say '<table border>'

    say '<tr>'
    say '<th>Name</th>'
    say '<th>Alias</th>'
    say '<th>Email</th>'
    say '<th>Company</th>'
    say '<th>Title</th>'
    say '<th>Notes</th>'
    say '<th>Business Address</th>'
    say '<th>Home Address</th>'
    say '</tr>'
  
    do k = 1 to addr.0
  
      if addr.k.inBookNum = book.i.bookNum then
        do
  
        say '<tr>'

        say '<td>'
        if addr.k.realName <> NULL then 
          say htmlChar(addr.k.realName)
        else
          say HTML_EMPTY
        say '</td>'

        say '<td>'
        if addr.k.alias <> NULL then 
          say htmlChar(addr.k.alias)
        else
          say HTML_EMPTY
        say '</td>'

        say '<td>'
        if addr.k.emailAddr <> NULL then 
          do
          parse var addr.k.emailAddr id '@' domain
          say '<a href="mailto:'addr.k.emailAddr'">'id' @ 'domain'</a>'
          end
        else
          say HTML_EMPTY
        say '</td>'

        say '<td>'
        if addr.k.company <> NULL then 
          say htmlChar(addr.k.company)
        else
          say HTML_EMPTY
        say '</td>'

        say '<td>'
        if addr.k.title <> NULL then 
          say htmlChar(addr.k.title)
        else
          say HTML_EMPTY
        say '</td>'

        say '<td>'
        if addr.k.notes <> NULL then 
          say (addr.k.notes)
        else
          say HTML_EMPTY
        say '</td>'
  
        say '<td>'
        if (addr.k.busiStreet <> NULL) | (addr.k.busiBldg <> NULL) | (addr.k.busiCity <> NULL) | (addr.k.busiState <> NULL) ,
          | (addr.k.busiZip <> NULL) | (addr.k.busiCountry <> NULL) | (addr.k.busiPhone <> NULL) | (addr.k.busiExt <> NULL) ,
          | (addr.k.busiFax <> NULL) then
          do
          ln1 = htmlPops( addr.k.busiStreet, addr.k.busiBldg, addr.k.busiCity, addr.k.busiState, addr.k.busiZip, addr.k.busiCountry )
          ln2 = htmlPots( addr.k.busiPhone, addr.k.busiExt, addr.k.busiFax )
          if length(ln1) > 0 then
            do
            if length(ln2) > 0 then
              say htmlChar(ln1) || ', ' || htmlChar(ln2)
            else
              say htmlChar(ln1)
            end
          else
            do
            if length(ln2) > 0 then
              say htmlChar(ln2)
            else
              nop
            end
          end
        else
          say HTML_EMPTY
        say '</td>'
  
        say '<td>'
        if (addr.k.homeStreet <> NULL) | (addr.k.homeBldg <> NULL) | (addr.k.homeCity <> NULL) | (addr.k.homeState <> NULL) ,
          | (addr.k.homeZip <> NULL) | (addr.k.homeCountry <> NULL) | (addr.k.homePhone <> NULL) | (addr.k.homeExt <> NULL) ,
          | (addr.k.homeFax <> NULL) then
          do
          ln1 = htmlPops( addr.k.homeStreet, addr.k.homeBldg, addr.k.homeCity, addr.k.homeState, addr.k.homeZip, addr.k.homeCountry )
          ln2 = htmlPots( addr.k.homePhone, addr.k.homeExt, addr.k.homeFax )
          if length(ln1) > 0 then
            do
            if length(ln2) > 0 then
              say htmlChar(ln1) || ', ' || htmlChar(ln2)
            else
              say htmlChar(ln1)
            end
          else
            do
            if length(ln2) > 0 then
              say htmlChar(ln2)
            else
              nop
            end
          end
        else
          say HTML_EMPTY
        say '</td>'
        say '</tr>'
  
        end   /* end if */
  
    end   /* end do */
  
  say '</table>'
  say '</p>'

  end   /* end do */
  
  return


/**************************************************************************
 *                                                                        *
 * htmlPops()                                                             *
 * Print address for plain old post service                               *
 *                                                                        *
 **************************************************************************/
htmlPops : procedure expose NULL

  parse arg street, bldg, city, state, zip, country

  ln = ''

  if street <> NULL then 
    ln = ln || street

  if bldg <> NULL then 
    if length(ln) > 0 then
      ln = ln || ', ' || bldg
    else
      ln = bldg

  if city <> NULL then 
    if length(ln) > 0 then
      ln = ln || ', ' || city
    else
      ln = city

  if (state <> NULL) | (zip <> NULL) then 
    do
    if state <> NULL then 
      do
      if length(ln) > 0 then
        ln = ln || ', ' || state
      else
        ln = state
      end
    if zip <> NULL then 
      do
      if length(ln) > 0 then
        ln = ln || ', ' || zip
      else
        ln = zip
      end
    end

  if country <> NULL then 
    do
    if length(ln) > 0 then
      ln = ln || ', ' || country
    else
      ln = country
    end

  return ln


/**************************************************************************
 *                                                                        *
 * htmlPots()                                                             *
 * Print address for plain old telephone service                          *
 *                                                                        *
 **************************************************************************/
htmlPots : procedure expose NULL

  parse arg phone, ext, fax

  ln = ''

  if (phone <> NULL) | (ext <> NULL) then 
    do

    if phone <> NULL then 
      ln = ln || 'tel:' phone

    if ext <> NULL then 
      do
      if length(ln) > 0 then
        ln = ln 'x' ext
      else
        ln = 'x' ext
      end
    end

  if fax <> NULL then 
    do
    if length(ln) > 0 then
      ln = ln', fax: 'fax
    else
      ln = 'fax:' fax
    end

  return ln


/**************************************************************************
 *                                                                        *
 * htmlChar()                                                             *
 * Translate characters in string to character references if necessary    *
 *                                                                        *
 **************************************************************************/
htmlChar: procedure

  parse arg s


  if 0 = verify( s, '&<>' || xrange(d2c(128),d2c(255)), 'match' ) then
    return s
  else
    do

    s = htmlChar2( s, '&amp;', '&' )
    s = htmlChar2( s, '&lt;', '<' )
    s = htmlChar2( s, '&gt;', '>' )
    s = htmlChar2( s, '&Ccedil;', '€' )
    s = htmlChar2( s, '&uuml;', '' )
    s = htmlChar2( s, '&eacute;', '‚' )
    s = htmlChar2( s, '&acirc;', 'ƒ' )
    s = htmlChar2( s, '&auml;', '„' )
    s = htmlChar2( s, '&agrave;', '…' )
    s = htmlChar2( s, '&aring;', '†' )
    s = htmlChar2( s, '&ccedil;', '‡' )
    s = htmlChar2( s, '&ecirc;', 'ˆ' )
    s = htmlChar2( s, '&euml;', '‰' )
    s = htmlChar2( s, '&egrave;', 'Š' )
    s = htmlChar2( s, '&iuml;', '‹' )
    s = htmlChar2( s, '&icirc;', 'Œ' )
    s = htmlChar2( s, '&igrave;', '' )
    s = htmlChar2( s, '&Auml;', 'Ž' )
    s = htmlChar2( s, '&Aring;', '' )
    s = htmlChar2( s, '&Eacute;', '' )
    s = htmlChar2( s, '&aelig;', '‘' )
    s = htmlChar2( s, '&AElig;', '’' )
    s = htmlChar2( s, '&ocirc;', '“' )
    s = htmlChar2( s, '&ouml;', '”' )
    s = htmlChar2( s, '&ograve;', '•' )
    s = htmlChar2( s, '&ucirc;', '–' )
    s = htmlChar2( s, '&ugrave;', '—' )
    s = htmlChar2( s, '&yuml;', '˜' )
    s = htmlChar2( s, '&Ouml;', '™' )
    s = htmlChar2( s, '&Uuml;', 'š' )
    s = htmlChar2( s, '&oslash;', '›' )
    s = htmlChar2( s, '&pound;', 'œ' )
    s = htmlChar2( s, 'Oe', '' )
    s = htmlChar2( s, '&times;', 'ž' )
    s = translate( s, 'f', 'Ÿ' )
    s = htmlChar2( s, '&aacute;', ' ' )
    s = htmlChar2( s, '&iacute;', '¡' )
    s = htmlChar2( s, '&oacute;', '¢' )
    s = htmlChar2( s, '&uacute;', '£' )
    s = htmlChar2( s, '&ntilde;', '¤' )
    s = htmlChar2( s, '&Ntilde;', '¥' )
    s = htmlChar2( s, '&ordf;', '¦' )
    s = htmlChar2( s, '&ordm;', '§' )
    s = htmlChar2( s, '&iquest;', '¨' )
    s = htmlChar2( s, '&reg;', '©' )
    s = htmlChar2( s, '&not;', 'ª' )
    s = htmlChar2( s, '&frac12;', '«' )
    s = htmlChar2( s, '&frac14;', '¬' )
    s = htmlChar2( s, '&iexcl;', '­' )
    s = htmlChar2( s, '&laquo;', '®' )
    s = htmlChar2( s, '&raquo;', '¯' )
    s = htmlChar2( s, '&Aacute;', 'µ' )
    s = htmlChar2( s, '&Acirc;', '¶' )
    s = htmlChar2( s, '&Agrave;', '·' )
    s = htmlChar2( s, '&copy;', '¸' )
    s = htmlChar2( s, '&cent;', '½' )
    s = htmlChar2( s, '&yen;', '¾' )
    s = htmlChar2( s, '&atilde;', 'Æ' )
    s = htmlChar2( s, '&Atilde;', 'Ç' )
    s = htmlChar2( s, '&curren;', 'Ï' )
    s = htmlChar2( s, '&eth;', 'Ð' )
    s = htmlChar2( s, '&ETH;', 'Ñ' )
    s = htmlChar2( s, '&Ecirc;', 'Ò' )
    s = htmlChar2( s, '&Euml;', 'Ó' )
    s = htmlChar2( s, '&Egrave;', 'Ô' )
    s = htmlChar2( s, 'EUR', 'Õ' )
    s = htmlChar2( s, '&Iacute;', 'Ö' )
    s = htmlChar2( s, '&Icirc;', '×' )
    s = htmlChar2( s, '&Iuml;', 'Ø' )
    s = htmlChar2( s, '&brvbar;', 'Ý' )
    s = htmlChar2( s, '&Igrave;', 'Þ' )
    s = htmlChar2( s, '&Oacute;', 'à' )
    s = htmlChar2( s, '&szlig;', 'á' )
    s = htmlChar2( s, '&Ocirc;', 'â' )
    s = htmlChar2( s, '&Ograve;', 'ã' )
    s = htmlChar2( s, '&otilde;', 'ä' )
    s = htmlChar2( s, '&Otilde;', 'å' )
    s = htmlChar2( s, '&micro;', 'æ' )
    s = htmlChar2( s, '&thorn;', 'ç' )
    s = htmlChar2( s, '&THORN;', 'è' )
    s = htmlChar2( s, '&Uacute;', 'é' )
    s = htmlChar2( s, '&Ucirc;', 'ê' )
    s = htmlChar2( s, '&Ugrave;', 'ë' )
    s = htmlChar2( s, '&yacute;', 'ì' )
    s = htmlChar2( s, '&Yacute;', 'í' )
    s = htmlChar2( s, '&macr;', 'î' )
    s = htmlChar2( s, '&acute;', 'ï' )
    s = translate( s, '-', 'ð' )
    s = htmlChar2( s, '&plusmn;', 'ñ' )
    s = htmlChar2( s, '&para;', 'ô' )
    s = htmlChar2( s, '&sect;', 'õ' )
    s = htmlChar2( s, '&divide;', 'ö' )
    s = htmlChar2( s, '&cedil;', '÷' )
    s = htmlChar2( s, '&deg;', 'ø' )
    s = htmlChar2( s, '&uml;', 'ù' )
    s = htmlChar2( s, '&middot;', 'ú' )
    s = htmlChar2( s, '&sup1;', 'û' )
    s = htmlChar2( s, '&sup3;', 'ü' )
    s = htmlChar2( s, '&sup2;', 'ý' )
  
    return s

    end


/**************************************************************************
 *                                                                        *
 * htmlChar2()                                                            *
 * Used within htmlChar()                                                 *
 *                                                                        *
 **************************************************************************/
htmlChar2: procedure

  parse arg s, ref, c

  i = 0
  i = verify( s, c, 'match', i + 1 )
  do while i > 0
    parse var s head (c) tail
    s = head || ref || tail
    i = verify( s, c, 'match', i + 1 )
  end

  return s


/**************************************************************************
 *                                                                        *
 * printCsv()                                                             *
 * Print address book in comma separated value format                     *
 *                                                                        *
 **************************************************************************/
printCsv : procedure expose addr. book. NULL

  say '"Book","Name","Alias","Email","Company","Title","Notes"',
    || ',"Business Street","Business Building","Business City","Business State","Business Zip","Business Country","Business Phone","Business Extension","Business Fax"',
    || ',"Home Street","Home Building","Home City","Home State","Home Zip","Home Country","Home Phone","Home Extension","Home Fax"'

  do i = 1 to book.0
  
    do k = 1 to addr.0
  
      if addr.k.inBookNum = book.i.bookNum then
        do
        ln = '"' || book.i.bookName || '"'
        ln = ln || printCsv2( addr.k.realName )
        ln = ln || printCsv2( addr.k.alias )
        ln = ln || printCsv2( addr.k.emailAddr )
        ln = ln || printCsv2( addr.k.company )
        ln = ln || printCsv2( addr.k.title )
        ln = ln || printCsv2( addr.k.notes )
        ln = ln || printCsv2( addr.k.busiStreet )
        ln = ln || printCsv2( addr.k.busiBldg )
        ln = ln || printCsv2( addr.k.busiCity )
        ln = ln || printCsv2( addr.k.busiState )
        ln = ln || printCsv2( addr.k.busiZip )
        ln = ln || printCsv2( addr.k.busiCountry )
        ln = ln || printCsv2( addr.k.busiPhone )
        ln = ln || printCsv2( addr.k.busiExt )
        ln = ln || printCsv2( addr.k.busiFax )
        ln = ln || printCsv2( addr.k.homeStreet )
        ln = ln || printCsv2( addr.k.homeBldg )
        ln = ln || printCsv2( addr.k.homeCity )
        ln = ln || printCsv2( addr.k.homeState )
        ln = ln || printCsv2( addr.k.homeZip )
        ln = ln || printCsv2( addr.k.homeCountry )
        ln = ln || printCsv2( addr.k.homePhone )
        ln = ln || printCsv2( addr.k.homeExt )
        ln = ln || printCsv2( addr.k.homeFax )
        say ln
        end
  
    end
  
  end
  
  return


/**************************************************************************
 *                                                                        *
 * printCsv2()                                                            *
 * Used within printCsv()                                                 *
 *                                                                        *
 **************************************************************************/
printCsv2: procedure expose NULL

  parse arg s

  if s <> NULL then
    return ',"'s'"'
  else
    return ',""'


