/*ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
  ณCFWINPUT PULL MIT Lngenbegrenzung (c) Copyright 1991 by C.F.W.   ณ
  ณ                                                                  ณ
  ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ
*/
parse arg row,col,len,string
string = left(string,len,'_')
maxcol = col + len - 1
call SysCurState 'ON'
call SysCurPos row,col
call charout,string
call SysCurPos row,col
do forever
 c=SysGetKey('NOECHO')
 parse value SysCurPos() with . cur_col
 select
   when c = 'เ'
    then
       do
        c = ''
        b=SysGetKey('NOECHO')
        select
          when b='K'
           then
             call charout,'[D'
          when b='M'
           then
             call charout,'[C'
          otherwise
           nop
        end
       end
   when c2d(c) = 13
    then
     do
      return strip(strip(SysTextScreenRead(row,col,len),,_))
     end
   when  cur_col >  maxcol
    then
       c=''
   otherwise
     nop
 end
 call charout,c
end
return ''
