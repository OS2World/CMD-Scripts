/*ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
  ณ    C.F.W ANSI-TREIBER   (C) Copyright 1992 by                  ณ
  ณ                                                                ณ
  ณ             C.F.W. Christian Fair Ware                         ณ
  ณ                   H”lderlinweg 10                              ณ
  ณ                   7043 Grafenau 2                              ณ
  ณ                                                                ณ
  ณ               Tel./FAX : (07033) 41 40 4                       ณ
  ณ                                                                ณ
  ณออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออณ
  ณ                                                                ณ
  ณ  Parameter : 1 COMMAND : SS = SCREEN SIZE  , row , col         ณ
  ณ                                                                ณ
  ณ                          CL = COLOUR       , foreground, backg.ณ
  ณ                                                                ณ
  ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

*/
trace on
parse arg command,parm1,parm2
command = translate(command)
parm1   = translate(parm1)
parm2   = translate(parm2)
select
  when command = 'SS'
   then
      do
       rc= screen_mode(parm1,parm2)
       return rc
      end
  when translate(strip(command)) = 'CL'
   then
      do
       rc=ansi_handle(parm1,parm2)
       return rc
      end
  otherwise
      return 99
 end
 exit rc
ansi_handle: procedure
 seq='['
 fg = ''
 bg = ''
 parse arg foreground,background
 select
   when substr(foreground,1,3) = 'RES'
     then
        call charout ,seq||'0m'
   when substr(foreground,1,3) = 'BOL'
     then
        call charout ,seq||'1m'
   when substr(foreground,1,3) = 'BLI'
     then
        call charout ,seq||'5m'
   when substr(foreground,1,3) = 'INV'
     then
        call charout ,seq||'7m'
   when substr(foreground,1,4) = 'INVI'
     then
        call charout ,seq||'8m'
   otherwise
     select
       when substr(foreground,1,3) = 'BLA'
         then fg = 30
       when substr(foreground,1,3) = 'RED'
         then fg = 31
       when substr(foreground,1,3) = 'GRE'
         then fg = 32
       when substr(foreground,1,3) = 'YEL'
         then fg = 33
       when substr(foreground,1,3) = 'BLU'
         then fg = 34
       when substr(foreground,1,3) = 'MAG'
         then fg = 35
       when substr(foreground,1,3) = 'CYA'
         then fg = 36
       when substr(foreground,1,3) = 'WHI'
         then fg = 37
       otherwise
          fg = 37
     end
     select
       when substr(background,1,3) = 'BLA'
         then bg = 40
       when substr(background,1,3) = 'RED'
         then bg = 41
       when substr(background,1,3) = 'GRE'
         then bg = 42
       when substr(background,1,3) = 'YEL'
         then bg = 43
       when substr(background,1,3) = 'BLU'
         then bg = 44
       when substr(background,1,3) = 'MAG'
         then bg = 45
       when substr(background,1,3) = 'CYA'
         then bg = 46
       when substr(background,1,3) = 'WHI'
         then bg = 47
       otherwise
          bg = 40
     end
  end
  if fg <> '' & bg <> ''
  then
     call charout ,'[1m'||seq||fg||';'||bg||'m'
return rc
screen_mode: procedure
 parse arg cols,rows
 '@MODE CO'||cols','rows
return rc
