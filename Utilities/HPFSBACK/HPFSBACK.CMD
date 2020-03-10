/* HPFSBAK.CMD   Backs up HPFS Volume to a FAT volume using ZOO.EXE and 
EABACKUP.EXE.
   Both files must be in your path (get these from any BBS ).
   I created this for those of us who don't have  a way to backup our HPFS 
drives (because our tape drive
   manufacturers don't support OS/2 and HPFS).  You can then use your tape 
drive software under DOS to
   backup the large file created on your FAT drive.  This file should reside 
on your HPFS volume */
   
/*
          Useage: HPFSBAK s: d: filename
           Where: HPFSBAK is this REXX file.
           s: is your HPFS source drive
           d: is a FAT drive with space free (lots!)
           filename is the name to which the .ZOO extension will be added 
*/
ARG source  dest  d_path
argtester(source,'source drive',dest,'destination drive',d_path,'filename')

argtester:    /* Check for valid arguements and say what's wrong if they're 
not */
Return_Code = 0  /* Start with everything set to normal */
DO i = 1 TO 5 BY 2 
    IF ARG(i) = " " 
    THEN DO
 SAY "You must supply a " || arg(i + 1)
 Return_Code = 1   /* Something's wrong with the syntax or options */
    END
END

 /* If arguements are valid execute EABACKUP.EXE to backup extended 
attributes and store  them on the root of the HPFS volume.  Build file tree 
by executing TREE.EXE on HPFS drive  and send the output to a temporary file 
(Tree.File).  Read Tree.File and extract only the paths.   Fix the paths that 
have spaces in them and then execute ZOO.EXE instructing it to store all 
files  in the path.  Repeat this process for all paths, and append to the 
.ZOO file.  */
     
main:
IF Return_Code = 0 
THEN DO
 ADDRESS CMD eabackup source source '/s'
 ADDRESS CMD 'TREE > Tree.File'
 DO WHILE LINES(Tree.File)
      thisline = LINEIN(Tree.File,,1)
      IF POS('Path: ',thisline) = 1
          THEN CALL out_file
      ELSE;
           NOP
 END
 CALL end_it

out_file:
 newstring = SUBWORD(thisline,2)
 newstring = source||newstring||'\*'
 numspaces =(WORDS(newstring)-1)
 num_questions = numspaces
 IF numspaces \= 0
      THEN
      CALL fix_string
 ELSE
 NOP
 ADDRESS CMD 'zoo ah '||dest||'\'||d_path||'.zoo' newstring
 RETURN

fix_string: /* If there are spaces in the path, replace each with 3 question 
marks (a character that will not  appear in legal filenames), then change 
these to a quoted space which ZOO.EXE can handle */

DO WHILE numspaces >> 0
 numspaces = numspaces -1
 space_test = POS(' ',newstring)
 newstring = DELSTR(newstring,space_test,1)
 newstring = INSERT(???,newstring,space_test-1,)
END

DO WHILE num_questions >> 0
 num_questions = num_questions -1
 space_test = POS('???',newstring)
 newstring = OVERLAY('" "',newstring,space_test)
END
RETURN

END
IF Return_Code <> 0  /* If something's wrong with the arguements, display 
lines 8 to end of comment */
THEN DO
 SAY ; SAY ;
 DO LINE = 8 WHILE SUBSTR(Sourceline(line),1,2)  <> '*/'
 SAY Sourceline(line)
 END
END
EXIT 1

end_it:
EXIT 1
