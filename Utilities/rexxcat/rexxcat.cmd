/*******************************************************************
 *                                                                 *
 * REXXCAT.CMD                                                     *
 *                                                                 *
 * A Rexx CueCat scan decoder                                      *
 *                                                                 *
 * First version: 10/18/2000                                       *
 *                                                                 *
 *******************************************************************/

say
say "Rexx CueCat Decoder"
say
say "Please scan a barcode"
say

parse pull _read
parse var _read "." serial "." type "." code "."

say
say "This CueCat scan is decoded as:"
say
say "Wand serial number     : " || DeCat( serial )
say "Type of barcode scanned: " || DeCat( type )
say "Barcode contents       : " || DeCat( code )

exit 0


/**\
  Main decoding routine.  It is assumed that only a
  component of the scan is passed as a parameter.
  If a "." is present the routine will fail.
\**/

DeCat: procedure
  parse arg scan, type

  if pos( ".", scan ) > 0 then return "ERROR: Not parsed"
  _tb = ""

/**\
  Create the Base64 table used by
  CueCat
\**/
  mrc = Table( )

/**\
  Convert the scanned string into its
  Base64 binary equivalent
\**/
  do i = 1 to Length( scan )
    index = c2d( Substr( scan, i, 1 ) )
    _tb = _tb || table.index
  end

  _l = Length( _tb )
  if _l/8 \= _l%8 then _tb = Substr( _tb, 1, _l - 2 )

/**\
  The resulting binary number has to be
  XORed byte by byte with "01000011" to
  produce the correct output
\**/
  _tx = ""
  do Length( _tb ) / 8
    _tx = _tx || "01000011"
  end

/**\
  BitXOR _tb with _tx.  The resulting string is a series of
  0x00 and 0x01.  To be usable they are converted into
  an ASCII string of "0"s and "1"s
\**/
  x = x2c(b2x(Translate(BitXor(_tb, _tx) , "01", x2c( 0 ) || x2c(1))))

return x

/**\
  The next function creates the
  modified Base64 table used by
  CueCat
\**/

Table: procedure expose table.
  do i = 97 to 122
    table.i = x2b( d2x( i - 97 ) )
    table.i = Adjust( table.i )
  end
  do i = 65 to 90
    table.i = x2b( d2x( i - 39 ) )
    table.i = Adjust( table.i )
  end
  do i = 48 to 57
    table.i = x2b( d2x( i + 4 ) )
    table.i = Adjust( table.i )
  end
  table.43 = "111110"
  table.45 = "111110"
  drop i
return 0

Adjust: procedure
  parse arg var

  if Length( var ) = 4 then var = "00" || var
  else var = Substr( var, 3 )

return var
