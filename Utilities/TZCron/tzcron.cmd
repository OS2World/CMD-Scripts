/* REXX  Copyright Lueko.Willms@T-Online.de  http://www.willms-edv.de  
   Use without any garanties and without any restrictions 
   Verwendung ohne jedwede Garantien und ohne EinschrÑnkungen 
   */

/* english text follows further down */

/* <deutsch>
   errechnet den nÑchsten Zeitpunkt der Zeitumstellung (Zeitzone, Sommerzeit, Standardzeit) 
   startet sich selbst mittels CRONTAB fÅr diesen Zeitpunkt (falls nicht schon in CRONTAB 
   setzt die Zeit neu, wenn es genau in der Minute der Umstellung gemÑ· TZ-Variable gestartet wurde 
   und fÅhrt dann auch TZSET aus, um die Zeitzoneninfo im System anzupassen   
   </deutsch>  */
   
/* <english>
   This program computes the next change between standard and daylight savings time;
   reschedules itself using CRONTAB, if it is not yet in the CRONTAB;
   resets the time according to the offset configured in the TZ-variable, 
     if it was started in the minute corresponding to the TZ-switch;
   calls TZSET.EXE to change the timezone information in the system time
   </english>
   */

/* Requirements - Voraussetzungen 
   
   
   a fully qualified TZ (Timezone) Variable (not just the timezone names), 
                   Info:  http://www.warpsite.de/en/csdp/SET_TZ.htm
                   TZCALC.EXE (http://hobbes.nmsu.edu/pub/os2/util/system/tzcalc03.zip) 
                   or TZcreator.EXE (http://hobbes.nmsu.edu/pub/os2/util/system/tzcr200.zip)
                   help to compute the correct TZ variable 

   RxDate 2.1      http://hobbes.nmsu.edu/pub/os2/dev/rexx/rxdate21.zip

   TZset.exe       http://eepjm.newcastle.edu.au/os2/software.html#tzset

   Cron with       http://hobbes.nmsu.edu/pub/os2/util/schedule/pmcron03.zip
   CRONTAB.EXE     I use this PMCron, if other implementations do work, I don't know (yet)
                   The main requirement is the program CRONTAB.EXE which allows to update the 
                   crontab while CRON itself is running. 

*/   

/*  Installation 
    
    <deutsch>
    Kopieren Sie das Programm irgendwohin und fÅhren es aus. 
    Der komplette Pfad wird automatisch in CRONTAB eingetragen 

    die folgenden beiden Programmzeilen (86, 87) mÅssen geÑndert werden, um den vollstÑndigen Pfad
    zu CRONTAB.EXE und TZSET.EXE auf Ihrem System zu konfigurieren. 

    u.U. mu· die Variable "zeitTrennzeichen" in Zeile 220 geÑndert werden, 
    um das Kommando TIME korrekt ausfÅhren zu kînnen. Dies Program 
    liest das Zeittrennzeichen aus den INI-Dateien, aber TIME akzeptiert das Zeichen nicht. 

    Testen Sie, indem Sie dies Programm mit 2 Parametern aufrufen: 
    Datum (JJJJ-MM-DD) umd Minute einer Zeitumstellung
    (mit Minute ist hier die Gesamtzahl der Minuten nach Mitternacht gemeint,  
    also 120 fÅr 2 Stunden, 180 fÅr 3 Stunden, etc).

    Eine zukÅnftige Version soll dann einen Installer haben, der das alles 
    automatisch erledigt. 
    </deutsch>    

    <english>
    Copy this program to where you want and execute it once. 
    The complete path will be entered in CRONTAB for the next scheduled execution. 

    the following two program lines (86, 87) will have to be changed, so that the correct
    path to CRONTAB.EXE and TZSET.EXE is being known to this program. 

    Test if this program can correctly set the time by calling it with two parameters, 
    the date (YYYY-MM-DD) and minute of a time zone switch in this year (minute being the minutes
    since midnight, like 120 for 2 hours, 180 for 3 hours, etc). 
    You might have to change the value for the time separator ("zeitTrennzeichen")
    in line 220 of this program. This program retrieves the time sepaparator from the INI settings, 
    but TIME doesn't like it. 

    A future version of this program should have an installer which does this
    configuration automatically. 

*/


crontabPath = "H:\APP\PMCRON\crontab.exe "
tzsetPath   = "h:\util\tzset.exe"

/* optional ein Datum und Minuten als Parameter, um testen zu kînnen */

