/* Name: edit.cmd */
/* Version: v2003.03.22*/
/* Description:  */
/* Author: Nick Morrow, C. Morrison  */
/* License: Public Domain */

/* edit.cmd */ progVer = "Edit v2003.03.22"

/* Usage: From an OS/2 command prompt type 'edit <filename>'

   Status: Released into the public domain.

   Contributors Date
   ------------ ---------
   C. Morrison  15 Jul 94 (RexxEdit.ZIP)
   N. Morrow    22 Mar 03 (Edit0303.ZIP)

   Contact Information
   -------------------
   N. Morrow - morrownr@netscape.net

   To-Do: (in priority order)

     -- Support for Spanish language

     -- Optimize and clean code

     -- Add Find, Find Again (Ctrl-F/Ctrl-G)

        (release for testing - Mar 2003) * current status *

     -- Add keyboard Cut, Copy and Paste capability ()

     -- Add error checking to ensure invalid filenames are rejected

     -- Add checking to gracefully handle non-text files

        (release for testing - Sep 2003)

     -- Add REXX keyword highlighting (F6=Rexx)

     -- Optimize and clean code

     -- Add Replace capability (Ctrl-R)

        (release for testing - Dec 2003)

     -- Add ASCII chart (F5=Char)

     -- Add Rename capability (F7=Name)

     -- Beef up error handling

        (release v1 - estimate Mar 2004)

   REXX Code Style:

     -- Indentation: 3 spaces

     -- Variable names: lower case letters with the initial letters
        of concatenated words in upper case (curRowInDoc)

     -- Keywords: lower case (address, arg, call, do, drop, exit,
        expose, forward, guard, if, interpret, iterate, leave,
        nop, numeric, options, parse, procedure, pull, push, queue,
        raise, reply, return, say, select, signal, trace, use)

     -- Built in functions (REXX.DLL): UPPER CASE (LEFT)

     -- Internal and external functions: initial letters of
        individual words in upper case.

     -- Assignments use "", all other uses of quoting use ''.

   Known issues:

   - Loading large files (for example: 5 mb) when Object Rexx is active
     is very slow.  If anyone with Object Rexx programming experience
     knows a better way to write the LoadFile subroutine I'd like to
     hear from you.

   DISCLAIMER:

   THIS SOFTWARE IS PROVIDED BY THE CONTRIBUTORS "AS IS" AND ANY
   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
   OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
   TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
   THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
   SUCH DAMAGE.
*/

if RxFuncQuery('SysLoadFuncs') then
   do
      call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
      call SysLoadFuncs
   end

/* Edit is designed to have an editing area that is easily resized.
   (0,0,21,79) are the the maximum sizes that work in 80x25 full screen
   mode, however, if you are working in a windowed environment you can
   increase the editing area to suit your needs.
*/
                   /* 'mode 120,30'      */      
scrTopRow    =  0  /* scrTopRow    =   0 */
scrLeftCol   =  0  /* scrLeftCol   =   0 */
scrBottomRow = 21  /* scrBottomRow =  26 */
scrRightCol  = 79  /* scrRightCol  = 119 */

/* calculate editing area size */
scrHeight = scrBottomRow - scrTopRow  + 1
scrWidth  = scrRightCol  - scrLeftCol + 1

/* tab size */
tabSize = 4

/* set screen colors */
ansiESC              = "1B"x
setColorWhite        = ansiESC || "[0;37m"
setColorBrightRed    = ansiESC || "[1;31m"
setColorBrightCyan   = ansiESC || "[1;36m"
setColorBrightGreen  = ansiESC || "[1;32m"
setColorBrightYellow = ansiESC || "[1;33m"
setTextColor    = setColorBrightGreen
setInfoColor    = setColorWhite
setKeywordColor = setColorBrightYellow
call CharOut, setTextColor

/* get OS type and version */
'@VER |RXQUEUE'              /* put data on the queue */
pull .                       /* discard the blank line */
pull OSType
OSType  = translate(OSType)
OSEnvir = 'OS2ENVIRONMENT'         /* OS/2 or eCS (default) */
if pos('WINDOWS', OSType) > 0 then
   OSEnvir = 'ENVIRONMENT'         /* Win9X/WinNT/Win2K/WinXP */

/* detect version of REXX in use on OS/2 and eCS */
if OSEnvir = 'OS2ENVIRONMENT' then
   do
      parse version RexxVer . . . .
      if RexxVer = 'REXXSAA' then
         RexxVer = 'Classic'
      else
         RexxVer = 'Object'
   end

/* detect and load language support */
langInUse = TRANSLATE(SUBSTR(VALUE('LANG',,OSEnvir),1,2))
select
   when langInUse = 'DE' then call German
   when langInUse = 'ES' then call Spanish
/* when langInUse = 'NL' then call Dutch      */
/* when langInUse = 'IT' then call Italian    */
/* when langInUse = 'PT' then call Portuguese */
/* when langInUse = 'RU' then call Russian    */
   otherwise call English
end

/* initialize variables ** used by: **/
docTopRow      = 1     /* WriteText: */
docLeftCol     = 1     /* WriteText: */
curRowInDoc    = 1     /* WriteStat: */
curColInDoc    = 1     /* WriteStat: */
curColInDocMem = 1
curRowOnScr = scrTopRow
curColOnScr = scrLeftCol
modified = 0
insMode  = 1
loadTime = "-"

main:
parse arg textFile
if LEFT(textFile,1) = '"' then
   parse VAR textFile '"' textFile '"'
