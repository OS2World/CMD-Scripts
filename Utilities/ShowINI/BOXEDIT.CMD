/*
program: boxedit.cmd
type:    REXXSAA-OS/2, OS/2 2.0
purpose: allow for editing text in a box
version: 1.04
date:    1992-06-01

author:  Rony G. Flatscher
         RONY@AWIWUW11.BITNET
         rony@wu-wien.ac.at

usage:   BOXEDIT(first_row first_col last_row last_col style [, [initial_text] [,[A|H] [, prompt] ]] )
returns: edited text

argument 1: rectangular dimensions plus optional style
            ... first_row = 0-based, first_col = 0-based
            style ... "", 1, 2, 3

argument 2: initial text (optional)

arbument 3: optional type of text
            A ... ASCII-Text (default)
            H ... hexadecimal Text

argument 4: prompt to be displayed (optional)

Following key-combinations can be used while editing:

        ESC             ... abort editing, return unchanged text
        F10             ... save edited text, return it

        ENTER           ... get to beginning of next line

        TAB             ... advance cursor 8 characters
        BACK-TAB        ... move cursor 8 characters backward

        CTRL-RIGHT      ... move cursor to beginning of next word
        CTRL-LEFT       ... move cursor to beginning of present/previous word

        END             ... move cursor to last column of current line
        HOME            ... move cursor to first column of current line

        CTRL-END        ... move cursor to last line, last column of box
        CTRL-HOME       ... move cursor to first line, first column of box

        CTRL-ENTER      ... insert blank line, move current line down
        CTRL-BACKSPACE  ... delete current line

All rights reserved, copyrighted 1992, no guarantee that it works without
errors, etc. etc.

donated to the public domain granted that you are not charging anything (money
etc.) for it and derivates based upon it, as you did not write it,
etc. if that holds you may bundle it with commercial programs too

you may freely distribute this program, granted that no changes are made
to it

Please, if you find an error, post me a message describing it, I will
try to fix and rerelease it to the net.

*/


PARSE SOURCE  . invocation .

IF invocation <> "FUNCTION" THEN SIGNAL usage

PARSE VALUE ARG(1) WITH first_row first_col last_row last_col style

CALL ON HALT


type = TRANSLATE(ARG(3))        /* translate into uppercase */

IF TRANSLATE(SUBSTR(ARG(3),1,1)) = "H" THEN type = "H"  /* hex-edit */
ELSE type = "A"                                         /* ASCII-edit */

/* check whether RxFuncs are loaded, if not, load them */
IF RxFuncQuery('SysLoadFuncs') THEN
DO
    /* load the load-function */
    CALL RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'       

    /* load the Sys* utilities */
    CALL SysLoadFuncs                                                 
END

/* save screen-area context */
PARSE VALUE SysTextScreenSize() WITH row columns
PARSE VALUE SysCurPos() WITH cursor_row cursor_col

save_screen = SysTextScreenRead(first_row, 0, (last_row - first_row + 1) * (columns + 1))

IF type = "H" THEN top_line = "Hex-edit [0-9,A-F]"
ELSE top_line = "ASCII-edit"

IF ARG(4) <> "" THEN            /* was a prompt supplied ? */
DO
   top_line = ARG(4) "(" || top_line || ")"
END

bottom_line = "<F10:save> <Esc:abort>"
client_area = draw_box(ARG(1), top_line, bottom_line)   /* draw frame */

CALL write_box client_area ARG(2)                       /* fill box with text */

/* position cursor one character after the last letter */
PARSE VAR client_area startRow startColumn endRow endColumn

textLength = LENGTH(ARG(2))
charsPerLine = endColumn - startColumn + 1
posColumn = startColumn + textLength // charsPerLine 
posRow = startRow + textLength % charsPerLine

IF posColumn > endColumn THEN
DO
   posColumn = startColumn
   posRow = posRow + 1
END

IF posRow > endRow THEN posRow = startRow

CALL SysCurPos posRow, posColumn       /* position cursor right after last character */


tmp = edit_box(client_area)            /* edit text */

IF tmp = "SAVE" THEN res = read_box(client_area) /* read new text */
                ELSE res = ARG(2)                /* leave text unchanged */

/* restore screen-area context */
CALL SysCurState "off"                 /* turn cursor off */
CALL SysCurPos first_row, 0            /* place cursor    */
CALL CHAROUT , save_screen             /* restore screen  */
CALL SysCurPos cursor_row, cursor_col  /* restore cursor  */
CALL SysCurState "on"                  /* turn cursor on  */

