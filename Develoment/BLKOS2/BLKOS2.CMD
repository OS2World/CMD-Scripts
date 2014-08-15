/*BLKOS2.CMD*/
/*copyright(c) C>BLACK, B.Stone,KUTEK 1993*/
/*all rights reserved*/
/*beta ver 0.1.7*/
'@echo off'   
/**********************CONFIGURE BLOCK*******************/

PATHER='F:'    /*THE PATH FOR THE BLKOS2 AUXILIARY FILES */
logon=1            /*1 FOR LOG  ON, 0 FOR LOG OFF DEFAULT*/
limtt=1000         /* THE LENGTH OF THE HISTORY BUFFER,ARBITRARY*/
SKIP='D: J:'      /* place capitalized drive letters WITH COLONS here to exclude from global search)*/
totdrv=1            /*0 sets searches to curr dir and below,1 searches entire drive in selector*/
prpt=35            /* standard ansi foreground color designator  for prompt color*/
/******************************************************************/
ert= pather'\history'
SIGNAL ON HALT name RESTORE 
if rxfuncquery(sysloadfuncs) then do
say 'LOADING REXXUTIL'
call RxFuncAdd 'SysLoadFuncs' , 'Rexxutil' , 'SysLoadFuncs'
call SysLoadFuncs
end
parse value systextscreensize() with rowm colm
call opencc
call sysmkdir(ert)
restor=0
opcomm.='';florn=0;keymax=0;keytmp=0;frob=0;row=0;keyn=0;alnum=0;select=0;gof=0
entrd=0;chaout='';bk.0='';o=0;huy=0;blou=0;show=0;col=1;nxx=0;nxxx=0
hnu=1;done=0;pos=0;cnt=0;rowm=0;colm=0;comenv='cmd';selecmod=0;
stpo=0;selecrun=0;opndr=0;replace=0;lev=0;nexus=0;nomatch=0;rename=0;
narmal=0;horiz=60;vert=18;wid=20;table=4;incr=5;omce=0;df=0;ent=0;sh=0;
zep=0;cdr='0A 0D 08 09 1B 01 0F';once=0;ent=1;topoo=1;hh=0;listlen.=''
dcfr=0;shh=1;movch=0;lener='';ov=0;joog=0;atts='';pr='';dddd=0;ddde=0;ddds=0
ddda=0;gtv.='';sholne=0;later=0;early=0;gook=0;recur=0;dhnu=1;dsh=1;dbk.='';dtopoo=1
ec=x2c(1b)
parse value syscurpos() with row col
call sessid
call loadals
call syscls
/*MAINLINE*/
do forever
 key='';cv=x2c(1b5b)'1;'prpt'm';cve=x2c(1b5b)'0m'
parse value systextscreensize() with rowm colm
call main
end /*THE END*/
MAIN:
do forever
if blou\=1 then do
if movch\=1 then q=syscurpos(row,0)
cur=directory()||'>'
sta=length(cur)
cur=cv||directory()||'>'cve
col=sta+pos
if selecmod\=1&movch\=1 then s=charout(,cur)
if movch\=1 then q=syscurpos(row,col)
end
ro=0
xx=sysgetkey('noecho')
nxx=c2x(xx)
if nxx=00|nxx=e0 then do  
xxx=sysgetkey('noecho')
nxxx=c2x(xxx)
ro=1
end
if blou\=1 then do
   if ro=0 then key=nxx
   else key=nxx||nxxx
if al.key=1 then do
chaout=key||' '||chaout
call chkals
end
end
if (nxx||nxxx\=E048)&(nxx||nxxx\=E050|nxx||nxxx=E084) then do;ent=1;once=0;end
if huy=1 then call keyhex
else if selecmod\=1 then
select
    when ro=1 then select
when nxx=00 then select
when nxxx=1F then do;if totdrv=1 then totdrv=0;else if totdrv=0 then totdrv=1;end
when nxxx=3B then call help
when nxxx=3f then sholne=1
when nxxx=5E then do;attir=1;
entrd=0;shh=1;call chkals;blou=0;if scner=1 then call vidrest;return;end
when nxxx=5F then do;if logon=1 then logon=0;if logon=0 then logon=1;end
when nxxx=1C then do
opndr=1;opcomm.1=chaout;call chkals;call adj;end
when nxxx=44 then do;z=1;opcomm.1=chaout; call sethist;call adj;end
when (nxxx=9B|nxxx=94)&pos\=0 then call wdbeg 
when nxxx=9d then call nxtwd 
when nxxx=A2 then do;if ov=1 then ov=0;else if ov=0 then ov=1;end
when nxxx=3E then call listals  
when nxxx=42 then call removals                                  
when nxxx=40 then do;form=chaout;rename=1;call removals;end      
when nxxx=85 then nexus=1     
when nxxx=41 then call killals
when nxxx=3D then call LOADALS
when nxxx=29 then do;z=1;opcomm.z=chaout;call sethist;call INT;end
when nxxx=0F&movch\=1 then do;if pos-8 >0 then pos=pos-8;else pos=0;end
when nxxx=86 then huy=1        
when nxxx=3C then call ALIAS
otherwise nop
end /*select*/
when nxx=E0 then select
when nxxx=91 then do;call dinn;friz=1;call sethist;call doutt;sd=directory(strip(chaout,'B'));call adj;friz=0;end
when nxxx=8D then do;friz=1;
dfff=chaout;if dfff\='' &dfff\=prev then df=1;else df=0;call dinn;call shiftB;call doutt/*;friz=0*/;end
when (nxxx=48|nxxx=50) then do
dfff=chaout;if dfff\='' &dfff\=prev then df=1;else df=0;call shiftB;end
when nxxx=49 then do;dfff=chaout;call DISPHIST;end
when nxxx=73&pos\=0 then call wdbeg
when nxxx=74&pos<79 then call nxtwd
when nxxx=75|nxxx=77 then call deltoend
when nxxx=4d then call RIGHTT
when nxxx=4b then call LEFTT
when nxxx=47 then pos=0
when nxxx=4f then do;rrr= length(chaout);pos=rrr;end
when nxxx=53 then call DELCH
otherwise nop
end  /*select*/
otherwise nop
end  /*1select */
   when ro=0 then select
when wordpos(nxx,cdr)=0 then call ADDCH
when nxx=08 then call BACKDEL
when nxx=09 then call TAB
when  nxx=1B&blou=1 then do
blou=0;chaout='';lener='';frob=0;if movch=1 then do
lev=1;done=1;selecmod=0;movch=0
movch=0;lener='';attir=0;nexus=0;end;pos=0;
if scner=1 then call vidrest;return;end
when  nxx=1B then call ESC
when  (nxx=0d|nxx=01|nxx=0A)&blou\=1 then do
if nxx=0A then normal=1
entrd=0;shh=1;if scner=1 then call vidrest;
if friz=1 then do;s=directory(chaout);call adj;friz=0;return;end
call chkals
return
end
when  nxx=0d&blou=1 then do
liner=substr(chaout,sta+1)
return
end  /* Do */
otherwise do;lev=0;leave;end
end  /*0select*/
otherwise call beep2
end /*MASTER*/
if frob=1&lev\=1 then return
end/*forever*/

