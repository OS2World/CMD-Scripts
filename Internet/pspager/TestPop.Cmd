@echo off
:Main
  cls
  if not "%1" == "" goto :%1

:Test1
  echo Titel: DEFAULT
  echo Text:  -
  echo B1:    -
  echo B2:    -
  echo B3:    -
  echo T:     -
  echo SM:    Nein
  pause
  set weiter=Test2
  pmpopup2
  if errorlevel 40 goto :40
  if errorlevel 30 goto :30
  if errorlevel 20 goto :20
  if errorlevel 10 goto :10

:Test2
  echo.
  echo ------------------------------------------------------
  echo Titel: DEFAULT
  echo Text:  eine Zeile
  echo B1:    -
  echo B2:    DEFAULT
  echo B3:    -
  echo T:     -
  echo SM:    Nein
  pause
  set weiter=Test3
  pmpopup2 "Dies ist ein Einzeiler"
  if errorlevel 40 goto :40
  if errorlevel 30 goto :30
  if errorlevel 20 goto :20
  if errorlevel 10 goto :10

:Test3
  echo.
  echo ------------------------------------------------------
  echo Titel: Testfall 3
  echo Text:  drei Zeilen
  echo B1:    ach!
  echo B2:    -
  echo B3:    so!
  echo T:     -
  echo SM:    Nein
  pause
  set weiter=Test4
  pmpopup2 "Dies ist ein Einzeiler~...~Oder doch nicht?" "Testfall 3" /b1:"ach!" /b3:"so!" /bell
  if errorlevel 40 goto :40
  if errorlevel 30 goto :30
  if errorlevel 20 goto :20
  if errorlevel 10 goto :10

:Test4
  echo.
  echo ------------------------------------------------------
  echo Titel: Testfall 4
  echo Text:  zwei Zeilen
  echo B1:    -
  echo B2:    -
  echo B3:    -
  echo T:     5
  echo SM:    Nein
  pause
  set weiter=Test5a
  pmpopup2 "~Diese Box schlie·t sich in 5 Sekunden." "Testfall 4" /t:5 /a:c
  if errorlevel 40 goto :40
  if errorlevel 30 goto :30
  if errorlevel 20 goto :20
  if errorlevel 10 goto :10

:Test5a
  echo.
  echo ------------------------------------------------------
  echo Titel: Testfall 5a
  echo Text:  fÅnf Zeile
  echo B1:    -
  echo B2:    Sofort aus!
  echo B3:    -
  echo T:     15
  echo SM:    Ja
  pause
  set weiter=Test5b
  pmpopup2 "Diese Box schlie·t sich in 15 Sekunden.~Oder Åber den Button.~Die Box ist systemmodal!" "Testfall 5a" /t:15 /b2:"Sofort aus!" /f:"10.Courier" /sm /bell
  if errorlevel 40 goto :40
  if errorlevel 30 goto :30
  if errorlevel 20 goto :20
  if errorlevel 10 goto :10

:Test5b
  echo.
  echo ------------------------------------------------------
  echo Titel: Testfall 5b
  echo Text:  fÅnf Zeile
  echo B1:    -
  echo B2:    Sofort aus!
  echo B3:    -
  echo T:     15
  echo SM:    Ja
  pause
  set weiter=ende
  pmpopup2 "Diese Box schlie·t sich in 15 Sekunden.~Oder Åber den Button.~Die Box ist systemmodal!" "Testfall 5b" /t:15 /b2:"~Sofort aus!" /f:"10.Helv" /sm
  if errorlevel 40 goto :40
  if errorlevel 30 goto :30
  if errorlevel 20 goto :20
  if errorlevel 10 goto :10

:ByeBye
  goto :ende

:40
  echo.
  echo TimeOut
  goto :%weiter%

:30
  echo.
  echo 3. (rechter) Button
  goto :%weiter%

:20
  echo.
  echo 2. (mittlerer) Button
  goto :%weiter%

:10
  echo.
  echo 1. (linker) Button
  goto :%weiter%

:ende

