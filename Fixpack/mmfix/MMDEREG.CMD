/*********************************************************************/
/*                                                                   */
/*  MMDEREG.CMD - version 1.1                                        */
/*  Copyright (C) R L Walsh 1997 - All Rights Reserved               */
/*                                                                   */
/*  email the author at rlwalsh@packet.net                           */
/*                                                                   */
/*********************************************************************/

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
call SysLoadFuncs
call RxFuncAdd 'RxWinReplaceObjectClass', 'mmparts', 'RxWinReplaceObjectClass'

say ''
say ' **********************************************************'
say ' *  MMDEREG.CMD - version 1.1                             *'
say ' *  Copyright (C) R L Walsh 1997 - All Rights Reserved    *'
say ' *                                                        *'
say ' *  email the author at rlwalsh@packet.net                *'
say ' **********************************************************'
say ''
say ''
say ' MMDEREG shows info about the WPS Multimedia classes'
say ' and lets you deregister / reregister them.'
say ' Deregistration is NOT effective unless you have run'
say ' MMFIX.CMD to patch MMPARTS.DLL.'
say ''
say ' Do you want to continue?  If yes, press "Y" then "Enter"'

pull answer
if left( strip(answer), 1) \= 'Y' then
    do
       say ' Quitting MMDEREG...'
       exit
    end

call DisplayMainMenu

do forever
    pull answer
    answer = left( strip(answer), 1)

    select
        when answer = 1 then
            call AudioProc

        when answer = 2 then
            call VideoProc

        when answer = 3 then
            call ImageProc

        when answer = 4 then
            call MiscProc

        when answer = 5 then
            call ListProc

        when answer = 'Q' then
            do
                say 'Quitting MMDEREG...'
                exit
            end

        otherwise
            nop

    end /* end select */

    call DisplayMainMenu

end /* do forever */


/*********************************************************************/

DisplayMainMenu: procedure

call SysCls
say ''
say '       WPS Multimedia Classes'
say ''
say ''
say '   1 - Audio classes (WAV, MIDI, etc.)'
say '   2 - Video classes (FLI, MPEG, etc.)'
say '   3 - Image classes (BMP, JPEG, etc.)'
say '   4 - Miscellaneous (LightTable, devices, etc.)'
say '   5 - List all Multimedia classes'
say '   Q - Quit'
say ''
say ''
say '  Choose an option, then press "Enter"'
say '  (You will return to this screen when done)'
say ''

return

/*********************************************************************/

AudioProc: procedure

class. = ''
class.0 = '9'
class.1 = 'MMMIDI'
class.2 = 'MMAIF'
class.3 = 'MMAU'
class.4 = 'MMIFF'
class.5 = 'MMSNDF'
class.6 = 'MMVOC'
class.7 = 'MMWAV'
class.8 = 'MM_AU'
class.9 = 'MMAudio'

do forever

drop status
status. = ''
call SysCls
call GetRegClasses

say ''
say 'Audio Classes'
say '                    associated with these'
say 'Nbr  Class   Reg  Extensions     File Types'
say '---  ------  ---  ---------      ----------'
say ' 1   MMMIDI   'left(status.1,1)'    (none)         (none)'
say ' 2   MMAIF    'left(status.2,1)'    *.AIF          AIF'
say ' 3   MMAU     'left(status.3,1)'    *.AU           AU'
say ' 4   MMIFF    'left(status.4,1)'    *.IFF          IFF'
say ' 5   MMSNDF   'left(status.5,1)'    *.SND          SND'
say ' 6   MMVOC    'left(status.6,1)'    *.VOC          VOC'
say ' 7   MMWAV    'left(status.7,1)'    *.WAV          WAV, Digital Audio'
say ' 8   MM_AU    'left(status.8,1)'    *._AU          _AU'
say ' 9   MMAudio  'left(status.9,1)'    (parent of classes 2-8)'
say ''
say 'Do not deregister MMAudio unless you also'
say 'deregister all of classes 2-8'
say ''
say 'Enter the numbers of the classes you want to register'
say 'and deregister, separated by spaces (e.g. "2 4 6").'
say 'Then press "Enter". Leave blank to return to the Main menu.'

if GetChoices() then
    return

end

return

/*********************************************************************/

VideoProc: procedure

class. = ''
class.0 = '5'
class.1 = 'MMAVI'
class.2 = 'MMFLI'
class.3 = 'MMMOV'
class.4 = 'MMMPG'
class.5 = 'MMVideo'

do forever

drop status
status. = ''
call SysCls
call GetRegClasses

