/******************************************************************/
/*                               Toby Thurston --- 30 Aug 2004    */
/******************************************************************/
/* Check all the functions calls in a REXX program.               */
/* List them by type and line number                              */
/*                                                                */
/* 2004-08-30 Bug fix -- call 'NAME' correctly flagged when name: */
/*            label exists.                                       */
/* 2004-08-13 Bug fixes -- see changes file                       */
/* 2004-08-04 Restructured parsing                                */
/*            Better interpretation of CALL and SIGNAL and other  */
/*            keywords.                                           */
/* 2004-07-26 Also list variables                                 */
/* 2003-05-07 corrected bug with detecting external commands      */
/*            literals after explicit ';'s are now also shown as  */
/*            external cmds, and literals after line              */
/*            continuations are not. (which I think is better).   */
/* 2003-02-13 corrected bug in the preceding correction           */
/*            comments with odd numbers of stars caused loop      */
/* 2001-07-06 corrected a bug in get_token, p not incremented     */
/* when COMMENT returned                                          */
/* 2001-07-06 added feature to list calls to external environment */
/******************************************************************/
/* set trace state                                                */
/******************************************************************/
trace 'O'
/******************************************************************/
/* read the command line                                          */
/******************************************************************/
parse arg cmdline
f. = ''
n = 0
options = ''
do while length(cmdline)>0
  cmdline = strip(cmdline)/* leading and trailing spaces never significant */
  ? = left(cmdline,1)
  select
    when ? = '"' then do
      n = n + 1
      parse var cmdline '"' f.n '"' cmdline
    end
    when ? = '-' | ? = '/' then do
      parse var cmdline option cmdline
      option = strip(option,,?)
      options = options''translate(left(option,1))
    end
  otherwise
    n = n + 1
    parse var cmdline f.n cmdline
  end
end
debug? = pos('D',options)>0
help?  = pos('H',options)>0
in = f.1
out = f.2

if help? | in=''
  then do
    say 'Usage: [rexx] checkfunc infile [outfile] [-d] [-h]'
    say
    say 'Options: -h give this help'
    say '         -d write token list to STDERR'
    say '            (You probably should redirect STDERR with "2>file")'
    exit 'Help'
  end
/******************************************************************/
/* Look for the input file                                        */
/******************************************************************/
in = stream(in,'c','query exists')
if in=''
  then do
    call lineout 'stderr', "Can't find" in
    exit 'Missing'
  end
/******************************************************************/
/* read the input source                                          */
/******************************************************************/
do i = 1 while lines(in) > 0
  source.i = strip(linein(in))
  s_len.i = length(source.i)
end
call lineout in
s_lines = i-1
/******************************************************************/
/* Stop now if nothing read                                       */
/******************************************************************/
if s_lines = 0
  then do
    call lineout 'stderr', 'No lines read from' in
    exit 'Empty'
  end
/******************************************************************/
/* Stop now if source doesn't start with a REXX comment           */
/*                                                                */
/* Note this does not guarantee that the source *IS* REXX, but it */
/* helps to prevent accidents.  This code will (probably) hang if */
/* you run it with a source that is not valid REXX                */
/******************************************************************/
s = 1                                  /* line counter            */
if left(source.s,2) = '#!' then s=2;   /* skip shebang line */
if left(source.s,2) <> '/*'
  then do
    call lineout 'stderr', 'No leading REXX comment in' in
    exit 'Not Rexx'
  end
/******************************************************************/
/* Stop now if this is compiled Rexx                              */
/******************************************************************/
if pos('00'x,source.1)>0
  then do
    call lineout 'stderr', 'Source has binary nulls in first line.  Probably compiled.'
    exit 'Compiled'
  end
/******************************************************************/
/* Load rexxutil                                                  */
/******************************************************************/
call rxfuncadd "SYSLOADFUNCS", "rexxutil", "SYSLOADFUNCS"
call 'SYSLOADFUNCS'

/******************************************************************/
/* Delete the output file if any                                  */
/******************************************************************/
if out <> ''
  then if stream(out,'c','query exists') <> ''
    then call 'SYSFILEDELETE' out

