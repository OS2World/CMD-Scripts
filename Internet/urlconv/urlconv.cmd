/* urlconv_cmd.m4,v 1.11 1999-12-04 14:14:12-05 rl Exp */


/*************************************************************************
 *                                                                       *
 * urlconv_cmd.m4 -> urlconv.cmd                                         *
 * 1997-01-05, Rolf Lochbuehler                                          *
 * 1999-11-20, Rolf Lochbuehler                                          *
 * 1999-12-02, Paul Elliott                                              *
 *                                                                       *
 *************************************************************************/


VERSION = '1.11'
AUTHOR = 'Rolf Lochbuehler <rolf@together.net>, Paul Elliott <pelliott@io.com>'
PROGRAM = 'UrlConv'
PROGRAM_CALL = 'urlconv'
TAB = d2c( 9 )
parse value date('sorted') with yyyy =5 mm =7 dd
NOW = yyyy'-'mm'-'dd time('normal')

PC_850 = 'pc850'


call rxFuncAdd 'sysLoadFuncs', 'rexxUtil', 'SysLoadFuncs'
call sysLoadFuncs


parse arg args
uArgs = translate( args )

if (0 < wordPos('-H',uArgs)) | (0 < wordPos('/H ',uArgs)) then
  do
  say ''
  say PROGRAM' 'VERSION
  say '  by 'AUTHOR
  say 'Purpose:'
  say '  Flatten URL folder tree into single file'
  say 'Syntax:'
  say '  'PROGRAM_CALL' [/h] [/cp 850] [/text] [RootDir]'
  say 'Arguments:'
  say '  /h        Print this help screen, then exit'
  say '  /cp 850   Convert from PC850 to ISO 8859-1 for HTML [default: no conversion]'
  say '  /text     Create plain text file [default: HTML]'
  say '  RootDir   Root directory of URL folder tree [default: .]'
  say 'Output:'
  say '  Output goes to standard output. To write into a file'
  say '  use redirection. Example: 'PROGRAM_CALL' > urls.html'
  exit 1
  end

i = wordpos( '/TEXT', uArgs )
if 0 = i then
  i = wordpos( '-TEXT', uArgs )
if 0 = i then
  html = 1
else
  html = 0
n = i + 1

i = wordpos( '/CP', uArgs )
if 0 = i then
  i = wordpos( '-CP', uArgs )
if 0 = i then
  convert = 0
else
  do
  convert = 1
  codePage = PC_850
  n = max( n, i + 2 )
  end

if ('' = args) | (n > words(args)) then
  rootDir = directory()
else
  do
  rootDir = subword( args, n )
  rootDir = normalize( rootDir )
  shortRootDir = fileSpec( 'name', rootDir )
  end

if html then
  do
  say '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">'
  say '<HTML>'
  say '<HEAD>'
  if convert then
    say '<TITLE>Links from OS/2 folder ' || codeConv(codePage,rootDir) || '</TITLE>'
  else
    say '<TITLE>Links from OS/2 folder ' || rootDir || '</TITLE>'
  say '<!-- Generated 'NOW' by 'PROGRAM' 'VERSION', 'AUTHOR' -->'
  say '</HEAD>'
  say '<BODY>'
  end
else
  do
  say 'Generated 'NOW' by 'PROGRAM' 'VERSION', 'AUTHOR
  say ''
  say 'Fields, separated by horizontal tabs:'
  say ''
  say 'Folder'TAB'Description'TAB'URL'
  say ''
  end


callDir = directory()

level = 1
call convert rootDir

call directory callDir

if html then
  do
  say '</BODY>'
  say '</HTML>'
  end

exit 0


/*************************************************************************
 *                                                                       *
 * convert                                                               *
 * Recursive procedure to extract URLs from URL folder hierarchy         *
 *                                                                       *
 *************************************************************************/