DISPHIST:
if florg\=1 then do
leest=0
dedede=1
call vidsave
selecmod=1;initc=2;marker=1;listle.='';listlen.='';mark.=''
horiz=45;vert=3;wid=25;table=5;end
jjj=hnu-1
do ki=jjj to 1 by -1
call goo;end
do ki=topoo to jjj+1 by -1
call goo;end
if florg=1 then do;if nax\=1 then listlen.='';nax=0;  return;end
listlen.0=leest;gof=1;nomatch=0;indi1=1;
aax1=6;bbx1= 29;ccx1=3;ddx1=43;az.1='blk';az.2= 'blk';az.3='magb';az.4='blk'
call bx 
call menu;if ghuy=1 then do;frob=1;call main;friz=0;end
selecrun=0;formark='';lev=0;call chkals;gof=0;
if scner=1 then call vidrest
dedede=0;ghuy=0;listle.='';listlen.='';nax=0
return

goo:
if dff='' then return
else if substr(bk.ki,1,length(dfff))\=dfff then return
nax=1
if bk.ki='BK.'ki then return
leest=leest+1
if friz\=1 then listlen.leest=bk.ki
if friz=1 then listlen.leest=dbk.ki
return

LEFTT:
if (col>sta|blou=1)&pos>0&movch\=1 then do
 pos=pos-1
if col>=0 then qa=syscurpos(row,pos);end
if movch=1 then  do;pos=pos-1;uu=startx+pos;row=starty
if col>0 then qa=syscurpos(row,uu);end
return

RIGHTT:
 if pos<79&pos\=length(chaout) then do
pos=pos+1
if movch=1 then do; po=startx+pos;qa=syscurpos(starty,po);end
else qa=syscurpos(row,pos)
end
return

OPENDIR:
if chaout\=''|opcomm.z\='' then do
if mxi=0 then mxi=1
do z=1 to mxi
parse var opcomm.z aa bb
vi='open=default;'
if bb='s' then vi='open=settings'
f=SysSetObjectData(aa,vi )
end
opndr=0
selecrun=0
opcomm.='';
call adj;end
return

INT:
/*INTERPRET    on alt-`  */
touahc=chaout;call adj
if logon=1&touahc\='' then do;z=1;opcomm.z=touahc;call logz;end
interpret touahc
call adj
return

DELCH:
  /*DELETE CHARACTER*/
chaout=delstr(chaout,pos+1,1)
if movch\=1 then a=overlay(' ',aa,1,79-sta)
else a=overlay(' ',aa,1,lener)
if movch\=1 then qa=syscurpos(row,sta)
else qa=syscurpos(starty,startx)
s=charout(,a)
if movch\=1 then qa=syscurpos(row,sta)
else qa=syscurpos(starty,startx)  
s=charout(,chaout)
if movch\=1 then qa=syscurpos(row,pos)
else do;uu=pos+startx;qa=syscurpos(starty,uu);end
return

ADJ2:
if movch=1 then return
xx=length(chaout)
w=copies(' ',79-sta)
q=syscurpos(row,sta)
s=charout(,w)
q=syscurpos(row,sta)
s=charout(,chaout)
q=syscurpos(row,0)
pos=xx
return

SHIFTB:
/*COMMAND RECALL SHIFT FORWARD/BACK*/
if friz\=1&chaout=''&bk.1='BK.1' then return
if friz=1&chaout=''&dbk.1='DBK.1' then return
 if df=1|(once=0&ent=1) then do
leest=0;ent=0
florg=1;call disphist;florg=0
if once=0 then do
if shh>1 then shh=shh-1
else shh=leest;end
once=1
end
if shh<leest+1&(nxxx=48|nxxx=98) then shh=shh+1
if shh>leest then shh=1
if shh\=0&nxxx=50 then do
if shh>1 then shh=shh-1
else shh=leest
end;
if shh=1 then do
oo= beep(1500,40)
end
chaout=listlen.shh
if chaout\='' then prev=chaout
call adj2
return

wdbeg:
if entrd=0 then do; comp.='';io=0;end
if pos=0 then return
in=pos
ps=pos;pes=pos
if pos\=1 then do
 if substr(chaout,ps,1)=' ' then do until re\=' '
ps=ps-1; if ps=0 then leave
 re=substr(chaout,ps,1);end;vup=ps
if ps>1 then if substr(chaout,ps-1,1)\=' ' then do until re=' '
 ps=ps-1;if ps=0 then leave
re=substr(chaout,ps,1);end
if ps=in|vup=ps then ps=ps-1
if ps>0 then pes=ps;else pes=0
end
if pos=1 then do;pes=0;ps=0;len=1;end
if nxxx=9B then do; call dele;end
if nxxx=94 then do
if entrd=1&pos\=zep-1 then entrd=0
io=io+1     
len=in-pes-1
inp=substr(chaout,pes+1,len+1)
if entrd=0 then  s=sysfiletree(inp'*',comp,)
if comp.0\=0&io<comp.0+1 then do
parse var comp.io z1 z2 z3 z4 z5
z5=strip(z5,'B')
frw=length(z5)
if pos(' ',z5,1)<frw&pos(' ',z5,1)>0 then z5='"'z5'"'
if entrd=0 then do
call dele
pws=pes-1;chot=chaout;end
if z5\='Z5' then chaout=insert(z5||' ',chot,pws)
call nxtwd;pes=pis;zep=pis
hin=inp
end
else do;pes=pis;call beep1;end
end
call shoow
if pes>0 then pos=pes-1
if nxxx\=94 then pos=pes;entrd=1
qa=syscurpos(row,pos);return

dele:
 pes=ps+1
chaout=chaout||' '
 len=in-pes+1
if pes=0 then pes=1
if substr(chaout,pes,len-1)=''&pes=1&in\=1 then len=len-1
chaout=delstr(chaout,pes,len)
if nxxx\=94 then  pes=pes-1
return

nxtwd:
if chaout=''|pos>length(chaout) then return
if pos=0 then do;tic=1;pus=1;end
else pus=pos
if substr(chaout,pos+1,1)\=' ' then do until rew=' '
if pos>length(chaout) then leave
pos=pos+1
rew=substr(chaout,pos,1);end;pis=pos
do until re\=' '
if pos>length(chaout) then leave
pos=pos+1
re=substr(chaout,pos,1);end
pas=pos-1
if nxxx=94 then return
if nxx=00& nxxx=9D then do
lend=pas-pus
if tic=1 then do; pus=0;lend=lend+1;end
chaout=delstr(chaout,pus+1,lend)
call shoow
if tic=1 then pos=0;else pos=pus
qa=syscurpos(row,pos)
end
else do
if pos\=length(chaout) then pos=pos-1
qa=syscurpos(row,pos)
end
tic=0
return

