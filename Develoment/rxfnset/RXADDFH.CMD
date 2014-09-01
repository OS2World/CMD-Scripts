/* */
Say "Sample Rexx program for demonstrating RXADDFH function"
Say "RxFnSet by Leshek Fiedorowicz"
Say
                                                                        
Arg Number
    Call RxFuncDrop 'RXADDFH'

    Call RxFuncAdd 'RXADDFH', 'RXFN32', 'RXADDFH'

    Call RXADDFH 0
    OriginalNumber = result /* Query original number of FH */

    Call RXADDFH Number

    select;
      when result = 0 then do
            say 'ERROR - Invalid parameter ('Number').'
            say '        Specified parameter was not valid number or is less'
            say '        then zero.'
         end
      when result \= (OriginalNumber+Number) then do 
         say 'WARNING - Unable to alocate requested number of File Handles.'
         say '          Number of FH allocated is 'result'.'
         say '          Posible reason - not enough memory available.'
      end
      Otherwise 
         say '   'Number' of FH succesfully added.'  
         say '   Total of 'result' is now available.'

    End;
    Call RxFuncDrop 'RXADDFH'
Exit
