extproc mci

: determines wether the CD-ROM drive is ready or not

: Make sure that you always use the wait option
: on status commands, otherwise the return value
: is not available

open cdaudio alias querycdstatus shareable wait
echo Querying wether CD-ROM drive is ready:^
status querycdstatus ready wait
close querycdstatus wait
