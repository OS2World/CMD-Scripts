/* examine a saved "DriveDir" output to see if FOUND* files can be renamed
   to their proper name */

parse arg fn .

call RxFuncAdd "SysLoadFuncs", RexxUtil, "SysLoadFuncs"
call SysLoadFuncs

/* read the input file contents, assumed a DriveDir redirected output */
n = 0
status = stream(fn,'c','open read')
Do While left(status,5) = 'READY'
   data = linein(fn)
   status = stream(fn,'s')
   if left(status,5) = 'READY' then do
      n = n + 1
      mLine.n = data
      parse var data fDate fTime fSize fAttr fName .
      key = fDate||"+"||fTime||"+"||fSize||"+"||fAttr
      mKey.n = key
      mFile.n = fName
      fNameOnly = strip(fName,'B','"')
      fNameOnly = filespec('name',fNameOnly)
      key2 = fSize||"+"||fNameOnly
      mKey2.n = key2
   end
End
status = stream(fn,'c','close')
mLine.0 = n

/* get the current directory structure */
rc = SysFileTree('*',files,'BSL')
Do i = 1 to files.0
  l = files.i
  parse var l dt tm size attr fname

  fname = strip(fname,'B')
  if pos('FOUND',fname) = 0 then iterate      /* must have 'found*' in path */

  /* enumerate all the files with those attributes */
  say fname
  key = dt||"+"||tm||"+"||size||"+"||attr
  nMatches = 0
  matchList = ''
  Do x = 1 to mLine.0
     if mKey.x = key then do
        nMatches = nMatches + 1
        say 'Match' nMatches 'of' fname 'to' mFile.x
        matchTo = mFile.x
        matchList = matchList x
     end
  End

  /* if we only have 1 matching file, move it to where it used to be */
  If nMatches = 1 then do
     say 'we found something to fix up'
     /* invoke the common file move routine to move matchTo to fname */
     call fixit
  End
  Else If nMatches > 1 Then Do
     say "'"||fname||"' matches" nMatches "possibilities"

     /* examine the subdirectory names in the found path for clues */
     rest = substr(reverse(filespec('path',fname)),2)
     s = 0
     Do until rest = ''
        parse var rest r '\' rest
        s = s + 1
        subdir.s = reverse(r)
     End
     subdir.0 = s

     /* for each possibility */
     Do p = 1 by 1
        /* since we manipulate matchList in the loop, must test here */
        If p > words(matchList) Then leave

        x = word(matchList,p)
        matchTo = mFile.x
        rest = substr(reverse(filespec('path',matchTo)),2)
        Do s = 1 by 1 until rest = ''
           parse var rest r '\' rest
           /* a hint as to the origin may be in the found directory path */
           parse value subdir.s with 'FOUND' . '.' clue
           If clue <> '' & translate(clue) <> translate(reverse(r)) Then Do
              /* this clue doesn't match this possibility, remove it */
              matchList = delword(matchList,p,1)
              p = p - 1
              leave
           End
           If s = subdir.0 Then leave
        End
     End

     /* if we still have multiple possibilities */
     If words(matchList) > 1 Then Do p = 1 by 1
        /* since we manipulate matchList in the loop, must test here */
        If p > words(matchList) Then leave

        x = word(matchList,p)
        matchTo = mFile.x

        /* if this possible match already exists */
        If stream(matchTo,'c','query exists') \= '' Then Do
           /* it can't be it */
           matchList = delword(matchList,p,1)
           p = p - 1
        End
     End

     /* If we have only 1 possibility left */
     nMatches = words(matchList)
     If nMatches = 1 Then Do
        /* this is good... move the file */
        x = strip(word(matchList,1))
        matchTo = mFile.x
        say "   Narrowed it down to '"||matchTo||"'"
        call fixit
     End
     Else say '   Narrowed it down to' nMatches 'possibilities'
  End
  Else Do
    fNameOnly = filespec('name',fname)
    if pos('FOUND',fNameOnly) = 1 then do while pos('FOUND',fNameOnly) = 1
       parse var fNameOnly 'FOUND' . '.' fNameOnly
    end
    If length(fNameOnly) >= 1 Then Do
       key2 = size||"+"||fNameOnly
       nMatches = 0
       matchList = ''
       Do x = 1 to mLine.0
          if mKey2.x = key2 then do
             nMatches = nMatches + 1
             say 'Match' nMatches 'of' fname 'to' mFile.x
             matchTo = mFile.x
             matchList = matchList x
          end
       End
       If nMatches = 1 Then Do
          x = word(matchList,1)
          data = mLine.x
          say 'should we assume:'
          say '    ' files.i
          say '  is' data
          say 'Yes or No?'
          pull response
          If translate(left(response,1)) = 'Y' Then Do
             parse var data fDate fTime .
             '@call fixdate.cmd' fname fDate fTime
             call fixit
          End
       End
    End
  End
End

/* now clean up and "found*" empty subdirectories */
rc = SysFileTree('*',dirs,'DSL')
Do i = dirs.0 to 1 by -1
  l = dirs.i
  parse var l dt tm size attr dir
  dir = strip(dir,'B')
  if substr(translate(dir),2,7) \= ':\FOUND' then iterate
  rc = SysFileTree(dir||'\*',nested,'BSL')
  if nested.0 = 0 then do
     'rd "'||dir||'"'
  end
End

exit

fixit: procedure expose matchto fname
  fpath = filespec('path',matchTo)
  nDirs = 0
  thePath = ''
  do while length(fpath) > 0
     parse var fpath aDir '\' fpath
     if aDir = '' then iterate
     nDirs = nDirs + 1
     thePath = thePath||"\"||aDir
     here = directory()

     if thePath \= substr(directory(thePath),3) then do
        'md' thePath
     end

     here = directory(here)
  End

  'move "'||fname||'" "'||substr(matchTo,4)

return
