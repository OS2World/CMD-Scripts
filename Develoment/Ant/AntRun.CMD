/*
 * AntRun.CMD
 * OS/2 and eComStation command file that runs a command in a directory with specified parameters.
 *
 * Copyright (C) 2003 Egothor Developers
 */
 
/*
 * Grab arguments
 */
PrgArgs = ARG(1)

/*
 * Change the current directory
 */
OldDir = DIRECTORY()
OurDir = WORD(PrgArgs, 1)
CALL DIRECTORY OurDir

/*
 * Run the command with the specified parameters
 */
AntRunCmd = WORD(PrgArgs, 2)
RestOfArgs = DELWORD(PrgArgs, 1, 2)

/*
 * Now we run the command with our arguments
 */
AntRunCmd RestOfArgs

/*
 * Back to the old dir
 */
CALL DIRECTORY OldDir
EXIT
