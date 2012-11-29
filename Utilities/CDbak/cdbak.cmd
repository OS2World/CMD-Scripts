/*  CDBAK Copyright Jason R Stefanovich, 2000  stefanj@gte.net                  */
/*  This program is covered by the GNU Lesser Public License (LGPL)             */
/*                                                                              */
/*  Description: Rexx script zips and backs up data onto an ISO9660 CDR with    */
/*  Joliet extensions.  Requires Rexx, InfoZip/Unzip and CdRecord.              */
/*                                                                              */
/*  Installation:  Place CDBAK in its own directory with a file named CDDIR.CFG */
/*  CDDIR.CFG is a line delimited listing of files and directories that         */
/*  should be backed up.  All directories are backed up recursively.            */
/*  CDRecord, its utilities and the InfoZip utilities must be in the PATH.      */
/*  The environment variables CDR_DEVICE and CDR_SPEED must be set in the       */
/*  CONFIG.SYS                                                                  */
/*                                                                              */
/*  Usage:  Call CDBAK from VIO or a WPS Object.  If using the WPS, ensure to   */
/*  set the program's working directory in the object's property notebook       */
/*  CDBAK can be called from a scheduler such as CRON for timed backups         */
/*  Errors are recorded to OUT.LOG.                                             */
/*                                                                              */
/*  Limitations:  CDBAK does not currently check for errors in the resulting    */
/*  CD.  CDBAK can currently only make single session CD's.                     */
/*  This program was written with Regina under Win32 for OS/2.                  */
/*  #include stddisclaimer.h                                                    */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

dircfg='cddir.cfg'
bakcmd='cdbak.cmd'
outlg='out.log'
xit='echo exit > xit.txt'
xitfl='xit.txt'
dtstamp=date(S)||time(S)
dtlabel=date(N)||time(N)
zipnm=dtstamp||'.zip'
noerr1='No errors found'

zipcmd='zip -g -q -r -S 'dtstamp' -@ <'dircfg
tstcmd='zip -T 'dtstamp' > 'outlg


call lineout bakcmd,zipcmd,1
call lineout bakcmd,tstcmd
call lineout bakcmd,xit
rc=stream(bakcmd,'C','CLOSE')

  start bakcmd

do while length(x)==0
  x=stream(xitfl,'C','QUERY EXISTS')
end

call sysfiledelete xitfl

a=right((linein(outlg)),2)
rc=stream(outlg,'C','CLOSE')


if a=='OK' then
  do
    appid="'Data archive created "dtlabel"'"

    mkiso='mkisofs -o cdbak.iso -A 'appid' -J  -pad -relaxed-filenames 'zipnm
    vfyiso='isovfy cdbak.iso >>'outlg

    call lineout bakcmd,mkiso,1
    call lineout bakcmd,vfyiso
    call lineout bakcmd,xit
    rc=stream(bakcmd,'C','CLOSE')

    start bakcmd

    do while length(x)==0
      x=stream(xitfl,'C','QUERY EXISTS')
    end

    call sysfiledelete xitfl

    inlog = charin(outlg,1,chars(outlg))
    rc=STREAM(outlg,'c','close')

    a=lastpos(noerr1, inlog)

    rc=stream(outlg,'C','CLOSE')

    if a >= 1 then
      do
        say 'No errors found in ISO image, creating CD archive'
        cdrec='cdrecord -v -eject cdbak.iso >>'outlg

        call lineout bakcmd,cdrec,1
        call lineout bakcmd,xit
        rc=stream(bakcmd,'C','CLOSE')

        start bakcmd

        do while length(x)==0
          x=stream(xitfl,'C','QUERY EXISTS')
        end

        call sysfiledelete xitfl

        say 'Archive process done.'
      end
      else
        say 'Errors found in ISO image, aborting CD archive.  Check OUT.LOG for details'
  end
  else
    say 'Errors found in Zip archive, aborting ISO image.  Check OUT.LOG for details'



