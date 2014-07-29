/* 

copied from SHOWINI.CMD (same author) ...
name of this module made compatible for FAT 


program: get_answ.cmd
type:    REXXSAA-OS/2, Object Rexx, REXXSAA 6.x
purpose: utilities for dealing with LaMail and PMMail files
version: 0.0.9
date:    1997-02-10
changed: ---

author:  Rony G. Flatscher
         Rony.Flatscher@wu-wien.ac.at

needs:   ObjectRexx 

usage:   via ::REQUIRES and then call the routine:

         get answer from user, if a 3rd argument is supplied, then force an entry
         ARG(1) ... string of valid letters
         ARG(2) ... upper bound of an arithmetic value
         ARG(3) ... if given, force user to enter at least one character

All rights reserved, copyrighted 1997, no guarantee that it works without
errors, etc. etc.

You are granted the right to use this module under the condition that you don't charge money for this module (as you didn't write
it in the first place) or modules directly derived from this module, that you document the original author (to give appropriate
credit) with the original name of the module and that you make the unaltered, original source-code of this module available on
demand.  If that holds, you may even bundle this module (either in source or compiled form) with commercial software.

Please, if you find an error, post me a message describing it, I will
try to fix and rerelease it to the net.
*/

:: ROUTINE GET_ANSWER   PUBLIC
    validLetters = ARG(1)
    upperBound   = ARG(2)       /* 0 - upperBound */

    i = 0
    answer = ""

    DO FOREVER
       tmp = TRANSLATE(SysGetKey("noecho"))     /* get key-stroke       */

       IF tmp = "0D"x THEN                      /* CR-was pressed       */
       DO
          IF ARG(3) = "" | i > 0 THEN LEAVE
          CALL BEEP 2000, 250
          ITERATE
       END

       IF tmp = "1B"x THEN                      /* Escape was pressed   */
       DO
          answer = tmp
          LEAVE
       END

       IF tmp = "08"x THEN                      /* Backspace was pressed        */
       DO
          IF i = 0 THEN                         /* already at first position    */
          DO
             CALL BEEP 2000, 250
             ITERATE
          END

          CALL CHAROUT , tmp                    /* backspace */
          CALL CHAROUT , " "                    /* erase character */
          CALL CHAROUT , tmp
          i = i - 1

          IF i = 0 THEN answer = ""             /* adjust value of answer */
          ELSE answer = SUBSTR(answer, 1, i)

          ITERATE
       END

       IF POS(tmp, validLetters) > 0 THEN       /* a valid letter ?     */
       DO
          IF answer = "" THEN
          DO
             answer = tmp
             CALL CHAROUT , answer
             LEAVE
          END

          CALL BEEP 2000, 250
          ITERATE
       END

       IF upperBound <> "" THEN                 /* number within upper bound ?  */
       DO
          IF i = 0 THEN
          DO
             IF POS(tmp, "0123456789") > 0 & tmp <= upperBound THEN
             DO
                CALL CHAROUT , tmp
                answer = tmp
                i = i + 1
                IF answer = 0 | LENGTH(upperBound) = 1 | (answer || "0" > upperBound) THEN LEAVE
                ITERATE
             END
          END
          ELSE
          DO
             IF POS(tmp, "0123456789") > 0 THEN
             DO
                IF answer || tmp <= upperBound THEN
                DO
                   CALL CHAROUT , tmp
                   answer = answer || tmp
                   i = i + 1

                   IF LENGTH(answer) = LENGTH(upperBound) | (answer || "0" > upperBound) THEN LEAVE
                   ITERATE
                END
             END
          END
       END

       CALL BEEP 2000, 250
    END
    SAY

    RETURN answer

