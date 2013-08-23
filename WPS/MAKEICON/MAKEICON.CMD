/* Hi-Res Icon Installer */
signal on halt name Exit
call RxFuncAdd SysLoadFuncs, RexxUtil, SysLoadFuncs;
call SysLoadFuncs;
call SysCls
Parse upper Arg Param
say ""
say ""
say "Hi-Res Icons - by Martin Kiewitz for OS/2 Warp"
say ""
call CharOut, 'Setting Icons...'

call sysfiletree "NewIcons\*.ico", 'IconDir.', 'FO'
IconCount = IconDir.0
CurFileID = 1
Do Forever
   If IconCount==0 Then Leave

   CurIconFile = IconDir.CurFileID
   parse value CurIconFile With 'NewIcons\' CurIconObject '.ico'
   parse value CurIconObject With CurIconObject '.ICO'

   Select
    When CurIconObject=='TCPIP' Then CurIconObject  = "TCP/IP"
    When CurIconObject=='TCPIP8' Then CurIconObject = "TCP/IP8"
    When CurIconObject=='TCPIP_SHADOWS' Then CurIconObject = "TCP/IP_SHADOWS"
    Otherwise Nop
   End

   If SysSetObjectData('<'CurIconObject'>','ICONFILE='CurIconFile) Then
      call CharOut, '.'
     else
      call LineOut, 'Setting of Object 'CurIconObject' failed!'

   IconCount=IconCount-1
   CurFileID=CurFileID+1
End

/* Now process Folder-Animation-Icons... */

call sysfiletree "NewIcons\Anim\*.ico", 'IconDir.', 'FO'
IconCount = IconDir.0
CurFileID = 1
Do Forever
   If IconCount==0 Then Leave

   CurIconFile = IconDir.CurFileID
   parse value CurIconFile With 'NewIcons\Anim\' CurIconObject '.ico'
   parse value CurIconObject With CurIconObject '.ICO'

   Select
    When CurIconObject=='TCPIP' Then CurIconObject  = "TCP/IP"
    When CurIconObject=='TCPIP8' Then CurIconObject = "TCP/IP8"
    When CurIconObject=='TCPIP_SHADOWS' Then CurIconObject = "TCP/IP_SHADOWS"
    Otherwise Nop
   End

   If SysSetObjectData('<'CurIconObject'>','ICONNFILE=1,'CurIconFile) Then
      call CharOut, '.'
     else
      call LineOut, 'Setting of Object 'CurIconObject' failed!'

   IconCount=IconCount-1
   CurFileID=CurFileID+1
End
call LineOut, 'done.'

call LineOut, 'completed.'
