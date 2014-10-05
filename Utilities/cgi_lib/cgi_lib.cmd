/************************************************************************/
/*                                                                      */
/*      CGi_LiB.CMD  (CGI プログラム用のユーティリィ)                   */
/*                                                                      */
/*      Version 1.00  (released  14 May 1998)                           */
/*                                                                      */
/*      Copyright (C) 1997-1998 K,Shimizu All rights reserved.          */
/*                                                                      */
/************************************************************************/
/*                                                                      */
/* This is free software with ABSOLUTELY NO WARRANTY.                   */
/*                                                                      */
/* This program is free software; you can redistribute it and/or modify */
/* it under the terms of the GNU General Public License as published by */
/* the Free Software Foundation; either version 2 of the License, or    */
/* (at your option) any later version.                                  */
/*                                                                      */
/* This program is distributed in the hope that it will be useful,      */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of       */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        */
/* GNU General Public License for more details.                         */
/*                                                                      */
/* You should have received a copy of the GNU General Public License    */
/* along with this program; if not, write to the Free Software          */
/* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA            */
/* 02111-1307, USA                                                      */
/*                                                                      */
/************************************************************************/
MainRtnBlock:
IF (ARG() = 0)  THEN    RETURN  'NoArg'

FUNC  =  TRANSLATE(ARG(1))


/*  'ReadParse' 機能は外部プログラムからの呼び出し不可   */
IF  (FUNC = 'READPARSE') THEN  EXIT 'NotAvailable'

SELECT
    WHEN (FUNC = 'CGIDIE')        THEN  CALL  CgiDie ARG(2), ARG(3)
    WHEN (FUNC = 'CGIERROR')      THEN  CALL  CgiError ARG(2), ARG(3)
    WHEN (FUNC = 'CGIPARSE')      THEN  CALL  CgiParse
    WHEN (FUNC = 'CONVERTCRLF')   THEN  CALL  ConvertCRLF  ARG(2)
    WHEN (FUNC = 'GETVARVAL')     THEN  CALL  GetVarVal  ARG(2)
    WHEN (FUNC = 'HTMLBOT')       THEN  CALL  HtmlBot
    WHEN (FUNC = 'HTMLTOP')       THEN  CALL  HtmlTop  ARG(2)
    WHEN (FUNC = 'HTMLTOP2')      THEN  CALL  HtmlTop2  ARG(2)
    WHEN (FUNC = 'MYURL')         THEN  CALL  MyURL
    WHEN (FUNC = 'PRINTDOCTYPE')  THEN  CALL  PrintDocType  ARG(2)
    WHEN (FUNC = 'PRINTHEADER')   THEN  CALL  PrintHeader
    WHEN (FUNC = 'READPARSE')     THEN  CALL  ReadParse  ARG(2)
    WHEN (FUNC = 'SETVARVAL')     THEN  CALL  SetVarVal
    WHEN (FUNC = 'URLDECODE')     THEN  CALL  UrlDecode  ARG(2)
    OTHERWISE   RETURN  'NoFunc'
END

EXIT  RESULT


/*************************  Function Blocks  *************************/


/*********************************************************************/
/*
    CgiError と同じだが、ここでプログラムは終了する。
     (cgi-lib.pl のマネ)

    引数 1 : 文書のタイトル および 第1レベルの見出し となる文字列
    引数 2 : 主内容となる文字列 (説明など)
*/
/********************************************************************/
CgiDie:PROCEDURE EXPOSE cgi_lib.

EXIT (CgiError(ARG(1),ARG(2)))


/*********************************************************************/
/*
    cgi の異常終了時メッセージを標準出力に出力する。

    引数 1 : 文書のタイトル および 第1レベルの見出し となる文字列
    引数 2 : 主内容となる文字列 (説明など)
*/
/********************************************************************/
CgiError:PROCEDURE EXPOSE cgi_lib.
CRLF  = '0D0A'x

