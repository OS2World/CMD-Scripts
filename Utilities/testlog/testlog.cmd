/**
 * @#D Azarewicz:2.9#@##1## 21 Aug 2014              DAZAR1    ::::::@@TestLog.Cmd (c) David Azarewicz 2014
 * V1.7 16-Sep-2011 changed APM.SYS to APM.ADD for ACPI log
 * V1.8 31-Dec-2011 Added current directory to search path
 * V1.9 02-Jan-2012 Added dsl file to log, fixed some errors
 * V2.0 29-Jan-2012 Added test for debug PSD in acpi log
 * V2.1 29-Feb-2012 Added Multimac r8110 logging
 * V2.2 20-Mar-2012 Added Multimac r8169, e1000e, nveth logging, removed r8110
 * V2.3 07-Sep-2012 Fixed search for PCI.EXE
 * V2.4 11-Nov-2012 Added support for Panorama
 * V2.5 16-Jul-2013 Added support for USB
 * V2.6 29-Jul-2013 Added support for AHCI
 * V2.7 01-Nov-2013 Added lantran.log to Multimac logs
 * V2.8 12-Jan-2013 Added SysInfo functions, usb device dump
 * V2.9 21-Aug-2014 Enhancements to ACPI logs
 * Written by David Azarewicz http://88watts.net
 */
TestLogVersion='2.9';
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

PARSE ARG TestId Arg2;

PARSE SOURCE Junk Junk CmdName;
CmdName=TRANSLATE(FILESPEC('name', CmdName));
select;
  when (CmdName='ACPILOG.CMD') then SysId='acpi';
  when (CmdName='UNIAUDLOG.CMD') then SysId='uniaud';
  when (CmdName='GENMACLOG.CMD') then SysId='genmac';
  when (CmdName='SANELOG.CMD') then SysId='sane';
  when (CmdName='PANORAMALOG.CMD') then SysId='panorama';
  when (CmdName='USBLOG.CMD') then SysId='usb';
  when (CmdName='AHCILOG.CMD') then SysId='ahci';
  otherwise do;
    SysId=TestId;
    TestId=Arg2;
  end;
end;

SysId=TRANSLATE(SysId);

