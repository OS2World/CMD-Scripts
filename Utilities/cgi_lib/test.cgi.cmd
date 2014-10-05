/*  フォームのテスト  */
/*   cgi_lib 対応版   */

if RxFuncQuery("SysLoadFuncs")   then   call RxFuncAdd "SysLoadFuncs","RexxUtil","SysLoadFuncs"
call SysLoadFuncs

options 'exmode'

/*  'cgiutils -status 200 -ct text/html -expires now'  */

parse value DATE(W) with Day_W +3

Say cgi_lib('PrintHeader')
Say

HEADER_STRING = 'FORM の TEST (汎用) / Method :' getEnv('REQUEST_METHOD')

Say cgi_lib('PrintDocType')
Say cgi_lib('HtmlTop',HEADER_STRING)
Say '<HR size=1>'

call  status_make

Say cgi_lib('HtmlBot')

Exit 0

/*    */
status_make:

        Say '<H2>フォームの入力内容 </H2>'

        Say '<TABLE WIDTH="75%" BORDER="1"><TR><TH ALIGN="center">URL 変数名</TH><TH ALIGN="center">値</TH></TR>'
        VarNames = cgi_lib('CgiParse')
        DO until VarNames = ''
            PARSE  VALUE  VarNames  WITH  sName  ','  VarNames
            VarVal = getEnv(('FORM_' || sName ))
            Say '<TR><TD>' sName '</TD><TD>' VarVal '</TD></TR>'
        END
        Say '</TABLE>'

        Say '<H2> 設定された環境変数</H2>'

        Say '<TABLE WIDTH="75%" BORDER="1"><TR><TH ALIGN="center">環境変数名</TH><TH ALIGN="center">値</TH></TR>'
        Say '<TR><TD>AUTH_TYPE</TD><TD>'         getEnv('AUTH_TYPE') '</TD></TR>' 
        Say '<TR><TD>CONTENT_ENCODING</TD><TD>'  getEnv('CONTENT_ENCODING') '</TD></TR>' 
        Say '<TR><TD>CONTENT_LENGTH</TD><TD>'    getEnv('CONTENT_LENGTH') '</TD></TR>' 
        Say '<TR><TD>CONTENT_TYPE</TD><TD>'      getEnv('CONTENT_TYPE') '</TD></TR>' 
        Say '<TR><TD>GATEWAY_INTERFACE</TD><TD>' getEnv('GATEWAY_INTERFACE') '</TD></TR>' 
        Say '<TR><TD>HTTP_ACCEPT</TD><TD>'       getEnv('HTTP_ACCEPT') '</TD></TR>' 
        Say '<TR><TD>HTTP_COOKIE</TD><TD>'       getEnv('HTTP_COOKIE') '</TD></TR>' 
        Say '<TR><TD>HTTP_REFER</TD><TD>'        getEnv('HTTP_REFER') '</TD></TR>' 
        Say '<TR><TD>HTTP_USER_AGENT</TD><TD>'   getEnv('HTTP_USER_AGENT') '</TD></TR>' 
        Say '<TR><TD>PATH_INFO</TD><TD>'         getEnv('PATH_INFO') '</TD></TR>' 
        Say '<TR><TD>PATH_TRANSLATED</TD><TD>'   getEnv('PATH_TRANSLATED') '</TD></TR>' 
        Say '<TR><TD>QUERY_STRING</TD><TD>'      getEnv('QUERY_STRING') '</TD></TR>' 
        Say '<TR><TD>REFERER_URL</TD><TD>'       getEnv('REFERER_URL') '</TD></TR>' 
        Say '<TR><TD>REMOTE_ADDR</TD><TD>'       getEnv('REMOTE_ADDR') '</TD></TR>' 
        Say '<TR><TD>REMOTE_HOST</TD><TD>'       getEnv('REMOTE_HOST') '</TD></TR>' 
        Say '<TR><TD>REMOTE_IDENT</TD><TD>'      getEnv('REMOTE_IDENT') '</TD></TR>' 
        Say '<TR><TD>REMOTE_USER</TD><TD>'       getEnv('REMOTE_USER') '</TD></TR>' 
        Say '<TR><TD>REQUEST_METHOD</TD><TD>'    getEnv('REQUEST_METHOD') '</TD></TR>' 
        Say '<TR><TD>SCRIPT_NAME</TD><TD>'       getEnv('SCRIPT_NAME') '</TD></TR>' 
        Say '<TR><TD>SERVER_NAME</TD><TD>'       getEnv('SERVER_NAME') '</TD></TR>' 
        Say '<TR><TD>SERVER_PORT</TD><TD>'       getEnv('SERVER_PORT') '</TD></TR>' 
        Say '<TR><TD>SERVER_PROTOCOL</TD><TD>'   getEnv('SERVER_PROTOCOL') '</TD></TR>' 
        Say '<TR><TD>SERVER_ROOT</TD><TD>'       getEnv('SERVER_ROOT') '</TD></TR>' 
        Say '<TR><TD>SERVER_SOFTWARE</TD><TD>'   getEnv('SERVER_SOFTWARE') '</TD></TR>' 
        Say '</TABLE><P>'

	Return 0

/*********************************************************************/
getEnv:PROCEDURE EXPOSE cgi_lib.
RETURN VALUE(ARG(1),, 'OS2ENVIRONMENT')

/*********************************************************************/
putEnv:PROCEDURE EXPOSE cgi_lib.
RETURN VALUE(ARG(1),ARG(2),'OS2ENVIRONMENT')

