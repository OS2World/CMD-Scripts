/* Telephone program
   Written by Helge Hafting
   email:
   hafting@pvv.unit.no
   snail mail:
   poverudvn. 22
   N-3440 R›yken
   NORWAY
*/

arg tlf

if (tlf='' | tlf='?') then signal hjelp

do while left(tlf,1) = ' '
 tlf = substr(tlf,2)
end 

silent = 0
force = 0
disp = 1
num = 0

param = left(tlf,1)
if param = '/' then do 
 tlf = substr(tlf,2)
 do while param <> ' '
  param = left(tlf,1)
  tlf = substr(tlf,2)
  select
   when param = 'S' then silent = 1
   when param = 'F' then force = 1
   when param = 'D' then disp = 0
   when param = '#' then num = 1
   when param = ' ' then nop
  otherwise
   say 'Unknown parameter: "' param '"'
  end
 end
end 
if (tlf='' | tlf='?') then signal hjelp

mmbase = value('MMBASE',,OS2ENVIRONMENT)
if mmbase='' & \force & \silent then signal nixmmpm 

n=setlocal()
parse source dummy1 dummy2 prg
parse upper value prg with newdir '\DIAL.CMD'
call directory(newdir)

if \silent then do
 add_err = rxfuncadd("mciRxInit", "MCIAPI", "mciRxInit")
 call mciRxInit
 rc = mciRxSendString('open waveaudio alias lyd wait', 'RetStr', '0', '0')
 if rc <> 0 then signal feil
end 

add_err = rxfuncadd("SysSleep", "RexxUtil", "SysSleep")
if add_err then say 'Warning: had trouble finding SysSleep in RexxUtil.  Pauses may be unavailable.'

forrige = '_'
do while tlf <> ''
 siffer = left(tlf,1)
 dsp = siffer
 tlf = substr(tlf,2)
 type = pos(siffer,'ABCDEFGHIJKLMNOPRSTUVWXY123456789*0#,')
 if type > 0 then do
  if siffer = '*' then siffer='stjerne'
  else if type < 25 then do
   siffer = trunc((type + 5) / 3)
   if num then dsp = siffer
  end
  if disp then call charout , dsp
  if \silent then do
   if siffer <> ',' then do
    filnavn = siffer'.wav'
    if siffer = forrige then rc = mciRxSendString('seek lyd to start wait', 'RetStr', '0', '0')
    else rc = mciRxSendString('load lyd' filnavn 'wait', 'RetStr', '0', '0')
    if rc <> 0 then signal feil
    rc = mciRxSendString('play lyd wait', 'RetStr', '0', '0')
    if rc <> 0 then signal feil
   end 
   else call SysSleep 1;
  end
 end
end

if \silent then do
 rc = mciRxSendString('close lyd wait', 'RetStr', '0', '0')
 if rc <> 0 then signal feil
 call mciRxExit
end

call RxFuncDrop SysSleep
exit(0)

feil:
MacRC = mciRxGetErrorString(rc, 'ErrStVar')
say 'error' rc',' ErrStVar
rc = mciRxSendString('close lyd wait', 'RetStr', '0', '0')
call mciRxExit
call RxFuncDrop SysSleep
exit(rc)

nixmmpm:
say 'MMPM seems not present.  Try silent operation, or use force.'
exit(1)

hjelp:
say
say 'Usage: dial [/parameters] <phone number>'
say
say 'Parameters, '
say
say 'S Silent       - don''t generate dialling tones.'
say '                 Useful for converting letters to numbers.'
say 'D no Display   - don''t display the numbers as they are dialled'
say '# numbers only - show the number a letter is converted to,'
say '                 instead of the letter itself.'
say 'F Force        - forces operation when mmpm cannot be detected.'
say
say 'Commas "," in the number will cause 1 second pauses. '
say 'Examples:'
say
say 'dial 1234567'
say 'dial /#S (865) 9-ABC-567'
say 'dial /D 12-345-76, *5,,, *2 ##4'
say
exit(0)


