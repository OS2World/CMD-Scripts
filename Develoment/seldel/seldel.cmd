/* SELECTIVE DELETE OF OS/2 APPLETS */
/* Jeff Elkins - 10/92  */



CALL RxFuncAdd 'SysFileDelete', 'RexxUtil', 'SysFileDelete'
call RxFuncAdd 'VInit', 'VREXX', 'VINIT'


initcode = VInit()
if initcode = 'ERROR' then signal CLEANUP

signal on failure name CLEANUP
signal on halt name CLEANUP
signal on syntax name CLEANUP

dloop  = 1

errmsg.1 = 'File not found'
errmsg.2 = 'Path not found'
errmsg.3 = 'Access denied'
errmsg.4 = 'Not DOS disk'
errmsg.5 = 'Sharing violation'
errmsg.6 = 'Sharing buffer exceeded'
errmsg.7 = 'Invalid parameter'
errmsg.8 = 'Filename exceedes range error'

errnum.1 = 2
errnum.2 = 3
errnum.3 = 5
errnum.4 = 26
errnum.5 = 32
errnum.6 = 36
errnum.7 = 87
errnum.8 = 206




error_st = ' '


list.0  = 28
list.1  = 'Terminal emulation applet'
list.2  = 'Enhanced PM editor'
list.3  = 'System Editor'
list.4  = 'PMChart applet'
list.5  = 'Jigsaw Applet (Puzzle)'
list.6  = 'Solitaire applet'
list.7  = 'Cat and Mouse applet'
list.8  = 'Chess applet'
list.9  = 'Picture viewer'
list.10 = 'Pulse CPU graph'
list.11 = 'PM Seek'
list.12 = 'Reversi'
list.13 = 'Scramble applet'
list.14 = 'PM alarms'
list.15 = 'PM calculator'
list.16 = 'PM calender'
list.17 = 'PM planner archive'
list.18 = 'PM Diary'
list.19 = 'PM to-do archive'
list.20 = 'PM to-do list'
list.21 = 'PM tune editor'
list.22 = 'PM activities list'
list.23 = 'PM monthly planner'
list.24 = 'PM cardfile'
list.25 = 'PM database'
list.26 = 'PM spreadsheet'
list.27 = 'PM sticky notes'
list.28 = 'ALL PM Diary applets'


list.vstring = list.1          /* default selection */

DO WHILE dloop = 1
call VDialogPos 25, 25
rb =  VListBox('Selective delete of OS/2 applets', list, 35, 8, 3)
IF rb = 'CANCEL' then
 dloop = 0
 ELSE
 DO
  call DISP_WIN

  IF list.vstring = list.1  then call KILLTERM
  IF list.vstring = list.2  then call ENHANCED
  IF list.vstring = list.3  then call SYSED
  IF list.vstring = list.4  then call KILLCHRT
  IF list.vstring = list.5  then call JIGSAW
  IF list.vstring = list.6  then call KLONDIKE
  IF list.vstring = list.7  then call NEKO
  IF list.vstring = list.8  then call CHESS
  IF list.vstring = list.9  then call PICVIEW
  IF list.vstring = list.10 then call PULSE
  IF list.vstring = list.11 then call PMSEEK
  IF list.vstring = list.12 then call REVERSI
  IF list.vstring = list.13 then call SCRAMBLE
  IF list.vstring = list.14 then call PMDALARMS
  IF list.vstring = list.15 then call PMDCALC
  IF list.vstring = list.16 then call PMDCALEND
  IF list.vstring = list.17 then call PMPARC
  IF list.vstring = list.18 then call PMDIARY
  IF list.vstring = list.19 then call PMTDARC
  IF list.vstring = list.20 then call PMTDLIST
  IF list.vstring = list.21 then call PMTUNE
  IF list.vstring = list.22 then call PMACTLIST
  IF list.vstring = list.23 then call PMMPLAN
  IF list.vstring = list.24 then call PMCARD
  IF list.vstring = list.25 then call PMDATA
  IF list.vstring = list.26 then call PMSPREAD
  IF list.vstring = list.27 then call PMSTICKY
  IF list.vstring = list.28 then call ALLPMD

  
