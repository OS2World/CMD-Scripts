extproc mci

: plays a cd syncronously (wait option on play command)

: Play can be interrupted by pressing Ctrl-Break twice
: or by closing the OS/2 session.

echo Playing entire CD from start and wait for end of play
open cdaudio alias playcd shareable wait
echo Press Ctrl-Break twice to exit ...
play playcd wait
close playcd
