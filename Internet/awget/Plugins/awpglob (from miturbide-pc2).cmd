/* Auto WGet Daemon Global Plugin Sample
 * Copyright (C) 2001-2003 Dmitry A.Steklenev
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgment:
 *    "This product includes software developed by Dmitry A.Steklenev".
 *
 * 4. Redistributions of any form whatsoever must retain the following
 *    acknowledgment:
 *    "This product includes software developed by Dmitry A.Steklenev".
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR OR CONTRIBUTORS "AS IS"
 * AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * AUTHOR OR THE CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $Id: awpglob.cms,v 1.12 2003/01/16 08:16:00 glass Exp $
 */

signal on notready
globals = "job. sys."

parse version version .

if version = "OBJREXX" then do
   sys.open_read  = "OPEN READ  SHAREREAD"
   sys.open_write = "OPEN WRITE SHAREREAD"
   end
else do
   sys.open_read  = "OPEN READ"
   sys.open_write = "OPEN WRITE"
end

do forever
  parse value linein() with event +4 +1 info

  select
    when event == "INIT" then
       call lineout, "DONE PLUGIN is activated"

    when event == "STOP" then
       exit 0

    when event == "SCAN" then do
       call lineout, "INFO PLUGIN confirms scanning "info
       call lineout, "DONE"
       end

    when event == "CONF" then
       call lineout, "DONE PLUGIN updates configuration"

    when event == "SEXE" then do
       call JobRead info
       call lineout, "INFO PLUGIN confirms activating:"
       call lineout, "INFO "job.object
       call lineout, "DONE"
       end

    when event == "SEND" then do
       call lineout, "DONE"
       end

    otherwise
       call lineout, "FAIL PLUGIN receives unknown event:" event info
  end
end

notready: exit 1

/* $Id: jobs.cms,v 1.16 2001/10/08 17:56:34 glass Exp $ */

/*------------------------------------------------------------------
 * Read Job from file
 *------------------------------------------------------------------*/
JobRead: procedure expose (globals)

  parse arg pathname

  job.object               = ""
  job.url                  = ""
  job.download             = ""
  job.message_done         = ""
  job.message_error        = ""
  job.downloads_utility    = ""
  job.downloads_parameters = ""
  job.downloads_rc         = 0
  job.downloads_info       = ""

  rc = stream( pathname, "C", sys.open_read )

  if rc \= "READY:" then do
     return 0
  end

  do while lines(pathname) > 0
     parse value linein(pathname) with keyword "=" argument

     keyword  = translate(strip(keyword))
     argument = strip(argument)

     select
        when keyword == "OBJECT",
           | keyword == "URL",
           | keyword == "DOWNLOAD",
           | keyword == "DOWNLOADS_UTILITY",
           | keyword == "DOWNLOADS_PARAMETERS",
           | keyword == "DOWNLOADS_RC",
           | keyword == "DOWNLOADS_INFO",
           | keyword == "MESSAGE_DONE",
           | keyword == "MESSAGE_ERROR" then

             job.keyword = argument
        otherwise
     end
  end

  rc = stream( pathname, "C", "CLOSE" )
return 1

/*------------------------------------------------------------------
 * Save Job to file
 *------------------------------------------------------------------*/
JobSave: procedure expose (globals)

  parse arg pathname

  if arg( 1, "omitted" ) | pathname == "" then do
     pathname = SysTempFileName( dir.jobs"\?????.job" )
     body.0   = 0
     end
  else do
     rc = stream( pathname, "C", sys.open_read )

     do i = 1 while lines(pathname) > 0
        body.i = linein(pathname)
     end
     body.0 = i - 1
     rc = stream( pathname, "C", "CLOSE" )
  end

  key_list = "OBJECT "               ||,
             "URL "                  ||,
             "DOWNLOAD "             ||,
             "MESSAGE_DONE "         ||,
             "MESSAGE_ERROR "        ||,
             "DOWNLOADS_UTILITY "    ||,
             "DOWNLOADS_PARAMETERS " ||,
             "DOWNLOADS_RC "         ||,
             "DOWNLOADS_INFO "

  do i = 1 to words(key_list)
     key = word(key_list,i)

     do j = 1 to body.0
        if left( strip( body.j ), 1 ) == "#" then
           iterate

        parse value body.j with keyword "="
        keyword = translate(strip(keyword))

        if key == keyword then
           leave
     end j

     body.j = key "=" job.key

     if j > body.0 then
        body.0 = j
  end i

  '@del "'pathname'" /F 1>nul 2>nul'
  rc = stream( pathname, "C", sys.open_write )

  if rc \= "READY:" then do
     return ""
  end

  do j = 1 to body.0
     call lineout pathname, body.j
  end

  rc = stream( pathname, "C", "CLOSE" )
return pathname
