This currently two-membered collection of REXX socket utilities has been 
started due to what I perceive as a lack of simple-function Internet 
utilities around.

These utilities require Object REXX, and will not function with SAA REXX.  
If you are running Warp v4, then execute "switchrx" from a command line to 
activate Object REXX if you've not already done so.  Object REXX is 
backwards compatible with SAA REXX, and offers many benefits completely 
independant from object-oriented programming.  If you are running Warp v3, 
you can download a copy of Object REXX for free from IBM.  The current URL 
for that download is http://service.software.ibm.com/dl/rexx/orexx30-d
It contains bug fixes for problems in the libraries that shipped with Warp 
4, so users of that should upgrade to the latest fixpack, which includes 
the REXX update.

================================================================================

The utilities:

URL File Fetcher

This utility has a simple function - grab a file from a remote server using
either FTP or HTTP.  Just run urlget.cmd with the URL of the file to grab.
The protocol used is determined by the given URL.  Read urlget.txt for more 
information.

NNTP Group Lister

This utility also has a very simple function (a recurring theme) - grab a 
list of news groups from a news server.  Run ngfetch.cmd with the name of a 
news server as the argument.  It will fetch a list of all available news 
groups.  Read ngfetch.txt for more information.

================================================================================

Comments, questions, and problems can be directed to me, Mike Ruskai, at 
thanny@home.com.

================================================================================

History:

02-27-98  First iteration of this package, including httpget and 
          ngfetch.

02-28-98  Fixed stupid bug in ngfetch.cmd that lost groups sporadically, 
          and wrote article number information instead.

03-03-98  Modified ngfetch to display number of groups received in 
          status, and fixed screen display methods to work with the new 
          version of Object REXX recently downloaded.  We'll call this 
          v0.03

03-13-98  Modified httpget.cmd to display total file size (if available) 
          and percentage completion.  While testing this, discovered a 
          problem with files on the root directory that I created while 
          spiffing it up to allow multiple URL's.  
            
          I also came across bad behavior on the part of Microsoft IIS 3.0.  
          I was issuing a simple GET message via HTTP 1.0, and IIS was 
          replying with a 406 error, stating that there was no suitable 
          reply type.  406 is not a valid return code in HTTP 1.0!  It's 
          only valid in HTTP 1.1!  With HTTP 1.1, if the client doesn't send 
          a header with the acceptable transfer encoding specified, the 
          specs say that the server "MAY" assume any type.  Well, IIS was 
          violating those specs by assuming *ONE* type, specifically 
          text/html.  I've worked around this bug, which I hope is only in 
          IIS, by putting in 'Accept:' and 'Accept-Encoding:' header items.  
          I've also put in a catch for 406 (even though no web server 
          should be returning it to a HTTP 1.0 request), which will only 
          happen with some really screwy web server that doesn't properly 
          acknowledge the headers.  If you see this happening, please 
          uncomment the lines marked by the 406 comments, and send the 
          resulting file to thanny@home.com, so I can see who the culprit 
          server is.  

          I also reworked the break handling, since it was ignoring the
          HALT status while in an object method.  Should be able to press
          CTRL-C/BRK at any time without orphaning a socket now :)

          We'll call this one v0.04.  Working on digesting FTP specs...

04-07-98  Just a quick fix to remove boneheadedness on my part.  I 
          neglected to include the comma deliminator procedure in ngfetch,
          so it doesn't work for anyone who doesn't have such a procedure
          somewhere in the path (i.e. everyone but me).  Not worthy of it,
          but this is v0.05, just to have a number.

