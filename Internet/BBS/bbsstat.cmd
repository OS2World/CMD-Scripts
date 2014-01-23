/* The stand alone "bbs statistics" generator */


/*---- load the rexxlib library */
foo=rxfuncquery('rexxlibregister')
if foo=1 then do
 call rxfuncadd 'rexxlibregister','rexxlib', 'rexxlibregister'
 call rexxlibregister
end
/* Load up advanced REXX functions */
foo=rxfuncquery('sysloadfuncs')
if foo=1 then do
  call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  call SysLoadFuncs
end

ansion=checkansi()
if ansion=1 then do
  aesc='1B'x
  cy_ye=aesc||'[37;46;m'
  normal=aesc||'[0;m'
  bold=aesc||'[1;m'
  re_wh=aesc||'[31;47;m'
  reverse=aesc||'[7;m'
end
else do
  cy_ye="" ; normal="" ; bold="" ;re_wh="" ; 
  reverse=""
end  /* Do */

 d1=date('b')
 t1=time('m')/(24*60)
 nowtime=d1+t1


cls
call lineout, bold cy_ye
CALL LINEOUT," This is the statistics generator for the BBS add-on for SRE-http. "
call lineout, normal bold "It must be run from the BBS USERLOG_DIR directory " normal
say " "

/* First, see how many .in files. */

aa=sysfiletree('*.in','infiles','FT')

nth=0
say " Reading user information.... "
do mm=1 to infiles.0
   aline=infiles.mm
   parse var aline date size attrib fname
   vlist=get_user_header(fname)
   
/* check variables  */
   if wordpos('STATUS',vlist)=0 then do
        say " ERROR. STATUS: entry missing from: " fname
        iterate
   end
   if wordpos("USER",vlist)=0 then do
        say " ERROR. USER: entry missing from: " fname
        iterate
   end
   parse var user_header.!status downf upf downb upb lasttime
   if  datatype(downf)<>'NUM' | datatype(upf)<>'NUM' | ,
     datatype(downb)<>'NUM' | datatype(upb)<>'NUM' | ,
     datatype(lasttime)<>'NUM' then do
         say "ERROR. Bad STATUS: entry "
   end  /* Do */

   parse var user_header.!user user .

   nth=nth+1
   entries.nth.!user=user
   entries.nth.!upf=upf ; entries.nth.!downf=downf
   entries.nth.!upb=upb ; entries.nth.!downb=downb

   tf=downf/max(1,upf)
   tb=downb/max(1,upb)
   entries.nth.!ratiob=tb
   entries.nth.!ratiof=tf
   entries.nth.!time=lasttime

end
say " # of user log files (user.IN files): " infiles.0
say " # of useable log files: " nth
 
/* how sort by upf downf upb downb ratiof ratiob */
totdownb=0; totdownf=0; totupf=0; totupb=0;
do mm=1 to nth
   totdownf=totdownf+entries.mm.!downf
   totdownb=totdownb+entries.mm.!downb
   totupf=totupf+entries.mm.!upf
   totupb=totupb+entries.mm.!upb
   adownf.mm=left(entries.mm.!downf,15)||entries.mm.!user
   aupf.mm=left(entries.mm.!upf,15)||entries.mm.!user
   adownb.mm=left(entries.mm.!downb,15)||entries.mm.!user
   aupb.mm=left(entries.mm.!upb,15)||entries.mm.!user
   aratiof.mm=left(entries.mm.!ratiof,15)||entries.mm.!user
   aratiob.mm=left(entries.mm.!ratiob,15)||entries.mm.!user
   atime.mm=left(entries.mm.!time,15)||entries.mm.!user
end

ok=arraysort(adownf,1,,1,15,'D','N')
ok=arraysort(aupf,1,,1,15,'D','N')
ok=arraysort(adownb,1,,1,15,'D','N')
ok=arraysort(aupb,1,,1,15,'D','N')
ok=arraysort(aratiof,1,,1,15,'D','N')
ok=arraysort(aratiob,1,,1,15,'D','N')
ok=arraysort(atime,1,,1,15,'D','N')

n2:
call charout ,  reverse ' Display the top n entries:  n  (enter=10)  ? ' normal
pull topn
if topn=""  then topn=10
topn=min(topn,nth)

call charout ,  reverse ' Display the number of users in the last d days: d (enter=7)  ? ' normal
pull ddays
if ddays="m"  then ddays=7



getname: call charout, " Filename to write the output report to:"
parse pull outname
outname=dosfname(outname)
hub=stream(outname,'c','query exists')
if hub<>' ' then do
    call charout, hub " exists. Enter Y to overwrite: "
    pull anans
    if upper(anans)='Y' then do
      say " deleting old copy of " hub
        ww=sysfiledelete(hub)
    end  /* Do */
    else do
        say " "
        signal getname
    end  /* Do */
end  /* Do */
else

say " writing to  " outname

