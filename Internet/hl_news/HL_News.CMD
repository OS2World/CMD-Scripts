/*
HL_News: A  Headline News Viewer (ver 2.1)
By Tom Fredrickson
6-12-1999


Citation:
   Headline News Viewer is based on  the  Deja News Reader  by
   Eric Walker (ftp.highboskage.com/dnreader)

Requirements:
   Headline News requires the following dynamic link libraries (DLL):
       REXXLIB.DLL and RXWIN30.DLL from Quercus Systems at
              http://www.quercus-sys.com/files/rexxlib.zip
       RXSOCK.DLL:  the IBM EWS RxSock library is usually installed with 
                OS/2. If you do not a copy of RXSOCK.DLL, you  can find it at
                 ftp.ibm.com/pub/pccbbs/os2_ews/rxsock.zip
   These DLL library files must be in your LIBPATH (say, in x:\os2\dll, where
    x: is your boot drive), or in the same directory as HL_NEWS.CMD

Installation:
  a)  Copy HL_NEWS.CMD., NEWS.CFG, and  possibly the aforementioned DLLs
        to one of your applications directory.
  b)  create a SITES, LOADS and SAVE subdirectories under this directory --
       these are used for workspace.
       If you want to use diffferent names for these workspace directories,
      you can modify NEWS.CFG.
  c)  Copy Site.list to SITES directory and edit for the sites you would like to keep

  Caution:
         The  LOADS subdirectory is subject to bulk erasal -- do NOT put anything in
         LOADS that you want to keep!


 Acknowlegements:

  * I must give specal thanks to Daniel Hellerstein author of HTML_TXT
     Without his help I would have probably not been able to get the text
     formatted in such a nice way.



*/




/***SETUP & INITIALIZATION:***************************************************/

/*   Rexx Function Extensions:  */

/*      Add Extended REXX Functions.  */
junk='Found RexxUtil DLL already available.'
If RxFuncQuery('SysLoadFuncs')=1 Then
  Do
    rexxutils=1
    junk='Loaded RexxUtils DLL functions locally.'
    If RxFuncAdd('SysLoadFuncs','RexxUtil','SysLoadFuncs')=0 Then Call SysLoadFuncs
     Else
      Do
        Say 'HL_News Unable to register OS/2 RexxUtils DLL functions.'
        Say
        Exit -1
      End
  End


/*      Add Quercus REXXLIB Functions.  */
text='Found RexxLib DLL already available.'
If RxFuncQuery('rexxlibregister')=1 Then
  Do
    quercuslib=1
    text='Loaded RexxLib DLL functions locally.'
    If RxFuncAdd('rexxlibregister','rexxlib','rexxlibregister')=0 Then Call RexxLibRegister
     Else
      Do
        Say 'HL_News Unable to register Quercus RexxLib DLL functions.'
        Say
        If rexxutils Then Call SysDropFuncs
        Exit -2
      End
  End

Call SysCls
Call CursorType ,,0  /* remove cursor from screen */
Call ScrWrite 1,1,Center('Setting up . . . ',80),,,31
Call ScrWrite 25,1,Center('Loading needed DLL functions . . . ',80),,,31
Call ScrWrite  5,1,Center(junk,80),,,14
Call ScrWrite  8,1,Center(text,80),,,14


/*      Add Quercus Window Functions.  */
text='Found RXWin30 DLL already available.'
If RxFuncQuery('w_open')=1 Then
  Do
    quercuswin=1
    text='Loaded RXWin30 DLL functions locally.'
    If RxFuncAdd('w_register','rxwin30','rxwindow')=0 Then Call W_Register
     Else
      Do
        Call ScrWrite 11,1,'Unable to register Quercus RXWin30 DLL functions.',,,12
        Call ScrWrite 13,1,Center('(Press any key to exit.)',80),,,15
        Call InKey
        Call SysCls
        If quercuslib Then Call RexxLibDeregister
        If rexxutils Then Call SysDropFuncs
        Exit -3
      End
  End
Call ScrWrite 11,1,Center(text,80),,,14
hello=W_Open(18,1,5,80,79)
Call W_Border hello
Call W_ScrWrite hello,3,2,Center('Remember!  The <F1> key brings help at any list-selection screen.',78)


/*      Add RxSock DLL functions.  */
text='Found RxSock DLL already available.'
If RxFuncQuery('SockLoadFuncs')=1 Then
  Do
    rexxsock=1
    text='Loaded RxSock DLL functions locally.'
    If RxFuncAdd('SockLoadFuncs','RxSock','SockLoadFuncs')=0 Then Call SockLoadFuncs dummy
     Else
      Do
        Call ScrWrite 14,1,'Unable to register IBM-EWS RxSock DLL functions.',,,12
        Call ScrWrite 16,1,Center('(Press any key to exit.)',80),,,15
        Call InKey
        'cls'
        If quercuswin Then Call W_Deregister
        If quercuslib Then Call RexxLibDeregister
        If rexxutils Then Call SysDropFuncs
        Exit -4
      End
  End
Call ScrWrite 14,1,Center(text,80),,,14
Drop junk text



/*   Initializations:  */

Call ScrWrite 25,1,Center('Initializing values . . . ',80),,,31


/*      Set essential (error-exit) "global" values.  */
rexxutils=0
quercuslib=0
quercuswin=0
rexxsock=0
global='rexxutils quercuslib quercuswin rexxsock boops'


/*      Set error reporting.  */
Signal On SYNTAX
Signal On HALT


/*      Set universal values.  */
homedir=Directory()


/*      Set scan codes.  */
pgup=D2C(73)
pgdn=D2C(81)
upkey=D2C(72)
dnkey=D2C(80)
leftkey=D2C(75)
rightkey=D2C(77)
ins=D2C(82)
del=D2C(83)
homekey=D2C(71)
endkey=D2C(79)
helpf1=D2C(59)
alts=D2C(31)
alti=D2C(23)
scancodes='pgup pgdn upkey dnkey leftkey rightkey ins del homekey endkey helpf1 alti alts' 


/*      User-settable values.  */

/*         Initialize values  */
gofr_wek=0
line_len=78
h_mark=''
hi_asc=0
loadsdir=homedir'\LOADS\'
sitesdir=homedir'\SITES\'
savesdir=''
boops=1
sitescolor=79      /*  white on RED   */
artcolor=96        /*  black on brown   */
hitpick=10         /*  GREEN on black   */

/*         Over-ride via CNF file  */
Call FileRead 'NEWS.CNF','dummy.'
Do line=1 to dummy.0
  If Pos('boops=',dummy.line)>0 Then Interpret dummy.line
  If Pos('loadsdir=',dummy.line)>0 Then Interpret dummy.line
  If Pos('sitesdir=',dummy.line)>0 Then Interpret dummy.line
  If Pos('savesdir=',dummy.line)>0 Then Interpret dummy.line
  If Pos('sitescolor=',dummy.line)>0 Then Interpret dummy.line
  If Pos('artcolor=',dummy.line)>0 Then Interpret dummy.line
  If Pos('hitpick=',dummy.line)>0 Then Interpret dummy.line
  If Pos('line_len=',dummy.line)>0 Then Interpret dummy.line
  /*If Pos('gofr_wek=',dummy.line)>0 Then Interpret dummy.line*/
  If Pos('hi_asc=',dummy.line)>0 Then Interpret dummy.line
  If Pos('h_mark=',dummy.line)>0 Then Interpret dummy.line

End
Drop line dummy.
If boops<>0 and boops<>1 Then boops=1
If crossmax>10 Then crossmax=10


/*      Augment "global" variables list.  */
cr=D2C(13)
crlf=D2C(13)||D2C(10)
escape=D2C(27)
nul=''
help=0
alfabase=64  /* ascii of "A" minus 1 */
global=global||' cr crlf escape nul help alfabase homedir loadsdir sitesdir line_len h_mark hi_asc savesdir'

/*      Initialize pointers cv.  */
pointers.0=5
Do junk=1 To 5
  pointers.junk=nul
End
Drop junk
!nextup=1
!oneback=2
!hitlist=3
!thread=4
!author=5
pointerstuff='pointers. !nextup !oneback !hitlist !thread !author'

/* title day for gopher */
T_Day=''

/*   Net SetUp:  */

Call ScrWrite 25,1,Center('Resolving addresses . . . ',80),,,31


/*      Get queries-host dot address.  */
queryserver=NewHost('dailynews.yahoo.com')
If queryserver=nul Then Call ItQuits 'Is the network down? Unable to resolve query-server name--exiting.',-5



/*   Set other procedure-expose groups:  */

colors='sitescolor artcolor hitpick '
poststuff='poster postserver username password email myname myorg editor groupname quoter intro crossmax'
criteria='svcclass ageweight agesign showsort msgmax'



/*   Clean plate:  */

/*      Delete any old Load files.  */
Call ScrWrite 25,1,Center('Cleaning up . . . ',80),,,31
Call SysFileTree loadsdir'*.*','dummy.','FO'
If (dummy.0)>0 Then Call KillAll '*.*'

/*      Close "hello" window.  */
Call Delay 3
Call W_Close hello
Call CursorType ,,0
drop dummy. hello




/***MAIN ACTIVITY LOOP:*******************************************************/

IF BOOPS THEN CALL SOUND 500,.1
       rc=DosIsDIR('SITES')

              if rc<>1 then do 
                
      if PopUp('Check SITES directory set up! Run intall.CMD?',4,nul)='Y' then do 

          Quiet=1
          '@echo off'
         '@call HL_install.cmd 'Quiet
         '@echo on'
         end
     else Call ItQuits 'Run HL_install.cmd.',0


         end
/*CALL POPUP 'This is BETA 1 of Headline News',2,'X'*/