/******************************************************************/
/* Initialize the data structures and control variables           */
/*                                                                */
/* As normal the function structure is implemented as a series of */
/* linked REXX stem variables.                                    */
/* Count. is indexed by the function name and is incremented each */
/* time that a function is found.  BIFs that are not used will    */
/* have a count. of 0 because of the initial value here           */
/*                                                                */
/* Type is indexed by the func name and the count.func:  it may   */
/* be either 'SYM' or 'LIT'.  It will only be 'LIT' is the        */
/* function name was written in 'quotes'.                         */
/*                                                                */
/* Refs is also index by func name and count.func and it holds    */
/* list of source line numbers where the function is called.      */
/*                                                                */
/* Func_list is a list of all the (unique) function names found.  */
/*                                                                */
/* All these are updated in ADD_FUNCTION, to which (func_vars)    */
/* are exposed.                                                   */
/*                                                                */
/* done. is a boolean stem indexed by function name.  Its updated */
/* as we list each function at the end and finally used to find   */
/* external functions, as these will be the only ones not 'done'  */
/* by the end.                                                    */
/******************************************************************/
count. = 0              /* count of how many times a func is used */
type. = 'SYM'                          /* type of each func       */
refs. = 0              /* line number of each use of the function */
done. = 0                    /* have we finished with a function? */
func_list = ''                    /* a list of all functions used */
modules = ''                      /* list of "::required" modules */
func_vars = 'func_list count. refs. type. done. modules'
/******************************************************************/
/* Labels are a bit simpler, we just keep two lists: one for each */
/* label as it occurs and another for any duplicates.  label_ref. */
/* is indexed by label name and holds the source reference for the*/
/* label.  Because we initialize it to 0, then if it is >0 when we*/
/* find a given label we know that we have a duplicate.           */
/******************************************************************/
labels = ''
duplicate_labels = ''
label_ref. = 0
label_vars = 'labels duplicate_labels label_ref.'
/******************************************************************/
/* vars    are even simpler                                       */
/* vars is a list of variable names used as blank separated words */
/* var_assigned. is a list of line numbers where the variable     */
/*      is assigned                                               */
/* var_used is a list of line numbers where it is used ...        */
/* stems is the same but for compound variables                   */
/******************************************************************/
vars = ''
var_assigned. = ''
var_used. = ''
stems = ''
stem_assigned. = ''
stem_updated. = ''
stem_used. = ''
var_vars = 'vars var_assigned. var_used. stems stem_assigned. stem_updated. stem_used.'
/******************************************************************/
/* Same thing for external commands                               */
/******************************************************************/
commands = ''                      /* a list of external commands */
command_refs. = ''    /* holds line numbers for external commands */
cmd_vars = 'commands command_refs.'

/******************************************************************/
/* charset table used in tokenizer --- does not include ª         */
/******************************************************************/
charset=' _abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ?!',
      ||'1234567890+/-*%&|=<>\',
      ||'.():"'';,'                    /* note blank at start     */
typeset='bsssssssssssssssssssssssssssssssssssssssssssssssssssssss',
      ||'nnnnnnnnnnooooooooooo',
      ||'.():"'';,s'        /* extra s matches unknowns as symbol */

/******************************************************************/
/* Gather the tokens into clauses.                                */
/******************************************************************/
t_type. = ';'
t_value. = ''
t_line. = ''
t = 0                                  /* token counter           */
p = 1                                  /* position in the line    */
last_type  = ';'        /* the type of the previously found token */

do forever                          /* get_token updates s & p... */
  parse value get_token() with t_type t_value

  select
    when t_type = 'EOF'  then leave
    when t_type = 'COMMENT' then iterate
    when t_type = 'EOL' & last_type <> ',' then t_type = ';'
  otherwise
  end

  if t_type = ';'   & last_type = ';' then iterate

  t = t + 1
  t_type.t  = t_type
  t_value.t = t_value
  t_line.t  = s
  last_type  = t_type
end

if debug? then do
  do i = 1 to t
    call lineout 'stderr', t_line.i '>' t_type.i t_value.i
    if t_type.i=';' then
      call lineout 'stderr', '---------------------------------------------------'
  end
end

/******************************************************************/
/* Loop through looking for function calls and labels.  At this   */
/* point we can now do things by clause.  At the start of the     */
/* clause, we either have                                         */
/*                                                                */
/* - an assignment if the first is a symbol and the second token  */
/*   starts with '='                                              */
/* - keyword (even if it's followed by ( ) if its a symbol and    */
/*   the value is one of the keywords                             */
/* - a label if the first is a symbol and the second is ':'       */
/* - a command                                                    */
/* - an O'Rexx directive                                          */
/******************************************************************/
keywords = 'ADDRESS ARG CALL DO DROP',
           'EXIT IF INTERPRET ITERATE',
           'LEAVE NOP NUMERIC OPTIONS PARSE' ,
           'PROCEDURE PULL PUSH QUEUE RETURN SAY SELECT',
           'SIGNAL TRACE USE',
           'ELSE OTHERWISE END WHEN'

