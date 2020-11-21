/* df.cmd - A DF-like script                                   950321 */
/* (c) martin lafaix 1994, 1995                                       */

if RxFuncQuery("SysLoadFuncs") then
   do
   call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
   call SysLoadFuncs
   end

drives = ''

if arg() = 0 | arg(1) = '' then
   drives = SysDriveMap()
else
   do i = 1 to words(arg(1))
      drives = drives word(filespec('d',word(arg(1),i)) filespec('d',directory()),1)
   end /* do */

say 'Filesystem         1024-blocks  Used Available Capacity Mounted on'
do i = 1 to words(drives)
   parse value SysDriveInfo(word(drives,i)) with drive free max label
   if drive = '' then iterate
   used = max-free
   if max = 0 then
      capacity = 100
   else
      capacity = used/max*100
   say left(strip(label),17) right(max % 1024,10) right(used % 1024,7) right(free % 1024,8) format(capacity,6,0)'%' right(drive,4)
end
