/* cygnus & PiG */

rc = RxFuncAdd("SysDriveInfo","rexxutil","SysDriveInfo")

a='[32;40m'
c='[36;40m'
d=1000000

say
call charout , 'Getting drives info '

stm=0
do i=67 to 90
rc=SysDriveInfo(d2c(i)':')
if strip(rc) \= '' then
	do
		stm=stm+1
		disk.stm=i
	end
	call charout ,'ş'
end

max=stm
say
say c'ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄ [0mcygni 'c'¿'
say '³ Disk ³ Volume label ³ Total space ³  Used space ³  Free space ³'
say 'ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
stm=1
do max
parse value SysDriveInfo(d2c(disk.stm)':') with dn fs ts l'.'l2
say '³ ' dn ' ³'  left(strip(l||l2),12) '³' right(format(ts/d,3,2),8) 'Mb ³' right(format((ts-fs)/d,3,2),8) 'Mb ³'a right(format(fs/d,4,2),8) 'Mb 'c'³'
stm=stm+1
end
say 'ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÙ[0m'
