/* cmdshl.cmd - an improved cmd shell                        20060525 */
/* (c) martin lafaix 1994 - 2006                                      */

/* user dependant values */
insertState = 1
cmdQueue = 1
impCD = 1
nl = '0d0a'x
defHelp = 'Use the DEFINE command to (re)define keyboard keys'nl||nl||,
          'SYNTAX:    DEF key [value]'nl||,
          '        DEFINE key [value]'nl||nl||,
          '         key    The name of the key to be redefined.'nl||,
          '         value  The new key value. It can be an internal command,'nl||,
          '                OSNowait xxx or TEXT yyy.'nl||nl||,
          'Examples:'nl||,
          '         DEF F12 TEXT dir /w'nl||,
          '      DEFINE F3  OSNOWAIT exit'nl||,
          '         DEF F12'
aliasHelp = 'Use the ALIAS command to view, add or remove an alias'nl||nl||,
            'SYNTAX: ALIAS [LIST|alias=[string]|@file]'nl||nl||,
            '         LIST    View all currently defined aliases.'nl||,
            '         alias   An alias name (case sensitive).'nl||,
            '         string  The new value for alias.'nl||,
            '         file    A file containing one (or more) alias definitions.'nl||nl||,
            'In an alias definition, %n[*] denotes command line parameters.'
ruleHelp = 'Use the RULE command to view, add or remove a rule'nl||nl||,
           'SYNTAX: RULE [LIST|rule=[string]|@file]'nl||nl||,
           '         LIST    View all currently defined rules.'nl||,
           '         rule    A rule name (case sensitive for aliases).'nl||,
           '         string  The new value for rule.'nl||,
           '         file    A file containing one (or more) rule definitions.'nl||nl||,
           'In a rule definition, %*, %(list), %c, %d, %e, %f, %l, %o, %u and'nl||,
           '%x denotes parameters types.'
cmdHelp = 'Use the CMDSHL command to enhance your command shell.'nl||nl||,
          'SYNTAX: CMDSHL [/I|/O] [/P profile] [/C cmd|/K cmd]'nl||nl||,
          '         /I    Insert mode is the default.'nl||,
          '         /O    Overstrike mode is the default.'nl||,
          '         /P    Use the specified profile file.'nl||,
          '         /C    Execute cmd and exit CMDSHL.'nl||,
          '         /K    Execute cmd without exiting CMDSHL.'nl||nl||,
          'By default, Insert mode is on and PROFILE.SHL is used as profile'nl||,
          'file if it exists along the path specified by the DPATH environment'nl||,
          'variable.'
cdHelp = 'Enter CD -     To go back to the previous current directory'nl||,
         'Enter CD s1 s2 To substitute s1 by s2 in current directory'
quitHelp = 'Use the QUIT command to leave CMDSHL.'nl||nl||,
           'SYNTAX: QUIT'
/* nothing to translate beyond this point */

/*====================================================================
 * The Main Loop.
 *====================================================================*/
'@echo off'; trace off

main:
call init

if arg() then
   call doarg arg(1)

call profile

loop:
do forever
   call charout ,print()

   if eval(getline()) = 0 then
      leave
end /* do */

call terminate

exit

/*====================================================================
 * A cmd.exe-like Command Prompt.
 *====================================================================*/
print:
   prompt = value('CMDSHL.PROMPT.'address(),,'OS2ENVIRONMENT')
   if prompt == '' then
     prompt = value('CMDSHL.PROMPT',,'OS2ENVIRONMENT')
   if prompt == '' then
      prompt = value('PROMPT',,'OS2ENVIRONMENT')
   if prompt == '' then
      prompt = '[$p]'

   str = ''

   do i = 1 to length(prompt)
      key = substr(prompt,i,1)
      if key = '$' then
         do
         i = i+1; key = translate(substr(prompt,i,1))
         select
            when key = '$' then str = str||'$'
            when key = 'A' then str = str||'&'
            when key = 'B' then str = str||'|'
            when key = 'C' then str = str||'('
            when key = 'D' then str = str||date()
            when key = 'E' then str = str||'1b'x
            when key = 'F' then str = str||')'
            when key = 'G' then str = str||'>'
            when key = 'H' then str = str||'08'x
            when key = 'I' then str = str||'1b'x'[s'||'1b'x'[0;0H'helpColor1||helpstring'1b'x'[K'helpColor2'1b'x'[u'
            when key = 'L' then str = str||'<'
            when key = 'N' then str = str||filespec('d',directory())
            when key = 'P' then str = str||directory()
            when key = 'Q' then str = str||'='
            when key = 'R' then str = str||rc
            when key = 'S' then str = str||' '
            when key = 'T' then str = str||time()
            when key = 'V' then str = str||verString
            when key = '_' then str = str||'0d0a'x
         otherwise
         end  /* select */
         end
      else
         str = str||key
   end /* do */
   return str

/*====================================================================
 * A cmd.exe-like Command Shell, w/ Filename Completion.
 *====================================================================*/
