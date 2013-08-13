/* ALLINFS.CMD    by Leshek Fiedorowicz 1992-11-15   V 3.0        */
/*                                      1993-03-10   V 3.02       */
/* To create VIEW folder with all your .INF files                 */
version = '3.02'

Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

Arg Options
/*
** Possible options :
** /D:list
** where 
**         list - the list of drives to search
**                ex: /D:CD to search only C: and D:
**
** /REP
**          to replace existing objects (to assign icons for example)
**
** /ICO
**          to assign icons if the .ICO file exists in the same directory
**          and with the same name as the .INF file
*/
Parse var Options Opt1'/D:'Drives Opt2
Drives = Strip(Drives);
Options = Opt1||Opt2;

If wordpos('/REP', Options) \= 0 then Do;
   Parse var Options Opt1'/REP'Opt2
   Options = Opt1||Opt2;
   Replace = 'YES'
End;
Else
   Replace = '';

If wordpos('/ICO', Options) \= 0 then Do;
   Parse var Options Opt1'/ICO'Opt2
   Options = Opt1||Opt2;
   AssignIcon = 'YES'
End;
Else
   AssignIcon = ''


listfile = 'AllInfs.lst'
IconFile = 'AllInfs.ico'

say
say 'AllInfs 'version' - by Leshek Fiedorowicz; CIS#74170,2007'

If Options \= '' then /* Some unrecognized option/parameters */
Do;
   say
   say 'ERROR: Unrecognized parameters/options, please try again.'
   say '      Supported options are:'
   say '      /D:list'
   say '      where:'
   say '            list - the list of drive letters to search if you '
   say "                   don't wish all drives to be searched."
   Exit 99;
End;

 
say
say 'Searching your drives for *.INF files.  Please wait... '
Call CSeeAll;
say

if lines(listfile) = 0 then
do;
   say
   say '*** Warning: AllInfs list file not found, object will have names same'
   say '             as files names.  Do you want to continue (Y/anything) ?'
   pull ans
   if strip(ans) \= 'Y' then do;
      say '    Place AllInfs.LST in current directory and try again.'
      say '    Thank you for using AllInfs 'version'.... Leshek Fiedorowicz.'
      say
      exit 4;
   end;
end;

/* read list file */
cnt = 0;
list. = '';
do while lines(listfile);         /* Read input file */
   cnt = cnt + 1;
   list.cnt = linein(listfile);
end;
list.0 = cnt;

