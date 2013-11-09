                     
		IceBerg V 2.00
		A REXX script for GTirc
		Written by Stephen Berg
		(C)1996 - Stephen Berg

Table of Contents

1.  Introduction

2.  Disclaimer

3.  Installation

4.  Usage

5.  Commands
    5a.  General Commands
    5b.  Shortened/enhanced versions of normal IRC commands
    5c.  Message logger commands
    5d.  Silly commands
    5e.  Accessible OS/2 commands
    5f.  Split Finder commands
    5g.  Access commands for OS2bot on EFNet
    5h.  Command notes
    5i.  Other Commands/Features

6.  Miscellaneous
    6a.  Start up commands
    6b.  IrcRexxWildCard

7.  New in version 2.00

8.  Future Plans

9.  Credits

10.  Contacts

*******************************************************
*                1.  Introduction:                    *
*******************************************************

	Thank you for looking at IceBerg.  This script was written with two
distinct goals in mind.  To customize and enhance the GTirc Internet Relay 
Chat client and to provide me with a learning tool for REXX programming.  
It has been ideal for both purposes.

	IceBerg is a first generation product.  While I did look at other 
UNIX based IRC scripts for ideas, the bulk of the IceBerg script is my own 
creation, with two exceptions.

	The message logging portion was written by someone else who went by 
the nick of "Wease", I've included some info about him in the credits 
section at the end of this document.  I've changed this portion to save the
messages to a file instead of memory.  This is so even in between GTirc 
sessions your log of messages will be saved.  It also solved one problem that
I had with the original code in previous versions of IceBerg.

	Armin Kunaschik contributed the original XDCC script.  I rewrote 
it to intergrate it a bit more smoothly with IceBerg but the original idea 
and code is his.

	I did get a couple of other ideas from various people in the
newsgroups and on IRC itself concerning the mechanics of the REXX code.  But 
the final code is mine.

	IceBerg is POSTCARD-ware.  That means it's free of charge, $0.00, 
here for the taking, up for grabs, or whatever you want to call it.  I 
do ask that if you're using it, drop me an E-Mail (Address is at the end 
of this document) and let me know what you think.

*******************************************************
*                2.  Disclaimer:                      *
*******************************************************

	(That silly legal stuff)

	OK, as I said in the Introduction section this script was written 
partly as a learning tool for me.  Which means I am in no way an expert 
in REXX.  The entire code is here for you to see, change, use or not use.  
I will *NOT* be held responsible if your machine blows up, if your 
Internet Provider disconnects you, if your significant other/wife/husband 
leaves you, if the IRS audits you or anything else bad happens to you by 
fault or not in this set of scripts.  That's why it's free.  And by using 
these scripts you fully and without reservation accept these terms.  If 
you don't accept, then don't run these scripts, it won't effect my paycheck 
either way.  =:-)

*******************************************************
*                3.  Installation:                    *
*******************************************************

	Well if you're reading this you've probably managed to un-zip the 
archive file.  Place at least the three main files in your GTirc 
subdirectory.  Next define the three files in the "Options" --> 
"Preferences" dialog of GTirc.  Startup Command would be 
"/run icestart.txt", "Input Message Script" would be IBergMsg.CMD and 
"Output Command Script" would be "IBergCmd.CMD".  That gets you up and 
running right away, no re-booting the machine, no re-loading GTirc, none 
of that nonsense.  You may want to issue a "/run icestart.txt" command to
set the variables in there that IceBerg uses in it's operation.  Aside
from that, once you click on the "OK" button you are ready to roll.  To 
use the autoop and XDCC feature you'll also need the "autoop.lst" and
"filelist.txt" files in the GTirc directory.

*******************************************************
*                     4.  Usage:                      *
*******************************************************

	Using IceBerg is simple, most of the commands are either shortened 
versions of the normal IRC commands, or command names that you may be used 
to from other IRC scripts.  I may have used a different name for a command 
from what you're used to.  Probably cause I haven't used the same scripts 
as you, =:-).  While running IceBerg you can type in "/icehelp", 
"/icehelp2" or "/msghelp" to view the help screens.  

	The "icestart.txt" file contains some commands to set up up flags
that IceBerg relys on for it's use.  Changing some of the "/iceberg ....." 
commands in this file will cause IceBerg to behave erratically, and I 
wouldn't suggest it.  You can change the default awaymsg by simply editing
the "icestart.txt" file.  Read the GTirc help on how to use text files and 
the "/RUN" command for further info.

	First thing I would suggest that you do once you have these
