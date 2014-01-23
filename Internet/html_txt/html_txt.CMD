/* 6 May 1999. HTML_TXT ver 1.11

             HTML_TXT.CMD : An HTML to text converter
   Created by Daniel Hellerstein (danielH@econ.ag.gov)

   This program is freeware. It's written in REXX, and has been
   tested under OS/2 4.0,  under the VCPI version of Regina REXX
   for DOS 08e, and under the WIN95 version of Regina REXX 08f.

   Note that several io features are not available when
   run under REGINA REXX (see HTML_TXT.HTM for details).

   It can also be run as an "addon" for the SRE-http web server
   (http://www.srehttp.org/), in which case the HTMLCVT.SHT
   "front end" can be used.

   See HTML_TXT.HTM for installation & usage details -- there are a number of
   options you may want to modify (though the defaults will work
   fine in most cases).

Usage:

   Assuming HTML_TXT.CMD is on your "x" drive; from an
   os/2 command prompt enter:
      x:>HTML_TXT file.htm file.txt
   This will convert the HTML document "file.htm" into an equivalent
   text (ascii), and save the results as file.txt.
    Or, enter HTML_TXT at a command prompt, and answer the queries.

   If you are using REGINA REXX (or some other version of REXX),
   then you'll need to modify the above example; perhaps using:
        x:>rexx HTML_TXT file.htm file.txt

Disclaimer:

   This is freeware that is to be used at your own risk -- the author
   and any potentially affiliated institutions disclaim all responsibilties
   for any consequence arising from the use, misuse, or abuse of
   this software.

   You may use this, or subsets of this program, as you see fit,
   including for commercial  purposes; so long as  proper attribution
   is made, and so long as such use does not preclude others from making
   similar use of this code.
*/


/**************        USER CONFIGURABLE PARAMETERS       **************/
/* Note: there are 3 classes of parameters:
       General controls
       Table controls
       Display characters

The following parameters are of particular importance (that is, they
may cure serious problems).

   NOANSI -- suppress use of ansi screen controls
  LINEART -- suppress use of high ascii characters
 TABLEMAXNEST and TABLEMODE2 -- use lists instead of nested tables
 TOOLONGWORD -- trim overly long strings (that have no spaces)

Note: in the next section, the parameters are listed by "class",
and within each class the parameters are listed in rough alphabetical order.

*/

/*  ----- General controls */

/*CHARWIDTH: width of a character in pixels.
   Used to convert various WIDTH and HEIGHT attributes.  */
charwidth=8

/* DISPLAY_ERRORS: note errors in text file
    0 : Do not note errors
    1 : Note serious errors
    2 : Note all errors and warnings
    3 : Long Note all errors, with
   The "ERROR_FLAG" is used to "note errors" (it is written to the text file
   near where the error was found). For 3, a short error description is also written*/
display_errors=0

/* DOCAPS: Captialization is used for these "logical and physical" elements */
docaps='TT CODE B STRONG '

/* DOULINE: Spaces are replaced with _ (uncerlines) for these "logical and
            physical elements" */
douline='U BLINK'

/* DOQUOTE: "quotes" are used for "logical and physical" elements.
  Note : QUOTESTRING1 and QUOTESTRING2 are used as the "quote" characters */
doquote='I EM VAR '

/*ERRORFLAG: String to place in output file when an error is found in the HTML code */
errorflag='_ERROR_'

/* FORM_BR: if 1, start a new line after end of a form.
             That is, interpret </FORM>  as a <BR> */
form_br=1

/* HN_OUTLINE: use numbered outline
   You can replace Hn elements  with a hierarchical outline.
   HN_OUTLINE says at what level of Hn to start.
      1 : start at H1
      2 : start at H2
      3...7 : etc.
      8   : never do outlining
   Note: see the HN_NUMBERS.n parameters for fine control of hierarchical outlininig*/
hn_outline=2

/* IGNORE_WIDTH: Ignore WIDTH in TABLE and TD elements
      2 : Ignore width, no autosizing (equi-sized cells
      1 : Ignore WIDTH attributes in table (auto-sizing used for column width
      0 : Use WIDTH attribute if available, otherwise use autosizing of table columns  */
ignore_width=0


/* IMGSTRING_MAX: controls display info for IMG elements
   -3 : Do not display (ignore all IMG elements)
   -2 : Just display the pre and post img characters
   -1 : Display a reference number (and generate a SRC and ALT reference list
        at the bottom of the text file)
    0 : Display all characters in an ALT attribute
    1 : Display, at most, current linelength characters from an ALT attribute
   nnn : display, at most, nnn characters from an ALT attrib ute
  Note: for options >-1, the filename is used if no ALT attribute is available*/
imgstring_max=-1

/* LINEART: Suppress use of high ascii (non keyboard) characters.
            This is useful if you have a non-standard display.
    -1 : No high ascii characters allows
     0 : No lineart characters, but other high ascii characters are allowed
     1 : Use high ascii characters   */
lineart=1

/* LINEART_ADDON: LIneart if called as sre-http addon
   Same values as above.
   This is used ONLY when HTML_TXT is called as an sre-http addon */
lineart_addon=-1

/* LINELEN: maximum length of line (in characters).
            Larger values mean wider text files */
linelen=80

/* LINK_DISPLAY: How to display URLS.
   0 = use the  targets (stuff between <a ..>  </a>)
   1 = use the targets, and a [nnn] reference number,
       where [nnn) points to a reference list at end of document
   2 = use the targets and the actual url */
link_display=1

/* NOANSI: Suppress use of ANSI screen controls.
  This only effects screen io, not program functioning. If you see lots of
  $, [ and other garbage on your screen, set NOSANSI=1
     0 : do NOT suppress ANSI screen controls
     1 : suppress ANSI screen controls */
noansi=0

/* NO_WORDWRAP: Each non-table paragraph is one long line
   This will suppress linelen (effectively setting linelen to infinity);
   but only for non-table output.  If you intend to import the text ouptut
   to a wordprocessor, use of NO_WORDWRAP is recommended.
     0 : do NOT suppress linelen
     1 : infinite lines (suppress linelen), but only for non-table output */
no_wordwrap=0

/* NOSPAN: Suppress COLSPAN and ROWSPAN
   0 : Do not suppress
   1 : Suppress COLSPAN and ROWSPAN
  If NOSPAN=1, then COLSPAN and ROWSPAN attributes of <TD> elements are ignored */
nospan=0

/* OPSYS: the operating system you are using.
          Valid values are:Or, if you want to, you can set
               Linux: opsys='LINUX'
               DOS: opsys='DOS'
               Windows 95: opsys='WIN95'
               Windows NT: opsys='NT'
               OS/2: opsys='OS/2'
         Notes:
          * If you are using LINUX, this should be set to LINUX.
          * If you are using OS/2, DOS, WIN95 or WINNT, you can leave
            this blank (HTML_TXT will detect the operating system)  */
opsys=''



/* SHOWALLOPTS: display all OPTIONS in a SELECT list.
   0 : Use the SIZE attrbute of a SELECT list
   1 : Ignore SIZE attribute (always display all OPTIONS) */
showallopts=1

/* SUPPRESS_BLANKLINES: minimize number of blank lines
   1  : If multiple empty lines, just print one empty line (except if PRE)
   0  : allow multiple empty lines  (i.e.; <BR><BR><BR> becomes 3 empty lines)*/
suppress_blanklines=1

/* TOOLONG WORD: trimming long strings.
  What to do with strings that don't fit (say, into a table cell)
    -1 : trim (discard excess)
     0 : wrap
     1 : push margins (does not apply to tables; for tables, 1 means trim) */
toolongword=0

/* VIEWER_PROGRAM: a command-line entry to execute in order to view output
      VIEWER_PROGRAM should be the command-line entry to "START" in order
      to view a program. For example: VIEWER_PRORGRAM='EPM ' means
      'use the EPM program to display the output (text) file".
      To suppress this option, set viewer_program=0
      To let HTML_TXT choose a default viewer, set viewer_program='' 
      Hint: To open a new window with the "viewer", use the "START".
            For example: VIEWER_PROGRAM='START EPM '
*/
viewer_program='START EPM '


/*  ----- Table controls */

/* SUPPRESS_EMPTY_TABLE: display empty rows and empty tables
     0  : do display (as blank lines)
     1  : do not display */
suppress_empty_table=1

/* TABLEMODE: Suppress "tabular" display of tables:
      1 :  use tabular display (possibly lineart)
      2 :  use a UL list instead of tabluar display
      3 :  use a HR like bar, P and BR instead of tabluar display*/
tablemode=1

/* TABLEMODE2: Suppress nested tables
    Values (1, 2, 3) are same as for TABLEMODE.
    Notes:
       * only applies when TABLEMAXNEST is sufficiently small.
       * never used if TABLEMODE>1   */
tablemode2=1

/* TABLEMAXNEST: When to apply TABLEMODE2
   At what "level of nesting" should TABLEMODE2 be used.
      0 : Use for all "nested tables" (tables within tables)
      1 : Use for "tables within tables within tables"
      2, 3, etc. : Larger numbers mean more nested tables are displayed.
  Note: you may need to set this to 0 if you are using Regina REXX */
tablemaxnest=3

/* TABLEBORDER: type of default table borders
    -1  : never display borders (ignore BORDER attribute)
      0 : default is no border -- can be overridden by a BORDER=n attribute in <TABLE>
      1 : default is narrow border -- can be overridden by a BORDER=n attribute in <TABLE>
    1.1 : always use narrow border
  2 and above: Use broad border. */
tableborder=0


/* TD_ADD: Augment cell widths
   Augment cell widths by this factor.  This will increase narrow
   cell widths, and decrease wide cells. Large values (say, 50)
   will tend to make all cells the same size. 0 means "no adjustment".*/
td_add=2

/*  ----- Display Characters */

/* You can specify either the actual character (in single quotes)
   or an ascii value (i.e.; 48 would mean '0').
   For example:
         RADIOBOX='X' and RADIOBOX=88 are equivalent.

   Notes:
      * for high ascii (values > 127), the character displayed may depend
         on the code page your computer uses.
      * if lineart=-1, high ascii values will not be used (if you
        specify a high ascii value, a default character will be used
        instead).
      * if lineart=0, high ascii values can be specified, but not for lineart.
      * in many cases, these characters are used to "quote" strings that
        would be displayed using fonts (say, italics, large bold headers,
        or colored links).
*/

/* CHECKBOX: Character used as to signify an <INPUT TYPE=CHECKBOX .. > element
   CHECKBOXCHECK: Character used as to signify an
                    <INPUT TYPE=CHECKBOX .. CHECKED> element */
checkbox=176
checkboxcheck=178

/* FLAGMENU: bullets used in MENU list.
    You can specify characters and/or ascii numbers. If the "level" of menus exceeds
    the words in flagmenu, the first character is used for these "excess" levels. */
flagmenu='# '

/* FLAGUL : bullets used in UL list.
     As with flagmenu, first character is used in "excess" levels */
flagul='@ ~ $ '

/* FLAGTL : bullets used with UL lists, when UL lists is used instead of a TABLE
     As with flagmenu, first character is used in "excess" levels */
flagtl='176 177 178 220 224'

/* FLAGSELECT: character used before an OPTION (in a SELECT list)
   FLAGSELECT2: character used for a "selected OPTION" (in a SELECT list) */
flagselect='?'
flagselect2='x'

/* HN_NUMBERS.n: characters to use in outlining
   These are used with the "nth level" of an Hn outline.
   Notes:
    *   hn_numbers.1 refers to the "first outline" -- if HN_OUTLINE=2, then these
        are used with H2 (that is, H1 is NOT subject to outline numbering).
    *   if the number of outline numbers exceeds the words in a hn_numbers.n list,
        standard numbers (i.e.; 27, 28, ...) are used  */
hn_numberS.1='I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI XVII XVIII IXX XX XX XXI XXII XXIII XXIV XXV XXVI'
hn_numberS.2='a b c d e f g h i j k l m n o p q r s t u v w x y z '
hn_numbers.3='1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 '
hn_numberS.4='i ii iii iv v vi vii viii ix x xi xii xiii xiv xv xvi xvii xviii ixx xx xx xxi xxii xxiii xxiv xxv xxvi'
hn_numbers.5='1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 '
hn_numbers.6='1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 '
hn_numbers.7='1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 '

/* HRBIG: character to use if SIZE>1 in an <HR ..> element */
hrbig=220

/* OL_NUMBERS: Characters (i.e.; roman numerals, standard digits, letters) in OL lists.
   If number of elements in a list exceeds the number of words in ol_numbers, standard
   numbers are used (i.e.; 11, 12, ...)
   These can be superseded by a TYPE= attribute (i.e. <OL type=a>  */
ol_numbers='1 2 3 4 5 6 7 8 9 10 '


/* PRETITLE: short string to place before the "document title"
   POSTTITLE: short string to place after the "document title" */
PRETITLE='   ***   '
POSTTITLE='   ***   '

/* PREA: character used before <A> anchors
   POSTA: character used after <A> anchors */
PREA=174
POSTA=175

/* PREH1 : character used before <H1>
   POSTH1 : character used after <H1> */
preh1='* '
posth1=' *'

/* PREHN : character used before H2 ... H7
   POSTHN : character used after H2 ... H7 */
prehn=' '
posthn=' '

/* PREIMG: character to place before an  "image placeholder" (the ALT attribute of <IMG ..>
   POSTIMG: character to place after and "image placeholder" */
preimg=' ['
postimg='] '


/* QUOTESTRING1: character used as a "left quote" (with doquote elements)
   QUOTESTRING2: character used as a "right quote" (with doquote elements) 
   Hint: you can use ANSI command character to use color when
         highlighting "quoted" text.  For example:
           quotestring1='1b'x||'[32m'
           quotestring2='1b'x||'[0;m'
         will cause "quoted" text to be displayed in green.
         Note that:
             * a display program that understands ANSI must be used
               (browsers will typically not understand ANSI codes,
               OS/2's TYPE command does understand ANSI codes).
             * for pages with complicated tables, use of a multi-character
               QUOTESTRING may cause problems with column alignment.

*/
quotestring1=244 /* 180 */
quotestring2=245 /* 195 */


/* BOLDSTRING1: character used as a "start BOLD" (with DOCAP elements)
   BOLDSTRING2: character used as a "end BOLD" (with DOCAP elements) 
   To capitalize, set BOLDSTRING1=0
   As with QUOTESTRING, you can use ANSI sequences. For example:
           quotestring1='1b'x||'[1;m'
           quotestring2='1b'x||'[0;m'
   The notes from above also apply -- specifying a non-0 BOLDSTRING1 (and 
   BOLDSTRING2) may cause problems on pages with complicated tables.

*/
boldstring1=0
boldstring2=0

/* RADIOBOX: Character used as to signify an <INPUT TYPE=RADIO .. > element
   RADIOBOXCHECK: Character used as to signify an
                    <INPUT TYPE=RADIO .. CHECKED> element */
radiobox=176
radioboxcheck=178

/* SUBMITMARK1: Character to use before a <INPUT TYPE=SUBMIT or TYPE=RESET ..> element
   SUBMITMARK2: Character to use after a <INPUT TYPE=SUBMIT or TYPE=RESET ..> element */
submitmark1=204
submitmark2=185


/* TEXTMARK1 : character to use on left end of an <INPUT TYPE=TEXT or FILE ..> element
   TEXTMARK2 : character to use on right end of an <INPUT TYPE=TEXT or FILE..> element
   TEXTMARK : character to use inside of  an <INPUT TYPE=TEXT or FILE..> element  */
textmark1=222
textmark2=221
textmark=250

/* TABLEVERT: character to use as vertical lines in a table
   TABLEHORIZ: character to use as horizontal lines in a table
   Neither of these are used if LINEART=1  */
tablevert='!'
tablehoriz='-'

/* TABLEFILLER: character to used to fill empty spaces in tables and textbox's */
tablefiller=' '

/**********            END OF USER CONFIGURABLE PARAMETERS        *********/
/**************************************************************************/


/* Do NOT edit stuff below this line ! */

parse arg  ddir, tempfile, reqstrg,list,verb ,uri,user, ,
          basedir ,workdir,privset,enmadd,transaction,verbose, ,
         servername,host_nickname,homedir,aparam,semqueue,prog_file


crlf='0d0a'x
img_refs.0=0

if verb='' then do              /* called as standalone ? */
   parse arg infile outfile params   /* reread command line options */
   call init_standalone
   addonmode=0
end
else do         /* called as addon */
   call init_sreaddon
   if result=0 then return ' '
   addonmode=1
end /* do */

/* get HEAD and BODY */
atitle=head_body(stuff)

/* write <TITLE> */
atitle=pretitle||atitle||posttitle
atitle=space(atitle)
if length(atitle)<linelen then atitle=center(atitle,linelen)
call lineout2 outfile,atitle
call lineout outfile,' '

/* find all <IMG links and convert to ALT tag, or to filename */
call img_convert 'IMG','SRC'

call img_convert 'AREA','HREF'   /* ,'<A>','</A>' */

/* remove APPLET  etc junk */
foo=remove_applet('APPLET')
foo=remove_applet('OBJECT')
foo=remove_applet('EMBED')

call set_vars           /* check and set display characters */

