/*===================================================================*/
/* Archive Handler v1.1 - Sean Camanyag                              */
/*   Usage: ARCH.CMD [archive name, full path required]              */
/*===================================================================*/
/* History: v1.0 - Initial release, based on NEWZIPS.CMD [SC]        */
/*          v1.1 - Cleaned up code using filespec commands. Added    */
/*                 capability to view GZip (*.gz) files by calling   */
/*                 Gzip then running user-specified file lister.     */
/*                 Changed documentation a little. Made better use   */
/*                 of work variables (archive programs, listers)     */
/*-------------------------------------------------------------------*/
/*                                                                   */
/* This is my first real REXX program. I wrote it because I wanted a */
/* way to handle .ZIP and .LZH archives using a WPS Folder.          */
/*                                                                   */
/* I'm pretty much clueless when it comes to programming; most of    */
/* this was done from looking at Felix Sawicki's NEWZIPS.CMD on      */
/* OS/2 Shareware BBS. (NEWZIPS.ZIP)  NEWZIPS seemed intended for    */
/* Sysops who examine all uploads personally.  At the time I was     */
/* calling various BBS's and checking FTP sites for some utility     */
/* that let the user handle .ZIPs via the WPS, as a .ZIP file was    */
/* double clicked on.                                                */
/*                                                                   */
/* I came across a utility that did that, however it was hard-coded  */
/* to use the PKWare OS/2 ZIP 1.x programs, which did not support    */
/* PKZip 2.0 format archives. Also, I didn't like its interface.     */
/*                                                                   */
/* I really wanted something to help me get un-used to the command   */
/* line, so, after about 2 hours of work, constantly looking at the  */
/* online REXX documentation and NEWZIPS.CMD, I got this to work.    */
/*                                                                   */
/* This was intended to be associated with .ZIP,.LZH, and .gz files. */
/* .gz files are those created by GZip, commonly used on FTP sites.  */
/* Gzip's default extension is .gz, but will read .z files as well.  */
/* You can easily add .z support by copying the .gz section, and     */
/* adding appropriate changes to the "get archive type" area.        */
/*                                                                   */
/* Make a object for this CMD file. Then use an association editor   */
/* (such as ASSOED03.ZIP) and link the ZIP/LZH/gz files so that when */
/* you double-click on their icons, Archive Handler will run on it.  */
/*                                                                   */
/* This program is public domain; feel free to modify it in any way  */
/* you want.  All I ask is that you mention that your modification   */
/* acknowledges me and F. Sawicki, if you upload it somewhere.       */
/* Please let me know of any fixes you make, and where I can         */
/* download it.  My internet email addresses are:                    */
/*                                  scamany@eis.calstate.edu         */
/*                                     bgc1@delphi.com               */ 
/*                                                                   */
/* The documentation from NEWZIPS.CMD says that Felix Sawicki can be */
/* contacted on the local msg area of OS/2 Shareware BBS.            */
/*                                                                   */
/* Disclaimer: (who doesnt use em, these days)                       */
/*             I take no responsibility at all for any damage this   */
/*             rexx program may do. It's provided as-is, no          */
/*             guarantees, etc etc, even if I'm aware of such        */
/*             dangers, etc etc etc etc... You get the idea.         */

/* Turn .CMD echo off */
"@ECHO OFF"

/* Remind user about making an object */
SAY 'You should create an object for this .CMD file.'
SAY 'Put a check mark on the [Start Minimized] area in the Settings tab,'
SAY 'and this window wont be visible anymore'

/* Handle Arguments */
parse arg arcname

/* Set work variables - **CHANGE THIS TO YOUR NEEDS** */
workdrv = 'E:'  
workdir = '\Comm\Test'
workpath = 'E:\Comm\Test\'
unzipprg = 'unzip -o '
unlzhprg = 'LH X -o '
ungzprg = 'GZip -d '
gzprg = 'GZip -9 '
fileview = 'PMV '

/* Get Archive Type; if the last character is a period, then the */
/* extension is 2 characters long - a .gz file                   */
type = right(filespec("name",arcname),3)
if left(type,1) = D2C(46) then do
   type = right(filespec("name",arcname),2)
   end

/* Filter out the filename for use as the folder's title */
windowname = filespec("name",arcname)

/* Check archive type and call appropriate unarchiver  */ 
/* You should be able to add just about any archiving  */
/* program; just use the part below and modify it for  */
/* the appropriate program                             */
select
  when type = 'ZIP'
     then 
     do
     newdir = workpath||windowname
     say newdir
     "pause"
     workdrv
     'cd 'workdir
     'md 'windowname
     'cd 'windowname
     unzipprg arcname
     if rc = 0 then
        do
        Call SysSetObjectData newdir, 'OPEN=DEFAULT'
        end
     end
  when type = 'LZH'
     then 
     do     
     newdir = workpath||windowname
     workdrv
     'cd 'workdir
     'md 'windowname
     'cd 'windowname
     unlzhprg arcname
     if rc = 0 then
        do
        Call SysSetObjectData newdir, 'OPEN=DEFAULT'
        end
     end
  when type = 'gz'
     then 
     do
     gzfullname = filespec("name",arcname)
     if left(gzfullname,1) > D2C(34) then 
        do
        gzname = left(gzfullname,length(gzfullname) - 3)
        end
     if left(gzfullname,1) = D2C(34) then 
        do
        gzname = left(gzfullname,length(gzfullname) - 4)
        end
     gzname = D2C(34)||gzname||D2C(34)
     gzdrive = filespec("drive",arcname)
     gzdrive
     gzpath = filespec("path",arcname)
     gzpath = left(gzpath,length(gzpath) - 1)
     'cd 'gzpath
     ungzprg gzname
     fileview gzname
     gzprg gzname
     end
otherwise     
end
Call SysSetObjectData LEFT(ARCNAME,LENGTH(arcname)-1) , 'OPEN=DEFAULT'    
'cd ..'

/* End of ARCH.CMD */
