/* PUSHD                                                                     */
/* written:  Ken Neighbors  sometime before 13 May 93                        */
/* revised:  Greg Roelofs   19 May 93  added +n option                       */
/* revised:  Ken Neighbors  30 May 93  comments, bug fixes, beautify         */
/* revised:  Ken Neighbors  28 jul 93  added support for spaces in dir       */

parse arg '"'Argument'"' rest

if ( Argument == '' ) then do
    parse arg Argument rest
end

if ( rest <> '' ) then do
    say 'pushd: Too many arguments.'
    exit 1
end

DirStack = value('PUSHD',,'OS2ENVIRONMENT')

if ( Argument == '' ) then do
    /*
     * first case:  no argument--swap top two directories
     */
    if ( DirStack == '' ) then do
        say 'pushd: No other directory.'
        exit 1
    end
    else do
        parse var DirStack CodedNewDir OtherDirs
        NewDir = decode(CodedNewDir)
        CurrentDir = _beaut(directory())
        NewDirVerify = _beaut(directory(NewDir))

        if ( NewDirVerify == '' ) then do
            say NewDir': No such directory.'
            /* get rid of bad directory (unlike csh pushd) */
            DirStack = OtherDirs
            call value 'PUSHD',DirStack,'OS2ENVIRONMENT'
            say CurrentDir decode(DirStack)
            exit 2
        end
        else do
	    /* place (old) current directory at beginning of stack */
	    CodedCurrentDir = encode(CurrentDir)
	    DirStack = insert(OtherDirs,CodedCurrentDir,length(CurrentDir)+1)
	    call value 'PUSHD',DirStack,'OS2ENVIRONMENT'
	    say NewDirVerify decode(DirStack)
        end

    end
end
else do

    /*
     * second case:  argument is "+n"--do cyclic rotation by n positions
     */

    if ( substr(Argument,1,1) == '+' ) then do
        n = substr(Argument,2)

        /* check that n is a whole number, greater than zero, less than dirs */
        if ( \datatype(n,'Whole number') | (n < 1) ) then do
            say 'pushd: Invalid cyclic parameter'
            exit 3
        end
        NumDirs = words(DirStack)   /* plus one:  current dir */
        if (n > NumDirs) then do
            say 'pushd: Directory stack not that deep'
            exit 3
        end

        CurrentDir = _beaut(directory())

        /* use subword() to parse according to n */
        CodedNewDir = subword(DirStack,n,1)      /* CurrentDir not in DirStack yet */
        NewDir = decode(CodedNewDir)
        NewDirVerify = _beaut(directory(NewDir))
        if ( NewDirVerify == '' ) then do
            say NewDir': No such directory.'
            /* get rid of bad directory (unlike csh pushd) */
            DirStack = delword(DirStack,n,1)
            call value 'PUSHD',DirStack,'OS2ENVIRONMENT'
            say CurrentDir decode(DirStack)
            exit 2
        end
        else do
	    /* directory exists and we're now in it:  shift DirStack around */
	    /* CurrentDir is no longer current--it's the old directory */
	    /* Warning:  this is confusing */
	    CodedCurrentDir = encode(CurrentDir)
	    DirStack = insert(DirStack,CodedCurrentDir,length(CurrentDir)+1)
	    firsthalf = subword(DirStack,1,n)
	    lasthalf = subword(DirStack,n+1)
	    DirStack = insert(firsthalf,lasthalf,length(lasthalf)+1)
	    /* get rid of now current dir, "NewDir" */
	    DirStack = delword(DirStack,1,1)

	    call value 'PUSHD',DirStack,'OS2ENVIRONMENT'
            say NewDir decode(DirStack)
        end
    end

    /*
     * third case:  argument is new directory--switch to it and add to stack
     */

    else do
	NewDir = translate(Argument,'\','/')
        CurrentDir = _beaut(directory())

        NewDirVerify = _beaut(directory(NewDir))
        if ( NewDirVerify == '' ) then do
            say NewDir': No such directory.'
            exit 2
        end
        CodedCurrentDir = encode(CurrentDir)
        DirStack = insert(DirStack,CodedCurrentDir,length(CurrentDir)+1)
        call value 'PUSHD',DirStack,'OS2ENVIRONMENT'
        say NewDirVerify decode(DirStack)
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
