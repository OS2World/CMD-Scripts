/* Correct Netscape URL Charset setting (fixes list bullets)
   (c) Peter Franken, Aachen/Germany, 1.4.96 
       peter@pool.informatik.rwth-aachen.de */
 CALL RxFuncAdd    'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
 CALL SysLoadFuncs

/*  ##### Change below, if necessary!!! ############## */
 NetScapeIni = 'E:\NETSCAPE\NETSCAPE.INI'
 NetScapeIni = 'NETSCAPE.INI'
/*  ##### Change above, if necessary!!! ############## */
 if stream(NetScapeIni,'C','query exists') = "" then
   do 
   say "The INI-File "NetScapeIni" doesn't exist!!!"
   say "NO CHANGES APPLIED, OPERATION ABORTED!"
   exit
   end
 else
   do
   say "The INI-File "NetScapeIni" will be changed to correct the "
   say "decoding of special characters like list bullets."

   rc = SysIni(NetScapeIni , "Intl", "URL Charset", "iso-8859-1")
   say
   if rc = "" then
     say NetScapeIni" successfully corrected"
   else
     do
     say "Can't correct "NetScapeIni"!!!"
     say "Please check "NetScapeIni" manually, if decoding errors still occur."
     end
   end