IF rc <> 0 then
   DO
     call GETERR
     msg.0 = 3
     msg.1 = ' '
     msg.2 = 'Error deleting ' list.vstring
     msg.3 = 'Error = ' error_st
     call VMsgBox 'File Error', msg, 1
   END
   VCloseWindow(id)
 END
END





 END



CLEANUP:
   call VExit
exit



DISP_WIN:

win.left   = 20
win.right  = 70
win.top    = 80
win.bottom = 40

id = VOpenWindow('Selective Delete', 'WHITE', win)

text.1 = 'Now deleting:'
text.2 = list.vstring

call VForeColor id, 'BLACK'
call VSetFont id, 'TIME', 24

x = 10
y = 900
do i = 1 to 2
   call VSay id, x, y, text.i
   y = y - 150
end

RETURN


GETERR:
 IF rc = 2   THEN error_st = errmsg.1
 IF rc = 3   THEN error_st = errmsg.2
 IF rc = 5   THEN error_st = errmsg.3
 IF rc = 26  THEN error_st = errmsg.4
 IF rc = 32  THEN error_st = errmsg.5
 IF rc = 36  THEN error_st = errmsg.6
 IF rc = 87  THEN error_st = errmsg.7
 IF rc = 206 THEN error_st = errmsg.8
RETURN





KILLTERM:
rc=SysFileDelete('\OS2\HELP\ANSI364.HLP')
rc=SysFileDelete('\OS2\HELP\ANSIIBM.HLP')
rc=SysFileDelete('\OS2\APPS\DLL\CTLSACDI.DLL')
rc=SysFileDelete('\OS2\APPS\CTLSACDI.EXE')
rc=SysFileDelete('\OS2\APPS\CUSTOM.MDB')
rc=SysFileDelete('\OS2\HELP\IBM31011.HLP')
rc=SysFileDelete('\OS2\HELP\IBM31012.HLP')
rc=SysFileDelete('\OS2\HELP\IBMSIO.HLP')
rc=SysFileDelete('\OS2\APPS\DLL\OACDISIO.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OANSI.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OANSI364.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OCHAR.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OCM.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OCOLOR.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OCSHELL.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\ODBM.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OFMTC.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OIBM1X.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OIBM2X.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OKB.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OKBC.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OKERMIT.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OLPTIO.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OMCT.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OMRKCPY.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OPCF.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OPM.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OPROFILE.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\ORSHELL.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OSCH.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OSIO.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OSOFT.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OTEK.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OTTY.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OVIO.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OVM.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OVT.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OXMODEM.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\OXRM.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\SACDI.DLL')
rc=SysFileDelete('\OS2\SYSTEM\SACDI.MSG')
rc=SysFileDelete('\OS2\APPS\DLL\SAREXEC.DLL')
rc=SysFileDelete('\OS2\APPS\SASYNCDA.SYS')
rc=SysFileDelete('\OS2\APPS\SASYNCDB.SYS')
rc=SysFileDelete('\OS2\APPS\SOFTERM.EXE')
rc=SysFileDelete('\OS2\HELP\SOFTERM.HLP')
rc=SysFileDelete('\OS2\HELP\VTTERM.HLP')
rc=SysFileDelete('\OS2\HELP\XRM.HLP')
rc=SysFileDelete('\OS2\APPS\ACSACDI.DAT')
RETURN

KILLCHRT:
rc=SysFileDelete('\OS2\APPS\FASHION.DAT')
rc=SysFileDelete('\OS2\APPS\FASHION.GRF')
rc=SysFileDelete('\OS2\APPS\GREEN.DAT')
rc=SysFileDelete('\OS2\APPS\GREEN.GRF')
rc=SysFileDelete('\OS2\APPS\INVEST.DAT')
rc=SysFileDelete('\OS2\APPS\INVEST.GRF')
rc=SysFileDelete('\OS2\APPS\DLL\MGXLIB.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\MGXVBM.DLL')
rc=SysFileDelete('\OS2\APPS\PMCHART.EXE')
rc=SysFileDelete('\OS2\HELP\PMCHART.HLP')
rc=SysFileDelete('\OS2\APPS\DLL\PMFID.DLL')
RETURN


