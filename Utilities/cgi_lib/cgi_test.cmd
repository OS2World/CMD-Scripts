/* */
parse arg inarg
parse var inarg func arg.1 arg.2 arg.3 arg.4 arg.5

if (func = "-?") | (func = "-h") |  (func = "/?") |  (func = "/h") |  (func = "") then signal showhelp


say 'test commnad is "CALL cgi_lib' func arg.1 ',' arg.2 ',' arg.3 ',' arg.4 ',' arg.5  '"'
say

CALL  cgi_lib  func , arg.1 , arg.2 , arg.3 , arg.4 , arg.5


say 'result is:'
say result
exit

showhelp:
	say 
	say "usage: cgi_lib.cmd  func [arg1 [arg2 [arg3 [arg4 [arg5] ] ] ] ]"
	say
	exit

