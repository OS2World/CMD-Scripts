/* eCSDeskTop.cmd */
/* Copyright 2000 Mensys BV */
/* Written by D.J. van Enckevort */
/* All rights reserved */

/* eCSDeskTop.cmd parses a datafile and sets up the desktop accordingly */

/* Revisions */
/* 19-12-2000: Initial version */
/* 19-12-2000: Update to add error checking */
/*             The file is now read in #begin/#end records and lines in */
/*             between are ignored. In addition all functions now check */
/*             their parameters. */
/* 20-12-2000: Improved error checking: if a non-existant file is specified */
/*              you will receive a warning. Added basic statistics */
/* 1-2-2001:Added a little more text output to display any problems - RC*/


call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

comment='//'
begintag=translate('#begin')

arg filename
if filename='' | lines(filename)=0 then
do
  say "eCSDeskTop needs the name of a configuration file as parameter!"
  return 1
end
else
  say 'Updating desktop using: '||filename

line=0
records=0
do while lines(filename)
   thisline=linein(filename)
   line=line+1
   if pos(comment, thisline)=0  then
   do
      if pos(begintag, translate(thisline))>0 then do
         call readrecord filename, thisline
      end
      else do
         if length(strip(thisline))>0 then
            say 'Ignoring line 'line
      end
   end
end
/* say records||' records processed' */

exit 0

readrecord: procedure expose line records QuietMode bootdrv
comment='//'
begintag=translate('#begin')
endtag=translate('#end')
createtag=translate('#create')
replacetag=translate('#replace')
movetag=translate('#move')
setuptag=translate('#setup')
deletetag=translate('#delete')
shadowtag=translate('#shadow')
debugtag=translate('#trace')
parse arg filename, thisline
uThisLine = translate(thisline)
temp=delstr(thisline, 1, pos(begintag, uThisline) + length(begintag)-1)
objectid=strip(temp)

if objectid='' then
do
   say "Error in config file line #"||line|| ": #begin tag misses object ID!"
   say "The program will continue but this record will be ignored!"
   return
end
else
do while lines(filename)
   thisline=linein(filename)
   uThisLine = translate(thisline)
   line=line+1
   if pos(comment, thisline)=0  then do
     if pos(movetag, uthisline)>0 then
        call moveobject objectid, thisline
     else
     if pos(setuptag, uthisline)>0 then
        call setupobject objectid, thisline
     else
     if pos(createtag, uthisline)>0 then
        call createobject objectid, thisline
     else
     if pos(replacetag, uthisline)>0 then
        call createobject objectid, thisline, "R"
     else
     if pos(deletetag, uthisline)>0  then
        call deleteobject objectid
     else
     if pos(shadowtag, uthisline)>0  then
        call shadowobject objectid, thisline
     else
     if pos(debugtag, uthisline)>0 then
     do
        interpret substr(thisline,2)   /* #trace ?i or #trace o */
     end
     else
     if pos(endtag, uthisline)>0 then
     do
        records=records+1
        return
     end
     else
     if pos(begintag, uthisline)>0 then
     do
        say "Error in config file line #"||line|| ": nested #begin tags!"
        exit 2
     end
   end
end
return

moveobject: procedure
parse arg objectid, thisline
parse var thisline word1' 'location
if location='' then
do
  say "Error in config file line #"||line|| ": Missing parameter in #move tag!"
  say line||': '||thisline
  return
end
rc=SysMoveObject(objectid, location)
if rc<>1 then say ' ! MOVING : Failed! Error: 'rc' - 'objectid' to 'location
else SAY " > MOVING : "objectid" to "location
return

shadowobject: procedure expose QuietMode
parse arg objectid, thisline
parse var thisline word1' 'location
if location='' then
do
  say "Error in config file line #"||line|| ": Missing parameter in #shadow tag!"
  say line||': '||thisline
  return
end
rc=SysCreateShadow(objectid, location)
   if rc<>1 then say ' ! SHADOW : Failed! Error: 'rc' - 'objectid' to 'location
   else SAY " > SHADOW : "objectid" to "location
return

setupobject: procedure
parse arg objectid, thisline
parse var thisline word1' 'setupstring
if setupstring='' then
do
     say "Error in config file line #"||line|| ": Missing parameter in #setup tag!"
     say line||': '||thisline
  return 
end
else
if right(setupstring, 1)<>';' then
   setupstring=setupstring||';'
rc=SysSetObjectData(objectid, setupstring)
if rc<>1 then say ' ! SETUP  : Failed! Error: 'rc' - 'objectid
else SAY " > SETUP  : "objectid
return

createobject: procedure
parse arg objectid, thisline, option
if (option="") then do
   option = "U"
end
parse var thisline word1' 'location', 'classname', 'title', 'setupstring
if location='' | classname='' | title='' then
do
  say "Error in config file line #"||line|| ": Missing parameter in #create tag!"
  say line||': '||thisline
  return
end
if right(setupstring, 1)<>';' & setupstring<>'' then
   setupstring=setupstring||';'
setupstring=setupstring||'OBJECTID='||objectid||';'
rc=SysCreateObject(classname, title, location, setupstring, option)
if rc<>1 then say ' ! CREATE : Failed! Error: 'rc' - 'objectid' to 'location
else SAY " > CREATE : "objectid" to "location
return

deleteobject: procedure
parse arg objectid
rc=SysDestroyObject(objectid)
if rc<>1 then say ' ! DELETE : Failed! Error: 'rc' - 'objectid' to 'location
else SAY " > DELETE : "objectid" to "location
return