JIGSAW:
 rc=SysFileDelete('\OS2\APPS\JIGSAW.EXE')
 rc=SysFileDelete('\OS2\HELP\JIGSAW.HLP')
RETURN

KLONDIKE:
rc=SysFileDelete('\OS2\APPS\KLONDIKE.EXE')
rc=SysFileDelete('\OS2\HELP\KLONDIKE.HLP')
rc=SysFileDelete('\OS2\APPS\CARDSYM.FON')
RETURN

ENHANCED:
rc=SysFileDelete('\OS2\APPS\BOX.EX')
rc=SysFileDelete('\OS2\APPS\DRAW.EX')
rc=SysFileDelete('\OS2\APPS\E3EMUL.EX')
rc=SysFileDelete('\OS2\APPS\EPM.EX')
rc=SysFileDelete('\OS2\APPS\EPM.EXE')
rc=SysFileDelete('\OS2\HELP\EPM.HLP')
rc=SysFileDelete('\OS2\APPS\EPMHELP.QHL')
rc=SysFileDelete('\OS2\APPS\EPMLEX.EX')
rc=SysFileDelete('\OS2\APPS\DLL\ETKE550.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\ETKR550.DLL')
rc=SysFileDelete('\OS2\APPS\DLL\ETKTHNK.DLL')
rc=SysFileDelete('\OS2\APPS\EXTRA.EX')
rc=SysFileDelete('\OS2\APPS\GET.EX')
rc=SysFileDelete('\OS2\APPS\HELP.EX')
RETURN


SYSED:
 rc=SysFileDelete('\OS2\E.EXE')
 rc=SysFileDelete('\OS2\DLL\EHXDLMRI.DLL')
 rc=SysFileDelete('\OS2\HELP\EHXHP.HLP')
RETURN

SCRAMBLE:
 rc=SysFileDelete('\OS2\APPS\DLL\SCRAMBLE.DLL')
 rc=SysFileDelete('\OS2\APPS\SCRAMBLE.EXE')
 rc=SysFileDelete('\OS2\HELP\SCRAMBLE.HLP')
 rc=SysFileDelete('\OS2\APPS\DLL\SCRCATS.DLL')
 rc=SysFileDelete('\OS2\APPS\DLL\SCRLOGO.DLL')
RETURN

REVERSI:
 rc=SysFileDelete('\OS2\APPS\DLL\REVERSI.DLL')
 rc=SysFileDelete('\OS2\APPS\REVERSI.EXE')
 rc=SysFileDelete('\OS2\HELP\REVERSI.HLP')
RETURN

PMSEEK:
 rc=SysFileDelete('\OS2\APPS\DLL\PMSEEK.DLL')
 rc=SysFileDelete('\OS2\APPS\PMSEEK.EXE')
 rc=SysFileDelete('\OS2\HELP\PMSEEK.HLP')
RETURN

CHESS:
 rc=SysFileDelete('\OS2\APPS\OS2CHESS.BIN')
 rc=SysFileDelete('\OS2\APPS\OS2CHESS.EXE')
 rc=SysFileDelete('\OS2\HELP\OS2CHESS.HLP')
 rc=SysFileDelete('\OS2\APPS\DLL\CHESSAI.DLL')
RETURN

NEKO:
 rc=SysFileDelete('\OS2\APPS\DLL\NEKO.DLL')
 rc=SysFileDelete('\OS2\APPS\NEKO.EXE')
 rc=SysFileDelete('\OS2\HELP\NEKO.HLP')
RETURN

