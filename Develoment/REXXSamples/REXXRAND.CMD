/*   */
/*   Program to generate some random numbers and store them in an array
      using REXX. The numbers are first calculated and stored. Then they are
      reported two at a time.

      usage: REXXRAND min_range max_range how_many
      where : min_range is the lowest acceptable random number
                   min_range is the highest acceptable random number
                   how_many is the number of samples.

                   All 3 MUST be whole positive numbers.

*/
/* I refuse to argue if 0 is a positive number !!!!!!  */
arg min_range max_range  how_many .
/*   period at the end catches any more than 3 arguments */

rc = 0                                                                                           /* set return code */
if datatype(min_range,'W') = 0                                                    /* check if it's a whow number */
then do      							    /* it's an error */
         say 'Min_range (' min_range ')  is not a whole number.'
          rc = 1 							    /* set return code */
          end

if datatype(max_range,'W') = 0                                               /* do it again for max_range */
then do
         say 'Max_range (' max_range ')  is not a whole number.'
         rc = 1
         end
if datatype(how_many,'W') = 0            			   /* and for how_many */	
then do
         say 'How_many (' how_many ')  is not a whole number.'
         rc = 1
         end
if max_range < min_range
then do
         say 'Max_range (' max_range ') must be greater than Min_range (' min_range ').'
         rc = 1
         end
if max_range < 0
then do
         say 'Max_range (' max_range ') must be greater than 0.'
         rc = 1
         end
if min_range < 0
then do
         say 'Min_range (' min_range ') must be greater than 0.'
         rc = 1
         end
if how_many < 0
then do
         say 'How_many (' how_many ') must be greater than 0.'
         rc = 1
         end

if rc > 0
     then do
   		say ; say ;                                  		      /* 2 blank lines */	
      								      /* loop thru source and display
     								      the syntax stuff   */	
    		do line = 6 while substr(sourceline(line),1,2) <> '*/'
             		say sourceline(line)
              		end
   	return
             end
								   /*   It's OK, do it */
								   /*   Use x as the subscript
								         and loop from 1 to how_many
    								         and fill with random numbers
								  */			
do x = 1 to how_many						
     result.x = random(min_range,max_range)                          /* x is the subscript       */
end x 								  /* end of x loop   */


say 'Show  samples in steps of 2'                                               /* start showing */


if how_many//2 <> 0
   	then display_loop = how_many - 1
            else display_loop = how_many

do x = 1 to display_loop  by 2 					   /* 1 to how_many in steps of 2 */
     Say 'Sample ' x ' was ' result.x '      Sample ' x+1 ' was ' result.x+1
end x								   /* end of loop */	
if display_loop <> how_many
  then Say 'Sample ' x ' was ' result.x
return								   /* exit program */

