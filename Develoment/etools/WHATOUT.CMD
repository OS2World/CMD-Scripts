/* Generic in command for tlib - uses the 'whoami' command for the 'w'
   Parameter - must have netware to use this! */
/* trace results */
ARG name

lastline = 'name'
fileptr = 0

/* kill the existing queue entries */
lines = QUEUED()
DO x = 1 TO lines
   PARSE PULL junk
END

if (name = "") then
   do
      /* find out who is issueing this command */
      '@whoami | rxqueue'

      PARSE PULL wholine
      name = WORD(wholine,4)
   end

namelen = LENGTH(name)

lines = QUEUED()
DO x = 1 TO lines
   PARSE PULL junk
END

say
say name 'has the following files checked out for version 1.10'
say

'@type "q:\eis\lib\*.?^?"  2>&1 | rxqueue'
lines = QUEUED()
DO x = 1 TO lines
   PARSE PULL line
   line = STRIP(line)
   testname = SUBSTR(line,1,namelen)
   if (line <> "") then
     do
      if (lastline = "name") then
         do
            lastline = "file"
            filename = line
         end
      else
         do
            lastline = "name"
            if (testname = name) then
               do
                  fileptr = fileptr + 1
                  parse var filename junk1 "\" junk2 "\" junk3 "\" filearray.fileptr
               end
         end
     end
end  /* do */
/*  trace results*/

DO x = 1 TO fileptr

   parse var filearray.x front '^' back
   filearray.x = front || '?' || back
   CALL CleanQueue
   '@attrib q:\eis\source\' || filearray.x || ' > nul'
   if (rc = 0) then
      do
         '@attrib q:\eis\source\' || filearray.x || ' | rxqueue'
         PARSE PULL line
         line = STRIP(line,'t')
         realname = substr(line,26,(LENGTH(line)-25))
         say realname
      end

END
EXIT

CleanQueue:
   lines = QUEUED()
   DO y = 1 TO lines
      PARSE PULL junk
   END
return