deltoend:
if pos=0&nxxx=77 then return
if nxxx=77 then chaout=substr(chaout,pos+2)
else chaout=substr(chaout,1,pos)
call shoow
if nxxx=77 then do;pos=0;
qa=syscurpos(row,0);end;return

shoow:
se=copies(' ',79-sta)
qa=syscurpos(row,sta)
sa=charout(,se)
qa=syscurpos(row,sta)
xs=charout(,chaout)
return

ADDCH:
 /*ADD NEW CHAR TO STRING */
if joog=1 then return
if blou=1 then sta=0
if ov\=1 then chaout=insert(xx,chaout,pos)
else chaout=overlay(xx,chaout,pos+1,1)
if lener=''&movch\=1 then do
 qa=syscurpos(row,sta)
e=charout(,chaout)
 pos=pos+1
if pos>1  then qa=syscurpos(row,pos);end
if movch=1 then do
  chaout=substr(chaout,1,lener)  
 qa=syscurpos(starty,startx) 
if pos<=lener then pos=pos+1
if startx\='STARTX' then uu=pos+startx    
e=charout(,chaout)   
 if pos>1 then qa=syscurpos(starty,uu)
end
return

BACKDEL:
   /*BACKSPACE DELETE*/
IF pos>0&movch\=1  then do
if chaout\='' then chaout=delstr(chaout,pos,1)
if pos>0 then pos=pos-1
a=overlay(' ',aa,1,79-sta)
qa=syscurpos(row,sta)
s=charout(,a)
qa=syscurpos(row,sta)
s=charout(,chaout)
 qa=syscurpos(row,pos)
end
if pos>0&movch=1 then do
if chaout\='' then chaout=delstr(chaout,pos,1)
if pos>0 then pos=pos-1;uu=pos+startx
a=overlay(' ',aa,1,lener);qa=syscurpos(starty,startx);s=charout(,a)
qa=syscurpos(starty,startx);s=charout(,chaout);qa=syscurpos(starty,uu);end
return

TAB:
if col<72 then do
if movch\=1 then pos=pos+8
if movch\=1 then qa=syscurpos(row,pos)
if movch=1 then do;pos=pos+startx;qa=syscurpos(starty,pos)
end
return

ESC:
/*ESCAPE*/
friz=0;shh=1;once=0
s=copies(' ',79-sta)
chaout=''
qa=syscurpos(row,0)
s=charout(,s)
q=syscurpos(row,0)
pos=0;entrd=0
return

COMMAND:
 /*COMMAND OUT  */
if scner=1 then do;scner=0;call vidrest;end
if (chaout=''|row>rowm-1) then do
nxt=x2c(0d)
if nxx\=1b then say nxt
end
s=lineout(,'')
  do z=1 to mxi
xsw=words(opcomm.z)
do e=1 to xsw
   x.e=word(opcomm.z,e)
end /* do */
if sholne=1 then do;chaout=opcomm.z;call adj2;sholne=0;return;end
if selecrun=1 then say x2c(1b)'[1;33m' opcomm.z x2c(1b)'[0m'
if logon=1&opcomm.z\='' then call logz
address cmd 'call' opcomm.z
end
selecrun=0;opcomm.='';v.='';x.='';show=0;call adj;done=1;movch=0;lener=''
return

keyhex:
if ro=1 then zzq=nxx||nxxx
else zzq=nxx
say zzq
call adj
huy=0
return

CHKALS:
mxi=0;nomatch=0;cnnt=0;florn=0;out='';done=0;tagnum=0;sti='';list=0
do; z=1;opcomm.1=chaout;if chaout\='' then call sethist;opcomm.1='';z=0;end
num=words(chaout)
norp=chaout
offs=0
 do qqwq=1 to num
v.qqwq=word(norp,qqwq)
if left(v.qqwq,1)='"'|left(v.qqwq,2)='["' then do
vxv='';ryt=0
tep=qqwq
do while ryt\=1
v.qqwq=word(norp,qqwq)
if right(v.qqwq,1)='"' then ryt=1
vxv=vxv||' '||v.qqwq
qqwq=qqwq+1
end
v.tep=strip(vxv,'B')
trw=num-(qqwq-tep)+1
do xy=qqwq to num
tep=tep+1 
v.tep=word(norp,xy);end
num=trw
end
if lev=1 then do;frob=0;selecrun=0;selecmod=0;lev=0;replace=0
listlen.='';attir=0;nexus=0;movch=0;return;end
if  substr(v.qqwq,1,1)=']' then do; list=1;
parse var v.qqwq ']' sti '[' v.qqwq;v.qqwq='['||v.qqwq;end
if left(v.qqwq,1)='['  then do
replace=1;selecmod=1;if dedede\=1 then do; call vidsave;dedede=1;end                                                                                                                                                      
tagnum=tagnum+1
tagg.tagnum=qqwq;tagg=qqwq
florn=1;if attir=1 then call attri;lener=''
call complete;nexus=0;pr=''
if list=1 then do;cnnt=1;v.tagg.1=sti||ert'\blklst.'qqwq;list=0;end
v.tagg.0=cnnt
if cnnt>mxi then mxi=cnnt;cnnt=0
if nomatch=1  then do
movch=0;selecmod=0;lener=''
nomatch=0;florn=0;done=1;s=syscurstate(on);
cnnt=0;selecrun=0;lev=1;if scner=1 then call vidrest;
call adj
say ec'[1;31m NO MATCH FOUND FOR AT LEAST ONE TERM' ec'[0m'
call adj
return;end
end  
end
douy=''
do qer=1 to num
if qer=1 then douy=strip(v.qer,'B','[')
else douy=douy||' '||strip(v.qer,'B','[')
end  
opcomm.1=douy
if replace=1&lev\=1 then do
  do z=1 to mxi
do wqaz =1 to tagnum
tagg=tagg.wqaz
if opcomm.z=''&wqaz=1 then opcomm.z=opcomm.1
  replpos=wordindex(opcomm.z,tagg)
 if replpos>0 then replpos=replpos-1
