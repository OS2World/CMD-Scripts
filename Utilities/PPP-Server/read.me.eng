                              REXX PPP-Server
                              ---------------

This is a REXX script to serve incoming calls for the multiple modems.
Main program is a PPPServ.cmd. PPPServ.cmd calls him self two times for any
attached modems.

Samples of configuration files are placed in the ETC directory of archive.
Server's configuration is in the dialin.cfg file which has to be placed to your
%ETC% directory. Configs for the PPP has to be called %ETC%\ppp-com1\ppp.cfg,
%ETC%\ppp-com2\ppp.cfg, and so on for the 1-st, 2-nd, and e.t.c ports
accordingly.

Secrets must placed at %ETC%\ppp.usr

	Time access control
	-------------------

There are two ways to control the access time: via ports, or via client's
IP-address.

Control by ports:

In this case, when next call is occured at time out of time access list for
the selected COM-port, modem won't accept this call.
Time access list is stored in the configuration files of PPP-driver
%ETC%\ppp-comN.cfg (N - port number). Each line describing access time has
format of:

#$ day_of_week begin_time-end_time

where:

'#$' - prefix
day_of_week - first 3 letters of weekday or "ANY" for all weekdays
begin_time - period begin time in format HH:MM
end_time - period end time in format HH:MM

If there are no '$#' lines (list is empty) modem will accept calls at any time.
begin_time cannot be less than end_time.

Control by IP-address of client:

In this case user has to be authorised first and, after assigning IP-address
to him, the time access list is checked. If there is no accepted time period
found PPP-driver is stopped and modem is hungup. Time access list is stored
in the file %ETC%\ppp-time.cfg.

Each line describing time access has format of:

ALLOW/DENY port ip-address : day_of_week begin_period - end_period

where:

ALLOW or DENY - rule's type
port - COM-port (com1, com2, ...) or "ANY" for all COM-ports
ip-address - assigned IP-address or "ANY" for all addresses
day_of_week - first 3 letters of weekday or "ANY" for all weekdays
begin_time - period begin time in format HH:MM
end_time - period end time in format HH:MM

Empty lines and lines beginning with "#" character are ignored.
If there are no lines or if there is no %ETC%\ppp-time.cfg file all authorised
users are accepted at any time.
begin_time cannot be less than end_time.

	Notes
        -----

  - The PPP.EXE version 1.18b is required;
  - After a lot of troubles with proxyarp parameter I have decided to decline
from one.

	Contacts
        --------

Andrey Vasilkin
E-Mail: digi@os2.snc.ru
WWW: http://digi.os2.snc.ru
IRC: eCSNet, #common, #eCS channels. Nickname - Digi
