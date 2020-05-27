/* Post processing for WUZ.CMD */
/* (c) Copyright 1994 Scott Maxwell. */

FinalCommand=''
/* ---- You can insert any commands you like between these two lines ---- */
/* ---- They will be preserved if you reinstall WUZ (a new version?) ---- */

arg Name WuzWhat haveFresh haveUpdate

if WuzWhat = '' then do
  Say "Post-WUZ is only meant to be used from WUZ.CMD"
  exit(0)
end

if WuzWhat \= 0 then
  call 'wuz' WuzWhat 'here'

call 'Open-Dir' '-c' Name
is4OS2 = Check4OS2()

say '0a'x"Type 'ZCLR' to remove the files and subdirectory."
if is4OS2 = 1 then do
  say "Hit <Alt-X> or type 'ZCLR -x' to remove files and close command line."
  '@alias @Alt-x=zclr -x^r'
end
else
  say "Type 'ZCLR -x' to also close the command line"

if haveUpdate \= '' then do
  if is4OS2 = 1 then do
    say "Type ZUPDATE or <Alt-u> to remove deleted files and add new files to archive."
    '@alias @Alt-u=zupdate^r'
  end
  else
    say "Type ZUPDATE to remove deleted files and add new files to the archive."
end


if haveFresh \= '' then do
  if is4OS2 = 1 then do
    say "Type ZFRESH or <Alt-f> to update existing files in the archive."
    '@alias @Alt-f=zfresh^r'
  end
  else
    say "Type ZFRESH to update existing files in the archive."
end

interpret FinalCommand

exit

Check4OS2: procedure
  '@set is4os2=%_4ver'
  return DATATYPE(VALUE(is4os2,,OS2ENVIRONMENT),'N')
