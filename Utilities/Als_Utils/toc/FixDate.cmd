/* Change the date/time stamp for a file  */

/* First, make sure the additional rexx utilities are loaded */
if RxFuncQuery("SysLoadFuncs") then do
   call RxFuncAdd "SysLoadFuncs", RexxUtil, "SysLoadFuncs"
   call SysLoadFuncs
end

arg fileid fdate ftime indicator . '(' option
option = translate(strip(option))

if fileid = "" | fileid = "?" then do
   say 'Fixes the date/time stamp of a file or list of files'
   say 'For individual file:'
   say '   fileName month/day/year hour:minute:second <AM/PM>'
   say '      where AM/PM indicator is optional,  24 hour clock assumed'
   say '      defaults to current date and time if both date/time missing'
   say '      defaults to 12:00:00am if date given but time is not given'
   say '   Note, fileName can be a file mask and all files matching that'
   say '     pattern in a directory will be set to the specified date/time.'
   say 'For list of files:'
   say '   list_fileName  ( list'
   say ' Various list formats are parsed, such as VM "cms exec" as well as'
   say '   the standard "dir /n" command output, plus others!'
   say "Another option is 'QUIET' to not stop on detected errors."
   say "   or 'SILENT' to not display normal confirmation messages."
   exit 100
end

count = 0
ourRC = 0

/* is there a request to adjust the timestamp by +- minutes? */
if pos('+',option) > 0 | pos('-',option) > 0 then do
   pAdj = pos('+',option)

   if pAdj = 0 then pAdj = pos('-',option)
   tAdj = word(substr(option,pAdj+1),1)
   if substr(option,pAdj,1) = '-' then tAdj = -tAdj
end
else tAdj = 0

If pos('LIST',option) <> 0 Then Do
   list = fileid
   if stream(list,'c','query exists') = '' then do
      say "ERROR: list file '" list "' doesn't exist.  ABORT!"
      exit 8
   end
   Do until substr(stream(list,"D"),1,8) = 'NOTREADY'
      data_line = linein(list)
      If words(data_line) = 0 Then iterate

      If left(data_line,1) = '*' Then iterate

      quotePos = pos('"',data_line)
      If quotePos > 0 Then Do
         If quotePos = 1 Then Do
            parse var data_line '"' fileid '"' .'"' afdate aftime aindicator . '"' .
         End
         Else Do
            parse var data_line yyyy'-'mm'-'dd  aftime . . . '"'fileid'"'
            afdate = mm||'/'||dd||'/'yyyy
            aindicator = ""
         End
      End
      Else Do
         parse var data_line fileid afdate aftime aindicator .
         if pos('/',fileid) > 0 Then Do
            parse var data_line afdate aftime aindicator . fileid
         End
         Else Do
            if (translate(right(afdate,1)) = 'P' | translate(right(afdate,1)) = 'A') &,
                datatype(translate(aftime,'012345678900','0123456789,.')) = 'NUM' & datatype(aindicator) = 'NUM' then do
               parse var data_line afdate aftime . TestEA fileid .
               if datatype(TestEA) = 'NUM'
                  then parse var data_line afdate aftime . TestEA . fileid .
               aindicator = right(aftime,1)||'M'
               aftime = left(aftime,length(aftime)-1)
            end
            else if fileid = '&1' then do
               /* cms exec format */
               parse var data_line . . vmfn vmft vmfm . . . . afdate aftime .
               fileid = vmfn||'.'||vmft
               aindicator = ''
            end
         End
      End
      if afdate = '' then afdate = fdate
      if aftime = '' then aftime = ftime
      if aindicator = '' then aindicator = indicator
      call ChangeIt afdate aftime aindicator
      if trunc(count/150) * 150 = count
         then if count > 0 then say "processed" count "files"
   End
End
Else Do
   quotePos = pos('"',fileid)
   If quotePos > 0
      Then arg '"'fileid'"' fdate ftime indicator . '(' option

   if pos("*",fileid) > 0 Then Do
      rc = SysFileTree(fileid, list, 'FO')
      Do i = 1 to list.0
         fileid = list.i
         call ChangeIt fdate ftime indicator
      End
   End
   Else call ChangeIt fdate ftime indicator
End

if pos('SILENT',option) = 0 then do
   If count = 1 & pos('LIST',option) = 0 Then Do
      if fdate = '' then fdate = " today"
      say fileid 'changed to' fdate ftime indicator
   End
   else say count 'files changed'
end

exit ourRC

ChangeIt: procedure expose count expose option expose fileid ourRC tAdj
   arg fdate ftime indicator
   if fdate = '' then do
      fdate = date('US')
      ftime = time();
   end

   if pos('-',fdate) > 0
      Then parse var fdate mm "-" dd "-" yyyy
      Else if pos(':',fdate) > 0
         Then parse var fdate yyyy ":" mm ":" dd
         Else parse var fdate mm "/" dd "/" yyyy
   if mm > 1900 & pos('-',fdate) > 0
      Then parse var fdate yyyy "-" mm "-" dd

   If yyyy < "1980" Then Do
      if yyyy < "80"
         then yyyy = "20"||yyyy
         else yyyy = "19"||yyyy
   End

   /* Handle situations where the AM/PM indicator is butted to the time */
   x = pos('P',translate(ftime))
   if x > 0 then do
      ftime = left(ftime,x-1)
      indicator = 'PM'
   end
   x = pos('A',translate(ftime))
   if x > 0 then do
      ftime = left(ftime,x-1)
      indicator = 'AM'
   end

   if ftime = "" then ftime= "00:00:00"
   parse var ftime hr ":" min ":" sec
   if min = '' then min = 0
   if sec = '' then sec = 0
   if translate(strip(indicator)) = 'PM' & hr < 12 then hr = hr + 12
   if translate(strip(indicator)) = 'AM' & hr = 12 then hr = 0

   if tAdj \= 0 then do
      /* adjust the time by the amount specified (in minutes) */
      min = min + tAdj
      if min >= 60 then do
         min = min - 60
         hr = hr + 1
      end
      else if min < 0 then do
         min = min + 60
         hr = hr - 1
      end

      if hr > 24 | hr < 0 then do
         if hr > 24 then do
            hr = hr - 24
            dd = dd + 1
         end
         else do
            hr = hr + 24
            dd = dd - 1
         end
         say 'For' fileid fdate ftime indicator
         say ' Possible month/day error adjusting time to' hr||':'||min||':'||sec yyyy||"-"||mm||"-"||dd
         say "Press ENTER to continue..."
         pull ok
      end
   end

   nDate = yyyy||"-"||mm||"-"||dd
   nTime = hr||":"||min||":"sec
   if (substr(nDate,3) \= '69-12-31') then do
      x= SysSetFileDateTime(fileid,nDate,nTime)
      if x <> 0 & pos('QUIET',option) = 0 then do;
         ourRC = 4
         say "Return code from SysSetFileDateTime is" x "for" fileid nDate nTime
         say "Press ENTER to resume..."
         pull ok
      end
      else if (x = 0) then count = count + 1
   end
return