Do Forever  
  /*  Select Clusters, Browse, Search, or Quit  */
  If boops Then Call Sound 900,.1
   Call ScrClear 16
    Call ScrWrite  1,1,Center('Task-Selection Screen:',80),,,31
    Call ScrWrite  2,1,'Help f1',80,,30

    Call ScrWrite  3,1,Copies('Í',80),,,31
    Call ScrWrite  5,1,center('HEADLINE NEWS',80),,,30
    Call ScrWrite  7,1,Copies('Í',80),,,31
    Call ScrWrite  10,10,'I = Select sites to get headlines',,,30
    Call ScrWrite 13,10,'B = Browse local list of news headlines',,,30
    Call ScrWrite 16,10,'D = Download a new list of headlines from all sites!',,,30
    Call ScrWrite 19,10,'M = HL_News Maintenance Edit, Add, or Build site list ',,,30
    Call ScrWrite 23,1,Copies('Í',80),,,31
    Call ScrWrite 25,1,Center('Select a task by indicator letter (<Esc> quits the program).',80),,,31

  ok=0
  allowed='BDIM'||escape
  help=8
  Do Until ok
    gothelp=0
    pressed=Upper(InKey())
    If Length(pressed)=2 Then
      Do
        scancode=Right(pressed,1)
        If scancode=helpf1 Then
          Do
            gothelp=1
            Call ShowHelp
          End
      End
     Else ok=Verify(pressed,allowed,'M')
    If gothelp=0 & ok=0 Then Call Sound 40,.3
    If pressed=escape Then
      Do
        If PopUp('Do you really want to exit this program?',6)='N' Then ok=0
         Else Call ItQuits 'Normal exit.',0
      End
  End
  help=0
  Call ScrClear
  /*  Do Called-For Task  */
  Select
    /*When pressed='I' Then Call Interests*/
    When pressed='B' Then do /*Browse*/
        rc=DosIsFile(loadsdir'SEARCH.REF')
        if rc<>1 then 
        do
          call PopUp 'No Reference File download a list!',4,'X'
          iterate
         end
    else do ;bill=1; Call OffLine;end
    end /* do */
    When pressed='D' Then do /*call search*/
       rc=DosIsFile(sitesdir'site.list')

              if rc<>1 then do 
      if PopUp('Check SITES directory set up! No site list! Make list now?',4,nul)='Y' then '@call Maint'
        else call popup 'Run HL_News Maintenance',2,'X' ; iterate
        end
    else Call Search 
  /* search will be online mode*/
  end
      When pressed='I' Then do /*call search*/
       rc=DosIsFile(sitesdir'site.list')

              if rc<>1 then do 
      if PopUp('Check SITES directory set up! No site list! Make list now?',4,nul)='Y' then '@call Maint'

        else call popup 'Run HL_News Maintenance',2,'X' ; iterate/* Call ItQuits 'Normal exit.',0*/
        end
    else Call DoList  
  /* search will be online mode*/
  end
  When pressed='M' then '@call Maint'

  otherwise nop
  End

 End




/******GET HEADLINES ACTIVITY LOOP:********************************************/
DoList:
 
 choicebase=0
 Do Forever
  Call ScrWrite 1,1,Center('Building HeadLine File:',80),,,31

help=1
New_Site=GetChoice()
help=0
if New_Site=0 then leave
   if New_site>0 then do
      parse var New_Site '['site']'
   call dosdel loadsdir'SEARCH.HIT'
   call dosdel loadsdir'SEARCH.REF'
   
New_site=GetHeadlines(New_Site 'B')
end
if New_site=-1 then iterate
  artibase=0
 toread=New_site

     Do Forever
    toread=PickArticle(site)                   /*  Select article from search results      */
    If toread=nul Then leave                 /*  User quits article selection            */
    if toread>0 then do
    toread=GetUrl(toread)
    Do Forever
      toread=ReadArticle(toread)               /*  User could select next article here     */
      If toread=nul Then Leave                 /*  User quits internal article selection   */
    End
  End
  end
End
Return



Search:

/*  Actual activity loop.  */
call dosdel loadsdir'SEARCH.HIT'
call dosdel loadsdir'SEARCH.REF'


Do Forever
  Call ScrWrite 1,1,Center('Building HeadLine File:',80),,,31
  /*plug in download list from site.list*/
  call fileread sitesdir'site.list','site.'
  type='S'
do line =1 to site.0
    if site.line=nul then iterate
   if pos('[end]',site.line)>0 then leave
   n_site=GetHeadlines(site.line type)
   end
   if n_site<0 then do
      call popup 'Problem loading headline list! Now Exiting HL_News',4,'X'
      Call ItQuits 'Normal exit.',0

   end /* do */
  

  bill=0
OffLine:

if bill=1 then got=1
  /*got=ParseSearch()*/
  artibase=0                               /*  Re-initialize articles-list placeholder */
  Do Forever
    toread=PickArticle()                   /*  Select article from search results      */
    If toread=nul Then Leave                 /*  User quits article selection            */
    if toread>0 then do
    toread=GetUrl(toread)
    Do Forever
      toread=ReadArticle(toread)               /*  User could select next article here     */
      If toread=nul Then Leave                 /*  User quits internal article selection   */
    End
  End
End
Return



/*  Procedures Specific To This Task.  */
GetHeadlines: 
Procedure Expose (global) T_Day 
parse arg site href' ['com']' type

  site=site
  if site='gopher.voa.gov' then do
     
   /* get a day */
   width=44
reverse = 112
normal = 31
 top=1
 /*curline=2*/

day.1='Sunday'
day.2='Monday'
day.3='Tuesday'
day.4='Wednesday'
day.5='Thursday'
day.6='Friday'
day.7='Saturday'
day.0=7
now=date('W')
call arraysearch 'day.','today.',now
curline=today.1
curline=curline+1
w = w_open(7,5,10,44,normal)
/*w = w_open(2,1,height+2,width,normal)*/
call w_border w,,,,,30
call w_put w,2,19,'Voice of America',17
call w_put w,3,16,'Select day for Articles',24
call w_put w,4,15,'Use  keys to select day',26
call w_put w,5,21,'Press Enter',12


count=day.0
old_top = 0
newdir = 1
do forever
    if top \= old_top then
    do
call w_hide w, 'n'
do i = 0 to 7
    j = top + i
    if j>count then call w_put w,i+2,3,copies(' ',width-6),width-4
    else do
    call w_put w, i+2, 3, day.j, 10/*width-4*/
    end
    if i+2 = curline then do
       col= lastpos(d2c(196),day.j) + 3
    call w_attr w, i+2, col, length(day.j) - col + 3, reverse
        end
        /*call highlight day.j, i+2*/
    end
call w_unhide w
end /* do */
      /* call show*/
    old_top = top
    current = top + curline - 2
    key=inkey()
    select
       when key=escape then do 
          call w_close w
          return -1
       end /* do */
       when key='0d'X then do 
          T_Day=day.current
        gday=lower(day.current)
        gday=substr(gday,1,3)
                  call w_close w
          leave
       end /* do */
when key ='0050'X then do

             if current = count then
                iterate
            if curline <= 10 then do
                call w_attr w, curline, 3, 10, normal
                curline = curline + 1
                current = top + curline - 2
                 col= lastpos(d2c(196),day.current) + 3
                 call w_attr w, curline, col, length(day.current) - col + 3, reverse

                end
            else
                top = top + 1
            end
        when key = '0048'X then do
            if current = 1 then
                iterate
            if curline > 2 then do
                call w_attr w, curline, 3, 10, normal
                curline = curline - 1
                current = top + curline - 2
                 col= lastpos(d2c(196),day.current) + 3
                 call w_attr w, curline, col, length(day.current) - col + 3, reverse

                end
            else
                top = top - 1
            end

    otherwise nop
    end  /* select */
end /*forever*/
     port=70
     /*gday=substr(date('W'),1,3)*/
     /*gday=lower(gday)*/
     query=href||gday
  end /* do */
  else do
  query=href
  port=80
  end
  artlist=MakeQuery(query,site,port,0,type)
  /*:::::::::::::::::::::::::::::::::::::::::::::::::::::::
        query=""
      queryserver=NewHost("")
      ok=MakeQuery(query,queryserver,'80','N')

  MakeQuery gets the server's response and saves it in a
  file named SEARCH.HTM; it returns 0 for success or, for 
  any failure, -1.
  :::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
 /* If artlist<0 Then Call PopUp 'Search failed somehow!',4,'X'*/
  If artlist<0 Then return artlist

       got=ParseSearch(type)
  If got=0 Then do /*Call PopUp 'There were NO Headlines returned.',3,'X'*/
     rc=DosIsFile(loadsdir'SEARCH.REF')
        if rc<>1 then Call PopUp 'There were NO Headlines returned.',3,'X' 
          return -1
        end /* do */

   return got

