/************************************************************************/
-- KWHELP.E
-- Mat Kramer, MekTek, 75746.2404@compuserve.com
-- 20 May 93: Initial revision
--
-- Please send comments, suggestions, bug reports to the above address.
--
-- This is a replacement for EPM's standard KWHELP.E.  It adds:
--    * generic "h" command to allow looking up a topic in a book
--    * list of available books generated from BOOKSHELF environment
--    * filetype-sensitivity in the index search -- the "EXTENSIONS:"
--      tags are not ignored.
--    * index search will search for case-insensitive match if no exact
--      match is found.
--
-- Entry points are typically the "kwhelp" command (which searches the help
-- index for the token under the text cursor), and the "h" command,
-- described below.  "kwhelp" is assigned to Ctrl+H and Ctrl+DblClick
-- by default.
--
-- Ideas for enhancements:
--    - Sort the book list
--    - Use DESCRIPTION tags or INF files to get titles of books
--    - Check environment for concatenated books (e.g., PMREF)
--
-- NOTE: This is not meant to work with earlier incarnations of E (pre-EPM)
/************************************************************************/
include 'stdconst.e'

const
compile if not defined(EPM_POINTER)
   EPM_POINTER = TEXT_POINTER
compile endif


/************************************************************************/
-- kwhelp
-- pHelp_C_identifier()
--
-- These are the entry defined by the standard KWHELP.E
/************************************************************************/
defc kwhelp=  call pHelp_C_identifier()

defproc pHelp_C_identifier
   if not find_token(startcol, endcol) then
      return
   endif
   identifier = substr(textline(.line), startcol, (endcol-startcol)+1)
   'h' identifier '*'


/************************************************************************/
-- h [topic [book]]
--
-- This command gets help on a specified topic from a specified book.
-- if book='*', then the HELPNDX is search for a matching book.  If
-- book is not specified, the user is prompted to pick a book from all
-- of the available books in the BOOKSHELF directories.  If topic is
-- not specified, the user is prompted to enter a topic string.
/************************************************************************/
defc h

   parse arg topic book

   /* get topic */
   if topic = '' then
      topic = entrybox('Enter Topic')
   endif
   if topic = '' then
      return
   endif

   /* get book to view */
   if book = '' then
      book = SelectBook()
   endif
   if book = '' then
      return
   endif

   /* get the required command */
   if book = '*' then
      cmd = FindIndexCmd(topic)
      if cmd = '' then
         sayerror 'Topic not in help index:' topic
         book = SelectBook()
         if book = '' then
            return
         endif
      endif
   else
      cmd = 'view' book topic
   endif

   /* execute the command */
   'dos' cmd
   return


