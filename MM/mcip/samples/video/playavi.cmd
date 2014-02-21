extproc mcipm

: plays an avi file asyncronously
: Note, that this must be done in a PM session

: Play can be stopped with closing PM Rexx.

echo Playing video file
open digitalvideo alias playavi shareable wait
load playavi %MCI_MMPMDIR%\MOVIES\MACAW.AVI wait
play playavi wait
close playavi wait
