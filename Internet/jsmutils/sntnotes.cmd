/***************************************************************************/
/*                                                                         */
/*    Converts Post Road Mailer 2.X and 3.X Drafts and Sent Notes, from    */
/*     the Post Road Mailer outbasket note format, to the normal *.POP     */
/*      file format used by the J Street Mailer as well as many other      */
/*    programs. Also copies files which are already in the normal *.POP    */
/*       file format, without doing any conversion since there is no       */
/*                      conversion to be done on them.                     */
/*                                                                         */
/*              Parameters: source_directory target_directory              */
/*                                                                         */
/*     InnoVal Systems Solutions, Inc., and the authors cannot be held     */
/*    responsible for damage that might occur while using this program.    */
/*                          Use at your own risk.                          */
/*                                                                         */
/***************************************************************************/

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
signal on syntax name NoRexx
call SysLoadFuncs
signal on syntax name Syntax
signal on halt name Halt
'@ECHO OFF'
parse arg args
call parsequotes
if ARG.0<>2 then do
   say
   say "Invalid syntax."
   say
   say "Specify the full pathname of the source directory and the full"
   say "pathname of the target directory."
   exit
end
source_dir=arg.1
target_dir=arg.2
drop args arg.
if substr(source_dir,2,2)<>":\" | substr(target_dir,2,2)<>":\" | ,
      length(source_dir)<4 | length(target_dir)<4 then do
   say
   say "Invalid syntax."
   say
   say "Source and target specifications must be full pathnames of"
   say "directories other than root directories."
   exit
end
if translate(source_dir)=translate(target_dir) then do
   say
   say "Invalid syntax."
   say
   say "Source and target directories must be different."
   exit
end
if right(source_dir,1)='\' then source_dir=shorten(source_dir,1)
call sysfiletree source_dir'\*.POP',files,'FO'
if files.0=0 then do
   say
   say "Invalid syntax."
   say
   say source_dir
   say "Specified source directory contains no *.POP files."
   exit
end
if right(target_dir,1)='\' then target_dir=shorten(target_dir,1)
call sysfiletree target_dir,target,'DO'
if target.0<>1 then do
   say
   say "Invalid syntax."
   say
   say target_dir
   say "Specified target directory does not exist."
   exit
end
say
done=0
do i=1 to files.0
   restart=1
   mime=0
   headerdone=0
   outfile=getpopname(target_dir,"POP")
   do while outfile="error"
      call syssleep 3
      outfile=getpopname(target_dir,"POP")
   end
   do while lines(files.i)
      line=linein(files.i)
      if headerdone=0 & left(line,1)<>"05"x then do
         headerdone=1
         if mime>0 then do
            call lineout outfile,"X-Encoding-Style: MIME"
            call lineout outfile,"X-Attachments:" mimenames
         end
         if restart=0 then call lineout outfile,""
      end
      if restart=1 then restart=0
      if left(line,1)<>"05"x then call lineout outfile,line
      else do
         parse var line . 2 tag 3 line
         select
            when tag="01"x then call lineout outfile,"To:" line
            when tag="02"x then call lineout outfile,"Cc:" line
            when tag="03"x then call lineout outfile,"Bcc:" line
            when tag="0B"x then call lineout outfile,"From:" line
            when tag="0F"x then call lineout outfile,"Subject:" line
            when tag="21"x then do
               if mime=0 then mimenames=line
               else mimenames=mimenames||"09"x||line
               mime=mime+1
            end
            when tag="26"x then do
               call lineout outfile,"X-Encoding-Style: UUENCODE"
               call lineout outfile,"X-Attachments:" line
            end
            when tag="30"x then call lineout outfile,"X-Bounce: Yes"
            when tag="31"x then call lineout outfile,"Reply-to:" line
            when tag="32"x then call lineout outfile,"Priority:" line
            when tag="33"x then call lineout outfile,"Acknowledge-to:" line
            when tag="34"x then call lineout outfile,""
            otherwise nop
         end
      end
   end
   call closefile files.i
   call closefile outfile
   say files.i "-->" outfile
   done=done+1
end
say
say done "*.POP files converted/copied."
exit
Syntax:
  say 'Error' rc 'in line' sigl':' errortext(rc)
  say sigl':' sourceline(sigl)
  exit
return
NoRexx:
   say 'Unable to load the REXXUtil functions.  Either the REXXUTIL.DLL file'
   say 'is not on the LIBPATH or REXX support is not installed on this system.'
   exit
return
Halt:
   say ""
   say "Program interrupted by Ctrl-C, ShutDown, or closing of WorkArea."
   exit
return
Shorten:
PROCEDURE
   parse arg STRING,NUMBER
   STRING=substr(STRING,1,length(STRING)-NUMBER)
return STRING
CloseFile:
PROCEDURE
   parse arg FILENAME
   if stream(FILENAME)<>"UNKNOWN" then call lineout FILENAME
return
ParseQuotes:
i=0
do until ARGS=""
   i=i+1
   ARGS=strip(ARGS)
   if left(ARGS,1)='"' then parse var ARGS . '"' ARG.i '"' ARGS
   else parse var ARGS ARG.i ARGS
end
ARG.0=i
return
/* Copyright (c)1996,1997 Kari Jackson for InnoVal Systems Solutions, Inc. */
/* Subroutine to produce a *.POP-style filename */
/* Returns d:\dirname\filename.ext or "error" */
GetPopName:procedure
parse arg directory,extension
if right(directory,1)='\' then directory=substr(directory,1,length(directory)-1)
if left(extension,1)='.' then extension=substr(extension,2)
characters='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
parse value date("O") with . 2 year "/" month "/" day
parse value time() with hour ":" minute ":" second
month=substr(characters,month+1,1)
day=substr(characters,day+1,1)
hour=substr(characters,hour+1,1)
fifth=minute%36
sixth=substr(characters,minute//36+1,1)
test=second//36
string=year||month||day||hour||fifth||sixth
do j=1 to 36
   test2=(test+j)//36
   if test2=0 then seventh=substr(characters,36,1)
   else seventh=substr(characters,test2,1)
   do i=1 to 36
      tryit=string||seventh||substr(characters,i,1)
      filename=directory||"\"||tryit||'.'||extension
      if stream(filename,'c','query exists')='' then return filename
   end
end
/* there have already been 1296 files created in that directory this minute */
return 'error'
