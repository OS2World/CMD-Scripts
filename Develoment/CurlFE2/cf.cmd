/* Curl Front-end v2 by DGD - Plain REXX; untested with other, should work.*/
/* Syntax > cf [# of file to start at, mostly for resume during testing]
   Requires:
   CURL and lib063 from http://www.smedley.info/os2ports/index.php?page=curl
   Unzip into C:\CURL, or modify lines below.
   !!! Creates root directories. Easily changed; refer to ddn just below.

   version 2: expands (some) shortened urls -- likely yet other variations
*/

Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

drive= 'C:\'
execfil= 'C:\CURL\BIN\CURL.EXE' /* executable */
useragent= ' "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)" '
/* ^ Most likely to spoof sites as the annoying ones insist on IE.
 Not currently used; would be added to 'execfil' lines below. See CURL docs at
   http://curl.haxx.se/docs/ */

ddn= date('O')   /* make a directory from date */
do while pos('/', ddn) > 0; ddn= delstr(ddn, pos('/', ddn), 1); end
'mkdir 'drive||ddn

parse arg start  /* kludge for testing, so can resume at # with problem */
if start = '' then start= 1

do forever
say
say 'Enter URL (just <enter> to exit program):'
parse pull url
if url= '' then exit

turl= '' /* '%' and '&' special to OS/2 have to be duplicated in url */
do pc= 1 to length(url) /* KLUDGE because don't want to do elegant */
  c= substr(url, pc, 1)
  if c = '%' then turl= turl||'%%'
    else turl= turl||c
end
url= turl
turl= delstr(turl, pos('/', turl), 1)
/* ^ used to expand partial urls below, un-double slash to make easier */

tfile= 'C:\CURL\'||time('S')||'_tpage.html' /* temporary downloaded page */
execfil' -o 'tfile' "'url'"' /* save the page in temp file */

/* look in .html for href having .mpg, .mpeg, .wmv, .jpg (add more below) */
slin.0= 0           /* form: <a href="image.jpg"> */
if stream(tfile, 'c', 'query exists') <> '' then do
  say 'Reading downloaded page...'
  ndx= 1
  do until lines(tfile) = 0
    tline= linein(tfile)    /* because STOOPID servers are case sensitive */
    cline= translate(tline) /* but tests below can't be, duplicate, upcased */
    do while pos('<A HREF=', cline) > 0
      p0= pos('<A HREF=', cline)
      p1= pos('"', cline, p0)  /* find next and matching double quotes */
      p2= pos('"', cline, p1 + 1)
      if p1 > 0 & p2 > 0 then do /* prevents crash in mal-formed page */
        tfn= substr(tline, p1 + 1, p2 - p1 - 1)
        cfn= substr(cline, p1 + 1, p2 - p1 - 1)
        tline= substr(tline, p2, length(tline) - p2 + 1)
        cline= substr(cline, p2, length(cline) - p2 + 1)
      end
      else do
        tline= delstr(tline, 1, 1)
        cline= delstr(cline, 1, 1)
      end

      if pos('HTTP://', cline) = 0 then do   /* fill in shortened url */
        tfn= substr(url, 1, lastpos('/', url))||tfn
      end

      if substr(tfn, 1, 1) = '/' then do  /* another type of shortened url */
        p0= pos('//', url)          /* missing up to first single "/" */
        tfn= substr(url, 1, pos('/', url, p0 + 2) - 1)||tfn
      end
 
      if pos('../', tfn) = 1 then do /* expand '..' dirs */
        p1= 1
        do while pos('../', tfn) = 1
          tfn= delstr(tfn, 1, 3)
          p0= pos('/', turl, p1) /* turl is prepared by un-doubling slashes */
          p1= p0 + 1
        end
        tfn= substr(turl, 1, p0 - 1)||'/'||tfn
        tfn= insert('/', tfn, pos('/', tfn)) /* double slashes fix up */
      end

      if pos('.MPG', cfn) > 0 |,  /* upcased because can't easily test for */
         pos('.MPEG', cfn) > 0 |, /* EVERY possible mix of cases */
         pos('.WMV', cfn) > 0 |,
         pos('.MP3', cfn) > 0 |,
         pos('.JPG', cfn) > 0 then do
           slin.ndx= tfn
           ndx= ndx + 1
         end
    end
  end
  ok= stream(tfile, 'c', 'close')
  slin.0= ndx - 1
  say ' 'copies('=', 78)
    /* because many files are simplistically named, add a time stamp */
  p0= time('M') /* minute: use same for all, less messy, somewhat groups */
  /* p0= time('S')  alternative, uses seconds since midnight */

  say slin.0' Files found.'

  do n= start to slin.0
    say 'Downloading # 'n' of 'slin.0
    fn= slin.n
    ofn= filespec('N', slin.n) /* copy for output name */

    /* PROBLEM of "%" and "&" exception on OS/2 command line */
    tfn= ''   /* must be doubled for input parameter */
    do pc= 1 to length(fn) /* simple KLUDGE because elegant is difficult */
      c= substr(fn, pc, 1)
      if c = '%' then tfn= tfn||'%%'
        else tfn= tfn||c
    end

    fn= tfn
    p= pos('amp;', fn) /* remove " amp;" from FileName (source url) */
    do while p > 0       /* this appears when is an "&" in html */
      fn= delstr(fn, p, 4)  /* but apparently doesn't want it back! */
      p= pos('amp;', fn)
    end

    p= pos('&', ofn) /* convert "&" in OutFileName (target file) */
    do while p > 0
      ofn= insert('And', ofn, p) /* changed to "And" */
      ofn= delstr(ofn, p, 1)
      p= pos('&', ofn)   /* okay, below may not be necessary here now that */
    end                  /* "amp;" is eliminated */
    p= pos('amp;', ofn) /* also remove " amp;" from outfilename */
    do while p > 0       /* this appears when is an "&" in html */
      ofn= delstr(ofn, p, 4)
      p= pos('amp;', ofn)
    end
    p= pos('%20', ofn) /* convert "%20" in outfilename */
    do while p > 0
      ofn= insert('_', ofn, p + 2) /* changed to "_" */
      ofn= delstr(ofn, p, 3)
      p= pos('%20', ofn)
    end
    p= pos(' ', ofn) /* convert spaces in outfilename */
    do while p > 0
      ofn= delstr(ofn, p, 1)
      ofn= insert('_', ofn, p) /* changed to "_" */
      p= pos(' ', ofn)
    end
    ofn= ddn||'_'p0'_'||ofn   /* always prefix date and time */

    execfil' -o "'drive||ddn'\'ofn'" "'fn'"'

    if n < slin.0 then do  /* no need to delay if the last one */
      d= 10 + random(20)    /* randomish delay to not look like robot... */
      say'  Sleeping for 'd' seconds...'
      call syssleep d
      say
    end
  end
'del 'tfile  /* delete only after in case want to look in */
start= 1 /* un-kludge so will get all from next url */
end /* file exists */
else do
  say 'Cannot find downloaded page: 'tfile
  exit
end
end /* main loop */