call lineout outname, "BBS use statistics for: " time(n) date(n)
call lineout outname, " Total DOWNLOADS: # files=" totdownf ", #bytes=" totdownb
call lineout outname, " Total UPLOADS:   # files="totupf ", #bytes=" totupb
jusers=0
do ll=1 to nth
   parse var atime.ll a1 a2   /* date name */
   if nowtime-a1> ddays then leave
   jusers=jusers+1
end /* do */
call lineout outname, " # users (downloaders/uploaders) in the last " ddays " days =" jusers



call lineout outname, ""
call lineout outname, " Top " topn " downloaders (files) : Top " topn " uploaders (files) "
call lineout outname, " "

do ll=1 to topn
   parse var adownf.ll a1 a2 ; b1=left(strip(a2),12) ; b2=left('('strip(a1)')',12)
   parse var aupf.ll a1 a2 ; c1=left(strip(a2),12) ; c2=left('('strip(a1)')',12)
   call lineout outname, b1 b2 '   : ' c1 c2
end
call lineout outname, " "
call lineout outname, " Top " topn " downloaders (bytes) : Top " topn " uploaders (bytes) "
do ll=1 to topn
   parse var adownb.ll a1 a2 ; b1=left(strip(a2),12) ; b2=left('('strip(a1)')',12)
   parse var aupb.ll a1 a2 ; c1=left(strip(a2),12) ; c2=left('('strip(a1)')',12)
   call lineout outname, b1 b2 '   : ' c1 c2
end
call lineout outname, " "
call lineout outname, " Top " topn " downloaders (file ratio) : Top " topn " uploaders (byte ratio) "
do ll=1 to topn
   parse var aratiof.ll a1 a2 ; a1=format(a1,,2);
    b1=left(strip(a2),12) ; b2=left('('strip(a1)')',12)
   parse var aratiob.ll a1 a2 ; a1=format(a1,,2)
   c1=left(strip(a2),12) ; c2=left('('strip(a1)')',12)
   call lineout outname, b1 b2 '   : ' c1 c2
end
call lineout outname, " "
call lineout outname, " Most recent activity: "
do ll=1 to topn
   parse var atime.ll a1 a2
    b1=left(strip(a2),12)
   b2a=dateconv(trunc(a1),'B','N')
   tmp=(a1-trunc(a1))*(24*60)
   min=translate(format(tmp//60,2,0),'0',' ')
   hr=tmp%60

   call lineout outname, b1 " : " b2a hr':'min
end /* do */

call lineout outname
say " Results saved to " outname



 

exit



  
 /* ------------------------------------------------------------------ */
 /* function: Check if ANSI is activated                               */
 /*                                                                    */
 /* call:     CheckAnsi                                                */
 /*                                                                    */
 /* where:    -                                                        */
 /*                                                                    */
 /* returns:  1 - ANSI support detected                                */
 /*           0 - no ANSI support available                            */
 /*          -1 - error detecting ansi                                 */
 /*                                                                    */
 /* note:     Tested with the German and the US version of OS/2 3.0    */
 /*                                                                    */
 /*                                                                    */
 CheckAnsi: PROCEDURE
   thisRC = -1
 
   trace off
                         /* install a local error handler              */
   SIGNAL ON ERROR Name InitAnsiEnd
 
   "@ANSI 2>NUL | rxqueue 2>NUL"
 
   thisRC = 0
 
   do while queued() <> 0
     queueLine = lineIN( "QUEUE:" )
     if pos( " on.", queueLine ) <> 0 | ,                       /* USA */
        pos( " (ON).", queueLine ) <> 0 then                    /* GER */
       thisRC = 1
   end /* do while queued() <> 0 */
 
 InitAnsiEnd:
 signal off error
 RETURN thisRC
 
   

/*************/
/* extract user header from userlog_lines. */
get_user_header:procedure expose user_header.
parse arg afile
afile=strip(afile)

/* get header info. ; lines are ignored. User_header.0 contains list of
   .extensions found (i.e.; user_header.!status, user_header.!privileges
   yield user_header.0='STATUS PRIVILEGES '
*/

issht=1
s1: nop
if issht=1 then
   oo=fileread(afile,userlog_lines,40)
else
   oo=fileread(afile,userlog_lines)

isdone=0
user_header.0=' '
do mm=1 to userlog_lines.0
     aline=strip(userlog_lines.mm)
     if abbrev(aline,';')=1 | aline=' ' then iterate
     parse var aline atype ':' aval ; uatype=upper(strip(atype))
     user_header.0=user_header.0||' '||uatype
     if uatype='MESSAGES' then do 
         isdone=1
         leave
     end  /* Do */
     fo='!'||uatype
     user_header.fo=aval
     if uatype='STATUS' then userlog_lines.statusat=mm
 end /* do */
 if isdone=0  & issht=1 then do
     drop user_header.
     issht=0
     signal s1
 end

 return user_header.0





