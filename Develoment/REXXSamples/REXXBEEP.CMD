/*    */
/*    Ring the bell. Every single programming text I have ever read
      has a bell program so I've added one to the list.

      Usage: REXXBEEP music_file .
      Where: music_file is the name of an OS/2 file that contains
             frequency values. These values will be played.

The file is in the format
440 8
330 12
.
.

Where the first number is the frequency and the second number
is the duration. Just stop when you run out of notes.
*/

NULL = ''                              /* Whats the null  */
HELPME = '?'                           /* How do we get help */

arg music_file .                     /* the . is garbage collection
                                        in case there are additional
                                        arguments not needed       */

if music_file = NULL                  /* if it's null use mine */
then file_in = 'REXXBEEP.MUS'         /* default file name */
else file_in = arg(1)                 /* your file name   */
                                      /* Someone could check
                                         if the files exist. Nahhhh */

if arg(1) = HELPME                   /* show lines 6 to 17  */
    then  do line = 5 while substr(sourceline(line),1,2) <> '*/'
              say sourceline(line)
              end

do xx = 1 while lines(file_in)   /* increment XX while reading lines */
   beeptext=linein(file_in)      /* get a line */
   push beeptext                 /* push the value on the stack */
   pull beepfreq duration .      /* pull it back but in 2 parts    */	
   beep(beepfreq, duration)      /*  beep   */
   end

/* to avoid the firestorm caused by using this. I just wanted to
demonstrate HOW to use the PUSH and PULL stuff. There are
obviously ways ( PARSE) to get the answer in one line without
using the stack.
*/

return
