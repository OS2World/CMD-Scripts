extproc mci

: unlocks door of CR-ROM drive

echo Unlocking door of CD-ROM drive
open cdaudio alias setcdstatus shareable wait
set setcdstatus door unlocked
close setcdstatus wait
