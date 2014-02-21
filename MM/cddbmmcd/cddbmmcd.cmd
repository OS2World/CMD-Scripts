/****************************************************************************
*
*  CDDBMMCD.CMD - update OS/2 PM CD-Player via CDDB
*
*  Copyright (C) 2001-2003 by Marcel MÅller
*/ opt.version = '0.44' /*
*
*  This program is free software; you can redistribute it and/or
*  modify it under the terms of the GNU General Public License
*  as published by the Free Software Foundation; either version 2
*  of the License, or (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software
*  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
****************************************************************************/

CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
CALL SysLoadFuncs

CALL RxFuncAdd 'MMLoadFuncs', 'RXMMUTL', 'MMLoadFuncs'
CALL MMLoadFuncs

NUMERIC DIGITS 12

/****************************************************************************
*
*  SECTION 0 - option parsing
*
****************************************************************************/

PARSE SOURCE dummy dummy opt.apppath

/* help */
ARG cmdl dummy
cmdl = TRANSLATE(cmdl, '-', '/')
IF cmdl = '-H' | cmdl = '-?' | cmdl = '--help' THEN DO
   SAY "CDDBMMCD - update OS/2 PM CD-Player via CDDB, version "opt.version
   SAY "Copyright (C) 2001-2003 by Marcel MÅller"
   SAY
   SAY "CDDBMMCD commandline options:"
   SAY "-p<profile>      Use specified profile instead of cddbmmcd.ini in current"
   SAY "                 directory."
   SAY "-d<device>       CDAUDIO device. Multiple devices may be seperated with komma."
   SAY "-l<path>         Path to a local CDDB."
   SAY "-l               Use local CDDB at default path."
   SAY "-l-              Disable local CDDB."
   SAY "-t<type>         Type of local CDDB. W[indows] or S[tandard] or [all]."
   SAY "-f<threshold>    Enable fuzzy search with specified threshold if no exact match"
   SAY "                 is found. Use -f0 to disable fuzzy search."
   SAY "-s<server>       Use specified cddb server(s). The separation character is komma."
   SAY "-s               Use default CDDB server."
   SAY "-s-              Disable CDDB server queries."
   SAY "-P<proxy>        Proxy-server."
   SAY "-u<user>         User name for CDDB HELLO."
   SAY "-h<host>         Host name for CDDB HELLO."
   SAY "-e<host>         User's e-mail for submitting CDDB records."
   SAY "-c<client>       Overwrite client name and version."
   SAY "-o[+|-]<opcodes> c  Check current CD if undefined."
   SAY "                 C  Check current CD always."
   SAY "                 q  Execute CDDB query (if required)."
   SAY "                 Q  Execute CDDB query of previous outstanding checks."
   SAY "                 o  Retry unsuccsessful queries, which are older than one month."
   SAY "                 O  Retry all unsuccsessful queries."
   SAY "                 u  Create upload record for unsuccessful queries, where the"
   SAY "                    information is entered with the OS/2 CD-Player meanwhile."
   SAY "                 U  Force creation of upload record for currently inserted CD."
   SAY "                 a  Create update records with newer revision when the CD"
   SAY "                    information has been modified."
   SAY "                    OPTION CURRENTLY EXPERIMENTAL!"
   SAY "                 s  Submit upload records."
   SAY "                    OPTION CURRENTLY EXPERIMENTAL!"
   SAY "                 R  Force recreation of pending upload records."
   SAY "-v<level>        Verbose output:"
   SAY "                 0  Show fatal errors (with program abort) only."
   SAY "                 1  Show all errors."
   SAY "                 2  Show errors and warnings. (default)"
   SAY "-v               3  Show informational messages, too. (also selected by -v)"
   SAY "-z<path>         Path for upload files. Default = .\"
   SAY "-w               Write specified options to profile as new defaults."
   SAY
   SAY "See documentation for more options."
   EXIT
   END

/* parse command line */
opt.writeini = 0
opt.reset = 0
opt.usedb = ''
nodb = ''
cmdl = ARG(1)
alphanum = XRANGE('A','Z')XRANGE('a','z')XRANGE('0','9')
DO WHILE cmdl \= ''
   IF LEFT(cmdl, 1) = '"' THEN
      PARSE VAR cmdl '"'opt'"'cmdl
    ELSE
      PARSE VAR cmdl opt cmdl
   cmdl = STRIP(cmdl, 'l')
   IF LEFT(opt,1) \= '-' & LEFT(opt,1) \= '/' THEN
      CALL Fatal 44, 'Illegal option 'opt'.'
   /* option */
   SELECT
    WHEN OptionCheck('cddev'     ,'d', '--device'   ,alphanum'_,') THEN NOP
    WHEN OptionCheck(            ,'l-','--nolocal') THEN
      nodb = nodb'L'
    WHEN OptionCheck('localdb_'  ,'l', '--local'    ,   , '') THEN DO
      opt.usedb = opt.usedb'L'
      IF opt.localdb_ \= '' THEN
         opt.localdb = ToPath(opt.localdb_)
      END
    WHEN OptionCheck(            ,'s-','--noserver') THEN
      nodb = nodb'S'
    WHEN OptionCheck('dbserver_' ,'s', '--server'   ,   , '') THEN DO
      opt.usedb = opt.usedb'S'
      IF opt.dbserver_ \= '' THEN
      opt.dbserver = TRANSLATE(opt.dbserver_,, ',')
      END
    WHEN OptionCheck('dbtype'    ,'t', '--type'     ,   , 'A') THEN DO
      tmp = TRANSLATE(opt.dbtype)
      IF \ABBREV('AUTO', tmp) & \ABBREV('STANDARD', tmp) & \ABBREV('WINDOWS', tmp) THEN
         CALL Fatal 42, 'Unknown database type 'tmp'.'
      opt.dbtype = LEFT(tmp, 1)
      END
    WHEN OptionCheck('windelta'  ,   , '--windbdelta','W') THEN NOP
    WHEN OptionCheck('hddvscpu'  ,   , '--hddvscpu' ,'W') THEN NOP
    WHEN OptionCheck('proxy'     ,'P', '--proxy') THEN NOP
    WHEN OptionCheck('fuzzy'     ,'f', '--fuzzy'    ,'W') THEN NOP
    WHEN OptionCheck('user'      ,'u', '--user') THEN NOP
    WHEN OptionCheck('host'      ,'h', '--host') THEN NOP
    WHEN OptionCheck('email'     ,'e', '--email') THEN NOP
    WHEN OptionCheck('client'    ,'c', '--client') THEN NOP
    WHEN OptionCheck('opcode'    ,'o', '--op') THEN DO
      tmp = VERIFY(opt.opcode, '+-cCqQoOuUsSaAR')
      IF tmp \= 0 THEN
         CALL Fatal 42, opt' contains illegal opcode 'SUBSTR(opt.opcode, tmp, 1)'.'
      END
    WHEN OptionCheck('cdx'       ,   , '--cdextra'  ,'W', 1) THEN NOP
    WHEN OptionCheck('uplpath'   ,'z', '--uploadpath') THEN
      opt.uplpath = ToPath(opt.uplpath)
    WHEN OptionCheck('verbose'   ,'v', '--verbose'  ,'W', 3) THEN NOP
    WHEN OptionCheck('cp'        ,   , '--codepage' ,'W') THEN NOP
    WHEN OptionCheck('proto'     ,   , '--proto'    ,'W') THEN NOP
    WHEN OptionCheck('ac'        ,   , '--caseadj'  ,'W', 1) THEN NOP
    WHEN OptionCheck('trkfix'    ,   , '--trackfix' ,'W', 1) THEN NOP
    WHEN OptionCheck('ext'       ,   , '--ext'      ,'W', 1) THEN NOP
    WHEN OptionCheck('special'   ,   , '--special') THEN NOP
    WHEN OptionCheck('profile'   ,'p', '--profile') THEN NOP
    WHEN OptionCheck(            ,'w', '--write') THEN
      opt.writeini = 1
    WHEN OptionCheck(            ,   , '--reset') THEN
      opt.reset = 0
    OTHERWISE
      CALL Fatal 44, 'Illegal option 'opt'.'
      END
   END

IF opt.usedb = '' THEN
   DROP opt.usedb

/* split opcode command */
p = VERIFY(opt.opcode, '+-', 'M')
IF p \= 0 THEN DO
   opmod = SUBSTR(opt.opcode, p)
   opt.opcode = LEFT(opt.opcode, p-1)
   IF opt.opcode = '' THEN
      DROP opt.opcode
   END
/* profile path */
CALL ApplyDefault 'profile', ,                ,                FILESPEC('D',opt.apppath)FILESPEC('P',opt.apppath)"CDDBMMCD.INI"
/* migrate profile from previous versions */
CALL MigrateProfile
/* read and update settings */
CALL ApplyDefault 'verbose', ,                'Verbose',       3
CALL ApplyDefault 'cddev',   ,                'CDAudioDevice', 'CDAUDIO'
CALL ApplyDefault 'localdb', ,                'LocalCDDBPath', './'
CALL ApplyDefault 'dbtype',  'S',             'LocalCDDBType'
CALL ApplyDefault 'windbdelta',,              'WinDBDelta',    6
CALL ApplyDefault 'fuzzy',   ,                'FuzzyThreshold',41
CALL ApplyDefault 'dbserver','freedb.freedb.org','CDDBservers'
CALL ApplyDefault 'proxy',   '',              'ProxyServer'
CALL ApplyDefault 'user',    ,                'Username',      VALUE('USER',,'OS2ENVIRONMENT'), 'os2user'
CALL ApplyDefault 'host',    ,                'Hostname',      VALUE('HOSTNAME',,'OS2ENVIRONMENT')
CALL ApplyDefault 'email',   ,                'EMail'
CALL ApplyDefault 'client',  ,                'ClientString',  'cddbmmcd/2 'opt.version
CALL ApplyDefault 'opcode',  'cqQo',          'OperationCodes'
CALL ApplyDefault 'cdx',     ,                'CDExtraWA',     1
CALL ApplyDefault 'usedb',   'L',             'CDDBType'
CALL ApplyDefault 'cdpini',  ,                'CDPiniLocation',STRIP(VALUE('MMBASE',,'OS2ENVIRONMENT'),'T',';')'\CDP.INI'
CALL ApplyDefault 'uplpath', ,                'UploadDataPath' opt.localdb
CALL ApplyDefault 'proto',   ,                'ProtocolLevel', 5
CALL ApplyDefault 'ext',     ,                'EXTFields',     0
CALL ApplyDefault 'hddvscpu',,                'HDDvsCPU',      10000
CALL ApplyDefault 'ac',      0
CALL ApplyDefault 'trkfix',  0
CALL ApplyDefault 'special', ''
CALL ApplyDefault 'cp',      ,                'Codepage',      1004
/* postprocess opcode */
DO WHILE opmod \= ''
   p = VERIFY(opmod'+', '+-', 'M', 2)
   cmd = LEFT(opmod, 1)
   tmp = SUBSTR(opmod, 2, p -2)
   opmod = SUBSTR(opmod, p)
   IF cmd = '+' THEN
      DO i = 1 TO p-2
         IF POS(SUBSTR(tmp, i, 1), opt.opcode) = 0 THEN
            opt.opcode = opt.opcode||SUBSTR(tmp, i, 1)
         END
    ELSE
      DO i = p-2 TO 1
         opt.opcode = RemoveC(opt.opcode, SUBSTR(tmp, i, 1))
         END
   END
CALL ApplyDefault 'opcode',  , 'OperationCodes'
DO i = 1 TO LENGTH(nodb)
   opt.usedb = RemoveC(opt.usedb, SUBSTR(nodb, i, 1))
   END
CALL ApplyDefault 'usedb',   , 'CDDBType'


/****************************************************************************
*
*  SECTION 1 - main
*
****************************************************************************/

CALL MMIniOpen opt.profile /* speed up */

IF opt.writeini THEN
   EXIT 0 /* no other operation in this case */
IF POS('S', opt.usedb) \= 0 THEN
   CALL TCPIPInit

/* special actions */
CALL Special /* this function my not return depending on the ation taken */

CALL MMIniOpen opt.cdpini /* speed up */

/* start ! */
CALL HandleCD
/* Pass the list of the currently inserted CD('s) in the stem cd. */
/* downloads */
CALL CDDBQuery

/* check 4 uploads */
CALL CheckUpload
/* upload */
CALL CDDBUpload

EXIT 0


/****************************************************************************
*
*  SECTION 2a - high level control functions: cddb lookup
*
****************************************************************************/

GetTOC: PROCEDURE EXPOSE opt.
/* get TOC of CD
   parameter:
      ARG(1) MCI device
   return:
      RESULT Table of contents of current CD
             '' on error
*/
   /*CALL MCIcmd 'close 'ARG(1)' wait'*/
   /* open CDAUDIO */
   CALL MCIcmd 'open 'ARG(1)' wait'
   /* get TOC */
   n = MCIcmd('status 'ARG(1)' number of tracks wait', 0)
   IF n = 0 THEN DO
      /*CALL MCIcmd 'close 'ARG(1)' wait'  Close seems to confuse REXX in this case: STDIN will remain broken. */
      RETURN ''
      END
   TOC = ''
   CALL MCIcmd 'set 'ARG(1)' time format mmtime wait'
   TOC = n' 'MCIcmd('status 'ARG(1)' length wait') / 40
   DO i = 1 TO n
      TOC = TOC' 'MCIcmd('status 'ARG(1)' position track 'i' wait') / 40
      /*SAY i'S' MCIcmd('status c position track 'i' wait') / 40' 'i'L' MCIcmd('status c length track 'i' wait') / 40*/
      END
   /* CD extra work around */
   IF opt.cdx THEN DO n = n
      /* search for additional tracks on CD-extra */
      p = MCIcmd('status 'ARG(1)' position track 'n+1' wait', 'X')
      IF p = 'X' THEN LEAVE
      TOC = TOC' 'p / 40
      END
   TOC = TOC' 'WORD(TOC, n+2) + MCIcmd('status 'ARG(1)' length track 'n' wait') / 40
   /* release device */
   CALL MCIcmd 'close 'ARG(1)' wait'
   RETURN TOC

