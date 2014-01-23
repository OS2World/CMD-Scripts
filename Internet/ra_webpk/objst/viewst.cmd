/* REXX Scipt to start a windows viewer from WebEx */

/* These first 5 lines take the name of the temporary file           */
/* passed from Web Explorer, and copy it from ????????.tmp           */
/* to ????????.brl.  This is necessary because WebEx will delete     */
/* the .tmp file as soon as this REXX script exits, so it won't      */
/* be there for the viewer to open.  The downside is now the .brl    */
/* file will never be deleted.  I recommend making an object which   */
/* calls a .cmd file which deletes the REXX files.  You can put this */
/* in your startup folder, and call it whenever you want.            */
/* Obviously, this script expects WebEx to call it like this:        */
/* webst.cmd %s.  That is, it just passes the filename.              */

parse arg filenmin
periodpos=pos(".",filenmin)
filenm=left(filenmin,periodpos-1)
filenm=filenm || '.brl'
'copy' filenmin filenm

/* Finally, call objst.exe, which will start the viewer.  The first  */
/* argument passed must be the object handle of the object to open,  */
/* obtained with FeelX.  After this, any arguments can be passed to  */
/* the program, with the filename interspersed between them as the   */
/* program needs.  In general it might look like this:               */
/* 'objst.exe <handle> <arguments>' filenm '<more arguments>'.       */
/* Don't forget the quotes will go around everything except filenm.  */
/* objst.exe will pass on the argument list (everything after the    */
/* handle, including the filename) directly to the viewer.           */
/* In this case, 170010 was the object handle of an object on my     */
/* desktop.  There were no other arguments to be passed, except the  */
/* filename.                                                         */

'objst.exe 170010' filenm
