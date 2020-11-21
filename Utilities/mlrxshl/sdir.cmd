/* sdir.cmd - an improved dir command                        20020306 */
/* (c) martin lafaix 1996, 1997, 1998, 2000, 2002                     */

/*
 * Options
 *
 * /B                                 -- full
 * /F                                 -- fullPath
 * /W                                 -- wide
 *
 * /S                                 -- use subdirs too
 *
 * /A[:][-]d[-]h[-]r[-]s[-]a[-]o[-]l  -- show or hide specified attributes
 *
 * /O[:][-]n[-]e[-]d[-]s[-]g          -- specify sort order
 *
 * /L                                 -- lower
 * /V                                 -- verbose (new Warp4 feature)
 * /P                                 -- pause every screen
 *
 * Environment variables
 *
 * DIRCMD                             -- options list
 *
 * DIRCLR.ATTRIB                      -- attrib[,...]:color[;...][;]
 * DIRCLR.DATE                        -- [+-=]date[,...]:color[;...][;]
 * DIRCLR.EASIZE                      -- [+-=]size[,...]:color[;...][;]
 * DIRCLR.EXT                         -- ext[,...]:color[;...][;]
 * DIRCLR.NAME                        -- name[,...]:color[;...][;]
 * DIRCLR.NORMAL                      -- color
 * DIRCLR.SIZE                        -- [+-=]size[,...]:color[;...][;]
 */

numeric digits 21

signal on halt

call init

parse arg commandLine

do while commandLine \= ''
   parse var commandLine left '"' file '"' commandLine
   if left \= '' then call getOptions left
   if file \=='' then call add file
end /* do */

if specs.0 = 0 & filespec = 0 then call add '*'
if sub & sortorder \= '' then sortorder = 'P' sortorder

do spec = 1 to specs.0
   call emit spec
end /* do */

call terminate

exit


getOptions:
  procedure expose wide full fullPath lower verbose pause specs. attron attroff filespec sortorder sub processingInit invalidOpt lineCount height findobjects findshadows
  do i = 1 to words(arg(1))
     opt = word(arg(1),i)
     if left(opt,1) = '/' then
        do while opt \= ''
           parse var opt '/' xswitch '/' -0 opt
           switch = translate(xswitch)
           select
              when switch = 'W' & \ full & \ fullPath then wide = 1
              when switch = '-W' then wide = 0
              when switch = 'B' & \ wide then full = 1
              when switch = '-B' then full = 0
              when switch = 'F' & \ wide then fullPath = 1
              when switch = '-F' then fullPath = 0
              when switch = 'L' then lower = 1
              when switch = '-L' then lower = 0
              when switch = 'S' then sub = 1
              when switch = '-S' then sub = 0
              when switch = 'V' then verbose = 1
              when switch = '-V' then verbose = 0
              when switch = 'P' then pause = 1
              when switch = '-P' then pause = 0
              when switch = '?' & \ processingInit then do
                    if value('HELP.COMMAND',,'OS2ENVIRONMENT') \= '' then
                       '@call %HELP.COMMAND% SDIR /?'
                    else
                       '@dir /?'
                    exit 0
                    end
              when left(switch,1) = 'A' then
                 if switch = 'A' then do
                    attroff = ''
                    findobjects = 1
                    findshadows = 1
                    end
                 else do
                    attr = strip(substr(switch,2),,':')
                    attron = ''
                    attroff = ''
                    do while attr \= ''
                       neg = left(attr,1) = '-'
                       if neg then attr = substr(attr,2)
                       if pos(left(attr,1),'HRSAD') > 0 then
                          if neg then
                             attroff = attroff||left(attr,1)
                          else
                             attron = attron||left(attr,1)
                       else
                       if left(attr,1) = 'O' then
                         findobjects = 1
                       else
                       if left(attr,1) = 'L' then
                         findshadows = 1
                       else
                          call invalidOption arg(1), xswitch
                       attr = substr(attr,2)
                    end /* do */
                    end
              when left(switch,2) = '-A' then do
                 attroff = 'SH'
                 attron = ''
                 end
              when left(switch,1) = 'O' then
                 if switch = 'O' then
                    sortorder = 'G N'
                 else do
                    order = strip(substr(switch,2),,':')
                    sortorder = ''
                    do while order \= ''
                       neg = left(order,1) = '-'
                       if neg then order = substr(order,2)
                       if pos(left(order,1),'NESDG') > 0 then
                          if neg then
                             sortorder = sortorder '-'left(order,1)
                          else
                             sortorder = sortorder left(order,1)
                       else
                          call invalidOption arg(1), xswitch
                       order = substr(order,2)
                    end /* do */
                    end
              when left(switch,2) = '-O' then
                 sortorder = ''
           otherwise
              call invalidOption arg(1), xswitch
           end /* select */
        end
     else
        call add opt
  end
  if sub & full then
    fullPath = 1
  return

