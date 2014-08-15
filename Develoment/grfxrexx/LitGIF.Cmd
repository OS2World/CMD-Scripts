/*********************************************************************
 LitGIF - Rapha‰l Vanney, 09/95

 The purpose of this REXX program is to get information from a GIF file.
 There's of course no waranty of any kind associated to it. Use freely.
**********************************************************************/

Debug=1
Parse Arg NomF
Say GetGIFDesc(NomF)
Drop NomF GIF.
Exit

GetGIFDesc:
/* Get description for a GIF file ; if first character of returned
   string is a "(", an error occured and the returned string is a
   description of the error rather than of the file.
   Normally returns "width x height (colors)".
   Extra info is available in GIF. if no error occured :
     GIF.bits       bits per pixel (Log2(colors))
     GIF.colors     number of colors
     GIF.bkg        background color
     GIF.width      image width
     GIF.height     image height
*/

Parse Arg FName
Drop GIF.

If FName="" Then Return "(must supply a filename)"

/* read file header */

Hdr=CharIn(FName, 1, 6)                      /* should return "GIF8?a" */
If SubStr(Hdr, 1, 3)<>"GIF" Then
Do
     rc=CharOut(FName)
     Drop Hdr
     Return "(not a GIF file)"
End

CurPos=11

GIF.bits=C2D(BitAnd(CharIn(FName, CurPos), D2C(7)))+1
If Debug Then Say "GIF.bits="GIF.bits
GIF.colors=2 ** GIF.bits
GIF.bkg=C2D(CharIn(FName))

CurPos=CurPos+3+(3*GIF.colors)+5

GIF.width=C2D(Reverse(CharIn(FName, CurPos, 2)))
GIF.height=C2D(Reverse(CharIn(FName, , 2)))

Drop CurPos

rc=CharOut(FName)
Return GIF.width||" x "||GIF.height||" ("||GIF.colors||" colors)"
