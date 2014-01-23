/******************************************************************************

 FeelX.go is the main definition file of FeelX. We use some definitions
 from toolbox.inc - therefore we include this file first:

*******************************************************************************/

 ^toolbox.inc

/******************************************************************************

 You may define Menus, actions etc. for any entry point. The following
 entry points may currently be used: (Those that defined by this
 default configuration are marked with an asterisk)

   Startup   -  execute object on startup
 * FeelX     -  2nd (right) mouse button on a titlebar
 * Shell     -  2nd (right) mouse button on a shell
   Shell3    -  3rd (middle) mouse button on a shell
 * Hotkeys   -  Hotkeys
   MenuLL    -  lower left menu
   MenuUL    -  upper left menu
   MenuLR    -  lower right menu
   MenuUR    -  upper right menu
   B1Desktop -  double-click (left button) on the desktop
   B3Desktop -  single-click (middle button) on the desktop

*******************************************************************************/

/* It is recommended to have an Actionbar visible on startup when no WPS */
/* is used. Therefore first an actionbar is created. That it is made     */
/* visible by the hideactionbar command. This might be contra-intuitive. */
/* Imagine that the actionbar is invisible on startup and you click on   */
/* a hideactionbar item to make it visible. At last a shell is created.  */
/* This is necessary on my system. maybe it's not on yours.              */

Startup := chain [ items=Default_Actionbar
                   items=hideactionbar
                   items=program [ type=os2win ]
                 ]

/* The FeelX menu: (defined in toolbox.inc)                          */
FeelX:= Default_FeelX

/* The shell menu: (defined in toolbox.inc)                          */
/* To disable this menu delete the following line                    */
Shell:= Default_Shell.

/* Hotkeys: Per default only PgUp, PgDn (in toolbox.inc) defined:    */
Hotkeys:=Default_Hotkeys


/* Uncomment the following line to have the user documentation in    */
/* the lower left corner                                             */

/* MenuLL:= User_Documentation */

/* Uncomment the following line to have the window list in the lower */
/* right corner                                                      */
/* MenuLR:= winlist */

/* The extended Desktop menu is similar to the actionbar             */
/* (not everyone likes actionbars). If you have a 3-button mouse     */
/* I would recommend to comment out the B1Desktop-line out           */
B3Desktop:=B1Desktop                    /* same as B1Desktop!        */
B1Desktop:=Default_Desktop

// PmShell := program [ entry="Workplace Shell", name="pmshell.exe", child=false ]

/* You can simply extend other objects by redefining/extending them  */
/*
** Tools := item= program[ entry="Tool~1", name="tool1.exe", window=minimized ]
**          item= program[ entry="Tool~2", name="tool2.exe"]
*/