call LoadFile
call LoadKeys
call WriteText; call WriteLine; call WriteStat; call WriteMenu
do forever
   call SysCurPos curRowOnScr, curColOnScr
   call SysCurState 'ON'
   inKey = SysGetKey('NOECHO')
   call SysCurState 'OFF'
/* debug */ call CharOut, setInfoColor
/* debug */ call SysCurPos scrBottomRow + 1, scrLeftCol
/* debug */ call CharOut, '-'
/* debug */ call CharOut, setTextColor
   select
      when inKey = Enter_Key             then call DoEnter
      when inKey = Ctrl_Enter            then call DoCtrlEnter
      when inKey = Backspace_Key         then call DoBackSpace
      when inKey = Ctrl_Backspace        then call DoCtrlBackspace
      when inKey = Tab_Key               then call DoTab
      when inKey = Esc_Key               then call DoQuit
      when inKey = Ctrl_F                then call DoFind
      when inKey = Ctrl_G                then call DoFindaGain
      when inKey = '00'x | inKey = 'E0'x then 
         do
            inKey2 = SysGetKey('NOECHO')
            select
               when inKey2 = Insert_Key     then call DoInsert
               when inKey2 = Delete_Key     then call DoDelete
               when inKey2 = Home_Key       then call DoHome
               when inKey2 = Ctrl_Home      then call DoCtrlHome
               when inKey2 = End_Key        then call DoEnd
               when inKey2 = Ctrl_End       then call DoCtrlEnd
               when inKey2 = PgUp_Key       then call DoPgUp
               when inKey2 = PgDn_Key       then call DoPgDn
               when inKey2 = DnArrow_Key    then call DoDnArrow
               when inKey2 = UpArrow_Key    then call DoUpArrow
               when inKey2 = RightArrow_Key then call DoRightArrow
               when inKey2 = LeftArrow_Key  then call DoLeftArrow
               when inKey2 = F1             then call DoHelp
               when inKey2 = F2             then call DoSave
               when inKey2 = F3             then call DoQuit
               when inKey2 = F9             then call DoInfo
               otherwise nop
            end
         end
      otherwise
         if C2D(inKey) > 31 then call WriteChar
   end
end

/* Core Subroutines */

DoEnter:
linePart1 = SUBSTR(line.curRowInDoc, 1, curColInDoc - 1)
linePart2 = SUBSTR(line.curRowInDoc, curColInDoc)
line.0    = line.0 + 1
do x      = line.0 to (curRowInDoc + 2) by -1
   y      = x - 1
   line.x = line.y
end
line.curRowInDoc = linePart1
lineBelow        = 1 + curRowInDoc
line.lineBelow   = linePart2
curRowInDoc      = 1 + curRowInDoc
curColInDoc      = 1
curColInDocMem   = curColInDoc
docLeftCol       = 1
if curRowOnScr < scrBottomRow then 
   curRowOnScr = 1 + curRowOnScr
else
   docTopRow = 1 + docTopRow
curColOnScr  = scrLeftCol
modified = 1; call WriteText; call WriteStat
return


DoBackSpace:
if curColInDoc > 1 then
   do /* if wrapping to line above not required */
      curColInDoc      = curColInDoc - 1
      curColInDocMem   = curColInDoc
      line.curRowInDoc = DELSTR(line.curRowInDoc, curColInDoc, 1)
      if curColOnScr > scrLeftCol then
         do /* moves cursor, leave document in place */
            curColOnScr = curColOnScr - 1
            iLine = SUBSTR(line.curRowInDoc, docLeftCol, scrWidth, ' ')
            call SysCurPos curRowOnScr, scrLeftCol
            call Charout, iLine
         end
      else
         do
            if docLeftCol > 1 then
               do /* moves document, leaves cursor in place */
                  docLeftCol = docLeftCol - 1
                  call WriteText
               end
            else
               do
                  curColOnScr  = curColOnScreen - 1
                  iLine = SUBSTR(line.CurRowInDoc, docLeftCol, scrWidth, ' ')
                  call SysCurPos curRowOnScr, scrLeftCol
                  call CharOut, iLine
               end            
         end
      modified = 1
   end
else
   do
      if curRowInDoc > 1 then
         do /* if wrapping cursor to end of line above */
            linePart2        = line.curRowInDoc
            curRowInDoc      = curRowInDoc - 1
            linePart1        = line.curRowInDoc
            lineLength       = LENGTH(line.curRowInDoc)
            line.curRowInDoc = INSERT(linePart1, linePart2)
            lastLine         = line.0        
            line.0           = line.0 - 1
            do x = (curRowInDoc + 1) to line.0
               y      = x + 1
               line.x = line.y
            end
            line.lastLine  = ""
            curColInDoc    = 1 + lineLength
            curColInDocMem = curColInDoc
            curColOnScr    = scrLeftCol + lineLength
            if curRowOnScr > scrTopRow then
               do /* if cursor is not on the top row */
                  curRowOnScr = curRowOnScr - 1
                  if curColOnScr > scrRightCol then
                     do
                        curColOnScr = scrRightCol
                        docLeftCol  = 1 + curColInDoc - scrWidth
                     end
                  modified = 1
                  call WriteText
               end
            else
               do
                  docTopRow = docTopRow - 1
                  if curColOnScr > scrRightCol then
                  do
                     curColOnScr = scrRightCol
                     docLeftCol  = 1 + curColInDoc - scrWidth
                  end
                  modified = 1
                  call WriteText
               end
         end
      else /* if cursor at beginning of document */
         call DoErrorBeep
   end
