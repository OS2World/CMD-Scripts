/*    */
/*     Prompted DIR listing with scrolling

       Usage: REXXDIR filename screen_size
       Where: filename is any valid OS/2 filename
            : Screen_size is the size of the virtual screen

       I used DOS compatability file types.
*/
arg  filename  screen_size .        /* get arguments   */
file_out = 'REXXDIR.TXT'            /* set up the work file   */
/*   check the filename */
r_c = 0
if length(filename) > 12 or length(filename) < 1
then do
     say 'The filename ('filename') is invalid'
     r_c = 1
     end
/* check the screen size value   */


if  datatype(screen_size,'W') = 0        /* Is it a whole number ? */
        then do
             say 'The screen size ('screen_size') is invalid'
             r_c = 1
             end
if screen_size < 2                       /* we need some lines   */
        then do
             say 'The screen size ('screen_size') is too low, invalid'
             r_c = 1
             end

/* if r_c does not equal zero, there was an error. Display the
   lines 4 to end as help.
   I like this method as it keeps my help files honest.
   Not that I ever need ......
*/
if r_c <> 0                          /* any problems ? 1 = yes 0 = No */
then do
       say ; say ;
       do line = 4 while substr(sourceline(line),1,2) <> '*/'
       say sourceline(line)
       end
       return
  end
screen_size = screen_size - 2          /* I need 2 lines    */

/* real work starts here */
/* REXX treats any variable with a '.' as an array, subscripted by
   whatever follows the '.'   2 dimensional matrices are 2 periods
   etc. This variable "FILE_LINE" is subscripted by X_POS to start
   and later by YY. It doesn't matter what variable you use as a
   subscript.
*/

'dir '||filename|| ' > 'file_out      /* pipe the DIR to a file */
 x_pos = 1
do x_pos = 1 while lines(file_out)             /* read the file    */
      file_line.x_pos = linein(file_out)       /* and store in an  */
      end                                      /* array */

cls
x_pos = x_pos - 1                            /* do loop is 1 high */
do XX = 1 to x_pos by screen_size            /* outer loop */
     disp_lines = xx + screen_size           /* show how many ? */
     if disp_lines > x_pos                   /* but only if enough */
        then disp_lines = x_pos              /* loop thru */
     do yy = xx to disp_lines
                 say file_line.yy
                 end
       say 'Press [ENTER] to continue'
       pull answer                        /* get a response using PULL */
       cls
  end
