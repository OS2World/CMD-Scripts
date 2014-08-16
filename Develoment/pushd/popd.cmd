/* POPD                                                                      */
/* written:  Ken Neighbors  sometime before 13 May 93                        */
/* revised:  Ken Neighbors  30 May 93  +n, comments, bug fixes, beautify     */
/* revised:  Ken Neighbors  28 jul 93  added support for spaces in dir       */

parse arg Argument rest

if ( rest <> '' ) then do
    say 'popd:  Too many arguments.'
    exit 1
end

DirStack = value('PUSHD',,'OS2ENVIRONMENT')

/*
 * first case: argument is "+n"--delete nth entry from stack
 */
if ( Argument <> '' ) then do
    if ( substr(Argument,1,1) == '+' ) then do
	n = substr(Argument,2)

	/* check that n is a whole number, greater than zero, less than dirs */
	if ( \datatype(n,'Whole number') | (n < 1) ) then do
	    say 'popd: Invalid cyclic parameter'
	    exit 3
	end
	NumDirs = words(DirStack)   /* plus one:  current dir */
	if (n > NumDirs) then do
	    say 'popd: Directory stack not that deep'
	    exit 3
	end

	DirStack = delword(DirStack,n,1)
	call value 'PUSHD',DirStack,'OS2ENVIRONMENT'
	CurrentDir = _beaut(directory())
	say CurrentDir decode(DirStack)
    end
    else do
	say 'popd:  Too many arguments.'
	exit 1
    end
end
/*
 * second case: no argument--pop top directory
 */
else do
    parse var DirStack CodedNewDir DirStack
    NewDir = decode(CodedNewDir)
    if ( NewDir == '' ) then do
	/* The stack is empty */
	say 'There is no directory to pop.'
	exit 1
    end
    else do
	/* Switch current directory with the one on top of stack, NewDir */
	NewDirVerify = _beaut(directory(NewDir))
	if ( NewDirVerify <> '' ) then do
	    call value 'PUSHD',DirStack,'OS2ENVIRONMENT'
	    say NewDirVerify decode(DirStack)
	end
	else do
	    /* could not change to NewDir, so just delete it from stack */
	    say NewDir': No such directory.'
	    call value 'PUSHD',DirStack,'OS2ENVIRONMENT'
	    CurrentDir = _beaut(directory())
	    say CurrentDir decode(DirStack)
	    exit 2
	end
    end
end
exit 0

encode:
    parse arg InputString

    OutputString = translate(InputString,'|',' ')
    return OutputString

decode:
    parse arg InputString

    OutputString = translate(InputString,' ','|')
    return OutputString
