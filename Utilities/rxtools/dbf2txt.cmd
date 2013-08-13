/* DBF to text converter by cygnus, 2:463/62.32 */

parse arg fname
if fname \= '' then
do
 i=0
 rc=reverse(charin(fname,5,4))
 records=c2d(rc)

 perc=records%30+1
 rc=charin(fname,1,32)
 test=charin(fname)

 do while test \= '0d'x
	i=i+1
	fieldname.i=test||charin(fname,,10)
	type.i=charin(fname)
	rc=charin(fname,,4)
	len.i=c2d(charin(fname))
	rc=charin(fname,,15)
	rc=charout('DBFout.txt',fieldname.i type.i len.i||'0d0a'x)
	test=charin(fname)
 end

 fields=i
 rc=charout('DBFout.txt','0d0a'x)
 do i=1 to fields
        rc=charout('DBFout.txt',left(fieldname.i,len.i)' ')
 end
 rc=charout('DBFout.txt','0d0a0d0a'x)
 rc=charout(,'Creating DBFout.txt ')

 do a=1 to records
	call charin(fname)
	if a//perc=0 then rc=charout(,'±')
	do i=1 to fields
		rc=charin(fname,,len.i)
		rc=charout('DBFout.txt',rc' ')
	end
	rc=charout('DBFout.txt','0d0a'x)
 end
 call charout 'DBFout.txt','0d0a'x||records 'records total.'
end
else say 'Usage: dbf2txt [DBFname.dbf]'