/*********************************************************************
 LitBMP - Rapha‰l Vanney, 09/95

 The purpose of this REXX program is to get information from a BMP file.
 There's of course no waranty of any kind associated to it. Use freely.
**********************************************************************/

Debug=1
Parse Arg NomF
Say GetBMPDesc(NomF)
Drop NomF BMP.
Exit

GetBMPDesc:
/* Get description for a BMP file ; if first character of returned
   string is a "(", an error occured and the returned string is a
   description of the error rather than of the file.
   Normally returns "width x height (color info)".
   Extra info is available in BMP. if no error occured :
   (Note that the extra info is unaccurate for non-Windows BMP:s ; this
   is because I don't have a documentation for OS/2's BMP).

     BMP.fsize           file size
     BMP.offbits         ?
     BMP.isize           ?
     BMP.width           image width
     BMP.height          image height
     BMP.planes          number of planes
     BMP.bits            bits per pixel (per plane)
     BMP.comp            compression type
     BMP.imgsize         ?
*/

Parse Arg FName
Drop BMP.

If FName="" Then Return "(must supply a filename)"

/* read file header */

Hdr=C2D(Reverse(CharIn(FName, 1, 2)))             /* type */
BMP.fsize=C2D(Reverse(CharIn(FName, , 4)))        /* which size ? */
BMP.rsv=C2D(Reverse(CharIn(FName, , 4)))          /* should be 0 */

If (Hdr<>19778) | (BMP.rsv<>0) Then
Do
     Drop Hdr BMP.
     rc=CharOut(FName)
     Return "(not a BMP file)"
End

BMP.offbits=C2D(Reverse(CharIn(FName, , 4)))
BMP.isize=C2D(Reverse(CharIn(FName, , 4)))
BMP.width=C2D(Reverse(CharIn(FName, , 4)))        /* bitmap width */
BMP.height=C2D(Reverse(CharIn(FName, , 4)))       /* bitmap height */
BMP.planes=C2D(Reverse(CharIn(FName, , 2)))       /* # of planes */
BMP.bits=C2D(Reverse(CharIn(FName, , 2)))         /* bits per pel */
BMP.comp=C2D(Reverse(CharIn(FName, , 4)))         /* comp */
BMP.imgsize=C2D(Reverse(CharIn(FName, , 4)))      /* img size in bytes */

Bits=BMP.planes*BMP.bits
If Bits>=15 Then BMP.colors=Bits||"-bit true color"
            Else BMP.colors=2**Bits||" colors"
Drop Bits

If Debug Then
Do
     Say "Type           "Hdr
     Say "File size      "BMP.fsize
     Say "bfOffBits      "BMP.offbits
     Say "biSize         "BMP.isize
     Say "Image size     "BMP.width"x"BMP.height
     Say "# of planes    "BMP.planes
     Say "Bits/pixel     "BMP.bits
     Say "Compression    "BMP.comp
     Say "Size in bytes  "BMP.imgsize
End

rc=CharOut(FName)

Return BMP.width||" x "||BMP.height||" ("||BMP.colors||")"

