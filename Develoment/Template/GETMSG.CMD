/* ------------------------------------------------------------------ */
/* GETMSG - example for an external message handling routine for      */
/*          TEMPLATE v3+                                              */
/*          (c) Bernd Schemmer 1995,1996                              */
/*                                                                    */
/*-Usage:                                                             */
/*   GETMSG msgNo {,msgFile} {,msgP1} {...} {,msgP9}                  */
/*                                                                    */
/*-Where:                                                             */
/*   msgNo   - message number                                         */
/*   msgFile - name of the message file (NOT used in TEMPLATE.CMD!)   */
/*   msgP1   - 1st message parameter                                  */
/*   ...                                                              */
/*   msgP9   - 9th message parameter                                  */
/*                                                                    */
/*-Returncode:                                                        */
/*   If called as programm, GETMSG prints the founded message on the  */
/*   screen and returns 0.                                            */
/*   Note that you can only use the msgNo Parameter if called not     */
/*   from within a REXX program.                                      */
/*   If called from within an REXX program, GETMSG returns            */
/*   the founded message or an empty string if it can't find          */
/*   the message.                                                     */
/*                                                                    */
/*-History:                                                           */
/*   25.06.1995 /bs v1.00                                             */
/*     - initial release                                              */
/*   29.08.1996 /bs v1.10                                             */
/*     - added code to support multiple use of a placeholder in a     */
/*       message                                                      */
/*                                                                    */
/*-Note:                                                              */
/*   Note that TEMPLATE.CMD always (!) uses an empty string for the   */
/*   message file parameter!!!                                        */
/*                                                                    */
/*   To test this routine, change the line                            */
/*                                                                    */
/*       global.__GetMsg = ''                                         */
/*                                                                    */
/*   in TEMPLATE.CMD to                                               */
/*                                                                    */
/*       global.__GetMsg = 'GETMSG'                                   */
/*                                                                    */
/*                                                                    */
/*-Distribution:                                                      */
/*   This file is part of the TEMPLATE package.                       */
/*                                                                    */
/*                                                                    */
GetMsg:
  parse arg msgNo ,msgFile, msgP1, msgP2, msgP3, msgP4, msgP5, msgP6, msgP7, msgP8, msgP9

                        /* use the default name for the message file  */
                        /* if neccessary                              */
  if msgFile = '' then
    msgFile = fileSpec( 'D', prog.__fullName ) || ,
              fileSpec( 'P', prog.__fullName ) || ,
              'TEMPLATE.MSG'

  msgText = ''          /* message text to return                     */
  msgFound = 0          /* 1: message found in the message file       */

  if stream( msgFile, 'c', 'QUERY EXIST' ) = '' then
  do
    msgText = 'GETMSG-Error: Message file not found!'
  end /* if stream( ... */
  else
  do
    do while lines( msgFile ) <> 0 & msgFound = 0

                        /* get the next line from the message file    */
      curLine = strip( lineIN( msgFile ) )

                        /* ignore empty and comment lines             */
      if curLine = '' | right( curLine,1 ) = ';' then
        iterate
                        /* split the line into msgNo and msgText      */
      parse var curLine curMsgNo '=' MsgText
      if curMsgNo = msgNo then
        msgFound = 1    /* message found                              */

    end /* do while lines( msgFile ) <> 0 & msgFound = 0 */

                        /* close the message file                     */
    call stream msgFile, 'c', 'CLOSE'

    if msgFound = 0 then
      msgText = ''      /* message not found, return an empty string  */

    else
      if MsgText <> '' then
      do
                        /* check for placeholder                      */
        if pos( '%', msgText ) <> 0 then
        do
                        /* replace the placeholder %1 ... %9          */
          do j = 1 to 9

            pString = '%' || j
            if arg( j+2, 'E' ) then                          /* v1.10 */
              do forever                                     /* v1.10 */
                if pos( pString, curMsgText ) = 0 then       /* v1.10 */
                  leave                                      /* v1.10 */
                parse var curMsgText part1 ( pString ) part2 /* v1.10 */
                curMsgText = part1 || arg( j+2 ) || part2    /* v1.10 */
              end /* do forever */                           /* v1.10 */

          end /* do j = 1 to 9 */
        end /* if i = MsgText <> '' & ... */

      end /* if MsgText <> '' then */
  end /* else */

  parse source . callType prog.__fullName
  if callType = 'COMMAND' then
  do
                    /* GETMSG called as program from the command line */                    
    say MsgText
    exit 0
  end /* if callType = 'COMMAND' then */
  else
  do                /* GETMSG called as sub routine from within an    */
                    /* REXX program                                   */
    RETURN msgText
  end /* else */
/* ------------------------------------------------------------------ */

