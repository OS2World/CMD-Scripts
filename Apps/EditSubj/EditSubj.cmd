/* EditSubj: Edit message subjects (MR/2 ICE exit)

    Copyright (c) 1999, 2004 Steven Levine and Associates, Inc.

   This program is free software licensed under the terms of the GNU
   General Public License.  The GPL Software License can be found in
   gnugpl2.txt or at http://www.gnu.org/licenses/licenses.html#GPL

   $TLIB$: $ &(#) %n - Ver %v, %f $
   TLIB: $ $

   Revisions	27 Jan 99 SHL - Baseline
		18 Nov 99 SHL - Make generic
		01 Nov 00 SHL - Optimze loop. Drop spare Re:
		20 Feb 01 SHL - Ensure file size changes.  Return changed flag.
		21 Mar 01 SHL - Support Antwort:
		23 Jan 02 SHL - Drop multiple RE: even if separated
		14 Jul 03 SHL - Translate Rv: to Re:
		07 Sep 04 SHL - Sync with standards
		23 Nov 04 SHL - Comments.  Optimize compare

*/

signal on Error
signal on FAILURE name Error
signal on Halt
signal on NOTREADY name Error
signal on NOVALUE name Error
signal on SYNTAX name Error

call LoadRexxUtil

Main:

  parse arg msgFile

  /* Ensure sane */

  if stream(msgFile, 'C', 'QUERY EXISTS') == '' then do
    say msgFile 'does not exist.'
    exit 255
  end

  /* Read file, scan for Subject line */

  call stream msgFile, 'C', 'OPEN'

  drop ErrCondition

  fChanged = 0

  /* Build traslation list - from values must be uppercase */
  MatchList.1 = 'ANTWORT:'		/* Translate Antwort: to Re: */
  ReplList.1 = 'Re:'

  MatchList.2 = ' RV: '			/* Translate Rv: to Re: */
  ReplList.2 = ' Re: '

  MatchList.3 = 'RV:RE:'		/* Translate Rv: to Re: */
  ReplList.3 = 'Re:'

  MatchList.4 = 'RE: RE:'		/* Drop multiple Re: */
  ReplList.4 = 'Re:'

  MatchList.5 = 'RE:RE:'		/* Drop multiple Re: */
  ReplList.5 = 'Re:'

  MatchList.0 = 5
  ReplList.0 = 5

  do while lines(msgFile) \= 0 & \ fChanged

    lPos = stream(msgFile, 'C', 'SEEK +0')	/* Remember BOL */

    call on NOTREADY name CatchError	/* Avoid death on missing NL */
    msgLine = linein(msgFile)
    signal on NOTREADY name Error

    /* Find subject line */
    if substr(msgLine, 1, 9) == 'Subject: ' then do

      if 0 then do
	say msgLine
	trace '?A'
      end

      /* When modifying lines, rewrite to orginal length to optimize I/O time */

      /* Normalize Re: strings */
      iList = 1
      msgLineU = translate(msgLine)		/* Optimize loop */
      do while iList <= MatchList.0
	sMatch = MatchList.iList	/* Assume upper case */
	iMatch = 9			/* Start after Subject: */
	do forever
	  iMatch = pos(sMatch, msgLineU, iMatch)
	  if iMatch = 0 then do
	    iList = iList + 1
	    leave
	  end
	  /* Replace original */
	  cMatch = length(sMatch)
	  sRepl = ReplList.iList
	  cRepl = length(sRepl)
	  msgLine = delstr(msgLine, iMatch, cMatch)
	  /* Insert replacement and fill to original length */
	  msgLine = insert(sRepl, msgLine, iMatch - 1) || copies(' ', cMatch - cRepl)
	  msgLineU = translate(msgLine)
	  if 0 then
	    say msgLine
	  fChanged = 1
	  iList = 1			/* Restart */
	end /* forever */
      end /* do iList */

      /* Translate leading
	   [xxxx] Re: zzzz
	 to
	   Re: [????] zzzz
      */

      iMatch = pos('[', msgLine)
      if iMatch = 10 then do
	iRight = pos('] RE: ', translate(msgLine))
	if iRight > iMatch then do
	  sMatch = substr(msgLine, iMatch, iRight - iMatch + 1)
	  sSubj = substr(msgLine, iRight + 6)
	  /* Move matched string and trailing space after Re: */
	  msgLine = 'Subject: Re: 'sMatch sSubj
	  msgLineU = translate(msgLine)
	  fChanged = 1
	end
      end

      if fChanged then do
	call stream msgFile, 'C', 'SEEK' lPos	/* Reposition to BOL */
	call charout msgFile, msgLine		/* Rewrite line */
      end

    end /* if subject */

  end /* while lines */

  if fChanged then do
    call stream msgFile, 'C', 'SEEK' '<0'
    call stream msgFile, 'C', 'SEEK' '+1'
    call charout msgFile, x2c('0a')
  end

  call stream msgFile, 'C', 'CLOSE'

  exit fChanged

/* end main */

/*=================================================================== */
/*=== Initialization and setup - Delete unused, but do not modify === */
/*=================================================================== */

/*=== LoadRexxUtil: Load fuctions ===*/

LoadRexxUtil:

/* Add all Rexx functions */
if RxFuncQuery('SysLoadFuncs') then do
  call RxFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
  if RESULT then do
    say 'Cannot load SysLoadFuncs'
    exit 255
  end
  call SysLoadFuncs
end /* end do */

return

/* end LoadRexxUtil */

/*========================================================================== */
/*=== SkelFunc standards - Delete unused - Move modified above this mark === */
/*========================================================================== */

/*=== CatchError() Catch condition; return ErrCondition ===*/

CatchError:
  ErrCondition = condition('C')
  return

/* end CatchError */

/*========================================================================== */
/*=== SkelRexx standards - Delete unused - Move modified above this mark === */
/*========================================================================== */

/*=== Error() Report ERROR, FAILURE etc. and exit ===*/

Error:
  say
  parse source . . thisCmd
  say 'CONDITION'('C') 'signaled at line' SIGL 'of' thisCmd
  if 'CONDITION'('C') == 'SYNTAX' & 'SYMBOL'('RC') == 'VAR' then
    say 'REXX error' RC':' 'ERRORTEXT'(RC)
  say 'Source =' 'SOURCELINE'(SIGL)
  trace '?A'
  say 'Exiting'
  call 'SYSSLEEP' 2
  exit 'CONDITION'('C')

/* end Error */

/*=== Halt() Report HALT condition and exit ===*/

Halt:
  say
  parse source . . thisCmd
  say 'CONDITION'('C') 'signaled at' SIGL 'of' thisCmd
  say 'Source = ' 'SOURCELINE'(SIGL)
  call 'SYSSLEEP' 2
  say 'Exiting'
  exit 'CONDITION'('C')

/* end Halt */

/* The end */
