/* HPFS names to 8.3 converter */
call RxFuncAdd 'SysFileTree', 'RexxUtil', 'SysFileTree'
call RxFuncAdd 'SysPutEA', 'RexxUtil', 'SysPutEA'

call SysFileTree '*', list., 'FO'

say '0d0a'x||'Processing long file names'||'0d0a'x

do i=1 to list.0
    outfile = substr(list.i, lastpos('\',list.i)+1)
    fext = ''

    EA = outfile
    if pos('.', outfile) \= 0 then do
	fname = substr(outfile, 1, lastpos('.', outfile)-1)
	fext  = substr(outfile, lastpos('.', outfile))
    end
    else
	fname=outfile

    if pos('.', fname) \= 0 | length(fname) > 8 | length(fext) > 4 then do
        if length(fname) > 8 then do
            leng = length(fname) - 2
            fname = substr(fname,1,4)||'~'||substr(fname, leng)
        end
	fname=translate(fname, '_', '.')
        if length(fext) > 4 then do
            fext = substr(fext,1,4)
        end
	call check
        say '09'x left(fname||fext,12) ' <- ' outfile
        '@copy "'outfile'" "'fname||fext'" >nul 2>nul'
	call SysPutEA fname||fext, '.LONGNAME', "FDFF"x||d2c(length(EA))||"00"x||EA
	'@del "'outfile'" >nul 2>nul'
    end
end
exit

check: procedure expose fname fext

do while chars(fname||fext) \= 0
	fname = substr(fname, 1, length(fname)-1)||d2c(c2d(substr(fname,length(fname)))+1)
end
return