do i = 1 to t
  next = i+1
  select
    when t_type.i = 'SYMBOL' & t_type.next = 'OP' & t_value.next = '='
      then do
        call add_assignment t_value.i, t_line.i
        i = i + 1
        call do_expression
      end

    when (t_type.i = 'SYMBOL' | t_type.i = 'CONSTANT' ) & t_type.next = ':'
      then do
        call add_label t_value.i, t_line.i
        i = i + 1
      end

    when t_type.i = 'SYMBOL' & wordpos(t_value.i,keywords)>0
      then call do_keyword

    when t_type.i = ':' & t_type.next = ':'/* O'Rexx directives ... */
      then do
        i = i + 2
        select
          when t_value.i = 'ROUTINE' then do
            i = i + 1
            call add_label t_value.i, t_line.i
            i = i + 1
          end
          when t_value.i = 'REQUIRES' then do
            i = i + 1
            if wordpos(t_value.i,modules)=0 then modules = modules t_value.i
          end
        otherwise
        end
        call do_expression
      end

    when t_type.i = ';' then iterate/* eg after a label with no procedure */

  otherwise
    call add_command t_type.i, t_value.i, t_line.i
    if t_type.i='SYMBOL' then i=i-1/* back up to include the command if it's a variable */
    call do_expression
  end
end

/******************************************************************/
/* Define names of known functions                                */
/******************************************************************/
core_bifs = 'ABBREV ABS ADDRESS ARG B2X BITAND BITOR BITXOR C2D C2X CENTER',
            'CENTRE COMPARE CONDITION COPIES D2C D2X DATATYPE DATE DELSTR',
            'DELWORD DIGITS ERRORTEXT FORM FORMAT FUZZ INSERT LASTPOS LEFT',
            'LENGTH MAX MIN OVERLAY POS QUEUED RANDOM REVERSE RIGHT SIGN',
            'SOURCELINE SPACE STRIP SUBSTR SUBWORD SYMBOL TIME TRACE',
            'TRANSLATE TRUNC VALUE VERIFY WORD WORDINDEX WORDLENGTH WORDPOS',
            'WORDS X2B X2C X2D XRANGE'

io_bifs = 'CHARIN CHAROUT CHARS LINEIN LINEOUT LINES STREAM QUALIFY FILESPEC'
rx_bifs = 'RXFUNCADD RXFUNCDROP RXFUNCQUERY'
new_bifs = 'CHANGESTR COUNTSTR'

modern_bifs = word_sort(new_bifs rx_bifs io_bifs)

arexx_bifs  = 'B2C BITCHG BITCLR BITCOMP BITSET BITTST C2B CLOSE COMPRESS',
              'EOF EXISTS EXPORT FREESPACE GETSPACE HASH IMPORT',
              'OPEN RANDU READCH READLN SEEK SHOW TRIM WRITECH WRITELN'
regina_bifs = 'CD CHDIR CRYPT FORK GETENV GETPID GETTID LOWER POOLID',
              'RXFUNCERRMSG UNAME UNIXERROR UPPER'
mainframe_bifs = 'BUFTYPE DESBUF DROPBUF MAKEBUF EXTERNALS GETMSG JUSTIFY LINESIZE MSG MVSVAR OUTTRAP PROMPT',
                 'SETLANG STORAGE SYSCPUS SYSDSN SYSVAR USERID SLEEP STATE INDEX FIND'
os2_bifs = 'BEEP DIRECTORY SETLOCAL ENDLOCAL RXQUEUE'
dbcs_bifs = 'DBADJUST DBRIGHT DBUNBRACKET DBBRACKET DBRLEFT DBVALIDATE',
            'DBCENTER DBRRIGHT DBWIDTH DBCJUSTIFY DBTODBCS DBLEFT DBTOSBCS'

exotic_bifs = word_sort(arexx_bifs mainframe_bifs os2_bifs regina_bifs dbcs_bifs)

ru_core = 'SYSCLS SYSCURPOS SYSCURSTATE SYSDRIVEINFO SYSFILEDELETE',
          'SYSFILESEARCH SYSFILETREE SYSGETKEY SYSMKDIR SYSOS2VER',
          'SYSRMDIR SYSSEARCHPATH SYSSLEEP SYSTEMPFILENAME SYSTEXTSCREENSIZE',
          'SYSLOADFUNCS SYSDROPFUNCS'

ru_ver2 = 'SYSSTEMCOPY SYSSTEMDELETE SYSSTEMINSERT SYSSTEMSORT'

ru_os2 = 'SYSCOPYOBJECT SYSCREATEOBJECT SYSCREATESHADOW',
        'SYSDEREGISTEROBJECTCLASS SYSDESTROYOBJECT SYSDRIVEMAP',
        'SYSDROPFUNCS SYSGETEA SYSGETMESSAGE SYSINI SYSMOVEOBJECT',
        'SYSOPENOBJECT SYSPUTEA SYSQUERYCLASSLIST SYSREGISTEROBJECTCLASS',
        'SYSSAVEOBJECT SYSSETICON SYSSETOBJECTDATA SYSTEXTSCREENREAD',
        'SYSWAITNAMEDPIPE'

