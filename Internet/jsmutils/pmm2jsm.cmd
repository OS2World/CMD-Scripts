/*
  Some rexx to convert PMMail Addressbook entries
  to JStreet Mailer
*/

separator = x'DE'

infile  = 'Addr.db'
outfile = 'jstreet.adr'


lineX  = "<TD></TD>"
lineTR = "</TR>"

do while lines(infile)
 addrline = linein(infile)
 parse value addrline with email "Ş" nickname "Ş" realname "Ş" flags
/* say "Here's the stuff: "
 say "  realname      : " realname
 say "  email         : " email
 say "  nickname      : " nickname */
 
 line1  = "<TR VALIGN=TOP>" 
 line2  = "<TD><B>"||nickname||"</B></TD>"
 line3  = "<TD>"||email||"</TD>"
 line4  = "<TD>"realname"</TD>"
 line5  = lineX
 line6  = lineX
 line7  = lineX
 line8  = lineX
 line9  = lineX
 line10 = lineX
 line11 = lineX
 line12 = lineX
 line13 = lineX
 line14 = lineX
 line15 = lineTR
 
 rc = lineout(outfile, line1)
 rc = lineout(outfile, line2)
 rc = lineout(outfile, line3)
 rc = lineout(outfile, line4) 
 rc = lineout(outfile, line5) 
 rc = lineout(outfile, line6) 
 rc = lineout(outfile, line7) 
 rc = lineout(outfile, line8) 
 rc = lineout(outfile, line9) 
 rc = lineout(outfile, line10) 
 rc = lineout(outfile, line11) 
 rc = lineout(outfile, line12) 
 rc = lineout(outfile, line13) 
 rc = lineout(outfile, line14) 
 rc = lineout(outfile, line15) 

end

return



