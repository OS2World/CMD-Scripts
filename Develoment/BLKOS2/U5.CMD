/*UNARCHIVE.CMD*/
/*copyright(c) 1992,1993 C>BLACK,B.Stone, KUTEK, all rights reserved*/
'@echo off'
if rxfuncquery(sysloadfuncs) then do
say 'LOADING REXXUTIL'
call RxFuncAdd 'SysLoadFuncs' , 'Rexxutil' , 'SysLoadFuncs'
call SysLoadFuncs
end
xsx=directory()
arg aa 
say aa
aa=strip(aa,'B')
len=length(aa)-4
parse var aa nam '.' z
drvc=substr(aa,1,3)
s=directory(drvc)
'md' nam
if right(aa,3)='EXE' then do
'call copy' aa nam
cd nam
aa 
end
if right(aa,3)='ZIP' then do
'copy' aa nam
cd nam
'un3 ' aa     /*?*****?*/
end
if right(aa,3)='ARJ' then do
'copy' aa nam
cd nam
'arj x -jf ' aa  /*?*****?*/
end
if right(aa,3)='LZH' then do
'copy' aa nam
'cd' nam
'lh /a /s x' aa   /*?*****?*/
end
if right(aa,3)='ZOO' then do
'copy' aa nam
'cd' nam
'ZOO x' aa   /*?*****?*/
end
if right(aa,3)='ARC' then do
'copy' aa nam
'cd' nam
'ARC x' aa  /*?*****?*/
end
call syssetobjectdata nam,'open=default'
'cd\'
cd nam
str:
do 3
say nam
end
say 'START A DOS SESSION?(Y/N)'
pull qt
if qt='Y'|qt='y' then do;'start /dos ';pause;end
else if qt='n'|qt='N' then 'cmd /k blkos2'
else call str
say nam
parse var nam drv'\'na
nat=drv||na
say nat
'call dd' nat '/'
s=directory(xsx)
exit

