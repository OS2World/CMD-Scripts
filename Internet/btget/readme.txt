README.TXT FOR BT_GET
V1.02

  BT_GET is a REXX script designed to simplify using BitTorrent under OS/2.


WHAT IS BITTORRENT?

  If you're trying to use this package, I'm assuming that you already know what
  BitTorrent is.  In brief, it's a protocol for distributed file downloads.  For
  more information, see the official website:  http://www.bittorrent.com

  BitTorrent is also the name of the original software program that implements
  this protocol.  It is written in Python, so it works under OS/2 as long as you
  have Python/2 installed (see instructions below).


WHAT DOES BT_GET DO?

  BT_GET simplifies the invocation of BitTorrent by setting up some necessary
  environment variables before calling the BitTorrent client to download a file
| (mainly so that you don't have modify CONFIG.SYS with all the Python/2 path 
| and environment settings.)  It also shields you to some extent from 
  BitTorrent's awkward command syntax.


REQUIREMENTS

  BT_GET requires the following:

|  * One of the following versions of OS/2:
|      - OS/2 Warp 3 (including Warp Connect & Warp Server 4), with FixPak 
|        35 or later
|      - OS/2 Warp 4 with FixPak 6 or later
|      - OS/2 Warp Server for e-business
|      - OS/2 Convenience Package (any version)
|      - eComStation (any version)

   * MPTS (I recommend version 5.3/WR*8600 or later) with a working Internet
     connection.

   * A web browser that supports external helper applications (almost all do).

   * The official BitTorrent implementation (Python source package) version
     3.4.2, available here:
     http://prdownloads.sourceforge.net/bittorrent/BitTorrent-3.4.2.zip?download


|    NOTE: Version 4.x of the BitTorrent client is not supported.  (With some
|          changes to the calling syntax used within BT_GET.CMD, version 4.0x
|          can be made to work, although it pegs the CPU at 100% and hangs if
|          you try to download more than one file at a time.  Later versions
|          don't seem to work at all.)


   * A recent version of the OS/2 Python package.  The latest version should be
     available here:  http://www.pcug.org.au/~andymac/python.html


     NOTE: I've had some trouble getting BitTorrent to work with Python 2.4, so
|          I recommend staying with version 2.3.5 for the time being.


   * The EMX runtime libraries.  Most OS/2 users probably have this installed
     already; if not, they are available on Hobbes (search for EMXRT.ZIP).


   * A file system which supports long filenames (HPFS, JFS, FAT32, etc.).


INSTALLATION

  1. Unzip the Python/2 distribution to a directory of your choice.  If you'll
     only be using Python for BitTorrent, you do NOT need to modify CONFIG.SYS
     or take any further steps to install Python.  BT_GET will take care of the
     rest.

  2. Unzip the BitTorrent source distribution to a directory of your choice.

| 3. Install BT_GET.CMD by copying it to a suitable directory, preferably one
|    on your PATH.


     IMPORTANT:  You must edit the BT_GET script and define some variables
                 which are located at the top of the file:

                 pythdir    Name of the directory where you unzipped Python.
                 btdir      Name of the directory where you unzipped the 
                            BitTorrent files.
                 savedir    Name of the directory where you want downloaded 
                            files to be saved to.

                 All directory names must be fully-qualified paths.  

|                **** BT_GET will NOT work until you have done this. ****


|    OPTIONAL:   There are three other variables that you may want to modify, 
|                listed below the others previous three (near the top of the
|                file).  
|
|                uploadspeed   The maximum upload speed (in KB/s) to allow when 
|                              sending data to other computers.  (If you're on 
|                              dial-up, you probably want to set this fairly 
|                              low.)  BT_GET.CMD sets this to 50 by default.
|
|                 minport      The first IP port to listen on.  If this is busy,
|                              BitTorrent will search for the next available IP
|                              port, up to the 'maxport' setting (see next).
|                              BT_GET.CMD sets this to 6881 by default.
|
|                 maxport      The last IP port to listen on.  BT_GET.CMD sets 
|                              this to 6999 by default.
|
|                 All IP ports in the range [minport] to [maxport] must be open
|                 to the outside world, or BitTorrent's performance will be
|                 severely curtailed (refer to step 5, below).


  4. Go into your web browser configuration and add a new MIME type (the precise
     steps required depends on your browser) as follows:

       MIME Type:    application/x-bittorrent
       Description:  BitTorrent
       Extension:    torrent
|      Action:       Open it with (fully-qualified name of BT_GET.CMD)

  5. If you have a firewall or a broadband router that does NAT, make sure it
|    allows or forwards incoming TCP connections on the entire IP port range
|    used by BitTorrent (as configured by the 'minport' and 'maxport' variables,
|    above); this is 6881 to 6999 by default.

     (If these ports are blocked, BitTorrent will download but not upload.
     Since BitTorrent uses a 'tit-for-tat' sharing system for transferring
     files, this will cause your download speeds to be extremely slow.)


USING BITTORRENT

  If you set everything up correctly, BitTorrent should now work.  Just click
  on a .torrent link in your web browser, and BitTorrent should start
  transferring the file.


FOR ADVANCED USERS

  Feel free to modify the REXX code as much you like to suit your own 
  environment.  If you want to change the way BitTorrent itself is invoked
  (for instance, to specify additional parameters), you can update the line
  that calls 'python btdownloadcurses.py' (around line 103).

  The file BT_ARGS.TXT contains a list of the command-line arguments 
  supported by version 3.4.2 of the BitTorrent client.


MORE INFORMATION

  I wrote an article for OS/2 VOICE which describes BitTorrent and BT_GET in
  more detail than I have included here.  The article is available on the WWW at:
  http://www.os2voice.org/VNL/past_issues/VNL0704H/vnewsf4.htm


NOTICES

  BT_GET was originally inspired by a Usenet posting from dink.  I have modified
  the procedure extensively from the one he described; it is now considerably
  more flexible and user-friendly.

  BT_GET was first published in an article appearing in the July 2004 edition
  of OS/2 VOICE.  The version included here has been updated somewhat.

  BT_GET is public domain software.


--
(C) 2006 Alex Taylor - http://www.cs-club.org/~alex
alextaylor41[at]rogers[dot]com
