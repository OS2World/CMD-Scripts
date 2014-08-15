@show
aa=x.2
if aa='X.2'|x.2=''|x.2='' then do
say 'MUST INPUT AN ALIAS NAME_TRY AGAIN'
x.=''done=1;opcomm.='';lev=1;call adj;return
end
ppp=pather||'master.als';ddd=pather||'123'
re=0
sw=aa;swl=length(sw)
vv='@'||sw
call sysfilesearch vv,ppp,poi
if poi.0=0|swl+1\= length(poi.1) then do
call adj;say  sw 'IS NOT A STORED ALIAS';call adj;return;end
else
do i=1 to al.aa.0
say x2c(1b5b)'1;36m'al.aa.i x2c(1b5b)'0m'
end
$$$$DISPLAYS THE LINES OF AN ALIAS
@e
'call epm' x.2
$$$$OPENS A FILE FOR EDITING
@d
if (datatype(x.2,'W' )=1)&(x.2<9) then aa=x.2
else aa=x.2'*'
'call d' aa
$$$$WILDCARD  QD.CMD
@edtal
'call e f:\master.als'
call loadals
$$$$OPENS MASTER.ALS FILE FOR EDITING
@t
'start /min /c alarm'  x.2 x.3 x.4 x.5 x.6 x.7
$$$$SETS AN ALARM
@refr
'call view rexx.inf'
$$$$opens rexx help
@refc
'call view f:\os2\book\cmdref.inf'
$$$$opens OS2 commands help
@i
if x.2='X.2' then X.2=''
call in x.2
$$$$SYSTEM DRIVE SPECS
@put
'call put' x.2
$$$$alt-p write a comment for an object
@showtmp
 aa=x.2
do i=1 to al.aa.0
say al.aa.i
end
$$$$SHOW TEMPORARY ALIAS STATEMENTS
@co
'call copy' x.2 x.3 
$$$$copy command
@note
'call get' x.2
$$$$display comments to an object
@mo
if x.2\=''&x.3\='' then 'copy' x.2 x.3
if rc=0 then 'del' x.2
$$$$MOVE inc drive to drive
@laz
'cache /Lazy:off'
$$$$turn off lazy write
@cl
'call slaughtr'
$$$$shutdown the system
@win
'start /f /c winos2'
$$$$start a win 3.1 session
@dd
'call dd' x.2||'*'
$$$$filename completing dd.cmd
@cat
do until lines(x.2)=0
line=linein(x.2)
ss=lineout(x.3,line)
end
aa=stream(x.2,'c','close')
aa=stream(x.3,'c','close')
$$$$concatenates 2 files
@log
'del' pather'\blk.log'
$$$$erases blkos2 command log file
@un
'call undelete /a' x.2
$$$$undelete
@fo
'call  format' x.2
$$$$format a disk
@cdd
call directory(x.2)
$$$$change directory across drives
@rec
aa=x.2 x.3 x.4 x.5 x.6 x.7 x.8
sd='list';sd2='dso'
sw=directory()
swq=strip(sw,'B')||'\'
'call' aa
call sysfiletree swq,sd,sd2
do i=1 to list.0
tt=list.i
w=directory(tt)
'call' aa
end
t=directory(sw)
$$$$commands recursively operate on sub dirs
@u5
'call u5' x.2
$$$$start openzip to open an archive
@002C
if x.2='' then return
mxi=0
opcomm.1='<WP_'translate(x.2)'>' x.3
call opendir;return
$$$$ALT- Z opens a standard wps object with objid
@lst
if x.2='' then return
call syscls
oo=0
do until lines(x.2)=0
oo=oo+1
dd.oo=linein(x.2);end
ss=stream(x.2,'c','close')
do forever
ww=oo%20
do u=0 to ww
call syscls
do i=1 to 19
tt=(20*u)+i
if dd.tt\=''&dd.tt\='DD.'tt then  say x2c(1b5b)'0m'dd.tt x2c(1b5b)'0m'
end
in =sysgetkey()
select
when in='u'&u=0 then leave
when in='u' &u-2>-2 then u=u-2
when in='x' then do;call syscls;dd.='';return;end
otherwise nop
end
end
end
$$$$display the contents of a file to screen
@erh
bk.=''
hnu=1
$$$$ERASE THE HISTORY BUFFER
@c
cls
$$$$clears the screen
@002D
exit
$$$$leave blkos2

