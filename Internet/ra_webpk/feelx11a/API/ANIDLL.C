/* This is a "real" example of how to integrate a DLL into FeelX             */
/* Assume you want to turn animation of folders on/off (maybe because the    */
/* system reacts faster when animation is off)                               */
/* This DLL offers a menu item for FeelX which is checked when animation is  */
/* on and uncheck if animation is off. By chosing the menu item you can      */
/* toggle the status of the animation.                                       */
/* The file testdll.c was used as a template                                 */
/* See documentation for more information                                    */
/* Compile with e.g. icc -Ge- anidll.c anidll.def                            */
/* To use other compilers rename _System to the system linkage (if not def.) */
/* To integrate into FeelX first define a special Animation object. e.g.     */
/* Animation:= dll [ entry="Animation"      (* this appears in the menu *)   */
/*                   fun="animation"        (* the name of the function *)   */
/*                   dll="anidll"           (* the dll name             *)   */
/*                   menufun="showToggle"   (* the name of the function *)   */
/*             ] (* end of dll *)                                            */
/* Now you can use Animation wherever you want. E.g. toggle Animation with   */
/* Ctrl-Shift-A:                                                             */
/* Hotkeys:=hotkeys [ (* ... other hotkeys here *)                           */
/*                    a=Animation       (* our hotkey *)                     */
/*          ] (* end of hotkeys *)                                           */
/* Now look at the source code. It's really easy to integrate a DLL into     */
/* FeelX, isn't it?                                                          */

#define INCL_PM
#include <os2.h>

/* Taken from testdll.c                                                      */
static MRESULT setMenuAttrib(HWND menu, USHORT id, USHORT attrib, BOOL set)
  {
  return WinSendMsg(menu, MM_SETITEMATTR, MPFROM2SHORT(id, TRUE),
                          MPFROM2SHORT(attrib, set ? attrib : ~attrib));
  }

/* This is to query the current animation status                             */
static BOOL queryAnimation()
  {
  return (BOOL)WinQuerySysValue(HWND_DESKTOP, SV_ANIMATION);
  }

/* .. and set the animation status                                           */
static void setAnimation(BOOL b)
  {
  WinSetSysValue(HWND_DESKTOP, SV_ANIMATION, b);
  }

/* toggle menuitem if animation is on. Don't use static data. Always query   */
/* the actual value. This function may be called at any time                 */
void _System showToggle(HWND menu, int id)
  {
  setMenuAttrib(menu, (USHORT)id, MIA_CHECKED, queryAnimation());
  }

/* This function is called, when the user selects animation                  */
/* Don't use static data here either. Always query the most actual value.    */
void _System animation(int x, int y, HWND hwnd, HWND frame,
          int argc, char *args[], char *vals[])
  {
  /* lots of parameters... all unused. */
  setAnimation(!queryAnimation());
  }