convert: procedure expose codePage convert html level PC_850 TAB

  parse arg dirName

  shortDirName = fileSpec( 'name', dirName )

  hLevel = min( level, 6 )

  call directory( dirName )

  /* URLs in this directory */

  call sysFileTree '*', 'fileName', 'fo'
  if fileName.0 > 0 then
    do

    if html then
      do
      if convert then
        say '<H'hLevel'>'|| codeConv(codePage,shortDirName) || '</H'hLevel'>'
      else
        say '<H'hLevel'>'|| shortDirName || '</H'hLevel'>'
      say '<P>'
      say '<UL>'
      end

    do i = 1 to fileName.0

      call sysGetEa filename.i, '.LONGNAME', 'longName'
      longName = strip( longName, 'trailing', '00'x )
      len = c2d( substr(longName,4,1) || substr(longName,3,1) )
      longName = substr( longName, 5, len )
      url = lineIn( fileName.i )
      call lineOut fileName.i

      if html then
        do
        if url <> '' then 
          do
          longName = strip( longName )
          if longName = '' then 
            longName = url
          say '<LI>'
          if convert then
            say '<A HREF="'url'">' || codeConv(codePage,longName) || '</A>'
          else
            say '<A HREF="'url'">' || longName || '</A>'
          say '</LI>'
          end
        end
      else
        say shortDirName || TAB || longName || TAB || url

    end

    if html then
      do
      say '</UL>'
      say '</P>'
      end

    end
  else
    do

    if html then
      do
      if convert then
        say '<H'hLevel'>' || codeConv(codePage,shortDirName) || '</H'hLevel'>'
      else
        say '<H'hLevel'>' || shortDirName || '</H'hLevel'>'
      end

    end


  /* Subdirectories with more URLs */

  call sysFileTree '*', 'subDirName', 'do'
  if subDirName.0 > 0 then
    do i = 1 to subDirName.0
      level = level + 1
      call convert subDirName.i
      level = level - 1
    end


  call directory '..'

  return
  

/*************************************************************************
 *                                                                       *
 * normalize()                                                           *
 * Complete directory name, substitute ellipses, etc.                    *
 *                                                                       *
 *************************************************************************/
