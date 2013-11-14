/* 22 May 1999, Daniel Hellerstein (danielh@econ.ag.gov)

                BlendGIF ver 1.15

   BlendGIF is a program to "blend" several gif files into a
   multiple-frame animated gif.  Requires rexxlib.dll, rxgdutil.dll, 
   rexxutil.dll, and rxsocket.

   We recommend setting the BLENDGIF_ROOT paramater below -- all other
   options can be left as is (they are just defaults).  
   In fact,
     a) to run this as a cgi-bin script, BLENDGIF_ROOT  MUST be set.
     b) if run as a stand alone, the "current" directory is used
     c) if run as an sre-http addon, the TEMPFILE_DIR directory is used

*/



/************************ User changable parameters ***********/
     /* It is recommended that you specify the BLENDGIF_ROOT parameter  */
      /* (or understand what happens if you don't specify it!)          */

BLENDGIF_ROOT=''     /* default root directory for INFILEs., and for temporary files */

/*        ----- The following are general parameters ------ */


INPUT_FILE=0        /* a fully qualififed filename, containing 1 option per line */

max_tempfiles=100 /* maximum # of temporary image files to retain */

width1=200        /* user supplied width (only used if resize_mode=2 */
height1=50        /* user supplied height(only used if resize_mode=2 */
resize_mode=1   /* 0=set to size of first image, 1=Set to max of h & w,2=set to specified h&w */

r_back=110      /* r,g,b values for pixel=0 */
g_back=110
b_back=110
             
ct_newlen=200     /* length of combined image color table (max is 255, since 0 is reserved for transp*/

fade_regions=16     /* number of divisions to use when creating fade ct lookup table */


disposal=1        /* disposal type */
ct_make_spec=0       /*0=most frequent colors, 1= some binary search, 2=more search  */
verbose=1         /* 1= verbose output, 0= more quiet */
no_transparent=0  /* if 1, do NOT have image be transparent, 2=intermediate frames not trans */

cycle=0           /* if 1, then repeat frames in reverse to return to image 1;
                      same as setting infile.0=3 and infile.3=infile1 */

iterations=4       /* # of times to iterate display (of all frames */

infile.0=3         /* # of images */
infile.1 ='good.gif'
infile.2 ='better.gif'
infile.3 ='best.gif'
infile.1.!nth=1         /* nth image (if not specified, use first */
infile.2.!nth=1         /* if !nth> number of images, use last image */

outfile='blendgif.gif'      /* name output file (if exists, will be overwritten) */

img_prog='NETSCAPE -l en '  /* program string for displaying images */

shrink_image=0          /* if 1, attempt to use "use prior image" disposal
                           mode to shrink final image size */


/* ----  The following are "default" parameters. They are used if      */
/*         no "image-pair" specific parameters are specified.  -------*/

frames=4         /* # of "frames" between each "file" in the  animation */

stop_after=0     /* stop after this frame, 0 means "no early stop */

anim_type='balloon' /*  ADD BALLOON CURTAIN DISSOLVE FADE MASK */

/* These are used with the "MASK" anim_type: */
mask.0=0                 /* # of mask files, only used if anim_type='MASK' */
MASK.1='FOREVER1.GIF'
MASK.2='FOREVER2.GIF'
MASK.1.!THRESH=0
MASK.2.!THRESH=0


/* These are used with the BALLOON anim_type */
balloon_TYPE=4      /* 1=square, 2=diamond, 3=octagon, 4=circle */
centerx=0.50        /* center of ballon (x=columns, y=rows */
centery=0.45
balloon_push=2     /* 0=overwrite,  1=push image,
                       2=squoosh original image,
                       20=squoosh, vert overwrite, 10=push, vert overwrite 
                       balloon_push is ignored if balloon_type<>4  */


/* These are used with the FADE anim_type */
fade_type=3      /* 0=frequency sort (default), 1=brightness sort, 
                     2=color specific brightness sort, 3=best match,
                     or a string containing a REXX math expression that uses
                     the R G and B variables, to specify a  ct sort;
                     such as: '2*R + G '*/


/* This is used with the CURTAIN anim_type */
CURTAIN_TYPE='T_B'              /* L_R, T_B, or  MIDDLE */
CURTAIN_OVERWRITE="OVERWRITE"    /* CURTAIN, PUSH, or SQUOOSH */

/*This is used with the DISSOLVE anim_type */
dissolve_spec='1'    /* 1= linear dissolve, 
                     or a string containing values between 0 and 100,
                     the thresholds will determined using a curve going 
                     through these values */
                     
frame_delay=50        /* delay between frames, 1/100th seconds */



/* ------------------------------------------------------------------------- 
  The following are "image-pair" specific parameters. 

  They are optional; if you don't specify a particular
  parameter for a particular image pair, the default
  values (set above) will be used.

  To specify a parameter, simply add a ".n" (without the
  quotes) to the end of the parameter name, where "n" is 
  the image pair.  Thus, .2 refers to "the animation frames
  derived from infile.2  and infile.3 ".

  The following parameter can have "image=pair" specific values:
        FRAMES    STOP_AFTER      ANIM_TYPE       BALLOON_TYPE 
        MASK.n     MASK.n.!THRESH  MASK_LIST      BALLOON_PUSH   
        CENTERX    CENTERY         FADE_TYPE
        CURTAIN_TYPE CURTAIN_OVEWRITE  DISSOLVE_SPEC   FRAME_DELAY 

  Examples:
      FRAMES.1=10 
      FRAMES.2=5
      ANIM_TYPE.1='BALLOON'
      BALLOON_TYPE.1=4
      BALLOON_PUS.1=0
      ANIM_TYPE.2="FADE"
      FADE_TYPE.2=1

The following are "image-specific" transformation options. 

They have  NO "default" equivalents.

  The image-specific tranformation parameter are: 
       TRANSFORM.  XMOVE. YMOVE. ZROTATE. YROTATE XROTATE. NUWIDTH.  NUHEIGHT.
  which should be specified using  a tail (a .n) with specifying which
  image to transform. Note that TRANSFORM. is a flag; the other parameters
  are used (for image n) ONLY when TRANSFORM.n=1.

  Examples:
      TRANSFORM.2=1
      NUWIDTH.1=0.7
      NUHEIGHT.1=0.7
      XMOVE.1=0.3
      YMOVE.1=0.2
      ZROTATE.1=10
      BKG_TRANSPARENT.1=1

   Notes: 
      NUWIDTH and NUHEIGHT should be real numbers (always include the 
      decimal point) that scale the images current size.
      XMOVE and YMOVE (also real numbers) specify a move, as a fraction
      of the width and height of the image you are creating (as set by the
      RESIZE_MODE, WIDTH1, and HEIGHT1 parameters).
      ROTATE is in degrees (+ or -).  Or, you can specify a space delimited
      list of three rotations; for the "z-axis", "y-axis", and "x-axis" (the
      "z-axis" comes out of the screen, rotation around the z-axis is the standard
      rotation of a flat image).
      BKG_TRANSPARENT controls the transparency of "background pixels" (values
      used for pixels the transformed image does not cover).  0 means "use
      the R_BACK, G_BACK, and B_BACK colors.  1 means use "transparent",
      2 is a more stringents transparent.


-------------------------------------------------------------------------   */

/******************* end of user changeable parameters ************/



param_list='width1 height1 resize_mode r_back g_back b_back ct_newlen ',
           'fade_regions disposal ct_make_spec verbose no_transparent ',
           ' cycle iterations infile. outfile img_prog  ',
           ' frames frames. stop_after stop_after. anim_type anim_type. ',
           ' mask. balloon_type balloon_type. centerx centerx. centery centery. ',
           ' balloon_push balloon_push. fade_type fade_type. curtain_type curtain_type. ',
           ' curtain_overwrite curtain_overwrite. dissolve_spec dissolve_spec. ',
           ' frame_delay frame_delay. INPUT_FILE_UPLOAD INPUT_FILE SHOWDIR SHOWFILE ',
           ' TRANSFORM.  XMOVE. YMOVE. ZROTATE. YROTATE. XROTATE. ' ,
           ' NUWIDTH.  NUHEIGHT. UPFILE. DOPAIR. SHRINK_IMAGE MASK_LIST. MASK_LIST ' ,
           ' bkg_transparent. upfile. save_tempfile '
param_list=translate(param_list)


parse arg  ddir, tempfile, reqstrg,list,verb ,uri,user, ,
          basedir ,workdir,privset,enmadd,transaction,verbose0, ,
         servername,host_nickname,homedir

   signal on error name erre ; signal on syntax name erre

is_cgi=0                     /* assume it's an sre-http invocation */
upfile.=0                   
mask_list.=0
crlf    ='0d0a'x                        /* constants */
input_file_upload=0
showdir=0
showfile=0
bkg_transparent=0
nuheight.='' ;nuwidth.=''; xmove.=''; ymove.='' ; zrotate.=''
yrotate.='' ; xrotate.=''
img_tempfile=0          /* if 1, then save a temporary image file */

/* check for CGI-BIN call */

if verb="" then do    /* is it cgi-bin? */
   method = value("REQUEST_METHOD",,'os2environment')
   if method="" then do
       is_cgi=2         /* command line invocation */
       v1=ddir
   end
   else do
      is_cgi=1          /* cgibin invocaiton */
      if method='GET' then do
          list=value("QUERY_STRING",,'os2environment')
      end
      else do
         tlen = value("CONTENT_LENGTH",,'os2environment')
         list=charin(,,tlen)
      end /* do */
      if blendgif_root='' then do
          call dosay2 "Blendgif Setup Error: the blendgif_root directory was not specified"
          return 0
      end /* do */
   end
end

/* When here, we know what type of invocation this is */

if is_cgi<2 then do             /* called as sre addon, or cgi-bin */

  amess=' *** Creating a blended/animated GIF'crlf

  if is_cgi=0  then do 
    if  blendgif_root='' then do
      blendgif_root=workdir
      amess=amess||'  BLENDGIF: Installation error-- the BLENDGIF_ROOT directory was not set ('blendgif_root')</pre></body></html>'
      'string 'amess
      exit
    end
    conttype=reqfield('Content-type')  /* sre-http adodn */
  end /* do */

  if is_cgi<>0 then  conttype=value("CONTENT_TYPE",,'os2environment')  /* cgi */

/* Is this a multipart/form-data POST (file uploads) ? */
  if abbrev(upper(conttype),'MULTIPART/FORM-DATA')=1 then do
     nn=read_multipart_data(list,conttype)  /* parse into form_data. */
     do mm=1 to nn
         elist=translate(strip(form_data.!list.mm))
         if wordpos('CONTENT-TYPE',elist)>0 then do  /* check for bad file upload */
             cc='!CONTENT-TYPE'
             if upper(form_data.cc.mm)<>'IMAGE/GIF' then do
                call dosay 'Ignoring upload ('form_data.!FILENAME.mm'): content type not image/gif : 'form_data.cc.mm
                iterate
             end /* do */
             parse var form_data.!filename.mm xx '.' ill
             INFILE.ill=' your 'FORM_DATA.!filename.MM  /* ASSUME FILENAME ENTRY IS AVAILABLE */
         end /* do */
         if wordpos('NAME',elist)>0 then do
            IF FORM_DATA.MM<>'' then DO
                 yof=translate(form_data.!name.mm,'.','$')
                 if valid_parameter(yof,param_list)=0 then do
                     call dosay2 'BlendGIF error. No such parameter (multi-part form): 'yof
                     return 0 
                 end /* do */
                 foo=value(yof,form_data.mm)
            END
         end /* do */
     end                /* doing parts */
  end /* do */
  else do                       /* standard form */
    verbose=verbose0
    if  verb="GET" then do
      parse var uri . '?' list   /* if srefilter addon, get purer version of request string */
    end    /* else use posted list */
    do forever   
       if list='' then leave
       parse var list a1 '&' list
       parse  var a1 a1a '=' a1b
       a1a=translate(strip(decodekeyval(translate(a1a,' ','+'||'09000a0d'x))))
       a1a=translate(a1a,'.','$')
       a1b=strip(decodekeyval(translate(a1b,' ','+'||'09000a0d'x)))
       a1b=translate(a1b,'.','$')               /* since javascript don't like a.b names */
       if a1b='' then iterate                   /* blank entry, ignore */    
       if valid_parameter(a1a,param_list)=0 then do
           call dosay2 'BlendGIF2 error. No such parameter (GET/POST): 'a1a
           return 0 
       end /* do */
       xx=value(a1a,a1b)
    end 
  end           /* enctype of form */
end             /* iscgi 1 */


/*  DETECT a BLENDGIF ? command line invocation */
if is_cgi=2 & v1="?" then do
   say " BlendGif -- blend 2 (or more) gifs into a multi-framed animated gif"
   say " To execute, enter:: "
   say "     BLENDGIF outfile.gif "
   say "        where outfile.gif is the output file to be created."
   say "     you will then be asked for some parameter values."
   say " For the details, see BLENDGIF.DOC"
   exit
end /* do */



/* -- special case: display contents of BLENDGIF_ROOT directory (or relative
      directory */