ENV='OS2ENVIRONMENT';
Host=VALUE('HOSTNAME',,ENV);
if (Host = '') then Host = "Unknown";
MyDate=DATE('S');
HostDate=Host||'-'||MyDate;
HeaderLine='File created '||DATE('N')||' '||TIME('N')||' by testlog.cmd v'||TestLogVersion||' available at http://88watts.net';
BootDrive=SysBootDrive();
TmpDirSlash = STRIP(value('TMP',,ENV),'T','\') || '\';
EtcDir = STRIP(value('ETC',,ENV),'T','\');
LogFilesDir = STRIP(value('LOGFILES',,ENV),'T','\');
if (LogFilesDir = '') then LogFilesDir=BootDrive||'\var\log';
CurDir=Directory();
rc=VALUE('PATH', CurDir||';'||VALUE('PATH',,ENV), ENV);
/* find PCI.EXE */
PCIEXE=SysSearchPath('PATH', 'PCI.EXE');
if (PCIEXE='') then do;
  PCIEXE=BootDrive||'\ecs\install\DETECTEI\PCI.EXE';
  if (stream(PCIEXE,'c','query exists')='') then do;
    say "PCI.EXE not found";
    exit;
  end;
end;

'@echo off'
do while (QUEUED() <> 0); PULL; end;

select
  when (SysId="UNIAUD") then do
    say "Please type a short description of the test result (1 line):";
    PARSE PULL TestResult;
    MMBase = STRIP(value('MMBASE',,'OS2ENVIRONMENT'),'T',';');
    PkgVer = PkgVersion(MMBase||'\uniaud32.sys');
    if (TestId <> "") then PkgVer = PkgVer || "-" || TestId;
    LogFile = TmpDirSlash || HostDate || '-uniaud-' || PkgVer || '.log';
    rc=SysFileDelete(LogFile);
    rc=LINEOUT(LogFile, HeaderLine);
    rc=LINEOUT(LogFile, "Test result: " || TestResult);
    rc=LINEOUT(LogFile);
    rc = AddSysInfoToLogBeg(LogFile);
    rc = DoCommand(LogFile, 'bldlevel '||MMBase||'\uniaud32.sys');
    rc = DoCommand(LogFile, 'bldlevel '||MMBase||'\uniaud16.sys');
    rc = DoCommand(LogFile, 'unimix -card');
    rc = DoCommand(LogFile, 'unimix -list');
    rc = DoCommand(LogFile, 'unimix -pcms');
    rc = DoCommand(LogFile, 'unimix -powerget');
    rc = DoCommand(LogFile, 'type alsahlp$');
    rc = AddSysInfoToLogEnd(LogFile);
    say LogFile||" has been created.";
  end
  when (SysId = "GENMAC") then do
    PARSE VALUE SysIni( , 'Generic MAC Wrapper Driver', 'Path') WITH GMBase'0'x;
    IF ((GMBase = '') | (GMBase = 'ERROR:')) THEN DO
       SAY 'error: cannot find GenMac Installation.';
       exit;
    END
    say "Please type a short description of the test result (1 line):";
    PARSE PULL TestResult;
    PkgVer = PkgVersion(GMBase||'\driver\genm32w.os2');
    if (TestId <> "") then PkgVer = PkgVer || "-" || TestId;
    LogFile = TmpDirSlash || HostDate || '-genmac-' || PkgVer || '.log';
    ZipFile = TmpDirSlash || HostDate || '-genmac-' || PkgVer || '.zip';
    rc=SysFileDelete(LogFile);
    rc=LINEOUT(LogFile, HeaderLine);
    rc=LINEOUT(LogFile, "Test result: " || TestResult);
    rc=LINEOUT(LogFile);
    rc = AddSysInfoToLogBeg(LogFile);
    rc = DoCommand(LogFile, 'bldlevel '||GMBase||'\driver\genm32w.os2');
    rc = DoCommand(LogFile, 'type wrnddb$');
    rc = AddSysInfoToLogEnd(LogFile);
    say LogFile||" has been created.";
    'zip -j -q 'ZipFile' 'LogFile
    say ZipFile||" has been created.";
  end
  when (SysId="SANE") then do
    say "Please type a short description of the test result (1 line):";
    PARSE PULL TestResult;
    SaneBase = 'e:\programs\tame';
    PkgVer = 'V';
    if (TestId <> "") then PkgVer = PkgVer || "-" || TestId;
    LogFile = TmpDirSlash || HostDate || '-sane-' || PkgVer || '.log';
    rc=SysFileDelete(LogFile);
    rc=LINEOUT(LogFile, HeaderLine);
    rc=LINEOUT(LogFile, "Test result: " || TestResult);
    rc=LINEOUT(LogFile);
    rc = AddSysInfoToLogBeg(LogFile);
    'set SANE_DEBUG_microtek2=255';
    'set SANE_DEBUG_SANEI_USB=255';
    'set SANE_DEBUG_DLL=255';
    rc = DoCommand(LogFile, 'scanimage -L');
    'set SANE_DEBUG_microtek2=';
    'set SANE_DEBUG_SANEI_USB=';
    'set SANE_DEBUG_DLL=';
    rc = AddSysInfoToLogEnd(LogFile);
    say LogFile||" has been created.";
  end
  when (SysId = "ACPI") then do
    address CMD 'acpistat CheckDebugPSD >NUL 2>&1';
    if (rc > 0) then do;
      say "The debug version of the PSD is not running.";
      say "Please install the debug version of ACPI.PSD, reboot, and try again.";
      say "Press enter when ready...";
      pull Answer;
      exit;
    end;
    TmpStr = FileFromAcpiDaemonCfg('AcpiLog', 1);
    if (TmpStr <> '') then do
      say "The following line is in your acpid.cfg file: "||TmpStr;
      say "Please remove or comment out this line, reboot, and try again.";
      say "Press enter when ready...";
      pull Answer;
      exit;
    end
    say "Please type a short description of the test result (1 line):";
    PARSE PULL TestResult;
    PkgVer = PkgVersion(BootDrive||'\os2\boot\acpi.psd');
    if (TestId <> "") then PkgVer = PkgVer || "-" || TestId;
    LogDir = TmpDirSlash || 'acpilog.tmp';
    if (BootDrive='Z:') then do
      LogName = 'acpi.log';
      LogFile = LogDir ||'\'|| LogName;
      ZipFile = TmpDirSlash || 'acpi.zip';
    end
    else do
      LogName = HostDate || '-acpi-' || PkgVer || '.log';
      LogFile = LogDir ||'\'|| LogName;
      ZipFile = TmpDirSlash || HostDate || '-acpi-' || PkgVer || '.zip';
    end
    rc=SysMkDir(LogDir);
    call SysFileTree LogDir||'\*', 'file', 'FO'
    do i=1 to file.0
      call SysFileDelete file.i
    end
    rc=LINEOUT(LogFile, HeaderLine);
    rc=LINEOUT(LogFile, "Test result: " || TestResult);
    rc=LINEOUT(LogFile);
    rc = AddSysInfoToLogBeg(LogFile);
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\boot\acpi.psd');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\dll\acpi32.dll');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\boot\apm.add');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\acpidaemon.exe');
    rc = DoCommand(LogFile, 'type acpica$');
    rc=AddFileToLog(LogFile, EtcDir||'\acpid.cfg');
    TmpStr = FileFromAcpiDaemonCfg('LogFile', 0);
    if (TmpStr<>'') then rc=AddFileToLog(LogFile, TmpStr);
    rc = AddSysInfoToLogEnd(LogFile);
    rc=Directory(LogDir);
    if (stream(BootDrive||'\ecs\bin\acpidump.exe','c','query exists')='') then do
      rc = DoCommand(LogFile, 'iasl -g');
    end
    else do
      rc = DoCommand(LogFile, 'acpidump -s');
      address CMD 'acpidump -b >nul 2>&1';
      address CMD 'iasl -d facp.dat >nul 2>&1';
      address CMD 'iasl -d dsdt.dat >nul 2>&1';
    end
    rc=Directory(CurDir);
    call SysFileTree LogDir||'\*.dsl', 'file', 'FO'
    do i=1 to file.0
      rc=AddFileToLog(LogFile, file.i);
    end
    address CMD 'zip -j -q '||ZipFile||' '||LogDir||'\*';
    say ZipFile||" has been created.";
    address CMD 'copy '||LogFile||' '||TmpDirSlash||LogName||' >nul 2>&1';
    say TmpDirSlash||LogName||" has been created.";
    call SysFileTree LogDir||'\*', 'file', 'FO'
    do i=1 to file.0
      call SysFileDelete file.i
    end
    rc=SysRmDir(LogDir);
    do while (QUEUED() <> 0); PULL; end;
    say "Please attach the above ZIP file to your ticket. (See the ACPI readme).";
    say "Press enter when ready...";
    pull Answer;
  end
  when (SysId="R8169") | (SysId="E1000E") | (SysId="NVETH") then do
    say "Please type a short description of the test result (1 line):";
    PARSE PULL TestResult;
    PkgVer = PkgVersion(BootDrive||'\ibmcom\macs\'||SysId||'.os2');
    if (TestId <> "") then PkgVer = PkgVer || "-" || TestId;
    LogFile = TmpDirSlash || HostDate || '-'||SysId||'-' || PkgVer || '.log';
    rc=SysFileDelete(LogFile);
    rc=LINEOUT(LogFile, HeaderLine);
    rc=LINEOUT(LogFile, "Test result: " || TestResult);
    rc=LINEOUT(LogFile);
    rc = AddSysInfoToLogBeg(LogFile);
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\ibmcom\macs\'||SysId||'.os2');
    rc = DoCommand(LogFile, 'type '||SysId||'$');
    rc=AddFileToLog(LogFile, BootDrive||'\ibmcom\lantran.log');
    rc=AddFileToLog(LogFile, BootDrive||'\ibmcom\protocol.ini');
    rc = AddSysInfoToLogEnd(LogFile);
    say LogFile||" has been created.";
    say "Please attach the above LOG file to your ticket.";
  end
  when (SysId = "PANORAMA") then do
    say "Please type a short description of the test result (1 line):";
    PARSE PULL TestResult;
    PkgVer = PkgVersion(BootDrive||'\os2\dll\vbe2grad.dll');
    if (TestId <> "") then PkgVer = PkgVer || "-" || TestId;
    LogFile = TmpDirSlash || HostDate || '-panorama-' || PkgVer || '.log';
    rc=SysFileDelete(LogFile);
    rc=LINEOUT(LogFile, HeaderLine);
    rc=LINEOUT(LogFile, "Test result: " || TestResult);
    rc=LINEOUT(LogFile);
    rc = AddSysInfoToLogBeg(LogFile);
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\dll\vbe2grad.dll');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\dll\panogrex.dll');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\gradd.sys');
    rc = DoCommand(LogFile, 'PanoUtil -q -i -v -s');
    rc = AddFileToLog(LogFile, LogFilesDir||'\vbe2grad.log');
    rc = AddSysInfoToLogEnd(LogFile);
    say LogFile||" has been created.";
    say "Please attach the above LOG file to your ticket.";
  end
  when (SysId = "USB") then do
    say "Please type a short description of the test result (1 line):";
    PARSE PULL TestResult;
    PkgVer = PkgVersion(BootDrive||'\os2\boot\usbehcd.sys');
    if (TestId <> "") then PkgVer = PkgVer || "-" || TestId;
    LogFile = TmpDirSlash || HostDate || '-usb-' || PkgVer || '.log';
    rc=SysFileDelete(LogFile);
    rc=LINEOUT(LogFile, HeaderLine);
    rc=LINEOUT(LogFile, "Test result: " || TestResult);
    rc=LINEOUT(LogFile);
    rc = AddSysInfoToLogBeg(LogFile);
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\boot\usbehcd.sys');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\boot\usbohcd.sys');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\boot\usbuhcd.sys');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\boot\usbd.sys');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\boot\usbhid.sys');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\boot\usbcom.sys');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\boot\usbkbd.sys');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\boot\usbprt.sys');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\boot\usbmsd.add');
    rc = DoCommand(LogFile, 'bldlevel '||FileFromConfigSys('usbmouse.sys'));
    rc = DoCommand(LogFile, 'bldlevel '||FileFromConfigSys('amouse.sys'));
    rc = AddUsbDumpToLog(LogFile);
    rc = AddSysInfoToLogEnd(LogFile);
    say LogFile||" has been created.";
    say "Please attach the above LOG file to your ticket.";
  end
  when (SysId = "AHCI") | (SysId="DISK") then do
    say "Please type a short description of the test result (1 line):";
    PARSE PULL TestResult;
    PkgVer = PkgVersion(BootDrive||'\os2\boot\os2ahci.add');
    if (TestId <> "") then PkgVer = PkgVer || "-" || TestId;
    LogFile = TmpDirSlash || HostDate || '-ahci-' || PkgVer || '.log';
    rc=SysFileDelete(LogFile);
    rc=LINEOUT(LogFile, HeaderLine);
    rc=LINEOUT(LogFile, "Test result: " || TestResult);
    rc=LINEOUT(LogFile);
    rc = AddSysInfoToLogBeg(LogFile);
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\boot\os2ahci.add');
    rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2\boot\danis506.add');
    rc = DoCommand(LogFile, 'type os2ahci$');
    rc = DoCommand(LogFile, 'type ibms506$');
    rc = AddSysInfoToLogEnd(LogFile);
    say LogFile||" has been created.";
    say "Please attach the above LOG file to your ticket.";
  end
  otherwise do
    say 'testlog.cmd v'||TestLogVersion||' available at http://88watts.net';
    say "Usage: testlog <driver> [testid]";
    say "  where <driver> can be on of the following:";
    say "  uniaud genmac sane acpi r8169 nveth e1000e panorama usb ahci";
  end
