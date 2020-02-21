Color.CMD, version 1.3
Written by Jack Tan



           Color.CMD is a REXX script which sets the screen colors.
           Type COLOR at the command line for help.



I developed Color to set my screen colors for windowed OS/2 sessions,
since the default color scheme was virtually unreadable with my current
video setup.  Color works with both windowed OS/2 and full-screen OS/2
sessions.

The supported foreground colors in Color are:

   BLACK          GRAY (GREY)              MEDBLUE            GREEN
   BLUE           PURPLE (MAGENTA)         LIGHTBLUE          LIGHTGREEN
   RED            LIGHTRED                 PINK               CYAN
   WHITE (BRIGHTWHITE/LIGHTWHITE)          YELLOW

If the foreground colors are prefixed by the word BLINK (e.g., BLINKRED
or BLINKMEDBLUE), the letters will blink in a full-screen session.  In a
windowed session, the colors may turn light (e.g., BLINKRED turns into a
bright red).

The supported background colors are:

   BLACK          GRAY (GREY)              RED                GREEN
   BLUE           PURPLE (MAGENTA)         CYAN               BROWN
   WHITE (adds the BLINK- prefix on foreground color)

There are three basic forms of syntax:

   [1] Color.CMD <foreground> [[ON] <background>]
   [2] Color.CMD ON <background>
   [3] Color.CMD <label>

Each form is discussed below.

[1] Color.CMD <foreground> [[ON] <background>]
     This form allows the user to change either both the foreground and
     background, or just the foreground.  If setting the background color
     as well, the word 'ON' is not necessary.  Examples are:

     [C:\]color white on blue  // white text on blue background
     [C:\]color blinkred grey  // blinking red text on gray background
     [C:\]color yellow         // change text to yellow, keep background color

[2] Color.CMD ON <background>
     The second form allows the user to change only the background color
     without disturbing the foreground color.  Here, the word 'ON' is
     necessary.  Example:

     [C:\]color on green       // change background to green

[3] Color.CMD <label>
     The form is used for pre-defined color schemes.  If the
     environmental variables 'label_TEXT_FG' and 'label_TEXT_BG' are set
     to valid colors, then those colors will be used for the foreground
     and background, respectively.  Examples:

     [C:\]set DEFAULT_TEXT_FG=white      // white text
     [C:\]set DEFAULT_TEXT_BG=blue       // blue background
     [C:\]color default                  // use white text, blue background

     [C:\]set USERID_TEXT_FG=lightgreen  // light green text
     [C:\]set USERID_TEXT_BG=black       // black background
     [C:\]color userid                   // use above scheme

     The SET commands may be placed in CONFIG.SYS, so that they are
     available in every session.  Color automatically defines the color
     scheme NORMAL:

          set NORMAL_TEXT_FG=GRAY        // this is the default
          set NORMAL_TEXT_BG=BLACK       // OS/2 color scheme

     If the colors on the screen are unreadable, COLOR NORMAL provides an
     escape (though somewhat long to type).

Each time Color is run, the current colors are updated, even if the
colors are unchanged.  The current color scheme is kept in the
enviromental variables TEXT_FG and TEXT_BG.  It is useful, although
not required, to place the following lines in CONFIG.SYS:

          set TEXT_FG=GRAY               // every CMD.EXE window starts
          set TEXT_BG=BLACK              // like this

These lines are also useful, but not required:

          set NORMAL_TEXT_FG=GRAY        // this is the default
          set NORMAL_TEXT_BG=BLACK       // OS/2 color scheme again

Lastly, type COLOR at the command line for a help summary.



I hope this program proves useful.  I welcome any comments, criticisms,
suggestions, and bug reports.  By using this program, the user accepts
all responsiblity for any damages resulting from this program, and
there is absolutely no warranty.  Although there is nothing malicious
about this program (except perhaps very obnoxious color combinations),
some sort of disclaimer must be included....

Jack Tan
jahk@uiuc.edu

P.O. Box 3894
Oak Brook, IL 60522-3894
United States of America
