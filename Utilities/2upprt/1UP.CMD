/* V2.3 - Print 1UP on Laser printer in Portrait Mode */
mode=1  /* Change to: 1-for PPDS, 2-for HP, 3-for PostScript */
vrexx=0 /* Change to: 1 to enable VREXX support */
Arg file opt opt1 .
If vrexx Then Call VREXXSET
ft=1
AGAIN:
mg.1='        '
bopt=0
If file=''|file='?' Then Signal TELL
opt=Translate(opt)
opt1=Translate(opt1)
If opt1='B' Then Signal BADOPT
If opt='B' Then Do
 bopt=1
 opt=opt1
End
If opt\=''&opt\='N'&opt\='A'&opt\='F'&opt\='H' Then Signal BADOPT
If opt='A'&mode=3 Then Signal BADOPT
If mode=1 Then Do
 q=X2C(1B5B4B0300063101)
 prn='LPT1:'  /* Printer    */
 If bopt Then Do
  cpl=91      /* Char/Line  */
  lpp=79      /* Lines/Page */
  qq=X2C(1B3A1B41061B301B5B53080000003B0000143BF6)
 End
 Else Do
  cpl=132     /* Char/Line  */
  lpp=121     /* Lines/Page */
  qq=X2C(0F1B41061B321B5B53080000003B0000143BF6)
 End
End
If mode=2 Then Do
 q=X2C(1B45)
 prn='LPT2:'  /* Printer    */
 If bopt Then Do
  cpl=76      /* Char/Line  */
  lpp=78      /* Lines/Page */
  qq=X2C(1B451B266C31451B287330541B283130551B28733130481B266C3844)
 End
 Else Do
  cpl=129     /* Char/Line  */
  lpp=78      /* Lines/Page */
  qq=X2C(1B451B266C31451B287330541B283130551B287331362E36481B266C3844)
 End
End
If mode=3 Then Do
 prn='LPT3:'  /* Printer    */
 If bopt Then cpl=104
 Else cpl=133 /* Char/Line  */
End
If opt=''|opt='N' Then Do
 ql=copies('Í',cpl+2)
 tl='É'||ql||'»'
 bl='È'||ql||'¼'
End
If (opt='A'|opt='H'|opt='F')&mode\=3 Then Do
 cpl=cpl+4
 lpp=lpp+1
 If (opt='A'|opt='H') Then lpp=lpp+2
 tl=copies('Í',cpl)
End
x=1
no=1
pg=0
sw=0
swl=0
np=D2C(12)
tab=D2C(9)
If mode=3 Then Call SETUP
Else Do
 Call charout prn,qq
 Call HDR
End
Do Forever
 If lines(file)<1 Then Signal FIN
 ln=linein(file)
 If opt='A'&mode\=3 Then Do
  lns=substr(ln,1,1)
  ln=substr(ln,2,cpl)
 End
 If substr(ln,1,1)=np Then ln=substr(ln,2)
 ln=translate(ln,' ',np)
 ln=translate(ln,' ',tab)
 If ln=''&swl=1 Then sw=1
 If sw=0|opt='A' Then Do
  If opt='N' Then ln=right(no,3)||' '||ln
  If length(ln)<=cpl Then Do
   l.x=ln
   Call CPG
  End
  Else Do
   l.x=substr(ln,1,cpl)
   Call CPG
   x=x+1
   If opt='N' Then l.x='    '||substr(ln,cpl+1,cpl-4)
   Else l.x=substr(ln,cpl+1,cpl)
   Call CPG
  End
  swl=0
  no=no+1
  x=x+1
 End
 If ln='' Then swl=1
 sw=0
End
FIN:
If mode=3 Then Call Out 'lastp'
Else Do
 Call PPG
 Call charout prn,q
End
Call stream file,'C','close'
If vrexx Then Call Vexit
Exit
CPG:
If mode=3 Then Do
 lp=''
 Do i=1 to length(l.x)
  If substr(l.x,i,1)='(' Then lp=lp||'\'
  If substr(l.x,i,1)=')' Then lp=lp||'\'
  lp=lp||substr(l.x,i,1)
  If substr(l.x,i,1)='\' Then lp=lp||'\'
 End
 lp='('||lp||') show lf'
 Call Out lp
 Return
End
If opt='A'&(lns='0'|lns='-'|lns='1') Then Do
 sv=l.x
 l.x=' '
 Call CPG1
 If lns='1' Then Do
  x=lpp
  k=1
 End
 If lns\='1' Then x=x+1
 If lns='-' Then Do
  l.x=' '
  Call CPG1
  x=x+1
 End
 l.x=sv
End
Call CPG1
Return
CPG1:
l.x=left(l.x,cpl,' ')
If x=lpp Then Do
 If k=1 Then Do
  sv=l.x
  l.x=' '
 End
 Call PPG
 Call HDR
 If k=1 Then Do
  k=0
  x=1
  l.x=sv
 End
 Else x=0
