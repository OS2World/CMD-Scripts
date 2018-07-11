@echo off
SETLOCAL
rem This is an example of setting the environment prior to running
rem TJD Software's FLIST product. In most cases you will see that we
rem use a secondary command processor to actually load and run the
rem required programs. Although FLIST is capable of running programs
rem directly it will not uninstall its BREAK handler. This means that
rem FLIST always sees the Ctrl-Break if the program that you are
rem executing doesn't install its own handler. If we use CMD.EXE to run
rem the program it will pass the Ctrl-Break to its child processes.
rem In addition to this, you will be able to start Presentation Manager
rem programs by using the normal eXecute function. FLIST itself is not
rem able to start PM programs (which abort when executed with a
rem standard call to the operating system.)
rem
rem The ability to specify how FLIST reacts to different file extensions
rem and how the programs will execute is one of the most powerful
rem facilities in FLIST and should be exploited to the full.
rem Note that you can force programs to run in VIO windows, run in the
rem background, run as detached processes etc. very easily!
rem
rem Set the $FPRN$ variable so that it doesn't suspend FLIST if the
rem spooler is not installed. Note that it's PRINT.COM not PRINT.EXE!!!
rem Using this method will make sure that FLIST stays in the foreground
rem and continues to run whilst the PRINT program runs
rem
SET $FPRN$=%COMSPEC% /c START /c "FLIST printing" PRINT.COM
rem
rem Note that by using the above technique you can start the editor, browser
rem and other programs and still leave FLIST running in the foreground.
rem
rem Set BRIEF as the editor to be used by FLIST overriding the default
rem E.EXE editor
rem
SET $FEDT$=B.EXE
rem
rem Set FLIST up to run the ZIPSHELL program when 'X' is requested for a
rem file with a .ZIP extension.
rem
SET $FZIP=%COMSPEC% /c ZIPSHELL $FN
rem
rem The following example shows how we can perform a MAKE operation when
rem we select 'X' for a .C file.
rem
SET $FC=%COMSPEC% /c MAKE $FN.MAK
rem
rem The following example shows how we can start a debugging session by
rem 'executing' a .OBJ or .MAP file. Note that we ask FLIST to prompt us for
rem parameters before it starts the debugger.
rem
SET $FOBJ=CVP $FN.EXE $P
SET $FMAP=CVP $FN.EXE $P
rem
rem TJD Software runs a BBS in the UK using Gilmore Systems' MAGNUM BBS for
rem OS/2 which has with it an interpreted language useful to SYSOPs. The
rem following example shows how I can run such a program without terminating
rem FLIST.
rem
SET $FMEX=%COMSPEC% /c MBBSEXEC $FN
rem
rem At last! We can start FLIST now.
rem
FLIST %1 %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL
