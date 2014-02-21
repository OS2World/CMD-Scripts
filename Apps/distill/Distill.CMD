/**********************************************************************/
/*  Distill.CMD                                                       */
/*  -----------                                                       */
/*  This REXX routine will take a raw postscript file and feed it     */
/*  through Aladdin Ghostscript in order to produce an Acrobat        */
/*  Portable Document Format (PDF) file.  Input is the file name of   */
/*  the raw postscript file.  If input is specified as "STDIN" it     */
/*  will accept the input from the STDIN device.  This makes it       */
/*  possible to use this REXX program with Kai Uwe Rommel's freeware  */
/*  PRINTMON program to produce Acrobat documents on the fly.         */
/*                                                                    */
/*  To use this program with PRINTMON to produce Acrobat documents    */
/*  directly, you must create a Printer object using the Generic      */
/*  Postscript Printer driver for OS/2.  For best results, always     */
/*  use the latest Postscript printer driver from IBM (at this        */
/*  writing, it is 30.515).  Assign the printer to a port (for        */
/*  example, LPT3).                                                   */
/*                                                                    */
/*  Next, add the following line to your STARTUP.CMD file:            */
/*                                                                    */
/*      START /MIN PRINTMON LPTx "Distill STDIN"                      */
/*                                                                    */
/*  (The above assumes that PRINTMON.EXE and DISTILL.CMD are in your  */
/*  path).  Whenever you print to the Postscript printer object, a    */
/*  pop-up dialog box should appear prompting you for a file name     */
/*  for your document.  Enter the name and press the "OK" button.     */
/*  That's all there is to it!                                        */
/*                                                                    */
/*  Requirements:                                                     */
/*     Kai Uwe Rommel's PRINTMON.EXE                                  */
/*     Aladdin Ghostscript                                            */
/*     Postscript Printer object                                      */
/*     IBM EWS Visual REXX Extensions (VREXX)                         */
/*     EMX Run Time environment                                       */
/*     Adobe's Acrobat Reader for OS/2 or                             */
/*        Russell Lang's GSView for OS/2                              */
/**********************************************************************/
'@ECHO OFF'
gsdir = 'E:\gs5.01'             /* Directory where Ghostscript lives  */

/**********************************************************************/
/*  Just fill in the required path for one of the two following       */
/*  variables.  If you want to use Adobe's Acrobat reader, fill out   */
/*  the acdir = line with the appropriate directory.  If you want     */
/*  to use Russell Lang's GSView program, fill in the gvdir = line.   */
/*  If both are specified, Acrobat reader will take precedence.       */
/**********************************************************************/
acdir = 'E:\AcroRead'           /* Directory for Adobe Acrobat Reader */
gvdir = ''                      /* Directory for GSView               */

path = Directory()              /* Get current directory              */
path = Strip(path, 'T', '\')    /* Standardize format                 */
/**********************************************************************/
/*  Parse the input file name.  If STDIN, set up so Ghostscript will  */
/*  read from STDIN and create a PDF file with a default name in the  */
/*  temporary directory.  Otherwise, parse the file name and create a */
/*  fully-qualified drive:\path\filename.  If no input file name is   */
/*  specified, just Exit with a bad return code.                      */
/**********************************************************************/
Parse Arg input

Select
   When input = '' Then
      Exit 4
   When Translate(input) = 'STDIN' Then
      psname = '-'
   Otherwise
      Do
         psname = Filespec('N', input)
         If psname = input Then
            psname = path || '\' || psname
      End
End

/**********************************************************************/
/*  set up the environment for the IBM EWS VREXX extensions, then     */
/*  prompt the user for the name of the new Acrobat document.  Once   */
/*  received, cancel the VREXX environment.                           */
/**********************************************************************/
Call RxFuncAdd 'VInit', 'VREXX', 'VINIT'
initcode = VInit()
If initcode \= 'ERROR' Then
   Do
      Call VDialogPos 50, 50
      Call VFileBox 'Name for PDF Document', ,
                     '*.PDF', ,
                     'FNAME'
      pdfname = fname.vstring

/**********************************************************************/
/*  Switch to the Ghostscript directory and use Ghostscript to        */
/*  distill the raw postscript file into PDF format.  When done,      */
/*  return to the home directory.                                     */
/**********************************************************************/
      Call Directory gsdir
      'GS -q -dNOPAUSE -dBATCH -sDEVICE#pdfwrite -sOutputFile#' || ,
         pdfname psname
      code = rc
      Call Directory path

/**********************************************************************/
/*  If the PDF file was created, prompt the user to see if he wants   */
/*  to launch the Acrobat Reader or GSView to verify it's validity    */
/**********************************************************************/
      If Stream(pdfname, 'C', 'QUERY EXISTS') \= '' & ,
         code = 0 Then
         Do
            Select
               When acdir \= '' Then
                  Do
                     vwdir = acdir || '\'
                     viewer = 'Acrobat'
                     vwpgm = 'ACROREAD'
                  End
               Otherwise
                  Do
                     vwdir = gvdir || '\'
                     viewer = 'GSView'
                     vwpgm = 'GVPM'
                  End
            End
            prompt.0 = 1
            prompt.1 = 'View the document?   '
            If VMsgBox('Launch' viewer, 'PROMPT', 6) = 'YES' Then
               'START' vwdir || ,
                       vwpgm ,
                       pdfname
         End
      Call VExit
   End
Exit