ru_win = 'SYSWINVER'

rxsock_bifs = 'SOCKACCEPT SOCKBIND SOCKCLOSE SOCKCONNECT SOCKDROPFUNCS SOCKGETHOSTBYADDR',
         'SOCKGETHOSTBYNAME SOCKGETHOSTID SOCKGETPEERNAME SOCKGETSOCKNAME SOCKGETSOCKOPT',
         'SOCKINIT SOCKIOCTL SOCKLISTEN SOCKLOADFUNCS SOCKPSOCK_ERRNO SOCKRECV',
         'SOCKRECVFROM SOCKSELECT SOCKSEND SOCKSENDTO SOCKSETSOCKOPT SOCKSHUTDOWN',
         'SOCKSOCLOSE SOCKSOCK_ERRNO SOCKSOCKET SOCKVERSION'

special_variables = 'RESULT RC SIGL ERRNO H_ERRNO'

/******************************************************************/
/* Start writing the output                                       */
/******************************************************************/
/* NB Dont change the text below without also updating IMEDIT.X   */
/******************************************************************/
call lineout out, 'Function analysis of' stream(in,'c','query exists')
call lineout out, ' '
/******************************************************************/
/* produce a list of bifs                                         */
/******************************************************************/
call list_funcs core_bifs,  'Core BIFs used (should work on all interpreters)'
call list_funcs modern_bifs,  'Newer BIFs (probably not good on CMS or TSO)'
call list_funcs exotic_bifs,  'Exotic BIFs (avoid for portability)'

/******************************************************************/
/* produce a list of internal functions                           */
/******************************************************************/
call lineout out, 'Internal functions'
call lineout out, '------------------'
labels = word_sort(labels)
do i = 1 to words(labels)
  bif = word(labels,i)
  done.bif = 1
  ? = label_ref.bif
  call lineout out, bif': ('count.bif')'
  call lineout out, right(?,6) source.?
  call lineout out, ' '
  do j = 1 to count.bif
    ref = refs.bif.j
    type = type.bif.j
    call lineout out, right(ref,6) source.ref
    if type = 'LIT'
      then do
        call lineout out, right(' ',6) copies('^',length(source.ref))
        if wordpos(bif,core_bifs modern_bifs)>0
          then msg = 'BIF'
          else do
            msg = 'external function'
            done.bif=2
          end
        call lineout out, right(' ',6) 'Direct call to' msg 'bypasses internal function'
      end
  end
  call lineout out, ' '
end
if i=1 then call lineout out, "None."
call lineout out, ' '

/******************************************************************/
/* Show any duplicate (and therefore unreachable labels           */
/******************************************************************/
call lineout out, 'Duplicate (and therefore unreachable) labels'
call lineout out, '--------------------------------------------'
duplicate_labels = word_sort(duplicate_labels)
do i = 1 to words(duplicate_labels)
  parse value word(duplicate_labels,i) with label ':' ref
  call lineout out, label':'
  call lineout out, right(ref,6) source.ref
end
if i = 1 then call lineout out, 'None.'
call lineout out, ' '

/******************************************************************/
/* produce a list of common external library functions            */
/******************************************************************/
call list_funcs ru_core, 'Rexxutil common functions'
call list_funcs ru_os2, 'Rexxutil OS/2 only functions'
call list_funcs ru_win, 'Rexxutil Windows only functions'
call list_funcs ru_ver2, 'Rexxutil Version 2 functions'
call list_funcs rxsock_bifs, 'RxSock functions'

/******************************************************************/
/* Now any that are not done must be external                     */
/*                                                                */
/* So we list them and find the external function for each one    */
/******************************************************************/
call lineout out, 'External functions'
call lineout out, '------------------'
call lineout out, ' '

rexx_entensions = '.cmd .rexx .rex'
none? = 1

func_list = word_sort(func_list)
do i = 1 to words(func_list)
  f = word(func_list,i)
  if done.f=1 then iterate       /* skip if we've already done it */

  /* if we get here we have at least 1 external function */
  none? = 0

  /* print the name of the function */
  call lineout out, f':'

  found = 0
  /* first look for the external function in any ::requires modules */
  do j=1 to words(modules)
    target = '::routine' f 'public'
    file = word(modules,j)
    if pos('.',file)=0 then file = file'.rex'
    call SysFileSearch target, file, 'temp'
    if result=0 & temp.0>0 then do
      call lineout out, '  Function found in' file':' temp.1
      found = 1
    end
  end

  if \found then  /* then look for it in the PATH */
  do j = 1 to 1+words(rexx_entensions)/* +1 to allow for no ext */
    file = space(f''word(rexx_entensions,j))
    call 'SYSSEARCHPATH' 'PATH', file
    if result <> '' then do            /* found one               */
      /* now check exact spelling of file name */
      file = result
      call 'SYSFILETREE' file, 'temp', 'FO'
      if result=0 & temp.0=1 & temp.1 \== file
        then call lineout out, '  Function found:' temp.1 '"<-- Case of name differs from call"'
        else call lineout out, '  Function found:' file
      found = 1
    end
  end

  if \found then
  call lineout out, '  "No external function found in PATH or any ::REQUIRED module"'

  /* show references as above */
  do k = 1 to count.f
    ref = refs.f.k
    type = type.f.k
    if done.f = 2/* special case for LITERAL calls overriding internal ones */
      then do;if type='LIT' then call lineout out, right(ref,6) type source.ref;end
      else call lineout out, right(ref,6) type source.ref
  end

  call lineout out, ' '

