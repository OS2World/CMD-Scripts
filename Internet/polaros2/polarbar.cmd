/* OS/2 PolarBar startup */
Trace 'n'
Parse Source . . our_cmd .
our_path = Filespec('d',our_cmd)||Filespec('p',our_cmd)
If Length(our_path) > 3 Then our_dir = Strip(our_path,'t','\')
Else our_dir = our_path
Parse Arg run_opts
t = Pos('/Z',Translate(run_opts))
If t <> 0 Then Do
 pbm_zip = Strip(Word(Substr(run_opts,t + 2),1))
 run_opts = Space(Left(run_opts,t - 1) Subword(Substr(run_opts,t + 2),2))
End
Else pbm_zip = 'pbm125a.zip' /* default Polarbar zip file */
run_opts = Strip(run_opts)
t = Pos('MAILTO:',Translate(run_opts))
If (t <> 0) Then Do
 If Abbrev(Translate(run_opts),'-MAILTO') Then Do
  run_opts = '-mailto' '"'||Substr(run_opts,t + 7)||'"'
  run_opts = Changestr('%20',run_opts,' ')
  run_opts = Changestr('%3C',run_opts,'<')
  run_opts = Changestr('%3E',run_opts,'>')
  run_opts = run_opts
 End
 Else run_opts = '-mailto' Strip(Left(run_opts,t - 1))
End
Parse Value Jvm_find('PVM') With java_exe java_dir class_path pvm_dir pvm_java_dir .
class_path = pvm_java_dir||'\'||pbm_zip||';'||class_path
save_dir = Directory(our_dir)
Address cmd '@'||java_exe '-classpath' class_path 'org.polarbar.mailer' run_opts
Call Directory save_dir
Return

Changestr: Procedure
Parse Arg needle,haystack,newneedle,.
t = Pos(needle,haystack,1)
Do While t <> 0
 haystack = Overlay(newneedle,haystack,t,Length(newneedle))
 haystack = Left(haystack,t)||Substr(haystack,t + Length(needle))
 t = Pos(needle,haystack,t + Length(newneedle))
End
Return haystack

/* configuration */
Jvm_find: Procedure Expose our_dir
Arg test_appl .
java_exe = 'ERROR:'
/* check for java_home */
java_exe = Jvm_dir(Value('java_home',,'os2environment'),java_exe)
/* check the current path */
If java_exe = 'ERROR:' Then java_exe = Jvm_dir(SysSearchPath('path','java.exe'),java_exe)
If java_exe = 'ERROR:' Then Do
 /* check for InnoTek Java */
 j. = ''
 j.1 = 'OS2 Kit for Java'
 j.2 = 'OS2 Kit for Java SDK'
 j.0 = 2
 Do x = 1 To j.0 While java_exe = 'ERROR:'
  t_ver = Strip(SysIni('user',j.x,'CurrentVersion'),'t','00'x)
  If t_ver <> 'ERROR:' Then java_exe = Jvm_dir(Strip(SysIni('user',j.x,t_ver),'t','00'x),java_exe)
 End
End
/* check for Golden Code */
If java_exe = 'ERROR:' Then java_exe = Jvm_dir(Value('gcd_java_home',,'os2environment'),java_exe)
java_parms = 'ERROR:'
If java_exe <> 'ERROR:' Then Do
 java_dir = Strip(Filespec('d',java_exe)||Filespec('p',java_exe),'t','\')
 java_base = Left(java_dir,Lastpos('\',java_dir) - 1)
 class_path = Value('classpath',,'os2environment')
 If Right(class_path,1) <> ';' Then class_path = class_path||';'
 If Stream(java_base||'\lib\SecMA.jar','c','query exists') <> '' Then Do
  If Pos(Translate(java_base||'\lib\SecMA.jar'),Translate(class_path)) = 0 Then class_path = class_path||java_base||'\lib\SecMA.jar;'
 End
 If Stream(java_base||'\Swing\swingall.jar','c','query exists') <> '' Then Do
  If Pos(Translate(java_base||'\Swing\swingall.jar'),Translate(class_path)) = 0 Then class_path = class_path||java_base||'\Swing\swingall.jar;'
 End
 If Stream(java_base||'\lib\classes.zip','c','query exists') <> '' Then Do
  If Pos(Translate(java_base||'\lib\classes.zip'),Translate(class_path)) = 0 Then class_path = class_path||java_base||'\lib\classes.zip;'
 End
 Select
  When test_appl = 'TCP' Then Do
   test_exe = SysSearchPath('path','tcpstart.cmd')
   If test_exe <> '' Then Do
    tcp_dir = Strip(Filespec('d',test_exe)||Filespec('p',test_exe),'t','\')
    tcp_java_dir = Left(tcp_dir,Lastpos('\',tcp_dir))||'java'
    If Stream(tcp_java_dir||'\tcpauth.jar','c','query exists') <> '' Then Do
     tcp_lang = Value('tcplang',,'os2environment')
     If tcp_lang = '' Then tcp_lang = Value('lang',,'os2environment')
     If tcp_lang <> '' Then Do
      tcp_java_lang_dir = tcp_java_dir||'\'||tcp_lang
      If Stream(tcp_java_lang_dir||'\tcpares.jar','c','query exists') <> '' Then Do
       tcp_etc = Value('etc',,'os2environment')
       If tcp_etc <> '' Then java_parms = java_exe java_dir class_path tcp_dir tcp_java_dir tcp_lang tcp_java_lang_dir tcp_etc
       Else Say 'Unable to locate ETC'
      End
      Else Say 'Unable to locate TCP/IP Java' tcp_lang 'directory'
     End
     Else Say 'Unable to determine language'
    End
    Else Say 'Unable to locate TCP/IP Java directory'
   End
   Else Say 'Unable to locate TCP/IP directory'
  End
  When test_appl = 'LVM' Then Do
   test_exe = SysSearchPath('path','lvm.exe')
   If test_exe <> '' Then Do
    lvm_dir = Strip(Filespec('d',test_exe)||Filespec('p',test_exe),'t','\')
    lvm_java_dir = lvm_dir||'\javaapps'
    If Stream(lvm_java_dir||'\lvmgui.zip','c','query exists') <> '' Then java_parms = java_exe java_dir class_path lvm_dir lvm_java_dir
    Else Say 'Unable to locate LVMGUI Java directory'
   End
   Else Say 'Unable to locate LVMGUI directory'
  End
  When test_appl = 'GSK' Then Do
   test_exe = SysSearchPath('path','gskver.exe')
   If test_exe <> '' Then Do
    gsk_dir = Strip(Filespec('d',test_exe)||Filespec('p',test_exe),'t','\')
    gsk_java_dir = Left(gsk_dir, Lastpos('\',gsk_dir))||'classes'
    If Stream(gsk_java_dir||'\cssgkey.jar','c','query exists') <> '' Then java_parms = java_exe java_dir class_path gsk_dir gsk_java_dir
    Else Say 'Unable to locate IBMGSK Java directory'
   End
   Else Say 'Unable to locate IBMGSK directory'
  End
  When test_appl = 'GSK40' Then Do
   test_exe = SysSearchPath('path','gsk4ver.exe')
   If test_exe <> '' Then Do
    gsk_dir = Strip(Filespec('d',test_exe)||Filespec('p',test_exe),'t','\')
    gsk_java_dir = Left(gsk_dir, Lastpos('\',gsk_dir))||'classes'
    If Stream(gsk_java_dir||'\gsk4cls.jar','c','query exists') <> '' Then java_parms = java_exe java_dir class_path gsk_dir gsk_java_dir
    Else Say 'Unable to locate IBMGSK40 Java directory'
   End
   Else Say 'Unable to locate IBMGSK40 directory'
  End
  When test_appl = 'GSK50' Then Do
   test_exe = SysSearchPath('path','gsk5ver.exe')
   If test_exe <> '' Then Do
    gsk_dir = Strip(Filespec('d',test_exe)||Filespec('p',test_exe),'t','\')
    gsk_java_dir = Left(gsk_dir, Lastpos('\',gsk_dir))||'classes'
    If Stream(gsk_java_dir||'\gsk5cls.jar','c','query exists') <> '' Then java_parms = java_exe java_dir class_path gsk_dir gsk_java_dir
    Else Say 'Unable to locate IBMGSK50 Java directory'
   End
   Else Say 'Unable to locate IBMGSK50 directory'
  End
  When test_appl = 'PVM' Then Do
   test_exe = Stream(our_dir||'\polarbar.cmd','c','query exists')
   If test_exe <> '' Then Do
    pvm_dir = Strip(Filespec('d',test_exe)||Filespec('p',test_exe),'t','\')
    pvm_java_dir = pvm_dir
    java_parms = java_exe java_dir class_path pvm_dir pvm_java_dir
   End
   Else Say 'Unable to locate Polarbar directory'
  End
  Otherwise java_parms = 'ERROR:'
 End
End
Else Say 'Unable to locate java.exe'
If java_exe = 'ERROR:' Then Do
 Say 'Press any key to continue'
 Pull .
End
Return java_parms

Jvm_dir: Procedure
Parse Arg t_dir,t_exe,.
If Pos('.',t_dir) <> 0 Then t_dir = Left(t_dir,Lastpos('\',t_dir))
t_dir = Strip(t_dir,'t','\')
If t_dir <> '' Then Do
 If Stream(t_dir||'\java.exe','c','query exists') <> '' Then t_exe = t_dir||'\JAVA.EXE'
 Else Do
  If SysFileTree(t_dir||'\java.exe','t_file.','fso') = 0 Then Do
   If t_file.0 <> 0 Then t_exe = t_file.1
  End
 End
End
Return t_exe

