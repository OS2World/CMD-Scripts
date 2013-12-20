/******************************************************************************
Pille's Pager in REXX                                                    v0.3.2

This is EMailware - write me a message with location of your pager to register 
 for updates/info/support !

Usage: 

Needs: 
  * IBM OS/2 w/ ReXX installed
  * an OS/2 webserver capable of running CGI's (I use Apache v1.2.4)
  * a FORM like:
    <FORM method=POST action="http://YOUR.MACHINE.DOM.AIN/cgi-bin/pager.cmd">
    <B>Message </B><input type="text" name="message" size=55 maxlength=80>
    <INPUT align=right type="submit" name="pushbutton" value="Send"></FORM>
  * or a Link like:
   <A HREF="http://YOUR.MACHINE.DOM.AIN/cgi-bin/pager.cmd?message=Hello%20You%20Fool">
    Hello You Fool</A>
  * pmpopup2 - from hobbes

Bugs/notes:
  * Rewrite the HTML Code to suit your needs
  * enough

History:
  * 19980513: dumped named pipe now using pmpopup2
  * 19980405: start (3 hours)
              added logging

Future:
  * Will I have one doing such stupid scripts? ;)

Latest Version: http://www.chillout.org/auswurf/software.html

Credits:
         --jlennon@IRCNet #OS/2ger - idea, his own pager script
         --Sacha Prins, <sacha@prins.net> for CGIParse 1.07         

Have phun...
                      Pille <pille@chillout.org>  -  http://www.chillout.org/
                      Pille@IRCnet
******************************************************************************/
Call RxFuncAdd 'SysLoadFuncs','RexxUtil','SysLoadFuncs'
Call 'SysLoadFuncs'
SIGNAL ON HALT NAME die
SIGNAL ON FAILURE NAME die
SIGNAL ON SYNTAX NAME die
SIGNAL ON ERROR NAME die

/*
** Settings & defaults
*/
_log	= "/usr/log/pager"  /*where to log pager messages*/
_delay	= 30                /*seconds to display the popup (max 65 secs, 0 to
                              disable autocloseing popups)*/
/*
** End of Settings
*/

_lf         = x2c(0a)
_host       = value("REMOTE_HOST",,"OS2ENVIRONMENT") 
call CGIParse

IF cgi.message='CGI.MESSAGE' THEN DO;
    rc = Charout(,"Content-type: text/html" || _lf) 
    rc = Charout(,_lf || "So wird das nix!" || _lf)
  END
ELSE DO
    rc = Charout(,"Content-type: text/html" || _lf) 
    '@start /pm /b pmpopup2 "From' _host || ':~~' cgi.message '" "WebPager Message" /a:c /b2:"Trash" /t:' || _delay
    '@echo' _host '[' || DATE() TIME() ||'] WebPager -' cgi.message '>>' _log
    rc = Charout(,_lf || "<HTML><HEAD><TITLE>Extreme - Message to Screen</TITLE></HEAD>")
    rc = Charout(,"<BODY BGCOLOR=#00002b TEXT=#aae0aa ALINK=#ffff80 VLINK=#e0c000 LINK=#e0c000 background=http://www.chillout.org/pics/background.jpg>")
    rc = Charout(,"<TABLE BORDER=0 WIDTH=100% HEIGHT=100%><TR><TD ALIGN=MIDDLE VALIGN=MIDDLE>Donge ;*)<BR>")
    rc = Charout(,"<P>'<B>" || cgi.message || "</B>' auf dem Bildschirm angezeigt</P><A HREF=http://www.chillout.org/webmail.html?to=pille>Nochmal?</A></BODY></HTML>")
    rc = Charout(,"</TD></TR></TABLE>" || _lf)
  END

Die:

quit:
rc = charout(,_lf)
exit 0

/******************************** procedures **********************************/

RxCat: procedure
parse arg file1
 rc=STREAM(file1,'C','OPEN READ')
 rc=CHAROUT(,CHARIN(file1,,STREAM(file1,'c','QUERY SIZE')))
 rc=STREAM(file1,'C','CLOSE')
return 0

exists: procedure
parse arg stream
IF STREAM(stream, 'C', 'QUERY EXISTS') = '' THEN RETURN 0
        ELSE RETURN 1

/* CGIPARSE 1.0.7, public release 1.0, build 7 */
/*********************************************************************/
CGIParse:PROCEDURE EXPOSE cgi.

queryString=''

IF getEnv('REQUEST_METHOD') = 'POST' THEN
 DO
    IF getEnv('CONTENT_TYPE') \= 'application/x-www-form-urlencoded' THEN RETURN 1
    j= getEnv('CONTENT_LENGTH')
    IF DATATYPE(j, 'W') \= 1 THEN queryString=''
    ELSE queryString= LINEIN()
 END
ELSE /* GET */
DO
 queryString= getEnv('QUERY_STRING')
END

queryString= TRANSLATE(queryString, ' ', '+')

DO WHILE LENGTH(queryString) > 0
 varCouple= ''
 PARSE VAR queryString varCouple'&'queryString
 PARSE VAR varCouple varName'='varVal
 IF varName = '' | varVal= '' THEN ITERATE
 varName= 'cgi.' || urlDecode(varName)
 varVal=  urlDecode(varVal)
 IF SYMBOL(varName) = 'BAD' THEN ITERATE
 IF VALUE(varName) \= TRANSLATE(varName) THEN call VALUE varName, VALUE(varName) || '0d'x || varVal
 ELSE call VALUE varName, varVal
END

RETURN 0

/*********************************************************************/
URLDecode:PROCEDURE EXPOSE cgi.

IF ARG()\=1 THEN RETURN ''
line= ARG(1)
lineLen= LENGTH(line)
newLine= ''

i=1
DO WHILE i <= lineLen
 c= SUBSTR(line, i, 1)
 IF c \= '%' THEN newLine = newLine || c
 ELSE IF i+2 <= lineLen THEN
                        DO
                           newLine= newLine || x2c(SUBSTR(line, i+1, 2))
                           i=i+2
                        END
 i= i+1
END
RETURN newLine


/*********************************************************************/
getEnv:PROCEDURE
RETURN VALUE(ARG(1),, 'OS2ENVIRONMENT')

/*********************************************************************/
putEnv:PROCEDURE
RETURN VALUE(ARG(1), ARG(2), 'OS2ENVIRONMENT')