end
if none? then call lineout out, "None."
/******************************************************************/
/* print out any external commands                                */
/******************************************************************/
call lineout out, ' '
call lineout out, 'Commands to external environments'
call lineout out, '---------------------------------'
if words(commands) = 0
  then call lineout out, "None."
  else do
    commands = word_sort(commands)
    do i = 1 to words(commands)
      cmd = word(commands,i)
      count = words(command_refs.cmd)
      if left(cmd,3)='LIT'
        then call lineout out, "'"substr(cmd,4)"' ("count')'
      else if left(cmd,3)='SYM'
        then call lineout out, 'Value of:' substr(cmd,4) '('count')'
      else call lineout out, cmd '('count')'
      do j = 1 to count
        ref = word(command_refs.cmd,j)
        call lineout out, right(ref,6) source.ref
      end
    end
  end
/******************************************************************/
/* Print the symbol index if necessary                            */
/******************************************************************/
if words(vars)>0 then do
  call lineout out, ' '
  call lineout out, 'Simple Variables Index'
  call lineout out, '----------------------'
  vars = word_sort(vars)
  do i = 1 to words(vars)
    w = word(vars,i)
    if wordpos(w,special_variables)=0
      then call lineout out, w
      else call lineout out, w '<----------- Special variable, assigned probably should be 0'

    call lineout out, '  Assigned: ('words(var_assigned.w)')'
    do j = 1 to words(var_assigned.w)
      s = word(var_assigned.w,j)
      call lineout out, right(s,6) source.s
    end

    call lineout out, '  Used: ('words(var_used.w)')'
    do j = 1 to words(var_used.w)
      s = word(var_used.w,j)
      call lineout out, right(s,6) source.s
    end
    call lineout out, ' '
  end
end

if words(stems)>0 then do
  call lineout out, ' '
  call lineout out, 'Compound Variables Index'
  call lineout out, '------------------------'
  stems = word_sort(stems)
  do i = 1 to words(stems)
    w = word(stems,i)
    if words(stem_assigned.w stem_updated.w) = 0
      then call lineout out, w '<----- Possibly assigned by external function'
      else call lineout out, w
    call lineout out, '  Initialised: ('words(stem_assigned.w)')'
    do j = 1 to words(stem_assigned.w)
      s = word(stem_assigned.w,j)
      call lineout out, right(s,6) source.s
    end
    call lineout out, '  Updated: ('words(stem_updated.w)')'
    do j = 1 to words(stem_updated.w)
      s = word(stem_updated.w,j)
      call lineout out, right(s,6) source.s
    end
    call lineout out, '  Used: ('words(stem_used.w)')'
    do j = 1 to words(stem_used.w)
      s = word(stem_used.w,j)
      call lineout out, right(s,6) source.s
    end
    call lineout out, ' '
  end
end

/******************************************************************/
/* Finally close the file                                         */
/******************************************************************/
if out <> '' then call lineout out

exit 0

