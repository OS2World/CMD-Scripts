/*SLAUGHTR.CMD from BLKOS2*/
/*copyright 1992,1993 C>BLACK,B.Stone,KUTEK*/
/*all rights reserved*/

call rxfuncadd syssleep,rexxutil,syssleep
'@echo off'
aq=rxqueue("create")
s=rxqueue('set',aq)
'pstat /c |rxqueue' aq
do until queued()=0
pull kjhg
queue kjhg
parse var kjhg c1 c2 c3 c4 c5
if POS('PSTAT.EXE',c4)\=0 then do
idd=c2;leave;end
end
i=0
do until queued()=0
pull w
parse var w c1 c2 c3 c4 c5 c6 
if datatype(c4,N)\=1&c5\=''&length(c1)=4 then do
if right(c4,11)='PMSHELL.EXE' then iterate
if right(c4,7)='CMD.EXE'&c1=idd then iterate
i=i+1
pid.i=c1
say 'CLOSING' c4
end
end
ss=rxqueue("DELETE",aq)
do j=1 to i
pid.j=X2D(pid.j)
do 3
'call killem' pid.j
end
end 

