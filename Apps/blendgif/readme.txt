24 May 1999. Daniel Hellerstein (danielh@econ.ag.gov)

         BlendGif ver 1.15: Create a multi-frame animated GIF 


Synopsis:
    BlendGIF is a free, OS/2 REXX application that will create a multi-frame
    animated GIF file from several  GIF image files. In addition to
    merely appending images together, BlendGif can create intermediate
    images --  thereby supporting a variety of fade, pan, dissolve,
    rotation, and other effects.

    BlendGIF can be run ...
       a) from an OS/2 command prompt,
       b) as a cgi-bin script (under an OS/2 web server that 
          understands CGI-BIN), or
       c) as an addon for the SRE-http web server 
   To support the latter two options, BLENDGIF.HTM can be used as a
   javascript-enabled, HTML <FORM> based front-end.
     
   For detailed installation instructions, see the manual (BLENDGIF.DOC).        

   And a Plea: BlendGIF is a new product (development started in Feb 1999).
               Though it's gotten a fair amount of use, if you discover
               any bugs or annoying obscurities, PLEASE contact me.
               

Requirements:  
   To use BLENDGIF, you must have the  RXGDUTIL.DLL and REXXLIB.DLL
   libaries. If you do not have them, you can contact Daniel Hellerstein
   (at the above address), or you can grab them from
        http://www.srehttp.org/pubfiles/blenddll.zip
   (please see the READ.ME that comes with BLENDDLL.ZIP)

   You also must have REXXUTIL.DLL and RXSOCK.DLL; but that's almost
   certainly already on your computer (they are shipped with OS/2).

File list:

  read.me         This document.
  blendgif.doc    The BlendGif manual
  blendgif.cmd    The BlendGif rexx program
  BLENDGIF.HTM    HTML document with a FORM that invokes BLENDGIF as 
                  an SRE-http addon, or as a CGI-BIN script.
  BLENDHLP.HTM    Description of BlendGIF options (BLENDGIF.HTM 
                  contains many links to BLENDHLP.HTM)
  BLENDFRM.HTM    Frame-enabled front-end for BLENDGIF.HTM
  BLENDTOC.HTM    TOC of BLENDGIF.HTM (used by BLENDFRM.HTM)
  BLENDGIF.IN     Example of a BlendGIF input file
  BLNDLOGO.GIF    The BlendGIF logo -- a several frame animated GIF

  GIF_INFO.CMD   Bonus: a utility to display the structure of GIF files

  hello.gif              Some sample images to play with
  goodbye.gif
  forever0.gif
  forever1.gif
  forever2.gif
  good.gif
  better.gif
  best.gif
  1_pixel.gif
 
Contact:

  PLEASE contact me (Daniel Hellerstein, danielh@econ.ag.gov) if you encounter any problems.
  Or, if you have any suggestions or kudos!

  You may also be interested in visiting http://www.srehttp.org/ -- the home
  page for SRE-http, BlendGIF, and a host of other web-related OS/2 utilities.

