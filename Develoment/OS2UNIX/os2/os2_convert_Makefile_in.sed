s@LIBTOOL[ \t]*=[ \t]*\.\.@LIBTOOL   = sh ..@
s@=[ \t]*\$(top_srcdir)/mkinstalldirs@= sh \$(top_srcdir)/mkinstalldirs@
s@/bin/sh@sh@
s@/bin/rm@rm@
s@/bin/ln@cp@
s@/bin/ls@ls@
s@/bin/cp@cp@
s@\$(DESTDIR)/\$(@$(DESTDIR)$(@g
s/[ \t]@://
s/INSTALL[ \t]*=[ \t]*:/INSTALL = /
s/^RANLIB[ \t]*=[ \t]*@RANLIB@/RANLIB = echo /
s/PATH=\(.*\):\$\$PATH\(.*\)$/PATH="\1;$$PATH"\2/
/TEXINPUTS=/s@:@";"@g
/PATH=/s@:@";"@g
s@^\t[\t ]*\($(srcdir)/.*mkinstalldirs.*\)$@\tsh \1@
