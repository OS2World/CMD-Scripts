; REC SMTWTFS start duration <-variable parameters-> directory/filename
; ^   ^days   ^     ^   MUST ALWAYS HAVE THE 5 PARAMETERS INDICATED  ^
; !!! There is only one KEYword in Time4SR: REC
; DIR, RND, STR, RST, and FKY of TZ are no longer relevant.
;
; Error checking is minimal, so ADHERE TO EXAMPLED FORMAT!
;
; A line is ignored if doesn't have REC in column 1.
;
; INHERENT LIMIT OF 255 LINES because using 8-bit value to refer to line #.
; For REALLY complex scheduling, then, eliminate all comment lines.
;
; Unlike TZ, OVERLAYS ARE FORBIDDEN. StreamRipper has its own timer and lacks
; control via named pipe. But can run multiple instances by making a copy of
; this file and renaming to the next IN SEQUENCE (no gaps), like: Time4SR2.sch
;
SAVEPATH C:\DAILY
;-Directory name is all starting 2nd word, can include spaces.
; The specified directory will be created if does not exist.
; It should contain only files named with stream_date_time format by Time4SR,
; because when using CLEAR or MAX, any file may be deleted (WILL BE, in time).
CLEAR
;-Presence of "CLEAR" keyword will allow Time4SR.CMD to DELETE FILES, if
; necessary, from SAVEPATH directory until sufficient space is cleared to save
; current recording. This strategy assumes dedicated drive that can be filled.
MAX 2G
;-The "MAX" keyword specifies maximum size for the SAVEPATH directory. FILES
; WILL BE DELETED if necessary. Supplements CLEAR keyword with a strategy more
; suited to MOST users, that is, the drive must NOT be entirely filled.
; Flexible format: 1.8G or 700M or exactly specified: 500000000
;
;-Example: specific PATH for RECord (else goes into SAVEPATH, above)
;   REC _MTWTF_ 11:03 57 PATH "C:\daily" C:\pls\aj.pls
; varied parms start here^    ^quoted     ^playlist always at lastpos ":\"
;
;-Example: further option only SPOOLS to specific path, then MOVEs to SAVEPATH
; Can reduce HD wear and noise by spooling to ramdrive.
;   REC _MTWTF_ 11:03 57 PATH "Z:\" MOVE C:\pls\aj.pls
;
;-Example: REC _MTWTF_ 11:02 2:58 PATH "Z:\" MOVE C:\pls\aj.pls
;         OPTIONAL colon here ^hours:minutes form for DURATION (is not _TO_)
;
; "SPLIT" IS NO LONGER OPERATIVE but can be left when copying from TZ.SCH.
; INSTEAD, DO YOUR OWN SPLITTING, IF NECESSARY. 128Kb/S streams run to about
; 1M per minute, which in my current boxes strains memory (when spooling to
; ramdrive, especially with concurrent streams), so I split high-bitrate 
; streams into 30 minute pieces. Time4SR and SR.EXE have an overhead of about
; fifteen seconds between recordings; if done on half hour, is usually only 
; "white space", anyhow. -- NOTE that Time4SR effectively splits files should
; stream errors cause SR.EXE to quit (or in case of flying start).
;
; For your first test, change the start time below:
REC SMTWTFS 00:00 10 MOVE C:\tsr\pls\france2.pls
;
; Or, pick one of these stations included in \tsr\pls (sample via TryZ.cmd):
; 1FM.pls                 1fmtran.pls             80sChannel.pls          
; BlitzRadio.FM-Te.PLS    ChilloutDreams-D.PLS    dell.cmd
; dichill.pls             discofox.pls            france2.pls
; FREQUENCE3-www.f.PLS    friskyRadiofeeli.PLS    groovsal.pls
; kinkfm.com.PLS          lectriq.pls             limbik.pls
; M2ANALOGONLY80's.PLS    maxi80.PLS              MELODIA99.2.PLS
; MUSIKGOLDIES.PLS        parisone.pls            POP-RadioPOPO.PLS
; PulsRadio-www.pu.PLS    RadioPaloma-100.PLS     SCHLGPOP.PLS
; SoloPiano-SKY.FM.PLS
;
;
; This example uses ramdrive and then moves to HD:
; REC SMTWTFS 00:00 60 PATH "Z:\" MOVE C:\tsr\pls\france2.pls
