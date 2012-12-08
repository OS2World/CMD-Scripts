/********************************************************************************/
/* Display magic eye in one of 3 states:                                        */
/* - disp='D' (radio switched off): colour gray                                 */
/* - disp='L' (radio switched on):  colour dark green                           */
/* - disp='R' (radio playing):      colour light green                          */
/********************************************************************************/
DispEye:
  if disp='D' then call charout ,'1b'X'[1;30;43m'  /* bg dark yellow, fg gray       */
  if disp='L' then call charout ,'1b'X'[0;32;43m'  /* bg dark yellow, fg dark green */
  if disp='R' then call charout ,'1b'X'[0;32;43m'  /* bg dark yellow, fg dark green */
  call SysCurPos 11, 10; call charout ,' ????????????? '
  call SysCurPos 12, 10; call charout ,' ????????????? '
  call charout ,'1b'X'[1;32;43m'                  /* bg dark yellow, fg light green */
  if disp='L' then
  do
    /*call SysCurPos 11, 17; call charout ,'?'*/
    /*call SysCurPos 12, 17; call charout ,'?'*/
    call SysCurPos 11, 11; call charout ,'?'
    call SysCurPos 11, 23; call charout ,'?'
    call SysCurPos 12, 11; call charout ,'?'
    call SysCurPos 12, 23; call charout ,'?'
  end
  if disp='R' then
  do
    /*call SysCurPos 11, 12; call charout ,'???????????'*/
    /*call SysCurPos 12, 12; call charout ,'???????????'*/
    call SysCurPos 11, 11; call charout ,'??????'
    call SysCurPos 11, 18; call charout ,'??????'
    call SysCurPos 12, 11; call charout ,'??????'
    call SysCurPos 12, 18; call charout ,'??????'
  end
return