ParseSearch:
Procedure Expose (global) query site
Parse arg type
Call ScrWrite 1,1,Center('Reply complete; parsing list . . . 'query,80),,,31    
Call ScrWrite 25,1,Center('Building headlines: 'site,80),,,31
if type='S' then Call FileRead loadsdir'SEARCH.HTM','html.'
else call Fileread loadsdir'Browse.HTM','html.'
/*  Extract hits/hrefs from raw file.  */
/*get a news list */
line=0
count=0
href.=''
hits.=''
href.0=0
hits.0=0
getout=0
no_start_mess='cant find start '
  select
     when site='dailynews.yahoo.com' then
     do

        select
           when pos('/ca/',query)>0 then Point='ca.dailynews.yahoo.com/ca/headlines'

        otherwise point='dailynews.yahoo.com/headlines'

        end  /* select */

          found.1=0
       call arraysearch 'html.','found.',point,'S'
          /*
        found.1=0
       call arraysearch 'html.','found.','dailynews.yahoo.com/headlines','S'
       */
       if found.1>0 then beginat=found.1 
        else do                                                                             
       call Scrwrite  23,1,Center('cant find start 'site,80),,,79                  
       return  0                                                                
         end  
       do line=beginat to html.0
           if pos('>&nbsp;',html.line)>0 then iterate
            if pos('>&#183;<',html.line)>0 then iterate

          getout=Pos('<HR>',upper(html.line))
            ref=Pos('HREF',upper(html.line))

           if getout>0 then leave
                 if ref>0 then do
                  count=count+1
           start=pos('//',html.line)+2
           cut=pos('"',html.line,start)
           if start >0 then  href.count=substr(html.line,start,cut-start)
                start=pos('<b>',html.line)+3
                cut=Pos('</b>',html.line)
                
                 hit.count=substr(html.line,start,cut-start)
                end
       end
      end
        when site='7am.com' then
        do
           call arraysearch 'html.','found.','<!-- LASTUPDATE -->'
            if found.1>0 then beginat=found.1 
             else do                                                                             
       call Scrwrite  23,1,Center(no_start_mess' 'site,80),,,79                  
       return 0                                                                
         end  
            call arraysearch 'html.','found.','"copyright.gif',,beginat
            if found.1>0 then endat=found.1-1
                                 else do                                                                             
       call Scrwrite  23,1,Center('cant find end! 'site,80),,,79                  
       return 0                                                                
         end 
            
             do line=beginat to endat
                 if getout>0 then leave
                 ref=Pos('<LI>',upper(html.line)) 
                       if ref>0 then do
                        count=count+1
                 start=pos('//',html.line)+2
                 cut=pos('"',html.line,start)
                 if start >0 then  href.count=substr(html.line,start,cut-start)
                  hit.count=dehtml(html.line)
             end
             end
            end /* 7am.com */
            when site='gopher.voa.gov' then
              do line=1 to html.0
                 test=html.line
                  if test='.' then leave
                 parse var test '0'h_l  '0'ref 
                 if ref='' then iterate
               count=count+1
                 start=pos('09'X,ref)
                    href_s=left(ref,start)
                    /*gopher.voa.gov:70/00*/
                    href='gopher.voa.gov:70/00'||strip(href_s,'T','09'X)
                    href.count=href
                    hit.count=strip(h_l,'T','09'X)
                 
               end /* gopher */
               when site='www.vny.com' then
               Do 
                     call arraysearch 'html.','found.',' (GMT)<'
                     if found.1>0 then beginat=found.1 
                      else do                                                                             
       call Scrwrite  23,1,Center(no_start_mess' 'site,80),,,79                  
       return 0                                                                
         end  

                     call arraysearch 'html.','found.','</table>',,beginat
                     if found.1>0 then endat=found.1-1
                                          else do                                                                             
       call Scrwrite  23,1,Center('cant find end! 'site,80),,,79                  
       return 0                                                                
         end 
                 
                  site='www.vny.com/cf/News/'
                   do line=beginat to endat
                  /* if Pos('<HR>',upper(html.line))>0 then leave*/
                  start=Pos('HREF=',upper(html.line))
                  if start>0 then do
                        count=count+1
                 cut=pos('">',html.line,start+1)
                 href=substr(html.line,start+6,cut-start-6)
                 href.count=site || href
                hit_a=DeHtml(html.line)
                hit.count=strip(hit_a,'L','20'X)
                  end /* do */
                  end
                 site='www.vny.com'
               end /* do */

               when site='www.latimes.com' then do    /* la times start */
              
                  site='www.latimes.com'

                 
                   get_out=0

                  start=upper(date('W'))                                                    
                 found.1=0
                 call arraysearch 'html.','found.',start
                 if found.1>0 then beginat=found.1
                 else do
                                call arraysearch 'html.','found.','<b>TOP STORY</b>','S' 
                       if found.1>0 then beginat=found.1                         
                       else do

                       call arraysearch 'html.','found.','<!--endHead-->','S' /*<!--CONTENT SPACE-->','S'            */
                       if found.1>0 then beginat=found.1                         
                       else do
                                            call arraysearch 'html.','found.','<!--CONTENT SPACE-->','S'                                  
                  if found.1>0 then do ;beginat=found.1 ;get_out=1;end                                           
                     else do
                                                 else do                                                                             
       call Scrwrite  23,1,Center('cant find start! 'site,80),,,79                  
       return 0                                                                
         end 

                     end /* do */
                  end /* do */

                 /* end /* do */*/
                      /* else return 0   */
                       end /* do */
                                                               
                  call arraysearch 'html.','found.','<!--BOTTOM NAV ROW-->',,beginat           
                  if found.1>0 then endat=found.1-1    
                                                 else do                                                                             
       call Scrwrite  23,1,Center('cant find end! 'site,80),,,79                  
       return 0                                                                
         end 
                  text=''
                  capon=0
                  do line=beginat to endat

                           if html.line=nul then iterate line

                          /* start=Pos('HREF=',upper(html.line))*/
     /*if start>0 then do*/
          if pos('href=""',html.line)>0 then iterate line
          if pos('http:',html.line)>0 then iterate line
       text_in=translate(html.line,' ','0da00009'X)
        html=html||text_in
        end
        anchor=0
        do until html=''
           if html='' then leave

           parse var html t1'<'t2 t2a'>'html
           T1=CONVERT_CODES(T1,CAPON,ISPRE,ULINEON)
           text=text' 'strip(t1,)
           if pos('A',upper(t2))>0 then do/*  say '['t2a']'*/

           iman=upper(left(html,4))                /* fix for img in anchors */
           if pos('<IMG',iman)>0 then iterate

           if anchor=0 then do
              
           start=pos('HREF=',upper(t2a))
           if start>0 then do
              anchor=1
               count=count+1
               cut=pos('"',t2a,start+6)
               href= substr(t2a,start+6,cut-7)
               href.count=site||href
               text=''
               end/*anchor*/
                 end
                end /*start*/
                   if  pos('/A',upper(t2))>0 & anchor=1 then do/*hit1||t1*/
                      if text>'' then hit.count=strip(text,)
                      else hit.count=href.count
                      text=''
                      anchor=0
                   end /* do */
                 /*else  text=text' 't1*/
                 end
           do i =1 to count
               no_link=Pos('HIT.',hit.i)
              if no_link>0 then hit.i='?????'
           end /* do */

               end /* www.latimes.com */

               when site='www.news.com' then do 

                   call arraysearch 'html.','found.','>One Week View<','S'
                       if found.1>0 then beginat=found.1     
                        call arraysearch 'html.','found.','More News','S'
                       if found.1>0 then endat=found.1 
                                              html=''
                       count=0
                       do line=beginat to endat
                           if html.line=nul then iterate line

                          /* start=Pos('HREF=',upper(html.line))*/
     /*if start>0 then do*/
        if pos('<font color="#000000">',html.line)>0 then iterate line
        if pos('HTTP://',upper(html.line))>0 then iterate line

        if Pos('/Categories',html.line)>0 then iterate line
        if pos('Week/List',html.line)>0 then iterate line
        if pos('/Investor/Quote/',html.line)>0 then iterate line

       text_in=translate(html.line,' ','0da00009'X)
        html=html||text_in
        end
        do until html=''
           if html='' then leave
           parse var html t1'<'t2 t2a'>'html
           if t2='a' then do /*say '['t2a']'t1*/
              count=count+1
              hit1=''
              start=1+pos('"',t2a)
              cut=pos('"',t2a,start+1)
              href.count=substr(t2a,start,cut-start)
              href.count=site||href.count
           end /* do */

           if t2='img' then do  /*say ']'t2a'['*/
              istart=5+pos('ALT="',upper(t2a))
              
              /*cut=pos('"',t2a,istart)*/

             if istart>0 then do;cut=pos('"',t2a,istart);hit1=substr(t2a,istart,cut-istart);end
                
             else hit1=''
           end /* do */
           if t2='/a' then hit.count=hit1||t1

               end /* www.news.com */
               end
                 
               when site='cnn.com' then do
                  /* start cnn.com/QUICKNEWS/print.html/ */
count=0
hit_on=0
call arraysearch 'html.','found.','<A NAME="Top1">','S'
beginat=found.1
do line=beginat to html.0
   if pos('3333CC',html.line)>0 then iterate
    text_in=translate(html.line,' ','0da00009'X)
        html=html||text_in
       /* end*/
        end
        do until html=''
           if html='' then leave
           parse var html t1'<'t2 t2a'>'html
           select
              when upper(t2)='A' then do
                 start=Pos('://',t2a)
                 if start>0 then do

                    cut=pos('/',t2a,start+3)
                    if cut<1 then iterate
                    href_cut=pos('"',t2a,cut)
                    site=substr(t2a,start+3,cut-start-3)
                    if pos('cnnsi',site)>0 then iterate
                    if pos('ad.',site)>0 then iterate
                    href=substr(t2a,cut,href_cut-cut)
                    count=count+1
                    hit_on=1
                    href.count=site' 'href
                 end /* do */
              end /* do */
              when upper(t2)='/A'&hit_on=1 then do 
                 hit.count=strip(t1,'B','2D'X)
                 hit_on=0
              end /* do */

           otherwise   nop
           end  /* select */

    
end /* do */

               end /* do cnn.com/QUICKNEWS/print.html/ */

               /* start www.washingtonpost.com */
               when site='www.washingtonpost.com' then do
                      anc_on=0
                      found.1=0
                         site='www.washingtonpost.com'
                       call arraysearch 'html.','found.','Start of Digest item','S'
                       if found.1>0 then beginat=found.1     
                       else do
                          call arraysearch 'html.','found.','Last updated:','S'
                          if found.1>0 then beginat=found.1
                                                 else do
                          call Scrwrite  23,1,Center('cant find start! 'site,80),,,79                  
                            return 0                                                                
                       end /* do */
                       end /* do */
                       found.1=0
                       call arraysearch 'html.','found.','End of Digest item','S'/*More News','S'*/
                       stop=found.0

                       if found.stop>0 then endat=found.stop 
                       else do
                          call arraysearch 'html.','found.','The Washington Post Company','S'
                          if found.1>0 then endat=found.1
                                                    else do
                          call Scrwrite  23,1,Center('cant find end! 'site,80),,,79                  
                            return 0                                                                
                       end /* do */

                       end /* do */

                       html=''
                       beginat =beginat+3
                       do line=beginat to endat
                           if html.line=nul then iterate line

          if pos('href=""',html.line)>0 then iterate line
          if pos('http:',html.line)>0 then iterate line
          if pos('[',html.line)>0 then iterate line
          if pos(']',html.line)>0 then iterate line

       text_in=translate(html.line,' ','0da00009'X)
        html=html||text_in
        end
        do until html=''
           if html='' then leave

           parse var html t1'<'t2 t2a'>'html
           t2=translate(t2)
           if Pos('digest2.htm',t2a)>0 then anc_on=2
           select
              when t2='A'&anc_on=0 then do
                 start=pos('HREF=',upper(t2a))
              cut=pos('"',t2a,start+8)
              if start>0 then do
                 count=count+1
                 href=substr(t2a,start+6,cut-start-6)
                 href.count=site' '||strip(href,'L','.')
                  anc_on=1
              end /* do */
              end
              when t2='CENTER' then 
                 anc_on=2
              when t2='/A'&anc_on=1 then do
              hit.count=t1
              anc_on=0
              end
              when t2='/A'&anc_on=2 then anc_on=0
           otherwise  nop
           end  /* select */
           end

               end /* do www.washingtonpost.com*/
          
               when site='www.newsday.com' then do
                  /* start www.newsday.com */
site='www.newsday.com'
html=''
anc_on=0
ok=0
found.1=0
call arraysearch 'html.','found.','>Today on newsday.com:','s'
if found.1>0 then do 
   beginat=found.1
   ok=1
