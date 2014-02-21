extproc mci

: plays a cd asyncronously, but waits for user to press
: a key by using the special MCIP command PAUSE

: Useful, if you create icons on the WPS for to play a CD,
: because the OS/2 session stays open, even when the play
: has stopped

echo Playing entire CD from start and wait for keystroke
open cdaudio alias playcd shareable wait
play playcd
pause Press any key to end...
close playcd
