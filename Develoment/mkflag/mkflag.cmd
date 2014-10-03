/*  document flags in a makefile */
/* June 29, 2006 ver 1.00 initial version - gjarvis@ieee.org */
/* Although the script looks like Classic REXX, the script uses Object REXX
   "use arg" to pass arguments by reference rather than by value. */

ver = "1.00"
say "mkflag version" ver
parse arg makefile .
if makefile='' then makefile = "makefile"

if \readstem(makefile,mkline.) then do
   say "Can not open file '"makefile"'"
   exit 1
end /* do */
say "read" mkline.0 "lines in" makefile

outline.0comment = '#'
if translate(right(makefile,4))=".CMD" then outline.0comment = 'REM '
tag  = outline.0comment"<mkflag>"
lentag = length(tag)
outline.0 = 0
outline.0wrap = 130
outline.0width = 24
outline.0continue = "\/"

defaults = "defaults."value("HOSTNAME",,"ENVIRONMENT")
if readstem(defaults,defline.) then do
   if defline.0<>1 then
      say defaults "must be only one line"
   else do
      wrap = outline.0wrap
      width = outline.0width
      interpret defline.1
      outline.0wrap = wrap
      outline.0width = width
      say "wrap =" outline.0wrap "width =" outline.0width
   end /* do */
end /* do */

state = 1
do i = 1 to mkline.0
       if state=2 then do /* get first line that is not a comment */
            if left(strip(mkline.i,'L'),length(outline.0comment))=outline.0comment then iterate
            state = 3
       end
       if state=1 then do /* look for <mkflag> tag */
            if left(strip(mkline.i,'L'),lentag)=tag then do
                outline.0indent = left(mkline.i,pos(outline.0comment,mkline.i)-1)
                line = 1
                parse var mkline.i (tag) descfile respfile .
                if readstem(value("home",,"environment")"\mkflag\"descfile,descript.) then state = 2
                say "read" descript.0 "lines in" descfile
                if respfile<>'' then do
                   if verify(respfile,"1234567890")=0 then do
                      line = respfile
                      respfile = ''
                   end
                   else do /* response file */
                      rc = readstem(respfile,flags.)
                      say "read" flags.0 "lines in" respfile
                   end
                end
            end /* do */
       end /* do */
       if state=3 then do /* parse flags */
            /* if not a response file then get current line */
            if respfile='' then do j = 1 to  200 /* assume this is a continued line */
               k = i + j + line - 2
               if k>mkline.0 then do
                  say "Can't find flag line. Processing Aborted."
                  exit  2
               end
               flags.j = mkline.k
              flags.0 = j
               if pos(right(flags.j,1),outline.0continue)=0 then leave
            end
            call parseflags flags., descript., outline.
            state = 1
       end /* do */
    outline.0 = outline.0 + 1
    outline.[outline.0] = mkline.i
end /* do */

if writestem(makefile,outline.) then
    say "write" outline.0 "lines in" makefile
exit  0


/* reads a text file, FILE, into stem, STEM.
    RETURN 0 if can not read file
    RETURN 1 if can read file and fills stem */
readstem: procedure
    use arg file, stem.
    if pos("ERROR",stream(file,'c',"open read"))>0  then do
       say "Can not open text file '"file"' for reading"
       stem.0 = 0
       return 0
    end /* do */
    i = 0
    do while lines(file)
       i = i + 1
       stem.i = linein(file)
    end /* do */
    stem.0 = i
    call stream file,'c',"close"
    return 1




/* writes a text file, FILE, from stem, STEM.
    RETURN 0 if can not write file
    RETURN 1 if can write file and fills stem */
writestem: procedure
    use arg file, stem.
    if pos("ERROR",stream(file,'c',"open write replace"))>0  then do
       say "Can not open text file '"file"' for writing"
       return 0
    end /* do */
    do i = 1 to stem.0
       call lineout file, stem.i
    end /* do */
    call stream file,'c',"close"
    return 1




/* parse a lines of flags, FLAGS., finds corresponding description in DESCRIPT.
    and then appends to OUTLINE. */
parseflags: procedure
    use arg flags., descript., outline.
    switch = ''
    caseignore = 0
    interpret descript.2
    /* say "switch =" switch  "caseignore =" caseignore */
    tab = d2c(9)
    do k = 1 to flags.0
       fline = translate(flags.k,' ',tab)
       if caseignore  then fline = translate(fline)
       do while fline<>''
          parse var fline flag fline
          ch1 = left(flag,1)
          if pos(ch1,switch)=0 then iterate
          flag = substr(flag,2,length(flag))
          found = flag  "*** unknown flag ***"
          do j = descript.0 to 3 by -1
             option =word(descript.j,1)
             if left(flag,length(option))=option then do
                parse var descript.j . found
                leave
             end /* do */
          end /* do */
          oline  = left(flag,outline.0width) strip(found,'B')
          /* wrap line and indent */
          wrap = outline.0wrap - length(outline.0indent || outline.0comment)
          do until oline=''
             outline.0 = outline.0 + 1
             if length(oline)<=wrap then
                rest = ''
             else do
                j = lastpos(' ',oline, wrap)
                parse var oline oline =(j) rest
             end
             outline.[outline.0] = outline.0indent || outline.0comment oline
             oline = "  " strip(rest,'L')
          end
       end /* do */
    end
    return


