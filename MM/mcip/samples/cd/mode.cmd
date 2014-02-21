extproc mci

: determines the current mode of the CD-ROM drive

: If your CD-ROM always reports "stopped",
: the device is not well shared by the driver.
: Then the driver always stops playing and
: recording when a STATUS or SET command is
: executed, and resumes operation afterwards.

: Make sure that you always use the wait option
: on status commands, otherwise the return value
: is not available

open cdaudio alias querycdstatus shareable wait
echo Querying current mode of CD-ROM:^
status querycdstatus mode wait
close querycdstatus wait