end /* do */
else beginat=5
do line=beginat to html.0
   text_in=translate(html.line,' ','0da00009'X)
        html=html||text_in
        end
        do until html=''
           if html='' then leave

           parse var html t1'<'t2 t2a'>'html

          select
             when upper(t2)='A'&ok=1 then do
                if anc_on=1 then do
                   hit.count=t1
                   anc_on=0
                end /* do */
              start=pos('HREF=',upper(t2a))
              cut=pos('"',t2a,start+8)
              if start>0 then do
                 count=count+1
                 href=substr(t2a,start+6,cut-start-6)
                  link=pos('://',href)
                  if link>0 then do
                    parse var href .'com'href
                    href.count=site' 'href
                  end /* do */
                else href.count=site' /ap/'href
                 anc_on=1
              end /* do */
              end
              when upper(t2)='/A'&anc_on=1 then do
              hit.count=strip(t1)
              anc_on=0
              end
              when upper(t2)='A/'&anc_on=1 then do
              hit.count=strip(t1)
              anc_on=0
              end
              when upper(t2)='UL' then ok=1
          otherwise  if anc_on=1& t1>'' then do
             hit.count=strip(t1)
             anc_on=0                
          end /* do */
          end  /* select */

end /* do */

               end /* do www.newsday.com*/
              otherwise return 0
  end  /* select */
   



hit.0=count
href.0=count
if count>0 then do
   call filewrite loadsdir'SEARCH.HIT','hit.','A'
   call filewrite loadsdir'SEARCH.REF','href.','A'
Return count
end
   else return 0

/*stop*/


/***SHARED PROCEDURES, ROUTINES, ETC.:****************************************/

/*   Major Routines:  */

PickArticle:
Procedure Expose (global) (scancodes) (colors) (pointerstuff) (poststuff)  artibase groupname queryserver T_Day
Parse Arg site
  /* search */
  do
      scheme1=hitpick
      scheme2=hitpick
      namespec='SEARCH'
      serial=0
      usename='News HeadLines: 'site
      if site='Voice of America' then usename=usename' 'T_Day
      mode='S'
      end
call fileread loadsdir'SEARCH.HIT','hits.'
call fileread loadsdir'SEARCH.REF','hrefs'
art=hits.0
if site='' then help=3
else help=11
picked=0
nextblock=''
Do Until picked
Call ScrWrite 1,1,Center('Current "'usename'"',80),,,31
  /*  Display 22-line window of list selections.  */
  attr=scheme1
  Do row=3 To 24    
    inset=(row-2)+artibase  /* row 3 is "A" */
    If inset<=art Then
      Do
        test=Strip(hits.inset,'L')
        blanks=(Length(hits.inset))-Length(test)
        If blanks=0 | Left(test,4)='Re: ' Then
          Do
            If attr=scheme1 Then attr=scheme2
             Else attr=scheme1
          End
        leader=D2C(row-2+alfabase)': '
        Call ScrWrite row,1,leader||Left(hits.inset,77),,,attr
        top=row
      End
     Else Call ScrWrite row,1,' ',80,' ',2
  End
  Call ScrWrite 2,1,Center('Local list lines 'artibase+1' To 'artibase+top-2' (of 'hits.0')',80),,,15
  /*  Get valid user choice.  */
  top=D2C(top-2+alfabase)
  allowed=XRange('A',top)
  Call ScrWrite 25,1,Center('Pick an Article by corresponding letter key.',80),,,31
  ok=0
  Do Until ok
    pressed=InKey()
    If Length(pressed)=1 Then 
      Do
        scancode=nul
        pressed=Upper(pressed)
        If pressed=escape Then ok=1
        If Verify(pressed,allowed,'Match') Then 
          Do
            index=artibase+C2D(pressed)-alfabase
            If hrefs.index<>nul Then ok=1
          End
      End
     Else 
      Do
        scancode=Right(pressed,1)
        pressed=nul
        If scancode=pgup | scancode=pgdn | scancode=homekey | scancode=endkey | scancode=helpf1 Then ok=1
      End
    If \ok Then Call Sound 40,.3
  End  /* of UNTIL OK loop */
  /*  Process choice as appropriate.  */
  picked=0
  If scancode<>nul Then
    Do
      Select
        /*  Screen-change keys.  */
        When scancode=pgup Then
          Do
            If artibase=0 Then 
              Do
                If boops Then Call Sound 200,.1
              End
             Else artibase=artibase-22
            If artibase<0 Then artibase=0
          End
        When scancode=pgdn Then
          Do
            If artibase<art-22 Then 
              Do
                artibase=artibase+22
                If artibase>(art-22) Then artibase=art-22
              End
              /* +++++++++++?+++++++++*/
             Else
              Do
                If nextblock='' Then Call Sound 40,.3
              End  /* of were-at-end */
             
          End  /* of PgDn */
        When scancode=homekey Then 
          Do
            If artibase=0 Then 
              Do
                If boops Then Call Sound 200,.1
              End
             Else artibase=0
          End
        When scancode=endkey Then 
          Do
            If artibase>=art-22 Then 
              Do
                If boops Then Call Sound 1300,.1
              End
             Else artibase=art-22
            If artibase<0 Then artibase=0
          End
        When scancode=helpf1 Then 
          Do
            Call ShowHelp
          End
      End  /* Select scancode */
    End  /* nonascii key used */
   Else
    Do
      picked=1
      If pressed=escape Then toread=nul
      Else toread=hrefs.index

    End
End  /* of Do-Until-Picked loop */
help=0
Return toread


ReadArticle:
Procedure Expose (global) (scancodes) (pointerstuff) (colors) (poststuff) /*queryserver*/
Parse Arg toread
 parse var toread query site port type
ok=MakeQuery(query,site,port,0,type)
/*If ok<0 Then Call PopUp 'Article NOT returned!',4,'X'*/
If ok<0 Then Return nul
/*call dosdel loadsdir'IMAGE.TXT'*/
call dosdel loadsdir'IMG.REF'
call dosdel loadsdir'IMG.HIT'

 if site='gopher.voa.gov' then do
    Call FileRead loadsdir'ARTICLE.HTM','article.'
    Call ScrWrite 1,1,Center('Converting 'article.0' HTML lines to straight text . . . ',80),,,31
    Call ScrWrite 25,1,Center(site' 'query,80),,,31
     If article.0>0 then call FileWrite loadsdir'ARTICLE.TXT','article.'
 end /* do */
 else do
Call FileRead loadsdir'ARTICLE.HTM','text.'
Call ScrWrite 1,1,Center('Converting 'text.0' HTML lines to straight text . . . ',80),,,31
Call ScrWrite 25,1,Center(site query,80),,,31

/*===How to read article====*/
no_start_mess=''
      select                                                                           
         when site='dailynews.yahoo.com'  then do  /* checked */                              
            read_by=1
            start='TimeStamp:'
            stop='<!-- TextEnd -->'        /* need -1 from endat */
         end /* do dailynews.yahoo.com */
         when site='gopher.voa.gov'  then do        /* checked */                             
            read_by=2
            beginat=1
            endat=text.0 
         end /* do gopher.voa.gov */
         when site='www.vny.com'   then do         /**/                            
             read_by=3 
             start='<title>'
             stop='</PRE>'        /* need-2 */
           end /* do vny.com */
         when site='www.latimes.com'   then do       /* checked */                           
                        read_by=4
            found.1=0
            call arraysearch 'text.','found.','<div align=right>'
            if found.1>0 then start='<div align=right>'
             else do; call arraysearch 'text.','found.','<!--CONTENT SPACE-->'
                  if found.1>0 then start='<!--CONTENT SPACE-->'
             else start='<!--LEFT SIDE LINKS END-->'
             end
             found.1=0
             call arraysearch 'text.','found.','<!--STORY ENDS-->'
                if found.1>0 then stop='<!--STORY ENDS-->'
                else stop='<!--BOTTOM NAV ROW-->'
         end /* do LA Times */
            
         when site='7am.com'   then do                 /**/
            read_by=5
            call arraysearch 'text.','found.','A 7am News Special Feature'
            if found.1>0 then start='<TITLE>'
                else   start='<FONT SIZE=5>'
                found.1=0
              call arraysearch 'text.','found.','#0000c0'
              if found.1>0 then stop='#0000c0'
               else  stop='<B>Previous Stories</B>'
         end /* do 7am.com */
         when site='cnn.com'   then do                 /* checked */
            read_by=6
            deal=0
            found.1=0
            call arraysearch 'text.','found.','PASTE CONTENT BELOW'
            if found.1>0 then do;start='PASTE CONTENT BELOW'
               stop='PASTE CONTENT ABOVE'
            end /* do */
            else do;start='Paste story between here'
               /*stop='Relateds'*/
              found.0=0
            call arraysearch 'text.','found.','Paste story between here'
            if found.2>0 then deal=found.2
            
            end
            end /* do cnn.com */
         when site='www.washingtonpost.com' then  do   /**/                         
         found.1=0
         call arraysearch 'text.','found.1','302 Moved'
             if found.1>0 then do
                 call Scrwrite  23,1,Center('Connection: closed Article Moved 'site,80),,,79
                 return  nextart
                   end
         read_by=7
         found.1=0
         call arraysearch 'text','found.','plsfield:headline','S'
         if found.1>0 then start='plsfield:headline'
         else do
            call arraysearch 'text','found.','plsfield:title','S'
            if found.1>0 then start='plsfield:title'
            else start='END 1ST LEFT NAV TABLE'
         end /* do */
         
         stop='The Washington Post Company'
          found.1=0
           end /* do www.washingtonpost.com */
         when site='news.bbc.co.uk'   then do          /**/                      
            read_by=8
         call arraysearch 'text.','found.1','Published','S'
             if found.1>0 then start='Published'
             else start='date" component *'


         call arraysearch 'text.','found.1','<!--Section Navigation -->'
             if found.1>0 then stop='<!--Section Navigation -->'
             else stop='Search/Back'
               /*
            start='date" component *'
            stop='Search/Back'
            */
         end /* do news.bbc.co.uk */
         when site='www.wired.com'  then do                /**/                      
            read_by=9
            /* get headline out<!-- HEADLINE=The Sordid Saga of Sex.com -->*/
            start='HEADLINE='
            stop='- END_OF_BODY -'
         end /* do www.wired  */ 
         when site='cnnfn.com'   then do               /**/                         
            read_by=10
                                    found.0=0
            call arraysearch 'text.','found.','-Start Header Block'
            if found.0>0 then start='-Start Header Block'
             else do; call arraysearch 'text.','found.','digitaljam'
                  if found.1>0 then start='digitaljam'
             else start='<title>'
             end
             found.1=0
             call arraysearch 'text.','found.','-End Body-'
                if found.1>0 then stop='-End Body-'
                else stop='Copyright '
         end /* do cnnfn.com */
         when site='www.news.com.au'  then do             /**/                         
            read_by=11
            start='<!-- START: Columns Table -->'
            stop='<!-- END: Columns Table -->'
         end /* do */
         when site='www.zdii.com'   then do            /**/                         
            read_by=12
            start='- content start center table -'
            stop='-content stop-'
         end /* do */
         when site='www.futurecard'   then do          /**/                         
            read_by=13
             call Scrwrite  23,1,Center('Need Credit? Goto:'site,80),,,79           
             return  nextart                                                           
         end /* do */
         when site='www.news.com'   then do            /**/                         
            read_by=14
            start='<blockquote>'
               found.1=0
            call arraysearch 'text.','found.','<!-- MAIN CONTENT -->','S'
            if found.1>0 then start='<!-- MAIN CONTENT -->'
               
               stop='</blockquote>'
         end /* www.news.com */

         when site='dynamic.webpoint.com' then  do           /*checked*/                 
            read_by=15  
             start='<!-- START TEXT -->'
             stop='<!-- END TEXT -->'       /* some strange character */
              end /* do */
          when site='www.techweb.com'   then do       /**/      
             read_by=16                                  
             start='-HEADLINE-'
             stop='-/BODY-'                
          end /* do */                                   
          when site='www.newsday.com' then do
             readby=17
             start='<TD COLSTART="2">'
             stop='03'X'AP'
          end /* do */
           when site=' www.nando.net' then do
              readby=18
              start='<head>'
              stop='FOR DEBUGGING'
           end /* do */

                                                                                       
      otherwise                                                                        
      read_by=0                                                                        
       call ArraySearch 'text.','found.','/applet','S'
         if found.0>0 then beginat=found.1+1
          else beginat=1
          endat=text.0
      end  /* select */                                                                


