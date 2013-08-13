/* .crk files description generator by cygnus, 2:463/62.32 */

call RxFuncAdd 'SysFileTree', 'Rexxutil', 'SysFileTree'

call SysFileTree '*.crk', 'list', 'FO'
say 'Found 'list.0 'crk files'

if list.0 \= 0 then do
    percent = list.0%50+1
    '@del cracks.lst 2>nul'

    rc = LineOut('cracks.lst', list.0 '.crk files. Descriptions:'||'0d0a'x||'----------------------------------------'||'0d0a'x||'')
    call charout , 'Creating cracks.lst '

    do i = 1 to list.0
        if i // percent = 0 then rc = charout(,'±')
        inp = LineIn(list.i)
        rc = CharOut(cracks.lst, format(i,4) right(delstr(list.i,1,length(directory())+1),12) '-' inp||'0d0a'x)
        rc = LineOut(list.i)
    end
end
exit