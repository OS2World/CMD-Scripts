/*******************************************************************************

This file defines:

   Default_FeelX
   Default_Shell
   Default_Actionbar

   Window


*******************************************************************************/

Default_FeelX:= menu [
            entry="Standard FeelX menu"  // not necessary in a toplevel menu
            item=feelx [ entry="FeelX"   // Selecting FeelX turns on/off
                         focus=true      // Sliding focus
                         cutpaste=true   // Cut & Paste in shells
(*                       hide=true       // hiding of mouse pointer *)
                       ] /* end feelx */
            item=altcutpaste             // alternate Cut & Paste keys
//          item=altcutpaste [entry="blah blah"] /* example other menu entry! */
            item=-                       // Separator
            item=Window                  // Window is a menu defined below
            item=-
            item=*addmenu                // add to quick switch list ( * default)
            item=qswitch [hide=true]
                                         // hide quick switch list if empty
            item=-
            item=Prompt                  // Start a shell
            item=redraw                  // Redraw the contents of window
            item=top                     // Always top feature
            item=winhotkey               // Assign a hotkey to this window
          ] /* end of menu */


Window := menu [                              // see feelx.inf for more information
            entry="window"
            item=*zorder[ entry="W. -> background", pos=wbottom]
            item= zorder[ entry="P.-> 1 back",      pos=pnext]
            item= zorder[ entry="P.-> background",  pos=pbottom]
            item= zorder[ entry="P.-> foreground",  pos=ptop]
          ] /* end of menu */

Default_Shell:= menu [
            entry="Standard Shell"
            item=keyin [ "cd ..\n", "~cd .." ]
            item=*keyin[ "dir\n", "~dir" ]
//          item=keyin[ entry="~unzip (%c)", string="unzip -l %c" ]
            item=menu [
                        entry="~font"
                        item=*font [ entry="~small font", font=1 ]
                        item= font [ entry="~large font", font=5 ]
                      ] /* end of menu (anonymous item) */
            item=keyin [ entry="open folder", string="wpopen\n" ]
            item=kill [ entry="e~xit" /*, killchild=true */ ]
          ] /* end of main menu  (Standard_shell) */

Default_Desktop := menu [
            item= hideactionbar
            item= Config
            item= -
            item= CommandPrompts[]
            item=*Prompt                // Start a shell (* = this is default!)
            item= -
            item= Tools
            item= User_Documentation
            item= -
            item= HelpFeelX
            item= shutdowndlg [ onshutdown=shutdown ]
            item= QuitFeelX
          ] /* end of menu */

Default_Actionbar := actionbar [
            item=qswitch
            item=mwinlist [ entry="~Window list", all=false, items="STARTFX.EXE" ]
            item=CommandPrompts[]
            item=Tools[]
            item=ConfigActionbar
//          item=User_Documentation[]
            item=HelpFeelXActionbar
          ] /* end of menu */
//Startup := Default_Actionbar

Config:= menu [
            entry="Config"
            item=feelx [ entry="Sliding focus", focus=true ]
            item=feelx [ entry="Cut & Paste", cutpaste=true ]
            item=feelx [ entry="Hide mouse", hide=true ]
            item=-
            item=hideactionbar
            item=moveactionbar
            item=-
            item=FxOpt
            item=FeelXObject
            item=SystemConfig[]
           ] /* end of menu */

ConfigActionbar:= menu [
            entry="Config"
            item=feelx [ entry="Sliding focus", focus=true ]
            item=feelx [ entry="Cut & Paste", cutpaste=true ]
            item=feelx [ entry="Hide mouse", hide=true ]
            item=-
            item=hideactionbar
            item=moveactionbar
            item=-
            item=FxOpt
            item=FeelXObject
            item=SystemConfig[]
            item=-
            item=shutdowndlg [ onshutdown=shutdown ]
            item=QuitFeelX
           ] /* end of menu */

SystemConfig:=menu [
            entry="System"
            item=object [ entry="Config folder", object="<WP_CONFIG>" ]
            item=program [ entry="edit config.sys", name="e.exe", parameters="config.sys" ]
            item=object [ entry="Color", object="<WP_CLRPAL>" ]
            item=object [ entry="Font", object="<WP_FNTPAL>" ]
            item=object [ entry="System", object="<WP_SYSTEM>" ]
           ] /* end of menu */


// (E) NÅtzliche (?) Objekte

Prog_Documentation:= menu [
            entry="Documentation"
            item= program [ entry="Control Pgm", name="view.exe", parameters="progref21" ]
            item= program[ entry="16-Bit API", name="view.exe", parameters=prcp ]
            item=*program [ entry="PM Reference", name="view.exe", parameters="pmref" ]
            item= program [ entry="C++ Lib", name="view.exe", parameters="dde4clib" ]
            item= program [ entry="C++ Ref", name="view.exe", parameters="dde4lrm" ]
           ] /* end of menu */

Prompt:= program [
            entry="Shell"
            type=os2win                  // no name: shell
            child=true                   // as a child: move to top
         ] /* end of program */

/* Just an example */
Help:= program [
          entry="Help!!"
          name="view.exe"
          parameters="PMFUN.INF+PMGPI.INF+PMHOK.INF+PMMSG.INF+PMREL.INF+PMWIN.INF+PMWKP.INF+CPGREF1.INF+CPGREF2.INF+CPGREF3.INF &"
       ] /* end of program */

User_Documentation:= menu [
            entry="User Documentation"
            item= program [ entry="OS/2", name="view.exe", parameters="cmdref.inf" ]
           ] /* end of menu */

Tools:= menu [
      entry="Tools"
      item= pmkill
      item= minimize
      item= -
      item= program [ entry="Clipboard", name="clipos2.exe" ]
      item= program [ entry="Calculator", name="pmcalc.exe" ]
      item= program [ entry="Pulse", name="pulse.exe" ]
      item= object  [ entry="Clock", object="<WP_CLOCK>" ]
      item= -
      item= Wo
      item= ReXX [ entry="ReXX: %c"
                   window=pm
            ]
      item= PmShell
      ] /* end of menu */

Wo:= program [
       title="wo"                        // Title of pm window
       name="wo.exe"                     // The program name
       parameters="-p c-:[Which file?]"     // Ask for file as a parameter
       window=pm                         // -> send output to a PM-Window
       entry="Where is ...?"             // menu entry
       ]

FxOpt:= program [
      entry="change opt."                // the menu entry
      name="fxopt.exe"                   // the program name
      path="g:\source\feelx\feelx"
      parameters="&"                     // Use clipboard as parameter!
      ] /* end of program */

cprogram:=program [ child=true ]

CommandPrompts:= menu [
      entry="Command Prompts"
      item=cprogram [ entry="OS/2 Shell (win)", type=os2win ]
      item=cprogram [ entry="OS/2 Shell (fs)", type=os2fs ]
      item=-
      item=cprogram [ entry="DOS Shell (win)", type=doswin ]
      item=cprogram [ entry="DOS Shell (fs)", type=dosfs ]
      item=-
      item=cprogram [ entry="Windows (fs)", name="progman.exe", type=windoze31 ]
      item=cprogram [ entry="Windows (seamless)", name="progman.exe", type=windoze31seamless ]
      ] /* end of menu */

HelpFeelX:= menu [
      entry="Help"
      item=*program [ entry="FeelX Doc", name="view.exe", parameters="feelx" ]
      item=program [ feelxpath=true, entry="FeelX Help about %c", name="view.exe", parameters="feelx &" ]
      item=program [ entry="OS/2 Help about %c", name="view.exe", parameters="cmdref &" ]
      ]

HelpFeelXActionbar:= menu [
      entry="Help"
      item=program [ entry="FeelX Doc", name="view.exe", parameters="feelx" ]
      item=program [ entry="Help about %c", name="view.exe", parameters="feelx &" ]
      item=program [ entry="OS/2 Help about %c", name="view.exe", parameters="cmdref &" ]
      ]
OS2Help:=program [entry="OS/2 Cmd~Help", name="view.exe", parameters="cmdref &"]

ReXX := program [
                  feelxpath=true
                  name="callrx.exe"
                  entry="ReXX"
                  rexxfile="interp.cmd"
                  rexxparameter="&"
                  parameters="<rexxfile> <rexxparameter>"
                ]

Default_Hotkeys:=hotkey [
// Please note: only the first two entry are on per default,
// all others are commented out.
// Ctrl-Shift-PgDn: Move window into the Background
                pgdn=zorder [ pos=pbottom ]
// Ctrl-Shift-PgUp: Move window into the Front
                pgup=zorder [ pos=ptop ]
// Example: Ctrl-Shift-s: start a command shell
//              s=Prompt
// Example: Ctrl-Shift-m: start the macro recorder
//              m=recordmacro
// Example: Ctrl-Shift-a: display/hide the actionbar
//              a=hideactionbar
// Example: Ctrl-Shift-h: Scan all programming guides. Look for clipboard entry
//              h=Help
// Example: Ctrl-Shift-ESC: display special menu-windowlist
//              esc=mwinlist []
// Example: Ctrl-Shift-v: switch to a program called viewdoc.exe (=view)
//              v=switchto [ name="viewdoc.exe" ]
// Example: Ctrl-Shift-f: toggle sliding focus (useful if incompatible)
//              f=feelx [ focus=true ]
// Example: Ctrl-Shift-k: graphical kill
//              k=pmkill
// Example: Ctrl-Shift-z: currently active window -> always top on/off
//              z=top
// Example: Ctrl-Shift-x: FeelX settings
//              x=object [ object="<WP_FEELX>", open="SETTINGS" ]
// Example: Ctrl-Shift-t: open template folder
//              t=object [ object="<WP_TEMPS>", open="DEFAULT" ]
// Example: Ctrl-Shift-e: Switch to e (if there) and/or epm (if there)
//              e=chain [ item=switchto [ name="e.exe" ]
//                        item=switchto [ name="epm.exe" ]
//                      ]
         ]
