/**** REXX Prog to Get ALL User Settings  GET_ALL1.CMD ****/

/**********************************************
W. Robert S. Webber
(C) Squarey Software Dec 1993
e-mail internet bwebber@welchlink.welch.jhu.edu
e-mail CompuServe 70154,546
**********************************************/

/****
Data concepts:
An .INI file is a list of APPs ( also = sections )
    An APP has an APP_NAME and is a list of KEYs
        A KEY has a KEY_NAME and is a string of bytes, ends with 0.
            (This program processes a KEY into a list or WORDs by
                replacing non printing chars with space. Multi space
                is then replaced with single space)
        A KEY has a KEY_NAME and is an array of WORDs.
            
GET_ALL1 will list out all items in the USER file OS2.INI.
There are two optional arguments Name and Mask that can be
used to restrict the output. If both arguments are omitted, then all
items are listed.

If Name is given only items containing WORDs that match Name will be listed.

APP ( sections ) names are still listed even if none of the KEYs contain
any WORDs that match Name. In this case the number of KEYs skipped is shown

Name need not be the full name, but can be fewer characters starting at
the begining of the item name.
If less than the full name is given all items matching the reduced name
will be listed, i.e. if Name is MY, then MY_Prog and MYGAME will both be
listed but not NEW_MY_GAME. The match always starts at the begining of the word.

Names with spaces will be listed on spearate lines in the output 
and cannot be specified in full. In this case just use the first
word of the item name, or change the spaces to underscores.
Name is not the .EXE name but the name as it appears on the
Desktop under the icon. Name is case insensitive, i.e. MyProg=myprog=MYPROG.

Mask is another optional parameter that can be used to further restrict
output. If Mask is given only items containing WORDs that match
Mask will be listed.

Mask can be used to match the class or attribute of the object.
If given then all items listed will contain WORDs matching both Name and Mask.
As with Name, Mask can be shorter than the full name of the object and
is also case insensitive.

If either Name or Mask are used, then they must be at least 3 letters long.

For DOS Session Settings:
It appears that OS2.INI only contains differences from default, so that only
those settings that are no set to their default value will be listed. As a
consequence, this program does not produce a full list of the DOS settings
for a given program.

Usage:
get_all1 Name Mask
where Name and Mask are optional and case insensitive. This will list
all items matching Name and Mask to the screen.
If output to a file is required, then redirect to a file as:
get_all1 Name Mask >my_set.lst

Examples:
To lsit all items to the screen:
get_all1

To list all iems to a file:
get_all1 >my_progs.lst

To list all MYGAME items to a file:
get_all1 MYGAME >my_games.lst

To list all utils but only their shadows
get_all1 UTil wpsh >my_shad.lst

This example assumses all util item names start with util.
The irregular case will be ignored. Mask uses a short word "wpsh" for
WPShadow to select only shodow programs, again case is ignored.

If you just want to work with program objects e.g. DOS Sessions
use GET_SET1.CMD
****/

/**** Add Extra functions to REXX ****/
call RXFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
call SysLoadFuncs

parse arg Look Mask

Look = strip( Look )        /* Remove any extra lead/trail spaces */
Look = translate( Look )    /* Force all to UPPER case */
LookLen = length( Look )

Mask = strip( Mask )
Mask = translate( Mask )
MaskLen = length( Mask )

MinKey = 3  /* Length of smallest Word in key to be printed */
FieldWidth = 25 /* Max name Field width */

say "Input: Name Size    " Look LookLen Mask MaskLen
say "Smallest Key Word = " MinKey
say "Name Field width  = " FieldWidth

tab1 = "   "   /* Space out for Key Lines */
tab2 = tab1 || tab1
tab3 = tab2 || tab1

/***** Range of chars to be change to space.
i.e. all non ASCII chars *****/
SpaceMask = xrange( '00'x, '09'x ) || xrange( '0B'x, '1F'x ) ||,
    xrange( '7F'x, 'FF'x )

say "## Scanning OS2.INI "
call SysIni 'USER', 'All:', 'Apps.'
if Result \= 'ERROR:' then do

    say "USER OS2.INI has " Apps.0 "Sections"
        /**** Apps is an array of APP_NAMEs ****/

/*** Scan Sections ****/
    do ii = 1 to Apps.0
    
        call SysIni 'USER', Apps.ii, 'All:', 'Keys.'
            /**** Keys is an array of KEY_NAMEs ****/

        if Result \= 'ERROR:' then do
            say
            say substr( Apps.ii, 1, FieldWidth ) "== " Keys.0 "Keys"

/**** Scan Keys in sections ****/
            SkipKey = 0
            do j = 1 to Keys.0
                val = SysIni( 'USER', Apps.ii, Keys.j )
                    /*** val is a KEY_FIELD ***/

/**** Replaced NL, CR with something ****/
/*                 val2 = translate( val, "~~", '0A'x || '0D'x, ' ' ) */
                val2 = translate( val, "  ", '0A'x || '0D'x, ' ' )


/**** Set non ACSII to space ****/
                val = translate( val2, ' ', SpaceMask, ' ' )

                val2 = space( val ) /* remove all extra space */
                val = val2

                Nwval = words( val )   /* Get number of words now in Key */

/**** See if any of the words in the current key match
what we are looking. Default is to print all if no string given, or
too short ****/
                if LookLen > 2 then do
                    FoundProg = "NO"
                    do k = 1 to Nwval
                        val3 = word( val, k )
                        if translate( left( val3, LookLen ) ) = Look then,
                            FoundProg = "YES"
                        end /* do k */

                    end /* if LookLen */

                else FoundProg = "YES"

                if ( MaskLen > 2 ) & ( FoundProg = "YES" ) then do
                    FoundProg = "NO"
                    do k = 1 to Nwval
                        val3 = word( val, k )
                        if translate( left( val3, MaskLen ) ) = Mask then,
                            FoundProg = "YES"
                        end  /* do k */
                    end /* if MaskLen */

                if FoundProg = "YES" then do
                    /* say */
                    say tab1 substr( Keys.j, 1, FieldWidth ),
                        Nwval "words Len" length(val)
                    
                    ShortCnt = 0

                    do k = 1 to Nwval
                        val2 = word( val, k )

/**** Skip short words ****/
                        if ( length( val2 ) > ( MinKey - 1 ) ) then
                            say tab2 word( val, k )
                        else ShortCnt = ShortCnt + 1

                        end /* do k */

                    if  ShortCnt > 0 then
                        say tab3 "Note: " ShortCnt "Words < " MinKey "Skipped"

                    end /* if FoundProg */

                else SkipKey = SkipKey + 1
        
                end /* do j */

            if SkipKey > 0 then
                say tab1 "Section " Apps.ii SkipKey "Keys Skipped"

            end /* if Result */

        else do
            say "SysIni " Result Apps.ii
            end  /* do */

        end /* do ii */

    end /* if Result */

else do
    say "SysIni " Result
    end
