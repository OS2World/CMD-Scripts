/* .mp3 files header extractor (OS/2 REXX) */

out='g:\t\'

parse arg fname .

if strip(fname) \= '' then do

    rc = RxFuncAdd("SysFileTree","rexxutil","SysFileTree")

    call lineout , '[32mGetting .mp3 files list...[0;0;0m'
    call SysFileTree '*.mp3', 'mpfiles', 'F'

    do i=1 to mpfiles.0
        parse value strip(mpfiles.i) with skip skip size.i skip mpname.i
        mpname.i=substr(mpname.i, lastpos('\',mpname.i)+1)
    end

    call lineout , '[32mTotal number of .mp3 files:[36;1m' mpfiles.0 '[0;0;0m'
    call charout , '[32mCreating list file[36;1m' out||fname||'[0;0;0m[32m:[0;0;0m '

    do i=1 to mpfiles.0
        name.i=charin(mpname.i, size.i-124, 123)
        name.i=translate(name.i,'2020'x, 'FF00'x)
        call lineout out||fname, strip(mpname.i '   ' strip(name.i))
        call lineout(mpname.i)
        call charout ,'þ'
    end
end
else
    say 'Please, enter list_file_name'
