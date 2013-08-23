If .%FileLimit = . Set FileLimit=15
set FileList=%@unique[%Temp]
(*dir /fbs /[!*.ba?] %$ | for %n in (@con) do echo %@fileage["%n"] %n >> %FileList) >& nul
start /bg /min /wait /C /N qsort /R %Filelist
(type %FileList | for /l %n in (1,1,%FileLimit) do echo %@instr[10,,%@line[con,0]] | find /V "ECHO is OFF") >&> nul
del /q %FileList
