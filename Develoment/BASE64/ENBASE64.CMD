/* Encodes a file in Base64.                         */
/*                                                   */
/* Written by James L. Dean                          */
char_set='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
CALL CHAROUT,'Input? '
input_file_name=LINEIN()
CALL CHAROUT,'Output? '
output_file_name=LINEIN()
SAY 'Writing "'output_file_name'".'
CALL RxFuncAdd 'SysFileDelete','RexxUtil','SysFileDelete'
i=SysFileDelete(output_file_name)
input_eof=0
col_num=1
DO WHILE (input_eof = 0)
  num_octets=0
  triple=0
  DO octet_num=1 TO 3
    IF input_eof = 0 THEN
      DO
        octet=CHARIN(input_file_name)
        IF LENGTH(octet) = 0 THEN
          input_eof=-1
      END
    IF input_eof = 0 THEN
      DO
        triple=256*triple+C2D(octet)
        num_octets=num_octets+1
      END
    ELSE
      triple=256*triple
  END
  num_sextets=(8*num_octets)%6
  IF 6*num_sextets < 8*num_octets THEN
    num_sextets=num_sextets+1
  IF num_sextets > 0 THEN
    DO
      sextet_num=1
      DO WHILE(sextet_num <= 4)
        quotient=triple%64
        stack.sextet_num=triple-64*quotient
        sextet_num=sextet_num+1
        triple=quotient
      END
      DO WHILE(num_sextets >= 1)
        sextet_num=sextet_num-1
        rc=CHAROUT(output_file_name,SUBSTR(char_set,1+stack.sextet_num,1))
        col_num=col_num+1
        IF col_num > 76 THEN
          DO
            rc=CHAROUT(output_file_name,D2C(13))
            rc=CHAROUT(output_file_name,D2C(10))
            col_num=1
          END
        num_sextets=num_sextets-1
      END
      DO WHILE(sextet_num > 1)
        rc=CHAROUT(output_file_name,'=')
        col_num=col_num+1
        IF col_num > 76 THEN
          DO
            rc=CHAROUT(output_file_name,D2C(13))
            rc=CHAROUT(output_file_name,D2C(10))
            col_num=1
          END
        sextet_num=sextet_num-1
      END
    END
END
IF col_num > 1 THEN
  DO
    rc=CHAROUT(output_file_name,D2C(13))
    rc=CHAROUT(output_file_name,D2C(10))
  END
