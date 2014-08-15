/*IN.CMD*/
skip=' '   /* place capitalized drive letter(X:) here to exclude from search*/
/*INFO.CMD*/
/*SYSTEM INFO UTILITY*/
/*copyright(c)1992,1993 C>BLACK,B.STONE,KUTEK*/
/*all rights reserved*/
/* usage: IN <drv,optional,no colon></> */
/* specifying drv letter shows stats for that drv alone*/
/* even floppy drvs*/
/*  "/" parameter shows floppies also in long list of all drvs*/

call rxfuncadd sysloadfuncs,rexxutil,sysloadfuncs
call sysloadfuncs
'cls'
sfe=''
nook=0
qrt=syscurpos(5,0)
say  '[1;32mSYSTEM DRIVE STATS [0m'
parse upper arg sfe
zcx=0
if (sfe\='/')&(sfe\='') then do
nook=1
call single
end
else
mp=sysdrivemap(,local)
s=((length(mp))+1)/3
if sfe='/' then do
s=s+2
l=s-1
ll=1
 end
do i=1 to s
if ll=1 then a.l='A:'
if ll=1 then a.s='B:'
if length(mp)\=0  then a.i=substr(mp,1,2)
if length(mp)\=0 then mp=delstr(mp,1,3)
if pos(a.i,skip)\=0 then iterate
n.i= sysdriveinfo(a.i)
end
showw:
zs=syscurpos()
parse var zs r c
say '[1;32mDRIVE[0m'
sa=syscurpos(r,20)
say '[1;32mSPACE FREE[0m'
sa=syscurpos(r,40)
say '[1;32mSPACE USED[0m'
sa=syscurpos(r,60)
say '[1;32mVOLUME LABEL[0m'
sa=syscurpos(r+2,0)
sun=0
sum=0
if nook=1 then s=1
do i=1 to s
parse var n.i c.1 c.2 c.3 c.4
if (c.3\='')&(c.2\='') then c.3=c.3-c.2
if c.2\=''&c.3\='' then do
sun=sun+c.2
sum=sum+c.3
end
if c.4='' then c.4='NO LABEL'
if c.3=''  then  c.2='[1;31mEXCLUDED DRIVE[0m'
if c.1='' then c.2='[1;5;31mDRIVE 'a.i' NOT READY[0m'
c.1=a.i
do u=1 to 4 
sss=strip(c.u,'b')
if datatype(sss,N)=1 then do
xxx=sss
call num
sss=xxx
end
if pos('[',sss)=0 then say '[1;36m'sss'[0m'
else say sss
sa=syscurpos(r+i+1,(u*20))
end
end
 xxx=sun
call num
say
if nook\=1 then say'[1;32mDISPLAYED DRVS TOTAL FREE SPACE [1;33m' xxx '[0m'
xxx=sum
call num
if nook\=1 then say'[1;32mDISPLAYED DRVS TOTAL USED SPACE [1;33m' xxx '[0m'

exit
num:
a=length(xxx)
if a<4 then do
 return
end
else xxx=insert(',',xxx,a-3)
do while pos(',',xxx)>4
a=pos(',',xxx)
xxx=insert(',',xxx,a-4)
end
return 

single:
a.1=sfe':'
n.1= sysdriveinfo(a.1)
call showw

