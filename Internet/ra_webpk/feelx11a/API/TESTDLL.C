/******************************************************************************
*                                                                             *
* This DLL is a sample for integrating a DLL seamlessly into FeelX.           *
* You may use this DLL as a "template". It is very to write a DLL for FeelX.  *
* Follow the general "rules" to create a DLL and supply one or more of the    *
* functions below. (example: icc -Ge- testdll.c testdll.def)                  *
*                                                                             *
* "Register" the DLL for FeelX by adding a DLL object in the FeelX.go file.   *
*                                                                             *
*******************************************************************************/

#define INCL_PM
#include <os2.h>
#include <stdio.h>
#include <string.h>

/* All functions *must* have _System linkage (or whatever your Compiler calls */
/* it. The functions must be exported (either by _Export or by a .DEF file)   */
/* If your are programming C++ extern "C" linkage is recommended.             */
/* Don't waste stack space! Note that test is called synchron per default.    */

/* The following function is only supplied to make usage of menus easier      */
/* "Internal" functions can have default linkage of course                    */

static MRESULT setMenuAttrib(HWND menu, USHORT id, USHORT attrib, BOOL set)
  {
  return WinSendMsg(menu, MM_SETITEMATTR, MPFROM2SHORT(id, TRUE),
                          MPFROM2SHORT(attrib, set ? attrib : ~attrib));
  }

/* The following function (take any name) is intended to be called by FeelX   */
/* whenever the menu is displayed. A small buffer (40 bytes) is taken as a    */
/* parameter. Fill in this buffer with any entry text you like                */
/* register with attribute: entryfun=showEntry                                */
/* If you do not supply this function the default as specified in the entry   */
/* attribute is taken.                                                        */
/* This function is called synchron.                                          */

void _System _Export showEntry(char *buffer)
  {
  strcpy(buffer, "my text");
  }


/* The following function is also called whenever a menu is displayed.        */
/* You can check or disable the menu entry.                                   */
/* register with attribute: menufun=showToggle                                */
/* If you do not supply this function the menuitem is displayed in a normal   */
/* way.                                                                       */
/* This function is called synchron.                                          */

void _System _Export showToggle(HWND menu, int id)
  {
  setMenuAttrib(menu, (USHORT)id, MIA_CHECKED, TRUE);
  }

/* The following function is intended to be called whenever the user clicks   */
/* on the specified item. It receives the following parameters:               */
/*   x        : The x position of the action (mouse pointer)                  */
/*   y        : The y position of the action (mouse pointer)                  */
/*   hwnd     : The window handle of an action                                */
/*   frame    : The frame window of hwnd (you can also calculate it yourself) */
/*   argc     : No. of attributes specified in feelx.go                       */
/*   args[i]  : The name of the i. attribute (including dll, menuentry, ...)  */
/*   vals[i]  : The value of the i. attribute                                 */
/* Like main the following assuption is correct: args[argc]==0==vals[i]       */
/*                                                                            */
/* register with attribute: fun=test                                          */
/* It does not make sense not to supply a function like this one.             */
/* This function is called synchron per default                               */
/* It is called asynchron if the attribute thread is supplied with true       */

void _System _Export test(int x, int y, HWND hwnd, HWND frame,
          int argc, char *args[], char *vals[])
  {
  int i;

  /* printf senseless. Just a test ...*/

  printf("--- TESTDLL call ---------------------------------\n\n");
  printf("Info:\n");
  printf("     x: %i\n", x);
  printf("     y: %i\n", y);
  printf("window: %x\n", hwnd);
  printf(" frame: %x\n", frame);
  printf(" parms: %i\n\n", argc);

  printf("Parameters:\n");
  for (i=0; i<argc; i++)
     printf("%20s: %s\n", args[i], vals[i]);

  printf("\n--------------------------------------------------\n\n");
  }
