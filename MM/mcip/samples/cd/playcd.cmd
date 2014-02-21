extproc mci

: plays a cd asyncronously (does not wait)

: Play can be stopped with stopcd.cmd being called
: in the same OS/2 session or by closing the OS/2
: session.

echo Playing entire CD from start.
echo Call stop.cmd or close OS/2 session to stop play
open cdaudio alias playcd shareable wait
play playcd
