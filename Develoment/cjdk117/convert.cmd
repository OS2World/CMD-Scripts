/**/

  call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  call SysLoadFuncs

  say'A utility to convert ALLNames.html to small separate files.'
  say''
  say'This script is hard coded for the ALLNames.html file as delivered with'
  say'the JDK 117ga release.'
  say''

  if stream('allnames.html','c','query exists') == '' then do
    say"Can't find ALLNames.html to convert!"
    say''
    say'You must run this rexx script from the \java11\docs\api directory!'
    say''
    exit
    end

/* Backup ALLNames.html to ALLNames.html.original */

  'copy ALLNames.html ALLNames.html.original'

/* Set up anchors */

  anchor.1='<a name="Thumb-$"><b> $ </b></a>'
  anchor.2='<a name="Thumb-_"><b> _ </b></a>'

  do index = 3 to 28
    anchor.index = '<a name="Thumb-'||d2c(index+62)||'"><b> '||d2c(index+62)||' </b></a>'
    end /* do index */

/* Read in ALLNames.html */

  if stream('allnames.html','c','query exists') == '' then do
    say"Can't find ALLNames.html to convert!"
    say''
    say'You must run this rexx script from the \java11\docs\api directory!'
    say''
    exit
    end /* if stream */

  say'Reading ALLNames.html into memory...'
  say''

  an.0=0
  index=0

  do while lines('ALLNames.html') > 0
    index=index+1
     an.index=linein('ALLNames.html')
     end /* do while */

  an.0 = index

  rc = stream('allnames.html','c','close')

/* create header */

  say'Creating header...'

  do index = 1 to an.0

    if pos('</h1>', an.index) > 0 then do
      headerstart = 1
      headerend   = index
      leave
      end
  end /* do index */

/* modify header */

  say'Modifying header...'

  do index = headerstart to headerend

    pointer =pos('<a href="#Thumb-', an.index)

    if pointer > 0 then do
      temp1 =  '<a href="'
      temp2 = substr(an.index, 17,1)
      temp3 = right(an.index, length(an.index)-18)
      an.index = temp1||temp2||'.html"'||temp3
      end /* if pointer */

  end /* index */

  say'Processing the ALLNames.html file into smaller files...'
  say''

  start       = 1
  writefile   = 0
  writeheader = 0

  do index = 1 to 28

    do allname = start to an.0

      if pos(anchor.index, an.allname) > 0 then do
        say an.allname
        writefile   = 1
        writeheader = 0
        end /* if pos */

      if writefile = 1 then do

        if writeheader = 0 then do
          do header = headerstart to headerend
            call lineout d2c(index+62)||'.html', an.header
            end /* do header */
            end /* if writeheader */

        writeheader = 1

        if pos('<a name="Thumb-', an.allname) > 0 then do
          letter = substr(an.allname,16,1)
          an.allname='<h2> With names begining with the letter "'||letter||'" </h2>'
          end /* if pos */

        call lineout d2c(index+62)||'.html', an.allname

          if pos('</dl>', an.allname) > 0 then do
            call lineout d2c(index+62)||'.html'
            writefile = 2
            start = allname
            end /* if pos */

      end /* if writefile */

      if writefile = 2 then do
        writefile=0
        call lineout d2c(index+62)||'.html', '</body>'
        call lineout d2c(index+62)||'.html', '</html>'
        call lineout d2c(index+62)||'.html'
        leave /* do allname */
        end /* if writefile */

    end /* allname */

  end /* index */

  say'Writing new ALLNames.html file'
  say''

  'del ALLNames.html'

  do index = headerstart to headerend
    call lineout 'ALLNames.html', an.index
    end /* do index */

  call lineout 'ALLNames.html', '</body>'
  call lineout 'ALLNames.html', '</html>'
  call lineout 'ALLNames.html'

  say''
  say'Finished!'
  say''

exit

