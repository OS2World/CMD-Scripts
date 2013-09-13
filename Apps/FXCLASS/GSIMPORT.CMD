/*  */                                                                  
   Arguments = 'd:\faxworks\PS2FaxTF.PSPIPE'
   FaxOperator = .FxOperator~new
    ResultCode = FaxOperator~Submit('import 'Arguments)
   SAY ResultCode
   exit

::REQUIRES FxMObj.CLS