RETURN res



/*****************************************************************/

HALT:
/* 
   Say "stop? (y/n) "
   key = SysGetKey("noecho")
   IF TRANSLATE(key) = "Y" THEN EXIT
   key = "3"x 
*/
   RETURN



/* define a square on a text-screen to edit */
EDIT_BOX: PROCEDURE EXPOSE type
   PARSE ARG first_row first_col last_row last_col
   PARSE VALUE SysCurPos() WITH act_row act_col

   DO FOREVER

      key = SysGetKey("noecho")
      d2ckey = C2D(key)

      SELECT
         WHEN d2ckey = 13 THEN      /* Carriage-return was pressed */
            DO
               d2ckey = 224         /* fake lead-in */
               d2ckey2 = 999        /* "impossible" char-value */
            END

         WHEN d2ckey = 8 THEN       /* Backspace pressed */
            DO
               CALL edit_box_text ARG(1) "BACKUP"
               PARSE VALUE SysCurPos() WITH act_row act_col
               ITERATE
            END

         WHEN d2ckey = 9 THEN       /* TAB pressed */
            DO
               CALL edit_box_text ARG(1) "TAB"
               PARSE VALUE SysCurPos() WITH act_row act_col
               ITERATE
            END

         WHEN d2ckey = 10 THEN      /* CTRL-Enter pressed = insertline */
            DO
               CALL edit_box_text ARG(1) "INSERTLINE"
               ITERATE
            END


         WHEN d2ckey = 27 THEN      /* ESCape was pressed, abort */
            RETURN "ESCAPE"

         WHEN d2ckey = 127 THEN     /* CTRL-Backspace pressed = deleteline */
            DO
               CALL edit_box_text ARG(1) "DELETELINE"
               ITERATE
            END

         WHEN d2ckey = 224 | d2ckey = 0 THEN   /* escape-sequence in hand ? */
            DO
               key2 = SysGetKey("noecho")       /* get next code */
               d2ckey2 = C2D(key2)

               IF d2ckey = 224 THEN
                  SELECT
                     WHEN d2ckey2 = 82  THEN    /* insert pressed */
                     DO
                        CALL edit_box_text ARG(1) "INSERT"
                        ITERATE
                     END

                     WHEN d2ckey2 = 83 THEN /* delete pressed */
                     DO
                        CALL edit_box_text ARG(1) "DELETE"
                        ITERATE
                     END

                     WHEN d2ckey2 = 116 THEN /* CTRL-right pressed */
                     DO
                        CALL edit_box_text ARG(1) "CTRL-RIGHT"
                        PARSE VALUE SysCurPos() WITH act_row act_col
                        ITERATE
                     END

                     WHEN d2ckey2 = 115 THEN /* CTRL-left pressed */
                     DO
                        CALL edit_box_text ARG(1) "CTRL-LEFT"
                        PARSE VALUE SysCurPos() WITH act_row act_col
                        ITERATE
                     END

                     WHEN d2ckey2 = 119 THEN /* CTRL-HOME (STRG-POS1) pressed move to first row, column */
                     DO
                        act_row = first_row
                        act_col = first_col
                        CALL SysCurPos act_row, act_col
                        ITERATE
                     END

                     WHEN d2ckey2 = 71 THEN /* HOME (POS1) pressed move to first column */
                     DO
                        act_col = first_col
                        CALL SysCurPos act_row, act_col
                        ITERATE
                     END

                     WHEN d2ckey2 = 117 THEN /* CTRL-END (STRG-ENDE) pressed move to last row, column */
                     DO
                        act_row = last_row
                        act_col = last_col
                        CALL SysCurPos act_row, act_col
                        ITERATE
                     END

                     WHEN d2ckey2 = 79 THEN /* END (ENDE) pressed move to last column */
                     DO
                        act_col = last_col
                        CALL SysCurPos act_row, act_col
                        ITERATE
                     END


                     OTHERWISE NOP
                  END
            END

         OTHERWISE   /* regular key pressed */
            DO
               IF type = "H" THEN
               DO
                  key = TRANSLATE(key)
                  IF POS(key, "0123456789ABCDEF") = 0 THEN
                  DO
                     CALL BEEP 440, 100
                     ITERATE
                  END
               END

               CALL CHAROUT , key      /* echo key to screen */
               /* fake a right-key-press */
               d2ckey  = 224
               d2ckey2 = 77
            END
      END

      IF d2ckey = 224 THEN            /* cursor-pad-key pressed */
      DO
         SELECT
            WHEN d2ckey2 = 999 THEN    /* enter was pressed, get to beginning of next line */
               DO
                  act_row = act_row + 1
                  act_col = first_col
               END

            WHEN d2ckey2 = 72 THEN     /* upper-arrow pressed */
               act_row = act_row - 1

            WHEN d2ckey2 = 80 THEN     /* down-arrow pressed */
               act_row = act_row + 1

            WHEN d2ckey2 = 75 THEN     /* left-arrow pressed */
               act_col = act_col - 1

            WHEN d2ckey2 = 77 THEN     /* right-arrow pressed */
               act_col = act_col + 1

            OTHERWISE CALL BEEP 440, 100
         END


         IF act_col < first_col THEN   /* check whether valid ranges */
         DO
            act_col = last_col
            act_row = act_row - 1
         END

         IF act_col > last_col THEN
         DO
            act_col = first_col
            act_row = act_row + 1
         END

         IF act_row < first_row THEN
         DO
            act_row = last_row
         END

         IF act_row > last_row THEN
         DO
            act_row = first_row
         END

      END
      ELSE     /* lead-in is 0 */
      DO
         SELECT
            WHEN d2ckey2 = 15 THEN       /* BACK-TAB pressed */
               DO
                  CALL edit_box_text ARG(1) "BACK-TAB"
                  PARSE VALUE SysCurPos() WITH act_row act_col
                  ITERATE
               END

            WHEN d2ckey2 = 68 THEN     /* F10 was pressed, save */
            DO
               IF type = "H" THEN       /* check for even numbers of characters and no blanks */
               DO
                  tmp = STRIP(read_box(ARG(1)))
                  IF POS(" ", tmp) > 0 THEN
                  DO
                     CALL error_msg "HEX-string must not contain blanks!"
                     ITERATE
                  END

                  IF LENGTH(tmp) // 2 = 1 THEN
                  DO
                     CALL error_msg "HEX-string must consist of even number of characters! ("LENGTH(tmp)" in HEX-string)"
                     ITERATE
                  END
                    


               END
               RETURN "SAVE"
            END

            OTHERWISE                  /* all other keys are ignored */
               CALL BEEP 440, 100
         END
      END

      CALL SysCurPos act_row, act_col  /* position cursor on new position */
   END
   RETURN



