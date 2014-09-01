/* Program name:  WPS_NDEL.CMD  Title: Figure 5              */
/* REXX Report              Issue: Summer '95, page 42-51    */
/* Article title: The Workplace Shell: Objects to the Core   */
/* Author: Rony G. Flatscher                                 */
/* Description: utilizing REXX to communicate with the       */
/*              Workplace Shell                              */
/* Program requirements: OS/2 Warp                           */
/*                                                           */


/* WPS_NDEL.CMD: make all WPS-default objects non-deletable         */

/* query all WPS-OBJECTID's (OS2.INI, app; "PM_Workplace:Location") */
CALL SysIni "USER", "PM_Workplace:Location", "ALL:", "object_id"

leadin_string = "<WP_"     /* work on WPS-objects only              */
setup = "NODELETE=YES;"    /* setup string: change to not deletable */
SAY "Trying to make all WPS-objects non-deletable:"; SAY

DO i = 1 TO object_id.0    /* loop over all entries                 */
   IF ABBREV(object_id.i, leadin_string) THEN   /* WPS-OBJECTID ?   */
   DO
      ok = SysSetObjectData(object_id.i, setup) /* change state     */
      SAY LEFT(object_id.i || " ", 57, ".") WORKED(ok)
   END
END
EXIT                                    /* end of program           */


/* procedure to indicate successful/not successful                  */
WORKED: PROCEDURE
   IF ARG(1) THEN RETURN "successful."
             ELSE RETURN "*** NOT succesful ***"