init:
   signal on syntax name initsyntax

   if RxFuncQuery('SysLoadFuncs') then
      do
      call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
      call SysLoadFuncs
      end

   if RxFuncQuery('VioLoadFuncs') then
      do
      call RxFuncAdd 'VioLoadFuncs','RexxVIO','VioLoadFuncs'
      call VioLoadFuncs
      end

   oldCur = VioGetCurType()

   insertMode.1 = '-80 -90'
   insertMode.0 = '0 -100'

   fileSeparator = ' =;<>|(&'

   prevLine.0 = 0

   helpSwitches = value('HELP.SWITCHES',,'OS2ENVIRONMENT')
   if helpSwitches = '' then
      helpSwitches = '/?'

   cmdList = 'CALL CD CHCP CHDIR CLS COPY DATE DETACH DIR DPATH ECHO',
             'ERASE DEL EXIT FOR IF KEYS MD MKDIR MOVE PATH PAUSE PROMPT',
             'REM REN RENAME RD RMDIR SET START TIME TYPE VER VERIFY VOL'

   cnvList = 'CALL CD CHDIR COPY DETACH DIR ERASE DEL MD MKDIR MOVE REN',
             'RENAME RD RMDIR START TYPE'

   shlList = 'ALIAS CD DEF DEFI DEFIN DEFINE KEYS QUIT RX RULE'

   extList = 'exe cmd bat com'

   rulesList = 'START DETACH CD SET FOR RD RMDIR CHDIR'

   /*
    * %c = command      %d = directory    %e = env. var.    %f = file
    * %l = letter       %o = option       %u = unix option  %x = expression
    * %* = anything     %(list) = file following a given pattern
    */
   rules.START = '"%*" %o %x^|"%*" %o^|%o %x^|%o'
   rules.DETACH = '%x'
   rules.CD = '%d^|%f %f^|/?^|'
   rules.CHDIR = '%d^|/?^|'
   rules.SET = '%e=%*^|/?^|'
   rules.FOR = '%%%l IN (%*) DO %x'
   rules.RD = '%d %d*^|/?'
   rules.RMDIR = '%d %d*^|/?'

   invalidCmd = 'call VioWrtNAttr origRow + xlen % col, xlen // col, length(xline), 12;',
                'xOfs = currOfs+1'

   preEvalCmd = ''
   postEvalCmd = ''

   pathExt = 0
   autoPathExt = 0

   helpColor1 = '1b'x'[0;34;47m'
   helpColor2 = '1b'x'[0m'

   _LEVEL_ = 0

   A_C = '002e'x;                   key._002e = 'mark copy'
   A_D = '0020'x;                   key._0020 = 'mark delete'
   C_E = '05'x;                     key._05   = 'ctrlend'
   C_K = '0B'x;                     key._0B   = 'dup'
   A_M = '0032'x;                   key._0032 = 'mark move'
   A_U = '0016'x;                   key._0016 = 'mark clear'
   A_W = '0011'x;                   key._0011 = 'mark word'
   C_X = '18'x;                     key._18   = 'expand'
   A_Z = '002c'x;                   key._002c = 'mark char'
   A_F10 = '0071'x
   BKSP = '08'x;                    key._08   = 'backsp'
   CURD = '0050'x;                  key._0050 = 'cdown'
   CURL = '004b'x;                  key._004B = 'cleft'
   CURR = '004d'x;                  key._004D = 'cright'
   CURU = '0048'x;                  key._0048 = 'cup'
   C_CURL = '0073'x;                key._0073 = 'ctrlleft'
   C_CURR = '0074'x;                key._0074 = 'ctrlright'
   C_END = '0075'x;                 key._0075 = 'ctrlend'
   C_HOME = '0077'x;                key._0077 = 'ctrlhome'
   C_PGDN = '0076'x
   C_PGUP = '0084'x
   DEL = '0053'x;                   key._0053 = 'del'
   END = '004F'x;                   key._004F = 'end'
   ENTER = '0d'x;                   key._0D   = 'enter'
   ESC = '1b'x;                     key._1B   = 'esc'
   F1 = '003b'x;                    key._003B = 'match'
   F2 = '003c'x
   F3 = '003d'x
   F4 = '003e'x
   F5 = '003f'x
   F6 = '0040'x
   F7 = '0041'x
   F8 = '0042'x
   F9 = '0043'x
   F10 = '0044'x
   F11 = '0085'x
   F12 = '0086'x
   HOME = '0047'x;                  key._0047 = 'home'
   INS = '0052'x;                   key._0052 = 'ins'
   PGDN = '0051'x
   PGUP = '0049'x
   S_TAB = '000F'x;                 key._000F = 'backtab'
   TAB = '09'x;                     key._09   = 'tab'
   SPACE = '20'x;                   key._20   = 'space'

   aliasNames = ''
   profileName = 'profile.shl'

   oldDir = directory()
   secondaryPrompt = SysGetMessage(1093)
   parse value SysGetMessage(1492) with helpString '0d0a'x

   parse value SysOS2Ver() with osmajor '.' osminor
   if osmajor = '2' & osminor = '30' then /* Warp kludge */
      parse value '3.00' with osmajor '.' osminor
   else
   if osmajor = '2' & osminor = '40' then /* Merlin kludge */
      parse value '4.00' with osmajor '.' osminor
   else
   if osmajor = '2' & osminor = "45" then /* WSeB & FP13+ kludge */
      parse value '4.50' with osmajor '.' osminor
   verString = SysGetMessage(1090,,osmajor,osminor)

   interactive = 0

   global = 'helpString profileName profileFile verString aliasNames oldDir RC',
            'cmdList impCD shlList invalidCmd interactive helpColor1 helpColor2',
            'insertMode. fileSeparator aliasStem. _LEVEL_ extList rulesList',
            'rules. helpSwitches preEvalCmd postEvalCmd pathExt cnvList',
            'autoPathExt'

   parse version rexx .
   if rexx = 'OBJREXX' then
      openread = 'open read' /* shared */
   else
      openread = 'open read'

   signal off syntax

   return

initsyntax:
   if rc = 43 then /* Probably an attempt to call a supposedly loaded function */
      signal main
   else
      do
      what = rc
      say right(sigl, 6) '+++  ' sourceline(sigl)
      parse source . . sourcefn .
      say 'REXX'right(what,4,0)': Error' what 'running' sourcefn', line' sigl':' errortext(what)
      exit(-what)
      end

terminate:
   call VioSetCurType word(oldCur,1),word(oldCur,2),word(oldCur,3),word(oldCur,4)
   return

profile:
   signal on syntax name profilesyntax
   interactive = 0; profileline = 0
   profileFile = SysSearchPath('DPATH',profileName)
   if profileFile \= '' then do
      call stream profileFile, 'c', openread
      do while lines(profileFile) > 0
         line = linein(profileFile); profileline = profileline+1
         do while lines(profileFile) > 0 & right(line,1) = ','
            line = left(line,length(line)-1) linein(profileFile)
         end /* do */
         if left(line,1) = "'" | left(line,1) = '"' then
            interpret 'call eval' line
         else
            interpret line
      end /* do */
      call stream profileFile, 'c', 'close'
      end
   interactive = 1
   signal off syntax
   return

profilesyntax:
   call charout ,'REX'right(rc,4,'0')': Error' rc 'running' profileFile', line' profileline':' errortext(rc)nl
   call stream profileFile, 'c', 'close'
   rc = -rc
   signal loop

getline:
   procedure expose prevLine. key. insertState cmdQueue secondaryPrompt (global)

   parse value SysCurPos() with origRow origCol .
   parse value SysTextScreenSize() with row col

   parse value origRow origCol '1 0 0 0 0 0' insertState,
         with currRow currCol firstCup currOfs currTab len olen xOfs insert key line

   parse value 0 0 with markLen markOfs

   call VioSetCurType word(insertMode.insert,1), word(insertMode.insert,2)

   if arg(1) \= '' then
      do
      line = arg(1)
      len = length(line)
      call charout , left(line,max(len,olen))
      if origRow + (origCol + len) % col >= row then
         origRow = row - (origCol + len) % col - 1
      olen = len
      call SysCurPos origRow + (origCol + currOfs) % col, (origCol + currOfs) // col
      end

   currLine = prevLine.0

   do while (key <> 'enter')
      lastKey = key
      key = getKey()
      oline = line

