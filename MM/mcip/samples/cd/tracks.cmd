extproc mci

: queries the count of audio tracks

: Make sure that you always use the wait option
: on status commands, otherwise the return value
: is not available

open cdaudio alias querycdstatus shareable wait
ECHO Querying the number of audio tracks:^
status querycdstatus number of tracks wait
close querycdstatus wait