HandleCD: PROCEDURE EXPOSE opt. cd.
/* handle currently inserted CD
   return:
      cd.0   number of cd entries
      cd.i   CD TOC
*/
   cd.0 = 0
   IF VERIFY('cCAU', opt.opcode, 'M') = 0 THEN
      RETURN
   CALL Section 'Get table of contents of current CD(s)...'
   /* Multimedia-REXX-UnterstÅtzung laden und initialisieren */
   CALL RXFUNCADD 'mciRxInit','MCIAPI','mciRxInit'
   CALL mciRxInit
   /* handle currently inserted CD(s) */
   devlist = opt.cddev
   i = 1
   DO WHILE devlist \= ''
      PARSE VAR devlist dev','devlist
      cd.i = GetTOC(dev)
      IF cd.i \= '' THEN
         i = i +1
      END
   /* close MCI */
   CALL mciRxExit
   cd.0 = i -1

   IF VERIFY('cC', opt.opcode, 'M') = 0 THEN
      RETURN
   /* current cd's */
   CALL Section 'Checking 'cd.0' CD(s)...'
   DO i = 1 TO cd.0
      PARSE VALUE GetCDState(cd.i) WITH state param
      IF POS('C', opt.opcode) = 0 THEN DO
         PARSE VALUE ReadMMCD(cd.i) WITH title'0'x
         IF state = 1 | state > 2 | title \= '' THEN DO
            /* data available */
            CALL Info 'CD Well known: ('state') 'title
            ITERATE
            END
         END
      /* query request */
      CALL Info 'CDDB query required'
      IF state = 1 THEN
         ITERATE
      CALL SetCDState cd.i, 1
      END

   RETURN

CDDBQuery: PROCEDURE EXPOSE opt. cd.
/* create CDDB query list and execute it
   parameter:
      cd.i   current cd's
*/
   IF VERIFY(opt.opcode, 'qQoO', 'M') = 0 THEN
      RETURN

   opq = POS('q', opt.opcode) \= 0
   opq_ = POS('Q', opt.opcode) \= 0
   opo = POS('o', opt.opcode) \= 0
   IF POS('O', opt.opcode) \= 0 THEN
      opo = 2
   /* create query list */
   query.0 = 0
   /* pending CDs */
   CALL GetCDList 'list'
   time = UnixTime()
   DO i = 1 TO list.0
      PARSE VALUE GetCDState(list.i) WITH state param
      SELECT
       WHEN state = 1 & IsCurrentCD(list.i) THEN
         IF \opq THEN ITERATE
       WHEN state = 1 THEN /* & \IsCurrentCD(list.i) */
         IF \opq_ THEN ITERATE
       WHEN opo = 0 THEN ITERATE
       WHEN state = 2 THEN
         IF opo = 1 & time < param + 30*24*60*60 THEN ITERATE
       OTHERWISE ITERATE
         END
      CALL AddCD list.i
      END
   /* execute query list */
   CALL Section "Executing "query.0" cddb queries..."
   DO i = 1 TO query.0
      IF \ExecQuery(query.i) THEN
         CALL Warning 'No cddb record found for unknown CD with 'WORD(query.i,1)' tracks and 'LEFT(F2MSF(WORD(query.i,2)),5)' length.'
       ELSE
         /* found match! */
         IF ParseXMCD() THEN DO
            /* store information */
            CALL Info 'CD Information found: 'TIT.0
            CALL CreateMMCDData
            CALL StoreMMCD query.i, RESULT, meta
            CALL SetCDState query.i, 3
            ITERATE
            END
      CALL SetCDState query.i, 2 UnixTime()
      END
   RETURN

ExecQuery: PROCEDURE EXPOSE opt. xmcd
/* execute CDDB query (local + server)
   parameter:
      ARG(1) TOC of CD to query
      ARG(2) category, optional, if omitted all categories are checked
   return:
      RESULT success (boolean)
      xmcd   xmcd data
*/
   IF POS('L', opt.usedb) \= 0 THEN
      IF LocalQuery(ARG(1), ARG(2)) THEN
         RETURN 1
   IF POS('S', opt.usedb) \= 0 THEN
      DO j = 1 TO WORDS(opt.dbserver)
         IF ServerQuery(ARG(1), WORD(opt.dbserver, j), ARG(2)) THEN
            RETURN 1
         END
   RETURN 0

/* local cddb */
LocalQuery: PROCEDURE EXPOSE opt. xmcd
/* request to local CDDB database
   parameter:
      ARG(1) table of contents of CD to query
      ARG(2) category, optional, if omitted all categories are checked
   return:
      RESULT success (boolean)
      xmcd   xmcd data
*/
   TOCn = WORDS(ARG(1)) - 3
   cdid = CalcCDID(ARG(1))
   /* search for cddb record */
   CALL Info 'Local database lookup for CD-ID: 'cdid
   IF ARG(2) = '' THEN
      CALL SysFileTree opt.localdb'*', 'dirs', 'DO' /* list categories */
    ELSE DO
      dirs.0 = 1
      dirs.1 = ARG(2)
      END
   /* always prefer exact matches */
   fuzzy = opt.fuzzy /* localize opt.fuzzy */
   opt.fuzzy = 0
   IF TryCDDBFileQuery(ARG(1), cdid) THEN
      RETURN 1 /* got it */
   opt.fuzzy = fuzzy
   /* try fuzzy search */
   IF fuzzy \= 0 & TOCn > 1 THEN DO
      CALL Info "- trying fuzzy search (Ò"opt.fuzzy")."
      IF TryCDDBFileQuery(ARG(1), CalcCDID(ARG(1), TRUNC((opt.fuzzy-1) / 75) + 2, 10)) THEN
         RETURN 1 /* got it */
      END
   CALL Info '- No local record found.'
   RETURN 0