if no_start_mess='' then no_start_mess='Cant find text start.'

  found.1=0                                                                           
  call ArraySearch 'text.','found.',start,'S'                                         
  if found.1>0 then  beginat=found.1                                                  
  else do                                                                             
       call Scrwrite  23,1,Center(no_start_mess' 'site,80),,,79                  
       return  nextart                                                                
         end                                                                          
         found.1=0                                                                    
   if stop='' then endat=text.0
   else do
  call ArraySearch 'text.','found.',stop,'S'                                          
  if found.1>0 then  endat=found.1                                                    
  else endat=text.0                                                                             
    end
/*-- add beginat endat ajustments here --*/
/*if read_by=1 then endat=endat-1*/
if read_by=3 then endat=endat-2
if read_by=6 then do
   if deal>0 then endat=deal
   else endat=endat-1
end /* do */

article.0=0
count=0
in=0
out=0
pre_tx_on=0
cut_on=0
pre_tx_on=0
get_out=0

text=''
do line=beginat to endat
   if text.line=nul then iterate line
   /*---------site specific -------------*/

     if read_by=4 then do           /* la times */
     if pos('>ADVERTISEMENT<',text.line)>0 then iterate line
     in=Pos('<!--LEFT SIDE LINKS BEGIN-->',text.line)
     out=Pos('<!--LEFT SIDE LINKS END-->',text.line)
  end /* do */

      if read_by=10 then do
         in=pos('Start Related Links',text.line)
         out=pos('End Related Links',text.line)
      end /* do */
    if read_by=14 then do              /* www.news.com */
       if pos('>&nbsp;Do you want to know more?<',text.line)>0 then iterate line
       if pos('newsLinks">',text.line)>0 then iterate line
       if pos('Message Boards</a',text.line)>0 then iterate line
         in=pos('<B>QUOTE SNAPSHOT',upper(text.line))

        out=pos('20+ minutes<',text.line)
        /*get_out=pos('>News around the Web<',text.line) */
        get_out=pos('>Related news stories<',text.line)
        

        if pos('News.com</a>',text.line)>0 then iterate line

    end /* do */
        if read_by =9 then do
       if pos('Related Wired Links:',text.line)>0 then leave
    end /* do */

   if pos('<PRE>',upper(text.line))>0 then pre_tx_on=1
   if pos('</PRE>',upper(text.line))>0 then pre_tx_on=0
       if get_out>0 then leave
  count=count+1
     text_in=translate(text.line,' ','0da00009'X)
      if get_out>0 then leave
        if in>0 then text_in=insert('[cut]',text_in,in)
        if out>0 then text_in=insert('[/cut]',text_in,out+10)
   text=text' 'text_in    
   if pre_tx_on=1 then text=text||' [pre]'
  end

    text=DeHtml(text)
     
    
       call Wrapper text
     /*  if count>0 then call filewrite loadsdir'ARTICLE.TXT','article.','R'*/
    end /* gopher not */

 count=article.0
Call ScrWrite 1,1,Center('Article From: 'site,80),,,31
nextart=nul
baseline=0
inset=0
done=0
temp=W_Open(2,1,23,80,artcolor)
help=6
Do Until done
  /*  Clear FULL screen in case of side trips made  */
  Call W_Clear temp,artcolor,' ',2,1,23,80
  /*  Display 23-line window of article.  */
  top=baseline+23
  If top>count Then top=count
  Call ScrWrite 25,1,Center('Lines 'baseline+1' to 'top' of 'article.0,80),,,31
  maxlength=0
  Do row=1 To top
    index=row+baseline
    Call W_ScrWrite temp,row,1,SubStr(article.index,1+inset,80)
    If Length(article.index)>maxlength Then maxlength=Length(article.index)
  End
  /*  Get a valid keypress.  */
  ok=0
  Do Until ok | done
    pressed=InKey()
    If Length(pressed)=1 Then 
      Do
        scancode=nul
        If pressed=escape Then done=1
         Else Call Sound 40,.3
      End
     Else 
      Do
        scancode=Right(pressed,1)
        pressed=nul
        Select
          When scancode=pgup Then
            Do
              ok=1
              If baseline=0 Then 
                Do
                  If boops Then Call Sound 200,.1
                End
               Else baseline=baseline-23
            End
          When scancode=pgdn Then
            Do
              ok=1
              If baseline>=(count-23) Then 
                Do
                  If boops Then Call Sound 1300,.1
                End
               Else 
                Do
                  baseline=baseline+23
                  If (baseline+24)>count Then baseline=count-23
                End
            End
          When scancode=homekey Then 
            Do
              ok=1
              If baseline=0 Then 
                Do
                  If boops Then Call Sound 200,.1
                End
               Else baseline=0
            End
          When scancode=endkey Then 
            Do
              ok=1
              If baseline=count-23 Then 
                Do
                  If boops Then Call Sound 1300,.1
                End
               Else baseline=count-23
            End
          When scancode=leftkey Then
            Do
              ok=1
              If inset=0 Then 
                Do
                  If boops Then Call Sound 200,.1
                End
               Else inset=inset-10
            End
          When scancode=rightkey Then
            Do
              ok=1
              If inset>=(maxlength-80) Then 
                Do
                  If boops Then Call Sound 1300,.1
                End
               Else 
                Do
                  inset=inset+10
                  If (inset+80)>maxlength Then inset=maxlength-80
                End
            End
          When scancode=helpf1 Then 
            Do
              Call ShowHelp
            End
/*::::::::Special-call keys:::::::::::::::::::::::::::::::::::::::::::*/
          When scancode=alts Then
            Do
              ok=1
              Call SaveIt
            End
          When scancode=alti Then
            Do
              ok=1
              Call ShowHeader
            End
          Otherwise Call Sound 40,.3
        End  /* Select on scancode */
      If baseline<0 Then baseline=0
      If inset<0 Then inset=0
      End  /* scankey pressed */
  End  /* get & process keypress */
  If \ok & \done Then Call Sound 40,.3
End
help=0
Call W_Close temp
Call CursorType ,,0
Return nextart


/*===============================================*/


MakeQuery:
Procedure Expose (global)
Parse Arg query,site,port,serial,type

/*Parse Arg query,serveraddr,port,serial,type*/
serveraddr=NewHost(site)
if port='' then port=80
Select
  When type='S' Then Call ScrWrite 1,1,Center('Getting 'site' HeadLines . . . ',80),,,31
  When type='B' Then Call ScrWrite 1,1,Center('Getting 'site' HeadLines . . . ',80),,,31
  When type='G' Then Call ScrWrite 1,1,Center('Getting requested Gopher Article. . . ',80),,,31
  When type='A' Then Call ScrWrite 1,1,Center('Getting requested Article from: 'site,80),,,31
  Otherwise Call ScrWrite 1,1,Center('Getting requested Article . . . 'site,80),,,31
End
/*  Connect to server for a socket.  */
Call ScrWrite 25,1,Center('Connecting . . . ',80),,,31
/*  Now log on.  */
socket=SockSocket("AF_INET","SOCK_STREAM",0)
If socket=-1 Then
   Do
     If boops Then Call Sound 300,.3
     Call ScrWrite 25,1,Center('Error opening socket!  (Press any key to continue.)',80),,,79
     Call InKey
   End
If socket=-1 Then Return -1
/*  Log on to the socket.  */
Call ScrWrite 25,1,Center('Logging on to socket 'socket' . . . ',80),,,31
server.!family='AF_INET'  /* mandatory  */
server.!port=port  /*  standard HTTP port  */
server.!addr=serveraddr  /* as obtained earlier  */
got=SockConnect(socket,'server.!')
If got=-1 Then
   Do
     If boops Then Call Sound 300,.3
     Call ScrWrite 25,1,Center('Error logging on to socket!  (Press any key to continue.)',80),,,79
     Call InKey
   End
If got=-1 Then Return -1
/*  Send actual service request.  */
Call ScrClear 7,' ',2,1,23,80
Call ScrWrite 25,1,Center('Sending request . . . ',80),,,31
if site='gopher.voa.gov' then  Call SendLine query||crlf,socket
else
DO
Call SendLine 'GET 'query' HTTP/1.0',socket
Call SendLine 'Accept: *'||'/'||'*; q=0.300',socket
Call SendLine 'Accept: application/octet-stream; q=0.100',socket
Call SendLine 'Accept: text/plain',socket
Call SendLine 'Accept: text/html',socket
Call SendLine 'User-Agent: IBM-RxSock-DLL/v1.1',socket
Call SendLine nul,socket
Call SendLine query,socket
END
Call ScrWrite 25,1,Center('Request sent . . . ',80),,,31
buffer=nul
Call Time('R')
Do Until buffer<>nul & data=nul
  If Time('E')>120 Then Leave
  rc=SockRecv(socket,'data',8000)
  If buffer=nul Then Call ScrWrite 25,1,Center('Receiving reply . . . 'Query,80),,,31
  buffer=buffer||data
  If data<>nul Then Call Time('R')
  Call ScrWrite 13,1,Center(Length(buffer)' bytes received . . . ',80),,,14
End
/*  Close socket before proceeding.  */
got=SockSoClose(socket)
If got=-1 Then Call ItQuits 'Error closing socket.',-7
/*  Process response, if any.  */
if type='S' then
do
   If Pos('>Bad Request<',buffer)>0 Then Return -1
   If Pos('Moved Temporarily',buffer)>0 Then Return -1
   If Pos('404 Not',buffer)>0 Then Return -1
   If Pos('302 Not',buffer)>0 Then Return -1
 end
