/* Run this script to convert these HTML files into a OS/2 INF book   */
/* You should have Image Alchemy for OS/2 on your path, or you should */
/* run this batch file with -P- option                                */
/* You also should have Information Presentation Facility Compiler    */
/* somewhere on your path and set up correctly.                       */

 'call ..\html2ipf.cmd %1 html2ipf.html'
 if stream('html2ipf.ipf', 'c', 'query exists') \= ''
  then do
        'call ..\inf.cmd html2ipf.ipf'
        'del html2ipf.ipf 1>nul 2>nul'
        'del *.bmp 1>nul 2>nul'
       end;
  else do
        say 'Documentation conversion failed!'
        say 'Please correct the problem, and run again.'
       end;
exit
