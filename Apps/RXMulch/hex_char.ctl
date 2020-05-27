;   This is a comment (line begins with a semi-colon ";").
;
;   Control-file for changing lower characters (x00-x1F) with the appropriate
;   hex-codes, except for CR-LF, so one can use an editor to look at the contents
;
;   to apply to 'infile' use:
;
;      rxMulch infile hex_char.ctl
;
;   to revert changes to 'infile' use:
;
;      rxMulch infile -hex_char.ctl
;
;  1993-11-14, Rony G. Flatscher, Wirtschaftsuniversitaet Wien
;
;  empty lines are ignored

; search-string/replace-string
; delimiter is "/", as this is the character in column 1

/@x00/<@@x00>/
/@x01/<@@x01>/
/@x02/<@@x02>/
/@x03/<@@x03>/
/@x04/<@@x04>/
/@x05/<@@x05>/
/@x06/<@@x06>/
/@x07/<@@x07>/
/@x08/<@@x08>/
/@x09/<@@x09>/
; conserve line-feed
;/@x0A/<@@x0A>/
/@x0B/<@@x0B>/
/@x0C/<@@x0C>/
; conserve carriage-return
;/@x0D/<@@x0D>/
/@x0E/<@@x0E>/
/@x0F/<@@x0F>/

; delimiter is "=", as this is the character in column 1

=@x10=<@@x10>=
=@x11=<@@x11>=
=@x12=<@@x12>=
=@x13=<@@x13>=
=@x14=<@@x14>=
=@x15=<@@x15>=
=@x16=<@@x16>=
=@x17=<@@x17>=
=@x18=<@@x18>=
=@x19=<@@x19>=
=@x1A=<@@x1A>=
=@x1B=<@@x1B>=
=@x1C=<@@x1C>=
=@x1D=<@@x1D>=
=@x1E=<@@x1E>=
=@x1F=<@@x1F>=


