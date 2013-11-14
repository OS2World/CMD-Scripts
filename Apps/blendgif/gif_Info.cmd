/* 25 Feb 1999. Daniel Hellerstein, danielh@econ.ag.gov */
/* This is a simple utility for examining the structure of a GIF file*/
/* to use it, you MUST have the REXXLIB and RXGDUTIL dlls installed */
/* It uses the PARSEGIF.RXX prodedure library */
/* For info on the PARSEGIF.RXX procedcure library, please go to
    http://www.srehttp.org/apps/gif_info/ */

parse arg gif_File

if gif_file='?' | gif_file='??' then do
  bold='' ; normal='' ; reverse=''; cy_ye=''
    say "GIF_INFO will display the block structure of a GIF file."
    say "Usage: GIF_INFO filename.ext "
    say "or, just enter GIF_INFO, and answer the prompts "
    say
    if gif_File='??' then call shownotes
    exit
end


call initit

ask1:
if gif_file='' then do
   call charout,"Name of .GIF file (? for file listing)? "
   pull gif_file
end /* do */
if gif_File='' then exit
gif_file=strip(gif_file)

if left(gif_file,2)="??" then do
   call shownotes
   gif_file=''
   signal ask1
end /* do */

if left(gif_file,1)="?" then do
   parse var aa . thisdir
   if thisdir="" then    thisdir=directory()
    say 
    say  ' >> List of .GIF files in: ' thisdir 
    do while queued()>0
    pull .
    end /* do */
   '@DIR /b  '||strip(thisdir,'t','\')'\*.gif | rxqueue'
    foo=show_dir_queue('.GIF')
    say
    say "Hint: enter ?? to display some program notes "
    gif_file=''
    signal ask1
end


if pos(".",gif_File)=0 then gif_file=gif_file'.gif'
fsize=stream(gif_file,'c','query size')
if fsize="" | fsize=0 then do
   say "No such file: " gif_File
   exit
end /* do */
foo=stream(gif_file,'c','open read')
gifimage=charin(gif_file,1,fsize)
foo=stream(gif_File,'c','close')
nblocks=show_gifcontents(gifimage,1)
exit


/****************/
shownotes:
say
 say cy_ye"GIF_INFO Notes:"normal
say bold " *"normal" The following abbreviations are used for block names:"
    say "    LSD: Logical Screen Descriptor "
    say "    GCE: Graphical Control Extension "
    say "    IMG: Image Descriptor "
    say "    CMT: Comment Block "
    say "    APE: Application Extension"
    say "    PTE: Plain Text Extension "
    say "    TRM: Terminator "
say bold " *"normal' IMG blocks contain image data (pixel values) and can '
say  "     contain a local color table (both of which you can examine)"
say bold " *"normal' LSD blocks contain a global color table (which you can examime)'
say

 return 1


/***************/
/* initilaize some stuff */
initit:

foo=rxfuncquery('sysloadfuncs')     /* load rexxutil library */
if foo=1 then do
  call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  call SysLoadFuncs
end

foo=rxfuncquery('rxgdloadfuncs')
if foo=1 then do
  Call RxFuncAdd 'RxgdLoadFuncs', 'RXGDUTIL', 'RxgdLoadFuncs'
  Call RxgdLoadFuncs
end
foo=rxfuncquery('rxgdloadfuncs')
if foo=1 then do
   if verb="" then do
        STRING "Sorry: RXGDUTIL.DLL is not available! Did you copy it to your LIBPATH? "
        return ' '
   end /* do */
   call dosay 'Sorry: RXGDUTIL.DLL is not available! Did you copy it to your LIBPATH? '
   exit
end /* do */


/* Load up advanced REXX functions */
foo=rxfuncquery('rexxlibregister')
if foo=1 then do
 call rxfuncadd 'rexxlibregister','rexxlib', 'rexxlibregister'
 call rexxlibregister
end
foo=rxfuncquery('rexxlibregister')
if foo=1 then do
    say "Sorry: REXXLIB is not available. Did you copy it to your LIBPATH?"
    exit
end /* do */

ansion=checkansi()
if ansion=1 then do
     aesc='1B'x
     cy_ye=aesc||'[37;46;m'
     cyanon=cy_ye
     normal=aesc||'[0;m'
     bold=aesc||'[1;m'
     re_wh=aesc||'[31;47;m'
     reverse=aesc||'[7;m'
 end
 else do
     say " Warning: Could not detect ANSI....  Install will look ugly ! "
      cy_ye="" ; normal="" ; bold="" ;re_wh="" ;
     reverse=""
end  /* Do */

return 1

/* -------------------- */
/* choose between several alternatives (by default,a yes or no ), 
return 1 if yes (or 0,1,2 for chosen altenative ) */

yesno:procedure expose normal reverse bold cy_ye
parse arg amessage , altans,def,arrowok
aynn=' '
if def='' then 
 defans=''
else
 defans=translate(left(strip(def),1))
if altans='' then altans='No Yes'

w.0=words(altans)
do iw0=1 to w.0
     w.iw0=strip(word(altans,iw0))
     a.iw0=translate(left(w.iw0,1))
     aa.iw0=substr(w.iw0,2)
     aynn=aynn||bold
     if  a.iw0=defans then aynn=aynn||cy_ye
     aynn=aynn||a.iw0||normal||aa.iw0
     if iw0<w.0 then aynn=aynn'|'
end
if arrowok=1 then aynn=aynn||' [UP]'
do forever
 foo1=normal||reverse||amessage||normal||aynn||' 'normal
 call charout,foo1
 anans=translate(sysgetkey('echo'))
 ianans=c2d(anans)
 if anans='' | ianans=13 | ianans=10 then  anans=defans

 if arrowok=1 & ianans=0 then do
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



/*********/
/* show stuff in queue as a list */
show_dir_queue:procedure 
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
          pull aa
          if pos(lookfor,aa)=0 then iterate
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




/************************/
/* Display info from a gif file. A list of the logical "blocks"
   comprising a gif file is displayed, followed by relevant
   information extracted from each block.

 This is adapted from the GIFVU.RXX procedure that comes with BLENDGIF.


Usage:
  status=show_gifcontents(gifimage,dopause)
 
where:
  gifimage: the contents of a gif file; say as read using
            gifimage=charin(gif_file,1,chars(gif_file))
  DOPause : If 1, then pause (wait for ENTER key) after displaying
            info on each block -- and give user chance to
            display more details.
and 
  status = number of blocks in the gif file

For example, the following program will display the structure of
a user supplied gif file:


*/
show_gifcontents:PROCEDURE expose bold normal cy_ye reverse
parse arg gifcontents,dopause
talist=read_gif_block(gifcontents,1,'',1)
say bold' The  "block" structure of the gif file is: 'normal
call charout,"  "cy_ye":"normal' '
do mm=1 to words(talist)
     call charout,word(talist,mm)' '
     if (mm//15=0) then do
        say 
        call charout,"  "cy_ye":"normal' '
     end /* do */
end /* do */
if (words(talist)//15)<>0 then say
say
cts.=0
ti=words(talist)
do iJmm=1 to ti
   ainfo=strip(word(talist,iJmm))
   aa='!'ainfo
   ii=cts.aa+1
   cts.aa=ii
   ab=read_gif_block(gifcontents,ii,ainfo,1)
   say reverse"Block "normal||' 'bold||ijmm||normal" (of "ti"): " ainfo ii ", length = "||length(ab)
   select
      when ainfo='CMT' then do
         aa=read_comment_block(ab)
         say "  comment= " aa
      end
      when ainfo='ACE' then do
         niter=read_animation_block(ab)
         parse var niter appname','niter
         if appname="NETSCAPE" then do
             say "  NETSCAPE:  # iters = " niter
          end
          else do
             say "  Appname= " appname
          end
      end /* do */

      when ainfo='IMG' then do
         ct_name='CT.'
         img_name='IMG.'
         img.=0
         ct.=0
         stuff=read_image_block(ab,0)           /* 0= do NOT looad IMG. matrix */
         parse var stuff lpos tpos width height lct lctsize interl sort ',' imgdata

         say "  Position (l,t): " lpos tpos
         say "  Size (w,h): " width height
         if lct=1 then 
                say '  Local color with ' lctsize '('ct.0 ') colors.'
         else
                say "  No local ct (though ctsize = "lctsize
         say "  Interlace, sort flags: " interl ',' sort
         say "  Size of compressed image: " length(imgdata)
      end /* do */

      when ainfo='LSD' then do
          ct_name='CT.'
          stuff=read_lsd_block(ab)
          parse var stuff width height gcflag gcsize colres sort bkgcolor aspect
          say "  Image width,height = " width height
          say "  Color resolution, aspect, bkg color " colres aspect bkgcolor 
          if gcflag=1 then
              say "  " gcsize '(' ct.0 ") colors in global color table (sorted="sort
          else
              say "   No global ct (though size = " gcsize

      end /* do */

      when ainfo='GCE' then do
        stuff=read_gce_block(ab)
        parse var stuff disposal usrinflag tcflag delay tcindex
        say "  Disposal, user input flag, delay : " disposal usrinflag delay
        say "  Transparency flag, index : "tcflag',' tcindex

      end /* do */
      when ainfo='TRM' then do
         iterate
     end
     when  ainfo='00' then do  /* junk, remove */
        say " found and ignoring 00  block "
       iterate
     end
     otherwise say " unknown extension "
   end  /* select */
   if dopause=1 then do
       if ainfo="IMG" | ainfo="LSD" then
          aa=yesno(normal"      ..... continue, exit, details?  ","Continue Exit Details ","Continue")
       else
          aa=yesno(normal"      ..... continue, exit, details?  ","Continue Exit ","Continue")
       if aa=0 then do
          say
          iterate
       end /* do */
       if aa=1 then exit
       if aa=2 then do
         select
           when  ainfo="IMG" then do
             do forever
              aa=yesno(normal '    'reverse'Display local Color table, Pixels, Next block? ','ColorTable Pixels Next','NEXT')
              if aa=0 then do
                   if lct=0 then
                         say bold" No local color table specified "
                  else
                    call show_ctable
              end /* do */
              if aa=1 then call show_pixel_values
              if aa=2 then leave
             end
           end
           When AINFO='LSD' then do
              aa=yesno(normal '    'reverse'Display global color table?',,'YES')
              if aa=1 then call show_ctable
           end
           otherwise do
                say "No extra details available .... "
           end
         end                 /* SELECT */
       end               /* DETAILS */
   end                    /* dopause */
end                      /* blocks */

return ti


/**********/
/* ask for an integer (min value of minval */
ask_integer:procedure expose bold normal
parse arg  amess,defval,minval
if minval='' then minval=0
if amess=''  then amess=' ? '
if defval='' then defval=minval

do forever
  call  charout,bold||amess||normal||'('||defval||'):'
  pull aa
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




/**************/
/* show color table (in ct. stem variable */
show_ctable:procedure expose ct. bold reverse cy_ye normal

say
say "# of colors=" ct.0', displayed with their Red, Green, Blue values:'
mm=0
nlines=0
do forever
   oog=0
   if mm>ct.0-1 then leave
   oog=1
   nlines=nlines+1
   if nlines>20  then do
       foo=yesno(normal'  ... more color table values?:',,'Y')
       if foo=0 then leave
       nlines=0
   end /* do */

   call charout, left("     " reverse||mm||normal": " ct.!r.mm' 'ct.!g.mm' 'ct.!b.mm,34)

   mm=mm+1
   if mm>ct.0-1 then leave
   call charout, left(" | " reverse||mm||normal": " ct.!r.mm' 'ct.!g.mm' 'ct.!b.mm,34)
   
   mm=mm+1
   if mm>ct.0-1 then leave
   call charout,lefT( " | " reverse||mm||normal": " ct.!r.mm' 'ct.!g.mm' 'ct.!b.mm,34)
   mm=mm+1

   say
end /* do */
say
if oog=1 then say
return 1

/***********/
/* show pixel values */
show_pixel_values:procedure  expose img. bold reverse cy_ye normal ab
img_name='IMG.' ; ct_name='act.'

img.=0
stuff=read_image_block(ab,1)

nrows=img.!rows ; ncols=img.!cols
irow=0 ; icol=0
do forever
irow0=ask_integer("Enter row (0 to "nrows'):',irow,0)
if irow0>nrows-1 then iterate
icol0=ask_integer("Enter start column (0 to "ncols'):',icol,0)
if icol0>ncols-1 then iterate
icol=icol0 ; irow=irow0
i1=icol
i2=min(ncols-1,icol+10-1)

icol=i2+1         /* for next default */

call charout, " Row "irow', cols 'i1' - 'i2' = 'bold
do oof=i1 to i2
   apix=c2d(substr(img.irow,oof+1,1))
   call charout,apix' '
end
say  normal
foo=yesno(normal'     dispay more pixel values? ',,'Y')
if foo=0 then do
   say
   return 1
end /* do */
end

/************************************************************
                            PARSEGIF
            Procedures to extract information from a  gif file.

Notes: 
 * In the descriptions below:
   > ABLOCK is an actual string of bytes; as pulled from gif file,
       or suitable for writing to a gif file.
   > CT_NAME is a string containing the name of the "matrix of 
       color table values" stem variable.
       You MUST set it's value before calling procedures that
       use it.  For example:   ct_name='MY_CT.'
       (note that you MUST include the . at the end of the stem name)
   > STUFF is a space or comma delimited list of variables returned
       by one of these procedures.
   > IMG_NAME is a string containing the name of a "matrix of pixels"
       stem avariable.
       You MUST set it's value before calling procedures that
       use it.  For example:   imgt_name='IMG_NAME.'
       (note that you MUST include the . at the end of the stem name)

 *  Use read_gif_block to read  various "blocks" from a GIF file, 
    these blocks may then be used as input to the other 
    For example: 
                 ablock=read_gif_block(a_gif_file,1,'LSD')
                 ablock=read_gif_block(a_gif_file,3,"IMG")
                 ablock=read_gif_block(gifstring,imgnum,'GCE',1)
    
 * Several of these procedures work with color tables. Color tables
   are stored in stem variables, which have the structure:
        ct.0 = # of colors
        ct.!r.n = red value for color n
        ct.!g.n = green value for color n
        ct.!b.n = blue value for color n
    where n =0 ... (ctable.0-1), and ct is the "color table name".
   
    Prior to calling a color table using/returning procedure,
    the "color table name" must be defined. 
    To do this, just set:
         CT_NAME='a_color_table_name.'
    For example:
         CT_NAME='MY_CT.'
         MY_CT.=0
    Note that you MUST include the . after the actual name. Use of MY_CT.=0
    (to set the default value of the MY_CT. "tail" values) is strictly optional.
    
    Example:
         CT_NAME='IMG3_CT.'
         IMG_NAME='IMG_PIX.'
         ablock=read_gif_block(gif_file,3,'IMG')
         stuff=READ_IMAGE_BLOCK(ablock,0)
         (the IMG3_CT. stem variable will contain the local color table
          for the 3rd image of gif_file, assuming one exists).

 *  Several of these procedures work with a matrix of pixel values.
    As with color tables, these are stored in stem variables, which
    requires one to assign a value to the IMG_NAME variable. For
    example:
          IMG_NAME='img1.'
          img1.=0
    Note that you MUST include the . after the actual name. 

   The structure of this stem variable is (assuming a stem name of img1):
      img1.!rows = # rows
      img1.!cols = # cols
   and each row of the image is in:
      img1.0
        ...
      img1.nrr
   where:
      nrr=# rows-1  
      and each "row" is a string of length img1.!cols.  
          Each character in this string corresponds (is the d2c) for
          a pixel value.  
    Thus, to get the pixel value of the 5 column of the 10th row:
                avalue=c2d(substr(img1.10,5,1)) 
 
List of Procedures:
 ablock=READ_GIF_BLOCK(giffile,imgnum,infotype,is_string)
 ablock=MAKE_ANIMATION_BLOCK(iter) 
  niter=READ_ANIMATION_BLOCK(ablock)
 ablock=MAKE_COMMENT_BLOCK(a_comment)
  stuff=READ_COMMENT_BLOCK(ablock)
 ablock=MAKE_GCE_BLOCK(tcflag,tcindex,delay,disposal,useinlag)
  stuff=READ_GCE_BLOCK(ablock)
 ablock=MAKE_IMAGE_BLOCK(lpos,tpos,wid,hei,lct,lctsize,inter,sort,imgdata)
  stuff=READ_IMAGE_BLOCK(ablock,to_matrix)
 ablock=MAKE_LSD_BLOCK(width,height,gcflag,colres,sort,bkgcolor,aspect,gcsize)
  stuff=READ_LSD_BLOCK(ablock)
 ablock=MAKE_PTE_BLOCK(tgleft,tgtop,tgwidth,tgheight,ccwidth,ccheight,tfore,tback,amess)
  stuff=READ_PTE_BLOCK(ablock)
 ablock=MAKE_TERMINATOR_BLOCK()


Description of procedures:

ablock=read_gif_block(giffile,imgnum,infotype,is_string)
    Pull a "block" from a gif file.

   Where:
        giffile : A file name OR a string containing the contents of a gif file
        nth  : Get block associated with this image, comment, or app block.
        infotype : Type of block to get
        is_string: If 1, then GIFFILE argument is a string, otherwise it's
                   a file name (which read_gif_block will read)
   Values of infotype:
        IMG  -- get the nth "image descriptor" of the imgnum image.
                To examine: use READ_IMG_BLOCK
        CMT  -- get the nth "comment extension". 
                To examine: use READ_COMMENT_BLOCK
        ACE  -- get the "application control extension" for the nth application.
                To examine: use READ_ANIMATION_BLOCK  -- but this is only
                useful if it's an "animation" block.
        LSD  -- get the "logical control descriptor", including the "GIF89a"
                (or "GIF87a") header (nth is ignored -- there is only one
                LSD per file). Note that the LSD is REQUIRED -- all gif files
                must have start with an LSD. 
                To examine: use  READ_LSD_BLOCK.
        GCE  -- get the nth "graphic control extension". 
                To examine: use READ_GCE_BLOCK.
        PTE --  get the nth "plain text extension".
        LST  -- return a spaced delimited list of INFOTYPE codes.

  Note that LST is different -- it returns a string. 
  Several additional codes may appear in this "LST" of blocks.
       00 = a '00'x block (a harmless error)
      TRM = terminator -- should ALWAYS be the last code in LST

  Note: if an error occurs, ablock will be a string starting with "ERROR",
        and followed by a short error message.

ablock=MAKE_ANIMATION_BLOCK(iter) 
      Create an "animation" applications block.

      Where:
          iter= # of iterations


stuff=READ_ANIMATION_BLOCK(ablock(
     Extract # iterations from a "netscape" animation applications 
     control extension (ACE) block.

     You can parse stuff with:
        parse var stuff appname','niters
     Where
        appname = name of applicaton block
        niters  = if "NETSCAPE" is the appname, then this is the # of iterations
                  Otherwise, niters=''                                                        

ablock=MAKE_COMMENT_BLOCK(a_comment)
   Make a comment block.

   Where:
        a_comment = A string containing your comment. Can be any length,
                    and contain CRLFs.

stuff=READ_COMMENT_BLOCK(ablock)
   Extract comment from a comment block.

   The comment is the only item returned in stuff.

ablock=MAKE_GCE_BLOCK(tcflag,tcindex,delay,disposal,useinlag)
   Make a "graphics control extension" block

   Where:
        tcflag  = transparent color index flag. If not 1, transparent
                  color still written (Tcindex), but will be ignored by
                  image dipslay programs.
        tcindex = index of the transparent color.
        delay = Delay time (1/100 ths seconds) -- wait this time AFTER
                displaying image
        dispoal = Disposal method (after delay is over, or userinput taken)
                    0=no action, 1=retain image
                    2=set to background  3=restore to previous
        useinflag = User input flag (1=yes)

stuff=READ_GCE_BLOCK(ablock)
  Obtain information from a graphics control extension block.
 
  To get the actual variables, use:
     parse var stuff  disposal usrinflag tcflag delay tcindex

  Where the variables are as defined in MAKE_GCE_BLOCK.

ablock=MAKE_IMAGE_BLOCK(lpos,tpos,wid,hei,lct,lctsize,inter,sort,imgdata)
    Create an "image descriptor" box.

    Where:
        lpos = column number of the left edge of the image (wrt to
               logical screen)
        tpos = row number of the right edge of the image 
        wid= image width in pixels
        hei= image height in pixels
        lct = local color table flag -- set to 1 if a color table 
              to create a local color table
              If LCT=1, then you must "setup the ct_name color table"
              before calling MAKE_IMAGE_BLOCK
      lctsize= size of local color table. if no specified, ct_name.0 is used.
                If LCT=0, lctsize will still be written (even though
                no color table is written). This is sort of pointless,
                but does seem to be a sop.
         inter = interlace flag 
          sort = if 1, indicates that the color table is sorted, with most
                 used color at top. 
      imgdata= If specifed, this should contain:
                   the actual lzw-compressed image data, (including the 
                   "lzw" starting byte)
               If not specified, or if equal to 0, then
                    MAKE_IMAGE_BLOCK will use the contents of the stem variable
                    declared by the IMG_NAME variable (see description above)
                    
    Note: when using a stem variable as the contents of the gif
          image (when imgdata=0), the !cols and !rows "tails" will
          NOT be used -- instead, the width and height variables (specified
          in the argument list) are used. 
          Of course, one would typically make sure that these were equal...

stuff=READ_IMAGE_BLOCK(ablock,to_matrix)
    Pull information out of an "image descriptor" block

    Where:
       ablock =an image descriptor block; say as retrieved with read_gif_block
       tempfile =  If missing or 0, then
                     ignore
                   If 1, then  
                      write the pixel values of the image to "IMG_NAME"
                      stem variable (see the introductory notes for details).
                      A temporary file, with a name like $TMPnnnn.TMP, 
                      will be temporarily created.
                   If a file name, then
                      Same as 1, but use this filename (instead of a
                      $TMPnnnn.TMP file name) for the temporary file.
              
    The actual information is then obtained by using:
         parse var stuff lpos tpos width hei lct interl sort ',' imgdata
        (see MAKE_IMAGE_BLOCK for a description of these variables).
     and (if to_matrix is appropriately specified)
        by examining the stem variable named by IMG_NAME.

    Notes:
         * be SURE to include a ',' before the imgdata (in the parse)
         * if there is any chance the image block includes a local color
           table, be sure to set the value of the CT_NAME variable
           before calling READ_IMAGE_BLOCK
         * if you specify to_matrix, be sure to set the value of the
           IMG_NAME variable before calling READ_IMAGE_BLOCK.


ablock=MAKE_LSD_BLOCK(width,height,gcflag,colres,sort,bkgcolor,aspect,gcsize)
      Make a logical screen descriptor  block -- including the "GIF89a"
      header (the first 6 six characters in a gif file).

      Where:
          width = "logical screen" width (in pixels)
          height= "logical screen" height (in pixels)
          gcflag= set to 1 if a global color table is to be created.
                 If GCFLAG=1, then you must "setup the ct_name color table"
                 beforecalling MAKE_LSD_BLOCK
          colres=2**(colres+1)= color resolution of image creater(rarely used)
          sort = if 1, indicates that the color table is sorted, with most
                 used color at top. 
          bkgcolor = background color index (rarely used)
          aspect = height to width aspect (rarely used)
          gcsize= size of color table. if no specified, ct_name.0 is used.
                 

stuff=READ_LSD_BLOCK(ablock)
  Pull information from an logical screen descriptor block

    Ablock is an logical screen descriptor block; say as 
    retrieved with read_gif_block.
     
    The actual information is then obtained by using:
        parse var st width height gcflag colres sort bkgcolor aspect

     Where the variables are as defined in MAKE_LSD_BLOCK

ablock=MAKE_PTE_BLOCK(tgleft,tgtop,tgwidth,tgheight,ccwidth,ccheight,tfore,tback,amess)
   Create a "plain text" extensions block

   Where:
        tgleft = pixel column number of left of text grid
        tgtop  = pixel row number of top of text grid
       tgwidth = width of text grid in pixels
      tgheight = height of text grid in pixels
      ccwidth  = width of each cell in pixels
      ccheight = height of each cell in pixels
      tfore    = text foreground color table index (into global color table)
      tback    = text background color table index (into global color table)
       amess   = message string

stuff=READ_PTE_BLOCK(ablock)
   Pull information from a plain text extension block.

   The actual information can be obtained using:
      parse stuff  tgleft tgtop tgwidth tgheight ccwidth ccheight tfore tback ',' ptext
   Where the variables are as defined in MAKE_PTE_BLOCK
        

ablock=MAKE_TERMINATOR_BLOCK()
   Create a "terminator" block.
   No arguments are required (this is simple a constant equal to '3b'x.

  
**********************************************************************/



/*******************/
/* make an image block (note use of img_name and ct_name )
Example: 
  ct_name='ct1.' ; img_name='img1.'
  stuff2=make_image_block(lpos,tpos,wid,hei,lct,lcsize,inter,sort,imgdata)
*/


make_image_block:procedure expose (ct_name) (img_name)

parse arg lpos,tpos,width,height,lctflag,lcsize,interlace,sortflag,imgdata

astuff='2c'x

astuff=astuff||dd2c(lpos,2)
astuff=astuff||dd2c(tpos,2)
astuff=astuff||dd2c(width,2)
astuff=astuff||dd2c(height,2)

/* create a byte containg several flags */

if interlace<>1 then interlace=0
if sortflag<>1 then sortflag=0
if lctflag<>1 then lctflag=0

ct0=value(ct_name'0')
if lcsize='' | datatype(lcsize)<>'NUM' then
   isizect=ct0
else 
   isizect=lcsize

select          /* 3 bit rep of 2**(sizect+1), rounded up */
   when isizect>128 then do 
         sizect='111' ; is2=256 ;end
   when isizect>64  then do
         sizect='110' ; is2=128 ; end 
   when isizect>32  then do 
        sizect='101' ; is2=64 ; end
   when isizect>16  then do 
        sizect='100' ; is2=32 ;end 
   when isizect>8   then do 
        sizect='011' ; is2=16 ; end ;
   when isizect>4   then do
         sizect='010' ; is2=8 ; end
   when isizect>2   then do 
        sizect='001' ; is2=4 ; end
   otherwise do
        sizect='000' ; is2=2 ; end
end

lc=lctflag||interlace||sortflag||'00'||sizect
aa=x2c(b2x(lc))

astuff=astuff||aa

/* add color table info */
if lctflag=1 then do
  lsd=''
  do mm=0 to min(isizect,ct0)-1
     ii=value(ct_name'!r.'mm)
     lsd=lsd||d2c(ii)
     ii=value(ct_name'!g.'mm)
     lsd=lsd||d2c(ii)
     ii=value(ct_name'!b.'mm)
     lsd=lsd||d2c(ii)
   end /* do */
   if isizect<is2 then do   /* pack the color table */
     do isizect+1 to is2
       lsd=lsd||'000000'x
    end /* do */
  end
  astuff=astuff||lsd
end

if imgdata<>'' & imgdata<>'0' then do
  astuff=astuff||imgdata
  return astuff
end

/* else, create lzw comppressed image from img_name stem */

tempname=imgdata

if tempname=1 then do
   usename=systempfilename('$TM1????.TMP')
end
else do
   if pos('?',tempname)>0 then
      usename=systempfilename(tempname)
   else
      usename=TEMPNAME
end

ncols=width
nrows=height
messim=rxgdimagecreate(ncols,nrows)
if messim<2 then do
  say "Error Could not create temporary gif image "
  return ''
end

pxs.=0
do mr=0 to nrows-1              /* FROM STEM ARRAY TO IMAGE */
   alin=value(img_name||mr)
   do mc=0 to ncols-1
     PXS.MC=c2d(substr(alin,mc+1,1))
   end /* do */
   styled=RxgdImageSetStyle(messim, pxs, ncols)  
   rc=RxgdImageLine(messim, 0,mr,ncols-1,mr,styled)
end

DO III=0 TO 255
   FOO=RXGDIMAGECOLORALLOCATE(MESSIM,III,255-III,0)
end /* do */
foo=rxgdimageinterlace(messim,interlace)
foo=rxgdimagegif(messim,usename)
foo=rxgdimagedestroy(messim)

oof=charin(usename,1,chars(usename))
if oof="" then  do
 say "Error retrieving temporary gif file"
 return ""
end
foo=stream(USENAME,'c','close')
foo=sysfiledelete(usename)

OOF2=read_gif_block(OOF,1,'IMG',1)

ct_name='ctmp.'
stuff2=read_image_block(oof2,0)
parse var stuff2 . ',' imgdata
return astuff||imgdata


/*******************/
/* read an image_block

Example:
  ct_name="CT3."
  ct3.=0 ; img_name='img1.'
  ablock=read_gif_block(giffile,1,'IMG')
  stuff=read_image_block(ablock,0)
  parse var stuff leftpos toppos width height lctflag interlaceflag sortflag ','||imgdata
  say " Left top at "leftpos toppos
  say " Width height = " width height
  say " Interlace:" interlaceflag 
  say ' local ct = 'lctflag ' ( sorted = 'sortflag
  if lctflag=1 then do
     say " # colors in lct = " ct3.0 ct3.!r.1 ct3.!g.1 ct3.!b.1
  end
  say " Imgsize = " length(imgdata)

and if tomtx is specified (=1 , or equal to a filename), then also
create the IMG_NAME stem variable "matrix of pixel values"

*/

read_image_block:procedure expose (ct_name) (IMG_NAME)

parse arg ablock,tomtx

il=substr(ablock,2,2)
lpos=c2d(reverse(il))
it=substr(ablock,4,2)
tpos=c2d(reverse(it))
iw=substr(ablock,6,2)
width=c2d(reverse(iw))
ih=substr(ablock,8,2)
height=c2d(reverse(ih))

pf=substr(ablock,10,1)

pf2= x2b(c2x(pf))
lctflag=substr(pf2,1,1)
interlace=substr(pf2,2,1)
sortflag=substr(pf2,3,1)

lctsize=right(pf2,3)
t=right(lctsize,8,0)

lctsize= x2d(b2x(t))

lctsize=2**(lctsize+1)
imgat=11

if lctflag=1 then do
   ith=0
   do m0=1 to (lctsize*3) by 3
      mm=m0+10
      aa=value(ct_name'!r.'ith,c2d(substr(ablock,mm,1)))
      aa=value(ct_name'!g.'ith,c2d(substr(ablock,mm+1,1)))
      aa=value(ct_name'!b.'ith,c2d(substr(ablock,mm+2,1)))
      ith=ith+1
   end
   imgat=mm+1
end

aa=value(ct_name'0',lctsize)

daimage=substr(ablock,imgat)    /* get rest of stuff in image descriptor block */

/* note: color table in exposed stem */
if tomtx="" | tomtx=0 then
   return lpos tpos width height lctflag lctsize interlace sortflag ','||daimage

/* else, create the img_name stem var */

tempname=tomtx

if tempname=1 then do
   usename=systempfilename('$TM2????.TMP')
end
else do
   if pos('?',tempname)>0 then
      usename=systempfilename(tempname)
   else
      usename=tempname
end


/* make the gif file in memory (very simple version) */
aa=MAKE_LSD_BLOCK(width,height,0,7,0,0,,)
aa=aa||ablock||make_terminator_block()

arf=charout(usename,aa,1)
if arf<>0 then do  
   say  "Error writing temporary gif file:" usename
   return 0
end
foo=stream(usename,'c','close')
/* now read with rxgd */
dim= RxgdImageCreateFromGIF(usename)
if dim<=1 then do
  say " Error reading temporary gif file: " usename
  oo=sysfiledelete(usename)
  return 0
end
  
nrows=RxgdImageSY(dim)
ncols=rxgdimageSx(dim)
foo=value(img_name'!ROWS',nrows)
foo=value(img_name'!COLS',ncols)

ndid=0
do ny=0 to nrows-1              /* FROM IMAGE TO STEM ARRAY */
  foo=rxgdimagegetrowpixels(dim,ny,pxels)
  alin=''
  do nx=1 to ncols
     alin=alin||d2c(pxels.nx)
  end
  foo=value(img_name||ny,alin)
end
foo=rxgdimagedestroy(dim)
foo=stream(usename,'c','close')
oo=sysfiledelete(usename)

return lpos tpos width height lctflag lctsize interlace sortflag ','||daimage

exit





/*******************/
/* make a netscape app block, for animated images, with niter iterations */

Example:
  niter=50
  nu_anim_block=make_animation_block(niter) 

*/

make_animation_block:procedure
parse arg niter
if niter="" then niter=0
if niter<0 then niter=0
if niter>65535 then niter=65334

ablock='21ff0b'x
ablock=ablock||'NETSCAPE2.0'
ablock=ablock||'03'x
ablock=ablock||'01'x
aiter=dd2c(niter,2)
ablock=ablock||aiter
ablock=ablock||'00'x
return ablock

/*******************/
/* read a netscape app block, for animated images, with niter iterations 

Example:
 aa=read_animation_block(ablock)

 You can parse aa with:
    parse var aa apname','niter
  
 If apname='NETSCAPE' then niter will be the iteration count.
 Otherwise, niter will = ''
 (that is, if not an animation block, niter='')
*/

read_animation_block:procedure
parse arg ablock

apname=substr(ablock,4,8)
apauth=substr(ablock,12,3)
foo=apname||apauth
if foo<>'NETSCAPE2.0' then return apname
aiter=substr(ablock,17,2)
niter=c2d(reverse(aiter))
return apname','niter




/*******************/
/* create a graphics control extension block.

Example:
  nu_gce_block=make_gce_block(tcflag,tcindex,delay,disposal,userinputflag)

*/

make_gce_block:procedure
parse arg tcflag,tcindex,delay,disposal,userinput

ablk='21f904'x

l3='000'
if disposal='' then disposal=0
ii= x2b(d2x(disposal))
ii=right(ii,8,0)
ii=right(ii,3)
l3=l3||ii

if userinput=1 then
  l3=l3||'1'
else
  l3=l3||'0'

if tcflag<>1 then
   tcflag='0'
else
   tcflag='1'
l3=l3||tcflag

l3a=x2c(b2x(l3))

ablk=ablk||l3a

if delay='' then delay=0
delay=dd2c(delay,2)

if tcindex='' then tcindex=0
tcindex=dd2c(tcindex,1)
ablk=ablk||delay||tcindex||'00'x

return ablk


/*******************/
/* make logical screen descriptor 
Example: (ct2. is a stem containing a color table )
  ct_name='CT2.'
  lsd_block=make_lsd_block(width,height,gcflag,colres,sort,bkgcolor,aspect)

*/

make_lsd_block:procedure expose (ct_name)
parse arg width,height,gcflag,colres,sort,bkgcolor,aspect,gcsize

/* organized as:
 hd= 'GIFxxx' (1-6)
 width = 2 bytes (7-8)
 height=  2 bytes (9-10)
packed = 1 byte (11) -- gcflag (1) colres (3) sort (1) sizect (3)
bkgcolor =1 byte (12)
aspect = 1 byte (13)
colortable = 14 ... 13+ 2**(sizect+1)  bytes (rgbrgbrgb....)
*/

LSD='GIF89a'

A2=dD2C(WIDTH,2)
A3=Dd2C(HEIGHT,2)

lsd=lsd||A2||A3

if gcflag=0 | gcflag='' then
  l3='0'
else
  l3='1'

gcflag=l3

if colres='' then do
  colres='111'
end
else do
  colres=x2b(d2x(colres))
  colres=right(colres,8,0)
  colres=right(colres,3)
end

l3=l3||colres

if sort='' | sort=0 then
    l3=l3||'0'
else
    l3=l3||'1'


ct0=value(ct_name'0')
if gcsize='' | datatype(gcsize)<>'NUM' then
  isizect=ct0
else
  isizect=gcsize
select          /* 3 bit rep of 2**(sizect+1), rounded up */
   when isizect>128 then do 
         sizect='111' ; is2=256 ;end
   when isizect>64  then do
         sizect='110' ; is2=128 ; end 
   when isizect>32  then do 
        sizect='101' ; is2=64 ; end
   when isizect>16  then do 
        sizect='100' ; is2=32 ;end 
   when isizect>8   then do 
        sizect='011' ; is2=16 ; end ;
   when isizect>4   then do
         sizect='010' ; is2=8 ; end
   when isizect>2   then do 
        sizect='001' ; is2=4 ; end
   otherwise do
        sizect='000' ; is2=2 ; end
end
l3=l3||sizect

l3a=x2c(b2x(l3))

lsd=lsd||l3a

if bkgcolor='' then 
   lsd=lsd||'00'x
else
   lsd=lsd||dd2c(bkgcolor,1)

if aspect='' then
   lsd=lsd||d2c(0)
else
   lsd=lsd||dd2c(aspect,1)

/* add color table info */
if gcflag=1 then do
  do mm=0 to isizect-1
    ii=value(ct_name'!r.'mm)
    lsd=lsd||d2c(ii)
    ii=value(ct_name'!g.'mm)
    lsd=lsd||d2c(ii)
    ii=value(ct_name'!b.'mm)
    lsd=lsd||d2c(ii)
  end /* do */
  if isizect<is2 then do
     do kkk=isizect+1 to is2
        lsd=lsd||'000000'x
     end /* do */
  end
end

return lsd

/*******************/
/* make a comment block
Example:
  cmt="this is my comment on "||date()
  nu_cmt_block=make_comment_block(cmt)
*/

make_comment_block:procedure
parse arg acomment
aa='21fe'x
aa=aa||chunkit(acomment)
return aa


/*********/
read_comment_block:procedure
parse arg ain
 iat=2
 lena=length(ain)
 amess=''
 do forever       
    if iat>lena then return ""   /* no block terminator -- error */
    iat=iat+1      /* size of block */
    ii=substr(ain,iat,1) ; ii=c2d(ii)
    if ii=0 then return amess 
    iat=iat+1
    amess=amess||substr(ain,iat,ii)
    iat=iat+ii-1
 end /* do */

/*******************/
/* plain text stuff */
read_pte_block;procedure
parse arg ain

  l1=substr(ain,1,2)
tgleft=c2d(reverse(l1))
  l2=substr(ain,3,2)
tgtop=c2d(reverse(l2))

   l1=substr(ain,5,2)
tgwidth=c2d(reverse(l1))
   l2=substr(ain,7,2)
tgheight=c2d(reverse(l2))

   l1=susbtr(ain,9,1)
 ccwidth=c2d(l1)
   l2=substr(ain,10,1)
 ccheight=c2d(l2)

  l1=substr(ain,11,1)
    tfore=c2d(l1)
  l2=substr(ain,12,1)
    tback=c1d(l2)

lena=length(ain);amess=''
 do forever       
    if iat>lena then return ""   /* no block terminator -- error */
    iat=iat+1      /* size of block */
    ii=substr(ain,iat,1) ; ii=c2d(ii)
    if ii=0 then leave
    iat=iat+1
    amess=amess||substr(ain,iat,ii)
    iat=iat+ii-1
 end /* do */

return  tgleft tgtop tgwidth tgheight ccwidth ccheight tfore tback ','||amess


/*******************/
/* plain text stuff */
make_pte_block;procedure
parse arg tgleft,tgtop,tgwidth,tgheight,ccwidth,ccheight,tfore,tback,amess
 
  ab='2101'x
  ab=ab||d2c(12)
  ab=ab||dd2c(tgleft,2)
  ab=ab||dd2c(tgtop,2)
  ab=ab||dd2c(tgwidth,2)
  ab=ab||dd2c(tgheight,2)
  ab=ab||dd2c(ccwidth,1)
  ab=ab||dd2c(ccheight,1)
  ab=ab||dd2c(tfore,1)
  ab=ab||dd2c(tback,1)
  ab=ab||chunkit(amess)

  return ab

/*************/
/* convert integer to character, using nb bytes */
dd2c:procedure
parse arg ival,nb
if nb='' then nb=2
a1=reverse(d2c(ival))
if length(a1)<nb then do 
   a1=a1||copies('00'x,nb-length(a1))
end /* do */
return left(a1,nb)


/****************/
/* convert character to interger */

/*******************/

/* make a terminator block -- no arguments needed
Example:
  my_trm_block=make_terminator_block()

*/
make_terminator_block:procedure

return '3b'x


/*********************/
/* parse a graphics control extension block (gce). 
  Note: Use read_gif_block to get the gce.

Example:
  imgnum=1
  ablock=read_gif_block(giffile,imgnum,'GCE')
  stu=read_gce_block(ablock)
  parse var stu disposal userinputflag tcflag delay tcindex
  say " disposal =  " disposal
  say " userinput flag = " userinputflag
  say " transparent color flag = " tcflag
  say " Delay = " delay
  say " transparent color index = " tcindex

*/

read_gce_block:procedure
parse arg ablock

l3=substr(ablock,4,1)
l3=x2b(c2x(l3))
reserved=left(l3,3)
disposal=right(substr(l3,4,3),8,0)
disposal=x2d(b2x(disposal))
userinputflag=substr(l3,7,1)
tcflag=substr(l3,8,1)

delay=c2d(reverse(substr(ablock,5,2)))

tcindex=c2d(substr(ablock,7,1))

return  disposal userinputflag tcflag delay tcindex


/*****************/
/* read lsd (including global color table), from string containing 
   logical screen descriptor (lsd)
   Note: use read_gif_block to get the lsd

Example of use:
  ct2.=0
  ct_name='CT2.'
  st=read_lsd_block(gifcontents)
  parse var st width height gcflag colres sort bkgcolor aspect
  SAY "  # COLORS :" CT2.0
  say " width " width
  say " height " height
  say " gcflag " gcflag
  say " colres " colres
  say " sort " sort
  say " bkgcolor " bkgcolor
  say " aspect " ASPECT
  say " # colors = " ct_name.0 
  do mm=0 to ct_name.0-1
     say " Color " mm " ct_name.!r.mm ct_name.!g.mm ct_name.!b.mm
  end 

*/

read_lsd_block:procedure expose (ct_name)
parse arg ain

/* organized as:
 hd= 'GIFxxx' (1-6)
 width = 2 bytes (7-8)
 height=  2 bytes (9-10)
 packed = 1 byte (11) -- gcflag (1) colres (3) sort (1) sizect (3)
 bkgcolor =1 byte (12)
 aspect = 1 byte (13)
 colortable = 14 ... 13+ 2**(sizect+1)  bytes (rgbrgbrgb....)
*/

gifver=left(ain,6)

if abbrev(translate(gifver),'GIF8')=0 then do
  return 'ERROR bad gif identifier: ' gifver
end

l1=substr(ain,7,2)
width=c2d(reverse(l1))
l2=substr(ain,9,2)
height=c2d(reverse(l2))

l3=substr(ain,11,1)  /* packed fields, used below */

bkg_color=c2d(substr(ain,12,1))
aspect=c2d(substr(ain,13,1))

ctable0=x2b(c2x(l3))

global_color_flag=left(ctable0,1)

colres=substr(ctable0,2,3)
colres=right(colres,8,0)
colres=x2d(b2x(colres))

sort=substr(ctable0,5,1)
ct1=right(ctable0,3)

ct1=right(ct1,8,0)
ct1=x2d(b2x(ct1))
numcolors=2**(ct1+1)

gcolortable=''
if global_color_flag=1 then do
   dcolortable=substr(ain,14,3*numcolors)
   ith=0
   do mm=1 to (numcolors*3) by 3
      aa=value(ct_name'!r.'ith,c2d(substr(dcolortable,mm,1)))
      aa=value(ct_name'!g.'ith,c2d(substr(dcolortable,mm+1,1)))
      aa=value(ct_name'!b.'ith,c2d(substr(dcolortable,mm+2,1)))
      ith=ith+1
   end
end
aa=value(ct_name'0',numcolors)
return  width height global_color_flag numcolors colres sort bkg_color aspect


/**************************
read_gif_block is called as:

     stuff=read_gif_block(gif_file,imgnum,infotype,is_string)

Parameters:

    GIF_FILE: Required. A fully qualified file name.
                  OR
              The contents of a gif_file (say, as read with 
                  gif_file=charin(afile,1,chars(afile))

         nth: # of image, etc. to get information about. If not specified,
              a value of 1 is assumed.

    infotype: Which type "descriptor block" to read (may be image specific)
              Actually, get the "nth" occurence of this infotype.
              Valid INFOTYPES are: LSD (nth will be ignored), GCE, IMG, PTE
              ACE, and CMT

    is_string: if 1,then gif_file is the "string" containing a gif file,
                otherwise, gif_file is a file name.

Returns:
  A block from the gif file; or a string beginning with ERROR.
  Or, if infotype='', a list ob blocks in the gif_file.

Technical info:  For gif89a specs, please see
                 http://member.aol.com/royalef/gif89a.txt

*/

read_gif_block:procedure
parse  arg afile,nth,infotype,is_string

infotype=translate(infotype)

if nth='' then nth=1

archy='LSD'    /* list of blocks found -- first is ALWAYS LSD block */
chewerr=0     /* flag set when error in chew_data */

/* read gif file ? */
if is_string<>1 then do
 fqn=stream(afile,'c','query exists')
 if fqn='' then do
    if chkerr=0 then return ''
    return 'ERROR no such file: ' afile
 end
 oo=stream(afile,'c','close')
 filesize=chars(afile)
 ain=charin(fqn,1,filesize)
 oo=stream(afile,'c','close')
end
else do         /* string provided */
   ain=afile
end

/* check for proper header */
gifver=left(ain,6)
if abbrev(translate(gifver),'GIF8')=0 then do
  if chkerr=0 then return ''
  return 'ERROR bad gif identifier: ' gifver
end


/* is there a global color table? */
l3=substr(ain,11,1)
ctable0=x2b(c2x(l3))
global_color_flag=left(ctable0,1)
ct1=right(ctable0,3)
ct1=right(ct1,8,0)
ct1=x2d(b2x(ct1))
numcolors=2**(ct1+1)

iat=13          /* 11 bytes used for intro info */

if global_color_flag=1 then do
   iat=iat+(3*numcolors)  /* iat is the Last byte used */
end

if infotype='LSD' then return substr(ain,1,iat)


/* if here, we need top scan file looking for other blocks */

desc.1='2c'x   /*'image' */
desc.2='21'x  /*'extension'*/
desc.3='3b'x   /*trailer' */

ext.1='f9'x ; /*graphic control'*/
ext.2='fe'x ; /*'comment'*/
ext.3='01'x ; /*'plain text'*/
ext.4='ff'x ; /*application'*/

nimgs=0         /* set counters */
ngcs=0
ncmts=0
napps=0
nptxts=0

lengif=length(ain)

do forever              /* ------------ scan the gif file */
iat=iat+1       

if iat>lengif then leave /* end of file contents (should not happen)*/

blockid=substr(ain,iat,1)       /* get next block type */
iat_b=iat               /* iat at beginning of this block */

select

   when blockid='00'x then do  /* ignore this relatively harmless error */
       ares=''
       ARCHY=archy' 00'
   end /* do */

   when blockid=desc.1 then do  /* it's an image */
      nimgs=nimgs+1
      call do_image
      ares=result
      archy=archy' IMG'
      if nimgs=nth  & infotype='IMG' then 
           return substr(ain,iat_b,(1+iat-iat_b))
   end

   when blockid=desc.2 then  do      /* extension */
       iat=iat+1                /* get extention type */
       extype=substr(ain,iat,1)

       select                   /* several types of "extensions */

          when extype=ext.1 then do     /*graphics control */
            ngcs=ngcs+1
            call graphics_control
            ares=result
            archy=archy' GCE'
            if infotype='GCE' & nth=ngcs then 
               return substr(ain,iat_b,(1+iat-iat_b))
          end

          when extype=ext.3  then do    /*plain text */
              nptxts=nptxts+1
              call plain_text  
              ares=result
              archy=archy' PTE'
              if nptxts=nth & infotype='PTE' then       /* check this image */
                    return substr(ain,iat_b,(1+iat-iat_b))
          end /* plain text */

          when extype=ext.2 then do     /*comment */
             ncmts=ncmts+1
             call is_comment
             ares=result
             archy=archy' CMT'
             if ncmts=nth &  infotype='CMT' then
                return substr(ain,iat_b,(1+iat-iat_b))
          end

          when extype=ext.4 then do     /* application */
             napps=napps+1
             call application_block
             ares=result
             archy=archy' ACE'
             if nth=napps & infotype='ACE' then 
                return substr(ain,iat_b,(1+iat-iat_b))
          end /* do */

          otherwise  do
             return 'ERROR Bad extension code: '||c2x(extype)
          end
       end      /* extype select */
   end          /* extention descriptor */

   when blockid=desc.3 then do
      archy=ARCHY' TRM'
      leave      /* terminator -- must be end of real gif stuff */
   end

   otherwise do
      return 'ERROR Bad descriptor code: ' blockid
   end

end  /* select */

if ares<>'' then do     /* ERROR DETECTED */
   if chkerr=0 then return ''
   return 'ERROR 'ares
end

end     /* forever */

/* if here, end of file and either nothing found, or found list of blocks */
if infotype='' then return archy
return ''                       /* blank means " not found " */


/************/
do_image:                             
      l3=substr(ain,iat+9,1)
      ctable0=x2b(c2x(l3))
      lcl_ct_flag=left(ctable0,1)
      t1=right(ctable0,3) ; t1=right(t1,8,0)
      lcl_ct_size=x2d(b2x(t1)) ; lcl_ct_size=2**(lcl_ct_size+1)

      skip=lcl_ct_flag*lcl_ct_size*3
      iat=iat+9+skip    /* iat is now just before the table based image */

/* chew up the data block */
       iat=iat+1        /* skip the lzw bits variable */
       img_data=chew_data()
       if imgdata="" then return 'ERROR Bad Image Data '
       return ""

/*********/
graphics_control:
       iat=iat+6
       term=x2d(c2x(substr(ain,iat,1)))
       if term<>0 then return 'Bad Graphics Control Extension '
return ""

/*********/
application_block:
iat=iat+1
app_blocksize=x2d(c2x(substr(ain,iat,1)))
if app_blocksize<>11 then do
    return 'Bad application block size '
end /* do */

iat=iat+11
app_data=chew_data()
if app_data="" then return 'Bad application block data '

return ""

/***********/
plain_text:
iat=iat+1
pt_data=''
app_blocksize=x2d(c2x(substr(ain,iat,1)))
if ptextblocksize<>12 then do
    return 'Bad Plain Text Block Size '
end /* do */

iat=iat+13
pt_data=chew_data()
if pt_data="" then return 'Bad Plain Text Data '
return ""

/*********/
is_comment:
cmt_data=chew_data()
if chewerr=1 then return 'Bad Comment Data '
return ""

/*********/
chew_data:procedure expose iat ain amess filesize chewerr
parse arg averbose
       chewerr=1
       amess=''
       do forever       /* data blocks */
         if iat>filesize then do
             return ""
         end /* do */
         iat=iat+1      /* size of block */
         ii=substr(ain,iat,1) ; ii=c2d(ii)
         if ii=0 then do 
             leave
         end /* do */
         iat=iat+1
         amess=amess||substr(ain,iat,ii)
         iat=iat+ii-1
       end /* do */
chewerr=0
return amess 

/***********/
/* make a chewable chunk of data */
chunkit:procedure
parse arg astr,klen
if klen='' then klen=250

mkit=''
lenstr=length(astr)
do mm=1 to lenstr by 250 
   iget=min(250,1+lenstr-mm)
   a1=substr(astr,mm,iget)
   a0=d2c(iget)
   mkit=mkit||a0||a1
end
mkit=mkit||'00'x   
return mkit





