/* VOLS            CMD by Gord Snider  2006/07/31  v02.06.00  2017/04/03     */
/* PURPOSE: To display, for a list of drives, or per SysDriveMap() group, (i.e.
LOCAL), the RESERVEDRIVELETTER, the free drives, the inaccessible drives,
the drive letters, volume labels, actual free space, per cent free space,
actual used space, per cent used space and total space. Default is to show all
such LOCAL space in MebiBytes (1,048,576 B).
For the SysDriveMap() groups DETACHED and REMOTE only the list of drives
is displayed, (may be null).

    SYNTAX:  VOLS [drives] [switches]
        or   VOLS /?

     WHERE:
Optional argument  drives  is a list of one or more drive letters (with colons
and spaces), e.g. VOLS C: D: E: shows stats for drives C: D: and E: if they
are accessible, and are a subset of the larger group.

   OPTIONS:
/?       to show this help screen and exit
/K | /B  to show disk sizes in Kilobytes or Bytes
/R | /D  to show REMOTE or DETACHED drives;

NOTE: This script works best with a window at least 80 columns wide.
NOTE: If there is a CD/DVD in your CD/DVD drive this script will include it in
      the numbers (which is probably NOT what you want, so remove the CD/DVD
      first).
NOTE: This script requires my Rexx External Function _color().
NOTE: This script requires my Rexx External Function _commas().
NOTE: This script assumes that RexxUtil.DLL has already been loaded.
NOTE: With the use of RexxUtil.DLL it is likely this will only work on OS/2
      compatible systems.
*/

/* opts     as of 2013/10/25 */
arg . '/'switches +0                                  /* split off the switches from the rest */
opt. = 0                                              /* unset options will be FALSE */
mod. = ''                                             /* unset option mods will be NULL */
do while pos( '/', switches) > 0                      /* each option must have leading slash */
   parse var switches '/'opt'/'switches +0            /* parse next option/modification set */
   parse upper var opt opt 2 mod                      /* split option from any modification */
   opt.opt = 1                                        /* capture option name, option value = TRUE */
   mod.opt = mod                                      /* capture option's modification, if any */
end   /* opts */

