s/INSTALL = :/INSTALL = /
s/INSTALL = @INSTALL@/INSTALL = install.exe/
s@/bin/sh@sh@
s/@PROG_EXT@/.exe/
s@= \$(top_srcdir)/mkinstalldirs@= sh \$(top_srcdir)/mkinstalldirs@
s@^LIBTOOL =@LIBTOOL= sh @
s@LIBTOOL   = ..@LIBTOOL   = sh ..@
s@  ln @ cp.exe -vp @
s@  -ln @ cp.exe -vp @
s@cp /dev/null sedscript@ echo >sedscript@
s@^\(link_command =.*\)$@\1 -Zexe @
