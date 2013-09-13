/*  */                                                                  

   Arguments = Arg(1)
    FaxOperator = .FxOperator~new
    ResultCode = FaxOperator~Submit('queue 'Arguments)
   SAY ResultCode
   exit

::REQUIRES FxMObj.CLS