/* help     as of 2013/10/26 */
parse value SysTextScreenSize() with rows cols             /* used to check for window full */
opdel = '/'||'*'||'FF'x                                    /* This line needed by LN.CMD */
cldel = 'FF'x||'*'||'/'                                    /* This line needed by LN.CMD */
if opt.? then do                                           /* Help screen */
      do ll = 1 to sourceline() while left( sourceline( ll), 2) \= '*'||'/'    /* get next help line */
         sl = sourceline( ll)                              /* to shorten next REXX lines */
         if pos( cldel, sl) - pos( opdel, sl) = 7 then     /* both delims present, 7 chars apart */
               sl = delstr( sl, pos( opdel, sl) , 10)      /* remove line #, if any, anywhere in line */
         say strip( left( sl, cols - 1), 'T')              /* say the stripped help line */
         if (ll // (rows - 2)) = 0 & ,                     /* 2 lines short of full screen and */
            left( sourceline( ll + 1), 2) \= '*'||'/' then do  /* next line NOT end of comments */
               say '<Enter> to continue ...'
               pull .
         end
      end ll                                               /* end of list-a-help line loop */
      exit 0
end   /* help */

select
   when opt.D then scope = 'DETACHED'
   when opt.R then scope = 'REMOTE'
   otherwise       scope = 'LOCAL'
end

scopevols   = SysDriveMap( , 'LOCAL')                                     /* scopevols can be something or null */
freevols    = SysDriveMap( , 'FREE')
remotevols  = SysDriveMap( , 'REMOTE')
detachvols  = SysDriveMap( , 'DETACHED')

if opt.D | opt.R then do
      say
      say 'These are the' scope 'drives:'
      say SysDriveMap( , scope)
      exit
end

rdl_flag = 0                                                              /* Find RESERVEDRIVELETTER */
say                                                                       /* blank line */
parse value Value( 'OSDIR', , 'OS2ENVIRONMENT') with bootdrive '\' .      /* capture bootdrive */
config = bootdrive'\CONFIG.SYS'                                           /* get FQFN of config.sys */

say 'Bootdrive is' bootdrive

call Stream config, 'C', 'OPEN READ'                                      /* Open CONFIG.SYS */
do i1 = 1 while Lines( config)
   rdl_line = LineIn( config)
   if Substr( rdl_line, 1, 19) = 'RESERVEDRIVELETTER=' then do            /* find R_D_L in config.sys */
         rdl_flag = 1                                                     /* Found it! */
         leave
    end
end i1
call Stream config, 'C', 'CLOSE'

if rdl_flag then do
      say
      say rdl_line                                                        /* announce R_D_L */
      parse var rdl_line 'RESERVEDRIVELETTER=' rdl
      freevols = delword( freevols, wordpos( rdl':', freevols), 1)
      end
   else do
      say
      say 'RESERVEDRIVELETTER not set.'
end

arg argvols '/' . +0                                                      /* Command line request for these drives. */

vols1 = ''                                                                /* For list of requested drives. */
do jj = 1 to words( argvols)                                              /* Are Asked for drives in scope?  */
   argvol = word( argvols, jj)
   if wordpos( argvol, scopevols) = 0 then do
         say
         say '.. Drive' argvol 'is not in scope' scope
         iterate
   end
   if SysDriveInfo( argvol) = '' then do
         say
         say '.. Drive' argvol 'is not accessible.'
         iterate
   end
   vols1 = vols1 argvol                                                   /* Accessible vols in scope on cmdline. */
end jj

say
vols2 = ''                                                                /* For list of accessible drives. */
do kk = 1 to words( scopevols)
   scopevol = word( scopevols, kk)
   if SysDriveInfo( scopevol) = '' then do
         say '.. Drive' scopevol 'is not accessible.'
         iterate
         end
      else do
         parse value SysDriveInfo( scopevol) with drive free total label
         if total = 0 then do
               say '.. Drive' scopevol 'is empty.'
               iterate
         end   /* if total = 0 then  */
   end   /* if SysDriveInfo( scopevol) = '' then */
   vols2 = vols2 scopevol                                                 /* Accessible vols in scope. */
end kk

vols = ''
if vols2 \= '' then vols = vols2
if vols1 \= '' then vols = vols1

if vols = '' then do                                                      /* List of vols for space determination. */
      say
      say '.. No volumes available for scope' scope'.'
      exit
end

say
say "These are the free LOCAL drive letters."
say freevols

numeric digits 15                                                         /* for large hard drive sizes */

sysfree  = 0                                                              /* system total free space  */
sysused  = 0                                                              /* system total used space  */
systotal = 0                                                              /* system total drive space */

select
   when opt.B   then do; heading = '  Bytes'; units =       1; end
   when opt.K   then do; heading = 'KiBytes'; units =    1024; end        /* 1 KiB = 1024 B */
   otherwise             heading = 'MiBytes'; units = 1048576             /* 1 MiB = 1024 KiB = 1048576 B */
end

say
say '   Volume            Free' heading '  %       Used' heading '  %      Total' heading
say

do ii = 1 to words( vols)                                                 /* split the map into drives */

   parse value SysDriveInfo( word( vols, ii)) with drive free total label .

   used     = total - free

   pcfree   = free / total * 100                                          /* per cent free space on this drive */
   pcused   = used / total * 100                                          /* per cent used space on this drive */
   sysfree  = sysfree  + free                                             /* system wide free */
   sysused  = sysused  + used                                             /* system wide used */
   systotal = systotal + total                                            /* system wide total */


   select
      when pcfree >= 80 then clrf = 'blu'
      when pcfree <= 30 then clrf = 'red'
      when pcfree <= 40 then clrf = 'ylw'
      otherwise              clrf = 'grn'
   end

   select
     when pcused <= 20 then clru = 'blu'
     when pcused >= 70 then clru = 'red'
     when pcused >= 60 then clru = 'ylw'
     otherwise              clru = 'grn'
   end

   say drive ,                                                            /* output line for each drive */
       left( label, 11) ,
       right( _commas( format( free  % units)), 18) ,                     /* free space    */
       _color( format( pcfree, 3, 0), clrf, blk) ,                        /* per cent free */
       right( _commas( format( used  % units)), 18) ,                     /* used space    */
       _color( format( pcused, 3, 0), clru, blk) ,                        /* per cent used */
       right( _commas( format( total % units)), 18)                       /* total space   */

end ii

say

   pcsysfree = sysfree / systotal * 100
   pcsysused = sysused / systotal * 100

   select
      when pcsysfree >= 80 then sysf = 'blu'                              /* Best result. */
      when pcsysfree <= 30 then sysf = 'red'                              /* Worst result. */
      when pcsysfree <= 40 then sysf = 'ylw'                              /* Third best result. */
      otherwise                 sysf = 'grn'                              /* Second best result. */
   end

   select
     when pcsysused >= 70 then sysu = 'red'                               /* Worst result. */
     when pcsysused >= 60 then sysu = 'ylw'                               /* Third best result. */
     when pcsysused <= 20 then sysu = 'blu'                               /* Best result. */
     otherwise                 sysu = 'grn'                               /* Second best result. */
   end

say '  ' ,                                                                /* spacer for drive letter */
    left( 'Totals', 11) ,
    right( _commas( format( sysfree  % units)), 18) ,                     /* Total free space */
    _color( format( pcsysfree, 3, 0), sysf) ,                             /* System per cent free */
    right( _commas( format( sysused  % units)), 18) ,                     /* Total asked-about space */
    _color( format( pcsysused, 3, 0), sysu) ,                             /* System per cent used */
    right( _commas( format( systotal % units)), 18)                       /* Total drive space asked-about */

exit 0
