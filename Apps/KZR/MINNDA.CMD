/* REXX_Programm MinNDA.CMD zur Ermittlung des kleinsten Wertes der */
/* Zahl ND, wenn mehrere oder auch nur eines der "externen"         */
/* mathematischen Funktionen von kzr.cmd verwendet werden.          */

/* In diesem Programm MinNDA.CMD sind fÅr alle Funktionen, deren Rechen-  */
/* genauigkeit begrenzt ist, die mit Pfad "Pfd" versehenen Dateinamen     */
/* festgelegt. In diese Dateien werden, sofern deren begrenzte Zahl ND    */
/* wirksam wird, die jeweilige maximale Zahl ND abgespeichert.            */
/* sqrt.cmd und root3.cmd haben keine interne Begrenzung fÅr ND...        */

   /* Wird bei der AusfÅhrung einer REXX-Anweisung ein Syntaxfehler */
   /* festgestellt, so wird zur Prozedur "Fehlermeldung" verzweigt. */
   signal on syntax name Fehlermsg

   /* Die Datei "Ergebnis.DAT" wird in dem Verzeichnis abgelegt, */
   /* in dem auch die Datei "kzr.CMD" abgelegt ist.              */
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   bufND =Pfd||"NDZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"
   /* Hier wird die in der "Kernfunktion" kzr.cmd festgelegte Zahl ND */
   /* der zu verwendenden Dezimalstellen Åbernommen.                  */
   ND = LineIn(bufND, 1)

/* Wenn Funktionen mit begrenzter Rechengenauigkeit hinzukommen, */
/* hier ergÑnzen.                                                */
   NDAsin      = Pfd||"NDAsin.DAT"
   NDAcos      = Pfd||"NDAcos.DAT"
   NDAtan      = Pfd||"NDAtan.DAT"
   NDAcot      = Pfd||"NDAcot.DAT"
   NDAexp      = Pfd||"NDAexp.DAT"
   NDAln       = Pfd||"NDAln.DAT"
   NDAlog      = Pfd||"NDAlog.DAT"
   NDAld       = Pfd||"NDAld.DAT"
   NDAn!       = Pfd||"NDAn!.DAT"
   NDAnbin     = Pfd||"NDAbin.DAT"
   NDAphi      = Pfd||"NDAphi.DAT"
   NDAp_       = Pfd||"NDAp_.DAT"
   NDAq_       = Pfd||"NDAq_.DAT"
   NDAerf      = Pfd||"NDAerf.DAT"
   NDAerfc     = Pfd||"NDAerfc.DAT"
   NDAarcsin   = Pfd||"NDAarcsin.DAT"
   NDAarccos   = Pfd||"NDAarccos.DAT"
   NDAarctan   = Pfd||"NDAarctan.DAT"
   NDAarccot   = Pfd||"NDAarccot.DAT"
   NDApot      = Pfd||"NDApot.DAT"
   NDAga       = Pfd||"NDAga.DAT"
   NDAsinh     = Pfd||"NDAsinh.DAT"
   NDAcosh     = Pfd||"NDAcosh.DAT"
   NDAtanh     = Pfd||"NDAtanh.DAT"
   NDAcoth     = Pfd||"NDAcoth.DAT"
   NDAarsinh   = Pfd||"NDAarsinh.DAT"
   NDAarcosh   = Pfd||"NDAarcosh.DAT"
   NDAartanh   = Pfd||"NDAartanh.DAT"
   NDAarcoth   = Pfd||"NDAarcoth.DAT"
   NDApi       = Pfd||"NDApi.DAT"