TryCDDBFileQuery: PROCEDURE EXPOSE opt. xmcd dirs.
/* Check for local cddb match and store the information in the OS/2 CD player's database on success.
   subfunction to LocalQuery

   parameter:
      ARG(1) TOC of CD.
      ARG(2) cdid (=filename), multiple cdids may be separated by spaces.
             But only the first matching xmcd record is returned.
      dirs.  Stemmed variable with the valid local cddb categories.
   return:
      RESULT success (boolean)
      xmcd   xmcd data
*/
   /* iterate over categories */
   DO i = 1 TO dirs.0
      /* iterate over multiple matches (in case of multiple cdids). */
      DO FOREVER
         xmcd = FindXMCDData(dirs.i'\', ARG(2))
         IF xmcd = '' THEN
            LEAVE
         IF CDDBMatchQ(ARG(1), RST.discid) THEN DO
            /* found match! */
            CALL ReadXMCDCleanup /* close any outstanding matches */
            RETURN 1
            END
         END
      END
   RETURN 0

FindXMCDData: PROCEDURE EXPOSE opt. RST. xmcd
/* read CDDB file and check if it matches TOC
   This function has an optimized lookup for multiple cdids.

   parameters:
      ARG(1) path including trailing '\'
      ARG(2) cdid (=filename), multiple cdids may be separated by spaces.
             But only the first matching xmcd record is returned.
   return:
      xmcd data
      ''     error
             You should always call the function unless it returns '' to ensure that all files are closed.
   global vars:
      RST.   This stemm is used to save object like state information.
      RST.discid discid of last returned xmcd record
*/
   IF SYMBOL('RST.cdid') = 'LIT' THEN
      /* first call */
      RST.cdid = TRANSLATE(ARG(2), 'abcdef', 'ABCDEF')

   DO nexttry = 0
      IF RST.cdid = '' THEN
         /* no more search criteria */
         RETURN ReadXMCDCleanup()

      /* fetch next cdid */
      RST.curcdid = WORD(RST.cdid,1)
      RST.cdid = SUBWORD(RST.cdid, 2)
      IF SYMBOL('RST.file') = 'LIT' THEN DO
         DROP RST.nextid /* the destruction of RST.file implicitly discards any last match id */
         /* no open file */
         IF opt.dbtype \= 'W' THEN DO
            f = ARG(1)WORD(RST.curcdid,1)
            CALL Debug 'Looking for 'f
            /* try normal cddb */
            xmcd = MMFileIn(f)
            IF xmcd \= '' THEN
               /* got it! */
               RETURN xmcd
            END
         IF opt.dbtype = 'S' THEN
            ITERATE nexttry /* normal cddb file not found and no win version selected */
         /* try win version of cddb */
         f = ''
         DO FOREVER
            f = WinDBNextTry(RST.curcdid, f)
            IF f = '' THEN
               ITERATE nexttry /* file not found */
            CALL Debug 'Looking for 'ARG(1)f
            IF STREAM(ARG(1)f, 'c', 'open read') = 'READY:' THEN
               LEAVE /* got it */
            END
         /* file found */
         RST.file = ARG(1)f
         /* extract all similar cdid's from RST.cdid which reside in the same file
            As side effect, this will prevent a 'normal' cddb file lookup for the similar cdid entries if opt.dbtype is 'A'. */
         DO i = WORDS(RST.cdid) TO 1 BY -1 /* reverse to make the iterator i independent of changes to RST.cdid */
            c = LEFT(WORD(RST.cdid, i), 2)
            IF c >= LEFT(f, 2) & c <= SUBSTR(f, 5,2) THEN DO
               RST.curcdid = SortedWordInsert(RST.curcdid, WORD(Rst.cdid, i)) /* keep RST.curcdid sorted */
               RST.cdid = DELWORD(RST.cdid, i, 1)
               END
            END
         /* initialize binary file scan */
         RST.1 = 0' 'STREAM(RST.file, 'c', 'query size')' '1' 'WORDS(RST.curcdid)+1
         RST.stack = 1
         END
      /* WinDB data file ..., RST.curcdid must be sorted */
      /* multiple binary search for matching entry */
      IF \ScanWinDBFile() THEN DO
         /* no more matches */
         CALL STREAM RST.file, 'c', 'close'
         /*CALL Debug 'no more 'RST.file*/
         DROP RST.file
         ITERATE nexttry /* end of file */
         END
      /* got match! */
      LEAVE
      END
   /* match found! read xmcd data */
   RST.discid = RST.nextid
   /*CALL Debug 'check for 'RST.discid*/
   CALL ReadXMCDData RST.file
   RETURN xmcd

ScanWinDBFile: PROCEDURE EXPOSE opt. RST.
/* Scan windows database file for one of a sorted list of disc IDs.

   return:
    0      no more matches
    1      possible match

   globals:
    RST.#  lower bound in file, upper bound in file, lower bound in RST.curcdid, upper bound in RST.curcdid, space delimited
    RST.stack current stack level

   remark:
    This function stores all ist state in RST.
*/
   /* get call logical stack */
   n = RST.stack
   DO WHILE n >= 1 /* stack loop */
      PARSE VAR RST.n flo fhi ilo ihi
      CALL Debug 'ScanWinDBFile 'n flo fhi ilo ihi
      IF flo = -1 THEN DO /* marker after exact match */
         /* check for random match */
         IF RST.nextid = WORD(RST.curcdid, ilo) THEN DO
            /* another exact match */
            ilo = ilo +1
            /* save state and return */
            RST.n = flo fhi ilo ihi
            RETURN 1
            END
         flo = STREAM(RST.file, 'c', 'seek +0') +1 /* search not before here */
         END
      DO WHILE flo < fhi & ilo < ihi
         IF fhi - flo > opt.hddvscpu THEN DO
            /* binary search */
            /* medium pos */
            fm = (flo+fhi-opt.hddvscpu) % 2 /* seek some bytes before the calculated position to improove speed */
            IF \DATATYPE(STREAM(RST.file, 'c', 'seek ='fm), 'W') THEN
               RETURN Error(0, 'Failed to seek in 'RST.file'.')
            CALL LINEIN RST.file /* always ignore the first (half) line */
            CALL Debug 'ScanWinDBFile 'n flo fhi ilo ihi fm
            /* scan for next #FILENAME= */
            DO FOREVER
               l = LINEIN(RST.file)
               IF l = '' THEN DO
                  /* end of file */
                  fhi = fm
                  LEAVE
                  END
               IF ABBREV(l, '#FILENAME=') THEN DO
                  RST.nextid = TRANSLATE(SUBSTR(l,11), 'abcdef', 'ABCDEF')
                  p = SortedWordPos(RST.curcdid, RST.nextid)
                  CALL Debug 'ScanWinDBFile 'RST.curcdid RST.nextid p
                  /* split into 2 jobs */
                  IF flo < fm & ilo < p THEN DO /* do not generate empty jobs */
                     RST.n = flo fm ilo p /* todo */
                     n = n +1
                     RST.stack = n
                     END
                  /* do the 2nd one first */
                  im = WORD(RST.curcdid, p)
                  CALL Debug 'ID = 'RST.nextid', 'RST.curcdid', 'p', 'im
                  IF im = RST.nextid THEN DO
                     /* exact match */
                     ilo = p +1
                     flo = -1 /* marker for RST.nextid */
                     /* save state and return */
                     RST.n = flo fhi ilo ihi
                     RETURN 1
                     END
                  ilo = p
                  flo = STREAM(RST.file, 'c', 'seek +0') /* do not search before the current position */
                  LEAVE
                  END
               END
            END
          ELSE DO
            /* linear search */
            IF \DATATYPE(STREAM(RST.file, 'c', 'seek ='flo), 'W') THEN
               RETURN Error(0, 'Failed to seek in 'RST.file'.')
            CALL LINEIN RST.file /* always ignore the first (half) line */
            CALL Debug 'ScanWinDBFileL 'n flo fhi ilo ihi
            /* scan for next #FILENAME= */
            DO WHILE flo < fhi
               l = LINEIN(RST.file)
               IF l = '' THEN DO
                  /* end of file */
                  fhi = flo
                  LEAVE
                  END
               IF ABBREV(l, '#FILENAME=') THEN DO
                  /* possible match */
                  RST.nextid = TRANSLATE(SUBSTR(l,11), 'abcdef', 'ABCDEF')
                  CALL Debug 'ScanWinDBFileL 'RST.curcdid RST.nextid
                  im = WORD(RST.curcdid, ilo)
                  CALL Debug 'ID = 'RST.nextid', 'RST.curcdid', 'im
                  IF im = RST.nextid THEN DO
                     /* exact match */
                     ilo = ilo +1
                     flo = -1 /* marker for RST.nextid */
                     /* save state and return */
                     RST.n = flo fhi ilo ihi
                     RETURN 1
                     END
                  flo = STREAM(RST.file, 'c', 'seek +0') /* do not search before the current position */
                  END
               END
            END
         END /* while loop */
      /* no success. Are there older jobs? */
      n = n -1
      RST.stack = n
      END
   /* no! */
   RETURN 0

WinDBNextTry: PROCEDURE EXPOSE opt.
/* try next possible filename of the windows database version

   parameters:
      ARG(1) cddb ID (only the first 2 characters are used)
      ARG(2) current filename or ''. In the latter case the first possible filename is returned.

   return:
      next possible filename or '' if no more possibilities are left. (limited by opt.windbdelta)
*/
   cur = LEFT(ARG(1), 2)
   IF ARG(2) = '' THEN
      RETURN cur'to'cur; /* first file, try exact match */
   /* all numbers to decimal */
   cur = X2D(cur)
   fr = X2D(LEFT(ARG(2), 2)) /* from */
   wd = X2D(SUBSTR(ARG(2), 5,2)) - fr /* width */
   IF fr < cur & fr + wd < 254 THEN
      fr = fr + 1 /* shift window */
    ELSE DO
      /* next delta */
      IF wd >= opt.windbdelta THEN
         RETURN '' /* game over, no more files */
      wd = wd + 1
      fr = MAX(cur - wd, 0)
      END
   /* got next name */
   RETURN TRANSLATE(D2X(fr, 2)"to"D2X(fr+wd, 2), XRANGE('a','f'), XRANGE('A','F'))

ReadXMCDFile: PROCEDURE EXPOSE opt. xmcd
/* read CDDB file
   parameter:
      ARG(1) filename
   return:
      RESULT success (boolean)
      xmcd   XMCD data
*/
   IF STREAM(ARG(1), 'c', 'open read') \= 'READY:' THEN
      RETURN 0
   CALL ReadXMCDData ARG(1)
   CALL STREAM ARG(1), 'c', 'close'
   RETURN 1

ReadXMCDData: /* private subfunction to ReadCDDBFile */
   xmcd = ''
   DO FOREVER
      l = LINEIN(ARG(1))
      IF l = '' THEN
         RETURN xmcd
      IF ABBREV(l, '#FILENAME=') THEN DO
         RST.nextid = TRANSLATE(WORD(SUBSTR(l,11),1), 'abcdef', 'ABCDEF')
         RETURN xmcd
         END
      xmcd = xmcd||l'0a'x
      END

ReadXMCDCleanup:
/* cleanup object data from ReadCDDBFile (destructor)

   global vars:
      RST.   This stemm is used to save object like state information.
*/
   IF SYMBOL('RST.file') = 'LIT' THEN
      CALL STREAM RST.file, 'c', 'close'
   DROP RST.
   RETURN ''

/* cddb server */
ServerQuery: PROCEDURE EXPOSE opt. xmcd discid
/* request to CDDB server

   parameters:
      ARG(1) table of contents of CD to query
      ARG(2) cddb server
      ARG(3) category, optional, if omitted a cddb query is executed first
   return:
      RESULT success (boolean)
      xmcd   xmcd data
      discid matching discid
*/
   /* bounce any server queries if one of the environment vars is missing */
   IF opt.user = '' | opt.host = '' THEN
      RETURN Error(0, "One of the following parameters is missing: host name (%HOSTNAME% or -h) or user name (%USER% or -u).")

   r = 0
   cddbtoc = CalcCDDBTOC(ARG(1))
   /* query cddb server */
   CALL Info 'CDDB query to server: 'ARG(2)
   IF CDDBinit(ARG(2)) = '' THEN
      RETURN 0

   tmp = CDDBCommand('DISCID 'cddbtoc, 2)
   IF tmp = '' THEN
      RETURN CDDBExit(0)
   discid = WORD(tmp, WORDS(tmp))

   IF ARG(3) \= '' THEN
      r = ServerRead(discid, ARG(3))
    ELSE DO
      tmp = CDDBCommand('CDDB QUERY 'discid' 'cddbtoc, 2)
      PARSE VAR tmp reply cat dummy
      SELECT
       WHEN reply = 200 THEN DO
         r = ServerRead(discid, cat)
         END
       WHEN reply = 211 | reply = 210 THEN DO
         CALL Info '- Inexact match for CD-ID 'discid
         PARSE VAR tmp dummy'0D0A'x matches
         IF WORD(ARG(1), 1) <= 2 THEN
            CALL Warning 'Inexact match with <= 2 tracks for CD-ID 'discid' - giving up.'
          ELSE
            DO WHILE matches \= '' & r = 0
               PARSE VAR matches tmp'0D0A'x matches
               PARSE VAR tmp cat discid dummy
               IF dummy = '' THEN LEAVE
               r = ServerRead(discid, cat)
               END
         END
       OTHERWISE
         CALL Info '- No record for CD-ID 'discid' found on server 'ARG(2)'.'
         END
      END
   IF r THEN
      r = CDDBMatchQ(ARG(1), discid)

   RETURN CDDBExit(r)

ServerRead: PROCEDURE EXPOSE opt. xmcd con.
/* read cddb entry, check if it is matching and store the result.
   subfunction to ServerQuery
   parameter:
      ARG(1) cddb discid
      ARG(2) cddb category
   return:
      RESULT success (boolean)
      xmcd   xmcd data
*/
   tmp = CDDBCommand('CDDB READ 'ARG(2)' 'ARG(1), 2)
   PARSE VAR tmp dummy'0a'x xmcd /* strip 1st line */
   IF WORD(dummy,1) \= 210 THEN
      RETURN Warning(0, 'Unknown cddb server reply 'dummy)
   RETURN 1

CDDBMatchQ: PROCEDURE EXPOSE opt. xmcd
/* Check if a CD matches the xmcd data.

   parameter:
      xmcd   xmcd data
      ARG(1) TOC of the CD
      ARG(2) diskid
   return:
      RESULT 1/0 true/false
*/
   /* extract meta data */
   xmcdtoc = QueryXMCD(ARG(2))
   IF xmcdtoc = '' THEN
      RETURN 0
   /* check track offsets */
   TOCn = WORD(ARG(1), 1) /* This will effectively exclude the data track of CD extra. */
   IF opt.fuzzy = 0 THEN DO
      /* exact match ? */
      IF SUBWORD(xmcdtoc, 3, TOCn) = SUBWORD(ARG(1), 3, TOCn) THEN
         RETURN 1 /* got it */
      CALL Info "CD-ID "ARG(2)" does not match, "SUBWORD(xmcdtoc, 3, TOCn)", "SUBWORD(ARG(1), 3, TOCn)
      RETURN 0
      END
   /* try fuzzy compare */
   diff = WORD(xmcdtoc, 3) - WORD(ARG(1), 3)
   DO i = 2+2 TO TOCn+2
      IF ABS(WORD(ARG(1), i) + diff - WORD(xmcdtoc, i)) >= opt.fuzzy THEN DO
         CALL Info "CD-ID "ARG(2)" does not match at track "i-2", "WORD(xmcdtoc, i)", "WORD(ARG(1), i)", "diff
         RETURN 0
         END
      END
   RETURN 1 /* got it */


/****************************************************************************
*
*  SECTION 2b - high level control functions: submissions
*
****************************************************************************/

CheckUpload: PROCEDURE EXPOSE opt. cd.
/* check for uploads

   parameters:
      cd.i   table of contents of current CDs
*/
   IF VERIFY(opt.opcode, 'uUaAR', 'M') = 0 THEN
      RETURN /* nothing to do */
   CALL Section "Preparing list of CDs to upload..."
   /* create update list */
   query.0 = 0
   /* currect CDs */
   IF VERIFY(opt.opcode, 'UA', 'M') \= 0 THEN
      DO i = 1 TO cd.0
         info = ReadMMCD(cd.i)
         IF info = '' THEN
            CALL Warning 'Unable to force upload: no title data available for unknown CD with 'WORD(ARG(1),1)' tracks and 'LEFT(F2MSF(WORD(ARG(1),2)),5)' length.'
          ELSE
            CALL AddCD cd.i, info, meta
         END
   /* old unsuccessful queries */
   opu = POS('u', opt.opcode) \= 0
   opa = POS('a', opt.opcode) \= 0
   opr_ = POS('R', opt.opcode) \= 0
   IF opu | opa | opr_ THEN DO
      CALL GetCDList 'list'
      CALL Debug 5, 'Checking 'list.0' entries.'
      DO i = 1 TO list.0
         PARSE VALUE GetCDState(list.i) WITH state param
         SELECT
          WHEN state = 2 THEN
            IF \opu THEN ITERATE
          WHEN state = 3 THEN
            IF \opa THEN ITERATE
          WHEN state = 4 THEN
            IF \opr_ THEN ITERATE
          OTHERWISE
            ITERATE
            END
         info = ReadMMCD(list.i)
         PARSE VAR meta md5'0'x cat'0'x rev'0'x
         title = GetMMCDTitle(info)
         IF state = 2 THEN DO
            /* upload */
            IF info = '' THEN
               ITERATE /* no upload or no data */
            /* clear revision */
            rev = '' /* this will be replced by 0 in the next section */
            CALL Info "Information of CD "title" has been entered - creating upload."
            END
          ELSE DO
            /* update? */
            IF info = '' THEN DO
               CALL Error "CD state inconsistent ("list.i' -> 'state"): no title data available."
               /*CALL SetCDState list.i, 0*/
               ITERATE
               END
            IF state = 3 THEN DO
               /* verify MD5 hash */
               IF md5 = '' THEN DO
                  CALL StoreMMCD list.i, , C2X(MMHash(info, "MD5"))'0'x||cat'0'x||rev /* recreate MD5 hash anyway */
                  CALL Warning "CD state inconsistent - missing MD5 hash recreated for "title"."
                  ITERATE
                  END
               CALL Debug "Verify MD5 hash of "title
               IF md5 = C2X(MMHash(info, "MD5")) THEN
                  ITERATE /* no changes */
               CALL Debug "- MD5 hash changed from "md5" to "C2X(MMHash(info, "MD5"))
               CALL Info "Information of CD "title" has changed - creating update."
               END
             /* ELSE  state = 4 -> force recreation */
            END
         /* do it! */
         CALL AddCD list.i, info, md5'0'x||cat'0'x||rev
         END
      END

   /* create upload packets */
   CALL Section "Creating "query.0" upload packets..."
   IF query.0 = 0 THEN RETURN
   IF POS('S', opt.usedb) = 0 THEN
      CALL Fatal 29, 'Server connection required for creation of upload records.'
   /* initialize cddb server */
   IF CDDBinit(WORD(opt.dbserver, 1)) = '' THEN
      RETURN
   lcat = ReadCategories()

   DO i = 1 TO query.0
      PARSE VAR meta.i md5'0'x cat'0'x rev'0'x
      title = GetMMCDTitle(data.i)
      IF rev = '' THEN
         rev = 0
       ELSE
         rev = rev +1
      CALL Info 'Creating upload for 'title', category 'cat', revision 'rev'.'
      /* query some missing information */
      IF cat = '' THEN DO
         SAY "Category required for upload of "title
         IF lcat = '' THEN DO
            CALL Error 29, "Category list is missing, giving up."
            ITERATE
            END
         SAY "Categories: "lcat
         SAY 'Enter category:'
         PULL cat
         cat = IdentifyCategory(cat, lcat)
         IF cat = '' THEN
            ITERATE
         END
      /* doit! */
      file = CreateUpload(query.i, data.i, cat, rev)
      IF file \= '' THEN DO
         CALL SetCDState query.i, '4 'file
         /* update cdp.ini meta data */
         CALL StoreMMCD query.i, , C2X(MMHash(data.i, "MD5"))'0'x||cat'0'x||rev
         END
      END
   CALL CDDBExit
   RETURN

CreateUpload: PROCEDURE EXPOSE opt. con.
/* create upload packet

   parameters:
      ARG(1) TOC of CD
      ARG(2) cd-title||'0'x||track1||'0'x||...trackn
      ARG(3) category
      ARG(4) revision
   return:
      filename  OK, xmcd file created
      ''        error
*/
   cddbtoc = CalcCDDBTOC(ARG(1))

   /* get disc ID */
   tmp = CDDBCommand('DISCID 'cddbtoc, 2)
   IF tmp = '' THEN
      RETURN ''
   discid = WORD(tmp, WORDS(tmp))

   /* create file name */
   fname = opt.uplpath||ARG(3)'-'discid
   CALL Info 'Creating upload file 'fname'.'

   /* parse CD data */
   CALL SplitMMCDData(ARG(2))
   X.rev = ARG(4)

   /* consistency check */
   IF \CheckCDDBData(ARG(1)) THEN
      RETURN ''

   /* looking for old data */
   IF ServerRead(discid, ARG(3)) THEN DO
      /* save old data */
      CALL CHAROUT fname'.old', xmcd
      CALL STREAM fname'.old', 'c', 'close'
      /* merge */
      IF \MergeMMCDData(ARG(1), ARG(2)) THEN
         RETURN ''
      END

   /* create file */
   IF \CreateXMCD(cddbtoc, fname, discid) THEN
      RETURN ''
   RETURN ARG(3)'-'discid

CheckCDDBData: PROCEDURE EXPOSE opt. TIT. EXT. X.
/* check CDDB dat for consistency
   parameter:
      ARG(1) TOC of CD
      TIT.   Stemmed variable which contains the title information for the TTITLE= fields.
             TIT.0 is the disk title.
      EXT.   Stemmed variable which contains the extended information for the EXTT= fields.
             EXT.0 is the extended information for the disk (EXTD=).
      X.year Release year (DYEAR=)
   return:
      RESULT (boolean) OK?
*/
   ntrk = WORD(ARG(1), 1)
   ok = 1
   various = ABBREV(TRANSLATE(TIT.0), 'VARIOUS') /* is various artists? */
   /* split artist, album, release year and extended infos */
   IF POS(' / ', TIT.0) = 0 THEN DO
      CALL Warning 'Missing artist separator (" / ") in disc title.'
      IF \various THEN
         DO i = 1
            IF i > ntrk THEN DO
               CALL Warning 'CD seems to have various artists - prepending "Various / ".'
               TIT.0 = 'Various / 'TIT.0
               various = 1
               LEAVE
               END
            IF POS(' / ', TIT.i) = 0 THEN DO
               ok = 0
               LEAVE
               END
            END
       ELSE
         ok = 0
      END
   /* split and check track titles */
   allartist = 1
   DO i = 1 TO ntrk
      artist.i = POS(' / ', TIT.i) \= 0
      allartist = allartist & artist.i
      IF TIT.i = '' THEN
         ok = Warning(0, 'Title of track 'i' is empty.')
       ELSE IF various & \artist.i THEN
         ok = Warning(0, 'Missing artist separator (" / ") in title of track 'i' of various artists disk.')
      END
   DO i = i TO WORDS(ARG(1))-3 /* CD extra ... */
      EXT.i = ''
      TIT.i = 'Data'
      END
   /* check for various artist CDs */
   IF allartist & \various THEN
      ok = Warning(0, 'CD seems to have various artists. Therefore the disc title should start with "Various".')
   /* commit warnings, if any */
   IF \ok THEN
      RETURN Commit("There are warnings, continue anyway?")
   /* done */
   RETURN 1

MergeMMCDData: PROCEDURE EXPOSE opt. TIT. EXT. X. xmcd
/* Merge new data with old data
   parameter:
      ARG(1) TOC of CD
      xmcd   old data
      TIT.   Stemmed variable which contains the title information for the TTITLE= fields.
             TIT.0 is the disk title.
      EXT.   Stemmed variable which contains the extended information for the EXTT= fields.
             EXT.0 is the extended information for the disk (EXTD=).
      X.year Release year (DYEAR=)
   return:
      RESULT 1/0 OK/parsing failed or data refused
      TIT.   Stemmed variable which contains the title information for the TTITLE= fields.
             TIT.0 is the disk title.
      EXT.   Stemmed variable which contains the extended information for the EXTT= fields.
             EXT.0 is the extended information for the disk (EXTD=).
      X.year Release year (DYEAR=)
*/
   /* parse old data */
   IF \GetOldData() THEN
      RETURN 1 /* failed parsing is successful merging */
   /* old data found (and logically OK) */
   IF OX.rev >= X.rev THEN DO
      /* revision clash! */
      IF X.rev = 0 THEN
         CALL Warning 'Your submission conflicts with an existing entry. This might be a discid clash.'||'0d0a'x||TIT.0
       ELSE DO
         CALL Warning 'A newer revision already exists on the server. Your submission will be ignored.'||'0d0a'x||TIT.0
         CALL StoreMMCD ARG(1), , C2X(MMHash(data.i, "MD5"))'0'x||cat'0'x||rev
         END
      RETURN 0
      END
   /* merge old data */
   ok = 1
   IF \opt.ext THEN DO
      DO i = 0 TO WORDS(ARG(1))-3
         IF EXT.i \= '' THEN
            ok = Warning(0, 'Ignoring extended data in title of track 'i' while option --ext is disabled.'||'0d0a'x||TIT.0'0d0a'x||EXT.i)
         END
      EXT. = OEXT.
      END
    ELSE
      DO i = 0 TO WORDS(ARG(1))-3
         IF EXT.i = '' & OEXT.i \= '' THEN
            ok = Warning(0, 'Extended data in title of track 'i' is removed. Maybe the last lookup was without option --ext.'||'0d0a'x||TIT.0'0d0a'x||OEXT.i)
         END
   IF X.year = '' & OX.year \= '' THEN
      ok = Warning(0, 'Metainfo year ('OX.year') sholud not be removed.'||'0d0a'x||TIT.0)
   X.genre = OX.genre
   /* commit warnings, if any */
   IF \ok THEN
      RETURN Commit("There are warnings, continue anyway?")
   RETURN 1

GetOldData: PROCEDURE EXPOSE opt. xmcd OTIT. OEXT. OX.
/* Get data of old XMCD record. Subfunction to Merge old data
   parameter:
      xmcd   old data record
   return:
      RESULT 1/0 OK/Error
      OTIT.  Stemmed variable which contains the title information for the TTITLE= fields.
             TIT.0 is the disk title.
      OEXT.  Stemmed variable which contains the extended information for the EXTT= fields.
             EXT.0 is the extended information for the disk (EXTD=).
      OX.year Release year (DYEAR=)
*/
   IF QueryXMCD() = '' THEN
      RETURN 0
   IF \ParseXMCD() THEN
      RETURN 0
   /* copy data */
   OTIT. = TIT.
   OEXT. = EXT.
   OX. = X.
   RETURN 1

/* submit */
CDDBUpload: PROCEDURE EXPOSE opt.
/* execute any upload packets
*/
   IF VERIFY(opt.opcode, 'sS', 'M') = 0 THEN
      RETURN
   IF POS('S', opt.usedb) = 0 THEN
      CALL Fatal 29, 'Server connection required for submission.'
   /* create upload list */
   query.0 = 0
   CALL GetCDList 'list'
   DO i = 1 TO list.0
      PARSE VALUE GetCDState(list.i) WITH state param
      IF state \= 4 THEN
         ITERATE
      CALL AddCD list.i, param
      END
   /* upload! */
   CALL Section "Submit "query.0" records..."
   IF query.0 = 0 THEN
      RETURN
   IF CDDBinit(WORD(opt.dbserver, 1)) = '' THEN
      RETURN
   DO i = 1 TO query.0
      CALL ExecUpload query.i, data.i
      END
   CALL CDDBExit
   RETURN

ExecUpload: PROCEDURE EXPOSE opt. con.
/* execute upload

   parameters:
      ARG(1) CD TOC
      ARG(2) filename
   return:
      1      OK, done
      0      error
*/
   fname = opt.uplpath||ARG(2)
   CALL Info 'Submit file 'fname'.'
   IF STREAM(fname, 'c', 'open read') \= 'READY:' THEN
      RETURN Warning(0, "Upload file "fname" not found.")
   PARSE VALUE ARG(2) WITH cat'-'discid
   /* read file */
   data = ''
   nel = '0d0a'x
   DO WHILE STREAM(fname, 's') = 'READY'
      l = LINEIN(fname)
      IF l = '' THEN LEAVE
      data = data||l||nel
      END
   CALL STREAM fname, 'c', 'close'
   /* execute */
   IF CDDBSubmitCommand(cat, discid, data) = '' THEN
      RETURN 0
   /* reset state to stored */
   IF POS('S', opt.op) \= 0 THEN
      CALL SetCDState ARG(1), 3
   RETURN 1

ReadCategories: PROCEDURE EXPOSE opt. con.
/* read all cddb categories

   return:
      cat1 cat2 ...
      ''     error
*/
   CALL Debug 'Read category list'
   tmp = CDDBCommand('cddb lscat', 2)
   IF tmp = '' THEN
      RETURN ''
   cat = ''
   PARSE VAR tmp l'0D0A'x tmp
   DO WHILE tmp \= ''
      PARSE VAR tmp l'0D0A'x tmp
      IF l = '' | l = '.' THEN
         LEAVE
      cat = cat' 'l
      END
   RETURN SUBSTR(cat, 2)

IdentifyCategory: PROCEDURE EXPOSE opt.
/* Identify and verify category

   parameter:
      ARG(1) input string
      ARG(2) list of categories (from ReadCategories)
   return:
      category
      ''     error
*/
   IF ARG(1) = '' THEN
      RETURN Warning('', 'No category selected. You can retry next time:-)')
   in = TRANSLATE(ARG(1))  /* case insensitive compare */
   lcat = TRANSLATE(ARG(2))
   n = 0
   DO i = 1 TO WORDS(lcat)
      IF ABBREV(WORD(lcat, i), in) THEN DO
         cat = WORD(ARG(2), i)
         n = n +1
         END
      END
   SELECT
    WHEN n = 0 THEN
      RETURN Error('', 'Category 'ARG(1)' unknown.')
    WHEN n > 1 THEN
      RETURN Error('', 'Category 'ARG(1)' is ambiguous.')
    OTHERWISE /* n = 1 */
      CALL Info '- Using category 'cat'.'
      RETURN cat
      END

/****************************************************************************
*
*  SECTION 2c - high level control functions: special features
*
****************************************************************************/

Special: PROCEDURE EXPOSE opt.
/* perform special (out of order) actions */
   IF opt.special \= '' THEN DO
      PARSE VAR opt.special func','para
      INTERPRET 'CALL 'TRANSLATE(func)' 'para
      EXIT RESULT
      END
   RETURN

Close: PROCEDURE EXPOSE opt.
   /* close all device handles */
   devlist = opt.cddev
   DO WHILE devlist \= ''
      PARSE VAR devlist dev','devlist
      CALL MCIcmd 'close 'dev' wait'
      END
   RETURN 0

ResetMD5: PROCEDURE EXPOSE opt.
/* reset all MD5 checksums */
   CALL Section 'Recreate all MD5 hashes...'
   CALL GetCDList 'list'
   DO i = 1 TO list.0
      info = ReadMMCD(list.i)
      IF info = '' THEN
         ITERATE
      CALL Info 'reset MD5 sum of 'GetMMCDTitle(info)
      PARSE VAR meta md5'0'x cat'0'x rev'0'x
      IF cat = '' & md5 = '' THEN
         CALL StoreMMCD list.i, , '0000'x
       ELSE
         CALL StoreMMCD list.i, , C2X(MMHash(info, "MD5"))'0'x||cat'0'x||rev
      END
   RETURN 0

ReenterUpload: PROCEDURE EXPOSE opt.
/* reenter upload entries into state database

   parameter:
    ARG(1) uploadfile
*/
   IF ARG(1) = '' THEN
      CALL Fatal 40, "Action ReenterUpload requires a filename."
   CALL Info 'Recreating reference for file 'ARG(1)'.'
   PARSE VALUE ARG(1) WITH cat'-'discid
   IF discid = '' THEN
      CALL Warning 0, 'Recreation filename should have the form category-discid.'
   IF STREAM(ARG(1), 'c', 'open read') \= 'READY:' THEN
      RETURN Error(30, 'Cannot read file 'ARG(1)'.')
   toc = QueryCDDBFile('l = LINEIN("'ARG(1)'")', discid)
   IF toc = '' THEN
      RETURN Error(20, 'Parsing of file 'ARG(1)' failed.')
   toc = GuessCDLength(toc)
   IF ReadMMCD(toc) = '' THEN DO
      SAY 'Warning:   CDP.INI seems to contain no data for the xmcd file 'ARG(1)'.'
      SAY 'Continue anyway?'
      PULL tmp
      IF TRANSLATE(tmp) \= 'Y' THEN
         RETURN 18
      END
   CALL SetCDState toc, '4 'ARG(1)
   CALL Debug '- done: 'toc
   RETURN 0

StoreFile: PROCEDURE EXPOSE opt.
   IF ARG(1) = '' THEN
      CALL Fatal 40, 'Action StoreFile requires a filename'
   IF \ReadXMCDFile(ARG(1)) THEN
      CALL Fatal 30, 'Cannot open file "'ARG(1)'"'
   toc = QueryXMCD()
   IF toc = '' THEN
      RETURN 20
   toc = GuessCDLength(toc)
   IF \ParseXMCD() THEN
      RETURN 20
   CALL Info 'CD Information stored: 'TIT.0
   CALL CreateMMCDData
   CALL StoreMMCD toc, RESULT, meta
   CALL SetCDState toc, 3
   RETURN 0

UpdateDB: PROCEDURE EXPOSE opt.
/* WinDB updater
   migrate tar file to database
   parameter:
    ARG(1) File or path to migrate
*/
   IF ARG(1) = '' THEN
      CALL Fatal 40, 'Action StoreFile requires a filename'
   /* check DB type */
   IF opt.dbtype = 'A' THEN
      CALL Error 24, "For updates you need to specify the database version. Auto detection (-t) is not sufficient."
   /* check source file type */
   CALL SysFileTree ARG(1), 'file', 'B'
   deltemp = 0
   IF SUBSTR(file.1, 32, 1) = 'D' THEN /* is folder ? */
      tmpfolder = STRIP(ARG(1), 'T', '\')
    ELSE DO
      file = FILESPEC('N', ARG(1))
      type = ''
      p = POS('.', TRANSLATE(file))
      IF p \= 0 THEN
         type = TRANSLATE(SUBSTR(file, p))
      dcp = ''
      SELECT
       WHEN file = '' THEN
         tmpfolder = LEFT(ARG(1), LENGTH(ARG(1)) -1)
       WHEN type = '.TAR' THEN NOP
       WHEN type = '.TAR.GZ' THEN
         dcp = 'gzip -cd'
       WHEN type = '.TAR.BZ2' THEN
         dcp = 'bzip2 -cd'
       OTHERWISE
         CALL Fatal 30, "The file "ARG(1)" has a not supported type ("type"). Only .tar, .tar.gz and .tar.bz2 will work."
         END
      tmpfolder = opt.localdb
      IF file \= '' THEN DO
         IF opt.dbtype = 'W' THEN DO
            /* create temporary folder */
            tmpfolder = SysTempFileName(VALUE('TEMP',,'OS2ENVIRONMENT')'\cddbmmcd?????.tmp')
            CALL SysMkDir(tmpfolder)
            IF RESULT \= 0 THEN
               CALL Fatal 28, "Failed to create temporary folder (RC="RESULT")"
            deltemp = 1
            END
         /* unpack */
         CALL Info "Unpack "ARG(1)" ..."
         IF dcp \= '' THEN
            dcp = '@call 'dcp' "'ARG(1)'" | tar -xf - -C "'tmpfolder'"'
          ELSE
            dcp = '@call tar -xf "'ARG(1)'" -C "'tmpfolder'"'
         dcp
         IF RC \= 0 THEN
            CALL Fatal 25, dcp" returned a bad status: "RC
         END
      END
   /*SAY tmpfolder*/
   /* migrate windows DB */
   IF opt.dbtype = 'W' THEN DO
      /* get categories */
      CALL SysFileTree tmpfolder'\*', 'cat', 'DO'
      /* iterate over categories */
      DO c = 1 TO cat.0
         cat = FILESPEC('N', cat.c)
         IF \DATATYPE(cat, 'A') THEN DO
            CALL Warning "Folder "cat" is not a valid CDDB category - skipping."
            ITERATE
            END
         /* scan destination */
         CALL Info "Scan for source and destination files for category "cat" ..."
         CALL SysFileTree opt.localdb'\'cat'\??to??', 'wfile', 'FSO'
         IF wfile.0 = 0 THEN DO
            CALL Warning "There are no database files for the category "cat". - ignoring updates."
            ITERATE
            END
         /* scan for updates */
         CALL SysFileTree cat.c'\????????', 'ufile', 'FO'
         /* iterate over all windb files */
         DO i = 1 TO wfile.0
            /* merge ! */
            CALL XFDo wfile.i, wfile.i'.new'
            END /* next windb file */
         /* free resources */
         DROP ufile.
         DROP wfile.
         DROP match.
         END /* next category */
      /* clean up */
      IF deltemp THEN
         CALL SysDestroyObject tmpfolder
      END
   RETURN 0

MQSort: PROCEDURE EXPOSE match.
/* quick sort match.
      ARG(1) lower bound
      ARG(2) upper bound
*/
   lo = ARG(1)
   hi = ARG(2)
   mi = (hi + lo) %2
   /*SAY lo hi mi m*/
   DO WHILE hi >= lo
      DO WHILE 'X'match.lo < 'X'match.mi
         lo = lo +1
         END
      DO WHILE 'X'match.hi > 'X'match.mi
         hi = hi -1
         END
      IF hi >= lo THEN DO
         tmp = match.lo
         match.lo = match.hi
         match.hi = tmp
         lo = lo +1
         hi = hi -1
         END
      END
   IF hi > ARG(2) THEN
      CALL MQSort ARG(2), hi
   IF ARG(3) > lo THEN
      CALL MQSort lo, ARG(3)
   RETURN

XFDo: PROCEDURE EXPOSE opt. ufile.
/* merge a result set of xmcd file into a single win db file
   parameter:
    ARG(1) source file
    ARG(2) destination file
   return:
    0      file not updated
    1      file updated
   globals:
    match. result set of matches
*/
   PARSE VALUE FILESPEC('N', ARG(1)) WITH hmin'to'hmax
   IF \DATATYPE(hmin, 'X') | \DATATYPE(hmax, 'X') THEN DO
      CALL Warning "Cannot parse path of file "ARG(1)". File ignored."
      RETURN 0
      END
   /* find matching updates */
   hmin = X2D(hmin)
   hmax = X2D(hmax)
   cnt = 0
   DO j = 1 TO ufile.0
      tmp = FILESPEC('N', ufile.j)
      IF \DATATYPE(tmp, 'X') THEN
         ITERATE
      p = X2D(LEFT(tmp, 2))
      IF p < hmin | p > hmax THEN
         ITERATE
      cnt = cnt +1
      match.cnt = FILESPEC('D', ufile.j)FILESPEC('P', ufile.j)TRANSLATE(tmp, 'abcdef', 'ABCDEF')
      END
   /* zero ? */
   IF cnt = 0 THEN DO
      CALL Info "No updates for file "ARG(1)
      RETURN 0
      END
   CALL Info "Updating file "ARG(1)" ..."
   /* sort matches */
   CALL MQSort 1, cnt
   IF opt.verbode >= 5 THEN
      DO j = 1 TO cnt
         CALL Debug 5, "- updateing "FILESPEC('N', match.j)
         END
   /*TRACE i*/
   CALL SysFileDelete ARG(2)
   IF STREAM(ARG(2), 'c', 'open write') \= 'READY:' THEN
      CALL Fatal 21, "Failed to open file "ARG(2)" for writing"
   /* merge! */
   /*l = STREAM(ARG(1), 'c', 'query size')
   q = CHARIN(ARG(1), , l) - memory leak
   CALL STREAM ARG(1), 'c', 'close'*/
   q = MMFileIn(ARG(1))
   l = LENGTH(q)
   IF \ABBREV(q, '#FILENAME=') THEN
      CALL Fatal 24, "Windows xmcd file must begin with #FILENAME=."
   j = 1
   p = 1
   DO WHILE p < l & j <= cnt
      id = X2D(TRANSLATE(SUBSTR(q, p+10, 8), 'abcdef', 'ABCDEF'))
         nid = X2D(FILESPEC('N', match.j))
         lp = p
         IF id <= nid THEN DO
         /* find section end */
         p = POS('0a'x||'#FILENAME=', q, p+11) +1
         IF p = 1 THEN
            p = LENGTH(q) +1
         END
      IF nid <= id THEN DO
         /* insert file */
         CALL XFInsert match.j, ARG(2)
         j = j +1
         END
       ELSE
         /* transfer section */
         IF CHAROUT(ARG(2), SUBSTR(q, lp, p-lp)) \= 0 THEN
            CALL Fatal 27, "Failed to write to "ARG(2)
      END
   /* write remaining part of q */
   IF CHAROUT(ARG(2), SUBSTR(q, p)) \= 0 THEN
      CALL Fatal 27, "Failed to write to "ARG(2)
   DROP q
   /* transfer remaining new content */
   DO WHILE j <= cnt
      /* insert file */
      CALL XFInsert match.j, ARG(2)
      /*CALL Debug 6, "I "FILESPEC('N', match.j)*/
      j = j +1
      END
   /* close files */
   CALL STREAM ARG(2), 'c', 'close'
   /* replace old file */
   '@copy "'ARG(2)'" "'ARG(1)'" >nul'
   '@del "'ARG(2)'"'
   RETURN 1

XFInsert: PROCEDURE EXPOSE opt.
/* insert xmcd file
      ARG(1) source file
      ARG(2) destination stream
*/
   d = MMFileIn(ARG(1))
   IF d = '' THEN
      CALL Fatal 22, "Failed to read update file "ARG(1)
   IF CHAROUT(ARG(2), '#FILENAME='FILESPEC('N', ARG(1))'0a'x) \= 0 | CHAROUT(ARG(2), d) \= 0 THEN
      CALL Fatal 27, "Failed to write to "ARG(2)
   RETURN

XFTsf: PROCEDURE EXPOSE opt.
/* transfer xmcd file block
      ARG(1) source stream
      ARG(2) destination stream
      ARG(3) filename line
*/
   IF ARG(2, 'e') THEN DO
      IF LINEOUT(ARG(2), ARG(3)) \= 0 THEN
         CALL Fatal 27, "Failed to write to "ARG(2)
      DO FOREVER
         l = LINEIN(ARG(1))
         IF l = '' | ABBREV(l, '#FILENAME=') THEN
            RETURN l /* next section */
         IF LINEOUT(ARG(2), l) \= 0 THEN
            CALL Fatal 27, "Failed to write to "ARG(2)
         END
      END
    ELSE
      DO FOREVER
         l = LINEIN(ARG(1))
         IF l = '' | ABBREV(l, '#FILENAME=') THEN
            RETURN l /* next section */
         END


/****************************************************************************
*
*  SECTION 3a - xmcd import/export
*
****************************************************************************/

QueryXMCD: PROCEDURE EXPOSE opt. X. xmcd
/* Query header information from xmcd data

   parameters:
      xmcd   xmcd data
      ARG(1) discid, optional. If specified, the discid will be verified.
   return:
      Table of contents
      ''      error
   return in global vars:
      X.discid discid. As in the xmcd specification there might be more discids separated by ','.
      X.rev    revision (0 by default)
      X.lenght disc length in seconds

   Remark: The returned TOC is usually not identical to te one from GetToc for several reasons.
   First of all the dics length is truncated to whole seconds rather than frames in the xmcd record.
   Secondly the returned number of tracks includes possible data tracks of CD-extra.
   Other reasons are e.g. slightly different CD releases.
*/
   IF \ABBREV(xmcd, '# xmcd') THEN
      RETURN Error('', 'xmcd data has an unknown format.')
   TOC = ''
   len = ''
   X.discid = ''
   X.rev = '0'
   X.length = ''
   data = xmcd
   DO line = 0
      /* read line */
      PARSE VAR data l'0a'x data
      l = STRIP(l, 'T', '0d'x) /* accept CR LF as wel as LF */
      IF l = '' THEN
         RETURN Error('', 'xmcd data has a logical error: no content found.')
      SELECT
       WHEN ABBREV(l, "# Track frame offsets:") THEN DO
         /* read track offsets */
         DO i = 1
            PARSE VAR data l'0a'x data
            l = STRIP(l, 'T', '0d'x) /* accept CR LF as well as LF */
            PARSE VAR l '#' offset
            IF offset = '' THEN
               LEAVE
            offset = STRIP(TRANSLATE(offset,,'9'x))
            TOC = TOC' 'offset
            END
         ntrk = i-1
         END
       WHEN ABBREV(l, "# Revision:") THEN
         PARSE VALUE SUBSTR(l, 12) WITH X.rev dummy
       WHEN ABBREV(l, "# Disc length:") THEN
         PARSE VALUE SUBSTR(l, 15) WITH X.length dummy
       WHEN LEFT(l, 1) = '#' THEN NOP /* any other comment */
       OTHERWISE
         PARSE VAR l item'='X.discid
         IF item \= 'DISCID' THEN
            RETURN Error('', 'The first data entry in the xmcd file should be "DISKID=".')
         IF ARG(1) = '' THEN
            PARSE VAR X.discid X.discid','
          ELSE /* check discid */
            IF POS(ARG(1), X.discid) = 0 THEN
               RETURN Error('', 'The discid of the xmcd data ('X.discid') does not match 'ARG(1)'.')
         LEAVE
         END
      END
   CALL Debug 'discid:'X.discid', len:'len', toc:'toc
   len = X2D(SUBSTR(X.discid, 3,4), 5) *75 + WORD(TOC,1)
   RETURN ntrk' 'len-WORD(TOC,1)||TOC' 'len

GuessCDLength: PROCEDURE EXPOSE opt.
/* Correct the length of the CD based on already stored information.
   parameter:
      ARG(1) preliminary TOC
   return:
      RESULT corrected TOC
   Note: The disc length in XMCD entries has only an accouracy of one second, but CDDBMMCD stores
   the information based on the disc length in frames. To avoid duplicate entries the exact disc
   length must be known. So the problem only comes up if the TOC is extracted from a XMCD file.
   This function tries to guess the disc length based on existing, similar entries.
*/
   n = WORDS(ARG(1))
   cmp = SUBWORD(ARG(1), 3, n-3)' '
   CALL GetCDList 'li'
   DO i = 1 TO li.0
      IF \ABBREV(SUBWORD(li.i, 3), cmp) THEN
         ITERATE
      /* found possible match */
      d = WORD(li.i, n)
      IF d = '' THEN
         ITERATE
      d = d - WORD(ARG(1), n)
      IF ABS(d) >= 75 THEN /* tolerate difference less than 1 second */
         ITERATE
      /* found match */
      IF d \= 0 THEN
         CALL Info 'Found similar CD entry with an length of 'WORD(li.i,2)' frames (prevoiusly 'WORD(ARG(1),2)').'
      RETURN li.i
      END
   RETURN ARG(1) /* fallback: old value */

ParseXMCD: PROCEDURE EXPOSE lines opt. TIT. EXT. X. xmcd
/* parse xmcd record
   parameter:
      xmcd   xmcd data
   return:
      RESULT 1/0 =  OK/Error
      TIT.   Stemmed variable which contains the title information for the TTITLE= fields.
             TIT.0 is the disk title.
      EXT.   Stemmed variable which contains the extended information for the EXTT= fields.
             EXT.0 is the extended information for the disk (EXTD=).
      X.year Release year (DYEAR=)
      X.genre Genre (DGENRE=)
*/
   IF \ABBREV(xmcd, '# xmcd') THEN
      RETURN Error(0, 'xmcd data has an unknown format.'||'0d0a'x||LEFT(xmcd, 20))
   DROP TIT.
   DROP EXT.
   DROP X.year
   DROP X.genre
   data = xmcd
   DO line = 0
      /* read line */
      PARSE VAR data l'0a'x data
      l = STRIP(l, 'T', '0d'x) /* accept CR LF as well as LF */
      IF l = '' THEN
         LEAVE
      IF LEFT(l, 1) = '#' THEN
         ITERATE /* comment */
      PARSE VAR l item'='val
      SELECT
       WHEN item = 'DTITLE' THEN
         TIT.0 = DefVal('TIT.0')val
       WHEN item = 'EXTD' THEN
         EXT.0 = DefVal('EXT.0')val
       WHEN item = 'DYEAR' THEN
         X.year = FromCDDBString(val)
       WHEN item = 'DGENRE' THEN
         X.genre = FromCDDBString(val)
       WHEN ABBREV(item, 'TTITLE') THEN DO
         i = SUBSTR(item,7) +1
         TIT.i = DefVal('TIT.'i)val
         END
       WHEN ABBREV(item, 'EXTT') THEN DO
         i = SUBSTR(item,5) +1
         EXT.i = DefVal('EXT.'i)val
         END
       OTHERWISE NOP/* this should be superflous - well, not in my case W4,FP15 */
         END
      END
   /* some translations of escape characters */
   DO i = 0 WHILE SYMBOL('TIT.i') = 'VAR'
      TIT.i = FromCDDBString(TIT.i)
      IF SYMBOL('EXT.i') = 'VAR' THEN
         EXT.i = FromCDDBString(EXT.i)
      END
   /* done */
   RETURN 1

DefVal:
/* read symbol but return default value if not defined
   parameter:
      ARG(1) symbol name
      ARG(2) default value, optional
   return:
      RESULT value
*/
   IF SYMBOL(ARG(1)) = 'VAR' THEN
      RETURN VALUE(ARG(1))
    ELSE
      RETURN ARG(2)

CreateXMCD: PROCEDURE EXPOSE lines opt. TIT. EXT. X.
/* create xmcd file
   parameter:
      ARG(1) cddb TOC of CD (different from internal representation)
      ARG(2) file name
      ARG(3) discid
      TIT.   Stemmed variable which contains the title information for the TTITLE= fields.
             TIT.0 is the disk title.
      EXT.   Stemmed variable which contains the extended information for the EXTT= fields.
             EXT.0 is the extended information for the disk (EXTD=).
      X.year Release year (DYEAR=)
      X.genre Genre
      X.rev  Revision
   return:
      RESULT 1/0 OK/Error
*/
   ntrk = WORD(ARG(1), 1)
   /* create file */
   CALL SysFileDelete ARG(2) /* 'open write replace' is not supported in Classic REXX */
   IF STREAM(ARG(2), 'c', 'open write') \= 'READY:' THEN
      RETURN Error(0, 'Failed to create cddb upload file 'ARG(2)'.')
   /* write header */
   CALL LINEOUT ARG(2), '# xmcd'
   CALL LINEOUT ARG(2), '#'
   CALL LINEOUT ARG(2), '# Track frame offsets:'
   DO i = 2 TO ntrk+1
      CALL LINEOUT ARG(2), '#'||'09'x||WORD(ARG(1), i)
      END
   CALL LINEOUT ARG(2), '#'
   CALL LINEOUT ARG(2), '# Disc length: 'WORD(ARG(1), ntrk+2)' seconds'
   CALL LINEOUT ARG(2), '#'
   CALL LINEOUT ARG(2), '# Revision: 'X.rev
   CALL LINEOUT ARG(2), '# Submitted via: 'opt.client' by 'opt.user'@'opt.host
   /*CALL LINEOUT fname, '# Category: 'ARG(3)*/
   CALL LINEOUT ARG(2), '#'
   /* write data */
   CALL LINEOUT ARG(2), 'DISCID='ARG(3)
   CALL WriteKey ARG(2), 'DTITLE', TIT.0
   CALL WriteKey ARG(2), 'DYEAR', X.year
   CALL WriteKey ARG(2), 'DGENRE', X.genre
   DO i = 1 TO ntrk
      CALL WriteKey ARG(2), 'TTITLE'i-1, TIT.i
      END
   /* extended infos */
   CALL WriteKey ARG(2), 'EXTD', EXT.0
   DO i = 1 TO ntrk
      CALL WriteKey ARG(2), 'EXTT'i-1, EXT.i
      END
   /* done */
   CALL LINEOUT ARG(2), 'PLAYORDER='
   CALL STREAM ARG(2), 'c', 'close'
   RETURN 1


WriteKey: PROCEDURE EXPOSE opt.
/* write key entry to cddb data file
   subfunction to CreateUpload
   input:
      ARG(1) file name
      ARG(2) key
      ARG(3) data
*/
   data = ToCDDBString(ARG(3))
   len = 71 - LENGTH(ARG(2))
   DO WHILE LENGTH(data) > len
      CALL LINEOUT ARG(1), ARG(2)'='LEFT(data, len)
      data = SUBSTR(data, len+1)
      END
   CALL LINEOUT ARG(1), ARG(2)'='data
   RETURN

FromCDDBString: PROCEDURE EXPOSE opt.cp /* convert cddb file line to ascii */
   r = MMTranslateCp(ARG(1), opt.cp, , '_')
   p = 1
   DO FOREVER
      p = POS('\', r, p)
      IF p = 0 THEN
         LEAVE
      c = SUBSTR(r, p+1, 1)
      SELECT
       WHEN c = 'n' THEN
         c = '0D0A'x
       WHEN c = 't' THEN
         c = '09'x
       OTHERWISE NOP
         END
      r = INSERT(c, DELSTR(r, p, 2), p-1)
      p = p + LENGTH(c)
      END
   RETURN r

ToCDDBString: PROCEDURE EXPOSE opt.cp /* convert ascii text to cddb line */
   r = ARG(1)
   p = 1
   DO FOREVER
      p = VERIFY(r, '\'||'09'x, 'M', p)
      IF p = 0 THEN
         LEAVE
      IF SUBSTR(r, p+1, 1) = '09'x THEN
         r = OVERLAY('t', r, p)
      r = INSERT('\', r, p-1)
      p = p +2
      END
   p = 1
   DO FOREVER
      p = POS('0D0A'x, r, p)
      IF p = 0 THEN
         LEAVE
      r = OVERLAY('\n', r, p)
      p = p +2
      END
   RETURN MMTranslateCp(r, , opt.cp, '_')

/****************************************************************************
*
*  SECTION 3b - CDP.ini (OS/2 CD player) import/export
*
****************************************************************************/

CreateMMCDData: PROCEDURE EXPOSE lines opt. TIT. EXT. X. meta
/* parse cddb file and store infos

   parameters:
      TIT.   Stemmed variable which contains the title information for the TTITLE= fields.
             TIT.0 is the disk title.
      EXT.   Stemmed variable which contains the extended information for the EXTT= fields.
             EXT.0 is the extended information for the disk (EXTD=).
      X.year Release year (DYEAR=)
      X.cat  cddb category (for meta data)
      X.rev  xmcd revision (for meta data)
   return:
      RESULT cd-title||'0'x||track1||'0'x||...trackn (optional)
      meta   meta data: MD5-hash||'0'x||category||'0'x||revision (optional)
*/
   /* generate result */
   r = MMCDFromVar('TIT.0',opt.ac)||MMCDFromVar('X.year',0,' [',']')
   IF opt.ext THEN
      r = r||MMCDFromVar('EXT.0',0,' {','}')
   DO i = 1 WHILE SYMBOL('TIT.'i) = 'VAR'
      tmp = MMCDFromVar('TIT.'i,opt.ac)
      IF opt.trkfix \= 0 THEN
         SELECT
          WHEN opt.trkfix <= 2 THEN DO
            PARSE VAR tmp a' / ' b
            IF b = '' THEN
               PARSE VAR tmp a' - ' b
            IF b \= '' THEN
               a = STRIP(a)
               b = STRIP(b)
               IF opt.trkfix = 1 THEN
                  tmp = b' /' a /* swap title and artist */
                ELSE
                  tmp = a' /' b
            END
          WHEN opt.trkfix = 4 THEN
            IF DATATYPE(LEFT(tmp, 2), 'W') & SUBSTR(tmp,3,1) = ' ' THEN
               tmp = SUBSTR(tmp, 4)
          OTHERWISE NOP
            END
      r = r'00'x||tmp
      IF opt.ext THEN
         r = r||MMCDFromVar('EXT.'i,0,' {','}')
      END
   /* TODO: seperate the store function from read */
   meta = C2X(MMHash(r, "MD5"))'0'x||MMCDFromVar('X.cat',0)'0'x||MMCDFromVar('X.rev',0)
   RETURN r

MMCDFromVar:
/* read variable
   parameter:
      ARG(1) var name
      ARG(2) case adjustment
      ARG(3) before
      ARG(4) after
      ARG(5) default value
   return:
      RESULT value
*/
   IF SYMBOL(ARG(1)) \= 'VAR' THEN
      RETURN ARG(5)
   mytmp = VALUE(ARG(1))
   IF mytmp = ARG(5) THEN
      RETURN mytmp
   IF ARG(2) THEN
      mytmp = CaseAdj(mytmp)
   RETURN ARG(3)||mytmp||ARG(4)

SplitMMCDData: PROCEDURE EXPOSE opt. TIT. EXT. X.
/* Parse the OS/2 CD-player record and split it into several fields
   parameter:
      ARG(1) cd-title||'0'x||track1||'0'x||...trackn
   return in global vars: (Any of these vars will be empty in case the filed does not exist.)
      TIT.   Stemmed variable which contains the title information for the TTITLE= fields.
             TIT.0 is the disk title.
      EXT.   Stemmed variable which contains the extended information for the EXTT= fields.
             EXT.0 is the extended information for the disk (EXTD=).
      X.year Release year (DYEAR=)
*/
   PARSE VALUE ARG(1) WITH TIT.0'0'x titles
   /* split artist, album, release year and extended infos */
   PARSE VAR TIT.0 tmp'{'EXT.0'}'dummy
   IF dummy = '' THEN
      TIT.0 = STRIP(tmp)
    ELSE
      EXT.0 = ''
   PARSE VAR TIT.0 tmp'['X.year']'dummy
   IF dummy = '' THEN
      TIT.0 = STRIP(tmp)
    ELSE
      X.year = ''
   IF EXT.0 = '' THEN DO /* the other way around */
      PARSE VAR TIT.0 tmp'{'EXT.0'}'dummy
      IF dummy = '' THEN
         TIT.0 = STRIP(tmp)
       ELSE
         EXT.0 = ''
      END
   /* split track titles */
   DO i = 1 WHILE titles \= ''
      PARSE VAR titles TIT.i'0'x titles
      PARSE VAR TIT.i tmp'{'EXT.i'}'dummy
      IF dummy = '' THEN
         TIT.i = STRIP(tmp)
       ELSE
         EXT.i = ''
      END
   /* done */
   X.genre = '' /* always empty so far */
   RETURN

GetMMCDTitle: PROCEDURE EXPOSE opt.
/* extract only the cd-title from MMCD record. Strip all extended information.
   parameter:
      ARG(1) cd-title||'0'x||track1||'0'x||...trackn
   return:
      RESULT cd-title
*/
   p = VERIFY(ARG(1),'{['||'0'x,'M')
   IF p = 0 THEN
      RETURN ARG(1)
   RETURN STRIP(LEFT(ARG(1), p-1), 'T')

ReadMMCD: PROCEDURE EXPOSE opt. meta
/* check if CD information is in CDP.INI

   parameter:
      ARG(1) table of contents
   return:
      RESULT cd-title||'0'x||track1||'0'x||...trackn
             '' = no or incomplete information found
      meta   this identifier is set to the meta information of the CD (if available)
*/
   mmcdkey = CalcMMCD(ARG(1))
   CALL Debug 5, "ReadMMCD: "mmcdkey
   /* read data */
   res = SysIni(opt.cdpini, mmcdkey, 'IMMCDDiscTitle')
   IF res = 'ERROR:' THEN RETURN ''
   DO i = 1 TO WORD(ARG(1), 1)
      tmp = SysIni(opt.cdpini, mmcdkey, i)
      IF tmp = 'ERROR:' THEN RETURN ''
      res = res'00'x||tmp
      END
   /* read meta infos */
   meta = SysIni(opt.cdpini, mmcdkey, 'CDDBmeta')
   IF meta = 'ERROR:' THEN DO
      /* migrate form cddbmmcd < 0.42 */
      meta = ReadIni(opt.cdpini, mmcdkey, 'CDDBMD5')'0'x||ReadIni(opt.cdpini, mmcdkey, 'CDDBCategory')'0'x||ReadIni(opt.cdpini, mmcdkey, 'CDDBRevision')
      IF LENGTH(meta) > 2 THEN
         IF WriteIni(opt.cdpini, mmcdkey, 'CDDBmeta', meta) THEN DO
            CALL SysIni opt.cdpini, mmcdkey, 'CDDBMD5', 'DELETE:'
            CALL SysIni opt.cdpini, mmcdkey, 'CDDBCategory', 'DELETE:'
            CALL SysIni opt.cdpini, mmcdkey, 'CDDBRevision', 'DELETE:'
            END
      END
   RETURN res

StoreMMCD: PROCEDURE EXPOSE opt.
/* store CD information in CDP.INI

   parameters:
      ARG(1) table of contents
      ARG(2) cd-title||'0'x||track1||'0'x||...trackn (optional)
      ARG(3) meta data: MD5-hash||'0'x||category||'0'x||revision (optional)
*/
   CALL Debug 4, 'StoreMMCD('ARG(1)','ARG(2)','ARG(3)')'
   /* calc MMCD key */
   mmcdkey = CalcMMCD(ARG(1))
   /* store data */
   IF ARG(2,'e') THEN DO
      PARSE VALUE ARG(2) WITH tmp'00'x titles
      CALL WriteIni opt.cdpini, mmcdkey, 'IMMCDDiscTitle', tmp
      DO i = 1 UNTIL titles = ''
         PARSE VAR titles tmp'00'x titles
         CALL WriteIni opt.cdpini, mmcdkey, i, tmp
         END
      END
   /* store meta data, if any */
   IF ARG(3,'e') THEN
      CALL WriteIni opt.cdpini, mmcdkey, 'CDDBmeta', ARG(3), '0000'x
   RETURN


/****************************************************************************
*
*  SECTION 4 - cddb server connection (low level)
*
****************************************************************************/

CDDBInit: PROCEDURE EXPOSE con. opt.
/* Prepare CDDB query

   parameter:
      ARG(1) server URL
   return:
      ''        error
      otherwise OK
*/
   /* parse protocol */
   CALL Debug 5, "CDDBInit("ARG(1)")"
   PARSE VALUE TRANSLATE(ARG(1),'/','\') WITH con.protocol '://' con.server
   IF con.server = '' THEN DO
      con.protocol = 'cddb'
      con.server = ARG(1)
      END
    ELSE IF con.protocol = 'cddbp' THEN
      con.protocol = 'cddb'
    ELSE IF con.protocol \= 'cddb' & con.protocol \= 'http' THEN DO
      SAY 'Unknown cddb protocol: 'con.protocol
      RETURN ''
      END
   /* protocol dispatcher */
   INTERPRET 'RETURN CDDBInit'con.protocol'(con.server)'

CDDBCommand: /* Protocol dispatcher */
/* Send CDDB command and wait for reply

   parameter:
      ARG(1) command (optional)
      ARG(2) maximum reply message class (optional)
   return:
      ''     error
      cddb server reply
*/
   /*CALL Debug "CDDBCommand("ARG(1)","ARG(2)")"*/
   INTERPRET 'RETURN CDDBreplycheck(ARG(1), CDDBCommand'con.protocol'(ARG(1)), ARG(2))'

CDDBSubmitCommand: /* Protocol dispatcher */
/* submit entry

   parameter:
      ARG(1) category
      ARG(2) discid
      ARG(3) cddb record
   return:
      ''     error
      cddb server reply
*/
   /*CALL Debug "CDDBSubmitCommand("ARG(1)","ARG(2)","ARG(3)")"*/
   INTERPRET 'RETURN CDDBreplycheck("Submit: "ARG(1) ARG(2)"...", CDDBSubmitCommand'con.protocol'(ARG(1), ARG(2), ARG(3)), 2)'

CDDBExit: /* Protocol dispatcher */
   CALL Debug 5, "CDDBExit("ARG(1)")"
   INTERPRET 'RETURN CDDBExit'con.protocol'(ARG(1))'

CDDBreplycheck:
/* check cddb server reply

   parameter:
    ARG(1) cddb server command
    ARG(2) cddb server response
    ARG(3) maximum reply message class (optional)
   return:
    cddb server response
*/
   CALL Debug 6, 'CDDBreplycheck('ARG(1)','ARG(2)','ARG(3)')'
   IF ARG(3) \= '' & LEFT(ARG(2), 1) > ARG(3) THEN DO
      CALL Error 'Unexpected CDDB server reply:'||'0d0a'x||' > 'ARG(1)'0d0a'x||' < 'ARG(2)
      INTERPRET 'CALL CDDBExit'con.protocol
      RETURN ''
      END
   RETURN ARG(2)

/* CDDB protocol ... */
CDDBInitcddb: PROCEDURE EXPOSE con. opt.
/* Initialize CDDB server access

   parameter:
      ARG(1)    server
   return:
      ''        error
      otherwise OK
*/
   /* parse server */
   PARSE VALUE ARG(1) WITH con.server':'con.port
   IF con.port = '' THEN con.port = 8880

   con.family = 'AF_INET'
   IF VERIFY(con.server, '0123456789.') = 0 THEN
      con.addr = server
    ELSE /* DNS lookup */
      IF SockGetHostByName(con.server, 'con.') \= 1 THEN
         RETURN Error('', 'DNS lookup for 'con.server' failed.')
   con.so = SockSocket('AF_INET', 'SOCK_STREAM', 'IPPROTO_TCP')
   IF con.so < 0 THEN
      CALL Fatal 10, 'Failed to create socket'
   IF SockConnect(con.so, 'con.') \= 0 THEN
      RETURN Error('', 'Failed to connect 'con.server':'con.port)
   /*IF SockSetSockOpt(con.so, 'SOL_SOCKET', 'SO_RCVTIMEO', 30) \= 0 THEN
      CALL Warning , 'Failed to set socket options ('con.server':'con.port')'*/
   CALL Info 'Now connected to cddb://'con.server':'con.port
   CALL Info '- Reply: 'CDDBCommand(,2)

   IF CDDBCommand('CDDB HELLO 'opt.user' 'opt.host' 'opt.client, 2) = ''
      THEN RETURN ''
   IF CDDBCommand('PROTO 'opt.proto, 2) = ''
      THEN RETURN ''
   RETURN 1

CDDBCommandcddb: PROCEDURE EXPOSE con. opt.
/* Send CDDB command and wait for reply

   parameter:
      ARG(1) command (optional)
   return:
      ''     error
      cddb server reply
*/
   IF SYMBOL('con.so') \= 'VAR' THEN
      RETURN ''
   IF ARG(1,'e') THEN DO
      CALL Debug 5, 'cddb > 'ARG(1)
      IF SockSend(con.so, ARG(1)'0d0a'x) \= LENGTH(ARG(1))+2 THEN DO
         CALL SockSoClose(con.so)
         DROP con.so
         RETURN Error('', 'Failed to send "'ARG(1)'" to server 'con.server':'con.port'.')
         END
      END
   IF SockRecv(con.so, 'tmp', 32000) = -1 THEN DO
      CALL SockSoClose(con.so)
      DROP con.so
      RETURN Error('', 'Failed to receive data from server 'con.server':'con.port'.')
      END
   CALL Debug 'cddb < 'tmp
   IF SUBSTR(tmp, 2, 1) = 1 THEN
      DO WHILE Pos('0D0A2E0D0A'x, RIGHT(tmp, 10)) = 0
         IF SockRecv(con.so, 'tmp2', 32000) = -1 THEN DO
            CALL SockSoClose(con.so)
            DROP con.so
            RETURN Error('', 'Failed to receive more data from server 'con.server':'con.port'.')
            END
         CALL Debug 5, 'cddb < 'tmp2
         tmp = tmp||tmp2
         END
   RETURN STRIP(STRIP(tmp,,'0A'x),,'0D'x)

CDDBSubmitCommandcddb: PROCEDURE EXPOSE con. opt.
/* submit entry

   parameter:
      ARG(1) category
      ARG(2) discid
      ARG(3) cddb record
   return:
      ''     error
      cddb server reply
*/
   IF POS('S', opt.op) = 0 THEN
      RETURN '200' /* test mode unsupported for the cddb protocol, However, this is not an error */
   /* write! */
   IF CDDBCommand('cddb write 'ARG(1)' 'ARG(2), 3) = '' THEN
      RETURN ''
   /* send data */
   RETURN CDDBCommandcddb(ARG(3)'.'||'0d0a'x)

CDDBExitcddb: PROCEDURE EXPOSE con.
   IF SYMBOL('con.so') = 'VAR' THEN DO
      CALL SockSoClose(con.so)
      DROP con.so
      END
   RETURN ARG(1)

/* http protocol ... */
CDDBInithttp: PROCEDURE EXPOSE con. opt.
/* Initialize CDDB server access

   parameter:
      ARG(1)    server
   return:
      ''        error
      otherwise OK
*/
   /* use proxy server if set */
   IF opt.proxy \= '' THEN DO
      con.cgiScript = 'http://'ARG(1)'/~cddb/'
      PARSE VAR opt.proxy server':'con.port
      END
    ELSE DO
      con.cgiScript = '/~cddb/'
      PARSE VALUE ARG(1) WITH server':'con.port
      END
   IF con.port = '' THEN con.port = 80

   con.family = 'AF_INET'
   IF VERIFY(server, '0123456789.') = 0 THEN
      con.addr = server
    ELSE /* DNS lookup */
      IF SockGetHostByName(server, 'con.') \= 1 THEN DO
         SAY 'DNS lookup of 'server' failed.'
         RETURN ''
         END
   CALL Info 'Initialized http connection: 'con.cgiScript' -> 'con.addr':'con.port
   RETURN 1

Quotehttp: PROCEDURE
   RETURN ARG(1) /* created more problems than solved */
/*   tmp = ARG(1)
   p = 1
   pass = XRANGE('A','Z')XRANGE('a','z')'0123456789'||'0d0a'x
   DO FOREVER
      p = VERIFY(tmp, pass, 'N', p)
      IF p = 0 THEN LEAVE
      tmp = LEFT(tmp,p-1)'%'C2X(SUBSTR(tmp,p,1))||SUBSTR(tmp,p+1)
      p = p +3
      END
   RETURN tmp*/

Starthttp:
   so = SockSocket('AF_INET', 'SOCK_STREAM', 'IPPROTO_TCP')
   IF so < 0 THEN
      CALL Fatal 10, 'Failed to create socket'
   IF SockConnect(so, 'con.') \= 0 THEN DO
      CALL SockSoClose(so)
      RETURN Error(0, 'Failed to connect to 'con.addr':'con.port)
      END
   /* set a reasonable timeout for HTTP transactions */
   IF SockSetSockOpt(so, 'SOL_SOCKET', 'SO_RCVTIMEO', 60) \= 0 THEN DO
      CALL SockSoClose(so)
      CALL Warning 'Failed to set socket options ('con.addr':'con.port')'
      END
   RETURN 1

Exechttp:
   /* write */
   IF SockSend(so, ARG(1)) \= LENGTH(ARG(1)) THEN DO
      CALL SockSoClose(so)
      RETURN Error('', 'Failed to send "'httpCmd'" to server 'con.addr':'con.port'.')
      END
   /* read */
   SAY 'waiting for reply'
   IF SockRecv(so, 'tmp', 32000) = -1 THEN DO
      CALL SockSoClose(so)
      RETURN Error('', 'Failed to receive data from 'con.addr':'con.port' ('con.cgiScript').')
      END
   CALL Debug 6, '< "'tmp'"'
   DO WHILE Pos('0D0A'x, RIGHT(tmp, 2)) = 0
      IF SockRecv(so, 'tmp2', 32000) = -1 THEN DO
         CALL SockSoClose(so)
         RETURN Error('', 'Failed to receive more data from 'con.addr':'con.port' ('con.cgiScript').')
         END
      IF tmp2 = '' THEN LEAVE
      CALL Debug 6, '< "'tmp2'"'
      tmp = tmp||tmp2
      END
   CALL SockSoClose(so)
   RETURN SUBSTR(tmp, POS('0D0A0D0A'x,tmp) +4)

CDDBCommandhttp: PROCEDURE EXPOSE opt. con.
/* Send HTTP CDDB command and wait for reply

   parameter:
      ARG(1) cddb command
   return:
      ''     error
      cddb server reply
*/
   IF \Starthttp() THEN
      RETURN ''
   cddbHello = opt.user' 'opt.host' 'opt.client
   cddbMsg = TRANSLATE('cmd='Quotehttp(ARG(1))'&hello='Quotehttp(cddbHello)'&proto='opt.proto,'+',' ')
   nel = '0d0a'x
   postHdr = 'User-Agent: 'opt.client||nel'Accept: */*'nel'Content-length: 'LENGTH(cddbMsg)||nel
   httpCmd = 'POST 'con.cgiScript'cddb.cgi HTTP/1.0'nel||postHdr||nel||cddbMsg||nel
   RETURN Exechttp(httpCmd)

CDDBSubmitCommandhttp: PROCEDURE EXPOSE con. opt.
/* submit entry

   parameter:
      ARG(1) category
      ARG(2) discid
      ARG(3) cddb record
   return:
      ''     error
      cddb server reply
*/
   IF opt.email = '' THEN
      CALL Fatal 29, 'You must specify your email address (option -e) to submit via http.'
   IF \Starthttp() THEN
      RETURN ''
   /* submit command */
   nel = '0d0a'x
   data = ARG(3)
   mode = Case(POS('S', opt.op) = 0, 'test', 'submit')
   postHdr = 'User-Agent: 'Quotehttp(opt.client)||nel'Category: 'Quotehttp(ARG(1))||nel'Discid: 'Quotehttp(ARG(2))||nel'User-Email: 'opt.email||nel'Submit-Mode: 'mode||nel'Charset: ISO-8859-1'nel'Content-length: 'LENGTH(data)||nel
   httpCmd = 'POST 'con.cgiScript'submit.cgi HTTP/1.0'nel||postHdr||nel||data
   CALL Debug 7, '"'httpCmd'"'
   RETURN Exechttp(httpCmd)

CDDBExithttp:
   RETURN ARG(1)

/****************************************************************************
*
*  SECTION 5 - helper functions
*
****************************************************************************/

CalcCDDBTOC: PROCEDURE
/* convert TOC to CDDB compatible format

   parameter:
      ARG(1) table of contents (from GetTOC)
   return:
      tracks TOC(1) TOC(2) ... TOC(tracks) length[s]
*/
   tos = WORDINDEX(ARG(1),3)
   toe = LASTPOS(' ',ARG(1))
   RETURN WORDS(ARG(1))-3' 'SUBSTR(ARG(1), tos, toe-tos)' 'SUBSTR(ARG(1), toe+1)%75

CalcMMCD: PROCEDURE
/* calculate CD key of MMPM CD player

   parameter:
      ARG(1) table of contents (from GetTOC)
   return:
      mmcdkey
*/
   n = WORD(ARG(1),1)
   RETURN TRANSLATE('1245',F2MSF(WORD(ARG(1),2)),'12345')TRANSLATE('1245.78',F2MSF(WORD(ARG(1),2)-WORD(ARG(1),n+3)+WORD(ARG(1),n+2)),'12345678')

/* calculate CDID for local cddb queries

   parameter:
      ARG(1) table of contents (from GetTOC)
      ARG(2) sum delta, optional, for fuzzy search
      ARG(3) length delta, optional, for fuzzy search
   return:
      CDID
*/
CalcCDID: PROCEDURE
   lendelta = Case(ARG(2,'e'), ARG(2), 0)
   qsdelta = Case(ARG(3,'e'), ARG(3), 0)
   TOCn = WORDS(ARG(1)) - 3
   s = 0
   DO i = 1 TO TOCn
      s = s + Qsum(TRUNC(WORD(ARG(1), i+2) / 75))
      END
   l = TRUNC(WORD(ARG(1), TOCn+3) / 75)-TRUNC(WORD(ARG(1), 3) / 75)
   cdids = ""
   DO qs = s - qsdelta TO s + qsdelta
      DO len = l - lendelta TO l + lendelta
         cdids = cdids' 'D2X(qs//255, 2)D2X(len, 4)D2X(TOCn, 2)
         END
      END
   RETURN SUBSTR(cdids, 2)


/* Profile access functions ************************************************/

GetCDState:
/* query CD state from profile

   parameters:
      ARG(1) table of contents
   return:
      0      unknown
      1      query request
      2 time not found at 'time' (unixtime)
      3      information stored
      4 file upload pending
*/
   RETURN ReadIni(opt.profile, 'PendingCDs', ARG(1), 0)

SetCDState:
/* update CD state in profile

   parameters:
      ARG(1) table of contents
      ARG(2) new state
*/
   CALL Debug "SetState: "ARG(1)', 'ARG(2)
   CALL WriteIni opt.profile, 'PendingCDs', ARG(1), ARG(2), 0
   RETURN

GetCDList:
/* list all state entries

   parameters:
      ARG(1) stem variable to store the information
*/
   CALL VALUE ARG(1)'.0', 0
   RETURN SysIni(opt.profile, 'PendingCDs', 'ALL:', ARG(1)) \= ''


/****************************************************************************
*
*  SECTION 6 - utility functions
*
****************************************************************************/

MigrateProfile: PROCEDURE EXPOSE opt.
/* Migrate profile data to current CDDBMMCD version level (if neccessary). */
   old = ReadIni(opt.profile, 'Internal', 'CDDBMMCDVersion', 0.41)
   ver = LEFT(opt.version'X', VERIFY(opt.version' ', '0123456789.')-1)
   IF old = ver THEN
      RETURN 1 /* got it */
   IF old > ver THEN
      RETURN Error(0, 'The profile is from a newer CDDBMMCD version 'old'.'||'0d0a'x'You are currently using version 'ver'.'||'0d0a'x'This may result in malfunctions.')
   /* migrate */
   IF old < 0.42 THEN DO
      /* 0.41 -> 0.42 */
      tmp = SysIni(opt.profile, 'Settings', 'Verbose')
      IF tmp \= 'ERROR:' THEN
         CALL WriteIni opt.profile, 'Settings', 'Verbose', tmp+1
      END
   CALL WriteIni opt.profile, 'Internal', 'CDDBMMCDVersion', ver
   RETURN 1

ApplyDefault: PROCEDURE EXPOSE opt.
/* Apply default value if value not set yet,
   prefer profile setting and write back (if desired).
   parameter:
      ARG(1) name of the option
      ARG(2) default value
      ARG(3) name of the profile entry (if any)
      ARG(4...) dynamic default values (if field is still empty)
*/
   IF opt.reset & ARG(3, 'e') THEN
      CALL WriteIni opt.profile, 'Settings', ARG(3)
   IF SYMBOL('opt.'ARG(1)) = 'VAR' THEN
      INTERPRET 'tmp = opt.'ARG(1)
    ELSE DO
      IF ARG(3,'e') THEN DO
         /* get setting from profile */
         tmp = SysIni(opt.profile, 'Settings', ARG(3))
         IF tmp = 'ERROR:' THEN DROP tmp
         END
      IF SYMBOL('tmp') = 'LIT' THEN
         tmp = ARG(2)
      END
   IF opt.writeini & ARG(3,'e') THEN
      CALL WriteIni opt.profile, 'Settings', ARG(3), tmp
   DO i = 4 WHILE tmp = '' & ARG(i,'e')
      tmp = ARG(i)
      END
   INTERPRET 'opt.'ARG(1)' = "'tmp'"'
   CALL Debug 'opt.'ARG(1)' = "'tmp'"'
   RETURN

OptionCheck: PROCEDURE EXPOSE opt. opt
/* check option parameter
   This function checks the variable opt if it is a short or long form of the specified option
   and assigns its parameter value to the stem variable opt.ARG(1). The function may be used
   only because of this side effect.
   If it is not this option the funtion returns false.

   parameters:
      opt    option string (global var)
      ARG(1) name of the option to assign the value,
             if ommitted the option must not have any parameters
      ARG(2) short option string, optional
      ARG(3) long option string, optional
      ARG(4) check datatype, optional
             If this argument has exactly one character, the parameter will be verified with the REXX function DATATYPE(..., ARG(4)).
             If this argument has more than one character, the parameter will be verified with the REXX function VERIFY(..., ARG(4)).
      ARG(5) default value, if ommitted the option must have parameters unless ARG(1) is also omitted.
             '' will in fact make the option parameter optional.
   return:
      1          option accepted
      0          option not accepted (continiue with next check!)
      exception  fatal option error will exit with rc = 42
*/
   SELECT
    WHEN ABBREV(SUBSTR(opt, 2), ARG(2), 1) THEN
      r = SUBSTR(opt, 3)
    WHEN opt = ARG(3) THEN
      r = ''
    WHEN ABBREV(opt, ARG(3)'=', 1) THEN
      r = SUBSTR(opt, LENGTH(ARG(3)) +2)
    OTHERWISE
      RETURN 0
      END
   IF r = '' THEN DO
      IF ARG(1,'O') THEN
         RETURN 1
      IF ARG(5,'O') THEN
         CALL Fatal 42, 'Option 'opt' requires a parameter.'
      r = ARG(5)
      END
    ELSE DO /* non empty */
      IF ARG(1,'O') THEN
         CALL Fatal 42, 'Option 'opt' must not have parameters.'
      IF LENGTH(ARG(4)) = 1 THEN DO
         IF \DATATYPE(r, ARG(4)) THEN
            CALL Fatal 42, 'Option 'opt' has an invalid format.'
         END
       ELSE IF ARG(4) \= '' THEN
         IF VERIFY(r, ARG(4)) \= 0 THEN
            CALL Fatal 42, 'Option 'opt' has an invalid format.'
      END
   IF ARG(1,'E') THEN
      CALL VALUE 'opt.'ARG(1), r
   RETURN 1

ReadIni: PROCEDURE EXPOSE opt.
/* like SysIni(ini, app, key) but return ARG(4) on error */
   val = SysIni(ARG(1), ARG(2), ARG(3))
   IF val = 'ERROR:' THEN
      RETURN ARG(4)
   RETURN val

WriteIni: PROCEDURE EXPOSE opt.
/* like SysIni(ini, app, key, newval) but delete key if newval is identical to ARG(5) */
   IF ARG(2) = '' | ARG(3) = '' THEN
      CALL Fatal 28, 'Internal error: WriteIni called with destructive parameters.'||'0d0a'x||'_'ARG(1)'_'ARG(2)'_'ARG(3)'_'ARG(4)'_'ARG(5)
   val = ARG(4)
   IF val = ARG(5) THEN val = 'DELETE:'
   IF SysIni(ARG(1), ARG(2), ARG(3), val) = 'ERROR:' THEN
      IF val \= 'DELETE:' THEN
         RETURN Error(0, 'Failed to write profile data: 'ARG(1)'\'ARG(2)'\'ARG(3)'='ARG(4)'.')
   RETURN 1

TCPIPInit: PROCEDURE EXPOSE opt.
/* initialize socket functions */
   IF RxFuncAdd("SockLoadFuncs","rxSock","SockLoadFuncs") \= 0 THEN
      RETURN /* can't init or already initialized */
   CALL SockLoadFuncs
   IF SockInit() \= 0 THEN
      CALL Fatal 99, "Failed to initialize Socket API."
   RETURN

MCIcmd: PROCEDURE EXPOSE opt.
/* execute MCI command and return result

   parameter:
    ARG(1) MCI command
    ARG(2) default return value in case of an error (optional)
           Without this parameter all errors are fatal.
*/
   CALL Debug 5, ">"ARG(1)">"
   rc = mciRxSendString(ARG(1), 'mcir', 0, 0)
   IF rc \= 0 THEN DO
      /* MCI error */
      IF ARG(2,'e') THEN
         RETURN ARG(2)
      CALL mciRxGetErrorString rc, 'errstr'
      CALL Error "MCI Error "rc" - "errstr'0d0a'x||" > "ARG(1)||'0d0a'x||" < "mcir
      CALL mciRxExit
      EXIT 255
      END
   CALL Debug 5, "<"mcir"<"
   RETURN mcir

SortedWordPos: PROCEDURE
/* Find the position of a word in a sorted string.

   parameter:
    ARG(1) sorted word collection
    ARG(2) word to find

   return:
    First position of the word or
    poistion where the word meight be inserted or
    WORDS(ARG(1))+1 if ARG(2) is past the end
*/
   lo = 1
   hi = WORDS(ARG(1))
   DO WHILE lo <= hi
      m = (hi+lo) % 2
      IF 'X'ARG(2) <= 'X'WORD(ARG(1), m) THEN
         hi = m -1
       ELSE
         lo = m +1
      END
   RETURN lo

SortedWordInsert: PROCEDURE
/* Insert a word into a collection of words keeping the sort order.

   parameter:
    ARG(1) sorted word collection
    ARG(2) new word

   return:
    sorted word collection with new word inserted
*/
   p = WORDINDEX(ARG(1), SortedWordPos(ARG(1), ARG(2)))
   IF p = 0 THEN
      RETURN ARG(1)' 'ARG(2) /* append */
    ELSE
      RETURN INSERT(ARG(2)' ', ARG(1), p-1)

UnixTime: PROCEDURE
/* return unix time
   The time zone is ignored here.
*/
   RETURN (DATE('B')-719162)*24*60*60 + TIME('S')

Qsum: PROCEDURE /* sum of digits */
   r = 0
   DO i = 1 TO LENGTH(ARG(1))
      r = r + SUBSTR(ARG(1), i, 1)
      END
   RETURN r

F2MSF: PROCEDURE /* frames -> mm:ss:ff */
   s = ARG(1)%75
   RETURN RIGHT(s%60,2,'0')':'RIGHT(s//60,2,'0')':'RIGHT(ARG(1)//75,2,'0')

RemoveC: PROCEDURE /* remove character from string */
   p = POS(ARG(2), ARG(1))
   IF p = 0 THEN
      RETURN ARG(1)
   RETURN DELSTR(ARG(1), p, LENGTH(ARG(2)))

ToPath: /* preprocess path setting */
   RETURN STRIP(TRANSLATE(ARG(1), '\', '/'), 't', '\')'\'

IsCurrentCD: PROCEDURE EXPOSE opt. cd.
/* check if cd is one of the current CD's

   parameters:
      ARG(1) table of contents from CD
   return:
      1/0    true/false
*/
   DO i = 1 TO cd.0
      IF cd.i = ARG(1) THEN
         RETURN 1
      END
   RETURN 0

AddCD: PROCEDURE EXPOSE opt. query. data. meta.
/* add TOC entry to CD list

   parameters:
    ARG(1) table of contents from CD
    ARG(2) data to store
    ARG(3) meta data to store
   return in global vars:
    query. list with table of contents, ARG(1)
    data.  list with data,              ARG(2)
    meta.  list with meta data,         ARG(3)
   The total number of entries is only stored in query.0
*/
   IF ARG(1) = '' THEN
      RETURN /* empty */
   tmp = query.0 +1
   query.tmp = ARG(1)
   query.0 = tmp
   IF ARG(2, 'e') THEN
      data.tmp = ARG(2)
   IF ARG(3, 'e') THEN
      meta.tmp = ARG(3)
   RETURN

CaseAdj: PROCEDURE /* adjust upper/lowercase automatically (best guess) */
   tmp = TRANSLATE(ARG(1), XRANGE('a','z'),XRANGE('A','Z')) /* well, lowercase, mainly... */
   p = 1
   DO FOREVER
      tmp = OVERLAY(MMUpper(SUBSTR(tmp, p, 1)), tmp, p)
      p = VERIFY(tmp, XRANGE('A','Z')XRANGE('a','z')XRANGE('80'x,'FF'x)"0123456789'",, p)
      IF p = 0 | p = LENGTH(tmp) THEN RETURN tmp
      p = p +1
      END

Case: /* inline if then else */
   IF ARG(1) THEN
      RETURN ARG(2)
   ELSE
      RETURN ARG(3)

Commit:
/* commit message
   parameter:
      ARG(1) message text
   return:
      RESULT (boolean), 1 = yes
*/
   SAY ARG(1)
   PULL r
   RETURN ABBREV('YES', r, 1)

/* error handling */
Message: PROCEDURE EXPOSE opt.verbose
/* Display message if severity level passes.
   parameter:
      ARG(1) severity level: 0 = Fatal, 1 = Error, 2 = Warning, 3 = Information, 4+ = Debug
      ARG(2) message
      ARG(3) indent string
*/
   IF SYMBOL('opt.verbose') = 'VAR' THEN DO
      IF opt.verbose < ARG(1) THEN
         RETURN
      END
    ELSE IF 2 < ARG(1) THEN
      RETURN
   msg = ARG(2)
   p = LENGTH(ARG(2))-2
   IF p > 0 THEN DO
      /* indent */
      ind = COPIES(' ',LENGTH(ARG(3)))
      DO WHILE p > 0
         p = LASTPOS('0d0a'x, msg, p)
         IF p = 0 THEN
            LEAVE
         msg = INSERT(ind, msg, p+1)
         END
      END
   SAY ARG(3)msg
   RETURN

Section: /* entering exeution block */
   CALL Message 1, ARG(1), '*****    '
   RETURN

Debug: /* Debug Message */
   IF ARG(2,'e') THEN
      CALL Message ARG(1), ARG(2), 'debug:   '
    ELSE
      CALL Message 4, ARG(1), 'debug:   '
   RETURN

Info: /* Informational Message */
   CALL Message 3, ARG(1), 'info:    '
   RETURN

Warning: /* warning message */
   IF ARG(2,'e') THEN DO
      CALL Message 2, ARG(2), 'Warning: '
      RETURN ARG(1)
      END
   CALL Message 2, ARG(1), 'Warning: '
   RETURN

Error: /* error message */
   IF ARG(2,'e') THEN DO
      CALL Message 1, ARG(2), 'ERROR:   '
      RETURN ARG(1)
      END
   CALL Message 1, ARG(1), 'ERROR:   '
   RETURN

Fatal:
/* Raise error and exit, i.e. do not return

   parameter:
    ARG(1) return code of the application
    ARG(2) message
*/
   CALL Message 0, ARG(2), 'FATAL:   '
   EXIT ARG(1)