call WriteStat
return


DoTab:
x       = 0
nextTab = 0
do until nextTab > curColInDoc
   x       = x + 1
   nextTab = tabSize * x
end
neededSpaces     = nextTab - curColInDoc
line.curRowInDoc = INSERT('', line.curRowInDoc, curColInDoc - 1, neededSpaces)
curColInDoc      = curColInDoc + neededSpaces
curColInDocMem   = curColInDoc
if curColOnScr + neededSpaces < scrRightCol + 1 then
   do
      iLine = SUBSTR(line.curRowInDoc, docLeftCol, scrWidth, ' ')
      call SysCurPos curRowOnScr, scrLeftCol
      call CharOut, iLine
      curColOnScr = curColOnScr + neededSpaces
   end
else
   do
      docLeftCol = docLeftCol + neededSpaces
      call WriteText
   end
modified = 1; call WriteStat
return


DoFind:
call SysCurPos scrBottomRow + 2, scrLeftCol
call CharOut, COPIES(' ',scrWidth)
call SysCurPos scrBottomRow + 2, scrLeftCol
call CharOut, _Find||': '
call SysCurPos scrBottomRow + 2, scrLeftCol + 6
call SysCurState 'ON'
parse pull findThisWord

DoFindaGain:
row = curRowInDoc
col = 1 + curColInDoc
do until (newcol \= 0) | (row > line.0)
   newcol = POS(TRANSLATE(findThisWord), TRANSLATE(line.row), col)
   col    = 1
   if newcol = 0 then row = row + 1
end
if newcol = 0 then
   do
      call SysCurPos scrBottomRow + 2, scrLeftCol
      call CharOut, COPIES(' ',scrWidth)
      call SysCurPos scrBottomRow + 2, scrLeftCol
      call CharOut, 'Unable to find:' findThisWord '- Press Enter to continue'
      call DoErrorBeep
      pull
   end
else
   do
      curRowInDoc    = row
      curColInDoc    = newcol
      curColInDocMem = curColInDoc
      curRowOnScr    = curRowInDoc - docTopRow  + scrTopRow
      if curRowOnScr > scrBottomRow then
         do
            docTopRow   = curRowInDoc - (scrHeight % 2)
            curRowOnScr = curRowInDoc - docTopRow + scrTopRow
            call WriteText
         end
      curColOnScr = curColInDoc - docLeftCol + scrLeftCol
      if curColOnScr < scrLeftCol then
         do
            docLeftCol  = curColInDoc
            curColOnScr = curColInDoc - docLeftCol + scrLeftCol
            call WriteText
         end
      if curColOnScr > scrRightCol then
         do
            wordLength  = LENGTH(findThisWord)
            docLeftCol  = curColInDoc - scrWidth + wordLength
            curColOnScr = curColInDoc - docLeftCol + scrLeftCol
            call WriteText
         end
   end
call WriteStat
return


DoInsert:
if insMode = 1 then
   insMode = 0
else
   insMode = 1
call WriteStat
return


DoCtrlEnter:
line.0    = line.0 + 1
do x      = line.0 to (curRowInDoc + 1) by -1
   y      = x - 1
   line.x = line.y
end
line.curRowInDoc = ""
curColInDoc      = 1
curColInDocMem   = curColInDoc
docLeftCol       = 1
curColOnScr      = scrLeftCol
modified = 1; call WriteText; call WriteStat
return


DoDelete:
lineLength = LENGTH(line.curRowInDoc)
if curColInDoc < 1 + lineLength then
   do
      line.curRowInDoc = DELSTR(line.curRowInDoc, curColInDoc, 1)
      iLine = SUBSTR(line.curRowInDoc, docLeftCol, scrWidth, ' ')
      call SysCurPos curRowOnScr, scrLeftCol
      call CharOut, iLine
      modified = 1
   end
else
   do
      lineBelow = 1 + curRowInDoc
      if lineBelow < 1 + line.0 then
         do
            line.curRowInDoc = INSERT(line.curRowInDoc, line.lineBelow)
            do x      = lineBelow to line.0
               y      = 1 + x
               line.x = line.y
            end
            lastLine = line.0
            line.lastLine = ""
            line.0 = line.0 - 1
            call WriteText
            modified = 1
         end
      else
         call DoErrorBeep
   end
call WriteStat
return


DoCtrlBackspace:
if 1 + curRowInDoc > line.0 then
   line.curRowInDoc = ""
else
   do
      do x      = curRowInDoc to line.0 - 1
         y      = 1 + x
         line.x = line.y
      end
      lastLine      = line.0
      line.lastLine = ""
      line.0        = line.0 - 1
   end
modified = 1; call WriteText; call WriteStat
return


DoHome:
if curColInDoc > 1 then
   do /* if cursor is not at beginning of the line */
      curColInDoc    = 1
      curColInDocMem = curColInDoc
      curColOnScr    = scrLeftCol
      if docLeftCol > 1 then
         do /* if left Col of line is not left justified */
            docLeftCol  = 1
            call WriteText
         end
      call WriteStat
   end
else
    call DoErrorBeep
return


DoCtrlHome:
select
   when (docTopRow > 1) | (docLeftCol > 1) then
      do
         curRowInDoc    = 1
         curColInDoc    = 1
         curColInDocMem = 1
         docTopRow      = 1
         docLeftCol     = 1
         curRowOnScr    = scrTopRow
         curColOnScr    = scrLeftCol
         call WriteText; call WriteStat
      end
   when (curRowInDoc > 1) | (curColInDoc > 1) then
      do
         curRowInDoc    = 1
         curColInDoc    = 1
         curColInDocMem = 1
         curRowOnScr    = scrTopRow
         curColOnScr    = scrLeftCol
         call WriteStat
      end
