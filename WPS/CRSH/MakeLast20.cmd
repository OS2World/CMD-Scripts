Set FileLimit=20
if %@numeric[%1] == 1 Set FileLimit=%1
Echo Finding %FileLimit newest files

(
  echo cd E:\!Jasio\!RecentlyUsed
  echo rootname !RecentlyUsed
  echo del %FileLimit+
) | MakeShadow /S

Call FindLatest D:\ E:\!Jasio G:\PROGRAMY | MakeShadow /B E:\!Jasio\!RecentlyUsed
for /l %n in (1,1,3) do (beep %+ beep 0 9)
