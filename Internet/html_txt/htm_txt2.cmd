/* 6 April 1999
              HTM_TXT2.CMD : An HTML to text converter
                              "the quicker version"

   Created by Daniel Hellerstein (danielH@econ.ag.gov)

   This is an older/faster/less_feature_rich version of HTML_TXT.CMD

   This program is freeware. It's written in REXX, and has been
   tested under OS/2 4.0, and under the VCPI version of Regina REXX
   for DOS.  Note that several io features are not available when
   run under REGINA REXX (see HTML_TXT.HTM for details).

Features include:
    Supports UL, OL, MENU ordered lists.
    Supports nested TABLES, using line art to display.
    FORM elements supported, including SELECT, TEXTAREA, and CHECKBOX.
    A Hierarchical outline can be created from Hn elements
    Highly configurable; logical element markers, list bullets,
      outline numbering style, table writing styles, and many other
      features are readily modified by changing user configurable parameters.
    Fast (table intensive 60k file in 6 seconds on a P166)
    Run from command line, or from a simple keyboard (non-gui) interface.

Installation:

  Just copy HTM_TXT2.CMD to any directory (for example, to a
  directory in your PATH).
  It runs a bit better with, but does NOT require, REXXUTIL.DLL

  Note:
   This is the "faster" version of HTML_TXT. It does not have support
   several advanced features; such as ROWSPAN and CAPTION for tables.
   However, for many less complex pages, this will do an adequate 
   job, in about 1/2 the time.


Usage:

   Assuming HTM_TXT2.CMD is on your "x" drive; from an
   os/2 command prompt enter:
      x:>HTM_TXT2 file.htm file.txt
   will convert the HTML document "file.htm" into an equivalent
   text (ascii), and save the results as file.txt.

   Or, enter HTM_TXT2 at a command prompt, and answer the queries.

   See HTML_TXT.HTM for usage details -- there are a number of
   options you may want to modify (though the defaults will work
   fine in most cases).

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


/********** USER CONFIGURABLE PARAMETERS *********/
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
*/
   
/*  ----- General controls */




/*CHARWIDTH: width of a character in pixels. 
   Used to convert various WIDTH and HEIGHT attributes.  */
charwidth=8

/* DOCAPS: Captialization is used for these "logical and physical" elements */
docaps='TT CODE B STRONG '

/* DOULINE: Spaces are replaced with _ (uncerlines) for these "logical and 
            physical elements" */
douline='U BLINK'

/* DOQUOTE: "quotes" are used for "logical and physical" elements.
  Note : QUOTESTRING1 and QUOTESTRING2 are used as the "quote" characters */
doquote='I EM VAR'


