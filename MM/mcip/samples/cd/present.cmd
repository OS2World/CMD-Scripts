extproc mci

: determines wether a cd is inserted or not

: Make sure that you always use the wait option
: on status commands, otherwise the return value
: is not available

open cdaudio alias querycdstatus shareable wait
echo Querying wether a CD is inserted:^
status querycdstatus media present wait
close querycdstatus wait
