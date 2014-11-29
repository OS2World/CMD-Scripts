/* A UPN calculator */

s = .UpnStack~new

do until inp = 'QUIT'
   pull inp
   if s~hasmethod(inp) then do
     cmd = "s~'"inp"'"
     INTERPRET(cmd)
   end
   else s~push(inp)
   s~dump

end

::REQUIRES UpnStack