/***************************************************/
/* Sample program that uses GIFINFOa.RXX procedures 
   to retrieve information from a gif file. To use this,
  you'll have to append the contents of GIFINFOa.RXX to the
  end of this program */

parse arg giffile               /* see if user provided gif name */

foo=rxfuncquery('sysloadfuncs')     /* load rexxutil library */
if foo=1 then do
  call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
  call SysLoadFuncs
end

if giffile='' then do                /* no, so ask for one */
  call charout, " Enter gif file(s): "
  pull giffile
  if words(giffile)>0 then do
      say "Please enter just one file name (* can be used as a wildcard)"
      exit
  end /* do */
end

if giffile='' then exit
if pos('.',giffile)=0 then giffile=giffile'.gif'  /* add the extension? */

if pos('*',giffile)>0 then do                     /* ? then use multiple files */
    oo=sysfiletree(giffile,fils,'FO')
end /* do */
else do
   fils.0=1 ; fils.1=giffile
end

say "Information on  " fils.0 " GIF files. "


/* Display information on each GIF file */

do ll=1 to fils.0
  if ll>1 then do
      call charout, " ---------------------  Hit ENTER to continue"
       pull .
  end /* do */
  say " File # " ll ' : ' fils.ll

  ok=strip(gif_info(fils.ll,1,'ERROR'))   /* is it an okay gif file ? */
  if abbrev(ok,'ERROR')=1 then do
      say "ERROR. " ok
     iterate
  end

/* get some global information */
  sns=gif_info(fils.ll,1,'#IMGS #CMTS #PTS #APPS  DEF_SIZE DEF_CT',',')
  parse var sns ni','nc','np','na','wd ht','ct
  say ' # of images=' ni ', #comments=' nc ', #plaintext='np ', #apps='na 
  say " Dimensions: " wd ht
  ff=length(ct)/2
  say " Length of color table: " ff

/* write out comments */
  do ll2=1 to nc
      acmt=gif_info(fils.ll,ll2,'CMT')
      say ' Comment #'ll2 ':' acmt
  end /* do */

/* write out application block data */
  do ll2=1 to na
       acmt=gif_info(fils.ll,ll2,'APP_ID ')
       say 'Application # 'll2 ': ID='left(acmt,8) ,
           ', Auth (in hex)=' c2x(right(acmt,3))
  end /* do */

/* information on the images */
  do ll2=1 to ni
      acmt=gif_info(fils.ll,ll2,'DELAY TRANSP SIZE POS IMG',' ')
      say ' Image# 'll2 ': Delay='word(acmt,1) ', Transp='word(acmt,2) ,
           ' Wd Ht= ' subword(acmt,3,2) ', Pos= ' subword(acmt,5,2) ,
           ' Bytes='||length(subword(acmt,7))
  end /* do */
  

end             /* get next gif file? */

exit


/* --- APPEND GIFINFOa.RXX here !!!!! */