icf. = '';
/* Find icon file (first occurence on the current drive           */
rc = SysFileTree('\'IconFile, 'icf', 'SF')
parse var icf.1 date time size attribs IconFileFullName;
IconFileFullName = Strip(IconFileFullName );

/* Create Foler on the Desktop                                    */
classname = 'WPFolder';
title = 'All IPFs';
location = '<WP_DESKTOP>';
setup='OBJECTID=<All_IPFs>;'||,
      'ICONVIEW=FLOWED;'||,
      'ICONFILE='IconFileFullName;
      /* SORT= LE=filename */
rc = SysCreateObject(classname, title, location, setup);
if rc \= 1 then do;
   say 'Unable to create <All IPFs> Folder, it may already exist.';
   say 'Processing Continues ... new IPFs will be added ... ';
   Say
end;

errors = '';
errors.0 = 0;

say 'In the following display:'
say '   . found file with .INF extension but not in a VIEW format.';
say '   - found file with .INF but unable to create corresponding object.';
say '   + found file with .INF and succesfully created object.';
Say 'Please wait...';

count = 0;
/* Main processing loop */
do in = 1 to AllFile.0;
   /* rc= charout(,'.'); */
   parse var AllFile.in date time size attribs infile'.'ext;
   InFile = Strip(InFile);
   LastBSlashPos = Lastpos('\', Infile);
   InfPath = Substr(InFile, 1, LastBSlashPos);
   InFile = Substr(InFile, (LastBSlashPos + 1));
   object = infpath||infile||'.INF';
   icon = infpath||infile||'.ICO';
   firstline = linein(object,1,1);
   call Stream object, 'c', 'close';
   if substr(firstline,1,4) \= 'HSP'||'01'x then do;
      rc= charout(,'.');
      iterate;                  /* Ignore non VIEWable files              */
   end;
   title = infile infpath;
   infile = translate(infile)   /* Uppercase file name                    */
   do k = 1 to list.0
      parse var list.k fl ttl
      if fl = infile then do;
         title = strip(ttl);
         leave k;
      end;
   end;
   if title = 'EXCLUDE' then
      iterate;                  /* Ignore specified files                 */

   ClassName = 'WPProgram';
   /* Title = Title;                                                      */
   Location = '<All_IPFs>';
   Setup = 'PROGTYPE=PM;'||,
           'EXENAME=VIEW.EXE;'||,
           'PARAMETERS='object';'||,
           'OBJECTID=<'object'>;';

   If AssignIcon \= '' then     /* If /ICO option - try to assign the icon*/
      Setup = Setup||'ICONFILE='Icon';';

   If Replace \= '' then        /* If /REP option was specified replace   */
      duplicateflag='ReplaceIfExists'; /* existing objects                */
     else
      duplicateflag='FailIfExists';

   rc = SysCreateObject(ClassName, Title, Location, Setup, duplicateflag);

   if rc = 1 then do;
      rc= charout(,'+');
      count = count + 1;
   end;
   else do;
      rc= charout(,'-');
      errors.0 = errors.0 + 1;
      i = errors.0;
      errors.i = object;
   end;
end;

say

if errors.0 \= 0 then do;
   say
   if error.0 >1 then
      txt = 'files have'
   else
      txt = 'file has'

   say '*** The following 'txt' not been processed correctly (may already exist):'
   ns = 22;
   done = 0;
   do i = 1 to errors.0
      if ((i - done) //ns = 0) then do;
         Say 'Press any key to continue...';
         Pull;
         done = (i - done) + done;
         ns = 22;
      End;
      tx = right(i,7)': 'errors.i
      say tx
      If length(tx) > 80 then
         ns = ns -1;
   end;
end;

say
select
  when count = 0 then
       say 'No objects created.'
  when count = 1 then
       say 'One .INF object has been created in <All IPFs> folder on your desktop.';
  Otherwise
       say count' INF objects have been created in <All IPFs> folder on your desktop.';
end;

say 'Thank you for using AllInfs 'version' .... Leshek Fiedorowicz.'
say

exit 0;

/* SEEALL     - by Leshek Fiedorowicz                             */
/* To find all file occurences on any drive, using wildcard       */
CSeeAll:

file = '*.INF'

If Drives = '' then do;       /* If no drives specified in the /D:*/
                              /*   option - search all drives     */
   /* Find all logical drives available - onto Drive. stem        */
   AllDrives = SysDriveMap('c:', 'USED');
End;
Else Do;                      /* If drive were specified in the /D*/
                              /* option - build the drives list   */
   AllDrives = '';
   Do sai = 1 to length(Drives);
      AllDrives = AllDrives Substr(Drives,sai,1)||': ';
   End;
End;

Drive. = '';
cnt = 0;
Do While AllDrives \= ''
   cnt = cnt + 1;
   Parse var AllDrives Drive.cnt AllDrives
End;
Drive.0 = cnt;

if Drive.0 = 0 then do;
   say 'Error : no logical drives found !'
   Exit 8;
End;

/* Check for the file on all available logical drives             */
AllFile. = '';
AllCnt = 0;
Do d = 1 to Drive.0;
   c1=Substr(Drive.d,1,1); c2=Substr(Drive.d,2,1);
   rc= charout(,c1); rc= charout(,c2); rc= charout(,'  ');
   rc = SysFileTree(Drive.d'\'file, 'file', 'SF')
   If rc \= 0 then say 'ERROR in SysFileTree call - 'rc
   do i=1 to file.0
      AllCnt = AllCnt + 1;
      AllFile.AllCnt = file.i
   End;
End;
AllFile.0 = AllCnt;
rc= charout(,'0A'x);
rc= charout(,'0D'x);

Return;

