/* Rexx Start- und Konfigurationsdatei  kpmlstart.cmd    */
/* Konfiguriert die erforderliche Umgebung f�r kmpl.cmd  */
   "@ echo off"
   call setlocal
   "set configpath=%path%"
   /* In die folgende Zeile Nr. 12 mu� der Anwender den absoluten Pfad   */
   /* des Verzeichnisses, in das alle zu KMPL geh�renden Dateien hinein- */
   /* kopiert worden sind, mit einem abschlie�enden Semikolon und in     */
   /* und in Anf�hrungszeichen eintragen.                                */
   /* Hier ist angenommen, da� der absolute Pfad dieses Verzeichnisses   */
   /* H:\REXX\KMPL ist.                                                  */
   kmplpath="H:\REXX\KMPL;"    
   "set path="kmplpath"%path%"
   "kmpl.cmd"
   call endlocal
EXIT 
