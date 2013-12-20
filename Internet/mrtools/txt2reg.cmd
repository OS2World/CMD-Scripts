/*
   Little program to generate a Mozilla registry file from a text template
   Usage: reg2txt <txt file> <binary file>
*/

parse arg in out
in  = strip(in)
out = strip(out)

Say '--- Mozilla Text to Registry converter v0.1.0 ---'
Say ''

/* Default values */
if (in = '') | (out = '') then do
  call lineout stderr,'Warning: -Invoked without parameters.'
  call lineout stderr,'Usage: txt2txt <txt file> <binary file>'
  call lineout stderr,''
  exit 1
 end

check = stream(in,'C','QUERY EXISTS')
if check = '' then do
  call lineout stderr,'Could not open the text template "'||in||'"'
  exit 2
 end

call read_reg
Say '--- Registry read, '||nodes.0||' node(s).'

/* Default stuff */
magic     = '41446476'x
vmajor    = '0100'x
vminor    = '0200'x

/* Initialize Root node position with std value */
next_wpos = 128

Say '--- Calculating node offset(s).'
do i=1 to nodes.0
  call node_setpos i
  Say 'Node '||right(i,length(nodes.0))||': '||nodes.i.location
 end

Say '--- Resolving cross reference(s).'
do i=1 to nodes.0
  call node_xref i
 end

Say '--- Done. Dumping binary file "'||out||'".'
'@del "'||out||'" >NUL 2>&1'

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
exit

read_reg:
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
          call lineout stderr,'Please insert nodes in sequential order!'
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
        else /* Add string terminator */
          newvalue = newvalue||'00'x
        nodes.NodeNo.value = newvalue
       end
      otherwise
        call lineout stderr,'Unknown parameter: '||param
     end

   end
  call stream in,'C','CLOSE'
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
