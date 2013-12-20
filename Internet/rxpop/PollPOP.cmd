/* PollPOP.cmd by Christoph Lechleitner */

call RxFuncAdd 'SysSleep', 'RexxUtil', 'SysSleep'

say ' '
say ' POP-Poller for jk.uni-linz.ac.at'
interval = 120
say ' I will poll it in intervals of ' interval ' seconds.'

do forever
  say ' '
  say ' Getting mail on' date() 'at' time() '.'
  '@call getpop.cmd <popserver> <userid> <password> <filemask>'
  /* replace the <variables> with your data */
  say ' '
  call SysSleep interval
end