/*ERRORFLAG: String to place in output file when an error is found in the HTML code */
errorflag='_ERROR_'

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
      2 : Ignore width, no autosizing (equi sized cells 
      1 : Ignore WIDTH attributes in table (use all space, equally divided 
      0 : Use WIDTH attributes  */
ignore_width=0


/* IMGSTRING: default words (or words) to use as an "image placeholder" 
   This is used if a IMG element has no ALT attribute). */
imgstring='[IMG]'

/* LINEART: Suppress use of high ascii (non keyboard) characters.
            This is useful if you have a non-standard display.
    -1 : No high ascii characters allows
     0 : No lineart characters, but other high ascii characters are allowed
     1 : Use high ascii characters   */
lineart=1

/* LINELEN: maximum length of line (in characters). 
            Larger values mean wider text files */
linelen=80

/* NOANSI: Suppress use of ANSI screen controls.
  This only effects screen io, not program functioning. If you see lots of 
  $, [ and other garbage on your screen, set NOSANSI=1 
     0 : do NOT suppress ANSI screen controls
     1 : suppress ANSI screen controls */
noansi=1   


/* SHOWALLOPTS: display all OPTIONS in a SELECT list.
   0 : Use the SIZE attrbute of a SELECT list
   1 : Ignor SIZE attribute (always display all options) */
showallopts=0   

/* SUPPRESS_BLANKLINES: minimize number of blank lines
   1  : If multiple empty lines, just print one empty line (except if PRE)
   0  : allow multiple empty lines  (i.e.; <BR><BR><BR> becomes 3 empty lines)*/
suppress_blanklines=1

/* TOOLONG WORD: trimming long strings.
  What to do with strings that don't fit (say, into a table cell)
    -1 : trim (discard excess)
     0 : wrap 
     1 : push margins (does not apply to tables; for tables, 1 means trim) */
toolongword=1     


/* DISPLAY_ERRORS: note errors in text file 
    0 : Do not note errors
    1 : Note serious errors
    2 :  Note all errors and warnings
    3 : Long Note all errors, with
   The "ERROR_FLAG" is used to "note errors" (it is written to the text file
   near where the error was found. For 3, a short error description is also written*/
display_errors=1

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
      0 : default is no border -- can be overridden by a BORDER=n attribute in <TABLE>
      1 : default is narrow border -- can be overridden by a BORDER=n attribute in <TABLE>
    1.1 : always use narrow border 
  2 and above: Use broad border. */
tableborder=0

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
flagmenu='#'

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
   numbers are used (i.e.; 11, 12, ...) */
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
   QUOTESTRING2: character used as a "right quote" (with doquote elements) */
quotestring1=180
quotestring2=195


/* RADIOBOX: Character used as to signify an <INPUT TYPE=RADIO .. > element
   RADIOBOXCHECK: Character used as to signify an 
                    <INPUT TYPE=RADIO .. CHECKED> element */
radiobox=176
radioboxcheck=178

/* SUBMITMARK1: Character to use before a <INPUT TYPE=SUBMIT or TYPE=RESET ..> element 
   SUBMITMARK2: Character to use after a <INPUT TYPE=SUBMIT or TYPE=RESET ..> element */
submitmark1=204
submitmark2=185


/* TEXTMARK1 : character to use on left end of an <INPUT TYPE=TEXT ..> element
   TEXTMARK2 : character to use on right end of an <INPUT TYPE=TEXT ..> element
   TEXTMARK : character to use inside of  an <INPUT TYPE=TEXT ..> element  */
textmark1=222
textmark2=221
textmark='_'

/* TABLEVERT: character to use as vertical lines in a table
   TABLEHORIZ: character to use as horizontal lines in a table
   Neither of these are used if LINEART=1  */
tablevert='!'      
tablehoriz='-'

/* TABLEFILLER: character to used to fill empty spaces in tables and textbox's */
tablefiller=' '

/********** END OF USER CONFIGURABLE PARAMETERS *********/


call loadlibs           /* load up some libraries and ANSI support*/

parse arg infile outfile params

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

if noansi=0 then call loadlibs


getin:
if infile="" then do
    call lineout,bold " Enter name of HTML file (? for help, EXIT to quit) "normal
    call charout,"  "reverse " :" normal
    pull infile ; infile=strip(translate(infile))
end

if strip(translate(infile))='EXIT' then do
   say "bye "
   exit
end /* do */

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

htmlfile=stream(infile,'c','query exists')              /* does it, or .html or .htm version of it, exist*/
if htmlfile='' then htmlfile=stream(infile||'.HTM','c','query exists')
if htmlfile='' then htmlfile=stream(infile||'.HTML','c','query exists')

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
   tout=tout||'.TXT'
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
        if yesno("Overwrite? ")=0 then do
            outfile='' ; signal outget
       end /* do */
     end                /* else, command line mode implies overrwrite */
     else do
          say "Overwriting "foo
     end /* do */
     foo=sysfiledelete(outfile)
     if foo<>0 then do
            say "Could not delete (error " foo
            outfile=''
            signal outget
     end /* do */
end /* do */
signal off syntax ; signal off error
signal hoy2

hoy1:
outfile=' '
say " % " sigl " : " rc
say "File exists. Try another name"
signal off syntax ; signal off error
signal outget


hoy2:
/* get HEAD and BODY */
atitle=head_body(stuff)


/* write <TITLE> */
atitle=pretitle||atitle||posttitle
if length(atitle)<linelen then atitle=center(atitle,linelen)
call lineout2 outfile,atitle
call lineout outfile,' '


/* find all <IMG links and convert to ALT tag, or to IMGSTRING */
call img_convert imgstring

/* remove APPLET  etc junk */
foo=remove_applet('APPLET')
foo=remove_applet('OBJECT')
foo=remove_applet('EMBED')

call set_vars           /* check and set display characters */


/* start parsing BODY */

linelen_orig=linelen
wasblank=0
indent=0                /* current indent */
rightindent=0
ispre=0                 /* <PRE> is on? */
olcnts=''                 /* OL count */
lastelem=''
capon=0
ulineon=0
listtypes=''
anchoron=0 ; anchoron1=0 ; ANCHORON2=0
quoteon=0 ; quoteon1=0 ; QUOTEON2=0
ddon=0
thispara=''             /* current paragraph */
iscenter=0
sendout_internal=0

if hn_outline>0 then do
  do jj=hn_outline to 7
     hn_outlines.jj=0
  end /* do */
end

iat=htmllen-length(body)
say bold " Converting HTML to Text " normal " ...... "
prenote=reverse||'   : '||normal
if htmllen>15000 then call charout, prenote

etime=time('r')

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
         foo=sendout(thispara,ispre,indent,aflag)
         thispara='';aflag=0
         call sendout ' '
         AA=DO_TABLE(t2a)
         sendout_internal=1
         abb=gen_table(1,linelen-(indent+rightindent))
         sendout_internal=0
         if tables.1.!errors<>'' then
              call do_display_error 0,'Table ERRORS: '||tables.1.!errors,tables.1.!errors
         foo=sendout(abb,1)
   end /* do */
   else do              /* NOT a table -- interpret this element (sets globals */
         call interpret_elems linelen   /* changes globals */
   end

end             /* do foerver -- until no more stuff in BODY  */

/* dump current paragraph */
foo=sendout(thispara,ispre,indent,aflag)

/* and we are done! */


call lineout outfile

etime=time('e')
say ' '
say "Elapsed time: " etime

exit


/*************** END OF MAIN **************/

/******************************/
/* change parameters */
change_params:
parse arg plist

plist_ok='TOOLONGWORD TABLEMODE TABLEMODE2 TABLEBORDER PRETITLE POSTTITLE ' ,
         ' LINELEN PREA POSTA PREH1 POSTH1 PREHN POSTHN IMGSTRING PREIMG POSTIMG ',
         ' DOCAPS DOULINE DOQUOTE QUOTESTRING1 QUOTESTRING2 HN_OUTLINE ' ,
         ' HN_NUMBERS.1 HN_NUMBERS.2 HN_NUMBERS.3 HN_NUMBERS.4 HN_NUMBERS.5 HN_NUMBERS.6 ',
         ' HN_NUMBERS.7 OL_NUMBERS FLAGMENU FLAGUL FLAGTL FLAGSELECT FLAGSELECT2 ',
         ' RADIOBOX RADIOBOXCHECK CHECKBOXK CHECKBOXCHECK TEXTMARK1 TEXTMARK2 TEXTMARK ',
         ' HRBIG SUBMITMARK1 SUBMITMARK2 LINEART TABLEHORIZ TABLEFILLER SHOWALLOPTS ' ,
         ' ERRORFLAG  NOANSI TABLEMAXNEST CHARWIDTH SUPPRESS_BLANKLINES DISPLAY_ERRORS ' ,
         ' IGNORE_WIDTH '

PLIST=STRIP(PLIST) ; PLIST=SUBSTR(PLIST,5)

do forever
   if plist='' then leave
   PARSE VAR PLIST AVAR '=' AVAL ';' PLIST
   AVAR=STRIP(TRANSLATE(AVAR))
   IF WORDPOS(AVAR,PLIST_OK)=0 then DO
       SAY "Parameter Error: no such parameter= "avar
       iterate
   end /* do */
   if datatype(strip(aval))='NUM' then aval=strip(aval)
   oldval=value(avar)
   foo=value(avar,aval)
   say " Changing "avar" from "reverse||oldval||normal' to 'bold||aval||normal
end /* do */
return 1




/*************/
/* write a box around a string. Use lineart, or ascii characters */
/* box if no ncols, then use width of longest line */
/* if ncols, cut longest line at ncols */
box_around:procedure expose  lineart tablefiller
parse arg ah,ncols
crlf='0d0a'x
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
figflag:procedure expose olcnts flagul flagmenu listtypes ol_numbers flagtl

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
     if io2>words(ol_numbers) then
        aflag=io2+1
     else
        aflag=strip(word(ol_Numbers,io2))
     aflag=aflag'.'
     olcnts=delword(olcnts,iw2)' 'io2
  end /* do */
  otherwise nop
end  /* select */

return aflag



/***********************************/
img_convert:
parse arg imgs

say bold " Converting <IMG> elements ... " normal
stuff2=''
iat=1
tbody=translate(body)
do forever
  iat2=pos('<IMG',tbody,iat)
  if iat2=0 then leave          /* all done */

/* found an IMG element. Extract it, modify body */
   iat3=pos('>',body,iat2)
    imgis=substr(body,iat2+4,iat3-(iat2+4))
    imgnAme=imgs
    if imgs=0 then do
       imgname=' ' ; imgis=''
    end /* do */
    else do
       imgname=get_elem_val(imgis,'ALT')
    end
    IF IMGNAME<>' ' THEN 
         imgname=preimg||imgname||postimg
    else
        imgname=imgs
    abody=left(body,iat2-1)||imgname
    iat=length(abody)
    body=abody||substr(body,iat3+1)
    tbody=abody||substr(tbody,iat3+1)
end

return 1




/****************/
/* set global vars */
set_vars:
crlf='0d0a'x
aflag=0

tablefiller=do_d2c(tablefiller,' ')
tablevert=do_d2c(tablevert,'|')
tablehoriz=do_d2c(tablehoriz,'_')

hrbig=do_d2c(hrbig,'=')

quotestring1=do_d2c(quotestring1,'`')
quotestring2=do_d2c(quotestring2,"`")

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
textmark=do_d2c(textmark,'_')


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
p1=left(body,foo-1)
parse var body . '>' body
return p1


/********/
/* remove < > from a string */
remove_htmls:procedure
parse arg ast

ast0=''
do forever
  if ast='' then leave
  parse var ast v1 '<' v2 '>' ast
  ast0=ast||v1
end /* do */
return ast0



/***********************************/
/* dump something to output file */
sendout:procedure expose linelen outfile rightindent iscenter toolongword ,
                 sendout_internal sendout_var suppress_blanklines wasblank

parse arg toput,ispre,indent,aflag,XLINELEN
crlf='0d0a'x
IF XLINELEN="" THEN XLINELEN=LINELEN

if (ispre='' | ispre=0)& toput=''  then do
  if suppress_blanklines=1 & wasblank=1 then do
      return 1           /* ignore this "extra crlf */
  end
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
      aline=fix_linelen(aline,Xlinelen,toolongword)
      toput0=toput0||aline
      if toput<>'' then do
         toput0=toput0||crlf
       end
    end
    toput=toput0
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
if ispre=2 then do
  toput0=''
  do forever
      if toput='' then leave
      parse var toput aline (crlf) toput
      aline=fix_linelen(copies(' ',indent)||aline,Xlinelen,toolongword)
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
  if indent>=(length(aflag)+1) then do
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

if (length(toput)+indent) <linelenl then do  /* short string -- write it */
     if iscenter=1 then do      /* center it*/
         isleft=Xlinelen-length(anindent1)
         toput=center(toput,isleft)
     end
     if iscenter=2 then do      /* right it*/
         isleft=Xlinelen-length(anindent1)
         toput=right(toput,isleft,' ')
     end


     if sendout_internal<>1 then
       call lineout2 outfile,anindent1||toput
     else
        sendout_var=sendout_var||anindent1||toput||crlf

     return 1
end /* do */

/* else, parse into linelen chunks and write out */
aline=anindent1
do forever
   if toput='' then leave
   parse var toput aword toput
   lenword=length(aword)

   if lenword>linelenl then do /* BIG word */
       if aline<>'' then do
         if iscenter=1 then aline=center(aline,Xlinelen)
         if iscenter=2 then aline=right(aline,Xlinelen)


         if sendout_internal<>1 then
             call lineout2 outfile,aline
         else
             sendout_var=sendout_var||aline||crlf
       end
       aword=fix_linelen(aword,Xlinelenl,toolongword)


       if sendout_internal<>1 then
              call lineout2 outfile,aword
        else
             sendout_var=sendout_var||aword||crlf

       aline=anindent
       iterate
   end /* do */

   if (length(aline)+lenword)>linelenl then do /* line + word too long */
       if iscenter=1 then  aline=center(aline,Xlinelen)
       if iscenter=2 then aline=right(aline,Xlinelen)

       if sendout_internal<>1 then
          call lineout2 outfile,aline
       else
           sendout_var=sendout_var||aline||crlf
       aline=anindent
   end /* do */

   aline=aline||aword||' '      /* append this word to current line */

end /* do */
if aline<>''  then  do
  if iscenter=1 then  aline=center(aline,Xlinelen)
  if iscenter=2 then aline=right(aline,Xlinelen)
  aline=fix_linelen(aline,Xlinelen,toolongword)

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
   app2=pos('</'||badelem,tbody,app1+5)
   if app2=0 then do
        say ' '
        say " Warning: no /"badelem ' element '
        return 0
   end /* do */
   body2=substr(body,app2+5)
   body=left(body,app1-1)
   parse var body2 . '>' body2
   body=body||body2
end


/*************************************/
/* REMOVE HTML COMMENTS, fix up <  x  elements, parse into HEAD and BODY sections (globals ) */
head_body:PROCEDURE expose head body normal reverse bold prenote
PARSE ARG STUFF

/* remove html comments */
say bold " Removing comments ... " normal
body="" ;iat=0
prenote=reverse||'   : '||normal

do forever              /*no comments within comments are allowed */
   if stuff="" then leave
   parse var stuff t1 '<!--' t2 '-->' stuff
   body=body||t1
end /* do */

/* convert < x to <x, where space can be space, tab, crlf */
say bold " Cleaning up elements " normal
stuff=body
body='' ;iat=0
do forever
  if stuff="" then leave
  parse var stuff t1 '< ' t2 '>' stuff
  body=body||t1
  if t2<>''  then do
    t2=translate(t2,' ','0d0a0900'x)
    t2=strip(t2)
    if t2<>'' then body=body||'<'||t2||'>'
  end
end /* do */


say bold " Extracting <HEAD> and <BODY> " normal
/* pull out <HEAD> and <BODY> sections */
stuff=body ;iat=0
body='' ; head='' ; iat=0
headon=0; bodyon=0 ; headon2=0; bodyon2=0

tstuff=translate(stuff)
hd1=pos('<HEAD',tstuff,1)
hd2=pos('</HEAD',tstuff,max(hd1,1))

if hd1=0 then say "Warning: no <HEAD> element "
if hd2=0 then say "Warning: no </HEAD> element "

if hd2>0 then do
   hdlen=hd2-(hd1+5)  /*  <HEAD starts at 10, then read from 10+5 */
   head=substr(stuff,hd1,hdlen)
   parse var head . '>' head   /* get rid of remnand  > */
end /* do */

hd2=hd2+6  /* get by /HEAD */

bd1=pos('<BODY',tstuff,hd2)
bd2=pos('</BODY',tstuff,max(bd1+5,hd2))

if bd1=0 then say "Warning: No <BODY> element "
if bd2=0 then say "Warning: No <HEAD> element "

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
DO_TABLE:PROCEDURE EXPOSE BODY TABLES. ignore_width tablemode2 tablemaxnest  charwidth linelen_orig ,
parse arg table1

drop tables.

tableinner=0
tables.0=1
tables.1.!rows=0
tables.1.1.!cols=0
tables.1.1.!totcols=0
tables.1.!errors=''
parse var table1 . tables.1.!spec

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
             if translate(v1,' ','0d0a0009'x)<>' ' then  say v1 ":ERROR:: Material outside of column at table " curtable " row " currow
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
                tables.curtable.!errors=tables.curtable.!errors';MISSING_LEADING_TR'
                currow=1
                curcol=0
        end /* do */

        tdcols=get_elem_val(v2a,'COLSPAN')
        if datatype(tdcols)<>'NUM' then tdcols=1
        if tdcols<=0  then tdcols=1
        tdrows=get_elem_val(v2a,'ROWSPAN')
        if datatype(tdrows)<>'NUM' then tdrows=1
        if tdrows<=0 then tdrows=1

        curcol=curcol+1
        tables.curtable.currow.!cols=curcol
        tables.curtable.currow.!totcols=tables.curtable.currow.!totcols+tdcols
        parse var v2a . tables.curtable.currow.curcol.!spec
        tables.curtable.currow.curcol.!TH=v2
        tables.curtable.currow.curcol.!stuff=''
        tables.curtable.currow.curcol.!colspan=tdcols
        tables.curtable.currow.curcol.!rowspan=tdrows
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
                 say v1 ":ERROR:: NEW table of column at table " kurtable " row " kurrow
                tables.kurtable.!errors=tables.kurtable.!errors';PREMATURE_NEW_COLUMN'
           end
        end /* do */

        TABLES.0=CURTABLE
        curtables=curtable' 'curtables
        tables.curtable.!rows=0
        tables.curtable.1.!cols=0
        tables.curtable.1.!totcols=0
        tables.curtable.!errors=''
        PARSE VAR V2A . TABLES.CURTABLE.!SPEC

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
get_tablewidth:procedure expose charwidth linelen_orig
parse arg specs,linelen

tablewidth=strip(get_elem_val(specs,'WIDTH'))

if tablewidth='' then  do
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

if ign<>1 then tdwidth=strip(get_elem_val(aspec,'WIDTH'))


if tdwidth='' | ign=1 then  do
  if ign=2 | colspan>1  then return '0 0 '
  eff=qcell_width(stuff2,linelen)                /* rough guess as to max linelength */
  return 0' 'eff      /* 0 means "no default length found */
end

/* convert % to characters */
if right(tdwidth,1)='%' then do
         tdwidth=strip(tablewidth,,'%')
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

   if t2a='INPUT' then do
          atype=TRANSLATE(get_elem_val(t2,'TYPE'))
          IF ATYPE='' then ATYPE='TEXT'
          avalue=get_elem_val(t2,'VALUE',1)
          if atype='RADIO' | atype='CHECKBOX' then do
            aline=aline' '
          end
          if atype='TEXT' then do
               av2=get_elem_val(t2,'SIZE')
               if av2='' then av2=get_elem_val(t2a,'MAXLENGTH')
               if av2='' then av2=4
               aline=aline'  '||copies(' ',av2)
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

mxlen=0
do iii=1 to ithl
    mxlen=max(mxlen,length(tlines.iii))
end

drop tlines.

return max(2,mxlen)





/******************************/
/* various utility procedures */

/***********************************/
/* load libraries, set ansi, set defaults */
loadlibs:
foo=rxfuncquery('sysloadfuncs')
if foo=1 then do
  foo2=RxFuncAdd('SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs')
  if foo2=0 then call SysLoadFuncs
end

cy_ye=' '; normal=''; bold='';re_wh='';reverse='';aesc=''
if noansi<>1 then do
  aesc='1B'x
  cy_ye=aesc||'[37;46;m'
  normal=aesc||'[0;m'
  bold=aesc||'[1;m'
  re_wh=aesc||'[31;47;m'
  reverse=aesc||'[7;m'
end

return 1


/********************/
/* get, possibly quoted, value of a field in an html type <element > */
get_elem_val:procedure
parse arg haystack,needle,lc

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
/* get a yes or no , return 1 if yes */
yesno:procedure expose normal reverse bold
parse arg fooa , allopt,altans
if altans<>" " & words(altans)>1 then do
   w1=strip(word(altans,1))
   w2=strip(word(altans,2))
   a1=left(w1,1) ; a2=left(w2,1)
   a1a=substr(w1,2) ; a2a=substr(w2,2)
end
else do
    a1='Y' ; a1a='es'
    a2='N' ; a2a='o'
end  /* Do */
ayn='  '||bold||a1||normal||a1a||'\'||bold||a2||normal||a2a
if allopt=1 then  ayn=ayn||'\'||bold||'A'||normal||'ll'

do forever
 foo1=normal||reverse||fooa||normal||ayn
 call charout,  foo1 normal ':'
 pull anans
 if abbrev(anans,a1)=1 then return 1
 if abbrev(anans,a2)=1 then return 0
 if allopt=1 & abbrev(anans,'A')=1 then return 2
end



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
/* wrap or trip a string */
fix_linelen:procedure
parse arg aline,llen,itype,adash
crlf='0d0a'x

if adash='' then adash=' '
if length(aline)<=llen then return aline
if itype=-1 then return left(aline,llen)  /* trim */
if itype=0 then do
  bud=''
  do mm=1 to length(aline) by (llen-1)
     bud=bud||substr(aline,mm,llen-1)||adash||crlf
  end /* do */
  bud=left(bud,length(bud)-3)   /* clip last adash crlf */
  return bud
end
return aline            /* as is */



/***************/
/* ADD SPECIAL "LOGICAL ELEMENT" CHARACTERS? */
fix_quote_anchor:procedure expose anchoron1 anchoron2 quoteon1 quoteon2 ,
                quotestring1 quotestring2 prea posta thispara
parse arg t1

     firstspace=verify(t1,' ')
     if firstspace=0 then signal stp2

     if anchoron1=1 then do
          t1=insert(prea,t1,firstspace-1)     /* preface this with prea */
          anchoron1=0
     end

     if quoteon1=1 then do
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
     if quoteon2=1 then do
           thispara=insert(quotestring2,thispara,lastchar)
           quoteon2=0
     end
     return t1


/**********************/
/* convert table elements? (uses globals */
cvt_table_elements:procedure expose t2a tablemode 
parse arg t2,inmain

    tfoo=wordpos(t2,'TABLE TR TD TH /TABLE ')
    if tfoo>0 then do           /* a table element ... */

/*   note: if tablemode=1, one should NEVER see TR TD or TH */
      if tablemode=1 & tfoo>1 & inmain=1 then do
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
CONVERT_CODES:PROCEDURE
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
    call lineout oofile,ooline
end /* do */
return 1


/* END OF UTILITY PROCS */
/******************/



/*******************************************/
/* GENERATE A TABLE INTO A TEMP VARIABLE */
GEN_TABLE:PROCEDURE EXPOSE TABLES. outfile ,
       pretitle posttitle prea posta preh1 posth1 prehn posthn imgstring preimg postimg ,
       docaps douline doquote quotestring1 quotestring2 hn_outline hn_Numbers. ol_numbers ,
       flagmenu flagul flagselect flagselect2 radiobox checkboxk  errorflag display_errors ,
       tablevert tablehoriz tablefiller lineart submitmark1 submitmark2 ,
       textmark1 textmark2 textmark radioboxcheck checkboxcheck toolongword hrbig ,
       tablemode2 flagtl  tableborder showallopts suppress_empty_table charwidth ,
       linelen_orig wasblank suppress_blanklines ignore_width


crlf='0d0a'x
arow.0=0

PARSE ARG nth,linelen

l0=linelen

/* see if WIDTH attribute for this table */
if ignore_width<>1 then do
   linelen=get_tablewidth(tables.nth.!spec,linelen)  /* might be less then linelen */
end

call get_border_info    /* get border character info (uses only globals, and sets BVAL  */


/* determine max columns in table, and WIDTH info of cells */
ccols=1; CSCOLS=1
do iii=1 to tables.nth.!rows
  cScols=max(ccols,tables.nth.iii.!totcols)
  ccols=max(ccols,tables.nth.iii.!cols)
  do jcc=1 to tables.nth.iii.!cols
       gogo=get_tdwidth(tables.nth.iii.jcc.!spec,linelen,ignore_width,tables.nth.iii.jcc.!stuff, ,
                        tables.nth.iii.jcc.!colspan)
       parse var gogo gogo1 gogo2
       if gogo2='' then gogo2=0
       tables.nth.iii.jcc.!tdwidth=gogo1
       tables.nth.iii.jcc.!mxll=min(gogo2,trunc(1.5*l0))

   end
end /* do */

/* determine width of each column, given WIDTH info exists from above */
do kk=1 to cscols
   colwidths.kk=0               /* 0 signfies "unspecified */
   colwidths2.kk=0              /* unwrapped line lengths (concatended */
end /* do */
do kr =1 to tables.nth.!rows
     kc2=1
     do kc=1 to tables.nth.kr.!cols
          cspan=tables.nth.kr.kc.!colspan
          cwidth=tables.nth.kr.kc.!tdwidth
          colwidths.kc2=max(colwidths.kc2,cwidth)
          if cwidth=0 then do
             colwidths2.kc2=max(colwidths2.kc2,tables.nth.kr.kc.!mxll)
          end /* do */
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
              colwidths.kk=max(2,trunc(t1*misslen))
           end
       end
       nsum=nsum+colwidths.kk
   end
end

/* normalize (insure sum equals linelen) */
if nsum<>linelen then do 
   afact=linelen/nsum
   nsum=0
   do kk=1 to cscols
        colwidths.kk=trunc(colwidths.kk*afact)
        nsum=nsum+colwidths.kk
   end /* do */
   colwidths.1=colwidths.1+linelen-nsum           /* truncations get added to first column */
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
    if jc2<=cscols then do
          toadd=-1
          if bval>0 then toadd=-2
          do jj=jc2 to cscols
             toadd=toadd+colwidths.jj+1
          end /* do */
          mycols=mycols+1
          tables.nth.kr.!filler=copies(tablefiller,toadd)     /* FILLER FOR AN EMPTY CELL */
                                /* implicitly, if mycols<cscols, this will be checked */
    end /* do */
end /* do */

call go_make_bars               /* make horizontal diviers (use/set globals */

IF mincellwidth<14  then  do
    tables.nth.!errors=tables.nth.!errors||"NARROW_CELLS"
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

if hn_outline>0 then do
  do jj=hn_outline to 7
     hn_outlines.jj=0
  end /* do */
end

sendout_internal=1
sendout_var=''

datable=horizbar1||crlf               /* top line of da table */
tablealive=0                    /* used to suppress empty table */

do Jir=1 to tables.nth.!rows

ic0=1
do ic=1 to tables.nth.Jir.!cols

 body=tables.nth.Jir.ic.!stuff

 linecc=tables.nth.jir.ic.!linecc
 if ic=tables.nth.jir.!cols & bval=0 then linecc=linecc+1

 indent=0 ; rightindent=0
 
 do forever
    if body='' then leave

    parse var body t1 '<' t2a '>' body

/* add t1 to thispara */

/* convert &codes */
     T1=CONVERT_CODES(T1,CAPON,ISPRE,ULINEON,TABLES.NTH.JIR.IC.!TH)

     t1=fix_quote_anchor(t1)  /* may change globals */

/* add more content ..... */
     thispara=thispara||t1      /* ADD T1 TO THISPARA FOR EVENTUAL OUTPUT */

/* now, process the <element> */
    t2=strip(translate(word(t2a,1)))             /* get rid of element modifiers */
    if left(t2,1)='/'  then
        t2end=substr(t2,2)
    else
        t2end=''

/* convert table elements? */
    t2=cvt_table_elements(t2)


/* THIS DOES THE WORK */
     if t2='_TABLE_' then do            /* this is an internal table -- recurse! */
           parse var t2a . newtable ; newtable=strip(newtable)
           foo=sendout(thispara,ispre,indent,aflag,lineCC)
           aflag='' ;THISPARA=''
           if  datatype(newtable)='NUM' then do
              newtable=strip(newtable)
              thispara=gen_table(newtable,linecc)
              foo=sendout(thispara,1,indent,'',lineCC)
              if tables.newtable.!errors<>' ' then
                 tables.1.!errors=tables.1.!errors||';'NEWTABLE':'tables.newtable.!errors
              thispara='' ;aflag=''
           end
     end /* do */
     else do
        call interpret_elems linecc /* generic interprets */
     end
  end           /* body forever */

/* all done with this cell -- write it out */
  foo=sendout(thispara,ispre,indent,aflag,lineCC)
  thispara=''

  nlines=0
  do forever
     if sendout_var='' then leave
     nlines=nlines+1
     parse var sendout_var arow.ic.nlines (crlf) sendout_var
  end /* do */
  arow.ic.0=nlines
  sendout_var=''
  arow.0=max(arow.0,nlines)


end    /* ic */

/* done with all cells in this row of the table.
  horiz cappend each line of each cell to create linelen lines,
  vert appen these lines to make a row of cells */

/* type of alighment */
rspec=tables.nth.Jir.!spec
dalign=get_elem_val(rspec,'ALIGN')
dalignv=get_elem_val(rspec,'ALIGNV')

thisrows="" ; tralive=0      /* assume empty row */
do iii0=1 to arow.0              /* max number of lines */
  thisline=''

  do ic=1 to tables.nth.Jir.!cols
      linecc=tables.nth.jir.ic.!linecc

      if iii0=1 then do          /* cell specs , check on first line */
         calign=''; calignv=''
         cspec=tables.nth.Jir.ic.!spec
         calignv=get_elem_val(cspec,'VALIGN')
           if calignv="" then calignv=dalignv
         calign=get_elem_val(cspec,'ALIGN')
           if calign="" then calign=dalign
         calign.ic=calign
         lineoffset.ic=0
         if calignv='MIDDLE' | calignv='CENTER' | calignv='' then do
            lineoffset.ic=trunc((arow.0-arow.ic.0)/2)
         end /* do */
      end
      iii=iii0-lineoffset.ic

      if iii<1 | iii>arow.ic.0 then do       /* fller line ?*/
         lcc=linecc
         if datatype(lcc)<>'NUM' then lcc=l0
         lcc=max(lcc,1)
         addme=copies(tablefiller,lcc)
      end
      else do                   /* got a line to add */
        addme0=arow.ic.iii
        if addme0<>' ' then do
            tralive=1  ;tablealive=1
        end /* do */
        select
           when calign.ic='MIDDLE' | calign.ic='CENTER' then
              addme=center(addme0,linecc)
           when calign.ic='RIGHT' then
              addme=right(addme0,linecc)
           otherwise
              addme=left(addme0,linecc,' ')
        end  /* select */
      end               /* non filler line */
      if bval=0 & ic=1 then
         thisline=addme
      else
         thisline=thisline||TVERT||addme


  end /* do */

/* in case of insufficient cells .. */
  if cScols>tables.nth.Jir.!TOTcols then do
      thisline=thisline||tvert||tables.nth.jir.!filler
  end /* do */

  if bval<>0 then thisline=thisline||TVERT          /* END OF A LINE */
  thisrows=thisrows||thisline||CRLF     /* APPEND TO "LINES IN THIS ROW OF CELLS */

end             /* iii */


if tralive=0 & suppress_empty_table=1 then do  /* suppress empty row? */
     nop
end /* do */
else do
  if Jir<>tables.nth.!rows then
     datable=DATABLE||thisrows||horizbarm||CRLF
  else
     datable=DATABLE||thisrows||horizbar2||CRLF
end

arow.0=0

end             /* Jir */

sendout_internal=0

if tablealive=0 & suppress_empty_table=1 then return ' '

return datable



/***********************/
go_make_bars:

horizbar=copies(THORIZ,linelen-1)  /* TABLE WIDE DIVIDER LINE */
horizbar2=horizbar; horizbar1=horizbar ; horizbarm=horizbar

if lineart=1 & bval<>0 then do             /* ascii art? */
  horizbar1=d2c(218)
  horizbar2=d2c(192)
  horizbarm=d2c(195)
  do kk=1 to cScols
     horizbarm=horizbarm||copies(thoriz,colwidths.kk-1)
     horizbar1=horizbar1||copies(thoriz,colwidths.kk-1)
     horizbar2=horizbar2||copies(thoriz,colwidths.kk-1)
     if kk<>cScols then do
        horizbarm=horizbarm||d2c(197)
        horizbar1=horizbar1||d2c(194)
        horizbar2=horizbar2||d2c(193)
     end
  end
  horizbarm=horizbarm||d2c(180)
  horizbar1=horizbar1||d2c(191)
  horizbar2=horizbar2||d2c(217)

end

return 1


/***************************/
/* get border info */
get_border_info:

/* Border for this table */
SPECS=TABLES.NTH.!SPEC
bval=get_elem_val(specs,'BORDER')
if datatype(bval)<>'NUM' then bval=tableborder

if tableborder>1 then bval=trunc(tableborder)  /* force borders? */

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
indent3=3
if xlinelen<22 then indent3=1

mindent3=3
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
             foo=sendout(center(d2c(201)||copies(d2c(205),Xlinelen-6)||d2c(187),Xlinelen),1,,,xlinelen)
         end
         else do
             foo=sendout(center('/'copies('=',Xlinelen-6)'\',Xlinelen),1,,,xlinelen)
         end
         indent=indent+indent3
      end

      when t2='HR2' then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         thispara='';aflag=0
         att='='
         if lineart>=0 then do
             foo=sendout(center(d2c(200)||copies(d2c(205),Xlinelen-6)||d2c(188),Xlinelen),1,,,xlinelen)
         end
         else do
             foo=sendout(center('\'copies('=',Xlinelen-6)'/',Xlinelen),1,,,xlinelen)
         end
         indent=max(indent-mindent3,0)
      end

/* H1 H2 H3 ... HEADERS */
      when wordpos(t2,'H1 H2 H3 H4 H5 H6 H7')>0 then do
         HN_LEVEL=WORDPOS(T2,'H1 H2 H3 H4 H5 H6 H7')
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         thispara=''
         ah=getelem('/H')
         ah=remove_htmls(ah)

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
         foo=sendout(ah,2,indent,,xlinelen)
         if HN_LEVEL<4 then call sendout ' '
         aflag=0
      end

      when t2='P' then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         thispara='';aflag=0
         if lastelem<>'P' then call sendout ' '
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
         ah=remove_htmls(ah)
         ncols=get_elem_val(t2a,'COLS')
         if datatype(ncols)<>'NUM' then ncols=50
         ah2=box_around(ah,min(ncols,Xlinelen-3))
         foo=sendout(ah2,1)
         aflag=0
      end

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
         if t2='OL' then OLCNTs=OLCNTs' 0'
         thispara='';aflag=0
         i3=3; if xlinelen<25 then i3=1

         indent=indent+indent3
     end

      when wordpos(t2,'/UL /DL /OL /MENU /DIR /TL ')>0 then do
         IW=WORDS(LISTTYPES)
         LASTT=WORD(LISTTYPES,IW)

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
             if iw2=1 then
                olcnts=''
             else
                olcnts=delword(olcnts,iw2)
         end
         if iw=1 then                 /* fix list of UL OL */
                listtypes=''
         else
               listtypes=delword(listtypes,iw)
         indent=max(0,indent-mindent3)
         if t2='/DL' & ddon=1 then indent=max(0,indent-mindent3)

         call sendout ' '

      end               /* /ul etc */

      when t2='LI'  then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         aflag=figflag(listtypes)       /* the flag for this type */
         thispara=''
         call sendout ' '
      end /* do */

      when t2='DD' | t2='DT' then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         goon=words(listtypes)
         if word(listtypes,goon)<>'DL' then do
              SAY ' '
              indent=0 ; olcnts='' ; listtypes=''
              call do_display_error 1, "Warning: DD or DT not expected in  list " , "UNEXPECTED_DD|DT"
         end
         aflag=' '
         if t2='DT' then do
             if ddon=1 then indent=max(0,indent-mindent3)
             ddon=0
         end
         if t2='DD' then do
              indent=indent+indent3
              ddon=1
         end
         thispara=''
         call sendout ' '
      end /* do */

      when t2='SELECT' then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         selsize=get_elem_val(t2a,'SIZE')
         if datatype(selsize)<>"NUM" | showallopts=1 then
             listtypes=listtypes' 't2
         else
             listtypes=listtypes' 't2||(selsize+1)
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
              iterate
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
              foo=sendout(thispara,ispre,indent+1,aflag,xlinelen)
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
              iterate
         end /* do */

/* legit list .. WITHIN SIZE?*/
         if right(lastt,1)<>'0' then
            foo=sendout(thispara,ispre,indent+1,aflag,xlinelen)

         thispara=' '         ; aflag=0
         if iw=1 then                 /* fix list of UL OL */
                listtypes=''
         else
               listtypes=delword(listtypes,iw)

         indent=max(0,indent-1)

         ijm=max(1,xlinelen-(indent+rightindent+4))

         ijm=min(ijm,14)
         if  lineart>=0 then
                foo3=d2c(192)||copies(d2c(196),ijm) /*||d2c(217) */
         else
                foo3='\'||copies('-',ijm)   /* ||'/' */
         foo=sendout(foo3,0,indent,,xlinelen)
      end



      when t2='BR' then do
         foo=sendout(thispara,ispre,indent,aflag,xlinelen)
         thispara='';aflag=0
      end /* do */

/* paragraph modifiers */
       when t2='A' then  do
             if pos('NAME=',translate(t2a))=0 then do
                anchoron2=0
                if anchoron=1 then do           /* warning */
                    call do_display_error 0,"Warning: unclosed <A> ", "UNCLOSED_<A>"
                    anchoron2=1                /* assume we are preceded by a </a> */ 
                end /* do */
                anchoron=1 ;anchoron1=1 
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
          if t1<>' ' then thispara=' 'thispara

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
          if atype='TEXT' then do
               av2=get_elem_val(t2a,'SIZE')
               if av2='' then av2=get_elem_val(t2a,'MAXLENGTH')
               if av2='' then av2=4
               atextmark=textmark1||copies(textmark,av2)||textmark2
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


/*************/
/* display error? */
do_display_error:
parse arg serious,amess,err2
if display_errors=0 then return 1       /* write nothing */

say amess               /* write to screen */

if display_errors=1 & serious<>1 then return 1  /* do not record to file */
if display_errors=3 then errflag=errorflag||err2
ioo=sendout(eRRflag' 'thispara,ispre,indent,aflag,xlinelen)
say " "
thispara=' ' ; aflag=0
return 1


/***************************/
/* say help */
sayhelp:
say ''
say "          "cy_ye||copies('/',25)||copies('\',25)|| normal
say "                    "bold"HTML_TXT: An HTML to text convert"normal
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
say cy_YE " ... hit ENTER key for more " NORMAL
parse pull xx
say " ";say " " ; say " " ; say " "; say " "; say " "; 
say bold" Usage Hints: "normal
say " "
SAY " * "reverse"Quick file list:"normal" enter "bold"/DIR file.ext"normal" (for example: "bold"/DIR *.HTM /p"normal
say " "
SAY " * "reverse"To change a parameter:"normal" enter "bold"/VAR var1=val1"normal" (for example: "bold"/VAR lineart=0 "normal
say " "
SAY " * "reverse"Command line mode:"normal" Specify input (html) and output (text) file"
say "         "bold"Example: "normal"D:\>HTM_TXT2 foo.htm foo.txt "
say " "
say "    ... or, to modify the default parameters, add "bold" /VAR var1=val1 ; var2=val2  "normal
say "         "bold"Example: "normal"D:\>HTM_TXT2 foo.htm foo.txt /VAR lineart=0 ; flagul=* $ ! "
say " "
say " * "bold"You can change the default parameters by editing HTM_TXT2.CMD "
say " "
say cy_ye " *  This is the less complete, but  quicker, version of HTML_TXT"normal
say " "
say "            "cy_ye||copies('\',25)||copies('/',25)|| normal
say " " ; say " "

return 1


