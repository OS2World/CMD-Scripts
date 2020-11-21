/* fl.cmd - A FILELIST clone                                 20040825 */


/* Work in progress :
 *
 * new options: (Append and (File;
 * broken option: (Wide;
 *
 * file.level._ATTR[.n]
 *            _COL               cursor pos on screen (0 = first col)
 *            _CPREFIXATTR
 *            _CHIGHLIGHTATTR
 *            _CURDIR
 *            _CURRENT           cursor pos on screen (0 = first line)
 *            _CURRENTATTR
 *            _HIGHLIGHTATTR
 *            _HOFFSET
 *            _MAXWIDTH
 *            _NCOL              number of columns in wide mode
 *            _OLDCOL
 *            _OLDCURRENT
 *            _PCMD.n            .i = prefix command (if any) for iest line
 *            _PREFIX.n          .i = prefix background for iest line
 *            _PREFIXATTR
 *            _PREFIXCMDATTR
 *            _PREFIXNUL         0 if prefix not nulls, 1 otherwise
 *            _PREFIXNUM         0 if prefix not numbered, 1 otherwise
 *            _PREFIXPOS         'LEFT' or 'RIGHT'
 *            _PREFIXWIDTH       prefix area width, 0 if prefix off
 *            _PREFIXGAP         prefix area gap
 *            _SHADOW.n          .0 = number of shadow lines, .i = n for iest line
 *            _SHADOWATTR
 *            _TOP               index in _VISIBLE of the first displayed line
 *            _TYPE              'Archive', 'File', 'Help', or 'List'
 *            _VISIBLE.n         .0 = number of visible lines, .i = n for iest line
 *                               (can be _SHADOW.i if denoting shadow)
 *            _WIDE
 *            n                  .1 = top line, .(.0+1) = bottom line
 *
 * level                         current buffer
 * item                          current index in _VISIBLE
 * realitem                      current index in base
 */
signal on novalue
'@echo off'; trace off

call main_init arg(1)
bg = VioReadCellStr(0,0)
call adjustwindows
/*
call execute 'CMDLINE', 'BOTTOM'
call execute 'CMDLINE', 'SET NUM ON'
call time 'R'
do 100
  call execute 'CMDLINE', 'U 1'
end /* do */
say time('E')
exit
  */
