
/* This program builds a structure in shared memory and starts */
/* a Rexx program which accesses the elements of this structure */

#define INCL_DOS
#include <os2.h>
#include <stdlib.h>
#include <stdio.h>
#include <rexxsaa.h>

#pragma pack(1)
struct _mystruct
  {
  ULONG  ulOne;
  UCHAR  uchTwo[35];
  SHORT  sThree;
  double dFour;
  UCHAR  uchFive[10];
  };
#pragma pack()
typedef struct _mystruct MYSTRUCT, *PMYSTRUCT;

void main(void)

{

  PMYSTRUCT pbuf;
  APIRET    rc;

  rc = DosAllocSharedMem((PPVOID)&pbuf,"\\SHAREMEM\\SOMEMEM",4096,
                         PAG_COMMIT | PAG_WRITE);
  if (rc)
    {
    printf("DosAllocSharedMem failed with rc = %ld\n",rc);
    return;
    }

  pbuf->ulOne = sizeof(MYSTRUCT);
  strcpy(pbuf->uchTwo,"Some test data from TESTS2S.C");
  pbuf->sThree = -24365;
  pbuf->dFour = 6.3e5;
  sprintf(pbuf->uchFive,"0x%08x",pbuf);

  printf("Shared memory '\\SHAREMEM\\SOMEMEM' has been set\n");
  system("start /c tests2s.cmd \\SHAREMEM\\SOMEMEM");
  system("pause");

  printf("Structure as set by tests2s.cmd:\n");
  printf("ulOne = %ld\n",pbuf->ulOne);
  printf("uchTwo = '%.*s'\n",sizeof(pbuf->uchTwo),pbuf->uchTwo);
  printf("sThree = %d\n",pbuf->sThree);
  printf("dFour = %f\n",pbuf->dFour);
  printf("uchFive = '%.*s'\n",sizeof(pbuf->uchFive),pbuf->uchFive);

  DosFreeMem(pbuf);

  return;

}