/* process edit keys DELETE, INSERT, BACKSPACE,
   CTRL-RIGHT, CTRL-LEFT, TAB and BACKTAB in box */

EDIT_BOX_TEXT: PROCEDURE EXPOSE type
   PARSE ARG first_row first_col last_row last_col switch
   PARSE VALUE SysCurPos() WITH act_row act_col

   delimiters = " !""#$%&'()*+,-./:;<=>@[\]^_`{|}~"

   client = first_row first_col last_row last_col
   text = Read_Box(client)
   line_nr = act_row - first_row
   line_length = last_col - first_col + 1

   charpos = line_nr * line_length + (act_col - first_col + 1)

   SELECT
      WHEN switch = "INSERT" THEN
         DO
            tmp = SUBSTR(text, 1, charpos - 1) || " " || SUBSTR(text, charpos)
         END

      WHEN switch = "DELETE" THEN
         DO
            tmp = SUBSTR(text, 1, charpos - 1) || SUBSTR(text, charpos + 1)
         END

      WHEN switch = "BACKUP" THEN
         DO
            IF (act_row act_col) = (first_row first_col) THEN
            DO
               CALL BEEP 440,100  /* cannot backspace, if in first position */
               RETURN
            END
            ELSE
            DO
               tmp = SUBSTR(text, 1, charpos - 2) || SUBSTR(text, charpos)
               act_col = act_col - 1

               IF act_col < first_col THEN
               DO
                  act_col = last_col
                  act_row = act_row - 1
                  IF act_row < first_row THEN
                     act_row = last_row
               END
            END
         END

      WHEN switch = "CTRL-RIGHT" THEN  /* find beginning of NEXT word */
         DO
            /* find first character which appears in delimiters */
            index = VERIFY(text, delimiters, "M", charpos)

            IF index = 0 THEN index = 1

            index = VERIFY(text, delimiters, , index)

            IF index = 0 THEN
            DO
               act_row = first_row
               act_col = first_col
            END
            ELSE
            DO
               index = index - 1
               act_row = first_row + index % line_length
               act_col = first_col + index // line_length
            END

            CALL SysCurPos act_row, act_col  /* position cursor */
            RETURN
         END


      WHEN switch = "CTRL-LEFT" THEN  /* find beginning of PREVIOUS word */
         DO
            IF LENGTH(text) = 0 THEN RETURN

            /* if on first, position search from the very last */
            IF (act_row act_col) = (first_row first_col) THEN
                i = 0
            ELSE     /* only delimiters before this character ? */
            DO i = charpos - 1 TO 1 BY -1
               IF POS(SUBSTR(text, i, 1), delimiters) > 0 THEN ITERATE
               LEAVE
            END

            IF i = 0 THEN charpos = LENGTH(text) + 1

            index = charpos - 1
            alpha = (POS(SUBSTR(text, (charpos - 1), 1), delimiters) = 0)

            IF \alpha THEN    /* non-alpha in hand, search for first alpha */
            DO
               DO i = charpos - 2 TO 1 BY -1
                  IF POS(SUBSTR(text, i, 1), delimiters) > 0 THEN ITERATE
                  index = i
                  LEAVE
               END
            END

            alpha_processed = 0

            DO i = index TO 1 BY -1 /* search beginning of alpha */
               IF POS(SUBSTR(text, i, 1,), delimiters) = 0 THEN ITERATE
               index = i + 1
               alpha_processed = 1
               LEAVE
            END

            IF \alpha_processed THEN index = 1

            IF index = 0 THEN
            DO
               act_row = first_row
               act_col = first_col
            END
            ELSE
            DO
               index = index - 1
               act_row = first_row + index % line_length
               act_col = first_col + index // line_length
            END

            CALL SysCurPos act_row, act_col  /* position cursor */
            RETURN
         END

      WHEN switch = "INSERTLINE" | switch = "DELETELINE" THEN
         DO
            text = read_box(client)   /* read actual text */

            line_length = last_col - first_col + 1
            line_nr     = last_row - first_row + 1
            act_line    = act_row  - first_row + 1

            IF switch = "INSERTLINE" THEN
            DO
               tmp = SUBSTR(text, 1, (act_line - 1) * line_length) ||,
                     COPIES(" ", line_length) ||,
                     SUBSTR(text, (act_line - 1) * line_length + 1)

             END
            ELSE     /* delete present line */
            DO
               IF act_line = 1 THEN
                  tmp = SUBSTR(text, line_length + 1)
               ELSE
                  tmp = SUBSTR(text, 1, (act_line - 1) * line_length) ||,
                        SUBSTR(text, act_line * line_length + 1)
            END
         END

      WHEN switch = "TAB" | switch = "BACK-TAB" THEN  /* position according to tab */
         DO
            tabs = 8    /* tab-interval */
            IF switch = "TAB" THEN act_col = act_col + tabs
                              ELSE act_col = act_col - tabs

            IF act_col > last_col THEN
            DO
               act_row = act_row + 1
               act_col = first_col + (act_col - last_col) - 1
            END

            IF act_col < first_col THEN
            DO
               act_row = act_row - 1
               act_col = last_col + (act_col - first_col) + 1
            END

            IF act_row > last_row THEN
               act_row = first_row

            IF act_row < first_row THEN
               act_row = last_row


            CALL SysCurPos act_row, act_col  /* position cursor */
            RETURN
         END


      OTHERWISE NOP
   END

   CALL Write_Box(client tmp)       /* update box */
   CALL SysCurPos act_row, act_col  /* restore cursor */

   RETURN





