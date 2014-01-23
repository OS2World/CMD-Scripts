/* /usr/bin/os2/warp/ */

/* SETUP -- begin -- */
counter= "c:\www\cgi-bin\dirs\data\count2.dat";
/* SETUP -- end -- */
parse arg a1 a2 a3
                say "Content-type: text/plain"
                say "Pragma: no-cache"
                say

/* otevri soubor */                
call stream counter,'C','OPEN READ'
/* precti cislo */
cislo=linein(counter);
if cislo='' then cislo=0;
call stream counter,'C','CLOSE'
if a1='i' then 
              do
                cislo=cislo+1;
                call stream counter,'C','OPEN WRITE'
                call stream counter,'C','SEEK 1'
                call lineout counter,cislo
              end  
say "c0="cislo
if a1='v' then say "vr=0.95i"