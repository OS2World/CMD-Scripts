/* REXX-Programm zur Umrechnung  Euro --> DM   */
/* Hermann Mahr, h_mahr@hrzpub.tu-darmstadt.de */   
numeric digits 12
u=1.95583
parse arg Euro
if Euro="" then
do
  Beep(443,200)
  say
  say"    Anwendung: euro2dm Euro-Betrag"
  say"    Beispiel : euro2dm 17,85"; say
  say"    Es kann das Dezimalkomma oder der Dezimalpunkt verwendet werden;"
  say"    Die Bildschirmausgabe geschieht mit dem Dezimalkomma.           "
  exit
end

/* FÅr die interne Umrechnung ein bei der Eingabe eventuell    */      
/* verwendetes Dezimalkomma durch einen Dezimalpunkt ersetzen. */      
kk=Pos(",",Euro)
if kk<>0 then Euro=OverLay(".",Euro,kk)

if DataType(Euro,'N')<>1 then
do
  Beep(443,200)
  say
  say"    Der von Ihnen eingegebene Euro-Betrag  "Euro
  say"    hat ein falsches Zahlenformat !"
  EXIT
end

DM=Euro*u
DM=Format(DM, ,2) 
               
/* FÅr die Bildschirmausgabe Dezimalpunkt */      
/* durch Dezimalkomma ersetzen.           */      
kp=Pos(".",u)
if kp<>0 then u=OverLay(",",u,kp)
kp=Pos(".",DM)
if kp<>0 then DM=OverLay(",",DM,kp)
kp=Pos(".",Euro)
if kp<>0 then Euro=OverLay(",",Euro,kp)
                             
say
say"    "Euro" Euro  =  "DM" DM"  
say
say"    (Umrechnungsfaktor:  u="u" DM/Euro)" 
EXIT
