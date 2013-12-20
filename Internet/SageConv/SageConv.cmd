/* SageR's mail conversion utility - last modified on 3/23/96 */
/* converts from ultimail to mr/2 format */
/* functions on a file by file or directory by directory basis */

/* note: only converts text mime parts and ignores other mime types */
/* remember: SysTempFileName() can't have more than 5 wildcards */

debug = 0
logfile = "scerror.log"
outfile = "tempfile.byl"

rc = rxfuncadd('SysLoadFuncs','RexxUtil','SysLoadFuncs')
  if (rc <> 1) then do
    say "ERROR: Problem loading rexx utility function..."
    say "Quitting..."
    EXIT
  end
  else do
    call sysloadfuncs
  end

parse arg arg.1 arg.2

  if (arg.1 = "") then do
    say "Error: I need to know your userid in order to determine"
    say "      whether a piece of mail is incoming our outgoing."
    say "Usage: SageConvert <username> [filename]"
    EXIT
  end
  else do
    username = translate(arg.1)
    say "Converting on the basis of username:" username
  end

  if (arg.2 = "") then do 	/* convert all files in directory */
    rc = SysFileTree('*.ENV' , 'dirlist', 'F')
    say dirlist.0 "files found."

    do M = 1 to dirlist.0	/* recursion */
      parse var dirlist.M . . . . pathname
      target = filespec("name", pathname)
      call sparse target
    end
  end
  else do 			/* convert one file */
    target = arg.2
    call sparse target
  end

EXIT

sparse:
  parse arg mailfile

  say "Converting" mailfile"."
  inheader = 1
  inpart = 0
  istext = 0
  ext = "RCV"

  do while (lines(mailfile) > 0)
    oneline = strip(linein(mailfile))

    if (inheader) then do
      parse var oneline . 'boundary="'openbound'"' .
      parse var oneline word.1 word.0

      if (openbound <> '') then do
        if (debug) then say "Part Boundary Determined:" openbound
        openbound = "--" || openbound
        closebound = openbound || "--"
        inheader = 0
      end

      if (inheader = 0) then NOP
      else if (translate(word.1) = "MIME-VERSION:") then NOP
      else if (translate(word.1) = "CONTENT-TYPE:") then NOP
      else if (translate(word.1) = "FROM:") then do
        if (lastpos(translate(username), translate(word.0)) <> 0) then do
          ext = "OUT"
        end
        rc = lineout(outfile, oneline)
      end
      else if (translate(word.1) = "TO:") then do
        if (lastpos(translate(username), translate(word.0)) <> 0) then do
          ext = "RCV"
        end
        rc = lineout(outfile, oneline)
      end
      else do
        rc = lineout(outfile, oneline)
      end
    end

    else if (inpart) then do
      if (oneline = closebound) then do	/* closing encounter */
        if (debug) then say "Part Closed:" oneline
        inpart = 0
      end

      else do			/* parsing within a mime definition */
        parse var oneline word.1 word.2 word.0
        if (translate(word.1) == "CONTENT-TYPE:") then do
          if (translate(word.2) == "TEXT/PLAIN;") then do
            parse var word.0 ."filename="mimetext
            if (debug) then say "Mime text part" mimetext "inserted."
            call readmime mimetext outfile 
          end
          else do		/* store non-text mime lines */
            say "Skipping non-text mime:" oneline
            say "Placeholder inserted and filename written to logfile."
            rc = lineout(logfile, "Error parsing mime part in:" mailfile)
            rc = lineout(logfile, "        "oneline)
            rc = lineout(outfile, "Error parsing following mime part.")
            rc = lineout(outfile, "        "oneline)
            ext = "ERR"
          end
        end
      end
    end

    else do				/* parse NON-MIME body lines */
      if (oneline = openbound) then do		/* part boundary */
        if (debug) then say "Part Start Detected:" oneline
        inpart = 1
      end
      else if (oneline = "> THIS IS A MESSAGE IN 'MIME' FORMAT.  Your mail reader does not support MIME.") then NOP
      else if (oneline = "> You may not be able to read some parts of this message.") then NOP
      else do				/* line that will be put */
        rc = lineout(outfile, oneline)
      end
    end
  end

  rc = lineout(mailfile)
  rc = lineout(outfile)
  /* if you comment out the next two lines it will consolidate your mail */
  template = "SC?????."ext 
  randname = SysTempFileName(template)
  'rename' outfile randname
  say ''
return

readmime:	/* reads a mime textfile "thisfile" into "thatfile" */
  parse arg thisfile thatfile

  do while (lines(thisfile) > 0)
    rc = lineout(thatfile, linein(thisfile))
  end
  rc = lineout(thisfile)
return