opcomm.z=delword(opcomm.z,tagg,1);
if z> v.tagg.0 then v.tagg.z=v.tagg.1
opcomm.z= insert(v.tagg.z||' ',opcomm.z,replpos)
end
end
replace=0
end
else do; opcomm.1=douy;mxi=1;end
v.tagg.='' 
florn=0
blou=0;attir=0
if opndr=1 then do; v.tagg.0=mxi
call opendir;lev=0;opndr=0;selecmod=0;chaout='';opcomm.='';return;end
zxsa=word(opcomm.1,1)
if scner=1 then do;scner=0;call vidrest;end
if (datatype(zxsa,'A')\=1|(al.zxsa\=1&al.zxsa\=2)|normal=1|sholne=1)&(lev\=1|ghuy=1) then do
call command;normal=0;lev=0;return;end
else if lev\=1 then do
call adj3
do z=1 to mxi
say x2c(1b)'[1;33m' opcomm.z x2c(1b)'[0m'   
if logon=1&opcomm.z\='' then call logz
xsw=words(opcomm.z)
do ee=1 to xsw
   x.ee=word(opcomm.z,ee)
if left(x.ee,1)='"' then do
vxv='';ryt=0
tep=ee
do while ryt\=1
x.ee=word(opcomm.z,ee)
vxv=vxv||' '||x.ee
if right(x.ee,1)='"' then ryt=1
ee=ee+1
end
x.tep=strip(vxv,'B')
trw=num-(ee-tep)+1
do xy=ee to xsw
tep=tep+1
x.tep=word(opcomm.z,xy);end
xsw=trw
end
end 
do xzqq=1 to value(al.zxsa.0)
out=out||al.zxsa.xzqq||';'          
end
call adj
interpret  out
call adj
out='';x.=''
end;end
call adj
florn=0;V.='';lev=0;replace=0;dedede=0;selecrun=0;opcomm.='';show=0
return

logz:
lo=idd'   'time()'  ' date()'  ' opcomm.z
 sazz=lineout(pather'\blk.log',lo)
s=stream(pather'\blk.log','c','close')
return

complete:
ddk=''
globabc=0
if selecmod=1 then call syscls
initc=2
posit=1
listlen.=''
mark.=''
marker=1
say
if right(v.qqwq,2)='[[' then recur=1
if right(v.qqwq,1)='['|recur=1 then ddk='ds'
abc=strip(v.qqwq,'B','[')
if recur=1 &right(abc,1)\='\'  then ddk='fs'
if ddk\='ds'&ddk\='fs' then ddk ='bs'
head=abc
cab=translate(abc)
if nexus=1&pos(':',abc)=2 then do
cab=translate(substr(cab,3))
abc=substr(abc,1,2)
end  /* Do */
else if nexus=1 then do;cab=translate(abc);abc='';end
if pos(':',abc)=2&substr(abc,3,1)\='\' then abc=insert('\',abc,2)
curr=directory()
if totdrv=1&recur\=1  then '@CD\'
if attir=1 then  pr='t'
if lev=1 then return
if recur\=1 then abc=abc'*'
if substr(v.qqwq,1,2)='[[' then call global
else rc= sysfiletree(abc,listlen,ddk||pr,atts)
if nexus=1 then do
clu=0
do wwer=1 to listlen.0
   listlen.wwer=translate(listlen.wwer)
if attir \=1 then parse var listlen.wwer z1 z2 z3 z4 z5
if attir=1 then  parse var listlen.wwer z1 z2 z3 z4
if attir\=1& pos(cab,z5)=0 then iterate
if attir=1&pos(cab,z4)=0 then iterate
if (attir=1&pos(cab,z4)\=0)|(attir\=1&pos(cab,z5)\=0) then do
clu=clu+1
listlen.clu=listlen.wwer
end
end
listlen.0=clu
end
if attir=1 then call filter
if listlen.0=0 then do
frob=0;selecmod=0;nomatch=1
curr=directory(curr)
return
end
if lev=1 then return
if recur=1 then do;do i=1 to listlen.0+1
u=listlen.0-i+1
if attir\=1 then  parse var listlen.u  zz1 zz2 zz3 zz4 zz5
if attir=1 then parse var listen.u zz1 zz2 zz3 zz4
if attir\=1 then v.tagg.i=zz5;if attir=1 then v.tagg.u=zz4;end;
cnnt=listlen.0
v.tagg.cnnt=abc;recur=0;return;end
qa=syscurpos(0,0)
xds=ec'[1;36mSEARCH PATTERN: 'ec'[33m'head
say xds
qa=syscurpos(0,50)
xda=ec'[32mMATCHES FOUND:'ec'[33m'listlen.0 ec'[0m'
say xda
horiz=0;vert=0;wid=75;table=rowm-3;call menu;movch=0
if list=1&lev\=1 then do;'call del' ert'\blklst.*';do ix=1 to v.tagg.0
s=lineout(ert||'\blklst.'qqwq,v.tagg.ix)
end;s=stream(ert||'\blklst.'qqwq,'c','close');end
if lev=1 then return 
curr=directory(curr)
return

menu:
per=listlen.0//table
if per\=0 then top=(listlen.0%table)*table
else top=listlen.0-table
loww=1
highh=table
do forever
   if lev=1 then  leave
       do i=loww to highh
          if i>listlen.0 then listlen.i=''
rrd=i-loww+2+vert
listle.i=substr(listlen.i,1+stpo,wid-initc)
swex='[1;32m'listle.i'[0m'
    if mark.i=1 then say '['rrd';'horiz+2'H'swex
else say '['rrd';'horiz+2'H'listle.i
  if i=highh then do
call syscurstate(off)
call selector
call syscurstate(on)
if nomatch=1|lev=1 then return 
end
end
cnnt=0
if lev\=1 then do
do i=1 to listlen.0
if mark.i=1 then do
cnnt=cnnt+1
if attir\=1 then parse var listlen.i x1 x2 x3 x4 x5
if attir=1 then parse var listlen.i x1 x2 x3 x4
if attir\=1&words(x5)>1 then x5='"'strip(x5,'B')'"'
if attir=1&words(x4)>1 then x4='"'strip(x4,'B')'"'
if attir\=1 then v.tagg.cnnt=x5
if attir=1 then v.tagg.cnnt=x4
end
end
v.tagg.0=cnnt
if cnnt=0 then do
cnnt=1
if attir\=1 then parse var listlen.marker x1 x2 x3 x4 x5
if attir=1 then parse var listlen.marker x1 x2 x3 x4
if attir\=1&words(x5)>1 then x5='"'strip(x5,'B')'"'
if attir=1&words(x4)>1 then x4='"'strip(x4,'B')'"'
if attir\=1 then v.tagg.1=x5
if attir=1 then  v.tagg.1=x4
end
end
lener=''
if selecrun=1 then return
end


selector:
selecrun=0
call adj
frob=1
call disp
do forever
if frob=0 then return
call main
if nxx=0d|nxx=0A then do
if nxx=0A then normal=1
if gof=1 then chaout=listlen.marker
else do
parse var listlen.marker x1 x2 x3 x4 x5
v.tagg.1=x5;end
selecrun=1  
selecmod=0
frob=0;gof=0
return
end  
else
if nxx=00&nxxx=1C then do
parse var listlen.marker x1 x2 x3 x4 x5
v.tagg.z=x5
selecrun=1
selecmod=0
frob=0
opndr=1;s=syscurstate(on);return;end
else
select
when nxx=00&nxxx=9B then do
do  iii=1 to listlen.0
 if mark.iii=1 then mark.iii=''
