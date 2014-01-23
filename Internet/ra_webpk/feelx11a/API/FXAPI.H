#ifdef __cplusplus
extern "C" {
#endif

INTERNAL BOOL            FXLINKAGE       FxQueryFeelXStatus()
  {
  return FeelXSettings.feelx;
  }

INTERNAL BOOL            FXLINKAGE       FxQueryActivateAll()
  {
  return FeelXSettings.activateAll;
  }

INTERNAL BOOL            FXLINKAGE       FxQueryMark()
  {
  return FeelXSettings.mark;
  }

INTERNAL int             FXLINKAGE       FxQueryWndFront()
  {
  return FeelXSettings.wndFront;
  }

INTERNAL ULONG           FXLINKAGE       FxQueryHide()
  {
  return FeelXSettings.hide;
  }

INTERNAL ULONG           FXLINKAGE       FxQueryHideTimeOut()
  {
  ULONG t;
//return ((t=FeelXSettings.hideTimeout)==(ULONG)-1) ? 0: t;
  return FeelXSettings.hideTimeout;
  }

INTERNAL BOOL            FXLINKAGE       FxQueryFolders()
  {
  return FeelXSettings.folders;
  }

INTERNAL BOOL            FXLINKAGE       FxQueryStaticMenus()
  {
  return FeelXSettings.staticMenus;
  }

INTERNAL BOOL            FXLINKAGE       FxQueryWinlist()
  {
  return FeelXSettings.staticWinlist;
  }

INTERNAL BOOL            FXLINKAGE       FxQueryMini()
  {
  return FeelXSettings.mini;
  }

INTERNAL int             FXLINKAGE       FxQueryMarkButton()
  {
  return FeelXSettings.markButton;
  }

INTERNAL ULONG           FXLINKAGE       FxQueryMarkFlags()
  {
  return FeelXSettings.markFlags;
  }

INTERNAL ULONG           FXLINKAGE       FxQueryMarkAltFlags()
  {
  return FeelXSettings.markAltFlags;
  }

INTERNAL int             FXLINKAGE       FxQueryPasteButton()
  {
  return FeelXSettings.pasteButton;
  }

INTERNAL BOOL            FXLINKAGE       FxQueryPasteDBClick()
  {
  return FeelXSettings.pasteDbClick;
  }

INTERNAL ULONG           FXLINKAGE       FxQueryPasteFlags()
  {
  return FeelXSettings.pasteFlags;
  }

INTERNAL ULONG           FXLINKAGE       FxQueryPasteAltFlags()
  {
  return FeelXSettings.pasteAltFlags;
  }

INTERNAL ULONG           FXLINKAGE       FxQueryStripCrLf()
  {
  return FeelXSettings.stripCrLf;
  }

INTERNAL ULONG           FXLINKAGE       FxQueryFullscreenHotkeys()
  {
  return FeelXSettings.fsHotkey;
  }

INTERNAL BOOL            FXLINKAGE       FxSetFeelXStatus(BOOL x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.feelx=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetActivateAll(BOOL x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.activateAll=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetMark(BOOL x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.mark=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetWndFront(int x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.wndFront=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetHide(ULONG x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.hide=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetHideTimeOut(ULONG x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
//FeelXSettings.hideTimeout= x==0 ? (ULONG)-1 : x;
  FeelXSettings.hideTimeout=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetFolders(BOOL x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.folders=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetStaticMenus(BOOL x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.staticMenus=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetWinlist(BOOL x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.staticWinlist=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetMini(BOOL x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.mini=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetMarkButton(int x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.markButton=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetMarkFlags(ULONG x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.markFlags=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetMarkAltFlags(ULONG x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.markAltFlags=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetPasteButton(int x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.pasteButton=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetPasteDBClick(BOOL x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.pasteDbClick=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetPasteFlags(ULONG x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.pasteFlags=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetPasteAltFlags(ULONG x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.pasteAltFlags=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetStripCrLf(BOOL x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.stripCrLf=x;
  return TRUE;
  }

INTERNAL BOOL            FXLINKAGE       FxSetFullscreenHotkeys(BOOL x)
  {
  if (!FxIsFeelXRunning())
     return FALSE;
  FeelXSettings.fsHotkey=x;
  return TRUE;
  }

#ifdef __cplusplus
}
#endif
