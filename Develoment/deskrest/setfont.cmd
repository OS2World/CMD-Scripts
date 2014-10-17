/* setfont <size.name> */                          
                                                   
call RxFuncAdd "SysIni", "RexxUtil","SysIni"                           
parse arg Font                                     
                                                   
if Font = "" then do                               
   call beep 400,250                               
   say "Aufruf: setfont",                          
       " size.fontname"                            
   say "z.B. setfont 8.Helv"                       
end                                                
else                                               
   call SysIni "User", "PM_SystemFonts", "DefaultFont", Font||x2c(0)                               