dokey:
      select
         when length(key) = 1 then
            do
            if insert then
               line = insert(key,line,currOfs)
            else
               line = overlay(key,line,currOfs+1)

            currOfs = currOfs + 1
            end

         when key = 'backsp' then
            do
            if currOfs <= 0 then
               if mc = 1 then return; else iterate
            line = delstr(line,currOfs,1)
            currOfs = currOfs - 1
            end

         when key = 'space' then
            do
            oldOfs = xOfs; xOfs = 0; xyzzy = findcontexttype()

            if insert then
               line = insert(' ',line,currOfs)
            else
               line = overlay(' ',line,currOfs+1)

            dif = compare(line,oline)
            if dif = 0 & olen \= length(line) then
               dif = length(line)
            if dif \= 0 then
               do
               len = length(line)
               if dif <= xOfs then dif = 1
               call SysCurPos origRow + (origCol + dif - 1) % col, (origCol + dif - 1) // col
               call charout , substr(line,dif,max(len,olen)-dif+1)

               if origRow + (origCol + len) % col >= row then
                  origRow = row - (origCol + len) % col - 1
               olen = len; oline = line
               end

            xlen = origCol + currOfs - length(strip(xline,'L'))
            if xyzzy = 'c' then do
               if findcommand() = '' then
                  interpret invalidCmd
               end
            else
            if xyzzy = '0' then
               interpret invalidCmd

            currOfs = currOfs + 1
            xOfs = max(oldOfs, xOfs)
            end

         when key = 'tab' | key = 'backtab' then
            do
            if currTab \= 0 then
               if key = 'tab' then
                  if currTab = tree.0 then
                     currTab = 1
                  else
                     currTab = currTab+1
               else
                  if currTab = 1 then
                     currTab = tree.0
                  else
                     currTab = currTab-1
            else
               if findcontextcompletion() = 0 then
                  if mc = 1 then return; else iterate
               else
                  if key = 'tab' then
                     currTab = 1
                  else
                     currTab = tree.0

            newf = filespec('d',file)filespec('p',file)filespec('n',tree.currTab)

            if pos(' ',newf) > 0 then
               newf = '"'stripdoublequotes(newf)'"'
            line = left(line,fileOfs)newf||substr(line,currOfs+1)
            currOfs = fileOfs+length(newf)
            end

         when key = 'match' & line \= '' then
            do prevLine.0
               currLine = currLine-1
               if currLine <= 0 then
                  currLine = prevLine.0

               if compare(prevLine.currLine,line) > currOfs then
                  do
                  xOfs = 0
                  line = prevLine.currLine
                  if mc = 1 then return; else leave
                  end
            end

         when key = 'backmatch' & line \= '' then
            do prevLine.0
               currLine = currLine+1
               if currLine > prevLine.0 then
                  currLine = 1

               if compare(prevLine.currLine,line) > currOfs then
                  do
                  xOfs = 0
                  line = prevLine.currLine
                  if mc = 1 then return; else leave
                  end
            end

         when key = 'cright' & currOfs < len then
            currOfs = currOfs + 1

         when key = 'cleft' & currOfs > 0 then
            currOfs = currOfs - 1

         when key = 'cup' | key = 'cdown' then
            do
            if prevLine.0 = 0 then
               if mc = 1 then return; else iterate

            if key = 'cup' then
               do
               if firstCup then
                  firstCup = 0
               else
                  currLine = currLine - 1
               end
            else
               currLine = currLine + 1

            if currLine <= 0 then
               currLine = prevLine.0

            if currLine > prevLine.0 then
               currLine = 1

            line = prevLine.currLine
            currOfs = length(line)
            xOfs = 0
            end

         when key = 'del' then
            line = delstr(line,currOfs+1,1)

         when key = 'home' then
            currOfs = 0

         when key = 'end' then
            currOfs = len

         when key = 'esc' then
            do
            line = ''
            currOfs = 0
            xOfs = 0
            end

         when key = 'ctrlend' then
            line = left(line,currOfs)

         when key = 'ctrlhome' then
            do
            line = substr(line,currOfs+1)
            currOfs = 0
            end

         when key = 'ctrlleft' & currOfs > 0 then
            currOfs = wordindex(line,words(left(line,currOfs)))-1

         when key = 'ctrlright' then
            do
            currTab = wordindex(line,words(left(line,currOfs+1))+1)-1
            if currTab >= 0 then
               currOfs = currTab
            end

         when key = 'ins' then
            do
            insert = \ insert
            call VioSetCurType word(insertMode.insert,1), word(insertMode.insert,2)
            if mc = 1 then
               return
            else
               iterate
            end

         when abbrev('OSNOWAIT',translate(word(key,1)),3) | translate(word(key,1)) = 'SHELL' then
            call eval subword(key,2)

         when translate(word(key,1)) = 'TEXT' then
            do
            if insert then
               line = insert(subword(key,2),line,currOfs)
            else
               line = overlay(subword(key,2),line,currOfs+1)

            currOfs = currOfs + length(subword(key,2))
            end

         when key = 'expand' & currOfs > 0 then
            do
            xyzzy = findcontexttype()
            xlen = origCol + currOfs - length(strip(xline,'L'))
            what = getFileSpec(left(line,currOfs))
            subl = left(line,currOfs-length(what))
            if substr(line,currOfs,1) = '=' then
               if translate(fcccmd) = 'ALIAS' then do
                  what = reverse(word(reverse(left(line,currOfs-1)),1))
                  if wordpos(what,aliasNames) > 0 then
                     line = insert(aliasStem.what,line,currOfs)
                  end
               else
               if translate(fcccmd) = 'RULE' then do
                  what = reverse(word(reverse(left(line,currOfs-1)),1))
                  if wordpos(what,rulesList) > 0 then
                     line = insert(rules.what,line,currOfs)
                  end
               else
                  line = insert(value(reverse(word(reverse(left(line,currOfs-1)),1)),,'OS2ENVIRONMENT'),line,currOfs)
            else
            if xyzzy = 'c' then do
               what = findcommand('real')
               if what = '' then
                  interpret 'subl = subl||xline;' invalidCmd
               else
                  subl = subl||what
               end
            else
               subl = subl||expand(what)
            line = subl||substr(line,currOfs+1)
            currOfs = length(subl)
            end

         when word(key,1) = 'mark' then
            call mark

         when key = 'dup' then
            do
            what = getFileSpec(left(line, currOfs))
            line = insert(' 'what, line, currOfs)
            currOfs = currOfs + length(what) + 1
            if currTab \= 0 then do
               key = 'tab'
               fileOfs = fileOfs + length(what) + 1
               end
            end

         when translate(word(key,1)) = 'MC' then
            do
            mc = 1
            parse value subword(key,2) with sep 2 seq
            do while seq \= ''
               parse value seq with key (sep) seq
               call dokey
            end /* do */
            mc = 0
            end

         otherwise
            nop
      end

      if key \= 'tab' & key \= 'backtab' then
         currTab = 0

      dif = compare(line,oline)
      if dif \= 0 then
         do
         len = length(line)
         if dif <= xOfs then dif = 1
         call SysCurPos origRow + (origCol + dif - 1) % col, (origCol + dif - 1) // col
         call charout , substr(line,dif,max(len,olen)-dif+1)

         if origRow + (origCol + len) % col >= row then
            origRow = row - (origCol + len) % col - 1
         olen = len
         end

      if markLine = currLine then
         call VioWrtNAttr origRow + (origCol + markOfs) % col, (origCol + markOfs) // col, markLen, 248
      call SysCurPos origRow + (origCol + currOfs) % col, (origCol + currOfs) // col

