/*  Patch for DualStor v3.0 for OS/2                               */
/*                                                                 */
/*  Author: Leif Simmons                                           */
/*   email: d91-lss@sm.luth.se                                     */
/*                                                                 */
/*  This patch will allow DualStor v3.0 to run on Warp v4.0, even  */
/*  if the Novell Netware Requester is installed.                  */
/*                                                                 */
/*  Note: This patch might also work if you are experiencing       */
/*        problems with the netware requestor v2.11c5 on           */
/*        Warp v3.0                                                */

PSpec = 'DualStor v3.0 for OS/2'
FSpec = 'DUALSTRP.EXE'

Say ''
Say 'This patch will allow' PSpec ' to run on OS/2 Warp v4.0,'
Say 'even if the Novell Netware Requester is installed.'
Say ''
Say 'The patch will disable all netware support in' PSpec
Say 'However, you will still be able to backup and restore from mapped drives.'
Say ''
Say 'Disclaimer: Use this patch AT YOUR OWN RISK. No one, except yourself'
Say '            can be held accountable if something goes wrong.'
Say ''
Say 'If you disagree with the above disclaimer, press CTRL-C now...'
pause

/* Look for the EXE file... */
If ( Stream( FSpec, 'c', 'Query Exists' ) = '' ) Then Do
    Say ''
    Say 'Cannot find:' FSpec
    Say ''
    Say 'USAGE: Run DS3PATCH.CMD in the directory where' PSpec
    Say '       is installed.'
	Exit
End

/* Do a simple check to see if we can patch this EXE file */
Say 'Checking' FSpec'...'
t = CharIn(FSpec, 118129, 32)
If c2x(t) \= '30004475616C53746F7220666F72204F532F322056657273696F6E20332E3000' Then Do
    Say 'Cannot patch' Fspec
    Say c2x(t)
    Exit
End

/* Check if it's allready patched */
t = CharIn(FSpec, 72854, 7)
If c2x(t) = '44533357344E57' Then Do
    Say Fspec 'allready patched.'
	Exit
End

/* Let's do the actual patch */
Say 'Patching' PSpec'...'

/*
   This is the actual patch, it removes DualStor's ability to locate
   NWCALLS.DLL. Actually, it still tries to find the DLL, but now it's
   looking for DS3W4NW.DLL, which, of course, does not exist.

   Hence, it believes no Netware Requester is installed ;-)
*/
Call CharOut FSpec, x2c('44533357344E57'),72854

/*
  This stuff only modifies the Product Information window, so that it
  will tell that the patch has been applied...
*/
Call CharOut FSpec, x2c('20556E6F6666696369616C2070617463'),118225
Call CharOut FSpec, x2c('6820666F7200576172702076342E3020'),118241
Call CharOut FSpec, x2c('4E6F76656C6C20526571756573746572'),118257
Call CharOut FSpec, x2c('20686173206265656E206170706C6965'),118273
Call CharOut FSpec, x2c('642E00436F72702E0020004F4B000000'),118289

Say 'Patch applied to' PSpec