/* main loop */
do until quit
  if file.level._CURRENT \= commandLine then do
    item = file.level._TOP + file.level._CURRENT - w1_x
    if item > file.level._VISIBLE.0 then do
      item = file.level._VISIBLE.0
      if item < file.level._TOP then do
        file.level._TOP = max(1, item - file.level._CURRENT + 1)
        call show
      end
      file.level._CURRENT = item - file.level._TOP + w1_x
    end
    else
    if item < 2 then do
      item = 2
      file.level._CURRENT = w1_x + 2 - file.level._TOP
    end
    if file.level._WIDE then do
      if file.level._COL = w1_y then
        file.level._COL = w1_y+fwidth
      else
      if file.level._COL = 1 then
        file.level._COL = w1_y+1
      item = min((item-2)*file.level._NCOL + 2 + (file.level._COL-7) % file.level._MAXWIDTH, (item-1)*file.level._NCOL+2-1)
      if item-1 > (1 * ((file.level._VISIBLE.0-1) // file.level._NCOL \= 0) + ((file.level._VISIBLE.0-1) % file.level._NCOL)) * file.level._NCOL then do
        item = file.level._VISIBLE.0
        file.level._CURRENT = w1_x + 1 + (1 * ((file.level._VISIBLE.0-1) // file.level._NCOL \= 0)) + (item - file.level._TOP*file.level._NCOL) % file.level._NCOL
        item = file.level._TOP + file.level._CURRENT - w1_x
        item = min((item-2)*file.level._NCOL + 2 + (file.level._COL-7) % file.level._MAXWIDTH, (item-1)*file.level._NCOL+2-1)
      end
      if item > file.level._VISIBLE.0 then
        item = file.level._VISIBLE.0
    end
  end
  else do
    if redrawCL then do
      call VioWrtCharStr w2_x, w2_y, left(command_line, width-6)
      redrawCL = 0
    end
    item = 2 + (file.level._TOP + currentLine - 3) * file.level._NCOL
    if file.level._COL = 1 then
      file.level._COL = 7
    else
    if file.level._COL = 6 then
      file.level._COL = width
  end
  if olditem \= item & datatype(file.level._VISIBLE.item) = 'NUM' then do
    call VioWrtCharStr 0, itemnumber, right(file.level._VISIBLE.item-1,4)
    olditem = item
  end
  call SysCurPos file.level._CURRENT, file.level._COL-1
  key = inkey()
  if symbol('file.'level'._VISIBLE.'item) = 'VAR' then
    realitem = file.level._VISIBLE.item
  else
    drop realitem
  select
    when symbol('keys._'c2x(key)) = 'VAR' then
      call execute 'CMDKEY', value('keys._'c2x(key)), realitem
    when key = CURU then
      if file.level._CURRENT = commandLine then
        if cmdarrows = 'RETRIEVE' then
          call execute 'CMDKEY', '?'
        else
          file.level._CURRENT = w1_x + height - 1
      else
      if file.level._CURRENT = w1_x | file.level._TOP + file.level._CURRENT - w1_x <= 2 then do
        file.level._CURRENT = commandLine
        file.level._COL = 7
      end
      else
        file.level._CURRENT = file.level._CURRENT - 1
    when key = CURD then
      if file.level._CURRENT = commandLine then
        if cmdarrows = 'RETRIEVE' then
          call execute 'CMDKEY', '?+'
        else
          file.level._CURRENT = w1_x
      else
      if file.level._CURRENT = w1_x + height - 1 |,
         (\ file.level._WIDE & file.level._TOP + file.level._CURRENT - w1_x >= file.level._VISIBLE.0) |,
         (file.level._WIDE & (file.level._TOP + file.level._CURRENT - w1_x) * file.level._NCOL > (1 * ((file.level._VISIBLE.0-1) // file.level._NCOL \= 0) + ((file.level._VISIBLE.0-1) % file.level._NCOL)) * file.level._NCOL) then do
        file.level._CURRENT = commandLine
        file.level._COL = 7
      end
      else
        file.level._CURRENT = file.level._CURRENT + 1
    when key = CURR then
      file.level._COL = 1 + file.level._COL // width
    when key = CURL then
      file.level._COL = 1 + (width+file.level._COL-2) // width
    when key = ENTER then
      if file.level._CURRENT = commandLine then do
        if command_line = '' then iterate
        command.cmdnum = command_line
        cmdpos = cmdnum
        cmdnum = cmdnum + 1
        command_line = ''
        call execute 'CMDLINE', command.cmdpos, realitem
        parse value '1 7' with redrawCL file.level._COL
        if showlevel \= level then do
          level = showlevel
          call redraw
        end
      end
      else
        call execute 'CMDKEY', 'SOS DOPREFIX'
    when length(key) = 1 then
      call execute 'CMDKEY', 'TEXT 'key
  otherwise
  end /* select */
end /* do */

call SysCurPos row, col
call VioWrtCellStr 0, 0, bg
exit

/* redraw current line */
redrawline:
  l = length(file.level._PCMD.realitem)
  if l < w1_y then
    if file.level._CURRENT = currentLine + w1_x - 1 then
      call VioWrtCharStrAttr file.level._CURRENT, w3_y, file.level._PREFIX.realitem ,,file.level._CPREFIXATTR
    else
      call VioWrtCharStrAttr file.level._CURRENT, w3_y, file.level._PREFIX.realitem ,,file.level._PREFIXATTR
  else
  if l < width then
    if file.level._CURRENT = currentLine + w1_x - 1 then
      call VioWrtCharStrAttr file.level._CURRENT, l, substr(file.level.realitem, file.level._HOFFSET+l-w1_y,1) ,,file.level._CURRENTATTR
    else
      call VioWrtCharStrAttr file.level._CURRENT, l, substr(file.level.realitem, file.level._HOFFSET+l-w1_y,1) ,,file.level._ATTR.realitem
  call VioWrtCharStrAttr file.level._CURRENT, 0, file.level._PCMD.realitem ,,file.level._PREFIXCMDATTR
  return

/* redraw current screen */
drawall:
  call redraw
  call VioScrollUp w2_x, w2_y, w2_x, width-1,255,, attr._CMDATTR
  do i = 1 to 12
    call w_put w4, 1, (i-1)*8 + 1, i//10, ,file.level._ATTR
    call w_put w4, 1, (i-1)*8 + 2, keyname.i, 7, attr._MSGATTR
  end
  return

redraw:
  fmode = left(filespec('D',file.level._CURDIR),1)
  fpath = filespec('P',file.level._CURDIR)
  if symbol('file.'level'._VISIBLE.'item) = 'VAR' then
    call VioWrtCharStrAttr w0_x, w0_y, left(left(file.level._CURDIR,width-23)||,
         right(pp(word(SysDriveInfo(fmode),2)),7)' disk',width-11)||right(file.level._VISIBLE.item-1,4)' of'right(file.level.0-1,4), ,attr._MSGATTR
  else
    call VioWrtCharStrAttr w0_x, w0_y, left(left(file.level._CURDIR,width-23)||,
         right(pp(word(SysDriveInfo(fmode),2)),7)' disk',width-11)||right(0,4)' of'right(file.level.0-1,4), ,attr._MSGATTR
  call show
  call VioWrtCharStrAttr w2_x, 0, overlay('['wordpos(level,allLevels)']','====> '), ,attr._ARROWATTR
  return

/* prettyprint a number -- arg(1) is the number to format */
pp: procedure
  val = arg(1)
  if \ datatype(val, 'N') then
    return val
  val = val % 1024; mod = 'K'
  if length(val) <= 6 then
    return val||mod
  val = val % 1024; mod = 'M'
  if length(val) <= 6 then
    return val||mod
  val = val % 1024; mod = 'G'
  if length(val) <= 6 then
    return val||mod
  val = val % 1024; mod = 'T'
  return val||mod

/* scroll file area one line up */
scrollu:
  iiiii = value('file.'level'._VISIBLE.'file.level._TOP+currentLine-2)
  if file.level._PREFIXWIDTH \= 0 then do
    call VioScrollUp w3_x, w3_y, currentLine+w3_x-2, w3_y+(file.level._PREFIXWIDTH-1), 1, ,file.level._PREFIXATTR
    call VioWrtCharStr currentLine+w3_x-2, w3_y, file.level._PREFIX.iiiii
  end
  call VioScrollUp w1_x, w1_y, currentLine+w1_x-2, w1_y+fwidth-1, 1, ,file.level._ATTR
  call VioWrtCharStrAttr currentLine+w1_x-2, w1_y, substr(file.level.iiiii, file.level._HOFFSET, fwidth), ,file.level._ATTR.iiiii
  if (symbol('file.'level'._PCMD.'iiiii) = 'VAR') then
    call VioWrtCharStrAttr currentLine+w1_x-2, 0, file.level._PCMD.iiiii ,,file.level._PREFIXCMDATTR
  iiiii = value('file.'level'._VISIBLE.'file.level._TOP+currentLine-1)
  if file.level._PREFIXWIDTH \= 0 then
    call VioWrtCharStrAttr currentLine+w3_x-1, w3_y, file.level._PREFIX.iiiii,,file.level._CPREFIXATTR
  if file.level._ATTR.iiiii = file.level._HIGHLIGHTATTR then
    call VioWrtCharStrAttr currentLine+w1_x-1, w1_y, substr(file.level.iiiii, file.level._HOFFSET, fwidth) ,,file.level._CHIGHLIGHTATTR
  else
    call VioWrtCharStrAttr currentLine+w1_x-1, w1_y, substr(file.level.iiiii, file.level._HOFFSET, fwidth) ,,file.level._CURRENTATTR
  if (symbol('file.'level'._PCMD.'iiiii) = 'VAR') then
    call VioWrtCharStrAttr currentLine+w1_x-1, 0, file.level._PCMD.iiiii ,,file.level._PREFIXCMDATTR
  if file.level._PREFIXWIDTH \= 0 then
    call VioScrollUp currentLine+w3_x, w3_y, height+w3_x-1, w3_y+(file.level._PREFIXWIDTH-1), 1, ,file.level._PREFIXATTR
  call VioScrollUp currentLine+w1_x, w1_y, height+w1_x-1, w1_y+fwidth-1, 1, ,file.level._ATTR
  if symbol('file.'level'._VISIBLE.'file.level._TOP+height-1) = 'VAR' then do
    iiiii = value('file.'level'._VISIBLE.'file.level._TOP+height-1)
    if file.level._PREFIXWIDTH \= 0 then
      call VioWrtCharStrAttr height+w3_x-1, w3_y, file.level._PREFIX.iiiii, ,file.level._PREFIXATTR
    call VioWrtCharStrAttr height+w1_x-1, w1_y, substr(file.level.iiiii, file.level._HOFFSET, fwidth), ,file.level._ATTR.iiiii
    if (symbol('file.'level'._PCMD.'iiiii) = 'VAR') then
      call VioWrtCharStrAttr height+w1_x-1, 0, file.level._PCMD.iiiii ,,file.level._PREFIXCMDATTR
  end
  return

/* scroll file area one line down */
scrolld:
  iiiii = value('file.'level'._VISIBLE.'file.level._TOP+currentLine)
  if file.level._PREFIXWIDTH \= 0 then do
    call VioScrollDown currentLine+w3_x, w3_y, height+w3_x-1, w3_y+(file.level._PREFIXWIDTH-1), 1, ,file.level._PREFIXATTR
    call VioWrtCharStrAttr currentLine+w3_x, w3_y, file.level._PREFIX.iiiii, ,file.level._PREFIXATTR
  end
  call VioScrollDown currentLine+w1_x, w1_y, height+w1_x-1, w1_y+fwidth-1, 1, ,file.level._ATTR
  call VioWrtCharStrAttr currentLine+w1_x, w1_y, substr(file.level.iiiii, file.level._HOFFSET, fwidth), ,file.level._ATTR.iiiii
  if (symbol('file.'level'._PCMD.'iiiii) = 'VAR') then
    call VioWrtCharStrAttr currentLine+w1_x, 0, file.level._PCMD.iiiii ,,file.level._PREFIXCMDATTR
  iiiii = value('file.'level'._VISIBLE.'file.level._TOP+currentLine-1)
  if file.level._PREFIXWIDTH \= 0 then
    call VioWrtCharStrAttr currentLine+w3_x-1, w3_y, file.level._PREFIX.iiiii,,file.level._CPREFIXATTR
  if file.level._ATTR.iiiii = file.level._HIGHLIGHTATTR then
    call VioWrtCharStrAttr currentLine+w1_x-1, w1_y, substr(file.level.iiiii, file.level._HOFFSET, fwidth) ,,file.level._CHIGHLIGHTATTR
  else
    call VioWrtCharStrAttr currentLine+w1_x-1, w1_y, substr(file.level.iiiii, file.level._HOFFSET, fwidth) ,,file.level._CURRENTATTR
  if (symbol('file.'level'._PCMD.'iiiii) = 'VAR') then
    call VioWrtCharStrAttr currentLine+w1_x-1, 0, file.level._PCMD.iiiii ,,file.level._PREFIXCMDATTR
  if file.level._PREFIXWIDTH \= 0 then
    call VioScrollDown w3_x, w3_y, currentLine+w3_x-2, w3_y+(file.level._PREFIXWIDTH-1), 1, ,file.level._PREFIXATTR
  if file.level._TOP > 0 then do
    iiiii = value('file.'level'._VISIBLE.'file.level._TOP)
    if file.level._PREFIXWIDTH \= 0 then
      call VioWrtCharStrAttr w3_x, w3_y, file.level._PREFIX.iiiii, ,file.level._PREFIXATTR
    call VioScrollDown w1_x, w1_y, currentLine+w1_x-2, w1_y+fwidth-1, 1, ,file.level._ATTR
    call VioWrtCharStrAttr w1_x, w1_y, substr(file.level.iiiii, file.level._HOFFSET, fwidth), ,file.level._ATTR.iiiii
    if (symbol('file.'level'._PCMD.'iiiii) = 'VAR') then
      call VioWrtCharStrAttr w1_x, 0, file.level._PCMD.iiiii ,,file.level._PREFIXCMDATTR
  end
  else
    call VioScrollDown w1_x, w1_y, currentLine+w1_x-2, w1_y+fwidth-1, 1, ,file.level._ATTR
  return

/* redraw file area */
show:
  if \ file.level._WIDE then do
    i_init = 0; i_end = height-1
    if file.level._TOP < 1 then do
      if file.level._PREFIXWIDTH \= 0 then
        call VioScrollUp w3_x, w3_y, w3_x-file.level._TOP, w3_y+(file.level._PREFIXWIDTH-1),height,,file.level._PREFIXATTR
      call VioScrollUp w1_x, w1_y, w1_x-file.level._TOP, w1_y+fwidth-1,height,,file.level._ATTR
      i_init = 1 - file.level._TOP
    end
    if file.level._TOP + i_end > 1 + file.level._VISIBLE.0 then
      i_end = 1 + file.level._VISIBLE.0 - file.level._TOP
    index = file.level._TOP+i_init; delta = w1_x+i_init
    iiiii = value('file.'level'._VISIBLE.'file.level._TOP+currentLine-1)
    oattr = file.level._ATTR.iiiii
    if oattr = file.level._HIGHLIGHTATTR then
      file.level._ATTR.iiiii = file.level._CHIGHLIGHTATTR
    else
      file.level._ATTR.iiiii = file.level._CURRENTATTR
    if file.level._HOFFSET = 1 then
      do index = index for i_end-i_init+1
        what = file.level._VISIBLE.index
        call VioWrtCharStrAttr delta, w3_y, file.level._PREFIX.what,,word(file.level._PREFIXATTR file.level._CPREFIXATTR,1+(iiiii = index))
        call VioWrtCharStrAttr delta, w1_y, left(file.level.what,fwidth) ,,file.level._ATTR.what
        if (symbol('file.'level'._PCMD.'what) = 'VAR') then
          call VioWrtCharStrAttr delta, 0, file.level._PCMD.what ,,file.level._PREFIXCMDATTR
        delta = delta + 1
      end
    else
      do index = index for i_end-i_init+1
        what = file.level._VISIBLE.index
        call VioWrtCharStrAttr delta, w3_y, file.level._PREFIX.what,,file.level._PREFIXATTR
        if what \= 1 & what \= file.level._VISIBLE.0 + 1 then
          call VioWrtCharStrAttr delta, w1_y, substr(file.level.what, file.level._HOFFSET,fwidth) ,,file.level._ATTR.what
        else
          call VioWrtCharStrAttr delta, w1_y, left(file.level.what,fwidth) ,,file.level._ATTR.what
        if (symbol('file.'level'._PCMD.'what) = 'VAR') then
          call VioWrtCharStrAttr delta, 0, file.level._PCMD.what ,,file.level._PREFIXCMDATTR
        delta = delta + 1
      end
    file.level._ATTR.iiiii = oattr
    if i_end \= height + 1 then do
      if file.level._PREFIXWIDTH \= 0 then
        call VioScrollUp delta, w3_y, w3_x+height-1, w3_y+(file.level._PREFIXWIDTH-1),height,,file.level._PREFIXATTR
      call VioScrollUp delta, w1_y, w1_x+height-1, w1_y+fwidth-1,height,,file.level._ATTR
    end
  end
  else
    do i = 1 to height
      index = file.level._TOP + i - 1
      if index <= 1 | 3+(index-2)*file.level._NCOL > 1 + file.level._VISIBLE.0 then do
        if file.level._PREFIXWIDTH \= 0 then
          call w_put w3, i, 1, copies(' ',file.level._PREFIXWIDTH), ,file.level._PREFIXATTR
        if index < 1 | 3+(index-3)*file.level._NCOL > 1 + file.level._VISIBLE.0 then
          call w_put w1, i, 1, '', fwidth, file.level._ATTR
        else
        if index = 1 then
          call w_put w1, i, 1, file.level.1, fwidth, file.level._ATTR.1
        else
          call w_put w1, i, 1, value('file.'level'.'file.level._VISIBLE.0+1), fwidth, value('file.'level'._ATTR.'file.level._VISIBLE.0+1)
        iterate
      end
      index = 2+(index-2)*file.level._NCOL
      shortnames = ''
      if file.level._PREFIXWIDTH \= 0 then
        call w_put w3, i, 1, file.level._PREFIX.index, ,file.level._PREFIXATTR
      do j = index for file.level._NCOL
        if j <= file.level._VISIBLE.0 then do
          if file.level._VISIBLE.j then
            if substr(file.level.j,26,1) = '>' then
              shortnames = shortnames||'['substr(file.level.j']',41,file.level._MAXWIDTH-1)
            else
              shortnames = shortnames||substr(file.level.j,41,file.level._MAXWIDTH)
          else
            shortnames = shortnames||left('',file.level._MAXWIDTH)
        end
      end /* do */
      if i = currentLine then
        call w_put w1, i, 1, shortnames, fwidth, file.level._CURRENTATTR
      else
        call w_put w1, i, 1, shortnames, fwidth, file.level._ATTR
    end /* do */
  return

/* show error messages -- arg(1) is error message */
errormsg:
  if beep then call beep 262, 100
msg:
  if inprofile then do
    say arg(1)
    return
  end
  save1 = VioReadCellStr(hline-1,0,width*2)
  call VioWrtCharStrAttr hline-1, 0, left(arg(1),width), width, attr._ERRORATTR
  key = inkey()
  call VioWrtCellStr hline-1, 0, save1
  return key

/* show operand error  -- error.1 if arg(1) is not null, error.11 otherwise */
badoperand:
  if arg(1) = '' then
    call errormsg error.11
  else
    call errormsg error.1 arg(1)
  return

/* execute a command -- arg(1) is one of CMDLINE, CMDKEY or PREFIX
                        arg(2) is command
                        arg(3) is optional current file name */
execute:
  cmd = arg(2)
  parse value '0 1 0' cmd with cmdrc ret nowait verb rest
  if translate(verb) = 'SET' then do
    parse var rest verb rest
  end
  verb = alias(verb)
  urest = translate(rest); uw1 = word(urest,1)
  select
    when verb = 'CURSOR' then do
      if abbrev('ESCREEN',uw1,1) then
        erest = subword(urest,2)
      else
        erest = ''
      select
        when urest = 'HOME' then
          if file.level._CURRENT = commandLine then do
            file.level._CURRENT = file.level._OLDCURRENT
            file.level._COL = file.level._OLDCOL
          end
          else do
            file.level._OLDCURRENT = file.level._CURRENT
            file.level._OLDCOL = file.level._COL
            file.level._CURRENT = commandLine
            file.level._COL = 7
          end
        when urest = 'UP' | erest = 'UP' then
          if file.level._CURRENT = commandLine then
            if cmdarrows = 'RETRIEVE' then
              call execute 'CMDKEY', '?'
            else
              file.level._CURRENT = w1_x + height - 1
          else
            /* does not handle cmdline at top yet */
            if file.level._CURRENT = 1 | file.level._TOP + file.level._CURRENT - 1 <= 2 then
              call execute arg(1), 'UP'
            else
              file.level._CURRENT = file.level._CURRENT - 1
        when urest = 'DOWN' | erest = 'DOWN' then
          if file.level._CURRENT = commandLine then
            if cmdarrows = 'RETRIEVE' then
              call execute 'CMDKEY', '?+'
            else
              file.level._CURRENT = w1_x
          else do
            /* does not handle cmdline at top yet */
            file.level._CURRENT = file.level._CURRENT + 1
            if file.level._CURRENT = commandLine then do
              file.level._CURRENT = file.level._CURRENT - 1
              call execute arg(1), 'DOWN'
            end
            else
            if file.level._WIDE then do
              if (file.level._TOP + file.level._CURRENT - 3) * file.level._NCOL + 2 > file.level._VISIBLE.0 then
                call execute arg(1), 'DOWN'
            end
            else
            if file.level._TOP + file.level._CURRENT - 1 > file.level._VISIBLE.0 then
              call execute arg(1), 'DOWN'
          end
        when abbrev('CMDLINE',uw1,2) then do
          file.level._CURRENT = commandLine
          if subword(urest,2) = '' then
            file.level._COL = 1
          else
          if datatype(subword(urest,2)) = 'NUM' then
            file.level._COL = 6 + subword(urest,2)
          else
            call badoperand rest
        end
      otherwise
        call badoperand rest
      end  /* select */
    end
    when verb = '?' then do
      command_line = command.cmdpos
      if cmdpos > 0 then
        cmdpos = cmdpos - 1
      else
      if cmdnum > 0 then
        cmdpos = cmdnum - 1
      call VioWrtCharStr w2_x, w2_y, left(command_line, fwidth)
    end
    when verb = '?+' then do
      if cmdnum > 0 then
        cmdpos = (cmdpos + 1) // cmdnum
      command_line = command.cmdpos
      call VioWrtCharStr w2_x, w2_y, left(command_line, fwidth)
    end
    when verb = 'TEXT' then do
      rest = translate(rest,case,mixed)
      select
        when file.level._CURRENT = commandLine then do
          command_line = insert(rest, command_line, file.level._COL - 7)
          redrawCL = 1
          file.level._COL = file.level._COL + length(rest)
        end
        when file.level._WIDE then
          call errormsg error.38 'Wide mode'
        when file.level._TYPE = 'List' | file.level._TYPE = 'Archive' then do
          select
            when symbol('file.'level'._PCMD.'realitem) = 'BAD' then
              iterate
            when symbol('file.'level'._PCMD.'realitem) = 'LIT' then do
              file.level._PCMD.realitem = rest
              file.level._COL = 1
            end
            when file.level._PCMD.realitem = '*' then do
              file.level._PCMD.realitem = rest
              file.level._COL = 1
            end
          otherwise
            file.level._PCMD.realitem = insert(rest, file.level._PCMD.realitem, file.level._COL - 1)
          end  /* select */
          call VioWrtCharStrAttr file.level._CURRENT, 0, file.level._PCMD.realitem ,,file.level._PREFIXCMDATTR
          file.level._COL = file.level._COL + length(rest)
        end
      otherwise
        call errormsg error.38 file.level._TYPE
      end  /* select */
    end
    when verb = 'SOS' then
      if arg(1) = 'CMDKEY' then
        call sos
      else
        call errormsg error.40 rest
    when verb = 'FLIST' & (arg(1) \= 'CMDLINE' | rest \= '') then do
      if rest = '' then
        rest = filename(arg(3))
      else
      if uw1 = '/' then
        rest = filename(arg(3))'\*' subword(rest,2)
      iExec = 1
      do while wordpos(iExec, allLevels) \= 0
        iExec = iExec + 1
      end /* do */
      opath = fpath; omode = fmode; olevel = level
      level = iExec
      if list_files(rest) = 0 then do
        allLevels = subword(allLevels,1,wordpos(olevel, allLevels)) iExec subword(allLevels,wordpos(olevel,allLevels)+1)
        showlevel = iExec
      end
      fpath = opath; fmode = omode; level = olevel
      if arg(1) = 'CMDKEY' then do
        level = showlevel
        call redraw
      end
    end
    when verb = 'XEDIT' | verb = 'EDIT' then do
      if rest = '' then
        rest = filename(arg(3))
      rest = strip(rest,'B','"')
      if file.level._TYPE = 'Archive' then do
        /* We are in an archive.  Lets fake a normal edit command */
        call VioWrtCharStr 0, itemnumber, ' loading...'
        call UZUnzipToVar left(file.level._CURDIR, length(file.level._CURDIR)-2), substr(rest,length(file.level._CURDIR)), 'temp.'
        if temp.0 = '' then do
          call errormsg error.3 substr(rest,length(file.level._CURDIR))
          call redraw
          return
        end
        iExec = 1
        do while wordpos(iExec, allLevels) \= 0
          iExec = iExec + 1
        end /* do */
        olevel = level
        allLevels = subword(allLevels,1,wordpos(level, allLevels)) iExec subword(allLevels,wordpos(level,allLevels)+1)
        level = iExec
        count = 2
        do idx = 1 for temp.0
          file.level.count = temp.idx
          count = count + 1
        end /* do */
        drop temp.
        call initlevel rest, arg(2), 0, fwidth, olevel
        showlevel = level
        level = olevel
      end
      else
        call loadlevel rest, 'File', error.2 rest
      if arg(1) = 'CMDKEY' then do
        level = showlevel
        call redraw
      end
    end
    when verb = 'HELP' then do
      call loadlevel SysSearchPath('DPATH', 'fl.hlp'), 'Help', error.8
      level = showlevel
      call redraw
    end
    when verb = 'TOP' then
      call execute arg(1), 'BACKWARD *'
    when verb = 'BOTTOM' then
      call execute arg(1), 'FORWARD *'
    when verb = 'FORWARD' | verb = 'BACKWARD' then do
      if rest = ''  then
        rest = 1
      else
      if rest = '*' then do
        rest = file.level._VISIBLE.0
        if file.level._CURRENT \= commandLine then
          file.level._CURRENT = currentLine + w1_x - 1
      end
      if verb = 'FORWARD' then do
        if file.level._TOP = file.level._VISIBLE.0 - currentLine + 1 then
          if pagewrap = 'OFF' | urest = '*' then
            return
          else
            file.level._TOP = max(file.level._TOP - file.level._VISIBLE.0 * height, -currentLine + 3)
        else
          file.level._TOP = min(file.level._TOP + rest * height, file.level._VISIBLE.0 - currentLine + 1)
        if file.level._WIDE then
          file.level._TOP = min(file.level._TOP, (file.level._VISIBLE.0-2) % file.level._NCOL - currentLine + 3)
      end
      else do
        if file.level._TOP = -currentLine + 3 then
          if pagewrap = 'OFF' | urest = '*' then
            return
          else
            file.level._TOP = min(file.level._TOP + file.level._VISIBLE.0 * height, file.level._VISIBLE.0 - currentLine + 1)
        else
          file.level._TOP = max(file.level._TOP - rest * height, -currentLine + 3)
      end
      call show
    end

    /* SET commands */
    when verb = 'BEEP' then
      if wordpos(urest,'ON OFF') > 0 then
        beep = 2 - wordpos(urest,'ON OFF')
      else
        call badoperand rest
    when verb = 'CASE' then
      select
        when abbrev('UPPER',urest,1) then case = xrange('A','Z')xrange('A','Z')
        when abbrev('LOWER',urest,1) then case = xrange('a','z')xrange('a','z')
        when abbrev('MIXED',urest,1) then case = mixed
      otherwise
        call badoperand rest
      end  /* select */
    when verb = 'CMDARROWS' then
      if abbrev('RETRIEVE',urest,1) then
        cmdarrows = 'RETRIEVE'
      else
      if abbrev('TAB',urest,1) then
        cmdarrows = 'TAB'
      else
        call badoperand rest
    when verb = 'CMDLINE' then
      if abbrev('TOP',urest,1) then do
        if \ inprofile then
          if file.level._CURRENT = commandLine then
            file.level._CURRENT = 1
          else
            file.level._CURRENT = file.level._CURRENT + (commandLine \= 1)
        commandLine = 1
        call adjustwindows
      end
      else
      if abbrev('BOTTOM',urest,1) then do
        if \ inprofile then
          if file.level._CURRENT = commandLine then
            file.level._CURRENT = height+1
          else
            file.level._CURRENT = file.level._CURRENT - (commandLine = 1)
        commandLine = height+1
        call adjustwindows
      end
      else
        call badoperand rest
    when verb = 'COLOR' | verb = 'COLOUR' then do
      parse upper value rest with area rest
      select
        when abbrev('ARROW',area,1) then
          attr._ARROWATTR = color(rest,attr._ARROWATTR)
        when abbrev('CMDLINE',area,1) then
          attr._CMDATTR = color(rest,attr._CMDATTR)
        when abbrev('CPREFIX',area,3) then
          file.level._CPREFIXATTR = color(rest,file.level._CPREFIXATTR)
        when abbrev('CURLINE',area,2) then
          file.level._CURRENTATTR = color(rest,file.level._CURRENTATTR)
        when abbrev('FILEAREA',area,1) then
          file.level._ATTR = color(rest,file.level._ATTR)
        when abbrev('IDLINE',area,1) then
          attr._MSGATTR = color(rest,attr._MSGATTR)
        when abbrev('MSGLINE',area,1) then
          attr._ERRORATTR = color(rest,attr._ERRORATTR)
        when abbrev('PENDING',area,1) then
          file.level._PREFIXCMDATTR = color(rest,file.level._PREFIXCMDATTR)
        when abbrev('PREFIX',area,2) then
          file.level._PREFIXATTR = color(rest,file.level._PREFIXATTR)
        when abbrev('SHADOW',area,2) then
          file.level._SHADOWATTR = color(rest,file.level._SHADOWATTR)
        when abbrev('STATAREA',area,2) then
          call color rest,0
        when abbrev('TOFEOF',area,2) then
          attr._TOFEOF = color(rest,attr._TOFEOF)
        when abbrev('HIGHLIGHT',area,2) then
          file.level._HIGHLIGHTATTR = color(rest,file.level._HIGHLIGHTATTR)
        when abbrev('CHIGHLIGHT',area,3) then
          file.level._CHIGHLIGHTATTR = color(rest,file.level._CHIGHLIGHTATTR)
      otherwise
        call badoperand area
      end  /* select */
      if \inprofile then
        call drawall
    end
    when verb = 'CURLINE' then do
      interpret 'rest =' rest '; IF rest < 0 THEN rest = 1 + height + rest'
      if \inprofile then
        file.level._TOP = file.level._TOP + currentLine - rest
      currentLine = rest
      if \inprofile then
        call show
    end
    when verb = 'EQUIVCHAR' then
      if rest = '' then
        call errormsg error.11
      else
      if length(rest) = 1 then
        EQUIVChar = rest
      else
        call errormsg error.37 rest
    when verb = 'HIGHLIGHT' then
      if urest = 'OFF' then
        highlight = 'OFF'
      else
      if abbrev('TAGGED',urest,3) then
        highlight = 'TAGGED'
      else
        call badoperand rest
    when verb = 'IMPOS' | verb = 'IMPCMSCP' then
      if wordpos(urest,'ON OFF') > 0 then
        impos = 2 - wordpos(urest,'ON OFF')
      else
        call badoperand rest
    when verb = 'LINEFLAG' then
      nop /* !!! */
    when verb = 'MSGLINE' then
      interpret 'hLine =' subword(rest,2) '; IF hLine < 0 THEN hLine = 2 + height + hLine'
    when verb = 'NUMBER' then
      if wordpos(urest,'ON OFF') > 0 then do
        file.level._PREFIXNUM = 2 - wordpos(urest,'ON OFF')
        if \inprofile then do
          call renumlevel
          call show
        end
      end
      else
        call badoperand rest
    when verb = 'PAGEWRAP' then
      if uw1 = 'ON' then
        pagewrap = 'ON'
      else
      if uw1 = 'OFF' then
        pagewrap = 'OFF'
      else
        call badoperand rest
    when verb = 'PENDING' then do
      parse var rest . what
      if uw1 = 'ON' then do
        file.level._PCMD.realitem = what
        call show
      end
      else
      if uw1 = 'OFF' then
        if what = '' then do
          drop file.level._PCMD.realitem
          call show
        end
        else
          call errormsg error.12 what
      else
        call badoperand rest
    end
    when verb = 'PREFIX' then
      if uw1 = 'ON' | abbrev('NULLS',uw1,1) |  uw1 = EQUIVChar then do
        if \inprofile then
          if uw1 \= EQUIVChar then
            file.level._PREFIXNUL = (uw1 \= 'ON')
        uw2 = word(urest,2)
        select
          when abbrev('LEFT',uw2,1) | abbrev('RIGHT',uw2,1) | uw2 = EQUIVChar then do
            if abbrev('LEFT',uw2,1) then
              file.level._PREFIXPOS = 'LEFT'
            else
            if uw2 \= EQUIVChar then
              file.level._PREFIXPOS = 'RIGHT'
            if subword(urest,3) \= '' then do
              parse value subword(urest,3) with _w _g _
              if _w = EQUIVChar then
                _w = file.level._PREFIXWIDTH
              if _g = EQUIVChar then
                _g = file.level._PREFIXGAP
              select
                when _ \= '' then
                  call errormsg error.12 _
                when \datatype(_w,'NUM') then
                  call badoperand _w
                when _w < 2 | _w > 20 then
                  call badoperand _w '(width must be in [2..20])'
                when _g \= '' & \datatype(_g,'NUM') then
                  call badoperand _g
                when _g \= '' & (_g < 0 | _g > 18) then
                  call badoperand _g '(gap must be in [0..18])'
                when _g >= _w then
                  call badoperand _g '(gap must be smaller than width)'
              otherwise
                file.level._PREFIXWIDTH = _w
                if _g \= '' then
                  file.level._PREFIXGAP = _g
                else
                  file.level._PREFIXGAP = 0
                if \ inprofile then
                  call renumlevel
                call adjustwindows
              end  /* select */
            end
            else do
              if file.level._PREFIXGAP > 0 then
                if \inprofile then
                  call renumlevel
              call adjustwindows
            end
          end
          when subword(rest,2) = '' then
            if \inprofile then do
              call renumlevel
              call drawall
            end
        otherwise
          call badoperand rest
        end  /* select */
      end
      else
      if uw1 = 'OFF' then do
        file.level._PREFIXWIDTH = 0
        file.level._PREFIXGAP = 0
        if \ inprofile then
          call renumlevel
        call adjustwindows
      end
      else
        call badoperand rest
    when verb = 'SCOPE' then
      if abbrev('ALL',urest,1) then
        scope = 'ALL'
      else
      if abbrev('DISPLAY',urest,1) then
        scope = 'DISPLAY'
      else
        call badoperand rest
    when verb = 'SCREEN' then
      nop /* !!! */
    when verb = 'SHADOW' then
      if urest = 'ON' | urest = 'OFF' then do
        shadow = urest
        call shadowlevel
      end
      else
        call badoperand rest
    when verb = 'SLK' then do
      parse var rest n text
      select
        when translate(n) = 'OFF' & text =  '' then do
          do i = 1 to 10
            keyname.i = ''
          end /* do */
          call drawall
        end
        when datatype(n, 'W') then
          if n < 1 | n > 12 then
            call errormsg error.1 n
          else do
            keyname.n = text
            call drawall
          end
      otherwise
        call badoperand rest
      end  /* select */
    end

    /* end of SET commands */

    when verb = 'QUERY' then
      select
        when urest = 'BEEP' then
          if beep then
            call msg rest 'ON'
          else
            call msg rest 'OFF'
        when urest = 'CASE' then
          if case = mixed then
            call msg rest 'MIXED IGNORE'
          else
            call msg rest case 'IGNORE'
        when uw1 = 'COLOR' then do
          parse var urest . area
          select
            when abbrev('ARROW',area,1) then
              call msg word(rest,1) word(rest,2) colorname(attr._ARROWATTR)
            when abbrev('CMDLINE',area,1) then
              call msg word(rest,1) word(rest,2) colorname(attr._CMDATTR)
            when abbrev('CPREFIX',area,3) then
              call msg word(rest,1) word(rest,2) colorname(file.level._CPREFIXATTR)
            when abbrev('CURLINE',area,2) then
              call msg word(rest,1) word(rest,2) colorname(file.level._CURRENTATTR)
            when abbrev('FILEAREA',area,1) then
              call msg word(rest,1) word(rest,2) colorname(file.level._ATTR)
            when abbrev('IDLINE',area,1) then
              call msg word(rest,1) word(rest,2) colorname(attr._MSGATTR)
            when abbrev('MSGLINE',area,1) then
              call msg word(rest,1) word(rest,2) colorname(attr._ERRORATTR)
            when abbrev('PENDING',area,1) then
              call msg word(rest,1) word(rest,2) colorname(file.level._PREFIXCMDATTR)
            when abbrev('PREFIX',area,2) then
              call msg word(rest,1) word(rest,2) colorname(file.level._PREFIXATTR)
            when abbrev('SHADOW',area,2) then
              call msg word(rest,1) word(rest,2) colorname(file.level._SHADOWATTR)
            when abbrev('STATAREA',area,2) then
              nop
            when abbrev('TOFEOF',area,2) then
              call msg word(rest,1) word(rest,2) colorname(attr._TOFEOF)
            when abbrev('HIGHLIGHT',area,2) then
              call msg word(rest,1) word(rest,2) colorname(file.level._HIGHLIGHTATTR)
            when abbrev('CHIGHLIGHT',area,3) then
              call msg word(rest,1) word(rest,2) colorname(file.level._CHIGHLIGHTATTR)
          otherwise
            call badoperand subword(rest,2)
          end  /* select */
        end
        when abbrev('CMDARROWS',urest,4) then
          call msg rest cmdarrows
        when abbrev('CMDLINE',urest,3) then
          call msg rest word('TOP BOTTOM',1+(commandLine \= 1))
        when abbrev('CURLINE',urest,4) then
          call msg rest currentLine
        when abbrev('EQUIVCHAR',urest,6) then
          call msg rest EQUIVChar
        when abbrev('HIGHLIGHT',urest,4) then
          call msg rest highlight
        when urest = 'IMPOS' | abbrev('IMPCMSCP',urest,3) then
          call msg rest impos
        when abbrev('MSGLINE',urest,4) then
          call msg rest hLine
        when abbrev('NUMBER',urest,3) then
          if file.level._PREFIXNUM then
            call msg rest 'ON'
          else
            call msg rest 'OFF'
        when urest = 'PAGEWRAP' then
          call msg rest pagewrap
        when abbrev('PREFIX',urest,3) then
          if file.level._PREFIXWIDTH = 0 then
            call msg rest 'OFF'
          else
            call msg rest 'ON' file.level._PREFIXPOS file.level._PREFIXWIDTH file.level._PREFIXGAP
        when urest = 'SCOPE' then
          call msg rest scope
        when urest = 'SHADOW' then
          call msg rest shadow
      otherwise
        call badoperand rest
      end  /* select */

    when verb = 'RGTLEFT' then
      if rest = '' | datatype(rest) = 'NUM' then do
        if rest = '' then
          rest = (width * 3) % 4
        if file.level._HOFFSET > 1 then
          file.level._HOFFSET = max(1, file.level._HOFFSET - rest)
        else
          file.level._HOFFSET = file.level._HOFFSET + rest
        call show
      end
      else
        call errormsg error.1 rest
    when verb = 'LEFT' then
      select
        when urest = 'HALF' then do
          file.level._HOFFSET = max(1, file.level._HOFFSET - width % 2)
          call show
        end
        when urest = 'FULL' then do
          file.level._HOFFSET = max(1, file.level._HOFFSET - width)
          call show
        end
        when datatype(rest) = 'NUM' then do
          file.level._HOFFSET = max(1, file.level._HOFFSET - rest)
          call show
        end
        when rest = '' then do
          file.level._HOFFSET = max(1, file.level._HOFFSET - 1)
          call show
        end
      otherwise
        call errormsg error.1 rest
      end  /* select */
    when verb = 'RIGHT' then
      select
        when urest = 'HALF' then do
          file.level._HOFFSET = file.level._HOFFSET + width % 2
          call show
        end
        when urest = 'FULL' then do
          file.level._HOFFSET = file.level._HOFFSET + width
          call show
        end
        when datatype(rest) = 'NUM' then do
          file.level._HOFFSET = max(1, file.level._HOFFSET + rest)
          call show
        end
        when rest = '' then do
          file.level._HOFFSET = file.level._HOFFSET + 1
          call show
        end
      otherwise
        call errormsg error.1 rest
      end  /* select */
    when verb = 'QUIT' then do
      if words(allLevels) = 1 then do
        quit = 1
        return
      end
      call clearlevel
      level = wordpos(level,allLevels)
      allLevels = delword(allLevels,level,1)
      level = level - 1
      if level = 0 then
        level = words(allLevels)
      level = word(allLevels,level)
      showlevel = level
      call adjustwindows
    end
    when verb = 'RELOAD' then
      if list_files(file.level._CURDIR) = 0 then do
        do idx = 1 to file.level.0+1
          drop file.level._PCMD.idx
        end /* do */
        call show
      end
    when verb = 'OSNOWAIT' | verb = 'DOSNOWAIT' then
      parse value '0 1' rest with ret nowait cmd
    when verb = 'RUN' | verb = 'OS' | verb = 'DOS' then do
      if rest = '' | urest = '/O' then
        cmd = value('comspec',,'OS2ENVIRONMENT') '/o'
      else
        cmd = rest
      ret = 0
    end
    when verb = 'NEXTWINDOW' | (verb = 'FLIST' & rest = '' & arg(1) = 'CMDLINE') then do
      nlevel = 1 + wordpos(level,allLevels)
      if nlevel > words(allLevels) then nlevel = 1
      showlevel = word(allLevels,nlevel)
      if level \= showlevel then do
        level = showlevel
        call adjustwindows
      end
    end
    when verb = 'PREVWINDOW' then do
      nlevel = wordpos(level,allLevels) - 1
      if nlevel < 1 then nlevel = words(allLevels)
      showlevel = word(allLevels,nlevel)
      if level \= showlevel  then do
        level = showlevel
        call adjustwindows
      end
    end
    when verb = 'CMSG' then do
      command_line = rest
      call VioWrtCharStr w2_x, w2_y, left(command_line, fwidth)
    end
    when verb = 'EMSG' then
       call errormsg  rest
    when verb = 'MSG' then
       call msg rest
    when verb = 'MACRO' then
       if word(rest, 1) = '?' then
         call macro subword(rest, 2)
       else
         call macro rest
    when verb = 'EXTRACT' then
       if inmacro > 0 then do
         do while rest \= ''
           parse upper var rest sep +1 target (sep) _
           select
             when target = 'BEEP' then do
               beep.0 = 1
               if beep then
                 beep.1 = 'ON'
               else
                 beep.1 = 'OFF'
             end
             when abbrev('CMDARROWS',target,4) then do
               cmdarrows.0 = 1
               cmdarrows.1 = cmdarrows
             end
             when abbrev('CURLINE',target,3) then do
               curline.0 = 3
               curline.1 = currentLine
               curline.2 = value('file.'level'._VISIBLE.'file.level._TOP+currentLine-1)
               curline.3 = value('file.'level'.'curline.2) /* ??? */
             end
             when abbrev('FILENAME',target,5) then do
               filename.0 = 1
               filename.1 = file.level._CURDIR
             end
             when target = 'IMPOS' then do
               impos.0 = 1
               impos.1 = impos
             end
             when abbrev('NUMBER',target,3) then do
               number.0 = 1
               if file.level._PREFIXNUM then
                 number.1 = 'ON'
               else
                 number.1 = 'OFF'
             end
           otherwise
             call badoperand target
           end  /* select */
           if _ \= '' then
             rest = sep||_
           else
             rest = ''
         end /* do */
       end
       else
         call errormsg error.53
    when verb = 'RESET' then do
      if (urest = 'ALL') | abbrev('PREFIX',urest,1) then
        do idx = 1 to file.level.0+1
          drop file.level._PCMD.idx
        end /* do */
      call show
    end
    when verb = 'CCANCEL' & arg(1) = 'CMDLINE' then quit = 1
    when verb = '/' then file.level._TOP = item - currentLine + 1
    when verb = 'NEXT' | verb = 'DOWN' then do
      otop = file.level._TOP
      if rest = '' then
        rest = 1
      if rest = '*' then
        file.level._TOP = file.level._VISIBLE.0 - currentLine + 1
      else
        file.level._TOP = min(file.level._TOP + rest, file.level._VISIBLE.0 - currentLine + 1)
      if file.level._WIDE then
        file.level._TOP = min(file.level._TOP, (file.level._VISIBLE.0-2) % file.level._NCOL - currentLine + 3)
      if file.level._TOP \= otop then
        if \ file.level._WIDE & rest = 1 then
          call scrollu
        else
          call show
    end
    when verb = 'UP' then do
      otop = file.level._TOP
      if rest = '' then rest = 1
      if rest = '*' then
        file.level._TOP = -currentLine+3
      else
        file.level._TOP = max(file.level._TOP - rest, -currentLine+3)
      if file.level._TOP \= otop then
        if \ file.level._WIDE & rest = 1 then
          call scrolld
        else
          call show
    end
    when verb = 'DEFINE' then do
      parse var rest key def
      if length(key) > 1 then
        key = value(translate(key,'_','-'))
      if def \= '' then
        if abbrev('CURSOR', translate(word(def,1)),3) & abbrev('SCREEN',translate(word(def,2)),1) then
          select /* faking std assignment */
            when key = CURU & translate(subword(def,3)) = 'UP' then
              drop keys._0048
            when key = CURD & translate(subword(def,3)) = 'DOWN' then
              drop keys._0050
            when key = CURL & translate(subword(def,3)) = 'LEFT' then
              drop keys._004B
            when key = CURR & translate(subword(def,3)) = 'RIGHT' then
              drop keys._004D
          otherwise
            call value 'keys._'c2x(key), def
          end  /* select */
        else
          if key = ENTER & translate(space(def)) = 'SOS DOPREFIX EXECUTE' then
            drop keys._0D
          else
            call value 'keys._'c2x(key), def
      else
        interpret 'drop keys._'c2x(key)
    end
    when verb = 'SHOWKEY' then do
      msg = 'Press the key to be translated...spacebar to exit'
      do forever
        key = errormsg(msg)
        if key = ' ' then leave
        if symbol('keys._'c2x(key)) = 'VAR' then
          msg = 'Key: 'physicalkey(key)' - assigned to '''value('keys._'c2x(key))''''
        else
          select /* faking std assignment */
            when key = CURU then
              msg = 'Key: 'physicalkey(key)' - assigned to ''cursor screen up'''
            when key = CURD then
              msg = 'Key: 'physicalkey(key)' - assigned to ''cursor screen down'''
            when key = CURL then
              msg = 'Key: 'physicalkey(key)' - assigned to ''cursor screen left'''
            when key = CURR then
              msg = 'Key: 'physicalkey(key)' - assigned to ''cursor screen right'''
            when key = ENTER then
              msg = 'Key: 'physicalkey(key)' - assigned to ''sos doprefix execute'''
          otherwise
            msg = 'Key: 'physicalkey(key)' - unassigned'
          end  /* select */
      end /* do */
    end
    when left(verb, 1) = '/' then
      call execute arg(1), 'LOCATE' arg(2)
    when verb = 'LOCATE' then do
      parse var rest sep +1 target (sep) _
      do idx = item+1 to file.level._VISIBLE.0
        if pos(translate(target), translate(value('file.'level'.'file.level._VISIBLE.idx))) \= 0 then do
          file.level._TOP = idx - currentLine + 1
          call show
          return
        end
      end
      call errormsg error.10 rest
    end
    when verb = 'TAG' then do
      call taglevel rest
      call show
    end
    when verb = 'ALL' then do
      call filterlevel rest
      /* adjusting display, keeping currentLine if possible */
      if file.level._VISIBLE.0 = 0 then
        item = 0
      else
        do idx = 1 to file.level._VISIBLE.0
          if file.level._VISIBLE.idx <= realitem then
            item = idx
        end
      file.level._TOP = item - currentLine + 1
      call show
    end
  otherwise
    if impos then
      ret = 0
    else
      call errormsg error.0 cmd
  end /* select */
  if ret then
    return
  if arg(1) \= 'PREFIX' | \ executed then do
    saved_screen = VioReadCellStr(0,0,(height+3)*width*2)
    call SysCls
    executed = 1
  end
  prompt = prompt()
  signal on halt
  if arg(1) \= 'CMDLINE' then
    cmd = substitute(cmd,arg(3))
  else
    cmd = substitute(cmd '/o',arg(3))
  say prompt||cmd
  address cmd cmd
  if file.level._TYPE = 'List' & stream(strip(filename(arg(3)), 'b', '"'),'c','query datetime') = '' then
    call value 'file.'level'.'arg(3), overlay(rod,value('file.'level'.'arg(3)))
  cmdrc = rc
after_halt:
  if arg(1) \= 'PREFIX' then do
    if \ nowait then do
      say
      say 'Press any key to continue.'
      call inkey
    end
    call VioWrtCellStr 0, 0, saved_screen
  end
  return

/* handle control break */
/* this should be activated only from the 'execute' routine */
halt:
  signal after_halt

/* parse command line & perform substitutions */
substitute: procedure expose file. fmode fpath level abbr.
  parse arg verb rest, item
  if verb = '/' then do
    parse arg rest, item
    verb = ''
  end
  parse value '0 0' with state subst tail
  parse var file.level.item fdate ftime fsize feasize fileid
  fileid = strip(fileid)
  if pos('.',fileid) \= 0 then do
    fn = substr(fileid,1,lastpos('.',fileid)-1)
    ft = substr(fileid,lastpos('.',fileid)+1)
  end
  else do
    fn = fileid
    ft = ''
  end
  do i = 1 to length(rest)
    c = translate(substr(rest,i,1))
    if state = 0 then do
      if c = '/' then
        state = 1
      else
        tail = tail||substr(rest,i,1)
    end
    else do /* state = 1 */
      select
        when c = 'N' then do
          tail = tail||fn
          subst = 1
        end
        when c = 'T' | c = 'E' then do
          tail = tail||ft
          subst = 1
        end
        when c = 'D' | c = 'M' then do
          tail = tail||fmode':'
          subst = 1
        end
        when c = 'P' then do
          tail = tail||fpath
          subst = 1
        end
        when c == ' ' then do
          tail = tail||filename(item)||' '
          subst = 1
        end
        when c = 'O' then
          subst = 1
      otherwise
        tail = tail||substr(rest,i,1)
      end /* select */
      state = 0
    end /* do */
  end /* outer loop */

  if state then tail = tail||filename(item)

  if \subst then do
    fname = filename(item)
    if tail \== '' then
      tail = tail fname
    else
      tail = fname
  end

  verb = alias(verb)
  return verb tail

/* handles sos commands */
sos:
  select
    when abbrev('BOTTOMEDGE',urest,7) then
      file.level._CURRENT = w1_x + height - 1
    when abbrev('CURRENT',urest,4) then
      file.level._CURRENT = currentLine + w1_x - 1
    when abbrev('DELBACK',urest,5) then
      if file.level._CURRENT = commandLine then do
        if file.level._COL <= 7 then
          return
        file.level._COL = file.level._COL - 1
        command_line = delstr(command_line, file.level._COL - 6, 1)
        redrawCL = 1
      end
      else
      if (file.level._COL > 1) & (symbol('file.'level'._PCMD.'realitem) = 'VAR') then do
        file.level._COL = file.level._COL - 1
        file.level._PCMD.realitem = delstr(file.level._PCMD.realitem, file.level._COL, 1)
        call redrawline
      end
    when abbrev('DELCHAR',urest,4) then
      if file.level._CURRENT = commandLine then do
        command_line = delstr(command_line, file.level._COL - 6, 1)
        redrawCL = 1
      end
      else
      if symbol('file.'level'._PCMD.'realitem) = 'VAR' then do
        file.level._PCMD.realitem = delstr(file.level._PCMD.realitem, file.level._COL, 1)
        call redrawline
      end
    when abbrev('DOPREFIX',urest,5) then do
      executed = 0
      if scope = 'ALL' then
        do idCmd = 2 to file.level.0
           call doprefix idCmd
        end /* do */
      else
        do idCmd = 1 to file.level._VISIBLE.0
           call doprefix file.level._VISIBLE.idCmd
        end /* do */
      if executed then do
        say
        say 'Press any key to continue.'
        call inkey
        call VioWrtCellStr 0, 0, saved_screen
      end
      if showlevel \= level then do
        level = showlevel
        call redraw
      end
      else
        call show
      ret = 1
    end
    when abbrev('ENDCHAR',urest,4) then
      if file.level._CURRENT = commandLine then
        file.level._COL = 7 + length(command_line)
      else do
        len = length(file.level.realitem)
        old = file.level._HOFFSET
        file.level._HOFFSET = 1 + max(0,((len % (fwidth % 2))-1))*(fwidth%2)
        file.level._COL = w1_y + 1 + len + 1 - file.level._HOFFSET
        if file.level._HOFFSET \= old then
          call show
      end
    when abbrev('EXECUTE',urest,2) then do
      file.level._CURRENT = commandLine
      call SysCurPos file.level._CURRENT, file.level._COL-1
      if command_line \= '' then do
        command.cmdnum = command_line
        cmdpos = cmdnum
        cmdnum = cmdnum + 1
        command_line = ''
        call execute 'CMDLINE', command.cmdpos, realitem
        parse value '1 7' with redrawCL file.level._COL
        if showlevel \= level then do
          level = showlevel
          call redraw
        end
      end
    end
    when abbrev('LEFTEDGE',urest,5) then
      if file.level._CURRENT = commandLine then
        file.level._COL = 7
      else
        file.level._COL = w1_y + 1
    when urest = 'MAKECURR' then do
      file.level._TOP = item - currentLine + 1
      file.level._CURRENT = currentLine + w1_x - 1
      call show
    end
    when abbrev('PREFIX',urest,3) then
      if file.level._CURRENT \= commandLine then
        file.level._COL = w3_y + 1
    when abbrev('QCMND',urest,2) then do
      file.level._CURRENT = commandLine
      file.level._COL = 7
      command_Line = ''
      redrawCL = 1
    end
    when abbrev('RIGHTEDGE',urest,6) then
      if file.level._CURRENT = commandLine then
        file.level._COL = width
      else
        file.level._COL = w1_y + fwidth
    when abbrev('STARTENDCHAR',urest,9) then
      if file.level._CURRENT = commandLine then do
        len = length(command_line)
        if file.level._COL = 7 + len then
          file.level._COL = 7
        else
          file.level._COL = 7 + len
      end
      else do
        len = length(file.level.realitem)
        old = file.level._HOFFSET
        if file.level._COL = w1_y + 1 + len + 1 - file.level._HOFFSET then do
          file.level._COL = w1_y + 1
          file.level._HOFFSET = 1
        end
        else do
          file.level._HOFFSET = 1 + max(0,((len % (fwidth % 2))-1))*(fwidth%2)
          file.level._COL = w1_y + 1 + len + 1 - file.level._HOFFSET
        end
        if file.level._HOFFSET \= old then
          call show
      end
    when abbrev('TABFIELDF',urest,8) then
      select
        when file.level._CURRENT = commandLine then do
          file.level._CURRENT = w1_x
          file.level._COL = 1+file.level._WIDE*w1_y
        end
        when file.level._WIDE & file.level._COL-(w1_y+1) < file.level._MAXWIDTH*(file.level._NCOL-1) & item < file.level._VISIBLE.0 then
          file.level._COL = 1+w1_y+(1+(file.level._COL-(w1_y+1))%file.level._MAXWIDTH)*file.level._MAXWIDTH
      otherwise
        file.level._CURRENT = file.level._CURRENT // (height + 1) + 1
        if \ file.level._WIDE & file.level._TOP + file.level._CURRENT - 1 - (commandLine = 1) > file.level._VISIBLE.0 then
          file.level._CURRENT = commandLine
        if file.level._WIDE & (file.level._TOP + file.level._CURRENT - 3) * file.level._NCOL + 2 > file.level._VISIBLE.0 then
          file.level._CURRENT = commandLine
        file.level._COL = 1+file.level._WIDE*w1_y
      end  /* select */
    when urest = 'TABFIELDB' then
      select
        when file.level._CURRENT = commandLine & file.level._COL = 7 then do
          file.level._CURRENT = w1_x+height-1
          if file.level._WIDE then
            file.level._COL = 1+w1_y+(file.level._NCOL-1)*file.level._MAXWIDTH
          else
            file.level._COL = 1
        end
        when file.level._COL = 1+w1_y*file.level._WIDE & (file.level._CURRENT = w1_x | file.level._TOP + file.level._CURRENT - 1 - (commandLine = 1) <= 2) then do
          file.level._COL = 7
          file.level._CURRENT = commandLine
        end
        when file.level._WIDE & file.level._COL > w1_y + 1 then
          file.level._COL = max(w1_y+1,w1_y+1+min(file.level._NCOL-1,(file.level._COL+file.level._MAXWIDTH-8)%file.level._MAXWIDTH-1)*file.level._MAXWIDTH)
        when \file.level._WIDE & file.level._COL > 1 then
          file.level._COL = 1
      otherwise
        file.level._CURRENT = file.level._CURRENT - 1
        file.level._COL = 1+file.level._WIDE*(w1_y+(file.level._NCOL-1)*file.level._MAXWIDTH)
      end  /* select */
    when urest = 'TABWORDB' then
      if file.level._CURRENT = commandLine then
        if words(left(command_line,file.level._COL - 7)) = 0 then
          file.level._COL = 7
        else
          file.level._COL = 7 + wordindex(command_line, words(left(command_line,file.level._COL -  7))) - 1
      else do
        old = file.level._HOFFSET
        pos = file.level._COL +  old - w1_y - 2
        if file.level._COL <= w1_y | file.level._COL > w1_y + fwidth then
          nop
        else do
          if words(left(file.level.realitem, pos)) = 0 then
            file.level._COL = w1_y + 1
           else
            file.level._COL = w1_y + wordindex(file.level.realitem, words(left(file.level.realitem, pos))) - old + 1
          if file.level._COL <= w1_y then do
            file.level._HOFFSET = 1 + max(0,(((file.level._COL + old - w1_y - 2) % (fwidth % 2))-1))*(fwidth%2)
            file.level._COL = file.level._COL + old - file.level._HOFFSET
            call show
          end
        end
      end
    when abbrev('TABWORDF',urest,7) then
      if file.level._CURRENT = commandLine then
        if file.level._COL - 7 > length(strip(command_line,'T')) then
          nop
        else
          if words(command_line) = words(left(command_line,file.level._COL - 7 + 1)) then
            file.level._COL = 7 + length(command_line)
          else
            file.level._COL = 7 + wordindex(command_line, words(left(command_line,file.level._COL - 7 + 1)) + 1) - 1
      else do
        len = length(strip(file.level.realitem,'T'))
        old = file.level._HOFFSET
        pos = file.level._COL + old - w1_y - 2
        if pos > len | file.level._COL <= w1_y | file.level._COL > w1_y + fwidth then
          nop
        else do
          if words(file.level.realitem) = words(left(file.level.realitem,pos + 1)) then
            file.level._COL = w1_y + 2 + len - old
          else
            file.level._COL = w1_y + wordindex(file.level.realitem, words(left(file.level.realitem,pos + 1)) + 1) - old + 1
          if file.level._COL > w1_y + fwidth then do
            file.level._HOFFSET = 1 + max(0,(((file.level._COL + old - w1_y - 2) % (fwidth % 2))-1))*(fwidth%2)
            file.level._COL = file.level._COL + old - file.level._HOFFSET
            call show
          end
        end
      end
    when abbrev('TOPEDGE',urest,4) then
      file.level._CURRENT = w1_x
    when urest = 'UNDO' then do
      if file.level._CURRENT = commandLine then
        parse value '1 7' with redrawCL file.level._COL command_line
      else do
        drop file.level._PCMD.realitem
        if file.level._CURRENT = currentLine + w1_x - 1 then do
          call VioWrtCharStrAttr file.level._CURRENT, w3_y, file.level._PREFIX.realitem ,,file.level._CPREFIXATTR
          call VioWrtCharStrAttr file.level._CURRENT, w1_y, left(substr(file.level.realitem, file.level._HOFFSET),fwidth),, file.level._CURRENTATTR
        end
        else do
          call VioWrtCharStrAttr file.level._CURRENT, w3_y, file.level._PREFIX.realitem ,,file.level._PREFIXATTR
          call VioWrtCharStrAttr file.level._CURRENT, w1_y, left(substr(file.level.realitem, file.level._HOFFSET),fwidth),, file.level._ATTR.realitem
        end
      end
    end
  otherwise
    call errormsg error.41 rest
  end  /* select */
  return

/* infer the physical key from a keycode -- arg(1) is keycode */
physicalkey: procedure expose definedkeys (definedkeys)
  key = arg(1)
  num = c2d(key)
  do i = 1 for words(definedkeys)
     if value(word(definedkeys, i)) = key then
       return translate(word(definedkeys, i), '-', '_')
  end /* do */
  if num < 32 then
    return 'C-'d2c(num+64)
  return key

/* compute a file name -- arg(1) is item # */
filename: procedure expose file. fmode fpath level
  arg item
  parse var file.level.item fdate ftime fsize feasize fileid
  fileid = fmode':'||fpath||strip(fileid)

  if pos(' ',fileid) \= 0 then
    return '"'fileid'"'
  else
    return fileid

/* expand the OS/2 prompt */
prompt: procedure expose rc
  prmpt = value('PROMPT',,'OS2ENVIRONMENT')
  if (prmpt == '') then
    prmpt = '[$p]'

  str = ''

  do i = 1 to length(prmpt)
    key = substr(prmpt,i,1)
    if (key = '$') then do
      i = i+1; key = translate(substr(prmpt,i,1))
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
        when key = 'I' then nop
        when key = 'L' then str = str||'<'
        when key = 'N' then str = str||filespec("d",directory())
        when key = 'P' then str = str||directory()
        when key = 'Q' then str = str||'='
        when key = 'R' then str = str||rc
        when key = 'S' then str = str||' '
        when key = 'T' then str = str||time()
        when key = 'V' then str = str||'Operating System/2 version' SysOS2Ver()
        when key = '_' then str = str||'0d'x
      otherwise
        str = str||substr(prmpt,i,1)
      end  /* select */
    end
    else
      str = str||key
  end /* do */
  return str

/* compute a command alias */
alias: procedure expose abbr.
  word = translate(arg(1))
  len = length(arg(1))

  if datatype('abbr._'left(word' ',1), 'Symbol') then
    i = value('abbr._'left(word' ',1))
  else
    i = 0

  if i > 0 then
    do i = i to abbr.0
      if len >= abbr.i.min then
        if abbrev(abbr.i.name,word) then
          return abbr.i.name
      if word < abbr.i.name then
        leave
    end /* do */
  return word

/* expand file spec */
expandspec: procedure expose fileexists
  fmode = filespec('d',arg(1))
  fpath = filespec('p',arg(1))
  fname = filespec('n',arg(1))
  if fmode = '' then
    fmode = filespec('d',directory())
  if fpath = '' then do
    current = directory()
    specified = directory(fmode)
    call directory current
    fpath = substr(specified,3)
  end
  if right(fpath,1) \= '\' then
    fpath = fpath||'\'
  if fname = '' then
    fname = '*'
  if pos('*',fname) = 0 then
    fname = fname||'\*'
  if \fileexists then do
    fileexists = stream(fmode||fpath||fname,'c','query exists') \= ''
    if \fileexists then do
      call DosFileTree fmode||fpath||fname, 'FEXIST.'
      fileexists = (FEXIST.0 \= 0)
    end
  end
  if pos(' ',fmode||fpath||fname) > 0 then
    return '"'fmode||fpath||fname'"'
  else
    return fmode||fpath||fname

/* run prefix command for line arg(1), if there is one */
doprefix:
  prefixline = arg(1)
  if symbol('file.'level'._PCMD.'prefixline) = 'VAR' then
    if file.level._PCMD.prefixline \= '' then do
      if file.level._PCMD.prefixline = '*' then do
        drop file.level._PCMD.prefixline
        return
      end
      if file.level._PCMD.prefixline \= '"' then
        cl = file.level._PCMD.prefixline
      call execute 'PREFIX', cl, prefixline
      if cmdrc = 0 then
        file.level._PCMD.prefixline = '*'
    end
  return

/* build the list of files - arg(1) is the specified command line */
list_files:
  parse arg list '(' options
  if list = '' then
    list = '*'
  filespec = ''
  fileexists = 0
  do while list \= ''
    parse value list with pre '"' main '"' list
    do i = 1 to words(pre)
      filespec = filespec expandspec(word(pre,i))
    end /* do */
    if main \= '' then
      filespec = filespec expandspec(main)
  end /* do */
  filespec = strip(filespec)

  /* scan options */
  options = translate(options, ' ', ')')
  parse value '0 0' translate(options) with tree_option sort_option options
  do i = 1 to words(options)
    opt = word(options,i)
    if abbrev('TREE',opt,2) then
      tree_option = 1
    else
    if abbrev('SORTD',opt,4) | abbrev('SORTA',opt,4) then
      sort_option = 1
  end /* do */

  if \fileexists & unzip then
    nop
  else
  if \tree_option & \fileexists then do
    call errormsg error.9 filespec
    return 2
  end

  if sort_option then
    sort = ''
  else
    if tree_option then
      sort = 'sort path sortd d'
    else
      sort = 'sort n'

  call listfile filespec, sort options
  count = file.level.0
  return (rc \= 0)

/* simulate listfile command - arg(1) is a series of directories
                               arg(2) is the options */
listfile: procedure expose file. rc level currentLine commandLine fwidth fileexists unzip tree_option attr. locale. base
  parse arg names, options
  options = translate(options, ' ', ')')
  parse value '0 0 /NAME /EXT /SIZE /DATE' with wide sorts sort_types
  do i = 1 to words(options)
    opt = translate(word(options, i))
    select
      when opt = 'SORT' | opt = 'SORTA' then do
        if i = words(options) then
          break
        i = i + 1
        sorts = sorts + 1
        x = pos('/'translate(word(options, i)), sort_types)
        parse var sort_types =(x) '/' sortype .
        sort.sorts = sortype 'a'
      end
      when opt = 'SORTD' then do
        if i = words(options) then
          break
        i = i + 1
        sorts = sorts + 1
        x = pos('/'translate(word(options, i)), sort_types)
        parse var sort_types =(x) '/' sortype .
        sort.sorts = sortype 'd'
      end
      when abbrev('WIDE',opt,1) | abbrev('(WIDE',opt,2) then wide = 1
      when opt = 'APPEND' | opt = '(APPEND' then nop
    otherwise
    end /* select */
  end /* do */

  count = 1
  do while names \= ''
    parse value names with file _ '"' main '"' names
    select
      when file = '' & main = '' then iterate
      when file = '' then file = main
      when main = '' then names = _ names
    otherwise
      names = _ '"'main'"' names
    end  /* select */
    lastfile = file

    select
      when fileexists then
        /* a real directory */
        if tree_option then
          call DosFileTree file, 'temp.', 'TS'
        else
          call DosFileTree file, 'temp.', 'T'
      when unzip then do
        /* maybe an archive */
        file = left(file, length(file)-2)
        call UZFileTree file, 'temp.', , ,'F'
      end
    otherwise
    end  /* select */

    maxwidth = 0

    do j = 1 to temp.0
      if fileexists then
        parse var temp.j year '/' month '/' day '/' hour '/' min sz ea at fid
      else do
        parse var temp.j sz ea . day '-' month '-' year hour ':' min fspec
        at = '----'
      end
      count = count + 1

      if length(sz) > 9 then
        sz = pp(sz)

      if fileexists then do
        if tree_option then
          fspec = substr(fid,lastpos('\',file)+2)
        else
          fspec = filespec('n', fid)
        if pos('D',at) \= 0 then
          sz = locale.dirLabel
      end
      else do
        if right(fspec,1) = '/' then
          sz = locale.dirLabel
      end

      /* localizing raw result */
      ea = ea / 2
      if ea = 2 then ea = 0
      year = right(year,2)
      select
        when locale.iDate = 0 then date = format(month) || locale.sDate || day || locale.sDate || year
        when locale.iDate = 1 then date = format(day) || locale.sDate || month || locale.sDate || year
        when locale.iDate = 2 then date = year || locale.sDate || month || locale.sDate || day
      end  /* select */
      if locale.iTime = 1 then
        time = format(hour) || locale.sTime || min' '
      else
        if hour < 13 then
          time = format(hour) || locale.sTime || min'a'
        else
          time = format(hour-12) || locale.sTime || min'p'

      file.level.count = right(date,8) right(time,7) right(sz,9) right(ea,11)'  'fspec

      maxwidth = max(maxwidth,length(fspec)+2*(pos('D',at) \= 0))
    end /* do */
  end /* do */
  count = count+1
  if fileexists then
    call initlevel lastfile, "List", wide, maxwidth, base
  else
    call initlevel lastfile, "Archive", wide, maxwidth, base

  sortspec = ''
  first = ''
  last = ''
  do i = 1 to sorts
    parse var sort.i type direction
    select
      when type = 'SIZE' then do
        first = 20
        last = 26
      end
      when type = 'NAME' then
        nop
      when type = 'EXT' then
        nop
      when type = 'DATE' then
        nop
    otherwise
    end /* select */
  end /* do */
  if first \= '' then
    call SysStemSort 'file.'level'.',direction,,2,count-1,first,last

   rc = 0
   return

/* initialize level data  --  arg(1) is level title
                              arg(2) is level type (one of Archive, File, Help or List)
                              arg(3) is wide mode
                              arg(4) is max width
                              arg(5) is base level to use as template */
initlevel:
  procedure expose file. level count currentLine commandLine attr. fwidth
  base = arg(5)
  file.level._PREFIXNUL = file.base._PREFIXNUL
  file.level._PREFIXNUM = file.base._PREFIXNUM
  file.level._PREFIXPOS = file.base._PREFIXPOS
  file.level._PREFIXWIDTH = file.base._PREFIXWIDTH
  file.level._PREFIXGAP = file.base._PREFIXGAP
  file.level._CPREFIXATTR = file.base._CPREFIXATTR
  file.level._PREFIXATTR = file.base._PREFIXATTR
  file.level._PREFIXCMDATTR = file.base._PREFIXCMDATTR
  file.level._ATTR = file.base._ATTR
  file.level._CURRENTATTR = file.base._CURRENTATTR
  file.level._CHIGHLIGHTATTR = file.base._CHIGHLIGHTATTR
  file.level._HIGHLIGHTATTR = file.base._HIGHLIGHTATTR
  file.level._SHADOWATTR = file.base._SHADOWATTR
  file.level.1 = "อออออ Top Of "arg(2)" อออออ"
  file.level._VISIBLE.1 = 1
  file.level._PREFIX.1 = copies(' ',file.level._PREFIXWIDTH)
  file.level._ATTR.1 = attr._TOFEOF
  file.level.count = "อออออ Bottom Of "arg(2)" อออออ"
  file.level._VISIBLE.0 = 0
  file.level._SHADOW.0 = 0
  file.level._PREFIX.count = file.level._PREFIX.1
  file.level._ATTR.count = attr._TOFEOF
  file.level._TOP = -currentLine+3
  file.level._CURRENT = commandLine
  file.level._COL = 7
  file.level._OLDCOL = 7
  file.level._OLDCURRENT = 2
  file.level._CURDIR = translate(arg(1), '\', '/')
  file.level._WIDE = arg(3)
  file.level._MAXWIDTH = arg(4)+2
  file.level._HOFFSET = 1
  file.level._TYPE = arg(2)
  if arg(3) then
    file.level._NCOL = fwidth % (arg(4)+2)
  else
    file.level._NCOL = 1
  file.level.0 = count-1
  do i = 2 to file.level.0
    file.level._ATTR.i = file.level._ATTR
  end /* do */
  call filterlevel ''
  call renumlevel
  return

/* clear visible data */
clearvisible:
  do idx = 2 for file.level._VISIBLE.0
    drop file.level._VISIBLE.idx
  end /* do */
  return

/* clear shadow data */
clearshadow:
  do idx = 1 for file.level._SHADOW.0
    drop file.level._SHADOW.idx
    drop file.level._PREFIX._SHADOW.idx
    drop file.level._ATTR._SHADOW.idx
  end /* do */
  return

/* clear level data */
clearlevel:
  do idx = 1 for file.level.0 + 1
    drop file.level.idx
    drop file.level._PCMD.idx
    drop file.level._PREFIX.idx
    drop file.level._ATTR.idx
  end /* do */
  call clearvisible
  call clearshadow
  drop file.level._TOP
  drop file.level._CURRENT
  drop file.level._COL
  drop file.level._OLDCOL
  drop file.level._OLDCURRENT
  drop file.level._CURDIR
  drop file.level._CHIGHLIGHTATTR
  drop file.level._WIDE
  drop file.level._MAXWIDTH
  drop file.level._HOFFSET
  drop file.level._ATTR
  drop file.level._CPREFIXATTR
  drop file.level._CURRENTATTR
  drop file.level._PREFIXATTR
  drop file.level._PREFIXCMDATTR
  drop file.level._HIGHLIGHTATTR
  drop file.level._SHADOWATTR
  drop file.level._TYPE
  drop file.level._NCOL
  return

/* filter level */
filterlevel: procedure expose file. level inprofile hline width attr. error.
  filter = arg(1)
  joint = ''
  call clearvisible
  if filter = '' then do
    do i = 2 for file.level.0
      file.level._VISIBLE.i = i
    end /* do */
    file.level._VISIBLE.0 = file.level.0
  end
  else do
    parse value strip(filter) with sep +1 filter (sep) _
    filter = translate(filter)
    if _ \= '' then do
      parse value strip(_) with joint _
      parse value strip(_) with sep +1 filter2 (sep) _
      if _ \= '' | (joint \= '|' & joint \= '&') then do
        call errormsg error.39 arg(1)
        return
      end
      filter2 = translate(filter2)
    end
    count = 2
    do i = 2 for file.level.0-1
      line = translate(file.level.i)
      visible = pos(filter, line) \= 0
      if joint \= '' then
        if joint = '|' then
          visible = visible | (pos(filter2, line) \= 0)
        else
          visible = visible & (pos(filter2, line) \= 0)
      if visible then do
        file.level._VISIBLE.count = i
        count = count + 1
      end
    end /* do */
    file.level._VISIBLE.0 = count-1
    file.level._VISIBLE.count = i
  end
  return

/* tag level */
taglevel: procedure expose file. level inprofile hline width attr. error.
  filter = arg(1)
  joint = ''
  if filter = '' then
    do i = 2 for file.level._VISIBLE.0-1
      call value 'file.'level'._ATTR.'file.level._VISIBLE.i, file.level._ATTR
    end /* do */
  else do
    parse value strip(filter) with sep +1 filter (sep) _
    filter = translate(filter)
    if _ \= '' then do
      parse value strip(_) with joint _
      parse value strip(_) with sep +1 filter2 (sep) _
      if _ \= '' | (joint \= '|' & joint \= '&') then do
        call errormsg error.1 arg(1)
        return
      end
      filter2 = translate(filter2)
    end
    do i = 2 for file.level._VISIBLE.0-1
      line = translate(value('file.'level'.'file.level._VISIBLE.i))
      match = pos(filter, line) \= 0
      if joint \= '' then
        if joint = '|' then
          match = match | (pos(filter2, line) \= 0)
        else
          match = match & (pos(filter2, line) \= 0)
      if match then
        call value 'file.'level'._ATTR.'file.level._VISIBLE.i, file.level._HIGHLIGHTATTR
      else
        call value 'file.'level'._ATTR.'file.level._VISIBLE.i, file.level._ATTR
    end /* do */
  end
  return

/* shadow level */
shadowlevel: procedure expose file. level shadow attr. error. fwidth
  indices = ''
  shadows = 0
  last = 0

  /* first iteration : locate gaps */
  call clearshadow
  do i = 2 for file.level._VISIBLE.0
    if datatype(file.level._VISIBLE.i) \= 'NUM' then
      iterate
    if file.level._VISIBLE.i \= last + 1 then
      indices = indices '_SHADOW.'file.level._VISIBLE.i-last-1-(i=2)
    last = file.level._VISIBLE.i
    indices = indices last
  end /* do */

  /* second iteration : rebuild _VISIBLE */
  call clearvisible
  current = 2
  do i = 1 for words(indices)
    what = word(indices, i)
    if shadow = 'ON' then do
      if datatype(what) = 'NUM' then
        file.level._VISIBLE.current = what
      else do
        shadows = shadows + 1
        file.level._SHADOW.shadows = center(' 'substr(what,9)' line(s) not displayed ', fwidth, '-')
        file.level._ATTR._SHADOW.shadows = file.level._SHADOWATTR
        file.level._PREFIX._SHADOW.shadows = '      '
        file.level._VISIBLE.current = '_SHADOW.'shadows
      end
    end
    else do
      if datatype(what) \= 'NUM' then
        iterate
      file.level._VISIBLE.current = what
    end
    current = current + 1
  end /* do */
  file.level._SHADOW.0 = shadows
  file.level._VISIBLE.0 = current-2

  return

/* renumber level */
renumlevel: procedure expose file. level
  if file.level._PREFIXNUL then
    fill = copies(' ',file.level._PREFIXWIDTH-file.level._PREFIXGAP)
  else
    fill = copies('=',file.level._PREFIXWIDTH-file.level._PREFIXGAP)
  if file.level._PREFIXPOS = 'LEFT' & file.level._PREFIXGAP > 0 then
    fill = left(fill,file.level._PREFIXWIDTH)
  if file.level._PREFIXPOS = 'RIGHT' & file.level._PREFIXGAP > 0 then
    fill = right(fill,file.level._PREFIXWIDTH)
  if file.level._PREFIXNUL then
    pad = ' '
  else
    pad = '0'
  if file.level._PREFIXNUM then
    do idx = 2 to file.level.0
      if file.level._PREFIXPOS = 'LEFT' then
        file.level._PREFIX.idx = left(right(idx-1,file.level._PREFIXWIDTH-file.level._PREFIXGAP,pad),file.level._PREFIXWIDTH)
      else
        file.level._PREFIX.idx = right(right(idx-1,file.level._PREFIXWIDTH-file.level._PREFIXGAP,pad),file.level._PREFIXWIDTH)
    end /* do */
  else
    do idx = 2 to file.level.0
      file.level._PREFIX.idx = fill
    end /* do */
  file.level._PREFIX.1 = copies(' ',file.level._PREFIXWIDTH)
  file.level._PREFIX.idx = file.level._PREFIX.1
  return

/* find the first empty level */
findnewlevel:
  iExec = 1
  do while wordpos(iExec, allLevels) \= 0
    iExec = iExec + 1
  end /* do */
  olevel = level
  allLevels = subword(allLevels,1,wordpos(level, allLevels)) iExec subword(allLevels,wordpos(level,allLevels)+1)
  level = iExec
  return
  
/* load a file into a new level */
loadlevel: procedure expose itemnumber allLevels level file. fwidth currentLine commandLine attr. showlevel inprofile hline width attr. beep
  call VioWrtCharStr 0, itemnumber, ' loading...'
  rest = stream(arg(1), 'c', 'query exists')
  if rest \= '' then do
    iExec = 1
    do while wordpos(iExec, allLevels) \= 0
      iExec = iExec + 1
    end /* do */
    olevel = level
    allLevels = subword(allLevels,1,wordpos(level, allLevels)) iExec subword(allLevels,wordpos(level,allLevels)+1)
    level = iExec
    count = 2
    do while lines(rest)
      file.level.count = linein(rest)
      count = count + 1
    end /* do */
    call stream rest, 'c', 'close'
    call initlevel rest, arg(2), 0, fwidth, olevel
    showlevel = level
    level = olevel
  end
  else
    call errormsg arg(3)
  return

/* initialize data and global variables */
main_init:

  if RxFuncQuery("SysLoadFuncs") then do
    call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
    call SysLoadFuncs
  end

  if RxFuncQuery("VioLoadFuncs") then do
    call RxFuncAdd 'VioLoadFuncs', 'REXXVIO', 'VioLoadFuncs'
    call VioLoadFuncs
  end

  unzip = 1
  if RxFuncQuery("UZLoadFuncs") then
    if RxFuncAdd('UZLoadFuncs', 'UNZIP32', 'UZLoadFuncs') then
      unzip = 0
    else
      call UZLoadFuncs

  ESC = '1b'x;                     keys._1B   = 'sos undo'
  ENTER = '0d'x
  BKSP = '08'x;                    keys._08   = 'sos delback'
  TAB = '09'x;                     keys._09   = 'sos tabfieldf'
  S_TAB = '000F'x;                 keys._000F = 'sos tabfieldb'
  DEL = '0053'x;                   keys._0053 = 'sos delchar'
  CURU = '0048'x
  CURD = '0050'x
  CURL = '004b'x
  CURR = '004d'x
  PGUP = '0049'x;                  keys._0049 = 'backward 1'
  PGDN = '0051'x;                  keys._0051 = 'forward 1'
  C_PGUP = '0084'x;                keys._0084 = 'backward *'
  C_PGDN = '0076'x;                keys._0076 = 'forward *'
  HOME = '0047'x;                  keys._0047 = 'cursor home'
  END = '004F'x;                   keys._004F = 'sos startendchar'
  F1 = '003b'x;                    keys._003B = 'help'
  F2 = '003c'x;                    keys._003C = 'reload'
  F3 = '003d'x;                    keys._003D = 'quit'
  F4 = '003e'x;                    keys._003E = 'sname'
  F5 = '003f'x;                    keys._003F = 'smode'
  F6 = '0040'x;                    keys._0040 = 'ssize'
  F7 = '0041'x;                    keys._0041 = 'backward 1'
  F8 = '0042'x;                    keys._0042 = 'forward 1'
  F9 = '0043'x;                    keys._0043 = 'fl'
  F10 = '0044'x
  F11 = '0085'x;                   keys._0085 = 'xedit'
  F12 = '0086'x;                   keys._0086 = 'nextwindow'
  A_F10 = '0071'x
  A_A = '001e'x
  A_B = '0030'x
  A_C = '002e'x
  A_D = '0020'x
  A_E = '0012'x
  A_F = '0021'x
  A_G = '0022'x
  A_H = '0023'x
  A_I = '0017'x
  A_J = '0024'x
  A_K = '0025'x
  A_L = '0026'x
  A_M = '0032'x
  A_N = '0031'x
  A_O = '0018'x
  A_P = '0019'x
  A_Q = '0010'x
  A_R = '0013'x
  A_S = '001f'x
  A_T = '0014'x
  A_U = '0016'x
  A_V = '002f'x
  A_W = '0011'x
  A_X = '002d'x
  A_Y = '0015'x
  A_Z = '002c'x
  A_1 = '0078'x
  A_3 = '007a'x
  A_4 = '007b'x
  A_5 = '007c'x
  A_6 = '007d'x
  A_8 = '007f'x
  A_9 = '0080'x
  A_0 = '0081'x
  A_1 = '0078'x;                   keys._0078 = 'xedit'
  A_X = '002D'x;                   keys._002D = 'xedit'
  S_F5 = '0058'x;                  keys._0058 = 'sos makecurr'
  C_CURL = '0073'x;                keys._0073 = 'sos tabwordb'
  C_CURR = '0074'x;                keys._0074 = 'sos tabwordf'

  definedkeys = 'ESC ENTER BKSP TAB S_TAB DEL CURU CURD CURL CURR PGUP PGDN',
                'C_PGUP C_PGDN HOME END F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12',
                'A_F10 A_A A_B A_C A_D A_E A_F A_G A_H A_I A_J A_K A_L A_M A_N',
                'A_O A_P A_Q A_R A_S A_T A_U A_V A_W A_X A_Y A_Z A_0 A_1 A_2',
                'A_3 A_4 A_5 A_6 A_7 A_8 A_9 S_F5 C_CURR C_CURL'

  /* abbreviations */
  abbr. = 0
  abbr.1.name =  'ALL';            abbr.1.min = 3;     abbr._A = 1
  abbr.2.name =  'BACKWARD';       abbr.2.min = 2;     abbr._B = 2
  abbr.3.name =  'BEEP';           abbr.3.min = 4
  abbr.4.name =  'BOTTOM';         abbr.4.min = 3
  abbr.5.name =  'CASE';           abbr.5.min = 4;     abbr._C = 5
  abbr.6.name =  'CCANCEL';        abbr.6.min = 2
  abbr.7.name =  'CMDARROWS';      abbr.7.min = 4
  abbr.8.name =  'CMDLINE';        abbr.8.min = 3
  abbr.9.name =  'CMSG';           abbr.9.min = 4
  abbr.10.name = 'COLOR';          abbr.10.min = 5
  abbr.11.name = 'COLOUR';         abbr.11.min = 6
  abbr.12.name = 'CURLINE';        abbr.12.min = 4
  abbr.13.name = 'CURSOR';         abbr.13.min = 3
  abbr.14.name = 'DEFINE';         abbr.14.min = 3;    abbr._D = 14
  abbr.15.name = 'DOS';            abbr.15.min = 3
  abbr.16.name = 'DOSNOWAIT';      abbr.16.min = 4
  abbr.17.name = 'DOWN';           abbr.17.min = 1
  abbr.18.name = 'EDIT';           abbr.18.min = 1;    abbr._E = 18
  abbr.19.name = 'EMSG';           abbr.19.min = 4
  abbr.20.name = 'EQUIVCHAR';      abbr.20.min = 6
  abbr.21.name = 'EXTRACT';        abbr.21.min = 3
  abbr.22.name = 'FLIST';          abbr.22.min = 2;    abbr._F = 22
  abbr.23.name = 'FORWARD';        abbr.23.min = 2
  abbr.24.name = 'HELP';           abbr.24.min = 4
  abbr.25.name = 'HIGHLIGHT';      abbr.25.min = 4;    abbr._H = 25
  abbr.26.name = 'IMPCMSCP';       abbr.26.min = 3;    abbr._I = 26
  abbr.27.name = 'IMPOS';          abbr.27.min = 5
  abbr.28.name = 'LEFT';           abbr.28.min = 2;    abbr._L = 28
  abbr.29.name = 'LINEFLAG';       abbr.29.min = 8
  abbr.30.name = 'LOCATE';         abbr.30.min = 1
  abbr.31.name = 'MACRO';          abbr.31.min = 5;    abbr._M = 31
  abbr.32.name = 'MSG';            abbr.32.min = 3
  abbr.33.name = 'MSGLINE';        abbr.33.min = 4
  abbr.34.name = 'NEXT';           abbr.34.min = 1;    abbr._N = 34
  abbr.35.name = 'NEXTWINDOW';     abbr.35.min = 5
  abbr.36.name = 'NUMBER';         abbr.36.min = 3
  abbr.37.name = 'OS';             abbr.37.min = 2;    abbr._O = 37
  abbr.38.name = 'OSNOWAIT';       abbr.38.min = 3
  abbr.39.name = 'PAGEWRAP';       abbr.39.min = 8;    abbr._P = 39
  abbr.40.name = 'PENDING';        abbr.40.min = 4
  abbr.41.name = 'PREFIX';         abbr.41.min = 3
  abbr.42.name = 'PREVWINDOW';     abbr.42.min = 5
  abbr.43.name = 'QUERY';          abbr.43.min = 1;    abbr._Q = 43
  abbr.44.name = 'QUIT';           abbr.44.min = 4
  abbr.45.name = 'RELOAD';         abbr.45.min = 5;    abbr._R = 45
  abbr.46.name = 'RESET';          abbr.46.min = 3
  abbr.47.name = 'RIGHT';          abbr.47.min = 2
  abbr.48.name = 'RUN';            abbr.48.min = 3
  abbr.49.name = 'SCOPE';          abbr.49.min = 5;    abbr._S = 49
  abbr.50.name = 'SCREEN';         abbr.50.min = 3
  abbr.51.name = 'SET';            abbr.51.min = 3
  abbr.52.name = 'SHADOW';         abbr.52.min = 6
  abbr.53.name = 'SHOWKEY';        abbr.53.min = 4
  abbr.54.name = 'SLK';            abbr.54.min = 3
  abbr.55.name = 'SOS';            abbr.55.min = 3
  abbr.56.name = 'UP';             abbr.56.min = 1;    abbr._U = 56
  abbr.57.name = 'XEDIT';          abbr.57.min = 1;    abbr._X = 57
  abbr.0 = 57

  olditem = ''; base = 'INIT'

  parse value '1 1 1' SysTextScreenSize() SysCurPos(),
        with showlevel level allLevels height width row col command_line command.

  height = height - 3

  parse value height%2 width-11 '2 0 0 0 0 0 0',
        with M itemnumber item olevel cmdpos cmdnum redrawCL quit executed

  rod = '--- renamed or discarded ---          '

  cmdarrows = 'RETRIEVE'
  scope = 'DISPLAY'
  highlight = 'OFF'
  pagewrap = 'ON'
  file.base._PREFIXPOS = 'LEFT'
  file.base._PREFIXNUL = 0
  file.base._PREFIXNUM = 0
  file.base._PREFIXWIDTH = 6
  file.base._PREFIXGAP = 0
  shadow = 'ON'
  inmacro = 0

  mixed = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

  /* main area color */
  parse value '116 23 49 49 49 113 116 31 31 63 62 116 49',
        with attr._ERRORATTR file.base._ATTR attr._CMDATTR attr._ARROWATTR,
             file.base._PREFIXATTR attr._MSGATTR file.base._PREFIXCMDATTR,
             file.base._CURRENTATTR,
             attr._TOFEOF file.base._HIGHLIGHTATTR file.base._CHIGHLIGHTATTR,
             file.base._SHADOWATTR file.base._CPREFIXATTR

  /* SETtable values */
  parse value mixed width-file.base._PREFIXWIDTH height+1 '1 7 2 0 =',
        with  case  fwidth  commandLine impos currentLine hLine beep EQUIVChar

  /* key names */
  keyname.1 = 'Help'
  keyname.2 = 'Reload'
  keyname.3 = 'Quit'
  keyname.4 = 'Sort(type)'
  keyname.5 = 'Sort(date)'
  keyname.6 = 'Sort(size)'
  keyname.7 = 'Backward'
  keyname.8 = 'Forward'
  keyname.9 =  'FL /n'
  keyname.10 = ''
  keyname.11 = 'XEDIT'
  keyname.12 = 'NextW'

  /* locale */
  locale.dirLabel = strip(SysGetMessage(1054)) /* <DIR> */
  ci = DosQueryCtryInfo()
  locale.iDate = c2d(substr(ci,9,1))   /* 0 = MDY, 1 = DMY, 2 = YMD */
  locale.iTime = c2d(substr(ci,28,1))  /* 0 = 12 Hour clock, 1 = 24 */
  locale.sDate = substr(ci,22,1)       /* '/' */
  locale.sTime = substr(ci,24,1)       /* ':' */

  /* error messages */
  error.0  = 'Error 0000: Invalid command:'
  error.1  = 'Error 0001: Invalid operand:'
  error.2  = 'Error 0002: File not found:'
  error.3  = 'Error 0003: File not found in archive:'
  error.8  = 'Error 0008: Help file not found'
  error.9  = 'Error 0009: Files not found:'
  error.10 = 'Error 0010: Target not found:'
  error.11 = 'Error 0011: Too few operands'
  error.12 = 'Error 0012: Too many operands:'
  error.37 = 'Error 0037: Operand too long:'
  error.38 = 'Error 0038: No prefix commands allowed in this context:'
  error.39 = 'Error 0039: Invalid argument for ALL:'
  error.40 = 'Error 0040: SOS commands must be bound to a key:'
  error.41 = 'Error 0041: Invalid SOS command:'
  error.53 = 'Error 0053: Valid only when issued from a REXX macro'

  /* profile support */
  profileName = 'profile.fl'

  level = base

  parse upper value arg(1) with _ '(N' +0 profile
  if abbrev('(NOPROFILE', strip(translate(word(profile,1), ' ', ')')),2) then
    profileName = ''

  parse upper value arg(1) with _ '(P' +0 profile
  if abbrev('(PROFILE', word(profile,1),2) then
    profileName = strip(subword(translate(profile, ' ', ')'),2))

  inprofile = 1
  if profileName \= '' then
    profileFile = SysSearchPath('DPATH',profileName)
  else
    profileFile = ''
  if profileFile \= '' then
    call macro profileFile

  level = 1
  if list_files(arg(1)) \= 0 then
    exit 3
  inprofile = 0

  return

/* execute macro -- arg(1) is full macro filename */
macro:
  inmacro = inmacro+1
  parse arg macro.inmacro args
  call stream macro.inmacro, 'c', 'open read'
  do while lines(macro.inmacro)
    line = linein(macro.inmacro)
    if left(line,1) = "'" | left(line,1) = '"' then
      call execute 'CMDLINE', strip(line,,left(line,1))
    else
      interpret line
  end /* do */
  call stream macro.inmacro, 'c', 'close'
  inmacro = inmacro-1
  return

/* compute windows offsets */
adjustwindows:
  if inprofile then
    return

  fwidth = width - file.level._PREFIXWIDTH

  w0 = 0 0;                               w0_x = word(w0,1); w0_y = word(w0,2) /* info */
  w1 = 1 + (commandLine = 1) file.level._PREFIXWIDTH; w1_x = word(w1,1); w1_y = word(w1,2) /* file */
  w2 = commandLine 6;                     w2_x = word(w2,1); w2_y = word(w2,2) /* command */
  w3 = 1 + (commandLine = 1) 0;           w3_x = word(w3,1); w3_y = word(w3,2) /* prefix */
  w4 = height+2 0;                        w4_x = word(w4,1); w4_y = word(w4,2) /* keys */

  if file.level._PREFIXPOS = 'RIGHT' then do
    w1_y = 0;      w1 = w1_x w1_y
    w3_y = fwidth; w3 = w3_x w3_y
  end

  call drawall

  return

/* convert color name to color # */
color: procedure expose hline width attr. inprofile error. beep
  arg word1 rest
  parse value '0 0 0 BLACK BLUE GREEN CYAN RED MAGENTA YELLOW WHITE' with col bg on name
  do while word1 \= ''
    select
      when \bg & word1 = 'BLINK' then col = col + 128
      when \bg & wordpos(word1,'BOLD BRIGHT HIGH') > 0 then col = col + 8
      when \bg & wordpos(word1,name) > 0 then do
        col = col + wordpos(word1,name) - 1
        bg = 1
      end
      when \on & word1 = 'ON' then do
        on = 1
        bg = 1
      end
      when \bg & word1 = 'ON' then
        bg = 1
      when bg & wordpos(word1,name) > 0 then col = col + 16 * (wordpos(word1,name)-1)
    otherwise
      call errormsg error.1 word1
      return arg(2)
    end  /* select */
    parse value rest with word1 rest
  end /* do */
  return col

/* convert color # to color name */
colorname: procedure
   col = d2c(arg(1))
   name = ''
   names = 'BLACK BLUE GREEN CYAN RED MAGENTA YELLOW WHITE'
   if bitand(col, '80'x) = '80'x then
     name = name 'BLINK'
   if bitand(col, '08'x) = '08'x then
     name = name 'BOLD'
   name = name word(names, 1+c2d(bitand(col,'07'x))) 'ON' word(names, 1+(c2d(bitand(col,'70'x)) / 16))
   return strip(name)

/* quick and dirty rexxlib replacement funcs */
w_put:
  if arg(5) = '' then
    return VioWrtCharStrAttr(word(arg(1),1)+arg(2)-1,word(arg(1),2)+arg(3)-1,arg(4),,arg(6))
  else
    return VioWrtCharStrAttr(word(arg(1),1)+arg(2)-1,word(arg(1),2)+arg(3)-1,left(arg(4),arg(5)),arg(5),arg(6))

inkey: procedure
  key  = SysGetKey("NOECHO")

  if (key = "E0"x) | (key = "00"x) then
    return "00"x || SysGetKey("NOECHO")
  else
    return key

debug:
  call VioWrtCharStrAttr 0, 0, left(arg(1),width), width, attr._ERRORATTR
  return
