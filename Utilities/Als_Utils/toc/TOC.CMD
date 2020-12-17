/* create and maintain a "Table of Contents" listing of 1 or more drives */

parse source . . exname .
parse arg drives fno '/' keep

/* set defaults */
prefix = '\TOC'    /* files created in root with name TOCymmdd.LST */
suffix = '.LST'    /* extension of our contents file we create */
if keep = ''
   then keep = 3   /* # of files to keep ... 1 per day */

/* default to all local drives */
if drives = '' then drives = '*'

/* display help if requested */
if drives = '?' | drives = '-?' then do
   say 'Manage Table of Contents listings'
   say ''
   say 'Syntax:'
   say '  ' exname '<drives> <single_output_filename>'
   say ' Where <drives> is a list of drive 1 or more drive letters'
   say '   If not specified, it defaults to "*" meaning all local drives'
   say '   When listing a single drive, an output file name may be given'
   say '     otherwise it defaults to TOCymmdd.LST on the respective drive'
   say ' '
   say ' To remove all the TOC files:' exname '<drives> /0'
   say ''
   say 'The purpose is to create up to' keep 'daily listings of the contents'
   say 'of a drive.  Thus in case the directory structure gets corrupted, we'
   say 'might have some idea of what was recently on the drive.'
   exit 100
end

/* we need the Rexx Utilities */
call RxFuncAdd "SysLoadFuncs", RexxUtil, "SysLoadFuncs"
call SysLoadFuncs

/* if not otherwise specified, get a list of all local drives */
If (substr(drives,1,1) = '*') Then Do
  call RxFuncAdd 'SysDriveMap','RexxUtil','SysDriveMap'
  drives = SysDriveMap(,'LOCAL')
End
Else Do
  /* a list of drives was specified as 1 or more strings */
  parseString = drives
  drives = ''
  /* for each word of the arguments */
  Do i = 1 to words(parseString)
     w = word(parseString,i)||' '
     /* parse this word as one or more drive letters followed by optional ':' */
     Do x = 1 to length(w)
        l = translate(substr(w,x,1))
        if l < 'A' | l > 'Z' then iterate
        drives = drives l

        If substr(w,x+1,1) = ':'  /* The string may or may not contain a ':' */
           Then x = x + 1
        /* standardize the format of the drives parameter */
        drives = drives||':'
     End
  End
End
mask = strip(drives)

/* filter out the drives that aren't manageable */
drives = ''
Do i = 1 to words(mask)
   aDriveLetter = word(mask,i)
   /* don't think about read only drives or ones that aren't ready */
   parse value SysDriveInfo(aDriveLetter) with theDrive free size label
   If theDrive = '' | free = 0
      Then aDriveLetter = ''
   Else Do
      /* or ones where we can't access the root directory */
      rc = SysFileTree(aDriveLetter||'\',files,'D')
      if rc \= 0 | files.0 = 0 then aDriveLetter = ''
   End

   If words(aDriveLetter) = 1 Then drives = drives aDriveLetter
End
drives = strip(drives)
say 'Managing Table of Contents listing for' drives

/* for each drive that is being monitored */
prefix = '\TOC'
suffix = '.LST'
Do i = 1 to words(drives)
   /* get a list of all the TOC files on this drive */
   mask = word(drives,i)||prefix||'*'||suffix
   rc = SysFileTree(mask,files,'F')

   /* filter out any files that fit the mask but aren't really tocdmmyy files */
   Do j = 1 to files.0
      /* parse this current entry */
      lj = files.j
      parse var lj dtJ tmJ sizeJ attrJ fnameJ
      parse value filespec('name',fnameJ) with fBaseNamej '.' fBaseExtJ
      If datatype(substr(fBaseNameJ,length(prefix))) \= 'NUM' then do
         lj = j
         files.lj = ''
         Do k = j+1 to files.0
            files.lj = files.k
         End
         lj = files.0 - 1
         files.0 = lj
      End
   End

   /* sort these by timestamp, descending so we keep the latest */
   Do j = 1 to files.0 - 1
      Do k = j+1 to files.0
         /* parse this current entry */
         lj = files.j
         parse var lj dtJ tmJ sizeJ attrJ fnameJ

         /* Normalize the Date/Time field */
         parse var dtJ mm '/' dd '/' yy
         parse var tmJ hr ':' min
         if translate(right(min,1)) = 'P'
            then min = substr(min,1,length(min)-1)+12
            else min = substr(min,1,length(min)-1)
         dtJ = right('2020'||yy+0,4)||'-'||right('00'||mm+0,2)||'-'||right('00'||dd+0,2)
         tmJ = right('00'||hr+0,2)||':'||right('00'||min+0,2)

         /* parse the next entry */
         lk = files.k
         parse var lk dtK tmK sizeK attrK fnameK

         /* Normalize the Date/Time field */
         parse var dtK mm '/' dd '/' yy
         parse var tmK hr ':' min
         if translate(right(min,1)) = 'P'
            then min = substr(min,1,length(min)-1)+12
            else min = substr(min,1,length(min)-1)
         dtK = right('2020'||yy+0,4)||'-'||right('00'||mm+0,2)||'-'||right('00'||dd+0,2)
         tmK = right('00'||hr+0,2)||':'||right('00'||min+0,2)

         If dtJ < dtK || (dtJ = dtK && tmJ < tmK) Then Do
            /* swap them */
            files.j = lk
            files.k = lj
         End
      End
   End

   /* create the name of the today's version */
   fn = word(drives,i)||prefix||substr(date('SORTED'),4)||suffix
   if words(drives) = 1 & fno \= ''
      then fn = fno

   /* if the most recent file wasn't created today */
   l1 = files.1
   parse var l1 dtJ tmJ sizeJ attrJ fnameJ
   If files.0 = 0 | translate(fn) \= translate(strip(fnameJ,'B')) & keep > 0 Then Do

      /* create a new TOC file */
      say 'creating new Table of Contents in ' fn
      '@call drivedir' word(drives,i)||'\* >'fn

      /* we created one, so one less to keep of the original ones */
      k = keep
   End
   Else k = keep + 1   /* we keep the first "keep" number, and erase the next */

   /* get rid of any extra files so we only keep the correct number around */
   Do j = k to files.0
      lj = files.j

      /* a "belt and suspenders" check of what we are going to erase! */
      parse var lj dtJ tmJ sizeJ attrJ fnameJ
      fnameJ = strip(fnameJ,'B')
      If translate(filespec('drive',fnameJ)) = word(drives,i) Then Do
         If filespec('path',fnameJ) = '\' Then Do
            If '\'||substr(filespec('name',translate(fnameJ)),1,length(prefix)-1) = prefix & fno = '' Then Do
               say 'Erasing extraneous Table of Contents file:' fnameJ
               '@erase' fnameJ
            End
         End
      End
   End

End