output = PrintHeader()
output = output || '<HTML><HEAD><TITLE>' || ARG(1) || '</TITLE></HEAD>' || CRLF
output = output || '<BODY><H1>' || ARG(1) || '</H1>' || CRLF

output = output || '<P>' ARG(2) '</P>' || CRLF
output = output || '</BODY></HTML>' || CRLF
SAY output

RETURN output


/*********************************************************************/
/*  
    フォームに入力された変数の値を、CERN httpd サーバと一緒に配布される
    cgiparse と同じ規則で環境変数に格納する。

      ※ フォームのメソッドは、自動的に判別して処理する。

    戻り値 : 変数名のリスト

    例) 
        ブラウザでのフォームの入力が以下の通りだとすると、

          変数の名前  変数の値
          ----------  --------
           name        権兵衛
           hobby       読書
           hobby       スポーツ

        環境変数の内容は、以下のようになる

           FORM_name    → '権兵衛'
           FORM_hobby   → '読書,スポーツ'

        戻り値は 'name,hobby' となる。
*/
/*********************************************************************/
CgiParse:PROCEDURE EXPOSE cgi_lib.
TRUE  = 1
FALSE = 0

VarNamesTBL = ''

IF  (ReadParse(',') = FALSE)  THEN  RETURN  ''

DO  i=1 to cgi_lib.input.0 by 1
    VarName  = VALUE('cgi_lib.input.' || i || '.name')
    StemName = 'cgi_lib.input.' || VarName
    VarValue = VALUE(StemName)
    EnvName  = 'FORM_' || VarName
    rc = putEnv(EnvName,VarValue)
    IF (i > 1)  THEN  VarNamesTBL = VarNamesTBL || ','
    VarNamesTBL = VarNamesTBL || VarName
END     /* DO */

RETURN  VarNamesTBL


/*********************************************************************/
/*
    改行コードをすべて CR+LF に変換する。

    引数 1 : 変換対象の文字列
*/
/********************************************************************/
ConvertCRLF:PROCEDURE EXPOSE cgi_lib.
CRLF  = '0D0A'x
CR    = '0D'x
LF    = '0A'x

IF (ARG() \= 1) THEN RETURN ''

StrnLen = LENGTH(ARG(1))
DecStrn = ARG(1)
OutStrn = ''

i = 1
DO  WHILE (i <= StrnLen)
    c  = SUBSTR(DecStrn, i, 1)
    SELECT
        WHEN (c = LF)  THEN  OutStrn = OutStrn || CRLF
        WHEN (c = CR)  THEN
            DO
                OutStrn = OutStrn || CRLF
                IF (i = StrnLen)  THEN  NOP
                ELSE  IF (SUBSTR(DecStrn,i,2) = CRLF) THEN  i = i+1
            END
        OTHERWISE   OutStrn = OutStrn || c
    END  /* select */
    i = i+1
END

RETURN OutStrn


/*********************************************************************/
/*  
    CgiParse の実行後、フォームで入力された変数の値を得る。

    引数 1 : 変数名

    戻り値 : 変数の値
*/
/*********************************************************************/
GetVarVal:PROCEDURE EXPOSE cgi_lib.

EnvName  = 'FORM_' || ARG(1)
RETURN getEnv(EnvName)


/*********************************************************************/
/*
    HTML 文書の終了文字列 (</BODY></HTML>) を得る。
*/
/********************************************************************/
HtmlBot:PROCEDURE EXPOSE cgi_lib.

CRLF  = '0D0A'x
RETURN ('</BODY></HTML>' || CRLF)


/*********************************************************************/
/*
    HTML 文書の開始文字列 (<HEAD><TITLE><BODY><H1>) を得る。

    引数 1 : 文書のタイトル および 第1レベルの見出し となる文字列
*/
/********************************************************************/
HtmlTop:PROCEDURE EXPOSE cgi_lib.

RETURN ('<HTML><HEAD><TITLE>' || ARG(1) || '</TITLE></HEAD><BODY><H1>' || ARG(1) || '</H1>')


