/*****************************************************************************/
/*                                                                           */
/*                                                                           */
/* RR - ReXX REQUESTER                                                       */
/*                                                                           */
/* Revision 0.11 (19/02/93)                                                  */
/*                                                                           */
/* (C) Copyright 1993 by Martin Adirsch.                                     */
/*                                                                           */
/* This is 'FreeWare'.  As such, it may be copied and distributed            */
/* freely.  If you want to use part of it in your own program, please        */
/* give credit where credit is due.  If you want to change the               */
/* program, please refer the change request to me or send me the             */
/* modified script code.  I can be reached as FIDO-POINT 2:240/602.26        */
/*                                                                           */
/* You may notice, that there are several options, which are still out       */
/* of function. This will change soon ;-).                                   */
/*                                                                           */
/*                                                                           */
/*****************************************************************************/

echo off
CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
CALL SysLoadFuncs
ansi on
cls

/*--Initialisieren-----------------------------------------------------------*/
ini:
outbound  = 'd:\bink\outbound\'  /* you may change this, soon ther will be a */
filelist  = 'rr.cfg'             /* seperate configuration routine ;-)       */
lister='@ call d:\os2tools\L'    /* set'lister=1'if you don't use an external*/
                                 /* lister.                                  */
Passwort='!PASSWORD'             /* Put in Req. Passwort (_capital_ letters  */
temp_dir='d:\temp\'
arj_pack='@ call d:\os2tools\unarj e '
zip_pack='@ call d:\os2tools\pkunzip '
lh_pack='@ call d:\os2tools\lh x '
filelist_dir='d:\bink\rr\'

