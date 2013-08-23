/* done by Nenad */

Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

Call RxFuncAdd 'StHealthLoadFuncs', 'StHealth', 'StHealthLoadFuncs'
Call StHealthLoadFuncs

Call RxFuncAdd 'RT2LoadFuncs', 'Theseus0', 'RT2LoadFuncs'
Call RT2LoadFuncs

do forever

  parse value RT2AnalyzeSwapper() with SwapUsed SwapFree
  '@echo' format((SwapUsed+SwapFree)*4/1024,,)" ("format(SwapUsed*4/1024,,1)")"'> \pipe\swapmon'

  Call SysSleep(10)

  '@echo' format(StHealthValue(TEMP1),,1)"øC "'> \pipe\tempmon'

  Call SysSleep(50)

end
