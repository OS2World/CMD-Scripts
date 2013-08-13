/* .mp3 files header extractor (PCDOS 7.0 REXX) */

temp='C:\TEMP\'
out='C:\MP3\'

i = 0

parse arg fname .

if strip(fname) \= '' then do

    'cls'
    call lineout , '[32mGetting files list...[0;0;0m'
    'dir *.mp3 |grep -i "mp3   " >' temp||'MP3list.tmp'

    do 1
        call linein temp||'MP3list.tmp'
    end

    do while lines(temp||'MP3list.tmp') = 1
        i=i+1
        parse value linein(temp||'MP3list.tmp') with mpname.i ext size.i '.'rest
        size.i=space(subword(size.i, 1, words(size.i)-1),0)
    end

    max=i
    call lineout , '[32mTotal number of .mp3 files:[36;1m' max '[0;0;0m'
    call charout , '[32mCreating list file[36;1m' out||fname||'[0;0;0m[32m:[0;0;0m '

    do i=1 to max
        name.i=charin(mpname.i||'.mp3', size.i-124, 123)
        name.i=translate(name.i,'2020'x, 'FF00'x)
        call lineout out||fname, strip(left(mpname.i||'.mp3', 12)||'09'x||name.i)
        call charout ,'þ'
        call lineout(mpname.i||'.mp3')
    end
end
else
    say 'Please, enter list_file_name'