/* start parsing BODY */

/* ol numbers used with TYPE= option in <OL
  .0  == default (oL_NUMBERS)
  .1  == TYPE=1
  .2  == TYPE=a
  .3  == type=A
  .4  == TYPE=i
  .5  == TYPE=I
*/
ol_numbers.0=ol_numbers
ol_numbers.1='1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 '
ol_numbers.2='a b c d e f g h i j k l m n o p q r s t u v w x y z '
ol_numbers.3='A B C D E F G H I J K L M N O P Q R S T U V W X Y Z '
OL_NUMBERS.4='i ii iii iv v vi vii viii ix x xi xii xiii xiv xv xvi xvii xviii ixx xx xx xxi xxii xxiii xxiv xxv xxvi'
ol_numberS.5='I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI XVII XVIII IXX XX XX XXI XXII XXIII XXIV XXV XXVI'

toterrors=0
foo=value('TOTERRORS',0)

leftside.0=0 ; leftside.!width=0 ; leftside.!done=0
linelen_orig=linelen
ISCLEAR=0
wasblank=0
indent=0                /* current indent */
rightindent=0
ispre=0                 /* <PRE> is on? */
olcnts=''                 /* OL count */
lastelem=''
capon=0
ulineon=0
listtypes=''
links_list.=0
anchoron=0 ; anchoron1=0 ; ANCHORON2=0
quoteon=0 ; quoteon1=0 ; QUOTEON2=0
ddon=0
thispara=''             /* current paragraph */
iscenter=0
sendout_internal=0

if datatype(td_add)<>'NUM' then td_add=0

if hn_outline>0 then do
  do jj=hn_outline to 7
     hn_outlines.jj=0
  end /* do */
end

iat=htmllen-length(body)
if addonmode<>1 then say bold " Converting HTML to Text " normal " ...... "
prenote=reverse||'   : '||normal
if htmllen>15000 then call charout, prenote

eeks=time('r')

doingtable=0    /* used to signal sendout that "we are writing a table */
do forever

    if body='' then leave
    if htmllen>15000 then iat=noteit(htmllen-length(body),iat,10000,prenote)

    parse var body t1 '<' t2a '>' body

    T1=CONVERT_CODES(T1,CAPON,ISPRE,ULINEON)

    t1=fix_quote_anchor(t1)  /* may change globals */


/* Ready to add more content ..... */
     thispara=thispara||t1      /* ADD T1 TO THISPARA FOR EVENTUAL OUTPUT */

/* now prepare to process this <element> (T2 is first word, T2A is all words */
    t2=strip(translate(word(t2a,1)))             /* get rid of element modifiers */
    if left(t2,1)='/'  then
        t2end=substr(t2,2)
    else
        t2end=''

/* a check: convert table to something else (works on globals? */
    t2=cvt_table_elements(t2,1)


/* Now, process this ELEMENT */
   if T2='TABLE' then DO            /* table -- LOTS OF WORK! */
         foo=sendout(thispara,ispre,indent,aflag,linelen)
         doingtable=1
         thispara='';aflag=0
         call sendout ' '
         AA=DO_TABLE(t2a)
         dacaption=''
         if tables.1.!caption<>' ' then do
            dacaption=prehn||tables.1.!caption||posthn
            if tables.1.!captiona<>'BOTTOM' then do
               foo=sendout(dacaption,0,indent,' ',linelen,'CENTER')
            end
         end /* do */
         sendout_internal=1
         tmptoolong=toolongword
         if toolongword=1 then toolongword=-1
         abb=gen_table(1,linelen-(indent+rightindent+leftside.!width))

         sendout_internal=0
         if tables.1.!errors<>'' then
              call do_display_error 0,'Table Warning(s): '||tables.1.!errors,tables.1.!errors

/* write it, or flow around it? */
         talign=get_elem_val(t2a,'ALIGN')
         if talign='LEFT' then do
            ifoo=0 ; lwidth=0; abb2=abb
            do forever
               if abb2='' then leave
               ifoo=ifoo+1
               parse var abb2 leftside.ifoo (crlf) abb2
               lwidth=max(lwidth,length(strip(leftside.ifoo,'t',' ')))
            end /* do */
            leftside.0=ifoo
            leftside.!done=0
            leftside.!width=lwidth+1
            IF LWIDTH+9 > LINELEN  then DO /* TOO WIDE -- CAN'T WRAP */
                 DROP LEFTSIDE.
                 LEFTSIDE.!WIDTH=0; LEFTSIDE.0=0; LEFTSIDE.!DONE=0
                 FOO=SENDOUT(ABB,1)
            end /* do */
         end /* do */
         else do
           foo=sendout(abb,2,indent,' ',linelen)           /* not align left */
           if tables.1.!captiona='BOTTOM'  & dacaption<>'' then do
               foo=sendout(dacaption,0,indent,' ',linelen,'CENTER')
           end /* do */
         end
         toolongword=tmptoolong
         doingtable=0
    end /* do */
   else do              /* NOT a table -- interpret this element (sets globals */
         if leftside.!done>=leftside.0 then leftside.!width=0
         call interpret_elems linelen   /* changes globals */
   end
   IF ISCLEAR<>0 then DO
      do mm=leftside.!done+1 to leftside.0
        call lineout outfile,leftside.mm
      end
      DROP LEFTSIDE.
      LEFTSIDE.!WIDTH=0; LEFTSIDE.0=0; LEFTSIDE.!DONE=0
      ISCLEAR=0
   END
end             /* do foerver -- until no more stuff in BODY  */


/* dump current paragraph */
foo=sendout(thispara,ispre,indent,aflag)

do mm=leftside.!done+1 to leftside.0
   call lineout outfile,leftside.mm
end

/* and we are done!  welll, maybe we need to write a refernce list of urls?*/
if link_display=1 then do
   call lineout outfile,' '
   call lineout outfile,'      =============================== '
   call lineout outfile,'          Reference List of URLs     '
   call lineout outfile,'      =============================== '
   call lineout outfile,' '
   do mmm=1 to links_list.0
        call lineout outfile,'['right(mmm,4)'] '||links_list.mmm
   end /* do */
   call lineout outfile
end /* do */

/* and perhaps a IMG SRC reference list */
if imgstring_max=-1  then do
   call lineout outfile,' '
   call lineout outfile,'      =============================== '
   call lineout outfile,'          Reference List of IMGs     '
   call lineout outfile,'      =============================== '
   call lineout outfile,' '
   do mmm=1 to img_refs.0
        call lineout outfile,'['right('I'mmm,5)'] '||img_refs.mmm
   end /* do */
   call lineout outfile
end /* do */


call lineout outfile
etime=time('r')

if addonmode=1 then do
   return 'FILE ERASE TYPE text/plain name 'outfile
end
else do
  say ' '
  say "Results written to: "outfile
  say "Elapsed time=" etime
  say
  foo=value('TOTERRORS')
  if toterrors>0 then do
       say "Note: " foo " HTML errors were detected."
       if display_errors=3 then
          say " Look for "errorflag" entries in "outfile
       else
         say "  -- for better error messages, try running with DISPLAY_ERRORS=3"
  end /* do */
  if forceout<>1 & viewer_program<>0 then do
       if got_rexxutil=1 then do
          aa=yesno("Would you like to view  "filespec('n',outfile),,)
       end
       else do
          say "Your output file is: "outfile
          aa=yesno("    Would you like to view your output file")
       end
       if aa=1 then do
          if viewer_program<>'' then do
              goo=viewer_program' 'outfile
          end
          else do
             if opsys='LINUX' then do
                goo='less  'outfile
             end /* do */
             else do
                goo='type 'outfile' | more '
             end /* do */
          end
          if OPSYS='OS/2' then
              address cmd goo
          else
               goo
       end /* do */
  end /* do */
end
exit


/*************** END OF MAIN **************/


/****************************************/
/* initialize when run as sre-http addon */
init_sreaddon:

 newp=''
 outfile=tempfile
 newp='LINEART='lineart_addon';'
 do forever
    if list='' then leave
      parse var list a1 '&' list
      if pos('=',a1)=0 then a1='THEURL='a1
      parse var a1 avar '=' aval
      avar=strip(translate(avar))
      aval=packur(translate(aval,' ','+'))

      if length(aval)='' then iterate           /*empty junk, ignore */
      if avar="THEURL" then do           /* the file or url to lookup */
        ico=pos(':',aval)
        if ico>0 & ico<4   then do      /* a file, on this server, must be superuser to request this*/
           if wordpos('SUPERUSER',privset)+wordpos('HTML_TXT',privset)=0 then do
                call ask_auth0
                return 0
           end                  /* otherwise, get the file */

           infile=strip(aval)
           infile0=infile
           if pos('.',infile)=0 then infile=infile||'.htm'
           htmlfile=stream(infile,'c','query exists')              /* does it, or .html or .htm version of it, exist*/
           if htmlfile='' & pos('.',infile0)=0 then htmlfile=stream(infile0,'c','query exists')
           if htmlfile='' then htmlfile=stream(infile0||'.html','c','query exists')

           if htmlfile='' then do
              call no_file infile,' File could not be found '
              return 0
           end
           htmllen=stream(htmlfile,'c','query size')
           if htmllen=0 then do
              call no_file infile,' File is empty '
              return 0
            end
            stuff=charin(htmlfile,1,htmllen)
            if verbose>2 then Say "HTML_TXT: Reading " HTMLlen " characters from " htmlfile
            iterate

       end /* do */
       else do                  /* it is a url */
            'extract serverport '
           foo1=sref_fix_url(aval,servername,serverport)
           hdr='Referer: HTML_TXT@'||servername||crlf||'Connection: close'||crlf
           hdr=hdr||'User-agent: Mozilla/2.0 (compatible)'||crlf
           igoo=pos('//',foo1)
           if igoo=0 then 
              igoo=1
           else
              igoo=igoo+2
           igoo2=pos('/',foo1,igoo)
        
           if igoo2=0 then
              dahost=substr(foo1,igoo)
           else
              dahost=substr(foo1,igoo,1+igoo2-igoo)
           hdr=hdr||crlf||'Host: 'dahost||crlf

           stuff=get_url(foo1,5000000,0,hdr)   /* 5meg max */
           if stuff=0 then do
               call no_url aval,'HTML_TXT: Could not retrieve URL: 'foo1 
               return 0
           end /* do */
           htmllen=length(stuff)
           if verbose>2 then Say "HTML_TXT: Reading " HTMLlen " characters from " aval
           htmlfile=aval
           iterate
       end /* do */

     end /* do */                       /* URL option */
     newp=newp||avar'='aval';'||' '     /* otherwise, retain other options */

 end /* do */
 if newp<>'' then    call change_params '/VAR '||newp,1     /* change parameters (globals) */


return 1


/************************************/
/* no such file */
no_file:
parse arg afile,amess
        call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 3.0//EN">'
        call lineout tempfile, "<html><head><title>HTML_TXT error </title>"
        call lineout tempfile, '</head><body> <h2>File Problem/h2>'
        call lineout tempfile,' Problem with: 'afile'<p><em>'amess'</em>'
        call lineout tempfile,' </body> </html> '
        call lineout tempfile
        'FILE ERASE TYPE text/html NAME' tempfile
        return 1


/************************************/
/* no such file */
no_url:
parse arg afile,amess
        call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 3.0//EN">'
        call lineout tempfile, "<html><head><title>HTML_TXT error </title>"
        call lineout tempfile, '</head><body> <h2>URL Problem</h2>'
        call lineout tempfile,' Problem with: 'afile'<p><em>'amess'</em>'
        call lineout tempfile,' </body> </html> '
        call lineout tempfile
        'FILE ERASE TYPE text/html NAME' tempfile
        return 1


/************************************/
/* not allowed -- ask for username pwd */
ask_auth0:


    is13=value('SREF_PREFIX',,'os2environment') /* which version of sre */
    if is13='' then do
        'RESPONSE HTTP/1.0 401 Unauthorized '     /* Set HTTP response line */
        'header add WWW-Authenticate: Basic Realm=<HTML_TXT>'  /* challenge */
        call lineout tempfile, '<!doctype html public "-//IETF//DTD HTML 3.0//EN">'
        call lineout tempfile, "<html><head><title>Not authorized </title>"
        call lineout tempfile, '</head><body> '
        call lineout tempfile,' </body> </html> '
        call lineout tempfile
        'FILE ERASE TYPE text/html NAME' tempfile
        return 1
     end
     else do
        foo=sref_response('unauth HTML_TXT','You are not allowed to select local files under HTML_TXT',servername,1)
        return foo
     end


/****************************************/
/* initializations; when run as a standalone program */
init_standalone:

do forever
 if queued()=0 then leave
end
parse upper version oof

if opsys=''  then do
  if pos('REXXSAA',oof)>0 then
    '@VER | rxqueue'
  else
    'VER | rxqueue'

  do forever
    if queued()=0 then leave
    pull oot
    if oot<>'' then otype=oot
  end
  select
    when pos('95',otype)>0 then opsys='WIN95'
    when pos('OPERATING SYSTEM/2',otype)>0 then opsys='OS/2'
    when pos('DOS',otype>0) then opsys='DOS'
    when pos('NT',otype)>0 then opsys='NT'
    otherwise opsys=''
  end
end

parse version fooa aa
say "You are using REXX version: "fooa" (under "opsys ')'
call loadlibs           /* load up some libraries and ANSI support */
foo=stream('html_txt.txt','c','query exists')
if foo=''  then foo=stream('read.me','c','query exists')
if foo<>'' & outfile='' & viewer_program<>0 then do
 foo2=yesno("Would you like to view the HTML_txt manual?",,'N')
 if foo2=1 then do
   if viewer_program<>'' then do
            goo=viewer_program' 'foo
    end
    else do
           if opsys='LINUX' then do
              goo='less  'foo
           end /* do */
           else do
              goo='type 'foo' | more '
          end /* do */
    end
    if OPSYS='OS/2' then
              address cmd goo
    else
            goo
 end /* do */
end

say "--------------------------------------------"
if abbrev(translate(infile),'/VAR')=1 then do
    params='/VAR 'outfile' 'params
    outfile='' ; infile=' '
end /* do */

if abbrev(translate(outfile),'/VAR')=1 then do
    outfile=''
    params='/VAR  'params
end /* do */

forceout=0
if outfile<>'' then forceout=1

if params<>'' then do
   call change_params params     /* change parameters (globals) */
end /* do */


getin:
if infile="" then do
    call lineout,bold " Enter name of HTML file (? for help, ?DIR for a directory, EXIT to quit) "normal
    call charout,"  "reverse " :" normal
    parse pull infile ; infile=strip(infile)
end

if strip(translate(infile))='EXIT' then do
   if addonmode<>1 then say "bye "
   exit
end /* do */


