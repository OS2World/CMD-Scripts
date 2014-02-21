extproc mcipm

: plays a fli file asyncronously
: Note, that this must be done in a PM session

: Play can be stopped with closing PM Rexx.

echo Playing video file
open digitalvideo alias playfli shareable wait
load playfli %MCI_BOOTDRIVE%\OS2\APPS\MAHJONGG.FLC wait
play playfli wait
close playfli wait
