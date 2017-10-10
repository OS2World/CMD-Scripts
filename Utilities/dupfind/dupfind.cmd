/* PROGRAM  : dupfind.cmd
   AUTHOR   : N. Morrow
   LANGUAGE : REXX
   OS       : eCS v1.2.x
   SYNOPSIS : duplicate filename find utility

   USAGE    : dupfind <volume letter>

   EXAMPLE  : > dupfind x [mask]
                or
            : > dupfind x:

   USAGE    : dupfind /h or dupfind -h
            : displays help

   CREATED  : 2005 Apr 22
   UPDATED  : 2005 Sep 11 - v1.0.7
   UPDATED  : 2006 Jun 29 - v1.1    by John Small
   STATUS   : Public Domain
   NOTES    :

   Dupfind checks for files with duplicate filenames on the selected
   volume.  Dupfind is useful for system troubleshooting and for
   locating redundant files.

   The results are logged to a text file called dupfind.log.  After
   processing is finished the location of dupfind.log will be
   displayed.  If the environment variable LOGFILES is set, as it
   is by default in current versions of eCS, then dupfind will
   respect this setting and place dupfind.log in the location
   specified by LOGFILES.

-- As of Warp 4 Fixpak 13, REXXUTIL included additional functions.
-- One of these was SysStemSort.  This program now tries to use
-- this function if it is available.  The speed improvement over
-- v1.0x of this program is dramatic.  Without SysStemSort,
   Dupfind is a processor intensive utility.  On older systems
   with large volumes the time to process may be lengthy.

   ---

   Installation: Place dupfind.cmd in the directory of
   your choice.  Typing "dupfind /h" at a command line interface
   will display help.

   Future enhancements:

   - nls support.
   - ability to check an entire system instead of only one volume.
   - group like filenames by date

*/

/* add REXXUTIL functions */
call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
call SysLoadFuncs
call time 'R'

useStemSort = (RXFUNCQUERY(SysStemSort) == 0)

/* set program name and version */
progVer  = "dupfind v1.1";
sep      = 'ff'x

/* get the volume letter entered at the command line and make it upper case */
parse upper arg volumeLetter mask .

mask = strip(mask)
if mask == '' then
   mask = '*.*'

/* display help */
if (POS("/H",volumeLetter) <> 0) |,
   (POS("-H",volumeLetter) <> 0) |,
   (POS('?', volumeLetter) <> 0) then
    do /* output help screen */
        say
        say progVer;
        say
        say "PURPOSE: Find duplicate filenames.";
        say
        say "USAGE  : dupfind <volume letter> [filename_mask]";
        say
        say "EXAMPLE: > dupfind x";
        say "           or";
        say "       : > dupfind x: *.exe";
        return 1;
    end

/* determine accessible local volumes */
localVolumes = SysDriveMap("C:", "LOCAL");

/* ask for volume letter if it wasn't supplied */
if (LENGTH(volumeLetter) < 1) then
    do
        say
        say progVer;
        say
        say "Accessible local volumes: " localVolumes;
        say
        call CharOut, "Which volume would you like to check? ";
        volumeLetter = SysGetKey() || ':'
    end
else
   if RIGHT(volumeLetter,1) \= ':' then volumeLetter = volumeLetter||':'


/* display error if non-existant volume is entered */
rc = SysDriveInfo(volumeLetter);
if rc = '' then
    do
        say
        say "ERROR: The volume you selected appears not to exist.";
        return 1;
    end

/* use value in LOGFILES environment variable if it is set */
outputDir = VALUE("LOGFILES",,"ENVIRONMENT");
/* if LOGFILES is not set then use current directory */
if outputDir = '' then
    do
        outputDir = directory();
        if RIGHT(outputDir,1) = '\' then
            outputFile = outputDir||"dupfind.log";
        else
            outputFile = outputDir||"\dupfind.log";
    end