V_gelb='[0;1;33m'
V_rot='[0;1;31m'
V_hellweiss='[0;1;38m'
V_cyan='[0;1;36m'
l_kill='[K'
call syscurstate 'off'
do forever

    call makechoice
    call tastendruck
    select
        when inkey=27 | key='q' |key='Q'           /*ESC*/
             then do
                 cur=syscurpos(15,11)
                 say "[0;30;47mI'm open for any comments and critics, send me NM, thanks.[0m"
                 cur=syscurpos(21,1)
                 exit
                 end
        when key='g' | key='G'
             then do
                 cur=syscurpos(15,11)
                 say "[0;30;47mSearch:                                                  "
                 cur=syscurpos(15,19)
                 call syscurstate 'on'
                 pull par
                 say "[0m"
                 call syscurstate 'off'
                 if par='' then signal ini
                 tag       = 1
                 do while lines(filelist)<>0
                   bbs     = linein(filelist)
                   parse var bbs adresse bbs
                   parse var bbs liste bbs
                   if right(liste,3)='arj' | right(liste,3)='zip' | right(liste,3)='lhz' then do
                      call Packer_test
                   end
                   cur=SysCurPos(15,11)
                   say  "[0;30;47mSearching through filelist" adresse "      "
                   cur=SysCurPos(15,58)
                   say  "Found: [0m"
                   call SysFileSearch par, liste, stamm.
                   do i=1 to stamm.0
                      if pos('.',stamm.i)<>0 & substr(stamm.i,1,1)<='Z' & substr(stamm.i,1,1)<>' ' then
                        do
                          node.tag=adresse
                          parse var stamm.i pgm_name.tag stamm.i
                          kette.tag=substr(stamm.i,1,50)'[0m'
                          tag=tag+1
                          cur=syscurpos(15,65)
                          say "[0;30;47m"right(i,4,0)"[0m"
                        end
                    end
                   if flag=1 then do
                    call kill_temp
                    flag=0
                   end
                  end
                  call lineout (filelist)
                  say"[47m[0m[255D"
                  CLS
                  i=1
                  call footer
                  call header
                  call ausga_forw
                  call global
                  cls
              end

        when key='s' | key='S'
             then do
                 cur=syscurpos(15,11)
                 say "[0;30;47mSearch:                                                  "
                 cur=syscurpos(15,19)
                 call syscurstate 'on'
                 pull par
                 say "[0m"
                 call syscurstate 'off'
                 if par='' then signal ini
                 tag       = 1
                 do while lines(filelist)<>0
                   bbs     = linein(filelist)
                   parse var bbs adresse bbs
                   parse var bbs liste bbs
                   
                   if right(liste,3)='lst' then do

                   cur=SysCurPos(15,11)
                   say  "[0;30;47mSearching through filelist" adresse "      "
                   cur=SysCurPos(15,58)
                   say  "Found: [0m"
                   call SysFileSearch par, liste, stamm.
                   do i=1 to stamm.0
                   if pos('.',stamm.i)<>0 & substr(stamm.i,1,1)<='Z' & substr(stamm.i,1,1)<>' ' then
                        do
                          node.tag=adresse
                          parse var stamm.i pgm_name.tag stamm.i
                          kette.tag=substr(stamm.i,1,50)'[0m'
                          tag=tag+1
                          cur=syscurpos(15,65)
                          say "[0;30;47m"right(i,4,0)"[0m"
                        end
                    end
                   end
         /* ende der if schleife */
                  end
                  call lineout (filelist)
                  say"[47m[0m[255D"
                  CLS
                  i=1
                  call footer
                  call header
                  call ausga_forw
                  call global
                  cls
              end

        when key='l' | key='L'
             then do
                 tag       = 1
                   do while lines(filelist)<>0
                     bbs     = linein(filelist)
                     parse var bbs adresse.tag bbs
                     parse var bbs liste.tag bbs.tag
                     tag=tag+1
                   end
                  call lineout(filelist)
                  say"[47m[0m[255D"
                  CLS
                  i=1
                  call header
                  call aus_cfg  /*Zeigen und wÑhlen */
                  if tag='m' | tag='M' then do
                                            cls
                                            signal ini
                                            end
                  adresse=adresse.tag
                  liste=liste.tag
                  call Packer_test
                  liste.tag=liste
                  if lister=1 then do
                     par=' '
                     call SysFileSearch par, liste.tag, stamm.
                        i=0
                        tag=stamm.0
                     say"[47m[0m[255D"
                     CLS
                     i=1
                     call footer
                     call header
                     call ausga_L_forw
                     call global_L
                     cls
                     end
                  else do
                     lister liste.tag
                     cls
                     end

                   if flag=1 then do
                    call kill_temp
                    flag=0
                   end
              end

        when key='h' | key='H'
             then do
                 cur=syscurpos(15,11)
                 say "[0;30;47mSorry, this OPTION is still not available ;-) PRESS A KEY"
                 call tastendruck
                 end

        when key='I' | key='i'
             then do
                 cls
                 cur=syscurpos(2,0)
                 say "/*****************************************************************************/"
                 say "/*                                                                           */"
                 say "/*                                                                           */"
                 say "/* RR - ReXX REQUESTER                                                       */"
                 say "/*                                                                           */"
                 say "/* Revision 0.11 (19/02/93)                                                  */"
                 say "/*                                                                           */"
                 say "/* (C) Copyright 1993 by Martin Adirsch.                                     */"
                 say "/*                                                                           */"
                 say "/* This is 'FreeWare'.  As such, it may be copied and distributed            */"
                 say "/* freely.  If you want to use part of it in your own program, please        */"
                 say "/* give credit where credit is due.  If you want to change the               */"
                 say "/* program, please refer the change request to me or send me the             */"
                 say "/* modified script code.  I can be reached as FIDO-POINT 2:240/602.26        */"
                 say "/*                                                                           */"
                 say "/* You may notice, that there are several options, which are still out       */"
                 say "/* of function. This will change soon ;-).                                   */"
                 say "/*                                                                           */"
                 say "/*                                                      <press a key>        */"
                 say "/*****************************************************************************/"
                 call tastendruck
                 cls
                 end

        when key='d' | key='D'
             then do
                  tag       = 1
                   do while lines(filelist)<>0
                     bbs     = linein(filelist)
                     parse var bbs adresse.tag bbs
                     parse var bbs liste.tag bbs.tag
                     tag=tag+1
                   end
                  call lineout (filelist)
                  say"[47m[0m[255D"
                  CLS
                  i=1
                  call header
                  call aus_cfg  /*Zeigen und wÑhlen */
                  if tag='m' | tag='M' then do
                                            cls
                                            signal ini
                                            end
                  cur=syscurpos(23,0)
                  say "Search at"v_rot adresse.tag v_gelb"for:"l_kill
                  call syscurstate 'on'
                  cur=syscurpos(23,25)
                  pull par
                  call syscurstate 'off'
                  if par='' then do
                                 cls
                                 signal ini
                                 end
                  adresse=adresse.tag
                  liste=liste.tag
                  call Packer_test
                  liste.tag=liste
                  tag       = 1
                   cur=SysCurPos(15,11)
                   say  "[0;30;47mSearching through filelist" adresse "      "
                   cur=SysCurPos(15,58)
                   say  "Found: [0m"
                   call SysFileSearch par, liste, stamm.
                   do i=1 to stamm.0
                     if pos('.',stamm.i)<>0 & substr(stamm.i,1,1)<='Z' & substr(stamm.i,1,1)<>' ' then
                        do
                          node.tag=adresse
                          parse var stamm.i pgm_name.tag stamm.i
                          kette.tag=substr(stamm.i,1,50)'[0m'
                          tag=tag+1
                          cur=syscurpos(15,65)
                          say "[0;30;47m"right(i,4,0)"[0m"
                        end
                    end
                  say"[47m[0m[255D"
                  CLS
                  i=1
                  call footer
                  call header
                  call ausga_forw
                  call global
                  cls
                   if flag=1 then do
                    call kill_temp
                    flag=0
                   end
              end

        when key='F' | key='f'
             then do
                 cur=syscurpos(15,11)
                 say "[0;30;47mSorry, this OPTION is still not available ;-) PRESS A KEY"
                 call tastendruck
                 end
        when key='K' | key='k'
             then do
                 cur=syscurpos(15,11)
                 say "[0;30;47mSorry, this OPTION is still not available ;-) PRESS A KEY"
                 call tastendruck
                 end

         otherwise
           nop
         end

         End