else
do
If Pos('>Bad Request<',buffer)>0 Then Call PopUp 'Server Could Not Understand Query!',4,'X'
If Pos('>Bad Request<',buffer)>0 Then Return -1
If Pos('Moved Temporarily',buffer)>0 Then Call PopUp 'This Article has Been Moved!',4,'X'
If Pos('Moved Temporarily',buffer)>0 Then Return -1
If Pos('404 Not',buffer)>0 Then Call PopUp 'This Article Not Found on server!',4,'X'
If Pos('404 Not',buffer)>0 Then Return -1
If Pos('302 Not',buffer)>0 Then Call PopUp 'This Article has Been Moved!',4,'X'
If Pos('302 Not',buffer)>0 Then Return -1
If Pos('302 Found',buffer)>0 Then Call PopUp 'This Article has Been Moved!',4,'X'
If Pos('302 Found',buffer)>0 Then Return -1

 end
If buffer<>nul Then
  Do      /* need select by QueryServer our type to set up the readArticle*/
    If type='G' Then ok=1/*serial+1*/
     Else ok=0
    dummy.0=1
    dummy.1=buffer
    Call ScrWrite 25,1,Center('Reply received; saving . . . ',80),,,31
    Select
      When type='S' Then dropin='SEARCH'
      When type='B' Then dropin='Browse'
      Otherwise dropin='ARTICLE'
    End
    Call ScrWrite 13,1,Copies(' ',80)
    Call FileWrite loadsdir||dropin||'.HTM','dummy.'
  End
 Else 
   Do
     ok=-1
     Call PopUp 'Error receiving response!',4,'X'
   End
Return ok



/*   Lesser Routines:  */


/*   Small Procedures (only globals Exposed):  */



NewHost:
Procedure Expose (global)
Parse Arg service
If SockGetHostByName(service,'host.!')=0 Then serveraddr=nul
 Else serveraddr=host.!addr
Return serveraddr



GetUrl:
procedure Expose (global)
parse arg url
/*  //gopher.voa.gov:70/00/newswire/mon/CONGO-HUMAN_RIGHTS 
    www.vny.com/cf/News/upidetail.cfm?QID=74278
*/

if pos('gopher',url)>0 Then do
     
     j=pos(':',url)
  site=substr(url,1,j-1)
  com=substr(url,j+5)
  /*
           n=pos('%',com)
           if n >0 then 
           do until n=0
          parse var com '%' !test
          /* set query for gopher*/
          test='%'||substr(!test,1,2)
          old=substr(!test,3)
          new_com=left(com,n-1)
            select
            When test='%26' Then use='&'
            When test='%7C' Then use='|'
            When test='%21' Then use='!'
            When test='%5E' Then use='^'
            When test='%22' Then use='"'
            When test='%3F' Then use='?'
            When test='%29' Then use=')'
            When test='%7B' Then use='{'
            When test='%7D' Then use='}'
            When test='%23' Then use='#'
            When test='%28' Then use='('
            When test='%2C' Then use=','
            When test='%25' Then use='%'
            When test='%3A' Then use=':' 
            When test='%7E' Then use='~'
            Otherwise use='[bad]'
          End
          com=new_com||use||old
           n=pos('%',com)
           
         end
           */
         query=com
/*queryserver=NewHost(site)*/
port=70
type='G'
   return query site port type
   end
else
    do
   j=pos('/',url)
   site_tag=substr(url,1,j-1)
   /*=====could select long or short here======*/
  if site_tag='www.latimes.com' then do
      la=lastpos('.1',url)
      if la>0 then  com_tag=substr(url,j,la-j)||substr(url,la+2)
      else com_tag=substr(url,j)
      comtag=url
      end
      else com_tag=substr(url,j)

query=com_tag
port=80
site=site_tag
return query site port
end

  /*MakeQuery(query,queryserver,0,'A')*/



Wrapper: procedure expose (global) article.
parse arg text
art_text.0=0
art=0
len=0
/*do line=1 to count*/
 sentence=''
   do forever
      if text='' then /* leave*/
      do 
         art=art+1
         /*say sentence*/
         art_text.art=sentence
         leave
      end /* do */
     parse var text aword text
     if aword=d2c(150) then aword='C4'X  /* special characters */
      if length(sentence)+length(aword)> line_len  then do    /*wraps the lines*/
         art=art+1
         art_text.art=sentence
       /* say  sentence /* or lineout it */*/
              if aword='[P]' then do; aword='';art=art+1;/*say ''*/ art_text.art='';end
        if aword='[BR]' then do; aword='';art=art+1;/*say ''*/ art_text.art='';end
           if aword='[pre]' then aword=''
            if aword='[/CENTER]' then aword=''
            if aword='[/TITLE]' then aword=''
            if aword='[CENTER]' then aword=''
            if aword='[TITLE]' then aword=''
            

         sentence=aword
         
    end
   else do
     sentence=sentence' 'aword
     if sentence='[BR]' then sentence=''
     if sentence='[P]' then sentence=''


     brk=pos('[BR]',sentence)-1
      if brk >0 then do
        /*sentence=sentence' 'aword*/
        sentence=left(sentence,brk)
        art=art+1
        art_text.art=sentence
       sentence=''
       art=art+1
       art_text.art=''
       /*say ''*/
       sentence=''
       end

     wrap=pos('[P]',sentence)-1
      if wrap >0 then do
        /*sentence=sentence' 'aword*/
        sentence=left(sentence,wrap)
        art=art+1
        art_text.art=sentence
      /* say sentence*/
       art=art+1
       art_text.art=''
       /*say ''*/
       sentence=''
       art=art+1
       art_text.art=''
       /*say ''*/
       sentence=''

       end



       title=pos('[TITLE]',sentence)-1
       if title>0 then do
          sentence=left(sentence,title)
          art=art+1
          art_text.art=sentence
           art=art+1
          art_text.art=''
          sentence='***'
       end /* do */
       end_title=pos('[/TITLE]',sentence)-1
       if end_title>0 then do
          sentence=left(sentence,end_title)||'***'
           art=art+1
          art_text.art=center(sentence,line_len-2)
           art=art+1
          art_text.art=''
          sentence=''

       end /* do */
              cent=pos('[CENTER]',sentence)-1
       if cent>0 then do
          sentence=left(sentence,cent)
          art=art+1
          art_text.art=sentence
          /*
           art=art+1
          art_text.art=''
          */
          sentence=''
       end /* do */
       end_cent=pos('[/CENTER]',sentence)-1
       if end_cent>0 then do
          sentence=left(sentence,end_cent)
           art=art+1
          art_text.art=center(sentence,line_len-2)
          sentence=''

       end /* do */

       pre_tx=pos('[pre]',sentence)-1
       if pre_tx>0 then do
          sentence=substr(sentence,1,pre_tx)
          art=art+1
          art_text.art=sentence
          sentence=''

       end /* do */
    end  
    end  

  art_text.0=art
 if art>0 then do 
   call filewrite 'loads\ARTICLE.TXT','art_text.','R'
    call arraydelete article.,1, article.0
 call arrayinsert art_text.,article.,1,1, art_text.0
/* end*/
    return 
 end



/*---- New Html markdown---*/
DeHtml:
PROCEDURE expose (global)


parse arg body
thispara=''
capon=0
cut_on=pos('[cut]',body)-1
cut_off=pos('[/cut]',body)+6
if cut_on>0 then body=left(body,cut_on)||substr(body,cut_off)
ispre=0
ulineon=0
img_num=0
img_href.=0
img_alt.=0
do forever
 if body='' then leave
    
    parse var body t1 '<' t2a '>' body
       
    T1=CONVERT_CODES(T1,CAPON,ISPRE,ULINEON)
/* Ready to add more content ..... */
     thispara=thispara||t1      /* ADD T1 TO THISPARA FOR EVENTUAL OUTPUT */
/* now prepare to process this <element> (T2 is first word, T2A is all words */
    t2=strip(translate(word(t2a,1)))             /* get rid of element modifiers */
    if left(t2,1)='/'  then
        t2end=substr(t2,2)
    else
        t2end=''

       /*do some stuff here*/
    select
    when t2='P' then do
       thispara=thispara||' ['t2'] '
    end /* do */
      when t2='PRE' then do;ispre=1;end

       when t2='/PRE' then do;ispre=0;end
        when t2='B' then capon=1
       when t2='/B' then capon=0
       when t2='IMG' then do
          img_num=img_num+1
          imgin=1
          parse var t2a . imgname 
          here=Pos('SRC',upper(imgname))
          start=Pos('"',imgname,here)+1
           if start>1 then cut=pos('"',imgname,start+1)
           else do
              img_num=img_num-1
              imgin=0
           end /* do */
           if imgin=0 then iterate
            link=substr(imgname,start,cut-start)
          here=Pos('ALT',upper(imgname))
          if here>0 then do
          start=pos('"',imgname,here)
           cut=pos('"',imgname,start+1)-1
          link_nam=substr(imgname,start+1,cut-start)
          end
          else link_nam='What no alt tag?'
           img_href.img_num=link
           img_alt.img_num=link_nam

                /*  if cut-start=2 then  imgname=substr(imgname,start+1,1)*/
                if length(link_nam)=1 then alt_let=link_nam
        else alt_let=''
          thispara=thispara||' 'alt_let
          
          end
        when t2='TITLE' then do
       thispara=thispara||' ['t2'] '
    end /* do */
    when t2='/TITLE' then do
       thispara=thispara||' ['t2'] '
       end
         when t2='CENTER' then do
       thispara=thispara||' ['t2'] '
    end /* do */
    when t2='/CENTER' then do
       thispara=thispara||' ['t2'] '
       end

     when wordpos(t2,'H1 H2 H3 H4 H5 H6 H7')>0 then do
       preHead=h_mark
        if h_mark='' then h_mark='0000'X||strip(t2,'L','H')||')'

         thispara=thispara||' [BR] '||h_mark
         h_mark=preHead
           end
              when wordpos(t2,'/H1 /H2 /H3 /H4 /H5 /H6 /H7')>0 then do
         thispara=thispara||' [BR] '
           end

        when t2='BR' then do
       thispara=thispara||' [BR] '
    end /* do */
    when t2='<P' then thispara=thispara||' < [P] '

 otherwise nop
   end
 end
 if img_num>0 then do
    img_href.0=img_num
    img_alt.0=img_num
    call filewrite loadsdir'IMG.REF','img_href.'
    call filewrite loadsdir'IMG.HIT','img_alt.'
 end /* do */
