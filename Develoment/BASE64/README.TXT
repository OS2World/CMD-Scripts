     ENBASE64.CMD/DEBASE64.CMD are Rexx programs that encode/decode a file
in Base64 (as used in Mime and described in Marshall T. Rose's book, The
Internet Message).  Like UUENCODE, ENBASE64 encodes any file as printable
characters.  Unlike UUENCODE, the characters are not garbled if they are 
translated from ASCII to EBCDIC and back to ASCII.  (This is a major advantage
for those of us that receive mail on IBM mainframes.)  And, files encoded via
ENBASE64 are immume to the loss of trailing spaces (because none are used). 
DEBASE64.CMD uses no unusual characters and can be sent to an OS/2 user
receiving a file encoded via ENBASE64; the Basic program DEBASE.BAS uses no
unusual characters and can be sent to a DOS user.

