/*
 *  MODULE NAME: CPICTELL.CMD
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
 *  FUNCTION:  Sends a message to a specified destination.
 *             The destination must have the CPICHEAR transaction program
 *             available to receive the message. The syntax is:
 *
 *             CPICTELL partner_LU_name message
 *
 *             where the partner_LU_name is either a defined partner LU alias
 *             or a fully qualified LU name in the network. Message is a
 *             message consisting of zero or more words.
 *
 *  RELATED FILES:
 *             See CPICTELL.DOC for detailed information.
 *
 *  PORTABILITY NOTES:
 *             XCSCST is an OS/2 Set_Conversation_Security_Type routine.
 *             Security is set to NONE, so no security needs be defined to
 *             run this sample. If security other than NONE is needed, or
 *             if this is not run on OS/2 then modifications to handle
 *             security may be need.
 *
 *             The CPICREXX.EXE should be executed on OS/2 before running
 *             this program. This program will attempt to execute the
 *             CPICREXX.EXE if it senses it has not been executed. The
 *             CPICREXX.EXE is specific to OS/2, and comes with either
 *             Extended Services or Networking Services/2.
 *
 *  REVISION LEVEL: 1.0
 *
 *  CHANGE HISTORY:
 *  Date       Description
 */


parse arg partner_LU_name msg

if pos('.',partner_LU_name) > 0 then
   parse upper var partner_LU_name partner_LU_name

/* A blank symbolic destination name is used.            */
/* There is no need to predefine CPI-C side information. */
/*                                                       */
/* CPI-C routines used:                                  */
/*  CMINIT - Initialize_Conversation                     */
/*  CMSPLN - Set_Partner_LU_name                         */
/*  CMSMN  - Set_Mode_Name                               */
/*  CMSTPN - Set_TP_Name                                 */
/*  XCSCST - Set_Conversation_Security_Type  (OS/2)      */
/*  CMALLC - Allocate                                    */
/*  CMSST  - Set_Send_Type                               */
/*  CMSEND - Send_Data                                   */

symdestname = '        '

partner_LU_name = substr(partner_LU_name,1,17)
partner_LU_name_length = length(partner_LU_name)

mode_name = '#INTER'
mode_name_length = length(mode_name)

TP_name = 'CPICHEAR'
TP_name_length = length(TP_name)

address CPICOMM 'CMINIT conv_id symdestname retc'
if rc = 30 then do;
   say "attempting to execute CPICREXX to initialize environment"
   'CPICREXX.EXE'
   address CPICOMM 'CMINIT conv_id symdestname retc'
   if rc = 30 then do;
      say "not successful"
      exit
      end;
   end;
if (rc <> 0 | retc <> 0) then error_exit("CMINIT - Initialize_Conversation");

address CPICOMM 'CMSPLN conv_id partner_LU_name partner_LU_name_length retc'
if (rc <> 0 | retc <> 0) then error_exit("CMSPLN - Set_Partner_LU_name");

address CPICOMM 'CMSMN conv_id mode_name mode_name_length retc'
if (rc <> 0 | retc <> 0) then error_exit("CMSMN - Set_Mode_Name");

address CPICOMM 'CMSTPN conv_id TP_name TP_name_length retc'
if (rc <> 0 | retc <> 0) then error_exit("CMSTPN - Set_TP_Name")

conv_security_type = 0  /* Security is XC_SECURITY_NONE */
address CPICOMM 'XCSCST conv_id conv_security_type retc'
if (rc <> 0 | retc <> 0) then error_exit("XCSCST - Set_Conversation_Security");

address CPICOMM 'CMALLC conv_id retc'
if (rc <> 0 | retc <> 0) then error_exit("CMALLC - Allocate");

sendtype = 4 /* Send type is CM_SEND_AND_DEALLOCATE */
address CPICOMM 'CMSST conv_id sendtype retc'
if (rc <> 0 | retc <> 0) then error_exit("CMSST - Set_Send_Type");

len = length(msg)
address CPICOMM 'CMSEND conv_id msg len r_to_s_rcvd retc'
if (rc <> 0 | retc <> 0) then error_exit("CMSEND - Send_Data");

exit

error_exit:
arg error_message

say error_message
if (rc <> 0) then say "CPICOMM return code is" rc
if (retc <> 0) then say "verb return code is" retc

exit
