/*GET.CMD*/
/*from BLKOS2 copyright(c) 1992,1993 C>BLACK,B.STONE,KUTEK*/
/*all rights reserved*/
parse arg aa
aa=strip(aa)
a=stream(aa,'c','close')
www=sysgetea(aa,'.comments',out)
beg=substr(out,10)
do until beg=''
parse var beg line 'fdff'x e '00'x beg
say line
end

