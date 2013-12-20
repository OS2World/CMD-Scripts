/*
   Little program to run Mozilla apps in a better way
   Now featuring FULLY mobile profiles... Poor man's roaming? you bet!
*/
'@Echo Off'
if RxFuncQuery('SysLoadFuncs') then do
  call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  call SysLoadFuncs
 end
if RxFuncQuery('ULSLoadFuncs') then do
  call RxFuncAdd 'ULSLoadFuncs', 'RXULS', 'ULSLoadFuncs'
  call ULSLoadFuncs
 end

/* Global var stuff */

/* Find a little about myself... */

parse source HostOS CallType ThisFile
HomeDrv = filespec("drive",ThisFile)
HomeDirSlash = HomeDrv||filespec("path",ThisFile)
CallDir = directory()
CallDrv = filespec("drive",CallDir)

Say 'MozCall v0.3.0'

parameters = Value('REXXPARMS',,'OS2ENVIRONMENT')
/* For some reason, this file may be running on its own - let's play along */
if parameters = '' then
  parse arg parameters

/* If you must specify a .cfg file tell me so */
parse var parameters what1st .
if left(translate(what1st),4) = '-CFG' then do
  parse var parameters cfgfile parameters
  cfgfile = substr(cfgfile,5)
 end
/* Or let's check the good ol' way */
else do
  batch = Value('BATCHFILE',,'OS2ENVIRONMENT')
  if batch <> '' then
    cfgfile = substr(batch,1,lastpos('.',batch))||'cfg'
 end

cfgfile = stream(cfgfile,'C','QUERY EXISTS')
if cfgfile = '' then do
  call lineout stderr,'Error: no config file found.'
  call lineout stderr,''
  call lineout stderr,'Usage: MozCall [-cfg<file.cfg>] [<parameters>]'
  call lineout stderr,'If no .cfg file is specified, one called 'substr(batch,1,lastpos('.',batch))||'cfg should be present.'
  exit 1
 end

call def_values
call read_cfg cfgfile
call cfg_relpaths
call check_cfg

if roaming = 1 then
  call roaming_setup

lang = Value('LANG',,'OS2ENVIRONMENT')
parse var lang language '_' country '_' .
if UILocale = 1 then
  parameters = parameters||' -UILocale '||language||'-'||country
if contentLocale = 1 then
  parameters = parameters||' -contentLocale '||country

/* And (set env vars, and) go! */
If Extended_FT2 = 1 then
  'SET MOZILLA_USE_EXTENDED_FT2LIB=T'
If BeginLibPath = 1 then
  'SET BEGINLIBPATH='||MozDir||';%BEGINLIBPATH%'
If Path = 1 then
  'SET PATH='||MozDir||'%PATH%'
If Moz_No_Remote = 1 then
  'SET MOZ_NO_REMOTE=1'
If LibPathStrict = 1 then
  'SET LIBPATHSTRICT=T'
'SET MOZILLA_HOME='||MozHome

Say
Say '--- Running application from '||MozDir||' ... '
Say 'Command line: "'||MozExe||' '||parameters||'"'
call directory MozDir
if separate_session = 1 then
  'start '||MozExe||' '||parameters
else
  MozExe||' '||parameters
/* Exit, pass along Mozilla exit code, and return to the original dir */
Say 'Return code: '||rc
call directory CallDir

exit rc

/*
   subst v1.1 2006/12/19

   Funci¢n que sustituye una cadena dentro de una m s grande por otra cadena;
   Par metros:
   1) Cadena que contiene lo que queremos sustituir
   2) Cadena que queremos sustituir
   3) Por lo que queremos sustituilla
   4) Cu ntas apariciones queremos sustituir (0=todas), empezando por el
     principio

   Observaciones:
   1) En caso de no querer hacer sustituciones, bastar¡a con NO llamar a la
     funci¢n, de ah¡ que se pueda especificar n=0 para sustituir todas las
     apariciones
*/

subst: procedure
  parse arg string,searchthis,replacement,howmany
  if howmany = '' then howmany = 0 
  len = length(searchthis)
  changes = 0
  ready = ''  
  do until (loc = 0) | changes=howmany
    loc = pos(searchthis,string)
    if loc > 0 then do
      ready = ready || substr(string,1,loc-1) || replacement 
      string = substr(string,loc+len)
      howmany=howmany+1
     end
   end
return ready || string

