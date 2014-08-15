/************************************************************************/
/*                                                                      */
/*   Program: Indentr.cmd                                               */
/*                                                                      */
/*   Purpose: Properly indents REXX programs                            */
/*                                                                      */
/*                                                                      */
/* Arguments: Filename.cmd                                              */
/*                                                                      */
/*   Returns: Modified file (original in *.bak)                         */
/*                                                                      */
/* Copyright: 1999 by J R Casey Bralla                                  */
/*            http://www.NerdWorld.org/indenter.html                    */
/*                                                                      */
/*            See ReadMe.Now for additional info                        */
/*                                                                      */
/*            See Shamelss.plg for a shameless advertisement            */
/*                                                                      */
/************************************************************************/

Parse Arg SourceFileName


  FileName = Left(SourceFileName, Length(SourceFileName)-4)

DestinationFileName = FileName || ".$$$"




Indent = 0              /* Running Indention amount */
IndentAmount = 5        /* The number of spaces to indent each level */




/* Read in Source File Line by Line */

Do While Lines(SourceFileName)

  LineToWorkOn = LineIn(SourceFileName)


  /* Strip away the comments temporarily */
  /* This will force the formatting to ignore any comments */
  CommentPosition = Pos("/*", LineToWorkOn)  /* */
  CommentLine = ""
  If CommentPosition > 0 Then Do
    CommentPosition = CommentPosition - 1
    CommentLine = Right(LineToWorkOn, Length(LineToWorkOn)- CommentPosition)
    LineToWorkOn = Left(LineToWorkOn, CommentPosition)
  End


  /* Temporarily pad extra spaces on front and rear of line */
  LineToWorkOn = "   " || LineToWorkOn || " "



  /* Check for Specific Keywords */

  /* "Do" Keyword */
  DoPosition = LastPos("Do", LineToWorkOn)

  If DoPosition > 0 Then Do

    /* Check to be sure these words aren't buried inside another word */
    If Substr(LineToWorkOn, DoPosition + 2 ,1) \= " "  | Substr(LineToWorkOn, DoPosition - 1 ,1) \= " " Then Do
      DoPosition = 0
    End

  End


  /* "End" Keyword */
  EndPosition = Pos("End", LineToWorkOn)

  If EndPosition > 0 Then Do

    /* Check to be sure these words aren't buried inside another word */
    If Substr(LineToWorkOn, EndPosition + 3 ,1) \= " "  | Substr(LineToWorkOn, EndPosition - 1 ,1) \= " " Then Do
    EndPosition = 0
    End
  End

  /* Strip Leading and trailing spaces */
  LineToWorkOn = Strip(LineToWorkOn,"Leading")
  LineLength = Length(LineToWorkOn)
  If LineLength = 0 Then LineToWorkOn = " "  /* Always have at least one space */
  LineToWorkOn =  Left(LineToWorkOn, ( Length(LineToWorkOn) - 1) ) /* Strip trailing space */



  /* Add back in the comment portion */
  LineToWorkOn = LineToWorkOn || CommentLine

  /* Rewrite the Line, incorporating the indention count */
  LineToWrite = Copies(" ",Indent) || LineToWorkOn
  Call LineOut DestinationFileName, LineToWrite






  /* Adjust Indention based on keywords */

  If  DoPosition > 0 Then Indent = Indent + IndentAmount
  If EndPosition > 0 Then Indent = Indent - IndentAmount

  If Indent < 0 Then Do
    Say "Error:  Indent less than Zero"
    Call Beep 450, 750
    /* Exit */
    Indent = 0
    Call LineOut DestinationFileName, "/*  Error!   Indentation less than Zero! */"
    End



End



Call Stream DestinationFileName, "Command", "Close"
Call Stream      SourceFileName, "Command", "Close"






/* Delete the old backup file */

"@IF EXIST " || FileName || ".bak DEL " || FileName || ".bak"


/* Rename the *.cmd file to *.bak" */

"@REN " || SourceFileName || " " || FileName || ".bak"


/* Rename the *.$$$ file to *.cmd */

"@REN " || DestinationFileName || " " || FileName || ".cmd"

Return