/* draw a box in the given square, return client-size */
draw_box: PROCEDURE EXPOSE type
   PARSE ARG first_row first_col last_row last_col style

   IF style = '' then style = 1   /* define default */

   /* text-window dimenstions */
   PARSE VALUE SysTextScreenSize() with sys_row sys_col
   sys_row = sys_row - 1
   sys_col = sys_col - 1


   /* left-upper-corner, horizontal, right-upper-corner,
      left-lower-corner, vertical, right-lower-corner */
   set.1 = "Ú Ä ¿ À ³ Ù"
   set.2 = "É Í » È º ¼"
   set.3 = "+ - + + | +"

   inner_width = last_col - first_col - 1
   CALL SysCurState "off"               /* turn cursor off */

   /* first line of box */

   tmp0 = WORD(set.style, 1) || COPIES(WORD(set.style, 2), inner_width) || WORD(set.style, 3)
   tmp1 = ARG(2)                        /* prompt */

   n = TRUNC((LENGTH(tmp0) - LENGTH(tmp1)) / 2) + 1
   IF n < 1 THEN 
      n = 1

   tmp0 = OVERLAY(tmp1, tmp0, n)

   CALL SysCurPos first_row, first_col
   CALL CHAROUT , tmp0
                  

   /* middle lines of box */
   middle_line = WORD(set.style, 5) || ,
                 COPIES(" ", last_col - first_col - 1) || ,
                 WORD(set.style, 5)
   DO i = first_row + 1 TO last_row - 1
      CALL SysCurPos i, first_col
      CALL CHAROUT , middle_line
   END

   /* last line of box */
   CALL SysCurPos last_row, first_col

   tmp0 = WORD(set.style, 4) || COPIES(WORD(set.style, 2), inner_width) || WORD(set.style, 6)

   tmp1 = ARG(3)

   n = TRUNC((LENGTH(tmp0) - LENGTH(tmp1)) / 2) + 1

   IF n < 1 THEN 
      n = 1

   tmp0 = OVERLAY(tmp1, tmp0, n)
   CALL CHAROUT , tmp0


   CALL SysCurPos first_row + 1, first_col + 1  /* position in client-area */
   CALL SysCurState "on"     /* turn cursor on */

   RETURN (first_row + 1) (first_col + 1) (last_row - 1) (last_col - 1)