else if mark.iii\=1 then mark.iii=1
end
return
end
when nxx=00&nxxx=43 then do;call vidrest
chaout=listlen.marker;call adj2;ghuy=1;
frob=0;selecmod=0;selecrun=0; lev=1;return;end
when nxx=E0&nxxx=8D then do; mark.=1;return;end
when nxx=E0&nxxx=91 then do; mark.='';return;end
 when nxx=E0&nxxx=49&i>table then do
call hilomin;return; end  
when marker=loww&marker>1&nxx=E0&nxxx=48 then do
call hilomin;return;end  
when nxx=1B then do
if gof\=1 then do;say 'PROCESS CANCELLED';call adj;end;
frob=0;lev=1;chaout='';done=1;blou=0
selecmod=0;attir=0;movch=0;s=directory(curr)
selecrun=1;opcomm.='';v.='';v.tagg.='';if scner=1 then call vidrest;return;end
when nxx=E0&nxxx=51&i<listlen.0-table&listlen.0-highh>table then do
indi1=1;call hiloplus;return;end
when nxx=E0&nxxx=51&listlen.0-highh<(table+1)&i<listlen.0 then do
indi1=1;call lim;return;end  
when marker=highh&nxx=E0&(nxxx=50|nxxx=4B)&listlen.0-highh>table then do
indi1=1;if nxxx=4B then mark.highh=1;call hiloplus;return;end  
when marker=highh&nxx=E0&(nxxx=50|nxxx=4B)&listlen.0-highh<table+1 then do
indi1=i;if nxxx=4B then mark.i=1;call lim;return;end
when marker>1&nxx=E0&nxxx=48 then do
marker=marker-1;call disp;end
when marker<listlen.0&nxx=E0&nxxx=50 then do
marker=marker+1;call disp;end
when nxx=E0&nxxx=4B &marker<listlen.0+1 then do
mark.marker=1;
if marker=listlen.0 then xcz=beep(900,40);
else marker=marker+1;call disp;end
when nxx=E0&nxxx=4D then do
 mark.marker=' ';call disp;end
when nxx=E0&nxxx=47&marker\=1 then do
marker=1;loww=1;highh=table;return;end
when nxx=E0&nxxx=4F&marker\=listlen.0 then do
marker=listlen.0;
loww=top+1;highh=top+table;trig=1;return;end
when nxx=E0&nxxx=73&stpo>incr-1 then do   
stpo=stpo-incr;return;end
when nxx=E0&nxxx=74&stpo<101 then do    
stpo=stpo+incr;return;end
otherwise call beep1
end/*select*/
end

HILOMIN:
indi1=1;loww=loww-table;highh=loww+(table-1);marker=highh;trig=1;call disp;return

HILOPLUS:
loww=loww+table;highh=loww+table-1;
indi1=1;marker=loww;trig=1;call disp;return

LIM:
loww=top+1;highh=top+table;marker=loww;trig=1;call disp;return

DISP:
if indi1=1 then do;indi1=0; return;end
else
 posit=marker-loww +2+vert
 if datatype(formark,'W')&trig\=1 then do
 qa=syscurpos(positf,0)
uuf=formark
parse var listlen.uuf x1 x2 x3 x4 x5
if mark.uuf=1 then do
blom= '[1;32m'listle.uuf'[0m'
say '['positf';'horiz+2'H'blom
end
else do
 brom='[0m' listle.uuf
say '['positf';'horiz+1'H'brom
end
end
uu=marker
parse var listle.uu x1 x2 x3 x4 x5
if mark.uu\=1 then lout= '[1;45m'listle.uu'[0m'
else  lout= '[1;32;45m'listle.uu'[0m'
say '['posit';'horiz+2'H'lout
formark=marker
positf=posit
trig=0
return

beep1:
call beep 900,40
return

beep2:
call beep 1100,30
return

global:
'cd\'
aafin=0
dri=sysdrivemap()
ne=0
do until dri=''
ne=ne+1
parse var dri djd.ne dri
end
do i=1 to ne
  if pos(djd.i,skip)\=0 then iterate
