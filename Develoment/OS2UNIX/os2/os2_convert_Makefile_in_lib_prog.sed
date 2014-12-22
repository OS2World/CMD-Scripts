#----------  Makefile.in for executables and library -----------
1{
i \
\#---------------------------------------------------------------\
\#  OS/2 - emx/gcc basic definitions\
\#  You may change "lib = lib " and "obj = obj" lines. \
lib = a\
obj = o\
ifeq ($(omf),on)\
	lib = lib\
	obj = obj\
	AR  = emxomfar\
%.lib: %.a\
	emxomf $<\
endif\
\#---------------------------------------------------------------
}
s/^\(CC[ \t]*=[ \t]*.*\)$/\1\
EXEEXT=@EXEEXT@\
OBJEXT=@OBJEXT@\
ifeq ($(OBJEXT),obj)\
\tCC += -Zomf\
else\
ifeq ($(obj),obj)\
\tCC += -Zomf\
endif\
endif\
/
s/^\(CXX[ \t]*=[ \t]*.*\)$/\1\
ifeq ($(OBJEXT),obj)\
\tCXX += -Zomf\
else\
ifeq ($(obj),obj)\
\tCXX += -Zomf\
endif\
endif\
/
s/^\(HOSTCC[ \t]*=[ \t]*.*\)$/\1\
ifeq ($(OBJEXT),obj)\
\tHOSTCC += -Zomf\
else\
ifeq ($(obj),obj)\
\tHOSTCC += -Zomf\
endif\
endif\
/

s/^\(OBJEXT[ \t]*=.*\)$/ifeq ($(omf),on)\
\tOBJEXT=obj\
else\
\t\1\
endif\
/
s/^AR[ \t]*=.*$/ifeq ($(obj),obj)\
\tAR = emxomfar\
else\
\tAR = ar\
endif\
/
s/^\.c\.o:/%.$(obj): %.c/
###Mar 7,2001 commented out   s/\<lib\([[:alnum:]]\+\)\.a\>/\1.$(lib)/g
s/\.a\>/.$(lib)/g
s/\.o\>/.$(obj)/g

s/^\(.*LDADD\)[ \t]*=[ \t]*\(.*\)$/\1 = \2\
ifeq ($(omf),on)\
\t\1 := $(\1:.a=.lib)\
endif/

s/^\(lib.*_LIBADD\)[ \t]*=[ \t]*\(.*\)$/\1 = \2\
ifeq ($(omf),on)\
\t\1 := $(\1:.o=.obj)\
endif/


s/^\(lib.*_DEPENDENCIES\)[ \t]*=[ \t]*\(.*\)$/\1 = \2\
ifeq ($(omf),on)\
\t\1 := $(\1:.o=.obj)\
endif/


s/^\(LIBOBJS\)[ \t]*=[ \t]*\(.*\)$/\1 = \2\
ifeq ($(omf),on)\
\t\1 := $(\1:.o=.obj)\
endif/

s/^\(all-yes:[ \t]*libintl.\$la\)\(.*\)$/ifeq ($(omf),on)\
ifeq ($(l),l)\
\1\2\
else\
all-yes: libintl.lib\2\
endif\
OBJECTS:=$(OBJECTS:.o=.obj)\
else\
\1\2\
endif/

s/^LDFLAGS[ \t]*=\(.*\)$/ifneq ($(EXEEXT),.exe)\
\tLDFLAGS = -Zexe \1\
\tEXE=.exe\
else\
\tLDFLAGS = \1\
\tEXE=\
endif\
ifeq ($(debug),on)\
\tCFLAGS += -DEMX_DEBUG\
endif\
/
s/@PROG_EXT@/.exe/
s/^CXXLIBS[ \t]*=[ \t]*@CXXLIBS@/CXXLIBS = @CXXLIBS@ -lstdcpp/
/^\(un\)*install[-a-zAZ0-9]*PROGRAMS\?:/,/^[ \t]*$/{
s@$$p@$$p$(EXE)@g
}
/^VPATH[ \t]*=[ \t]*/s@:@;@g
s/@exeext@/.exe/g
#----END OF  Makefile.in for executables and library -----------