/* write string into box */
WRITE_BOX: PROCEDURE
   PARSE ARG first_row first_col last_row last_col text

   line_length = last_col - first_col + 1
   line_nr     = last_row - first_row + 1

   CALL SysCurState "off"     /* turn cursor off */

   next_item = 1
   DO i = 0 TO line_nr - 1
      CALL SysCurPos first_row + i, first_col
      CALL CHAROUT , SUBSTR(text, next_item, line_length)
      next_item = next_item + line_length
   END

   CALL SysCurState "on"     /* turn cursor on */
   CALL SysCurPos first_row, first_col

   RETURN



/* read string from box */
READ_BOX: PROCEDURE
   PARSE ARG first_row first_col last_row last_col .

   line_length = last_col - first_col + 1
   line_nr     = last_row - first_row + 1
   tmp = ''
   DO i = 0 TO line_nr - 1
      tmp = tmp || SysTextScreenRead(first_row + i, first_col, line_length)
   END

   RETURN tmp


/* show an error box */
ERROR_MSG: PROCEDURE
   /* save screen-area context */
   nr_lines = 1

   CALL SysCurState "off"                               /* turn cursor off */
   PARSE VALUE SysTextScreenSize() WITH row columns     /* get screen dimensions */
   PARSE VALUE SysCurPos() WITH cursor_row cursor_col   /* get current position */

   r0 = cursor_row - nr_lines
   IF r0 < 0 THEN
      r0 = 0

   /* draw box at center of screen */
   c0 = (columns - LENGTH(ARG(1))) % 2 - 1              /* starting position of window */
   rn = cursor_row + nr_lines

   cn = c0 + LENGTH(ARG(1)) + 3                         /* wideness of window */

   save_screen = SysTextScreenRead(r0, 0, (rn - r0 + 1) * columns)

   client_area = draw_box(r0 c0 rn cn 2, "Error:", "<press any key to continue>")    /* draw frame */

   CALL write_box client_area CENTER(ARG(1), cn - (c0 + 2) + 1) /* fill box with text */


   CALL BEEP 2500, 250
   CALL SysCurState "off"                               /* turn cursor off */
   key = SysGetKey("noecho")


   /* restore screen-area context */
   CALL SysCurPos r0, 0                                 /* place cursor    */
   CALL CHAROUT , save_screen                           /* restore screen  */
   CALL SysCurPos cursor_row, cursor_col                /* restore cursor  */
   CALL SysCurState "on"                                /* turn cursor on  */
   RETURN


/* show usage */
USAGE:
   SAY "Function to allow editing text on an ANSI-screen"
   SAY
   SAY " BOXEDIT(first_row first_col last_row last_col [style] [, initial_text][,A|H])"
   SAY " ... first_row = 0, first_col = 0"
   SAY
   SAY " argument 1: rectangular dimensions plus optional [style]"
   SAY "             style ... '', 1, 2, 3"
   SAY 
   SAY " argument 2: initial text (optional)"
   SAY
   SAY " argument 3: optional type of text"
   SAY "             A ... ASCII-Text (default)"
   SAY "             H ... hexadecimal Text"
   SAY
   SAY " argument 4: prompt to be displayed (optional)"
   EXIT