PULSE:
 rc=SysFileDelete('\OS2\APPS\PULSE.EXE')
 rc=SysFileDelete('\OS2\HELP\PULSE.HLP')
RETURN

PICVIEW:
 rc=SysFileDelete('\OS2\DLL\PICV.DLL')
 rc=SysFileDelete('\OS2\APPS\DLL\PICVIEW.DLL')
 rc=SysFileDelete('\OS2\APPS\PICVIEW.EXE')
 rc=SysFileDelete('\OS2\HELP\PICVIEW.HLP')
RETURN

PMDALARMS:
 rc=SysFileDelete('\OS2\APPS\PMDALARM.EXE')
RETURN

PMDCALC:
 rc=SysFileDelete('\OS2\APPS\PMDCALC.EXE')
RETURN

PMDCALEND:
 rc=SysFileDelete('\OS2\APPS\PMDCALEN.EXE')
RETURN

PMPARC:
 rc=SysFileDelete('\OS2\APPS\PMDDARC.EXE')
RETURN

PMDIARY:
 rc=SysFileDelete('\OS2\APPS\PMDDIARY.EXE')
RETURN

PMTDARC:
 rc=SysFileDelete('\OS2\APPS\PMDTARC.EXE')
RETURN

PMTDLIST:
 rc=SysFileDelete('\OS2\APPS\PMDTODO.EXE')
RETURN

PMTUNE:
 rc=SysFileDelete('\OS2\APPS\PMDTUNE.EXE')
RETURN

PMACTLIST:
 rc=SysFileDelete('\OS2\APPS\PMDLIST.EXE')
RETURN

PMMPLAN:
 rc=SysFileDelete('\OS2\APPS\PMDMONTH.EXE')
RETURN

PMCARD:
 rc=SysFileDelete('\OS2\APPS\PMDNOTE.EXE')
RETURN

PMDATA:
rc=SysFileDelete('\OS2\APPS\PMMBASE.EXE')
RETURN

PMSPREAD:
 rc=SysFileDelete('\OS2\APPS\PMSPREAD.EXE')
RETURN

PMSTICKY:
 rc=SysFileDelete('\OS2\APPS\PMSTICKY.EXE')
 rc=SysFileDelete('\OS2\APPS\DLL\PMSTICKD.DLL')
RETURN


ALLPMD:
 rc=SysFileDelete('\OS2\APPS\PMDALARM.EXE')
 rc=SysFileDelete('\OS2\APPS\PMDCALC.EXE')
 rc=SysFileDelete('\OS2\APPS\PMDCALEN.EXE')
 rc=SysFileDelete('\OS2\APPS\PMDDARC.EXE')
 rc=SysFileDelete('\OS2\APPS\PMDDIARY.EXE')
 rc=SysFileDelete('\OS2\APPS\PMDLIST.EXE')
 rc=SysFileDelete('\OS2\APPS\PMDMONTH.EXE')
 rc=SysFileDelete('\OS2\APPS\PMDNOTE.EXE')
 rc=SysFileDelete('\OS2\APPS\PMDTARC.EXE')
 rc=SysFileDelete('\OS2\APPS\PMDTODO.EXE')
 rc=SysFileDelete('\OS2\APPS\PMDTUNE.EXE')
 rc=SysFileDelete('\OS2\APPS\PMMBASE.EXE')
 rc=SysFileDelete('\OS2\APPS\PMSPREAD.EXE')
 rc=SysFileDelete('\OS2\APPS\PMSTICKY.EXE')
 rc=SysFileDelete('\OS2\APPS\DLL\PMSTICKD.DLL')
 rc=SysFileDelete('\OS2\APPS\DLL\PMDIARYF.DLL')
 rc=SysFileDelete('\OS2\APPS\PMDIARY.$$A')
 rc=SysFileDelete('\OS2\APPS\DLL\PMDIARY.DLL')
 rc=SysFileDelete('\OS2\HELP\PMDIARY.HLP')
 rc=SysFileDelete('\OS2\APPS\DLL\PMDCTLS.DLL')
RETURN


