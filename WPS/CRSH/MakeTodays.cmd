(
  echo rootname !ChangedToday 
  echo del All
) | makeshadow /S

Set FileLimit=50
Call FindLatest E:\ D:\ G:\ /[d-1] `| find /v "E:\\Mail" | find /v "E:\\HVM" | find /v "G:\\TMP" | find /v "G:\\!"` | MakeShadow /B E:\!Jasio\!ChangedToday
for /l %n in (1,1,3) do (beep %+ beep 0 9)
