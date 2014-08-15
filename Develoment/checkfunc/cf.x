/******************************************************************/
/* call checkfunc on the file named in the first word of the      */
/* current line                       Toby Thurston - 11 Jul 2000 */
/******************************************************************/
'extract /line/'
'extract /file/'
parse var line.1 file .
'edit .rexx';'qquit'
call 'checkfunc' file '.rexx'
if result = 0
  then 'edit .rexx'
  else 'msg checkfunc returned:' result 'on' file