say ''
say 'Video Classes'
say '                    associated with these'
say 'Nbr  Class   Reg  Extensions      File Types'
say '---  ------  ---  -----------     -------------'
say ' 1   MMAVI    'left(status.1,1)'   *.AVI           AVI, Digital Video'
say ' 2   MMFLI    'left(status.2,1)'   *.FLI,*.FLC     FLC/FLI'
say ' 3   MMMOV    'left(status.3,1)'   *.MOV,*.QT      QuickTime Movie'
say ' 4   MMMPG    'left(status.4,1)'   *.MPG,*.VBS     MPEG'
say ' 5   MMVideo  'left(status.5,1)'   (parent of classes 1-4)'
say ''
say 'Do not deregister MMVideo unless you also'
say 'deregister all of classes 1-4'
say ''
say 'Enter the numbers of the classes you want to register'
say 'and deregister, separated by spaces (e.g. "2 4 6").'
say 'Then press "Enter". Leave blank to return to the Main menu.'

if GetChoices() then
    return

end

return

/*********************************************************************/

ImageProc: procedure

class. = ''
class.0 = '11'
class.1 = 'MMBitmap'
class.2 = 'MMAVC'
class.3 = 'MMDIB'
class.4 = 'MMGIF'
class.5 = 'MMJPG'
class.6 = 'MMMMotion'
class.7 = 'MMPCX'
class.8 = 'MMPhotoCD'
class.9 = 'MMTIFF'
class.10 = 'MMTarga'
class.11 = 'MMImage'

do forever

drop status
status. = ''
call SysCls
call GetRegClasses

say ''
say 'Image Classes'
say '                      associated with these'
say 'Nbr  Class     Reg  Extensions      File Types'
say '---  ------    ---  ----------      ----------'
say ' 1   MMBitmap   'left(status.1,1)'     *.BMP          Bitmap'
say ' 2   MMAVC      'left(status.2,1)'     *._IM          AVC Image'
say ' 3   MMDIB      'left(status.3,1)'     *.DIB          DIB'
say ' 4   MMGIF      'left(status.4,1)'     *.GIF          GIF'
say ' 5   MMJPG      'left(status.5,1)'     *.JPG          JPG'
say ' 6   MMMMotion  'left(status.6,1)'     *.VID          MMotion Image'
say ' 7   MMPCX      'left(status.7,1)'     *.PCX          PCX'
say ' 8   MMPhotoCD  'left(status.8,1)'     *.PCD          Photo CD'
say ' 9   MMTIFF     'left(status.9,1)'     *.TIF          TIFF'
say '10   MMTarga    'left(status.10,1)'     *.TGA          Targa'
say '11   MMImage    'left(status.11,1)'     (parent of classes 2-10)'
say ''
say 'Do not deregister MMImage unless you also'
say 'deregister all of classes 2-10'
say ''
say 'Enter the numbers of the classes you want to register'
say 'and deregister, separated by spaces (e.g. "2 4 6").'
say 'Then press "Enter". Leave blank to return to the Main menu.'

if GetChoices() then
    return

end

return

/*********************************************************************/

MiscProc: procedure

class. = ''
class.0 = '8'
class.1 = 'MMFolder'
class.2 = 'MMShadow'
class.3 = 'MMVolume'
class.4 = 'MMCDDevice'
class.5 = 'MMLVDDevice'
class.6 = 'MMDevice'
class.7 = 'MMFinder'
class.8 = 'MMDataFile'

do forever

drop status
status. = ''
call SysCls
call GetRegClasses

say ''
say 'Miscellaneous Classes'
say ''
say 'Nbr   Class        Reg   Function'
say '---   -----------  ---   ---------------------'
say ' 1    MMFolder      'left(status.1,1)'    Lighttable folder'
say ' 2    MMShadow      'left(status.2,1)'    Lighttable thumbnails'
say ' 3    MMVolume      'left(status.3,1)'    Volume control'
say ' 4    MMCDDevice    'left(status.4,1)'    Compact Disk'
say ' 5    MMLVDDevice   'left(status.5,1)'    Video Disk (?)'
say ' 6    MMDevice      'left(status.6,1)'    (parent of 4-5)'
say ' 7    MMFinder      'left(status.7,1)'    MM viewer file dialog'
say ' 8    MMDataFile    'left(status.8,1)'    parent of Audio, MIDI,'
say '                         and Video classes'
say ''
say 'Do not deregister MMDevice unless you also deregister classes 4 and 5'
say 'Do not deregister MMDataFile unless you also deregister all of the'
say 'Audio, MIDI, and Video classes'
say ''
say 'Enter the numbers of the classes you want to register'
say 'and deregister, separated by spaces (e.g. "2 4 6").'
say 'Then press "Enter". Leave blank to return to the Main menu.'

if GetChoices() then
    return

end

return

/*********************************************************************/

GetChoices: procedure expose class. status.

rtn = 0
list. = ''
err = ''

pull choice answer
if left(strip(choice), 1) = '' then
    return 1

do while choice \= ''
    if class.choice = '' then
        err = err choice
    else
        do
            z = 1
            do while list.z \= ''
                if choice = list.z then
                    leave
                z = z + 1
            end

            if list.z = '' then
                list.z = choice
            else
                err = err choice
        end

    parse var answer choice answer