/* Wenn Funktionen mit begrenzter Rechengenauigkeit hinzukommen, */
/* hier ergÑnzen.                                                */
   NDA.1 =LineIn(NDAsin     , 1)
   NDA.2 =LineIn(NDAcos     , 1)
   NDA.3 =LineIn(NDAtan     , 1)
   NDA.4 =LineIn(NDAcot     , 1)
   NDA.5 =LineIn(NDAexp     , 1)
   NDA.6 =LineIn(NDAln      , 1)
   NDA.7 =LineIn(NDAlog     , 1)
   NDA.8 =LineIn(NDAld      , 1)
   NDA.9 =LineIn(NDAphi     , 1)
   NDA.10=LineIn(NDAp_      , 1)
   NDA.11=LineIn(NDAq_      , 1)
   NDA.12=LineIn(NDAerf     , 1)
   NDA.13=LineIn(NDAerfc    , 1)
   NDA.14=LineIn(NDAarcsin  , 1)
   NDA.15=LineIn(NDAarccos  , 1)
   NDA.16=LineIn(NDAarctan  , 1)
   NDA.17=LineIn(NDAarccot  , 1)
   NDA.18=LineIn(NDApot     , 1)
   NDA.19=LineIn(NDAga      , 1)
   NDA.20=LineIn(NDAsinh    , 1)
   NDA.21=LineIn(NDAcosh    , 1)
   NDA.22=LineIn(NDAtanh    , 1)
   NDA.23=LineIn(NDAcoth    , 1)
   NDA.24=LineIn(NDAarsinh  , 1)
   NDA.25=LineIn(NDAarcosh  , 1)
   NDA.26=LineIn(NDAartanh  , 1)
   NDA.27=LineIn(NDAarcoth  , 1)
   NDA.28=LineIn(NDApi      , 1)


/* Wenn Funktionen mit begrenzter Rechengenauigkeit hinzukommen, */
/* hier ergÑnzen.                                                */
   Call Charout(NDAsin)    ;  Call SysFileDelete NDAsin
   Call Charout(NDAcos)    ;  Call SysFileDelete NDAcos
   Call Charout(NDAtan)    ;  Call SysFileDelete NDAtan
   Call Charout(NDAcot)    ;  Call SysFileDelete NDAcot
   Call Charout(NDAexp)    ;  Call SysFileDelete NDAexp
   Call Charout(NDAln )    ;  Call SysFileDelete NDAln
   Call Charout(NDAlog)    ;  Call SysFileDelete NDAlog
   Call Charout(NDAld )    ;  Call SysFileDelete NDAld
   Call Charout(NDAphi)    ;  Call SysFileDelete NDAphi
   Call Charout(NDAp_ )    ;  Call SysFileDelete NDAp_
   Call Charout(NDAq_ )    ;  Call SysFileDelete NDAq_
   Call Charout(NDAerf)    ;  Call SysFileDelete NDAerf
   Call Charout(NDAerfc)   ; Call SysFileDelete NDAerfc
   Call Charout(NDAarcsin) ; Call SysFileDelete NDAarcsin
   Call Charout(NDAarccos) ; Call SysFileDelete NDAarccos
   Call Charout(NDAarctan) ; Call SysFileDelete NDAarctan
   Call Charout(NDAarccot) ; Call SysFileDelete NDAarccot
   Call Charout(NDApot)    ; Call SysFileDelete NDApot
   Call Charout(NDAga)     ; Call SysFileDelete NDAga
   Call Charout(NDAsinh)   ; Call SysFileDelete NDAsinh
   Call Charout(NDAcosh)   ; Call SysFileDelete NDAcosh
   Call Charout(NDAtanh)   ; Call SysFileDelete NDAtanh
   Call Charout(NDAcoth)   ; Call SysFileDelete NDAcoth
   Call Charout(NDAarsinh) ; Call SysFileDelete NDAarsinh
   Call Charout(NDAarcosh) ; Call SysFileDelete NDAarcosh
   Call Charout(NDAartanh) ; Call SysFileDelete NDAartanh
   Call Charout(NDAarcoth) ; Call SysFileDelete NDAarcoth
   Call charout(NDApi)     ; Call SysFileDelete NDApi

   /* Ein String mit Zahlen, denen jeweils ein Komma folgt, wird erzeugt. */
   i=1; NDAstr=""
   do while i<=28
     if NDA.i > 0 then NDAstr=NDAstr||NDA.i||","
     i=i+1
   end
   /* Das letzte Komma dieses Strings wird wieder entfernt. */
   lp=LastPos(",", NDAstr)
   if lp > 0 then  NDAstr=DelStr(NDAstr, lp)
   say

   /* Wenn keine mathematischen Funktionen mit begrenzter     */
   /* Rechengenauigkeit verwendet werden, Weitergabe von ND.  */
   if length(NDAstr)=0 then do; NDAmin=ND; Signal WW; end
   /* Da die Funktion offenbar einen String der Form "12,45,6,890,3"  */
   /* so ohne weiteres nicht verarbeiten kann, ist die folgende       */
   /* Anweisung erforderlich:                                         */
   interpret "NDAmin=Min("NDAstr")"

WW:
   return(NDAmin)

