extproc mci

: locks door of CR-ROM drive


echo Locking door of CD-ROM drive
open cdaudio alias setcdstatus shareable wait
set setcdstatus door locked
close setcdstatus wait
