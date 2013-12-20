/*
   Little program to convert Mozilla's registry.dat to text

   Usage: reg2txt [registry file, typically registry.dat] [out txt]

*/

parse arg parameters
parse var parameters in out
in  = strip(in)
out = strip(out)

Say '--- Mozilla Registry to Text converter v0.1.0 ---'
Say ''

/* Default values */
if in = '' then do
  call lineout stderr,'Warning: -Invoked without parameters.'
  call lineout stderr,'Usage: reg2txt [registry file] [text file]'
  call lineout stderr,''
  call lineout stderr,'Warning: registry file not specified.'
  call lineout stderr,'Defaulting to "registry.dat" in current directory.'
  call lineout stderr,''
  in = 'registry.dat'
 end

if out <> '' then
  outdev = out
else do
  call lineout stderr,'Text file not specified. Defaulting to screen output'
  call lineout stderr,''
  outdev = stdout
 end

check = stream(in,'C','QUERY EXISTS')
if check = '' then do
  call lineout stderr,'Could not open the registry file "'||in||'"'
  exit 1
 end

regdata = charin(in,1,chars(in))
call stream in,'C','CLOSE'

magic     = substr(regdata,1,4)
vmajor    = c2d(reverse(substr(regdata,5,2)))
vminor    = c2d(reverse(substr(regdata,7,2)))
hdr_avail = c2d(reverse(substr(regdata,9,4)))
hdr_root  = c2d(reverse(substr(regdata,13,4)))

if magic <> '41446476'x then do
  call lineout stderr,'Error: not a Registry file'
  exit 2
 end

/*
   Obviously we got no nodes yet but we know there's at least one
   -> Keep going where no one's gone before :)
*/

nodes.0    = 0
newnodes.0 = 1
newnodes.1 = hdr_root

/*
   If REXX, recursivity and I mixed together, we could just readndump(root) and 
   readndump(newnode) on the fly inside the function, like in the Perl code I'm
   resembling here...
*/
do until newnodes.0 = 0
  newfound.0 = 0
  do i=1 to newnodes.0
    nodes.0 = nodes.0 +1
    call readnode newnodes.i,nodes.0
   end
  do i=1 to newfound.0
    newnodes.i = newfound.i
   end
  newnodes.0 = newfound.0
 end

/* Translate the offset mess into something more useful - node numbers? */
do i=1 to nodes.0

  nodes.i.child = ''
  nodes.i.NextSibling = ''
  nodes.i.pointed = ''

  if nodes.i.type < 16 then do
    if (nodes.i.valuePtr > 0 ) & (nodes.i.valueLen = 0) then
      nodes.i.pointed = nodes.i.valuePtr
    if nodes.i.down > 0 then
      nodes.i.child = nodes.i.down
   end

  if nodes.i.left > 0 then
    nodes.i.NextSibling = nodes.i.left
  do j=1 to nodes.0
    if nodes.i.location = nodes.j.parent then
      nodes.j.parentNo = i
    if nodes.i.pointed = nodes.j.location then
      nodes.i.pointed = j
    if nodes.i.child = nodes.j.location then
      nodes.i.child = j
    if nodes.i.NextSibling = nodes.j.location then
      nodes.i.NextSibling = j
   end
 end

do i=1 to nodes.0
  if nodes.i.parent > 0 then
    call lineout outdev,''
  call lineout outdev,';-- New node --'
  call lineout outdev,'Number:    '||i
  call lineout outdev,'Type:      '||nodes.i.type
  call lineout outdev,'Name:      "'||nodes.i.name||'"'
  if nodes.i.value <> 'NODES.'||i||'.VALUE' then
    call lineout outdev,'Value:     '||nodes.i.value
  if nodes.i.parent >0 then
    call lineout outdev,'Parent:    '||nodes.i.parentNo
  if nodes.i.NextSibling <> '' then
    call lineout outdev,'Sibling:   '||nodes.i.NextSibling
  if nodes.i.child <> '' then
    call lineout outdev,'1st child: '||nodes.i.child
  if nodes.i.pointed <> '' then
    call lineout outdev,'2nd child: '||nodes.i.pointed
 end

exit

readnode:
  parse arg offset,where
  node_data = substr(regdata,offset +1,32)
  nodes.where.location = c2d(reverse(substr(node_data, 1,4)))
  nodes.where.namePtr  = c2d(reverse(substr(node_data, 5,4)))
  nodes.where.nameLen  = c2d(reverse(substr(node_data, 9,2)))
  nodes.where.type     = c2d(reverse(substr(node_data,11,2)))
  nodes.where.left     = c2d(reverse(substr(node_data,13,4)))
  nodes.where.down     = c2d(reverse(substr(node_data,17,4)))
  nodes.where.valuePtr = c2d(reverse(substr(node_data,21,4)))
  nodes.where.valueLen = c2d(reverse(substr(node_data,25,4)))
  nodes.where.parent   = c2d(reverse(substr(node_data,29,4)))
  nodes.where.name     = strip(substr(regdata,nodes.where.namePtr +1,nodes.where.nameLen),,'00'x)
  /*
     The actual comparison here was with the bit no. 4, i.e. 000x0000 in type
     v.g. substr(x2b(d2x(type,2)),4,1) = 1, but what the hell...
  */
  if nodes.where.type >= 16 then do
    nodes.where.value = substr(regdata,nodes.where.valuePtr +1,nodes.where.valueLen)
    select
      when nodes.where.type = 17 then
        nodes.where.value = '"'||strip(nodes.where.value,,'00'x)||'"'
      otherwise
        nodes.where.value = 'x2c('||c2x(nodes.where.value)||')'
     end
   end
  if nodes.where.type < 16 then do
    if (nodes.where.valuePtr > 0 ) & (nodes.where.valueLen = 0) then
      call addnew nodes.where.valuePtr
    if nodes.where.down > 0 then
      call addnew nodes.where.down
   end
  if nodes.where.left > 0 then
    call addnew nodes.where.left
return

addnew:
  parse arg new_offset
  known = 0
  do j=1 to newfound.0
    if new_offset = newfound.j then do
      known = 1
      leave
     end
   end
  if known = 0 then do
    newpos = newfound.0 +1
    newfound.newpos = new_offset
    newfound.0 = newpos
   end
return
