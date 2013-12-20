/*                                                                     */ 
 /***************************************************************************
 *  form processor
 * grabs all fields on a web page and creates an e-mail and 
 * send it to the user via a hidden field in the html call email
 * it then sends the user to a predefined location also specified
 * by hidden field in refering the HTML page
 * 
 *
 *  Author:  Eddie Shultz eddie@web-dock.com
 *  version 00.02.00
 *  June 12 ,1998 
 *
 * example HTML code copy the following to a blank html page
 * change the cgi server location
 * change the e-mail address 
 * change the send to web page
 * the remaining fields are just for demo (name,age,os)
 *
 * <FORM action="http://lucent.web-dock.com/cgi-bin/readmein.cmd" method="POST">
 * <INPUT type="hidden" name="myaddress" value="support@nowselling.com">
 * <INPUT type="hidden" name="mywebpage" value="http://lucent.web-dock.com/formprocess.html">
 * name<INPUT name="name" size="20"><BR>
 * age<INPUT name="age" size="20"><BR>
 * os<INPUT name="os" size="20"><BR>
 * <INPUT type="submit">
 * </FORM>
 *
 *  6-12-98
 * added field verification
 * the script now check to see that data was entered in *ALL* fields
 * if you want a field that a user does not have to fill out
 * then in the HTML put a default value of something
 * anything ie.. NA, not required , * 
 * 
 * 4-24-98
 * add url field so user can specify a place to go after the form has
 * been processed
 * add e-mail field 
 * add security to insure that only allowed domains are using the form  processor
 **************************************************************************/

Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

/* user defines 
 * change to suite your needs
 * nothing else requires changeing but feel free
 */

pageBackground ='http://www.web-dock.com/images/globe_background.gif'
pageBgColor='#ffffff'
pageMessage ='Please go back an ensure that you have submitted all the required information'

/* end user defines */


/* inits */
uft = time()
ft = translate(uft,"_",":")
dt = date()
dtt = translate(dt,"_"," ")
mailFile = ft||dtt.wdd



call CGIParse

sendtoaddress = cgi.1
newlocation = cgi.2

/* get HTML information for e-mail and relocate */
parse var sendtoaddress  trash "=" mailto
mailtoaddress = strip(mailto)
parse var newlocation  trash "=" newlocation
newlocation= strip(newlocation)


/* check if all data from page was filled in if not then exit 
 * this routine checks to see if the value returned is blank
 * and if the length if the returned variable = 0
 * if yes then error
*/


data_error = 0
DO i = 1 to cgi.0
	parse value cgi.i with remark "=" value
	if compare(substr(value,1,3)," ") = 0 then data_error = 1
	if length(value) = 0 then data_error = 1
/* debug	Say 'var=:' remark  ' value = :' value ' and length =:' rxd' and error = :' data_error || '<BR>' */
END




/* error no e-mail address was specified */

if data_error = 1 then DO

	Say "Content-type: text/html"
	Say 
	Say "<HTML>"
	Say "<HEAD>"
	Say "<TITLE>Shop</TITLE>"
	Say "</HEAD>"
	Say '<BODY background="'pageBackground'"  bgcolor="'pageBgColor'">'
	Say '<BR>'
	
	Say '<center>'
	Say  pageMessage
	Say '<BR>'
	Say '</Body>'
	Say '</HTML>'
	return 0
	exit

END




/* create e-mail   */

go=lineout(mailFile ,"subject:Form Information.")
go=lineout(mailFile ,"from:WebDock Form Processor")
go=lineout(mailFile ,"------------------------------------------------------")
go=lineout(mailFile,"Form Information")
go=lineout(mailFile ,"Date:  " || date()|| "  Time: " || time())
go=lineout(mailFile ,"------------------------------------------------------")
go=lineout(mailFile ," ")
go=lineout(mailFile ," ")

DO i = 3 to cgi.0
	go=lineout(mailFile ,cgi.i)
END
go=lineout(mailFile ," ")
go=lineout(mailFile ," ")
go=lineout(mailFile ,"--------End of Transmission--------")
go = lineout(mailFile)

/* end mail file creation */



/* relocate the user */

Say "HTTP/1.0 302 Found:"
Say  "Location: "||newlocation
Say


/* mail information  */
"sendmail -af "|| mailFile  mailtoaddress  


/* remove the temp mail file */
'del '||mailFile 


/* exit */
return 0 





/* cgi parse */

CGIParse:PROCEDURE EXPOSE cgi.

queryString=''

IF getEnv('REQUEST_METHOD') = 'POST' THEN
 DO
    IF getEnv('CONTENT_TYPE') \= 'application/x-www-form-urlencoded' THEN RETURN 1
    j= getEnv('CONTENT_LENGTH')
    IF DATATYPE(j, 'W') \= 1 THEN queryString=''
    ELSE queryString= LINEIN()
 END

queryString= TRANSLATE(queryString, ' ', '+')
i = 0
DO WHILE LENGTH(queryString) > 0
 varCouple= ''
 PARSE VAR queryString varCouple'&'queryString
 PARSE VAR varCouple varName'='varVal
 IF varName = ''  THEN ITERATE /* | varVal= '' THEN ITERATE */
 i = i +1
 varNametag= varName
 varName= 'cgi.' || i
 varVal=  urlDecode(varNametag)||" = "||urlDecode(varVal)
 IF SYMBOL(varName) = 'BAD' THEN ITERATE
 IF VALUE(varName) \= TRANSLATE(varName) THEN call VALUE varName, VALUE(varName) || '0d'x || varVal
 ELSE call VALUE varName, varVal
END
cgi.0=i
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



 