otherwise
   call DoErrorBeep
end
return


DoEnd:
lineLength = LENGTH(line.curRowInDoc)
if curColInDoc < 1 + lineLength then
   do /* if cursor is not at end of line */
      curColInDoc    = 1 + lineLength
      curColInDocMem = curColInDoc
      curColOnScr    = scrLeftCol + lineLength
      if curColOnScr > scrRightCol then
         do /* if right column is not right justified */
            curColOnScr = scrRightCol
            docLeftCol  = 1 + curColInDoc - scrWidth
            call WriteText
         end
      call WriteStat
   end
else
   call DoErrorBeep
return


DoCtrlEnd:
curRowInDoc = line.0
lineLength  = LENGTH(line.curRowInDoc)
select
   when (docTopRow < line.0 - scrHeight + 1) then
      do
         curColInDoc    = 1 + lineLength
         curColInDocMem = curColInDoc
         curRowOnScr    = scrTopRow + scrHeight - 1
         curColOnScr    = scrLeftCol + lineLength
         if curColOnScr > scrRightCol then
            do /* if right column is not right justified */
               curColOnScr = scrRightCol
               docLeftCol  = 1 + curColInDoc - scrWidth
            end
         docTopRow = line.0 - scrHeight + 1
         call WriteText; call WriteStat
      end
    when (curRowInDoc > 1) then
       do
         curColInDoc    = 1 + LENGTH(line.curRowInDoc)
         curColInDocMem = curColInDoc
         docTopRow      = line.0 - scrHeight + 1
         docLeftCol     = 1
         curRowOnScr    = scrTopRow + scrHeight - 1
         curColOnScr    = scrLeftCol + LENGTH(line.curRowInDoc)
         call WriteStat
       end
otherwise
   call DoErrorBeep
end
return


DoPgUp:
if docTopRow > 1 then
   do
      if docTopRow > scrHeight - 1 then
         do
            docTopRow   = docTopRow   - scrHeight
            curRowInDoc = curRowInDoc - scrHeight
         end
      else
         do
            x           = docTopRow
            docTopRow   = 1
            y           = x - docTopRow 
            curRowInDoc = curRowInDoc - y
         end
      curColInDoc    = curColInDocMem
      lineLength     = LENGTH(line.curRowInDoc)
      if curColInDoc > 1 + lineLength then
         curColInDoc = 1 + lineLength
      curColOnScr    = curColInDoc + scrLeftCol - docLeftCol
      if curColOnScr < scrLeftCol then
         docLeftCol  = 1 + lineLength
      if curColOnScr > scrRightCol then
         /* if document needs to be moved to the left */
         docLeftCol  = curColInDocument - scrWidth + 1
      curColOnScr    = curColInDoc + scrLeftCol - docLeftCol
      call WriteText; call WriteStat
   end
else
   call DoErrorBeep
return


DoPgDn:
if line.0 > docTopRow + scrHeight - 1 then
   do /* if lines of text currently exceeds the screen bottom row */
      if line.0 - scrHeight > docTopRow + scrHeight then         
         do
            docTopRow   = docTopRow   + scrHeight
            curRowInDoc = curRowInDoc + scrHeight
         end
      else
         do
            x           = docTopRow
            docTopRow   = line.0 - scrHeight + 1
            y           = docTopRow - x
            curRowInDoc = curRowInDoc + y
         end
      curColInDoc    = curColInDocMem
      lineLength     = LENGTH(line.curRowInDoc)
      if curColInDoc > 1 + lineLength then
         curColInDoc = 1 + lineLength
      curColOnScr    = curColInDoc + scrLeftCol - docLeftCol
      if curColOnScr < scrLeftCol then
         docLeftCol  = 1 + lineLength
      if curColOnScr > scrRightCol then
         /* if document needs to be moved to the left */
         docLeftCol  = curColInDoc - scrWidth + 1
      curColOnScr    = curColInDoc + scrLeftCol - docLeftCol
      call WriteText; call WriteStat
   end
else
   call DoErrorBeep
return


DoDnArrow:
if curRowInDoc < line.0 then
  do /* if cursor is not on bottom line of document */
    curRowInDoc = 1 + curRowInDoc
    if curRowOnScr < scrBottomRow then
      do /* if cursor is not on bottom line of screen */
        curRowOnScr = 1 + curRowOnScr
        curColInDoc = curColInDocMem
        lineLength  = LENGTH(line.curRowInDoc)
        if curColInDoc > 1 + lineLength then
          /* if cursor needs to be moved to end of line */
          curColInDoc = 1 + lineLength
        curColOnScr  = curColInDoc + scrLeftCol - docLeftCol
        if curColOnScr < scrLeftCol then
          do /* if document needs to be moved to the right */
            docLeftCol = 1 + lineLength
            call WriteText
          end
        if curColOnScr > scrRightCol then
          do /* if document needs to be moved to the left */
            docLeftCol = curColInDoc - scrWidth + 1
            call WriteText
          end
        curColOnScr = curColInDoc + scrLeftCol - docLeftCol
      end
    else
      do /* if cursor is on the bottom line of the screen */
        docTopRow   = 1 + docTopRow
        curColInDoc = curColInDocMem
        lineLength  = LENGTH(line.curRowInDoc)
        if curColInDoc > 1 + lineLength then
           /* if cursor needs to be moved to end of line */
           curColInDoc = 1 + lineLength
        curColOnScr = curColInDoc + scrLeftCol - docLeftCol
        if curColOnScr < scrLeftCol then
           /* if document needs to be moved to the right */
           docLeftCol = 1 + lineLength
        if curColOnScr > scrRightCol then
           /* if document needs to be moved to the left */
           docLeftCol = curColInDoc - scrWidth + 1
        curColOnScr = curColInDoc + scrLeftCol - docLeftCol
        call WriteText
      end
    call WriteStat
  end
