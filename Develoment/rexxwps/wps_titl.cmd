/* Program name:  WPS_TITL.CMD  Title: Figure 6              */
/* REXX Report              Issue: Summer '95, page 42-51    */
/* Article title: The Workplace Shell: Objects to the Core   */
/* Author: Rony G. Flatscher                                 */
/* Description: utilizing REXX to communicate with the       */
/*              Workplace Shell                              */
/* Program requirements: OS/2 Warp                           */
/*                                                           */


/* WPS_TITL.CMD: show setting a title                               */

/* setting a title with SysCreateObject                             */
title = "This is a title,^this is the second line;^this the third !"
objectid     = "<RGF Testfolder for title>"
setup_string = "ICONPOS=15,30;OBJECTID=" || objectid || ";"

ok = SysCreateObject("WPFolder",,       /* instance of WPFolder     */
                     title,,            /* object title             */
                     "<WP_DESKTOP>",,   /* location: desktop        */
                     setup_string,,     /* setup string             */
                     "F")               /* fail, if object exists   */
SAY "creating:" objectid "-" worked(ok)
"@PAUSE"

/* note how to escape a semi-colon which usually ends a key-value   */
setup_title = "This is a title,^this is the 2nd line^;^this the 3rd!"

setup_string = "TITLE=" || setup_title || ";"
ok = SysSetObjectData(objectid, setup_string)       /* change title */
SAY "changing title:" objectid "-" worked(ok)
"@PAUSE"

SAY "cleaning up..."
ok = SysDestroyObject(objectid)         /* delete folder            */
SAY "destroying (deleting):" objectid "-" worked(ok)

EXIT

/* procedure to indicate successful/not successful                  */
WORKED: PROCEDURE
   IF ARG(1) THEN RETURN "successful."
             ELSE RETURN "*** NOT succesful ***"
