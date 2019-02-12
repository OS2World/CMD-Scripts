.******** Browse Program Help Panel Definition (.IPF) file ********************
.*
.* This file defines the help panels for the Browse program.  These
.* panels are defined using the Information Presentation Language markup tags.
.* This file is compiled with the IPFC conversion tool to create the .hlp file
.* which becomes the help library file for the program.
.*
.******************************************************************************
:userdoc.
:title.Help for Browse Program
:body.
.*
.*
:h1 res=405.Extended Help for Browse
:i1.Browse
:p.The Browse program allows a user to view files as a series of text
lines. Any file can be browsed, but if the file does not contain
only simple ASCII text then garbage will appear on the screen when
the file is opened.
:p.Help is available any time you press the
F1 key from anywhere within the program.  Because this is context
sensitive help, the help information that is displayed depends on where in the
program F1 was selected.
:p.For instance, you receive help for the :hp2.Options:ehp2. pull-down on the action
bar when you highlight :hp2.Options:ehp2. and press F1.  However, this is not
the same help that is displayed when you press F1 while the
:hp2.Set colors:ehp2. choice
in the :hp2.Options:ehp2. pull-down is highlighted.
:p.Press Esc at any time to view the previous help window or to return to the
main Browse window if there are no other help windows active.
.*
.******************************************************************************
.*
.*
:h1.Help for Browse Menu Choices
:i1.Menus
:p.The menu system on the main Browse window contains 4 choices:
:ol.
:li.File
:li.Edit
:li.Options
:li.Help
:eol.
.*
:h2 res=407.Help for File Menu
:i1.File Menu
:p.Use the :hp2.File:ehp2. pull-down choices to select
a new file to be browsed or to exit Browse.
.*
:h3 res=408.Help for Open Choice
:i1.Open Menu Choice
:p.Use this choice to select a new file to be browsed.
.*
:h3 res=409.Help for Exit Choice
:i1.Exit Menu Choice
:p.Use this choice to end the Browse program and return to the Desktop
Manager.
.*
:h2 res=410.Help for Edit Menu
:i1.Edit Menu
:p.Use the :hp2.Edit:ehp2. pull-down choices to
:ul.
:li.Search for a text string in the currently browsed file
:li.Copy the currently highlighted text to the Clipboard
:li.Clear the currentl highlighted text.
:eul.
.*
:h3 res=411.Help for Copy Choice
:i1.Copy Menu Choice
:p.Use this choice to copy the currently highlighted text to
the Clipboard.
.*
:h3 res=412.Help for Find Choice
:i1.Find Menu Choice
:p.Use this choice to search the currently browsed file for a text
string.
.*
:h3 res=413.Help for Select All
:i1.Select All Menu Choice
:p.Use this choice to highlight the entire contents of the currently
browsed file.
.*
:h2 res=414.Help for Options Menu
:i1.Options Menu
:p.Use the :hp2.Options:ehp2. pull-down choices to
:ul.
:li.Set the display font
:li.Set the text and background colors
:li.Turn wordwrap on/off.
:eul.
.*
:h3 res=415.Help for Set Font Choice
:i1.Set Font Menu Choice
:p.Use this choice to select the font used for the display of text
in the main window.
.*
:h3 res=416.Help for Set Colors Choice
:i1.Set Colors Menu Choice
:p.Use this choice to select the colors used to display
text in the main window.
.*
:h3 res=417.Help for Wordwrap Choice
:i1.Wordwrap Menu Choice
:p.Use this choice to toggle the word wrap option.
.*
:h2 res=418.Help for Help Menu
:i1.Help Menu
:p.Use the :hp2.Help:ehp2. pull-down choices to
find out how to use help, to
get extended help, to go to a list of keys, or to go to the
help index.
:dl tsize=10 break=all.
:dt.:hp2.Help for help:ehp2.
:dd.Provides detailed information on the kinds of help
available and how to use help.
:dt.:hp2.Help for Browse:ehp2.
:dd.Displays general help.
:dt.:hp2.Keys help:ehp2.
:dd.Displays a list of keys and their functions.
:dt.:hp2.Help index:ehp2.
:dd.Displays the help index list of topics.
:dt.:hp2.About Browse:ehp2.
:dd.Displays the Copyright and Author information for the program.
:edl.
.*
:h3 res=419.Help for Help Choice
:i1.Help Menu Choice
:p.Use this choice to obtain information on how to use the Help
facility.
.*
:h3 res=420.Extended Help Choice
:i1.Extended Help Menu Choice
:p.Use this choice to obtain general help information on Browse.
.*
:h3 res=421.Help for Keys Choice
:i1.Keys Menu Choice
:p.Use this choice to see a list of the special keys and function
keys that are used by Browse and their uses.
.*
:h3 res=422.Help for Help Index Choice
:i1.Index Menu Choice
:p.Use this choice to display the help index.
:p.The help index lists the titles of the help information that
are available.
.*
:h3 res=423.Help for About Browse Choice
:i1.About Browse Menu Choice
:p.Use this choice to display the Copyright and Author information
for Browse.
.*
.******************************************************************************
.*
.*
:h1 res=406.Help for Key Assignments
:i1.Keys
:p.The list of keys is arranged in groups.
:p.:hp2.ACCELERATOR KEYS:ehp2.
:dl tsize=5 break=all.
:dt.Ctrl+a
:dd.Select all text in the currently browsed file
:dt.Ctrl+c
:dd.Select new colors for the display text
:dt.Ctrl+f
:dd.Search for a text string in the currently displayed file
:dt.Ctrl+Insert
:dd.Copy selected text to the Clipboard
:dt.Ctrl+o
:dd.Open a new file to be browsed
:dt.Ctrl+w
:dd.Toggle Wordwrap on/off
:dt.F3
:dd.Exit program
:edl.
.*
:p.:hp2.HELP KEYS:ehp2.
:dl tsize=5 break=all.
:dt.F1
:dd.Get help
:dt.F2
:dd.Get extended help (from within any help window)
:dt.Alt+F4
:dd.End help
:dt.F9
:dd.Go to a list of keys (from within any help window)
:dt.F11
:dd.Go to the help index (from within any help window)
:dt.Esc
:dd.Previous Help Panel, or End help if only one panel
:dt.Alt+F6
:dd.Go to/from help and programs
:dt.Shift+F10
:dd.Get help for help
:edl.
:p.:hp2.SYSTEM KEYS:ehp2.
:dl tsize=5 break=all.
:dt.Alt+F6
:dd.Switch to the next windowed program
:dt.Alt+Esc
:dd.Switch to the next program, including full-screen programs
:dt.Ctrl+Esc
:dd.Switch to the Task List
:edl.
:p.:hp2.WINDOW KEYS:ehp2.
:dl tsize=5 break=all.
:dt.F3
:dd.Close a window
:dt.F10
:dd.Go to/from the action bar
:dt.Arrow keys
:dd.Move among choices
:dt.End
:dd.Go to the last choice in a pull-down
:dt.Esc
:dd.Cancel a pull-down or the system menu
:dt.Home
:dd.Go to the first choice in a pull-down
:dt.PgUp
:dd.Scroll the contents of the window up one page
:dt.PgDn
:dd.Scroll the contents of the window down one page
:dt.Underlined letter
:dd.Move among the choices on the action bar and pull-downs
:dt.Alt+F10
:dd.Go to/from the action bar
:dt.Alt+F4 or F3
:dd.Close the window
:dt.Alt+F5
:dd.Restore the window
:dt.Alt+F7
:dd.Move the window
:dt.Alt+F8
:dd.Size the window
:dt.Alt+F9
:dd.Minimize the window
:dt.Alt+F10
:dd.Maximize the window
:dt.Ctrl+PgDn or Shift+F8
:dd.Scroll the contents of the window right one page
:dt.Ctrl+PgUp or Shift+F7
:dd.Scroll the contents of the window left one page
:dt.Shift+Esc or Alt+Spacebar
:dd.Go to/from the system menu
:dt.Shift+Esc or Alt
:dd.Go to/from the system menu of a text window
:edl.
:index.
:euserdoc.
.* end of Browse help Library File ********.wda.**

