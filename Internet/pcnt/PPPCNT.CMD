/*

   Started on April 3rd 1998, Walt Shekrota  Use pinstall.cmd for setup.

   Establish point to point through desired service without intervention
   of IBM's GUI front end. (slippm.exe) dialer.exe is the slick interface
   that you only see if using IBM's Global Service. If you use another
   ISP you are stuck using the clunky slippm cludge. It requires you to
   hit enter on starting and asks questions shutting down. Not to mention
   the fact that they did not implement saved window features. (shift key)

   Use the GUI (slippm) to enter the user data ie. userid, password etc and
   let it modify the HOSTS file with correct domain info. Use it to try the
   connection, then convert to using this procedure.

  'start' also generates desired effect that PPP doesn't autostart should
   you have 'autostart programs' set in your config.sys and shutdown without
   killing PPP.

   To END connection: Control-C on 'PPP Connection' screen selected from
   task list.

 */

     Parse Arg appl runthis

/* Clear queue */

            Do Queued();Pull .;End

/* Check for PPP running? If not then continue */

            Call PPPrunning

            If (result=1) Then

             If (runthis="") Then

                Do
                 Say "PPP is already running!"
                 Exit 20
                End

             Else Signal StartAPP


/* get the path info from where this cmd file is run */

            Parse Source . . this .
            this=Reverse(this)
            Parse Var this . '\' cmdpath .
            cmdpath=Reverse(cmdpath)

            Call rxfuncadd sysloadfuncs, rexxutil, sysloadfuncs
            Call sysloadfuncs

/* get parms that were stored in TCPOS2.INI by Other Provider Dialer */

            inif=tcpchk(appl)
            if(inif="") Then Exit 28

            running=SysIni(inif, appl, 'CAUTION')  /* caution state icon    */

/* maintain current/last connection names for newsreader */

            ls=SysIni(inif, 'CONNECTION', 'CURRENT_CONNECTION') /* get last connect id */

            If("ERROR:"=SysIni(inif,"CONNECTION","LAST_CONNECTION",ls)) Then
               Say "Error INI write LAST_CONNECTION"
            If("ERROR:"=SysIni(inif,"CONNECTION","CURRENT_CONNECTION",appl)) Then
               Say "Error INI write CURRENT_CONNECTION"

            ip=SysIni(inif, appl, 'DNS') /* get nameserver i/p addr */
            dn=SysIni(inif, appl, 'DOMAIN_NAME') /* get domain */
/*
 * resolv files are really a manual configuration issue but dialer
 * will modify it on a connection basis. (ISP) Why not, slippm does it.
 * Yes rename will fail in most cases if existing
 * as intended so as to save ONLY the original!
 */

           '@rename resolv resolv.org'  /* save bu if org doesn't exist */
           '@erase resolv'              /* make room for temp create */

            xx=Lineout("resolv","domain" dn,1)
            xx=Lineout("resolv","nameserver" ip)
            xx=Lineout("resolv")

/* Turn on the yellow light that says we be a going */

            Call SysCreateObject "WPProgram", appl,"<WP_DESKTOP>","OBJECTID=<"Substr(appl,1,8,'_')">;EXENAME="cmdpath"\pppcnt.cmd;PARAMETERS=" appl ";ICONFILE="cmdpath"\"running,"U"

            stopped=SysIni(inif, appl, 'STOP')     /* stop state icon       */

            amready=SysIni(inif, appl, 'GO')       /* running state icon    */

            id=SysIni(inif, appl, 'LOGIN_ID')      /* Query the login       */
            id=Delstr(id, Length(id))

            pw=SysIni(inif, appl, 'PWD')           /* Query the password    */
            pw=Delstr(pw, Length(pw))

            phone=SysIni(inif, appl, 'PHONE_NUMBER') /* Query the phonenumber */
            phone=Delstr(phone, Length(phone))

            port=SysIni(inif, appl, 'COMPORT')     /* COM port used?        */
            port=Delstr(port, Length(port))

            speed=SysIni(inif, appl, 'BAUD')       /* Linespeed?            */
            speed=Delstr(speed, Length(speed))

            prefix=SysIni(inif, appl, 'PREFIX')    /* prefix dial tone/pulse*/
            prefix=Delstr(prefix, Length(prefix))

            init1=SysIni(inif, appl, 'INIT')       /* init string 1         */
            init1=Delstr(init1, Length(init1))

            init2=SysIni(inif, appl, 'INIT2')      /* init string 2         */
            init2=Delstr(init2, Length(init2))

            mru=SysIni(inif, appl, 'MTU_SIZE')     /* MRU                   */
            mru=Delstr(mru, Length(mru))

            scr=SysIni(inif, appl, 'SCRIPT')       /* Connection script     */
            scr=Delstr(scr, Length(scr))

            dis=SysIni(inif, appl, 'DISABLE')      /* disable cw if 'TRUE'  */
            dis=Delstr(dis, Length(dis))

            seq=SysIni(inif, appl, 'DISABLE_SEQ')  /* usually *70           */
            seq=Delstr(seq, Length(seq))

