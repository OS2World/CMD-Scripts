/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ bits.cmd                                               ³
  ³ A REXX procedure to determine if an OS/2 binary file is³
  ³ compiled as 16-bits "NE" or 32-bits "LX"               ³
  ³ Thanks go to Craig Swanson for the above information.  ³
  ³ Last revision: 9 January 93                            ³
  ³ Syntax: bits filespec                                  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

if arg() = 0 then signal Suggestion

parse arg filename

signature = charin(filename, 129, 2)

select
   when signature = "NE" then
      do
      say filename "is a 16-bit New Executable binary file."
      exit
      end
   when signature = "LX" then
      do
      say filename "is a 32-bit Linear eXecutable binary file."
      exit
      end
   otherwise say "Let's confine ourselves to OS/2 binary files, chief!"
end

call stream filename, 'c', 'close'

exit

Suggestion:
say 'Syntax example: bits foo.exe'
exit
