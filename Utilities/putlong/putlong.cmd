/* PutLong.cmd - A little tool to modify or set the .LONGNAME EA */
/* without modifying the real nameof a file.                     */

rc = rxFuncAdd('sysLoadFuncs', 'rexxUtil', 'SysLoadFuncs')
if rc \= 0 then call sysLoadFuncs

say 'PutLong v1.01 - (C) Cristiano Guadagnino 2001'
say ' '

if Arg() = 0 then do
    say 'syntax: PUTLONG <filename> [<longname>]'
    say ' '
    exit
end

Parse Arg _filename _longname

_retcode = SysGetEA(_filename, '.LONGNAME', 'LONGEA')
if (_retcode = 0) & (LONGEA \= '') then do
    say 'The file ' || _filename || ' already has a .LONGNAME extended'
    say 'attribute, containing: ' || Substr(LONGEA, 5) || '.'
    say 'Do you want to overwrite it? (Y/N) '
    pull _answer .
    if Translate(_answer) \= 'Y' then Exit
    say ' '
end

_newEA = 'FDFF'x
if Length(_longname) > 255 then do
    say 'LONGNAME too long.'
    exit
end

_newEA = _newEA || D2C(Length(_longname), 1)
_newEA = _newEA || '00'x
_newEA = _newEA || _longname

say 'Writing .LONGNAME: "' || _longname || '"...'
_retcode = SysPutEA(_filename, '.LONGNAME', _newEA)

if _retcode \= 0 then
    say 'Failed setting .LONGNAME extended attribute.'
else
    say 'Done.'

Exit _retcode

