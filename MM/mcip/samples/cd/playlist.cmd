extproc mci
: plays a list of tracks syncronously

: The special MCIP command GOTO lets all specified tracks
: being repeated forever (until you press Ctrl-Break twice)

echo Playing track 3 and track 4 forever
echo Press Ctrl-Break twice to exit ...
open cdaudio alias playcd shareable wait
:playtrack
playtrack playcd 3 wait
playtrack playcd 4 wait
goto playtrack
close playcd wait