ARG  heutigesDatum testmin . 

 IF testmin = "" THEN
    jetztMinuten = TIME("M")   /* Minuten nach Mitternacht */
 ELSE
    jetztMinuten = testmin

 Call RxFuncAdd  'RxDate', 'REXXDATE', 'RxDate'

 tzVar = VALUE("TZ",,"OS2ENVIRONMENT")
 PARSE VAR tzVar tzNamDiff "," startMonat "," startWoche "," startTag "," startSekunde "," endMonat "," endWoche "," endTag "," endSekunde "," diffSekunden
 /* Hinweis: Wenn {start|END}Woche = 0 DANN {start|END}Tag IN [1,31], sonst Wochentag mit 0 = Sonntag   */
 diesJahr   = RxDate(heutigesDatum, "%Y")
 heuteDatum = RxDate(heutigesDatum)

 startDatum = gibDatumAusTZ(diesJahr, startWoche, startMonat, startTag)
 endDatum = gibDatumAusTZ(diesJahr, endWoche, endMonat, endTag)

 jetztTimestamp = heuteDatum + jetztMinuten / 1440
 startTimestamp = startDatum + (startSekunde % 60) / 1440
 endTimestamp   = endDatum   + (endSekunde % 60) / 1440
 SELECT  
    WHEN jetztTimestamp < startTimestamp THEN
      DO
       nextSwitchDatum = startDatum 
       nextSwitchSekunden = startSekunde
      END
    WHEN jetztTimestamp = startTimestamp THEN
      DO
       /* Uhr um offset vordrehen, tzset ausfÅhren */
       CALL zeitSetzen +diffSekunden
       nextSwitchDatum = endDatum 
       nextSwitchSekunden = endSekunde
      END
    WHEN jetztTimestamp < endTimestamp THEN
      DO
       nextSwitchDatum = endDatum 
       nextSwitchSekunden = endSekunde
      END
    WHEN jetztTimestamp = endTimestamp THEN
      DO
       /* Uhr um Offset zurÅckdrehen, tzset ausfÅhren */
       CALL zeitSetzen -diffSekunden
       nextSwitchDatum = gibDatumAusTZ(diesJahr + 1, startWoche, startMonat, startTag)
       nextSwitchSekunden = startSekunde
      END
 otherwise
    DO
     nextSwitchDatum = gibDatumAusTZ(diesJahr + 1, startWoche, startMonat, startTag)
     nextSwitchSekunden = startSekunde
    END
 END  /* select */
 crontab = gibCrontabZeile(nextSwitchDatum, nextSwitchSekunden) 
 SAY "nÑchste Zeitumstellung am " RxDate(nextSwitchDatum, "%Y-%m-%d")
 PARSE SOURCE . . thisProgram
 thisProgram = TRANSLATE(thisProgram)
 
 schonVorgesehen = 0
 crontabPath "Show | RXQUEUE"
 DO WHILE QUEUED() > 0
    PULL crontabZeile 
    IF schonVorgesehen = 0 & SPACE(SUBWORD(crontabZeile,2)) = SPACE(crontab||" "||thisProgram) THEN
      DO
       schonVorgesehen = 1
      END
 END
 IF schonVorgesehen = 1 THEN
   SAY "Schon vorgesehen: " crontab thisProgram
 ELSE
   DO
    execZeile = crontabPath||" "||crontab||" "||thisProgram
    execZeile
   END

EXIT
/* ----------------------- end of main program ------------------------------- */

gibDatumAusTZ: 
PROCEDURE
ARG dasJahr, dieWoche, derMonat, derTag 

 SELECT 
   WHEN dieWoche = 0  THEN
     DO
      dasDatum = RxDate(dasJahr||"-"||derMonat||"-"||derTag)
     END
   WHEN dieWoche > 0 THEN
     DO
      refDatum = RxDate(dasJahr||"-"||derMonat||"-"||"1")   /* Monatsanfang */
      dasDatum = refDatum - RxDate(refDatum, "%w") + ((dieWoche -1) * 7) + derTag
     END
   WHEN dieWoche < 0 THEN
     DO
      refDatum = RxDate(dasJahr||"-"||derMonat + 1||"-"||"1") - 1
      refWochentag = RxDate(refDatum, "%w")
      dasDatum = refDatum - refWochentag + derTag + ((dieWoche + 1) * 7)  /* dieWoche ist ja schon negativ, in diesem Fall */
     END
 otherwise
 END  /* select */
RETURN dasDatum


gibCrontabzeile: 
PROCEDURE 
ARG switchDatum, switchSekunden 

  switchMinuten = switchSekunden % 60
  crontab = "ONCE "||switchMinuten // 60||" "||switchMinuten % 60||" "||RxDate(switchDatum, "%d")||" "||RxDate(switchDatum, "%m")||" "||RxDate(switchDatum, "%w")
RETURN crontab


zeitSetzen: 
PROCEDURE EXPOSE tzsetPath
ARG offset 

  diffSekunden = offset // 60
  offset          = offset %  60
  diffMinuten  = offset  // 60
  diffStunden  = offset   % 60

 SAY "jetzt  " TIME("L")
 CALL rxfuncadd 'SysLoadFuncs', 'Rexxutil', 'SysLoadFuncs'
 CALL SysLoadFuncs

 zeitTrennzeichen = STRIP(SysIni(,"PM_National","sTime"),"B",D2C(0))
 dezimalTrennzeichen = STRIP(SysIni(,"PM_National","sDecimal"),"B",D2C(0))
 jetztLang = TIME("L") 
 jetztStunde = LEFT(jetztLang,2)
 jetztMinute = SUBSTR(jetztLang, 4, 2)
 jetztSekunden = SUBSTR(jetztLang, 7)
 zeitTrennzeichen = "."   /* the command line "time" uses dot instead of the "sTime" in SYS.INI ... */
 neueZeitKommando = "TIME "||TRANSLATE(FORMAT(jetztStunde + diffStunden,2,0)||zeitTrennzeichen||FORMAT(jetztMinute + diffMinuten,2,0)||zeitTrennzeichen||TRANSLATE(FORMAT(jetztSekunden + diffSekunden,2,2),dezimalTrennzeichen,"."),"0"," ")
 ADDRESS CMD neueZeitKommando
 ADDRESS CMD tzsetPath
RETURN
/* the end */
