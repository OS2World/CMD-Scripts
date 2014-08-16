/* DIRS                                                                      */
/* written:  Ric Anderson   14 May 93                                        */
/* revised:  Ken Neighbors  30 May 93   beautify                             */
/* revised:  Ken Neighbors  28 jul 93  added support for spaces in dir       */

DirStack = value('PUSHD',,'OS2ENVIRONMENT')
say _beaut(directory()) decode(DirStack)
exit 0

encode:
    parse arg InputString

    OutputString = translate(InputString,'|',' ')
    return OutputString

decode:
    parse arg InputString

    OutputString = translate(InputString,' ','|')
    return OutputString
