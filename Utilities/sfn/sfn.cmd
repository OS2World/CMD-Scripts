/* Short Filename Namer 1.0 - (C) 1998  Samuel Audet <guardia@cam.org> */

/* Load the usual garbage ... */
call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

'@echo off'

parse arg realpath virtualpath
realpath = strip(realpath)
virtualpath = strip(virtualpath)

if (realpath = '') | (virtualpath = '') then do
   say 'sfn <realpath> <virtualpath>'
   say 'ex.: sfn c: x:'
   say '     sfn f:\mp3 x:\lalala'
   exit
end

/* Remove trailing backslash */

if lastpos('\',realpath) = length(realpath) then realpath = left(realpath,length(realpath) - 1)
if lastpos('\',virtualpath) = length(virtualpath) then virtualpath = left(virtualpath,length(virtualpath) - 1)

/*  sfns -> short filename list
    lfns -> long filename list */

filecounter = 0
dircounter = 0

call ProcessOneDirectory realpath,virtualpath

say 'Total files processed:' filecounter
say 'Total directories processed:' dircounter

exit


ProcessOneDirectory: Procedure expose filecounter dircounter

   parse arg realpath,virtualpath

   filesfns.0 = 0
   call SysFileTree realpath'\*','filelfns','FO'
   dirsfns.0 = 0
   call SysFileTree realpath'\*','dirlfns','DO'

   /* process files */

   do i=1 to filelfns.0
      filecounter = filecounter + 1

      lifilename = substr(filelfns.i,lastpos('\',filelfns.i)+1)

      period = lastpos('.',lifilename)
      select
         when period > 8 then do
            leftpart = left(lifilename,8)
            rightpart = '.'substr(lifilename,period+1,3)
            end
         when period = 0 then do
            if(length(lifilename)) > 8 then
               leftpart = left(lifilename,8)
            else
               leftpart = lifilename
            rightpart = ''
            end
         otherwise
            leftpart = left(lifilename,period-1)
            rightpart = '.'substr(lifilename,period+1,3)
      end

      leftpart = translate(leftpart,'_','.')  /* remove periods from left part */
      sifilename = leftpart||rightpart
      /* change illegal DOS 8.3 chars, gimme more! - no this is not a smily */
      sifilename = translate(sifilename,'_-()!-__',' +[];=,~')

      /* check for duplicates only if filename is modified */
      number = 1

      if(sifilename \= lifilename) then do until checkagain = 0
         checkagain = 0

         do e=1 to filesfns.0

            sefilename = substr(filesfns.e,lastpos('\',filesfns.e)+1)
            lefilename = substr(filelfns.e,lastpos('\',filelfns.e)+1)

            /* if the long version DOES NOT compare, but short version DOES, we have a problem */
            if ((translate(sefilename) = translate(sifilename)) & (lefilename \= lifilename)) then do
               endpos = pos('.',sefilename) - 1
               if endpos < 0 then endpos = length(sefilename)
               tildepos = pos('~',sefilename)
               if tildepos > 0 then
                  number = substr(sefilename, tildepos+1, endpos - tildepos) + 1
               endpos = pos('.',sifilename) - 1
               if endpos < 0 then endpos = length(sifilename)
               sifilename = left(sifilename,endpos-length(number)-1)'~'number||substr(sifilename,endpos+1)
               checkagain = 1
            end

         end

         do e=1 to dirsfns.0

            sefilename = substr(dirsfns.e,lastpos('\',dirsfns.e)+1)
            lefilename = substr(dirlfns.e,lastpos('\',dirlfns.e)+1)

            /* if the long version DOES NOT compare, but short version DOES, we have a problem */
            if ((translate(sefilename) = translate(sifilename)) & (lefilename \= lifilename)) then do
               endpos = pos('.',sefilename) - 1
               if endpos < 0 then endpos = length(sefilename)
               tildepos = pos('~',sefilename)
               if tildepos > 0 then
                  number = substr(sefilename, tildepos+1, endpos - tildepos) + 1
               endpos = pos('.',sifilename) - 1
               if endpos < 0 then endpos = length(sifilename)
               sifilename = left(sifilename,endpos-length(number)-1)'~'number||substr(sifilename,endpos+1)
               checkagain = 1
            end

         end

      end /* if short filename does not equal long filename */

      filesfns.0 = i
      filesfns.i = virtualpath'\'sifilename

      say filelfns.i '->' filesfns.i
      'TvLink "'filesfns.i'" "'filelfns.i'" -rw'

   end


   /* process directories */

   do i=1 to dirlfns.0
      dircounter = dircounter + 1

      lifilename = substr(dirlfns.i,lastpos('\',dirlfns.i)+1)

      period = lastpos('.',lifilename)
      select
         when period > 8 then do
            leftpart = left(lifilename,8)
            rightpart = '.'substr(lifilename,period+1,3)
            end
         when period = 0 then do
            if(length(lifilename)) > 8 then
               leftpart = left(lifilename,8)
            else
               leftpart = lifilename
            rightpart = ''
            end
         otherwise
            leftpart = left(lifilename,period-1)
            rightpart = '.'substr(lifilename,period+1,3)
      end

      leftpart = translate(leftpart,'_','.')  /* remove periods from left part */
      sifilename = leftpart||rightpart
      /* change illegal DOS 8.3 chars, gimme more! - no this is not a smily */
      sifilename = translate(sifilename,'_-()!-_',' +[];=,')

      /* check for duplicates only if filename is modified */
      number = 1

      if(sifilename \= lifilename) then do until checkagain = 0
         checkagain = 0

         do e=1 to filesfns.0

            sefilename = substr(filesfns.e,lastpos('\',filesfns.e)+1)
            lefilename = substr(filelfns.e,lastpos('\',filelfns.e)+1)

            /* if the long version DOES NOT compare, but short version DOES, we have a problem */
            if ((translate(sefilename) = translate(sifilename)) & (lefilename \= lifilename)) then do
               endpos = pos('.',sefilename) - 1
               if endpos < 0 then endpos = length(sefilename)
               tildepos = pos('~',sefilename)
               if tildepos > 0 then
                  number = substr(sefilename, tildepos+1, endpos - tildepos) + 1
               endpos = pos('.',sifilename) - 1
               if endpos < 0 then endpos = length(sifilename)
               sifilename = left(sifilename,endpos-length(number)-1)'~'number||substr(sifilename,endpos+1)
               checkagain = 1
            end

         end

         do e=1 to dirsfns.0

            sefilename = substr(dirsfns.e,lastpos('\',dirsfns.e)+1)
            lefilename = substr(dirlfns.e,lastpos('\',dirlfns.e)+1)

            /* if the long version DOES NOT compare, but short version DOES, we have a problem */
            if ((translate(sefilename) = translate(sifilename)) & (lefilename \= lifilename)) then do
               endpos = pos('.',sefilename) - 1
               if endpos < 0 then endpos = length(sefilename)
               tildepos = pos('~',sefilename)
               if tildepos > 0 then
                  number = substr(sefilename, tildepos+1, endpos - tildepos) + 1
               endpos = pos('.',sifilename) - 1
               if endpos < 0 then endpos = length(sifilename)
               sifilename = left(sifilename,endpos-length(number)-1)'~'number||substr(sifilename,endpos+1)
               checkagain = 1
            end

         end

      end /* if short filename does not equal long filename */

      dirsfns.0 = i
      dirsfns.i = virtualpath'\'sifilename

      say 'Making' dirsfns.i
      call sysmkdir dirsfns.i
      call ProcessOneDirectory dirlfns.i,dirsfns.i

   end

return