normalize: procedure

  parse arg d

  d = strip( d, 'b' )
  d = strip( d, 'b', '"' )

  if d = '' then
    dn = directory()
  
  /* '.' */
  else if d = '.' then
    dn = directory()
  
  /* '..' */
  else if d = '..' then
    do
    curDir = directory()
    call directory '..'
    dn = directory()
    call directory curDir
    end
  
  /* '\any\dir\name' */
  else if subStr(d,1,1) = '\' then
    do
    parse value directory() with drive ':\' .
    dn = drive':'d
    end
  
  /* 'any\dir\name' */
  else if pos(':',d) = 0 then
    do
    temp = directory() 
    if lastPos('\',temp) <> length(temp) then
      temp = temp || '\'
    dn = temp || d
    end

  else
    dn = d

  return dn


/*************************************************************************
 *                                                                       *
 * codeConv()                                                            *
 * Convert characters to ISO 8859-1                                      *
 *                                                                       *
 *************************************************************************/
codeConv : procedure expose PC_850

  parse arg cp, string

  select

    when cp = PC_850 then string = pc850( string )

    otherwise nop

  end

  return string


/*************************************************************************
 *                                                                       *
 * pc850()                                                               *
 * Convert characters from code page 850 to ISO 8859-1                   *
 *                                                                       *
 *************************************************************************/
pc850 : procedure

  parse arg r

  chars = '<>&' || xRange( '80'x, 'ff'x )

  i = 1
  s = ''
  do until i = 0

    i = verify( r, chars, 'match' )

    if i > 0 then
      do

      if i > 1 then
        do
        parse var r t =(i) c +1 r
        s = s || t
        end
      else
        parse var r c +1 r

      select
        when c = '"' then s = s'´'
        when c = '-' then s = s'†'
        when c = 'Ä' then s = s'«'
        when c = 'Å' then s = s'¸'
        when c = 'Ç' then s = s'È'
        when c = 'É' then s = s'‚'
        when c = 'Ñ' then s = s'‰'
        when c = 'Ö' then s = s'‡'
        when c = 'Ü' then s = s'Â'
        when c = 'á' then s = s'Á'
        when c = 'à' then s = s'Í'
        when c = 'â' then s = s'Î'
        when c = 'ä' then s = s'Ë'
        when c = 'ã' then s = s'Ô'
        when c = 'å' then s = s'Ó'
        when c = 'ç' then s = s'Ï'
        when c = 'é' then s = s'ƒ'
        when c = 'è' then s = s'≈'
        when c = 'ê' then s = s'…'
        when c = 'ë' then s = s'Ê'
        when c = 'í' then s = s'∆'
        when c = 'ì' then s = s'Ù'
        when c = 'î' then s = s'ˆ'
        when c = 'ï' then s = s'Ú'
        when c = 'ñ' then s = s'˚'
        when c = 'ó' then s = s'˘'
        when c = 'ò' then s = s'ˇ'
        when c = 'ô' then s = s'÷'
        when c = 'ö' then s = s'‹'
        when c = 'õ' then s = s'¯'
        when c = 'ú' then s = s'£'
        when c = 'ù' then s = s'ÿ'
        when c = 'û' then s = s'◊'
        when c = '†' then s = s'·'
        when c = '°' then s = s'Ì'
        when c = '¢' then s = s'Û'
        when c = '£' then s = s'˙'
        when c = '§' then s = s'Ò'
        when c = '•' then s = s'—'
        when c = '¶' then s = s'™'
        when c = 'ß' then s = s'∫'
        when c = '®' then s = s'ø'
        when c = '©' then s = s'Æ'
        when c = '™' then s = s'¨'
        when c = '´' then s = s'Ω'
        when c = '¨' then s = s'º'
        when c = '≠' then s = s'°'
        when c = '≥' then s = s'^3'
        when c = 'µ' then s = s'¡'
        when c = '∂' then s = s'¬'
        when c = '∑' then s = s'¿'
        when c = '∏' then s = s'©'
        when c = 'Ω' then s = s'¢'
        when c = 'æ' then s = s'•'
        when c = '∆' then s = s'„'
        when c = '«' then s = s'√'
        when c = 'œ' then s = s'§'
        when c = '–' then s = s''
        when c = '—' then s = s'–'
        when c = '“' then s = s' '
        when c = '”' then s = s'À'
        when c = '‘' then s = s'»'
        when c = '÷' then s = s'Õ'
        when c = '◊' then s = s'Œ'
        when c = 'ÿ' then s = s'œ'
        when c = '›' then s = s'¶'
        when c = 'ﬁ' then s = s'Ã'
        when c = '‡' then s = s'”'
        when c = '·' then s = s'ﬂ'
        when c = '‚' then s = s'‘'
        when c = '„' then s = s'“'
        when c = '‰' then s = s'ı'
        when c = 'Â' then s = s'’'
        when c = 'Ê' then s = s'µ'
        when c = 'Á' then s = s'˛'
        when c = 'Ë' then s = s'ﬁ'
        when c = 'È' then s = s'⁄'
        when c = 'Í' then s = s'€'
        when c = 'Î' then s = s'Ÿ'
        when c = 'Ï' then s = s'˝'
        when c = 'Ì' then s = s'›'
        when c = 'Ó' then s = s'Ø'
        when c = 'Ô' then s = s'¥'
        when c = 'Ò' then s = s'±'
        when c = 'Û' then s = s'æ'
        when c = 'Ù' then s = s'∂'
        when c = 'ı' then s = s'ß'
        when c = 'ˆ' then s = s'˜'
        when c = '˜' then s = s'∏'
        when c = '¯' then s = s'∞'
        when c = '˘' then s = s'®'
        when c = '˙' then s = s'∑'
        when c = '˚' then s = s'π'
        when c = '¸' then s = s'≥'
        when c = '˝' then s = s'≤'
        otherwise s = s || c
      end

      end

  end

  s = s || r

  return s


