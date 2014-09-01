/*--------------------------------------------------------------*/
/* RxLogin v1.0b3 - An ultra-simple login program...            */
/*      originally written by Digital Productions,              */
/* Rewritten by darkpoet - darkpoet@bellsouth.net               */
/*      copyright (c) 1997 darkpoet productions, inc.           */
/*--------------------------------------------------------------*/
CALL rxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
CALL SysLoadFuncs

/* colors: BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE       */
/*  fg      30   31   32     33    34     35    36    37        */
/*  bg      40   41   42     43    44     45    46    47        */
BlueOnBlack =D2C(27)||"["||34||";"||40||";m"
/* atributes: NORMAL HIGH LOW ITALIC UNDERLINE BLINK RAPID REVERSE */
/*              0     1    2    3      4         5     6     7     */
Normal =D2C(27)||"["||0||";m"

SIGNAL ON HALT NAME NiceExit;

PARSE VALUE SysTextScreenSize() with height width

PARSE ARG checkpass

IF LENGTH(checkpass) > 0 THEN
  DO
    checkpass = INSERT(D2C(13), checkpass, LENGTH(checkpass))
    PARSE VALUE SysCurPos() with row col
    IF row >= (height-2) THEN
      DO
        SAY
        SAY
        row = height - 3
      END
    SIGNAL BreakFoil
  END

SAY BlueOnBlack "What password should I use? ->"
PARSE VALUE SysCurPos() with row col
row = row - 1
col = 31
DO UNTIL (C2D(key) = 13) | (row = width)
  PARSE VALUE SysCurPos(row, col) with x y
  key = SysGetKey('NOECHO')
  IF C2D(key) = 8 THEN
    DO
      IF col > 30 THEN
        DO
          col = col - 1
          PARSE VALUE SysCurPos(row, col) with x y
          SAY " "
          checkpass = LEFT(checkpass, LENGTH(checkpass) - 1)
        END
    END
  ELSE
    DO
      SAY "*"
      checkpass = INSERT(key, checkpass, LENGTH(checkpass))
      col = col + 1
    END
END

SAY BlueOnBlack "Machine now locked."

row = row + 2
IF row >= (height-1) THEN
  DO
    SAY
    SAY
    row = height - 3
  END

BreakFoil:
SIGNAL ON HALT NAME BreakFoil;

DO UNTIL password = checkpass
  col = 29
  PARSE VALUE SysCurPos(row, 0) with x y
  SAY COPIES(' ',width)
  PARSE VALUE SysCurPos(row, 0) with x y
  SAY BlueOnBlack "Please enter the password ->"
  password = ""
  DO UNTIL (C2D(key) = 13) | (col = width)
    PARSE VALUE SysCurPos(row, col) with x y
    key = SysGetKey('NOECHO')

    IF C2D(key) = 8 THEN
      DO
        IF col > 28 THEN
          DO
            col = col - 1
            PARSE VALUE SysCurPos(row, col) with x y
            SAY " "
            password = LEFT(password, LENGTH(password) - 1)
          END
      END
    ELSE
      DO
        SAY "*"
        password = INSERT(key, password, LENGTH(password))
        col = col + 1
      END
  END
END

NiceExit:
SAY Normal
SAY BlueOnBlack "RxLogin v1.0b2, copyright (c) 1997, darkpoet productions, inc."
SAY Normal