s=directory(djd.i'\')
dr=sysfiletree(djd.i||abc||'*',vt,(ddk)||pr,atts)
if vt.0\=0 then do f=1 to vt.0
aafin=aafin+1
listlen.aafin=vt.f
end
end
listlen.0=aafin
return

adj:
if friz=1 then do;chaout='';say x2c(0d);end
if florn\=1 then chaout=''
pos=0
if scner=1 then do; row=tow;col=tol;end
else parse value syscurpos() with row col
if (chaout=''|row>rowm-1) then do
nxt=x2c(0d)
if nxx\=1b then say nxt
end
return

adj3:
pos=0
parse value syscurpos() with row col
col=col-sta
if (chaout=''|row>rowm-1) then do
nxt=x2c(0d)
if nxx\=1b then say nxt
end
return

sethist:
if (opcomm.z=''&chaout=''&op='') then return
if friz\=1 then op=opcomm.z
if restor=0 then restor=1
if hnu<=limtt&hh\=1 then topoo=hnu
if hnu>limtt then do
 hnu=1;sh=1;topoo=limtt;hh=1;end
if friz=1 then dbk.hnu=op
else bk.hnu=op
if hnu=1 then s=lineout(pather'\history\'idd'hist.qqq',bk.hnu,1)
else s=lineout(pather'\history\'idd'hist.qqq',bk.hnu)
s=stream(pather'\history\'idd'hist.qqq','c','close')
hnu=hnu+1
ticc=hnu-1
return

dinn:
ctopoo=topoo;topoo=dtopoo
ltmtt=limtt;limtt=20;chnu=hnu;hnu=dhnu;
cshh=shh;shh=dsh
op=directory();return

doutt:
dtopoo=topoo;topoo=ctopoo;dsh=shh;shh=cshh
limtt=ltmtt;dhnu=hnu;hnu=chnu;/*friz=0*/;return

killals:
r=chaout
al.r=0
call adj
say 'ALIAS' r 'REMOVED FROM MEMORY';call adj;v.=''
return

LOADALS:
comm.='';
keymax=0;keyn=0
say
filer.2=pather'\master.als'
FILER.1=PATHER'\history\'idd'REST.TPP'
swe=stream(filer.1,'C','QUERY EXISTS')
do g=2 to 1 by -1
if restor=1&g=1 then iterate
do until lines(filer.g)=0
line=linein(filer.g)
if line='' then iterate
select
when left(line,1)='@' then do
key=substr(line,2)
keyn=keyn+1
key.keyn=key
if g=1 then al.key=2;else al.key=1
end
when substr(line,1,4)='$$$$' then do
          al.key.0=cnt
          cnt=0
if keyn\=1 then r=value(key.keyn)
else r=strip(key.1,'B')
comm.r=substr(line,5)
end
otherwise do
cnt=cnt+1
al.key.cnt=line
end
end/*select*/
end
ww=stream(filer.g,'c','close')
end
call adj
keymax=keyn
keyn=0
if restor=0 then do 
restor=1
lop=pather'\history\'idd'hist.qqq'
ds=stream(lop,'C','query exists')
if ds\='' then do
fex=0
do until lines(lop)=0
  fex=fex+1
bk.fex=linein(lop)
if fex>limtt then leave
end  
s=stream(lop,'C','close')   
hnu=fex+1
end
end
else sdc=sysfiledelete(lop)
/*end*/
call adj
return

ALIAS:
blou=1
say x2c(1b5b)'1;32mALIAS CREATION MODE'x2c(1b5b)'0m'
say 'input alias keyname, alpha numeric chars ONLY'
say 'ESC to abort alias creation,/k for key alias'
call adj
do 
call main;if blou=0 then return
key=strip(liner,'B')
call adj
if al.key=1 then say'ALIAS KEYNAME USED-THIS ALIAS WILL BE OVERWRITTEN '
if key='/k' then do
call adj
say 'HIT A KEY or VALID KEY COMBINATION'
frob=1
call adj
call main;if blou=0 then return
if ro=1 then key=nxx||nxxx
else key=nxx
say key
frob=0
end
if datatype(key,'A')\=1 then do
   say 'NON ALPHA-NUMERIC CHARS NOT ALLOWED IN KEY'
say 'REINPUT ALIAS KEY'
call adj
end  
end
al.key=1
keyn=keymax+keytmp+1
key.keyn=key
do
     call adj
say 'INPUT ALIAS DESCRIPTION/COMMENT'
call adj
call main;if blou=0 then return
r=value(key.keyn)
comm.r=liner
call adj
end
'epm' pather'\'key'.bls'
'@pause'
i=0
do while lines(pather'\'key'.bls')\=0
rkl=linein(pather'\'key'.bls')
if rkl='' then iterate
i=i+1
al.key.i=rkl
end
al.key.0=i
w=stream(pather'\'key'.bls','c','close')
say 'SAVE THIS ALIAS TO MASTER FILE? (Y/N)'
pull resp
 do
if resp='Y' then do;iu=1;sxx=pather'\master.als';end
else do;sxx=pather'\history\'idd'rest.tpp';iu=0;end
n=lineout(sxx,'@'key)
do i=1 to al.key.0
   if al.key.i='' then iterate
     n=lineout(sxx,al.key.i)
end
n=lineout(sxx,'$$$$'comm.r)
 ss=stream(sxx,'c','close')
if iu=1 then say 'ALIAS ' key 'SAVED TO MASTER FILE'
keymax=keymax+1
end
if iu=0 then do;keytmp=keytmp+1;al.key=2;end
s=sysfiledelete(pather'\'key'.bls')
say 'ALIAS' key' ACTIVE'
blou=0
call adj
return

vidsave:
parse value syscurpos() with tow tol
xdxx.=''
zz=x2c(0A)
bb=x2c(0d)
say x2c(1b)'[s'
qa=syscurpos(0,0)
do i=1 to rowm
xdxx.i=systextscreenread(i,0,78)
xdxx.i=strip(xdxx.i,'b',bb)
xdxx.i=strip(xdxx.i,'B',zz)
scner=1
end
return

vidrest:
s=syscurstate(off)
qa=syscurpos(0,0)
do i=1 to rowm
d=charout(,xdxx.i)
qa=syscurpos(i,0)
end
qa=syscurpos(tow,tol)
scner=0;dedede=0
s=syscurstate(on)
return

opencc:
call syscls
oy=rowm%2-3;ox=colm%2-14
dd.1= 'BLKOS2  (c) 1992,1993'
dd.2='C>BLACK,B.STONE,KUTEK '
dd.3 =' all rights reserved'
do i=1 to 3
  qa=syscurpos((oy+i-1),ox)
xx=lineout(,x2c(1b5b)'1;35m' dd.i x2c(1b5b)'0m')
end
return

REMOVALS:
if chaout='' then do;say 'ALIAS NAME REQUIRED-TRY AGAIN';return;end
ppp=pather||'master.als';ddd=pather||'123'
re=0;wwe=0;ewew=0;form=''
sw=strip(chaout);swl=length(sw)
form=sw
vv='@'||sw
do until lines(ppp)=0
dfdf=linein(ppp)
if dfdf=vv then ewew=1
end /* do */
qq=stream(ppp,'c','close')
if ewew\=1 then do 
call adj;say  sw 'IS NOT A STORED ALIAS';call adj;return;end
if rename=1 then do forever
call adj;blou=1;say ' INPUT NEW NAME';call adj;call main;
sw=strip(liner);blou=0;
  if al.sw=1 then do;sw='';call adj;say 'ALIAS NAME ALREADY USED';end
else leave
end 
if sw\='' then do until lines(ppp)=0
sd=linein(ppp)
if rename\=1&substr(sd,1,1)='@'&substr(sd,2,swl)=form then
do forever
sd=linein(ppp)
if substr(sd,1,1)='@'|sd='' then leave
end
do
re=re+1
if rename=1&sd='@'form then sde.re='@'sw
else sde.re=sd
end
end
test=0
do i=1 to re
s=lineout(ddd,sde.i)
test=test+s
end
s=stream(ddd,'c','close')
s=stream(ppp,'c','close')
if test=0 then do
al.form=0;al.form.=''
call sysfiledelete(ppp)
'ren' ddd 'master.als'
call sysfiledelete(ddd)
call adj
if rename=1 then say 'ALIAS 'form' RENAMED TO 'sw
else say 'ALIAS ' sw 'REMOVED FROM MASTER FILE'
end
else say ec'[1;31mPROCESS FAILED->MASTER IS UNCHANGED' ec'[0m'
if rename=0 then do;al.sw=0;al.sw.='';end;rename=0;call adj
call loadals
return

listals:
call vidsave
call syscls
selecmod=1;initc=2;marker=1;listle.='';listlen.='';mark.=''
lstnum=1
do xi=1 to keytmp+keymax
rrrr=key.xi
if xi\=1 then x=value(key.xi)
else x=key.xi
if al.rrrr=0 then iterate
listlen.lstnum=rrrr
listlen.lstnum=insert(comm.x,listlen.lstnum,15)
lstnum=lstnum+1
end
listlen.0=lstnum
qa=syscurpos(0,0)
say ec'[1;36mLIST OF ACTIVE ALIASES'ec'[0m'
horiz=0;vert=0;wid=75;table=15;initc=1;lev=0;call menu
if lev\=1 then chaout=key.marker
call vidrest;call chkals;chaout='';listlen.='';listle.=''
return

restore:
return

bx:
pp='[0m'
sent=''
call colors
xx=d2c(186)/*vert block*/
yy=d2c(0)/* space*/
zz=d2c(205)/*upper block*/
zza=d2c(201)/*upper left corn*/
zzb=d2c(187)/*upper right cor*/
zzc=d2c(200)/*lower left corner*/
zzd=d2c(188)/*low rght cor*/
d=syscurpos(ccx1,ddx1)
s=copies(zz,bbx1-2)
nn=copies(zz,bbx1-2)
say (zyzy)(zza)(s)(zzb)(pp)
t= center(sent,bbx1-2)
do i=1 to aax1
d=syscurpos(i+ccx1,ddx1)
q=(zyzy)(xx)(zxzx)(t)(zyzy)(xx)(pp)
say q
end
d=syscurpos(aax1+ccx1,ddx1)
say (zyzy)(zzc)(nn)(zzd)(pp)
return

colors:
do i=1 to 4
tt.i=''
rr.i=''
as.i=''
narb= right(az.i,2)
if pos('f',narb)\=0 then do
rr.i='5'
az.i=delstr(az.i,4)
end
if pos('b',narb)\=0 then do
tt.i='1'
az.i=delstr(az.i,4)
end

if az.i='n' then  as.i=pp
if az.i='blk' then as.i=0
if az.i='red' then as.i=1
if az.i='grn' then as.i=2
if az.i='yel' then as.i=3
if az.i='blu' then as.i=4
if az.i='mag' then as.i=5
if az.i='cya' then as.i=6
if az.i='whi' then as.i=7
if az.i='nul' then as.i=''
end
zxzx='['rr.1'm['tt.1';3'as.1';4'as.2'm'
zyzy='['rr.3'm['tt.3';3'as.3';4'as.4'm'
return

sessid:
drop=pather||'okstart'
do until stream('drop','C','QUERY EXISTS')=''                                               
   call syssleep 2                                                                             
end
aq=rxqueue("create")
s=rxqueue('set',aq)
'pstat /c |rxqueue' aq
do until queued()=0                                                                            
pull kjhg                                                                                      
parse var kjhg c1 c2 c3 c4 c5                                                                  
if POS('PSTAT.EXE',c4)\=0 then do                                                              
idd=c2;leave;end                                                                               
end                                                                                            
 s=sysfiledelete('drop')                                                                     
s=rxqueue('delete',aq)
return

attri:
call syscls
do i=1 to 7;gtv.i='';end;chaout='';nxx=''
lener=1
aax1=6;bbx1=41;ccx1=6;ddx1=23;az.1='blk';az.2= 'blk';az.3='cya';az.4='blu'
call bx
vv=(zyzy)d2c(196)(zxzx)
xx.1='Date  (low):         (high):         '
xx.2='Time  (low):         (high):         '
xx.3='Size  (low):         (high):         '
xx.4=copies(vv,39)
xx.a=center('SEARCH PATTERN 'strip(v.qqwq,'B','['),colm)
xx.5='Attributes:'
qa=syscurpos(4,0)
say x2c(1b5b)'1;33m'xx.a
do i=1 to 5
qa=syscurpos((6+i),24)
say x2c(1b5b)'1;37m'xx.i
end
say x2c(1b5b)'0m'
movch=1;startx=36;starty=7
qa=syscurpos(7,36);pos=0
aa=syscurstate(off)
joog=1
rek=0
gty.1=36 7 8
gty.2=52 7 8
gty.3=36 8 6
gty.4=52 8 6
gty.5=36 9 8
gty.6=52 9 8
gty.7=37 11 7
do forever
frob=1;blou=1
select
when nxx=00&nxxx=85 then nexus=1
when nxx=00&nxxx=0F then do;if rek\=0 then gtv.rek=chaout
if rek>0 then rek=rek-1;if rek<=0 then rek=7;chaout=''
parse var gty.rek startx starty lener                            
pos=0;aa=syscurstate(on);chaout=gtv.rek;end
when nxx=09 then do;if rek\=0 then gtv.rek=chaout;chaout=''
rek=rek+1;if rek=8 then rek=1;
parse var gty.rek startx starty lener
pos=0;aa=syscurstate(on)
qa=syscurpos(starty,startx);chaout=gtv.rek;end
when nxx=1B then do;movch=0;chaout='';blou=0;lener='';aa=syscurstate(on)
selecmod=0;attir=0;lev=1;return;end
when nxx=0d then do;if rek\=0 then gtv.rek=chaout;qa=syscurpos(12,37)
say ec'[1;32;44m SEARCHING' ec'[0m';call prep; return;end
otherwise nop
end  /* select */
selecmod=0;call main;selecmod=1;joog=0
end
return

prep:
ds=0;ckt=0;ck=0;szz=0;zop=1;vop=1;sop=1
if gtv.1\=''|gtv.2\='' then dddd=1
if pos('=',gtv.1)\=0 then do;gtv.1=substr(gtv.1,1,6);hg=1;end
if pos('i',gtv.1)\=0 then do;gtv.1=substr(gtv.1,1,6);zop=0;end
if pos('l',gtv.1)\=0 then do;gook=1;gtv.1=substr(gtv.1,1,6);later=1;end
if pos('e',gtv.1)\=0 then do;gook=1;gtv.1=substr(gtv.1,1,6);early=1;end
if gtv.3\=''|gtv.4\='' then ddde=1
if pos('=',gtv.3)\=0 then do;gtv.3=substr(gtv.3,1,4);gf=1;end
if pos('i',gtv.3)\=0 then do;gtv.3=substr(gtv.3,1,4);vop=0;end
if gtv.5\=''|gtv.6\='' then ddds=1
if pos('=',gtv.5)\=0 then do;parse var gtv.5  gtv.5 '=';sg=1;end
if pos('i',gtv.5)\=0 then do;parse var gtv.5 gtv.5 'i';sop=0;end
if gtv.7\='' then do;ddda=1;parse var gtv.7 hu '/' norg;call parattrib;end
if dddd\=1&ddde\=1&ddds\=1&ddda\=1 then  return
return

filter:
if gook=1 then do;dddd=0;ddde=0;end
do i=1 to listlen.0
parse var listlen.i  zc1 zc2 zc3 zc4
parse var zc1 pp'/'qq'/'rr'/'ss'/'tt
ck=(pp)(qq)(rr)
ckt=(ss)(tt)
szz=zc2
if gook=1 then do
day=ck||ckt
nite=gtv.1||gtv.3
if later=1&day<nite then iterate
if early=1&day>nite then iterate
end
if dddd=1 then do
bloog=0
select
   when (hg=1)&(gtv.1=ck) then bloog=1
when hg\=1 then select
when (gtv.2 \='')&(gtv.1\='') then if (gtv.2-ck>=0)&(gtv.1-ck<=0) then bloog=1
when (gtv.1='') then if (gtv.2-ck>=0)  then bloog=1
when (gtv.2='') then if (gtv.1-ck<=0) then bloog=1
otherwise iterate
end/*select*/
otherwise iterate
end/*select*/
if bloog\=zop then iterate
end
if ddde=1 then do
boog=0
select
when (gf=1)&(gtv.3=ckt) then boog=1
when (gf\=1) then select
when (gtv.4 \='')&(gtv.3\='') then if (gtv.4-ckt>=0)&(gtv.3-ckt<=0) then boog=1
when (gtv.3='') then if (gtv.4-ckt>=0)  then boog=1
when (gtv.4='') then if (gtv.3-ckt<=0) then boog=1
end/*select*/
otherwise iterate
end/*select*/
if boog\=vop then iterate
end
if ddds=1 then do
sloog=0
select
   when (sg=1)&(gtv.5=szz) then sloog=1
when sg\=1 then select
when (gtv.6 \='')&(gtv.5\='') then if (gtv.6-szz>=0)&(gtv.5-szz<=0) then sloog=1
when (gtv.5='') then if (gtv.6-szz>=0)  then sloog=1
when (gtv.6='') then if (gtv.5-szz<=0) then sloog=1
otherwise iterate
end/*select*/
otherwise iterate
end/*select*/
if sloog\=sop then iterate
end
 call ssl
end
if dddd=1|ddde=1|ddds=1|later=1|early=1 then listlen.0=ds;gtv.='';
early=0;blou=0;dddd=0;ddde=0;ddds=0;later=0;hg=0;gf=0;sg=0
ddda=0;atts='';gook=0
return

ssl:
ds=ds+1
listlen.ds=listlen.i
return

parattrib:
if norg='m' then atts='-----'
if norg=''  then atts='*****'
do i= 1 to 5
   fgt=substr(hu,i,1)
fgt=translate(fgt)
if fgt='H' then atts= overlay('+',atts,3,1)
if fgt='A' then atts=overlay('+',atts,1,1)
if fgt='R' then atts=overlay('+',atts,4,1)
if fgt='S' then atts=overlay('+',atts,5,1)
if fgt='D' then atts=overlay('+',atts,2,1)
end /* do */
return

help:
c.1=x2c(1b5b)'1;36m';c.2=x2c(1b5b)'1;33m';c.3=x2c(1b5b)'0m'
h.1= c.1'F1:'c.2'   HELP'c.3' screen'
H.2=c.1'F2:'c.2'   CREATE ALIAS'c.3
h.3= c.1'F3:'c.2'   RELOAD ALIASES'c.3' from master'
h.4= c.1'F4:'c.2'   LIST'c.3' and select 'c.2'ACTIVE ALIASES'c.3
h.5=c.1'F5:'c.3'   bring 'c.2'SELECTed terms to CL'c.3' -press BEFORE entering SELECTOR'
H.6=c.1'F6:'c.2'   RENAME'c.3' an ALIAS'
H.7=c.1'F7:'c.2'   DEACTIVATE'c.3' an ALIAS '
H.8=c.1'F8:'c.2'   REMOVE'c.3' ALIAS from master alias file'
h.9=c.1'F9:'c.3'   place a 'c.2'line from HISTORY box on CL'c.3' for EDITING'
h.10=c.1'F10:'c.3'  place current 'c.2'command line into HISTORY'c.3
h.11=c.1'F11:  'c.3'Activate the 'c.2'STRING MATCH FILE SEARCH 'c.3'function'
h.12=c.1'F12:'c.2'  ACTIVATE KEYHEX 'c.3'for the next key pressed after F12'
h.13=c.1'CTRL-DOWN ARROW:'c.2' QUICK CHANGE DIR'c.3
h.14=c.1'CTRL-UP ARROW:   'c.2'DIR HISTORY RECALL'c.3
h.15=c.1'CTRL -F1:'c.3'  begin 'c.2'SELECTOR with ATTRIBUTE'c.3' search'
h.16=c.1'CTRL-TAB:'c.2'  FILENAME COMPLETION'c.3
h.17=c.1'CTRL-ENTER:'c.3'Key on cl 'c.2'NORMAL COMMAND'c.3' instead of alias'
h.18=c.1'CTRL-F2:'c.2'TOGGLE LOG ON/OFF'c.3
h.19=c.1'ALT-s:    'c.2'  TOGGLE SEARCH DEPTH'c.3
h.20=c.1'ALT-~:    'c.2'  REXX interpret'c.3
h.21=c.1'ALT-INS:  'c.2'  TOGGLE TYPE MODE'c.3
h.22=c.1'ALT- ENTER:'c.2' OPEN WPS OBJECT'c.3
h.23=c.1'UP ARROW:'c.2'   RECALL HISTORY'c.3
h.24=c.1'PAGE UP:'c.2'    HISTORY LIST'c.3

call vidsave
call syscls
do i=1 to 24
   say h.i;end
s=sysgetkey()
call vidrest
h.=''
return



/*notes:
4/24 added alt-ins to switch between insert and overwrite modes
4/24 added bright and flashing to color control
fix the select menu not disappearing on F9 and alt enter
4/24 fixed select menu not disappearing  on enter
4/26 fixed entry from alias list appearing on cl when escaped from
4/29 tab and shft tab move forward/backarwds through menu 
4/29 ctrl=F2 - all commands issued through blk to a log file
5/6 each term has separate attrib select.fixed f11 search
so that [asasdasd[ with f11 works- separate f11 for each term implemented
by F11 in attrib select
log file has commands id'd by session
add list file for any selection term and individual f11 search capability
(per term),add start pick list at letter and sort lists.
generating file list added.
5/9addedmultiple skip and fixed problem with not looking at all dirs in gtlobal search.
fixed attrib field erase problem when tabbing through fields.
5/10 f5 gives selector to cl for editing select output
absolute later than and earlier than functions
5/12 added means to specify actions to all sub dir or files therein without displaying a select list ie [[ tail on select term
rec global(4os2) like command alias for blkos2)
5/13-fixed history buffer recall so that entries are not skipped.
added directory stack -store(pushd- like) via alt ->,recall list by alt up arrow once
5/15 major prob with f11 fixed circa lines 567
fixed prob with screen not being restored if escaping from an attrib search
5/16 fixed prob with hpfs being spread over multiple v variables in chkals
fixed conflict withdelete word to right and the dir hist function.
5/18:problem with alias renamefixed
5/19 added first  help screen and colorized prompt*/
