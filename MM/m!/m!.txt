 m!.cmd  Beta version 0.7.2  by Wolfgang Reinken 
 last update: May 3rd 2007

 I wrote this little text based frontend to have the chance as well as play multiple MIDI files
 and store and load MIDI file play lists. So I adapted the look and feel of the great MP3 player
 z!.exe and wrote this player in REXX, the language of my choice. 

 By default it uses the MCI REXX functions. In a later version I extended M!.cmd with  
 support of environments having trouble with playing MIDI by MMOS2. In those cases the tool 
 invokes the program timidity.exe. This execution mode has unfortunately some limitations
 compared to the MMOS2 mode. 

 - disclaimer -
 this program comes with absolutely no guarantees. any problems, side effects,
 or whatever is your responsibility.				
						
Program requirements:

1. This REXX program needs the library RXU.DLL (successor of YDBAUTIL.DLL)
   available at: http://hobbes.nmsu.edu/pub/os2/dev/rexx/rxu1a.zip
   note: If you already use YDBAUTIL M!.cmd should also run after the necessary modification

2. If your sound card doesn't support playing MIDI you need the command line version timidity.exe
   of timidity package
   available at: http://doconnor.reamined.on.ca/timidity++_2104_os2.zip

Installation: 

1. Copy m!.cmd to a directory of your choice
2. If not already done so place RXU.DLL into your LIBPATH
3. If needed place TIMIDITY.EXE into your PATH
4. If wanted you can create a program icon using one of the two icon files (m!.ico or m2.ico)
   provides by Andreas Kohl

Run the program:

Just change to program path and type m!.cmd and the programme's main menu appears. For further
actions just press the keys mentioned in main menu or get help by pressing the F1 key. 
Two different help panels are available: 
   a) Main help, invoked from main menu
   b) Play help, invoked while playing

note: m!.cmd doesn't run properly under 4OS2 environment!



I hope you'll enjoy using this little frontend.

Thanks to Andreas Kohl for providing the two nice icon-files. 

Comments are welcome: wolfgang.reinken@t-online.de


Wolfgang Reinken

April 29 2007

Leipzig, Germany