/************************************************************************/
-- SelectBook()
--
-- Procedure prompts user to select an INF book from the BOOKSHELF.
-- Returns an empty string if no books were found or if the user
-- selected Cancel.
/************************************************************************/
defproc SelectBook
 
   universal vTEMP_FILENAME, booklist

   /* create a book list if not already done */
   if not booklist then

      mouse_setpointer WAIT_POINTER

      /* get a list of all books */
      call erasetemp(vTEMP_FILENAME)
      booklist = get_env('BOOKSHELF')
      sayerror 'Building book list:' booklist
      do while booklist <> ''
         parse value booklist with bookdir ';' booklist
         call subdir(bookdir'\*.INF >>'vTEMP_FILENAME)
      enddo
      'edit /d /q' vTEMP_FILENAME
      call erasetemp(vTEMP_FILENAME)
   
      /* build a delimited book list for listbox() */
      booklist = '/'  -- initial delimiter
      top
      do while .line < .last
         book = textline(.line)
         if pos('SYS', book) <> 1 then
            /* not an error line (SYSnnnn:), add to list */
            book = substr(book, lastpos('\', book)+1)  -- get filename
            book = leftstr(book, length(book)-4)  -- strip .INF extension
            booklist = booklist||book||'/'
         endif
         down
      enddo
      'quit'  -- don't need the file anymore

      mouse_setpointer EPM_POINTER

   endif

   /* present the listbox */
   if verify(booklist, '/') > 0 then
      return listbox('Select Book', booklist)
   else
      return ''
   endif


/************************************************************************/
-- FindIndexCmd(topic)
--
-- Searches the help index (NDX files) for a matching topic.  If one
-- is found, the command required to view the information is returned.
-- Otherwise, an empty string is returned.
--
-- format of index file:
--     (Win*, view pmwin.inf ~)
--     (printf, view dde4help.inf printf)
/************************************************************************/
defproc FindIndexCmd(topic)

   universal helpindex_id

   ftype = filetype()  -- save file type

   /* switch to the help index */
   getfileid CurrentFile             /* save the ID of the current file */
   if helpindex_id then
      rc = 0
      activatefile helpindex_id
      if rc then  -- File's gone?
         helpindex_id = 0
      endif
   endif
   if not helpindex_id then
      'LoadHelpIndex'
   endif
 
   /* search for a match */
   sayerror 'Searching help index for:' topic
   mouse_setpointer WAIT_POINTER
   display -2  -- disable messages
   call psave_mark(savemark)
   getsearch savesearch
   found = SearchSections(topic, ftype, line, col)
   if not found then
      found = SearchSections(topic, '*', line, col)
   endif
   if not found then
      found = SearchSections(topic, '', line, col)  -- search ALL sections
   endif
   setsearch savesearch
   call prestore_mark(savemark)
   display 2  -- enable messages
   mouse_setpointer EPM_POINTER

   /* substitute occurences of '~' with original topic */
   if not found then
      cmd = ''
   else
      parse value substr(textline(line), col) with ',' cmd ')'
      loop
         i = pos('~', cmd)
         if not i then
            leave
         endif
         cmd = leftstr(cmd, i-1)||topic||substr(cmd, i+1)
      endloop
   endif

   activatefile CurrentFile
   return cmd


/************************************************************************/
-- LoadHelpIndex
--
-- Loads all files specified in the HELPNDX environment variable into
-- the hidden buffer with fileid "helpindex_id".  The specified files
-- are searched for first in the default locations (findfile 'D' option),
-- then in the PATH.
/************************************************************************/
defc LoadHelpIndex

   universal helpindex_id

   helplist = Get_Env('HELPNDX')
   if helplist='' then
compile if defined(KEYWORD_HELP_INDEX_FILE)
       helplist = KEYWORD_HELP_INDEX_FILE
compile else
       helplist = 'epmkwhlp.ndx'
compile endif
   endif
   sayerror 'Loading help index:' helplist
   do while helplist<>''
      parse value helplist with helpindex '+' helplist

      /* look for the help index file in current dir, EPMPATH, DPATH, and EPM.EXE's dir: */
      findfile destfilename, helpindex, '','D'

      if rc then
         /* If that fails, try the standard path. */
         findfile destfilename, helpindex, 'PATH'
         if rc then
            sayerror  'Help index 'helpindex' not found'
            iterate
         endif
      endif
compile if EVERSION >='5.50'
      if pos(' ',destfilename) then
         destfilename = '"'destfilename'"'  -- HPFS support
      endif
compile endif
      if helpindex_id then
         /* append to help index */
         bottom
         last = .last
         'get' destfilename
      else
         /* load first help index */
         'xcom e /d' destfilename
         getfileid helpindex_id
         .visible = 0
      endif
   enddo
   return

 
/************************************************************************/
-- SearchSections(string, filetype, line, col)
--
-- The NDX file(s) are sectioned with the "EXTENSIONS" tags, which
-- specify which file types the section applies to.  This procedure will
-- search all sections matching the specified file type.  If ftype=''
-- then all sections are searched.  (* as an extension means the section
-- applies to all file types).
--
-- returns 1 if a match was found (loaction is in line & col)
-- returns 0 if no match was found
/************************************************************************/
defproc SearchSections(string, ftype, var line, var col)

   search = 'xcom L ~EXTENSIONS:~e+'

   /* find first section */
   top; .col = 1
   getfileid fileid
   search
   if rc then
      return 0  -- no sections?!
   endif
   startline = .line
   startcol = .col
   /* get list of extensions, padded on both sides with space */
   ext = upcase(' '||substr(textline(.line), .col+11)||' ')

   more = 1
   do while more

      /* move to next match or bottom */
      down  -- move past this match
      search
      if rc then
         bottom  -- last section
         more = 0
      endif
      nextline = .line
      nextcol = .col

      /* search this section if it applies */
      if (ftype='') or (pos(' '||upcase(ftype)||' ', ext)>0) then

         call pset_mark(startline, nextline, 1, 1, 'LINE', fileid)
         .line = startline  -- move to start of mark
         .col = startcol
         if LocateIndexEntry(string, line, col) then
            return 1  -- found a match in this section
         endif
      endif

      /* move to next match */
      if more then
         .line = nextline
         .col = nextcol
         startline = nextline
         startcol = nextcol
         ext = upcase(' '||substr(textline(.line), .col+11)||' ')
      endif

   enddo
   return 0  -- not found


/************************************************************************/
-- LocateIndexEntry(topic, line, col)
--
-- Searches the marked area of an NDX file for a matching entries.  After
-- looking for an exact (case-insensitive) match, it tries all possible
-- prefixes.
--
-- Returns 1 for index entry match (at line, col)
/************************************************************************/
defproc LocateIndexEntry(topic, var line, var col)

   if LocateBestCase('('topic',', line, col) then
      return 1  -- found match
   endif
   do i = length(topic) to 0 by -1
      if LocateBestCase('('leftstr(topic, i)'*,', line, col) then
         return 1  -- found prefix match
      endif
   enddo
   return 0  -- sorry, no match


/************************************************************************/
-- LocateBestCase(string, line, col)
--
-- Search the marked area for the specified string.  Return location of
-- a case sensitive match in 'line' and 'col', otherwise case insensitive.
-- The return value is 1 if a string was found, 0 otherwise.
-- Assumes that starting location is at the start of the marked area
/************************************************************************/
defproc LocateBestCase(string, var line, var col)

   top; .col = 1
   line = ''  -- flag none found yet
   rc = 0
   do while not rc
      'xcom L ~'string'~cm+'  -- find next match in this section
      if not rc then
         line = .line  -- save match location
         col = .col
         if string = substr(textline(.line), .col, length(string)) then
            return 1  -- found an exact (same case) match
         endif
      endif
      right -- move beyond this match
   enddo
   if line = '' then
      return 0  -- no matches found
   else
      return 1  -- use last match (case insensitive)
   endif

