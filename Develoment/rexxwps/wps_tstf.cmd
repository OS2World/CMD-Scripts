/* Program name:  WPS_TSTF.CMD  Title: Figure 8              */
/* REXX Report              Issue: Summer '95, page 42-51    */
/* Article title: The Workplace Shell: Objects to the Core   */
/* Author: Rony G. Flatscher                                 */
/* Description: utilizing REXX to communicate with the       */
/*              Workplace Shell                              */
/* Program requirements: OS/2 Warp                           */
/*                                                           */


/* WPS_TSTF.CMD: test folders, shadows and moving objects           */

/******* create four folders on the desktop to play with ************/
DO i = 1 TO 4
   objectid = "<RGF Testfolder_" || i || ">" /* unique objectid     */
   title    = "Testfolder #" i
   folder.i = objectid                       /* save for later use  */
   y_pos = 100 - i*20                        /* placement on y-axis */
   setup = "ICONPOS=5," || y_pos || ";" ||,  /* icon placement      */
           "ICONVIEWPOS=15," || y_pos   ||,  /* initial folder dim: */
                        ",35,20;"       ||,  /* relative to icon    */
           "OBJECTID=" || objectid || ";"    /* assign objectid     */

   ok = SysCreateObject(,           /* create object                */
         "WPFolder",,               /* Object type: WPS-Folder      */
         title,,                    /* Title                        */
         "<WP_DESKTOP>",,           /* create on desktop            */
         setup,,                    /* setup-string                 */
         "F")                       /* fail, if object exists       */

   SAY "creating:" objectid "-" worked(ok)
END
folder.0 = 4                        /* indicate 4 elements in array */
SAY                                 /* display empty line           */

/******* change state-data to open folder in icon view **************/
"@PAUSE"
DO i = 1 TO 3                       /* open first three folders     */
   setup = "OPEN=ICON;"             /* open them using icon view    */
   ok = SysSetObjectData(folder.i, setup)
   SAY "setup object data ["setup"] for" folder.i  "-" worked(ok)
END

/******* create shadow of OS/2 Configuration Folder *****************/
shadObjID = "<RGF Testshadow_1>"        /* OBJECITD of shadow       */
folder.5  = shadObjID                   /* memorize                 */
folder.0  = 5                           /* now we have 5 elements   */
setup = "SHADOWID=<WP_CONFIG>;" ||,     /* shadow OS2-config folder */
        "OBJECTID=" || shadObjID || ";" /* OBJECTID of shadow       */

ok = SysCreateObject(,                  /* create object            */
      "WPShadow",,                      /* Object type: WPS-Shadow  */
      title,,                           /* Title                    */
      folder.1,,                        /* put into folder # 1      */
      setup,,                           /* setup-string             */
      "F")                              /* fail, if object exists   */
SAY "creating shadow for" folder.5  "-" worked(ok)
SAY                                     /* display empty line       */

/******* move Testfolder # 4 between the first three folders ********/
location1 = 1                         /* shadow in folder #1        */
location2 = 0                         /* folder #4 on desktop       */

DO FOREVER
   SAY "Press enter to animate (enter 'exit' to end):"
   PARSE UPPER PULL input             /* get input from user        */
   IF LEFT(input, 1) = "E" THEN LEAVE /* just check first letter    */

   location1 = (location1 //  3) + 1  /* next folder for shadow     */
   location2 = (location2 //  3) + 1  /* next folder for folder # 4 */

   ok = SysMoveObject(shadObjID, folder.location1)   /* move shadow */
   SAY "moving shadow" shadObjID "to" folder.location1 "-" worked(ok)
   ok = SysMoveObject(folder.4, folder.location2)    /* move folder */
   SAY "moving folder" folder.4 "to" folder.location2 "-" worked(ok)
   SAY                                /* display empty line         */
END

/******* delete test folders ? (delete, if first letter is "Y" ******/
SAY "Delete test folders ? (Yes/No)"
PARSE UPPER PULL input
IF LEFT(input, 1) = "Y" THEN         /* delete test folders ?       */
DO i = folder.0 TO 1 BY -1           /* delete, start with # 3      */
   ok = SysDestroyObject(folder.i)
   SAY "destroying (deleting):" folder.i "-" worked(ok)
END

EXIT

/* procedure to indicate successful/not successful                  */
WORKED: PROCEDURE
   IF ARG(1) THEN RETURN "successful."
             ELSE RETURN "*** NOT succesful ***"
