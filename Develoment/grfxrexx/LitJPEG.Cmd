/*********************************************************************
 LitJPEG - Rapha‰l Vanney, 09/95

 The purpose of this REXX program is to get information from a JPEG
 file. There's of course no waranty of any kind associated to it. Use
 freely.
**********************************************************************/

Debug=1                  /* turn this off to avoid output */
Parse Arg NomF
Say GetJPEGDesc(NomF)
Drop NomF JPEG.
Exit

GetJPEGDesc:
/* Get description for a JPEG file ; if first character of returned
   string is a "(", an error occured and the returned string is a
   description of the error rather than that of the file.
   Otherwise, returns "width x height (color info)".

   Extra info is available in JPEG. if no error occured :
   JPEG.bps         bits per sample
   JPEG.height      image height
   JPEG.width       image width
   JPEG.noc         number of components (I don't know either)
   JPEG.color       color information
*/
Parse Arg FName
Drop JPEG.

If FName="" Then Return "(must supply a filename)"

/* read file header */

Hdr=C2X(CharIn(FName, 1, 2))

If Debug Then Say "File header (SOI) : "Hdr
If Hdr<>"FFD8" Then Return "(not a JPEG file)"

NxtSeg=3
Do While (Seg.Type<>"D9") & (NxtSeg<>-1) & (JPEG.height="JPEG.HEIGHT")
     NxtSeg=LitSegment(NxtSeg)
End

Drop Hdr NxtSeg Seg. Res FName

If JPEG.height<>"JPEG.HEIGHT"
Then Return JPEG.width||" x "||JPEG.height||" ("||JPEG.color||")"
Else Return "(size not found)"

LitSegment:         /* reads a JPEG segment's header from the input file */
Arg SegPos

Seg.marker=C2X(CharIn(FName, SegPos))
If Seg.marker<>"FF" Then
Do
     If Debug Then Say "Invalid segment at "SegPos" ("Seg.marker")"
     Return -1
End
Seg.Type=C2X(CharIn(FName))
Res=SegPos+2                  /* position of next segment */
If (Seg.Type="01") | ((Seg.Type>="D0") & (Seg.Type<="D9")) Then
Do   /* these segments contain no data nor length info */
     Seg.Len=0
End
Else
Do
     Seg.Len=C2D(CharIn(FName, , 2))
End
Res=Res+Seg.Len

If (Seg.Type="C0") | (Seg.Type="C2") Then
Do
     /* start of frame 0 */
     JPEG.bps=C2D(CharIn(FName))             /* bits per sample */
     JPEG.height=C2D(CharIn(FName, , 2))
     JPEG.width=C2D(CharIn(FName, , 2))
     JPEG.noc=C2D(CharIn(FName))             /* number of components */
     Select
          When JPEG.noc=1 Then
               JPEG.color="grayscale"
          When JPEG.noc=3 Then
               JPEG.color="color YCbCr"
          When JPEG.noc=4 Then
               JPEG.color="color CMYK"
          Otherwise
               JPEG.color="?"
     End
End

If Debug Then Say "Segment at "D2X(SegPos, 4)", type "Seg.Type", length "Seg.Len

Return Res
