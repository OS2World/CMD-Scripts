� �� 0�  d   Mainh  usei  use1f  IPg  Versionj  Frame1�   Settings�  Option1�  Option2�  LogFile1�  LogFile2�  
ComandText�  
ComandLine�  ComandLine_2> RefreshText�  Refresh?  7 Textsize�  
TextSizeIs6 Option38 Option49 Option5; Option6< Option7�  AtNewIP_Prog�  SettingsQuit�  SettingStatus�  SettingsSave�  Frame2= Frame55 Frame3: Frame4,  	AboutForm. 	AboutText0 AboutText_21 AboutText_32 AboutText_4/ OK3  ��� 0y  Show_Version�/*Clear RXQUEUE*/
DO WHILE LINES("QUEUE:") > 0
 objecttext = linein("QUEUE:")
END

/* IF big frame then show version */
IF (ProgSize==0)  & (ProgSizeStan==0) THEN DO
   /*Get Version from GeiMyIP.EXE*/
   "@GetMyIP /V | RXQUEUE"
   objecttext = linein("QUEUE:")
   call main.use1.text (objecttext)

   /*Clear RXQUEUE*/
   DO WHILE LINES("QUEUE:") > 0
    objecttext = linein("QUEUE:")
   END
END
iniProgPos�/* Settings */
IF setup == 0 THEN DO
   call main.IP.Font(IPFont)
   IF ProgSize==1 THEN DO
      call main.use.visible 0
      call main.use1.visible 0
      call main.frame1.visible 0
      call main.version.visible 0
      /* Pos */
      x = ipx
      y = ipy - 25
      cx = ipcx 
      cy = ipcy 
      CALL Main.Ip.Position x,y,cx,cy
      call Main.text(GlobalName)
      x = mainx
      y = mainy
      cx = maincx 
      cy = maincy - 110
      CALL Main.Position x,y,cx,cy
   END

   IF ProgSizeStan==1 THEN DO
      call main.use.visible 0
      call main.use1.visible 0
      call main.frame1.visible 0
      call main.version.visible 0
      /* Pos */
      x = ipx
      y = ipy - 40
      cx = ipcx 
      cy = ipcy / 4
      cy=FORMAT(cy, ,0) 
      CALL Main.Ip.Position x,y,cx,cy
      call Main.text(GlobalName || "  at  Stan's mode" )
      x = mainx
      y = mainy
      cx = maincx 
      cy = maincy - 200
      CALL Main.Position x,y,cx,cy
   END

   IF (ProgSize==0)  & (ProgSizeStan==0) THEN DO
      call main.use.visible 1
      call main.use1.visible 1
      call main.frame1.visible 1
      call main.version.visible 1
      /* Pos */
      x = ipx
      y = ipy
      cx = ipcx 
      cy = ipcy 
      CALL Main.Ip.Position x,y,cx,cy
      call Main.text(GlobalName)
      x = mainx
      y = mainy
      cx = maincx 
      cy = maincy 
      CALL Main.Position x,y,cx,cy
  END
call Show_Version
ENDLOAD_INI_STRING�	/* Load the INI from file to variables */

INI=installpath || "GetMyIP.INI"
/* Cleer all */
OPT1 = ""
OPT1_S = 0
OPT2 = ""
OPT2_S = 0
comand_in = ""
comand_2_in = ""
IPFont="14.Helvetica Bold"
ProgSize = 0
ProgSizeStan = 0	
OnlyIP = 0
AtNewIPOpt1=0
AtNewIPOpt2=0
AtNewIPProg=""
RefreshAll=300

/* Read File */
Ret = STREAM(INI,'C',"OPEN READ")
IF Ret == "READY:" then DO
   OPT1 = Linein(INI)
   OPT1_S = Linein(INI)
   OPT2 = Linein(INI)
   OPT2_S = Linein(INI)
   comand_in = Linein(INI)
   comand_2_in = Linein(INI)
   mainx = Linein(INI)
   mainy = Linein(INI)
   IPFont=Linein(INI)
   ProgSize=Linein(INI)
   OnlyIP=Linein(INI) 
   ProgSizeStan=Linein(INI)
   AtNewIPOpt1=Linein(INI)
   AtNewIPOpt2=Linein(INI)
   AtNewIPProg=Linein(INI)
   
RefreshAll=Linein(INI)
   if RefreshAll=="" then do
	RefreshAll=300
   end
   if RefreshAll<30 then do
	RefreshAll=30
   end
   if RefreshAll>3200 then do
	RefreshAll=3200
   end

   if setup == 0 then do
        CALL Main.Position mainx,mainy,maincx,maincy
   end
   if first == 1 then do
        PARSE VALUE main.ip.Position() WITH ipx ipy ipcx ipcy
        first=0
   end   
   call iniProgPos	