/*********************************************************************/
/*
    背景色として白を指定し、第1レベルの見出しを中央揃えにした
    HTML 文書の開始文字列 (<HEAD><TITLE><BODY><H1>) を得る。

    引数 1 : 文書のタイトル および 第1レベルの見出し となる文字列
*/
/********************************************************************/
HtmlTop2:PROCEDURE EXPOSE cgi_lib.

RETURN ('<HTML><HEAD><TITLE>' || ARG(1) || '</TITLE></HEAD><BODY BGCOLOR="#ffffff"><DIV ALIGN="center"><H1>' || ARG(1) || '</H1></DIV>')


/*********************************************************************/
/*
    cgi スクリプトの URL を得る。
*/
/********************************************************************/
MyURL:PROCEDURE EXPOSE cgi_lib.

port = getEnv('SERVER_PORT')
IF (port = 80) | (port = '') THEN port = ''
ELSE port = ':' || port
RETURN ('http://' || getEnv('SERVER_NAME') || port || getEnv('SCRIPT_NAME'))


/*********************************************************************/
/*
    HTML 文書のバージョン宣言文字列 (<!DOCTYPE>) を得る。

    引数 1 : HTML のバージョン
*/
/********************************************************************/
PrintDocType:PROCEDURE EXPOSE cgi_lib.
CRLF  = '0D0A'x

DocType = TRANSLATE(ARG(1))

SELECT 
    WHEN (DocType = 'HTML4.0')  | (DocType = '4.0')   THEN output = ('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">' || CRLF)
    WHEN (DocType = 'HTML4.0S') | (DocType = 'Strict')   THEN output = ('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">' || CRLF)
    WHEN (DocType = 'HTML4.0T') | (DocType = 'Transitional') THEN output = ('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' || CRLF)
    WHEN (DocType = 'HTML4.0F') | (DocType = 'Frame') THEN output = ('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Frameset//EN">' || CRLF)
    WHEN (DocType = 'HTML3.2')  | (DocType = '3.2')   THEN output = ('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">' || CRLF)
    WHEN (DocType = 'HTML2.0')  | (DocType = '2.0')   THEN output = ('<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">' || CRLF)
    OTHERWISE  output = ('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' || CRLF)
END
RETURN  output


/*********************************************************************/
/*
    cgi 出力のヘッダ部を得る

      ※ DateUtil.CMD を外部ルーチンとして使用
*/
/********************************************************************/
PrintHeader:PROCEDURE EXPOSE cgi_lib.

CRLF  = '0D0A'x
output = 'HTTP/1.0 200 OK' || CRLF
output =  output || 'Date:' dateutil(RfcDate) || CRLF
output =  output || 'Server:' GetEnv('SERVER_SOFTWARE') || CRLF
output =  output || 'Content-Type: text/html' || CRLF
output =  output || 'MIME-Version: 1.0' || CRLF || CRLF
RETURN output


/*********************************************************************/
/*  
    フォームに入力された変数の値を、ステム 'cgi_lib.input.' に格納する

      1) 変数の値を 'cgi_lib.input.変数名' に格納する
      2) 変数の数を 'cgi_lib.input.0' に格納する。
      3) 変数名を 'cgi_lib.input.番号.name' に格納する。
         ("番号" は 1 ～ 変数の数 までの間の整数)

      ※ フォームのメソッドは、自動的に判別して処理する。

    引数 1 : 同一名の項目に複数の値が入った場合のセパレータ文字。
             省略時値は '00'x

    戻り値 : 0 または 1  (0:変数なし   1:変数あり)

    例)
        ブラウザでのフォームの入力が以下の通りだとすると、

          変数の名前  変数の値
          ----------  --------
           name        権兵衛
           job         きこり
           age         25

        ステム変数の内容は以下のようになる

           cgi_lib.input.name    → '権兵衛'
           cgi_lib.input.job     → 'きこり'
           cgi_lib.input.age     → '25'
           cgi_lib.input.0       → '3'
           cgi_lib.input.1.name  → 'name'
           cgi_lib.input.2.name  → 'job'
           cgi_lib.input.3.name  → 'age'
*/
/*********************************************************************/
ReadParse:PROCEDURE EXPOSE cgi_lib.

