/*
   Retrieves the last zone:net/node that BinkleyTerm had a mail session
   with, will accept a command line arg which is path\filename pointing
   to your binkley.scd file. If no arg is provided, it assumes that a
   the binkley.scd file is in the current directory.

   See comments below concerning setting environment variables.

   This code is released into the public domain by Chuck Renshaw on or
   about 4/91 with no guarantees of any type attached. Use it as you
   will, share it if you can.

*/

arg fn
if fn = '' then fn = 'binkley.scd'
rtn = STREAM(fn, 'C', 'OPEN')
lzonel = CHARIN(fn, 33, 1)
lzoneh = CHARIN(fn, 34, 1)
lzone = (lzoneh)(lzonel)
lzoned = C2D(lzone)
lnetl = CHARIN(fn, 35, 1)
lneth = CHARIN(fn, 36, 1)
lnet = (lneth)(lnetl)
lnetd = C2D(lnet)
lnodel = CHARIN(fn, 37, 1)
lnodeh = CHARIN(fn, 38, 1)
lnode = (lnodeh)(lnodel)
lnoded = C2D(lnode)
SAY 'Last mail session''s zone:net/node was' lzoned':'lnetd'/'lnoded'.'
/*
    If you don't want to set environment variables, delete the 3 set
    statements. You also might want to change the names of the env.
    variables to suit your setup. As set up, the zone will be set in
    LZONE, the net in LNET, and the node in LNODE.

*/
'@set LZONE='lzoned
'@set LNET='lnetd
'@set LNODE='lnoded
/* */
rtn = STREAM(fn, 'C', 'CLOSE')
