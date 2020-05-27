;   This is a comment (line begins with a semi-colon ";").
;
;   Control-file for changing lower characters (x00-x1F) with the abbreviations
;   known as "^" plus key-char, except for CR-LF, so one can use an editor to 
;   look at the contents
;
;   to apply to 'infile' use:
;
;      rxMulch infile ctl_char.ctl
;
;   to revert changes to 'infile' use:
;
;      rxMulch infile -ctl_char.ctl
;
;  1994-01-07, Rony G. Flatscher, Wirtschaftsuniversitaet Wien
;

; search-string/replace-string
; delimiter is "/", as this is the character in column 1

/@x00/<@@^@@>/
/@x01/<@@^A>/
/@x02/<@@^B>/
/@x03/<@@^C>/
/@x04/<@@^D>/
/@x05/<@@^E>/
/@x06/<@@^F>/
/@x07/<@@^G>/
/@x08/<@@^H>/
/@x09/<@@^I>/
; conserve line-feed
;/@x0A/<@@^J>/
/@x0B/<@@^K>/
/@x0C/<@@^L>/
; conserve carriage-return
;/@x0D/<@@^M>/
/@x0E/<@@^N>/
/@x0F/<@@^O>/

; delimiter is "=", as this is the character in column 1

=@x10=<@@^P>=    
=@x11=<@@^Q>=    
=@x12=<@@^R>=    
=@x13=<@@^S>=    
=@x14=<@@^T>=    
=@x15=<@@^U>=    
=@x16=<@@^V>=    
=@x17=<@@^W>=    
=@x18=<@@^X>=    
=@x19=<@@^Y>=    
=@x1A=<@@^Z>=    
=@x1B=<@@^[>=    
=@x1C=<@@^\>=    
=@x1D=<@@^]>=    
=@x1E=<@@^^>=    
=@x1F=<@@^_>=    


