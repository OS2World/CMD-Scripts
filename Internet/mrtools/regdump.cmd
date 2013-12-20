/*
   Little program to dump Mozilla's registry.dat to human grokkable text

   Usage: RegDump [registry file, typically registry.dat] [out txt]

*/

parse arg parameters
parse var parameters in out
in  = strip(in)
out = strip(out)

Say '--- Mozilla Registry Dump v0.1.0 ---'
Say ''

/* Default values */
if in = '' then do
  call lineout stderr,'Warning: -Invoked without parameters.'
  call lineout stderr,'Usage: regdump [registry file] [text file]'
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
    call readndump newnodes.i,nodes.0
   end
  do i=1 to newfound.0
    newnodes.i = newfound.i
   end
  newnodes.0 = newfound.0
 end

exit

readndump:
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

  if nodes.where.parent > 0 then
    call lineout outdev,''
  call lineout outdev,'-- New node --'
  call lineout outdev,'Number: '||where||', Offset: '||offset||' (0x'||d2x(offset)||')'
  call lineout outdev,'-- Node data --'
  call lineout outdev,'Location: '||right(nodes.where.location,5)||right(d2x(nodes.where.location,4),8)
  call lineout outdev,'namePtr:  '||right(nodes.where.namePtr,5)||right(d2x(nodes.where.namePtr,4),8)
  call lineout outdev,'nameLen:  '||right(nodes.where.nameLen,5)||right(d2x(nodes.where.nameLen,2),8)
  call lineout outdev,'Type:     '||right(nodes.where.type,5)||right(d2x(nodes.where.type,2),8)
  call lineout outdev,'Left:     '||right(nodes.where.left,5)||right(d2x(nodes.where.left,4),8)
  call lineout outdev,'Down:     '||right(nodes.where.down,5)||right(d2x(nodes.where.down,4),8)
  call lineout outdev,'valuePtr: '||right(nodes.where.valuePtr,5)||right(d2x(nodes.where.valuePtr,4),8)
  call lineout outdev,'valueLen: '||right(nodes.where.valueLen,5)||right(d2x(nodes.where.valueLen,4),8)
  call lineout outdev,'parent:   '||right(nodes.where.parent,5)||right(d2x(nodes.where.parent,4),8)
  call lineout outdev,'-- Additional --'
  call lineout outdev,'Name:         "'||nodes.where.name||'"'

  /*
     The actual comparison here was with the bit no. 4, i.e. 000x0000 in type
     v.g. substr(x2b(d2x(type,2)),4,1) = 1, but what the hell...
  */
  if nodes.where.type >= 16 then do
    nodes.where.value = substr(regdata,nodes.where.valuePtr +1,nodes.where.valueLen)
    select
      /* Apparently, 17 is text */
      when nodes.where.type = 17 then
        nodes.where.value = '"'||strip(nodes.where.value,,'00'x)||'"'
      otherwise
        nodes.where.value = 'x2c('||c2x(nodes.where.value)||')'
     end
    call lineout outdev,'Value:        '||nodes.where.value
   end

  if nodes.where.type < 16 then do
    if (nodes.where.valuePtr > 0 ) & (nodes.where.valueLen = 0) then do
      call lineout outdev,'Navigates to: '||nodes.where.valuePtr
      call addnew nodes.where.valuePtr
     end
    if nodes.where.down > 0 then do
      call lineout outdev,'Navigates to: '||nodes.where.down
      call addnew nodes.where.down
     end
   end

  if nodes.where.left > 0 then do
    call lineout outdev,'Navigates to: '||nodes.where.left
    call addnew nodes.where.left
   end

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