/*
   Function that returns the complete URI a relative link points to, given
   a base URI, and a flag that indicates if the base URI is that of a file
   or a directory:

   With base URI "a/b/c" the relative link 'd/e/f' will point
   to "a/b/c/d/e/f" if "a/b/c" is a directory, and
   to "a/b/d/e/f" if it is a file.

   By default, a file is assumed, since it is not directories what contain
   links, but rather directory listings (transient files?)...

   Parameters: <base_URI>,<rel_link>,F|D

   Remarks: also works for relative paths within a UNIX-type filesytem
*/

add_link: procedure
  parse arg baseuri,rel_uri,flag
  if flag = '' then
    flag = 'F'
  /* The 'relative' link is actually an absolute one -> we're done */
  if (pos('://',rel_uri)>0 | pos(':\',rel_uri)>0)then
    return rel_uri
  rel_uri = subst(rel_uri,'&amp;','&',0)
  /*
     A DOS-related stupidity fix: (unix-like relative paths have always been
     accepted by DOS browsers, so no need to use '\' )
  */
  rel_uri = subst(rel_uri,'\','/')
  if pos('\',baseuri)>0 then ds = '\'
  else ds = '/'
  parse var baseuri scheme '://' host '/' path '?' query '#' anchor
  select
    when rel_uri = '' then
      res = baseuri
    /* Disguised absolute URIs, found in IBM's pages  */
    when left(rel_uri,2) = '//' then
      res = scheme||':'||rel_uri
    when left(rel_uri,1) = '/' then
      res = scheme||'://'||host||rel_uri
    otherwise
      /* Now the common part */
      if flag = 'F' then
        base = substr(baseuri,1,lastpos(ds,baseuri))
      else
        base = baseuri||ds
      if left(rel_uri,2)='./' then
        rel_uri = substr(rel_uri,3)
      do while left(rel_uri,3) = '../'
        parse var rel_uri '../' rel_uri
        base = substr(base,1,length(base)-1)
        base = substr(base,1,lastpos(ds,base))
       end
      res = subst(base||rel_uri,'/',ds)
   end
return res

file2list:
  parse arg filename,listname
  cnt = 0
  if filename<>'' then do
    open=stream(filename,'C','OPEN READ')
    if open='READY:' then do
      do while lines(filename)>0
        txt=linein(filename)
        if txt<>'' & left(txt,1)<>'#' & left(txt,1)<>';' & left(txt,2)<>'//' then do
          cnt=cnt+1
          call value value(listname).cnt,txt
         end
       end
      call stream filename,'C','CLOSE'
     end /* end if open='READY:'*/
   end /*end if filename <> '' */
  call value value(listname).0,cnt
return

subst_env:
  parse arg string
  do while pos('%',string)>0
    parse var string head '%' varname '%' tail
    string = head||value(varname,,'OS2ENVIRONMENT')||tail
   end
return string

def_values:
  MozExe        = ''
  MozDir        = ''
  MozHome       = './'
  CacheParent   = ''
  BeginLibPath  = 0
  Path          = 0
  Moz_No_Remote = 0
  LibPathStrict = 0
  roaming       = 0
  AppType       = ''
  separate_session = 0
return

read_cfg:
  /* Huge risks of getting internal vars overwritten here */
  call file2list cfgfile,cfg_var
  do i=1 to cfg_var.0
    parse var cfg_var.i vname '=' vvalue
    vname  = strip(vname)
    vvalue = strip(vvalue)
    call value vname,vvalue
   end
return

/* Convert relative values within .cfg file to absolute */
cfg_relpaths:
  MozHome     = add_link(cfgfile,subst_env(MozHome))
  if right(MozHome,1) = '\' & directory(MozHome) = '' then
    MozHome = substr(MozHome,1,length(MozHome)-1)
  if right(MozHome,1) = '\' then
    MozHomeS  = MozHome
  else
    MozHomeS  = MozHome||'\'
  MozDir      = add_link(cfgfile,subst_env(MozDir))
  CacheParent = add_link(cfgfile,subst_env(CacheParent))
return

/*
   Now let's check if the program is in place...
   ToDo: check if the CacheParent dir is writable
*/
check_cfg:
  MozDir = directory(MozDir)
  if MozDir = '' then do
    call lineout stderr,'Error: Application directory could not be accessed. Exiting.'
    exit 1
   end
  rc = stream(MozDir||'\'||MozExe,'C','QUERY EXISTS')
  if rc = '' then do
    call lineout stderr,'Error: Application executable could not be found. Exiting.'
    exit 1
   end
  AppType = translate(AppType)
  if roaming = 1 & pos(AppType,'SM MZ TB FX') = 0 then do
    call lineout stderr,'Application type must be specified as one of: SM MZ TB FX.'
    exit 1
   end
return

roaming_setup:
  Say
  say '--- Roaming enabled. Looking for profiles to patch.'
  select
    when AppType = 'MZ' then
      call make_reg
    when AppType = 'SM' then
      call read_ini MozHomeS||'Mozilla'
    when AppType = 'FX' then
      call read_ini MozHomeS||'Mozilla\FireFox'
    when AppType = 'TB' then
      call read_ini MozHomeS||'ThunderBird'
    otherwise nop
   end
  /* Now we should have a list of profiles... */
  Say
  say 'Detected '||profiles.0||' profiles(s).'
  /*
     But profile paths should be stored:
     -in UTF-8 (aka CP1208) in the registry / profiles.ini
     -in local CP in the preferences themselves
     Argh :(
  */
  if RxFuncQuery('ULSConvertCodepage') then do
    call lineout StdErr
    call lineout StdErr,'Warning: Unicode conversion routines not available.'
    call lineout StdErr,'Some profiles may not be accessible to patch...'
    call lineout StdErr,'... or not usable at all !!'
   end
  do i=1 to profiles.0
    if RxFuncQuery('ULSConvertCodepage') = 0 then
      profiles.i = ULSConvertCodepage(profiles.i,'1208',SysQueryProcessCodePage())
    PrefsT = stream(profiles.i||'\prefs.txt','C','QUERY EXISTS')
    if PrefsT <> '' then do
      say ''
      say 'Profile '||right(i,length(profiles.0))||': '||profiles.i
      call patch_prefs profiles.i
     end
   end
return

read_ini:
  parse arg inidir
  profiles.0 = 0
  profiles_ini = inidir||'\profiles.ini'
  profiles_txt = stream(inidir||'\profiles.txt','C','QUERY EXISTS')
  if profiles_txt <> '' then do
    if stream(inidir||'\profiles.old','C','QUERY EXISTS') <> '' then
      '@del "'||inidir||'\profiles.old" >NUL 2>&1'
    if stream(profiles_ini,'C','QUERY EXISTS') <> '' then do
      '@ren "'||profiles_ini||'" *.old >NUL 2>&1'
      if rc <> 0 then do
        call lineout StdErr,'Warning: failed archiving "'||profiles_ini||'" - running app? skipping!'
        return
       end
     end
    do while lines(profiles_txt)>0
      newln = linein(profiles_txt)
      parse var newln part1 '=' part2
      if translate(part1) = 'PATH' then do
        prev = part2
        /* They are supposed to be relative, aren't they? */
        part2        = add_link(profiles_txt,subst_env(part2))
        cnt          = profiles.0 +1
        profiles.cnt = part2
        profiles.0   = cnt
        newln = part1||'='||part2
        if part2 <> prev then 
          Say 'Changed: "'||prev||'" -> "'||part2||'"'
       end
      call lineout profiles_ini,newln
     end
    call stream profiles_txt,'C','CLOSE'
   end
  else 
    do while lines(profiles_ini)>0
      newln = linein(profiles_ini)
      parse var newln part1 '=' part2
      part1 = translate(part1)
      if part1 = 'PATH' then do
        part2        = add_link(profiles_ini,part2)
        cnt          = profiles.0 +1
        profiles.cnt = part2
        profiles.0   = cnt
       end
     end
  call stream profiles_ini,'C','CLOSE'
return

patch_prefs:
  parse arg profdir
  prefs_file = profdir||'\prefs.js'
  prefs_tmpl = profdir||'\prefs.txt'
  call file2list prefs_file,'settings'
  call file2list prefs_tmpl,'patch'
  do j=1 to patch.0
    parse var patch.j prhead ',' '"' setvalue '"' prtail
    parse var setvalue svhead '[' macro ']' relpath
    say ' '||patch.j
    style = ''
    do while left(macro,1) = '\' | left(macro,1) = '/'
      style = style||left(macro,1)
      macro = substr(macro,2)
     end
    select
      when translate(macro) = 'PROFD' then
        setvalue = svhead||add_link(profdir,relpath,'D')
      when translate(macro) = 'MOZHOME' then
        setvalue = svhead||add_link(MozHome,relpath,'D')
      when translate(macro) = 'CACHEPARENT' then
        setvalue = svhead||add_link(CacheParent,relpath,'D')
      otherwise nop
     end
    if style <> '' then
      setvalue = subst(setvalue,'\',style)
    insertpos = 0
    do k=1 to settings.0
      if pos(prhead,settings.k) = 1 then do
        insertpos = k
        Say ' -> Changed to "'||setvalue||'"'
        leave
       end
     end
    if insertpos = 0 then do
      insertpos = settings.0 +1
      settings.0 = insertpos
      Say ' -> Added as "'||setvalue||'"'
     end
    settings.insertpos = prhead||', "'||setvalue||'"'||prtail
   end

  if stream(profdir||'\prefs.old','C','QUERY EXISTS') <> '' then
    '@del "'||profdir||'\prefs.old" >NUL 2>&1'
  if stream(prefs_file,'C','QUERY EXISTS') <> '' then do
    '@ren "'||prefs_file||'" *.old >NUL 2>&1'
    if rc <> 0 then do
      call lineout StdErr,'Warning: failed archiving "'||prefs_file||'" - running app? skipping!'
      return
     end
   end
  do j=1 to settings.0
    call lineout prefs_file,settings.j
    call stream prefs_file,'C','CLOSE'
   end
return

/* Damn obsolete registry.dat stuff */

make_reg:
  RegDir   = MozHomeS||'Mozilla'
  RegTmpl  = RegDir||'\registry.txt'
  Registry = RegDir||'\registry.dat'
  check = stream(RegTmpl,'C','QUERY EXISTS')
  if check = '' then
    call lineout stderr,'Warning: Mozilla registry template "'||RegTmpl||'" not found.'
  else do
    Say '--- Reading registry template "'||RegTmpl||'"'
    call read_reg RegTmpl
    Say '--- Done, '||nodes.0||' node(s).'
    if stream(RegDir||'\registry.old','C','QUERY EXISTS') <> '' then
      '@del "'||RegDir||'\registry.old" >NUL 2>&1'
    if stream(Registry,'C','QUERY EXISTS') <> '' then do
      '@ren "'||Registry||'" *.old >NUL 2>&1'
      if rc <> 0 then do
        call lineout StdErr,'Warning: failed archiving "'||Registry||'" - running app? skipping!'
        return
       end
     end
    call dump_reg Registry
   end
return

read_reg:
  profiles.0 = 0
  parse arg in
  nodes.0 = 0
  do while lines(in) > 0
    newln = linein(in)
    if pos(left(newln,1),' ;#') >0 then
      iterate
    parse var newln param ':' newvalue
    param = translate(strip(param))
    newvalue = strip(newvalue)
    select
      when param = 'NUMBER' then do
        if newvalue = (nodes.0 +1) then do
          NodeNo = newvalue
          nodes.NodeNo.parentNo = 0
          nodes.NodeNo.parent   = 0
          nodes.NodeNo.name     = ""
          nodes.NodeNo.dtype    = ""
          nodes.NodeNo.leftNo   = 0
          nodes.NodeNo.left     = 0
          nodes.NodeNo.downNo   = 0
          nodes.NodeNo.down     = 0
          nodes.NodeNo.value    = 0
          nodes.NodeNo.2child   = 0
          nodes.0 = NodeNo
         end
        else do
          call lineout stderr,'Registry nodes NOT in sequential order!'
          call lineout stderr,'Expecting node number '||nodes.0 +1||', found '||newvalue||'!'
          exit 1
         end
       end
      when param = 'TYPE' then
        nodes.NodeNo.dtype    = newvalue
      when param = 'NAME' then do
        newvalue = strip(newvalue,,'"')
        nodes.NodeNo.name     = newvalue
       end
      when param = 'PARENT' then
        nodes.NodeNo.parentNo = newvalue
      when param = '1ST CHILD' then
        nodes.NodeNo.downNo = newvalue
      when param = '2ND CHILD' then
        nodes.NodeNo.2child = newvalue
      when param = 'SIBLING' then
        nodes.NodeNo.leftNo = newvalue
      when param = 'VALUE' then do
        newvalue = strip(newvalue,,'"')
        if pos('x2c',newvalue) > 0 then do
          parse var newvalue with 'x2c(' newvalue ')'
          newvalue = x2c(newvalue)
         end
        else do
          /* New profile paths -> convert to absolute, store */
          if nodes.NodeNo.name = 'directory' then do
            oldvalue = newvalue
            newvalue = add_link(in,subst_env(newvalue))
            if newvalue <> oldvalue then
              Say 'Changed: "'||oldvalue||'" -> "'||newvalue||'"'
            cnt          = profiles.0 +1
            profiles.cnt = newvalue
            profiles.0   = cnt
           end
          /* Add string terminator */
          newvalue = newvalue||'00'x
         end
        nodes.NodeNo.value = newvalue
       end
      otherwise
        call lineout stderr,'Unknown parameter: '||param
     end

   end
  call stream in,'C','CLOSE'
return

dump_reg:
  parse arg out

  /* Default stuff */
  magic     = '41446476'x
  vmajor    = '0100'x
  vminor    = '0200'x
  /* Initialize Root node position with std value */
  next_wpos = 128

  Say 'Calculating node offset(s)...'
  do i=1 to nodes.0
    call node_setpos i
   end

  Say 'Resolving cross references...'
  do i=1 to nodes.0
    call node_xref i
   end
  
  Say '--- Done. Dumping binary file "'||out||'".'
  call charout out,magic
  call charout out,vmajor
  call charout out,vminor
  call charout out,reverse(x2c(d2x(regsize,8)))
  call charout out,reverse(x2c(d2x(nodes.1.location,8)))
  /* Padding zeros */
  call charout out,copies('00'x,nodes.1.namePtr -16)
  do i=1 to nodes.0
    call node_dump i
   end
  call stream out,'C','CLOSE'
return

node_setpos:
  parse arg Nodeno
  nodes.NodeNo.NamePtr = next_wpos
  nodes.NodeNo.NameLen = length(nodes.NodeNo.name) +1
  /* Has it a 'strange' child? */
  if nodes.NodeNo.2child > 0 then do
    nodes.NodeNo.valuePtr = '?' /* yet */
    nodes.NodeNo.valueLen = 0
   end
  /* Then has it a value? */
  else
    if nodes.NodeNo.value = 0 then do
      nodes.NodeNo.valuePtr = 0
      nodes.NodeNo.valueLen = 0
     end
    else do
      nodes.NodeNo.valuePtr = nodes.NodeNo.NamePtr + nodes.NodeNo.NameLen
      nodes.NodeNo.valueLen = length(nodes.NodeNo.value)
     end
  /* At last we know this node location */
  nodes.NodeNo.location = nodes.NodeNo.NamePtr + nodes.NodeNo.NameLen + nodes.NodeNo.valueLen
  /* The next node should be adjacent to this one */
  next_wpos = nodes.NodeNo.location +32
  /* For now, the whole file is this size */
  regsize = next_wpos 
return

node_xref:
  parse arg Nodeno
  /* Calculating each node physical offset and layout */
  if nodes.NodeNo.parentNo > 0 then do
    nfs = nodes.NodeNo.parentNo
    nodes.NodeNo.parent = nodes.nfs.location
   end
  if nodes.NodeNo.leftNo > 0 then do
    nfs = nodes.NodeNo.leftNo
    nodes.NodeNo.left = nodes.nfs.location
   end
  if nodes.NodeNo.downNo > 0 then do
    nfs = nodes.NodeNo.downNo
    nodes.NodeNo.down = nodes.nfs.location
   end
  if nodes.NodeNo.2child > 0 then do
    nfs = nodes.NodeNo.2child
    nodes.NodeNo.valuePtr = nodes.nfs.location
   end
return

node_dump:
  parse arg NodeNo
  call charout out,nodes.NodeNo.name||'00'x
  if nodes.NodeNo.valueLen > 0 then
    call charout out,nodes.NodeNo.value
  call charout out,reverse(x2c(d2x(nodes.NodeNo.location,8)))
  call charout out,reverse(x2c(d2x(nodes.NodeNo.namePtr,8)))
  call charout out,reverse(x2c(d2x(nodes.NodeNo.nameLen,4)))
  call charout out,reverse(x2c(d2x(nodes.NodeNo.dtype,4)))
  call charout out,reverse(x2c(d2x(nodes.NodeNo.left,8)))
  call charout out,reverse(x2c(d2x(nodes.NodeNo.down,8)))
  call charout out,reverse(x2c(d2x(nodes.NodeNo.valuePtr,8)))
  call charout out,reverse(x2c(d2x(nodes.NodeNo.valueLen,8)))
  call charout out,reverse(x2c(d2x(nodes.NodeNo.parent,8)))
return