/* init strings and expected responses */

            If(dis='TRUE') Then phone=seq||phone    /* Call waiting */

            If(init1="") Then str1=""
             Else str1=init1 "OK"
            If(init2="") Then str2=""
             Else str2=init2 "OK"

            str3=prefix||phone "NECT"

/* implement connection scripts here, insert id and password */

            If scr<>'NONE' Then
              Do
               chars="0d0a"x
               scr=Translate(scr,"  ",chars)
               scr=ReplaceIf(scr,"[LOGINID]",id)
               scr=ReplaceIf(scr,"[PASSWORD]",pw)

               str3=str3 scr
               namenpw=""
              End

             Else
              namenpw="secret" pw "name" id

/* PPP to run serial link attach, to talk commands to modem */

            cstr='"slattach' str1 str2 str3 '" defaultroute mru' mru port speed

/* Start PPP in another process and wait for connection ready */

say        '@start "PPP Connection" /i /c /b /min' cmdpath'\rxppp' stopped appl cmdpath namenpw 'connect' cstr
           '@start "PPP Connection" /i /c /b /min' cmdpath'\rxppp' stopped appl cmdpath namenpw 'connect' cstr

            Say "Serial Link Commands."

/* Validate that shared memory is ready */

            Do While(\PPPrunning())      /* process id yet? */
            End

            NotStarted=1

            Do While NotStarted & PPPrunning()

              '@pstat /m|rxqueue'
               Do Queued()
                    Pull a "PPP0PID" b
                    If b<>"" Then NotStarted=0
               End

               etime=Time("R")
               etime=Time("R")

               Do While(etime<1)
                   etime=Time("E")
               End

            End

            If(\PPPrunning()) Then StopIt()

               Else Say "PPP started."

/* Turn on the green light and GO if still running */

            If(PPPrunning()) Then
               Call SysCreateObject "WPProgram", appl,"<WP_DESKTOP>","OBJECTID=<"Substr(appl,1,8,'_')">;EXENAME="cmdpath"\pppcnt.cmd;PARAMETERS=" appl ";ICONFILE="cmdpath"\"amready,"U"

            Else StopIt()

/* was application passed to start? */
          StartAPP:

            If runthis<>"" Then Address CMD 'start' runthis

           'Exit'           /*  Normal Exit command shell */


/* ================= INTERNAL SUBROUTINES ====================== */

/* See if PPP running by sifting through PSTAT */

          PPPrunning:

              '@pstat /c|rxqueue'
               found=0
               Do Queued()
                 Pull a "PPP.EXE" b
                 If b<>"" Then found=1
               End

               Return found

/* In a string, find a string and replace it, easiest is find, delete, insert */

          Replaceif:

            Parse Arg tstring,from,to

               idx=Pos(from,tstring)
               If(idx<>0) Then
                 Do
                   tstring=Delstr(tstring,idx,Length(from))
                   idx=idx-1
                   tstring=Insert(to,tstring,idx)
                 End
               Return tstring

/* Abnormal condition, restore traffic light Red! */

          StopIt:

            Say "Error PPP not running for some reason."
            Call SysCreateObject "WPProgram", appl,"<WP_DESKTOP>","OBJECTID=<"Substr(appl,1,8,'_')">;EXENAME="cmdpath"\pppcnt.cmd;PARAMETERS=" appl ";ICONFILE="cmdpath"\"stopstate,"U"
            Exit 28