return thispara



/* CONVERT &ENCODING */
CONVERT_CODES:PROCEDURE expose (global)
PARSE ARG T1,CAPON,ISPRE,ULINEON,ISTH

IF T1='' then RETURN T1

      if capon>0 | ISTH='TH' then t1=translate(t1)
      if ispre=0 then t1=translate(T1,' ','0d0a0009'x)
      if ulineon=1 then do
           if ispre=0 then
              t1= translate(space(t1,1),'_',' ')
           else
              t1=translate(t1,'_',' ')
      end /* do */

      tt1=t1 ;t1=''
      do forever
        if tt1='' then leave
        parse var tt1 g1 '& 'g2 .
        parse var tt1 v1 '&' v2a tt1

        t1=t1||v1
        goo=pos(';',v2a)

        if goo>0 then do
            v2=left(v2a,goo-1)
            v3a=substr(v2a,goo+1)
            tt1=v3a' 'tt1
        end /* do */
        else do
           v2=v2a
        end /* do */

        v2=strip(v2)

        if v2<>"" then do
            v2=strip(translate(v2))
            v2=strip(v2,,'#')
            select
               when v2='AMP' then t1=t1||'&'
               when v2='COPY' then t1=t1||' '
               when v2='EACUTE' then t1=t1||D2C(130)
               when v2='LT' then t1=t1||'<'
               when v2='GT' then t1=t1||'>'
               when v2='QUOT' then t1=t1||'"'
               when v2='NBSP' then t1=t1||' '
               when datatype(v2)='NUM' then do 
                  if hi_asc=0 then t1=t1||' '
                  else t1=t1||d2c(v2)
               end /* do */
                 when g2>'' then t1=t1||'& 'v2a' '
               otherwise t1=t1||'&'v2a' '
            end  /* select */
        end /* v2<>"" */
      end /* FOREVER  */
RETURN T1

/*-------------------------------------*/
        /* end text markup*/





/*test*/
GetChoice:
Procedure Expose (global) (colors) (scancodes)  sites. choices.  choicebase  
parse arg type
blank=' ' 
attr=sitescolor/*79*/
forblanks='Ä' 
index=0

select
when type=-1 then do
    count=choices.0
end /* do */
when type=0 then do
   count=sites.0
   Call CursorType ,,0  /* remove cursor from screen */

   Call ScrClear attr,blank,2,1,23,80


end /* do */
otherwise   do
     call fileread sitesdir'site.list','choices.'
     count=choices.0
     Call CursorType ,,0  /* remove cursor from screen */

     Call ScrClear attr,blank,2,1,23,80
 Call ScrWrite 25,1,Center('Pick a News Site by corresponding letter key.',80),,,31
end /* do */
end  /* select */

/*drop_index=drop_in||index*/
/*choicebase=0*/
If count>11 Then skip=1
 Else skip=2
pick=-1
Call ScrClear attr,blank,2,1,23,80
Do Until pick>=0
  /*  Display 23-line window of choices.  */
  allowed=''
  top=choicebase+23
  If top>count Then top=count
  bottom=choicebase+1
  
  Do index=bottom To top
         if type=0 then dropin=sites.index

      else dropin=choices.index
        
     parse var dropin site href '['com']'
    row=index-choicebase+1
    If Strip(dropin)=nul Then Call ScrWrite row,1,Copies(forblanks,80),,,attr
     Else 
      Do
        option=D2C(index-choicebase+alfabase)
        allowed=allowed||option
        Call ScrWrite row,1,option||': 'Left(site' ('com')',77),80,blank,attr
      End
  End
  /*  Get a valid keypress.  */
  top=D2C(top-choicebase+alfabase)
  ok=0
  Do Until ok
    pressed=InKey()
    If Length(pressed)=1 Then 
      Do
        scancode=nul
        pressed=Upper(pressed)
        If Verify(pressed,allowed,'Match') | pressed='+' | pressed=escape | pressed=alt'S' Then ok=1
        If forblanks=blank & pressed='+' Then ok=0  /*  + valid only in group selection */
      End
     Else 
      Do
        scancode=Right(pressed,1)
        pressed=nul
        Select
          When scancode=pgup | scancode=pgdn | scancode=homekey | scancode=endkey | scancode=helpf1 Then ok=1   /*| scancode=alts  */
          Otherwise ok=0
        End
      End
    If \ok Then Call Sound 40,.3
  End
  /*  Process valid keypresses.  */
  If scancode<>nul Then
    Do
      Select
        When scancode=pgup Then
          Do
            If choicebase=0 Then 
              Do
                If boops Then Call Sound 200,.1
              End
             Else choicebase=choicebase-23
          End
          /*
                        When scancode=alts Then
            Do
              ok=1
              return nul
            End
            */
        When scancode=pgdn Then
          Do
            If choicebase>=(count-23) Then 
              Do
                If boops Then Call Sound 1300,.1
              End
             Else 
              Do
                choicebase=choicebase+23
                If (choicebase+24)>count Then choicebase=count-23
              End
          End
        When scancode=homekey Then 
          Do
            If choicebase=0 Then 
              Do
                If boops Then Call Sound 200,.1
              End
             Else choicebase=0
          End
        When scancode=endkey Then 
          Do
            If choicebase=count-23 Then 
              Do
                If boops Then Call Sound 1300,.1
              End
             Else choicebase=count-23
          End
        When scancode=helpf1 Then 
          Do
            Call ShowHelp
          End
      End
      If choicebase<0 Then choicebase=0
    End

   Else
    Do
      Select
        When pressed=escape Then return 0
         Otherwise pick=choicebase+(C2D(pressed))-alfabase
      End
    End
End
if type=0 then Return Sites.pick
else return choices.pick



GetPointer:
Procedure Expose (global)
Parse Arg item
test=Upper(item)
start=Pos('HREF=',test)
If start=0 Then Return nul
start=start+12
If Pos('HREF="',test)>0 Then 
  Do
    start=start+1
    cut=Pos('">',item,start)
  End
 Else cut=Pos('>',item,start)
If cut>0 Then 
  Do
    ref=SubStr(item,start,cut-start)
    If ref<>nul Then
      Do
        start=Pos('/',ref)
        If start>0 Then query=SubStr(ref,start)
         Else query=ref
      End
  End
 Else query=nul
Return query


GetAuthor:           /* cuold be used t get a url ?*/
Procedure Expose (global)
Parse Arg item
start=Pos('/profile.xp',item)
If start=0 Then Return nul
cut=Pos('">',item,start)
If cut=0 Then cut=Pos('>',item,start)
If cut>0 Then query=SubStr(item,start,cut-start)
 Else query=nul
Return query


PopUp:
Procedure Expose (global)
Parse Arg text,color,mode
If mode=nul Then second='Press Y for Yes or any other key for No.'
 Else second='Press any key to continue.'
width=6+Length(text)
If width<46 Then width=46
column=1+((80-width)%2)
If boops Then Call Sound 600,.2
handle=W_Open(10,column,7,width,(color+8)*16)
Call W_Border handle,1,1,1,1
Call W_ScrWrite handle,3,4,Center(text,width-6)
Call W_ScrWrite handle,5,4,Center(second,width-6)
pressed=Upper(InKey())
Call W_Close handle
Call CursorType ,,0
If pressed<>'Y' Then pressed='N'
Return pressed






KillAll:
Procedure Expose (global)
Parse Arg spec
Call SysFileTree loadsdir||spec,'dummy.','FO'
Do i=1 To dummy.0
   if dummy.i=loadsdir||'SEARCH.HIT' then iterate
   if dummy.i=loadsdir||'SEARCH.REF' then iterate
  Call DosDel dummy.i
End
Return


SendLine:
Procedure Expose (global)
Parse Arg tosend,socket
data=tosend||crlf
Do Forever
  If SockSend(socket,data)=Length(data) Then Leave
   Else
    Do
      pressed=PopUp('Failure sending command line.  Retry?',1,nul)
      If pressed='N' Then Call ItQuits 'Fatal error trying to send to server.',-8
    End
End
Return


ShowHeader:
Procedure Expose (global)
Call FileRead loadsdir'IMG.REF','dummy.'
head.0=0
j=0
done=0
Do i=1 To dummy.0
  j=j+1
  If j>18 Then
    Do
      done=1
      j=18
      dummy.j=Center('[Image text overflowed allowed space--not all shown]',80)
    End
  If done Then Leave
  If Length(dummy.i)<=80 Then head.j=dummy.i
   Else
    Do
      head.j=Left(dummy.i,80)
      inset=1+Pos(':',dummy.i)
      balance=SubStr(dummy.i,81)
      allowed=79-inset
      Do While balance<>nul
        j=j+1
        head.j=Copies(' ',inset)||Left(balance,allowed)
        balance=SubStr(balance,1+allowed)
      End
    End  
End
head.0=j
max=5+head.0
temp=W_Open(2,1,max,80,112)
Call W_ScrWrite temp,max-2,1,Center('(Press any key to dismiss image text.)',80)
Call W_ScrWrite temp,max,1,Copies(':',80)
row=1
Do line=1 To head.0
  row=row+1
  Call W_ScrWrite temp,row,1,head.line
End
Call InKey
Call W_Close temp
Call CursorType ,,0
Return


