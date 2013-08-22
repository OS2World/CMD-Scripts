Version 1.0, November 3, 2002

This REXX script, TZCRON.CMD, will add itself to the crontab to be scheduled
at the next switch between standard and daylight savings time, and when
called at the right minute of such a switch, will change system time
including the time zone offset accordingly.

More documentation in the CMD file itself.

Requires two or three changes to the script's text to run.

A problem which was not mentioned in the script, is that CRON might refuse
to accept the new crontab entry for being "busy". You may then simply call
the program again manually. I try to find a remedy for this without
entering into an endless loop.

lueko.willms@t-online.de