END
Ret = STREAM(INI,'C',"CLOSE")
setup = 0


LOAD_INI�/* Load the INI to GUI*/
/* LOAD INI */
call LOAD_INI_STRING
/* Save to Program */
IF OPT1 == "" THEN OPT1 = "GetMyIP.LOG"
call LogFile1.Text(OPT1)
call Option1.Select(OPT1_S)
IF OPT2 == "" THEN OPT2 = "GetMyIP.LOG"
call LogFile2.Text(OPT2)
call Option2.Select(OPT2_S)
call ComandLine.Text(comand_in )
call ComandLine_2.Text(comand_2_in )
call Option3.Select(ProgSize)
call Option4.Select(OnlyIP)
call Option5.Select(ProgSizeStan)
call TextSizeIs.text(IPFont)
call Option6.Select(AtNewIPOpt1)
call Option7.Select(AtNewIPOpt2)
call AtNewIP_Prog.Text(AtNewIPProg)
call Refresh.Text(RefreshAll)
SAVE_INI�/* Save the INI */
INI=installpath || "GetMyIP.INI"
CALL SettingStatus.Text(INI)
comand_2_in=Settings.ComandLine_2.Text()
call SysFileDelete INI
CALL SettingStatus.Text("Delete: INI")
Ret = STREAM(INI,'C',"OPEN WRITE")
CALL SettingStatus.Text("Open: " || INI)
call charout INI, OPT1 || crlf
call charout INI, OPT1_S  || crlf
call charout INI, OPT2 || crlf
call charout INI, OPT2_S  || crlf
call charout INI, comand_in  || crlf
call charout INI, comand_2_in  || crlf
/* POS */
PARSE VALUE Main.Position() WITH x y cx cy
call charout INI, x  || crlf
call charout INI, y  || crlf
/* LOOK */
call charout INI,TextSizeIs.Text() || crlf
call charout INI,Settings.Option3.Select() || crlf
call charout INI,Settings.Option4.Select() || crlf
call charout INI,Settings.Option5.Select() || crlf
/* At new IP */
call charout INI,Settings.Option6.Select() || crlf
call charout INI,Settings.Option7.Select() || crlf
call charout INI,AtNewIP_Prog.Text() || crlf
/*Refreshtime for IP*/
call charout INI,Refresh.Text()||crlf

CALL SettingStatus.Text("Close: " || INI)
Ret = STREAM(INI,'C',"CLOSE")
build_command�/*Build the Comandstring*/
Comand_String= ""
OPT1=Settings.LogFile1.Text()
OPT1_S=Settings.Option1.Select()
IF OPT1 == "GetMyIP.LOG" THEN OPT1 = ""
IF OPT1_S = 1 THEN Comand_String = Comand_String || "/L:" || OPT1 || " " 
OPT2=Settings.LogFile2.Text()
OPT2_S=Settings.Option2.Select()
IF OPT2 == "GetMyIP.LOG" THEN OPT2 = ""
IF OPT2_S = 1 THEN Comand_String = Comand_String || "/l:" || OPT2 || " " 

Settings.ComandLine.Text(Comand_String)
comand_in = Comand_String
comand_2_in=Settings.ComandLine_2.Text()READ_IP_ALL5M�/*Get IP with GeiMyIP.EXE*/
pulltime = Time();
Comand_line = comand_in  || " " || comand_2_in
IF Comand_line <> "" then
  "@GetMyIP " || Comand_line || " | RXQUEUE"
IF Comand_line = "" then
  "@GetMyIP | RXQUEUE"
objecttext = linein("QUEUE:")
if oldip \= objecttext then do
  call IP.Color  "+", "#255 0 0"
  if AtNewIPOpt1==1 then
    if (AtNewIPOpt2==1) & (first1==1) then 
       nop 
    else 
       ADDRESS CMD START AtNewIPProg objecttext
end
if oldip == objecttext then
  call IP.Color "+", "#0 0 255"
oldip = objecttext
if OnlyIP == 0 then
 call IP.text(objecttext || " @ " || pulltime)
if OnlyIP == 1 then 
 call IP.text(objecttext )
/*Clear RXQUEUE*/
DO WHILE LINES("QUEUE:") > 0
  objecttext = linein("QUEUE:")