/******************************************************************/
/* A mini REXX tokeniser.                                         */
/* Notice that for the current application we don't need a CLAUSER*/
/* because we don't care where the clauses are, we just need to   */
/* examine the sequence of tokens                                 */
/*                                                                */
/* Returns the type of token followed by the value (if any)       */
/*                                                                */
/* We also expose the source information:  source.  itself, the   */
/* corresponding array s_len.  which has the length of each line  */
/* and s_lines the total number of lines read, as well as 's' and */
/* 'p' which point at the source line and column number           */
/* respectively.                                                  */
/*                                                                */
/* We also need charset which defines the valid REXX character    */
/* set and typeset which defines the type of each character.      */
/*                                                                */
/* Note that comments are not tokens (see TRL2), but we still     */
/* return them (and then do nothing with them) as this is the way */
/* I wrote it.  Comments do nothing except separate adjacent      */
/* tokens.                                                        */
/*                                                                */
/* The type of token returned are as follows                      */
/*      Name            Returns a value                           */
/*      EOF             No                                        */
/*      EOL             No                                        */
/*      BLANK           No                                        */
/*      COMMENT         No                                        */
/*      SYMBOL          Yes                                       */
/*      LITERAL         Yes                                       */
/*      CONSTANT        Yes   (includes numbers)                  */
/*      OP              Yes                                       */
/*      special         Yes one of: .():;,                        */
/******************************************************************/
get_token: procedure expose s_lines s p source. s_len. charset typeset
  if s > s_lines then return 'EOF'     /* off the end of the file */
  had_blank = 0
  if p > s_len.s                       /* off the end of the line */
    then do
      s = s + 1
      p = 1
      return 'EOL'
    end

  do forever

    c = substr(source.s,p,1)
    p = p + 1
    if c = ' '
      then do
        had_blank = 1
        iterate
      end
    if had_blank
      then do    /* blanks only significant (for us) before these */
        if verify(c,':.(') = 0
          then do
            p = p - 1/* back up one so we start in the right place */
            return 'BLANK'
          end
      end

    if c = '/' & substr(source.s,p,1) = '*'    /* start a comment */
      then do
        p = p + 1
        nest = 1             /* REXX comments must nest correctly */
        do forever                     /*                  <----  */
          if p > s_len.s               /*                      |  */
            then do                    /*                      |  */
              p = 1                    /*                      |  */
              s = s + 1                /*                      |  */
              if s > s_lines then return 'EOF'
              iterate                  /* iterates nearest loop-  */
            end                        /*                      |  */
          c1 = substr(source.s,p,1)    /*                      |  */
          p = p + 1                    /*                      |  */
          if c1 <> '/' & c1 <> '*'     /*                      |  */
            then iterate  /* can't be the end of the comment then */
            else do
              c2 = substr(source.s,p,1)
              if c1 = '/' & c2 = '*' then nest = nest + 1
              if c1 = '*' & c2 = '/' then nest = nest - 1
              if nest = 0
                then do
                  p = p + 1/* 2002-02-13 advance to next char only if successful */
                  return 'COMMENT'
                end
            end
        end
      end

    type = translate(c,typeset,charset)

    if type = '"' | type = "'"         /* literals                */
      then do
        val = ''
        do forever
          c = substr(source.s,p,1)
          p = p + 1
          if c = type                 /* 'they''re' ==> "they're" */
            then do
              if p > s_len.s then leave/* can't be escaped        */
              if substr(source.s,p,1) <> c     /* isn't escaped   */
                then do
                  ?=substr(source.s,p,1)/* check for binary / hex data */
                  if (?='b'|?='x')&verify(substr(source.s,p+1,1),'!.0123456789?ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz')
                    then do
                      if ?='b' then val = b2x(val)
                      val = x2c(val)
                      p = p + 1
                    end
                  leave
                end
              p = p + 1                /* step over escaped quote */
            end
          val = val''c
        end
        return 'LITERAL' val
      end

    if type = 's'                      /* SYMBOLS                 */
      then do                          /* (and stems.with.tails)  */
        symbol_value = c
        do forever
          if p > s_len.s then leave
          c = substr(source.s,p,1)
          type = translate(c,typeset,charset)
          if type <> 's' then if type <> 'n' then if type <> '.' then leave
          symbol_value = symbol_value''c
          p = p + 1
        end
        return 'SYMBOL' translate(symbol_value)
      end

    if type = 'o'
      then do
        if pos(c,'+-%')>0 then return 'OP' c/* singleton operators */
        if p > s_len.s    then return 'OP' c/* at end of line */
        c2 = substr(source.s,p,1)
        if pos(c,'/*&|=')>0 then do    /* doubleton operators     */
          if c<>c2 then return 'OP' c
          p = p + 1
          return 'OP' c''c
        end
        if pos(c,'<>')>0 then do       /* compare operators       */
          if pos(c2,'<>=')=0 then return 'OP' c
          p = p + 1
          if c<>c2 then return 'OP' c''c2 /* <= or <> or >= or >< */
          c2 = substr(source.s,p,1)
          if c2<>'=' then return 'OP' c''c     /* << or >>        */
          p = p + 1
          return 'OP' c''c''c2         /* <<= or >>=              */
        end
        if c='\' then do
          if pos(c2,'<>=')=0 then return 'OP \'
          p = p + 1
          c3 = substr(source.s,p,1)
          if c2<>c3 then return 'OP \'c2
          p = p + 1
          return 'OP \'c2''c3
        end
        call lineout 'stderr', 'Unexpected operator character:' c
      end

    if type = 'n' | type = '.'/* constant symbols starts with n or . can include s n or . */
      then do
        constant_value = c
        do forever
          if p > s_len.s then leave
          c = substr(source.s,p,1)
          type = translate(c,typeset,charset)
          if verify(type,'sn.') then leave
          constant_value = constant_value''c
          p = p + 1
        end
        return 'CONSTANT' constant_value
      end

    return type c

  end

