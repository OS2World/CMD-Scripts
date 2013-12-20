/* linksRexx.cmd	2000-07-15

	Arguments (in enviroment variable LinksREXXParms )
 	[
	<Full URL> | <HTTP URL without the "http://" part but including a "/">
		| <LocalFile.htm> | <LocalFile.html> | <UrlObject>
		| <WindowsInternetShortcut.URL>
	[ <switches for links> ]
	]

	Called by linksWPS.cmd. Enables drag-and-drop of HTML files, URL objects
	and Windows Internet shortcuts onto the Links program object.

	DON'T CALL linksRexx.cmd directly.
	Use linksWPS.cmd to ensure proper handling of // characters
	
	(C) 2000 David Mediavilla <davidme.forum@bigfootREMOVEIFNOTSPAM.com>

	linksRexx.cmd is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

linksRexx.cmd is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with linksWPS.cmd; see the file COPYING.  If not, write to
the Free Software Foundation, 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.
*/

StartPage= 'file://' || value( 'HOME' , , "OS2ENVIRONMENT") || '/.links/StartPage.html'
links= 'links.exe'

signal on novalue

/* Taken from Rexx Tips & Tricks 3.00 to avoid mishandling of // characters
    in the command line */   
  
/* get the name of the environment variable with  */
/* the parameters                                 */
    parse arg parmVar
  
/* get the parameters from the environment        */
/* variable                                       */
    thisParms = value( parmVar , , "OS2ENVIRONMENT" )

if 0 = pos( '"', thisParms) then
	parse var thisParms firstArg rest
else	/* There are " in the parameters */
	parse var thisParms '"' firstArg '"' rest
/* 'mode con1 80,31' */

select
	when ""= firstArg  then do
		links StartPage
return
		end	/* firstArg= "" */ 

	when 0 \= lastpos( '/', firstArg) then do
		/* There is a / so it is an URL, not a filename.
		    OK, OS/2 allows / as a path separator but it is uncommon.
		*/
	      if 0= pos( 'tp:', firstArg)
		then do		/* There are no 'http' or 'ftp' in the URL.
				 We will add http */
			links 'http://'||firstArg rest
return
			end	/* 0= pos( 'tp:', firstArg) */
		else do		/* The URL is fully-formed */
			links firstArg rest
return
			end	/* else 0= pos( 'tp:', firstArg) */
		end /* 0 \= lastpos( '/', firstArg) */

	otherwise	/* it is a filename. Let's read the first line */
		if 'READY:' \= stream( firstArg, 'COMMAND', 'OPEN READ')
			then do /* error reading the file. Pass to links anyway */
				links 'file://'firstArg rest
return
				end	/* 'READY' \= stream( firstArg, 'COMMAND', 'OPEN READ') */
			else do
				parse value linein( firstArg ) with URL
				select 
					when 0 \= pos( 'InternetShortcut', URL) then
						/* A Windows Internet shortcut.
						   The URL is in the 	second line */
						parse value linein( firstArg ) with 'URL=' URL
					when 0 = pos( 'tp:/', URL) then
				     		/* Another kind of file */
						URL= 'file://'firstArg
				     	otherwise /* it's an OS/2 URL object, pass to links */
						nop
				end	/* select */
				/* Now URL contains the proper URL */
				call stream firstArg, 'COMMAND', 'CLOSE'
				links URL rest
			end /* else 'READY' \= stream( firstArg, 'COMMAND', 'OPEN READ') */
return
	end	/* otherwise */                          