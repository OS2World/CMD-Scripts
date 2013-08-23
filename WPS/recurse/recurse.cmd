/* Creates a program object with an association to the type
   "Snippet".  This will add the type Snippet to the association
   list.  You can delete the program object once it is created,
   but the type will remain in the list.
*/

call RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
call SysLoadFuncs
say arg(1)

root = word(arg(1),1)
if (length(root) = 0) then
do
  say "Must specify a folder to operate on"
  exit
end

action = subword(arg(1),2)
if (length(action) = 0) then
do
  say "Must specify an action to apply"
  exit
end
say "action="action
say "root="root

rc = SysFileTree(root"\*", folders, "DSO")

rc = SysSetObjectData(root, action)
do i = 1 to folders.0
  rc = SysSetObjectData(folders.i, action)
end

