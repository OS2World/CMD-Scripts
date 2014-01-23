/******************************************************************************/
/*                                                                            */
/*    Program: RA2.CMD                                                        */
/*                                                                            */
/*     Author: Skip Osterhus                                                  */
/*                                                                            */
/*    Company: Soft Recovery Technology                                       */
/*             3631 East Meadows Court                                        */
/*             Okemos, MI  48864                                              */
/*                                                                            */
/* Work Voice: 517-349-9007                                                   */
/*                                                                            */
/*     E-MAIL: skipo@sojourn.com                                              */
/*        CIS: 73776,122                                                      */
/*    PRODIGY: RKRT45A                                                        */
/*                                                                            */
/*     Status: FreeWare                                                       */
/*                                                                            */
/******************************************************************************/

      parse arg TempFile

      RADirectory = 'c:\raplayer\'            /* User might change this here! */
      RATempFile  = RADirectory||'ra2.tmp'
      RAPlayer    = RADirectory||'raplayer.exe'

      RAHist      = 1                         /* 1 = keep track of URL's */
      RAHistFile  = RADirectory||'ra2.hst'    /* History of URL's listened to */

/******************************************************************************/
/*                                                                            */
/* Step 1 ... Load the needed REXX functions.                                 */
/*                                                                            */
/******************************************************************************/

      Call RxFuncAdd 'SysLoadFuncs','REXXUTIL','SysLoadFuncs';
      Call SysLoadFuncs;

/******************************************************************************/
/*                                                                            */
/* Step 2 ... Make sure the Real Audio file name was passed                   */
/*                                                                            */
/******************************************************************************/

     if TempFile == '' then do
                               say '***No File parameter was passed!***'
                               exit 1
                            end

/******************************************************************************/
/*                                                                            */
/* Step 3 ... Create an addressable desktop object ( if not already created ).*/
/*                                                                            */
/******************************************************************************/

      SetupString=""||,
      "DEFAULTVIEW=RUNNING;"||,
      "MINWIN=DESKTOP;"||,
      "NOPRINT=YES;"||,
      "ASSOCFILTER=.RAM,"||,
      ","||,
      ";"||,
      "EXENAME="RAPlayer";"||,
      "PROGTYPE=PROG_31_ENHSEAMLESSCOMMON;"||,
      "SET DPMI_MEMORY_LIMIT=64;"||,
      "OBJECTID=<WP_RAPlayer>;"

      rc = SysCreateObject( "WPProgram",,
                            "Real Audio",,
                            "<WP_DESKTOP>",,
                             SetupString,,
                            "ReplaceIfExists" );

      if rc <> 1 then do
                         say "***Real Audio desktop object could not be created/updated !***";
                         say 'Result code='rc
                         exit 2
                      end

/******************************************************************************/
/*                                                                            */
/* Step 4 ... Copy the temporary Real Audio file to a permanent real file.    */
/*                                                                            */
/******************************************************************************/

      '@copy' TempFile RATempFile

      if RAHist = 1 then do while lines( TempFile ) > 0
                            call lineout RAHistFile, linein( TempFile )
                         end

/******************************************************************************/
/*                                                                            */
/* Step 5 ... Run the Real Audio program from the desktop icon.               */
/*                                                                            */
/******************************************************************************/

      call SysSetObjectData "<WP_RAPlayer>", "PARAMETERS="RATempFile";OPEN=DEFAULT;"

/******************************************************************************/
/*                                                                            */
/* Step 6 ... Reset the desktop icon to no parameters.                        */
/*                                                                            */
/******************************************************************************/

      call SysSetObjectData "<WP_RAPlayer>" , "PARAMETERS=%"
