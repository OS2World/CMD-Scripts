extproc sh
#!sh
#@@@ You should define OS2UNIX_DIR if you'd like to use this script to
#    make a zip archive for OS/2 developers.
#        i:/RedHat/SOURCES -- where I have installed os2*.* files
#
#
OS2UNIX_DIR="i:/RedHat/SOURCES"
if [ -f ./os2/os2_convert_configure.sed ] ; then
	SC_DIR=`pwd`/os2
else
	SC_DIR=${OS2UNIX_DIR}
fi
#
#@@@ You may change CONFIG_SITE definistion @@@
# To run `configure' script, specify CONFIG_SITE env. var. according 
# to your installation of `config.site' file. 
#
CONFIG_SITE=${SC_DIR}/config.site
export CONFIG_SITE
#=========================================================================
# os2unix version 2.2 by Jun SAWATAISHI <jsawa@attglobal.net>
#                                Sun Jan 16 21:07:54 JST 2005
# 
#   Purpose: Rewrite scripts (configure ...) and Makefile.in's 
#            to run configure and make WITHOUT AUTOCONF. 
# 
#            At least you will succeed in 9 of 10. 
#
#   Usage: 
#          In a top source directory
# 
#            x:/source/foo> os2unix -ALL
#            x:/source/foo> os2unix -config  --help
#            x:/source/foo> os2unix -config [SOME_ARGUMENT] && make
#           
#
# @@@ Required Executables @@@
#
#   HOBBES=ftp://hobbes.nmsu.edu/pub/os2
#   LEO=ftp://ftp.leo.org/pub/comp/os/os2/leo
#   JSAWA=http://www2s.biglobe.ne.jp/~vtgf3mpr
#
#  GNU find (find.exe, xargs.exe)
#      LEO/gnu/systools/gnufind.zip   ; v4.1
#      HOBBES/util/disk/gnufind.zip   ; v4.1
#  GNU sed 
#      LEO/gnu/systools/gnused.zip    ; v2.05
#      HOBBES/apps/editors/gnused.zip ; v3.0
#      JSAWA/gnu/sed.htm              ; v3.02.80
#  GNU grep (grep.exe)
#      HOBBES/util/file/gnugrep.zip    ; v2.0
#      LEO/gnu/systools/gnugrep.zip    ; v2.0 
#      JSAWA/gnu/grep.htm              ; v2.3h or later
#
#  GNU text utilities (cat,cut)  ;
#     LEO/gnu/systools/gnututil.zip    ; v1.19
#     HOBBES/util/file/gnututil.zip    ; v1.19
#     JSAWA/gnu/text-util.htm          ; v2.0 or later
#
#  GNU file utilities (chmod)  or ATTRIB.EXE from OS/2 install CD
#     LEO/gnu/systools/gnufutil.zip    ; v3.13
#     HOBBES/util/file/gnufutil.zip    ; v3.13
#     JSAWA/gnu/fileutils.htm          ; v3.16
#
#  file - determine file type          ; v3.30
#      JSAWA/os2unix/file330.zip
#
# Note for web2c source
#       etexdir/etex.mk: change PATH sep ':' to '\;'
#   pdftexdir/pdftex.mk
#         Change pdftexdir/pdftosrc.o:$(srcdir)/pdftexdir/pdftosrc.c
#             to pdftexdir/pdftosrc.o: $(srcdir)/pdftexdir/pdftosrc.c
# 
#
#@@@ user definetions @@@

SED_CONF="${SC_DIR}/os2_convert_configure.sed"
SED_LTMAIN="${SC_DIR}/os2_convert_ltmain.sed"
SED_MK="${SC_DIR}/os2_convert_Makefile_in.sed"
GREP_MK="${SC_DIR}/os2_convert_Makefile_in.grep"
SED_MK1="${SC_DIR}/os2_convert_Makefile_in_lib_prog.sed"
SED_MK2="${SC_DIR}/os2_convert_mk.sed"
SED_PO_MK="${SC_DIR}/os2_convert_Makefile_in_in.sed"
MKSINSTALLDIRS="${SC_DIR}/os2_mkinstalldirs"
MISSING="${SC_DIR}/os2_missing"
export SED_CONF
export SED_LTMAIN
export SED_MK
export SED_MK1
export SED_MK2
export SED_PO_MK
export MKSINSTALLDIRS
export MISSING
if type chmod>nul   ; then
	CHANGE_MODE=chmod
