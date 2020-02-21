/*****************************************************************************
 *
 *  MODULE NAME : POPUP.C
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
 *  FUNCTION:  Displays the text of any arguments on an OS/2 full screen.
 *             Until the ENTER key at the workstation is hit. Written to be
 *             part of the CPICTELL package. The CPICHEAR.CMD calls this
 *             routine.
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

#define INCL_BASE
#include <os2.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define VIO_HANDLE 0

void main(int argc, char * argv[])
{
    USHORT wait = 1;
    int i, dos_rc;
    UCHAR buffer[512];

    strcpy(buffer, "");
    for (i = 1; i < argc; i++) {
        strcat(buffer, argv[i]);
        strcat(buffer, " ");
    }

    dos_rc = VioPopUp((PUSHORT)&wait,VIO_HANDLE);
    if (dos_rc == 0) {
        printf("%s\n\n Press enter to end\n", buffer);
        gets(buffer);
        VioEndPopUp(VIO_HANDLE);
    }
}
