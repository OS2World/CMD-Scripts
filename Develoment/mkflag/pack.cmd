/* package cube */
/*"@echo off"*/
prg = "mkflag"
src = directory(".")
curpath = directory("package")
dest = curpath"\"prg
publish = left(curpath,3) || "pub_html\"prg /* my local web page mirror */

"dir /b" curpath'\'Prg"*.txt > name"
parse value linein("name") with pkg ".txt"
call stream "name", "c", "close"
say "src=" src "dest=" dest "curpath=" curpath "publish=" publish "packing" pkg

call pack "bin\*.cmd"
call pack "*"
"copy ..\f*.diz *"
"dir /b /s" curpath ">dir"

del "/n *.zip"
address cmd "zip -mr" pkg prg"\*"
address cmd "zip -m" pkg "*.diz"

/*
"del /n" publish"\*"
copy pkg".zip" publish
copy src"\doc\*.css" publish
copy src"\doc\*.html" publish

copy  src"\doc\*.txt" curpath
*/

say "enter 2hobbes in directory" curpath "and run sitecopy"
exit 0


pack:  procedure expose src dest
    parse arg from, to
    if to="" then to = from
    xcopy src'\'from  dest'\'to
    return