invalidOption:
  call display SysGetMessage(1003)
  if words(arg(1)) > 1 | pos('/',arg(1),pos('/',arg(1))+1) > 0 then
     call display SysGetMessage(1249,,'/'arg(2))
  if processingInit then do
     invalidOpt = 1
     return
     end
  else
     exit 1

add:
  procedure expose specs. filespec lineCount height pause
  filespec = filespec + 1
  i = specs.0 + 1
  file = arg(1)

  /*
   * les divers cas sont :
   *
   * 1- chemin relatif dans l'unit‚ courante
   * 2- chemin absolu dans l'unit‚ courante
   * 3- chemin relatif dans une unit‚ donn‚e
   * 4- chemin absolu dans une unit‚ donn‚e
   */
  if substr(file,2,1) \= ':' then
     file = filespec('d',directory())file
  /*
   * les cas 1- et 2- ont ‚t‚ trait‚s
   */
  if substr(file,3,1) \= '\' then
     file = directory(filespec('d',file))'\'substr(file,3)
  if left(file,1) = '\' then do
     call display SysGetMessage(15)
     return
     end
  /*
   * directory() ajoute un '\' en fin de chaŒne si c'est la racine
   */
  if substr(file,4,1) = '\' then
     file = delstr(file,4,1)
  /*
   * le r‚sultat est-il un r‚pertoire, ou une sp‚cification de fichier ?
   */
  if right(file,1) \= '\' & verify(file,'*?','M') = 0 then
     if stream(file,'c','query exists') = '' & stream(file,'c','query datetime') \= '' then
        file = file'\'

  specs.i = file
  specs.0 = i

  return