end

rc=Directory(CurDir);
exit;

FileFromConfigSys: procedure expose BootDrive;
  parse upper arg SearchString;
  ConfigSys=BootDrive||'\config.sys';
  Line='';
  do while LINES(ConfigSys) <> 0;
    Line=STRIP(TRANSLATE(LINEIN(ConfigSys)));
    if (LEFT(Line,3)='REM') then iterate;
    if (POS(SearchString, Line) > 0) then leave;
  end;
  rc=stream(configSys,'c','close');
  if (Line='') then return Line;
  FileName = WORD(STRIP(SUBSTR(Line, POS('=',Line)+1)),1);
  return FileName;

DoCommand: procedure;
  parse arg LogFile, Cmd;
  Line = LEFT('----- Output of: '||Cmd||' ', 80, '-');
  rc=LINEOUT(LogFile, Line); rc=LINEOUT(LogFile);
  address CMD Cmd || ' 1>>'||LogFile||' 2>&1';
  RETURN(0);

PkgVersion: procedure;
  File = ARG(1);
  '@bldlevel 'File' 2>&1 | rxqueue'
  do while (QUEUED() > 0)
    PARSE PULL Line1':'Line2
    if (Line1 = "Revision") then leave;
    if (Line1 = "File Version") then leave;
    Line2 = "";
  end
  do while (QUEUED() <> 0); PULL; end;
  Return(STRIP(Line2,'B'));

