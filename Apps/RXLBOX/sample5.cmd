EXTPROC RXLBOX.CMD %0 /EXTPROC
; --------------------------------------------------------------------
;
; Menu description file for RxLBox v1.30 to test EXTPROC feature
;
; (see RXLBOX.MEN for a complete description of menu description files;
;  see RXLBOX.CMD for the usage description)
;
; --------------------------------------------------------------------
[*MainMenu*]
Title1             = Sample menu file for RxLBox v1.30
Title2             = RxLBox is Copyright (c) 1996-1998 by Bernd Schemmer
Title3             = This menu is called via the EXTPROC feature
StatusLine         = Choose a menu entry to test RXLBOX.
InputPrompt        = Your choice:
HelpPrompt         = Press any key to continue ...
ErrorPrompt        = Press any key to continue ...
CLS                = WHITE ON BLACK
AcceptAllInput     = NO
HelpForF1          = MAINHELP
HelpForCTRL_F1     = KEYHELP
HelpForALT_F1      = INPUTLINEHELP

; turn off CTRL-C
OnInit             =  nop; MenuDesc.__NoHalt = 1;

MenuItem.#         = Read the file README.DOC
Action.#           = #ExecuteCmd() {'E' directory() || '\readme.doc'} 
StatusLine.#       = Choose this entry to view the file README.DOC

MenuItem.#         = Help for the format of menu description files
Action.#           = #ExecuteCmd() {'E' directory() || '\RXLBOX.MEN'}
StatusLine.#       = Choose this entry to view the file RXLBOX.MEN

MenuItem.#         = Help for the usage of RXLBOX
Action.#           = #ExecuteCmd() {'E' directory() || '\RXLBOX.CMD'}
StatusLine.#       = Choose this entry to view the file RXLBOX.CMD

MenuItem.#         = ---------------------------------------------------------------------------
Action.#           = #NOP()
StatusLine.#       = This is a dummy entry

MenuItem.#         = Try the SAMPLE1
Action.#           = #ExecuteCmd() {'*cmd /c ' || directory() || '\SAMPLE1.CMD' }
StatusLine.#       = Choose this entry to run the SAMPLE1.CMD

MenuItem.#         = Try the SAMPLE2
Action.#           = #ExecuteCmd() {'*cmd /c ' || directory() || '\SAMPLE2.CMD' }
StatusLine.#       = Choose this entry to run the SAMPLE2.CMD

MenuItem.#         = Try the SAMPLE3
Action.#           = #ExecuteCmd() {'*cmd /c ' || directory() || '\SAMPLE3.CMD' }
StatusLine.#       = Choose this entry to run the SAMPLE3.CMD

MenuItem.#         = Try the SAMPLE4 
Action.#           = #ExecuteCmd() {'*cmd /c ' || directory() || '\SAMPLE4.CMD' }
StatusLine.#       = Choose this entry to run the SAMPLE4.CMD

; ----------------------------
[<MainHelp>]
This the online help for the main menu. The main menu is the default
menu displayed by RxLBox if it's called with no menu parameter.

Each online help can have up to 14 lines with up to 69 characters.

---------------------------------

Use <CTRL-F1> to call the online help with the function key description.
Use <ALT-F1> to call the online help with the input line description.
[dummy section]

; ----------------------------
[<KeyHelp>]
F1 - show the online help
ALT-F1 - show the input line description
CTRL-F1 - show the function key description

F8 - show macro list              F9 - refresh display
F11 - show list of all menus      F12 - show menu history list

F10 - Quit                        ESC - go one menu back

RETURN - choose the highlighted entry

Use the cursor keys, PgDn, PgUp, Home, End, CTRL-Home and CTRL-End
to scroll through the menu.
[dummy section]

; ----------------------------
[<InputLineHelp>]
+n - scroll down n entries        -n scroll up n entries
 n - choose the entry n if its on the current page
     or
     jump to the entry if it's not on the current page

 *command - exeucte the OS/2 command 'command' (Preceed the command
            with another asterix '*' to wait after execution)

 macroName - execute the macro 'macroName'

---------------------------------
Use <F1> to call the general online help
Use <CTRL-F1> to call the online help with the key description.
[dummy section]

; --------------------------------------------------------------------
