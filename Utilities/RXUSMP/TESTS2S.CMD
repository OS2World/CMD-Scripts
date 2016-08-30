/* rexx */

/* Access a structure contained in shared memory */

if rxfuncquery('rxstructmap') then
  do
  call rxfuncadd 'yinit','ydbautil','rxydbautilinit'
  call yinit
  end

arg memname .

call rxgetnamedsharedmem 'ptr',memname,'w'

s.0=5
s.p=1
s.1.t='L'  /* unsigned long */
s.2.t='c'  /* character array (35 bytes) */
s.2.l=35
s.3.t='s'  /* signed short */
s.4.t='d'  /* double */
s.5.t='c'  /* character array (10 bytes) */
s.5.l=10

map = rxstructmap('s.')

call rxstruct2stem 'm.',ptr,map

call rxvlist 'm.'

q.1 = 365
q.2 = left('my string',35,'00'x)
q.3 = -12
q.4 = 3.1415926
q.5 = left('more data',10,'00'x)

call rxstem2struct 'q.',ptr,map
'@pause'

call rxfreemem ptr
'@pause'

exit
