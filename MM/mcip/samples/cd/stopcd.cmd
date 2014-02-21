extproc mci

: stops asynchronous play. The play must have been
: started in the same OS/2 session.

: Note that if the OS/2 session is closed,
: the play is also stopped.

: Make sure, that you use the same device alias
: definition than in the script, that started the
: play (like playcd.cmd).

echo Play is being stopped
stop playcd wait
close playcd wait
