SLIP HomeWork (Oct 1, 1995)
-------------

Bruce Clarke (Bruce.Clarke@UAlberta.CA)

This package is freeware. Anyone may use it, copy it, and modify it.
Please send me a copy if you make improvements.

The text files included are:

SLIPHW.TXT   - the main docs. Read this first.
CONFIG.TXT   - how to configure this for your IP addresses, etc
COMSETUP.TXT - tips for beginners on getting a serial port working
NETSETUP.TXT - about routing and configuring TCP/IP interfaces.

What you need to use this package
=================================

Home PC
-------
with modem and phone line, running Warp (Warp for Win or Fullpack or Connect).
OS/2 2.1 is OK if you have IBM's TCP/IP package.

Work PC 
-------
with modem and phone line, preferably on the Internet. In that case Warp isn't
sufficient because Warps IAK cannot handle a networking card. The best option
is Warp Connect. You can also use OS/2 2.1 provided you have installed IBM's
TCP/IP 2.0 and the CSD's from August 1994.

Laptop PC (optional)
---------
Same requirements as home PC.

IP Addresses
----------
The network administrator for your office network has to give you an IP address
for the machine you use at home. In addition, you need to know about an unused
IP address on your work subnetwork which you can use.


How to Install
==============

(1) Unzip everything into \SLIPHW

(2) At the top of each *.CMD file there are variables that have to be
adjusted with suitable phone numbers, IP addresses, etc. See SLIPHW.TXT
and CONFIG.TXT for detailed instructions on configuring these parameters.
Zip up these personalized copies and move one to \SLIPHW on the home machine,
and one to \SLIPHW on the work machine.

(3) On each machine start in the \SLIPHW directory and copy files:
    On work machine: copy work*.cmd \TCPIP\BIN
		     copy work*.cfg \TCPIP\ETC
		     copy autonetw.cmd \TCPIP\BIN
    On home machine: copy home*.cmd \TCPIP\BIN
		     copy home*.cfg \TCPIP\ETC
		     copy autoneth.cmd \TCPIP\BIN

(4) Set up desktop objects you can click on or put in your Startup folder.
    On work machine. create a program reference object that runs WorkServ.cmd
		     create a prm that runs Work2Hom.CMD
    On home machine  create a prm that runs HomeServ.CMD
		     create a prm that runs Home2Wrk.CMD

(5) Test as follows. Start HomeServ on the home machine, and then run
    Work2Hom on the work machine. They should connect. Then start WorkServ
    on the work machine, and run Home2Wrk on the home machine. They should
    connect.

(6) After each connection test with ping. Test daemons (ftp, www...)

(7) Set up CRONRGF (freeware) on the Home machine
    Copy CRONTAB.HW to the CRON directory. Start CRON with this command:

    cronrgf crontab.hw

    The home machine should log into the work machine every 10 minutes and
    update the system clock.
    Change crontab.hw to do something more useful.