else
   call DoErrorBeep
return


DoUpArrow:
if curRowInDoc > 1 then
  do /* if cursor is not on top line of document */
    curRowInDoc = curRowInDoc - 1
    if curRowOnScr > scrTopRow then
      do /* if cursor is not on the top line of screen */
        curRowOnScr = curRowOnScr - 1
        curColInDoc = curColInDocMem
        lineLength  = LENGTH(line.curRowInDoc)
        if curColInDoc > 1 + lineLength then
           /* if cursor needs to be moved to end of line */
           curColInDoc = 1 + lineLength
        curColOnScr = curColInDoc + scrLeftCol - docLeftCol
        if curColOnScr < scrLeftCol THEN
          do /* if document needs to be moved to the right */
            docLeftCol = 1 + lineLength
            call WriteText
          end
        if curColOnScr > scrRightCol then
          do /* if document needs to be moved to the left */
            docLeftCol = curColInDoc - scrWidth + 1
            call WriteText
          end
        curColOnScr = curColInDoc + scrLeftCol - docLeftCol
      end
    else
      do /* if cursor is on the top line of the screen */
        docTopRow   = docTopRow - 1
        curColInDoc = curColInDocMem
        lineLength  = LENGTH(line.curRowInDoc)
        if curColInDoc > 1 + lineLength then
           /* if cursor needs to be moved to end of line */
           curColInDoc = 1 + lineLength
        curColOnScr = curColInDoc + scrLeftCol - docLeftCol
        if curColOnScr < scrLeftCol then
           /* if document needs to be moved to the right */
           docLeftCol = 1 + lineLength
        if curColOnScr > scrRightCol then
            /* if document needs to be moved to the left */
            docLeftCol = curColInDoc - scrWidth + 1
        curColOnScr = curColInDoc + scrLeftCol - docLeftCol
        call WriteText
      end
    call WriteStat
  end
else
   call DoErrorBeep
return


DoRightArrow:
lineLength = LENGTH(line.curRowInDoc)
if curColInDoc < 1 + lineLength then
   do /* if wrapping to next line not required */
      curColInDoc    = 1 + curColInDoc
      curColInDocMem = curColInDoc
      if curColOnScr < scrRightCol then
         /* if cursor needs to be moved (leave document in place) */
         curColOnScr = 1 + curColOnScr
      else
         do /* if document needs to be moved (leave cursor in place) */
            docLeftCol = 1 + docLeftCol
            call WriteText
         end
   end
else
   do
      if curRowInDoc < line.0 then
         do /* if cursor is not on bottom line of document */
            curRowInDoc    = 1 + curRowInDoc
            curColInDoc    = 1
            curColInDocMem = curColInDoc
            curColOnScr    = scrLeftCol
            if curRowOnScr < scrBottomRow then
               do /* if cursor is on bottom row of screen */
                  if docLeftCol = 1 then
                     /* if document is left justified */
                     curRowOnScr = 1 + curRowOnScr
                  else
                     do
                        docLeftCol   = 1
                        curRowOnScr  = 1 + curRowOnScr
                        call WriteText
                     end
               end
            else
               do
                  docLeftCol = 1
                  docTopRow  = 1 + docTopRow
                  call WriteText
               end
         end
      else
          call DoErrorBeep
   end
call WriteStat
return


DoLeftArrow:
if curColInDoc > 1 then
   do /* if wrapping to next line not required */
      curColInDoc    = curColInDoc - 1
      curColInDocMem = curColInDoc    
      if curColOnScr > scrLeftCol then
         /* move cursor, leave document in place */
         curColOnScr = curColOnScr - 1
      else
         do
            docLeftCol = docLeftCol - 1
            call WriteText
         end
   end
else
   do
      if curRowInDoc > 1 then
         do /* if wrapping cursor to end of line above */
            curRowInDoc    = curRowInDoc - 1
            lineLength     = LENGTH(line.curRowInDoc)
            curColInDoc    = 1 + lineLength
            curColInDocMem = curColInDoc
            curColOnScr    = scrLeftCol + lineLength
            if curRowOnScr > scrTopRow then
               do /* if cursor is not on the top row */
                  curRowOnScr = curRowOnScr - 1
                  if curColOnScr > scrRightCol then
                     do /* */
                        curColOnScr = scrRightCol
                        docLeftCol  = 1 + curColInDoc - scrWidth
                        call WriteText
                     end
               end
            else
               do /* */
                  docTopRow = docTopRow - 1
                  if curColOnScr > scrRightCol then
                     do
                        curColOnScr = scrRightCol
                        docLeftCol  = 1 + curColInDoc - scrWidth
                     end
                  call WriteText
               end
         end
      else /* if cursor at beginning of document */
         call DoErrorBeep
   end
call WriteStat
return