04-26-98  Added quiet mode to httpget and ngfetch, to suppress both the
          calculations and display of transfer status.  
        
          Added stats line upon the end of transfer that prints 
          out in quiet and non-quiet mode as final confirmation (and only 
          confirmation in quiet mode).

          Added excessive error handling to httpget, since it's getting
          bulky, and I don't want to strand sockets on people's computers
          if it crashes for any reason not found during testing.  

          Altered usage display of httpget and ngfetch to be more 
          clear for those not familiar with commandline argument standards, 
          though you still need to know that <> denotes mandatory, [] 
          denotes optional, and | means "or".  

          Fixed a very obscure "bug" that probably never happened to 
          anyone.  It's only by chance that I found it at all.  It could
          only happen with a *fast* connection.  What could happen is that
          the transfer of the first 10240 bytes would happen so quickly 
          that the REXX timer (which has a 0.01 second granularity) would
          give an elapsed time of 0 seconds, resulting in a divide-by-zero
          error when calculating the transfer rate.  Just made any zero
          times 0.01.

          Added User-Agent: tag to the header, specifying HTTPGet and
          Object REXX with their respective versions.

          Reformated history to be more readable (so I cheated).

          Call this version 0.06.  

05-31-98  Added version checking to prevent the programming from looking
          really nasty as it crashed with SAA REXX.  Don't know why this
          wasn't done in the first place.  After receiving a few e-mails
          about it, though, I've been straightened out <g>.  

08-07-98  Modified the display behavior of httpget to not show all the 
          transfer status junk if the remote file doesn't exist.

          Will only display local storage name if it differs from the 
          remote filename (which includes saving to a different directory
          locally).

          No more messages about socket handling; no longer says "Done!",
          which is obvious by that point.

          Modified the transfer rate calculation to reflect the "current"
          rate, rather than the overall rate so far.  What's actually
          calculated is the rate of the last four packets received.  Will
          not be very accurate for wildly erratic transfer rates.

          Tokenization pushes the EA size for this sucker to about 62KB, 
          pushing the limit.

          0.07 shall be the name of this creature.  Still working (slowly)
          on FTP specs.

08-12-98  Suddenly decided to implement FTP, and after a couple of hours of
          imagining just how to kill the writers of RFC959, httpget has gone
          the way of the dodo.  Replacing it is urlget, which will fetch
          files via either HTTP or FTP, as always by URL.  In the process,
          found some dormant bugs and fixed them.

          What's *actually* calculated for transfer rate is the last four
          measured intervals.  For faster connections, that will entail
          many more than four packets (between me and my server, it's
          about 1200 packets).

          Tokenization is history.  The spiffy new urlget is more than
          twice the size of httpget, running headfirst into the EA size
          barrier.

          Added a bit of code to gracefully fail if the programs cannot
          load the REXX Sockets functions.

          Updated and better implemented the error levels of ngfetch.cmd.

          Added errorlevels to urlget.cmd.

          This will be version 0.08, with no big ideas for other utilities
          left.  Will work on logging for next release, and tuning urlget
          up a bit.

08-13-98  Knocked off about 13KB worth of code from urlget.  I dislike a
          string of repetitive commands that are only slightly different, 
          so I made an arcane FTP command class, and looped through the
          server login and configuration procedure, with catches for the
          extra work that some commands required.  In the process, I 
          learned that either ::routine provides no way of exposing 
          main body variables, or the way to do it is undocumented.  This
          necessitated the passing of some variables that should be global.

          Tweaked a couple other things, to (hopefully) properly handle
          cases where either the filename or directory contain spaces.

          Fixed the handling of spaces in either the filename or path.

          This will be version 0.09.

