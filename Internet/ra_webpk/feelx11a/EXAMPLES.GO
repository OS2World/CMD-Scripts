/* Assume that you do not paste with the middle (3rd mouse button)            */
/* Use the following statement to paste with the middle mouse button with CR  */

Shell3:= keyin [ string="%c\n" ]


/* The following statement implements a popup-menu-windowlist on              */
/* Ctrl-Shift-Esc. (Use behind an other Hotkeys definition)                   */

Hotkeys:= Hotkeys [ esc=mwinlist [] ]


/* The following example shows how to integrate a textmode program into FeelX */
/* Please make sure that the program is in the path or type in the fully      */
/* qualified path name at the name-attribute                                  */

program [
    entry="Whereis"                   /* If this appears in the menu then show*/
                                      /* the string Whereis                   */
    name="wo.exe"                     /* the name (or c:\tools\...)           */
    parameters="c-:[Which file]"      /* Ask for "Which file" and substitute  */
                                      /* [...] with the answer                */
    window=pm                         /* redirect output to a small viewer    */
    title="wo"                        /* This is the program title            */
    ] /* end of program */

/* You can simply get help about a specific topic with the following fragment */
/* Mark WinCreateWindow in your text and execute the following instruction    */

Help:= program [
          entry="Help!!"                        /* the menu entry             */
          name="view.exe"                       /* the help viewer of OS/2    */
          parameters="PMFUN.INF+PMWIN.INF &"    /* the references and         */
       ] /* end of program */                   /* & (=Clipboard)             */


/* You want to have the real windowlist to appear when the mouse is in the    */
/* lower right corner?                                                        */

MenuLR:=winlist
