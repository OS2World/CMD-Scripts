CFLAGS = -AH -c -W3
LLIB = /NOD k:\toolkt13\lib\os2 k:\ibmc2\lib\llibcep c:\cmlib\acs c:\cmlib\cpic
 
popup up.exe: popup.obj
   LINK popup, popup, popup, $(LLIB), popup
 
popup.obj: popup.c
   CL $(CFLAGS)  popup.c
