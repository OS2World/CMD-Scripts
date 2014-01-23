/*
        GetWEBPics 0.2b
        (C) 1996 By Marco Pontello

        Download all *.JPG & *.GIF files from a WWW page
        (Need GetURL (C) Derek J Decker)

*/

Call ShowHeader

Parse Arg URLName

If URLName = '' then
do
        Call ShowUsage
        exit
end

GetURLPath = 'f:\tools\geturl\'

Say 'Getting Index file...'
'@'GeturlPath'geturl http://'URLName ' -timeout 200 -o Index.TMP'

if Translate(Right(URLName,4)) = ".HTM" | Translate(Right(URLName,5)) = ".HTML" then
do
        c = ''
        do i = length(URLName) to 1 by -1
                c = substr(URLName, i, 1)
                if c = '/' then leave
        end
        URLName = Left(URLName, i)
end

if Right(URLName,1) <> "/" then URLName = URLName || "/"

TotLines = 0
TotImg = 0
ImgList= ' '

Say 'Scanning...'

SrcFile = 'Index.TMP'

DO WHILE Lines(SrcFile)
        Temp = Strip(LineIn(SrcFile))
        If Temp <> "" then
        Do
                TotLines = TotLines +1
                SrcLines.TotLines = Temp
                l = TotLines
                P = Pos('<A HREF="', Translate(SrcLines.l))
                If P <> 0 then
                do
                        PP = Pos('">', SrcLines.l,P)
                        Temp= SubStr(SrcLines.l, P, (PP-P+2))
                        P = Pos('"', Temp)
                        PP = Pos('"', Temp, P+1)
                        Link = SubStr(Temp, P+1, (PP-P-1))

                        if Translate(Right(Link,4)) = ".JPG" | Translate(Right(Link,4)) = ".GIF" then
                        do
                                if WordPos(Link, ImgList) = 0 then
                                do
                                        TotImg = TotImg +1
                                        Img.TotImg = Link
                                        ImgList = ImgList || Link || ' '
                                end
                        end
                end
        end
end

SrcLines.0 = TotLines
Img.0 = TotImg
Say 'Found 'TotImg' link to pics.'
Say ' '

If TotImg > 0 then
do
        i = 1
        DO while i <= TotImg
                Say 'Pic 'i'/'TotImg' - 'Img.i
                '@'GeturlPath'geturl http://'URLName''Img.i ' -o -timeout 200'
                i = i + 1
        END
end

Say ' '
Say 'Finished!'
exit



ShowHeader:
        Say ''
        Say 'GetWEBPics 0.2b - (C) 1996 By Marco Pontello'
        Say '--------------------------------------------'
return

ShowUsage:
        Say 'Usage: GetWPics <URL>'
return