if showdir<>0 &showdir<>'' then do
   if is_cgi=1 then do
      call dosay "Sorry, image library listing not currently supported under CGI-BIN."
      return 0
   end /* do */

   bdoc='<html><head><title>BlendGIF image-library</title></head><body><h2>The BlendGIF image library</h2>'||crlf
   if pos(':',showdir)>1 then do
      call dosay2 "BlendGIF error: can not specify fully-qualified file name: "showdir
      return 0
   end /* do */
   bb=strip(blendgif_dir) ; bb=translate(blendgif_root,'\','/')
   bb=strip(bb,'t','\')||'\'
   showdir=strip(decodekeyval(showdir))
   showdir=translate(showdir,'\','/'); showdir=strip(showdir,,'\')||'\'
   cc=bb||showdir
   foo=sysfiletree(cc'*.GIF','gots','OF')
   bdoc=bdoc||'<br># of Files Found: 'gots.0||crlf
   if gots.0>0 then do
      bdoc=bdoc||'<ul>'crlf
      do ig=1 to gots.0
         g1=substr(gots.ig,length(bb)+1)
         bdoc=bdoc||'<li> <a href="/blendgif?showfile='g1'">'||translate(g1,'/','\')||'</a>'crlf
      end /* do */
      bdoc=bdoc||'</ul>'crlf
   end /* do */
   bdoc=bdoc||'</body></html>'
   foo=sref_gos('VAR TYPE TEXT/HTML NAME BDOC ', bdoc)
   return '200 '||length(bdoc)
end /* do */

/* Special case: show a file in the BLENDGIF_ROOT directory */
if showfile<>0 &showfile<>'' then do
   if is_cgi=1 then do
      call dosay "Sorry, image display not currently supported under CGI-BIN."
      return 0
   end /* do */
   if pos(':',showdir)>1 then do
      call dosay2 "BlendGIF error: can not specify fully-qualified file name: "showfile
      return 0
   end /* do */
   
   bb=strip(blendgif_dir) ; bb=translate(blendgif_root,'\','/')
   bb=strip(bb,'t','\')||'\'
   showfile=strip(decodekeyval(showfile))
   showfile=translate(showfile,'\','/'); showfile=strip(showfile,,'\')
   cc=bb||showfile
   cc2=stream(cc,'c','query size')
   if (cc2=0 | cc2='') then do
        call dosay2 "BlendGIF error: no such file: "cc
        return 0
   end /* do */
   foo=sref_gos('FILE type image/gif name 'cc)
   return '200 '||cc2
end

/* If here, we will geneerate a gif== to send as multipart form, or
to save as temporary file? */

if is_cgi=0 then do
  if save_tempfile=1 then do
     amess=amess||'0d0a'x||'      (Status messages are displayed, '||crlf||'       after which you can download the image) '||crlf||crlf

     AMESS='<html><head><title>BlendGif</title></head><body><pre>'amess

     foo=sref_multi_send(amess,'text/HTML','1S')
  end
  else do
     amess=amess||'0d0a'x||'      (Status messages are displayed, '||crlf||'       and then the image is automatically loaded ) '||crlf
     foo=sref_multi_send(amess,'text/plain','SS')
  end
end


/*  ----- read an input file? */
call read_input_file
if result=0 then return 0

if is_cgi<2 then do             /* called as sre addon, or cgi-bin */
  call dosay "     :: Number of images used: "infile.0 
end


didp0=0
doinit1: call init1            /* load some dlls */

dop0: nop

if is_cgi=2 then do                     /* command line mode */
   if v1='' then v1='anim'
   outfile=v1
   if pos('.',outfile)=0  then outfile=outfile'.gif'
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
   call set_params0 didp0
   didp0=1
   signal on error name erre ; signal on syntax name erre

   arf= yesno(" Change/view other parameters? ",'NO YES REDO ?')
   if arf=2 then signal dop0
   if arf>0 then  do
      call set_params arf
      if result=2 then signal dop0
   end

  call ask_input_file           /* ask user for input file of blendgif options */

end

call init2            /* set global parameters */

/* read files into memory */
do kmm=1 to infile.0
   infile.kmm=strip(infile.kmm)

   if infile.kmm='.' then do    /* empty screen */
       infile.kmm='1_pixel.gif'
   end

   if datatype(infile.kmm.!nth)="NUM" then mg1=infile.kmm.!nth
   mg1=trunc(mg1)
  if upfile.kmm<>0 then do      /* got an upload */
       call dosay kmm") Reading uploaded file " infile.kmm ', frame # ' mg1
       f1a=upfile.kmm
   end
   else do
      call dosay kmm") Reading " infile.kmm ', frame # ' mg1
      if is_cgi<>2 then do
          if pos(':',infile.kmm)=2  then DO
             call dosay2 "BlendGIF error: absolute filename not allowed: "infile.kmm
             return 0
          end /* do */
          if abbrev(translate(infile.kmm),'HTTP://')=0 then
              infile.kmm=strip(translate(strip(infile.kmm),'\','/'),'l','\')
      end /* do */    
      f1a=read_giffile(infile.kmm ,BLENDGIF_ROOT)
      if f1a=0 then do 
          call dosay2 "Error: GIF not available: "infile.kmm
          return 0
      end 

   end
   if f1a='' then do
      call dosay " Could not read "infile.kmm 
      exit
   end /* do */
    talist=read_gif_block(f1a,1,'',1)
    if abbrev(talist,'ERROR')=1 then do
        call dosay2 "Problem with "infile.kmm " = "||subword(talist,2)
        return 0
    end /* do */

/* 1a) Get LSD and GCE for images */
   ab1=read_gif_block(f1a,1,'LSD',1)               /* get logical screen descriptor */
   if abbrev(ab3,'ERROR')=1 then do
         call dosay2 "Error: not a valid GIF file: "infile.kmm
         return 0
    end /* do */

   ct_name='ct.'                          /* extract info from it */
   stuff=read_lsd_block(ab1)
   parse var stuff width.kmm height.kmm gcflag.kmm gcsize.kmm colres.kmm ,
                   sort.kmm bkgcolor.kmm aspect.kmm

/* determine which IMG and which GCE block to read */
   dogce=1 ; doimg=1
   if mg1<0  then mg1=1
   if mg1<>1 then do            /* make sure there's mg1 images */
         imgct=0 ; iat=0
         do forever
            iat=wordpos('IMG',talist,iat+1)
            if iat=0 then leave
            imgct=imgct+1
         end 
         doimg=min(imgct,mg1)
         if doimg<>mg1 & verbose=1 then call dosay "   Warning: using IMG block # "doimg

         iat=0; gcect=0
         do forever
            iat=wordpos('GCE',talist,iat+1)
            if iat=0 then leave
            gcect=gcect+1
         end /* do */
         dogce=min(gcect,mg1)
         if dogce<>mg1 & verbose=1 then call dosay "   Warning: using GCE block # "dogce
   end

   ab2=read_gif_block(f1a,dogce,'GCE',1)               /* get graphical control extension */
  if abbrev(ab2,'ERROR')=1 then do
         call dosay2 "Error: not a valid GIF file: "infile.kmm
         return 0
  end /* do */

   stuff=READ_GCE_BLOCK(ab2)                /* extract info from it */
   parse var stuff adisposal usrinflag.kmm tcflag.kmm delay.kmm tcindex.kmm
   ab3=read_gif_block(f1a,doimg,'IMG',1)
   img_name='img.' ; ct_name='loct.'
   stuff=read_image_block(ab3,1)
   parse var stuff lpos.kmm tpos.kmm widtha.kmm heighta.kmm islct lctsize ,
                   interl.kmm sort.kmm ',' imgdata.kmm
   foo=cvcopy('img',imgs.kmm)
   if kmm=1 & resize_mode=0 then do
       width1=widtha.1 ; height1=heighta.1
   end 
   if resize_mode=1 then do
       width1=max(width1,widtha.kmm); height1=max(height1,heighta.kmm)
   end 

   if islct>0 then do
      call dosay " .... using local color table "
      drop ct.
      gcsize.kmm=lctsize
      foo=cvcopy('loct','ct')
   end
   foo=cvcopy('ct',cts.kmm)
end

/* now, resize images (if necessary), and count pixels */
do kmm=1 to infile.0

   if (width1<>widtha.kmm) | (height1<>heighta.kmm) | , 
             (transform.kmm=1)   then do /*need to resize */
      if verbose>0 then call dosay "Resizing "kmm ') 'infile.kmm " from " widtha.kmm 'x' heighta.kmm " to " width1 'x' height1
      if transform.kmm=1  then do       /* save original for later use */
          foo=cvcopy('imgs.'kmm,'origimg.'kmm)
      end

      aaa=get_transforms(1,,kmm)
      parse var aaa dh','dw','dx','dy','drz','dry','drx

      FOO=CVCOPY('IMGS.'KMM,'AIMG')
/* make_resizedi will either scale an image to be width1xheight1, or
   will trabnsform an image (using dh,etc.), and fill in non-identified
   pixels with the background pixel */
      foo=make_resizedi(transform.kmm,kmm,width1,height1,dh,dw,dx,dy,drz,dry,drx)
      foo=cvcopy('resizedi','imgs.'kmm)
      if transform.kmm=1 then foo=cvcopy('trmask','trmasks.'kmm)   /* retain transformation mask */
      img_name='resizedi.'      /* re create imgdata.kmm */
      aw=make_image_block(0,0,width1,height1,0,0,interl.kmm,0,0)
      stuff=read_image_block(aw,0)
      parse var stuff . ',' imgdata.kmm
      height.kmm=height1 ; width.kmm=width1  /* save new "screen size */

   end                                  /* done resizing */

   foo=cvcopy('IMGS.'kmm,'AIMG')
   IMGNAME='AIMG.'                     /* count occurences of pixel values */
   if verbose>0 then call dosay " ... counting pixels in " infile.kmm
   FOO=COUNT_PIXELS(cts.kmm.0)         /* RETURN AS 'nn nn nn ... ' */ 
   DO MM1=1 TO WORDS(FOO)              /* this is used in ct creation */
      mm2=mm1-1
      parse var foo cts.kmm.!ct.mm2 foo
   end /* do */
end 
cts.0=infile.0

call dosay " image data read (w x h = "width1 'x' height1

/*3) Create a new "combined and shrunken" color table */

aa=make_new_ctable(ct_newlen,infile.0*height1*width1,ct_make_spec)

/* 4) remap images to ctnew2
   Note that 0 of ctnew2 is "transparent", and pointers to it should never
   occur in img1 or img2 (with the exception of "transformed images background") */
ch0=c2d(0)
do icth=1 to cts.0
   call dosay "Remapping pixels in image # "icth
   do mm=0 to cts.icth.0-1
      rr=cts.icth.!r.mm ; gg=cts.icth.!g.mm ; bb=cts.icth.!b.mm
      ichk=checked2.rr.gg.bb
      cts.icth.!map.mm=ichk
   end /* do */
   jindx=tcindex.icth                   /* map transparent to pixel 0 */
   if no_transparent<>1 & tcflag.icth=1 then cts.icth.!map.jindx=0

   do ir=0 to imgs.icth.!rows-1   /* height1-1 */
      arow=imgs.icth.ir
      newrow=''
      do mm=1 to imgs.icth.!cols  /* width1 (1..width1 characters in string ) */
         ivv=c2d(substr(arow,mm,1))
         if cts.icth.!map.ivv<0 then 
            call dosay2 " ERROR AT FirstImage: " ir mm ivv cts.icth.!map.0

         use1=d2c(cts.icth.!map.ivv)       /* remap pixel, or use background pixel */
         if transform.icth=1 then do
            if substr(trmasks.icth.ir,mm,1)=ch0 then use1=ch0
         end  
         newrow=newrow||use1
      end /* do */
      imgs.icth.ir=newrow
   end                          /*row ir of image icth */


/* transform the original images? */
   if transform.icth=1 then do
     do ir=0 to origimg.icth.!rows-1   /* height1-1 */
       arow=origimg.icth.ir
       newrow=''
       do mm=1 to origimg.icth.!cols-1  /* width1-1 */
         ivv=c2d(substr(arow,mm,1))
         if cts.icth.!map.ivv<0 then 
            call dosay2 " ERROR AT FirstImage: " ir mm ivv cts.icth.!map.0
         use1=d2c(cts.icth.!map.ivv)       /* remap pixel, or use background pixel */
         newrow=newrow||use1
       end /* do */
       origimg.icth.ir=newrow
     end
   end                          /*row ir of image icth */

end


ctnew2.!r.0=r_back ; ctnew2.!g.0=g_back ; ctnew2.!b.0=b_back

/* --------- NOW create the various frames of the animation */

/* 5) WRITE LSD and FIRST image */

ct_name='ctnew2.'
a1=MAKE_LSD_BLOCK(width1,height1,1,7,0,bkgcolor.1,aspect.1,ctnew2.0)
iii=infile.0

a2=make_comment_block('BlendGif: 'anim_type" animation from "infile.1  " and " infile.2 )

a3=make_animation_block(do_iter)
tcflag1=tcflag.1
if no_transparent=1 then tcflag1=0
a4=MAKE_GCE_BLOCK(tcflag1,tcindex.1,frame_delay.1,adisposal0,0)

foo=cvcopy(cts.1,'ct1')
ct_name='ct1.'
a5=make_image_block(0,0,width.1,height.1,1,gcsize.1,interl.1,0,imgdata.1)
aa=a1||a2||a3||a4||a5

/*5) And now start building the animated GIF file */

/* 5a) note that the first GIF file is the "base" upon which future
      images are built, hence is not animated (although it can be transformed)
*/
cycleaa=''
use_newimg=0
do kmoo=1 to infile.0-1
  ido1=kmoo ; ido2=kmoo+1          
  if use_newimg=1 then                  /* a trick to have cumulative additions */
    foo=cvcopy('newimg','img1')
  else                                  /* use next */
     foo=cvcopy('imgs.'ido1,'img1')
  foo=cvcopy('imgs.'ido2,'img2')
  img2_trans=0
  if transform.ido2=1  then do
      img2_trans=1
      foo=cvcopy('trmasks.'ido2,'trmask')
      foo=cvcopy('origimg.'ido2,'aimg')
   end /* do */
   

/* 5a2) get "image-pair" specific parameters */
  nframes=frames.kmoo ; anim_type=strip(translate(anim_type.kmoo))
  stop_after=stop_after.kmoo  

  if stop_after=0 | stop_after='' then stop_after=110000
  centerx=centerx.kmoo  ; centery=centery.kmoo 

  balloon_type=strip(translate(balloon_type.kmoo))
  ktt=wordpos(balloon_type,'SQUARE DIAMOND OCTAGON CIRCLE')
  if ktt>0  then balloon_type=ktt

  balloon_push=strip(translate(balloon_push.kmoo))
  jtt=wordpos(balloon_push,'OVERWRITE PUSH SQUOOSH')
  if jtt>0 then balloon_push=jtt-1
     
  fade_type=strip(translate(fade_type.kmoo))
  jtt=wordpos(fade_type,'FREQUENCY BRIGHTNESS COLOR_BRIGHTNESS BEST_MATCH')
  if jtt>0 then fade_type=jtt-1

  CURTAIN_TYPE=strip(translate(CURTAIN_TYPE.kmoo))
  CURTAIN_OVERWRITE=strip(translate(CURTAIN_OVERWRITE.kmoo))

  dissolve_spec=dissolve_spec.kmoo 
  adelay=frame_delay.kmoo  
  if anim_type='MASK' then do
     do il0=1 to mask.0
        mask.il0=mask.il0.kmoo ; mask.il0.!thresh=mask.il0.!thresh.kmoo
     end /* do */
/* MASK_LIST supersedes MASKS. entreis  */
    if mask_list.kmoo<>'' & mask_list.kmoo<>0 then do
        do mk=1 to words(mask_list.kmoo)
            awm=strip(word(mask_list.kmoo,mk))
            mask.mk=awm ; mask.mk.!thresh=0
        end /* do */
        mask.0=words(mask_list.kmoo)
    end /* do */
  end

  call dosay anim_type " from " infile.kmoo  " to " infile.ido2 

/* 5b) might need to create some lookup stuff  */
  if anim_type='FADE' then do     
       if fade_type=2 & gotroutes=0 then do
          foo=make_ctroutes()
          gotroutes=1
        end /* do */
        if fade_type=3 & gotminfos=0 then do 
              gg=make_regions(nregions)
              gotminfos=1
        end /* do */
   end

/* 5c) Create sorted index into CTNEW2 (creates sorted_ct.)  */
   if anim_type='FADE' then foo=sort_ctnew2(fade_type) 

/* 5d) do the animation!!! */
   if nframes>0 | anim_type='ADD' then call do_anims anim_type   

/* 5e) add the actual 2nd image (as the "final frame" of the set of frames for this image-pair) */
   use_newimg=0
   if (nframes<stop_after | stop_after=0) & anim_type<>'ADD' then do
      if (ido2<>infile.0) | (ido2=infile.0 & cycle=1) then do    /* finalize the idoo2 image */
        if transform.ido<>1 then do
           tcflag2=tcflag.ido2
           if no_transparent>0 then tcflag2=0
           a6=MAKE_GCE_BLOCK(tcflag2,tcindex.ido2,adelay,adisposal0,0)
           foo=cvcopy(cts.ido2,'ct2')
           ct_name='ct2.'
           a7=make_image_block(0,0,width1,height1,1,gcsize.ido2,interl.ido2,0,imgdata.ido2)
           aa=aa||a6||a7
           if cycle=1 & ido2<>infile.0 then cycleaa=a6||a7||cycleaa
        end             /* else, it was done in do_anim */
      end
    end                 /* nframes < stop_after */
    else do                     /* either stop_after is active, or ADD anim_type */
       use_newimg=1             /* then use current image as first image of next pair */
    end /* do */

/* a few more reasons for using current image as first image in next pair */
    if transform.ido2=1 & bkg_transparent.ido2>0 then use_newimg=1 
    if anim_type='ADD' then use_newimg=1

end                             /* infiles loop */

/* 5f) WRITE final image (note use of imgdata instead of img. array)*/
if (nframes>=stop_after  & stop_after<>0 ) | ( transform.ido2=1) then do
   if cycle=1 then do
       tcflag2=tcflag.1
       if no_transparent=1 then tcflag2=0
       a6=MAKE_GCE_BLOCK(tcflag2,tcindex.1,adelay,adisposal0,0)
       foo=cvcopy(cts.1,'ct2')
       ct_name='ct2.'
       a7=make_image_block(0,0,width1,height1,1,gcsize.1,interl.1,0,imgdata.1)
       aa=aa||cycleaa||a6||a7||make_terminator_block()
    end
    else do
       aa=aa||make_terminator_block()
    end /* do */
end /* do */
else do
  if cycle=1 then do     /* cycle back */
    ill=1
    tcflag2=tcflag.ill
    if no_transparent=1 then tcflag2=0
    a6=MAKE_GCE_BLOCK(tcflag2,tcindex.ill,adelay,adisposal0,0)
    foo=cvcopy(cts.ill,'ct2')
    ct_name='ct2.'
    a7=make_image_block(0,0,width1,height1,1,gcsize.ill,interl.ill,0,imgdata.ill)
    aa=aa||cycleaa||a6||a7||make_terminator_block()
  end
  else do         
    ill=infile.0
    tcflag2=tcflag.ill
    if no_transparent=1 then tcflag2=0
    a6=MAKE_GCE_BLOCK(tcflag2,tcindex.ill,adelay,adisposal0,0)
    foo=cvcopy(cts.ill,'ct2')
    ct_name='ct2.'
    a7=make_image_block(0,0,width1,height1,1,gcsize.ill,interl.ill,0,imgdata.ill)
    aa=aa||a6||a7||make_terminator_block()
  end 
end

/* try and shrink image? */
if  shrink_image=1 then do
    call dosay "... shrinking image "
     aa=do_shrink_gif(aa)
end /* do */

/* 6) Write image, and all done */
if is_cgi=2 then do
   xx=sysfiledelete(OUTFILE)
   foo=charout(outfile,aa,1)
   foo2=stream(outfile,'c','close')
   call dosay "New file created: " outfile
   IF YESNO(' Display this image using '||img_prog) =1 then do
       oo=stream(outfile,'c','query exists')
       ar1=translate(oo,':','|')
       ar1=translate(ar1,'/','\')
       foo=img_prog' file:///'||ar1
       '@start /f 'foo
       say cy_ye " >>> starting "img_prog ||normal" (it might take a few seconds...)"
   end                  /* display with "img_prog" */
   exit
end
/* if here, sre-http addon or cgi */
if is_cgi=0 then do
  if save_tempfile<>1 then do           /* send image as final part */
     foo=sref_multi_send('... finished!','text/plain','SE')
     gt='image/gif'||'0d0a'x||'Content-Disposition: attachment ; filename="'||outfile||'"'
     foo=sref_multi_send(aa,gt,'E') 
     return '200 '||length(aa)  
  end
  else do                /* send a link to the image */
    tname=blendgif_root
    bb=strip(blendgif_dir) ; bb=translate(blendgif_root,'\','/')

/* delete some old temp files? */
    bb2=strip(bb,'t','\')||'\BLND*.GIF'
    foo=sysfiletree(bb2,'foos','TF')
    if foos.0>max_tempfiles then do     /* too many tempfiles, delete a few */
      garg=min(5,1+(max_tempfiles/3))
      do io=1 to garg
         call deleteold
      end /* do */
      call pmprintf('BlendGIF: Deleted 'garg 'old temporary files ')
    end 
     
    bb=strip(bb,'t','\')||'\BLND????.GIF'
    bb=dostempname(bb)
    foo=charout(bb,aa,1)
    foo2=stream(bb,'c','close') 
    outf=filespec('n',bb)
    toview='<a href="/blendgif?showfile='outf'">your animated GIF</a>?'
    call dosay " </pre> <b>Would you like to view</b> "toview'<p>'
    call dosay "</body></html>"
    return '200 '  
  end   
end

/* if here, cgi */
say 'Content-type: image/gif '
say 
call charout,aa
exit 


erre:
 call dosay2 "Error occured at line "sigl' 'rc
 exit 



/*************************** END OF MAIN *******************/

/* ------------------- */
deleteold:              /* real primitive search */
  oldest='999999999999999' ; oldid=0
  do ijo=1 to foos.0
     parse var foos.ijo adate . 
     if adate<oldest  then do
         oldest=adate ; oldid=ijo
     end /* do */
  end       /* io loop */
  parse var foos.oldid . . . afile
  idid=sysfiledelete(strip(afile))
  foos.oldid='99999999999999999999'
  return 0



/********************/
/* ask user for input file (of blendgif options */
ask_input_file:
do forever
  arf=yesno(normal||bold||" and last of all -- "normal||reverse" read options from an input file",'NO YES ?','NO')
  if arf=0 then return 0

  if arf=2 then do
     say " "
     say "You can read options from a BlendGIF input file."
     say bold"An example of such a file is: "normal
     say "    ; sample input file for BlendGIF"
     say "    infile.0=2 "
     say "     infile.1=hello "
     say "     infile.2=goodbye "
     say "     anim_type=balloon"
     say "     balloon_push=squoosh"
     say "     balloon_type=circle "
     say "For further details on BlendGIF options, see the manual (BLENDGIF.DOC)"
     say " "
     iterate
  end /* do */

/* if here, ask for file name */
  do forever
      say "     "bold" File name: " normal"(BLENDGIF.IN, ?=list files):"
      call charout,"     "bold"? "normal
      parse pull aa ; aa=strip(aa)
      if aa='' then aa='BLENDGIF.IN'
      if left(aa,1)="?" then do
          parse var aa . thisdir
          if thisdir="" then    thisdir=directory()
          say 
          say reverse ' List of .IN files in: ' normal bold thisdir normal
          do while queued()>0
             pull .
           end /* do */
          '@DIR /b  '||strip(thisdir,'t','\')'\*.in | rxqueue'
          foo=show_dir_queue('.IN')
          say
          iterate
      end
      if pos('.',aa)=0 then aa=aa'.in'
      foo=stream(aa,'c','query size')
      if foo=0 | foo='' then do
         say "       a) No such file: " aa
         iterate
      end /* do */
      input_file=aa
      call read_input_file
      if result=0 then iterate   /* some kind of error */
      return 1                  /* got it okay */

   end                  /* read file loop */

end /* top forreer */


/************************/
/* read an input file containing blendgif parameters */
read_input_file:
if input_file<>0 & input_file<>'' then do  
   input_file=resolve_filename(input_file,blendgif_root,'.IN')
   jaa=stream(input_file,'c','query size')
   if jaa=0  | jaa='' then do
      call dosay2 "BlendGIF error: no such input file: "input_file
      return 0
   end /* do */
   foo=stream(input_file,'c','open read')
   input_file_upload=charin(input_file,1,jaa)
end
if input_file_upload<>'' & input_file_upload<>0 then do
   iread=0
   do forever           /* parse and use parameters in input file */
      if input_file_upload='' then leave
      parse var input_file_upload a1 (crlf) input_file_upload
      a1=strip(a1) 
      if abbrev(a1,';')=1 then iterate  /* skip comments */
       parse var a1 a1a '=' a1b
       a1a=strip(decodekeyval(translate(a1a,' ','+'||'09000a0d'x)))
       a1b=strip(decodekeyval(translate(a1b,' ','+'||'09000a0d'x)))
       a1b=translate(a1b,'.','$')               /* since javascript don't like a.b names */
       if a1b='' then iterate                   /* blank entry, ignore */    

       if valid_parameter(a1a,param_list)=0 then do
           call dosay2 'BlendGIF error. No such parameter (input-file): 'a1
           return 0 
       end /* do */
      if abbrev(translate(a1a),'UPFILE')=1 then do       /* special case -- read lines, decode */
          ccc=''
          parse var a1a . '.' mmm
          infile.mmm=' Uploaded file = ' a1b
          do forever
             if input_file_upload='' then leave
             parse var input_file_upload  c0 (crlf) input_file_upload
             if c0='' then leave                /* blank line signals end of file upload */
             ccc=ccc||c0
          end /* do */
          a1b=unpack64(ccc)
       end /* do */
       xx=value(a1a,a1b)
       iread=iread+1
   end /* do */
   call dosay "# of options read from input file= " iread
end /* do */

return 1

/***************************/
/* determine transformation factors, given "nth" frame in kth 
set of nframes factors. 
Speial case: If "nth"=1 then just use first word in each factor */
get_transforms:procedure expose nuheight. nuwidth. xmove. ymove. ,
                               zrotate. yrotate. xrotate. 
parse arg nth,inlist,kmm
if nth=1 then do
 dh=word(nuheight.kmm,1) ; dw=word(nuwidth.kmm,1)
 dx=word(xmove.kmm,1) ; dy=word(ymove.kmm,1)
 drz=word(zrotate.kmm,1); dry=word(yrotate.kmm,1)
 drx=word(xrotate.kmm,1)
end
else do
 dh=get_user_scale(nth,inlist,nuheight.kmm) 
 dw=get_user_scale(nth,inlist,nuwidth.kmm)
 dx=get_user_scale(nth,inlist,xmove.kmm) 
 dy=get_user_scale(nth,inlist,ymove.kmm)
 drz=get_user_scale(nth,inlist,zrotate.kmm)
 dry=get_user_scale(nth,inlist,yrotate.kmm)
 drx=get_user_scale(nth,inlist,xrotate.kmm)
end /* do */
return dh','dw','dx','dy','drz','dry','drx


/****************************************/
/* resize/transform AIMG., returns RESIZEDI
  NEWIMG. will be height1 x width1;
  If dotransform=1, then and translate/rotate/scale, and possibly
  fill background 
  If dotransform=0, then just scale it up (or down)
  Other Arguments:  
  knn = points to some parameters arrays
  nuheight = height of full image
  nuwidth = width of full image
  myheight = image scaled to this height
  mywidth = image scaled to this width
  myxmove,myymove = move this way horiz and vertical
  zrotate, yrotate, xrotate=rotate by this angle(s)
*/
make_resizedi:procedure expose resizedi. trmask. aimg. ,
                               bkg_transparent. tcflag. tcindex.

parse arg dotransform, knn,width1,height1,myheight,mywidth,myxmove,myymove, ,
              zrotate,yrotate,xrotate

drop resizedi.
resizedi.=0
/* resize to width1, height1 (no transformations?) */
if dotransform<>1 then do
  resizedi.!rows=height1 ; resizedi.!cols=width1
  wfact=(AIMG.!cols-1)/max(1,(width1-1))
  hfact=(AIMG.!rows-1)/max(1,(height1-1))
  oldir1a=-1
  do ir1=0 to height1-1
    ir1a=trunc(ir1*hfact)
    if oldir1a=ir1a then do
       irn1=ir1-1
       resizedi.ir1=resizedi.irn1
       iterate
    end /* do */
    userow=AIMG.ir1a
    new1=''
    do ic1=0 to width1-1
       ic1a=trunc(ic1*wfact)
       new1=new1||substr(userow,ic1a+1,1)
    end                         /* ic1 = 0 to width-1 */
    resizedi.ir1=new1
    oldir1a=ir1a
  end           /* ir1 .. 0 to height-1 */
  return 1
end


/* ------------ if here, this is a "transformation" */
resizedi.=0
resizedi.!cols=width1 ; resizedi.!rows=height1  /* full "window" size */

if zrotate='' then zrotate=0
if yrotate='' then yrotate=0
if xrotate='' then xrotate=0
BKG_TRANSPARENT=BKG_TRANSPARENT.KNN
IF wordpos(bkg_transparent,'0 1 2')=0 then bkg_transparent=0
if datatype(myheight)<>'NUM' then   myheight=AIMG.!ROWS
if datatype(mywidth)<>'NUM' then    mywidth=AIMG.!COLS
if datatype(myxmove)<>'NUM' then    myxmove=0
if datatype(myymove)<>'NUM' then    myymove=0
if datatype(zrotate)<>'NUM' then   zrotate=0
if datatype(xrotate)<>'NUM' then   xrotate=0
if datatype(yrotate)<>'NUM' then   yrotate=0

/* CONVERT FRACTIONS APPROPRIATELY */
IF pos('.',myheight)>0 then myheight=trunc(AIMG.!rows*myheight)
IF pos('.',mywidth)>0   then mywidth=trunc(AIMG.!cols*mywidth)
/* enforce minimums */
myheight=max(2,myheight) ; mywidth=max(2,mywidth)

/* scale factors */
hscale=myheight/AIMG.!rows
wscale=mywidth/AIMG.!cols

if pos('.',myxmove)>0 then myxmove=trunc(myxmove*width1)
if pos('.',myymove)>0 then myymove=trunc(myymove*height1)

blank1=copies(d2c(0),width1)
do ir1=0 to height1-1             /* initialize */ 
    resizedi.ir1=blank1          
    trmask.ir1=blank1            
end
ch1=d2c(255)


/* compute the transformation and inverse transformation matrices */
   tran_matrix='trnmtx.'; inv_tran_matrix='itrnmtx.'
   astatus=create_trans_matrix(AIMG.!cols-1,AIMG.!rows-1, ,
                            wscale,hscale,zrotate,yrotate,xrotate,myxmove,myymove)

/* the transformation works in reverse direction -- for each spot in
the "new image", we find where it would have come from in the old image.
As an efficiency measure, we bound the area of this "detransformation"
by transforming the corners, and finding mins and maxs */

tran_matrix='trnmtx.'
parse value transfrm_point(0,0,0) with x0 y0 z0
parse value transfrm_point(AIMG.!cols-1,0,0) with x1 y1 z1
parse value transfrm_point(AIMG.!cols-1,AIMG.!rows-1,0) with x2 y2 z2
parse value transfrm_point(0,AIMG.!rows-1,0) with x3 y3 z3

/* find bounds of where transformation will fall (on the "screen") */
xmin=max(min(x1,x2,x3,x0,width1-1),0)   /* keep it on the "screen" */
xmax=min(max(x1,x2,x3,x0,0),width1-1)
ymin=max(min(y1,y2,y3,y0,height1-1),0) 
ymax=min(max(y1,y2,y3,y0,0),height1-1)

/* define plane equation */
xa=x1-x0 ; ya=y1-y0 ; za=z1-z0  /* equation for line A */
xb=x2-x0 ; yb=y2-y0 ; zb=z2-z0  /* equation for line B */
xab=(ya*zb)-(za*yb);            /* AxB, x component */
yab=-( (xa*zb)-(za*xb))         /* AxB, y component */
zab=(xa*yb)-(ya*xb)             /* AxB, z component */
/* the _ab line is normal to the plane defined by lines a and b */
D=(xab*x0)+(yab*y0)+(zab*z0)    /* Ax + By + Cz = D  */

/* z function is:  znew = (D- ((xnew*xab)+(ynew*yab)) ) /  zab  */
ISTC=0 ; TCVAL=CH1
IF TCFLAG.KNN=1 then DO
  ISTC=1 ; TCVAL=D2C(TCINDEX.KNN)
END

/* resize, and make the TRmask. Note: default is "pixel is not useable"
(that it is transparent) */

tran_matrix='itrnmtx.'
do ir1=ymin to ymax
  do ic1=xmin to xmax
     if zab=0 then
        iz1=0
     else
        iz1= (d - ((ic1*xab)+(ir1*yab)))/ zab
     parse value transfrm_point(ic1,ir1,iz1) with ocol orow odepth
     if orow<0 | ocol<0 | orow>=AIMG.!rows | ocol>=AIMG.!cols then iterate
     pold=substr(AIMG.orow,ocol+1,1)
     resizedi.ir1=overlay(pold,resizedi.ir1,ic1+1,1)
     if (bkg_transparent=2) then do   /* mark tc pixels as background transparent? */
        if (istc=1 & pold=tcval) then iterate /* do NOT mark this as "useable */
     end /* do */
     trmask.ir1=overlay(ch1,trmask.ir1,ic1+1,1)
  end /* columns */
end /* rows */


return 1


/************************/
/* allow user to set parameters */
set_params0:
parse arg didp00
if didp00<>1 then do
  say
  say "     " cy_ye" BlendGif -- blend several GIF files into a multi-frame animated GIF" normal
  say
  say bold" Please specify a few parameters."normal
  say     "  "bold"*"normal" values in parenthesis, and "cy_ye"H"normal"ighlighted choices, are the defaults "
  say     "  "bold"*"normal" [Up] means : Hit Upper Arrow to go back to a prior question "
  say     "  "bold"*"normal" The BlendGIF manual is BlendGIF.DOC"
  if stream('BLENDGIF.DOC','c','query exists')<>'' then do
     ii=yesno(normal"      "bold"Would you like to view BLENDGIF.DOC in another window?"normal,,'N')
     if ii=1 then '@START  "The BlendGif Manual" /C /F /WIN E BLENDGIF.DOC'
  end
end
else do
  say
   say cy_ye'... please re-enter parameters...'normal
  say
end /* do */
say
do forever

 infile.0=ask_integer('INFILE.0'," Number of GIF files (or URLS) to blend:",infile.0,2)

if datatype(infile.0)<>'NUM' then signal if0
mm=0
do forever
   if mm>=infile.0 then leave
   mm0=mm+1
   say "    (INFILE."mm0" )" bold" File name (or URL): " normal"("infile.mm0 ", ?=list files, *=wildcard):"
   call charout,"     "bold"? "normal
   parse pull aa
   if left(aa,1)="?" then do
        parse var aa . thisdir
        if thisdir="" then    thisdir=directory()
        say 
        say reverse ' List of GIF files in: ' normal bold thisdir normal
        do while queued()>0
            pull .
         end /* do */
        '@DIR /b  '||strip(thisdir,'t','\')'\*.gif | rxqueue'
        foo=show_dir_queue('.GIF')
        say "  "bold"*"normal" Note: to retrieve a GIF file on the www,  "
        say "          enter it's complete URL (including the http://) "
        say
        iterate
   end

   if pos('*',aa)>0 then do           /* get wildcards */
         oo=sysfiletree(aa,goobs,'O')
         say " Found "goobs.0' matches to: 'aa
         do jj=1 to goobs.0
           mm=mm+1
           infile.mm=goobs.jj
           iii=get_img_Num(mm') 'infile.mm '(0 to skip)',0) 
           if iii=0 then do             /* 0 means "skip this one" */
             mm=mm-1
             iterate
           end /* do */
           infile.mm.!nth=iii
           if mm>=infile.0 then leave
        end               
        iterate
   end /* do */

  if aa='' then aa=infile.mm0 
  if pos('.',aa)=0 then aa=aa||'.GIF'   
  if abbrev(translate(aa),'HTTP://')=0 then do
    if resolve_filename(aa,BLENDGIF_ROOT,'.GIF')='' then do
       say "Plese reenter (no such file: "aa ')'
       iterate
    end 
  end
  mm=mm+1               /* record name, and nth image */
  infile.mm =aa
  infile.mm.!nth=get_img_Num('')
end

yesans.0='NO' ; yesans.1='YES'

qq1: cycle=yesno("(CYCLE) Cycle through images (YES= first to last to first)",,yesans.cycle)

frames=ask_integer('FRAMES','# of intermediate frames between images:',frames,0)

iterations=ask_integer('ITERATIONS'," # of iterations of animation loop: ",iterations,1)

frame_delay=ask_integer('FRAME_DELAY','Delay between frame display (in 1/100th seconds)',frame_delay,1)

shrink_image=yesno(" Attempt to shrink final image file size (by using 'retain' disposal)?")


rsans.0='F' ; rsans.1='M'; rsans.2='U'
rhere: rr=yesno("(RESIZE_MODE) How to set image size" ,'FIRST_IMG MAX USER_SET ?',rsans.resize_mode,1)
if rr=-1 then  signal qq1
resize_mode=rr
if resize_mode=2 then do
   width1=ask_integer('     WIDTH1','Width of image (in pixels) ',width1,2)
   height1=ask_integer('    HEIGHT1','Height of image (in pixels)',height1,2)
end /* do */
if resize_mode=3 then do
  say " Determine the size of the image by: "
  say bold" *"normal" FIRST_IMG = Using the size of the first image "
  say bold" *"normal"       MAX = Using the maximum width and height (across all images) "
  say bold" *"normal"  USER_SET = Specify the width and height "
  signal rhere
end

jumpa:aa=yesno("(ANIM_TYPE) Animation type","ADD BALLOON CURTAIN DISSOLVE FADE MASK ?",anim_type,1)
if aa=-1 then signal rhere

anim_type=aa+1          /* first choice is 0 */
if anim_type=7 then do
    say ' '
    say reverse'Select one of: 'normal
    say '          'bold'ADD'normal': The second image is added onto the the first '
    say '     'bold' BALLOON'normal': The first image is replaced by an expanding "balloon" '
    say '               of the second image.'
    say '     'bold'CURTAIN'normal': The second image is a curtain pulled over the first image'
    say '     'bold'DISSOLVE'normal': The first image dissolves into the second image'
    say '         'bold'FADE'normal': The first image fades into the second image.'
    say '        'bold'MASK'normal': "Mask" files are used to overlay portions of the second image'
    say '               onto the first image.'
    say ' '
    signal jumpa
end /* do */
else do
   anim_type=strip(word('ADD BALLOON CURTAIN DISSOLVE FADE MASK',anim_type))
end /* do */

do forever
 select
   when anim_type="FADE" then do
      call charout,'  (FADE_TYPE) 'bold' Type of fade 'normal'('fade_type', ?=help):'
      pull aa
      if aa='' then aa=fade_type
      if aa="?" then do
           say "     Standard FADE_TYPE values (or, enter a equation in R,G and B): "
           say "        0 = color frequency           :  1=Brightness "
           say "        2 = Color specific brightness :  3=Best match "
           say "        Equation example: "bold" 2*R + G "normal
           iterate
      end /* do */
      fade_type=aa
   end /* do */

   when anim_type="BALLOON" then do
     bans.1='S'; bans.2='D'; bans.3='O'; bans.4='C'
      bb=yesno(normal'   (BALLOON_TYPE) 'bold' Type of balloon: 'normal,'SQUARE DIAMOND OCTAGON CIRCLE',bans.balloon_type,1)
      if bb=-1 then signal jumpa
      balloon_type=bb+1
      if balloon_type=4 then do
        bans.0='0';bans.1='P'; bans.2='S';bans.10='P'; bans.20='S'
        btmp=yesno(normal'   (BALLOON_PUSH) 'bold' Circular-balloon mode :'normal,'OVERWRITE PUSH SQUOOSH ',bans.balloon_push,1)
        if btmp<0 then signal jumpa
        if btmp>0 then do
           aa='Y'; if balloon_push<10 then aa='N'
           btmp2=yesno(normal'   (BALLOON_PUSH columns)'bold' Squoosh/Push columns only? ',,aa)
           if btmp2=-1 then signal jumpa
           if btmp2=1 then btmp=btmp||'0'
        end /* do */
        balloon_push=btmp
      end
   end                  /* balloon  */

   when  anim_type="CURTAIN" then do
        ctype=yesno(normal'  (CURTAIN_TYPE)'bold'Direction of curtain: 'normal,'LEFT_RIGHT TOP_BOTTOM MIDDLE_DRAW',1)
        if ctype=-1 then jumpa
        curtain_type=strip(word('L_R T_B MIDDLE',ctype+1))
        ctype=yesno(normal'  (CURTAIN_OVEWRWITE)'bold'Curtain Overwrite Mode: ','OVERWRITE PUSH SQUOOSH',1)
        if ctype=-1 then jumpa
        curtain_overwrite=strip(word('OVERWRITE PUSH SQUOOSH',ctype+1))
   end                   /* CURTAIN animtype */

   otherwise 
 end  /* select */
 leave

end


return 1

/**************/
/* is this a valid parameter? -- return 0 if not */
valid_parameter:procedure
parse upper arg aparam,alist

luse=aparam
foo=pos('.',luse)       
if foo>0 then luse=left(aparam,foo)
foo=wordpos(luse,alist)
return foo

/************/
/* unpack64   :  astring=unpack64(string_packed_64) */

unpack64:procedure
char_set='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
do mm=0 to length(char_set)-1
   a.mm=substr(char_set,mm+1,1)
end /* do */

parse arg mess
newmess=""
do mm=1 to length(mess)
   a1=substr(mess,mm,1)
   a1a=c2d(a1)
   select
     when a1a>64 & a1a<91  then a1b=a1a-65  /* ascii 65 to 90 */
     when a1a>96 & a1a<123 then a1b=26+(a1a-97)  /* ascii 97 to 122 */
     when a1a>47 & a1a<58  then a1b=a1a+4   /* ascii 48 to 57 */
     when a1='+' then a1b=62
     when a1='/' then a1b=63
     when a1='=' then iterate
     otherwise return ""        /* error */
   end
   pp=x2b(d2x(a1b))
   if length(pp)>6 then
        pp=substr(pp,3)
   else
        pp=right(pp,6,0)
   newmess=newmess||pp
end
ilen=trunc(length(newmess)/8)*8 ; newmess=left(newmess,ilen)
newm=x2c(b2x(newmess))
return newm


/************************************************/
/* procedure from TEST-CGI.CMD by  Frankie Fan <kfan@netcom.com>  7/11/94 */
DecodeKeyVal: procedure
  parse arg Code
  Text=''
  Code=translate(Code, ' ', '+')
  rest='%'
  do while (rest\='')
     Parse var Code T '%' rest
     Text=Text || T
     if (rest\='' ) then
      do
        ch = left( rest,2)
        if verify(ch,'01234567890ABCDEF')=0 then
           c=X2C(ch)
        else
           c=ch
        Text=Text || c
        Code=substr( rest, 3)
      end
  end
  return Text


/*********/


/**********/
/* ask for an integer (min value of minval */
ask_integer:procedure expose bold normal
parse arg  varname,amess,defval,minval
if minval='' then minval=0
if amess=''  then amess=' ? '
if defval='' then defval=minval
if varname='' then varname=word(amess,1)

do forever
  call  charout,'('varname')'bold||amess||normal||'('||defval||'):'
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





/**********/
/* ask for image number */
get_img_Num:procedure expose bold normal
parse arg aname,amin
if amin='' then amin=1
if length(aname)>30 then  say aname 

do forever
  if length(aname)<=30 then do
    if aname='' then
       call charout,'    'bold'... Which frame (in this image) 'normal'(first frame): '
    else
       call charout,aname'    'bold'... which frame (in this image) 'normal'(first frame): '
  end
  else do
       call charout,'    'bold' ... which frame (in this image) 'normal'(first): '
  end /* do */
  pull aa
  if aa='' then aa=1
  if datatype(aa)<>'NUM' then do
        say "Bad frame number -- enter a positive integer "
        iterate
   end /* do */
   return trunc(max(amin,aa))
end


/************************/
/* allow user to set parameters */
set_params:
parse arg isq
signal on error name ggg ; signal on syntax name ggg
if isq>1 then do
  call showhelp
  call charout,cy_ye'...hit any key to continue'
  foo=sysgetkey('NOECHO');say
end
say bold" Please enter parameter values. "normal
say bold"  *"normal " Enter 1 value per line. "
say bold"  *"normal " When done, don't enter anything (just hit the ENTER key)"
say bold"  *"normal " To view current parameter settings, enter "bold"? "normal
say bold"  *"normal " To re-enter parameters, enter "bold"REDO"normal
say bold"  *"normal " To exit program, enter "bold"EXIT"normal
say "  Example: " reverse "   ANIM_TYPE='DISSOLVE' " normal
do forever
   call charout,bold "? " normal
    pull ain ; ain=strip(ain)
   if ain='' then return 1
   if translate(ain)='REDO' then return 2
   if ain="?" then do
      call showhelp
      iterate
   end
   interpret ain
end /* do */


ggg:
say
say " Bad entry. Did you forget a quote? "
say
signal set_params
return


/*****************************/
/* list parameters and current values */
showhelp:

btype.1='square'
btype.2='diamond'
btype.3='octagon'
btype.4='circle'

btype2.0='overwrite' ; btype2.1='push' ; btype2.2='squoosh'
btype2.10='push columns ' ; btype2.20='squoosh columns'

ctms.0='most frequent colors'
ctms.1='some binary search'
ctms.2='more binary search'

fty.='rexx string'
fty.0='frequency sort'
fty.1='brightness sort'
fty.2='color specific brightness sort'
fty.3='best match'

ptype.L_R="left to right"
ptype.T_B="top to bottom"
ptype.MIDDLE='converge in middle'

yesnoc.0="no" ; yesnoc.1="yes"

say "    " cy_ye"The more important parameters, and their current values."normal
SAY " INFILE.0 (# of files)= "bold' 'infile.0||normal||'.  INFILE.n  INFILE.n.!nth ['bold'filename'normal' image#] =='
aa=''
do iii=1 to infile.0
   af=infile.iii 
   kiki=infile.iii.!nth
   if datatype(kiki)<>'NUM' then kiki=1
   af='['bold||af||normal' '||kiki||'] '
   if length(af)<18 then af=left(af,17)
   if length(aa||af)>74 then do
      say '   ' aa
      aa=af
   end
   else do
      aa=aa||af
   end /* do */
end /* do */
if aa<>'' then say '   ' aa
say normal" CT_NEWLEN (length of global color table) = " bold' ' ct_newlen' 'normal
say " CT_MAKE_SPEC (global color table method; 0,1,2) = "bold' ' ct_make_spec' ('ctms.ct_make_Spec')'normal
say " FADE_REGIONS (dimensions of FADE index) = "bold ' ' fade_regions' 'normal 

say " FRAMES (# frames) = "bold' ' frames' 'normal  , 
      ', FRAME_DELAY (1/100 seconds) = 'bold' ' FRAME_DELAY ' ' normal
say " CYCLE (0,1) = "bold ' ' CYCLE' ('yesnoc.cycle') 'normal ', ITERATIONS = 'bold' 'iterations ' ' normal ,
    ", STOP_AFTER = "bold||stop_after||normal
say " ANIM_TYPE (add balloon curtain dissolve fade mask) = " bold' 'anim_type' ' normal
say "    BALLOON_TYPE (1,2,3,4) = " bold' 'balloon_Type' ('btype.balloon_type') 'normal  
say '       BALLOON_PUSH (0,1,2,10,20)= 'bold' ' balloon_push' ('btype2.balloon_push') ' normal
say "       CENTERX and CENTERY = "bold' ' centerx ' ' centery' ' normal
say "    CURTAIN_TYPE (L_R T_B MIDDLE) = " bold' ' curtain_type' ('ptype.CURTAIN_TYPE')' normal
say "        CURTAIN_OVERWRITE (OVERWRITE PUSH SQUOOSH) = " bold' ' curtain_overwrite normal
say "    FADE_TYPE = " bold' ' fade_type ' ('fty.fade_type')' normal
say "    DISSOLVE_SPEC = "bold' ' dissolve_spec' ' normal
SAY "    MASK.0 (# of mask files)= "bold' 'mask.0
aa=''
do iii=1 to mask.0
   af=mask.iii ; if length(af)<15 then af=left(af,14)
   if length(aa||af)>74 then do
      say '       ' aa
      aa=af
   end
   else do
      aa=aa||af
   end /* do */
end /* do */
say '       ' aa

return 1



/*******************************************/
use_sorted_ct:procedure expose sorted_ct. is_cgi BLENDGIF_ROOT save_tempfile
parse arg ac1,ac2,pp,sort_ct

/* use raw (frequency) pixel values */
if sort_ct=0 | sorted_ct.!is=0 then
 return ac1+trunc((ac2-ac1)*pp)

i1=sorted_ct.ac1
i2=sorted_ct.ac2       /* the "brightness" levels of pixel 1 and 2 */
ip=i1+trunc((i2-i1)*pp) /* an index to an intermediate brightness */
return sorted_ct.!rev.ip  /* this index points to a ctnew2. color */


exit




/**************************/
/* construct a set of animated frames, append to the AA variable
  Requires that img1 and img2 (the begin and end images) be
  set
*/

do_anims:
parse arg anim_type

newimg.=0
newimg.!rows=height1
newimg.!cols=width1

btype2.0='Overwrite' ; btype2.1='Push' ; btype2.2='Squoosh'
btype2.10='PushX  ' ; btype2.20='SquooshX '

ch0=d2c(0)
cctype=anim_type
if cctype='CURTAIN' then cctype=curtain_overwrite
/* build a shutter style animation */
select

when cctype="ADD" then do
     foo=cvcopy('img2','newimg')
     itt=0
     if img2_trans=1 then do
        call do_fix_trans   /* enforce transparency of "transformed" image 2 */
     end
     a4=MAKE_GCE_BLOCK(itt,0,adelay,adisposal0,0)
     img_name='newimg.'
     a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
     aa=aa||a4||a5
     if cycle=1 then  cycleaa=a4||a5||cycleaa

signal on error name eek1err ;  signal on syntax name eek1err ;

/* now do other transformations (if any were specified) */
    oo=ismany_transforms(ido2)
    if oo=1 then do
      do jmm=1 to min(nframes,stop_after)
        aaa=get_transforms(jmm+1,nframes+1,ido2) 
        parse var aaa dh','dw','dx','dy','drz','dry','drx
  
        CALL DOSAY '   'jmm' of 'nframes'  frame of ADD image (' aaa
        foo=make_resizedi(1,kmm,width1,height1,dh,dw,dx,dy,drz,dry,drx)
        foo=cvcopy('resizedi','NEWIMG')
        itt=0
        if img2_trans=1 then do
          call do_fix_trans   /* enforce transparency of "transformed" image 2 */
        end
        a4=MAKE_GCE_BLOCK(itt,0,adelay,adisposal0,0)
        img_name='newimg.'
        a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
        aa=aa||a4||a5
        if cycle=1 then  cycleaa=a4||a5||cycleaa
      end /* do */
    end
end




when cctype="OVERWRITE" & CURTAIN_TYPE="T_B" then do
  rowchunk=(height1/(nframes+1))
  do mm=1 to min(nframes,stop_after)
     m2=trunc(rowchunk*mm)
     call dosay " CURTAIN: rows to " m2

     do i1=0 to m2
        newimg.i1=img2.i1
     end /* do */
     do i2=m2+1 to height1-1
        newimg.i2=img1.i2
     end /* do */

     if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

     a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)
     img_name='newimg.'
     a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
     aa=aa||a4||a5
     if cycle=1 then  cycleaa=a4||a5||cycleaa

  end
end /* do */



when  cctype="PUSH" & CURTAIN_TYPE="T_B" then do
  rowchunk=height1/(nframes+1)
  do mm=1 to min(nframes,stop_after)
     m2=trunc(rowchunk*mm)
     call dosay " PUSH: rows to " m2
     do i1=0 to m2
        i1a=i1+height1-m2
        newimg.i1=img2.i1a
     end /* do */
     do i2=m2+1 to height1-1
        i2a=i2-(m2+1)
        newimg.i2=img1.i2a
     end /* do */

     if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

     a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)
     img_name='newimg.'
     a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
     aa=aa||a4||a5
     if cycle=1 then  cycleaa=a4||a5||cycleaa
  end
end /* do */


when cctype="SQUOOSH" & CURTAIN_TYPE="T_B" then do
  rowchunk=(height1/(nframes+1))
  do mm=1 to min(nframes,stop_after)
     m2=trunc(rowchunk*mm)
     call dosay " SQUOOSH: rows to " m2
     do i1=0 to m2
        i1a=i1+height1-m2
        newimg.i1=img2.i1a
     end /* do */
     if rleft<2 then do
        do i2a=0 to rleft-1
          newimg.i2=img1.i2a
        end /* do */
     end
     else do
       rleft=(height1-1)-(m2)
       rfact=(height1-1)/(max(1,(rleft-1)))
       do i2=1 to rleft                 /* squoosh vertically */
          i2a=trunc((i2-1)*rfact)
          i22=m2+i2
          newimg.i22=img1.i2a
       end /* do */
     end
     if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

     a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)
     img_name='newimg.'
     a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
     aa=aa||a4||a5
     if cycle=1 then  cycleaa=a4||a5||cycleaa
  end
end /* do */


when cctype="BALLOON" & balloon_type<>4 then do
   ixcenter=trunc(width1*centerx)
   if ixcenter<0 | ixcenter>(width1-1) then ixcenter=trunc(width1/2)
   iycenter=trunc(height1*centery)
   if iycenter<0 | iycenter>(height1-1) then iycenter=trunc(height1/2)
   d1=dist3(ixcenter,iycenter,,balloon_type)
   d2=dist3(width1-ixcenter,iycenter,,balloon_type)
   d3=dist3(ixcenter,height1-iycenter,,balloon_type)
   d4=dist3(width1-ixcenter,height1-iycenter,,balloon_type)
   mrad=max(d1,d2,d3,d4)
   radstep=mrad/nframes

   do mm=1 to min(nframes,stop_after)                   /*use all of img2 with userad of ixcenter,iycenter*/
      userad=trunc(radstep*mm)
      call dosay " Drawing frame " mm " with "balname.balloon_type" radius = " userad '(center of 'ixcenter iycenter')'
      userad2=userad*userad
      do ir=0 to height1-1  
         arow1=img1.ir
         arow2=img2.ir
         dy=abs(ir-iycenter)
         doit1=0
         do ic=0 to width1-1    
            dd=dist3(ic-ixcenter,ir-iycenter,,balloon_type)    
            if dd<userad then do 
               doit1=1
               aca=substr(arow2,ic+1,1)
               arow1=overlay(aca,arow1,ic+1,1)
            end
            else do
               if doit1=1 then leave   /* no more arow2 possible */
            end /* do */
         end            /* ic loop */
         newimg.ir=arow1
      end /* do */

     if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

      a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)
      img_name='newimg.'
      a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
      aa=aa||a4||a5
      if cycle=1 then  cycleaa=a4||a5||cycleaa
   end /* do */
end /* do */


when cctype="BALLOON" & balloon_type=4 then do
   ixcenter=trunc(width1*centerx)
   if ixcenter<0 | ixcenter>(width1-1) then ixcenter=trunc(width1/2)
   iycenter=trunc(height1*centery)
   if iycenter<0 | iycenter>(height1-1) then iycenter=trunc(height1/2)
   d1=dist3(ixcenter,iycenter,,balloon_type)
   d2=dist3(width1-ixcenter,iycenter,,balloon_type)
   d3=dist3(ixcenter,height1-iycenter,,balloon_type)
   d4=dist3(width1-ixcenter,height1-iycenter,,balloon_type)
   mrad=max(d1,d2,d3,d4)
   radstep=mrad/nframes

   do mm=1 to min(nframes,stop_after)                   /*use all of img2 with userad of ixcenter,iycenter*/
      userad=max(1,trunc(radstep*mm))
      call dosay btype2.balloon_push " frame " mm " with "balname.balloon_type" radius = " userad '(center of 'ixcenter iycenter')'
      userad2=userad*userad
      IF TRANSLATE(BALLOON_PUSH)='OVERWRITE' then BALLOON_PUSH=0
      if translate(balloon_push)='PUSH' then balloon_push=10
      if translate(balloon_push)='SQUOOSH' then balloon_push=20

      do ir=0 to (iycenter-userad)
         if balloon_push=0 | balloon_push=10 | balloon_push=20 then do
                newimg.ir=img1.ir
                iterate
          end
          if balloon_push=1 then do
             ir0=ir+userad
             newimg.ir=img1.ir0
          end /* do */
          if balloon_push=2 then do
             dnm=max(iycenter-userad,1)
             ki=(height1-1)/dnm  
             kii=trunc(ki*ir)
             newimg.ir=img1.kii
          end /* do */
      end /* do top */

      do ir=max(0,1+iycenter-userad) to min(height1-1,iycenter+userad)
         arow1=img1.ir
         arow2=img2.ir
         dy=abs(ir-iycenter)
         if balloon_push=0 then do      /* euclidean replace */
             if dy>userad then do           /* too far away in rowspace */
                newimg.ir=arow1
                iterate
            end 
            t1=trunc(sqrt(userad2-(dy*dy)))+1
            m1=ixcenter-t1 ; m2=ixcenter+t1
            if m1<2 & m2>=width1 then do         /* full line */
              newimg.ir=arow2
              iterate
            end /* do */
            if m1<2  then do     /* but not full line */
               newimg.ir=left(arow2,m2)||substr(arow1,m2+1)
               iterate
            end                 /* else, right end of line */
            if m1>1 & m2>=width1  then do
               newimg.ir=left(arow1,m1)||substr(arow2,m1+1)
               iterate
            end                 /* else, original image on both sides of row */
            newimg.ir=left(arow1,m1)||substr(arow2,m1+1,m2-m1)||substr(arow1,m2+1)
            iterate
         end

         if balloon_push=1 | balloon_push=10 then do      /* euclidean push */
            t1=trunc(sqrt(userad2-(dy*dy)))+1
            m1=ixcenter-t1 ; m2=ixcenter+t1
            if m1<2 & m2>=width1 then do         /* full line */
              newimg.ir=arow2
              iterate
            end /* do */
            if m1<2  then do     /* but not full line */
              p1=squoosh_row(arow2,m2)
              newimg.ir=left(p1||substr(arow1,ixcenter),width1)
              iterate
            end                 /* else, right end of line */
            if m1>1 & m2>=width1  then do
              p2=squoosh_row(arow2,width1-m1)
              newimg.ir=substr(arow1,ixcenter-m1,m1)||p2
              iterate
            end                 /* else, original image on both sides of row */
            p1=substr(arow1,ixcenter-m1,m1)
            p2=squoosh_row(arow2,1+m2-m1)
            p3=substr(arow1,ixcenter)
            newimg.ir=left(p1||p2||p3,width1)
            iterate
        end

        if  balloon_push=2 | balloon_push=20 then do      /* euclidean squoosh */
            t1=trunc(sqrt(userad2-(dy*dy)))+1
            m1=ixcenter-t1 ; m2=ixcenter+t1
            if m1<2 & m2>=width1 then do         /* full line */
              newimg.ir=arow2
              iterate
            end /* do */
            if m1<2  then do     /* but not full line */
              p1=squoosh_row(arow2,m2)
              p2=substr(arow1,ixcenter)
              newimg.ir=p1||squoosh_row(p2,width1-length(p1))
              iterate
            end                 /* else, right end of line */
            if m1>1 & m2>=width1  then do
              p2=squoosh_row(arow2,width1-m1)
              p1=squoosh_row(left(arow,ixcenter),m1)
              newimg.ir=p1||p2
              iterate
            end                 /* else, original image on both sides of row */
            p1=squoosh_row(left(arow1,ixcenter),m1)
            p2=squoosh_row(arow2,1+m2-m1)
            newimg.ir=p1||p2
            ip3=width1-(length(p1)+length(p2))
            if ip3>0 then
               newimg.ir=newimg.ir||squoosh_row(substr(arow1,ixcenter),ip3)
            iterate
        end
      end                /* iycenter-userad ... iycenter + userad */

      do ir=max(0,iycenter+userad+1) to height1-1  
         if balloon_push=0 | balloon_push=10 | balloon_push=20 then do
                newimg.ir=img1.ir
                iterate
          end
          if balloon_push=1 then do
             ir0=iycenter+(ir-(iycenter+userad+1))
             newimg.ir=img1.ir0
          end /* do */
          if balloon_push=2 then do
             ira=ir-(iycenter+userad+1)
             dnm=max((height1-1)-(iycenter+userad+1),1)
             ki=(height1-1)/(dnm)   
             kii=trunc(ki*ira)
             newimg.ir=img1.kii
          end /* do */
      end /* do bottom */

     if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

      a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)
      img_name='newimg.'
      a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
      aa=aa||a4||a5
      if cycle=1 then  cycleaa=a4||a5||cycleaa
   end /* do */
end /* do */


when cctype="DISSOLVE" then do
   do Rmm=0 to height1-1         /* create a "DISSOLVE" mask */
      brow=''
      do nn=1 to width1
         brow=brow||d2c(random(1,100))
      end
      mask.Rmm=brow
   end
   ijump=100/(nframes+1)
   nwd=words(dissolve_spec)
   do jj=1 to min(nframes,stop_after)     
      pp=trunc(jj*ijump)
      if nwd<=1 then do
         thresh=d2c(pp)
      end
      else do           /* do a linear interpolation */
          jw=(pp/100)*(1+nwd)
          jw1=trunc(jw)
          select
            when jw1=0 then do
                pc1=0 ; pc2=strip(word(dissolve_spec,1))
            end 
            when jw1>=NWD then do
               pc1=strip(word(dissolve_spec,NWD)) ; PC2=100
            end 
            otherwise do
                pc1=strip(word(dissolve_spec,jw1)) 
                pc2=strip(word(dissolve_spec,jw1+1)) 
            end
          end
          thr=pc1+((jw-jw1)*(pc2-pc1))
          thr=trunc(max(0,min(thr,100)))
          thresh=d2c(thr)
      end /* do */
      call dosay " DISSOLVE: Writing frame with " pp"% threshold "
      do ir=0 to height1-1
         arow1=img1.ir
         arow2=img2.ir
         msk1=mask.ir
         do ic=1 to width1    /*replace elements of arow1 if within userad */
            if substr(msk1,ic,1)<thresh then do
               acb=substr(arow2,ic,1)
               arow1=overlay(acb,arow1,ic,1)
            end /* do */
         end
         newimg.ir=arow1
      end /* do */
     if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

      a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)
      img_name='newimg.'
      a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
      aa=aa||a4||a5
      if cycle=1 then  cycleaa=a4||a5||cycleaa
  end /* do */
end /* do */



when cctype="FADE" then do
   ijump=1/(nframes+1)
   do jj=1 to min(nframes,stop_after) 
      pp=ijump*jj
      call dosay " FADE: Writing frame with " trunc(100*pp)"% distance "
      do ir=0 to height1-1
         arow1=img1.ir
         arow2=img2.ir
         do ic=1 to width1    /*replace elements of arow1 if within userad */
            ac1=c2d(substr(arow1,ic,1))
            ac2=c2d(substr(arow2,ic,1))
            if ac1=ac2 then do
                iterate                 /* no need to change */
            end
            SELECT
              when  fade_type=2 then DO
                   typ1=ctnew2.!class.ac1
                   typ2=ctnew2.!class.ac2
                   rte='!'||typ1||typ2      /* which route to look in */
                   RTE=RTES.RTE      /* GR=RG, ETC. */
                   n1=ctnew2.rte.ac1        /* position of color 1 in route */
                   n2=ctnew2.rte.ac2        /* position of color 2 */
                   dn=n1+trunc((n2-n1)*pp)  /* somewhere between, in route */
                   dd=ctrs.rte.dn           /* and the ctnew2. value of this inbetween */
              END
              WHEN fade_type=3 then DO
                    R1=CTNEW2.!r.AC1;G1=CTNEW2.!G.AC1;B1=CTNEW2.!b.AC1    
                    R2=CTNEW2.!r.AC2;G2=CTNEW2.!G.AC2;B2=CTNEW2.!b.AC2    
                    DR=PP*(R2-R1) ; DG=PP*(G2-G1) ; DB=PP*(B2-B1)
                    R3=TRUNC(R1+DR) ; G3=TRUNC(G1+DG) ; B3=TRUNC(B1+DB)

                    dd=d2c(get_region(r3,g3,b3,nregions))

                    arow1=overlay(dd,arow1,ic,1)
                    iterate
              end 
              otherwise  do       /* just use the "sorted" color table */
                  dd=use_sorted_ct(ac1,ac2,pp,fade_type) /* uses sorted_ct. */
              end
            end  /* select */
            arow1=overlay(d2c(dd),arow1,ic,1)
         end                    /* this row */
         newimg.ir=arow1
      end /* do */
     if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

      a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)
      img_name='newimg.'
      a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
      aa=aa||a4||a5
      if cycle=1 then  cycleaa=a4||a5||cycleaa
  end /* do */
end /* do */


when cctype="OVERWRITE" & CURTAIN_TYPE="L_R" then do
   ijump=width1/(nframes+1)
   do jj=1 to min(nframes,stop_after)     
      pp=trunc(jj*ijump)

      call dosay " CURTAIN: Swiping to "pp
      do ir=0 to height1-1
         arow1=img1.ir
         arow2=img2.ir
         newimg.ir=substr(arow2,1,pp)||substr(arow1,pp+1)
      end /* do */

      if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

      a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)
      img_name='newimg.'
      a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
      aa=aa||a4||a5
      if cycle=1 then  cycleaa=a4||a5||cycleaa
  end /* do */
end /* do */

when cctype="PUSH" & CURTAIN_TYPE="L_R" then do
   ijump=width1/(nframes+1)
   do jj=1 to min(nframes,stop_after)     
      pp=trunc(jj*ijump)
      call dosay  "  PUSH: Pushing column to "pp
      do ir=0 to height1-1
         arow1=img1.ir
         arow2=img2.ir
         newimg.ir=left(right(arow2,pp)||arow1,width1)
      end /* do */

     if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

      a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)
      img_name='newimg.'
      a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
      aa=aa||a4||a5
      if cycle=1 then  cycleaa=a4||a5||cycleaa
  end /* do */
end /* do */

when cctype="SQUOOSH" & CURTAIN_TYPE="L_R" then do
   ijump=width1/(nframes+1)
   do jj=1 to min(nframes,stop_after)     
      pp=trunc(jj*ijump)
      call dosay " SQUOOSH: Squooshing left  "pp
      do ir=0 to height1-1
         arow1=img1.ir
         arow2=img2.ir
         p1=right(arow2,pp)
         p2=squoosh_row(arow1,width1-pp)
         newimg.ir=p1||p2
      end /* do */

     if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

      a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)
      img_name='newimg.'
      a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
      aa=aa||a4||a5
      if cycle=1 then  cycleaa=a4||a5||cycleaa
  end /* do */
end /* do */



when cctype="OVERWRITE" & CURTAIN_TYPE="MIDDLE" then do
   ijump=width1/(nframes+1)

   do jj=1 to min(nframes,stop_after)     
      pp=trunc(jj*ijump/2)
      call dosay " CURTAIN: Curtain to "pp
      do ir=0 to height1-1
         arow1=img1.ir
         arow2=img2.ir
         p1=left(arow2,pp)
         p3=right(arow2,pp)
         p2=substr(arow1,pp+1,width1-2*pp)
         newimg.ir=p1||p2||p3
      end /* do */

     if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

      a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)

      img_name='newimg.'
      a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
      aa=aa||a4||a5
      if cycle=1 then  cycleaa=a4||a5||cycleaa
  end /* do */
end /* do */

when cctype="SQUOOSH" & CURTAIN_TYPE="MIDDLE" then do
   ijump=width1/(nframes+1)

   do jj=1 to min(nframes,stop_after)     
      pp=trunc(jj*ijump/2)
      half=trunc(width1/2)
      call dosay " SQUOOSH: SQUOOSH to "pp
      do ir=0 to height1-1
         arow1=img1.ir
         arow2=img2.ir
         p1=substr(arow2,half-pp,pp)
         p3=substr(arow2,half,pp)
         p2=squoosh_row(arow1,width1-(2*pp))
         newimg.ir=p1||p2||p3
      end /* do */

     if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

      a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)
      img_name='newimg.'
      a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
      aa=aa||a4||a5
      if cycle=1 then  cycleaa=a4||a5||cycleaa
  end /* do */
end /* do */

when cctype="PUSH" & CURTAIN_TYPE="MIDDLE" then do
   ijump=width1/(nframes+1)

   do jj=1 to min(nframes,stop_after)     
      pp=trunc(jj*ijump/2)
      half=trunc(width1/2)
      call dosay " PUSH: to "pp
      do ir=0 to height1-1
         arow1=img1.ir
         arow2=img2.ir
         p1=substr(arow2,half-pp,pp)
         p3=substr(arow2,half,pp)

         irem=width1-2*pp
         IREM2=TRUNC(IREM/2)
         p2=LEFT(AROW1,IREM2)||RIGHT(AROW1,IREM-IREM2)
         newimg.ir=p1||p2||p3
      end /* do */

     if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

      a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)
      img_name='newimg.'
      a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
      aa=aa||a4||a5
      if cycle=1 then  cycleaa=a4||a5||cycleaa
  end /* do */
end /* do */



when cctype="MASK" then do           /*use the mask files */
   do jSj=1 to mask.0
     call dosay " MASK: Using Maskfile " mask.jsj
     acthresh=d2c(mask.jSj.!thresh)
      if is_cgi<>2 then do
          if pos(':',amask.jsj)>0 then DO
             call dosay "BlendGIF error: an absolute filename is not allowed: "amask.jsj
             return 0
          end /* do */
          amask.jsj=strip(translate(strip(amask.jsj),'\','/'),'l','\')
      end /* do */
     amask=read_giffile(mask.jSj,BLENDGIF_ROOT)
     if amask=0 then return 0
     ab=read_gif_block(amask,1,'LSD',1)        /* get logical screen descriptor */
     ct_name='lct.'                          /* extract info from it */
     stuff=read_lsd_block(ab)
     parse var stuff mwidth mheight  .
     img_name='mimg.'
     ab=read_gif_block(amask,1,'IMG',1)
     stuff=read_image_block(ab,1)
     if stuff=0 then do
         call dosay "Problem with " mask.jsj
         exit       
     end
/* might need to replicate, or shrink */
     if mheight<height1 then do         /* add rows */
        mh0=mheight
        kat=mheight
        do until kat=height1
          do kat2=0 to mh0-1
             mimg.kat=mimg.kat2
             kat=kat+1
             if kat=height1 then leave
          end
        end 
     end                /* MHEIGHT< HEIGFHT1 */
     dx=width1-mwidth             /* add or subtract columns */
     if dx<0 then dx=0
     fct=trunc(0.99+(dx/mwidth))+1
     do kr=0 to height1-1
           mimg.kr=left(copies(mimg.kr,fct),width1)
     end 
     do ir=0 to height1-1              /* now mask the image */
         arow1=img1.ir
         arow2=img2.ir
         mrow=mimg.ir
         do ic=1 to width1    /*replace elements of arow1 if msk1>mask.!thresh */
            if substr(mrow,ic,1)>acthresh then do
               aca=substr(arow2,ic,1)
               arow1=overlay(aca,arow1,ic,1)
            end 
         end            /* I=1 TO WIDTH1 */
         newimg.ir=arow1
     end                 /* IR=0 TO HEIGHT-1 */

     if img2_trans=1 then call do_fix_trans   /* enforce transparency of "transformed" image 2 */

     a4=MAKE_GCE_BLOCK(0,0,adelay,adisposal0,0)
     img_name='newimg.'
     a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
     aa=aa||a4||a5
     if cycle=1 then  cycleaa=a4||a5||cycleaa
  end                   /* get next mask file */     
end             /* MASK */


otherwise nop

end

/* if transformed image, and nframes< stop_after, then write original transformed image */
if cctype<>"ADD"  & img2_trans=1 & (nframes<stop_after | stop_after=0) then do
     do i1=0 to height1-1
        newimg.i1=img2.i1
     end /* do */
     itt=0
     call do_fix_trans   /* enforce transparency of "transformed" image 2 */
     tcflag3=tcflag.ido2
     if no_transparent>0 then tcflag3=0
     a4=MAKE_GCE_BLOCK(tcflag3,tcindex.ido2,adelay,adisposal0,0)
     img_name='newimg.'

     a5=make_image_block(0,0,width1,height1,0,0,interl.1,0,0)  /* local ct NOT specified */
     aa=aa||a4||a5
     if cycle=1 then  cycleaa=a4||a5||cycleaa
end /* do */


return 1

eek1err:
say " ERROR at " sigl ' ' rc
exit

/*************************/
/*do any of this image specific transformations have multiple parameters */
ismany_transforms:procedure expose  nuheight. nuwidth. xmove. ymove. ,
                               zrotate. yrotate. xrotate. 
parse arg ijj
if words(nuheight.ijj) >1 then return 1
if words(nuwidth.ijj) >1 then return 1
if words(xmove.ijj) >1 then return 1
if words(ymove.ijj) >1 then return 1
if words(zrotate.ijj) >1 then return 1
if words(yrotate.ijj) >1 then return 1
if words(xrotate.ijj) >1 then return 1
return 0



/***********************************/
/* overlay strings, using a mask */
/* The mask should have 00 and ff bytes. 
   A "00" bytes means "use string 1 byte"
   A "11" byte means "use string 2 byte"

mess1: string 1
mess2: string 2
cmask: the "00 / ff" mask 

All 3 of these MUST be the same size! 

*/
overlay_strings:procedure
parse arg mess1,mess2,cmask


ch1=d2c(255)

/* if imask is 1, use mess 2 character. Else, use mess 1 character */
use1=bitand(mess2,cmask)
cmaskn=bitxor(cmask,ch1,ch1)            /* reverse of cmask (flip 1s and 0s */
use2=bitand(mess1,cmaskn)
newmess=bitor(use1,use2)
return newmess


/**********************************/
/* enforce transparency of "transformed" image2:
  a)for all pixels in newimg
  b)if corresponding pixel trmask = 0, then 
      reset newimg pixel to corresponding pixel from img1
*/
do_fix_trans:

do ki=0 to height1-1
   msk1=trmask.ki
   old1=img1.ki
   new1=newimg.ki
   newimg.ki=overlay_strings(old1,new1,msk1)
end /* do */
return 1


/********************************/
/******** PROCEDURES USED BY FADE ANIM_TYPE *****/
/********************************/

/********************/
/* return a region, give a color table position */
get_region:procedure expose reglist. is_cgi BLENDGIF_ROOT save_tempfile
parse arg ar,ag,ab,nregions
regsize=trunc(256/nregions)
ir=min(1+trunc(ar/regsize),nregions)
ig=min(1+trunc(ag/regsize),nregions)
ib=min(1+trunc(ab/regsize),nregions)
nn=reglist.ir.ig.ib

return nn

/***************************/
/* find color closest to rgb (in ctnew2) */
find_color:procedure expose ctnew2. is_cgi BLENDGIF_ROOT  save_tempfile
parse arg ar,ag,ab,try1,regsize
tr=ctnew2.!r.try1
tg=ctnew2.!g.try1
tb=ctnew2.!b.try1
dst=dist3(tr-ar,tg-ag,tb-ab)
igot=try1
dstsec=0
do mm=1 to ctnew2.0-1
   if mm=try1 then iterate
   dr=abs(ctnew2.!r.mm-ar)
   dg=abs(ctnew2.!g.mm-ag)
   db=abs(ctnew2.!b.mm-ab)
   if max(dr,dg,db)>dst then iterate
   a1=max(dr,dg)
   a2=min(dr,dg)
   d1=(a1+(a2/2))
   a1=max(abs(d1),abs(db))
   a2=min(abs(d1),abs(db))
   tdst=(a1+(a2/2))
   if tdst<dst then do
       dstsec=dst-tdst
       dst=tdst ;  igot=mm
       if dst<regsize then return igot regsize
   end
end
return igot dstsec

/***************************/
/* create match array for rgb regions */
make_regions:procedure expose ctnew2. reglist. is_cgi BLENDGIF_ROOT  save_tempfile
parse arg nregions

reglist.=0
gg=1
regsize=trunc(256/nregions)
add1=trunc(regsize/2)
do ir=1 to nregions
   call dosay "  " ir " of "nregions " reference layers (fade lookup table)"
   do ig=1 to nregions
      distsec=0
      do ib=1 to nregions
            if distsec>regsize then do
               reglist.ir.ig.ib=gg
               distsec=distsec-regsize
            end /* do */
            else
            ur=(ir-1)*regsize+add1
            ug=(ig-1)*regsize+add1
            ub=(ib-1)*regsize+add1
            agg=find_color(ur,ug,ub,gg,regsize)
            parse var agg gg distsec
            reglist.ir.ig.ib=gg
       end /* do */
   end
end
return 1



/***************************/
/* assign "close colors" to each 32x32x32 cell of color table space */
/* this has been superseded by make_regions */
make_matchinfos:procedure expose minfos. ctnew2. verbose is_cgi BLENDGIF_ROOT  save_tempfile

csize=dist3(8,8,8)
csize2=csize/2
ir0=0
a80=60

do ir=8 to 255 by 16          
 ir0=1+ir0 ; ig0=0
 do ig=8 to 255 by 16
  ig0=1+ig0 ; ib0=0
  do ib=8 to 255 by 16
    ib0=1+ib0
    drop act.; act.0=0
    do mm=1 to ctnew2.0-1
      dr=abs(ctnew2.!r.mm-ir) ; dg=abs(ctnew2.!g.mm-ig) ;db=abs(ctnew2.!b.mm-ib)
      if max(dr,dg,db)>a80 then iterate
      adist=trunc(dist3(dr,dg,db))
      if adist<csize2 then do           /* close enough */
         minfos.ir0.ig0.ib0=mm
         iterate ib
      end
      jact=act.0+1
      act.jact=left(mm,5)||left(adist,8)
      act.0=jact
    end 
    if act.0=0 then do  /* nothing close, do again no restrictiosn */
      do mm=1 to ctnew2.0-1
        a80=a80+5
        dr=abs(ctnew2.!r.mm-ir) ; dg=abs(ctnew2.!g.mm-ig) ;db=abs(ctnew2.!b.mm-ib)
        adist=trunc(dist3(dr,dg,db))
        act.mm=left(mm,5)||left(adist,8)
        act.0=act.0+1
      end 
    end
    foo=arraysort(act,1,,6,8,'A','N')
    parse var act.1 jmm ascor
    keepers=jmm 
    athresh=ascor+csize
    do mm=2 to act.0
      parse var act.mm jmm ascor
      if ascor>athresh then leave
      keepers=keepers' 'jmm
    end
    minfos.ir0.ig0.ib0=keepers
  end /* do */
 end /* do */
 call dosay "   Building pre-search ctable for " ir
end /* do */
return 1


/***************************/
/* classify a color into one of:
  W (black and white)
  R G B (red green blue)
  C M O (cyan (gb), magenta (rb), orange (rg)
*/
classify_color:procedure 
parse arg ar,ag,ab

/* a grey scale */
if max(abs(ar-ab),abs(ar-ag),abs(ab-ag))<10 then return 'W'  

if ar> 0.8*(ag+ab)  then return 'R'
if ag> 0.8*(ar+ab)  then return 'G'
if ab> 0.8*(ar+ag)  then return 'B'

if ag>ar & ab>ar  then return 'C'
if ar>ag & ab>ag  then return 'M'

return 'O'            /* ar>ab & ag>ab (O) is the default */


/********************************/
/* make  ctrs. (ct-routes), and pointers from ctnew2. to ctrs. */
make_ctroutes:procedure expose ctrs. ctnew2. RTES.

combos='WW RR GG BB CC MM OO '|| ,
       '   WR WG WB WC WM WO '|| ,
       '      RG RB RC RM RO '|| ,
       '         GB GC GM GO '|| ,
       '            BC BM BO '|| ,
       '               CM CO '|| ,
       '                  MO '
isum=0

DO MM=1 TO WORDS(COMBOS)
   AW=STRIP(WORD(COMBOS,MM))
   AW2='!'||AW
   RTES.AW2=AW2
   AW3='!'||REVERSE(AW)
   RTES.AW3=AW2
END

ctrs.=0
ctnew2.!class.0='W'
DO mm=1 TO CTNEW2.0-1           /* classify each color */
   ar=ctnew2.!r.mm ; ag=ctnew2.!g.mm ; ab=ctnew2.!b.mm
   CTNEW2.!class.mm=classify_color(ar,ag,ab)
end /* do */

wnc=words(combos)
do Rii=1 to wnc
   a1=strip(word(combos,Rii))

   a1a=left(a1,1); a1b=right(a1,1)
/* find all colors that classify into a1a or a1b */
   drop tct.
   tct.0=0 ; a1as=0; a1bs=0
   do mm=0 to ctnew2.0-1
      ttype=ctnew2.!class.mm
      ar=ctnew2.!r.mm ; ag=ctnew2.!g.mm ; ab=ctnew2.!b.mm
      if ttype=A1A & a1a<>a1b then do      /* - value for very much a1a */
         scor=-fig_color_score(ttype,ar,ag,ab)
         itct=tct.0+1
         tct.itct=left(mm,5)||left(scor,8)
         tct.0=itct
         a1as=a1as+1
       end
       if ttype=A1B  then do
         scor=fig_color_score(ttype,ar,ag,ab)
         itct=tct.0+1
         tct.itct=left(mm,5)||left(scor,8)
         tct.0=itct
         a1bs=a1bs+1
       end
    end                 /* grabbing candidate colors */
    if a1as+a1bs=0 then iterate      /* neither of either color */
    if a1a<>a1b & a1as*a1bs=0 then iterate /* one of 2 colors is missing */
    ta1='!'||a1         /* fill these tails */
    ta2='!'||a1b||a1a

    foo=arraysort(tct,1,,6,8,'A','N')
    if foo=0 then do 
          call dosay "ARRAYSORT failure "
          return 0
    end /* do */
/* normalize scores between 0 and 100 */

    tnn=tct.0
    if tnn<=1 then iterate   /* 1 element, no need for table */
    parse var tct.1 . smin
    parse var tct.tnn . smax
    dif=smax-smin
    do nn=1 to tct.0                    /* creating 1..101 ctable */
       parse var tct.nn jmm asco
       tct.nn=jmm
       if asco-smin=0 then
           kikw=1
       else
          kikw=trunc(100*(asco-smin)/dif)+1  /* 1 to 101 */
       tct.nn.!sc=kikw
       ctnew2.ta2.jmm=tct.nn.!sc
       if ta1<>ta2 then ctnew2.ta1.jmm=tct.nn.!sc
    end 

    atct.=0
    do nn=1 to tct.0            /* fill know values  */
       nn2=trunc(tct.nn.!sc)
       atct.nn2=tct.nn 
    end

    iwas=atct.1                 /*now fill in gaps */
    do nn=1 to 101
       if atct.nn=0 then 
          atct.nn=iwas
       else
          iwas=atct.nn
    end /* do */ 
    do nn=1 to 101                      /* now record this normalized/expanded ct */
          jmm=atct.nn
          ctrs.ta1.nn=jmm
          if a1a<>a1b then  ctrs.ta2.nn=jmm
    end /* do */

end /* do */
return 1

/**************************/
/* compute a color intensity score */
fig_color_score:procedure
parse arg ttype,rr,gg,bb

select
   when ttype='W' then return (rr+gg+bb)/3   
   when ttype='R' then return rr
   when ttype='G' then return GG
   when ttype='B' then return bb
   when ttype='C' then return (bb+gg)/2
   when ttype='M' then return (rr+bb)/2
   otherwise return (gg+rr)/2                   /* O is the default */
end


/*****************************/
/* FIND COLOR CLOSE TO R,G,B; USING MINFOS. ARRAY TO SPEED THINGS UP */
FIND_CLOSEST:procedure expose minfos. ctnew2.
parse arg ar,ag,ab

ir=min(1+trunc(ar/16),16)
ig=min(1+trunc(ab/16),16)
ib=min(1+trunc(ag/16),16)

ilook=minfos.ir.ig.ib
if words(ilook)=1 then return ilook
adist=111111
do mm=1 to words(ilook)
   jmm=strip(word(ilook,mm))
   br=ctnew2.!r.jmm ; bg=ctnew2.!g.jmm ; bb=ctnew2.!b.jmm
   adist2=dist3(ar-br,ag-bg,ab-bb)
   if adist2<adist then do
      adist=adist2 ; iuse=jmm
   end
end
return iuse



/********************************/
/****** CT CREATION PROCEDURES  ***************/
/********************************/

/****************************************/
/* Combine and shrink cts.  Returns checked2. and ctnew2.  */
 
make_new_ctable:procedure expose ctnew2. checked2. verbose cts. is_cgi BLENDGIF_ROOT verbose ,
                                r_back g_back b_back   save_tempfile

parse arg ct_newlen,npixels,usesrch

rmin=0;gmin=0;bmin=0;rmax=255;bmax=255;gmax=255 /* search bounds */

/*a) combine the several color tables, discard unused colors (create ctnew.)*/

call combine_cts
call dosay " total used & unique colors " ctnew.0 
if ctnew.0+1 <= ct_newlen then do
   usesrch=0
   ct_newlen=ctnew.0+1
end /* do */


/*b) shrink combined color table to  ct_newlen 
       ctnew2. = the new "shrunken" color table
       checked2. = points from rgb to newcolor table 
*/

ctnew2.!r.0=r_back ; ctnew2.!g.0=g_back ; ctnew2.!b.0=b_back       /* 0 is for transparent color */
ctnew2.0=1
checked2.=0                     /* setup pointer from rgb to ctnew2 */

/*c) find most frequent pixel value, that will be the #1 color */
pmax=find_frequent(1,0)
if verbose>0 then call dosay "  Most freq color occurs " pmax  " times "

unacc=npixels-pmax             /* unaccounted for pixels */

select
 when usesrch=0 then mx1=ct_newlen-1
 when usesrch=1 then mx1=trunc(.66*ct_newlen)
 otherwise mx1=trunc(ct_newlen*0.40)
end

/* 3b.ii) now, fill up to 1/2 of ctnew2 with "frequent" colors */
do nc=2 to mx1
  if usesrch=2 then
     n2=find_frequent(nc,unacc/(ct_newlen-nc))
  else
     n2=find_frequent(nc,0)
  if n2=0 then do
       leave            /* no winner */
    end
  unacc=unacc-n2
end

if verbose>0 then 
   call dosay "  "ctnew2.0-1 " frequent colors (unaccounted for pixels= " unacc

/* d) Initialize distances of ctnew colors */
foo=reset_dist(ctnew2.!r.1,ctnew2.!g.1,ctnew2.!b.1,1,1)

/* e) For  remaining colors in ctnew2, compute the "set of miniumum distances"
   of colors in ctnew */

totre=0
do mm=3 to ctnew2.0-1
   totre=totre+reset_dist(ctnew2.!r.mm,ctnew2.!g.mm,ctnew2.!b.mm,mm)
end /* do */
if verbose>0 then call dosay "  Total number of distance resets " totre


/* f) search for 3-color values that remove the most distance  */

totdist=0
do mm0=0 to ctnew.0-1
     totdist=totdist+(ctnew.!ct.mm0*ctnew.!dist.mm0)
end /* do */
if verbose>0 then call dosay "Total distance to explain: " totdist

athresh=0
if usesrch=1 then athresh=40
ijf=ctnew2.0
do iat=ijf to ct_newlen-1
  saves=make_colors_search(128,128,128,128,iat,athresh)
  if saves=0 then leave                         /* couldn't improve */
end

/* g) try frequent colors again (or all, if usesrch=1*/
unacc=0
do kk=0 to ctnew.0-1
   ir=ctnew.!r.kk ; ig=ctnew.!g.kk ; ib=ctnew.!b.kk
   if checked2.ir.ig.ib=0 then do
       unacc=unacc+ctnew.!ct.kk
   end
end /* do */
if verbose>0 then call dosay " Currently unaccounted for = " unacc

iz=ctnew2.0
do nc=iz to ct_newlen-1
  if usesrch=1 then
     n2=find_frequent(nc,0)
  else
     n2=find_frequent(nc,unacc/(ct_newlen-nc))
  unacc=unacc-n2
  if n2=0 then leave            /* no winner */
  lastdid=nc
end

if verbose>0 then call dosay "Colors in new table = " ctnew2.0

/* reset distance again */
totre=0
do mm=iz to ctnew2.0-1
   totre=totre+reset_dist(ctnew2.!r.mm,ctnew2.!g.mm,ctnew2.!b.mm,mm)
end /* do */
if verbose>0 then call dosay " Total number of distance resets " totre

/* h) binary search again */
iz=ctnew2.0
do iat=iz to ct_newlen-1
  axx=make_colors_search(120,120,120,128,iat)
  if axx=0 then leave
end 

/* i) fill up with frequents */
iz=ctnew2.0
do nc=iz to ct_newlen-1
  n2=find_frequent(nc,0)
  unacc=unacc-n2
end

/* reset distance again */
totre=0
do mm=iz to ctnew2.0-1
   totre=totre+reset_dist(ctnew2.!r.mm,ctnew2.!g.mm,ctnew2.!b.mm,mm)
end /* do */

/* CHECKED2. will contain cntains pointers from rgb values
   to CTNEW2 (the new color table) */

/* i) define REMAPS */
DO MM=0 TO CTNEW.0-1
   INEW=CTNEW.!NEW.MM
   kr=ctnew.!r.mm ; kg=ctnew.!g.mm ; kb=ctnew.!b.mm
   checked2.kr.kg.kb=inew    
end /* do */

return 1

exit

/**************************/
/* use binary search to find best colors */
make_colors_search:procedure expose ctnew. ctnew2. checked2. rmin rmax gmin gmax bmin bmax verbose is_cgi BLENDGIF_ROOT  save_tempfile
parse arg r1,g1,b1,size,iat,athresh

if athresh='' then athresh=0

saves=-1; 
drop checked.
checked.=0

do iii=1 to 8           /* 2**8 = 256 */
   foo=points_8(r1,g1,b1,size)            /* 8 points in 8 quadrants */

/* compute "savings" from each of these points */
   do mm=1 to 8
       ee=comp_savings(points.!r.mm, points.!g.mm,points.!b.mm)  
       if ee>saves then do 
         r1=points.!r.mm; g1=points.!g.mm ; b1=points.!b.mm ;saves=ee
       end /* do */
   end
   size=size/2 
end

if saves<=athresh then return 0   /* can't find a useful enough rgb, give up */

ctnew2.!r.iat=r1 ; ctnew2.!g.iat=g1 ; ctnew2.!b.iat=b1
ctnew2.0=iat+1
if verbose>0 then call dosay " Using color " r1 g1 b1 " explains " saves 
aa=reset_dist(r1,g1,b1,iat)
checked2.r1.g1.b1=iat
return saves



/******************************/
/* find frequent pixels, and assign them to the ctnew2.  color table
 nc= spot in ctnew2. to (possibly) set
 thresh = .!ct must exceed thresh 
*/

find_frequent:procedure expose ctnew. ctnew2. checked2. is_cgi BLENDGIF_ROOT  save_tempfile
parse arg nc,thresh                     

thresh=max(1,thresh)
amax=0
do nc2=0 to ctnew.0-1                  /* check each used color */
   rr=ctnew.!r.nc2 ; gg=ctnew.!g.nc2 ; bb=ctnew.!b.nc2
   if checked2.rr.gg.bb>0 then iterate   /* skip if already matched */
   if ctnew.!ct.nc2>amax then do
         amax=ctnew.!ct.nc2 
         rr1=rr; bb1=bb; gg1=gg ; ipt=nc2
   end /* do */
end

if amax>=thresh then do                /* the max is > thresh, record it */
     ctnew2.!r.nc=rr1
     ctnew2.!g.nc=gg1
     ctnew2.!b.nc=bb1
     checked2.rr1.gg1.bb1=nc
     ctnew.!new.ipt=nc
     ctnew.!dist.ipt=0
     ctnew2.0=nc+1                      /* account for 0th color */
     return amax
end
return 0                      /* no winner */



/****************************************/
/* 1) create ctnew from cts  */
combine_cts:procedure expose  ctnew. cts. is_cgi BLENDGIF_ROOT  save_tempfile

ctref.=0 ; ctnew.=0
do ithc=1 to cts.0
  foo=cvcopy(cts.ithc,'ct1')
  do mm=0 to ct1.0-1
    atail=d2c(ct1.!r.mm)||d2c(ct1.!g.mm)||d2c(ct1.!b.mm)
    if ctref.atail=0 then do
      i0=ctnew.0
      ctnew.!r.i0=ct1.!r.mm; ctnew.!g.i0=ct1.!g.mm; ctnew.!b.i0=ct1.!b.mm
      ctnew.0=i0+1
      ctref.atail=i0
    end /* do */
    i0=ctref.atail
    ctnew.!ct.i0=ctnew.!ct.i0+ct1.!ct.mm
  end 
end

/* Discard unused colors */
itt=0
do mm=0 to ctnew.0-1
  if ctnew.!ct.mm>0 then do
      ctemp.!r.itt=ctnew.!r.mm ; ctemp.!g.itt=ctnew.!g.mm 
      ctemp.!b.itt=ctnew.!b.mm ; 
      ctemp.!ct.itt=ctnew.!ct.mm ;  ctemp.!dist.itt=-1 ; 
      CTEMP.!NEW.ITT=-1
      itt=itt+1
      ctemp.0=itt
  end /* do */
end
drop ctnew.
foo=cvcopy('ctemp','ctnew')

return 1



/**********************/
/* reset .!dist for ctnew. */
reset_dist:procedure expose ctnew. checked2. is_cgi BLENDGIF_ROOT  save_tempfile
parse arg r0,g0,b0,icc,istart

ree=0
do mm=0 to ctnew.0-1
   ar=ctnew.!r.mm ; ag=ctnew.!g.mm ; ab=ctnew.!b.mm
   if checked2.ar.ag.ab>0 then do
       ctnew.!new.mm=checked2.ar.ag.ab
       ctnew.!dist.mm=0
       iterate
   end
   isdist=ctnew.!dist.mm
   adist=dist3(r0-ar,g0-ag,b0-ab)
   if (adist< isdist) | (istart=1) then do
      ree=ree+1
      ctnew.!dist.mm=adist 
      CTNEW.!NEW.MM=ICC
      if adist=0 then checked2.ar.ag.ab=icc
   end /* do */
end /* do */
return ree

/**********************/
/* given a candidate color, compute how much this "saves" (for colors
in ctnew */
comp_savings:procedure expose ctnew. checked. rmin rmax gmin gmax bmin bmax checked2. is_cgi BLENDGIF_ROOT  save_tempfile
parse arg r0,g0,b0

if checked.r0.g0.b0=1 then do
   return 0  /* checked this round */
end

if checked2.r0.g0.b0>0 then do
   return 0  /* useing this color */
end

if r0<rmin | r0>rmax | g0<gmin | g0>gmax | b0<bmin | b0>bmax then do
   return 0
end

checked.r0.g0.b0=1
saves=0
do mm=0 to ctnew.0-1
   ar=ctnew.!r.mm ; ag=ctnew.!g.mm ; ab=ctnew.!b.mm
   adist=dist3(r0-ar,g0-ag,b0-ab)
   if adist< ctnew.!dist.mm then saves=saves+((ctnew.!dist.mm-adist)*ctnew.!ct.mm)

end /* do */
return saves

/**********************/
/* define 8 quadrants in color cube, as defined by centers */
points_8:procedure expose points.
parse arg rc,gc,bc,isize
is2=max(1,trunc(isize/2))
points.!r.1=rc-is2 ;   points.!g.1=gc-is2 ;   points.!b.1=bc-is2
points.!r.2=rc+is2 ;   points.!g.2=gc-is2 ;   points.!b.2=bc-is2
points.!r.3=rc-is2 ;   points.!g.3=gc+is2 ;   points.!b.3=bc-is2
points.!r.4=rc+is2 ;   points.!g.4=gc+is2 ;   points.!b.4=bc-is2
points.!r.5=rc-is2 ;   points.!g.5=gc-is2 ;   points.!b.5=bc+is2
points.!r.6=rc+is2 ;   points.!g.6=gc-is2 ;   points.!b.6=bc+is2
points.!r.7=rc-is2 ;   points.!g.7=gc+is2 ;   points.!b.7=bc+is2
points.!r.8=rc+is2 ;   points.!g.8=gc+is2 ;   points.!b.8=bc+is2

return 1



/***************************************/
/* count occurences of a pixel value in an image stem array
  return in a space delimted list (nth word corresponding to nth+1 pixel value)
*/
count_pixels:procedure expose (imgname) is_cgi BLENDGIF_ROOT  save_tempfile
parse arg ncs
cts.=0
irows=value(imgname||'!rows')
icols=value(imgname||'!cols')
do ir=0 to irows-1
   arow=value(imgname||ir)
   do ic=1 to icols
      ipx=c2d(substr(arow,ic,1))
      if ipx>(ncs-1) then do
         call dosay "ERROR: pixel value greater then # colors: " ir ic ipx ncs irows icols
         exit
      end /* do */
      cts.ipx=cts.ipx+1
   end /* do */
end /* do */
goo=''
do ii=0 to ncs-1
  goo=goo||cts.ii' '
end /* do */
return goo


/**************************/
/* created sorted_ct. -- a sort index into ctnew2. 
*/

sorT_ctnew2:procedure expose ctnew2. sorted_ct. is_cgi BLENDGIF_ROOT  save_tempfile
parse arg ttype

if ttype=0 | ttype=2 | ttype=3 then return 0 /* don't need to sort ct */

/* otherwise, score and sort colors */
bri.0=ctnew2.0-1
do mm=1 to ctnew2.0-1        /* always leave 0th unchanged */
      r=ctnew2.!r.mm ; g=ctnew2.!g.mm ; b=ctnew2.!b.mm
      if ttype=1 then do
         scor=r+g+b
      end /* do */
      else do
         ff='scor='||ttype
         interpret ff
      end /* do */
      bri.mm=left(mm,5)||left(scor,8)
end /* do */
foo=arraysort(bri,1,,6,8,'A','N')
if foo=0 then do 
       call dosay "ARRAYSORT failure "
       return 0
end /* do */
do mm=1 to bri.0
   parse var bri.mm jmm .
   sorted_ct.jmm=mm      /* ctnew2.jmm is the mm'th "brightest" color */
   sorted_ct.!rev.mm=jmm  /* the mm'th brightest color is ctnew2.jmm */
end /* do */
return 1


/****** END OF CT CREATION PROCEDURE  ***************/

/********************************/
/******** GENERALLY USEFUL PROCEDURES (and INITIALIZATION PROCEDURE ****/
/********************************/

/**********************/
/* temp file in gif_dir_dir */
systempfilename2:procedure expose BLENDGIF_ROOT  save_tempfile
parse arg aname
aa=resolve_filename(aname,BLENDGIF_ROOT,,1)

bb=systempfilename(aa)

return bb



/* -------------------- */
/* choose between 3 alternatives (by default,a yes or no ), 
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

/********/
/* say or "push" a message -- but don't do nothing if cgi-bin! */
dosay:procedure expose is_cgi BLENDGIF_ROOT save_tempfile
parse arg amess
if is_cgi=2 then say amess
if is_cgi=0 then do
   if save_tempfile=1 then
      foo=sref_multi_send(amess||'0d0a'x,'text/plain','1A')
   else
      foo=sref_multi_send(amess||'0d0a'x,'text/plain','A')
   if foo<0 then do
       call pmprintf(" connection broken in blendgif")
       exit
   end /* do */
end
return 0


/********/
/* say or "push" an error message -- if cgi-bin, first write content-type line
   open as a text file */
dosay2:procedure expose is_cgi BLENDGIF_ROOT save_tempfile
parse arg amess
if is_cgi=2 then say amess              /* from command prompt */
if is_cgi=0 then do                     /* sre-http addon */
   if save_tempfile=1 then
      foo=sref_multi_send(amess||'</body></html>'||'0d0a'x,,'1E')
   else
      foo=sref_multi_send(amess||'0d0a'x,'text/plain','A')
   if foo<0 then do
       call pmprintf(" connection broken in blendgif")
       exit
   end /* do */
end
if is_cgi=1 then do                     /* cgi-bin */
   say 'Content-type: text/plain'
   say
   say amess
end /* do */
return 0


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


/********************************/
/* determine a user scale, given ith of Ilen position, and 
   list of "user_scales". We assume user_scales is a space delimited list
  of numbers. 

The algorithim: determine relative position of ilen in the 1...LLEN list
of integer values.  Then map this relative position to a relative
position in the implicit graph determined by the points listed in the
user_scales array; and read off the value at this position 
*/

get_user_scale:procedure 
parse arg ith,ilen,user_scales

if user_scales="" then return ''  /* AN ARIBRARY DEFAULT */

igoo=words(user_scales)

if igoo=1 then return user_scales  /* a trivial case */

/* More trivial, "ends", cases */
if ith=1 then return word(user_scales,1)
if ith>=ilen then return word(user_scales,igoo)

/* middle position -- determine relative position */
frac=(ith-1)/(ilen-1)    /* where in scale list is it (steps from first position*/
spot=1+ ((igoo-1)*frac)
ifrac=trunc(spot)
afrac=spot-ifrac

/* exact match (no interpolation needed */
if afrac=0 then return word(user_scales,ifrac)

/* otherwise, interpolate */
ii=ifrac+1
a1=word(user_scales,ii)
a2=word(user_scales,ifrac)

diff=a1-a2
aaa=(a2+(diff*afrac))
if pos('.',a1)+pos('.',a2)=0 then aaa=trunc(aaa)
return aaa

/************************************/
/* load dlls, etc */
init1:

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
return 0


/****************/
/* initialize parameters */
init2:
nregions=fade_regions 
nframes=frames

balname.1='Square'
balname.2='Diamond'
balname.3='Octagon'
balname.4='Circle'

adisposal=disposal
ADISPOSAL0=DISPOSAL
do_iter=iterations

gotroutes=0; gotminfos=0


/* assign defaults to unspecified .n parameers */
pnames='FRAMES STOP_AFTER ANIM_TYPE BALLOON_TYPE BALLOON_PUSH MASK_LIST  '|| ,
       'CENTERX CENTERY FADE_TYPE CURTAIN_OVERWRITE CURTAIN_TYPE DISSOLVE_SPEC FRAME_DELAY'

do nmm=1 to infile.0-1
   do njj=1 to words(pnames)
      aw=strip(word(pnames,njj))
      if symbol(aw'.'nmm)<>'VAR' | DOPAIR.Nmm<>1 then do
         arf=aw'.'nmm'='aw
         interpret arf
      end /* do */
   end /* do */
   do njj=1 to mask.0   
      if symbol('MASK.'njj'.'nmm)<>'VAR'   | DOPAIR.mm<>1 then
        mask.njj.nmm=mask.njj
      if symbol('MASK.'njj'.!thresh.'nmm)<>'VAR'   | DOPAIR.mm<>1 then
        mask.njj.!thresh.nmm=mask.njj.!thresh
   end /* do */
end /* do */


if resize_mode<>2 then do
   height1=0 ;width1=0
end /* do */

if datatype(r_back)<>'NUM' then r_back=110
if datatype(g_back)<>'NUM' then g_back=110
if datatype(b_back)<>'NUM' then b_back=110

r_back=min(max(0,r_back),255)
g_back=min(max(0,g_back),255)
b_back=min(max(0,b_back),255)

return 0


/*********************/
/* read a gif file into memory  -- possibly use socket calls to get
a gif file from da web */
read_giffile:procedure expose is_cgi BLENDGIF_ROOT  save_tempfile
parse arg giffile, BLENDGIF_ROOT
giffile=strip(giffile)
if giffile='' then do
  call charout, " Enter gif file(s): "
  pull giffile
end
if giffile='' then exit
if pos('.',giffile)=0 then giffile=giffile'.gif'  /* add the extension? */

hh=strip(translate(giffile))
if abbrev(hh,'HTTP://')=1 then do   /* get from the web */
  gifcontents=go_get_url(giffile,,verbose)
  if gifcontents='' then do
     return 0
  end /* do */
/* parse it, check content-type, then return body */
  parse var gifcontents lin1 '0d0a'x gifcontents
  parse var lin1 ap istat .
  if left(istat,1)<>'2' then return 0  /* not a 200 response */
/* scan through headers, check for content-type */
  isimg=0
  do forever
     parse var gifcontents lin1 '0d0a'x gifcontents
     if lin1='' then do
        if isimg=0 then return 0       /* no image/gif header found */
        return gifcontents
     end /* do */
     parse  upper var lin1 amime ':' amime2
     if strip(amime)='CONTENT-TYPE'  then do
        if strip(amime2)<>'IMAGE/GIF' then return 0  /* not a gif file */
        isimg=1
     end
     if gifcontents='' then return 0
  end /* do */
end /* do */


/* else, read a file into memory */
gfn=giffile
if BLENDGIF_ROOT<>'' then do
   gfn=resolve_filename(giffile,BLENDGIF_ROOT,'.GIF')
end
if gfn='' then do
   call dosay "b) no such file "||giffile
   return 0
end /* do */

igs=stream(gfn,'c','query size')
if igs=0 | igs='' then do
   call dosay "c) no such file "||giffile
   return 0
end /* do */
gifcontents=charin(gfn,1,igs)
foo=stream(gfn,'c','close')
return gifcontents 


/* ---------------------------------------------*/
/* Return a file name; given a file name and
   a root directory.  Will resolve file name, if it's
   not fully qualified
Called as:  newname=resolve_file(afile,adir,nocheck)
   afile: the file name to resolve, might be relative
   adir : root directory. Use it's drive and path, with
             afile, to determine newfilename
             If not specified,  then current directory is used
  defext   : default extension to add, if no .ext exists
             if '', then ignore
   check: if =1, then do NOT check for existence of this file
returns
  Newname, if it exists of if nocheck=1
  '' -- if it doesn't exist and nocheck<>1

Note: afile and adir will be "stripped" of spaces -- which
limits the range of non 8.3 names that can be used */

resolve_filename:procedure

parse arg afile,adir,defext,nocheck
afile=strip(afile) ; adir=strip(adir)

curdir0=directory()
curdir=curdir0'\'

if adir='' then adir=curdir     /* no adir specified, use current */

if right(adir,1)<>'\' & right(adir,1)<>':' then adir=adir'\'

usedrive=filespec('D',adir)
usedrive0=usedrive

if usedrive='' then usedrive=filespec('D',curdir) /* no drive in adir, use current*/

usepath=filespec('P',adir)
if left(usepath,1)<>'\' then do    /* relative to current usedrive path */
   foo=directory(usedrive)'\'
   foo2=directory(curdir0)
   usepath=filespec('p',foo)||usepath
end /* do */
oldfile=filespec('n',afile)

select
  when substr(afile,2,2)=":\" then do /* if 2-3 = :\, then use afile as is */
     usefile=afile
  end /* do */

  when substr(afile,2,1)=':' then do    /* relative file name on drive */

      if usedrive0='' then do            /* perhaps use usepath? */
          usefile=left(afile,2)||usepath||oldfile
      end               /* otherwise, use afile as is */
      else do
         usefile=afile
      end /* do */
  end
  when left(afile,1,1)='\' then do      /* attach adir drive */
      usefile=usedrive||afile
  end
  otherwise do
      usefile=usedrive||usepath||afile
  end
end

if pos('.',afile)=0 & defext<>'' then usefile=usefile||'.'||strip(defext,'l','.')

if nocheck=1 then return usefile

afile=stream(usefile,'c','query exists')
return afile


/* ---------------------------------------------*/
/* get a fully qualified url from some site, return first
maxchar characters (if maxchar missing, get 10million (the whole thing?) */
/* ---------------------------------------------*/

go_get_url:procedure expose is_cgi BLENDGIF_ROOT  save_tempfile
parse arg aurl,maxchar,verbose,headers

if maxchar="" then maxchar=10000000

got=""
if abbrev(translate(aurl),'HTTP://')=1 then do
   aurl=substr(aurl,8)
end
else do
     return ''     /* must be fully qualified url */
end /* do */
parse var aurl server '/' request

/* now get the url.  It requires the RxSock.DLL be in your LIBPATH. */

/* Load RxSock */
    if \RxFuncQuery("SockLoadFuncs") then nop
    else do
       call RxFuncAdd "SockLoadFuncs","rxSock","SockLoadFuncs"
       call SockLoadFuncs
    end

    crlf    ='0d0a'x                        /* constants */
    family  ='AF_INET'
    httpport=80

   if verify(server,'1234567890.')>0 then 
       rc=sockgethostbyname(server, "serv.0")  /* get dotaddress of server */
   else
      serv.0addr=strip(server)

    if rc=0 then do
        call dosay 'Unable to resolve "'server'"'
        return ''
    end
    dotserver=serv.0addr                    /* .. */
    gosaddr.0family=family                  /* set up address */
    gosaddr.0port  =httpport
    gosaddr.0addr  =dotserver

    gosock = SockSocket(family, "SOCK_STREAM", "IPPROTO_TCP")

    /* Set up request */
    message="GET /"request' HTTP/1.0 'crlf
    if length(headers)>2 then do
       if right(headers,2)=crlf then headers=left(headers,length(headers)-2)
    end
    if headers<>'' then message=message||headers||crlf
    message=message||'Host: 'server||crlf

    message=message||crlf

  if verbose>0 then call dosay "   Retrieving " request " from " dotserver 
    got=''
    rc = SockConnect(gosock,"gosaddr.0")
    if rc<0 then do
        call dosay ' Unable to connect to "'server'"'
        return ' '
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



/*********************************/
/* Create a transformation matrix, and it's inverse; given:
   width (WIDTH) and height (HEIGHT) (of image) in pixels
   width (WSCALE) and height (HSCALE scale (eg; 0.5=one half, 1.0=no change, 2.0=doubling)
   rotation (ROTATE)(in degrees)
   column (XMOVE) and row (YMOVE) translation.

The transformation matrix assumes the following operatiosn:
   move center of image to 0,0 origin 
   scale the image
   rotate the image
   move the image (which also accounts for the "move to center")

call as:
   tran_matrix='a_stem.'; inv_tran_matrix='b_stem.'
   astatus=create_trans_mtx(width,height,wscale,hscale,zrotate,yrotate,xrotate,xmove,ymove)
where:
   the arguments are as defined above, and where
   tranmtx is a 4x4 matrix which will transform any pixel in the image.
   tran_matrix should be set to a stem name into which transformation 
   matrix will be written (be SURE to include the trailing period).

To compute a transformation on a point at XOLD,YOLD (column,row), 
perform the matrix multiplication:
  xnew= xold*trnmtx.1.1 + yold*trnmtx.2.1 + tranmtx.4.1
  yxnew=xold*trnmtx.1.2 + yold*trnmtx.2.2 + tranmtx.4.2
where:
  TRNMTX is the value of TRAN_MATRIX that is, TRAN_MATRIX='TRANMTX.'

And, to transform xnew, ynew back to xold,yold:
  xold= xnew*itrnmtx.1.1 + ynew*itrnmtx.2.1 + itranmtx.4.1
  yold= xnew*itrnmtx.1.2 + ynew*itrnmtx.2.2 + itranmtx.4.2

where:  ITRNMTX is the value of INV_TRAN_MATRIX 


*******/
create_trans_matrix:procedure expose (tran_matrix) (inv_tran_matrix)
parse arg width,height,wscale,hscale,zdeg,ydeg,xdeg,xmove,ymove

mtx1.=0
mtx1.1.1=1; mtx1.2.2=1 ; mtx1.3.3=1 ; mtx1.4.4=1
mtx1.4.1=-width/2
mtx1.4.2=-height/2

/* 1b) scale matrix */
mtx2.=0
mtx2.1.1=wscale
mtx2.2.2=hscale
mtx2.3.3=1
mtx2.4.4=1

/* 1c) multipliy origin-translation * scaler */
newmtx='mtx1.'
foo=mtx_mult(4)

/* 1d) rotate z */
mtx2.=0
ztheta=(2*3.1416)*(zdeg/360)
csi=cos(ztheta) ;ssi=sin(ztheta)
mtx2.1.1=csi ; mtx2.1.2=ssi
mtx2.2.1=-ssi ; mtx2.2.2=csi
mtx2.3.3=1
mtx2.4.4=1

/* 1e) multiply 1c * rotater */
newmtx='mtx1.'
foo=mtx_mult(4)
 

/* 1da) rotate y */
mtx2.=0
ytheta=(2*3.1416)*(ydeg/360)
csi=cos(ytheta) ;ssi=sin(ytheta)
mtx2.1.1=csi ; mtx2.1.3=ssi
mtx2.3.1=-ssi ; mtx2.3.3=csi
mtx2.2.2=1
mtx2.4.4=1

/* 1ea) multiply 1d * 1da * rotater */
newmtx='mtx1.'
foo=mtx_mult(4)


/* 1db) rotate x */
mtx2.=0
xtheta=(2*3.1416)*(xdeg/360)
csi=cos(xtheta) ;ssi=sin(xtheta)
mtx2.2.2=csi ; mtx2.2.3=ssi
mtx2.3.2=-ssi ; mtx2.3.3=csi
mtx2.1.1=1
mtx2.4.4=1

/* 1ea) multiply 1db * 1da */
newmtx='mtx1.'
foo=mtx_mult(4)


/* 1f) translate + de-originizer */
mtx2.=0
mtx2.1.1=1; mtx2.2.2=1 ; mtx2.3.3=1 ; mtx2.4.4=1
mtx2.4.1=(width/2)+xmove
mtx2.4.2=(height/2)+ymove


/* 1g) multiply 1e*  translater+de-origin-translation */
newmtx='mtx3.'
foo=mtx_mult(4)

do ii=1 to 4
   do jj=1 to 4
      foo=value(tran_matrix||ii||'.'||jj,mtx3.ii.jj)
   end /* do */
end /* do */

if value(inv_tran_mtx)='' then return 1

/* now create de-transformer */
/* 2a) inv(translate + de-originizer) */
mtx1.=0
mtx1.1.1=1; mtx1.2.2=1 ; mtx1.3.3=1 ; mtx1.4.4=1
mtx1.4.1=-((width/2)+xmove)
mtx1.4.2=-((height/2)+ymove)


/* 2b1) derotate x */
mtx2.=0
xtheta=-(2*3.1416)*(xdeg/360)
csi=cos(xtheta) ;ssi=sin(xtheta)
mtx2.2.2=csi ; mtx2.2.3=ssi
mtx2.3.2=-ssi ; mtx2.3.3=csi
mtx2.1.1=1
mtx2.4.4=1

newmtx='mtx1.'
foo=mtx_mult(4)

/* 2b2) derotate y */
mtx2.=0
ytheta=-(2*3.1416)*(ydeg/360)
csi=cos(ytheta) ;ssi=sin(ytheta)
mtx2.1.1=csi ; mtx2.1.3=ssi
mtx2.3.1=-ssi ; mtx2.3.3=csi
mtx2.2.2=1
mtx2.4.4=1

newmtx='mtx1.'
foo=mtx_mult(4)


/* 2b3)de rotate z */
mtx2.=0
ztheta=-(2*3.1416)*(zdeg/360)
csi=cos(ztheta) ;ssi=sin(ztheta)
mtx2.1.1=csi ; mtx2.1.2=ssi
mtx2.2.1=-ssi ; mtx2.2.2=csi
mtx2.3.3=1
mtx2.4.4=1

newmtx='mtx1.'
foo=mtx_mult(4)

/* 2c)inv scale matrix */
mtx2.=0
mtx2.1.1=1/wscale
mtx2.2.2=1/hscale
mtx2.3.3=1
mtx2.4.4=1

newmtx='mtx1.'
foo=mtx_mult(4)


/* 2d) inv originizer */
mtx2.=0
mtx2.1.1=1; mtx2.2.2=1 ; mtx2.3.3=1 ;mtx2.4.4=1
mtx2.4.1=width/2
mtx2.4.2=height/2

newmtx='mtx3.'
foo=mtx_mult(4)

do ii=1 to 4            /* copy to the inverse transformation matrix */
   do jj=1 to 4
      foo=value(inv_tran_matrix||ii||'.'||jj,mtx3.ii.jj)
   end /* do */
end /* do */

return 1


/* multiply mtx1 by mtx2, return as mtx3 */
mtx_mult:procedure expose  mtx1. mtx2. (newmtx)
parse arg ndim

mtx3.=0
do rr=1 to NDIM
   do cc=1 to ndim
     do ii=1 to ndim
        mtx3.rr.cc=mtx3.rr.cc+(mtx1.rr.ii*mtx2.ii.cc)
     end /* do */
   end /* do */
end /* do */
do cc=1 to ndim
  do rr=1 to ndim
    foo=value(newmtx||cc||'.'||rr,mtx3.cc.rr)
  end /* do */
end /* do */

return 2



/**************/
/* transform a point (at x0 y0) using the "tran_matrix")*/
transfrm_point:procedure expose (tran_matrix)
parse arg x0,y0,z0
if z0='' then z0=0

t11=value(tran_matrix||1'.'1)
t21=value(tran_matrix||2'.'1)
t31=value(tran_matrix||3'.'1)
t41=value(tran_matrix||4'.'1)

t12=value(tran_matrix||1'.'2)
t22=value(tran_matrix||2'.'2)
t32=value(tran_matrix||3'.'2)
t42=value(tran_matrix||4'.'2)

t13=value(tran_matrix||1'.'3)
t23=value(tran_matrix||2'.'3)
t33=value(tran_matrix||3'.'3)
t43=value(tran_matrix||4'.'3)

xn= x0*t11 + y0*t21 + z0*t31 + t41
yn= x0*t12 + y0*t22 + z0*t32 + t42
zn= x0*t13 + y0*t23 + z0*t33 + t43
return trunc(xn)' 'trunc(yn)' 'trunc(zn)

/***************************/
/* quasi euclidean distance of a point in 3 space (to origin) */
dist3:procedure
parse arg dx,dy,dz,dtype
if dz='' then dz=0
if dtype='' then dtype=3

if dtype=1 then return max(abs(dx),abs(dy),abs(dz))  /* square */

if dtype=2 then return (abs(dx)+abs(dy)+abs(dz))  /* diamond */

if dtype=3 then do          /* octagonal */
  a1=max(abs(dx),abs(dy))
  a2=min(abs(dx),abs(dy))
  d1=(a1+(a2/2))
  if dz=0 then return d1
  a1=max(abs(d1),abs(dz))
  a2=min(abs(d1),abs(dz))
  return (a1+(a2/2))
end

/* otherwise, euclidean circle */
aa=(dx*dx)+(dy*dy)+(dz*dz)
return sqrt(aa)


/**********************************/
/* squoosh a row */
squoosh_row:procedure
parse arg arow,newlen

oldlen=lengtH(arow)
if newlen<=2 then return left(arow,newlen)
tfact=oldlen/(newlen-1)
pp=''
do mm=1 to newlen
   jmm=min(1+trunc(tfact*(mm-1)),oldlen)
   pp=pp||substr(arow,jmm,1)
end /* do */
return pp


/**********************************/
/* shrink a gif file by looking for areas of non-changing pixels */
do_shrink_gif:procedure expose is_cgi blendgif_root  save_tempfile
parse arg gifcontents

signal on error name foo2err ;signal on syntax name foo2err 

oldsize=length(gifcontents)
/* 0) ascertain block structure of the gif file */
talist=read_gif_block(gifcontents,1,'',1)

/* 1) get stuff up to and including first image */
newimage=''
cts.=0
curgce=''
do forever
   parse upper var talist ainfo talist
   aa='!'ainfo
   ii=cts.aa+1
   cts.aa=ii
   ab=read_gif_block(gifcontents,ii,ainfo,1)
   if ainfo='GCE' then DO        /* MAKE SURE TO RETAIN IMAGE */
      stuff=READ_GCE_BLOCK(ab)
      parse var STUFF disposal usrinflag tcflag delay tcindex
      ab=MAKE_GCE_BLOCK(tcflag,tcindex,delay,1,useinFlag)
   end /* do */
   newimage=newimage||ab
   if ainfo='IMG' then leave  /* got first image, now use it ... */
end

/* 2) Initialize "current image" matrix (using img block in ab */
ct_name='CT.'
img_name='CURIMG.'
curimg.=0
ct.=0
stuff=read_image_block(ab,1)           /* 0= do NOT looad IMG. matrix */
parse var stuff lpos tpos width0 height0 lct lctsize interl sort ',' imgdata

do forever      /*  do the images in the file */

/* 3) start examining other blocks, determining what portions to retain */
do forever
   if talist='' then do
      call dosay "   Image shrunk from "oldsize " to " length(newimage)" bytes."
      return newimage   /* all done */
   end
   parse upper var talist ainfo talist
   aa='!'ainfo

   ii=cts.aa+1
   cts.aa=ii
   ab=read_gif_block(gifcontents,ii,ainfo,1)
   if ainfo='GCE' then do 
      stuff=READ_GCE_BLOCK(ab)
      parse var STUFF disposal usrinflag tcflag delay tcindex
      curgceold=MAKE_GCE_BLOCK(tcflag,tcindex,delay,1,useinFlag)
      curgcenu=MAKE_GCE_BLOCK(tcflag,tcindex,delay,3,useinFlag)
      iterate
   end /* do */
   if ainfo="IMG" then leave    /* will use AB below */
   if ainfo='TRM' then 
       newimage=newimage||'3b'x
   ELSE
       newimage=newimage||ab
end

/* 4) got an image, and a a gce block. See what changes. .. */

ct_name='CT2.'
img_name='IMG.'
img.=0
ct.=0
stuff=read_image_block(ab,1)           /* 0= do NOT looad IMG. matrix */
parse var stuff lpos tpos width height lct lctsize interl sort ',' imgdata

/* compare IMG. to CURIMG. --- note xmin xmax ymin ymax (of where changes are */
xmin=11111 ; xmax=0 ; ymin='' ; ymax=height ;allsame=1
do irow=0 to height0-1
   arowcur=curimg.irow
   arownew=img.irow
   imatch1=compare(arowcur,arownew) 
   if imatch1=0 then iterate /* perfect match, so skip */
   allsame=0
   imatch2=compare(reverse(arowcur),reverse(arownew))
   if ymin='' then ymin=irow
   ymax=irow
   xmin=min(xmin,imatch1)
   xmax=max(xmax,1+length(arowcur)-imatch2)
   curimg.irow=arownew         /* new image becomes the current image */
end

if allsame=1 then do
   newimage=newimage||curgceold||ab 
end /* do */
else do
/*  determine mins/maxs */
  xmin=max(0,xmin-1); xmax=min(width,xmax+1)
  ymin=max(0,ymin-1); ymax=min(height,ymax+1)
/* if everything changed, then just current stuff */
  if ymin<3 & xmin<3 & xmax>(width0-2) & ymax>(height0-2) then do
      newimage=newimage||curgceold||ab
  end
  else do                 /* just write a section */
     call dosay "   Shrinking image to" (1+xmax-xmin) 'x' (1+ymax-ymin)
     width2=1+xmax-xmin
     height2=1+ymax-ymin
     lpos=xmin
     tpos=ymin
     do irow2=ymin to ymax
       irr=irow2-ymin
       nuimg.irr=substr(img.irow2,xmin+1,1+xmax-xmin)
     end 
     nuimg.!rows=1+ymax-ymin
     nuimg.!cols=1+xmax-xmin
     ct_name='ct2.' ; img_name='nuimg.'
     ablock=MAKE_IMAGE_BLOCK(lpos,tpos,width2,height2,lct,lctsize,interl,sort,0)
     NEWIMAGE=NEWIMAGE||curgcenu||ABLOCK
  end
end

end             /* mondo huge oop */


foo2err:
say " error at "sigl ' 'rc
/************************************************************/
/************************************************************/
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
       to_matrix =  If missing or 0, then
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


make_image_block:procedure expose (ct_name) (img_name) is_cgi BLENDGIF_ROOT  save_tempfile

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
   usename=systempfilename2('$TM1????.TMP')
   if usename='' then do
      call dosay2 "BlendGIF error. Unable to create temporary file (perhaps a setup error)"
      exit
   end /* do */
end
else do
   if pos('?',tempname)>0 then do
      usename=systempfilename2(tempname)
      if usename='' then do
        call dosay2 "BlendGIF error. Unable to create temporary file (perhaps a setup error)"
        exit
      end /* do */
   end
   else do
      usename=TEMPNAME
   end
end

ncols=width
nrows=height
messim=rxgdimagecreate(ncols,nrows)
if messim<2 then do
  call dosay2 "Error Could not create temporary gif image "
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
 call dosay2 "Error retrieving temporary gif file: "usename
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

read_image_block:procedure expose (ct_name) (IMG_NAME) is_cgi BLENDGIF_ROOT  save_tempfile

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
   usename=systempfilename2('$TM2????.TMP')
   if usename='' then do
      call dosay2 "BlendGIF error. Unable to create temporary file (perhaps a setup error)"
      exit
   end /* do */
end
else do
   if pos('?',tempname)>0 then do
     usename=systempfilename2(tempname)
     if usename='' then do
        call dosay2 "BlendGIF error. Unable to create temporary file (perhaps a setup error)"
        exit
     end /* do */
   end
   else do
      usename=tempname 
   end
end

/* make the gif file in memory (very simple version) */

/*rse arg width,height,gcflag,colres,sort,bkgcolor,aspect,gcsize*/


aa=MAKE_LSD_BLOCK(width,height,0,0,0,0,,)
aa=aa||ablock||make_terminator_block()

arf=charout(usename,aa,1)
if arf<>0 then do  
   call dosay2  "Error writing temporary gif file:" usename
   return 0
end
foo=stream(usename,'c','close')
/* now read with rxgd */
dim= RxgdImageCreateFromGIF(usename)
if dim<=1 then do
  call dosay2 " Error reading temporary gif file: " usename
exit
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

make_lsd_block:procedure expose (ct_name) is_cgi BLENDGIF_ROOT  save_tempfile
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
parse arg ablock
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

read_gif_block:procedure expose is_cgi BLENDGIF_ROOT  save_tempfile
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



/**************************************/
/* read data sent back by an html FORM declared with:
   enctype="multipart/form-data" method="POST"

Calling syntax:
   nentries=read_multipart(stuff,content_type)
  where
     stuff == the body of a POST request (i.e.; the 4th argument sent to
              sre-http addons)
     nentries == the number of entries found. If error, nentries=0
    
  and also the expose variable FORM_DATA is constructed.

The structure of FORM_DATA is:
  FORM_DATA.0 = # of entries (in this multipart submission)
  FORM_DATA.!list.j = space delimited list of "variable names" in part
                       j (j=1.. FORM_DATA.0)
     For each word in FORM_DATA.!list.j, there is FORM_DATA. tail.
     In particular, FORM_DATA.!aword.j, where !aword is an ! prepended
     to a word form the FORM_DATA.!list.j list.
     For example, in almost all cases, one of these words will be "NAME".
       Thus, FORM_DATA.!NAME.j = the "name" of this variable
  FORM_DATA.j  - the actual value of this part.

  Basically, a typical entry  will contain:
    FORM_DATA.!NAME.j and FORM_DATA.j
  which can be interpreted as the "name" of the variable and it's "value".
  However, sometimes other variables will be mentioned in the
  FORM_DATA.!LIST. In particular, file uploads will often have a
  FORM_DATA.!FILENAME.j, which is often the local name of 
  the file the client is uploading.


  Notes:
    * if an error occurs, a 0 is returmed, and FORM_DATA.!ERROR
      will contain an error message
    * a content-disposition entry, if found, is NOT included in FORM_DATA

*/
read_multipart_data:procedure expose form_data.
parse arg abody,atype

drop form_data.

crlf='0d0a'x

/* is there a content-type request header ? */
if atype="" then do
   form_data.!error=" No  content-type  request header"
   return 0
end

parse var atype thetype ";" boog 'boundary=' abound    /* get the type */

if translate(thetype)<>"MULTIPART/FORM-DATA" then do
  form_data.!error="No  multipart/form-data in Content-type "
  return 0
end

if translate(thetype)<>"MULTIPART/FORM-DATA" then do
  form_data.!error=" BlendGif upload error: No boundary in multipart/form-data header "
  return 0
end

abound="--"||abound   /* since boundaries always start with -- */

abd2=abound||crlf
/* loop through message, pulling out blocks and storing in stem var bigstuff. */

/* Now parse the various parts.*/

parse var abody foo1 (abd2) abody    /* move beyond first boundary and it's crlf */
/* check for netscape 2.0 incorrect format */
if pos(abound,abody)=0 then do   /* no ending boundary, so add one */
   abody=abody||crlf||abound||" -- "
end

mm=0
do until abody=""
  parse var abody thestuff (abound) abody        /* get a  boundary defined block */
  if strip(left(thestuff,4))="--" then leave        /* -- signals no more */
  if abody="" then leave
  mm=mm+1
  form_data.!list.mm='' ; form_data.mm=''
  do forever            /* get block headers.  Stop when hit a blank line */
     parse var thestuff anarg (crlf) thestuff
     if anarg="" then do
           leave
     end
     else do                    /* extract the arguments on this line */
         do until anarg=""
              parse var anarg anarg1 ";" anarg
              boob1=pos(':',anarg1) ; boob2=pos('=',anarg1)
              if boob1=0 then nixon=boob2
              if boob2=0 then nixon=boob1
              if boob1>0 & boob2>0 then nixon=min(boob1,boob2)
              t1=translate(strip(strip(substr(anarg1,1,nixon-1)),,'"'))
              t2=strip(strip(substr(anarg1,nixon+1)),,'"')
              if t1="CONTENT-DISPOSITION" then iterate /* don't bother retaining this */
              form_data.!list.mm=form_data.!list.mm' 't1
              nm1='!'||t1
              form_data.nm1.mm=t2
          end     /* exract arguments */
     end        /* extract args on this line */
  end                    /* get a line */
  if thestuff<>"" then do
    form_data.mm=left(thestuff,length(thestuff)-2)  /* strip off ending crlf */
    parse var abody foo (crlf) abody   /* jump past extra crlf */
  end
  else do
     form_data.body.mm=""
  end
end

return mm


/***********************/

