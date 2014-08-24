/* Name: DM2EURO                                       */
/* Description: REXX program to conver DM --> Euro     */
/* Author: Hermann Mahr, h_mahr@hrzpub.tu-darmstadt.de */
/* License: Freeware                                   */

numeric digits 12
u=1.95583
parse arg DM
if DM="" then
do
  Beep(443,200)
  say
  say"    Anwendung: dm2euro DM-Betrag"
  say"    Beispiel : dm2euro 15,27"; say
  say"    Es kann das Dezimalkomma oder der Dezimalpunkt verwendet werden;"
  say"    Die Bildschirmausgabe geschieht mit dem Dezimalkomma.           "
  exit
end

/* Fr die interne Umrechnung ein bei der Eingabe eventuell    */      
/* verwendetes Dezimalkomma durch einen Dezimalpunkt ersetzen. */      
kk=Pos(",",DM)
if kk<>0 then DM=OverLay(".",DM,kk)

if DataType(DM,'N')<>1 then
do
  Beep(443,200)
  say
  say"    Der von Ihnen eingegebene DM-Betrag  "DM
  say"    hat ein falsches Zahlenformat !"
  EXIT
end

Euro=DM/u
Euro=Format(Euro, ,2) 
               
/* Fr die Bildschirmausgabe Dezimalpunkt */      
/* durch Dezimalkomma ersetzen.           */      
kp=Pos(".",u)
if kp<>0 then u=OverLay(",",u,kp)
kp=Pos(".",DM)
if kp<>0 then DM=OverLay(",",DM,kp)
kp=Pos(".",Euro)
if kp<>0 then Euro=OverLay(",",Euro,kp)
                             
say
say"    "DM" DM  =  "Euro" Euro"  
say
say"    (Umrechnungsfaktor:  u="u" DM/Euro)" 
EXIT
