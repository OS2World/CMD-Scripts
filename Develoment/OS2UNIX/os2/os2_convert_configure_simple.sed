#conv_config.sed 
2i\
PATH=`cmd.exe /c "echo %PATH%" | sed -e 's@\\\\\\\\@/@g'`\
export $PATH\
CONFIG_SITE=${UNIXROOT}/usr/share/config.site\
ac_cv_host=i386-pc-gnu
s@/bin/sh@sh.exe@
s/IFS=\":\"$/IFS=";"/
s/"${IFS}:"/"${IFS};"/
s@\$ac_dir/\$ac_word@$ac_dir/${ac_word}.exe@
s@^\( */\*\))@\1|[a-zA-Z]:[\\/]*)@
s/ac_confdir=`echo .*/ac_confdir=\`echo \$ac_prog\|sed -e \'s%\/\[\^\/\]\[\^\/\]\*\$%%\' -e \'s%\^\.\:%%\'\`/
s@^\(cache_file=\).*$@\1./config.cache@
s/^host=NONE$/host=i386-pc-gnu/
s@^prefix=NONE$@prefix=/usr@
s@^exec_prefix=NONE$@exec_prefix=/usr@
s@^infodir=.*$@infodir='${prefix}/share/info'@
s@^mandir=.*$@mandir='${prefix}/share/man'@
s@^x_includes=NONE$@x_includes='${X11ROOT}/XFree86/include'@
s@^x_libraries=NONE$@x_libraries='${X11ROOT}/XFree86/lib'@
#EOF