else
	if type attrib>nul ; then
		CHANGE_MODE=attrib
	else
		CHANGE_MODE=echo
	fi
fi
export CHANGE_MODE
#
convert_script=os2_convert_script.sh
convert_config=os2_convert_config.sh
convert_make_in=os2_convert_make_in.sh
convert_make_mk=os2_convert_make_mk.sh
#
needed_util="cp rm find xargs grep cut sed  cat patch ${CHANGE_MODE}" 
#
#
## functions

function do_check
{
  if [ ! -f CHMOD_DONE.tmp ] ; then
      case "${CHANGE_MODE}"  in
        chmod*)
          echo "${CHANGE_MODE}  +rw -R '*'"
          ${CHANGE_MODE}  +rw -R '*' 2>nul
          ;;
        attrib*)
          echo ${CHANGE_MODE} '-r -h -s /s *'
          ${CHANGE_MODE} -r -h -s /s '*'
          ;;
        *)
          echo "Waring: neither chmod.exe nor attrib.exe is available"
          ;;
      esac
      echo DONE >  CHMOD_DONE.tmp
  fi

echo "\n"
echo -n "-- Now verifying \`file' utility to determine file type ... "
if ! type file >nul   ; then
     echo "NO\n"
     echo "\t\t Warning: Modifying shell scripts will be avoided. "
     echo "\t\t          You might have to change \`/bin/sh' to \`sh'. \n"
else
     echo "OK\n"
fi
echo -n "-- checking \`os2unix' scripts exist in ${SC_DIR} directory .... "

for os2_script in ${SED_CONF} ${SED_MK} ${GREP_MK} ${SED_MK1} ${SED_MK2}\
         ${SED_PO_MK} ${MKSINSTALLDIRS} ${MISSING}; do
   if [ ! -f ${os2_script} ] ; then
     echo "\n\t Error: ${os2_script} not exist"
     if [ ! "${AVOID_EXIT}" = "yes" ] ; then
       exit 1
     fi
   fi
done

echo  "\n-- verifyig GNU utilities: ${needed_util} .... \n"

for os2_utl in ${needed_util}  ; do
  if [ "${AVOID_EXIT}" = "yes" ] ; then
    echo -n "\t GNU ${os2_utl}"
  fi
  if ! ${os2_utl} --version 2>nul | grep '\(util\|GNU\)' >nul  ; then
    echo  " is not installed: You may fail to run this script"
      case ${os2_utl} in 
        find|patch)
          echo "\n\t Your \`${os2_utl}' may be OS/2 default one, not GNU's"
          echo "\t   If you have already installed GNU ${os2_utl},"
          echo "\t   delete or rename OS/2 default program. "
          ;;
        attrib)
          echo "\t   Instead of GNU chmod, attrib.exe will be used"
          return
          ;;
      esac
     if [ ! "${AVOID_EXIT}" = "yes" ] ; then
       exit 1
     fi
  else
    if [ "${AVOID_EXIT}" = "yes" ] ; then
        echo -n "\tOK\n"
    fi
  fi
done
echo "\n -- Done "
}


function make_convert_script
{
  find . -type f  ! -regex '.*/[A-Z]+.*' ! -regex\
  '.*\.\([aCchoy1-9]\|obj\|com\|am\|m4\|[Cc][Cc]\|exp\|out\|exe\|\dll\|pm\|tmp\|rej\|mo\|gmo\|po\|lib\|tex.*\|inf.*\|def\|sed\|awk\|good\|ac\|inp\)'\
  ! -iname 'configure*' ! -iname mkinstalldirs \
  ! -iname ltmain.sh  -exec file '{}' \; > 00script_candidate.tmp

  if [ -s 00script_candidate.tmp ] ; then
    grep '\(script\|commands\)' 00script_candidate.tmp|cut -d: -f1 > 00scripts.tmp
    if [ -s 00scripts.tmp ] ; then
      sed 's@^\(.*\)$@cp.exe -vp \1 \1.tmp@' 00scripts.tmp  > 00cp_script.tmp
    fi
  fi
  if [ -s 00cp_script.tmp ] ; then
     sed 's_^cp.exe \-vp \(.*\) \(.*\)$_sed -e s@\/bin\/sh@sh@  -e s@\/bin\/bash@bash@ -e s@\/usr\/bin\/perl@perl@ \2 > \1_' \
     00cp_script.tmp > tmp.tmp
     cat 00cp_script.tmp tmp.tmp > ${convert_script}
     rm tmp.tmp
  fi
}


