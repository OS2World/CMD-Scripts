/* Squirm Process Reconfiguration v1.0             */
/* Dimitris 'sehh' Michelinakis <sehh@altered.com> */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call sysloadfuncs
say "þ start"
say "þ initializing"
do while queued()<>0
 call lineIN("QUEUE:")
end
say "þ scanning processes"
cmd='@pstat /C 2>NUL | rxqueue 2>NUL'
cmd
proc.0=0
i=0
do while queued()<>0
 rc = lineIN( "QUEUE:" )
 i=i+1
 proc.i=rc
end
proc.0=i
say "þ restarting processes"
z=0
do i=1 to proc.0
 if pos("SQUIRM.EXE",proc.i)>0 then do
  parse value proc.i with word proc.i
  cmd='@emxkill.exe 1 '||x2d(word)
  cmd
  z=z+1
  call SysSleep(1)
 end
end
say "þ "||z||" processes restarted"
say "þ end"
