/* setbitm.cmd Version 314 Release 159g  */
/* modification du bitmap de fond d'ecran */
/* change desktop's background - modification du bitmap de fond d'ecran */
/* 20/05/98 Santoni Pierre santoni@aix.pacwan.net */
/* in comments: variations */
call sysFileTree 'c:\os2\bitmap\*.bmp', 'thebumps','FO'
/* call sysFileTree 'MyDir\*.bmp', 'thebumps','FO' for other directory */
/* find the next:
  j=RANDOM(1,thebumps.0)
  can replace lines while 'eaob='
  sysputea unnecessaruy
*/
j=thebumps.0 + 1
if SysGetEA('setbitm.cmd','lastbmp','oldname')=0 then
  do i=1 to j-1
    if thebumps.i==oldname then j=i+1
    end
if j==thebumps.0 + 1 then j=1
eaob=thebumps.j
lob="Background="eaob",s,1"
/* lob="Background="eaob",t"  tiled */
/* lob="Background="eaob",s,x"  multiplied x*x times */
/* lob="Background="eaob",n"  normal */
if SysSetObjectData("<WP_DESKTOP>",lob) then
  call SysPutEA "setbitm.cmd","lastbmp",eaob
Return