09-18-98  Made a kludge to work around a bug in NCSA HTTPd version 1.5, 
          where response headers were followed by LF characters, instead
          of the CRLF pairs required by HTTP 1.0 (or 1.1, for that matter).
          
          Fixed a problem with unexpected failures of the STAT command, 
          which some inferior FTP servers actually don't support.  Also
          modified the parsing to work with a non-standard reply of STAT
          by a server I found.

          After learning that some FTP servers will deny passive mode for
          (dubious) security reasons, added the ability to transfer
          normally, with the server initiating the data connection.  To
          make this work properly, added a firewall flag to the program,
          which is part of the new config file (with all of two entries).
          If a server refuses passive mode, and the machine is configured
          as behind a firewall, then the transfer will fail (can't be 
          done).  Otherwise, a new socket is created, bound to, and 
          listened on before sending the file request.  I was shocked that
          it worked the first time I tested it <g>.  Note:  If your 
          firewall uses IP masquerading (or something like it), it may be 
          possible for FTP transfers to work without passive mode.  It 
          depends on whether the IP masquerader is smart enough to know 
          that FTP servers initiate data connections from the port number 
          immediately preceding the control connection port.  I don't know 
          one way or another.  If that's the case, then make the firewall
          setting in the config file 0.

          Wanted to do logging, but have been spending my free time with 
          C++ making a trivial program called the WarpAMP Playlist Editor.
          Will do logging for next release, unless I discover bugs to be
          quickly fixed.

          This is version 0.10.

10-01-98  Worked around the same bug as above for NCSA 1.5.1.

          Worked around flaky FTP servers (such as Serv-U 2.3b for Windows)
          reacting to a STAT command with parameters as if it were a STAT 
          command with no parameters.  That is, it was returning a success
          code of 211 when it should properly have issued a failure code, 
          since it did not process the command as requested.  

11-29-98  Rewrote the FTP handling completely.  Removed the arcane command 
          class to allow for more flexibility.  As a result, the bulk of 
          the program has increased, but it doesn't matter much, because
          it won't tokenize either way without using rexxc.exe to create
          a tokenized "executable".

          Added FTP status messages, so that if nothing's happening, one
          can at least see where the hangup is.

          Added resume capability for FTP receives.

          Added logging.  Put "logging=1" in the config file to enable it.

          Reworked the command line parsing.  It worked fine, but didn't 
          allow parameters very easily.  Now it does.

          Added command line switches:

            /l  - explicitly enable logging, regardless of config setting.
            /r  - attempt to resume FTP transfer if the local filename.
                  exists and is smaller than the server copy.
            /f  - same as /r, but will abort the transfer if the FTP server
                  doesn't support resume, or the file size on the server
                  can't be determined.
            /p  - attempt transfer when passive mode denied, and behind a
                  firewall - probably won't work, but what the heck.
            /d# - set the delay between attempting to send and receive data
                  during FTP processing - some servers seemed to break when
                  requests were made too quickly.  Default delay is 0.10 
                  seconds, maximum allowed setting is 60 seconds.
            /b# - set the transfer block size.  Generally speaking, larger
                  blocksizes make for quicker transfers, to a point.  Valid
                  values are from 512 bytes to 65535 bytes.  The default is
                  10240 bytes.
            /m# - set the maximum number of retries for failed socket
                  transfers.  The default is 1000, and the maximum is 
                  999999999.  This can be increased for patient people.

01-11-99  Somewhere along the way, fixed a few argument parsing problems,
          and perhaps some other small problems.

          Seems problem-free enough to release as version 0.12.

01-23-99  Changed ngfetch.cmd to use the same rate calculations as 
          urlget.cmd, so that the number would be based on the current 
          rate, rather than the average rate.  Also fixed it to close the
          socket after it's done, which was removed at some unknown point
          in the past, for some unknown reason.  Also changed it so that 
          any existing .newsrc file is not overwritten until the server
          looks as if it will cooperate, and send the data.

          Changed the configuration file of urlget.cmd to be an INI 
          profile, instead of a text-file.  This makes it easier to deal 
          with programmatically.  If it gets more complicated than three
          variables, I'll put in the ability to change them at will, one at 
          a time.  As it is, if you want to change something, you'll need 
          to delete the INI file and answer three questions, short of some
          hex editing, or your own programmatic solution.

          This will be version 0.13.

