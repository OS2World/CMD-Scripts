/****************************************************************************
*
*  INSTALL.CMD - Installation script for CDDBMMCD
*
*  Copyright (C) 2003 by Marcel MÅller
*/ opt.version = '0.2' /*
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

/* info screen */
SAY "Install CDDBMMCD to run from the CURRENT directory."
SAY "Copyright (C) 2003 by Marcel MÅller"
SAY
SAY "This will configure CDDBMMCD and create some desktop objects."
SAY "You may re-run the script if you want to change the settings or the program's"
SAY "folder. This may override additional user settings made in the meanwhile."
SAY
SAY "Press Ctrl-C to abort or Enter to continue."
PULL


CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
CALL SysLoadFuncs


/* locate cddbmmcd.cmd */
opt.cddbmmcd = STREAM('cddbmmcd.cmd', 'c', 'query exists')
IF opt.cddbmmcd = '' THEN
   CALL Fatal 50, "Cannot locate cddbmmcd.cmd in the current directory."
opt.dir = DIRECTORY()

/* ? database type */
SAY "What kind of connection to the database do you want to use?"
SAY " ONLINE   Online connection to a freedb server. Your queries will be executed"
SAY "          immediately."
SAY " OFFLINE  Offline connection to a freedb server. Your queries will be collected"
SAY "          and executed later, when you are online."
SAY " LOCAL    Use a local copy of the freedb database. See CDDBMMCD documentation"
SAY "          for how to obtain one."
SAY " ALL      Create all kind of query objects. The choice about what kind of"
SAY "          connection you want to use is up to you at runtime."
SAY
SAY "Note: You may use unique, case-insensitive abbrevations of the keywords."
opt.con = KeySelect('ONLINE','O', 'OFFLINE','X', 'LOCAL','L', 'ALL','OXL')
opt.srv = VERIFY(opt.con, 'OX', 'M') \= 0
/* ? upload feature */
SAY "Do you want to submit or update database entries {YES|NO}?"
opt.upd = KeySelect('YES',1, 'NO',0)
IF opt.upd & \opt.srv THEN DO
   SAY "You have selected to use a local database but database submissions require a"
   SAY "connection to a cddb server. Keep this in mind and don't wonder if you're asked"
   SAY "for server parameters."
   SAY
   opt.srv = 1
   END

/* ? cddb server */
IF opt.srv THEN DO
   SAY "Enter the name of the freedb server to use."
   SAY "Simply hit enter to use the default server freedb.freedb.org."
   SAY "It is recommended to use a freedb mirror site close to your location to"
   SAY "optimize performance."
   opt.server = ParaSelect('freedb.freedb.org')
   /* protocol */
   SAY "What kind of transfer protocol do you want to use for the server communication?"
   SAY " HTTP   Use http as transfer protocol. This is the default."
   SAY " CDDBP  The native cddb server protocol. This is the most efficient one."
   IF opt.upd THEN DO
      SAY "        Note that the 'official' freedb servers will reject any submission"
      SAY "        via cddbp."
      END
   SAY " PROXY  Use http via a proxy server. This is helpful if your online connection"
   SAY "        is through a firewall. You will be asked for proxy server later."
   opt.proto = KeySelect('','http', 'HTTP','http', 'CDDBP','cddb', 'PROXY','httpproxy')
   /* proxy */
   IF opt.proto = 'httpproxy' THEN DO
      opt.proto = 'http'
      SAY "Enter the name of the proxy server."
      opt.proxy = ParaSelect()
      END
   /* identity parameters */
   IF VALUE('HOSTNAME',,'OS2ENVIRONMENT') = '' THEN DO
      SAY "Your host name cannot be detected automatically."
      SAY "This is required for any connection to a cddb server."
      SAY "It is recommended to use the machine name that is used for shares in your LAN,"
      SAY "if any."
      SAY "Please enter your host name. The name should not contain spaces."
      opt.host = ParaSelect()
      END
   IF opt.upd & VALUE('USER',,'OS2ENVIRONMENT') = '' THEN DO
      SAY "Your user name is required for cddb submissions and updates."
      SAY 'It is recommended to use your login or something like that. Do not use your'
      SAY 'full name like "Marcel MÅller".'
      SAY "Please enter your user name. The name should not contain spaces."
      opt.user = ParaSelect()
      END
   IF opt.upd & opt.proto = 'http' THEN DO
      SAY "Submissions via http additionaly require a email address for replies."
      SAY "This address must be existing and accessable for you."
      SAY "The address is not used unless you send submissions via http."
      SAY "Enter your email address for submissions."
      opt.email = ParaSelect()
      END
   END /* end of server parameter */

/* ? local db */
IF VERIFY(opt.con, 'L', 'M') \= 0 THEN DO
   SAY "You have choosen to use a local copy of the cddb database."
   SAY "Please enter the path to the database files, i.e. the folder where the"
   SAY 'subfolders "rock", "misc" etc. reside. The path must not end with "\".'
   SAY "To use the current folder simply press enter."
   opt.dbpath = ParaSelect('.',,'CheckLocalDB')
   END

