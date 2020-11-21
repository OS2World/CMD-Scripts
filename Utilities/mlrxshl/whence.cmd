/* whence.cmd - which exec is used ?                  971031 */
parse value arg(1) 'PATH' with file var .
w = syssearchpath(var,file)
If w = '' then
   w = syssearchpath(var,file'.*')
say w
