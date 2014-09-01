;   This is a comment (line begins with a semi-colon ";").
;
;   Control-file for changing lower characters (x00-x1F) with the appropriate
;   decimal-codes, except for CR-LF, so one can use an editor to look at the 
;   contents
;
;   to apply to 'infile' use:
;
;      rxMulch infile dec_char.ctl
;
;   to revert changes to 'infile' use:
;
;      rxMulch infile -dec_char.ctl
;
;  1993-11-04, Rony G. Flatscher, Wirtschaftsuniversitaet Wien
;
;  empty lines are ignored

; search-string/replace-string
; delimiter is "/", as this is the character in column 1

/@x00/<@@d000>/
/@x01/<@@d001>/
/@x02/<@@d002>/
/@x03/<@@d003>/
/@x04/<@@d004>/
/@x05/<@@d005>/
/@x06/<@@d006>/
/@x07/<@@d007>/
/@x08/<@@d008>/
/@x09/<@@d009>/
; conserve line-feed
;/@x0A/<@@d010>/
/@x0B/<@@d011>/
/@x0C/<@@d012>/
; conserve carriage-return
;/@x0D/<@@d013>/
/@x0E/<@@d014>/
/@x0F/<@@d015>/

; delimiter is "=", as this is the character in column 1

=@x10=<@@d016>=
=@x11=<@@d017>=
=@x12=<@@d018>=
=@x13=<@@d019>=
=@x14=<@@d020>=
=@x15=<@@d021>=
=@x16=<@@d022>=
=@x17=<@@d023>=
=@x18=<@@d024>=
=@x19=<@@d025>=
=@x1A=<@@d026>=
=@x1B=<@@d027>=
=@x1C=<@@d028>=
=@x1D=<@@d029>=
=@x1E=<@@d030>=
=@x1F=<@@d031>=


