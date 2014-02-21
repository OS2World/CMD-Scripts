
  RxShout

RxShout is a source client for a streaming server, clone of original shout
utility (with some additional features). The purpose of this client is to
provide an mp3-stream to a Icecast server.

Usage ex.

  1. Create playlist.txt by command:

	dir D:\path\*mp3 /F /S>playlist.txt

  2. Type:

	rxshout localhost -P:mypswd -e:8001 -l -r -V

     , where localhost - Icesast's address, 8001 - Icesast's port
     (in 'shoutcast-compat' mode)

Switches:

  -P:<password>   - Use specified password
  -V              - Use verbose output
  -S              - Display all settings and exit
  -b:<bitrate>    - Start using specified bitrate (def. 128)
  -e:<port>       - Connect to port on server (def. 8001)
  -g:<genre>      - Use specified genre
  -l              - Go on forever (loop)
  -n:<name>       - Use specified name
  -p:<playlist>   - Use specified file as a playlist (def. playlist.txt)
  -r              - Shuffle playlist (random play)
  -u:<url>        - Use specified url
  -stdin          - Read stream from stdin (not use playlist)

Note:
  Do not use '\\' in <url>, change it with '\/': "-u:http:\/www.my.site.org"


  Reencoding stream 'on-fly'

RxShow is able to send mp3-stream with original bitrate only. But you can
create a stream with any desirable bitrate by using LameStream.cmd.
This script will read files from a playlist, reencode them and type them into
stdout. Then, RxShow will read the stream from stdin and forward to Icecast
server.

For reincoding purposes the lame.exe is used, which should be located in the
same direcory with LameStream.cmd or %PATH%. You can get it from hobbes file
archive:

  http://hobbes.nmsu.edu/cgi-bin/h-search?sh=1&button=Search&key=lame-3.97.zip

Example of launching stream source with on-fly reencoding:

  D:\path\>LameStream|rxshout localhost -P:mypswd -e:8001 -V -stdin

Switches for LameStream:

  -r              - Shuffle playlist (random play)
  -f              - Go on forever (loop)
  -p:<playlist>   - Use specified file as a playlist (def. playlist.txt)
  -c:<DT|Size>    - Reload playlist when date/time changed or size only
  -l:<file>       - Logfile
  -b:<N>          - Output bitrate
  -w:<file>       - Web-file, history of last played songs in XML-format

Defaults is:
  -r -f -p:playlist.txt -c:D -l:LameStream.log -b:128 -w:LameStream.xml

XML-file indicated as -w option, saves 10 most recently played files.

For parsing into HTML-format, LameStream.xsl to be used, which should be
located on the same path where Web-file is. This file can be opened directly
in browser (xml/xslt support required), or you can point to a path available
through a local ftp or web-server.

Web-server must send mime-type "application/xml" for *.xml and *.xsl files
(see mime.types file for Apache)

----

In our local network stream source is been launching on the server from
startup.cmd:

  LameStream.cmd -w:C:\var\log\LameStream\LameStream.xml -l:C:\var\log\LameStream\LameStream.log -b:128 -c:S|rxshout.cmd 127.0.0.1 -P:pswd -e:8001 -n:Gizamen-radio -b:128 -g:Rock-n-Metal -stdin

Periodical playlist up-date is performed (by cron):

  dir "F:\Radio\*mp3" /F /S >C:\programs\icecast\shout\playlist.txt

Thereby, when content of folder F:\RADIO is changed, the playlist is up-dated
and re-counted consequently.


Vasilkin Andrey, 2007
digi@os2.snc.ru