CheckDebugVersion: procedure;
  File = ARG(1);
  address CMD '@bldlevel '||File||' 2>&1 | rxqueue'
  do while (QUEUED() > 0)
    PARSE PULL Line1':'Line2
    if (Line1 = "Signature") then leave;
    Line2 = "";
  end
  do while (QUEUED() <> 0); PULL; end;
  Return(POS("Debug", Line2));

FileFromAcpiDaemonCfg: procedure expose EtcDir;
  parse upper arg SearchString, ReturnLine;
  DaemonCfg=EtcDir||'\acpid.cfg';
  Line='';
  do while LINES(DaemonCfg) <> 0;
    Line=STRIP(LINEIN(DaemonCfg));
    if (LEFT(Line,1)=';') then iterate;
    if (LEFT(Line,1)='#') then iterate;
    if (LEFT(Line,1)='%') then iterate;
    if (POS(SearchString, TRANSLATE(Line)) > 0) then leave;
  end;
  rc=stream(DaemonCfg,'c','close');
  if (ReturnLine) then return Line;
  if (Line='') then return Line;
  FileName = WORD(STRIP(SUBSTR(Line, POS('=',Line)+1)),1);
  return FileName;

AddFileToLog: procedure;
  parse arg LogFile, FileName;

  Line = LEFT('----- Contents of file: '||FileName||' ', 80, '-');
  rc=LINEOUT(LogFile, Line);
  do while LINES(FileName) <> 0;
    rc=LINEOUT(LogFile, LINEIN(FileName));
  end;
  rc=LINEOUT(LogFile);
  rc=stream(FileName,'c','close');
  return 0;

