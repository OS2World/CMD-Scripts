CFLAGS = -AH -c -W3
LLIB = /NOD k:\toolkt13\lib\os2 k:\ibmc2\lib\llibcep c:\cmlib\acs c:\cmlib\cpic
 
cpichear up.exe: cpichear.obj
   LINK cpichear, cpichear, cpichear, $(LLIB), cpichear
 
cpichear.obj: cpichear.c
   CL $(CFLAGS)  cpichear.c
