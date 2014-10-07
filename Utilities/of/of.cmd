/* ************************************************************************ */
/* Program: OF.CMD                                                          */
/* Purpose: Open a WPS folder for the current directory, or the directory   */
/*          specified on the command line.  Requires W3/FP32 or W4/FP6 or   */
/*          higher.                                                         */
/*                                                                          */
/* Alex Taylor - Jun 21 2007                                                */
/* Based on OF.CMD by Dirk Terrel - OS2 ezine Mar 16 1999                   */
/*                                                                          */
/* ************************************************************************ */
If RxFuncQuery('SysOpenObject') == 1
Then Do
    Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
    Call SysLoadFuncs
End
view='DEFAULT'

Parse Arg directory
directory = Translate(directory, '\', '/')
If directory='' Then directory=Directory()
directory = Strip(directory, 'T', '\')

/* Root directory requires some special logic */
If (Filespec('PATH', directory) = '') & (Filespec('NAME', directory) = '')
Then Do
    If (SysOpenObject(directory, view, 'TRUE') = 1) Then
        Call SysOpenObject directory, view, 'TRUE'
    Else
        Say 'Failed to open folder' directory '(root directory).'
End
Else Do
    switch = Filespec('NAME', directory)
    If (SysOpenObject(directory, view, 'TRUE') = 1) Then Do
        If RxFuncQuery('SysSwitchSession') == 0 Then
            Call SysSwitchSession switch
    End
    Else
        Say 'Failed to open folder' directory'.'
End

Return