SaveIt:
Procedure Expose (global)
Parse Arg serial
temp=W_Open(10,1,7,80,95)
Call W_Border temp
Call W_ScrWrite temp,3,2,Center('Enter the save-file name (or press <Esc> to abort):',78)
saveas=W_Get(temp,5,2,78,savesdir,15)
Call W_Close temp
Call CursorType ,,0
If saveas<>nul Then
  Do
    If ValidName(saveas) Then
      Do
        testdir=FileSpec('Drive',saveas)||Strip(FileSpec('Path',saveas),'T','\')
        If DosIsDir(testdir) Then 
          Do
            If DosIsFile(saveas) Then 
              Do
                If PopUp('File exists; append?',6)='Y' Then howto='A'
                 Else howto='R'
              End
             Else howto='R'
            /*ec=DosCopy(loadsdir'IMAGE.TXT',saveas,howto)*/
             ec=DosCopy(loadsdir'ARTICLE.TXT',saveas,howto)
            If ec<>0 Then Call PopUp 'Save failed! (rc='ec')',4,'X'
             Else 
               Do
                 If boops Then Call Sound 1200,.1
               End
          End
         Else Call PopUp 'That directory does not exist!  (Not saved.)',3,'X'
      End
     Else Call PopUp 'That is not a valid filespec! (Not saved.)',3,'X'
  End
Call CursorType ,,0
Return




GetALine:
Procedure Expose (global)
Parse Arg socket
buffer=nul
Do While Pos(crlf,buffer)=0
  rc=SockRecv(socket,'data',8000)
  If rc<>-1 Then buffer=buffer||data
End
cut=Pos(crlf,buffer)
If cut>0 Then 
  Do
    got=SubStr(buffer,1,cut-1)
    buffer=SubStr(buffer,cut+2)  /*  keep any excess for later  */
  End
 Else got='### BAD RECEIVE ###'
Return got


LineValue:
Procedure Expose (global)
Parse Arg linevalue
start=Pos(':',linevalue)
linevalue=Strip(SubStr(linevalue,start+1))
Return linevalue


LongMessage:
Procedure Expose (global)
Parse Arg meaning
temp=W_Open(12,1,3,80,79)
Call W_ScrWrite temp,2,1,meaning
Call InKey
Call W_Close temp
Call CursorType ,,0
Return


GoodBye:
Procedure Expose (global)
Parse Arg socket
Call SendLine 'QUIT',socket
Call ScrWrite 25,1,Center('Logging off 'poster'.',80),,,31
got=GetALine(socket)
got=SockSoClose(socket)
If got=-1 Then Call PopUp 'Error closing socket!',4,'X'
Return got



/*   Help Screens:  */

ShowHelp:
Procedure Expose (global)
temp=W_Open(2,1,24,80,31)
Call W_Border temp
Call W_ScrWrite temp,24,2,Center('(Press any key to dismiss this help screen.)',78,'Í')
/*                                      ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8  */
Select

 /*  Pick an Site for Article:  */
        When help=1 Then              
    Do
      Call W_ScrWrite temp, 5,2,Center('You can use the <PgDn>, <PgUp>, <Home>, and <End> keys',78)
      Call W_ScrWrite temp, 7,2,Center('to display more choices (if there are more).',78)
      Call W_ScrWrite temp,10,2,Center('Press any letter shown to get the Headlines from that site.',78)
      Call W_ScrWrite temp,16,2,Center('Press the <Esc> key when done to return to "Task-Selection Screen:".',78)
    End

         When help=2 Then  /*  Add sites to list */
    Do
      Call W_ScrWrite temp, 5,2,Center('You can use the <PgDn>, <PgUp>, <Home>, and <End> keys',78)
      Call W_ScrWrite temp, 7,2,Center('to display more choices (if there are more).',78)
      Call W_ScrWrite temp,9,2,Center('Press any letter shown to add that site to Headline List.',78)
      Call W_ScrWrite temp,11,2,Center('This screen is followed by a window that allows editing of the site name.',78)
      Call W_ScrWrite temp,13,2,Center('Then the next screen selects where to place the site in the list.',78)
      Call W_ScrWrite temp,15,2,Center('When done adding sites press the <ESC> key.',78)
    End

            /*  Pick an Article: Browse Mode */
             When help=3 Then
    Do
      Call W_ScrWrite temp, 5,2,Center('You can use the <PgDn>, <PgUp>, <Home>, and <End> keys',78)
      Call W_ScrWrite temp, 7,2,Center('to display more choices (if there are more).',78)
      Call W_ScrWrite temp,10,2,Center('Press any letter shown to read that specific article.',78)
      Call W_ScrWrite temp,16,2,Center('Press the <Esc> key to return to "Task-Selection Screen:".',78)
    End



                        When help=4 Then    /* Sites inserted */
    Do
      Call W_ScrWrite temp, 5,2,Center('You can use the <PgDn>, <PgUp>, <Home>, and <End> keys',78)
      Call W_ScrWrite temp, 8,2,Center('to display more choices (if there are more).',78)
      Call W_ScrWrite temp,11,2,Center('Press a letter key to insert the new site in the list.',78)
      Call W_ScrWrite temp,14,2,Center('The new site will be inserted below the selected site.',78)
      Call W_ScrWrite temp,16,2,Center('Press the <Esc> key to see the list of sites.',78)
    End


                        When help=5 Then    /* Sites inserted list shown */
    Do
      Call W_ScrWrite temp, 5,2,Center('You can use the <PgDn>, <PgUp>, <Home>, and <End> keys',78)
      Call W_ScrWrite temp, 8,2,Center('to display more choices (if there are more).',78)
      Call W_ScrWrite temp,11,2,Center('This screen shows how the list looks after inserting this site',78)
      Call W_ScrWrite temp,16,2,Center('Press the <Esc> key to select another site to add to the list.',78)
    End

         /*  View an Article:  */
  When help=6 Then
    Do
      Call W_ScrWrite temp, 5,2,Center('You can use the <PgDn>, <PgUp>, <Home>, and <End> keys',78)
      Call W_ScrWrite temp, 6,2,Center('to see more text (if there is more).',78)
      Call W_ScrWrite temp, 10,2,Center('You can use the LeftArrow and RightArrow cursor keys.',78)
      Call W_ScrWrite temp, 14,2,Center('to shift the display sideways if text is off-screen.',78)
      Call W_ScrWrite temp,16,2,Center('Press Alt-S to save this article to a specific file.',78)
      Call W_ScrWrite temp,18,2,Center('Press Alt-I to see image text: a list of any images',78)
      Call W_ScrWrite temp,22,2,Center('Press the <Esc> key to return to selecting articles.',78)
    End



             When help=7 Then    /*  Maintenance */
    Do
      Call W_ScrWrite temp, 5,2,Center('<M> Make sites list will copy all sites to the list used to fetch headlines.',78)
      Call W_ScrWrite temp, 8,2,Center('<E> Edit an existing list of sites. Will delete selected sites from the list.',78)
      Call W_ScrWrite temp,11,2,Center('If there is no site list "Edit Sites will optionally create the site list.',78)
      Call W_ScrWrite temp,11,2,Center('<A> Add sites will add selected sites to site list.',78)
      Call W_ScrWrite temp,16,2,Center('Press the <Esc> key to return to "Task-Selection Screen:".',78)
    End

          /*  Select a Task:  */
  When help=8 Then
    Do
      Call W_ScrWrite temp, 8,2,Center('<I> Loads Site list for selecting articles from chosen Site. ',78)
      Call W_ScrWrite temp, 10,2,Center('<B> Browse all available news headlines from Previously Loaded local file',78)
      Call W_ScrWrite temp,12,2,Center('<D> Loads news headlines for articles. Using all sites in Site List! ',78)
      Call W_ScrWrite temp,14,2,Center('<M> "Maintenance Mode" Edit Site List! ',78)
      Call W_ScrWrite temp,16,2,Center('Press the <Esc> key to completely exit the Reader.',78)
    End


             When help=9 Then    /*  insert rules */
    Do
      Call W_ScrWrite temp, 5,2,Center('You can use the <PgDn>, <PgUp>, <Home>, and <End> keys',78)
      Call W_ScrWrite temp, 8,2,Center('to display more choices (if there are more).',78)
      Call W_ScrWrite temp,11,2,Center('Press a letter key to insert a horizontal rule in the list.',78)
      Call W_ScrWrite temp,13,2,Center('The new rule will be inserted below the selected site.',78)
      Call W_ScrWrite temp,15,2,Center('Press the <Esc> key to continue and save the list of sites.',78)
      Call W_ScrWrite temp,17,2,Center('You will be given a choice to save the file or reset the horizontal rules.',78)
    End

                When help=10 Then  /*  Add sites to list */
    Do
      Call W_ScrWrite temp, 5,2,Center('You can use the <PgDn>, <PgUp>, <Home>, and <End> keys',78)
      Call W_ScrWrite temp, 7,2,Center('to display more choices (if there are more).',78)
      Call W_ScrWrite temp,9,2,Center('Press any letter shown to edit the title of the site.',78)
      Call W_ScrWrite temp,11,2,Center('This screen is followed by a window that allows editing of the site name.',78)
      Call W_ScrWrite temp,13,2,Center('You can remove a site by entering delete in the entry field.',78)
      Call W_ScrWrite temp,15,2,Center('When done editing sites press the <ESC> key.',78)
    End

                        /*  Pick an Article: sites Mode */
             When help=11 Then
    Do
      Call W_ScrWrite temp, 5,2,Center('You can use the <PgDn>, <PgUp>, <Home>, and <End> keys',78)
      Call W_ScrWrite temp, 7,2,Center('to display more choices (if there are more).',78)
      Call W_ScrWrite temp,10,2,Center('Press any letter shown to read that specific article.',78)
      Call W_ScrWrite temp,16,2,Center('Press the <Esc> key to get headlines from another Site.',78)
    End




    Otherwise
    Do
      Call W_ScrWrite temp,12,2,Center('No context-sensitive help is available for this screen.',78)
    End
End
Call InKey
Call W_Close temp
Call CursorType ,,0
Return



/*   Exit Routines:  */

SYNTAX:
which=rc
where=sigl
Do 3
  Call Sound 500,.2
  Call Sound 200,.1
End
Call ScrClear
Call ScrWrite  1,1,Center('A SYNTAX Trap has occurred!',80),,,79
Call ScrWrite  6,1,Center('The error was in Line #'where', which reads:',80),,,63
Call ScrWrite 14,1,Center('The short error description for Rexx Error #'which' is:',80),,,63
Call ScrWrite 15,1,Center(ErrorText(which),80)
Call ScrWrite 25,1,Center('Operation cannot continue--press any key to exit.',80),,,79
Call ScrWrite  7,1,ShowLine(where)
Call Inkey
Call ItQuits 'Syntax Error 'which' on Line 'where'.',-9


HALT:
where=sigl
Do 3
  Call Sound 500,.2
  Call Sound 200,.1
End
Call ScrClear
Call ScrWrite  1,1,Center('A HALT has occurred!',80),,,79
Call ScrWrite 10,1,Left('The Halt occurred while in Line #'where', which reads:',80),,,63
Call ScrWrite 11,1,ShowLine(where)
Call ScrWrite 25,1,Center('Operation cannot continue--press any key to exit.',80),,,79
Call Inkey
Call ItQuits 'HALT initiated while on Line 'where'.',-10


ItQuits:
Procedure Expose (global)
Parse Arg message,ec
Call CursorType ,,1
If rexxsock Then Call SockDropFuncs
If quercuswin Then Call W_Deregister
If quercuslib Then Call RexxLibDeregister
If rexxutils Then Call SysDropFuncs
If boops Then 
  Do
    Call Beep 400,200
    Call Beep 200,100
  End
'cls'
Say
Say '   'message
Say
Say
Exit ec


ShowLine:
Procedure Expose (global)
Parse Arg line
Call FileRead homedir'\HL_News.CMD','reader.'
text=reader.line
Return text


/* [end] */
