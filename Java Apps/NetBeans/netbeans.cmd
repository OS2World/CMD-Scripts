/*
 *                 Sun Public License Notice
 * 
 * The contents of this file are subject to the Sun Public License
 * Version 1.0 (the "License"). You may not use this file except in
 * compliance with the License. A copy of the License is available at
 * http://www.sun.com/
 * 
 * The Original Code is NetBeans OS/2 Launcher. 
 * The Initial Developer of the Original Code is Laszlo Kishalmi. 
 * Portions Copyright 2004-2004 Laszlo Kishalmi. All Rights Reserved.
 */
call RXFUNCADD "SysLoadFuncs", "RexxUtil", "sysloadfuncs";
call SysLoadFuncs;

PARSE ARG nb_args
parse source . . prg_name

n = setlocal()
ENV = "OS2ENVIRONMENT"

tmpdir = value("tmp",,ENV)

progdir = directory(FILESPEC("drive", prg_name)||FILESPEC("path", prg_name)||"..");

call_os2install = 0
netbeans_default_options = ""
nb_args = parse_args(nb_args)

call parse_conf

if call_os2install then do
  call os2install
  n = endlocal()
  exit
end
  
if (symbol("netbeans_clusters") = "LIT") then 
  netbeans_clusters=progdir||'\nb5.0;'||progdir||'\ide6'
if (directory(progdir||'\enterprise2') = progdir||'\enterprise2') then
  netbeans_clusters=netbeans_clusters||';'||progdir||'\enterprise2'
if (directory(progdir||'\extra') = progdir||'\extra') then
  netbeans_clusters=netbeans_clusters||';'||progdir||'\extra'
if (symbol("netbeans_extraclusters") = "VAR") then 
  netbeans_clusters=netbeans_clusters||';'||netbeans_extraclusters
  
nb_args = netbeans_default_options || " " || nb_args

if (symbol("netbeans_default_userdir") = "VAR") then
  nb_args = "--userdir " || netbeans_default_userdir || " " || nb_args
if (symbol("netbeans_jdkhome") = "VAR") then 
  nb_args = "--jdkhome " || netbeans_jdkhome || " " || nb_args 

say progdir
platdir = directory(progdir||"\platform6\lib")
say platdir

nb_args='-J-Dnetbeans.importclass=org.netbeans.upgrade.AutoUpgrade -J-Dnetbeans.accept_license_class=org.netbeans.license.AcceptLicense --branding nb --clusters '||netbeans_clusters||' '||nb_args
__launcher = 'call "'||platdir||'\nbexec.cmd" (nb_args)'
interpret __launcher
n = endlocal()
exit rc

parse_conf:
  do while LINES(progdir||'\etc\netbeans.conf') > 0
    S = STRIP(LINEIN('etc\netbeans.conf'));
    if (\((left(S, 1) = "#") | (LENGTH(S) = 0))) then do
      S = replace_env(S)
      interpret S;
    end
  end
return

parse_args: 
  ideargs = arg(1)
  args = ''
  DO I = 1 to WORDS(ideargs)
  	param = WORD(ideargs, I);
  	select
      when (param = "-?") | (param = "-h") | (param = "--help") | (param = "-help") then do
        netbeans_os2opt = VALUE("netbeans_os2opt", "  --os2-install         install desktop folder and icons for NetBeans", ENV);
        args = args || " " || param
	  end
	  when (param = "--os2-install") then do
	    call_os2install = 1
	  end
	  otherwise do
	    args = args || " " || param
      end
  	end
  end
return args

replace_env: procedure
  is = arg(1);
  do while POS("${", is) > 0 
    _var_start = POS("${", is)  
    _var_end   = POS("}", is, _var_start)
    _var = substr(is, _var_start + 2, _var_end - _var_start - 2)
    _var_val = _var
    if (symbol(_var) = "VAR") then _var_val = VALUE(_var)
    else _var_val = VALUE(_var,, "OS2ENVIRONMENT")
    is = substr(is, 1, _var_start - 1) || _var_val || substr(is, _var_end + 1)
  end
  is = translate(is, '\', '/')
return is

os2install:
  
  '@unzip -n '||progdir||'\nb5.0\nbos2icons.zip -d '||tmpdir
  
  CRLF = D2C(13)||D2C(10)

  nb_fld_opt = 'OBJECTID=<NB41_FOLDER>;';
  nb_fld_opt = nb_fld_opt||'ICONNFILE=1,'||tmpdir||'\nb_fldr2.ico;';
  nb_fld_opt = nb_fld_opt||'ICONFILE='||tmpdir||'\nb_fldr1.ico';
  
  nb_ide_opt = 'PROGTYPE=WINDOWABLEVIO;MINIMIZED=YES;';
  nb_ide_opt = nb_ide_opt||'EXENAME='||progdir||'\bin\netbeans.cmd;';
  nb_ide_opt = nb_ide_opt||'PARAMETERS=--os2-windowed;';
  nb_ide_opt = nb_ide_opt||'STARTUPDIR='||progdir||'\bin;';
  nb_ide_opt = nb_ide_opt||'ICONFILE='||tmpdir||'\nb_ide.ico';
  
  nb_readme_opt = 'URL='progdir'\README.html'
  nb_credits_opt = 'URL='progdir'\CREDITS.html'
  nb_relnotes_opt = 'URL=http://www.netbeans.org/community/releases/41/relnotes.html'
  nb_url_opt = 'URL=http://www.netbeans.org'

  if SysCreateObject("WPFolder", "NetBeans 5.0", "<WP_DESKTOP>", nb_fld_opt, 'r') THEN DO
      say "'NetBeans 5.0' folder created."
	
      if SysCreateObject("WPProgram", "NetBeans IDE 5.0", "<NB41_FOLDER>", nb_ide_opt, 'r') THEN
          say "'NetBeans IDE 5.0' program object created."
	
      if SysCreateObject("WPUrl", "NetBeans Home", "<NB41_FOLDER>", nb_url_opt, 'r') THEN
          say "'NetBeans Home' URL object created."
		
      if SysCreateObject("WPUrl", "NetBeans 4.1"CRLF"README", "<NB41_FOLDER>", nb_readme_opt, 'r') THEN
          say "'NetBeans 5.0 README' URL object created."
		
      if SysCreateObject("WPUrl", "NetBeans 4.1"CRLF"CREDITS", "<NB41_FOLDER>", nb_credits_opt, 'r') THEN
          say "'NetBeans 5.0 CREDITS' URL object created."
      
     if SysCreateObject("WPUrl", "NetBeans 5.0"CRLF"Release Notes", "<NB41_FOLDER>", nb_relnotes_opt, 'r') THEN
          say "'NetBeans 5.0 Release Notes' URL object created."
  end
  '@del '||tmpdir||'\nb_ide.ico'
  '@del '||tmpdir||'\nb_fldr1.ico'
  '@del '||tmpdir||'\nb_fldr2.ico'
return
