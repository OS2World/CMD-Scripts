/*****************************************************************************
 *
 *  MODULE NAME : CPICHEAR.C
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
 *  FUNCTION:  Issues a call to invoke the CPICHEAR.CMD. It is assumed
 *             CPICHEAR.CMD will be in the system PATH. See CPICTELL.DOC for
 *             details.
 *
 *  RELATED FILES:
 *             See CPICTELL.DOC for detailed information.
 *
 *  PORTABILITY NOTES:
 *             None known.
 *
 *  REVISION LEVEL: 1.0
 *
 *  CHANGE HISTORY:
 *  Date       Description
 *****************************************************************************/

#include <stdlib.h>

void main(void)
{ system("CPICHEAR.CMD"); }
