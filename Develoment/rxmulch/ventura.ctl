;   This is a comment (line begins with a semi-colon ";").
;
;   Control-file for changing lower characters (x00-x1F) with the appropriate
;   hex-codes, except for CR-LF, so one can use an editor to look at the contents
;
;   This control-file is intended for Ventura CHP-files, which contain all vital
;   Ventura file-information used in a chapter (including absolute paths). You
;   can apply this to the style-sheet *.sty which contains an absolute path to
;   the used *.wid-file.
;
;   This control file will replace a blank+cr+lf with a blank+<-->+cr+lf; this
;   is necessary for Ventura-chapter files, if one wants to alter them e.g.
;   because the original document paths changed. It is mandatory for Ventura-
;   chapter-files to have an extra blank at the end of each line !!
;
;   to apply to 'os2.chp' use:
;
;      rxMulch os2.chp vent_chp.ctl
;
;   no the last blank in each line is being followed by a '<-->' and you
;   can edit the chapter-file with any text-editor.
;
;   to revert changes (i.e. the '<-->') to 'os2.chp' use (note the minus!):
;
;      rxMulch os2.chp -vent_chp.ctl
;
;  1994-02-02, Rony G. Flatscher, Wirtschaftsuniversitaet Wien
;
;  empty lines are ignored

; search-string/replace-string
; delimiter is "/", as this is the character in column 1

; change BLANK+CR+LF to BLANK+<-->+CR+LF
/ @c@l/ <-->@c@l/

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