End
Return
PPG:
Do z=1 To lpp
 If opt='' Then l.z='º '||l.z||' º'
 Call Out l.z
End
If opt='' Then Call Out bl
Return
HDR:
pg=pg+1
If opt='' Then Do
 dl=copies(' ',cpl+4)
 hl=strip(right(date('U'),cpl+4),'t')
End
Else Do
 dl=copies(' ',cpl)
 hl=strip(right(date('U'),cpl),'t')
End
hl=overlay(hl,dl)
hl=overlay(file,hl)
If opt='' Then hl=overlay('Page 'pg,hl,((cpl+4)%2)-2)
Else hl=overlay('Page 'pg,hl,(cpl%2)-2)
If mode=2 Then Call Out ''
If opt='A'&ft=0 Then Call charout prn,np
ft=0
If opt\='H'&opt\='A' Then Do
 Call Out hl
 Call Out tl
End
Do z=1 To lpp
 l.z=copies(' ',cpl)
End
Return
OUT:
Parse Arg ot
Call lineout prn,ot
Return
SETUP:
nf=''
Do i=1 to length(file)
 nf=nf||substr(file,i,1)
 If substr(file,i,1)='\' Then nf=nf||'\'
End
nd=date('U')
nd=strip(nd)
Call Out 'save /pgn 1 def'
If bopt Then Call Out '/lspace { 8 } bind def'
Else Call Out '/lspace { 6 } bind def'
Call Out '/tm { 753 } bind def /bm { 20 } bind def'
Call Out '/lbox { newpath setgray setlinewidth 22 761 moveto'
Call Out ' 22 20 lineto 590 20 lineto 590 761 lineto closepath stroke } def'
Call Out '/llin { newpath setgray setlinewidth 22 761 moveto'
Call Out ' 590 761 lineto stroke } def'
Call Out '/F { findfont exch scalefont setfont } bind def'
Call Out '/incp { /pgn pgn 1 add def } bind def'
Call Out '/lf { currentpoint exch pop lspace sub dup bm lt { pop showpage saveobj'
Call Out ' restore incp opg /saveobj save def tm } if lm exch moveto } bind def'
Call Out '/lastp { currentpoint tm 5 sub gt { 50 gt { showpage } if }'
Call Out ' { pop showpage } ifelse saveobj restore restore } def'
Call Out '/opg { 1 setgray clippath fill 1 setlinejoin'
If opt\='H' Then Do
 If opt='F' Then Call Out ' 2 0 llin 0 setgray 9 /Helvetica-Bold F'
 Else Call Out ' 2 0 lbox 0 setgray 9 /Helvetica-Bold F'
 Call Out ' 22 765 moveto ('||nf||') show 555 765 moveto'
 Call Out ' ('||nd||') show 282 765 moveto (Page) show 308 765 moveto'
 Call Out ' /pgstr 4 string def pgn pgstr cvs show'
End
If bopt Then Call Out ' 0 setgray 9 /Courier-Bold F } bind def'
Else Call Out ' 0 setgray 7 /Courier-Bold F } bind def'
Call Out ' 75 45 {dup mul exch dup mul add 1.0 exch sub } setscreen'
Call Out 'opg'
Call Out '/lm { 26 } def lm tm moveto'
Call Out '/saveobj save def'
Return
BADOPT:
If vrexx Then Signal BADOPT1
Say 'Bad option field!'
TELL:
If vrexx Then Signal TELL1
Say 'Format: 1UP filespec <B> <N>'
Say '                         <A>'
Say '                         <F>'
Say '                         <H>'
Say '        B - Bigger print'
Say '        N - Number lines'
Say '        A - ANSI controls'
Say "        F - don't Frame page"
Say '        H - no frame/Headers'
Exit
VREXXSET:
Call rxfuncadd 'VInit','VREXX','VINIT'
ini=Vinit()
If ini='ERROR' Then Signal FIN1
Signal On Halt name FIN1
Signal On Error name FIN1
Signal On Syntax name FIN1
Signal On Failure name FIN1
Return
BADOPT1:
mg.1='Bad option field!'
TELL1:
Call vdialogpos 50,40
mg.0=10
If mg.1='' Then mg.1='You MUST enter a filespec!  '
mg.2='Format: 1UP filespec <B> <N>    '
mg.3='                             <A>   '
mg.4='                             <F>   '
mg.5='                             <H>   '
mg.6='              B - Bigger print  '
mg.7='              N - Number lines  '
mg.8='              A - ANSI controls  '
mg.9="              F - don't Frame page  "
mg.10='              H - no frame/Headers   '
rb=vinputbox('1UP ERROR',mg,35,3)
If rb='OK' Then Do
 Parse var mg.vstring file opt opt1 .
 Signal AGAIN
End
FIN1:
Call Vexit
