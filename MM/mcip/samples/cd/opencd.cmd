extproc mci

: opens the door of CR-ROM drive

: note that not all drivers support the
: "set <device> door closed" command.

echo Opening door of CD-ROM drive
open cdaudio alias setcdstatus shareable wait
set setcdstatus door open
close setcdstatus wait
