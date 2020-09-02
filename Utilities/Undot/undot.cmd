/* Rename files with 'undesired' characters by R. Hamerling */
/* Replace the characters '., (){}[]' by an underscore      */
/*   (includes spaces, but not the single quotes!)          */
/*   The extension-dot, if present, is preserved!           */
/* Subdirectories are searched, but not renamed.            */
/* Easily adaptable for other chars (from and to)           */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs

parse arg filespec                           /* preserve spaces! */
if filespec = '' then
  do
    say 'Syntax: UNDOT <pathspec>  (wildcards allowed)'
    return 99
  end

xxx = '., (){}[]'                            /* to be replaced */
yyy = '_________'                            /* 1-to-1 substitutes */

say "Replacing characters '"xxx"' in filenames of '"filespec"' . . ."
rx = SysFileTree(filespec, 'flist', 'FSO')   /* list of filespecs */
                                             /* 'FO' excludes subdirs */
if rx \= 0 then do
  say "Error collecting file information, rc" rx
  return rx
end

j = 0                                        /* rename count */
do i=1 to flist.0                            /* all files */
  spec = filespec('name', flist.i)           /* exclude drive:path */
  offsetx = lastpos('.', spec)               /* last dot */
  if offsetx > 0 then do                     /* extension(?) present */
    name = substr(spec, 1, offsetx - 1)      /* first part */
    ext  = substr(spec, offsetx + 1)         /* last part (ex. dot) */
    if verify(name, xxx, 'Match') > 0  |,    /* name has 'xxx' chars or */
       verify(ext, xxx, 'Match') > 0 then do  /* ext has 'xxx' chars */
      name = translate(name, yyy, xxx)       /* xlate name */
      ext  = translate(ext,  yyy, xxx)       /* xlate ext */
      spec = name'.'ext                      /* rejoin */
      say spec                               /* progress report */
      '@rename' '"'flist.i'"' '"'spec'"' '>nul'    /* rename */
      j = j + 1                              /* count renames */
      end
    end
  else do                                    /* no dots in filespec */
    if verify(spec, xxx, 'Match') > 0  then do  /* spec has 'xxx' chars */
      spec = translate(spec, yyy, xxx)       /* xlate filespec */
      say spec                               /* progress report */
      '@rename' '"'flist.i'"' '"'spec'"' '>nul'    /* rename */
      j = j + 1                              /* count renames */
      end
    end
end
say "Number of files matching '"filespec"':" flist.0", renamed:" j
return 0

