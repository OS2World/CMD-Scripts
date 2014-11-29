/*
 Kopieren von Verzeichnisbaeumen eines Quellsystems (UNIX DEC OSF/1) in ein Zielsystem (OS/2,NETWARE,NT,WINDOWS95). Die benoetigten Verzeichnisse des Zielsystems werden angelegt. Es werden nur Verzeichnisse des Quellsystems mit Inhalt (Datei oder Unterverzeichnis) beruecksichtigt.

			(w) 30.04.1996 Gerald Roehrbein
			*/
parse arg source ip user pswd destdrive
srcpath.0  = source
rc = RxFuncAdd("SysLoadFuncs","RexxUtil","SysLoadFuncs")
rc = SysLoadFuncs()
rc = RxFuncAdd("FtpLoadFuncs","rxFtp","FtpLoadFuncs")
rc = FtpLoadFuncs()
/*
 Setzen des UNIX Account.
*/
rc = FtpSetUser(ip,user,pswd)
ctr=1
dirctr=0
/*
 Diese Schleife ermittelt alle nach Dateien zu durchsuchenden Unterverzeichnisse des Quellsystems, ab dem als erstes Argument und in srcpath.0 gespeicherten Verzeichniss. Die gefundenen Verzeichnisse liegen in dem Array "srcpath.".
 Es wird aus dem als Parameter uebergebenen Quellverzeichnis, dass absolut und von root ausgehend sein muss, der jeweils absolute und nicht der zum Startverzeichnis relative Pfad ermittelt.
*/
DO FOREVER
  say "Durchsuche "srcpath.dirctr
  rc = FtpChDir(srcpath.dirctr)
  rc = FtpLs("*","files.")
  DO i=1 TO files.0
     delim=Pos("/",files.i)
     IF delim <>0 THEN DO
tmpname=srcpath.dirctr||substr(files.i,1,delim)
	isnewsubdir=1
	/*
	 Testen ob das gefundene Verzeichnis in der Liste
	 der Verzeichnisse bereits existiert.
	*/
	DO k=1 TO ctr
	   IF tmpname=srcpath.k THEN DO
	       isnewsubdir=0
	       leave
	   END
	END
	IF isnewsubdir=1 THEN DO
	   srcpath.ctr=tmpname
	   ctr=ctr+1
	END
     END
  END
  dirctr=dirctr+1
  IF dirctr>ctr THEN LEAVE
END /* DO FOREVER */
/*
 Suchen nach Dateien in den gefundenen Unterverzeichnissen des
 Quellsystems und Uebertragen der Daten auf das Zielsystem.
*/
CRLF="0D0A"x
vzcrectr=0
totalctr=0
errctr=0
/*
 Name des Logfiles.
*/
errlog="GETUNIX.LOG"
rc=SysFileDelete(errlog)
ret=Stream(errlog,'C',"OPEN WRITE")
/*
 Protokollieren der gefundenen Quellverzeichnisse
*/
call charout errlog,"Quellverzeichnisse:"CRLF
DO n=0 TO ctr-1
   call charout errlog,"+"srcpath.n||CRLF
END
call charout errlog,"Liste der fehlerhaft uebertragenen Dateien"CRLF
DO n=0 TO ctr-1
   destpath=translate(destdrive||srcpath.n,"\","/")
   destpath=substr(destpath,1,LENGTH(destpath)-1)
   currdir=Directory()
   /*
    Wenn Zielverzeichnis nicht existiert, dann anlegen.
   */
   IF Directory(destpath)="" THEN DO
      crepath.vzcrectr=destpath
      vzcrectr=vzcrectr+1
      ret=DIRECTORY(destdrive||"\")
      destpath=destpath||"\"
      DO FOREVER
	 bpos=POS("\",destpath)-1
	 IF bpos>1 THEN
	    subdir=Substr(destpath,1,bpos)
	 ELSE
	    subdir=destpath
	 ret=SysMkDir(subdir)
	 ret=Directory(subdir)
	 destpath=Substr(destpath,POS("\",destpath)+1,LENGTH(destpath))
	 IF destpath="" THEN LEAVE
      END
   END
   call Directory(currdir)
   /*
    In Quellverzeichnis wechseln und alle Dateien des Quellverzeichnis
    einlesen.
   */
   call FtpChdir(srcpath.n)
   rc = FtpLs("*","files.")
   DO i= 1 TO files.0
      /*
       Dateien eines Unterverzeichnis ignorieren, da das Unterverzeichnis
       im Zielbereich evtl. noch nicht angelegt wurde.
       Die durch diese Bedingung ausgeschlossenen Dateien werden im naechsten
       Schritt kopiert! Es wird so auch verhindert, dass Dateien mehrfach
       mehrfach kopiert werden.
      */
      IF pos("/",files.i)<>0 THEN ITERATE
      
      /*
       Anzahl bearbeiteter Dateien zaehlen.
      */ 
      totalctr=totalctr+1
      /*
       Bilden des Quelldateinamen
      */
      dirstrc= srcpath.n||files.i
      say "Kopiere "|| dirstrc
      say "nach    "|| translate(destdrive||dirstrc,"\","/")
      /*
       Uebertragen der Datei von Quelle nach Ziel
      */
      rc = FtpGet(translate(destdrive||dirstrc,"\","/"),dirstrc,"Binary")
      IF rc = -1 THEN DO
	 say "!!! FTP-Fehler !!!"
	 errctr=errctr+1
	 call charout errlog,dirstrc||CRLF
      END
   END
END /* do ueber alle gefundenen Verzeichnisse */
rc = FtpLogoff()
rc = FtpDropFuncs()
/*
 Ausgabe der Verarbeitungsstatistik
*/
say "Anzahl erzeugter Verzeichnisse :"vzcrectr
DO n=0 TO vzcrectr
 say crepath.n
END
say "Anzahl uebertragener Dateien   :"totalctr
say "Anzahl Uebertragungsfehler     :"errctr
call charout errlog,"Anzahl erzeugter Verzeichnisse :"vzcrectr||CRLF
DO n=0 TO vzcrectr
 call charout errlog,crepath.n||CRLF
END
call charout errlog,"Anzahl uebetragener Dateien    :"totalctr||CRLF
call charout errlog,"Anzahl Uebertragungsfehler     :"||CRLF
ret =STREAM(errlog,'C',"CLOSE")
say "LOGFILE ist GETUNIX.LOG"