/* ? service objects */
SAY "Create additional objects for maintance purposes {YES|NO(default)}?"
opt.xobj = KeySelect('',0, 'YES',1, 'NO',0)

/* configue CDDBMMCD ! */
SAY "Configuring CDDBMMCD..."
opt = '-w'
IF opt.srv THEN
   opt = opt' "-s'opt.proto':\\'opt.server'"'
opt = opt||TOpt('proxy','-P')TOpt('host','-h')TOpt('user','-u')TOpt('email','-e')
opt = opt||TOpt('dbpath','-l')TOpt('dbtype','-t')
"@CALL cddbmmcd "opt
IF RC \= 0 THEN
   SAY "ERROR: Invocation of CDDBMMCD failed with returncode "RC"."
SAY

/* create desktop items */
SAY "Creating desktop objects..."
nel = '0d0a'x
IF \SysCreateObject('WPFolder', 'CDDBMMCD', '<WP_DESKTOP>', SKey('OBJECTID','<CDDBMMCD_Folder>')SKey('ICONVIEW','FLOWED,NORMAL')SKey('ALWAYSSORT','NO'), 'U') THEN
   CALL Fatal 29, "Failed to create CDDBMMCD folder. Bailing out."
/* opposite order... */
tmp = STREAM(opt.dir'\index.html', 'c', 'query exists')
IF tmp = '' THEN
   SAY 'index.html not found in the current directory. Skipping documentation object.'
 ELSE IF \SysCreateObject('WPUrl', 'Documentation', '<CDDBMMCD_Folder>', SKey('OBJECTID','<CDDBMMCD_Doc>')SKey('URL','file://'TRANSLATE(tmp,'/|','\:'), 'U')) THEN
   SAY 'Failed to create Documentation Object.'
 ELSE
   SAY 'Object "Documentation" successfully created.'
/* update object */
IF VERIFY(opt.con, 'L', 'M') \= 0 THEN
   CALL MyCreateObj 'Update local database'nel'(drop update file)', '<CDDBMMCD_Update>', SKey('MINIMIZED','NO')SKey('NOAUTOCLOSE','YES')SKey('PARAMETERS','"--special=UpdateDB,%*"')
/* submit objects */
IF opt.upd THEN DO
   IF opt.xobj THEN
      CALL MyCreateObj 'Send submissions and updates'nel'(Submit mode, read manual first!)', '<CDDBMMCD_Submit>', SKey('MINIMIZED','NO')SKey('NOAUTOCLOSE','YES')SKey('PARAMETERS','-os')
   CALL MyCreateObj 'Send submissions and updates'nel'(Test mode)', '<CDDBMMCD_SubmitTest>', SKey('MINIMIZED','NO')SKey('NOAUTOCLOSE','YES')SKey('PARAMETERS','-os')
   IF opt.xobj THEN
      CALL MyCreateObj 'Force database update for the current CD', '<CDDBMMCD_ForceUpdate>', SKey('PARAMETERS','-oU')
   CALL MyCreateObj 'Create submissions and updates.', '<CDDBMMCD_AutoUpdate>', SKey('MINIMIZED','NO')SKey('NOAUTOCLOSE','YES')SKey('PARAMETERS','-oua')
   END
/* query objects */
IF opt.xobj THEN
   CALL MyCreateObj 'Force lookup of the current CD', '<CDDBMMCD_ForceQuery>', SKey('PARAMETERS','-oCq -v [Additional fixups, if any:]')
IF VERIFY(opt.con, 'X', 'M') \= 0 THEN DO
   CALL MyCreateObj 'Execute CDDB queries', '<CDDBMMCD_ExecQuery>', SKey('MINIMIZED','YES')SKey('PARAMETERS','-oQo')
   CALL MyCreateObj 'Collect CDDB queries', '<CDDBMMCD_CollectQuery>', SKey('MINIMIZED','YES')SKey('PARAMETERS','-oc')
   END
IF VERIFY(opt.con, 'OL', 'M') \= 0 THEN
   CALL MyCreateObj 'CDDB query', '<CDDBMMCD_DefaultQuery>', SKey('MINIMIZED','YES')


EXIT 0

MyCreateObj: PROCEDURE EXPOSE opt.
/* create program object and print result.
   parameter:
      ARG(1) Object name
      ARG(2) Object ID
      ARG(3) Additional setup string parameters.
*/
   IF SysCreateObject('WPProgram', ARG(1), '<CDDBMMCD_Folder>', SKey('OBJECTID',ARG(2))SKey('EXENAME',opt.cddbmmcd)SKey('STARTUPDIR',opt.dir)ARG(3), 'U') THEN
      SAY 'Object "'ARG(1)'" successfully created.'
    ELSE
      SAY 'Could not create program object "'ARG(1)'".'
   RETURN