if mc = 1 then return

   end

   if line <> '' & lastKey <> 'cup' & lastKey <> 'cdown' then do
      o = prevLine.0 + 1
      prevLine.0 = o
      prevLine.o = line
      end
   else
   if cmdQueue = 1 & (lastKey = 'cup' | lastKey = 'cdown') then do
      do i = currLine to prevLine.0 - 1
         j = i + 1
         prevLine.i = prevLine.j
      end /* do */
      call value 'prevLine.'prevLine.0, line
      end

   call SysCurPos origRow + (origCol + len) % col, (origCol + len) // col
   say

   if line \= '' & verify(reverse(line),'^') // 2 = 0 then do
      call charout , secondaryPrompt
      line = left(line,len-1) getLine()
      end

   return line

/*------------------------------------------------------------------
 * get file spec
 *------------------------------------------------------------------*/
getFileSpec:
   fileOfs = length(arg(1))
   do forever
      select
         when fileOfs < 1 then do; fileOfs = 0; leave; end
         when pos(substr(arg(1),fileOfs,1), fileSeparator) > 0 then leave
         when substr(arg(1),fileOfs,1) = '"' & fileOfs > 1 then fileOfs = lastpos('"',arg(1),fileOfs-1)
      otherwise
         nop
      end
      fileOfs = fileOfs - 1
   end
   if left(translate(substr(arg(1),fileOfs+1)),8) = 'FILE:///' then
      fileOfs = fileOfs + 8
   return substr(arg(1),fileOfs+1)

/*------------------------------------------------------------------
 * get key
 *------------------------------------------------------------------*/
getKey:
   call on halt name ignore

   key  = SysGetKey('NOECHO')
   ckey = c2x(key)

   /*---------------------------------------------------------------
    * get second 'key' if needed
    *---------------------------------------------------------------*/
   if ckey = 'E0' | ckey = '00' then
      ckey = '00'c2x(SysGetKey('NOECHO'))

   /*---------------------------------------------------------------
    * look it up
    *---------------------------------------------------------------*/
   ckey = '_'ckey

   if symbol('key.'ckey) = 'LIT' then
      return key
   else
      return key.ckey

/*------------------------------------------------------------------
 * handle break
 *------------------------------------------------------------------*/
ignore:
   return ''

/*====================================================================
 * Interpret Command-line Arguments.
 *====================================================================*/
doarg:
   lineArg = arg(1)

   do while lineArg \= ''
      parse value lineArg with switch lineArg

      select
         when switch = '/O' | switch = '/o' then insertState = 0
         when switch = '/I' | switch = '/i' then insertState = 1
         when wordpos(switch,helpSwitches) > 0 then do
            if value('HELP.COMMAND',,'OS2ENVIRONMENT') \= '' then
               '@call %HELP.COMMAND% CMDSHL' lineArg
            else
               say cmdHelp
            exit
            end
         when switch = '/C' | switch = '/c' then do
            if left(lineArg,1) = '"' & right(lineArg,1) = '"' then
               call eval strip(lineArg, 'b', '"')
            else
               call eval lineArg
            exit
            end
         when switch = '/K' | switch = '/k' then do
            if left(lineArg,1) = '"' & right(lineArg,1) = '"' then
               call eval strip(lineArg, 'b', '"')
            else
               call eval lineArg
            leave
            end
         when switch = '/P' | switch = '/p' then
            parse value lineArg with profileName lineArg
      otherwise
         say SysGetMessage(1003)
         exit 1
      end  /* select */

   end /* do */

   return

/*====================================================================
 * A cmd.exe-like Command Evaluator.
 *====================================================================*/
