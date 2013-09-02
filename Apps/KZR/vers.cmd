/* vers.cmd */

n=1
do while n<4
  call "H:\rexx\kzrneu\kzrn.cmd" "24, (x); x=n"
  say"    n =" n
  n=n+1
end

/*
call "kzrn"   "24, 2/3"  
*/



Exit
