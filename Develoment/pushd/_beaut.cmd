/* _beaut */
/* Ken Neighbors  30 May 1993 */

uc='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
lc='abcdefghijklmnopqrstuvwxyz'

parse arg Directory
if ( Directory <> '' ) then do
    /* Lowercasize the drive letter */
    DriveLetter = substr(Directory,1,1)
    DriveLetter = translate(DriveLetter,lc,uc)
    Directory = overlay(DriveLetter,Directory,1)

    /* Lowercasize the whole thing */
    /* Directory = translate(Directory,lc,uc) */
end
return Directory