/*-------------------------------------------------------------------------*/
global:

do forever
    call tastendruck
    select
        When inkey=27 | key='q' | key='Q'                        /*ESC*/
           Then return
         When inkey=72 | inkey=75   /* UP,RT */
           then do
                call ausga_back
                cur=syscurpos(22,0)
                say l_kill
                end
         when inkey=77 | inkey=80   /* DW,LF */
                then do
                call ausga_forw
                end
         When inkey=32                          /* CR taggen */
            Then Do
                 call taggen
                 call footer
                 call header
                 cur=syscurpos(22,0)
                 End

         Otherwise
            nop
         End

end
return
/*-------------------------------------------------------------------------*/
global_L:

do forever
    call tastendruck
    select
        When inkey=27 | key='q' | key='Q'                        /*ESC*/
           Then return
         When inkey=72 | inkey=75   /* UP,RT */
           then do
                call ausga_L_back
                cur=syscurpos(22,0)
                say l_kill
                end
         when inkey=77 | inkey=80   /* DW,LF */
                then do
                call ausga_L_forw
                end
         When inkey=32                          /* CR taggen */
            Then Do
                 call taggen_L
                 call footer
                 call header
                 cur=syscurpos(22,0)
                 End

         Otherwise
            nop
         End

end
return
/*-------------------------------------------------------------------------*/
taggen:
    zeile=2
    cur=SysCurPos(zeile,0)
    say V_gelb">>"
    cur=syscurpos(2,0)
    inkey=0
    do while inkey<>27
     call tastendruck
     select
        When inkey=27 | key='q' | key='Q'                        /*ESC*/
           Then do
                do m=2 to 21
                  cur=syscurpos(m,0)
                  say "   "
                end
                return
                end
         When inkey=72 | inkey=75   /* UP,RT */
           then do
                call tag_up
                end
         when inkey=77 | inkey=80   /* DW,LF */
                then do
                call tag_down
                end
         When inkey=32                          /* CR taggen */
            Then Do
                 tag_kette=systextscreenread(zeile,3,74)
                 cur=syscurpos(22,0)
                 parse var tag_kette adresse tag_kette
                 parse var tag_kette pgm tag_kette
                 say V_hellweiss"Confirm request for "v_gelb pgm v_hellweiss'at'v_rot adresse v_hellweiss'(Yes / ESC=No / Password)'
                 do forever
                 call tastendruck
                 select
                 when key='y' | key='Y' | key='p' | key='P' then do
                                   call umrechnen
                                   call request
                                   cur=syscurpos(22,0)
                                   say V_hellweiss"Request has been created, press a key"l_kill
                                   call tastendruck
                                   cur=syscurpos(22,0)
                                   say l_kill
                                   leave
                                   end

                 when inkey=27 then do
                      cur=syscurpos(22,0)
                      say l_kill
                      inkey=0
                      leave
                      end
                 otherwise
                    nop
                 end
                 End
                 end
         Otherwise
            nop
         End
 end
