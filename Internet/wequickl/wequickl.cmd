/* 
program: wequickl.cmd
type:    REXXSAA-OS/2
purpose: read WebExplorer's quicklist entries and generate WPS-URL-objects
version: 1.0
date:    1995-06-05

usage:   wequickl
         ... generates WPS-URL-objects from WE-quicklist in explore.ini
author:  Rony G. Flatscher, Wirtschaftsuniversitaet/Vienna

standard disclaimer:

All rights reserved, copyrighted 1995, no guarantee that it works without
errors, etc. etc.

donated to the public domain granted that you are not charging anything
(money etc.) for it and derivates based upon it, as you did not write it,
etc. if that holds you may bundle it with commercial programs too
*/
 
/* check whether OS/2's RexxUtil functions are loaded, if not, load them      */
IF RxFuncQuery('SysLoadFuncs') THEN
DO
    /* load the RexxUtil-load-function                                        */
    CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
    /* load all the Sys* utilities via "SysLoadFuncs"                         */
    CALL SysLoadFuncs
END
                                             /* get full path for explore.ini */
explore_ini = VALUE("ETC", , "OS2ENVIRONMENT") || "\explore.ini"

IF STREAM(explore_ini, "C", "QUERY EXISTS") = "" THEN
   CALL error explore_ini": WebExplorer INI-file does not exist !"

/* get quicklist entries (titles and URLs)                                    */

i = 0                                           /* counter for array index    */
quicklist_found = 0                             /* boolean, false             */
quicklist.0 = 0                                 /* indicate no items in array */
url_next    = 0                                 /* indicate if URL expected   */

CALL STREAM explore_ini, "C", "OPEN READ"       /* open file for reading only */
DO WHILE CHARS(explore_ini) > 0                 /* as long as lines left      */
   line = LINEIN(explore_ini)                   /* read line                  */

   IF LEFT(line, 1) = "[" THEN                  /* new section found          */
   DO
      IF \quicklist_found THEN                  /* quicklist section ?        */
      DO
         IF TRANSLATE(line) = "[QUICKLIST]" THEN  /* is it the quicklist part?*/
            quicklist_found = 1
         ITERATE                                /* jump to top, read next line*/
      END
      ELSE                                      /* quicklist section is over  */
         LEAVE
   END

   IF \quicklist_found THEN ITERATE             /* skip line                  */

   IF \url_next THEN                            /* title in hand              */
   DO
      i = i + 1                                 /* new entry, increase index  */
      PARSE VAR line "quicklist= " title        /* parse URL itself           */
      quicklist.i.eTitle = title                /* save title of URL          */
   END
   ELSE
      quicklist.i.eURL   = line                 /* save URL                   */

   url_next = \url_next                         /* switch boolean value       */
END

quicklist.0 = MAX(0, i - 1)                     /* save # of items in array   */
CALL STREAM explore_ini, "C", "CLOSE"           /* close input file           */

IF quicklist.0 = 0 THEN
   CALL error explore_ini || ": no quicklist items found!"

/* create folder to contain the URLs ******************************************/
web_folder_id = "<RGF WEB QUICKLIST>"           /* Object ID for WEB folder   */

ok = SysCreateObject(,
      "WPFolder",,                              /* Object type                */
      "WEB Quicklist Folder",,                  /* Title                      */
      "<WP_DESKTOP>",,                          /* Location                   */
      "OBJECTID=" || web_folder_id || ";",,     /* object ID                  */
      "F")                                      /* fail, if exists            */

SAY right("", 3) "WEB Quicklist folder - creation status:" feedback_message(ok)

                                             /* set flowed and mini icon view */
ok = SysSetObjectData(web_folder_id, "ICONVIEW=FLOWED,MINI;")
SAY right("", 3) "SysSetObjectData() status:" feedback_message(ok)
SAY

/* create WE-objects, if they don't exist yet in top folder *******************/
DO i = quicklist.0 TO 1 BY -1                   /* loop over array            */
   SAY right(i,3) quicklist.i.eTitle            /* show index, URL-title      */
   SAY right("", 3) quicklist.i.eURL            /* show URL                   */

   ok = SysCreateObject(,
              "WebExplorer_Url",,               /* Object type                */
              quicklist.i.eTitle,,              /* Title                      */
              web_folder_id,,                   /* Location                   */
              "LOCATOR=" || quicklist.i.eURL,,  /* URL                        */
              "F")                              /* fail, if exists            */

   SAY right("", 3) "creation status:" feedback_message(ok) /* show status    */
END 

SAY
SAY "total of" quicklist.0 "quicklist entries processed."

EXIT

/*
   little procedure, to tell whether creation was successfully, 
   expects boolean (0 = false, 1 = true)
*/
FEEDBACK_MESSAGE: PROCEDURE
   IF ARG(1) THEN RETURN "successful."
             ELSE RETURN "*** NOT succesful *** (one reason: maybe it exists ?)"
/*
   procedure to tell error and exit with a negative return code
*/
ERROR:
   SAY "ERROR:" ARG(1) "aborting ..."
   EXIT -1
