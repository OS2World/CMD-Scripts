/*          REXX Ergonomic Reminder for OS/2                  */
/*                                                            */
/*   Written by: David Richard                                */
/*               Fleming Companies, Inc.                      */
/*               Development Support Group                    */
/*                                                            */
/*   Purpose:    Create a distinctive BEEP sound every hour   */
/*               to remind workstation users to take a short  */
/*               break from their work.                       */
/*                                                            */
/*  Load REXX System Functions                                */
Call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs';
Call SysLoadFuncs;           
/*                                                            */
/*  Make Beep sounds so user will know what to listen for     */
CALL Beep 2500,250
CALL Beep 1250,125
/*                                                            */
/*  Sleep for 1 hour (3600 seconds)                           */
CALL SysSleep 3600
DO Forever
    CALL Beep 2500,250
    CALL Beep 1250,125
    CALL SysSleep 3598
End
/*   Sleep for a little less than one hour to compensate       */
/*   for the time it takes to:                                 */
/*               Wake up from SysSleep                         */
/*               Process the END of the DO statement           */
/*               Make Beep sounds                              */
/*    On my PS/2 Mod-80, this compensation is about 2 seconds  */
/*    Other machines may need less (or no) compensation        */
/*    Feel free to modify the 2nd SysSleep for your needs      */
