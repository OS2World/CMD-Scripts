/*
 PROGRAM  : cfgSort.cmd
 AUTHOR   : N. Morrow - morrownr@netscape.net
 LANGUAGE : REXX
 OS       : eCS v1.2
 SYNOPSIS : command line config.sys sort utility
 USAGE    : cfgsort <input filename> <output filename>
          :   Allows user to specify filenames
 USAGE    : cfgsort /v
          :   Input and output filenames set to:
          :   <boot volume>:\CONFIG.SYS
          :   Verbose mode, command line output displayed
 USAGE    : cfgsort /r
          :   Input and output filenames set to:
          :   <boot volume>:\CONFIG.SYS
          :   Restrained mode, no command line output
 USAGE    : cfgsort /h
          :   Displays help
 CREATED  : 2003 May 12
 UPDATED  : 2004 Mar 21
 STATUS   : Public Domain
 NOTES    :

 It is desirable from reviewer, user and tech support
 perspectives to have an eCS config.sys that is orderly.

 cfgSort is designed to meet that goal.  cfgSort may be used
 as often as necessary to maintain the organization of the
 config.sys file.

 Basic concept of operation:

 cfgSort will sort statements into *sections* as follows:

    [0] REMARK STATEMENTS - "REM" statements that do not
    contain keywords will be placed in this section in the
    order encountered in the input config.sys.

    [1] KERNEL DIRECTIVE STATEMENTS will be alphabetically
    sorted.  REMed kernel directive statements will be
    alphabetically sorted as if there is no "REM " at the
    beginning of the statement.  REMed comment statements
    must contain one of the keywords for this section to be
    retained in the section.  REMed comment statements will
    be sorted in alphabetically order.

      Keywords:

      KERNEL
      AUTOFAIL
      BREAK 
      BUFFERS
      CLOCKSCALE
      CODEPAGE
      COUNTRY
      DEVICEHIGH
      DISKCACHE
      DLLBASING
      DOS
      DUMPPROCESS
      EARLYMEMINIT
      FCBS
      FAKEISS
      FILES
      I13PAGES
      IOPL
      LASTDRIVE
      MAXWAIT
      MEMMAN
      NWDTIMER
      PAUSEONERROR
      PRINTMONBUFSIZE
      PRIORITY
      PRIORITY_DISK_IO
      PROTECTONLY
      PROTSHELL
      RASKDATA
      REIPL
      RESERVEDRIVELETTER
      RMSIZE
      SHELL
      STRACE
      SUPPRESSPOPUPS
      SXFAKEHWFPU
      THREADS
      TIMESLICE
      TRACE
      TRACEBUF
      TRAPDUMP
      VIRTUALADDRESSLIMIT
      VME

    [2] SET STATEMENTS - "SET" statements will be
    alphabetically sorted.  REMed SET statements will be
    alphabetically sorted as if there is no "REM " at the
    beginning of the statement.   REMed comment statements
    must contain the keyword for this section to be
    retained in the section.  REMed comment statements will
    be sorted in alphabetically order.

      Keyword:  SET


    [3] PATH STATEMENTS - "PATH" statements, REMed PATH
    statements and comments will be placed in the output
    config.sys in the order encountered in the input
    config.sys.

      Keyword:  PATH


    [4] DEVICE INFORMATION - "DEVINFO" statements, REMed
    DEVINFO statements and comments will be placed in the
    output config.sys in the order encountered in the input
    config.sys.

      Keyword:  DEVINFO


    [5] PLATFORM SPECIFIC DRIVERS - "PSD" statements, REMed
    PSD statements and comments will be placed in the output
    config.sys in the order encountered in the input config.sys.

      Keyword:  PSD


    [6] BASE DEVICE DRIVERS - "BASEDEV" statements, REMed
    BASEDEV statements and comments will be sorted by category
    but individual statements within each category will not be
    sorted.

    The category order will be as follows:

    SYS
    BID
    VSD
    TSD
    ADD
    I13
    FLT
    DMD

      Keyword:  BASEDEV


    [7] DEVICE DRIVERS - "IFS" statements and "DEVICE"
    statements, REMed IFS and DEVICE statements and comments
    will be placed in the output config.sys in the order
    encountered in the input config.sys.

      Keywords:  IFS, DEVICE


    [8] EXECUTABLE STATEMENTS - "RUN" and "CALL" statements,
    REMed RUN and CALL statements and comments will be placed
    in the output config.sys in the order encountered in the
    input config.sys.

      Keywords:  RUN, CALL


    -----

    Files included in the distribution:

    cfgsort.cmd - executable.
    cfgsort.doc - documentation in text format.
    cfgsort.en - English language support file (compiled).
    cfgsort.de - German language support file (compiled).
    cfgsort.es - Spanish language support file (compiled).
    cfgsort.fr - French language support file (compiled).
    en.mkm - English language support file source code.
    de.mkm - German language support file source code.
    es.mkm - Spanish language support file source code.
    fr.mkm - French language support file source code.
        
    Installation: Place cfgsort.cmd in the directory of
    your choice.  Typing "cfgsort /h" or "cfgsort" with
    no parameters at a command line interface will display
    help.

    Language support:  English is supported by default.  To
    enable another language it is necessary to place a file
    named cfgsort.msg in the same directory as cfgsort.cmd
    or, alternatively, in any directory in the DPATH.

    Example:  To enable German language support, copy or
    rename the file "cfgsort.de" to "cfgsort.msg" and then
    place cfgsort.msg in the same directory as cfgsort.cmd
    or, alternatively, in any directory in the DPATH.

    Language support source code files:

    I am including the language support source files (*.mkm)
    in an effort to make it easy for folks to add support
    for additional languages.  Open the files with a text editor
    for more information.

    -----

    cfgSort has been tested with Classic REXX and Object REXX.

    -----

    Change log:

    v4:  Changed the order of the sections.  UI cleanup.

    v4.2: Added support for PSDs.  Code cleanup.
          Moved language support into cfgsort.msg.

    v4.3:  Code cleanup and optimization.
           Spanish language support.

    v4.4.5:  Added section numbers.
             French language support.
             German language support.
             Section sorting routines improved.
             The SET section is now alphabetically sorted.
             Improved docs (I hope).
             Kernel directive section now retains REMed statements
               and comments.

    v4.6.0   Added KERNEL keyword to kernel directive section
             Changed section roman numerals to regular numbers
             Fixed minor cosmetic bugs

    -----

    Bug reports, new language files and recommendations go to:

    morrownr@netscape.net

    -----

 DISCLAIMER:

 THIS SOFTWARE IS PROVIDED BY THE CONTRIBUTORS "AS IS" AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

progVer = "cfgSort v4.6.5"

call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
call SysLoadFuncs

loadLanguageSupport:
msgFile = "cfgsort.msg"
msgFileAvailable = STRIP(STRIP(SysGetMessage(0100,msgFile),'T','0a'x),'T','0d'x)
if msgFileAvailable = 'cfgSort' then
   do
       _PURPOSE_    = STRIP(STRIP(SysGetMessage(0101,msgFile),'T','0a'x),'T','0d'x)
       _USAGE1_     = STRIP(STRIP(SysGetMessage(0102,msgFile),'T','0a'x),'T','0d'x)
       _USAGE2a_    = STRIP(STRIP(SysGetMessage(0103,msgFile),'T','0a'x),'T','0d'x)
       _USAGE2b_    = STRIP(STRIP(SysGetMessage(0104,msgFile),'T','0a'x),'T','0d'x)
       _WARNING1a_  = STRIP(STRIP(SysGetMessage(0105,msgFile),'T','0a'x),'T','0d'x)
       _WARNING1b_  = STRIP(STRIP(SysGetMessage(0106,msgFile),'T','0a'x),'T','0d'x)
       _WARNING2a_  = STRIP(STRIP(SysGetMessage(0107,msgFile),'T','0a'x),'T','0d'x)
       _WARNING2b_  = STRIP(STRIP(SysGetMessage(0108,msgFile),'T','0a'x),'T','0d'x)
       _ERROR_      = STRIP(STRIP(SysGetMessage(0109,msgFile),'T','0a'x),'T','0d'x)
       _Input_file  = STRIP(STRIP(SysGetMessage(0110,msgFile),'T','0a'x),'T','0d'x)
       _Output_file = STRIP(STRIP(SysGetMessage(0111,msgFile),'T','0a'x),'T','0d'x)
       _Successful  = STRIP(STRIP(SysGetMessage(0112,msgFile),'T','0a'x),'T','0d'x)
   end
else
   do
       _PURPOSE_    = "PURPOSE: Sort CONFIG.SYS file into orderly sections."
       _USAGE1_     = "USAGE: cfgSort <input filename> <output filename>"
       _USAGE2a_    = "USAGE: cfgSort /v"
       _USAGE2b_    = "     : Input and output set to"
       _WARNING1a_  = "WARNING: cfgSort does not prompt before overwriting"
       _WARNING1b_  = "         existing files with the output file."
       _WARNING2a_  = "WARNING: Please make a backup of your current CONFIG.SYS"
       _WARNING2b_  = "         before using this utility."
       _ERROR_      = "ERROR: Cannot find file:"
       _Input_file  = "Input file :"
       _Output_file = "Output file:"
       _Successful  = "Successful"
   end

inputFile  = ''
outputFile = ''
noOutput   = 0

parse upper arg inputFile outputFile

if (LENGTH(inputFile) < 1) | (POS('/H',inputFile) <> 0) then
   do /* output help screen */
      say
      say progVer
      say
      say _PURPOSE_
      say
      say _USAGE1_
      say 
      say _USAGE2a_
      say _USAGE2b_ SysBootDrive()||'\CONFIG.SYS'
      say
      say _WARNING1a_
      say _WARNING1b_
      say
      say _WARNING2a_
      say _WARNING2b_
      return 1
   end