end

reg = ''
dereg = ''
x = 1

do while list.x \= ''
    choice = list.x
    if status.choice = 'r' then
        dereg = dereg class.choice
    else
        reg = reg class.choice
    x = x + 1
end

if err \= '' then
    do
        say ''
        say 'These entries were invalid or duplicates: ' err
    end

if reg \= '' | dereg \= '' then
    do
        say ''
        if reg \= '' then
            say 'Register: ' reg
        if dereg \= '' then
            say 'Deregister: 'dereg
        say 'Is this correct?  Press "Y" if yes'

        pull answer
        if left( strip(answer), 1) = 'Y' then
            call DeReg
    end

say ''
say 'Press "Enter" to continue...'
pull ok

return rtn

/*********************************************************************/

Dereg:

say ''
say 'Registering / Deregistering classes...'
say ''

x = 1

do while list.x \= ''

    choice = list.x

    if status.choice = 'r' then
    do
        replace = ''
        if class.choice = 'MMBitmap' then
                replace = 'WPBitmap'
        else
        if class.choice = 'MMShadow' then
                replace = 'WPShadow'

        if replace \= '' then
            if RxWinReplaceObjectClass(replace, class.choice, '0') then
                say class.choice 'unreplaced'
            else
                say 'Error!  Unable to unreplace' class.choice

        if SysDeregisterObjectClass(class.choice) then
            say class.choice 'successfully deregistered'
        else
            say 'Error!  Unable to deregister' class.choice
    end
    else
    do
        dll = 'MMPARTS'
        replace = ''
        if class.choice = 'MMBitmap' then
            do
                dll = 'MMBIT'
                replace = 'WPBitmap'
            end
        else
        if class.choice = 'MMShadow' then
            do
                dll = 'MMSHD'
                replace = 'WPBitmap'
            end

        if SysRegisterObjectClass(class.choice, dll) = FALSE then
            say 'Error!  Unable to register' class.choice
        else
            do
                say class.choice 'successfully registered'
                if replace \= '' then
                    if RxWinReplaceObjectClass(replace, class.choice, '1') then
                        say replace 'replaced with' class.choice
                    else
                        say 'Error!  Unable to replace' replace 'with' class.choice
            end
    end

    x = x + 1

end

return

/*********************************************************************/

ListProc: procedure

class. = ''
class.0 = '33'
class.1 = 'MMDataFile'
class.2 = 'MMAudio'
class.3 = 'MMMIDI'
class.4 = 'MMAIF'
class.5 = 'MMAU'
class.6 = 'MMIFF'
class.7 = 'MMSNDF'
class.8 = 'MMVOC'
class.9 = 'MMWAV'
class.10 = 'MM_AU'
class.11 = 'MMVideo'
class.12 = 'MMAVI'
class.13 = 'MMFLI'
class.14 = 'MMMOV'
class.15 = 'MMMPG'
class.16 = 'MMBitmap'
class.17 = 'MMImage'
class.18 = 'MMAVC'
class.19 = 'MMDIB'
class.20 = 'MMGIF'
class.21 = 'MMJPG'
class.22 = 'MMMMotion'
class.23 = 'MMPCX'
class.24 = 'MMPhotoCD'
class.25 = 'MMTIFF'
class.26 = 'MMTarga'
class.27 = 'MMFolder'
class.28 = 'MMShadow'
class.29 = 'MMVolume'
class.30 = 'MMDevice'
class.31 = 'MMCDDevice'
class.32 = 'MMLVDDevice'
class.33 = 'MMFinder'


drop status
status. = ''
call SysCls
call GetRegClasses

say ''
say '          Status of All WPS Multimedia Classes'
say '         (r = Registered, blank = Deregistered)'
say ''

i = 1
do while i <= class.0
    j = i + 1
    k = i + 2
    say ' ' left(status.i, 2) left(class.i, 18) left(status.j, 2) left(class.j, 18) left(status.k, 2) class.k
    i = i + 3
end

say ''
say ''
say '  Note:  all MM classes are contained in MMPARTS.DLL'
say '         except for MMBitmap which is in MMBIT.DLL,'
say '         and MMShadow which is in MMSHD.DLL'
say ''

say '  Press "Enter" to continue...'
pull ok
return

/*********************************************************************/

GetRegClasses: procedure expose class. status.

call SysQueryClassList 'reg.'

do i = 1 to reg.0
    parse var reg.i cls dll
    dll = translate(dll)
    if (dll \= 'MMPARTS') & (dll \= 'MMBIT') & (dll \= 'MMSHD') then
        iterate

    done = 1
    do j = 1 to class.0
        if status.j = '' then
            do
                done = 0
                if class.j = cls then
                    do
                        status.j = 'r'
                        leave
                    end
            end
    end

    if done = 1 then
        leave
end

return

/*********************************************************************/

