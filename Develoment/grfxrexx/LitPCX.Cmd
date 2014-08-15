/*********************************************************************
 LitPCX - Rapha‰l Vanney, 09/95

 The purpose of this REXX program is to get information from a PCX file.
 There's of course no waranty of any kind associated to it. Use freely.
**********************************************************************/

Debug=1
Parse Arg NomF
Say GetPCXDesc(NomF)
Drop NomF PCX.
Exit

GetPCXDesc:
/* Get description for a PCX file ; if first character of returned
   string is a "(", an error occured and the returned string is a
   description of the error rather than of the file.
   Normally returns "width x height (colors)".
   Extra info is available in PCX. if no error occured :

     PCX.version         version of PaintBrush
     PCX.comp            encoding method (should be 1=RLE)
     PCX.bits            bits/pixel/plan
     PCX.xmin            \
     PCX.ymin             \ Image coordinates ; usually xmin=ymin=0
     PCX.xmax             /
     PCX.ymax            /
     PCX.width           image width (xmax-xmin+1)
     PCX.height          image height (ymax-ymin+1)
     PCX.planes          # of planes
     PCX.colors          color information
*/

Parse Arg FName
Drop PCX.

If FName="" Then Return "(must supply a filename)"

/* read file header */

Hdr=C2D(CharIn(FName, 1))                    /* manufacturer */
PCX.version=C2D(CharIn(FName))               /* PaintBrush version */
PCX.comp=C2D(CharIn(FName))                  /* encoding (1=RLL) */
PCX.bits=C2D(CharIn(FName))                  /* bits per pixel */
PCX.xmin=C2D(Reverse(CharIn(FName, , 2)))
PCX.ymin=C2D(Reverse(CharIn(FName, , 2)))
PCX.xmax=C2D(Reverse(CharIn(FName, , 2)))
PCX.ymax=C2D(Reverse(CharIn(FName, , 2)))
PCX.width=PCX.xmax-PCX.xmin+1
PCX.height=PCX.ymax-PCX.ymin+1
PCX.planes=C2D(CharIn(FName, 66))            /* # of planes */

If (Hdr<>10) | (PCX.version>7) | (PCX.version<1) | ,
   (PCX.comp<0) | (PCX.comp>1) | (PCX.planes<0) | (PCX.planes>4) Then
Do
     Drop Hdr PCX.
     rc=CharOut(FName)
     Return "(not a PCX file)"
End
Drop Hdr

Bits=PCX.planes*PCX.bits
If Bits>=15 Then PCX.colors=Bits"-bit true color"
            Else PCX.colors=2**Bits" colors"
Drop Bits

If Debug Then
Do
     Say "PaintBrush version       "PCX.version
     Say "Encoding                 "PCX.comp
     Say "Bits/pixel               "PCX.bits
     Say "x0, y0, x1, y1           "PCX.xmin","PCX.ymin","PCX.xmax","PCX.ymax
     Say "Planes                   "PCX.planes
End

rc=CharOut(FName)

Return PCX.width||" x "||PCX.height||" ("||PCX.colors||")"