init:
  if RxFuncQuery("SysLoadFuncs") then do
     call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
     call SysLoadFuncs
     end
  if RxFuncQuery("VioLoadFuncs") then do
     call RxFuncAdd 'VioLoadFuncs','REXXVIO','VioLoadFuncs'
     call VioLoadFuncs
     end

  wptools = 1
  if RxFuncQuery("WPToolsLoadFuncs") then do
     wptools = 0
     call RxFuncAdd 'WPToolsLoadFuncs', 'WPTOOLS', 'WPToolsLoadFuncs'
     if RxFuncQuery("WPToolsLoadFuncs") then do
        call WPToolsLoadFuncs
        wptools = 1
        end
     else
        call RxFuncDrop "WPToolsLoadFuncs"
     end

  processingInit = 1

  lineCount = 1

  filespec = 0            /* no filespec found */
  orgdir = directory()    /* initial directory */
  specs.0 = 0
  sub = 0                 /* /S */
  wide = 0                /* /W */
  full = 0                /* not /B */
  fullPath = 0            /* not /F */
  lower = 0               /* /L */
  verbose = 0             /* /V */
  pause = 0               /* /P */
  attron = ''             /* attributes required */
  attroff = 'SH'          /* attributes exclued */
  sortorder = ''          /* how to sort */
  findobjects = 0         /* should we look for WPS objects? */
  findshadows = 0         /* should we look for WPS shadows? */

  prevdrive = ''
  prevrep = ''
  prevfile = 0
  partialSize = 0
  partialCount = 0
  totalSize = 0
  totalCount = 0

  dirLabel = strip(SysGetMessage(1054)) /* <DIR> */
  objLabel = '<OBJ>'
  linkLabel = '<LINK>'
  parse value SysTextScreenSize() with height width .
  if width = 0 then
    width = 80
  if height = 0 then
    height = 25

  ci = DosQueryCtryInfo()
  iDate = c2d(substr(ci,9,1))    /* 0 = MDY, 1 = DMY, 2 = YMD */
  iTime = c2d(substr(ci,28,1))   /* 0 = 12 Hour clock, 1 = 24 */
  sThousands = substr(ci,18,1)   /* ',' */
  sDate = substr(ci,22,1)        /* '/' */
  sTime = substr(ci,24,1)        /* ':' */

  today = left(date('S'),4)*372+substr(date('S'),5,2)*31+right(date('S'),2)

  bright = 1
  underline = 4
  blink = 5

  black = 30
  red = 31
  green = 32
  yellow = 33
  blue = 34
  magenta = 35
  cyan = 36
  white = 37

  normal = 0

  val = value('DIRCLR.ATTRIB',,'OS2ENVIRONMENT')
  do while val \= ''
     parse var val list ':' color ';' val
     list = translate(list,' ',',')
     do i = 1 to words(list)
        call value 'dirclr._attrib_._'word(list,i), ansivalue(color)
     end /* do */
  end /* do */
  val = value('DIRCLR.EXT',,'OS2ENVIRONMENT')
  do while val \= ''
     parse var val list ':' color ';' val
     list = translate(list,' ',',')
     do i = 1 to words(list)
        call value 'dirclr._ext_.'word(list,i), ansivalue(color)
     end /* do */
  end /* do */
  val = value('DIRCLR.NAME',,'OS2ENVIRONMENT')
  do while val \= ''
     parse var val list ':' color ';' val
     list = translate(list,' ',',')
     do i = 1 to words(list)
        call value 'dirclr._name_.'word(list,i), ansivalue(color)
     end /* do */
  end /* do */
  val = value('DIRCLR.DATE',,'OS2ENVIRONMENT')
  do while val \= ''
     parse var val list ':' color ';' val
     dirclr._date_.newer = -list ansivalue(color)
  end /* do */
  val = value('DIRCLR.NORMAL',,'OS2ENVIRONMENT')
  if val = '' then
     normal = '1b'x'[0m'
  else
     normal = ansivalue(val)

  val = value('DIRCMD',,'OS2ENVIRONMENT')
  if val \= '' then
     call getOptions val
  if invalidOpt = 1 then
     call display SysGetMessage(3154,,'DIRCMD')

  processingInit = 0
  return

ansivalue:
  litcolor = arg(1); ansicolor = ''; on = 0
  do while litcolor \= ''
     parse upper var litcolor item litcolor
     if item = 'ON' then on = 10
     else
       ansicolor = ansicolor || ';' || value(item)+on
  end /* do */

  return '1b'x'['strip(ansicolor,'L',';')'m'