return

/*-------------------------------------------------------------------------*/
taggen_l:
    zeile=12
    cur=SysCurPos(zeile,0)
    say V_gelb">>"
    cur=syscurpos(2,0)
    inkey=0
    do while inkey<>27
     call tastendruck
     select
        When inkey=27 | key='q' | key='Q'                        /*ESC*/
           Then do
                do m=2 to 21
                  cur=syscurpos(m,0)
                  say "   "
                end
                return
                end
         When inkey=72 | inkey=75   /* UP,RT */
           then do
                call tag_up
                end
         when inkey=77 | inkey=80   /* DW,LF */
                then do
                call tag_down
                end
         When inkey=32                          /* CR taggen */
            Then Do
                 tag_kette=systextscreenread(zeile,3,74)
                 cur=syscurpos(22,0)
                 parse var tag_kette pgm tag_kette
                 say V_hellweiss"Confirm request for "v_gelb pgm v_hellweiss'at'v_rot adresse v_hellweiss'(Yes / ESC=No / Password)'
                 do forever
                 call tastendruck
                 select
                 when key='y' | key='Y' | key='p' | key='P' then do
                                   call umrechnen
                                   call request
                                   cur=syscurpos(22,0)
                                   say V_hellweiss"Request has been created, press a key"l_kill
                                   call tastendruck
                                   cur=syscurpos(22,0)
                                   say l_kill
                                   leave
                                   end

                 when inkey=27 then do
                      cur=syscurpos(22,0)
                      say l_kill
                      inkey=0
                      leave
                      end
                 otherwise
                    nop
                 end
                 End
                 end
         Otherwise
            nop
         End
 end
return

tag_up:
    cur=SysCurPos(zeile,0)
    say "   "
    zeile=zeile-1
    if zeile<2 then do
                    zeile=21
                    cur=syscurpos(zeile,0)
                    end

    cur=SysCurPos(zeile,0)
    say v_gelb">>"
return

tag_down:

    zeile=zeile+1
    cur=syscurpos(zeile-1,0)
    say "   "
    if zeile>21 then do
                     zeile=2
                     cur=syscurpos(zeile,0)
                     end
    say v_gelb">>"
return

umrechnen:
zeiger1=pos('/',adresse)
node=substr(adresse,zeiger1+1,4)
zeiger2=pos(':',adresse)
net=substr(adresse,zeiger2+1,zeiger1-zeiger2-1)
kont=substr(adresse,1,1)
reqfile_name=d2x(net,4)d2x(node,4)
return


/*---------------------------------------------------------------------------*/
makechoice:
call menu
cur=syscurpos(15,11)
say "[0;30;47mMake your choice...[47m[0m[255D"
return

/*---------------------------------------------------------------------------*/
request:
leer=''
if key='p' | key= 'P' then do
                      pgm=pgm passwort
                      end
call lineout outbound''reqfile_name'.req',pgm
call lineout outbound''reqfile_name'.req'
call lineout outbound''reqfile_name'.clo',leer
call lineout outbound''reqfile_name'.clo'
return

/*---------------------------------------------------------------------------*/
menu:
cur=syscurpos(3,0)

