/**/

cls = Get()

IF ARG(1) = '' THEN DO
  CALL Bin2Stem cls
  CALL View
  END
 ELSE DO
  CALL Read ARG(1)
  cls = Stem2Bin(cls)
  SAY "Really replace class list [Y/N]?"
  PULL ret
  IF ret = 'Y' THEN
    CALL Set cls
  END
EXIT

/*CALL CHAROUT 'test.bin', cls*/

Bin2Stem: PROCEDURE EXPOSE cls.
  cls = SUBSTR(ARG(1),9)
  n = 0
  DO WHILE LENGTH(cls) \= 0
    l1 = C2D(REVERSE(SUBSTR(cls, 1, 4)))
    l2 = C2D(REVERSE(SUBSTR(cls, 5, 4)))
    p = POS('00'x, cls, 9)
    fn = SUBSTR(cls, 9, p-9)
    q = POS('00'x, cls, p+1)
    dll = SUBSTR(cls, p+1, q-p-1)
    cls = SUBSTR(cls, q+1)
    n = n + 1
    cls.n = l1'09'x||l2'09'x||fn'09'x||dll
    END
  cls.0 = n
  RETURN n

Stem2Bin: PROCEDURE EXPOSE cls.
  ret = ''
  DO i = 1 TO cls.0
    PARSE VAR cls.i l1'09'x l2'09'x fn'09'x dll
    IF dll = '' THEN
      CALL Error 11, "Systax error in input data: "cls.i
    ret = ret||REVERSE(D2C(l1,4))||REVERSE(D2C(l2,4))||fn'00'x||dll'00'x
    END
  RETURN OVERLAY(REVERSE(D2C(LENGTH(ret)+8,2)), LEFT(ARG(1),8), 3)ret

View: PROCEDURE EXPOSE cls.
  DO i = 1 TO cls.0
    SAY cls.i
    END
  RETURN

Read: PROCEDURE EXPOSE cls.
  IF STREAM(ARG(1), 'c', 'open read') \= 'READY:' THEN
    CALL Error 10, 'Failed to open 'ARG(1)
  n = 0
  DO WHILE STREAM(ARG(1), 's') = 'READY'
    l = LINEIN(ARG(1))
    IF l = '' THEN
      ITERATE
    n = n + 1
    cls.n = l
    END
  cls.0 = n
  RETURN

Get: PROCEDURE
  RETURN SysIni("SYSTEM", "PM_Objects", "ClassTable")

Set: PROCEDURE
  CALL SysIni "SYSTEM", "PM_Objects", "ClassTable", ARG(1)
  RETURN

Error: PROCEDURE
   CALL LINEOUT STDERR, ARG(2)
   EXIT ARG(1)


