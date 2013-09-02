/* REXX-Programm ld.cmd  */
   signal on syntax name ldMsg

/* Diese Variablen mÅssen fÅr jede Prozedur definiert werden, damit die  */
/* Prozedur die Variable bufND kennt und die Variable ND Åbernehmen kann.*/
   Pfd=SysSearchPath("PATH", "kzr.cmd")
   lp=LastPos("\", Pfd)
   Pfd=DelStr(Pfd, 1+lp)
   NDAld =Pfd||"NDAld.DAT"
   bufND =Pfd||"NDZahl.DAT"
   bufMsg=Pfd||"Meldung.DAT"
   ND = LineIn(bufND, 1)
   NUMERIC DIGITS (ND+10)

/* An dieser Stelle mu·  "bufMsg"  gelîscht werden, damit dann,   */
/* die Datei  "Meldung.DAT"  leer ist, diese auch leer bleibt.    */
   call charout(bufMsg)
   Call SysFileDelete bufMsg

   if ND > 450 then
   do
     ND=450
     call charout(NDAld) ; Call SysFileDelete NDAld
     ret=LineOut(NDAld, 450)
     Call Charout,"   Achtung, nur 450 Dezimalstellen bei der Berechnung von   ld(...)"
     say
     Beep(444, 200); Beep(628,300)  /* Hier kein EXIT ! */
   end

   /* Wenn ND <= 450 ist, wird ND = ND  weitergegeben */
   call charout(NDAld) ; Call SysFileDelete NDAld
   ret=LineOut(NDAld, ND)

   /* lna1 = ln(1.69) */
   lna1=0.||,
   5247285289349821040709919737619087944083329122628682807714352193917||,
   841152941153983271549167017823808545808161009529459962452580538075605143||,
   179614957470321246015797443040147265215320127063135916286921788619242526||,
   575215249400686632216631794011227950002119245158263789878915397341784224||,
   036001931559858474752982104716769644711036227308178568176895075832529284||,
   232546039929327153868686072445084165605817063965568882069930595207030840||,
   9660140381917978653590041436934688403145311165682227293922935107690474705

   /* lna2 = ln(3.49) */
   lna2=1.||,
   2499017362143357951634986131299112939466823602028164371597327972818||,
   379181900889747291289440245239282509867619774937415989840364673381082569||,
   214417875411147801968539067758474601483417628517197130791023958191843818||,
   414009839452902151163994500318180865847594804307169876881964505466838103||,
   221492536478446093780088944130981471122649198384614405790745449910842241||,
   934168422623424820130114818783092800899731734225475602660107791102746614||,
   760700072592629269363017609250380628876450730290050619407723681593250485

   /* lna3 = ln(7) */
   lna3=1.||,
   9459101490553133051053527434431797296370847295818611884593901499375||,
   798627520692677876584985878715269930616942058511409117237522576777868431||,
   489580951639007759078244681042747833822593490084673744125049737048535517||,
   678355774862401510277418088686710751412134809387974183108102518231684930||,
   140733063932877119341121406876924002605769358524796053502857536256906187||,
   920955021911641759086475695432943962682703455511789841649613810686409244||,
   5160419227745099543528972772872862328141474249580376618676174693688509687

   /* ln10 = ln(10) */
   ln10=2.||,
   3025850929940456840179914546843642076011014886287729760333279009675||,
   726096773524802359972050895982983419677840422862486334095254650828067566||,
   662873690987816894829072083255546808437998948262331985283935053089653777||,
   326288461633662222876982198867465436674744042432743651550489343149393914||,
   796194044002221051017141748003688084012647080685567743216228355220114804||,
   663715659121373450747856947683463616792101806445070648000277502684916746||,
   5505868569356734206705811364292245544057589257242082413146956890167589403

   m2=1.||,
   442695040888963407359924681001892137426645954152985934135449406931||,
   109219181185079885526622893506344496997518309652544255593101687168359642||,
   720662158223479336274537369884718493630701387663532015533894318916664837||,
   643128615424047478422289497904795091530351338588054968865893096996368036||,
   110511075630844145427215828344941891933908577715790044171280246848341374||,
   522695182369011239094034459968539906113421722886278029158010630061976762||,
   445652605995073753240625655815475938178305239725510724813077156267545808

   arg x,y
   p0p=x*x /* Diese Anweisung provoziert eine Syntax-Fehlermeldung */

   if length(y) > 0 then
   do
     call charout(NDAld) ; Call SysFileDelete NDAld
     ret=LineOut(bufMsg, "Im Argument von  ld(...)  ist mindestens  1  nicht zulÑssiges Komma !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   if x<=0 then
   do
     call charout(NDAld) ; Call SysFileDelete NDAld
     ret=LineOut(bufMsg, "Der Logarithmus ist fÅr  x <= 0  nicht definiert !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

   if x  = 1    then do y=0;    return(y);   EXIT; end
   if x >= 1    then do z=x;    sgn=+1;  SIGNAL A; end
   if x <= 1    then do z=1/x;  sgn=-1;  SIGNAL A; end

A: p=10; n=0; do while (z>9.5); z=z/p; n=n+1; end

   if (5.0   <  z) then if (z <= 9.50 ) then
           do aa=7.00; aln=lna3; SIGNAL B; end
   if (2.430 <  z) then if (z <= 5.00 ) then
           do aa=3.49; aln=lna2; SIGNAL B; end
   if (1.05  <  z) then if (z <= 2.430) then
           do aa=1.69; aln=lna1; SIGNAL B; end
   if (0.95  <  z) then if (z <= 1.05 ) then SIGNAL C

B: tt=(z-aa)/(z+aa); t=tt*tt; u=1; m=1; v=1
   do while ((u/v) > 10**(-ND-7))
       g=t*(2*m-1)/(2*m+1); u=u*g; v=v+u; m=m+1; end
   y=sgn*(n*ln10 + aln+2*tt*v); SIGNAL E

C: tt=(z-1)/(z+1); t=tt*tt; u=1; m=1; v=1
   do while ((u/v) > 10**(-ND-7))
       g=t*(2*m-1)/(2*m+1); u=u*g; v=v+u; m=m+1; end
   y=sgn*(n*ln10 + 2*tt*v)

E: u=m2*y
   NUMERIC DIGITS ND
   return(Format(u))

ldMsg:
   sf=ErrorText(RC)
   if  Pos("Bad arithmetic conversion", sf) > 0 then
   do
     call charout(NDAld) ; Call SysFileDelete NDAld
     ret=LineOut(bufMsg, "Sie haben in  ld(...)  kein gÅltiges Argument eingegeben !")
  /* "bufMsg" und  "bufND" werden immer beim Beenden von kzr.cmd gelîscht, */
  /*  damit in den diesbezÅglichen temporÑren Dateien                      */
  /*  Meldungen und ND-Werte nicht aneinandergehÑngt werden.               */
     EXIT
   end