say"[0;1;47mﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ[40m"
say"[47m[0;47mﬂﬂﬂ[30mƒƒƒƒƒƒƒƒƒƒƒ [34mRR - ReXX-REQUESTER Vers. 0.11 [30mƒƒ [34m19. Februar 1993 [30mƒƒƒƒƒƒƒƒƒƒ[37mﬂﬂ [40m"
say"[47m   [1;30m‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹   [40m"
say"[47m   [34;40m≈[0;34m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈[1m≈[0;36m≈[1m≈[37m≈[36m≈[0;36m≈[1;34m≈[0;34m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈[1m≈[0;36m≈[1m≈[37m≈[36m≈[0;36m≈[1;34m≈[0;34m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈[1m≈[0;36m≈[47m   [40m"
say"[47m   [40m≈[1;34m≈[0;34m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈[1m≈[0;36m≈[1m≈[37m≈[36m≈[0;36m≈[1;34m≈[0;34m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈[1m≈[0;36m≈[1m≈[37m≈[36m≈[0;36m≈[1;34m≈[0;34m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈[1m≈[47m   [40m"
say"[47m   [36;40m≈[0;36m≈[1;34m≈[0;34m≈≈[1;37;47m€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ[30m‹[0;34m≈≈≈≈[47m   [40m"
say"[47m   [1;37;40m≈[36m≈[0;36m≈[1;34m≈[0;34m≈[1;37;47m€  [33mG[0;30;47mlobal search (ALL)                          Read [1;33mF[0;30;47milelist  [1m€[0;34m≈≈≈≈[47m   [40m"
say"[47m   [1;36;40m≈[37m≈[36m≈[0;36m≈[1;34m≈[37;47m€  [0;30;47mGlobal [1;33ms[0;30;47mearch (only unpacked)                [1;33mK[0;30;47mill Filelist  [1m€[0;34m≈≈≈≈[47m   [40m"
say"[47m   [36;40m≈[1m≈[37m≈[36m≈[0;36m≈[1;37;47m€  [33mD[0;30;47metailed search                              [1;33mI[0;30;47mnfo           [1m€[0;34m≈≈≈≈[47m   [40m"
say"[47m   [1;40m≈[0;36m≈[1m≈[37m≈[36m≈[37;47m€  [33mL[0;30;47mist                                         [1;33mQ[0;30;47muit           [1m€[0;34m≈≈≈≈[47m   [40m"
say"[47m   [40m≈[1m≈[0;36m≈[1m≈[37m≈[47m€                                                              [30m€[0;34m≈≈≈≈[47m   [40m"
say"[47m   [40m≈≈[1m≈[0;36m≈[1m≈[37;47m€  [0;30;47mƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ  [1m€[0;34m≈≈≈≈[47m   [40m"
say"[47m   [40m≈≈≈[1m≈[0;36m≈[1;37;47m€                                                              [30m€[0;34m≈≈≈≈[47m   [40m"
say"[47m   [40m≈≈≈≈[1m≈[37;47mﬂ[30m‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€[0;34m≈≈≈≈[47m   [40m"
say"[47m   [40m≈≈≈≈≈[1m≈[0;36m≈[1m≈[37m≈[36m≈[0;36m≈[1;34m≈[0;34m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈[1m≈[0;36m≈[1m≈[37m≈[36m≈[0;36m≈[1;34m≈[0;34m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈[1m≈[0;36m≈[1m≈[37m≈[36m≈[0;36m≈[1;34m≈[0;34m≈≈≈≈≈≈≈≈[47m   [40m"
say"[47m   [40m≈≈≈≈≈≈[1m≈[0;36m≈[1m≈[37m≈[36m≈[0;36m≈[1;34m≈[0;34m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈[1m≈[0;36m≈[1m≈[37m≈[36m≈[0;36m≈[1;34m≈[0;34m≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈[1m≈[0;36m≈[1m≈[37m≈[36m≈[0;36m≈[1;34m≈[0;34m≈≈≈≈≈≈≈[47m   [40m"
say"[47m   [1;37mﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ   [40m"
say"[47m[0;47mﬂﬂﬂ[30mƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ [34m(c) by Martin Adirsch @ 2:240/602.26 [30mƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[37mﬂﬂ [40m"
say"[47m[1;30m‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹[40m"
say"[47m[0m[255D"
say""
return
/*---------------------------------------------------------------------------*/
header:

cur=syscurpos(0,0)
say "[44m [0;1;44m****  ReXX-REQUESTER V0.11 ******  RR  *****  (c) 1993 by Martin Adirsch ****  [40m"
say "[44m[0m[255D"
return

/*---------------------------------------------------------------------------*/
footer:

cur=syscurpos(23,0)
say"[44m [0;1;41mUp/Down[44m Cursorblock    [41mSPACE[44m Taggen on    [41mESC[44m Taggen off                 [41mQ[44muit [40m"
return

