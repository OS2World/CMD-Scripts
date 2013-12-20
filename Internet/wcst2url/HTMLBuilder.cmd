/*
 *
 * HTMLBuilder v1.0 - (c) 1997
 * Create an HTML file out of WarpCast URLs created by createURL.cmd
 *
 * G.Aprile A.Resmini P.Rossi
 * resmini@netsis.it
 *
 * Needless to say, this is absolutely FREEWARE, comes with no
 * warranties whatsoever, and does not work in Windows.
 * Actually, you would need some 10MBs program to do this, in Windows.
 * ;)
 *
 * G.Aprile and A.Resmini are members of teamOS2 Italy
 *
 * This Rexx procedure creates a simple HTML file which keeps track of
 * Warpcast URLs. The HTML source code uses no frames.
 * 
 * URLs are tracked and assigned a NORMAL, NEW or UPDATED state.
 * As a default an URL becomes NORMAL if 7 days pass without it being
 * updated. You can set this value changing the ExpireDate variable.
 * An URL is NEW if it has never been broadcasted before.
 * NEW and UPDATED URLs are assigned corresponding icons, while NORMAL
 * URLs have no distinctive sign.
 * You can set your preferred images for the NEW or UPDATED status by
 * changing the newJPG and updJPG variables, or by overwriting the
 * new.jpg and upd.jpg in the HTMLBuilder folder.
 *
 * You will need the FILEREXX rexx extensions, available on Hobbes as
 * filerx.zip (should be in the \rexx directory)
 *
 */

    call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
    call SysLoadFuncs
    call RxFuncAdd 'FileLoadFuncs', 'FILEREXX', 'FileLoadFuncs'
    call FileLoadFuncs

 /* Set a bunch of variables and explain them */

 /*
  * This is the amount of time after which an URL which is not updated
  * is set to normal status.
  */

    ExpireDate = 7

 /*
  * Set the images used in the HTML file for signalling a NEW or UPDATED
  * link. The double quotes are used for writing it in HTML style,
  * <img src = "new.jpg ">
  */
   
    newJPG = '"new.jpg"'
    updJPG = '"upd.jpg"'


 /*
  * This is the data file created by createURL.cmd.
  * If you change this, change it in both files.
  */

    NameDat = 'wcastidx.dtf'

 /*
  * A dat file which holds all of your URLs from Warpcast.
  * This is the main archive. If you delete it, you loose track of what
  * is new and what is not.
  */

    HTMLDat = 'warpcast.dtf'

 /* The HTML file */

    nameHTML = 'warpcast.html'

 /* Handles. Just leave them alone. */

    handle.0 = 3
    handle.1 = 0
    handle.2 = 0
    handle.3 = 0

    handle.1 = FileOpen(NameDat,'rw','e')
    if handle.1 = 0 then
     do
       if FileClose(handle.1) = 0 then handle.1 = 0
       say 'Wow, an OS error while creating the file ' || NameDat
     end
     dateUpdated = FileGets(handle.1,'t')
     nDateControlExpire = DateToNumber(dateUpdated)
     nCount = 0
     do while FileErr <> 0
        err = FileGets(handle.1,'t')
        if FileErr <> 0 then
           do
           nCount = nCount + 1
           aDatiWCast.nCount.Titolo = err
           aDatiWCast.nCount.Url = FileGets(handle.1,'t')
           aDatiWCast.nCount.Flag = FileGets(handle.1,'t')
           end
     end

        aDatiWCast.0 = nCount

    if FileClose(handle.1) = 0 then handle.1 = 0

    handle.2 = FileOpen(HTMLDat,'rw','en')
    if handle.2 = 0 then
     do
       if FileClose(handle.2) = 0 then handle.2 = 0
       say 'Wow, an OS error while creating the file ' || HTMLDat
     end

     dateUpdatedHtml = FileGets(handle.2,'t')
     nCount = 0
     do while FileErr <> 0
        err = FileGets(handle.2,'t')
        if FileErr <> 0 then
           do
                nCount = nCount+1
                aDatiHtml.nCount.Titolo = err
                aDatiHtml.nCount.Url = FileGets(handle.2,'t')
                aDatiHtml.nCount.Data = FileGets(handle.2,'t')
                aDatiHtml.nCount.Flag = FileGets(handle.2,'t')
                if  nDateControlExpire - DateToNumber(aDatiHtml.nCount.Data) >= ExpireDate then
                    do
                     aDatiHtml.nCount.Flag = 'Normal'
                    end
           end
     end
        aDatiHtml.0 = nCount

       if FileClose(handle.2) = 0 then handle.2 = 0

 /* Start first loop */

       do wcast = 1 to aDatiWCast.0
          Matching = 0

 /* Start second loop */

       do wHtml = 1 to aDatiHtml.0

           if aDatiWCast.wcast.Url = aDatiHtml.wHtml.Url then
              do
                aDatiHtml.wHtml.Data = dateUpdated
                aDatiHtml.wHtml.Flag = aDatiWCast.wcast.Flag
                Matching = 1
              end
       end

 /* End second loop */

         if Matching = 0 Then

            do
             aDatiHtml.0 = aDatiHtml.0 + 1
             nTemp = aDatiHtml.0
             aDatiHtml.nTemp.Titolo = aDatiWCast.wCast.Titolo
             aDatiHtml.nTemp.Url = aDatiWCast.wCast.Url
             aDatiHtml.nTemp.Data = dateUpdated
             aDatiHtml.nTemp.Flag = aDatiWCast.wCast.Flag
            end

       end

 /* End first loop */

    handle.2 = FileOpen(HTMLDat,'rw','on')
    if handle.2 = 0 then
     do
       if FileClose(handle.2) = 0 then handle.2 = 0
       say 'Wow, an OS error while creating the file ' || HTMLDat
     end
     err = Fileputs(handle.2,dateupdated)

          do wHtml = 1 to aDatiHtml.0

           err=FilePuts(handle.2, aDatiHtml.wHtml.Titolo)
           err=FilePuts(handle.2, aDatiHtml.wHtml.Url)
           err=FilePuts(handle.2, aDatiHtml.wHtml.Data)
           err=FilePuts(handle.2, aDatiHtml.wHtml.Flag)

          end

       if FileClose(handle.2) = 0 then handle.2 = 0

        Call Sort
    handle.3 = FileOpen(nameHTML,'rw','on')
    if handle.3 = 0 then
     do
       if FileClose(handle.3) = 0 then handle.3 = 0
       say 'Wow, an OS error while creating the file ' || nameHTML
     end

 /*
  * Now let's start writing something which resembles HTML code
  * into the file.
  */

  err=FilePuts(handle.3,'<!-- doctype html public "-//wc3//dtd html 3.2//en" -->')
  err=FilePuts(handle.3,'<!-- document ' || nameHTML || ' created on ' || dateUpdated || '  -->' )
  err=FilePuts(handle.3,'')
  err=FilePuts(handle.3,'<html>')
  err=FilePuts(handle.3,'  <head>')
  err=FilePuts(handle.3,'    <meta name="generator" content="HTMLBuilder v1.0">')
  err=FilePuts(handle.3,'    <title>WarpCast New and Updated Links for ' || dateUpdated || '</title>')
  err=FilePuts(handle.3,'  </head>')
  err=FilePuts(handle.3,'')
  err=FilePuts(handle.3,'  <!-- body of the HTML document begins -->')
  err=FilePuts(handle.3,'')
  err=FilePuts(handle.3,'  <body text="#000000" bgcolor="#ffffff" link="#0000cc" vlink="#970000" alink="#00a000">')
  err=FilePuts(handle.3,'')
  err=FilePuts(handle.3,'  <center>')
  err=FilePuts(handle.3,'    <img src="wcast.jpg">')
  err=FilePuts(handle.3,'  </center>')
  err=FilePuts(handle.3,'')
  err=FilePuts(handle.3,'  <table>')

          do wHtml = 1 to aDatiHtml.0
                  err=FilePuts(handle.3,'   <tr>')

              Select
                 When aDatiHtml.wHtml.Flag = 'UpDated' then
                   do
                    err=FilePuts(handle.3,'     <td width = "20%">')
                    err=FilePuts(handle.3,'       <img src= ' || updJPG || ' >')
                    err=FilePuts(handle.3,'     </td>')
                   End
                 When aDatiHtml.wHtml.Flag = 'New' then
                   do
                    err=FilePuts(handle.3,'     <td width = "20%">')
                    err=FilePuts(handle.3,'       <img src= ' || newJPG || ' >')
                    err=FilePuts(handle.3,'     </td>')
                   End
                  Otherwise
                   do
                    err=FilePuts(handle.3,'     <td width = "20%">')
                    err=FilePuts(handle.3,'')
                    err=FilePuts(handle.3,'     </td>')
                   End
              End
                err=FilePuts(handle.3,'     <td width = "80%" valign="top">' )
                err=FilePuts(handle.3,'       <font color="#880000">')
                err=FilePuts(handle.3,'         <h3><a href="' || aDatiHtml.wHtml.Url || '">' || aDatiHtml.wHtml.Titolo || '</a><br>')
                err=FilePuts(handle.3,'         Last updated ' || aDatiHtml.wHtml.Data || '<br>')
                err=FilePuts(handle.3,'       </font>')
                err=FilePuts(handle.3,'       <p>')
                err=FilePuts(handle.3,'     </td>')
                err=FilePuts(handle.3,'   </tr>')
          end

  err=FilePuts(handle.3,' </table>')
  err=FilePuts(handle.3,'')
  err=FilePuts(handle.3,'  <pre>')
  err=FilePuts(handle.3,'  </pre>')
  err=FilePuts(handle.3,'')
  err=FilePuts(handle.3,'  <center>')
  err=FilePuts(handle.3,'    <font size="-1">')
  err=FilePuts(handle.3,'      WarpCast New and Updated links - ' || date('L') || '<br>')
  err=FilePuts(handle.3,'      Created by HTMLBuilder v1.0 - December 1997<br>')
  err=FilePuts(handle.3,'    </font>')
  err=FilePuts(handle.3,'  </center>')
  err=FilePuts(handle.3,'')
  err=FilePuts(handle.3,'  </body>')
  err=FilePuts(handle.3,'')
  err=FilePuts(handle.3,'  <!-- body of the HTML document ends -->')
  err=FilePuts(handle.3,'')
  err=FilePuts(handle.3,'</html>')

       if FileClose(handle.3) = 0 then handle.3 = 0

 /*
  * Bonus: create an object for the Warpcast HTML file so you can drag it
  * on Netscape/2 or WebExplorer or whatever.
  *
  * This instruction was used when we were about to create an URL for it. 
  * dir = translate( directory() || '/', '|/', ':\')
  * Now it's just shadowed. :)
  */

   dir = directory() || '\'

   classname = 'WPShadow' 
   title = 'Warpcast links'
   location = '<WP_DESKTOP>'
   setup = 'SHADOWID =' || dir || nameHTML
   flag = 'U'

   rc = SysCreateObject(classname, title, location, setup, flag)


 /*
  * This is stolen directly from the Allfigures.txt in the rexxwps.zip
  * package you can find as usual on Hobbes. Straight from the original txt:
  *
  * "What follows, is a *complete* ASCII-list of the figures I submitted
  * Miller & Freeman (producer of "OS/2 Developer") together with my article
  * for this year's "REXX Report, Summer '95", September 95).  So it includes
  * also the tables for all documented keyword/value pairs of the discussed
  * WPS object classes."
  *
  * The author is Rony G. Flatscher and the file is an ASCII version of his
  * article 'The Workplace Shell: Objects to the Core'.
  * We are using here just a sort function, but the file contains lots of
  * interesting examples and infos.
  *
  * 'One of Knuth's algorithms; sort object classes in stem ObjCls.'
  */

  Sort:

   M = 1
   DO WHILE (9 * M + 4) < aDatiHtml.0
      M = M * 3 + 1
   END

   DO WHILE M > 0
      K = aDatiHtml.0 - M
      DO J = 1 TO K
         Q = J
         DO WHILE Q > 0
            L = Q + M

            IF TRANSLATE(aDatiHtml.Q.Titolo) <<= TRANSLATE(aDatiHtml.L.Titolo) THEN
               LEAVE
            tmp      = aDatiHtml.Q.Titolo
            aDatiHtml.Q.Titolo = aDatiHtml.L.Titolo
            aDatiHtml.L.Titolo = tmp
            Q = Q - M
         END
      END
      M = M % 3
   END
   RETURN


 /*
  * This function handles the string => date translations we need,
  * since we have dates in 'Mon, 15 Dec 1997' format.
  */

  DateToNumber:

   parse arg dDate
   parse var dDate cTemp.1 cTemp.2 cTemp.3 cTemp.4

   Select
    when cTemp.3 = 'Jan' then cTemp.3 = 1
    when cTemp.3 = 'Feb' then cTemp.3 = 2
    when cTemp.3 = 'Mar' then cTemp.3 = 3
    when cTemp.3 = 'Apr' then cTemp.3 = 4
    when cTemp.3 = 'May' then cTemp.3 = 5
    when cTemp.3 = 'Jun' then cTemp.3 = 6
    when cTemp.3 = 'Jul' then cTemp.3 = 7
    when cTemp.3 = 'Aug' then cTemp.3 = 8
    when cTemp.3 = 'Sep' then cTemp.3 = 9
    when cTemp.3 = 'Oct' then cTemp.3 = 10
    when cTemp.3 = 'Nov' then cTemp.3 = 11
    when cTemp.3 = 'Dec' then cTemp.3 = 12
   End

  nDays = cTemp.2 + cTemp.3*30 + cTemp.4 * 365

  Return nDays