if POS('/V',inputFile) <> 0 then
   do
      inputFile  = SysBootDrive()||"\"||"CONFIG.SYS"
      outputFile = inputFile
   end

if POS('/R',inputFile) <> 0 then
   do
      inputFile  = SysBootDrive()||"\"||"CONFIG.SYS"
      outputFile = inputFile
      noOutput   = 1
   end


call SysFileTree inputFile, 'fileExist', 'F'
if fileExist.0 = 0 then
   do
      say
      say progVer
      say 
      say _ERROR_||inputFile
      say 
      return 1
   end

/* initialize variables */
rem     = 0 /* REMARK STATEMENTS */
kernel  = 0 /* KERNEL DIRECTIVE STATEMENTS */
set     = 0 /* SET STATEMENTS */
path    = 0 /* PATH STATEMENTS */
devinfo = 0 /* DEVICE INFORMATION */
psd     = 0 /* PLATFORM SPECIFIC DRIVERS */
basedev = 0 /* BASE DEVICE DRIVER STATEMENTS */
device  = 0 /* DEVICE DRIVERS */
exe     = 0 /* RUN AND CALL STATEMENTS */

rems.     = "" /* REMARK STATEMENTS */
kernels.  = "" /* KERNEL DIRECTIVE STATEMENTS */
sets.     = "" /* SET STATEMENTS */
paths.    = "" /* PATH STATEMENTS */
devinfos. = "" /* DEVICE INFORMATION */
psds.     = "" /* PLATFORM SPECIFIC DRIVERS */
basedevs. = "" /* BASE DEVICE DRIVER STATEMENTS */
devices.  = "" /* DEVICE DRIVERS */
exes.     = "" /* RUN AND CALL STATEMENTS */

