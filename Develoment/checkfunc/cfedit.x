/******************************************************************/
/*                                    Toby Thurston - 11 Jul 2000 */
/******************************************************************/
/* replacement for openfile                                       */
/*                                                                */
/* Assign to the key you use for openfile in your profile         */
/******************************************************************/
'extract /line/'
parse var line.1 a b c .
'extract /line' 1'/'
parse var line.1 d e f thisfile
if d e f = 'Function analysis of'
  then do
    if datatype(a,'w') then 'command edit' thisfile '/c'a
    else if a b = 'Function found:' then 'command edit' c
    exit
  end
'openfile'