03-11-99  Changed the time display to only show hundredths of second.  
          After all, that's the resolution of the REXX timer.

          Changed the comma delimination to work with fractional numbers, 
          in case the transfer time breaks 1000 seconds (or should I say
          1,000 seconds?).

          Added /N option to avoid overwriting local files.  So, if the 
          filename exists, the transfer is aborted.  If FTP resume is
          enabled, the file will be appended to if it's smaller than the
          server copy, and the server supports resume.  If the file isn't
          smaller, can't have its size determined, or the server doesn't
          support resume, the transfer is aborted, just as with the /F 
          option.

          Put the status display on a separate thread, which will update at 
          a constant frequency regardless of whether or not data is coming 
          in from the socket.  As a result, the current transfer rate will
          be about as accurate as possible, and there will be no more long
          delays between updates with erratic speeds.

          Changed the newsgroup listing file to 'newsrc', instead of
          '.newsrc', since the latter won't work on FAT drives.

          Fixed a small error in ngfetch that counted one group too many,
          writing the terminating period.

          Changed all .environment objects to .local objects, because the
          former is shared across REXX processes, and we don't want to 
          screw up other REXX programs (including other instances of 
          urlget or ngfetch).

          This is version 0.14.

04-27-99  Somewhere along the line added the /W option to temporarily act 
          as if behind a firewall, using passive mode for FTP transfers.  
          If you find that the transfer doesn't commence after sending the 
          data port, try using this switch.  There are times when you have 
          a path to the remote server, but it doesn't have a path to you, 
          so can't make the data connection.

          I may have fixed other small bugs.  Don't know.  

          This is version 0.15, and the last conventional version of 
          urlget.cmd.  The next will perform up to eight transfers at a 
          time, use the same FTP connection for transfers on the same host 
          with the same user identity, and other good stuff.

01-10-00  OK, I lied.  I've been sidetracked by other projects, so the
          multiple transfer version of urlget hasn't been getting much
          attention.  I have periodically made small changes and
          enhancements to the conventional urlget, as I discovered
          problems, or thought of new features that I desired.  This update
          contains everything I've done to urlget.cmd over the past 8
          months or so.

          New features in urlget that I can remember:

              Local files aren't overwritten by default, if they exist and
              are the same size as the copy on the server.  Use the /c
              option to override this behavior, and overwrite regardless.

              The /qq option will suppress all program standard output.
              This can be useful if you're calling urlget from a script,
              and don't want your script's display messed up.  Logging
              is still performed, if enabled.

              URL list files can have comment lines.  A comment is any line
              that begins with '//', '/*', ';', or '#'.

              With URL lists, FTP transfers are more intelligent.  If the
              current server, port, and user ID are the same as those of
              the previous transfer, the same control connection is used.
              This saves the time of connecting and logging in when it
              isn't necessary.

              Eliminated the need to check for buggy NCSA HTTP servers (and
              a whole lot of them are buggy), by looking for dual CRLF and
              LF pairs, to indicate the ending of the header.

          New features in urlget that I can remember:

              Added options to control block size, status timing interval,
              and maximum retries.

              Added a randomized quicksort implementation, to sort the
              newsgroups after retrieval.  Since REXX is interpreted, this
              is somewhat slow.  It also requires that received groups be
              stored in memory.  With raw writes enabled, this will
              typically take up 1.5MB or so of RAM.  Without raw writes,
              it'll generally be less than half a megabyte.  This varies by
              the number of newsgroups, of course.

          New features in both:

              Made a few modifications to make it work in Object REXX for
              Windows 95.  Win95 will be automatically detected, and
              options affected accordingly.  The only two differences in
              program behavior are that the code for adding a .LONGNAME
              extended attribute on FAT drives is skipped, and all calls to
              SysSleep() use whole second granularity (a limitation in the
              Win95 version of REXXUTIL).  The latter affects the status
              timing interval, and FTP command delay.  Command line options
              are processed accordingly (i.e. specifying anything other
              than whole seconds when running Win95 isn't allowed).

          There are probably other additions and bug fixes that I don't
          recall offhand.

          This is version 0.16, and I still intend to work on the multiple
          transfer version.  Ultimately, it will do everything that WGET
          does, and more.  In the meantime, I might still make adjustments
          to the current urlget.cmd, and release them (#1 on my current
          list is to handle HTTP redirections).