scripts loaded is to start GTirc, and run "/icehelp", "/icehelp2" and 
"/msghelp".  That will display some help screens on what commands are
available, their syntax and a brief description.

*******************************************************
*                    5.  Commands:                    *
*******************************************************

<XXXX> - means a required parameter
[XXXX] - means an optional parameter

    5a.  General Commands

/iceberg <setting> [value]		query the value of or change a 
					global GTirc REXX variable


/whom <nick>				Get VERSION & USERINFO about nick


/idle <nick>				Get idle time for nick


/icehelp				displays brief help statements for
					IceBerg commands (this is mostly 
					the functional, practical stuff)

/icehelp2				displays brief help statements for
					IceBerg commands not in /icehelp 

/msghelp				displays brief help statements for 
					the IceBerg message logging 
					functions

/dw <hostname|IP address>		does a who on the hostname or IP
					address, placing an "*" at the 
					beginning and end to do a wildcard 
					who on that domain

/wall <#channel> <text>			sends a msg to every visible 
					occupant of #channel
					(** See Note 1 **)

/wallop <#channel> <text>		sends a msg to every visible 
					channel op of #channel  
					(** See Note 1 **)

/xdccadv				Sends notices announcing the files
					you have made available via the XDCC
					function.  (** See Note 2**)

/cstat <#channel>			get and diplay statistics on the
					specified channel

    5b.  Shortened versions of normal IRC commands

/k <nick> [reason]			performs a kick on nick, with a reason
					if one is specified

/kb <#channel> <nick> [reason]		sets a ban for #channel against nick
					then kicks nick from #channel for reason

/j <#channel>				joins #channel

/q <nick>				starts a private query with <nick>

