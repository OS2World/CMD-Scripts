*/
/*嬪様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様邑
  �    C.F.W Box-Zeichnen   (C) Copyright 1992 by                  �
  �                                                                �
  �             C.F.W. Christian Fair Ware                         �
  �                   H�lderlinweg 10                              �
  �                   7043 Grafenau 2                              �
  �                                                                �
  �               Tel./FAX : (07033) 41 40 4                       �
  �                                                                �
  獲様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様由
  �                                                                �
  �  Parameter : zeile,reihe,breite,h�he in char                   �
  �                                                                �
  �                                                                �
  塒様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様余

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
 top_left = '�'
 top_right= '�'
 bot_left = '�'
 bot_right= '�'
 hor      = '�'
 vert     = '�'
 rc       = 0
return
