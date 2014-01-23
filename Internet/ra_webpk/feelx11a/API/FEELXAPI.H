#ifndef _FEELXAPI_H_
#define _FEELXAPI_H_

#include <os2.h>

/******************************************************************************
Usage: #define INTERNAL inline
or whatever inlining means to have it inlined
do not define INTERNAL to create an obj or a DLL
******************************************************************************/

#ifdef INTERNAL
  #define FXLINKAGE
#endif

#if defined(__IBMC__) || defined (__IBMCPP__)
 #ifndef FXLINKAGE
   #define FXLINKAGE _System
 #endif
   #define FX2LINKAGE _System
#endif

#if defined (__BORLANDC__)||defined (__BORLANDCPP__)
 #ifndef FXLINKAGE
  #define FXLINKAGE _system
 #endif
 #define FX2LINKAGE _system
#endif

#if defined (__GCC__)
 #ifndef FXLINKAGE
  #define FXLINKAGE
 #endif
 #define FX2LINKAGE
#endif


/* The following is the FeelX settings structure */
/* Don't refer directly to this structure */
typedef struct _FEELXPARAMETERS {
  BOOL                   feelx;                /* Sliding focus               */
  BOOL                   activateAll;          /* activate all Controls       */
  BOOL                   mark;                 /* quick marking in shells     */
  BOOL                   hotkey;
  int                    wndFront;             /* Windows->front w Shift...   */
                                               /* need WND_*                  */
  BOOL                   staticWinlist;        /* static windowlist           */
  BOOL                   hide;                 /* hide mouse pointer          */
  ULONG                  hideTimeout;          /* and its timeout-value       */
  BOOL                   folders;              /* push folders into front     */
  BOOL                   fsHotkey;
  BOOL                   stripCrLf;            /* strip CR/LF on marking      */
  BOOL                   staticMenus;          /* "static" menus              */
  BOOL                   mini;                 /* show Minnie on start-up     */

  int                    markButton;           /* mark button 1-3             */
  ULONG                  markFlags;            /* mark Flags, uses KC_*       */
  ULONG                  markAltFlags;         /* alternate mark Flags KC_*   */

  int                    pasteButton;          /* pasteButton 1-3, uses KC_*  */
  BOOL                   pasteDbClick;         /* paste w/double-click?       */
  ULONG                  pasteFlags;           /* flags, uses KC_*            */
  ULONG                  unused3;
  ULONG                  pasteAltFlags;        /* and alternative paste flags */
} FEELXPARAMETERS;

extern FEELXPARAMETERS FeelXSettings;

#define WND_FRONT_ALWAYS        1      /* Always pop up windows */
#define WND_FRONT_SHIFT         2      /* only with shift       */
#define WND_FRONT_NEVER         3      /* no, never             */


#ifdef _cplusplus
extern "C" {
#endif

/* This is in FeelXdll.dll */
BOOL            FX2LINKAGE       FxIsFeelXRunning();
char           *FX2LINKAGE       FxQueryFeelXPath();
HWND            FX2LINKAGE       FxQueryWndProc();
HWND            FX2LINKAGE       FxQueryPID();
BOOL            FX2LINKAGE       FxSaveSettings();
BOOL            FX2LINKAGE       FxLoadSettings();
BOOL            FX2LINKAGE       FxDefaultSettings(FEELXPARAMETERS *);
BOOL            FX2LINKAGE       FxJournalRecord();
BOOL            FX2LINKAGE       FxReleaseJournalRecord();
struct PlaybackMessages;                /* internal!!! */
BOOL            FX2LINKAGE       FxPlayback(struct PlaybackMessages *);
BOOL            FX2LINKAGE       FxAddFront(HWND h);
BOOL            FX2LINKAGE       FxQueryFront(HWND h);
BOOL            FX2LINKAGE       FxDeleteFront(HWND h);
BOOL            FX2LINKAGE       FxAddAltCutPaste(HWND h);
BOOL            FX2LINKAGE       FxQueryAltCutPaste(HWND h);
BOOL            FX2LINKAGE       FxDeleteAltCutPaste(HWND h);
BOOL            FX2LINKAGE       FxExecObject(char *);
BOOL            FX2LINKAGE       FxAssignHotkey(HWND h, char *);
BOOL            FX2LINKAGE       FxSetHotkey(ULONG h);
BOOL            FX2LINKAGE       FxQueryHotkey();
BOOL            FX2LINKAGE       FxDeleteHotkey(char *s);
BOOL            FX2LINKAGE       FxDeleteAllHotkeys();

/* This is in FeelXapi.h */
BOOL            FXLINKAGE       FxQueryFeelXStatus();
BOOL            FXLINKAGE       FxQueryActivateAll();
BOOL            FXLINKAGE       FxQueryMark();
int             FXLINKAGE       FxQueryWndFront();
ULONG           FXLINKAGE       FxQueryHide();
ULONG           FXLINKAGE       FxQueryHideTimeOut();
BOOL            FXLINKAGE       FxQueryFolders();
BOOL            FXLINKAGE       FxQueryStaticMenus();
BOOL            FXLINKAGE       FxQueryWinlist();
BOOL            FXLINKAGE       FxQueryMini();
int             FXLINKAGE       FxQueryMarkButton();
ULONG           FXLINKAGE       FxQueryMarkFlags();
ULONG           FXLINKAGE       FxQueryMarkAltFlags();
int             FXLINKAGE       FxQueryPasteButton();
BOOL            FXLINKAGE       FxQueryPasteDBClick();
ULONG           FXLINKAGE       FxQueryPasteFlags();
ULONG           FXLINKAGE       FxQueryPasteCtrlLFFlags();
ULONG           FXLINKAGE       FxQueryPasteAltFlags();
ULONG           FXLINKAGE       FxQueryStripCrLf();
ULONG           FXLINKAGE       FxQueryFullscreenHotkeys();

BOOL            FXLINKAGE       FxSetFeelXStatus(BOOL);
BOOL            FXLINKAGE       FxSetActivateAll(BOOL);
BOOL            FXLINKAGE       FxSetMark(BOOL);
BOOL            FXLINKAGE       FxSetWndFront(int);
BOOL            FXLINKAGE       FxSetHide(ULONG x);
BOOL            FXLINKAGE       FxSetHideTimeOut(ULONG);
BOOL            FXLINKAGE       FxSetFolders(BOOL);
BOOL            FXLINKAGE       FxSetStaticMenus(BOOL);
BOOL            FXLINKAGE       FxSetWinlist(BOOL);
BOOL            FXLINKAGE       FxSetMini(BOOL);
BOOL            FXLINKAGE       FxSetMarkButton(int);
BOOL            FXLINKAGE       FxSetMarkFlags(ULONG);
BOOL            FXLINKAGE       FxSetMarkAltFlags(ULONG);
BOOL            FXLINKAGE       FxSetPasteButton(int);
BOOL            FXLINKAGE       FxSetPasteDBClick(BOOL);
BOOL            FXLINKAGE       FxSetPasteFlags(ULONG);
BOOL            FXLINKAGE       FxSetPasteCtrlLFFlags(ULONG);
BOOL            FXLINKAGE       FxSetPasteAltFlags(ULONG);
BOOL            FXLINKAGE       FxSetStripCrLf(BOOL x);
BOOL            FXLINKAGE       FxSetFullscreenHotkeys(BOOL x);

#ifdef _cplusplus
}
#endif

#ifdef INTERNAL
  #include "fxapi.h"
#endif

#endif
