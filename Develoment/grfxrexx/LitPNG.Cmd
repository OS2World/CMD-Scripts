/*********************************************************************
 LitPNG - Rapha‰l Vanney, 09/95

 The purpose of this REXX program is to get information from a PNG file.
 There's of course no waranty of any kind associated to it. Use freely.
**********************************************************************/

Debug=1                  /* turn this off to avoid output */
Parse Arg NomF
Say GetPNGDesc(NomF)
Drop NomF PNG.
Exit

GetPNGDesc:
/* Get description for a PNG file ; if first character of returned
   string is a "(", an error occured and the returned string is a
   description of the error rather than that of the file.
   Otherwise, returns "width x height (color info)".

   Extra info is available in PNG. if no error occured :
     PNG.width      width of image
     PNG.height     height of image
     PNG.bits       bits per pixel
     PNG.ctype      color type
     PNG.comp       compression type
     PNG.filter     filter type
     PNG.inter      interlace type
     PNG.info       text info regarding colors (based on ctype & bits)
*/
Parse Arg FName
Drop PNG.

If FName="" Then Return "(must supply a filename)"

/* read file header */

Hdr=CharIn(FName, 1, 8)
If Hdr<>(D2C(137)||"PNG"||D2C(13)||D2C(10)||D2C(26)||D2C(10)) Then
     Return "(not a PNG file)"

NxtSeg=9
Do While (Seg.Type<>"IEND") & (NxtSeg<>-1) & (PNG.height="PNG.HEIGHT")
     NxtSeg=LitSegment(NxtSeg)
End

Drop Hdr NxtSeg Seg. Res FName
rc=CharOut(FName)

If PNG.height<>"PNG.HEIGHT"
Then Return PNG.width||" x "||PNG.height||" ("||PNG.info||")"
Else Return "(size not found)"

LitSegment:         /* reads a PNG chunk's header from the input file */
Arg SegPos

Seg.len=C2D(CharIn(FName, SegPos, 4))   /* length of chunk's DATA */
Seg.type=CharIn(FName, , 4)             /* chunk type */
Res=SegPos+12+Seg.len                   /* position of next chunk */

If Debug Then Say "Chunk at "D2X(SegPos, 4)", type "Seg.type", length "Seg.len

If Seg.type="IHDR" Then
Do
     /* header chunk */
     PNG.width=C2D(CharIn(FName, , 4))
     PNG.height=C2D(CharIn(FName, , 4))
     PNG.bits=C2D(CharIn(FName))
     PNG.ctype=C2D(CharIn(FName))
     PNG.comp=C2D(CharIn(FName))
     PNG.filter=C2D(CharIn(FName))
     PNG.inter=C2D(CharIn(FName))
     Select
          When PNG.ctype=0 Then
               PNG.info=2**PNG.bits||" gray levels"
          When PNG.ctype=2 Then
               PNG.info=3*PNG.bits||"-bit RGB color"
          When PNG.ctype=3 Then
               PNG.info=2**PNG.bits||" colors"
          When PNG.ctype=4 Then
               PNG.info=2**PNG.bits||" gray levels with alpha chanel"
          When PNG.ctype=6 Then
               PNG.info=3*PNG.bits||"-bit RGB color with alpha chanel"
          Otherwise
               PNG.info="unknow color type ("||PNG.ctype||")"
     End
End

Return Res
