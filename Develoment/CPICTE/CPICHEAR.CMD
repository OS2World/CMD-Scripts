/*
 *  MODULE NAME: CPICHEAR.CMD
 *
 *  COPYRIGHTS:
 *             This module contains code made available by IBM
 *             Corporation on an AS IS basis.  Any one receiving the
 *             module is considered to be licensed under IBM copyrights
 *             to use the IBM-provided source code in any way he or she
 *             deems fit, including copying it, compiling it, modifying
 *             it, and redistributing it, with or without
 *             modifications.  No license under any IBM patents or
 *             patent applications is to be implied from this copyright
 *             license.
 *
 *             A user of the module should understand that IBM cannot
 *             provide technical support for the module and will not be
 *             responsible for any consequences of use of the program.
 *
 *             Any notices, including this one, are not to be removed
 *             from the module without the prior written consent of
 *             IBM.
 *
 *  AUTHOR:    John E. Diller
 *             VNET:     JEDILLER at RALVM6           Tie Line: 444-5496
 *             Internet: jediller@ralvm6.vnet.ibm.com     (919) 254-5496
 *
 *  FUNCTION:  Receives a message sent from a remote location using the
 *             CPICTELL.CMD.  Some setup is required see CPICTELL.DOC
 *             for details.
 *
 *  RELATED FILES:
 *             See CPICTELL.DOC for detailed information.
 *
 *  PORTABILITY NOTES:
 *             See CPICTELL.DOC for detailed information.
 *
 *  REVISION LEVEL: 1.0
 *
 *  CHANGE HISTORY:
 *  Date       Description
 */

req = 256

address CPICOMM 'CMACCP conv_id retc'
if rc = 30 then do;
   'CPICREXX'
   address CPICOMM 'CMACCP conv_id retc'
   end;
if (rc <> 0 | retc <> 0) then error_exit("CMACCP");

address CPICOMM 'CMEPLN conv_id plu len retc'
if (rc <> 0 | retc <> 0) then error_exit("CMEPLN");

address CPICOMM 'CMRCV conv_id buffer req data len stat r_to_s retc'
if (rc <> 0 | (retc <> 0 & retc <> 18)) then error_exit("CMRCV");

'popup message from:' plu 'at' time() '-' buffer
exit

error_exit:
arg err_at
if (plu = 'plu' | plu = 'PLU') then plu = 'plu unknown'
'popup CPICHEAR message fails at' err_at 'rc =' rc 'retc =' retc 'from' plu
exit
