; KEY SMTWTFS start duration <-variable parameters-> directory/filename
; ^   ^       ^     ^   MUST ALWAYS HAVE THE 5 PARAMETERS INDICATED  ^
; KEYwords: DIR: directory | RND: as directory but random order
;   STR: stream | RST: random stream from directory of playlists
;   REC: record stream
;   FKY key# stream: assign stream playlist to a function key
;
; Error checking is minimal, so ADHERE TO EXAMPLED FORMAT!
;
; >>> MINIMUM DURATION IS 5 (FIVE) MINUTES.
;
; More or less, a line is ignored if doesn't have SAVEPATH or one of above
; KEYs in column 1 (after stripping spaces that really shouldn't be present
; anyway). -- Semi-colons here are actually only for show.
;
; INHERENT LIMIT OF 255 LINES because using 8-bit value to refer to line #.
; For REALLY complex scheduling, then, eliminate all these comment lines.
;
; SCHEDULES OVERLAY ACCORDING TO ORDER LISTED; CLASHES SIMPLY DON'T OCCUR!
; Events run - even multiple times - EVERY minute not overlaid.
; This can be HIGHLY convenient to schedule a default action for up to entire
; day (time 00:00, duration 1440, or 24:00 after v1.0).
;
SAVEPATH C:\DAILY
;-SAVEPATH directory name is all starting 2nd word, can include spaces.
; The specified directory will be created if does not exist.
; It should contain only files named with date_time format by TZ.
CLEAR
;-Presence of this keyword will cause TZ.CMD to DELETE FILES, if necessary,
; from SAVEPATH directory until sufficient space is cleared to save current
; recorded file. This strategy assumes a dedicated drive that can be filled.
MAX 1G
;-This keyword specifies a maximum size for the save_path directory. Files
; will be deleted if necessary. Supplements CLEAR keyword with a strategy more
; suited to MOST users, that is, the drive must not be entirely filled. --
; Ooops, huh? Slight oversight due to developing on dedicated recorder...
; Flexible format: 1.8G or 700M or exactly specified: 500000000
;
;-Example: specific PATH for RECord
;   REC _MTWTF_ 11:03 57 PATH "C:\daily" C:\pls\aj.pls
; varied parms start here^    ^quoted     ^filename always at lastpos ":\"
;
;-Example: further option to specific path MOVEs to SAVEPATH
; limits HD wear and noise by spooling to RAM drive
;   REC _MTWTF_ 11:03 57 PATH "Z:\" MOVE C:\pls\aj.pls
;
;-Example: SPLIT option for RECord breaks long sessions into chunks
; easier to skip through; some hedge against stream errors
;   REC _MTWTF_ 11:02 180 PATH "Z:\" MOVE SPLIT 30 C:\pls\aj.pls
;         follow "SPLIT" with time parameter in ^minutes
;
;-Example: REC _MTWTF_ 11:02 2:58 PATH "Z:\" MOVE C:\pls\aj.pls
;         colon here optional ^hours:minutes form for DURATION (not _TO_)
;
; random streams for likely waking hours...
RST SMTWTFS 08:00 16:00 17 C:\tz\favored
;
; Garrison Keillor daily
REC _MTWTF_ 08:59 5 PATH "Z:\" MOVE C:\tz\phc\KAMU.PLS
;
; Infowars.com, Alex Jones
REC _MTWTF_ 11:01 3:59 PATH "Z:\" MOVE SPLIT 30 C:\tz\news\aj.pls
;
; WhatReallyHappened.com, Michael Rivero daily
REC _MTWTF_ 17:07 53 PATH "Z:\" MOVE SPLIT 30 C:\tz\gcn\GCN2.m3u
;
; Rense.com, Jeff Rense
REC _MTWTF_ 21:08 52 PATH "Z:\" MOVE SPLIT 30 C:\tz\gcn\GCN2.m3u
REC _MTWTF_ 22:08 52 PATH "Z:\" MOVE SPLIT 30 C:\tz\gcn\GCN2.m3u
REC _MTWTF_ 23:08 52 PATH "Z:\" MOVE SPLIT 30 C:\tz\gcn\GCN2.m3u
;
; Car Talk on NPR
REC ______S 09:00 58 PATH "Z:\" MOVE SPLIT 20 C:\tz\phc\KAMU.PLS
;
; WhatReallyHappened.com, Michael Rivero
REC ______S 11:08 52 PATH "Z:\" MOVE SPLIT 30 C:\tz\gcn\gcn4.m3u
REC ______S 12:08 52 PATH "Z:\" MOVE SPLIT 30 C:\tz\gcn\gcn4.m3u
;
; Webster Tarpley
REC ______S 13:08 52 PATH "Z:\" MOVE SPLIT 30 C:\tz\gcn\gcn2.m3u
REC ______S 14:08 52 PATH "Z:\" MOVE SPLIT 30 C:\tz\gcn\gcn2.m3u
;
; Prairie Home Companion, Garrison Keillor
REC ______S 17:00 1:59 PATH "Z:\" MOVE SPLIT 30 C:\tz\phc\KAMU.PLS
;
; Alex Jones Sunday on GCN
REC S______ 16:07 53 PATH "Z:\" MOVE SPLIT 30 C:\tz\gcn\GCN3.m3u
REC S______ 17:07 53 PATH "Z:\" MOVE SPLIT 30 C:\tz\gcn\GCN3.m3u
;
; Function KeYs jump right to that stream
;
FKY 1 C:\TZ\favored\1FM.pls
FKY 2 C:\TZ\favored\1fmtran.pls
FKY 3 C:\TZ\favored\maxi80.PLS
FKY 4 C:\TZ\favored\schlgpop.pls
FKY 5 C:\TZ\favored\dichill.pls
FKY 6 C:\TZ\favored\france2.pls
FKY 7 C:\TZ\favored\groovsal.pls
FKY 8 C:\TZ\favored\lectriq.pls
FKY 9 C:\TZ\favored\limbik.pls
FKY 10 C:\TZ\favored\parisone.pls
FKY 11 C:\TZ\favored\discofox.pls
FKY 12 C:\TZ\PHC\KAMU.PLS
;
; NOTE: program examples are simply to avoid effort of finding neutral content.
