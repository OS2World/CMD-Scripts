/*DIRDEL.CMD*/
/*copyright (c) C>BLACK,B.STONE, KUTEK 1993*/
/*all rights reserved, USE AT YOUR OWN RISK*/
/*recursive delete utility*/
/*command line utility,not to be used in batch files*/
/*usage: dirdel <drv:dir>  <filespec> < / >   */
/*  " / " parameter specifies to remove the top dir also*/
/*without it it will remove files in the top dir*/
/*and all sub directories, and the sub dirs themselves*/
/* file spec can be used to remove files of a certain type */
/*throughout a tree*/
/*example dirdel c:os2 removes C:\os2 leaving only the empty*/
/*c:\OS2 directory*/
/*example: dirdel c:winos2 removes C:\OS2\MDOS\WINOS2*/
/* example: dirdel c:os2  *.exe removes .exe files from os2 and all subs*/
/*example: dirdel c:os2 / removes entire os2 tree*/
/* dirdel needs to have access to the D.cmd in order to function*/
/*place both in you path*/
/*remove these comments from your working copy*/

'@echo off'
blonk=0
fiz=0
fle=''
lut=0
ko=''
ss=rxfuncquery(sysloadfuncs)
if ss=1 then do
call rxfuncadd sysloadfuncs,rexxutil,sysloadfuncs
call sysloadfuncs;end
curr=directory()
cfr=0
arg naa rtz fle
if aa ='' then do
say 'NO INPUT PARAMETERS SPECIFIED PROGRAM ABORTING'
exit
end
if substr(naa,3,1)='\' then do
parse var naa asw'\'asq
naa=asw||asq
end
if naa='/' then rtz='/'
else if rtz\='/' then fle=rtz
if naa='*'|naa='/' then aa=curr
else do
s4=value(noff,naa,'OS2ENVIRONMENT')
'call d'
aa=value(noff,,'os2environment')
if naa=aa then do
   say 'DIRECTORY DOES NOT EXIST'
exit
end
if aa=''|aa='AA' then do
say 'ABORTING DELETE'
exit
end
'set noff='
end
'cd\'
if right(aa,1)\='\'then aa=aa'\'
if fle=''&right(aa,1)='\' & length(aa)=3 & pos(':',aa)\=0 then do
say 'WARNING THIS IS THE ROOT DIRECTORY!!!!'
say 'THE ENTIRE DISK WILL BE DELETED!! PROCEED? (y/N)'
pull ans
if ans\='Y' then do
s=directory(curr)
exit
end
end
a=sysfiletree(aa,dir,dst)
do i=1 to dir.0
parse var dir.i k1 k2 k3 k4
k4=strip(k4,'b')
xxx.i=k4
end
call checkatt
do l=dir.0 to 1 by -1
nn=sysrmdir(xxx.l)
if nn=0 then say xxx.l 'REMOVED'
cfr=nn+cfr
end

if cfr=0 then do
if (rc=0)&(rtz\='/')&fle='' then say 'SUB DIRECTORIES REMOVED'
if rtz='/' then do
tt=strip(aa,'T','\')
hh=sysrmdir(tt)
end
if hh=0&fle='' then do
 say 'DIR TREE 'tt' HAS BEEN REMOVED'
exit
end
end
else if fle='' &fiz\=0 then say 'ERROR:DELETE PROCESS NOT COMPLETED'
else if fle\=''&fiz=0 then say 'SPECIFIED FILES REMOVED'
if aa\=curr then s=directory(curr)
exit

checkatt:
bb=sysfiletree(aa||fle,'fil','bst','*****',ko)
if fil.0=0 then say 'FILES DO NOT EXIST'
do u=1 to fil.0
parse var fil.u o1 o2 o3 o4
if (pos('D',o3)=2) then iterate
if (pos('H',o3)=3)|(pos('R',o3)=4)|(pos('S',o3)=5) then do
lut =1
if blonk\=1 then iterate
end
do
say 'deleting' o4
o4=strip(o4,'B')
dsc= sysfiledelete(o4)
if dsc>0 then fiz=1
end
end
if blonk\=1&lut=1 then do
say' THERE ARE H, R, OR S ATTRIBUTE FILES IN THE TARGET TREE'
say 'DO YOU WANT TO DELETE THEM NOW(Y/N)?'
cc=sysgetkey()
if cc='Y'|cc='y' then do
blonk=1
ko='**---'
call checkatt
end
else  do
say 'DELDIR ABORTED'
exit
end
end
return





