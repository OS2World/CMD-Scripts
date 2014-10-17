/* Restore the <WP_DESKTOP> object-ID in the file OS2.INI */

/* Olaf Kolling 1995 */
/* Falls Sie Fragen oder Anregungen haben, k”nnen Sie mich in Compuserve unter 100342,1303 erreichen */
/* If you have questions or suggestions you can reach me on CIS as 100342,1303 */

Call RxFuncAdd SysLoadFuncs, RexxUtil, SysLoadFuncs
Call SysLoadFuncs

Call SysCls

Say 
Say '(D)eutsch / (E)nglish'
Say
Parse Upper Value SysGetKey('NOECHO') With Antwort
Call SysCls
If Antwort = 'D' Then Call Deutsch
If Antwort = 'E' Then Call English
Exit


Deutsch:
Say 
Say 'REST_DESK.CMD:'
Say 'Das Script tr„gt die Arbeitsoberfl„che unter der'
Say 'Object-ID "<WP_DESKTOP>" in die OS2.INI ein'
Say 
Say 'Benutzen Sie diese Script NUR WENN DIE VARIABLE <WP_DESKTOP> ZERST™RT WURDE !!!'
Say 
Say 'Wollen Sie das Script fortsetzen ?'
Parse Upper Value SysGetKey('NOECHO') With Antwort
If Antwort <> 'J' Then Exit

Say 
Say 'Wie heiát Ihre aktuelle Arbeitsoberfl„che ? (z.B. C:\ARBEITSOBERFLŽCHE)'
Say
Pull Name

Eigenschaften = 'OBJECTID=<WP_DESKTOP>'

Say
Say 'Das Verzeichnis 'Name' wird als Desktop in die '
Say 'User-Ini Datei (OS2.INI) eingetragen !!'
Say
Say 'Wollen Sie das wirklich ?'
Parse Upper Value SysGetKey('NOECHO') With Antwort
If Antwort <> 'J' Then Exit
Say
result = SysSetObjectData(Name, Eigenschaften)
if result=1 Then
   Say 'Das Verzeichnis 'Name' wurde erfolgreich eingetragen !'
else
   Say 'Fehler !! Das Verzeichnis 'Name' konnte nicht eingetragen werden !'

Return



English:
Say 
Say 'REST_DESK.CMD:   '
Say 'Restores the <WP_DESKTOP> entry for your desktop-directory in OS2.INI'
Say 
Say 'You MUST NOT use this Script if your <WP_DESKTOP> entry is correct !!!'
Say 
Say 'Do you want to continue ?'
Parse Upper Value SysGetKey('NOECHO') With Antwort
If Antwort <> 'Y' Then Exit

Say 
Say 'What is the physical name of your desktop-directory ? (i.e. C:\DESKTOP)'
Say
Pull Name

Eigenschaften = 'OBJECTID=<WP_DESKTOP>'

Say
Say 'The directory 'Name' will be put in OS2.INI '
Say 'as your working-desktop !!'
Say
Say 'Do you realy want to continue ?'
Parse Upper Value SysGetKey('NOECHO') With Antwort
If Antwort <> 'Y' Then Exit
Say
result = SysSetObjectData(Name, Eigenschaften)
if result=1 Then
   Say 'The directory 'Name' was entered successfully !'
else
   Say 'Error !! The directory 'Name' could not be entered !'

Return
