/* A UPN calculator class */


::REQUIRES Stack

::CLASS UpnStack SUBCLASS Stack PUBLIC

::METHOD plus
  x = self~pop
  y = self~pop
  self~push(x + y)

::METHOD '+'
  x = self~pop
  y = self~pop
  self~push(x + y)

::METHOD '*'
  x = self~pop
  y = self~pop
  self~push(x * y)

::METHOD '/'
  x = self~pop
  y = self~pop
  self~push(y / x)

::METHOD '-'
  x = self~pop
  y = self~pop
  self~push(y - x)

  
::METHOD String
  return 'UPN Stack'