eval:
   signal on halt
   _LEVEL_ = _LEVEL_ + 1
   eval._LEVEL_.cmdLine = strip(arg(1),'L')
   needcr = 1; eval._LEVEL_.xlen = length(eval._LEVEL_.cmdLine); eval._LEVEL_.xpos = 1

   do while eval._LEVEL_.xpos <= eval._LEVEL_.xlen
      /* parsing command line */
      inStr = 0; inSub = 0; redir = 0; eval._LEVEL_.xcur = eval._LEVEL_.xpos
      do while eval._LEVEL_.xpos <= eval._LEVEL_.xlen
         redir = (ch = '>')
         ch = substr(eval._LEVEL_.cmdLine,eval._LEVEL_.xpos,1); eval._LEVEL_.xpos = eval._LEVEL_.xpos + 1

         if ch = '"' then inStr = inStr && 1
         else
         if \inStr then do
            if ch = '^' then eval._LEVEL_.xpos = eval._LEVEL_.xpos + 1
            else
            if ch = '&' & redir = 0 & inSub = 0 then
               if substr(eval._LEVEL_.cmdLine,eval._LEVEL_.xpos,1) \= '&' then
                  leave
               else
                  eval._LEVEL_.xpos = eval._LEVEL_.xpos + 1
            else
            if ch = '(' then inSub = inSub + 1
            else
            if ch = ')' then inSub = inSub - 1
            end
      end /* do */

      parse value substr(eval._LEVEL_.cmdLine,eval._LEVEL_.xcur,eval._LEVEL_.xpos-eval._LEVEL_.xcur) with cmd args

      if pos('"', cmd) \= 0 then do
         args = cmd args; cmd = getArg(args); args = substr(args, length(cmd)+1)
         end

      if pos('|', cmd) \= 0 then do
         args = cmd args; cmd = left(args, pos('|', args)-1); args = substr(args, length(cmd)+1)
         end

      if inStr = 0 & right(args,1) = '&' & right(args,2) \= '&&' & right(args,2) \= '^&' then
         args = left(args,length(args)-1)

      ucmd = translate(cmd)

      if args = '' & impCD = 1 then do
         curDir = directory()
         if dir(cmd) \= '' then do
            oldDir = curDir
            iterate
            end
         end

      if preEvalCmd \= '' then
         interpret preEvalCmd

      select
         when wordpos(cmd,arg(2)) = 0 & wordpos(cmd,aliasNames) > 0 then do
            call eval substitute(aliasStem.cmd,cmd args), arg(2) cmd
            needcr = 0
            end
         when wordpos(ucmd,shlList) > 0 then
            select
               when ucmd = 'CD' then call cd args
               when ucmd = 'RX' then do
                  signal on syntax name error
                  interpret args
                  needcr = 0
                  end
               when ucmd = 'ALIAS' then call alias args
               when ucmd = 'RULE' then call rule args
               when ucmd = 'KEYS' then
                  if translate(args) = 'LIST' then
                     do key = 1 to prevLine.0
                        say right(key,5)':' prevLine.key
                     end /* do */
                  else
                     ''cmd args
               when abbrev('DEFINE',ucmd,3) then do
                  parse value args with key rest
                  if wordpos(args,helpSwitches) > 0 then
                     if value('HELP.COMMAND',,'OS2ENVIRONMENT') \= '' then
                        '@call %HELP.COMMAND% DEFINE' args
                     else
                        say defHelp
                  else do
                     needcr = 0
                     if length(key) > 1 then
                        if symbol(translate(key,'_','-')) = 'VAR' then
                           key = value(translate(key,'_','-'))
                        else do
                           if interactive = 0 then
                              call charout ,'Line' profileline': '
                           say SysGetMessage(1003)
                           iterate
                           end
                     if rest \= '' then
                        call value 'key._'c2x(key), rest
                     else
                        interpret 'drop key._'c2x(key)
                     end
                  end
               when ucmd = 'QUIT' then
                  if wordpos(args,helpSwitches) > 0 then
                     if value('HELP.COMMAND',,'OS2ENVIRONMENT') \= '' then
                        '@call %HELP.COMMAND% QUIT' args
                     else
                        say quitHelp
                  else
                     return 0
            otherwise
            end
         when left(ucmd,1) = '(' then
            double(expand(cmd args))
         when autoPathExt & wordpos(ucmd, cnvList) > 0 then
            cmd double(expandAll(args))
         when wordpos(ucmd, cmdList) > 0 then
            cmd double(expand(args))
      otherwise
         if args = '' & impCD = 2 then do
            xline = ucmd
            xyzzy = findcommand('REAL')
            if xyzzy \= '' then
               if stream(xyzzy,'c','query exists') = '' | (length(xyzzy)=3 & right(xyzzy,2) = ':\' & datatype(left(xyzzy,1),'M')) then do
                  curDir = directory()
                  if dir(cmd) \= '' then do
                     oldDir = curDir
                     iterate
                     end
                  end
            'call' double(double(expand(cmd args)))
            end
         else
            'call' double(double(expand(cmd args)))
      end /* select */

      if postEvalCmd \= '' then
         interpret postEvalCmd
   end

   if arg(1) \= '' & interactive & needcr then say

   _LEVEL_ = _LEVEL_ - 1

   return 1

error:
   say 'REX'right(rc,4,'0')':' errortext(rc)nl
   if condition('I') = 'SIGNAL' then
      signal loop
   else
      return

double:
   procedure
   expr = arg(1); doubled = ''
   do while pos('%',expr) > 0
      doubled = doubled||left(expr,pos('%',expr))||'%'
      expr = substr(expr,pos('%',expr)+1)
   end /* do */
   doubled = doubled||expr
   return doubled

substitute:
   procedure
   symb = arg(1); actual = arg(2); xpos = 1; xlen = length(symb); r = ''; inSubst = 0
   do while xpos <= xlen
      ch = substr(symb,xpos,1); xpos = xpos + 1
      if ch = '^' then do
         r = r||substr(symb,xpos,1)
         xpos = xpos + 1
         end
      else
      if ch = '%' & inSubst = 0 then inSubst=1
      else
      if inSubst = 1 then do
         inSubst = 0
         if pos(ch,0123456789) > 0 then
            if substr(symb,xpos,1) = '*' then do
               r = r||subword(actual,ch+1)
               xpos = xpos+1
               end
            else
               r = r||word(actual,ch+1)
         else
         if ch = '*' then
            r = r||subword(actual,2)
         else
            r = r'%'ch
         end
      else
         r = r||ch
   end /* do */
   if inSubst = 1 then
      r = r'%'
   return r

expand:
   procedure
   args = arg(1); xpos = pos('%',args)+1
   if xpos > 1 then do
      ypos = pos('%',args,xpos)
      if ypos > 0 then do
         envi = substr(args,xpos,ypos-xpos)
         valu = value(envi,,'OS2ENVIRONMENT')
         if valu = '' then
            args = left(args,xpos-1)||envi||expand(substr(args,ypos))
         else
            args = left(args,xpos-2)||valu||expand(substr(args,ypos+1))
         end
      end
   return args

expandAll:
   procedure expose rc pathExt
   expanded = ''; args = expand(arg(1))
   do while args \= ''
      elem = getArg(args)
      sep = copies(' ',verify(args,' ')-1)
      args = substr(args,length(elem)+length(sep)+1)
      if left(elem,1) = '/' then
        expanded = expanded || sep || elem
      else
        expanded = expanded || sep || canonize(elem)
   end /* do*/
   return expanded

dir:
   procedure expose rc pathExt
   rc = 0
   args = stripdoublequotes(expand(arg(1)))
   if chdir(expandpathext(args)) = '' then do
      if canPerformCDPATH(args) then do
         cdpath = value('CDPATH',,'OS2ENVIRONMENT')
         do while cdpath \= ''
            parse value cdpath with path ';' cdpath
            if pos(right(path,1),'\/') = 0 then
               path = path'\'
            if chdir(expandpathext(path||args)) \= '' then do
               return directory()
               end
         end /* do */
         end
      rc = 1
      return ''
      end
   return directory()

chdir:
   procedure
   args = arg(1)
   if pos(right(args,1),'\/') \= 0 then
      if length(args) > 1 & left(right(args,2),1) \= ':' then
         args = left(args,length(args)-1)
   return directory(args)

canPerformCDPATH:
   procedure
   args = arg(1)
   select
     when pos(left(args,1),'\/') \= 0 then
        return 0
     when strip(args,'l','.') = ''  then
        return 0
     when pos(left(strip(args,'l','.'),1),'\/') \= 0 then
        return 0
     when pos(':', args) \= 0 then
        return 0
   otherwise
   end /* select */

   return 1

canonize:
   return expandpathext(stripdoublequotes(translate(expand(arg(1)), '\', '/')))

stripdoublequotes:
   return translate(space(translate(arg(1), ' "', '" '), 0), ' ', '"')

expandpathext:
   procedure expose rc pathExt
   rc = 0
   args = arg(1)
   if pathExt then
      select
         when args = '~' then
           args = getHome()
         when left(args, 2) = '~/' | left(args, 2) = '~\' then
           args = getHome()expandpathext(substr(args,3))
         when pos('\\', args) \= 0 then
           args = expandpathext(left(args, pos('\\', args))substr(args,pos('\\', args)+2))
         when pos('//', args) \= 0 then
           args = expandpathext(left(args, pos('//', args))substr(args,pos('//', args)+2))
         when pos('/\', args) \= 0 then
           args = expandpathext(left(args, pos('/\', args))substr(args,pos('/\', args)+2))
         when pos('\/', args) \= 0 then
           args = expandpathext(left(args, pos('\/', args))substr(args,pos('\/', args)+2))
         when left(args, 3) = '...' then
           args = expandpathext('..\'substr(args, 2))
         when pos('\...', args) \= 0 then
           args = expandpathext(left(args, pos('\...', args)+1)'.\'substr(args, pos('\...', args)+2))
         when pos('/...', args) \= 0 then
           args = expandpathext(left(args, pos('/...', args)+1)'./'substr(args, pos('/...', args)+2))
      otherwise
      end  /* select */
   return args

cd:
   parse value arg(1) with args

   curDir = directory()
   select
      when args = '-' then do
         call directory oldDir
         oldDir = curDir
         end
      when wordpos(args,helpSwitches) > 0 then do
         if value('HELP.COMMAND',,'OS2ENVIRONMENT') \= '' then
            '@call %HELP.COMMAND% CD' args
         else do
            '@CD /?'
            say cdHelp
            end
         end
      when args = '' | (length(strip(args)) = 2 & right(args,1) = ':') then do
         say directory(args)
         call directory curDir
         end
   otherwise
      arg1 = getArg(args)
      if args = arg1 then
        if dir(args) = '' then do
           say SysGetMessage(0003)
           needcr = 0
           end
        else
           oldDir = curDir
      else do
         arg2 = strip(substr(args, length(arg1)+1))
         arg1 = stripdoublequotes(translate(arg1))
         if pos(arg1,translate(curDir)) = 0 then do
            say SysGetMessage(1171,,arg1)
            rc = 1
            needcr = 0
            end
         else
         if dir(left(curDir,pos(arg1,translate(curDir))-1)arg2||substr(curDir,pos(translate(arg1),translate(curDir))+length(arg1))) = '' then do
            say SysGetMessage(0003)
            needcr = 0
            end
         else
            oldDir = curDir
       end
   end  /* select */

   return

alias:
   procedure expose aliasHelp aliasNames aliasStem. helpSwitches

   parse value arg(1) with subcmd '>' file

   select
      when translate(subcmd) = 'LIST' then
         if file \= '' then do
            do alias = 1 to words(aliasNames)
               name = word(aliasNames,alias)
               call lineout file,name'='aliasStem.name
            end /* do */
            call stream file,'c','close'
            end
         else
            do alias = 1 to words(aliasNames)
               name = word(aliasNames,alias)
               say right(alias,4) left(name,10) '=' aliasStem.name
            end
      when left(subcmd,1) = '@' then do
         file = substr(subcmd,2)
         do while lines(file) > 0
            call addalias linein(file)
         end /* do */
         call stream file,'c','close'
         end
      when wordpos(subcmd,helpSwitches) > 0 then do
         if value('HELP.COMMAND',,'OS2ENVIRONMENT') \= '' then
            '@call %HELP.COMMAND% ALIAS' subcmd
         else
            say aliasHelp
         end
   otherwise
      call addalias arg(1)
   end /* select */
   return

addalias:
   parse value arg(1) with alias '=' cmd
   alias = strip(alias)
   if cmd \= '' then do
      if wordpos(alias,aliasNames) = 0 then
         aliasNames = aliasNames alias
      aliasStem.alias = cmd
      end
   else do
      parse value aliasNames with first (alias) last
      aliasNames = first last
      end
   return

rule:
   procedure expose ruleHelp rulesList rules. helpSwitches

   parse value arg(1) with subcmd '>' file

   select
      when translate(subcmd) = 'LIST' then
         if file \= '' then do
            do rule = 1 to words(rulesList)
               name = word(rulesList,rule)
               call lineout file,name'='rules.name
            end /* do */
            call stream file,'c','close'
            end
         else
            do rule = 1 to words(rulesList)
               name = word(rulesList,rule)
               say right(rule,4) left(name,10) '=' rules.name
            end
      when left(subcmd,1) = '@' then do
         file = substr(subcmd,2)
         do while lines(file) > 0
            call addrule linein(file)
         end /* do */
         call stream file,'c','close'
         end
      when wordpos(subcmd,helpSwitches) > 0 then do
         if value('HELP.COMMAND',,'OS2ENVIRONMENT') \= '' then
            '@call %HELP.COMMAND% RULE' subcmd
         else
            say ruleHelp
         end
   otherwise
      call addrule arg(1)
   end /* select */
   return

addrule:
   parse value arg(1) with rule '=' cmd
   rule = strip(rule)
   if cmd \= '' then do
      if wordpos(rule,rulesList) = 0 then
         rulesList = rulesList rule
      rules.rule = cmd
      end
   else do
      parse value rulesList with first (rule) last
      rulesList = first last
      end
   return

mark:
   select
      when word(key,2) = 'word' then
         do
         if markLine = currLine then
            call VioWrtNAttr origRow + (origCol + markOfs) % col, (origCol + markOfs) // col, markLen, 7
         markLen = 0
         markLine= currLine
         select
            when line = '' then
               return
            when currOfs = 0 then
               markOfs = wordindex(line,1)-1
            when left(line,currOfs) = '' then
               markOfs = wordindex(line,1)-1
            when substr(line,currOfs,1) = ' ' then
               markOfs = currOfs+wordindex(substr(line,currOfs),1)-2
            otherwise
               markOfs = wordindex(line,words(left(line,currOfs)))-1
         end  /* select */
         markLen = length(word(substr(line,markOfs+1),1))
         call VioWrtNAttr origRow + (origCol + markOfs) % col, (origCol + markOfs) // col, markLen, 248
         end
      when word(key,2) = 'char' then
         do
         if markLine \= currLine | (markLen = 0 & markOfs = 0) then
            do
            markOfs = currOfs
            markLen = 1
            markLine= currLine
            end
         else
            do
            call VioWrtNAttr origRow + (origCol + markOfs) % col, (origCol + markOfs) // col, markLen, 7
            if markOfs > currOfs then
               do
               markLen = markLen+markOfs-currOfs+1
               markOfs = currOfs
               end
            else
               markLen = currOfs-markOfs+1
            end
         call VioWrtNAttr origRow + (origCol + markOfs) % col, (origCol + markOfs) // col, markLen, 248
         end
      when word(key,2) = 'clear' then
         do
         if markLine = currLine then
            call VioWrtNAttr origRow + (origCol + markOfs) % col, (origCol + markOfs) // col, markLen, 7
         markLen = 0
         markOfs = 0
         end
      when word(key,2) = 'copy' then
         do
         if markLine = currLine then
            do
            call VioWrtNAttr origRow + (origCol + markOfs) % col, (origCol + markOfs) // col, markLen, 7
            line = left(line,currOfs)substr(line,markOfs+1,markLen)substr(line,currOfs+1)
            end
         else
            line = left(line,currOfs)substr(prevline.markLine,markOfs+1,markLen)substr(line,currOfs+1)
         markOfs = currOfs
         markLine= currLine
         currOfs = currOfs+markLen
         end
      when word(key,2) = 'delete' then
         if markLine = currLine then
            do
            call VioWrtNAttr origRow + (origCol + markOfs) % col, (origCol + markOfs) // col, markLen, 7
            line = left(line,markOfs)substr(line,markOfs+markLen+1)
            if currOfs > markLen + markOfs then currOfs = currOfs - markLen
            else
            if currOfs > markOfs then currOfs = markOfs
            markLen = 0
            end
         else
            markLen = 0
      when word(key,2) = 'move' then
         do
         if markLine = currLine then
            do
            if currOfs > markLen + markOfs then currOfs = currOfs - markLen
            else
            if currOfs > markOfs then return
            line = insert(substr(line,markOfs+1,markLen),left(line,markOfs)substr(line,markOfs+markLen+1),currOfs)
            end
         else
            do
            line = left(line,currOfs)substr(prevline.markLine,markOfs+1,markLen)substr(line,currOfs+1)
            markLine= currLine
            end
         markOfs = currOfs
         end
      otherwise
         nop
   end /* select */
   return

getHome:
   procedure
   home = strip(value('HOME',,'OS2ENVIRONMENT'))
   if home = '' then
      home = substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ', DosQuerySysInfo(5), 1)':'
   return strip(strip(stripdoublequotes(home),'T','/'),'T','\')'\'

getArg:
   procedure
   args = arg(1)
   if pos('"', args) \= 0 then do
      inStr = 0; arg = ''
      do while \ (\inStr & left(args, 1) = ' ') & args \= ''
         if left(args, 1) = '"' then inStr = inStr && 1
         arg = arg||left(args, 1)
         args = substr(args, 2)
      end /* do */
      return arg
      end
   else
     return word(args, 1)

findcompletion:
   file = getFileSpec(left(line,currOfs))
   if pos('*',file) = 0 then
      file = file'*'
   call SysFileTree canonize(file),'tree',arg(1)'O','**-*-'
   if tree.0 = 0 then
      return 0
   if tree.0 = 1 & tree.1'*' = canonize(file) then
      return 0
   return 1

findmulticompletion:
   fmcarg = translate(arg(1),'   ','(,)')
   file = getFileSpec(left(line,currOfs))
   fmctree = 1
   do fmci = 1 to words(fmcarg)
      call SysFileTree canonize(file||word(fmcarg,fmci)),'multi','FO','**-*-'
      do fmcj = 1 to multi.0
         tree.fmctree = multi.fmcj
         fmctree = fmctree+1
      end /* do */
   end /* do */
   if pos('*',file) = 0 then
      call SysFileTree canonize(file'*'),'multi','DO','**-*-'
   else
      call SysFileTree canonize(file),'multi','DO','**-*-'
   do fmcj = 1 to multi.0
      tree.fmctree = multi.fmcj
      fmctree = fmctree+1
   end /* do */
   fmctree = fmctree-1
   tree.0 = fmctree
   return fmctree \= 0

findcommand:
   if xline = '' | xline = '"' then
      return xline
   fccmd = canonize(xline)
   command = ''
   if arg(1) \= '' then /* return the real command */
      do
      if impCD = 1 then do
         if length(fccmd) > 1 & right(fccmd,1) = '\' then
            zline = left(fccmd,length(fccmd)-1)
         else
            zline = fccmd
         command = SysSearchPath('CDPATH',zline)
         if command == '' then
            if stream(zline,'c','query datetime') \= '' then
               command = zline
         end
      if command = '' then if wordpos(fccmd,aliasNames) > 0 then command = fccmd
      if command = '' then if wordpos(translate(fccmd),cmdList shlList) > 0 then command = fccmd
      end
   else                 /* return a possible command -- fast */
      do
      if wordpos(fccmd,aliasNames) > 0 then command = fccmd
      if command = '' then if wordpos(translate(fccmd),cmdList shlList) > 0 then command = fccmd
      if command = '' then if impCD \= 0 then
         do
         if length(fccmd) > 1 & right(fccmd,1) = '\' then
            zline = left(fccmd,length(fccmd)-1)
         else
            zline = fccmd
         command = SysSearchPath('CDPATH',zline)
         if command = '' then
            if stream(zline,'c','query datetime') \= '' then
               command = zline
         end
      end
   if command = '' then
      if left(fccmd,1) = '\' | substr(fccmd,2,1) = ':' then do
         if length(fccmd) = 2 & right(fccmd,1) = ':' then
            if pos(translate(left(fccmd,1)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ') > 0 then
               command = fccmd
         if command = '' then
            command = stream(fccmd,'c','query exist')
         do ext = 1 to words(extList) while command = ''
            command = stream(fccmd'.'word(extList,ext),'c','query exist')
         end /* do */
         end
      else do
         command = SysSearchPath('PATH',fccmd)
         if command \= '' & impCD = 2 then
            command = stream(command,'c','query exists')
         do ext = 1 to words(extList) while command = ''
            command = SysSearchPath('PATH',fccmd'.'word(extList,ext))
         end /* do */
         end
   if command = '' & arg(1) \= '' & impCD = 2 then do
      if length(fccmd) > 1 & right(fccmd,1) = '\' then
         zline = left(fccmd,length(fccmd)-1)
      else
         zline = fccmd
      command = SysSearchPath('CDPATH',zline)
      if command = '' then
         if stream(zline,'c','query datetime') \= '' then
            command = zline
      end
   if pos(' ', command) = 0 then
      return command
   else
      return '"'command'"'

findenvcompletion:
   file = ''
   fecenv = DosGetEnv()
   fecvar = stripdoublequotes(translate(getFileSpec(left(line,currOfs))))
   feci = 0
   do while length(fecenv) > 1
      parse var fecenv fecname '=' fecvalue '0'x fecenv
      if abbrev(fecname, fecvar) then do
         feci = feci+1
         tree.feci = fecname
      end
   end /* do */
   tree.0 = feci
   if feci = 0 then
     return 0
   return 1

findcurrentcommand:
   procedure expose xline
   xOfs = 0; xline = translate(arg(1),'  ','()'); xlen = lastpos('&',xline)
   if lastpos('|',xline) > xlen then xlen = lastpos('|',xline)
   if xlen > 0 then
      if verify(reverse(substr(xline,1,xlen-1)),'^') // 2 = 1 then
         if left(strip(reverse(substr(xline,1,xlen-1)),'L'),1) = '>' then
            xline = ''
         else
            xline = substr(xline,xlen+1)
      else
         xline = ''
   xline = strip(xline, 'L')

   /*
    * les divers cas possibles :
    *
    * - pas d'espaces et un guillemet -> #2
    * - pas d'espaces et pas de guillemets -> #1
    * - un espace et pas de guillemets -> ignore
    * - un espace et un guillemet -> ignore si espace avant guillemet, #2 sinon
    */
   if xline \= '' then
      do
      spos = pos(' ', xline)
      gpos = pos('"', xline)
      if spos = gpos then
         return xline
      else
      if gpos = 0 | (spos < gpos) then
         return word(xline, 1)
      else
         do
         /* command quoted */
         curCmd = xline; inStr = 0; xline = ''
         do while \ (\inStr & left(curCmd, 1) = ' ') & curCmd \= ''
            if left(curCmd, 1) = '"' then inStr = inStr && 1
            xline = xline||left(curCmd, 1)
            curCmd = substr(curCmd, 2)
         end /* do */
         if curCmd = '' & \inStr then
            return xline
         end
      end
   return ''

findcontextcompletion:
   fcc = findcontexttype()
   if fcc = 'd' then
      return findcompletion('D')
   else
   if fcc = 'f' | fcc = 'c' | fcc = 'a' then
      return findcompletion()
   else
   if fcc = 'e' then
      return findenvcompletion()
   if left(fcc,1) = '(' then
      return findmulticompletion(fcc)
   else
      return 0

findcontexttype:
   if arg() = 0 then
      context = left(line, currOfs)
   else
      context = arg(1)
   fcccmd = findcurrentcommand(context)
   if xline == fcccmd then
      return 'c'
   if wordpos(fcccmd, rulesList) > 0 | symbol('rules.'fcccmd) = 'VAR' then do
      /* use specified rule */
      if wordpos(fcccmd, rulesList) > 0 then
         fccrules = rules.fcccmd
      else
         fccrules = value('rules.'fcccmd)
      do while fccrules \= ''
         parse var fccrules fccrule '|' fccrules
         fccargs = strip(substr(right(context, length(xline)), length(fcccmd)+1), 'L')
         do while fccrule \== ''
            if left(fccrule, 1) = '%' then do
               fccch2 = substr(fccrule,2,1)
               if length(fccrule) = 2 then
                  fccch3 = ''
               else
                  fccch3 = substr(fccrule,3,1)
               select
                  when pos(fccch2, 'fd') > 0 then do
                     fcci = verify(fccargs, fileSeparator||fccch3, 'M')
                     if fcci = 0 then
                        return fccch2
                     fccargs = substr(fccargs, fcci)
                     end
                 when fccch2 = '(' then do
                     parse var fccrule '%(' spec ')' . +1 fccch3 +1 .
                     fcci = verify(fccargs, fileSeparator||fccch3, 'M')
                     if fcci = 0 then
                        return '('spec')'
                     fccargs = substr(fccargs, fcci)
                     if fccch3 \= '*' then
                        fccrule = substr(fccrule,pos(')',fccrule)-1)
                     end
                  when fccch2 = 'c' then do
                     xline = fccargs
                     fcci = verify(fccargs, fileSeparator||fccch3, 'M')
                     if fcci = 0 then
                        return fccch2
                     fccargs = substr(fccargs, fcci)
                     end
                  when fccch2 = 'e' then do
                     fcci = verify(fccargs, '<>=|'fccch3, 'M')
                     if fcci = 0 then
                        return fccch2
                     fccargs = substr(fccargs, fcci)
                     end
                  when fccch2 = 'o' then do
                     do while left(fccargs, 1) = '/'
                        fcci = pos(' ', fccargs)
                        if fcci = 0 then
                           return ''
                        else
                           fccargs = strip(substr(fccargs, fcci), 'L')
                     end /* do */
                     fccargs = ' 'fccargs
                     end
                  when fccch2 = 'u' then do
                     do while left(fccargs, 1) = '-'
                        fcci = pos(' ', fccargs)
                        if fcci = 0 then
                           return ''
                        else
                           fccargs = strip(substr(fccargs, fcci), 'L')
                     end /* do */
                     fccargs = ' 'fccargs
                     end
                  when fccch2 = '*' then do
                     if length(fccrule) = 2 then
                        return 'a'
                     fcci = verify(fccargs, fccch3, 'M')
                     if fcci = 0 then
                        return 'a'
                     fccargs = substr(fccargs, fcci)
                     end
                  when fccch2 = 'l' then
                     if length(fccargs) > 0 then
                        fccargs = substr(fccargs, 2)
                  when fccch2 = 'x' then
                     return findcontexttype(fccargs)
                  when fccargs == '' then
                     return ''
                  when fccch2 = '%' then do
                     if left(fccargs, 1) \= '%' then
                        leave
                     fccargs = substr(fccargs, 2)
                     end
               otherwise
               end  /* select */
               if fccch3 = '*' then do
                  fccargs = substr(fccargs, 2)
                  iterate
                  end
               fccrule = substr(fccrule, 2)
               end
            else
            if fccargs == '' then
               return ''
            else
            if left(fccrule, 1) = ' ' & left(fccargs, 1) = ' ' then
               fccargs = strip(fccargs, 'L')
            else
            if translate(left(fccrule, 1)) \= translate(left(fccargs,1)) then
               leave
            else
            if translate(left(fccrule, 1)) = translate(left(fccargs, 1)) then
               fccargs = substr(fccargs, 2)
            fccrule = substr(fccrule, 2)
         end /* do */
         if fccargs = '' then
            return ''
      end /* do */
      return 0
   end
   else
     return 'a'

halt:
  call charout ,SysGetMessage(1048)
  call directory orgdir
  signal loop
