s/INSTALL = :/INSTALL = /
s/INSTALL = @INSTALL@/INSTALL = install.exe/
s@/bin/sh@sh@
s@/bin/rm@rm@
s@/bin/ln@cp@
s@/bin/ls@ls@
s@/bin/cp@cp@
s/@PROG_EXT@/.exe/
s/PATH=\(.*\):\$\$PATH\(.*\)$/PATH="\1;$$PATH"\2/
s/@:/ /
s@= \$(top_srcdir)/mkinstalldirs@= sh \$(top_srcdir)/mkinstalldirs@
s@LIBTOOL   = ..@LIBTOOL   = sh ..@
/^check:/{
i \
ja.gmo: ja.po\
	if  type nkf >nul 2>&1  ; then \\\
	  if grep -i "charset=EUC" ja.po >nul 2>&1 ; then \\\
	    nkf -s ja.po | sed 's/charset=.*\\\\n/charset=sjis\\\\n/'> ja.tmp ;\\\
	    $(MSGFMT) -o $@ ja.tmp ;\\\
	    rm ja.tmp ; \\\
	  else  \\\
	    $(MSGFMT) -o $@  $< ;\\\
	  fi ; \\\
	else  \\\
	   $(MSGFMT) -o $@  $< ;\\\
	fi\

}