/lv [#channel]				leaves current channel or the 
					specified channel

/not <nick|#channel> <text>		notice the target nick or channel
					with text (see note 3)

/t [new topic]				sets the current channel's topic, 
					without arguments it will display 
					the topic

/wi <nick>				does a whois on nick

/ww <nick>				does a whowas on nick

/inv <nick>				invites nick to current channel

/cm [[+|-] modes]			adds or subtracts mode settings for 
					the current channel, with no 
					parameters it retrieves and 
					displays the current channels modes

/um <+|- modes>				changes your user modes


    5c.  Message logger commands

/reset					clears and resets the message 
					buffer (** See Note 2 **)

/play					displays the messages saved

/playlong				displays the messages saved showing 
					the message originators full address
					instead of just their nick

/msgchk					displays the current number of 
					messages stored in the buffer

/gone [away message]			marks you to being away with the 
					optional away message and turns 
					message logging on.  If no away 
					message is specified the default 
					"awaymsg" in "icestart.txt" is 
					used (see "/awaymsg")

/back					turns off message logging, displays 
					the messages in the buffer as if 
					/last had been run, and unmarks 
					you as being away

/awaymsg [away message]			checks or sets the default away 
					message

    5d.  Silly commands (I had to add a few of these!)

/crypt <text>				encrypt and send text to the 
					current channel.  Other GTirc users
					that have IceBerg will get an 
					automatic decryption of the text
					everyone else will most likely see
					junk.  (This is in *NO* way un-
					breakable code)

/revsay <text string>			reverses the text string and sends 
					it to the current channel or query

/revmsg <nick> <text string>		same as /revsay, but in a msg to 
					nick

/revme <text string>			once again, but sends it as a /me
					command to the current channel or 
					query


    5e.  Accessible OS/2 commands

/nsl <hostname|IP address>		runs an "NSLOOKUP" command on the
					hostname or IP, and returns the
					result to the GTirc window

/host <hostname|IP address>		runs a "HOST" command on the
					hostname or IP, and returns the 
					result to the GTirc window

/osping <hostname|IP address>		runs a "PING" command to the
					hostname or IP, (using two, 25 
					byte packets) and returns the 
					result to the GTirc window

/ossend <command>			runs command and sends the result
					to the current channel or query
					this does ignore any blank lines 
					when it sends the results to the
					channel  (see note 4)

/osmsg <nick> <command>			same as /ossend but sends the 
					results to nick in a /msg

/exec <command>				runs an OS/2 command and returns 
					the result to the GTirc window

    5f.  Split Finder commands

/getservers				get a listing of all currently
					present servers from your current
					server.  This does not need to be
					run each time you want to find any
					split servers, IceBerg saves this
					file and updates it when you run
					the /findsplit or /addnew command 
					(see note 5a)

/findsplit				gets a listing of all currently
					present servers, then compares
					that to "servers.lst" to find any
					split servers and displays the
					split servers in the control
					window  (see note 5b)

/addnew					find and add any servers currently
					listed in the "current.lst" file, 
					generated by /findsplit, that do 
					not appear in "servers.lst" to 
					"servers.lst" and displays those 
					new servers in the control
					window  (see note 5b)

    5g.  Access commands to OS2bot on EFNet

/calc <string>				send a calc message to OS2Bot on
					#OS/2 (EFNet) the string will be
					evaluated for a value and the value
					will be returned.  
					(Try "/calc ssgt" or "/calc ibm")

/phone <string>				send a message to OS2Bot on #OS/2
					(EFNet) the string will be
					evaluated for a value and the value
					will be returned.  This does lookups
					of phone numbers for companies 
					involved with OS/2
					(Try "/phone novastor" or "/phone ibm")

 
    5h.  Command notes

(Note 1) - The /wall and /wallop commands may be used from inside or outside 
a channel.  When outside a channel it will not be able to see any users 
that have set the (+i, or invisible) mode for themselves.  Abuse of these 
commands will usually get you kicked and/or banned from channels.  Excessive 
abuse may get you K-lined from servers.

**  You've been warned, so don't blame me when you get banned from a  **
**  channel or K-lined from a server.                                 **

(Note 2) - This is another thing that can be obnoxious if abused depending
on the channel you happen to be in.  And if you have a large number of files 
offered, it could possibly get you disconnected by your server due to the 
fact that it may mistake the output as a flood.

(Note 3) - The /NOT command is not a short version of /NOTIFY.  This is
just a version of the /notice command.  The /NOTICE command is not supported 
in GTirc at this time.  Incoming notices from other users are handled as 
private messages.  I have tried to fix this, but it tends to mess up other 
functions in GTirc, so I left it alone.

(Note 4) - This can generate quite a bit of text to be sent to the channel 
or query one line at a time depending on the command you are issuing.  It 
can cause you to be kicked from channels, and possibly disconnected from 
your server due to excess flooding being detected.  If you're unsure how 
much data is going to be returned, run the command using the "/exec" 
command first since that displays the result only to you.

(Note 5a) - Only run "/getservers" if your "servers.lst" has become 
corrupted or lost.  I have included the "servers.lst" that I have with the 
IceBerg distribution.  If you're running this on UnderNet it won't be of 
much help to you, since it lists EFNet servers.  I'm currently thinking 
about how to support multiple nets with this function.  

(Note 5b) - Running "/findsplit" will show you any servers in "servers.lst" 
that do not appear on the net at that time.  It will then run "/addnew" 
which will find any new servers that do not appear in "servers.lst", it 
will display the servers name and add it to the "servers.lst" file.

    5i.  Other Commands/Features

Auto-Op:  By setting the Auto-Op feature using "/iceberg autoop on", you
will enable the Auto-Op feature in IceBerg.  Auto-Op uses the file,
"autoop.lst" as a list of people you wish to automatically give ops to in 
particular channels.  Each line in this file represents one user and one 
channel.  (An example is included with IceBerg.)

XDCC:  I've included a sample file "filelist.txt" that the XDCC feature
uses to determine what files are available to the rest of the IRC world.
The syntax is very simple, "filename description".  Filename can be a
fully qualified pathname, and description can be any string of words but 
they both *MUST* be on one line for things to work properly.

*******************************************************
*                  6.  Miscellaneous                  *
*******************************************************

    6a.  Start up commands

	I'm working on a scheme to set up an initial set of start up 
commands instead of using the "icestart.txt" file.  This is due to the fact
that GTirc runs any defined Startup Command any time you connect to a
server, instead of just at the initial program start.

    6b.  IrcRexxWildCard

	I finally figured out how to utilize the IrcRexxWildCard() function
that GTirc provides.  It is used in the autoop feature.  Basically if you
are familiar with wildcard use in the IRC environment for user@host.com 
matching, it provides that whereas doing it in REXX is difficult and somewhat
slow.  I'm gonna look into my scripts a bit more closely on possibly making
better use of this feature.

	For the autoop.lst file to properly match a user, the user entry
must be properly formatted.  (Ex:  "*sberg@*.southwind.com")  IceBerg
uses this to match against the JOIN message.  If it matches and the channel
matches, then a mode +o for the user is sent.  Note:  It won't work too
well if you're not opped yourself.  =:-)

*******************************************************
*                7.  New in Version 2.00              *
*******************************************************

	This version adds support for XDCC functions.  Credits to Armin 
Kunaschik for the code.  Basically a listing of files that you wish to make 
available to anyone is contained in a text file, people can then message 
you with XDCC requests.  These requests can be to list the available files, 
send a particular file or to send help on the XDCC function.  Also an 
/xdccadv command is added to advertise that you have XDCC capability and 
what files are available.

	The autoop feature now makes use of GTirc's IrcRexxWildCard 
matching feature.  So if you have people you wish to autoop that are on a
dynamic IP address/hostname it is much easier to set up now.

	Added in a /phone command to get company phone numbers from OS2Bot
on EFNet.

	Changed the message logger feature to utilize file storage of the 
messages instead of memory.  This makes your message log survive even if 
you shut down and restart GTirc and also fixed the problem of initializing
the logger at startup in version 1.10.  Changed the "/last" to "/play" for 
playback of the stored messages.  Added a "/playlong" to playback the messages
but display the full user id of whoever sent the message instead of just a
nickname.

	A simple kick command is replacing the joke kicks from previous 
versions.  

	A kickban routine is now implemented for banning and then kicking a
user from a channel.  Syntax for /kb is:    "/kb <#channel> <nick> [reason]"

	A "/q" command for quick starting a query with another user.

	Some of the CTCP responses were replying to the requestor with a
private message.  These should be done with a notice according to RFC1459.  
I have added in support for CTCP responses using my "/not" command to 
accomplish this.  If you are concerned with complying with RFC1459, do not
define any CTCP Options in GTirc.  Change the "*resp" strings in my 
ibergmsg.cmd script to personalize the ones that I handle.  Leave the
beginning and ending smiley face characters as they are, this how GTirc and
other IRC clients identify CTCP messages.  My script handles them, and then 
passes them on to GTirc, so if you do define CTCP Options this problem will 
appear.  (NOTE:  It probably won't hurt if you do but it is possible to get 
stuck in a loop with someone elses script if these features are used.)

The CTCP USERINFO option does not show this undesired behavior regardless 
of whether or not you have a CTCP Option defined so I left it alone.

*******************************************************
*                   8.  Future Plans:                 *
*******************************************************

	I have a few more ideas that I need some time to work out the REXX
code for that I plan to add into IceBerg.  I have heard that there is a 
planned release sometime around spring 96 of GTirc V2.00.  From what I have
heard (take that with a grain of salt) that there will be some changes
that may effect how the REXX scripts need to be written.  Hopefully it'll
be simple changes that I can implement easily.

	If you have any ideas that you would like to see implemented in 
IceBerg send me an E-mail and I'll definitely look into it.  

	Right now I'm gonna stop developing IceBerg until I get GTirc 2.00
installed and running and can see what (if any) changes in these scripts
will be necessary.

*******************************************************
*                     9.  Credits:                    *
*******************************************************

Message logger - 
	Greg Spath  (Wease on the IRC)
	gspath@epix.net

	his web page is:
	http://www.epix.net/~gspath

XDCC code - 
	Armin Kunaschik <Armin.Kunaschik@e-technik.tu-chemnitz.de>

General Ideas and his constant bugging me to get it done -
	Profx on IRC in #os/2 (author of Intercom for OS/2)
		http://revsoft2.is.net/ic/intercom.html

General REXX advice -
	RajV on IRC in #os/2
	Topham on IRC in #os/2
	Lots of others on IRC
	Quite a few people on Usenet in comp.lang.rexx
	Quite a few people on various REXX mailing lists

                *******************************
                *   !! THANKS TO YOU ALL !!   *
                *******************************

*******************************************************
*                  10.  Contacts                      *
*******************************************************

	I can be found on IRC usually on EFNet using "SSgt" as a nick.  
For E-Mail, sberg@southwind.com works.

	If you have suggestions *please* E-Mail them to me, that way I can 
keep an archive on what suggestions I've looked at/worked on/added in, and 
I can also keep track of who suggested what.

