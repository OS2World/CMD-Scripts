extproc mci

: plays a track asyncronously by using the special MCIP
: command PLAYTRACK

: Play can be stopped with stopcd.cmd being called
: in the same OS/2 session or by closing the OS/2
: session.

: You can also play the track synchronously by
: - using the wait option on playtrack command (seeplaycdw.cmd)
: - using the special MCIP command PAUSE (see playcdp.cmd

echo Playing track 3
echo Call stop.cmd or close OS/2 session to stop play
open cdaudio alias playcd shareable wait
playtrack playcd 3
