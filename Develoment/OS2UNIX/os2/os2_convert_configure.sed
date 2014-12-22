#!sed -f
#
#  This script was wrote by SAWATAISHI Jun <jsawa@attglobel.net>
#
#
#--- for libtool: To enable -Zomf option when execute "make omf=on"
#
#-------------------- starting  making DLLs =================================
#
# AR definition is the first object for modification
s@^\(AR=.*\)$@if [ "\\$omf" = "on" ] ; then\
\tAR="emxomfar"\
\temx_add_flag=-Zomf\
\temx_libext=lib\
else\
\t\1\
\temx_add_flag=' '\
\temx_libext=a\
fi@

s@^\(objext=.*\)$@if [ "\\$omf" = "on" ] ; then\
\tobjext="obj"\
else\
\t\1\
fi@

s@^\(.*library_names_spec=[^/{}]\+dll\) \(.*\).a\(.*\)$@\1 \2.\$emx_libext\3@

s@^\(libext=.*\)$@if [ "\\$omf" = "on" ] ; then\
\tlibext="lib"\
else\
\t\1\
fi@

s@^\([ \t]*old_archive_from_new_cmds=.*\)\(emximp -o .*libname\).a\(.*def\)'$@\1\2.a \3~ \2.lib \3'@

s@^\([ \t]*archive_cmds=.*\)-Zdll\(.*\)$@\1-Zdll $emx_add_flag \2@

#-------------------- end of making DLLs =================================

s@^\(cache_file=\).*$@\1./config.cache@
s/\-lintl/\-llibintl/g
s@/bin/sh@sh.exe@
s@^\(includedir=\).*$@if [ -z ${C_INCLUDE_PATH} ] ; then\
\tC_INCLUDE_PATH=$UNIXROOT/usr/include\
\t\1$UNIXROOT/usr/include\
else\
\t\1${C_INCLUDE_PATH}\
fi\
@
s/^.*MYPATH=\".*$/MYPATH=\"$PATH\"/
s@DATADIRNAME=lib@DATADIRNAME=share@
s/ ln -s / cp.exe -p /
s/'ln -s'/'cp.exe -p'/
s/"ln -s"/"cp.exe -p"/
s/=ln/=cp/
s@^ac_default_prefix=.*$@ac_default_prefix=/usr@
s@^prefix=.*$@prefix=/usr@
s@^ac_given_srcdir=.*@ac_given_srcdir=\`pwd \| sed \-e \"s/\^\.://\"\`@
s@^srcdir=.*@srcdir=\`pwd \| sed \-e \"s/\^\.://\"\`@
s/IFS=\":\"$/IFS=";"/
#s/^ *\(\/\*)\)$/  [a-zA-Z]:*|*)/
s@^\( */\*\))@\1|[a-zA-Z]:[\\\\/]*)@
s@\[/\$\]\*)@[a-zA-Z]:[\\\\/]*|[/$]*)@
#---------------  find executables ------------------
#
# Old style:  for find ==> x:/usr/bin/find.exe
#  s@\$ac_dir/\$ac_word@$ac_dir/${ac_word}.exe@
# 
# New style:  use function test defined in `config.site' 
#             for find ==> find
#
s@if test -f \$ac_dir/\$ac_word@if test -x $ac_word@
s@if test -f \$ac_dir/\$ac_prog@if test -x $ac_prog@
s@^\(.*\$as_executable_p  *"\$ac_dir/\$ac_word\)\(".*\)$@\1.exe\2@
s@^\(.*ac_cv_path_.*\)="\$ac_dir/\(.*\)$@\1="\2@
#------------------------------------------------------------------------
s/^ac_exeext=$/ac_exeext=.exe/
s/^x_includes=NONE/x_includes='$\{X11ROOT\}\/XFree86\/include'/
s/^x_libraries=NONE/x_libraries='$\{X11ROOT\}\/XFree86\/lib'/
###################################################################
# If LDFLAG do NOT have ``-Zexe'' uncomment the next two lines
s/conftest /conftest${ac_exeext} /g
s/conftest;/conftest${ac_exeext};/g
#s/conftest /conftest.exe /g
#s/conftest;/conftest.exe;/g
###################################################################
s/"${IFS}:"/"${IFS};"/
s/ac_confdir=`echo .*/ac_confdir=\`echo \$ac_prog\|sed -e \'s%\/\[\^\/\]\[\^\/\]\*\$%%\' -e \'s%\^\.\:%%\'\`/
s/\$LN_S%g$/cp.exe -p%g/
s%/bin/sh%sh%g
s%/usr/bin/uname%uname%g
s%/bin/uname%uname%g
s%/bin/rm%rm%g
s/ac_cv_prog_cc_cross=yes/ac_cv_prog_cc_cross=no/
#s/^host=NONE$/host=i386-pc-gnu/
s/^host=NONE$/host=i386-pc-os2-emx/
s@^prefix=NONE$@prefix=/usr@
s@^exec_prefix=NONE$@exec_prefix=/usr@
#
# Change library names
s@-ldb-3.1@-ldb-3_1@g
s@^\(DEFS=`.*\)`$@\1|tr -d '\\r' `@
#
# To search C header files "/usr/include/...."
#
s@ /usr/include@ ${C_INCLUDE_PATH}@g
s@"-I/usr/include@"-I${C_INCLUDE_PATH}@g

### EOF ######################################################################