function ch_script
{
  if [ ! -f SCRIPTS_CHANGED.tmp ] ; then
    if [ ! -f ${convert_script} ] ; then
      if  type file >nul 2>&1 ; then
        make_convert_script
      else
        echo "A utility file is not installed\n"
        return
      fi
    fi
    find . -iname mkinstalldirs > 00mkin.tmp
    if [ -s 00mkin.tmp ] ; then
      sed -e 's@^\(.*\)$@cp -vp ${MKSINSTALLDIRS} \1@' 00mkin.tmp >>${convert_script}
    fi
    sh ./${convert_script}
    if [ -f missing ] ; then
      cp -vp missing MISSING.tmp
      cat ${MISSING} MISSING.tmp > missing
    fi
    echo DONE >  SCRIPTS_CHANGED.tmp
  else
    echo "\nWarning: Scripts already modified"
    return
  fi
}
function do_config
{
  _changed_tmp=CONFIGURE_DONE.tmp
  if [ ! -f ${_changed_tmp} ] ; then
    if [ -s os2_configure.cmd ] ; then
      cmd.exe /c os2_configure.cmd
    else
      echo "Now running configure $* ...."
      sh configure "$*"
    fi
    echo DONE >  ${_changed_tmp}
  else
    echo "\nconfigure has been already executed"
    echo   "  You'd better run \`config.status --recheck'"
  fi
}

function do_patch
{
  _changed_tmp=PATCH_DONE.tmp
  if [ ! -f ${_changed_tmp} ] ; then
    for f in os2/C_Source.diff os2/In-make.diff os2/Other.diff
    do
      if [ -s $f ] ; then
        echo "\n Patching: $f ...."
        patch -p1 < $f
      fi
    done
    echo DONE >  ${_changed_tmp}
    if [ -f configure ] ; then
      touch configure
    fi
  else
    echo "\nThere is no diff file to apply"
  fi
}

function ch_config
{ 
  _sed_file='${SED_CONF}'
  _script_file=${convert_config}
  _changed_tmp=CONFIGURE_CHANGED.tmp

  if [ ! -f ${_changed_tmp} ] ; then
    if [ ! -f ${_script_file} ] ; then
      find . -iname configure -o -iname ltmain.sh > 00conf.tmp
      if [ -s 00conf.tmp ] ; then
        sed -e \
         "s@^\(.*\)\$@cp -vp \1 \1.tmp \&\& sed -f ${_sed_file} \1.tmp > \1@"\
                                                00conf.tmp > ${_script_file}
      fi
    fi
    if [ -s ${_script_file} ] ; then
      sh ./${_script_file}
    fi
    echo DONE >  ${_changed_tmp}
  else
    echo "\nWarning: configure and ltmainsh already modified"
  fi
}
function ch_makefile
{
  _sed_file='${SED_MK}'
  _script_file=${convert_make_in}
  _changed_tmp=MAKEFILE_in_CHANGED.tmp

  if [ ! -f ${_changed_tmp} ] ; then
    if [ ! -f ${_script_file} ] ; then
      echo "\n Now finding Makefile.in's\n"
      find . -iname Makefile.in -o -iname GNUMakefile > 00mk_in.tmp
      sed -e  "s@^\(.*\)\$@cp -vp \1 \1.tmp  \&\& sed -f ${_sed_file} \1.tmp > \1@" 00mk_in.tmp \
                                                              > ${_script_file}
      echo "\n Now finding Makefile.in's for library or executables\n"
      cat 00mk_in.tmp |xargs grep -l -f ${GREP_MK} > 00grepped.tmp

      if [ -s 00grepped.tmp ] ; then
        sed -e  's@^\(.*\)$@cp -vp \1 \1.tmp \&\& sed -f ${SED_MK1} \1.tmp > \1@' ./00grepped.tmp >> ${_script_file}
      fi

      echo "\n Now finding Makefile.in.in's \n"
      find . -iname Makefile.in.in -o -iname Makefile.inn > 00mk_in_in.tmp
      if [ -s 00mk_in_in.tmp ] ; then
        sed -e 's@^\(.*\)$@cp -vp \1 \1.tmp \&\& sed -f ${SED_PO_MK} \1.tmp > \1@'\
                           00mk_in_in.tmp                   >> ${_script_file}
      fi
    fi
    echo "\n Now converting Makefile.in*'s........"\n
    sh ./${_script_file}
    echo DONE >  ${_changed_tmp}
  else
    echo "\nWarning: Makefile.in*'s already modified"
  fi
}


