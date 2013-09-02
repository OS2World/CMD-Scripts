/* REXX-Programm PPrim.CMD        */          
/* Die Dateien "kzr.INF" und "krz.CMD   */
/* befinden sich im selben Verzeichnis. */
   
   Call RxFuncAdd 'SysLoadFuncs', RexxUtil, 'SysLoadFuncs'
   Call SysLoadFuncs
   signal on halt name PgmEnd
  
Pfd=SysSearchPath("PATH", "kzr.cmd")
lp=LastPos("\", Pfd)
Pfd=DelStr(Pfd, 1+lp)

ab=34
Parse upper arg x
say
/* ZwischenrÑume aus dem String  x  entfernen */
do forever
  lzw=Pos(" ", x)
  if lzw = 0 then leave
  x=DelStr(x,lzw,1)
end

ND=length(x)+6
Numeric Digits ND 

if (length(x)= 0) then
do
  "@ start /PM /MAX view.exe" Pfd||"KZR.INF Primfaktoren"
  EXIT
end

if DataType(x, 'W')<>1 | x<1 | Pos(",", x)>0 then
do
  Call Color 1,white
  say"Sie haben keine positive ganze Zahl eingegeben !"
  Beep(444, 200); Beep(628,300)
  signal PgmEnd
end

call Charout,"   Die Zahl, die in Primfaktoren zerlegt werden soll,"; say
call Charout,"   ist:"; say
Call Color 1,Cyan
call Charout,"       " x
Call Color 0,white; say; say
say Insert("Primfaktor    Exponent",' ',ab, ,); say

y=x; z=1; erg=1 
do while v>0 
  T=GWurz(y)+1
  do N=2 to T
    v=0
    do while (y//N=0 & y>=N)
      y=y/N
      z=z*N
      v=v+1
    end
    
    if v>0 then
    do
      erg=erg*N**v 
      lz=ab-length(N)
      NN=Insert(N,' ',lz, ,)
      lv=4-length(v)
      vv=Insert(v,' ',lv, ,)
      call Color 1,white
      say"          "NN"        "vv
      Call Color 0,white
    end
    if v>0 then leave
  end
end
  
if y<>1 then
do
  erg=erg*y**1 
  lz=ab-length(y)
  NN=Insert(y,' ',lz, ,)
  call Color 1,white
  say"          "NN"           1"
  Call Color 0,white
end
Beep(120, 300)
say

if erg==y then
do
  erg=erg*y**1 
  call Charout,"   Die eingegebene Zahl "; say
  Call Color 1,cyan
  call Charout,"                        " x  
  Call Color 0,white
  call Charout,","; say; say 
  call Charout,"   die in ihre Primfaktoren zerlegt werden soll, " 
  Call Color 1,white
  call Charout,"ist selbst eine Primzahl."
  Beep(444, 200); Beep(628,300)
  say             
  signal PgmEnd
end

if erg<>1 then
do
  call Charout,"   Der Wert des Produktes,"; say
  call Charout,"   dessen Faktoren die einzelnen Potenzen "
  Call Color 1,green
  call Charout,'"Primfaktor hoch Exponent"'  
  Call Color 0,white
  call Charout," sind,"; say 
  call Charout,"   ist:"; say 
  Call Color 1,cyan
  call Charout,"        "erg
  say             
  signal PgmEnd
end

PgmEnd:
say
Call Color 0,white
EXIT


/* Prozedur GWurz fÅr die Berechnung der zweiten Wurzel */
/* aus positiven ganzen Zahlen.                         */
/* GWurz liefert als Ergebnis nur ganze Zahlen.         */
GWurz:
   Procedure
   arg x
   ND=40
   numeric digits ND+3

   n=0
   do while x>100
     x=x/100
     n=n+1
   end

   y=1; t=x/y
   do while abs(y-t) > y*10**(-ND-2)
     y=(y+t)/2
     t=x/y
   end

   u=y*10**n
   numeric digits ND
   return(Format(u,,0))


Raus:
  say
  Call Color 1,red
  call Charout,"   Kein Ergebnis !"; say; say
  call Color 1,white
  Call Charout,"   Mindestens einer der Primfaktoren"
  Call Charout," der von Ihnen eingegebenen Zahl"; say; say
  call Color 1,Cyan
  call Charout,"            " x; say; say
  call Color 1,white
  Call Charout,"   ist offenbar so gro·, da· die Zerlegung"
  Call Charout," dieser Zahl in ihre Primfaktoren"; say
  Call Charout,"   mit einer Interpretersprache wie REXX"
  Call Charout," viel zu lange dauern wÅrde."; say
  Beep(444, 200); Beep(628,300)
  signal PgmEnd


/***************************** ANSI-Prozeduren ******************************/


Color:     /* Call Color <Attr>,<ForeGround>,<BackGround>                */  
Procedure  /* Attr=1 -> HIGH;  Attr=0 -> LOW; Attr only for ForeGround ! */
arg A,F,B   
CLRS = "BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE"
A=strip(A); if length(A)==0 then A=0    
F=strip(F); if length(F)==0 then F=WHITE
B=strip(B); if length(B)==0 then B=BLACK
return CHAROUT(,D2C(27)||"["A";"WORDPOS(F,CLRS)+29";"WORDPOS(B,CLRS)+39"m")
