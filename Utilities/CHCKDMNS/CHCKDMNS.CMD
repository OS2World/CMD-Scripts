/*
    CHECK_DEAMONS.CMD
    (C)1992 Turgut Kalfaoglu <TURGUT@FRORS12.BITNET>

 This program will monitor the deamons it knows about, every <interval> 
 minutes (you define the intervals, default=2), restarting them, if they 
 are not active, and terminating them if there are too many copies of it 
 active.  

Syntax of the deamon. stem:

   <name of the deamon> <required_number_of_copies> <entire command>

name of the deamon: as it appears to PROCS.EXE
required_number_of_copies: The number of copies of this deamon that must
 be active. Use * if any number of copies may be present, but at LEAST 
 one copy must be active.
entire_command: this is the command needed to restart the deamon.

This program is useful to keep your system checked continuously at your 
 absence. Especially some releases of SENDMAIL are prone to proliferate 
 into multiple copies. This program should cure that.

This program requires - a shareware package that displays the processes 
 running, which also comes with a program to stop these processes. This 
 package contains two programs: PROCS.EXE and KILLEM.EXE. Available from
 many sources, including listserv@blekul11, and ftp-os2.nmsu.edu

*****************************************************************/

interval = 2  /* in minutes */
deamon.  = ''
deamon.1 = 'SENDMAIL.EXE 1 DETACH SENDMAIL -bd -q30m'
deamon.2 = 'LAMAIL.EXE 1 START /MIN LAMAIL'
deamon.3 = 'LPRMON.EXE 1 DETACH LPRMON LPT1:'
deamon.4 = 'FTPD.EXE * START /MIN FTPD'
deamon.5 = 'INETD.EXE 1 START /MIN INETD'

Call RxFuncAdd 'SysSleep','RexxUtil','SysSleep'
'@ECHO ON'
do z=1 while deamon.z \=''
end /* do */
maxdeamon = z-1
'CLS'
say time() 'Deamon Monitor Up and running, monitoring' maxdeamon,
 'deamons.'

do forever
   '@PROCS /S > \tmpfile.out'
   line="?"
   count. = 0
   do linenum=1 while (line > "" | linenum<30)
      line = LINEIN("\tmpfile.out")
      parse var line . . procname .
      do z=1 to maxdeamon
         if word(deamon.z,1) = procname then 
            count.z = count.z+1
      end /* do */
   end
   r = LINEOUT("\tmpfile.out",,) /* finis */
   do z=1 to maxdeamon
      parse var deamon.z deamonname maxcopies startcmd
      if count.z = 1 & maxcopies = '*' Then Iterate
      if count.z \= maxcopies then do
        if maxcopies \= '*' Then Do
          say time() 'Found' count.z 'copies of' deamonname'.' 
          if count.z>maxcopies then do
              say time() 'Terminating' deamonname 'deamon(s).'
              'KILLEM' deamonname
          end
        End
        maxcpy = maxcopies
        if maxcpy = '*' then maxcpy=1
        say time() 'Re-activating' maxcpy 'copies of' deamonname
        do t=1 to maxcpy
           interpret '"'startcmd'"'
        end /* do */
      end /* if */
   end /* do */
   Call SysSleep  interval*60
end