/*---------------------------------------------------------------------------*/
ausga_forw:
    do m=2 to 21
       if i<tag then do
                     cur=syscurpos(m,0)
                     say "  "v_rot node.i V_hellweiss pgm_name.i v_cyan substr(kette.i,1,54)"[K"
                     i=i+1
                     end
       if i=tag then do
                     parse value SysCurpos() with zeile spalte
                       do ii=zeile to 21
                          cur=syscurpos(ii,0)
                          say l_kill
                          i=i+1

                       end
                     end

    end
    if i>tag then do
                  cur=syscurpos(22,26)
                  say V_rot "******* EOF *******[0m"
                  end
    return

/*---------------------------------------------------------------------------*/
ausga_back:
    do m=2 to 21
    i=i-1
    if i<1 then do
                i=1
                leave
                end

       if i>=tag then do
                     cur=syscurpos(23-m,0)
                     say l_kill
                     end
       if i<tag then do
                     cur=syscurpos(23-m,0)
                     say "  "v_rot node.i V_hellweiss pgm_name.i v_cyan substr(kette.i,1,54)"[K"
                     end
    end

    return

/*---------------------------------------------------------------------------*/
ausga_L_forw:
    do m=2 to 21
       if i<tag then do
       cur=syscurpos(m,0)
       say '  ' substr(stamm.i,1,74) "[K"
                     i=i+1
                     end
       if i=tag then do
                     parse value SysCurpos() with zeile spalte
                       do ii=zeile to 21
                          cur=syscurpos(ii,0)
                          say l_kill
                          i=i+1
                       end
                     end
    end

    if i>tag then do
                  cur=syscurpos(22,26)
                  say V_rot "******* EOF *******[0m"
                  end
    return

/*---------------------------------------------------------------------------*/
ausga_L_back:
    do m=2 to 21
    i=i-1
    if i<1 then do
                i=1
                leave
                end

       if i>=tag then do
                     cur=syscurpos(23-m,0)
                     say l_kill
                     end
       if i<tag then do
                     cur=syscurpos(23-m,0)
                     say '   'substr(stamm.i,1,74) "[K"
                     end
    end
    return

/*---------------------------------------------------------------------------*/
aus_cfg:
  spalte=0
  do s=1 to 2
    do m=2 to 21
            cur=syscurpos(m,spalte)
            if i<tag then do
                     say v_gelb right(i,2) v_rot adresse.i v_cyan substr(BBS.i,1,22)"[K"
                     i=i+1
                     end
            else do
                     say l_kill
            end
    end
    spalte=spalte+40
  end

  cur=syscurpos(23,0)
  say v_gelb"Make your choice...M=Menu:"
  cur=syscurpos(23,29)
  call syscurstate 'on'
  pull tag
  call syscurstate 'off'
  if tag<0 or tag>50 then tag=1
  if tag="" then tag=1
  return

/*---------------------------------------------------------------------------*/
menu:

    cls
    say "MENU-Optionen kommen spÑter :-)"
    pause
    cls
    return

/*---------------------------------------------------------------------------*/
tastendruck:

    inkey = 0
    Do While inkey=224 | inkey=0      /* Throw away modIfier key */
      Parse Value SysGetKey('NOECHO') With key
      inkey = c2d(key)
    End
return

/*---------------------------------------------------------------------------*/
Packer_test:
                   cls
                   if right(liste,3)='arj' | right(liste,3)='ARJ' then do
                      arj_pack''filelist_dir''liste
                      liste=substr(liste,1,pos('.',liste))'lst'
                      flag=1
                   end
                   if right(liste,3)='zip' | right(liste,3)='ZIP' then do
                      zip_pack''filelist_dir''liste
                      liste=substr(liste,1,pos('.',liste))'lst'
                      flag=1
                   end
                   if right(liste,3)='lhz' | right(liste,3)='LHZ' then do
                      lh_pack''filelist_dir''liste
                      liste=substr(liste,1,pos('.',liste))'lst'
                      flag=1
                   end
                   cls
                   call menu
return

/*---------------------------------------------------------------------------*/
kill_temp:

           erase filelist_dir''liste

return
/*---------------------------------------------------------------------------*/