rems.0     = 0 /* REMARK STATEMENTS */
kernels.0  = 0 /* KERNEL DIRECTIVE STATEMENTS */
sets.0     = 0 /* SET STATEMENTS */
paths.0    = 0 /* PATH STATEMENTS */
devinfos.0 = 0 /* DEVICE INFORMATION */
psds.0     = 0 /* PLATFORM SPECIFIC DRIVERS */
basedevs.0 = 0 /* BASE DEVICE DRIVER STATEMENTS */
devices.0  = 0 /* DEVICE DRIVERS */
exes.0     = 0 /* RUN AND CALL STATEMENTS */

main:
do while LINES(inputFile)
   inputLine = LINEIN(inputFile)

   select

      /* delete blank lines */
      when LENGTH(inputLine)     = 0        then nop

      /* delete cfgsort section headers */
      when SUBSTR(inputLine,1,5) = 'REM ['  then nop

      /* delete old style cfgSort section headers */
      when SUBSTR(inputLine,1,6) = 'REM -=' then nop

      /* start REM processing */

      when SUBSTR(TRANSLATE(inputLine),1,3) = 'REM' then
      select

         /* must come before routine that processes SET statements */
         when POS('SET HELP=', TRANSLATE(inputLine)) <> 0 then
            do
               path       = path + 1
               paths.0    = path
               paths.path = inputLine
            end

         /* must come before routine that processes SET statements */
         when POS('SET BOOKSHELF=', TRANSLATE(inputLine)) <> 0 then
            do
               path       = path + 1
               paths.0    = path
               paths.path = inputLine
            end

         /* must come before routine that processes SET statements */
         when POS('PATH', TRANSLATE(inputLine)) <> 0 then
            do
               path       = path + 1
               paths.0    = path
               paths.path = inputLine
            end

         when POS('SET', TRANSLATE(inputLine)) <> 0 then
            do
               set      = set + 1
               sets.0   = set
               sets.set = inputLine
            end

         when POS('DEVINFO', TRANSLATE(inputLine)) <> 0 then
            do
               devinfo          = devinfo + 1
               devinfos.0       = devinfo
               devinfos.devinfo = inputLine
            end

         when POS('PSD', TRANSLATE(inputLine)) <> 0 then
            do
               psd      = psd + 1
               psds.0   = psd
               psds.psd = inputLine
            end

         when POS('BASEDEV', TRANSLATE(inputLine)) <> 0 then
            do
               basedev          = basedev + 1
               basedevs.0       = basedev
               basedevs.basedev = inputLine
            end

         when POS('IFS', TRANSLATE(inputLine)) <> 0 then
            do
               device         = device + 1
               devices.0      = device
               devices.device = inputLine
            end

         when POS('DEVICE',  TRANSLATE(inputLine)) <> 0 then
            do
               device         = device + 1
               devices.0      = device
               devices.device = inputLine
            end

         when POS('RUN', TRANSLATE(inputLine)) <> 0 then
            do
               exe      = exe + 1
               exes.0   = exe
               exes.exe = inputLine
            end

         when POS('CALL', TRANSLATE(inputLine)) <> 0 then
            do
               exe      = exe + 1
               exes.0   = exe
               exes.exe = inputLine
            end

         /* start REMed kernel statements */

         when POS('KERNEL', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('AUTOFAIL', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('BREAK', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('BUFFERS', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('CLOCKSCALE', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('CODEPAGE', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('COUNTRY', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('DEVICEHIGH', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('DISKCACHE', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('DLLBASING', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('DOS', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('DUMPPROCESS', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('EARLYMEMINIT', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('FCBS', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('FAKEISS', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('FILES', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('I13PAGES', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('IOPL', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('LASTDRIVE', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('MAXWAIT', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('MEMMAN', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('NWDTIMER', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('PAUSEONERROR', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('PRINTMONBUFSIZE', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('PRIORITY', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('PRIORITY_DISK_IO', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('PROTECTONLY', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('PROTSHELL', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('RASKDATA', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('REIPL', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('RESERVEDRIVELETTER', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('RMSIZE', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('SHELL', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('STRACE', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('SUPPRESSPOPUPS', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('SXFAKEHWFPU', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('THREADS', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('TIMESLICE', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('TRACE', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('TRACEBUF', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('TRAPDUMP', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('VIRTUALADDRESSLIMIT', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         when POS('VME', TRANSLATE(inputLine)) <> 0 then
            do
               kernel         = kernel + 1
               kernels.0      = kernel
               kernels.kernel = inputLine
            end

         /* end REMed kernel statements */

      otherwise
         do
            rem      = rem + 1
            rems.0   = rem
            rems.rem = inputLine
         end
      end

      /* end REM processing */


      /* must come before routine that processes SET statements */
      when POS('SET HELP=', TRANSLATE(inputLine)) <> 0 then
         do
            path       = path + 1
            paths.0    = path
            paths.path = inputLine
         end

      /* must come before routine that processes SET statements */
      when POS('SET BOOKSHELF=', TRANSLATE(inputLine)) <> 0 then
         do
            path       = path + 1
            paths.0    = path
            paths.path = inputLine
         end

      /* must come before routine that processes SET statements */
      when POS('PATH', TRANSLATE(inputLine)) <> 0 then
         do
            path       = path + 1
            paths.0    = path
            paths.path = inputLine
         end

      when SUBSTR(TRANSLATE(inputLine),1,3) = 'SET' then
         do
            set      = set + 1
            sets.0   = set
            sets.set = inputLine
         end

      when SUBSTR(TRANSLATE(inputLine),1,7) = 'DEVINFO' then
         do
            devinfo          = devinfo + 1
            devinfos.0       = devinfo
            devinfos.devinfo = inputLine
         end

      when SUBSTR(TRANSLATE(inputLine),1,3) = 'PSD' then
         do
            psd      = psd + 1
            psds.0   = psd
            psds.psd = inputLine
         end

      when SUBSTR(TRANSLATE(inputLine),1,7) = 'BASEDEV' then
         do
            basedev          = basedev + 1
            basedevs.0       = basedev
            basedevs.basedev = inputLine
         end

      when SUBSTR(TRANSLATE(inputLine),1,3) = 'IFS' then
         do
            device         = device + 1
            devices.0      = device
            devices.device = inputLine
         end

      when SUBSTR(TRANSLATE(inputLine),1,6) = 'DEVICE' then
         do
            device         = device + 1
            devices.0      = device
            devices.device = inputLine
         end

      when SUBSTR(TRANSLATE(inputLine),1,3) = 'RUN' then
         do
            exe      = exe + 1
            exes.0   = exe
            exes.exe = inputLine
         end

      when SUBSTR(TRANSLATE(inputLine),1,4) = 'CALL' then
         do
            exe      = exe + 1
            exes.0   = exe
            exes.exe = inputLine
         end

   otherwise  /* assumed to be a kernel directive */ 
      do
         kernel    = kernel + 1
         kernels.0 = kernel
         kernels.kernel = inputLine
      end
   end  /* select */
end /* main */
call STREAM inputFile,'C','CLOSE'


outputNewFile:
rc = SysFileDelete(outputFile)

call LINEOUT outputFile, 'REM [CONFIG.SYS]'
call LINEOUT outputFile, 'REM ['DATE('O') TIME()']'
call LINEOUT outputFile, 'REM [Sorted by' progVer']'
call LINEOUT outputFile, ''

if rems.1 <> "" then
   do
      call LINEOUT outputFile, ''
      call LINEOUT outputFile, 'REM [0] REMARK STATEMENTS'
      do i = 1 to rems.0
         call LINEOUT outputFile, rems.i
      end
      call LINEOUT outputFile, ''
   end

call LINEOUT outputFile, ''
call LINEOUT outputFile, 'REM [1] KERNEL DIRECTIVE STATEMENTS'
/* begin sort - tweeked by Veit */
do i = 1 to kernels.0
   kernels_temp.i = TRANSLATE(kernels.i)
   if SUBWORD(kernels_temp.i,1,1) == 'REM' then
      kernels_temp.i = SUBWORD(kernels_temp.i,2)
end
do i = kernels.0 to 1 by -1 until flip_flop = 1
   flip_flop = 1
   do j = 2 to i
      m = j - 1
      if kernels_temp.m >> kernels_temp.j then
      do
         xchg           = kernels.m
         kernels.m      = kernels.j
         kernels.j      = xchg
         xchg           = kernels_temp.m
         kernels_temp.m = kernels_temp.j
         kernels_temp.j = xchg
         flip_flop      = 0
      end
   end
end
drop kernels_temp
/* end sort */
do i = 1 to kernels.0
   call LINEOUT outputFile, kernels.i
end
call LINEOUT outputFile, ''

call LINEOUT outputFile, ''
call LINEOUT outputFile, 'REM [2] ENVIRONMENT VARIABLE STATEMENTS'
/* begin sort - tweeked by Veit */
do i = 1 to sets.0
   sets_temp.i = TRANSLATE(sets.i)
   if SUBWORD(sets_temp.i,1,1) == 'REM' then
      sets_temp.i = SUBWORD(sets_temp.i,2)
end
do i = sets.0 to 1 by -1 until flip_flop = 1
   flip_flop = 1
   do j = 2 to i
      m = j - 1
      if sets_temp.m >> sets_temp.j then
      do
         xchg        = sets.m
         sets.m      = sets.j
         sets.j      = xchg
         xchg        = sets_temp.m
         sets_temp.m = sets_temp.j
         sets_temp.j = xchg
         flip_flop   = 0
      end
   end
end
drop sets_temp
/* end sort */
do i = 1 to sets.0
   call LINEOUT outputFile, sets.i
end
call LINEOUT outputFile, ''

call LINEOUT outputFile, ''
call LINEOUT outputFile, 'REM [3] PATH STATEMENTS'
do i = 1 to paths.0
   call LINEOUT outputFile, paths.i
end
call LINEOUT outputFile, ''

call LINEOUT outputFile, ''
call LINEOUT outputFile, 'REM [4] DEVICE INFORMATION STATEMENTS'
do i = 1 to devinfos.0
   call LINEOUT outputFile, devinfos.i
end
call LINEOUT outputFile, ''

if psds.1 <> "" then
   do
      call LINEOUT outputFile, ''
      call LINEOUT outputFile, 'REM [5] PLATFORM SPECIFIC DRIVER STATEMENTS'
      do i = 1 to psds.0
         call LINEOUT outputFile, psds.i
      end
      call LINEOUT outputFile, ''
   end

call LINEOUT outputFile, ''
call LINEOUT outputFile, 'REM [6] BASE DEVICE DRIVER STATEMENTS'
do i = 1 to basedevs.0
   if POS('.SYS', TRANSLATE(basedevs.i)) <> 0 then
      do
         call LINEOUT outputFile, basedevs.i
      end
end
do i = 1 to basedevs.0
   if POS('.BID', TRANSLATE(basedevs.i)) <> 0 then
      do
         call LINEOUT outputFile, basedevs.i
      end
end
do i = 1 to basedevs.0
   if POS('.VSD', TRANSLATE(basedevs.i)) <> 0 then
      do
         call LINEOUT outputFile, basedevs.i
      end
end
do i = 1 to basedevs.0
   if POS('.TSD', TRANSLATE(basedevs.i)) <> 0 then
      do
         call LINEOUT outputFile, basedevs.i
      end
end
do i = 1 to basedevs.0
   if POS('.ADD', TRANSLATE(basedevs.i)) <> 0 then
      do
         call LINEOUT outputFile, basedevs.i
      end
end
do i = 1 to basedevs.0
   if POS('.I13', TRANSLATE(basedevs.i)) <> 0 then
      do
         call LINEOUT outputFile, basedevs.i
      end
end
do i = 1 to basedevs.0
   if POS('.FLT', TRANSLATE(basedevs.i)) <> 0 then
      do
         call LINEOUT outputFile, basedevs.i
      end
end
do i = 1 to basedevs.0
   if POS('.DMD', TRANSLATE(basedevs.i)) <> 0 then
      do
         call LINEOUT outputFile, basedevs.i
      end
end
call LINEOUT outputFile, ''

call LINEOUT outputFile, ''
call LINEOUT outputFile, 'REM [7] DEVICE DRIVER STATEMENTS'
do i = 1 to devices.0
   call LINEOUT outputFile, devices.i
end
call LINEOUT outputFile, ''

call LINEOUT outputFile, ''
call LINEOUT outputFile, 'REM [8] EXECUTABLE STATEMENTS'
do i = 1 to exes.0
   call LINEOUT outputFile, exes.i
end
call LINEOUT outputFile, ''

call LINEOUT outputFile, ''
call LINEOUT outputFile, 'REM [-----'

if noOutput = 0 then
   do
      say
      say progVer
      say
      say _Input_file inputFile
      say _Output_file outputFile
      say
      say _Successful
      say
   end

if LENGTH(outputFile) > 0 then rc = STREAM(outputFile, 'C', 'CLOSE')
return 0
