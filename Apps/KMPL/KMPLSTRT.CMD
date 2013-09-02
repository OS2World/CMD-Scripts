/* Rexx Start- und Konfigurationsdatei  kpmlstart.cmd    */
/* Konfiguriert die erforderliche Umgebung fÅr kmpl.cmd  */
   "@ echo off"
   call setlocal
   "set configpath=%path%"
   /* In die folgende Zeile Nr. 12 mu· der Anwender den absoluten Pfad   */
   /* des Verzeichnisses, in das alle zu KMPL gehîrenden Dateien hinein- */
   /* kopiert worden sind, mit einem abschlie·enden Semikolon und in     */
   /* und in AnfÅhrungszeichen eintragen.                                */
   /* Hier ist angenommen, da· der absolute Pfad dieses Verzeichnisses   */
   /* H:\REXX\KMPL ist.                                                  */
   kmplpath="H:\REXX\KMPL;"    
   "set path="kmplpath"%path%"
   "kmpl.cmd"
   call endlocal
EXIT 