TRUE  = 1
FALSE = 0
CRLF  = '0D0A'x
CR    = '0D'x
LF    = '0A'x
QueryString = ''
cgi_lib.input. = ''

IF (ARG(1) = '') THEN   Sepatater = '00'x
ELSE    Separater = ARG(1)

IF  ChkMethGet()  THEN  QueryString = getEnv('QUERY_STRING')
ELSE
    DO
        i = getEnv('CONTENT_LENGTH')
        IF (DATATYPE(i,'W'))    THEN    QueryString = CHARIN(STDIN,,i) 
        ELSE    QueryString = ''
    END

QueryString = TRANSLATE(QueryString,' ','+')

i=0
DO  UNTIL  (QueryString = '')
    NameEqValue = ''
    VarName     = ''
    VarValue    = ''
    PARSE  VAR  QueryString  NameEqValue  '&'  QueryString
    PARSE  VAR  NameEqValue  VarName  '='  VarValue
    IF (VarName = '')   THEN  ITERATE
    VarName  = UrlDecode(VarName)
    VarValue = UrlDecode(VarValue)
    StemName = 'cgi_lib.input.' || VarName
    OldValue = VALUE(StemName)
    IF (OldValue = '')  | (OldValue = TRANSLATE(StemName)) THEN  NewValue = VarValue
    ELSE    NewValue = OldValue || Separater || VarValue
    rc = VALUE(StemName,NewValue)
    i=i+1
    StemName = 'cgi_lib.input.' || i || '.name'
    rc = VALUE(StemName,VarName)
END     /* DO */

cgi_lib.input.0 = i

IF ( i = 0 )    THEN    RETURN  FALSE
ELSE    RETURN  TRUE


/*********************************************************************/
/*  
    CgiParse を実行する
    (cgi-lib.pl のマネ)
*/
/*********************************************************************/
SetVarVal:PROCEDURE EXPOSE cgi_lib.

RETURN CgiParse


/*********************************************************************/
/*
    URL エンコードされた文字列を復号する。
    同時に、改行コードをすべて CR+LF に変換する。

    引数 1 : 復号対象の文字列
*/
/********************************************************************/
URLDecode:PROCEDURE EXPOSE cgi_lib.
CRLF  = '0D0A'x
CR    = '0D'x
LF    = '0A'x
DecStrn = ''

IF (ARG() \= 1) THEN RETURN ''

Strn = TRANSLATE(ARG(1),' ','+')
StrnLen = LENGTH(Strn)

    /* URL Decode */

i = 1
DO  WHILE (i <= StrnLen)
    c = SUBSTR(Strn, i, 1)
    IF  (c = '%')  THEN
            DO
                DecStrn = DecStrn || x2c(SUBSTR(Strn, i+1, 2))
                i = i+2
            END
    ELSE   DecStrn = DecStrn || c
    i = i+1
END

    /* Converts LF, CR -> CRLF */

RETURN ConvertCRLF(DecStrn)


/*********************************************************************/
ChkMethGet:PROCEDURE EXPOSE cgi_lib.
RETURN (getEnv('REQUEST_METHOD') = 'GET')

/*********************************************************************/
ChkMethPost:PROCEDURE EXPOSE cgi_lib.
RETURN (getEnv('REQUEST_METHOD') = 'POST')

/*********************************************************************/
GetEnv:PROCEDURE EXPOSE cgi_lib.
RETURN VALUE(ARG(1),, 'OS2ENVIRONMENT')

/*********************************************************************/
PutEnv:PROCEDURE EXPOSE cgi_lib.
RETURN VALUE(ARG(1),ARG(2),'OS2ENVIRONMENT')
