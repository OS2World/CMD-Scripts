/* ------------------------------------------------------------------ */
/*                                                                    */
/* simple routine to read messages from a message file for the        */
/* RXLBOX sample no. 3                                                */
/*                                                                    */
/* Usage: GETMSG1 msgNo {,msgParameter1 {,...} {,msgParameter9}}      */
/*                                                                    */
/* ------------------------------------------------------------------ */

  parse arg msgNo

  curDir = directory()
  if right( curDir, 1 ) = '\' then
    curDir = dbrright( curDir, 1 )

  msgFile = curDir || '\SAMPLE3.MSG'

  curMsgNo=0
  do while curMsgNo <> msgNo & lines( msgFile ) <> 0
    parse value lineIN( msgFile ) with curMsgNo '=' curMsgText
  end /* do */

  call stream msgFile, 'c', 'CLOSE'

  if curMsgNo = MsgNo then
  do
                    /* replace the placeholder with the values        */
    if pos( '%', curMsgText ) <> 0 then
    do
                    /* this loop processes the parameter 3 to n       */
      do j = 1 to 9
        pString = '%' || j

        do forever
          if pos( pString, curMsgText ) = 0 then
            leave
          parse var curMsgText part1 ( pString ) part2
          curMsgText = part1 || arg( j+1 ) || part2
        end /* do forever */

      end /* do j= 1 to 9 */

    end /* if pos( '%', curMsgText ) <> 0 then */

    return CurMsgText
  end /* if curMsgNo = MsgNo then */
  else
    return '???'

/* ------------------------------------------------------------------ */
/*                                                                    */
/* ------------------------------------------------------------------ */
