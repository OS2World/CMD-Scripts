/*  */                                                                  

   Arguments = Arg(1)
    FaxOperator = .FxOperator~new
    ResultCode = FaxOperator~Submit('import 'Arguments)
   SAY ResultCode
   exit

::REQUIRES FxMObj.CLS