DoHelp:
call CharOut, setInfoColor
call SysCls
call SysCurPos  0,0; call CharOut, _Help
call SysCurPos  2,3; call CharOut, _Enter_
call SysCurPos  3,3; call CharOut, _Ctrl_Enter_
call SysCurPos  4,3; call CharOut, _Backspace_
call SysCurPos  5,3; call CharOut, _Ctrl_Backspace_
call SysCurPos  6,3; call CharOut, _Tab_
call SysCurPos  7,3; call CharOut, _Esc_              
call SysCurPos  8,3; call CharOut, _Insert_
call SysCurPos  9,3; call CharOut, _Delete_
call SysCurPos 10,3; call CharOut, _Home_
call SysCurPos 11,3; call CharOut, _Ctrl_Home_
call SysCurPos 12,3; call CharOut, _End_
call SysCurPos 13,3; call CharOut, _Ctrl_End_
call SysCurPos 14,3; call CharOut, _Page_Up_
call SysCurPos 15,3; call CharOut, _Page_Down_
call SysCurPos 16,3; call CharOut, _Down_Arrow_
call SysCurPos 17,3; call CharOut, _Up_Arrow_
call SysCurPos 18,3; call CharOut, _Right_Arrow_
call SysCurPos 19,3; call CharOut, _Left_Arrow_
call SysCurPos 20,3; call CharOut, _Ctrl_F_G_R_
call SysCurPos 24,0; call CharOut, _Press_any_key_to_continue
inkey = SysGetKey('NOECHO')
if inkey = '00'x | inkey = 'E0'x THEN inkey2 = SysGetKey('NOECHO')
call CharOut, setTextColor
call SysCls
call WriteText; call WriteLine; call WriteStat; call WriteMenu
return


DoSave:
do while textFile = ''
   call CharOut, setInfoColor
   call SysCls
   call SysCurPos 0,0; call CharOut, _Save
   call SysCurPos 2,3; call CharOut, _Please_type_a_name_for_the_file
   call SysCurPos 4,3; call CharOut, '>'
   call SysCurPos 4,4; call SysCurState 'ON'
   parse pull textFile
/* need to test for legal filename */
end
if STREAM(textfile, 'C', 'QUERY EXISTS') \= '' then
   call SysFileDelete textFile
do i = 1 to line.0
   call LINEOUT textFile, line.i
end
call STREAM textfile, 'C', 'CLOSE'
modified = 0
call CharOut, setTextColor
call SysCls
call WriteText; call WriteLine; call WriteStat; call WriteMenu
return


DoQuit:
call CharOut, setInfoColor
if modified \= 0 THEN
  do
    call SysCls
    call SysCurPos  0,0; call CharOut, _Quit
    call SysCurPos  2,2; call CharOut, _The_file_has_been_modified
    call SysCurPos  4,2; call CharOut, _Save_before_quitting_Y_n
    YesNo = SysGetKey('NOECHO')
    if (YesNo = 'N') | (YesNo = 'n') THEN
      do
        call SysCls
        exit
      end
    else
       call DoSave
  end
call SysCls
exit


DoInfo:
call CharOut, setInfoColor
call SysCls
call SysCurPos  1,1; call CharOut, _Please_standby
totalBytes = 0
maxWidth = 0
do i = 1 TO line.0
   x = LENGTH(line.i)
   totalBytes = totalBytes + 2 + Length(line.i)
   if x > maxWidth THEN maxWidth = x
end
call SysCls
call SysCurPos  0,0; call CharOut, _Info
call SysCurPos  2,3; call CharOut, ProgVer
call SysCurPos  4,3; call CharOut, _A_simple_text_editor_written_in_REXX
call SysCurPos  7,3; call CharOut, textfile
call SysCurPos  9,3; call CharOut, _Width maxWidth
call SysCurPos 10,3; call CharOut, _Bytes totalBytes
call SysCurPos 12,3; call CharOut, _Loadtime loadTime 'seconds'
call SysCurPos 24,0; call CharOut, _Press_any_key_to_continue
inkey = SysGetKey('NOECHO')
if inkey = '00'x | inkey = 'E0'x THEN inkey2 = SysGetKey('NOECHO')
call CharOut, setTextColor
call SysCls
call WriteText; call WriteLine; call WriteStat; call WriteMenu
return

/* Output Subroutines */

WriteChar:
if insMode = 1 then
   line.curRowInDoc = INSERT(inKey, line.curRowInDoc, curColInDoc - 1, 1)
else
   line.curRowInDoc = OVERLAY(inKey, line.curRowInDoc, curColInDoc, 1)
curColInDoc    = curColInDoc + 1
curColInDocMem = curColInDoc
if curColOnScr < scrRightCol then
   do
      iline = SUBSTR(line.curRowInDoc, docLeftCol, scrWidth, ' ')
      call SysCurPos curRowOnScr, scrLeftCol
      call CharOut, iLine
      curColOnScr = curColOnScr + 1
   end
else
   do
      docLeftCol = docLeftCol + 1
      call WriteText
   end
modified = 1; call WriteStat
return


WriteText:
x = scrTopRow
do i = docTopRow to (docTopRow + scrHeight - 1)
   outputLine.i = SUBSTR(line.i, docLeftCol, scrWidth, ' ')
   call SysCurPos x, scrLeftCol; call CharOut, outputLine.i
   x = x + 1
end
/* Debug */ call CharOut, setInfoColor
/* Debug */ call SysCurPos scrBottomRow + 1, scrLeftCol
/* Debug */ call CharOut, '*'
/* Debug */ call CharOut, setTextColor
return