AddSysInfoToLogBeg: procedure expose BootDrive;
  parse arg LogFile;
  rc = DoCommand(LogFile, 'dir /A '||BootDrive||'\os2*');
  rc = DoCommand(LogFile, 'bldlevel '||BootDrive||'\os2krnl');
  return 0;

AddSysInfoToLogEnd: procedure expose BootDrive PCIEXE;
  parse arg LogFile;
  rc = DoCommand(LogFile, PCIEXE||' -N');
  rc = DoCommand(LogFile, 'rmview -irq');
  rc = AddFileToLog(LogFile, BootDrive||'\CONFIG.SYS');
  return 0;

AddUsbDumpToLog: procedure;
  parse arg LogFile;

  signal on syntax name UsbError;
  rc=RxFuncAdd('UsbLoadFuncs', 'USBCALLS', 'USBLOADFUNCS');
  rc=UsbLoadFuncs();
  signal off syntax;

  Line = LEFT('----- USB Device List ', 80, '-');
  rc=LINEOUT(LogFile, Line);

  drop NumDevices;
  rc=RxUsbQueryNumberDevices(NumDevices);
  if (rc=0) then rc=LINEOUT(LogFile, NumDevices||' USB devices attached to the system');
  else do
    rc=LINEOUT(LogFile, 'Error quering number of devices');
    rc=LINEOUT(LogFile);
    return 0;
  end

  do d=1 to NumDevices
    rc=LINEOUT(LogFile, "Device "||d);
    drop Report;
    rc=RxUsbQueryDeviceReport(d, Report);
    if (rc\=0) then do
      rc=LINEOUT(LogFile, "  Query device failed. rc="||rc);
      iterate;
    end
    ReportLen=LENGTH(Report);
    Size=X2D(SUBSTR(Report,1,2));
    Type=X2D(SUBSTR(Report,3,2));
    if (Size\=18) | (Type\=1) then do
      rc=LINEOUT(LogFile, "  Bad descriptor Len="||Size||" Type="||Type);
      iterate;
    end
    DeviceClass=SUBSTR(Report,9,2);
    DeviceSubClass=SUBSTR(Report,11,2);
    DeviceProtocol=SUBSTR(Report,13,2);
    MaxPacketSize=SUBSTR(Report,15,2);
    Vendor=SUBSTR(Report,19,2)||SUBSTR(Report,17,2);
    Product=SUBSTR(Report,23,2)||SUBSTR(Report,21,2);
    NumConfigs=X2D(SUBSTR(Report,35,2));
    ManuString=X2D(SUBSTR(Report,29,2));
    ProductString=X2D(SUBSTR(Report,31,2));
    SerialString=X2D(SUBSTR(Report,33,2));
    rc=LINEOUT(LogFile, "  Class="||DeviceClass||" SubClass="||DeviceSubClass||" Protocol="||DeviceProtocol);
    rc=LINEOUT(LogFile, "  NumConfigs="||NumConfigs||" MaxPacketSize="||MaxPacketSize);
    rc=LINEOUT(LogFile, "  ID="||Vendor||":"||Product);
    rc=LINEOUT(LogFile, "    ManuString="||ManuString);
    rc=LINEOUT(LogFile, "    ProductString="||ProductString);
    rc=LINEOUT(LogFile, "    SerialString="||SerialString);
    NumItems=NumConfigs;
    ConfigIX=0;
    InterfaceIX=0;
    EndpointIX=0;
    Base=Size*2+1;
    do while (NumItems>0) & (Base < ReportLen)
      Size=X2D(SUBSTR(Report,Base+0,2));
      Type=X2D(SUBSTR(Report,Base+2,2));
      select
        when (Size=0) & (Type=0) then leave;
        when (Size=9) & (Type=2) then do /* configuration */
          ConfigIX=ConfigIX+1;
          NumItems=NumItems-1;
          rc=LINEOUT(LogFile, "  Configuration "||ConfigIX);
          Len=SUBSTR(Report,Base+6,2)||SUBSTR(Report,Base+4,2);
          NumInterfaces=X2D(SUBSTR(Report,Base+8,2));
          NumItems=NumItems+NumInterfaces;
          ConfigString=X2D(SUBSTR(Report,Base+12,2));
          rc=LINEOUT(LogFile, "    NumInterfaces="||NumInterfaces);
          rc=LINEOUT(LogFile, "    ConfigString="||ConfigString);
          InterfaceIX=0;
        end
        when (Size=9) & (Type=4) then do /* Interface */
          InterfaceIX=InterfaceIX+1;
          NumItems=NumItems-1;
          rc=LINEOUT(LogFile, "    Interface "||InterfaceIX);
          NumEndpoints=X2D(SUBSTR(Report,Base+8,2));
          NumItems=NumItems+NumEndpoints;
          InterfaceClass=X2D(SUBSTR(Report,Base+10,2));
          InterfaceSubClass=X2D(SUBSTR(Report,Base+12,2));
          InterfaceProtocol=X2D(SUBSTR(Report,Base+14,2));
          InterfaceString=X2D(SUBSTR(Report,Base+16,2));
          String='';
          if (InterfaceClass=1) then String=' Audio';
          if (InterfaceClass=2) then String=' Communication';
          if (InterfaceClass=3) then String=' HID';
          if (InterfaceClass=6) then String=' Image';
          if (InterfaceClass=7) then String=' Printer';
          if (InterfaceClass=8) then String=' MSD';
          if (InterfaceClass=14) then String=' Video';
          rc=LINEOUT(LogFile, "      InterfaceClass="||InterfaceClass||String);
          rc=LINEOUT(LogFile, "      InterfaceSubClass="||InterfaceSubClass);
          String='';
          if (InterfaceClass=3) then do
            if (InterfaceProtocol=1) then String=' Keyboard';
            if (InterfaceProtocol=2) then String=' Mouse';
          end
          rc=LINEOUT(LogFile, "      InterfaceProtocol="||InterfaceProtocol||String);
          rc=LINEOUT(LogFile, "      InterfaceString="||InterfaceString);
          rc=LINEOUT(LogFile, "      NumEndpoints="||NumEndpoints);
          EndpointIX=0;
        end
        when (Size=7) & (Type=5) then do /* Endpoint */
          EndpointIX=EndpointIX+1;
          NumItems=NumItems-1;
          rc=LINEOUT(LogFile, "      Endpoint "||EndpointIX);
          EndpointAddress=SUBSTR(Report,Base+4,2);
          Attributes=SUBSTR(Report,Base+6,2);
          MaxLen=SUBSTR(Report,Base+10,2)||SUBSTR(Report,Base+8,2);
          rc=LINEOUT(LogFile, "        Address=0x"||EndpointAddress);
          rc=LINEOUT(LogFile, "        Attributes=0x"||Attributes);
          rc=LINEOUT(LogFile, "        MaxPacketSize=0x"||MaxLen);
        end
        when (Size=9) & (Type=33) then do /* HID descriptor */
          rc=LINEOUT(LogFile, "      HID Descriptor Release Number=0x"||SUBSTR(Report,Base+2,4));
          rc=LINEOUT(LogFile, "        Country=0x"||SUBSTR(Report,Base+4,2));
          rc=LINEOUT(LogFile, "        NumClassDescriptors=0x"||SUBSTR(Report,Base+5,2));
          rc=LINEOUT(LogFile, "        ReportDescriptorType=0x"||SUBSTR(Report,Base+6,2));
          rc=LINEOUT(LogFile, "        TotalDescriptorLength=0x"||SUBSTR(Report,Base+7,2));
        end
        otherwise do
          rc=LINEOUT(LogFile, "      Descriptor: Type="||Type||" Size="||Size);
          TmpStr='       ';
          do i=0 to (Size-1)*2 by 2
            TmpStr=TmpStr||' '||SUBSTR(Report,Base+i,2);
          end
          rc=LINEOUT(LogFile, TmpStr);
        end
      end
      Base=Base+Size*2;
    end
  end

UsbError:
  rc=LINEOUT(LogFile);
  return 0;

