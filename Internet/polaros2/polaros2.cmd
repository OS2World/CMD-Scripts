/*
polaros2.cmd - create OS/2 program objects on desktop for Polarbar Mailer
Copyright 2000-2007, Charles H. McKinnis
Changes - 24 Nov 2007
   Support all OS/2 and eCS Java
Changes - 23 Aug 2006
   Add -Djava.awt.fonts= for Java 1.3.1
Changes - 28 Dec 2005
   Support Golden Code Java.
   Eliminate pbm125b and pbm125c.
Changes - 8 Dec 2005
   Handle Firefox invocaton.
   Provide some debug output.
Changes - 14 Oct 2005
   Handle Java 1.4 requirement.
   Locate all JAVA.EXE occurences in PATH.
Changes - 3 Mar 2005
   Generate user.js statements for launching Polarbar from Mozilla/Firefox
Changes - 9 Aug 2004
   Use Setlocal and Endlocal before and after execution.
Changes - 4 Feb 2004
   Allow Java 1.1.8 to be used even if it is not the default JVM.
   Allow Java 1.4.x to be used.
Changes - 8 Jul 2003
   Set BEGINLIBPATH for Java
   Handle Innotek OS2 Java 1.4.2, drop 1.4.1 support
Changes - 19 Jun 2003
   Allow for options to be passed to the polarbar execution
   Allow running from LAN drive
   Generate security parms as required
   Handle Innotek OS2 Java 1.4.1
   Look for Java 1.3+ info in os2.ini
Changes - 27 Jan 2003
	Make Java storage limitation optional
	Build polarbar.cmd file dynamically
	Be sensitive to Java version
	Remove Hot Java Browser support
	Correct disabling of JIT compiler
	Attempt to update PolarBar Mailer object before creating a new one
	Update polarbar.cmd to eliminate 2 windows for execution
*/

Trace('N')

Call Rxfuncadd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
Call SysLoadFuncs

Parse Source . . polar_os2 .
our_path = Filespec('d',polar_os2)||Filespec('p',polar_os2)
If Length(our_path) > 3 Then our_dir = Strip(our_path,'t','\')
Else our_dir = our_path
Call Directory our_dir

Say 'POLAROS2 1.3.4 - Copyright 2000-2007, Charles H. McKinnis'
Say 'This routine will create or update a Polarbar Mailer object.'
Say 'It will execute the polarbar.cmd file to dynamically determine'
Say '  the most current Java version and launch the Polarbar Mailer'
Say '  application.  By default, the current Polarbar Mailer Java'
Say '  version (pbm125a.zip) will be used.  If you want to use a'
Say '  different version, add "/z <Polarbar Mailer zip file name>"'
Say '  to the parameter line of the object properties.'
Say 'Do you wish to install a Polarbar Mailer object (y,N)?'
Pull ans .
If \Abbrev(ans,'Y') Then Call Exit

obj_icon = our_dir||'\pbmos2.ico'
obj_icon_pos = '45 45'
obj_class = 'WPProgram'
obj_title = 'Polarbar^Mailer'
obj_loc = '<WP_DESKTOP>'
obj_id = 'OBJECTID=<POLARBAR_MAILER>;'
exec = 'EXENAME='||our_dir||'\polarbar.cmd;'
window = 'CCVIEW=NO;'

Say 'Do you want to run with the Java console window minimized (Y,n)?'
Pull ans .
If Abbrev(answer,'N') Then window = window||'MINIMIZED=NO;'
Else window = window||'MINIMIZED=YES;'

Say 'Do you want to close the Java console window when Polarbar ends (Y,n)?'
Pull ans .
If Abbrev(answer,'N') Then window = window||'NOAUTOCLOSE=YES;'
Else window = window||'NOAUTOCLOSE=NO;'

icon = 'ICONFILE='||obj_icon||';ICONPOS='||obj_icon_pos||';'

setup = obj_id||exec||window||icon
If SysCreateObject(obj_class,obj_title,obj_loc,setup,'U') Then
 Say 'Polarbar program object created'
Else
 Say 'Failed to create or update Polarbar program object'
Call Exit

Exit: Procedure
Exit
Return
