/* This is a small example how to call a FeelX function from your applet     */
/* See feelxapi.h for prototypes. Its very easy. Use only the wrapper        */
/* functions.                                                                */
/* This program can be used to turn off the Sliding focus status (e.g. to    */
/* programs that don't like FeelX.                                           */

#define INCL_PM
#define INCL_DOS
#include <os2.h>                        /* include os2.h first               */

/* The functions to change FeelX are very small and easy. They can be well   */
/* inlined by the compiler. If you want to inline the functions #define      */
/* INTERNAL to _Inline or inline whatever the compiler and language supplies */
/* If you do not want to inline the create a dummy c file which includes     */
/* fxapi.h. Define INTERNAL to nothing and compile this file to an .obj      */
/* All other modules do not define INTERNAL at all and include feelxapi.h    */
/* Link them together.                                                       */

/* Example: icc setx.c feelxdll.lib                                          */
/* Note that you must link with feelxdll.lib and your program does not run   */
/* without feelxdll.dll. If you do not want to link statically to a DLL      */
/* you must first create a .obj (see above) and create a DLL supporting all  */
/* functions you need. Refer dynamically to this DLL at runtime              */

#define INTERNAL _Inline                /* icc: we want to inline            */
#include "feelxapi.h"                   /* now include feelxapi.h            */

#include <string.h>
#include <stdio.h>

int main(int argc, char *argv[])
  {
  if (argc!=2)
     {
     printf("Usage: %s [on|off|toggle|?].\n");
     printf("       Toggle FeelX on or off.\n", argv[0]);
     }
  else
     {
     if (!FxIsFeelXRunning())                   /* FeelX API function */
        printf("Warning! FeelX is not running!");
     if (!stricmp(argv[1], "on"))
        FxSetFeelXStatus(TRUE);                 /* set status         */
     else if (!stricmp(argv[1], "off"))
        FxSetFeelXStatus(FALSE);
     else if (!stricmp(argv[1], "toggle"))
        FxSetFeelXStatus(!FxQueryFeelXStatus());
     else
        printf("current Status of FeelX is: %s",
           FxQueryFeelXStatus() ? "on":"off");
     }
  return (int)FxQueryFeelXStatus();
  }
