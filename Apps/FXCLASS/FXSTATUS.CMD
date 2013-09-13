/*  */                                                                  

   Arguments = Arg(1)
    FaxOperator = .FxOperator~new
    ResultCode = FaxOperator~Submit('status 'Arguments)
   SAY ResultCode
   exit

::REQUIRES FxMObj.CLS
