/* Decodes a Base64 file.                            */
/*                                                   */
/* Written by James L. Dean                          */
char_set='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
DO n=0 to 127
  t.n=-1
END
DO n=0 to 63
  i=C2D(SUBSTR(char_set,n+1,1))
  t.i=n
END
CALL CHAROUT,'Input? '
input_file_name=LINEIN()
CALL CHAROUT,'Output? '
output_file_name=LINEIN()
SAY 'Writing "'output_file_name'".'
CALL RxFuncAdd 'SysFileDelete','RexxUtil','SysFileDelete'
i=SysFileDelete(output_file_name)
input_line=''
input_line_index=81
input_eof=0
DO WHILE (input_eof = 0)
  sextet_num=1
  num_bits=0
  DO WHILE(sextet_num <= 4)
    DO WHILE((input_eof = 0) & (input_line_index > LENGTH(input_line)))
      IF LINES(input_file_name) = 0 THEN
        input_eof=-1
      ELSE
        DO
          input_line=LINEIN(input_file_name)
          input_line_index=1
        END
    END
    IF input_eof = 0 THEN
      DO
        i=C2D(SUBSTR(input_line,input_line_index,1))
        input_line_index=input_line_index+1
        t1=t.i
        IF t1 >= 0 THEN
          DO
            sextet.sextet_num=t1
            num_bits=num_bits+6
            sextet_num=sextet_num+1
          END
      END
    ELSE
      DO
        sextet.sextet_num=0
        sextet_num=sextet_num+1
      END
  END
  IF num_bits >= 8 THEN
    DO
      t1=sextet.1
      t2=sextet.2
      CALL CHAROUT output_file_name,D2C(4*t1+t2%16)
      num_bits=num_bits-8
    END
  IF num_bits >= 8 THEN
    DO
      t1=sextet.3
      CALL CHAROUT output_file_name,D2C(16*(t2//16)+(t1%4))
      num_bits=num_bits-8
    END
  IF num_bits >= 8 THEN
    DO
      t2=sextet.4
      CALL CHAROUT output_file_name,D2C(64*(t1//4)+t2)
    END
END