SKey: PROCEDURE
/* Create setup string entry.
   parameter:
      ARG(1) Keyname
      ARG(2) Value. The ';' character is preceeded by ^.
   return:
      RESULT Setup string component in the form "keyname=value;"
*/
   v = ARG(2)
   p = 1
   DO FOREVER
      p = VERIFY(v, '^;', 'M', p)
      IF p = 0 THEN
         LEAVE
      v = INSERT('^', v, p)
      p = p +2
      END
   RETURN ARG(1)'='v';'


TOpt: PROCEDURE EXPOSE opt.
/* translate option parameter to the cddbmmcd command line format
   parameter:
      ARG(1) Name of the option variable.
      ARG(2) Command line option.
   return:
      RESULT Option with a leading space or ''
*/
   n = TRANSLATE(ARG(1))
   IF SYMBOL('opt.'n) \= 'VAR' THEN
      RETURN ''
   RETURN ' "'ARG(2)VALUE('opt.'n)'"'

CheckLocalDB: PROCEDURE EXPOSE opt.
   CALL SysFileTree ARG(1)'\misc\00to??', 'f', 'O'
   fw = f.0 \= 0
   CALL SysFileTree ARG(1)'\misc\??????14', 'f', 'O'
   fu = f.0 \= 0
   SELECT
    WHEN fw & fu THEN DO
      SAY 'The Databasetype detection failed. The database type is ambiguous.'
      SAY 'Please specify what kind of database you want to use {Windows|Standard}:'
      opt.dbtype = KeySelect('','A', 'WINDOWS','W', 'STANDARD','S')
      END
    WHEN fw THEN
      opt.dbtype = 'W'
    WHEN fu THEN
      opt.dbtype = 'S'
    OTHERWISE
      SAY '"'ARG(1)'\" seem to contain neither the normal nor the windows version'
      SAY "of the local database. Try again."
      RETURN 0
      END
   SELECT
    WHEN opt.dbtype = 'W' THEN
      SAY 'Using windows version of cddb database at "'ARG(1)'\".'
    WHEN opt.dbtype = 'S' THEN
      SAY 'Using standard cddb database at "'ARG(1)'\".'
    OTHERWISE
      SAY 'Trying to autodetect the database type at runtime.'
      SAY 'The database upddater will not work in this mode.'
      END
   RETURN 1

KeySelect: PROCEDURE
/* Select one of a list of keywords and return the assigned value.
   parameter:
      ARG(1) Keyword 1 (must be uppercase)
      ARG(2) Value 1
      ARG(3) Keyword 2 (must be uppercase)
      ARG(3) Value 2
      ...
   return:
      RESULT Value of the matching keyword
   This function will pull for input until the input data will match one of the keywords exactly
   or is a unique abbrevation of one of the keywords.
   To set a default value use an empty keyword with this value assigned.
*/
   SAY /* empty line before */
   keys = ''
   DO i = 1 BY 2 WHILE ARG(i,'e')
      IF ARG(i) \= '' THEN
         keys = keys' 'ARG(i)
      END
   keys = SUBSTR(keys, 2)
 RestartKey:
   PULL input
   m = 0
   DO i = 1 BY 2 WHILE ARG(i,'e')
      IF ARG(i) = input THEN DO
         SAY /* empty line after */
         RETURN ARG(i+1)
         END
      IF ABBREV(ARG(i), input, 1) THEN
         IF m = 0 THEN
            m = i
          ELSE DO
            SAY '"'input'" is not an unique abbrevation of one of "'keys'.'
            SIGNAL RestartKey
            END
      END
   IF m \= 0 THEN DO
      SAY /* empty line after */
      RETURN ARG(m+1)
      END
   IF input = '' THEN
      SAY 'There is no default value. Use one of "'keys'".'
    ELSE
      SAY '"'input'" does not match one of "'keys'".'
   SIGNAL RestartKey

ParaSelect: PROCEDURE EXPOSE opt.
/* Pull for a free parameter.
   parameter:
      ARG(1) Default value in case of an empty input. (optional)
             If omitted empty inputs are not allowed. Pass '' to allow this.
      ARG(2) Check datatype (optional)
      ARG(3) Custom check function (optional)
   return:
      RESULT Selected value
*/
   SAY /* empty line before */
 RestartPara:
   PARSE PULL input
   IF input = '' THEN DO
      IF ARG(1,'o') THEN DO
         SAY 'A parameter input is required.'
         SIGNAL RestartPara
         END
      SAY ARG(1)
      input = ARG(1)
      END
    ELSE IF ARG(2,'e') THEN
      IF \DATATYPE(input, ARG(2)) THEN DO
         SAY 'The input "'input'" has not the correct data type.'
         SIGNAL RestartPara
         END
   IF ARG(3,'e') THEN DO
      INTERPRET 'CALL 'ARG(3)' input'
      IF RESULT = 0 THEN
         SIGNAL RestartPara
      END
   SAY /* empty line after */
   RETURN input

Fatal:
/* Raise error and exit, i.e. do not return

   parameter:
    ARG(1) return code of the application
    ARG(2) message
*/
   SAY 'FATAL: 'ARG(2)
   EXIT ARG(1)