return 'OTHER'                      /* this can never be returned */


word_sort: procedure         /* optimal insertion sort with words */
parse arg s
s = '00'x s        /* the leading 'null word' simplifies the sort */
do j = 2 to words(s)
  i = j - 1
  if word(s,i) >> word(s,j) then do
    key = word(s,j)
    s = delword(s,j,1)
    do until word(s,i) <<= key
      i = i - 1
    end
    s = subword(s,1,i) key subword(s,1+i)
  end
end
return space(subword(s,2))/* get rid of the null word at the front */


list_funcs: procedure expose (func_vars) source. labels out
  parse arg list, description
  call lineout out, description
  call lineout out, copies('-',length(description))
  none? = 1
  do i = 1 to words(list)
    bif = word(list,i)
    if count.bif = 0 then iterate
    done.bif = 1
    none? = 0
    shown_line. = 0
    call lineout out, bif': ('count.bif')'
    do j = 1 to count.bif
      ref = refs.bif.j
      type = type.bif.j

      if shown_line.ref = 0
        then do
          shown_line.ref = 1
          call lineout out, right(ref,6) source.ref
        end

      if type = 'SYM' & wordpos(bif,labels)>0
        then do
          call lineout out, right(' ',6) copies('^',length(source.ref))
          call lineout out, right(' ',6) 'Overridden by internal function'
        end
    end
  end
  if none? then call lineout out, "None."
  call lineout out, ' '
  return


add_assignment: procedure expose (var_vars)
  parse arg v, ref
  if pos('.',v)=0
    then do
      if wordpos(v, vars) = 0 then vars = vars v
      var_assigned.v = var_assigned.v ref
      return
    end

  parse var v stem '.' tail
  stem = stem'.'
  if wordpos(stem, stems) = 0 then stems = stems stem
  if tail = ''
    then stem_assigned.stem = stem_assigned.stem ref
    else do
      stem_updated.stem = stem_updated.stem ref
      do while length(tail) > 0
        parse var tail ? '.' tail
        if verify(left(?,1),'1234567890.')
          then do
            if wordpos(?, vars) = 0 then vars = vars ?
            var_used.? = var_used.? ref
          end
      end
    end
  return

add_usage: procedure expose (var_vars)
  parse arg v, ref

  if pos('.',v)=0
    then do
      if wordpos(v, vars) = 0 then vars = vars v
      var_used.v = var_used.v ref
      return
    end

  parse var v stem '.' tail
  stem = stem'.'
  if wordpos(stem, stems) = 0 then stems = stems stem
  stem_used.stem = stem_used.stem ref
  do while length(tail) > 0
    parse var tail ? '.' tail
    if verify(left(?,1),'1234567890.')
      then do
        if wordpos(?, vars) = 0 then vars = vars ?
        var_used.? = var_used.? ref
      end
  end
  return

add_function: procedure expose (func_vars)
  parse arg type, name, ref
  count.name = count.name + 1
  ? = count.name
  refs.name.? = ref
  type.name.? = left(type,3)
  if ?=1 then func_list = space(func_list name)
  return

add_label: procedure expose (label_vars)
  parse arg s, ref
  if label_ref.s > 0
    then duplicate_labels = space(duplicate_labels s':'ref)
    else do
      label_ref.s = ref
      labels = space(labels s)
    end
  return

add_command: procedure expose (cmd_vars)
  parse arg type, s, ref
  s = left(type,3)word(s,1)
  if command_refs.s = ''
    then commands = commands s
  command_refs.s = command_refs.s ref
  return

/* process an expression upto end of clause */
do_expression: procedure expose t_type. t_value. t_line. i (var_vars) (func_vars)
  do until t_type.i = ';'/* this relies on the default being ';' at EOF */
    i=i+1
    select
      when at_a_function(i) then call add_function t_type.i, t_value.i, t_line.i
      when t_type.i='SYMBOL' then call add_usage t_value.i, t_line.i
    otherwise
    end
  end
  return

do_varlist: procedure expose t_type. t_value. t_line. i (var_vars)
  do until t_type.i = ';'
    i=i+1
    if t_type.i='SYMBOL' then call add_usage t_value.i, t_line.i
  end
  return

do_template: procedure expose t_type. t_value. t_line. i (var_vars)
  do until t_type.i = ';'
    i=i+1
    if t_type.i='SYMBOL' then call add_assignment t_value.i, t_line.i
  end
  return