else
   do
      /* check if directory in LOGFILES exist */
      rc = DIRECTORY(outputDir);
      if rc \= '' then
          if RIGHT(outputDir,1) = '\' then
              outputFile = outputDir||"dupfind.log";
          else
              outputFile = outputDir||"\dupfind.log";
      else
          do
              say
              say "ERROR: The directory in environment variable LOGFILES appears not to exist.";
              return 1;
          end
   end

/* delete existing dupfind.log */
if STREAM(outputFile, 'C', "QUERY EXISTS") \= '' then
    call SysFileDelete outputFile;

/* dupfind can take a long time on older systems */
say
call SysCurState "OFF"
say "Working...";


/* reads in all filenames from volume specified, ignores hidden files */
rc = SysFileTree(volumeLetter|| "\" || mask, "fullyQualifiedFilenames", "FS", "**-**");

/* display error code */
if rc \= 0 then
    do
        say
        say "ERROR: SysFileTree reported error code" rc;
        return 1;
    end


/* we need to work with filenames, not fully qualified filenames */
do i = 1 to fullyQualifiedFilenames.0
    filenames.i = translate(strip(substr(fullyQualifiedFilenames.i, lastpos('\',fullyQualifiedFilenames.i) + 1))) || sep || i
/* This is slightly slower: TRANSLATE(FILESPEC("name", fullyQualifiedFilenames.i)) || sep || i */
end

/* output log file header */
call LINEOUT outputFile, "dupfind.log"
call LINEOUT outputFile, DATE('O') TIME()
call LINEOUT outputFile, progVer
call LINEOUT outputFile, ''
call LINEOUT outputFile, "Duplicate filenames matching "mask" on volume" volumeLetter
call LINEOUT outputFile, ''

/* find and output duplicate filenames */
if useStemSort == 0 then
   do                       /* 1.0x code for systems without SysStemSort */
      i = 0;
      k = 0;
      dupFilenames. = '';
      do x = 1 to fullyQualifiedFilenames.0
          alreadyDone = 0;
          j = 0;
          testFilenames.x = filenames.x;
          if k > 0 then
              do m = 1 to k
                  if testFilenames.x = dupFilenames.m then alreadyDone = 1;
              end
          if alreadyDone = 1 then nop
          else
              do z = (x + 1) to fullyQualifiedFilenames.0
                  if filenames.z = testFilenames.x then
                      do
                          k = k + 1;
                          dupFilenames.k = testFilenames.x;
                          i = i + 1;
                          if j = 0 then call LINEOUT outputFile, fullyQualifiedFilenames.x;
                          j = j + 1;
                          call LINEOUT outputFile, fullyQualifiedFilenames.z;
                      end
              end
          if j > 0 then call LINEOUT outputFile, ''
      end
   end
else
   do
      filenames.0 = fullyQualifiedFilenames.0
      call SysStemSort('filenames.')
      do j = 1 to filenames.0
         parse var filenames.j name1 (sep) i
         n = 1
         outlist.n = fullyQualifiedFilenames.i
         do k = j + 1 to filenames.0
            parse var filenames.k name2 (sep) i
            if name1 == name2 then
               do
                  n = n + 1
                  outlist.n = fullyQualifiedFilenames.i
               end
            else
               leave
         end
         if n > 1 then
            do
               outlist.0 = n
               call SysStemSort 'outlist.',,,,,38
               do n = 1 to outlist.0
                  call lineout outputfile, outlist.n
               end
               call lineout outputfile, ''
            end
         j = j - 1 + n
      end
   end
/* close the output file */
rc = STREAM(outputFile, "C", "CLOSE");
totaltime = time('E')

/* tell user we are finished and display output file location */
say
say "Finished.";
call BEEP 800,250;
say
say "Output file: " outputFile;
say
say "Files processed: "filenames.0
say
say "Elapsed time: "totaltime
/* return 0 to os signifying sucessful finish */
return 0;

