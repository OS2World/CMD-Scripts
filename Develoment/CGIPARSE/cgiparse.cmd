/* CGIPARSE 1.0.7, public release 1.0, build 7 */

/* Credits where they are due:
 *  
 * This script is created by Sacha Prins, sacha@prins.net
 * 
 * Please think of me when using this code.
 *
 */

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


