/*D.CMD*/
/*QUICK DIRECTORY CHANGE/LIST COMMAND from ***BLKOS2****/
/*(c) C.BLACK,B.STONE, KUTEK 1992,1993*/
/*KUTEK PO BOX 261 FORKED RIVER, NJ 08731*/
/* you do not type full paths with this command- it finds them for you!!!*/
/* in the following dir is the dir you want to go to or list subdirs of*/
/*USAGE: D <x:dir OR a number> </>  ( no space  for the /)*/
/*EXAMPLE:you are at g:\ and want to go to C:\what\when\where\how\cost\scream*/
/* type      D c:scream           to go directly to scream*/
/* if more than one dir scream exists on the target you choose from a list*/
/*EXAMPLE: you are at c:\tired\being\ ripped\ off  */
/*and want to go to b:\blkos2\excellent\functional\cheapware\capable*/
/* type D b:capable  and you are there.*/
/*EXAMPLE: D x:dir/    gives you a list of all subdir of X:dir*/
/* where x is  a drive letter  and dir is a directory name on that drive*/
/*choose a number from the list to go directly to that sub*/
/*EXAMPLE: to see the sub dirs of b:\blkos2\excellent\functional  */
/* type D b:functional/  */
/*EXAMPLE: type D alone to get  a list of all subs of the current dir*/
/*choose a number from the list to go directly to that sub*/
/*EXAMPLE: D 5  to go 'up'  the dir tree from scream to what*/
/* the number eliminates that many terms from the prompt*/
/*EXAMPLE: D g:/ gives a list of all subdirs on drive g  */
/*wildcards are allowed*/
/*EXAMPLE: to go from g:\ to c:\\\scream you can type D c:sc??am  */
/* case is irrelevant*/
/*no quotation marks necessary for long dir names on HPFS drives*/
/*EXAMPLE HPFS: to go to_ g:\how easy can you get _on hpfs drive g  */
/*type D G:how easy can you get        add / for sub dir list   */
/* all REXX programs must start with a comment  at the first col of the first line*/
/*remove all BUT ONE of these comments from your working copy*/
/* to get max speed*/
/* turn ansi ON*/
/* make sure long lines with ansi terms are one line in your working copy*/
/*D.CMD*/
/*QUICK DIRECTORY CHANGE/LIST COMMAND from ***BLKOS2****/
/*(c) C.BLACK,B.STONE, KUTEK 1992,1993*/
/*all rights reserved, use at your own risk*/
/* may not be sold or bundled*/

'@echo off'
s=rxfuncquery(sysloadfuncs)
if s=1 then do
call rxfuncadd sysloadfuncs,rexxutil,sysloadfuncs
call sysloadfuncs;end
ret=directory()
curd=substr(ret,1,3)
dodir=0
tt=0;nju=''
fleeb=0
if value(noff,,'OS2ENVIRONMENT')\=''  then fleeb=1
if fleeb =0 then parse upper arg xx
else do
xx=value(noff,,'OS2ENVIRONMENT')
end  /* Do */

if right(xx,1)='/' then do
dodir=1
xx=strip(xx,'T','/')
end
if length(xx)=2&(pos(':',xx)=2)&(dodir\=1) then do
wq=directory(xx'\')
exit
end

 if (xx\='')&(datatype(xx,W)=1)&(xx<9) then do i=1 to xx
'cd..'
if i=xx  then exit
   end  /* Do */
    if (length(xx)=2) &(substr(xx,2,1)=':')  then do
 l=xx'\'
tt=1
end
 if (xx='')&(right(ret,1)\='\') then l=(ret)('\')
   If (xx\='')&(pos(':',xx)=0) then l=(curd)(xx)('\')
else if(length(xx)>2)&(pos(':',xx)=2) then do
parse var xx aaa':'bbb
l=aaa':\'bbb'\'
   end  /* Do */
if (dodir\=1)&(tt\=1)then l=strip(l,'T','\')
if (xx='')&(ret\=curd) then do
 l=ret'\*'
dodir=1
end
if (xx='')&(ret=curd) then l='*'
lu=sysfiletree(l,by,dst)
if (dodir\=1)&(by.0=0) then do
if fleeb=1 then do
rtnn='xxx*'
call gone
end
else
say '[1;33m'L '[1;31mDOES NOT EXIST ON THE DRIVE[0m'
sfd=directory(ret)
exit
end
else if(dodir\=1)&( by.0=1) then do
parse var by.1 v1 v2 v3 v4
xx=strip(v4,b)
if fleeb=1 then call gone
else
call directory xx
exit
end

listit:
parse value systextscreensize() with rr y
lp=0
 if (BY.0=0) then do
say '[1;31mTHERE ARE NO SUBDIRECTORIES [0m'
sfr=directory(ret)
exit
end
else do k=1 to BY.0
lp=lp+1
parse var by.k v1 v2 v3 v4 
say  '[1;36m('k')' v4'[0m'
if lp=rr-2 then do
call ki
lp=0
end
end
ki:
if k<(BY.0-1) then say '[1;32mSELECT DIRECTORY OR HIT ENTER FOR MORE[0m'
else say '[1;33mSELECT DIRECTORY OR HIT ENTER TO EXIT TO PROMPT[0m'

do forever                              
nj=sysgetkey()                          
if nj=x2c(0d) then leave                
nju=nju||nj                             
end                                     
                      
if (nju\='') then do
parse var by.nju b1 b2 b3 b4 
xx=strip(b4,b)
if fleeb=1 then do
   call gone
end  /* Do */
else
call directory xx
end
if (nju='')&(k\>by.0-1) then return
else do
if nju='' then fry=directory(ret)
 exit
end
end
end
exit

gone:
www=value(noff,xx,'OS2ENVIRONMENT')
return 




                                          /*     REXX RULES!!    */