do_keyword: procedure expose t_type. t_value. t_line. i (var_vars) (func_vars) (cmd_vars)
  select
    when t_value.i = 'ADDRESS' then do
      i = i + 1
      select
        when t_type.i =';' then nop
        when t_type.i ='SYMBOL' & t_value.i = 'VALUE' then call do_expression
      otherwise
        i=i+1
        if t_type.i<>';' then do
          call add_command t_type.i, t_value.i, t_line.i
          if t_type.i = 'SYMBOL' then call add_usage t_value.i, t_line.i
          call do_expression
        end
      end
    end
    when wordpos(t_value.i,'ARG PULL')>0 then call do_template
    when t_value.i = 'CALL' then do
      i=i+1
      select
        when t_value.i = 'OFF' then i=i+1
        when t_value.i = 'ON' then do
          ?=i+2
          if t_value.? = 'NAME'
            then i=i+3
            else i=i+1
          call add_function t_type.i, t_value.i, t_line.i
        end
      otherwise
        call add_function t_type.i, t_value.i, t_line.i
        call do_expression
      end
    end
    when t_value.i = 'DO' then do
      i = i + 1
      if at_an_assignment(i) then do/* only assignment if first thing after DO */
        call add_assignment t_value.i, t_line.i
        i = i + 1                      /* skip the =              */
      end
      do forever
        if t_type.i = ';' then leave
        select
          when at_a_function(i)
            then call add_function t_type.i, t_value.i, t_line.i
          when t_type.i='SYMBOL' & wordpos(t_value.i,'TO BY FOR FOREVER UNTIL WHILE OVER')=0
            then call add_usage t_value.i, t_line.i
          otherwise
        end
        i = i + 1
      end
    end
    when t_value.i = 'DROP' then call do_varlist
    when t_value.i = 'ELSE' then nop
    when t_value.i = 'IF' | t_value.i = 'WHEN' then do forever
      i=i+1
      if t_type.i = 'SYMBOL' & t_value.i = 'THEN' then leave
      select
        when at_a_function(i) then call add_function t_type.i, t_value.i, t_line.i
        when t_type.i='SYMBOL' then call add_usage t_value.i, t_line.i
      otherwise
      end
    end
    when t_value.i = 'ITERATE'   then call do_varlist
    when t_value.i = 'LEAVE'     then call do_varlist
    when t_value.i = 'NOP'       then nop
    when t_value.i = 'NUMERIC'   then do forever
      i = i + 1
      if t_type.i=';' then leave
      if at_a_function(i)
          then call add_function t_type.i, t_value.i, t_line.i
      else if t_type.i='SYMBOL' & wordpos(t_value.i,'DIGITS FORM SCIENTIFIC ENGINEERING VALUE FUZZ')=0
          then call add_usage t_value.i, t_line.i
    end
    when t_value.i = 'OTHERWISE' then nop
    when t_value.i = 'PARSE' then do
      i = i + 1
      if t_value.i = 'UPPER' then i = i + 1
      if t_value.i = 'VAR' then do
        i = i + 1
        call add_usage t_value.i, t_line.i
      end
      else if t_value.i = 'VALUE' then do forever
        i = i + 1
        if t_type.i='SYMBOL' & t_value.i='WITH' then leave
        select
          when at_a_function(i) then call add_function t_type.i, t_value.i, t_line.i
          when t_type.i='SYMBOL' then call add_usage t_value.i, t_line.i
        otherwise
        end
      end
      call do_template
    end
    when t_value.i = 'PROCEDURE' then do
      i = i + 1
      if t_value.i = 'EXPOSE' then call do_varlist
    end
    when t_value.i = 'SIGNAL' then do
      i = i + 1
      select
        when t_value.i = 'OFF' then i=i+1
        when t_value.i = 'ON' then do
          ?=i+2
          if t_value.? = 'NAME'
            then i=i+3
            else i=i+1
          call add_function t_type.i, t_value.i, t_line.i
        end
        when t_value.i = 'VALUE' then call do_expression
      otherwise
        call add_function t_type.i, t_value.i, t_line.i
      end
    end
    when t_value.i = 'TRACE' then do
      i = i + 1
      if t_value.i = 'VALUE' then call do_expression
    end
    when t_value.i = 'USE' then do
      i = i + 1     /* skip the ARG that always has to follow USE */
      call do_template
    end
  otherwise                      /* catch all for PUSH QUEUE SAY etc   */
    call do_expression
  end
return

at_a_function: procedure expose t_type.
  arg i
  j=i+1
  return (t_type.i='SYMBOL' | t_type.i='LITERAL') & t_type.j = '('

at_an_assignment: procedure expose t_type. t_value.
  arg i
  if t_type.i <> 'SYMBOL' then return 0
  i=i+1
  if t_type.i <> 'OP' then return 0
  if t_value.i <> '=' then return 0
  return 1