emitHeader1:
  drive = SysDriveInfo(filespec('d',file))
  rep = left(file,lastpos('\',file)-1)
  if length(rep) = 2 then rep = rep'\'

  /* displaying standard directory header */
  if drive \= prevdrive then do
     if prevdrive \= '' then call terminate
     call display SysGetMessage(1516,,left(drive,1),subword(drive,4))
     call display SysGetMessage(1243,,translate('abcd:efgh',word(DosQueryFSInfo(drive),6),'abcdefgh'))
     end
  return

emitHeader2:
  rep = strip(arg(1))
  if length(rep) = 2 then rep = rep'\'

  if rep \= prevrep then do
     if partialCount > 0 then do
        if wide then do
           itemCount = width % (maxWidth+4)
           line = ''
           do _i = 1 to partialCount
              line = line || subword(dir._i,2)
              if _i // itemCount = 0 then do
                 call display line'0d0a'x
                 line = ''
                 end
              else
                 line = line || copies(' ',maxWidth+4-word(dir._i,1))
           end /* do */
           if _i // itemCount \= 1 then call display line'0d0a'x
           maxWidth = 0
           end
        call emit1060 partialCount, partialSize
        end
     partialSize = 0
     partialCount = 0
     if sub then
        call display '0d0a'x
     call display SysGetMessage(1053,,rep)
     end
  else
  if spec \= prevfile then do
     if partialCount > 0 then
        call emit1060 partialCount, partialSize
     partialSize = 0
     partialCount = 0
     end
  if LOCALRC \= 0 then do
     if partialCount > 0 then
        call emit1060 partialCount, partialSize
     partialSize = 0
     partialCount = 0
     call display SysGetMessage(LOCALRC)
     end

  prevdrive = drive
  prevrep = rep
  prevfile = spec
  return

/*
 Heap sort the "file." array in ascending order.
 Algorithm from "Numerical Recipes in Fortran", Cambridge University Press
*/
sort:
  if file.0 < 2 then
     return
  l = trunc(file.0/2)+1
  ir = file.0
  do forever
     if l>1 then do
        l = l-1
        tempd = file.l
        end
     else do
        tempd = file.ir
        file.ir = file.1
        ir = ir - 1
        if ir = 1 then do
           file.1 = tempd
           return
           end
        end
     i = l
     j = l + l
     do while j <= ir
        if j < ir then do
           k = j + 1
           if compare(file.j, file.k) then
              j = j + 1
           end
        if compare(tempd, file.j) then do
           file.i = file.j
           i = j
           j = j + j
           end
        else
           j = ir + 1
     end /* do */
     file.i = tempd
  end /* do */

compare: /* arg(1) < arg(2) */
  procedure expose sortorder
  parse upper value arg(1) with date1 size1 . attr1 fullname1
  parse upper value arg(2) with date2 size2 . attr2 fullname2
  name1 = substr(fullname1,lastpos('\',fullname1)+1)
  name2 = substr(fullname2,lastpos('\',fullname2)+1)

  do i = 1 to words(sortorder)
     order = word(sortorder,i)
     select
        when order = 'D' then do
           if date1 < date2 then return 1
           if date1 > date2 then return 0
           end
        when order = '-D' then do
           if date1 > date2 then return 1
           if date1 < date2 then return 0
           end
        when order = 'S' then do
           if size1 < size2 then return 1
           if size1 > size2 then return 0
           end
        when order = '-S' then do
           if size1 > size2 then return 1
           if size1 < size2 then return 0
           end
        when order = 'N' then do
           if name1 < name2 then return 1
           if name1 > name2 then return 0
           end
        when order = '-N' then do
           if name1 > name2 then return 1
           if name1 < name2 then return 0
           end
        when order = 'E' then do
           p1 = lastpos('.',name1); if p1 = 0 then ext1 = ''; else ext1 = substr(name1,p1+1)
           p2 = lastpos('.',name2); if p2 = 0 then ext2 = ''; else ext2 = substr(name2,p2+1)
           if ext1 < ext2 then return 1
           if ext1 > ext2 then return 0
           end
        when order = '-E' then do
           p1 = lastpos('.',name1); if p1 = 0 then ext1 = ''; else ext1 = substr(name1,p1+1)
           p2 = lastpos('.',name2); if p2 = 0 then ext2 = ''; else ext2 = substr(name2,p2+1)
           if ext1 > ext2 then return 1
           if ext1 < ext2 then return 0
           end
        when order = 'G' then do
           if substr(attr1,2,1) \= substr(attr2,2,1) & substr(attr1,2,1) = 'D' then return 1
           if substr(attr1,2,1) \= substr(attr2,2,1) & substr(attr2,2,1) = 'D' then return 0
           end
        when order = '-G' then do
           if substr(attr1,2,1) \= substr(attr2,2,1) & substr(attr1,2,1) = '-' then return 1
           if substr(attr1,2,1) \= substr(attr2,2,1) & substr(attr2,2,1) = '-' then return 0
           end
        when order = 'P' then do /* only set when sub is 1 */
           if left(fullname1, length(fullname1)-length(name1)) < left(fullname2, length(fullname2)-length(name2)) then return 1
           if left(fullname1, length(fullname1)-length(name1)) > left(fullname2, length(fullname2)-length(name2)) then return 0
           end
     end  /* select */
  end /* do */
  return 0

emit:
  file = value('specs.'arg(1))
  filename = substr(file,lastpos('\',file)+1)

  if \full & \fullPath then call emitHeader1 arg(1)

  maxWidth = 0

  if attron \= '' & attroff \= '' & verify(attron,attroff,'M') \= 0 then
     file.0 = 0
  else do
     attribute = '*****'
     do i = 1 to length(attron)
        attribute = overlay('+',attribute,pos(substr(attron,i,1),'ADHRS'))
     end /* do */
     do i = 1 to length(attroff)
        attribute = overlay('-',attribute,pos(substr(attroff,i,1),'ADHRS'))
     end /* do */

     if sub then
        call DosFileTree file, file., 'TS', attribute
     else
        call DosFileTree file, file., 'T', attribute
     if wptools & (findobjects | findshadows) then
        call findWPSObjects
     if sortorder \= '' then call sort
     else
     if wptools & (findobjects | findshadows) & iRetco \= 0 then do
        sortorder = 'N'
        call sort
        end
     end

  if file.0 = 0 then do
     LOCALRC = 2
     call emitHeader2 left(file,lastpos('\',file)-1)
     end
  else
     LOCALRC = 0

  /* handling relevant files */
  do i = 1 to file.0
     parse var file.i year '/' month '/' day '/' hour '/' min size easize attr name

     if full | fullPath then do
        if right(name,2) = '\.' | right(name,3) = '\..' then iterate
        end
     else
        call emitHeader2 left(name,lastpos('\',name)-1)

     partialSize = partialSize + size
     partialCount = partialCount + 1
     totalSize = totalSize + size
     totalCount = totalCount + 1

     if \ fullPath then
        name = substr(name,lastpos('\',name)+1)
     else
        name = strip(name)
     easize = easize % 2
     if easize = 2 then easize = 0
     if lower then name = translate(name, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')
     itemLength = length(name)
     if itemLength > maxWidth then maxWidth = itemLength
     if substr(attr,2,1) = 'D' then do
        if wide then
           name = '['name']'
        else
           size = dirLabel
        itemLength = itemLength + 2
        end
     if substr(attr,6,1) = 'O' then do
        if wide then
           name = '{'name'}'
        else
           size = objLabel
        itemLength = itemLength + 2
        end
     if substr(attr,7,1) = 'L' then
        size = linkLabel

     /* highlighting relevent files */
     dot = lastpos('.',name); oname = name
     do j = 1 to length(attr)
        if symbol('dirclr._attrib_._'substr(attr,j,1)) = 'VAR' then
           name = value('dirclr._attrib_._'substr(attr,j,1))name
     end /* do */
     if dot > 0 then
        if symbol('dirclr._ext_'substr(oname,dot)) = 'VAR' then
           name = value('dirclr._ext_'substr(oname,dot))name
     if dot = 0 then dot = length(oname)+1
     if symbol('dirclr._name_.'left(oname,dot-1)) = 'VAR' then
        name = value('dirclr._name_.'left(oname,dot-1))name
     if symbol('dirclr._date_.newer') = 'VAR' then
        if today - (year * 372 + month * 31 + day) <= word(dirclr._date_.newer,1) then
           name = subword(dirclr._date_.newer,2)||name
     if length(name) \= itemLength then
        name = name||normal

     if wide then
        dir.partialCount = itemLength name
     else
     if full | fullPath then
        call display name'0d0a'x
     else do
        year = right(year,2)
        select
           when iDate = 0 then fdate = format(month)||sDate||day||sDate||year
           when iDate = 1 then fdate = format(day)||sDate||month||sDate||year
           when iDate = 2 then fdate = year||sDate||month||sDate||day
        end  /* select */
        if iTime = 1 then
           time = format(hour)||sTime||min' '
        else
           if hour < 13 then
              time = format(hour)||sTime||min'a'
           else
              time = format(hour-12)||sTime||min'p'
        if verbose then
          call display right(fdate,8) right(time,6) maybeRight(pprint(size),13) right(pprint(easize),6) left(translate(delstr(attr,2,1), 'arsh', 'ARSH'),4)'  'name'0d0a'x
        else
          call display right(fdate,8) right(time,7) maybeRight(size,9) right(easize,11)'  'name'0d0a'x
        end
  end /* do */

  /* displaying result */
  if wide & partialCount > 0 then do
    itemCount = width % (maxWidth+4)
    line = ''
    do i = 1 to partialCount
      line = line || subword(dir.i,2)
      if i // itemCount = 0 then do
        call display line'0d0a'x
        line = ''
        end
      else
        line = line || copies(' ',maxWidth+4-word(dir.i,1))
    end /* do */
    if i // itemCount \= 1 then call display line'0d0a'x
    end

  if LOCALRC = 0 & \full & \fullPath & spec = specs.0 then
     if sub then do
        call emit1060 partialCount, partialSize
        call display SysGetMessage(3155)
        call emit1060 totalCount, totalSize
        end
     else
        call emit1060 partialCount, partialSize

  return

terminate:
  /* displaying standard directory footer */
  if LOCALRC = 0 & specs.0 \= 0 & \full & \fullPath then
     if verbose then
        call display SysGetMessage(3156,,right(strip(pprint(word(formatSize(word(drive,2)),1)) word(formatSize(word(drive,2)),2)),31))
     else
        call display SysGetMessage(3156,,right(formatSize(word(drive,2)),28))

  call directory orgdir
  return

pprint:
  procedure expose sThousands
  if \ datatype(arg(1), 'N') then
    return arg(1)
  value = reverse(arg(1))
  newval = ''
  do while value \= ''
     parse var value group =4 value
     newval = newval || sThousands || group
  end /* do */
  return strip(reverse(newval),, sThousands)

formatSize:
  procedure
  val = arg(1)
  if \ datatype(val, 'N') then
    return val
  if length(val) <= 9 then
    return val
  val = val % 1024; mod = 'K'
  if length(val) <= 9 then
    return val mod
  val = val % 1024; mod = 'M'
  if length(val) <= 9 then
    return val mod
  val = val % 1024; mod = 'G'
  if length(val) <= 9 then
    return val mod
  val = val % 1024; mod = 'T'
  return val mod

emit1060:
  _size = formatSize(arg(2))
  if verbose then
     _size = right(strip(pprint(word(_size, 1)) word(_size, 2)), 13)
  else
     _size = maybeRight(_size, 10)
  call display SysGetMessage(1060,,format(arg(1),9),_size)
  return

maybeRight:
  if length(arg(1)) > arg(2) then
     return arg(1)
  else
     return right(arg(1),arg(2))

halt:
  call display SysGetMessage(1048)
  call directory orgdir
  exit

display:
  call charout ,arg(1)
  lineCount = lineCount+length(space(translate(arg(1),'             !',,' '),0))
  if pause & lineCount // height = 0 then do
     call charout ,SysGetMessage(1032)
     if pos(SysGetKey('NOECHO'), '00e0'x) > 0 then
        call SysGetKey('NOECHO')
     say
     call charout ,SysGetMessage(3152,,rep)
     lineCount = lineCount+2
     end
  return

findWPSObjects:
  fop = left(file, lastpos('\', file)-1)
  iRetco = WPToolsFolderContent(fop, 'list.')
  if iRetco = 0 then
     return

  do iObject = 1 to list.0
     Iretco = WPToolsQueryObject(list.Iobject, 'szclass', 'sztitle', 'szsetupstring', 'szlocation')
     if Iretco then do
        fsi = file.0 + 1
        if pos(';NOTVISIBLE=YES', ';'szsetupstring) \= 0 then do
           if pos('H', attroff) > 0 then
              iterate
           foattr = 'H----O'
           end
        else do
           if pos('H', attron) > 0 then
              iterate
           foattr = '-----O'
           end
        if szclass = 'WPShadow' | szclass = 'WPNetLink' then
           file.fsi = '0000/00/00/00/00 0 0' foattr'L' fop'\'szTitle
        else
        if findobjects then
           file.fsi = '0000/00/00/00/00 0 0' foattr fop'\'szTitle
        else
           iterate
        file.0 = fsi
        end
  end /* do */

  return
