/************************/
/* Display info from a gif file. A list of the logical "blocks"
   comprising a gif file is displayed, followed by relevant
   information extracted from each block.

   MUST BE COMBINED WITH THE THE PROCEDURES IN PARSEGIF.CMD

Usage:
  status=show_gifcontents(gifimage,dopause)
 
where:
  gifimage: the contents of a gif file; say as read using
            gifimage=charin(gif_file,1,chars(gif_file))
  DOPause : If 1, then pause (wait for ENTER key) after displaying
            info on each block
and 
  status = number of blocks in the gif file

For example, the following program will display the structure of
a user supplied gif file:

----------------begin example------------------------------- 
parse arg gif_File
gifimage=charin(gif_file,1,chars(gif_file))
nblocks=show_gifcontents(gifimage,1)
exit
-----------------end example-------------------------------


*/
show_gifcontents:PROCEDURE
parse arg gifcontents,dopause
talist=read_gif_block(gifcontents,1,'',1)
say " Structure of the gif file is: "
say "   " talist
cts.=0
ti=words(talist)
do iJmm=1 to ti
   ainfo=strip(word(talist,iJmm))
   aa='!'ainfo
   ii=cts.aa+1
   cts.aa=ii
   ab=read_gif_block(gifcontents,ii,ainfo,1)
   say " ------ " ainfo ii ", length = "||length(ab)
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
         ct.=0
         stuff=read_image_block(ab,0)
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
       call charout,' .... hit enter to view next block .... '
       pull xxx
       say
   end /* do */
end /* do */

return ti