END
First1=0�� �d   �  �  �  ��          � �  �� j � d d ���         � �? P ( 	 h � ��        k � D � 
 i p��        �E�  � ( f ���        {�  � 	 g ���          �  � 3 j ��DrDialog: An Oberon Program    Text �      x   9.WarpSans                                                                                                              Text �      x   9.WarpSans                                                                                                              IP �                         `   14.Helvetica Bold                                                                               Version �               l   7.Courier                                                                                                   Group �                        `   9.WarpSans                                                                                      � �d 0Y   Y   �      Refresh 
   �       Setup 
   �       Help    �      About ���d 0�    Refresh(/*Read new IP */
call READ_IP_ALL5M; 
 Setup/* Setup */
CALL Settings.Open 	Help_Main  About)/* Open AboutForm */
call AboutForm.Open���d 0�  �d Timer�/*Stop Timer */
CALL Main.Timer
/*Read new IP */
call READ_IP_ALL5M 
/*Wait RefreshAll */
 if RefreshAll>3200 then RefreshAll=3200 /* and not more*/

 waitTime = RefreshAll - (time("s") // RefreshAll)
 call Main.Timer waitTime*1000
Init�1/**************************************************************************/
/*                                           GetMyIP_GUI                                                                                                     */ 
/*                     by Peter Lueersen <Peter.Lueersen@warp-ecs-owl.de>                                          */
/*                                              V 1.0.8                                                                                                             */
/**************************************************************************/
/* This program is free software                                                                                                                 */
/* you can redistribute it and/or modify it under the terms of the GNU General Public License   */
/* as published by the Free Software Foundation; either version 2 of the License,                       */
/* or (at your option) any later version.                                                                                                   */
/*                                                                                                                                                                        */
/* This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY  */
/* without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      */ 
/* PURPOSE.    See the GNU General Public License for more details.                                               */
/*                                                                                                                                                                        */
/* You should have received a copy of the GNU General Public License along with this program*/  
/* if not, write to the                                                                                                                                       */
/* Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA */  
/***************************************************************************/
/*- Modification History                                                                                                                                -*/
/*-                                                                                                                                                                      -*/
/*-   VERSION        DATE         AUTHOR                                                                                                         -*/
/*-                                                                                                                                                                      -*/
/*-   V1.0.8      27.08.2006      Peter Lueersen                                                                                          -*/
/*-         New setting Refresh IP all XXX s                                                                                                  -*/
/*-   V1.0.7       04.08.2006    Peter Lueersen                                                                                          -*/
/*-         New Version only                                                                                                                            -*/
/*-   V1.0.6       15.06.2006    Peter Lueersen                                                                                          -*/
/*-         Version                                                                                                                                              -*/
/*-   V1.0.6�3   25.05.2006    Peter Lueersen                                                                                          -*/
/*-   	New call Program by new IP                                                                                                         -*/
/*-   V1.0.6�2   25.05.2006    Peter Lueersen                                                                                          -*/
/*-   	New setting small size Stan's style                                                                                            -*/
/*-   V1.0.6�1   25.05.2006    Peter Lueersen                                                                                          -*/
/*-   	New setting Font                                                                                                                              -*/
/*-   	New setting small size                                                                                                                   -*/
/*-   	New setting Show only IP                                                                                                             -*/
/*-   V1.0.5        17.05.2006    Peter Lueersen                                                                                          -*/
/*-   	First version of the code.                                                                                                               -*/
/*-                                                                                                                                                                     -*/
/*-------------------------------------------------------------------------*/


/* Beschriftungen */
Globalver = ' 1.0.8 '
GlobalName = 'GetMyIP GUI '
GlobalAutor = 'by Peter Lueersen'
call Main.text(GlobalName )
call Version.text(GlobalName || GlobalAutor || " Ver.: " || Globalver)
call use.text("use:")
call Frame1.text(" My IP is now ")

/* Init Path and co */
parse source . . ScriptFile
inst_drive = filespec("D", ScriptFile)
inst_path = filespec("P", scriptfile)
installpath=inst_drive||inst_path
crlf = "0d0a"x
oldip = "0.0.0.0"
first=1
first1=1
setup = 0

/* Pos */
PARSE VALUE main.Position() WITH mainx mainy maincx maincy

/* init RexxUtil */
if rxfuncquery('SysLoadFuncs') then do
 call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
 call SysLoadFuncs
end

/* Load INI*/
call LOAD_INI_STRING

/* Schow Programversion */
call Show_Version

/*1.Start Timer */
 waitTime = 1
 call Main.Timer waitTime
�� �� 0m	  m	  �  ��            �� T � � � ��#        ' �	 � < 	 � -��        � �	 � = 	 � ���        	 �H � W  � 7        ? �H � W  � Em        u �	 � `  � z��        �, �
 w �  � �         �
 l �  � "�        ��	 Y = 	 >���        � �K Z &  � ���        � �t Y  	 ?���        �� F 9 	 7���       
 7 �C H [  � B��        | � ; K 	 6���        � � 1 K 	 8���        � �S ; P 	 9���        # �  J 	 ;)��        L �U  M 	 <R��        u �  �  � {��        �  �  ( 
 � ���        �  .  N 
 � ��        Y  �}  ( 
 � ^��        �  � h � = � ���        	  � V �  =	��        %	  � / � ' 5+	��        I	  �  �  :O	��Settings    Check g               S   9.WarpSans                                                                         Check g               S   9.WarpSans                                                                         Entry $                   8.Helvetica      �     Entry $                   8.Helvetica      �     Text h               T   9.WarpSans                                                                          Entry $                   8.Helvetica      �     Entry h                T   9.WarpSans                                                                           �     Text          8.Helvetica     Entry          8.Helvetica     s          8.Helvetica     Text 7      /   9.WarpSans                                     TextSizeIs 6      .   9.WarpSans                                    Check 7      /   9.WarpSans                                     Check *      "   9.WarpSans                        Check (          9.WarpSans                      Check          9.WarpSans             Check          9.WarpSans             Entry !         9.WarpSans               Push S                ?   9.WarpSans                                                     Text T                @   9.WarpSans                                                      Push o                [   9.WarpSans                                                                                 Group &                  8.Helvetica       Group          8.Helvetica       Group          8.Helvetica       Group          8.Helvetica       ���� 0�  �� Init�/* Pos */
setup = 1
PARSE VALUE main.Position() WITH x y cx cy
CALL Settings.Position x,y
/* Beschriftungen und co */
call Settings.Text("Settings")
call SettingsSave.Text("Save")
call SettingsQuit.Text("Quit")
call ComandLine.Text("")
call ComandLine_2.Text("")
call ComandLine.Range(256)
call ComandLine_2.Range(256)
call ComandText.Text("ControlOptions:")
call Option1.Text("/L: log last IP to")
call Option2.Text("/l: log all IPs to")
call Option3.Text("Small Form")
call Option4.Text("Show only IP")
call Option5.Text("Small Form Stan's Style")
call Option6.Text("Run at IP change")
call Option7.Text("but not at programstart")
call LogFile1.Text("GetMyIP.LOG")
call LogFile2.Text("GetMyIP.LOG")
call Frame2.Text(" Log File ")
CALL SettingStatus.Text("")
call Frame3.Text(" Look of " || GlobalName)
call TextSize.Text("Text size")
call Frame4.Text(" Actions ")
call Frame5.Text("Refresh")
call RefreshText.Text("Refresh IP all ")
call AtNewIP_Prog.Text("")
call AtNewIP_Prog.Range(256)

/*INI wiederherstellen*/
call LOAD_INI

�� Click�/* Save Settings and close */
CALL SettingStatus.Visible(1)
CALL SAVE_INI
CALL SettingStatus.Visible(0)
/* Refresh neu Settings */
call LOAD_INI
CALL Settings.Close�� Click /* close */
CALL Settings.Close�9Click�/* Disable check box 5 if the check box 3 is selected: */
IF Option5.Select() = 1 THEN DO
  CALL Option3.Select 0
  call Settings.TextSizeIs.text("14.Helvetica Bold")
end
IF Option5.Select() = 0 THEN DO
  call Settings.TextSizeIs.text(IPFont)
end

 
�6Clicko/* Disable check box 5 if the check box 3 is selected: */
IF Option3.Select() = 1 THEN CALL Option5.Select 0
�� 	LoseFocusCall build_command
�� 	LoseFocusCall build_command
�� Click�/* Disable check box 1 if the check box 2 is selected: */
IF Option2.Select() = 1 THEN CALL Option1.Select 0
Call build_command
�� Click�/* Disable check box 2 if the check box 1 is selected: */
IF Option1.Select() = 1 THEN CALL Option2.Select 0
Call build_command

�� �,0[  [  �  ��          � �  �� j � d ,���         � E� I �  .� ��        : � ; �  0?��        w � + �  1|��        � �  �  2���        �  �?  ( 
 /���         /  �  � G 30��<untitled dialog>    Text ;                           16.Helvetica Bold          Text 4                           9.WarpSans          Text 4                           9.WarpSans          Text 4                           9.WarpSans          Push 5                            9.WarpSans            '                  9.WarpSans         ���,0�  �,Init�/* Pos */
PARSE VALUE main.Position() WITH x y cx cy
CALL AboutForm.Position x,y
/* Beschriftungen */
CALL AboutForm.Text(" About ")
CALL AboutText.text(GlobalName)
CALL AboutText_2.text(GlobalAutor || " Version:  " || Globalver )
CALL AboutText_3.text("http://www.warp-ecs-owl.de")
CALL AboutText_4.text( "mailto: Peter@warp-ecs-owl.de")
CALL OK.Text(" OK ")�/Click /* Exit */
CALL AboutForm.Close