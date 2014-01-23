;this contains dir" specific privilege information for the BBS package
; Each entry should have the structure:
;     dir  priv_list  , root_dir
; Where (note that the comma is REQUIRED):
;    dir : is the value of the "dir" option
;       if dir ends with an *, then this entry also applies to all
;       subdirectories of dir
;    priv_list  : privileges required to access this dir (and it's 
;        subdirectories).  A *, or a blank list, means "no access control"
;       (entry is allowed to all clients with bbs rights).
;       Thep privileges can also be used to determine upload ratios
;       (using a priv_ratios.!yyy=' 1 2 ' type of parameter in bbs.ini)
;    root_dir (optional):
;              the fully qualified root directory for dir. If not
;               specified, the "file_dir" default is used.
;              Note that the xxx in the dir=xxx option is relative
;              to root_dir, or file_dir.
; Note that / and \ are equivalent, and that leading and trailing \ (or /)
; are ignored
;
; Examples:
;   /dir1/*   *
;   /dir2/*   CATS 
;   /dir3     DOGS , d:\others
;   /dir4   TIGERS , d:\zoo
;
; Note that *  in /dir1/* is a wildcard,
;           * (in privilege list) is "all clients allowed"
;           an empty ratio list implies "use defaults"
;
; A note on matching.
;  BBS uses a "best match strategy" ---
;   If several entries can match the requested DIRL...
;     1) Exact matches take precedence
;     2) The wildcard match with the "longest portion before the *"
;        is used.
;     3) In case of ties, the match with the "longest portion after 
;         the *" is used.
;     Thus, if your DIR is FOOD/FRUIT/ORANGES
;     then the order (with first being chosen before last) is:
;               /FOOD/FRUIT/ORANGES  (the exact match)
;               /FOOD/*/ORANGES
;               /FOOD/*
;               /*
;     (these 4 entries can appear in any order in this file, with no
;      effect on precedence).
;
; For otherwise open systems, we  highly recommend including a
; /* * entry (permit entry to all directories for all users,
; unless otherwise specified).
/* *
