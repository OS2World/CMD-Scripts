/*PUT.CMD*/
/*BLKOS2 copyright (C)1992,1993 C>BLACK,B.STONE,KUTEK*/
/*all rights reserved*/
xz=''
parse arg aa
aa=strip(aa)
www=sysgetea(aa,'.comments',out)
beg=substr(out,10)
do until beg=''
parse var beg line 'fdff'x e '00'x beg
sz=lineout('comm.tnp',line)
end
o=stream('comm.tnp','C','close')
'epm  comm.tnp'
pause
ww=sysputea(aa,'.COMMENTS','')
eee=0
do until lines('comm.tnp')=0
eee=eee+1
czz=linein('comm.tnp')
if eee=1 then cz=d2c(length(czz))||'00'x||czz
else cz=x2c(fdff)||d2c(length(czz))||'00'x||czz
xz=xz||cz
end
swq=x2c(dfff0000)
tt=d2c(eee)
xz=swq||tt||'00fdff'x||xz
ww=sysputea(aa,'.COMMENTS',xz)
if ww=0 then do
 say 'COMMENT SUCCESSFULLY WRITTEN TO' aa
pp=stream('comm.tnp','c','close')
s=sysfiledelete('comm.tnp')
end
