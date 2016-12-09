/**** REXX Prog to Get Program Settings  GET_SET1.CMD ****/

/**********************************************
W. Robert S. Webber
(C) Squarey Software Dec 1993
e-mail internet bwebber@welchlink.welch.jhu.edu
e-mail CompuServe 70154,546
**********************************************/

/****
GET_SET1 will list out the setting for all Porgrams in the USER
file OS2.INI, i.e. all PM_Abstract:Objects. There are two optional arguments
Name and Mask that can be used to restrict the output. If both arguments are
omitted, then all programs are listed.

If Name is given only programs matching Name will be listed.

Name need not be the full name, but can be fewer characters starting at
the begining of the program name.
If less than the full name is given all programs matching the reduced name
will be listed, i.e. if Name is MY, then MY_Prog and MYGAME will both be
listed but not NEW_MY_GAME. The match always starts at the begining of the word.

Names with spaces will be listed on spearate lines in the output 
and cannot be specified in full. In this case just use the first
word of the program name, or change the spaces to underscores.
Name is not the .EXE name but the name as it appears on the
Desktop under the icon. Name is case insensitive, i.e. MyProg=myprog=MYPROG.

Mask is another optional parameter that can be used to further restrict
output. Mask can be used to match the class or attribute of the object.
If given then all programs listed will match both Name and Mask.
As with Name, Mask can be shorter than the full name of the object and
is also case insensitive.

If either Name or Mask are used, then they must be at least 3 letters long.

It appears that OS2.INI only contains differences from default, so that only
those settings that are no set to their default value will be listed. As a
consequence, this program does not produce a full list of the DOS settings
for a given program.

Usage:
get_set1 Name Mask
where Name and Mask are optional and case insensitive. This will list
all programs matching Name and Mask to the screen.
If output to a file is required, then redirect to a file as:
get_set1 Name Mask >my_set.lst

Examples:
To lsit all programs to the screen:
get_set1

To list all programs to a file:
get_set1 >my_progs.lst

To list all MYGAME programs to a file:
get_set1 MYGAME >my_games.lst

To list all utils but only their shadows
get_set1 UTil wpsh >my_shad.lst

This example assumses all util program names start with util.
The irregular case will be ignored. Mask uses a short word "wpsh" for
WPShadow to select only shodow programs, again case is ignored.

If you want to work with all objects use GET_ALL1.CMD
****/

/**** Add Extra functions to REXX ****/
call RXFuncAdd 'SysLoadFuncs', 'REXXUTIL', 'SysLoadFuncs'
call SysLoadFuncs


/**** Set up preferences ****/
NewLine = "  "  /* How NL, CR are to be treated */

tab1 = "    "   /* Tab width in spaces */
tab2 = tab1 || tab1

SearchObj = "PM_Abstract:Objects"   /* Select program Objects */
MinKey = 3  /* Length of smallest Word in key to be printed */
            /* Keys smaller than this will be skipped */

/***** Range of chars to be change to space.
i.e. all non ASCII chars *****/
SpaceMask = xrange( '00'x, '09'x ) || xrange( '0B'x, '1F'x ) ||,
    xrange( '7F'x, 'FF'x )


parse arg Look Mask         /* Get input form command line */

Look = strip( Look )        /* Remove any extra lead/trail spaces */
Look = translate( Look )    /* Set to all Upper case */
LookLen = length( Look )

Mask = strip( Mask )
Mask = translate( Mask )
MaskLen = length( Mask )

/**** Log what we are doing ****/
say "Input: Name=" Look LookLen "Mask=" Mask MaskLen
say "Search Class " SearchObj "Smallest Key Word= " MinKey

/**** Get list of all program object keys ****/
call SysIni 'USER', SearchObj, 'All:', 'Keys.'

if (Result \= 'ERROR:') then do

     say SearchObj "Has " Keys.0 "Keys"
     SkipKey = 0

     do j = 1 to Keys.0
         val = SysIni( 'USER', SearchObj, Keys.j )

/**** Need to get rid of all non printing characters by changing then to space.
Replaced NL, CR with something. These are treated separately first
so that Nl & CR can be made to show up with a special char pair if need be
****/
         val2 = translate( val, NewLine, '0A'x || '0D'x, ' ' )


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
            say
            say substr( Keys.j, 1 ,30)  j "has " Nwval "words Len=" length(val)
            
            ShortCnt = 0

            do k = 1 to Nwval
                val2 = word( val, k )

/**** Skip short words ****/
                if ( length( val2 ) > ( MinKey - 1 ) ) then
                    say tab1 word( val, k )
                else ShortCnt = ShortCnt + 1
                
                end /* do k */
            say tab2 "Note: " ShortCnt "Words less than " MinKey "Skipped"
            end /* if FoundProg */

         else SkipKey = SkipKey + 1
 
         end /* do j */
    say
    say "-----------------------------"
    say Keys.0 - SkipKey "Porgrams Listed" SkipKey "Object Keys Skipped"

    end /* if Result */

else do
    say "Error Reading " SearchObj Look Mask
    end