WriteLine:
call CharOut, setInfoColor
call SysCurPos scrBottomRow + 1, scrLeftCol
call CharOut,  COPIES('-', scrWidth)
call CharOut, setTextColor
return


WriteStat:
call CharOut, setInfoColor
call SysCurPos scrBottomRow + 2, scrLeftCol
call CharOut,  COPIES(' ', scrWidth)
call SysCurPos scrBottomRow + 2, scrLeftCol
if modified = 1 then x = "+"
else      x = "-"
if insMode  = 1 then y = _Insert
else      y = _Replace
call CharOut, _Line,
               curRowInDoc,
              _of,
               line.0,
              _Column,
               curColInDoc,
               y,
               x,
               FILESPEC('N',textFile)
call CharOut, setTextColor
return


WriteMenu:
call CharOut, setInfoColor
call SysCurPos scrBottomRow + 3, scrLeftCol
call CharOut, 'F1='||_Help '',
              'F2='||_Save '',
              'F3='||_Quit '',
              'F9='||_Info
call CharOut, setTextColor
return

/* Supporting Subroutines */

LoadFile:
call SysCls
line. = ""
line.0 = 0
if textfile \= '' then
   do
      if STREAM(textfile,'C','QUERY EXISTS') \= '' then
         do
            call SysCurState 'OFF'
            call SysCurPos 0,0; call CharOut, _Please_standby
            i = 0
            LoadTime = TIME('E') /* start timing */
            do UNTIL LINES(textfile) = 0
               i = i + 1
              line.i = LineIn(textfile)
            end
            LoadTime = TIME('E') /* end timing */
           ok = STREAM(textfile,'C','CLOSE')
           line.0 = i
           call SysCls
        end

    /* Need to add code in case the file does not exist */

   end
else
   line.0 = 1
return


DoErrorBeep:
call BEEP 800,25
return

/* Data Subroutines */

LoadKeys:
Enter_Key      = X2C('0D')
Ctrl_Enter     = X2C('0A')
Backspace_Key  = X2C('08')
Ctrl_Backspace = X2C('7F')
Tab_Key        = X2C('09')
Esc_Key        = X2C('1B')
Ctrl_F         = X2C('06')
Ctrl_G         = X2C('07')

Insert_Key     = X2C('52') /* Extended Key Codes */
Delete_Key     = X2C('53')
Home_Key       = X2C('47')
Ctrl_Home      = X2C('77')
End_Key        = X2C('4F')
Ctrl_End       = X2C('75')
PgUp_Key       = X2C('49')
PgDn_Key       = X2C('51')
DnArrow_Key    = X2C('50')
UpArrow_Key    = X2C('48')
RightArrow_Key = X2C('4D')
LeftArrow_Key  = X2C('4B')
F1             = X2C('3B')
F2             = X2C('3C')
F3             = X2C('3D')
F9             = X2C('43')
return


German:
_Line     = "Zeile"
_of       = "von"
_Column   = "Spalte"
_Insert   = "Einfgen"
_Replace  = "Ersetzen"
_Modified = "Verndert"
_Help     = "Hilfe"
_Save     = "Abspeichern"
_Quit     = "Ende"
_Info     = "Info"
_Find     = "Finden"
_File     = "Datei"
_Width    = "Breite"
_Bytes    = "Bytes"
_Loadtime = "Ladezeit"

_Enter_          = "Eingabetaste ... Fgt neue Zeile ein"
_Ctrl_Enter_     = "Strg-Enter ..... Fgt leere Zeile ein"
_Backspace_      = "Rcktaste ...... Lscht Buchstabe links vom Cursor"
_Ctrl_Backspace_ = "Strg-Rcktaste . Lscht gegenwrtige Zeile"
_Tab_            = "Tabulatortaste . Verlegt den Cursor zum nchsten Tabulator"
_Esc_            = "Esc ............ Schliesst das Dokument"
_Insert_         = "Einfg .......... Wechselt zwischen Einfgen und berschreiben"
_Delete_         = "Delete ........  Lscht Buchstabe beim Cursor"
_Home_           = "Heim ........... Bewegt den Cursor zum Anfang der gegenwrtigen Zeile"
_Ctrl_Home_      = "Strg-Heim ...... Springt an den Beginn des Dokumentes"
_End_            = "Ende ........... Bewegt den Cursor zum Ende der aktuellen Zeile"
_Ctrl_End_       = "Strg-Ende ...... Springt an das Ende des Dokumentes"
_Page_Up_        = "Bild auf ....... Zeigt die vorhergehende Bildschirmseite"
_Page_Down_      = "Bild ab ........ Zeigt die folgende Bildschirmseite"
_Down_Arrow_     = "Pfeil unten .... Bewegt den Cursor eine Zeile nach unten"
_Up_Arrow_       = "Pfeil oben ..... Bewegt den Cursor eine Zeile nach oben"
_Right_Arrow_    = "Pfeil rechts ... Bewegt den Cursor einen Buchstaben nach rechts"
_Left_Arrow_     = "Pfeil links .... Bewegt den Cursor einen Buchstaben nach links"
_Ctrl_F_G_R_     = "Strg-F/G ....... Finden/Wiederhole Finden"

_Please_standby                       = "Bitte warten"
_Press_any_key_to_continue            = "Weiter mit beliebiger Taste"
_Save_before_quitting_Y_n             = "Mchten Sie die Datei abspeichern? ([J]a/[n]ein)"
_The_file_has_been_modified           = "Die bearbeitete Datei wurde verndert"
_Please_type_a_name_for_the_file      = "Bitte einen Dateinamen angeben"
_A_simple_text_editor_written_in_REXX = "Einfacher Texteditor, geschrieben in REXX"
return


