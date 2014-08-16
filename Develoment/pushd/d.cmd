/* D */
/* Ken Neighbors  30 May 1993 */
/* change directory, slash = backslash */
/* revised:  Ken Neighbors  28 jul 93  added support for spaces in dir       */

parse arg '"'NewDir'"' rest

if ( NewDir == '' ) then do
    parse arg NewDir rest
end

if ( rest <> '' ) then do
    say '"'rest'"' 'ignored'
end

NewDir = translate(NewDir,'\','/');

if ( NewDir == '' ) then do
    say beautify(directory());
end
else do
    NewDirVerify = directory(NewDir);
    if ( NewDirVerify == '' ) then do
	say NewDir': No such directory.'
	exit 1
    end
end

exit 0

beautify:
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
