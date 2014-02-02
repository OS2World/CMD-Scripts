/* Sample.CMD, calls IsISIN.CMD */

error.0='is possibly a valid ISIN code'
error.1='is NOT a valid ISIN code (invalid length)'
error.2='is NOT a valid ISIN code, invalid character at position 1-2'
error.3='is NOT a valid ISIN code, invalid character at position 3-11'
error.4='is NOT a valid ISIN code, invalid character at position 12' 
error.5='is NOT a valid ISIN code, checksum failure'

isin.0=20
DO i=1 TO 10
   isin.i='NL000000010'||i-1
END i
isin.11='FR0000031122'   
isin.12='US4592001014'
isin.13='Us4592001014'
isin.14='US459200101X'
isin.15='US459200101' 
isin.16='US45920010 1' 
isin.17='GB00B03MLX29'   
isin.18='GB00B03NLX29'
isin.19='BE0003793107'   
isin.20='FR0010208488'   

DO i=1 TO isin.0
   rc=IsISIN(isin.i)
   SAY isin.i error.rc
END i
CALL 'IsISIN.CMD'

EXIT
