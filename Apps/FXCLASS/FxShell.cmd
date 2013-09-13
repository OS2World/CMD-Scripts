/*  */                                                                  

DO UNTIL ARGUMENTS~Translate = 'EXIT' | Arguments~Translate = 'QUIT'
   SAY 'FxShell Command List'
   SAY '------------------------------------------------------------------------'
   SAY 'Command      Parameters'   
   SAY '------------------------------------------------------------------------'
   SAY 'Send|Queue   File2Fax;TO=n,c,F#;FROM=n,c,v#,F#;INFO=c,h,n,b,s,1-3;AT=t,d'
   SAY 'Import       Source'
   SAY 'Status       Tag#'
   SAY 'Report       Index#'
   SAY 'Copy|Export  Source;Target'
   SAY 'TextToFax    Source;Target'
   SAY 'Delete       -Index or Tag'
   SAY 'Exit|Quit'
   SAY '------------------------------------------------------------------------'
   Arguments = linein()
   IF ARGUMENTS~Translate = 'EXIT' | Arguments~Translate = 'QUIT' THEN DO
       SAY ' '
       SAY 'Goodbye!'
       EXIT
       END
   ELSE DO
     SAY' '
     FaxOperator = .FxOperator~new
     ResultCode = FaxOperator~Submit(Arguments)
     SAY ResultCode
     SAY ' '
     SAY '------------------------------------------------------------------------'      
   END
END

::REQUIRES FxMObj.CLS
