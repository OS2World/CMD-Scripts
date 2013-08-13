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
	call charout ,'�'
end

max=stm
say
say c'��������������������������������������������������������� [0mcygni 'c'�'
say '� Disk � Volume label � Total space �  Used space �  Free space �'
say '���������������������������������������������������������������Ĵ'
stm=1
do max
parse value SysDriveInfo(d2c(disk.stm)':') with dn fs ts l'.'l2
say '� ' dn ' �'  left(strip(l||l2),12) '�' right(format(ts/d,3,2),8) 'Mb �' right(format((ts-fs)/d,3,2),8) 'Mb �'a right(format(fs/d,4,2),8) 'Mb 'c'�'
stm=stm+1
end
say '�����������������������������������������������������������������[0m'