Spanish:
_Line     = "L¡nea"
_of       = "de"
_Column   = "Columna"
_Insert   = "Insertar"
_Replace  = "Reemplazar"
_Modified = "Modificado"
_Help     = "Ayuda"
_Save     = "Guardar"
_Quit     = "Cerrar"
_Info     = "Informaci¢n"
_Find     = "Buscar"
_File     = "Archivo"
_Width    = "Anchura"
_Bytes    = "Bytes"
_Loadtime = "Tiempo de carga"

_Enter_          = "Intro .......... Dividir la l¡nea en la posici¢n del cursor"
_Ctrl_Enter_     = "Ctrl-Intro ..... Insertar una l¡nea en blanco"
_Backspace_      = "Retroceso ...... Suprimir un caracter a la izquierda del cursor"
_Ctrl_Backspace_ = "Ctrl-Retroceso . Suprimir la l¡nea actual"
_Tab_            = "Tab ............ Desplazar el cursor a la siguiente tabulaci¢n"
_Esc_            = "Esc ............ Salir"
_Insert_         = "Insertar ....... Conmutar la modalidad de inserci¢n"
_Delete_         = "Suprimir ....... Eliminar el caracter en la posici¢n del cursor actual"
_Home_           = "Inicio ......... Desplazar el cursor al inicio de la l¡nea actual"
_Ctrl_Home_      = "Ctrl-Inicio .... Situar la vista al inicio del documento"
_End_            = "Fin ............ Desplazar el cursor al final de la l¡nea actual"
_Ctrl_End_       = "Ctrl-Fin ....... Situar la vista al final del documento"
_Page_Up_        = "Re P g ......... Situar la vista una p gina por encima de la actual"
_Page_Down_      = "Av P g ......... Situar la vista una p gina por debajo de la actual"
_Down_Arrow_     = "Flecha abajo ... Desplazar el cursor una l¡nea hacia abajo"
_Up_Arrow_       = "Flecha arriba .. Desplazar el cursor una l¡nea hacia arriba"
_Right_Arrow_    = "Flecha derecha . Desplazar el cursor un caracter a la derecha"
_Left_Arrow_     = "Flecha izquierda Desplazar el cursor un caracter a la izquierda"
_Ctrl_F_G_R_     = "Ctrl-F/G ....... Buscar/Repetir b£squeda"

_Please_standby                       = "Espere por favor..."
_Press_any_key_to_continue            = "Presione cualquiera tecla para continuar"
_Save_before_quitting_Y_n             = "¨Desea guardar antes de salir? (Y/n)"
_The_file_has_been_modified           = "Se ha modificado el archivo"
_Please_type_a_name_for_the_file      = "Teclee un nombre para el archivo"
_A_simple_text_editor_written_in_REXX = "Un editor de texto sencillo, escrito en REXX"
return


English:
/*
  Notes concerning language support:

- Edit is developed and tested using codepage 850

- "_" is the first character in all identifiers requiring language
      support
- "_" is the last character in identifiers where the actual text is
      longer than the characters in the identifier
*/

_Line     = "Line"
_of       = "of"
_Column   = "Col"
_Insert   = "Insert"
_Replace  = "Replace"
_Modified = "Modified"
_Help     = "Help"
_Save     = "Save"
_Quit     = "Quit"
_Info     = "Info"
_Find     = "Find"
_File     = "File"
_Width    = "Width"
_Bytes    = "Bytes"
_Loadtime = "Loadtime"

_Enter_          = "Enter .......... Splits current line at cursor"
_Ctrl_Enter_     = "Ctrl-Enter ..... Inserts blank line"
_Backspace_      = "Backspace ...... Deletes character to left of cursor"
_Ctrl_Backspace_ = "Ctrl-Backspace . Deletes current line"
_Tab_            = "Tab ............ Moves cursor to next tab location"
_Esc_            = "Esc ............ Quit"
_Insert_         = "Insert ......... Toggles insert mode"
_Delete_         = "Delete ......... Deletes character at cursor position"
_Home_           = "Home ........... Moves cursor to beginning of line"
_Ctrl_Home_      = "Ctrl-Home ...... Shifts view to beginning of document"
_End_            = "End ............ Moves cursor to end of line"
_Ctrl_End_       = "Ctrl-End ....... Shifts view to end of document"
_Page_Up_        = "Page Up ........ Shifts view to page above current page"
_Page_Down_      = "Page Down ...... Shifts view to page below current page"
_Down_Arrow_     = "Down Arrow ..... Moves cursor one line down"
_Up_Arrow_       = "Up Arrow ....... Moves cursor one line up"
_Right_Arrow_    = "Right Arrow .... Moves cursor one character to right"
_Left_Arrow_     = "Left Arrow ..... Moves cursor one character to left"
_Ctrl_F_G_R_     = "Ctrl-F/G ....... Find/Find Again"

_Please_standby                       = "Please standby"
_Press_any_key_to_continue            = "Press any key to continue"
_Save_before_quitting_Y_n             = "Save before quitting? (Y/n)"
_The_file_has_been_modified           = "The file has been modified"
_Please_type_a_name_for_the_file      = "Please type a name for the file"
_A_simple_text_editor_written_in_REXX = "A simple text editor, written in REXX"
return
