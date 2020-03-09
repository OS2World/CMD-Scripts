*/
/*ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
  ณ    C.F.W Box-Zeichnen   (C) Copyright 1992 by                  ณ
  ณ                                                                ณ
  ณ             C.F.W. Christian Fair Ware                         ณ
  ณ                   H”lderlinweg 10                              ณ
  ณ                   7043 Grafenau 2                              ณ
  ณ                                                                ณ
  ณ               Tel./FAX : (07033) 41 40 4                       ณ
  ณ                                                                ณ
  ณออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออณ
  ณ                                                                ณ
  ณ  Parameter : zeile,reihe,breite,h”he in char                   ณ
  ณ                                                                ณ
  ณ                                                                ณ
  ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

*/
parse arg b_row,b_col,width,height
call init
do
 top_line = top_left||copies(hor,width-2)||top_right
 frame    = vert||copies(' ',width-2)||vert
 bot_line = bot_left||copies(hor,width-2)||bot_right
 row = b_row
 call SysCurPos row,b_col
 call charout,top_line
 row = row + 1
 do i = 1 to height-2
  call SysCurPos row,b_col
  call charout,frame
  row=row+1
 end
 call SysCurPos row,b_col
 call charout,bot_line
end
exit rc
init:
 top_left = 'ฺ'
 top_right= 'ฟ'
 bot_left = 'ภ'
 bot_right= 'ู'
 hor      = 'ฤ'
 vert     = 'ณ'
 rc       = 0
return
