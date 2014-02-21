extproc mci

: determines the volume

: Make sure that you always use the wait option
: on status commands, otherwise the return value
: is not available

open cdaudio alias querycdstatus shareable wait
echo Querying current colume (left:right):^
status querycdstatus volume wait
close querycdstatus wait
