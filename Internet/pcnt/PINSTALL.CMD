/*

   Setup objects for PPP connection on desktop.
   Remember, info is taken from that set by 'Dial Other Provider'
   '.ini' setup info. Do setup there first, try your connection
   and then run this exec to create objects that do not use the SLIPPM
   GUI interface to dial.
   Then these PPP objects may be dragged to desktop context 'menu' tab
   to create easier access.

   Example: If 'Dial Other Providers' shows an 'XYZ-Account'
   then type:  pinstall XYZ-Account
   This would create an object on the desktop in a random place
   to start connection for XYZ-Account.

   To specify custom icons order is important ... stop, caution, go

 */

     Parse Arg acct stopicon cauticon goicon

/* if custom icons ALL must be set or default to traffic light */

         If(stopicon="")|(cauticon="")|(goicon="") Then

           Do
             stopicon="redlight.ico"
             cauticon="yellight.ico"
             goicon  ="grelight.ico"
           End

         Parse Source . . this .
         this=Reverse(this)
         Parse Var this . '\' cmdpath .
         cmdpath=Reverse(cmdpath)

         Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
         Call SysLoadFuncs

/* make checks for TCPOS2, account and PPP function */

         inif=tcpchk(acct)
         If(inif="") Then Exit 28

/* write icon names out to TCPOS2 for account */

         complete=FALSE

         If("ERROR:"=SysIni(inif,acct,"STOP",stopicon)) Then
            Say "Error INI write stop tag"
           Else

         If("ERROR:"=SysIni(inif,acct,"CAUTION",cauticon)) Then
            Say "Error INI write caution tag"
           Else

         If("ERROR:"=SysIni(inif,acct,"GO",goicon)) Then
            Say "Error INI write go tag"
           Else

         complete=TRUE

         If(FALSE=complete) Then
           Do
           Say "Error writing to ini file."
           Exit 32
           End

/* Create DESKTOP icon for account in random position */

         xc=Random(0,90,Time('S'))
         yc=Random(0,90,Time('S'))

         setup='EXENAME='cmdpath'\pppcnt.cmd;PARAMETERS='acct '%'
         setup=setup||';MINIMIZED=YES;CCVIEW=NO;ICONFILE='cmdpath'\'stopicon';ICONPOS='xc yc

         result=SysCreateObject('WPProgram',acct,'<WP_DESKTOP>','OBJECTID=<'Substr(acct,1,8,"_")'>;'setup,'R')

         If(result) Then Say "Object created on desktop."
          Else "Say difficulty creating Account object on desktop, result="result

        Exit