if abbrev(translate(infile),'?DIR')=1 then do
    parse var infile . thisdir

    if thisdir="" then do
      if opsys='OS/2'then
        thisdir=strip(directory(),'t','\')||'\*.*'
      if opsys<>'LINUX' then  thisdir='.\*.*'
      if opsys='LINUX' then thisdir='*.*'
    end
    say
    say reverse ' List of files in: ' normal bold thisdir normal
    do while queued()>0
            pull .
    end /* do */
    toget=thisdir

    select
       when  opsys='OS/2' then '@DIR /b  '||toget||' | rxqueue'
       when  opsys='LINUX' then 'ls '||toget||' | rxqueue '
       otherwise 'DIR /b  '||toget||' | rxqueue'
    end
    foo=show_dir_queue('*')
    say
    infile=''
    signal getin
end



if infile=' ' | strip(infile)='?' then do
   call sayhelp
   infile=''
   signal getin
end /* do */

if abbrev(translate(strip(infile)),'/DIR')=1 then do
    infile=substr(strip(infile),2)
    address cmd infile
    infile=''
    signal getin
end /* do */


if abbrev(translate(strip(infile)),'/VAR')=1 then do
  call change_params infile
  infile=''
  signal getin
end

/* maybe it's actually a file name */

infile=strip(infile)
infile0=infile
if pos('.',infile)=0 then infile=infile||'.htm'
htmlfile=stream(infile,'c','query exists')              /* does it, or .html or .htm version of it, exist*/
if htmlfile='' & pos('.',infile0)=0 then htmlfile=stream(infile0,'c','query exists')
if htmlfile='' then htmlfile=stream(infile0||'.html','c','query exists')


if htmlfile='' then do
    Say "Sorry. could not find: " infile
    exit
end /* do */

htmllen=stream(htmlfile,'c','query size')
if htmllen=0 then do
   say " Sorry -- " htmlfile " is empty "
   infile=''
   signal getin
end /* do */
stuff=charin(htmlfile,1,htmllen)
Say "Reading " HTMLlen " characters from " htmlfile

outget: nop
if outfile='' then do
   parse var htmlfile tout '.' .
   tout=tout||'.txt'
   say " "
   say bold " Enter name of output file (ENTER="tout")"normal
   call charout,"  "reverse " :" normal
   parse pull outfile
   if outfile='' then outfile=tout
end /* do */

foo=stream(outfile,'c','query size')
if foo='' then foo=0

signal off syntax ; signal off error
signal on syntax name hoy1 ; signal on error name hoy1
if foo<>0 then do
     if forceout=0 then do
        arf=yesno(normal"     "bold"Overwrite")
        if arf=0 then do
            outfile='' ; signal outget
        end /* do */
     end                /* else, command line mode implies overrwrite */
     else do
          say "     Overwriting "foo
     end /* do */
     if got_rexxutil=1 then do
         foo=sysfiledelete(outfile)
     end
     else do
        say "     .... trying to delete "outfile
        if opsys="LINUX" then
           'rm 'outfile
        else
           'DEL 'outfile
        foo=0
     end
     foo=stream(outfile,'c','query exists')
     if foo<>'' then do
            say "      Could not delete "outfile
            outfile=''
            signal outget
     end /* do */
end /* do */

if forceout=1 then return

/* modify parameters ? */
say
say "In most cases, the default settings of HTML_txt will produce"
say "adequate output. However, you can customize several parameters."

oo=yesno("   Would you like to set a few HTML_TXT parameters",,'N')
if oo=0 then return
say "  "bold"*"normal" select an option by entering it's first letter....."
say "  "bold"*"normal" enter ? for more details "
say " "
yesno.0="NO"
yesno.1="YES"

if cansi=0 then do
  noansi=0
end
else do
/*
 varname='NOANSI'
 noansi=yesno(normal'   'bold"Suppress ANSI screen controls ",,yesno,noansi)
*/
end

yy.0='Neither'
yy.1='High_ascii_only'
yy.2='Both'
lii=lineart+1
varname="LINEART"
lineart=yesno(normal'   'bold'Use lineart and high-ascii characters ',yy.0' 'yy.1' 'yy.2,yy.lii)-1


ss='No'
if imgstring_max>0 then ss='Alt-attribute'
if imgstring_max=-2 then ss='[]'
if imgstring_max=-1 then ss='Reference'
if imgstring_max=-3 then ss='No-display'

varname='IMGSTRING_MAX'
iim=yesno(normal'   'bold'How to display images','Alt-attribute Reference [] No-display',ss)
if iim=0 & imgstring_max <1 then imgstring_max=0
if iim=3 then imgstring_max=-3
if iim=2 then imgstring_max=-2
if iim=1 then imgstring_max=-1

l0=linelen
varname='LINELEN'
linelen=ask_integer('LINEWIDTH','Maximum line width (in columns) ',linelen,5)

if l0<>linelen then do
  varname='CHARWIDTH'
  charwidth=ask_integer('CHARWIDTH','Width of characters (in pixels) ',charwidth,1)
end


varname='NO_WORDWRAP'
no_wordwrap=yesno(normal'   'bold'Treat non-table paragraphs as infinitely long ',,yesno.no_wordwrap)

tt=toolongword+1
ayy.0='Trim'
ayy.1='Wrap'
ayy.2='Push_margins'

varname="TOOLONGWORD"
toolongword=yesno(normal'   'bold'Trim overly long words ','Trim Wrap Push_margins',ayy.tt)
toolongword=toolongword-1

tm.1='Tables'
tm.2='UL_list'
tm.3='Paragraphs'
varname="TABLEMODE"
tablemode=yesno(normal'   'bold'How to display tables ','Tables UL_list Paragraphs',tt.tablemode)+1

derr.0='No'
derr.1 ='Serious_only'
derr.2 ='All'
derr.3 ='Verbose_all'
varname="DISPLAY_ERRORS"
DISPLAY_ERRORS=YESNO(normal'   'bold'Note errors in output file ','No Serious_only All Verbose_all',derr.display_errors)

if tablemode=1 then do
   varname="BORDER"
   tbs=yesno(normal'   'bold'Always put a border around tables ',,'No')
   if tbs=1 then tableborder=1.1

/* TD_ADD: Augment cell widths
   Augment cell widths by this factor.  This will increase narrow
   cell widths, and decrease wide cells. Large values (say, 50)
   will tend to make all cells the same size. 0 means "no adjustment".*/
  varname="TD_ADD"
  td_add=ask_integer('   TD_ADD','<TD> augmentation factor (large values toincrease small cells)',,
                     td_add,0)
end
aa.0='Target_only'
aa.1='Referenced_target'
aa.2='URL&target'
varname="LINK_DISPLAY"
link_display=yesno(normal'   'bold"Link display mode: ",'Target_only Referenced_target URL&target ',aa.link_display)

say
say cy_ye'Advanced Users Note:'normal' HTML_TXT.CMD contains a number of other parameters.'
say
signal off syntax ; signal off error
return 1

hoy1:
outfile=' '
say " % " sigl " : " rc
say "File exists. Try another name"
signal off syntax ; signal off error
signal outget




/******************************/
/* change parameters */
change_params:
parse arg plist,nosay

plist_ok='TOOLONGWORD TABLEMODE TABLEMODE2 TABLEBORDER PRETITLE POSTTITLE ' ,
         ' LINELEN PREA POSTA PREH1 POSTH1 PREHN POSTHN  IMGSTRING_MAX PREIMG POSTIMG ',
         ' DOCAPS DOULINE DOQUOTE BOLDSTRING1 BOLDSTRING2 QUOTESTRING1 QUOTESTRING2 HN_OUTLINE ' ,
         ' HN_NUMBERS.1 HN_NUMBERS.2 HN_NUMBERS.3 HN_NUMBERS.4 HN_NUMBERS.5 HN_NUMBERS.6 ',
         ' HN_NUMBERS.7 OL_NUMBERS FLAGMENU FLAGUL FLAGTL FLAGSELECT FLAGSELECT2 ',
         ' RADIOBOX RADIOBOXCHECK CHECKBOX CHECKBOXCHECK TEXTMARK1 TEXTMARK2 TEXTMARK ',
         ' HRBIG SUBMITMARK1 SUBMITMARK2 LINEART TABLEHORIZ TABLEFILLER SHOWALLOPTS ' ,
         ' ERRORFLAG  NOANSI TABLEMAXNEST CHARWIDTH SUPPRESS_BLANKLINES DISPLAY_ERRORS ' ,
         ' IGNORE_WIDTH NOSPAN TD_ADD NO_WORDWRAP FORM_BR LINK_DISPLAY'

PLIST=STRIP(PLIST) ; PLIST=SUBSTR(PLIST,5)

do forever
   if plist='' then leave
   plist=strip(plist,'l',';')
   PARSE VAR PLIST AVAR '=' AVAL ';' PLIST
   avar=translate(avar)
   if avar='' then iterate
/* file specifieers ... */
   if avar='INFILE' then do
       infile=strip(aval) ; iterate
   end /* do */
   if avar='OUTFILE' then do
       outfile=strip(aval) ;iterate
   end /* do */
   if avar='PFILE' then do                      /* read parameter file */
       psize=stream(strip(aval),'c','query size')
       if psize>0  then do
             gge=charin(strip(aval),1,psize)
             t0=''
             do forever
                if gge='' then leave
                parse var gge b1 '0d0a'x gge
                t0=t0||b1';'
             end /* do */
             plist=t0||plist
             iterate
       end /* do */
   end /* do */

   AVAR=STRIP(TRANSLATE(AVAR))
   if avar='' | avar=';' then iterate

   IF WORDPOS(AVAR,PLIST_OK)=0  & nosay<>1 then DO
       SAY "Parameter Error: no such parameter= "avar
       iterate
   end /* do */
   if datatype(strip(aval))='NUM' then aval=strip(aval)
   oldval=value(avar)
   foo=value(avar,aval)
   if nosay<>1 then  say " Changing "avar" from "reverse||oldval||normal' to 'bold||aval||normal
end /* do */
return 1




/*************/
/* write a box around a string. Use lineart, or ascii characters */
/* box if no ncols, then use width of longest line */
/* if ncols, cut longest line at ncols */
box_around:procedure expose  lineart tablefiller crlf
parse arg ah,ncols
if ncols="" then do     /* no length -- use length of longest line */
   smot=ah ; ncols=0
   do forever
      if smot='' then leave
      parse var smot al1 (crlf) smot
      ncols=max(max,length(al1))
   end /* do */
end /* do */
 ahz='_' ; avt='|'
 ah2='   'copies(ahz,ncols+1)||crlf
 if lineart=1 then do
       ahz=d2c(196) ; avt=d2c(179)
       ah2=' 'd2c(218)||copies(ahz,ncols)||d2c(191)||crlf
 end
 do until ah=''
        parse var ah  aline (crlf) ah
        aline=left(aline,ncols,tablefiller)
        if lineart=1 then
              ah2=ah2' 'avt||aline||avt
        else
              ah2=ah2' 'avt' 'aline' 'avt
        if ah<>'' then ah2=ah2||crlf
  end /* do */
  if lineart=1 then
          ah2=ah2||crlf||' 'd2c(192)||copies(ahz,ncols)||d2c(217)||crlf
  else
         ah2=ah2||crlf'   'copies(ahz,ncols+1)||crlf

  return ah2


/*******************/
/* a "list flag" needed? */
figflag:procedure expose olcnts flagul flagmenu listtypes flagtl oltypes.
parse arg thisval

 if listtypes='' then return ''
 IW=WORDS(LISTTYPES)
  LASTT=WORD(LISTTYPES,IW)

select
  when lastt='UL' then aflag=nth_word(flagul,iw)
  when lastt='TL' then aflag=nth_word(flagtl,iw)
  when lastt='MENU' | lastt='DIR' then aflag=nth_word(flagmenu,iw)
  when lastt='OL' then do
     iw2=words(olcnts)
     io2=strip(word(olcnts,iw2))
     io2=io2+1
     if datatype(thisval)='NUM' then io2=thisval  /* VALUE attribute in LI ? */
     olhere=oltypes.iw2
     if io2>words(olhere) then
        aflag=io2+1
     else
        aflag=strip(word(olhere,io2))
     aflag=aflag'.'
     if iw2<1 then
         call do_display_error 1, "Warning: Problem with OL UL or SELECT ","UNEXPECTED_DELWORD"
     else
         olcnts=delword(olcnts,iw2)' 'io2
  end /* do */
  otherwise nop
end  /* select */

return aflag



/***********************************/
img_convert:
parse upper arg aimg,hrefsrc,p1,p2
if addonmode<>1 then say bold ' Converting <'aIMG'> elements ... ' normal
stuff2=''
iat=1
tbody=translate(body)
do forever
  iat2=pos('<'||aIMG,tbody,iat)
  if iat2=0 then leave          /* all done */

/* found an IMG element. Extract it, modify body */
   iat3=pos('>',body,iat2)
    imgis=substr(body,iat2+4,iat3-(iat2+4))
    imgname=get_elem_val(imgis,'ALT')
    if imgname='' then do
        imgname=get_elem_val(imgis,hrefsrc)
        rimg=reverse(imgname)
        if pos('.',rimg)>0 then parse var rimg . '.' rimg
        rimg=strip(rimg,'l','/')
        parse var rimg imgname '/' .
        imgname=reverse(imgname)
        if imgname='' then imgname='IMG'
    end /* do */
    srcname=''
    if aimg='IMG' then
       srcname=get_elem_val(imgis,'SRC')

   IF IMGSTRING_MAX<LENGTH(IMGNAME) & IMGSTRING_MAX>1 then
        IMGNAME=LEFT(IMGNAME,IMGSTRINg_MAX)

    abody=left(body,iat2-1)||p1||'<IMG 'srcname' 'imgname'>'||p2
    iat=length(abody)
    body=abody||substr(body,iat3+1)
    tbody=abody||substr(tbody,iat3+1)
end

return 1




/****************/
/* set global vars */
set_vars:

aflag=0

tablefiller=do_d2c(tablefiller,' ')
tablevert=do_d2c(tablevert,'|')
tablehoriz=do_d2c(tablehoriz,'_')

hrbig=do_d2c(hrbig,'=')

quotestring1=do_d2c(quotestring1,'`')
quotestring2=do_d2c(quotestring2,"`")

if boldstring1<>0 then do
  BOLDString1=do_d2c(BOLDstring1,'`')
  BOLDstring2=do_d2c(BOLDstring2,"`")
end


radiobox=do_d2c(radiobox,'o')
checkbox=do_d2c(checkbox,'O')
radioboxcheck=do_d2c(radioboxcheck,'x')
checkboxcheck=do_d2c(checkboxcheck,'x')

flagselect=do_d2c(flagselect,'?')
flagselect2=do_d2c(flagselect2,'x')

submitmark1=do_d2c(submitmark1,'{')
submitmark2=do_d2c(submitmark2,'}')

textmark1=do_d2c(textmark1,'[')
textmark2=do_d2c(textmark2,']')
textmark=do_d2c(textmark,'.')


prea=do_d2c(prea,'<')
posta=do_d2c(posta,'>')
preh1=do_d2c(preh1,':')
posth1=do_d2c(posth1,':')
prehn=do_d2c(prehn,':')
posthn=do_d2c(posthn,':')

preimg=do_d2c(preimg,'[')
postimg=do_d2c(postimg,'[')

flagul=do_d2c(flagul,'*',1)
flagmenu=do_d2c(flagmenu,'@',1)
flagtl=do_d2c(flagtl,'=',1)

return 1



/***********************************/
/* get string ending with /TOFIND */
getelem:
parse upper arg tofind
tofind=strip(tofind)
foo=pos('<'||tofind,translate(body))
if foo=0 then do
    call do_display_error 1, "Missing end element " tofind '(remaining: ' length(body)
    return ''
end /* do */
p1=left(body,foo-1)
body=substr(body,foo+1)
parse var body . '>' body
return p1


/********/
/* remove < > from a string */
remove_htmls:
parse arg ast
ast0=''
do forever
  if ast='' then leave
  parse var ast v1 '<' v2 '>' ast
  v1a=''
  if abbrev(v2,'IMG')=1 then do
      parse var v2  . v1a '>'
      call do_imagename v1a
      v1a=result
  end
  ast0=ast0||v1||v1a
end /* do */
return ast0



/***********************************/
/* dump something to output file */
sendout:procedure expose linelen outfile rightindent iscenter toolongword ,
                 prea posta crlf no_wordwrap doingtable,
                 sendout_internal sendout_var suppress_blanklines wasblank ,
                 leftside. preimg postimg tablehoriz

parse arg toput,ispre,indent,aflag,XLINELEN,altype

if wordpos(strip(altype),'RIGHT CENTER')=0 then altype='LEFT' /* only supplied within tables */

if datatype(indent)<>'NUM' then indent=0


IF XLINELEN="" THEN XLINELEN=LINELEN
xlinelen_wrap=xlinelen
if  doingtable=0 & no_wordwrap=1 then xlinelen=10000000
dolft=1-sendout_internal

if (ispre='' | ispre=0)& toput=''  then do
  if suppress_blanklines=1 & wasblank=1 then do
      return 1           /* ignore this "extra crlf */
  end
  if  dolft=1 then toput=add_leftside(toput)
  if sendout_internal<>1 then do
      call lineout2 outfile,toput
  end
  else do
      sendout_var=sendout_var||toput||crlf
  end
  wasblank=1            /* signal "we just did a crlf (ignored if suppress_blanklines<>1 */
  return 1
end

wasblank=0              /* not a crlf, or a <PRE> crlf */


/* PRE-- send as is (with possible margin clipping */
if  ispre=1 then do
  if toolongword<1 then do
    toput0=''
    do forever
      if toput='' then leave
      parse var toput aline (crlf) toput
      if altype='CENTER' | iscenter=1 then do      /* center it*/
         isleft=min(xlinelen_wrap,Xlinelen)
         aline=center(aline,isleft)
      end
      if altype='RIGHT' | iscenter=2 then do      /* right it*/
         isleft=min(xlinelen_wrap,Xlinelen)
         aline=right(aline,isleft,' ')
      end

      aline=fix_linelen(aline,Xlinelen,toolongword,dolft,altype)
      toput0=toput0||aline
      if toput<>'' then do
         toput0=toput0||crlf
       end
    end
    toput=toput0
  end
  else do
     if dolft=1 then toput=add_leftside(toput)             /* uses leftside. global */
  end

  if sendout_internal<>1 then do
      call lineout2 outfile,toput
  end
  else do
      sendout_var=sendout_var||toput||crlf
  end
  return 1
end

/* pre, with indent */
if ispre=2 | ispre=22 then do
  toput0=''
  do forever
      if toput='' then leave
      parse var toput aline (crlf) toput

      if ispre=2 then
         aline=fix_linelen(copies(' ',indent)||aline,Xlinelen,toolongword,dolft)  /* might use leftside. */
      else
         aline=fix_linelen(copies(' ',indent)||aline,Xlinelen,0,dolft)  /* might use leftside. */

      toput0=toput0||aline
      if toput<>'' then toput0=toput0||crlf
  end

  toput=toput0
  if sendout_internal<>1 then do
      call lineout2 outfile,toput
  end
  else do
      sendout_var=sendout_var||toput||crlf
  end
  return 1
end

if aflag=0 & toput='' then return 1


if indent='' then indent=0
if indent<0 | indent>(Xlinelen-1) then indent=0
anindent=''
if indent>0 then anindent=copies(' ',indent)
anindent1=anindent

if aflag<>0 then do
  if indent>=(length(aflag)) then do
       indent=indent-length(aflag)
       anindent1=copies(' ',indent)||aflag||' '
       anindent=anindent' '
   end
end /* do */


linelenl=Xlinelen-(rightindent)    /* shorten linelen if blockquote is on */

/* remove extra spaces and crlfs */
toput=translate(toput,' ','0d0a0009'x)
toput=space(toput,1)
toput=translate(toput,' ','01'x)  /* hack used for &Nbsp */


if (length(toput)+indent + (dolft*leftside.!width) ) <linelenl then do  /* short string -- write it */
     if altype='CENTER' | iscenter=1 then do      /* center it*/
         isleft=min(xlinelen_wrap,Xlinelen)-length(anindent1)
         toput=center(toput,isleft)
     end
     if altype='RIGHT' | iscenter=2 then do      /* right it*/
         isleft=min(xlinelen_wrap,Xlinelen)-length(anindent1)
         toput=right(toput,isleft,' ')
     end

     if dolft=1 then toput=add_leftside(toput)             /* uses leftside. global */

     if sendout_internal<>1 then
       call lineout2 outfile,anindent1||toput
     else
        sendout_var=sendout_var||anindent1||toput||crlf

     return 1
end /* do */




/* else, parse into linelen chunks and write out */
aline=anindent1
do forever
   SUP1=0
   if toput='' then leave
   parse var toput aword toput
   IUU=POS('_',AWORD)
   IF IUU>0 & IUU<>LENGTH(AWORD) then DO  /* ALLOW _ TO BE WORD BREAKERS */
      AW1=LEFT(AWORD,IUU)
      AW2=SUBSTR(AWORD,IUU+1)
      AWORD=AW1
      TOPUT=AW2' 'TOPUT
      SUP1=1
   end /* do */

   lenword=length(aword)

   if lenword>(linelenl-(dolft*leftside.!width)) then do /* BIG word */
       if aline<>'' then do
         if altype='CENTER' | iscenter=1 then
            aline=center(aline,min(xlinelen_wrap,Xlinelen)-(dolft*leftside.!width))
         if altype='RIGHT'| iscenter=2 then
                 aline=right(aline,min(xlinelen_wrap,Xlinelen)-(dolft*leftside.!width))

         if dolft=1 then aline=add_leftside(aline)             /* uses leftside. global */

         if sendout_internal<>1 then
             call lineout2 outfile,aline
         else
             sendout_var=sendout_var||aline||crlf
       end

       aword=fix_linelen(aword,Xlinelen,toolongword,dolft)
       if sendout_internal<>1 then
              call lineout2 outfile,aword
        else
             sendout_var=sendout_var||aword||crlf
       aline=anindent

       iterate
   end /* do */

   if (length(aline)+lenword)>linelenl then do /* line + word too long */
       if altype='CENTER' | iscenter=1 then  aline=center(aline,min(xlinelen_wrap,Xlinelen)-(dolft*leftside.!width))
       if altype='RIGHT' | iscenter=2 then aline=right(aline,min(xlinelen_wrap,Xlinelen)-(dolft*leftside.!width))

       if dolft=1 then aline=add_leftside(aline)             /* uses leftside. global */
       if sendout_internal<>1 then
          call lineout2 outfile,aline
       else
           sendout_var=sendout_var||aline||crlf
       aline=anindent
   end /* do */

   IF SUP1=1 then
      aline=aline||aword      /* append this word to current line */
   ELSE
      aline=aline||aword||' '      /* append this word to current line */

end /* do */

if aline<>''  then  do
  if altype='CENTER' | iscenter=1 then  aline=center(aline,min(xlinelen_wrap,Xlinelen)-(dolft*leftside.!width))
  if altype='RIGHT' | iscenter=2 then aline=right(aline,min(xlinelen_wrap,Xlinelen)-(dolft*leftside.!width))

  aline=fix_linelen(aline,Xlinelen,toolongword,dolft)
  if sendout_internal<>1 then
     call lineout2 outfile,aline
  else
     sendout_var=sendout_var||aline||crlf
end
return 1


/*************************************/
/* remove <APPLET> ... </APPLET>  */
remove_applet:procedure expose body
parse upper arg badelem
do forever  /* exit with RETURN */
   tbody=translate(body)                /* not real efficient, but easy */
   app1=pos('<'badelem,tbody,1)
   if app1=0 then return 0
   app2=pos('</'||badelem,tbody,app1+3)
   if app2=0 then do
        say ' '
        say " Warning: no /"badelem ' element '
        return 0
   end /* do */
   body2=substr(body,app2+3)
   body=left(body,app1-1)
   parse var body2 . '>' body2
   body=body||body2
end


/*************************************/
/* REMOVE HTML COMMENTS, fix up <  x  elements, parse into HEAD and BODY sections (globals ) */
head_body:PROCEDURE expose head body normal reverse bold prenote addonmode
PARSE ARG STUFF

/* remove html comments */
if addonmode<>1 then say bold " Removing comments ... " normal
body="" ;iat=0
prenote=reverse||'   : '||normal
do forever              /*no comments within comments are allowed */
   if stuff="" then leave
   parse var stuff t1 '<!--' t2 '-->' stuff
   body=body||t1
end /* do */

/* convert < x to <x, where space can be space, tab, crlf */
if addonmode<>1 then say bold " Cleaning up elements " normal
stuff=body
body='' ;iat=0
hhlen=lengtH(stuff)
iat=0
do forever
  if stuff="" then leave
  parse var stuff t1 '<' t2 '>' stuff
  body=body||t1
  if abbrev(strip(t2),'<')=1 then do  /* get rid of < < */
     t2=substr(strip(t2,'l'),2)
     say " Warning: removing repeated < "
  end /* do */
  if t2<>''  then do
    t2=translate(t2,' ','0d0a0900'x)
    t2=strip(t2)
    if t2<>'' then body=body||'<'||t2||'>'
  end
  if hhlen>15000 then iat=noteit(length(body),iat,10000,prenote)
end /* do */

if addonmode<>1 then say bold " Extracting <HEAD> and <BODY> " normal
/* pull out <HEAD> and <BODY> sections */
stuff=body ;iat=0
body='' ; head='' ; iat=0
headon=0; bodyon=0 ; headon2=0; bodyon2=0

tstuff=translate(stuff)
hd1=pos('<HEAD',tstuff,1)
hd2=pos('</HEAD',tstuff,max(hd1,1))

if hd1=0 & addonmode<>1 then say "Warning: no <HEAD> element "
if hd2=0 & addonmode<>1 then say "Warning: no </HEAD> element "

if hd2>0 then do
   hdlen=hd2-(hd1+5)  /*  <HEAD starts at 10, then read from 10+5 */
   head=substr(stuff,hd1,hdlen)
   parse var head . '>' head   /* get rid of remnand  > */
end /* do */

hd2=hd2+6  /* get by /HEAD */

bd1=pos('<BODY',tstuff,hd2)
bd2=pos('</BODY',tstuff,max(bd1+5,hd2))

if bd1=0 & addonmode<>1 then say "Warning: No <BODY> element "
if bd2=0 & addonmode<>1 then say "Warning: No <HEAD> element "

isrem=length(tstuff)-bd2
if isrem>100 then say "Warning: "isrem " characters after </body> "

if bd1=0 then bd1=max(bd1+5,hd2)
if bd2=0 then bd2=length(tstuff)+1
bdlen=bd2-bd1
body=substr(stuff,bd1,bdlen)


/* extract TITLE  from HEAD */
do forever
   if head="" then leave
   parse var head t1 '<' t2 '>' head
   t2a=strip(translate(word(t2,1)))
   if t2a="TITLE" then do
      parse var head title '<' .
      return title
   end /* do */
end /* do */

return ' '




/***************/
/* return 0 for no, 1 for yes, default otherwise */
is_yes_no:procedure
parse arg aval,def
tdef=strip(translate(aval))
if wordpos(tdef,'Y YES 1')>0 then return 1
if wordpos(tdef,'N NO 0')>0 then return 0
return def


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




/*********************************/
/* PROCESS A TABLE */
DO_TABLE:PROCEDURE EXPOSE BODY TABLES. ignore_width tablemode2 tablemaxnest  charwidth linelen_orig nospan ,
                        addonmode
parse arg table1
drop tables.

tableinner=0
tables.0=1
tables.1.!rows=0
tables.1.1.!cols=0
tables.1.1.!totcols=0
tables.1.!errors=''
tables.1.!caption=' '
tables.1.!captiona=' '
parse var table1 .  aspec
tables.1.!spec=aspec
tables.1.!align=get_elem_val(aspec,'ALIGN')
tables.1.!border=get_elem_val(aspec,'BORDER')


curtables=1

DO FOREVER
   if body='' then leave
   parse var body v1 '<' v2a '>' body
   v2=strip(translate(word(v2a,1)))

  tfoo=wordpos(v2,'TABLE TR TD TH /TABLE')

  if v2='TABLE' then do
      tableinner=tableinner+1
  end /* do */

  if tablemaxnest<tableinner  & tfoo>0 then do     /* inner tables not allowed, then..*/
      select
          when tablemode2=2 then do
             v2=strip(word('TL LI LI LI /TL',tfoo)) ;v2a=v2
          end
          when tablemode2=3 then do
             v2=strip(word('HR1 P BR BR HR2 ',tfoo)); v2a=v2
          end
          otherwise nop           /* make a table using ascii and/or lineart */
      end               /* select */
   end
   if tfoo=5 then tableinner=max(0,tableinner-1)


   if tfoo>0 then do    /*dump prior stuff, or perhaps convert */
           curtable=strip(word(curtables,1))
           currow=tables.curtable.!rows
           curcol=tables.curtable.currow.!cols
           if curcol>0 then do          /* add stuff */
              tables.curtable.currow.curcol.!stuff=tables.curtable.currow.curcol.!stuff||v1
           end
           else do
             if translate(v1,' ','0d0a0009'x)<>' '  & addonmode<>1 then
                    say v1 ":ERROR:: Material outside of column at table " curtable " row " currow
           end /* do */
   end

/* TR: new row,  TD or TH: new colum, TABLE: new table definition */
   select
      when v2='TR' then do
        curtable=strip(word(curtables,1))
        currow=tables.curtable.!rows+1
        tables.curtable.!rows=currow
        parse var v2a . tables.curtable.currow.!spec
        tables.curtable.currow.!cols=0
        tables.curtable.currow.!totcols=0

      end /* do */

      when v2='TD' | v2='TH' then do
        curtable=strip(word(curtables,1))
        currow=tables.curtable.!rows
        curcol=tables.curtable.currow.!cols

        if currow=0 then do
                tables.curtable.!rows=1
                tables.curtable.1.!spec=''
                tables.curtable.!errors=tables.curtable.!errors';MISSING_LEADING_TR '
                currow=1
                curcol=0
        end /* do */

        tdcols=get_elem_val(v2a,'COLSPAN')
        if datatype(tdcols)<>'NUM' | nospan=1 then tdcols=1
        if tdcols<=0  then tdcols=1

        tdrows=get_elem_val(v2a,'ROWSPAN')
        if datatype(tdrows)<>'NUM' | nospan=1 then tdrows=1
        if tdrows<=0 then tdrows=1

        curcol=curcol+1

/* A ROWSPAN KICKED IN? */
        DO FOREVER
          oaa=SYMBOL('TABLES.'CURTABLE'.'CURROW'.'CURCOL'.!ROWSPAN')
          if oaa='VAR' then do
             tables.curtable.currow.!totcols=tables.curtable.currow.!totcols+ ,
                                             tables.curtable.currow.curcol.!colspan
             CURCOL=CURCOL+1       /* if here, prior row's rowspan created this var */
          end
          else do
             leave
          end
        END

        tables.curtable.currow.!cols=curcol   /* !cols is actualys "TDs" */

/* wastot = actual # of columns (includes colspans */
        wastot=tables.curtable.currow.!totcols
        tables.curtable.currow.!totcols=wastot+tdcols

/* specs etc for this cell */
        parse var v2a . tables.curtable.currow.curcol.!spec
        tables.curtable.currow.curcol.!TH=v2
        tables.curtable.currow.curcol.!stuff=''
        tables.curtable.currow.curcol.!colspan=tdcols
        tables.curtable.currow.curcol.!rowspan=tdrows
        tables.curtable.currow.curcol.!nobot=0
        if tdrows>1 then tables.curtable.currow.curcol.!nobot=1

/* if rowspan>1, then create cells in next trs */
        DO CUR2=CURROW+1 TO (CURROW+TDROWS-1)

           tables.curtable.cur2.curcol.!th=v2
           tables.curtable.cur2.curcol.!colspan=tdcols
           tables.curtable.cur2.curcol.!spec=''
           if cur2<>(currow+tdrows-1) then do
              tables.curtable.cur2.curcol.!nobot=1
              TABLES.CURTABLE.CUR2.curcol.!ROWSPAN=-1
           end
           else do
                tables.curtable.cur2.curcol.!nobot=0
                TABLES.CURTABLE.CUR2.curcol.!ROWSPAN=1
           end
           TABLES.CURTABLE.CUR2.curcol.!STUFF='  '
        end /* do */
      end /* do */


      when v2='CAPTION' then do         /* table caption */
         curtable=strip(word(curtables,1))
         foo1=pos('</TABLE',translate(body))
         foo2=pos('</CAPTION',translate(body))
         if foo2=0 | foo1<foo2 then do
              say v1 ":ERROR:: Unclosed CAPTION at table " curtable
              tables.curtable.!errors=tables.curtable.!errors';UNCLOSED_CAPTION '
         end
         acaption=left(body,foo2-2)
         body=substr(body,foo2)
         parse var body . '>' body
         tables.curtable.!captiona=get_elem_val(v2a,'ALIGN')
         tables.curtable.!caption=acaption
      end /* do */

      when v2='TABLE' then do           /* a sub table */

        kurtable=strip(word(curtables,1))
        kurrow=tables.kurtable.!rows
        kurcol=tables.kurtable.kurrow.!cols
        curtable=tables.0+1

        if kurcol>0 then do          /* add stuff */
            moose= tables.kurtable.kurrow.kurcol.!stuff
            tables.kurtable.kurrow.kurcol.!stuff=moose||' <_TABLE_ 'curtable '>'
        end
        else do
           if translate(v1,' ','0d0a0009'x)<>' ' then do
                if addonmode<>1 then
                   say v1 ":ERROR:: NEW table of column at table " kurtable " row " kurrow
                tables.kurtable.!errors=tables.kurtable.!errors';PREMATURE_NEW_COLUMN '
           end
        end /* do */

        TABLES.0=CURTABLE
        curtables=curtable' 'curtables
        tables.curtable.!rows=0
        tables.curtable.1.!cols=0
        tables.curtable.1.!totcols=0
        tables.curtable.!errors=''
        tables.curtable.!caption=' '
        tables.curtable.!captiona=' '
        PARSE VAR V2A . aspec

        TABLES.CURTABLE.!SPEC=aspec
        tables.curtable.!border=get_elem_val(aspec,'BORDER')
        tables.curtable.!align=get_elem_val(aspec,'ALIGN')


      end /* do */

      when v2='/TABLE' then do                  /* end of table, pop an index from curtables */
           if words(curtables)=1 then leave
           parse var curtables . curtables
      end

      otherwise do              /* add to !stuff of current cell */
        curtable=strip(word(curtables,1))

         v2a2='<'v2a'>'

         currow=tables.curtable.!rows ; curcol=tables.curtable.currow.!cols
         if currow=0 | curcol=0 then do
                if addonmode<>1 then
                   say " ERROR: row or column not specified ("currow curcol")"
                iterate
         end
         tables.curtable.currow.curcol.!stuff=tables.curtable.currow.curcol.!stuff||v1||v2a2
     end
  end                   /*select */
end


return 1



/************/
/* determine tablewidth in character s*/
get_tablewidth:procedure expose charwidth linelen_orig ignore_width
parse arg specs,linelen

tablewidth=strip(get_elem_val(specs,'WIDTH'))

if tablewidth='' | ignore_width<>0 then  do
  tablewidth=linelen
end
else do
   if right(tablewidth,1)='%' then do           /* pct of line lenght */
         tablewidth=strip(tablewidth,,'%')
         if datatype(tablewidth)<>'NUM' then do
            tablewidth=linelen
         end
         else do
            tablewidth=(tablewidth/100)*linelen_orig
            tablewidth=trunc(min(tablewidth,linelen))
         end
   end /* do */
   else do              /* convert pixels to charactes */
         if datatype(tablewidth)='NUM' then do
            tablewidth=trunc(min(tablewidth/charwidth,linelen))
         end /* do */
         else do
            tablewidth=linelen
         end
   end /* do */
   tablewidth=max(2,tablewidth)   /* can't bee too small */
end /* do */
return tablewidth

/****************/
/* determine max width of cell (check for WIDTH element */
get_tdwidth:procedure expose charwidth
parse arg aspec,linelen,ign,stuff2,colspan

tdwidth=''
if ign=0 then tdwidth=strip(get_elem_val(aspec,'WIDTH'))

if tdwidth='' | ign>0 | colspan>1 then  do
  if ign=2 | colspan>1  then return '0 0 0'
  eff=qcell_width(stuff2,linelen)                /* rough guess as to max and min linelength */
  return 0' 'eff      /* 0 means "no default length found */
end

/* convert % to characters */
if right(tdwidth,1)='%' then do
         tdwidth=strip(tdwidth,,'%')
         if datatype(tdwidth)<>'NUM' then  return 0  /* error- ignore width */
         tdwidth=trunc(min(linelen*tdwidth/100,linelen))
end /* do */
else do              /* convert pixels to charactes */
      if datatype(tdwidth)<>'NUM' then  return 0  /* error- ignore width */
      tdwidth=min(trunc(tdwidth/charwidth,linelen))
end /* do */
return trunc(max(tdwidth,1))



/*************************/
/* quick guess at length of line in a cell (after html mappings */
qcell_width:procedure
parse arg stuff,deflen
ithl=0
aline=''
do forever

  if stuff='' then do
        ithl=ithl+1 ; tlines.ithl=aline
        leave
  end /* do */

  parse upper var stuff t1 '<' t2 '>' stuff

  if pos('&',t1)>0 then do
    t1a=''
    do forever
       if t1='' then leave
       parse var t1  p1 '&' p2 ';' t1
       if p2<>"" then
          t1a=t1a||p1'x'
       else
          t1a=t1a||p1
    end
    t1=t1a
  end /* do */

  t1=space(translate(t1,' ','000d0a0d'x))
  aline=aline||t1

  parse var t2 t2a t2b ; t2a=strip(t2a); t2a=strip(t2a,,'/')


  if wordpos(t2a,'HR HR2 HR1 P BR H1 H2 H3 H4 H5 H6 H7 PRE ')>0 then do
        ithl=ithl+1 ; tlines.ithl=alineadd||aline
        aline='' ; iterate ; alineadd=''
  end

  if t2a='_TABLE_' then do
        ithl=ithl+1 ; tlines.ithl=copies('x',deflen); aline='' ;alineadd=''
        iterate
  end /* do */

  if wordpos(t2a,'BLOCKQUOTE TL SELECT UL DL OL MENU DIR ')>0 then do
        ithl=ithl+1 ; tlines.ithl=alineadd||aline
        alineadd='         ' ; iterate                /* no nested indenting, might fix later */
   end


  IF T2A='IMG' then DO
       PARSE VAR T2  . FOO
       foo=space(translate(foo,' ','000d0a0d'x))
       ALINE=ALINE||'x'FOO ; ITERATE
  END

   if t2a='INPUT' then do
          atype=TRANSLATE(get_elem_val(t2,'TYPE'))
          IF ATYPE='' then ATYPE='TEXT'

          avalue=get_elem_val(t2,'VALUE',1)
          if atype='RADIO' | atype='CHECKBOX' then do
            aline=aline' '
          end
          if atype='FILE' then do
               av2=get_elem_val(t2,'SIZE')
               if av2='' then av2=get_elem_val(t2a,'SIZE')
               if av2='' then av2=12
               aline=aline'xx'||copies('_',av2)
          end
          if atype='TEXT' then do
               av2=get_elem_val(t2,'SIZE')
               if av2='' then av2=get_elem_val(t2a,'SIZE')
               if av2='' then av2=4
               aline=aline'xx'||copies('_',av2)
          end
          if atype='SUBMIT' | atype='RESET' then do
                if avalue='' then avalue='     '
                aline=aline'  '||avalue
          end /* do */
         iterate
   end

/* paragraph modifiers */
   if wordpos(t2a,'A OPTION '||doquote)>1 then do
        aline=aline' '                  /* add space for quote characters */
   end /* do */

end

mxlen=2
mnlen=2
do iii=1 to ithl
    mxlen=max(mxlen,length(tlines.iii))
    do ithlw=1 to words(tlines.iii)
        sww=strip(word(tlines.iii,ithlw))
        if left(sww,1)='&' then sww='x'
        mnlen=max(mnlen,length(sww))
    end
end

drop tlines.

return mxlen' 'mnlen

/******************************/
/* various utility procedures */

/***********************************/
/* load libraries, set ansi, set defaults */
loadlibs:
foo2=1
foo=rxfuncquery('sysloadfuncs')
if foo=1 then do
  foo2=RxFuncAdd('SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs')
  if foo2=0 then call SysLoadFuncs
  foo=rxfuncquery('sysloadfuncs')
end
if foo=0 then  do
   got_rexxutil=1
end
else do
  say "Note: RexxUtil is NOT installed, so some options will not be available."
  got_rexxutil=0
end

cy_ye=' '; normal=''; bold='';re_wh='';reverse='';aesc=''

cansi=0
if opsys='OS/2' then  cansi=checkansi()

if  (noansi<>1 & cansi=1) then do
  aesc='1B'x
  cy_ye=aesc||'[37;46;m'
  normal=aesc||'[0;m'
  bold=aesc||'[1;m'
  re_wh=aesc||'[31;47;m'
  reverse=aesc||'[7;m'
end
else do
  say "Warning: ANSI not available, output will be simpler."
end
return 1


/********************/
/* get, possibly quoted, value of a field in an html type <element > */
get_elem_val:procedure
parse arg haystack,needle,lc
haystack=translate(haystack,' ','000d0a09'x)

thay=' 'translate(haystack)
needle=' '||translate(needle)||'='
foo=pos(needle,thay)
if foo=0 then return ''
haystack=strip(substr(haystack,foo+length(needle)-1))

if abbrev(haystack,'"')=1 then
  parse var haystack '"' aval '"' .
else
  parse var haystack aval .

if lc<>1 then aval=translate(aval)
return aval


/***************/
/* convert to ascii, but only if >1 character that is
 a numeric value. */
do_d2c:procedure expose lineart
parse arg a1,defval,islist

if islist=1 then do
  alist2=''
  do forever
     if a1='' then leave
     parse var a1 a1a a1 ; a1a=strip(a1a)
     if length(a1a)>1 & datatype(a1a)='NUM' then do
       if lineart>-1 then
         a1a=d2c(a1a)
       else
         a1a=defval
     end
     alist2=alist2||a1a' '
  end /* do */
  return alist2
end /* do */
else do
  if length(a1)>1 & datatype(a1)='NUM' then  do
    if lineart>-1 then
       a1=d2c(a1)
    else
       a1=defval
  end
  return a1
end

/* -------------------- */
/* choose between 3 alternatives (by default,a yes or no ),
return 1 if yes (or 0,1,2 for chosen altenative ) */

yesno:procedure expose normal reverse bold cy_ye got_rexxutil opsys noansi varname preimg postimg
parse arg amessage , altans,def,arrowok
ony2:
aynn=' '
if def='' then
 defans=''
else
 defans=translate(left(strip(def),1))
if altans='' then altans='No Yes'

w.0=words(altans)
goo=aynn
do iw0=1 to w.0
     w.iw0=strip(word(altans,iw0))
     a.iw0=translate(left(w.iw0,1))
     aa.iw0=substr(w.iw0,2)
     aynn=aynn||bold
     if  a.iw0=defans then aynn=aynn||cy_ye
     aynn=aynn||a.iw0||normal||aa.iw0
     goo=goo||a.iw0||aa.iw0
     if iw0<w.0 then do
       if noansi=0 then
          aynn=aynn'  '
       else
          aynn=aynn'  '
       goo=goo||'  '
     end
end
if arrowok=1 then aynn=aynn||' [UP]'

do forever
 foo1=normal||reverse||amessage||'? '||normal||aynn||': 'normal
 goo=amessage'?'||goo':'

 if length(goo)<73 then do
    call charout,foo1
 end
 else do
    foo1=normal||reverse||amessage||'? '||normal
    say foo1
    call charout,'     : 'aynn||': 'normal
 end

 if got_rexxutil =1 then do
    anans=translate(sysgetkey('echo'))
 end
 else do
    pull anans
    anans=left(strip(anans),1)
 end

 if anans='?' then do   /* asking for help */
     call online_help varname
     say
     signal ony2
 end 

 ianans=c2d(anans)
 if anans='' | ianans=13 | ianans=10 then  anans=defans

 if arrowok=1 & ianans=0 & got_rexxutil=1 then do
     ians=c2d(sysgetkey('noecho'))
     if ians=72 then  do
           say ;say
           return -1  /* -1 : up key */
     end
 end /* do */

 do ijj=1 to w.0
    if abbrev(anans,a.ijj)=1 then do
        say
        return Ijj-1
    end
 end /* do */
 call charout,'0d'x
end

/*********************/
online_help:procedure expose normal reverse bold cy_ye got_rexxutil opsys noansi preimg postimg
parse upper arg varname



/* NOANSI LINEART IMGSTRING_MAX LINELEN NO_WORDWRAP TD_ADD
TOOLONGWORD TABLEMODE DISPLAY_ERRORS LINK_DISPLAY BORDER */
say
say cy_ye"Help for: "normal bold varname
select
   when varname="NOANSI" then do
     say bold" Suppress use of ANSI screen controls."normal
     say "This only effects screen io, not program functioning. If you see lots of"
     say "$, [ and other garbage on your screen, then you should enable this option"
   end
   when varname="LINEART" then do
     say bold"Use lineart and other high-ascii (non keyboard) characters." normal
     say "This is useful if you have a non-standard display."
     say '           NEITHER: do not use high ascii characters '
     say '   HIGH_ASCII_ONLY: Use high ascii "glyphs", but do not use lineart '
     say '              BOTH: Use both high-ascii glyphs and lineart '
   end
   when varname="IMGSTRING_MAX" then do
     say bold'How to display  IMG elements'normal
     say ' NO_DISPLAY : Do not display (ignore all IMG elements)'
     say '         [] : Just display the 'bold'PREIMG'normal' ('preimg' ) and 'bold'POSTIMG'normal' ( 'postimg' ) characters'
     say '  REFERENCE : Display a reference number (and generate a SRC and ALT'
     say '             reference list at the bottom of the text file)'
     say ' ALT_ATTRIBUTE: Display all characters in an <IMG ALT=xx> attribute'
     say '                The filename is used if no ALT attribute is available'
   end
   when varname="LINEWIDTH" then do
     SAY BOLD 'Maximum length of line (in characters).'NORMAL
     SAY      'Larger values mean wider text files '
   end
   when varname="NO_WORDWRAP" then do
     SAY BOLD 'Each non-table paragraph is one long line.'NORMAL
     SAY 'This will suppress the maximum line length --'
     say '   (effectively setting the maximum line length to infinity)'
     SAY 'but only for non-table output.  '
     say 'If you intend to import the text ouptut file  to a wordprocessor,'
     say 'use of NO_WORDWRAP is recommended.'
   end
   when varname="TD_ADD" then do
     say bold 'Augment cell widths'normal
     say 'Augment cell widths (in tables) by this factor. '
     say '  This will increase narrow cell widths, and decrease wide cells.'
     say '  Large values (say, 50) will tend to make all cells the same size. '
     say '  0 means "no adjustment".'
     say 'Use of a large value (say, 20) can help when text is being clipped'
     say 'in narrow cells.'
   end /* do */
   when varname="CHARWIDTH" then do
     say bold 'Width of character in pixels'normal
     say 'Assume that characters are this wide'
     say '   CHARWIDTH is used to convert absolute pixel sizes (say, as specified'
     say '   in the WIDTH element of an IMG or a TABLE) to an equivalent '
     say '   number of characters. For example, if linelength=80 and '
     say '   charwidth=8, then the implicit screen width is 640.'
   end /* do */
   when varname='BORDER' then do
      say bold 'Always display a border around tables 'normal
      say 'To (by default) display a border around tables, enable this option.'
      say 'This can be disabled to by a BORDER=0 attribute in a <TABLE > element'
   end /* do */
   when varname="TOOLONGWORD" then do
     SAY BOLD 'Trimming long strings.'normal
     SAY " What to do with strings that don't fit (say, into a table cell)"
     SAY ' TRIM : trim to line (or cell) width (discard excess)'
     say ' WRAP : wrap excess onto a new line'
     say ' PUSH : release margins (allow a line to be larger then maximum line width)'
     say '        Does not apply to tables; for tables, PUSH  means TRIM'
   end
   when varname="TABLEMODE" then do
      say bold 'How do display tables.'normal
      say '     TABLES :  use tabular display (cells of text, possibly nested)'
      say '    UL_LIST :  use a UL list instead of tabluar display'
      say '  PARAGRAPHS:  use a HR like bar, and line breaks, instead of tabluar display'
      say ' Use of UL_LIST and PARAGRAPHS may be necessary when you have'
      say ' very complicated tables'
   end
   when varname="DISPLAY_ERRORS" then do
      say bold 'Note errors in text (output) file'normal
      say '        NO : Do not note errors'
      say '    SERIOUS: Note serious errors'
      say '        ALL: Note all errors and warnings'
      say '    VERBOSE:  Note all errors, with short description '
      say 'Note: The ERROR_FLAG is used to "note errors" (it is written to the '
      say '      text file near where the error was found). '
   end
   when varname="LINK_DISPLAY" then do
     say bold ' How to display URLS.'normal
     say '            TARGET : display the  target (stuff between <a href=..>  and  </a>)'
     say '  REFERENCE&TARGET : display the target, and a [nnn] reference number, where '
     say '                     [nnn] points to a reference list at end of the output file'
     say '         URL&TARGET: use the targets and the actual url '
   end

   otherwise do
     say "No help available "
   end
end  /* select */

return 0


/*********************/
/* select nth from a sequence of words -- use first if nth ># words */
nth_word:procedure
parse arg alist,nth
if words(alist)=1 then return alist
if nth>words(alist) then nth=1
return strip(word(alist,nth))

/************/
/* running status report to screen  */
noteit:procedure
parse arg nowlen,waslen,blocksize,prenote
if nowlen-waslen> blocksize then do
   call charout,'0d'x || '0d'x||prenote' 'nowlen
   return nowlen
end /* do */
return waslen


/***********************/
/* wrap or strip a string */
fix_linelen:procedure expose leftside. preimg postimg prea posta crlf

parse arg aline,llen,itype,dolft,altype
adash=' '
select
   when length(aline)<=(llen-(dolft*leftside.!width)) then do  /* as is */
       bud=aline
       if dolft=1 then bud=add_leftside(aline)
   end /* do */

   when itype=-1 then do                /* trim */
      aline=shrink_in(preimg,aline,postimg,llen)        /* remove stuff between quotes */
      aline=shrink_in(prea||preimg,aline,postimg||posta,llen)
      arf=substr(aline,2,1)             /* detect line of all same stuff */
      repeats=1
      do iarf=3 to length(aline)-1
         if arf=substr(aline,iarf,1) then iterate
         repeats=0 ; leave
      end /* do */
      if repeats=0 then do              /* not all same stuff */
        bud=left(aline,llen-(dolft*leftside.!width))  /* trim */
      end
      else do           /* all same stuff, remove junk from middle */
           tt1=left(aline,1); tt2=right(aline,1)
           bud=copies(arf,max(1,llen-((dolft*leftside.!width)+2)))
           bud=tt1||bud||tt2
      end /* do */
      if dolft=1 then bud=add_leftside(aline)
   end

   otherwise do
      bud=''
      alime=strip(aline,'t')
      if length(alime)<=(llen-(dolft*leftside.!width)) then do  /* as is */
         bud=alime
         if dolft=1 then bud=add_leftside(alime)
      end /* do */
      else do
       lll=max(1,(llen-((dolft*leftside.!width)+1)))
        do mm=1 to length(alime) by lll
           s2=substr(alime,mm,max(1,llen-1))
           if dolft=1 then s2=add_leftside(s2)
           bud=bud||s2||adash||crlf
        end /* do */
        if length(bud)>3 then
        bud=left(bud,length(bud)-3)   /* clip last adash||crlf */
      end                        /* too long ,even after stripping */
   end   /*otherwise */
end             /* select */

return bud


/**********************/
/* remove middle, unimportatnt portions of quoted string */
shrink_in:procedure
parse arg q1,aline,q2,llen
q1=space(q1,0)
q2=space(q2,0)
iq1=length(q1)
iq2=length(q2)
if (left(aline,iq1)=q1) & (right(aline,iq2)=q2)  &  (llen>(iq1+iq2+1))  then do
           aline=q1||substr(aline,iq1+1,llen-(iq1+iq2))||q2
end
return aline

/***************/
/* add leftside. stuff */

add_leftside:procedure expose leftside.
parse arg bud
if leftside.!width>0  then do
   if leftside.!done<leftside.0 then do
      iss=leftside.!done+1
      bud=leftside.iss' 'bud
      leftside.!done=iss
      if iss=leftside.0 then do
          leftside.0=0 ;leftside.!done=0
      end
      drop leftside.iss
   end
   else do
        bud=copies(' ',leftside.!width)||bud
   end /* do */
end
return bud


/***************/
/* ADD SPECIAL "LOGICAL ELEMENT" CHARACTERS? */
fix_quote_anchor:procedure expose link_display links_list. anchoron1 anchoron2 quoteon1 quoteon2 ,
                quotestring1 quotestring2 prea posta thispara
parse arg t1

     firstspace=verify(t1,' ')
     if firstspace=0 then signal stp2

     if anchoron1=1 then do
          select
             when link_display=1 then do
                t1='['||links_list.0||']'||strip(t1)
             end
             when link_display=2 then do
                mm3=links_list.0
                parse var links_list.mm3 atp '?' .
                t1='<"'atp'">'||t1
             end /* do */
             otherwise nop
          end  /* select */
         firstspace=verify(t1,' ')
          t1=insert(prea,t1,firstspace-1)     /* preface this with prea */
          anchoron1=0
     end

     if quoteon1=1 & t1<>'' then do
           t1=insert(quotestring1,t1,firstspace-1)
           quoteon1=0
     end

stp2:
     lenth=length(thispara)
     if thispara='' then
         lastchar=0
     else
         lastchar= 1+lenth-verify(reverse(thispara),' ')

     if anchoron2=1 then do
            thispara=insert(posta,thispara,lastchar)
            anchoron2=0
     end
     if quoteon2=1 & thispara<>'' then do
           thispara=insert(quotestring2,thispara,lastchar)
           quoteon2=0
     end
     return t1


/**********************/
/* convert table elements? (uses globals */
cvt_table_elements:procedure expose t2a tablemode addonmode
parse arg t2,inmain

    tfoo=wordpos(t2,'TABLE TR TD TH /TABLE ')
    if tfoo>0 then do           /* a table element ... */

/*   note: if tablemode=1, one should NEVER see TR TD or TH */
      if tablemode=1 & tfoo>1 & inmain=1 & addonmode<>1 then do
          say ' '
          say "Warning: syntax error; TD TR or TH detected in main "
      end /* do */

      select
          when tablemode=2 then do
             t2=strip(word('TL LI LI LI /TL',tfoo)) ;t2a=t2
          end
          when tablemode=3 then do
             t2=strip(word('HR1 P BR BR HR2 ',tfoo)); t2a=t2
          end
          otherwise nop           /* make a table using ascii and/or lineart */
      end               /* select */
   end          /* tfoo */
   return t2


/*************/
/* CONVERT &ENCODING */
CONVERT_CODES:PROCEDURE expose boldstring1 boldstring2
PARSE ARG T1,CAPON,ISPRE,ULINEON,ISTH

IF T1='' then RETURN T1

      if capon>0 | ISTH='TH' then do 
         if boldstring1<>0 then do
            t1=boldstring1||t1||boldstring2
         end /* do */
         else DO
            t1=translate(t1)
         END
      end 
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
               when v2='LT' then t1=t1||'<'
               when v2='GT' then t1=t1||'>'
               when v2='QUOT' then t1=t1||'"'
               when v2='NBSP' then t1=t1||'01'x
               when datatype(v2)='NUM' then t1=t1||d2c(v2)
               otherwise t1=t1||' 'translate(v2)' '
            end  /* select */
        end /* v2<>"" */
      end /* FOREVER  */
RETURN T1




/***********************/
/* a lineout with a fix for regina rexx */
lineout2:
parse arg oofile,dothis1
dothis2=dothis1  ; leaveit=0
do until leaveit=1
   ffo=pos('0d0a'x,dothis2)
   if ffo=0 then do
     ooline=dothis2 ; leaveit=1    /* end */
   end
   else do
      if ffo=1 then do  /* empty line */
          ooline='  '
          dothis2=substr(dothis2,3)
      end
      else do
          ooline=left(dothis2,ffo-1)
          dothis2=substr(dothis2,ffo+2)
      end
    end

/* replace leading spaces with tabs if no_wordwrap? */
   if no_wordwrap=1 & doingtable=0 then do
       ll1=length(ooline); ll2=length(strip(ooline,'l'))
       if pos('___',ooline)=0 & ll1>ll2 then do  /* don't center hrs */
            ntabs=(ll1-ll2)%4
            a3=copies('09'x,ntabs+1)
            ooline=a3||strip(ooline,'l')
       end /* do */
   end /* do */
   call lineout oofile,ooline

end /* do */
return 1


/* END OF UTILITY PROCS */
/******************/



/*******************************************/
/* GENERATE A TABLE INTO A TEMP VARIABLE */
GEN_TABLE:PROCEDURE EXPOSE TABLES. outfile ,
       pretitle posttitle prea posta preh1 posth1 prehn posthn imgstring_max preimg postimg ,
       docaps douline doquote quotestring1 quotestring2 hn_outline hn_Numbers.  oltypes. ol_numbers. olnumber ,
       flagmenu flagul flagselect flagselect2 radiobox checkbox  errorflag display_errors ,
       tablevert tablehoriz tablefiller lineart submitmark1 submitmark2 ,
       textmark1 textmark2 textmark radioboxcheck checkboxcheck toolongword hrbig ,
       tablemode2 flagtl  tableborder showallopts suppress_empty_table charwidth ,
       linelen_orig wasblank suppress_blanklines ignore_width leftside. addonmode ,
       td_add crlf form_br links_list. link_display img_refs. BOLDSTRING1 BOLDSTRING2 


arow.0=0

PARSE ARG nth,linelen

 /* say linelen " table " nth tables.nth.!spec  */
l0=linelen


/* set width of  this table */
linelen=get_tablewidth(tables.nth.!spec,linelen)  /* might be less then linelen */

call get_border_info    /* get border character info (uses only globals, and sets BVAL  */
if bval>1.0 then do
  noouter=' '; norules=' '
end

/* determine max columns in table, and WIDTH info of cells */
ccols=1; CSCOLS=1
do iir=1 to tables.nth.!rows
  tribble=tables.nth.iir.!totcols
  if tribble=0 then do                  /* warning: 0 tds in this tr */
    tables.nth.!errors=tables.nth.!errors||"TR_NO_TD "
    if addonmode<>1 then
       say " Warning: TR with no TD "
  end
  cscols=max(cscols,tribble)
  ccols=max(ccols,tables.nth.iir.!cols)
  do jcc=1 to tables.nth.iir.!cols
       gogo=get_tdwidth(tables.nth.iir.jcc.!spec,linelen,ignore_width,tables.nth.iir.jcc.!stuff, ,
                        tables.nth.iir.jcc.!colspan)
       parse var gogo gogo1 gogo2 gogo3         /* explicit maxauto minauto */
       if gogo1='' then gogo1=0
       if gogo3='' then gogo3=0
       if gogo2='' then gogo2=0
       tables.nth.iir.jcc.!tdwidth=gogo1
       tables.nth.iir.jcc.!mxll=min(gogo2,trunc(l0*1.5))
       tables.nth.iir.jcc.!mnll=max(gogo3,td_add+2)

/*       tables.nth.iir.jcc.!mxll=max(gogo2+td_add,tables.nth.iir.jcc.!tdwidth)
       tables.nth.iir.jcc.!mnll=max(gogo3,td_add+2) */


end   /* jcc tds */

end /* iir trs */

/* determine width of each column, given WIDTH info exists from above */
do kk=1 to cscols
   colwidths.kk=0               /* 0 signfies "unspecified */
   colwidths2.kk=0              /* unwrapped line lengths (concatended */
   colwidths2.kk.!min=2
   EXTRAS.KK.0=0
   extras.kk.!rws=1
end /* do */
do kr =1 to tables.nth.!rows
     kc2=1
     do kc=1 to tables.nth.kr.!cols
          cspan=tables.nth.kr.kc.!colspan
          cwidth=tables.nth.kr.kc.!tdwidth
          colwidths.kc2=max(colwidths.kc2,cwidth)
          if cwidth=0 then do
             tmx=tables.nth.kr.kc.!mxll
             colwidths2.kc2=max(colwidths2.kc2,tmx)
             tmn=tables.nth.kr.kc.!mnll
             colwidths2.kc2.!min=max(colwidths2.kc2.!min,tmn)
          end /* do */
          tables.nth.kr.kc.!tblcol=kc2  /* actual table column this td starts at */
          kc2=kc2+cspan
     end /* do */
end /* do */

/* colwidths2.0 ... */
colwidths2.0=0
do kk=1 to cscols
  colwidths2.0=colwidths2.0+colwidths2.kk
end /* do */

/* determine missing widths */

/* first, assign widths to columns with no width specified  -- use  td specific ".!maxlinelen" info*/
nsum=0 ; nnone=0
do kk=1 to cscols
   nsum=nsum+colwidths.kk
   if colwidths.kk=0 then do
      nnone=nnone+1
    end
end /* do */

/* 2) add missings? */
if nnone>0 then do
   misslen=linelen-nsum    /* default width to use for non width specfied columns */
   deflen=trunc(misslen/nnone)
   nsum=0
   do kk=1 to cscols
       if colwidths.kk=0 then do
           if colwidths2.kk=0 then do
               colwidths.kk=deflen
           end
           else do
              t1=colwidths2.kk/colwidths2.0
              colwidths.kk=max(colwidths2.kk.!Min+2,trunc(t1*misslen))
           end
       end
       nsum=nsum+colwidths.kk
   end
end

/* normalize (insure sum equals linelen) */
if (nnone>0 & nsum<>linelen) | (nsum>linelen) then do
   afact=linelen/nsum
   nsum=0
   do kk=1 to cscols
        colwidths.kk=max(1,trunc(colwidths.kk*afact))

        nsum=nsum+colwidths.kk
   end /* do */
   fixit=linelen-nsum
   if fixit>0 then do
      colwidths.1=colwidths.1+linelen-nsum           /* truncations get added to first column */
   end
   else do                      /* cols must be 1 space wide -- subtract from other columns*/
      do pp=1 to cscols         /* column that will support it */
         if colwidths.pp>5 then do
              colwidths.pp=colwidths.pp-1
              fixit=fixit+1 ; if fixit=0 then leave
              if colwidths.pp>25 then do         /* extra penalty */
                colwidths.pp=colwidths.pp-1
                fixit=fixit+1
                if fixit=0 then leave
              end                       /* small chance it won't get evened out . */
          end           /* >5 */
      end               /* 1 to cscols */
   end                  /* fixit */
end /* do */

if bval<>0 then colwidths.1=colwidths.1-1                       /* leave room for left side border */

mincellwidth=linelen            /* used for a warning message */
funk=''
do kk=1 to cscols
   mincellwidth=min(mincellwidth,colwidths.kk)
   funk=funk' 'colwidths.kk
end /* do */

/* compute actual size of cells in each row, taking colspan into account */
/* also, add filler cell if need be */
do kr=1 to tables.nth.!rows
    jc1=1 ; mycols=tables.nth.kr.!cols
    do kc=1 to mycols
       actsize=-1
       jc2=jc1+tables.nth.kr.kc.!colspan
       do jj=jc1 to (jc2-1)
          actsize=actsize+colwidths.jj
       end /* do */
       tables.nth.kr.kc.!linecc=actsize
       jc1=jc2
    end /* do */
end /* do */

call go_make_bars       /* make default horizontal diviers (use/set globals */

IF mincellwidth<14  then  do
    tables.nth.!errors=tables.nth.!errors||"NARROW_CELLS "
    TABLEMODE=3         /* use HR BR instead for internal tables */
end
else do
  tablemode=tablemode2            /* tablemode for nested tables */
end
wasblank=0
indent=0; rightindent=0
ispre=0                 /* <PRE> is on? */
olcnts=''                 /* OL count */
lastelem=''
capon=0
ulineon=0
listtypes=''
anchoron=0 ; anchoron1=0; anchoron2=0
quoteon=0 ; quoteon1=0 ; quoteon2=0
ddon=1
thispara=''             /* current paragraph */
iscenter=0
aflag=' '

if hn_outline>0 then do
  do jj=hn_outline to 7
     hn_outlines.jj=0
  end /* do */
end

sendout_internal=1
sendout_var=''

/********* Widths are now determined -- start writing lines of the table */

datable=''
tablealive=0                    /* used to suppress empty table */

do Jir=1 to tables.nth.!rows    /********* FOR EACH ROW OF THE TABLE */
ic0=1
do ic=1 to tables.nth.Jir.!cols /**** FOR EACH COLUMN-CELL IN THE ROW */

 body=tables.nth.Jir.ic.!stuff          /* cell contents */

 linecc=tables.nth.jir.ic.!linecc       /* cell width in characters */
 if ic=tables.nth.jir.!cols & bval=0 then do
    linecc=linecc+1
    tables.nth.jir.ic.!linecc=linecc
 end

/* parse and format this cell's content */

 indent=0+cellpadding ; rightindent=0+cellpadding
 do forever                     /**** FOR EACH LINE IN A COLUMN-CELL */
    if body='' then leave

    parse var body t1 '<' t2a '>' body

/* Add t1 to thispara */
/* but first convert &codes */
     T1=CONVERT_CODES(T1,CAPON,ISPRE,ULINEON,TABLES.NTH.JIR.IC.!TH)

/* and fix up quote/anchor stuff */
     t1=fix_quote_anchor(t1)     /* may change globals */
/* now add it..... */
     thispara=thispara||t1      /* ADD T1 TO THISPARA FOR EVENTUAL OUTPUT */

/* now, process the <element> */
    t2=strip(translate(word(t2a,1)))
    if left(t2,1)='/'  then
        t2end=substr(t2,2)
    else
        t2end=''

/* convert table element to simpler form?? */
    t2=cvt_table_elements(t2)

/* THIS DOES THE PARSING */
     if t2='_TABLE_' then do            /* this is an internal table -- recurse! */
           parse var t2a . newtable ; newtable=strip(newtable)
           foo=sendout(thispara,ispre,indent,aflag,lineCC)
           aflag='' ;THISPARA=''
           if  datatype(newtable)='NUM' then do
              newtable=strip(newtable)
              if tables.newtable.!caption<>' ' then do
                 dacaption=prehn||tables.newtable.!caption||posthn
                 if tables.newtable.!captiona<>'BOTTOM' then
                   foo=sendout(dacaption,0,indent,' ',linecc,'CENTER')
              end /* do */
              thispara=gen_table(newtable,linecc)

              altype=tables.newtable.!ALIGN

              foo=sendout(thispara,1,indent,'',lineCC,altype)
              if tables.newtable.!captiona='BOTTOM' then
                   foo=sendout(dacaption,0,indent,' ',linecc,'CENTER')

              if tables.newtable.!errors<>' ' then
                 tables.1.!errors=tables.1.!errors||';'NEWTABLE':'tables.newtable.!errors' '
              thispara='' ;aflag=''
           end
     end /* do */
     else do
        call interpret_elems linecc /* generic interprets */
     end
  end           /* body forever */

/* all done with this cell -- write it out a "line at a time */

  t1=fix_quote_anchor('')  /* may change globals */

  foo=sendout(thispara,ispre,indent,aflag,lineCC)
  thispara=''

/* add some prior lines (from rowspan>1 cell in this column) ? */
  nlines=0
  ictbl=tables.nth.jir.ic.!tblcol  /* starting table column of this td */
  if extras.ictbl.0>0 then do
      do nl=1 to extras.ictbl.0         /* add "extras for this table column */
         arow.ic.nl=extras.ictbl.nl
      end /* do */
      nlines=extras.ictbl.0
      extras.ictbl.0=0
  end

  do forever            /* Parse lines out and store in arow.ic. array */
     if sendout_var='' then leave
     nlines=nlines+1
     parse var sendout_var arow.ic.nlines (crlf) sendout_var
  end /* do */
  arow.ic.0=nlines
  sendout_var=''

/* note: excess lines in rowspan>1 are shuffled down; these may have
         been from a several rows back large rowspan  */

  if tables.nth.jir.ic.!rowspan=1 then arow.0=max(arow.0,nlines)

end    /* ic */

/* and extras  beyond this tr's last td? */
ikoo=tables.nth.jir.!cols
islandtds=''
if ikoo=0 then
   ikoo2=cscols+1   /* a hack to cause skip of next section */
else
   ikoo2=tables.nth.jir.ikoo.!tblcol
do joob=ikoo2+1 to cscols
   if extras.joob.0=0 then iterate
   arow.0=max(arow.0,extras.joob.0)  /* island cells  approximation */
   islandtds=islandtds' 'joob
end /* do */

/* shuffle down extra lines (for rowspan<>1 cells) -- they may have come
   from prior rows */

do ic=1 to tables.nth.jir.!cols
   ictbl=tables.nth.jir.ic.!tblcol     /* save to appropriate table column storage */
   extras.ictbl.!bar=' '
   if arow.ic.0>arow.0 then do

      ictbl=tables.nth.jir.ic.!tblcol     /* save to appropriate table column storage */
      iq1=arow.0+1
      extras.ictbl.!bar=arow.ic.iq1          /* use this instead of usebar */
      iq3=0
      do iq2=arow.0+2 to arow.ic.0
         iq3=iq2-(1+arow.0)
         extras.ictbl.iq3=arow.ic.iq2
      end
      extras.ictbl.0=IQ3
   end /* do  >arow.0 */
end /* do ic */

/* done with all cells in this row of the table.
  horiz append each line of each cell to create linelen lines,
  vert appen these lines to make a row of cells */

/* type of alighment */
rspec=tables.nth.Jir.!spec
dalign=get_elem_val(rspec,'ALIGN')
dalignv=get_elem_val(rspec,'ALIGNV')

thisrows="" ; tralive=0      /* assume empty row */
iii0=1
didpad=cellpadding ; didpad2=didpad

do until iii0>arow.0
  thisline=''

  if jir=tables.nth.!rows then do
    if noouter<>"VOID" then do
               usebar=horizbar2
     end
     else do
               usebar=copies(' ',length(horizbar2))
     end
  end
  else do
    if norules<>"NONE" then do
       if noouter="VOID" then
          usebar=' 'substr(horizbarm,2,length(horizbarm)-2)' '
       else
          usebar=horizbarm
    end
    else  do
       usebar='|'||copies(' ',max(1,length(horizbarm)-2))||'|'
    end
  end

  do ic=1 to tables.nth.Jir.!cols
      linecc=tables.nth.jir.ic.!linecc
      if iii0=1 then do          /* cell specs , check on first line */
          call set_caligns
      end
      iii=iii0-lineoffset.ic            /* used for centering */

      if iii<1 | iii>arow.ic.0 then do       /* fller line (valign stuff ?*/
         addme=copies(tablefiller,max(1,linecc))
         if didpad>0 & iii0=1 then do     /* add initial padding */
            if ic=tables.nth.jir.!cols then didpad=didpad-1
            dopad=1
          end
          if didpad2>0 & iii0=arow.0 then do     /* add ending padding */
             if ic=tables.nth.jir.!cols then didpad2=didpad2-1
             dopad=1
          end
      end
      else do                   /* got a line to add */
/* initial padding? */
       select
         when didpad>0 & iii0=1 then do     /* add initial padding */
            if ic=tables.nth.jir.!cols then didpad=didpad-1
            addme0='  '; dopad=1
          end
          when didpad2>0 & iii0=arow.0 then do     /* add ending padding */
             if ic=tables.nth.jir.!cols then didpad2=didpad2-1
              addme0=arow.ic.iii ; arow.ic.iii=' '; dopad=1
          end
          otherwise   do
                addme0=arow.ic.iii ;dopad=0
          end
        end
        if addme0<>' ' then do
            tralive=1  ;tablealive=1
        end /* do */
        linecc=max(1,linecc)
        select
           when calign.ic='MIDDLE' | calign.ic='CENTER' then
              addme=center(addme0,linecc)
           when calign.ic='RIGHT' then
              addme=right(addme0,linecc)
           otherwise
              addme=left(addme0,max(0,linecc),' ')
        END
      end               /* non filler line */

      if bval=0 & ic=1 then do          /* put border around thisline */
         tl1=length(thisline)
         thisline=addme
         tl2=length(thisline)
      end
      else do
         tl1=length(thisline)+length(tvert)
         tvv=tvert
         if ic=1 & noouter='VOID' then tvv=' '
         if ic<>1 & norules='NONE' then tvv=' '
         thisline=thisline||tvv||addme
         tl2=length(thisline)
      end

     if iii0==arow.0 then do                       /* modify usebar? */
        if tables.nth.jir.ic.!nobot=1 then do      /* suppress bottom border */
          ictbl=tables.nth.jir.ic.!tblcol
          usebar=overlay(extras.ictbl.!bar,usebar,tl1+1,tl2-tl1)
       end
     end

  end /* do ic */

/* in case of insufficient cells .. */
  if cScols>tables.nth.Jir.!TOTcols then do
     if islandtds<>'' then do            /* island cells to do? */
       is2=islandtds
       oz0=tables.nth.jir.!totcols+1
       do forever
         if is2='' then do              /* no more islands -- fill to end */
             do ozo=isle1+1 to cscols
                thisline=thisline||copies(tablefiller,max(1,colwidths.ozo-1))
             end /* do */
             leave
         end /* do */
         parse var is2 isle1 is2 ; isle1=striP(isle1)
         tvv=tvert; if norules='NONE' then tvv=' '
         do ozo=oz0 to (isle1-1)                /* fill some columns */
            thisline=thisline||tvv||copies(tablefiller,max(colwidths.ozo-1,1))
         end /* do */
         addmox=extras.isle1.iii0
         select
           when calign.ic='MIDDLE' | calign.ic='CENTER' then
              addmox=center(addmox,colwidts.isle1-1)
           when calign.ic='RIGHT' then
              addmox=right(addmox,colwidths.isle1-1)
           otherwise
              addmox=left(addmox,colwidths.isle1-1,' ')
          END
         tvv=tvert ; if norules="NONE" then tvv=' '
         thisline=thisline||tvv||addmox||tvv
       end
     end
     else do            /* no istlands -- fill rest of line */
          goon2=LINELEN-length(thisline)
          thisline=thisline||copies(tablefiller,max(1,goon2-1))
     end /* do */
  end /* do */

  if bval<>0 & noouter<>'VOID' then
      thisline=thisline||TVERT          /* END OF A LINE */
  else
      thisline=thisline||' '          /* END OF A LINE */

  thisrows=thisrows||thisline||CRLF     /* APPEND TO "LINES IN THIS ROW OF CELLS */

  if dopad=0 then iii0=iii0+1   /* not padding */

end             /* iii (lines in this row ) */

DO FOREVER
   IF ISLANDTDS='' then LEAVE
   PARSE VAR ISLANDTDS IS1 ISLANDTDS ; IS1=STRIP(IS1)
   EXTRAS.IS1.0=0
end /* do */

if tralive=0 & suppress_empty_table=1 then do  /* suppress empty row? */
     nop
end /* do */
else do
     datable=DATABLE||thisrows||usebar||CRLF
end

arow.0=0

end             /* Jir'th row */

sendout_internal=0

if tablealive=0 & suppress_empty_table=1 then return ' '


if noouter<>'VOID' then
   datable=horizbar1||crlf||datable               /* top line of da table */
else
  datable=copies(' ',length(horizbar1))||crlf||datable



return datable



/***********/
/* set alignment info */
set_caligns:
         calign=''; calignv=''
         cspec=tables.nth.Jir.ic.!spec
         calignv=get_elem_val(cspec,'VALIGN')
           if calignv="" then calignv=dalignv
         calign=get_elem_val(cspec,'ALIGN')
           if calign="" then calign=dalign
         calign.ic=calign
         lineoffset.ic=0
         if calignv='MIDDLE' | calignv='CENTER' | calignv='' then do
            lineoffset.ic=max(0,trunc((arow.0-arow.ic.0)/2))
         end /* do */
return 1


/***********************/
go_make_bars:

horizbar2=' '||copies(THORIZ,max(1,linelen-2))  /* TABLE WIDE DIVIDER LINE */
horizbar1=horizbar2 ; horizbarm=horizbar2


I218=' ';I192=' ';I195=' ';I197=' ';I194=' '; I193=' '
I180=' '; I191=' '; I217=' '

SELECT
  WHEN bvaL=0 THEN DO           /* no lines */
     USET=' '
  end /* do */
  WHEN LINEART=1 then DO                /* use lineart for nice boxes */
    if bval<2 then do
       i218=d2c(218) ;   i192=d2c(192) ;  i195=d2c(195)
       i197=d2c(197) ; i194=d2c(194) ; i193=d2c(193)
       i180=d2c(180) ; i191=d2c(191) ; i217=d2c(217)
    end
    else do
         i218=d2c(201) ; i192=d2c(200); i195=d2c(204)
         i193=d2c(202) ; i194=d2c(203)
         i197=d2c(206) ; i180=d2c(185) ; i191=d2c(187) ;i217=d2c(188)
    end /* do */
    uset=thoriz
  END
  OTHERWISE DO          /* NO LINEART --  use _ only */
      USET=THORIZ
  END
END


  horizbar1=i218
  horizbar2=i192
  horizbarm=i195
  do kk=1 to cScols
     horizbarm=horizbarm||copies(uset,max(1,colwidths.kk-1))
     horizbar1=horizbar1||copies(uset,max(1,colwidths.kk-1))
     horizbar2=horizbar2||copies(uset,max(1,colwidths.kk-1))
     if kk<>cScols then do
       horizbarm=horizbarm||i197
       horizbar1=horizbar1||i194
       horizbar2=horizbar2||i193
     end
  end
  horizbarm=horizbarm||i180
  horizbar1=horizbar1||i191
  horizbar2=horizbar2||i217
  return 1


/**************************/
/* get border info */
get_border_info:

/* Border for this table */
SPECS=TABLES.NTH.!SPEC
bval=tables.nth.!border


if datatype(bval)<>'NUM' then bval=tableborder

if tableborder>1 then bval=trunc(tableborder)  /* force borders? */
if tableborder=-1 then bval=0           /* suppress borders */

noouter=get_elem_val(specs,'FRAME')

norules=get_elem_val(specs,'RULES')

cellpadding=get_elem_val(specs,'CELLPADDING')
if datatype(cellpadding)<>'NUM' then
  cellpadding=0
else
  cellpadding=max(0,trunc(cellpadding/charwidth))



IF  bval=0 then DO               /* border type */
   TVERT=' '; THORIZ=' '
end /* do */
else DO                 /* line art, or explicit character */
  if lineart<>1 then do
      tvert=tablevert
  end
  else do
     if bval=1  then
       tvert=d2c(179)
     else
        tvert=d2c(186)
  end
  if lineart<>1 then do
      thoriz=tablehoriz
  end
  else do
    if bval=1  then
      thoriz=d2c(196)
    else
      thoriz=d2c(205)
  end
END

return 1


/*********************/
/* routine to interpret html elements -- uses lots of globals */
interpret_elems:

parse arg Xlinelen
indent3=4
if xlinelen<22 then indent3=1

mindent3=4
if xlinelen<22 then mindent3=1

/* break off piece of body  */

/* look for line breakers */
    select
      when t2='HR' then do

         hrsize=get_elem_val(t2a,'SIZE')                /* line height */
         if datatype(hrsize)<>'NUM' then hrsize=1
         if hrsize<3 then
            hrchar='_'
         else
            hrchar=hrbig

         hrwidth=strip(get_elem_val(t2a,'WIDTH'))   /* line width */
         select
             when hrwidth='' then hrwidth=1.0
             when right(hrwidth,1)='%' then do
                 parse var hrwidth hrwidth '%' .
                 if datatype(hrwidth)='NUM' then
                    hrwidth=min(100,hrwidth)/100
                 else
                    hrwidth=1
             end /* do */
             otherwise do
                if datatype(hrwidth)='NUM' then
                      hrwidth=min(1,hrwidth/640)
                else
                       hrwidth=1
             end
         end
         hrchars=max(2,trunc((xlinelen-4)*hrwidth))
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         call sendout ' '
         thispara='';aflag=0
         foo=sendout(center(copies(hrchar,hrchars),xlinelen),1,,,xlinelen)
         if hrsize>10 then
            foo=sendout(center(copies(hrchar,hrchars),xlinelen),1,,,xlinelen)
         call sendout ' '

      end

      when t2='HR1' then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         thispara='';aflag=0
         if lineart>=0 then do
             foo=sendout(center(d2c(201)||copies(d2c(205),max(1,Xlinelen-6))||d2c(187),Xlinelen),1,,,xlinelen)
         end
         else do
             foo=sendout(center('/'copies('=',max(1,Xlinelen-6))'\',Xlinelen),1,,,xlinelen)
         end
         indent=indent+indent3
      end

      when t2='HR2' then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         thispara='';aflag=0
         att='='
         if lineart>=0 then do
             foo=sendout(center(d2c(200)||copies(d2c(205),max(1,Xlinelen-6))||d2c(188),Xlinelen),1,,,xlinelen)
         end
         else do
             foo=sendout(center('\'copies('=',max(1,Xlinelen-6))'/',Xlinelen),1,,,xlinelen)
         end
         indent=max(indent-mindent3,0)
      end

/* H1 H2 H3 ... HEADERS */
      when wordpos(t2,'H1 H2 H3 H4 H5 H6 H7')>0 then do
         HN_LEVEL=WORDPOS(T2,'H1 H2 H3 H4 H5 H6 H7')
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         thispara=''
         ah=getelem('/H')

         call remove_htmls ah
         ah=result

         docenter=0     /* don't add pre Hn stuff if centered */

/* Add an "outline" number */
        if hn_outline<=hn_level & hn_outline<>0 then do
           hn_outlines.hn_level=hn_outlines.hn_level+1

           do mmh=hn_outline to (hn_level-1)        /* fix up lower levels */
              if hn_outlines.mmh=0 then hn_outlines.mmh=1
           end /* do */
           do mmh=hn_level+1 to 7  /* fix up higher levels */
              hn_outlines.mmh=0
           end /* do */

           immh=0 ;aah=''       /* build outline number */
           do mmh=hn_outline to hn_level
              immh=immh+1
              jint=hn_outlines.mmh
              anums=hn_numbers.immh
              if words(anums)<jint then
                aah=aah||jint
              else
                aah=aah||strip(word(anums,jint))
              if mmh<hn_level then aah=aah'.'
           end /* do */
           ah=aah') 'ah         /* add the outline number */
        end

        if  (pos('CENTER',translate(t2a))+pos('MIDDLE',translate(t2a)))>0 & ,
             length(ah)<Xlinelen then do
                docenter=1
         end
         else do
             if HN_LEVEL=1 then do
                 p1=preh1;p2=posth1
              end
              else do
                   p1=prehn ; p2=posthn
              end /* do */
              ah=p1||ah||p2
         end /* do */

         ah=translate(ah,' ','0d0a0009'x)
         if docenter=1 then  ah=center(ah,Xlinelen)

         call sendout ' '
         foo=sendout(ah,22,indent,,xlinelen)
         if HN_LEVEL<4 then call sendout ' '
         aflag=0 ; thispara=''
      end

      when t2='P' then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         thispara='';aflag=0
         if lastelem<>'P' then
             foo=sendout(' ',ispre,indent,aflag,xlinelen)
         palign=get_elem_val(t2a,'ALIGN')
         if palign='CENTER' | palign='MIDDLE' then docenter=1
         if palign='LEFT' | palign='RIGHT' then docenter=0
      end /* do */


       when t2='PRE'  then DO
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
          CALL SENDOUT ' '
          thispara='' ; aflag=0
          ispre=1
       END
       when t2='/PRE' then DO
          foo=sendout(thispara,ispre,indent,aflag,xlinelen)
          CALL SENDOUT ' '
          thispara='' ; aflag=0
          ispre=0
       END

       when t2='DIV'  then do
          foo=sendout(thispara,ispre,indent,aflag,xlinelen)
          isc=get_elem_val(t2a,'ALIGN')
          if isc="MIDDLE" | isc="CENTER" then
              iscenter=1
          if isc="RIGHT" then iscenter=2
          thispara='' ; aflag=0
       end /* do */

       when t2='/DIV' then do
          foo=sendout(thispara,ispre,indent,aflag,xlinelen)
          thispara='' ; aflag=0
          iscenter=0
       end

       when t2='CENTER' then do
          foo=sendout(thispara,ispre,indent,aflag,xlinelen)
          thispara='' ; aflag=0
          iscenter=1
        end

       when t2='/CENTER' then do
          foo=sendout(thispara,ispre,indent,aflag,xlinelen)
          thispara='' ; aflag=0
          iscenter=0
        end

      when t2='TEXTAREA' then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         thispara='';aflag=0
         ah=getelem('/TEXTAREA')
         call remove_htmls ah
         ah=result
         ncols=get_elem_val(t2a,'COLS')
         if datatype(ncols)<>'NUM' then ncols=50
         ah2=box_around(ah,min(ncols,Xlinelen-3))
         foo=sendout(ah2,1)
         aflag=0
      end

      when t2='IMG' then do
         parse var t2a . srcname imgname
         call do_imagename imgname
         thispara=thispara||imgname' '
      end /* do */

      when t2='BLOCKQUOTE' then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         call sendout ' '
         thispara='';aflag=0
         indent=indent+indent3 ; rightindent=rightindent+indent3
      end

      when t2='/BLOCKQUOTE' then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         thispara='';aflag=0
         call sendout ' '
         indent=max(0,indent-mindent3); rightindent=max(0,rightindent-mindent3)
      end

      when wordpos(t2,'UL TL DL OL MENU DIR')>0 then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         listtypes=listtypes' 't2
         if t2='OL' then DO
             olstart=get_elem_val(t2a,'START')
             if datatype(olstart)<>'NUM' then olstart=1
             olstart=olstart-1
             OLCNTs=OLCNTs' 'olstart
             aOLTYPE=GET_ELEM_VAL(T2A,'TYPE',1)
             oltype=WORDPOS(aOLTYPE,'1 a A i I')
             foof=words(olcnts)
             oltypes.foof=ol_numbers.oltype

         end
         if t2='DL' then ddison=0
         thispara='';aflag=0
         i3=3; if xlinelen<25 then i3=1
         indent=indent+indent3
     end

      when wordpos(t2,'/UL /DL /OL /MENU /DIR /TL ')>0 then do
         IW=WORDS(LISTTYPES)
         lastt=''
         if iw>0 then LASTT=WORD(LISTTYPES,IW)
         IF lastt<>SUBSTR(T2,2) then do
              indent=0 ; olcnts='' ; listtypes=''
              call do_display_error 1 ,  "Warning: expected "||t2||"; found /"||lastt , ,
                                         T2"_NOT_"lastt
         end /* do */

/* legit list .. */
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         thispara=' '         ; aflag=0

/* shrink list infos */
         if lastt='OL' then do
             iw2=words(olcnts)
             if iw2=1 then do
                olcnts=''
             end
             else do
               if iw2<1 then
                 call do_display_error 1, "Warning: Problem with OL UL or SELECT ","UNEXPECTED_DELWORD"
               ELSE
                  olcnts=delword(olcnts,iw2)
             END
         end
         if iw=1 | listtypes='' then                 /* fix list of UL OL */
                listtypes=''
         else
               listtypes=delword(listtypes,iw)
         indent=max(0,indent-mindent3)
         if t2='/DL' & ddon=1 then indent=max(0,indent-mindent3)

         call sendout ' '

      end               /* /ul etc */

      when t2='LI'  then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         thisval=get_elem_val(t2a,'VALUE')
         aflag=figflag(thisval)       /* the flag for this type */
         thispara=''
         call sendout ' '
      end /* do */

      when t2='DD' | t2='DT' then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         goon=words(listtypes)
         rre=0
         if goon=0 then do
            rre=1
         end /* do */
         else do
            if word(listtypes,goon)<>'DL' then rre=1
         end
         if rre=1 then do
              if addonmode<>1 then SAY ' '
              indent=0 ; olcnts='' ; listtypes=''
              call do_display_error 1, "Warning: DD or DT not expected in  list " , "UNEXPECTED_DD|DT"
         end
         aflag=' '
         if t2='DT' then do
             if ddon=1 then indent=max(0,indent-mindent3)
             ddison=0
             ddon=0
         end
         if t2='DD' then do
              if ddison=0 then indent=indent+indent3
              ddon=1 ; ddison=1
         end
         thispara=''
         call sendout ' '
      end /* do */

      when t2='SELECT' then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         selsize=get_elem_val(t2a,'SIZE')
         if datatype(selsize)<>"NUM" | showallopts=1 then do
             listtypes=listtypes' 't2
         end
         else do
             a1=2
             if selsize=1 then a1=1
             listtypes=listtypes' 't2||(selsize+a1)
         end
         thispara='';aflag=0
         ijm=max(1,xlinelen-(indent+rightindent+4))

         ijm=min(ijm,14)
         if  lineart>=0 then
            foo3=d2c(218)||copies(d2c(196),ijm)  /* ||d2c(191) */
         else
            foo3='/'||copies('-',ijm)   /* ||'\' */
         foo=sendout(foo3,0,indent,,xlinelen)
         indent=indent+1

      end

      when t2='OPTION' then do
         goon=words(listtypes)
         ggw=word(listtypes,goon)
         if abbrev(ggw,'SELECT')=0 then do      /* SELECT not active */
              indent=0 ; olcnts='' ; listtypes=''
              call display_error 1,"Warning: Option not expected in list" , "UNEXPECTED_OPTION"
         end

/* check selsize counter */
         parse var ggw 'SELECT' ggw2
         showok=0
         if ggw='SELECT' then do
            showok=1
         end
         else do
            if datatype(ggw2)='NUM' then do
               if ggw2>0  then do
                   showok=1
                   if ggw2=1 then showok=2
                   jt3=ggw2-1 /* count down */
                   ggw3='SELECT'||jt3
                   listtypes=delword(listtypes,goon)' 'ggw3
               end /* do */
            end
         end
         if showok=1 then do    /* SIZE not violated */

              if thispara<>"" then foo=sendout(thispara,ispre,indent+1,aflag,xlinelen)
              aflag=flagselect
              if pos('SELECTED',translate(t2a))>0 then aflag=flagselect2
              thispara=''
          end         /* else, SIZE shown already */
          else do
             if showok=2 then DO
               thispara=prea||'...more'||posta /* this is the ..more.. flag */
               foo=sendout(thispara,ispre,indent+1,aflag,xlinelen)
             END
             thispara='' ; AFLAG=''  /* zap this option text */
          end /* do */
      end /* do */


     WHEN T2='/SELECT' then DO
         IW=WORDS(LISTTYPES)
         LASTT=WORD(LISTTYPES,IW)
         IF abbrev(lastt,'SELECT')=0 then do
              call do_display_error 1, "Warning: expected "||t2||"; found /"||lastt , "UNEXPECTED_/SELECT"
              indent=0 ; olcnts='' ; listtypes=''
         end /* do */

/* legit list .. WITHIN SIZE?*/
         if right(lastt,1)<>'0' then
            foo=sendout(thispara,ispre,indent+1,aflag,xlinelen)

         thispara=' '         ; aflag=0
         if iw=1 then  do               /* fix list of UL OL */
                listtypes=''
         end
         else do
             if iw>0 then listtypes=delword(listtypes,iw)
         end
         indent=max(0,indent-1)

         ijm=max(1,xlinelen-(indent+rightindent+4))

         ijm=min(ijm,14)
         if  lineart>=0 then
                foo3=d2c(192)||copies(d2c(196),ijm) /*||d2c(217) */
         else
                foo3='\'||copies('-',ijm)   /* ||'/' */
         foo=sendout(foo3,0,indent,,xlinelen)
      end

      when t2='BR' | (t2='/FORM' & form_br=1) then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         if t2='BR' then isclear=get_elem_val(t2a,'CLEAR')      /* clear past floatings (end word wrap) ? */
         thispara='';aflag=0
      end /* do */

/* paragraph modifiers */
       when t2='A' then  do
             if pos(' NAME=',translate(t2a))=0 then do
                anchoron2=0
                if anchoron=1 then do           /* warning */
                    call do_display_error 0,"Warning: unclosed <A> ", "UNCLOSED_<A>"
                    anchoron2=1                /* assume we are preceded by a </a> */
                end /* do */
                anchoron=1 ;anchoron1=1
                yowo=pos('HREF=',translate(t2a))
                yowo2=substr(t2a,yowo)
                if pos('"',yowo2)=0 then
                  parse var yowo2 . '=' a_url . 
                else
                  parse var yowo2 hh '"' a_url '"' .
                if link_display<>0 then do
                  igg=links_list.0+1
                  links_list.igg=a_url
                  links_list.0=igg
                end
             end
       end
       when t2='/A' then  do
          if anchoron=1 then anchoron2=1
          anchoron=0 ;anchoron1=0
       end

/* LOGICAL ELEMENTS */
       when pos(t2,docaps' 'douline' 'doquote)>0 then do        /* a font modifer */
           if wordpos(t2,docaps)>0 then capon=capon+1
           if wordpos(t2,douline)>0 then ulineon=ulineon+1
           if wordpos(t2,doquote)>0 then do
                quoteon=quoteon+1 ;quoteon1=1 ; QUOTEON2=0
            end
       end /* do */

/* END LOGICAL ELEMENTS */
       when pos(t2end,docaps' 'douline' 'doquote)>0 then do        /* end of font modifer */
          if wordpos(t2end,docaps)>0 then capon=max(0,capon-1)

          if wordpos(t2end,douline)>0 then ulineon=max(0,ulineon-1)
          if wordpos(t2end,doquote)>0 then do
             IF QUOTEON=1 then QUOTEON2=1   /* this is the end of nested emphasis */
             quoteon=max(quoteon-1,0) ;quoteon1=0
          end
          if t1<>'' then thispara=' 'thispara

       end

      when t2='INPUT' then do

          atype=TRANSLATE(get_elem_val(t2a,'TYPE'))

          IF ATYPE='' then ATYPE='TEXT'
          avalue=get_elem_val(t2a,'VALUE',1)
          if atype='RADIO' then do
             if wordpos('CHECKED',translate(t2a))>0 then
                 thispara=thispara' 'radioboxcheck
             else
                 thispara=thispara' 'radiobox
          end
          if atype='CHECKBOX' then do
             if wordpos('CHECKED',translate(t2a))>0 then
                 thispara=thispara' 'checkboxcheck' '
             else
                 thispara=thispara' 'checkbox' '
          end
          if atype='TEXT'  then do
               av2=get_elem_val(t2a,'SIZE')
               if av2='' then av2=get_elem_val(t2a,'MAXLENGTH')
               if av2='' then av2=4
               atextmark=textmark1||textmark||textmark||left(avalue,max(1,av2-2),textmark)||textmark2
               thispara=thispara' 'atextmark
          end
          if atype='FILE'  then do
               av2=get_elem_val(t2a,'SIZE')
               if av2='' then av2=get_elem_val(t2a,'MAXLENGTH')
               if av2='' then av2=5
               atextmark=textmark1||textmark||textmark||left(avalue,max(1,av2-2),textmark)||'(submit)'textmark2
               thispara=thispara' 'atextmark
          end

          if atype='SUBMIT' then do
             if avalue='' then avalue='SUBMIT'
             thispara=thispara' '||submitmark1||strip(avalue)||submitmark2
          end /* do */
          if atype='RESET' then do
             if avalue='' then avalue='RESET'
             thispara=thispara' 'submitmark1||strip(avalue)||submitmark2
          end /* do */

       end /* do */

       otherwise nop
    end  /* select */

return 1                /* results saved in thispara */

/******************/
/* figure out waht the imagename should be */
do_imagename:
parse arg imgname

imgname00=imgname
         select
          when imgstring_max<0 then imgname=''
          when imgstring_max=1 then imgname=left(imgname,min(length(imgname),max(5,xlinelen-5)))
          when imgstring_max=0 then nop
          otherwise imgname=left(imgname,min(length(imgname),imgstring_max))
         end
         if imgname<>'' then do
            imgname=preimg||strip(imgname)||postimg
         end
         else do                     /* if -2, then show nothing */
            select
               when imgstring_max=-3 then nop /* imgname is still '' */
               when imgstring_max=-2 then  imgname=preimg||postimg
               when imgstring_max=-1 then do
                  ir=img_refs.0+1
                  imgname=preimg||'I'ir||postimg
                  img_refs.ir='('srcname'): 'imgname00
                  img_refs.0=ir
               end /* do */
               otherwise imgname='[IMG]'
            end  /* select */
         end /* do */
         imgname=space(translate(imgname,' ','0d0a0009'x))
         imgname=fix_quote_anchor(imgname)
return imgname


/*************/
/* display error? */
do_display_error:
parse arg serious,amess,err2
if display_errors=0 then return 1       /* write nothing */

if addonmode<>1 then say amess               /* write to screen */

if display_errors=1 & serious<>1 then return 1  /* do not record to file */
errflag=errorflag
if display_errors=3 then errflag=errorflag||err2
ioo=sendout(eRRflag' 'thispara,ispre,indent,aflag,xlinelen)
if addonmode<>1 then say " "
thispara=' ' ; aflag=0

toterr=value('TOTERRORS')
if datatype(toterr)<>"NUM" then toterr=0
toterr=value('TOTERRORS',toterr+1)


return 1


/***************************/
/* say help */
sayhelp:
say ''
say "          "cy_ye||copies('/',25)||copies('\',25)|| normal
say "                    "bold"HTML_TXT: An HTML to text converter"normal
say " "
say bold"HTML_TXT "normal" is used to convert an "bold"HTML"normal" file to a "bold"text"normal" file. "
say " "
say bold"HTML_TXT"normal" will attempt to maintain the format of the HTML document "
say "by using appropriate spacing and ASCII characters. "
say " "
say bold"HTML_TXT"normal" can use ASCII art (lines and boxes), as well as other high-ascii "
say "characters, to improve the appearance of the output (text) file."
say " "
say bold"HTML_TXT"normal" can be customized in a number of ways. For example, you can:"
say " * suppress the use of line art and other high ASCII characters (your output"
say "   will be rougher, but will suffer from fewer compatability problems)."
say " * display tables (including nested tables) in a tabular format, or as "
say "   ordered lists"
say " * change the bullet characters used in ordered lists "
say ' * display Hn "headers" as an hierarchical outline '
say " * change characters used to signify logical elements (emphasis, anchors, etc.)"
say " "
say " "
if got_rexxutil=1 then do
    say cy_YE " ... hit ank key to continue " NORMAL
    foo=sysgetkey('noecho')
end
else do
    call charout, " .. hit ENTER to continue "
    pull foo
end

say
say " ";say " " ; say " " ; say " "; say " "; say " "
say bold" Usage Hints: "normal
say " "
SAY " * "reverse"Quick file list:"normal" enter "bold"/DIR file.ext"normal" (for example: "bold"/DIR *.HTM /p"normal
say " "
SAY " * "reverse"To change a parameter:"normal" enter "bold"/VAR var1=val1"normal" (for example: "bold"/VAR lineart=0 "normal
say " "
SAY " * "reverse"Command line mode:"normal" Specify input (html) and output (text) file"
say "         "bold"Example: "normal"D:\>HTML_TXT foo.htm foo.txt "
say " "
say "    ... or, to modify the default parameters, add "bold" /VAR var1=val1 ; var2=val2  "normal
say "         "bold"Example: "normal"D:\>HTML_TXT foo.htm foo.txt /VAR lineart=0 ; flagul=* $ ! "
say " "
say " * "bold"Reading parameters from a file:"normal" include a "bold"PLIST=file.ext"normal" in a /VAR list"
say " "
say " * "bold"HTML_TXt allows you to set a few of the more important parameters "
say " "
say " * "bold"You can set a number of user-configurable parameters by editing HTML_TXT.CMD "
say " "
say "            "cy_ye||copies('\',25)||copies('/',25)|| normal
say " " ; say " "
return 1


/*********/
/* show stuff in queue as a list */
show_dir_queue:procedure expose qlist.
parse arg lookfor
    ibs=0 ;mxlen=0
    if lookfor<>1 then
       nq=queued()
     else
        nq=qlist.0
    do ii=1 to nq
       if lookfor=1 then do
          aa=qlist.ii
          ii2=lastpos('\',aa) ; anam=substr(aa,ii2+1)
       end /* do */
       else do
          parse pull aa
          if pos(lookfor,aa)=0 & lookfor<>'*' then iterate
          parse var aa anam (lookfor) .
          if strip(anam)='.' | strip(anam)='..' then iterate
       end
       ibs=ibs+1
       blist.ibs=anam
       mxlen=max(length(anam),mxlen)
    end /* do */
arf=""
do il=1 to ibs
   anam=blist.il
   arf=arf||left(anam,mxlen+2)
   if length(arf)+mxlen+2>75  then do
        say arf
        arf=""
   end /* do */
end /* do */
if length(arf)>1 then say arf
say
return 1


/**********/
/* ask for an integer (min value of minval */
ask_integer:procedure expose bold normal varname cy_ye reverse
parse arg  varname,amess,defval,minval
if minval='' then minval=0
if amess=''  then amess=' ? '
if defval='' then defval=minval
if varname='' then varname=word(amess,1)

do forever
  call  charout,'   'bold||amess||normal||'('||defval||'):'
  pull aa
  if aa='?'  then do
      call online_help varname
      say
      iterate
  end
  if aa="" then aa=defval
  if datatype(aa)<>'NUM' then do
      say " You must enter an integer greater then or equal to " minval
      iterate
  end /* do */
  if aa<minval then do
      say " You must enter an integer greater then or equal to " minval
      iterate
  end /* do */
  return aa
end


/* ---------------------------------------------*/
/* get a url from some site, return first
maxchar characters (if maxchar missing, get 10million (the whole thing?) */
/* ---------------------------------------------*/



get_url:procedure 
parse arg aurl,maxchar,verbose,headers

if maxchar="" then maxchar=10000000

got=""
aurl=sref_fix_url(aurl)
if abbrev(translate(aurl),'HTTP://')=1 then do
   aurl=substr(aurl,8)
end
parse var aurl server '/' request

/* if VERBOSE>0 then 
    call pmprintf(" calling http url : " server ", " request)
*/

/* now get the url.  This is based on GoServe's MOVEAUD command. It
requires the RxSock.DLL be in your LIBPATH. */

/* Load RxSock */
    if \RxFuncQuery("SockLoadFuncs") then nop
    else do
       call RxFuncAdd "SockLoadFuncs","rxSock","SockLoadFuncs"
       call SockLoadFuncs
    end

    crlf    ='0d0a'x                        /* constants */
    family  ='AF_INET'
    httpport=80

   rc=1
   if verify(server,'1234567890.')>0 then 
       rc=sockgethostbyname(server, "serv.0")  /* get dotaddress of server */
   else
      serv.0addr=strip(server)

    if rc=0 then do
        ss=sref_error('Unable to resolve "'server'"',verbose)
        return 0
    end
    dotserver=serv.0addr                    /* .. */
    gosaddr.0family=family                  /* set up address */
    gosaddr.0port  =httpport
    gosaddr.0addr  =dotserver

    gosock = SockSocket(family, "SOCK_STREAM", "IPPROTO_TCP")

    /* Set up request [HTTP 0.9 style, for all servers] */
    message="GET /"request' HTTP/1.0 'crlf
    if length(headers)>2 then do
       if right(headers,2)=crlf then headers=left(headers,length(headers)-2)
    end
    if headers<>'' then message=message||headers||crlf
    message=message||crlf

    got=''
    rc = SockConnect(gosock,"gosaddr.0")
    if rc<0 then do
        ss=sref_error(' Unable to connect to "'server'"',verbose)
        return 0
    end
    rc = SockSend(gosock, message)



 /* Now wait for the response */

   do r=1 by 1
     rc = SockRecv(gosock, "response", 1000)
     got=got||response
     if rc<=0 then leave
     tmplen=length(got)
     if tmplen> maxchar then leave
  end r

  rc = SockClose(gosock)

return got

