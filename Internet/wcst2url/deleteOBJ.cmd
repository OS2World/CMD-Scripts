/*
 * Quickly get rid of the Warpcast folders. Check nothing, just delete them.
 */

    call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
    call SysLoadFuncs

    call SysDestroyObject('<WCASTNEW>')
    call SysDestroyObject('<WCASTUPD>')

    call SysDropFuncs