function web2c_mk
{
  _sed_file='${SED_MK2}'
  _script_file=${convert_make_mk}
  _changed_tmp=MK_CHANGED.tmp

  if [ ! -f ${_changed_tmp} ] ; then
    if [ ! -f ${_script_file} ] ; then
      find . -iname '*.mk' -o -iname  '*.make' > 00mk.tmp
      if [ -s 00mk.tmp ] ; then
        sed -e 's@^\(.*\)$@cp -vp \1 \1.tmp \&\& sed -f ${_sed_file} \1.tmp > \1@'\
                                              00mk.tmp > ${_script_file}
      fi
    fi
    if [ -s ${_script_file} ] ; then
      cat ${_script_file}
      sh ./${_script_file}
      echo DONE >  ${_changed_tmp}
    fi
  else
    echo "\nWarning: \*.mk already modified"
  fi
}

function show_help
{
  echo "Option is ALWAYS required"
  echo "   -c  : convert configure and ltmain.sh using"
  echo "           $SED_CONF \n\t\tand $SED_LTMAIN\n"
  echo "   -s  : convert shell scripts\n"
  echo "   -m  : convert Makefile.in* using"
  echo "             $SED_MK"
  echo "         and $SED_MK1"
  echo "                              (for libary/program)\n"
  echo "   -all: execute all steps above"
  echo "   -patch: apply diff files if exist"
if [ -s ./os2_configure.cmd ] ; then
  echo "   -config : run os2_configure.cmd"
else
  echo "   -config [arguments] : run configure [with arguments]"
fi
if [ -s ./os2_configure.cmd ] ; then
  echo "   -ALL: execute all steps above"
else
  echo "   -ALL [arguments for configure]:  execute all steps above"
fi
  echo "   -mk : convert *.mk (needed for web2c) using"
  echo "           $SED_MK2\n"
  echo "   -clean     : clean temporary files"
  echo "   -distclean : clean both created scripts and temporary files"
  echo "   -check : Check required scripts and executables to run this script"
}
## end of functions


if [ -z $1 ] ; then
  show_help
  exit 0
fi


case "$1" in 
	-s)
		do_check
		ch_script
		;;
	-c) 
		do_check
		ch_config
		;;
	-m) 
		do_check
		ch_makefile
		;;
	-patch)
		do_patch
		;;
	-all)
		do_check
		ch_config
		ch_script
		ch_makefile
		;;
	-ALL)
		do_check
		ch_config
		ch_script
		ch_makefile
		do_patch
		touch configure
#  IMPORTANT NOTICE
#    When configure is older than config.h.in or aclocal.m4
#    autoconf may be invoked.
#    To avoid this, we should "touch" configure. 
		shift
		do_config
		make
		;;
	-mk) 
		do_check
		web2c_mk
		web2c_make
		;;
	-clean)
		find . -name '*~' -o -name '*.tmp' -o -name '*.rej' | xargs rm -f
	  ;;
	-distclean)
		find . -name '*~' -o -name '*.tmp' -o -name '*.rej' | xargs rm -f
		rm -f ${convert_script} ${convert_config} ${convert_make_in} ${convert_make_mk}
	  ;;
	-config)
		shift
		echo "Now running configure $* ...."
		sh configure "$*"
		;;
	-check)
		AVOID_EXIT=yes
		do_check
	  ;;
	*) echo Unrecognized option ;;
esac


exit 0
#EOF
