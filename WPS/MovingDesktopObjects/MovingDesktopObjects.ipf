:userdoc.
:docprof toc=123.
:title.Workaround for moved desktop objects at startup
:h1 id=1 clear.1  Description of the bug
:p.
After system restart all desktop objects moved by the height of the
toolbar. For a toolbar at the top of the desktop the objects move
upwards. For a toolbar at the bottom they move downwards.
:p.
It happens with all toolbars that :hp2.reduce the workplace area:ehp2.. That means
that not only XWorkplace's XCenter (or eCenter) is affected, but also
Warp 4's WarpCenter (or SmartCenter).
:p.
I can remember that Ulrich M”ller wrote that it's an old IBM bug.
:h1 id=2 x=0% y=0% width=30% height=100% clear.2  Steps to get rid of it - at least for some time
:p.
:link reftype=hd auto viewport dependent refid=3.
Unfortunately, the described mechanism is just a workaround and has
to be repeated from time to time.
:p.
Select one of the required steps&colon.
:ul compact.
:li.:link reftype=hd viewport dependent refid=3.Run the included .cmd file:elink.
:li.:link reftype=hd viewport dependent refid=4.Move the objects back by using the vertical scroll bar:elink.
:eul.
:h2 id=3 x=30% y=0% width=70% height=100%.2.1  Run the included .cmd file
:p.
That step is easy. Just run the included .cmd file
:hp2.RmDesktopFolderPos.cmd:ehp2. and you're done.
It removes an erranous entry in OS2.INI for the desktop in icon
view. I have tested it for some months now and had no side effects.
:p.
The script gets the object handle for :hp2.<WP_DESKTOP>:ehp2.. Therefore it
looks up in the ini application :hp2.PM_Workplace&colon.Location:ehp2.. After that,
the entry for the :hp2.icon view:ehp2. of the decimal object handle is removed
from :hp2.PM_Workplace&colon.FolderPos:ehp2..
:xmp.
Syntax&colon. RmDesktopFolderPos [RUN] [QUIET]

        Options (not case-sensitive)&colon.
           RUN    don't ask at startup, only error messages
           QUIET  no output messages, check RC for the result
:exmp.
:h2 id=4 x=30% y=0% width=70% height=100%.2.2  Move the objects back by using the vertical scroll bar
:p.
This step can not be automated. You have to move all objects back.
It's not required to grab every object separately&colon.
:ol.
:li.If the vertical scroll bar at the right edge of the desktop is not
shown&colon. Move one of the desktop objects upwards (for XCenter at the
top) until the vertical scroll bar appears.
:li.Then scroll it until it disappears.
:li.Maybe repeat the movement of that desktop object and the scrolling
until all other objects are on the right place again.
:li.After that, move that object back to its correct place.
:eol.
:h1 id=5 x=0% y=0% width=30% height=100% clear.3  Appendix
:p.
:link reftype=hd auto viewport dependent refid=6.
Select one of the following topics&colon.
:ul compact.
:li.:link reftype=hd viewport dependent refid=6.Author:elink.
:li.:link reftype=hd viewport dependent refid=7.Copyright and license:elink.
:li.:link reftype=hd viewport dependent refid=8.Credits:elink.
:li.:link reftype=hd viewport dependent refid=9.Related bug reports in the eCS bugtracker:elink.
:eul.
:h2 id=6 x=30% y=0% width=70% height=100%.3.1  Author
:p.
Andreas Schnellbacher
:p.
:artwork name='..\BIN\bmp\nsmail.bmp' runin.
:artlink.
:link reftype=launch object='nEtScApE.eXe' data='mailto:andreas.schnellbacher@web.de'.
:eartlink.
:link reftype=launch object='nEtScApE.eXe' data='mailto:andreas.schnellbacher@web.de'.andreas.schnellbacher@web.de:elink.
:h2 id=7 x=30% y=0% width=70% height=100%.3.2  Copyright and license
:p.
This package is freeware and comes with no license. A copyright on the
simple REXX script is not intended.
:h2 id=8 x=30% y=0% width=70% height=100%.3.3  Credits
:ul.
:li.Rich Walsh for explaining the PM_Workplace&colon.FolderPos details.
:li.Paul Ratcliffe for the hint that it sometimes suffices to move all
(or the right) desktop object a bit.
:li.Doug Bisset for pointing to PM_Workplace&colon.FolderPos and mentioning
that removing the icon view entry suffices.
:eul.
:h2 id=9 x=30% y=0% width=70% height=100%.3.4  Related bug reports in the eCS bugtracker
:p.
You have to login on with your eCS account first.
:ul.
:li.
:artwork name='..\BIN\bmp\ns.bmp' runin.
:artlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=2164'.
:eartlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=2164'.http&colon.//bugs.ecomstation.nl/view.php?id=2164:elink.
:li.
:artwork name='..\BIN\bmp\ns.bmp' runin.
:artlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=2143'.
:eartlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=2143'.http&colon.//bugs.ecomstation.nl/view.php?id=2143:elink.
:li.
:artwork name='..\BIN\bmp\ns.bmp' runin.
:artlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=3559'.
:eartlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=3559'.http&colon.//bugs.ecomstation.nl/view.php?id=3559:elink.
:li.
:artwork name='..\BIN\bmp\ns.bmp' runin.
:artlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=2533'.
:eartlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=2533'.http&colon.//bugs.ecomstation.nl/view.php?id=2533:elink.
:li.
:artwork name='..\BIN\bmp\ns.bmp' runin.
:artlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=2330'.
:eartlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=2330'.http&colon.//bugs.ecomstation.nl/view.php?id=2330:elink.
:li.
:artwork name='..\BIN\bmp\ns.bmp' runin.
:artlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=1620'.
:eartlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=1620'.http&colon.//bugs.ecomstation.nl/view.php?id=1620:elink.
:li.
:artwork name='..\BIN\bmp\ns.bmp' runin.
:artlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=491'.
:eartlink.
:link reftype=launch object='nEtScApE.eXe' data='http://bugs.ecomstation.nl/view.php?id=491'.http&colon.//bugs.ecomstation.nl/view.php?id=491:elink.
:eul.
:euserdoc.
