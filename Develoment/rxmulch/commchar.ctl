;   This is a comment (line begins with a semi-colon ";").
;
;   Control-file for changing lower characters (x00-x1F) with the abbreviations
;   known in communications, except for CR-LF, so one can use an editor to look
;   at the contents
;
;   to apply to 'infile' use:
;
;      rxMulch infile commchar.ctl
;
;   to revert changes to 'infile' use:
;
;      rxMulch infile -commchar.ctl
;
;  1994-01-07, Rony G. Flatscher, Wirtschaftsuniversitaet Wien
;
;  empty lines are ignored

; search-string/replace-string
; delimiter is "/", as this is the character in column 1

/@x00/<@@NUL>/
/@x01/<@@SOH>/
/@x02/<@@STX>/
/@x03/<@@ETX>/
/@x04/<@@EOT>/
/@x05/<@@ENQ>/
/@x06/<@@ACK>/
/@x07/<@@BEL>/
/@x08/<@@BS>/
/@x09/<@@HT>/
; conserve line-feed
;/@x0A/<@@LF>/
/@x0B/<@@VT>/
/@x0C/<@@FF>/
; conserve carriage-return
;/@x0D/<@@CR>/
/@x0E/<@@SO>/
/@x0F/<@@SI>/

; delimiter is "=", as this is the character in column 1

=@x10=<@@DLE>=
=@x11=<@@DC1>=
=@x12=<@@DC2>=
=@x13=<@@DC3>=
=@x14=<@@DC4>=
=@x15=<@@NAK>=
=@x16=<@@SYN>=
=@x17=<@@ETB>=
=@x18=<@@CAN>=
=@x19=<@@EM>=
=@x1A=<@@SUB>=
=@x1B=<@@ESC>=
=@x1C=<@@FS>=
=@x1D=<@@GS>=
=@x1E=<@@RS>=
=@x1F=<@@US>=


