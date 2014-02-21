/*-----------------------------------------------------------------------------+
|   Arin mp3puristin v2000.03.20                   http://www.tec.puv.fi/~k3   |
|   HaLPaRoTuKTioNS 2000                           e-mail:k3@sah.tec.puv.fi    |
+-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------+
| THIS SCRIPT NEEDS TO BE COMPETITELY REWRITTEN. THIS IS MY FIRST REXX SCRIPT. |
|       KEEP THAT IN MIND WHILE INVESTIGATING THE SECRETS OF MP3PURISTIN       |
+-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------+
|  You can modify mp3puristin as much as you like! I've made this to fill      |
|  my needs... so if you need something, just add it! Send me a copy of the    |
|  modified version and some sort of description about the changes...          |
+-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------+
|                                                                              |
|      History: ! = fix ... + = added somethig ... - = removed something       |
|                                                                              |
|  990914: + First working version... Everything new!!!                        |
|  0.01    + Leech and Lame supported                                          |
|                                                                              |
|  990915: ! Some major fixes                                                  |
|  0.10    + Colors                                                            |
|                                                                              |
|  990916: + User can define which tracks to be encoded                        |
|  0.15                                                                        |
|                                                                              |
|  990922: ! Something...                                                      |
|  0.16                                                                        |
|                                                                              |
|  991013: + Mono encoding now uses -a switch                                  |
|  0.17    ! Some defaults added and redefined...                              |
|                                                                              |
|  991101: ! Uups! There was missing some sections, sorry.                     |
|  0.18    ! Uuups uups... ...now fixed...                                     |
|                                                                              |
|  991203  + variable filename ( by Andreas.Ebbert@gmx.de )                    |
|  0.20    ! comments are now in english also.                                 |
|                                                                              |
|  000315  + language selection; MP3 destination drive selection               |
|  0.25    ! Done by Przemyslaw Pawelczyk - warpman@poczta.fm                  |
|          ! Fixed the CD-drive bug (CD in drive f:)                           |
|                                                                              |
|                                                                              |
+-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------+
|              >>>>>>>>>>>>>>  VERY IMPORTANT   <<<<<<<<<<<<<<<                |
|                                                                              |
|  1. REXX has to be installed.                                                |
|  2. LAME and LEECH directories must be in a PATH.                            |
+-----------------------------------------------------------------------------*/


/*-----------------------------------------------------------------------------+
|  Fin: P��ohjelma                                                             |
|  Eng:                        PROGRAM'S MAIN BODY                             |
+-----------------------------------------------------------------------------*/
TIME('E')
CALL alustus

/*-----------------------------------------------------------------------------+
|  YOU CAN CHANGE THE LANGUAGE FOR LANGUAGE SELECTION BELOW FOR:               |
|  Fin: Finnish_language                                                       |
|  Eng: English_language                                                       |
|  Pol: Polish_language                                                        |
+-----------------------------------------------------------------------------*/
CALL English_language
CALL SelectLanguage
CALL infoscreen_1
IF modex ='Y' THEN CALL muuta
CALL modes
CALL infoscreen_2
IF modex ='Y' THEN CALL FileNameChange
CALL leech
CALL lameta
SAY
SAY
SAY Mylang.1 TIME('R')' s.'
SAY Mylang.2

EXIT


/*-----------------------------------------------------------------------------+
|  Procedures                                                                  |
+-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------+
|  Fin: Alkuinfo, esitet��n                                                    |
|  Eng: Infoscreen_1                                                           |
|  Pol: Ekran pierwszy                                                         |
+-----------------------------------------------------------------------------*/
INFOSCREEN_1:
  SAY Mylang.3
  SAY Mylang.4
  SAY Mylang.5
  SAY Mylang.6
  SAY Mylang.7
  SAY Mylang.57
  SAY Mylang.58
  SAY
  SAY Mylang.8
  SAY Mylang.9
  SAY
  SAY Mylang.10
  SAY Mylang.11
  SAY
  SAY Mylang.12
  SAY Mylang.13
  SAY Mylang.14
  SAY Mylang.15
  SAY Mylang.16
  SAY Mylang.17
  SAY
  SAY Mylang.18
  PULL modex .
RETURN

/*-----------------------------------------------------------------------------+
|  Fin: Alkuinfo, esitet��n                                                    |
|  Eng: Infoscreen_2                                                           |
|  Pol: Ekran drugi                                                            |
+-----------------------------------------------------------------------------*/
INFOSCREEN_2:
  SAY
  SAY Mylang.19 filename
  SAY
  SAY Mylang.20
  PULL modex     
RETURN

/*-----------------------------------------------------------------------------+
|  Fin: Tehd��n muutama tarpeellinen v�ri...                                   |
|  Eng: Let's make some colors and default parameters...                       |
|  Pol: Definiowanie kolor�w i innych parametr�w...                            |
+-----------------------------------------------------------------------------*/
ALUSTUS:
  'cls'
  es='1b'x'[1;3'
  re=es'1m'; gr=es'2m'; ye=es'3m'; bl=es'4m'; pu=es'5m'; cy=es'6m'; wh=es'7m'
  ez='1b'x'[;3'
  gray=ez'7m'

  /* Alkuasetukset / Defaults */
  smode='-m j'
  buffor='-w1024'
  br=' 128'
  quality='-h'
  vari='  '
  vbr= '  '
  mono='  '
  filename='track'    
RETURN

/*-----------------------------------------------------------------------------+
|  Fin: Esitet��n kaikki moodit                                                |
|  Eng: Shaw all modes                                                         |
|  Pol: Poka� wszystkie opcje                                                  |
+-----------------------------------------------------------------------------*/
MODES:
  SAY Mylang.21
  SAY Mylang.22 smode
  SAY Mylang.23 br
  SAY Mylang.24 quality
  SAY
  SAY Mylang.25 vari
  SAY Mylang.26 vbr
  SAY wh'lame 'smode' -b'br' 'quality' 'vari' 'vbr' <in.wav> <out.mp3>'gray
  SAY
RETURN

/*-----------------------------------------------------------------------------+
|  Fin: Luetaan tietoja CD:lt�                                                 |
|  Eng: Getting some information about CD                                      |
|  Pol: Pobieranie informacji o CD                                             |
+-----------------------------------------------------------------------------*/
LEECH:
  SAY Mylang.27
  SAY Mylang.28  
  PULL drive

  SAY Mylang.29
  SAY Mylang.30
  SAY Mylang.31
  SAY Mylang.70  
  PULL mp3drive

  SAY Mylang.32
  '@leech 'drive': TOC'
  SAY Mylang.33
  SAY Mylang.34
  PULL track_first

  SAY Mylang.35
  PULL track_last
RETURN

/*-----------------------------------------------------------------------------+
|  Fin: Grabbaus Leechill� ja encoodaus Lamella                                |
|  Eng: Leech and Lame                                                         |
|  Pol: Uruchom programy leech i lame.                                         |
+-----------------------------------------------------------------------------*/
LAMETA:
  DO WHILE track_first <= track_last

    '@leech 'drive': track 'track_first' "'mp3drive || filename'" 'buffor
    IF track_first < 10 THEN DO
      filenameWAV = mp3drive || filename'_0'track_first'.wav'
      filenameMP3 = mp3drive || filename'_0'track_first'.mp3'
    END        
    ELSE DO
      filenameWAV = mp3drive || filename'_'track_first'.wav'
      filenameMP3 = mp3drive || filename'_'track_first'.mp3'
    END
                 
    '@lame  'smode' -b 'br' 'quality' 'vari' 'vbr' 'mono' "'filenameWAV'" "' ||,
            filenameMP3'"'
    '@del "'filenameWAV'" >nul'
  
    track_first=track_first + 1
  END    
RETURN    

/*-----------------------------------------------------------------------------+
|  Fin: Asetuksien muuttaminen tehd��n t��ll�                                  |
|  Eng: Changing the options                                                   |
|  Pol: Zmiana parametr�w                                                      |
+-----------------------------------------------------------------------------*/
MUUTA:
  SAY
  SAY Mylang.36
  SAY Mylang.37
  SAY Mylang.38
  SAY Mylang.39
  SAY Mylang.56
  SAY Mylang.40
  SAY Mylang.41
  
  PULL custom
  IF custom='F' THEN DO
    smode=' -m m '
    mono =' -a '
    br=' 80 '
    quality='  '
    vari='  '
    vbr=' '
    RETURN
  END
  
  IF custom='E' THEN DO
    smode=' -m s '
    br=' 128 '
    quality=' -h '
    vari=' -v '
    vbr=' -V 6'
    RETURN
  END
  
  IF custom='D' THEN DO
    smode=' -m j '
    br=' 112'
    quality=' -h '
    vari=' -v '
    vbr=' -V 4'
    RETURN
  END
  
  IF custom='C' THEN DO
    smode=' -m s '
    br=' 192 '
    quality=' -h '
    RETURN
  END

  IF custom='B' THEN DO
    smode=" -m s "
    br=' 160 '
    quality=' -h '
    RETURN
  END
  ELSE DO     /* ------------------------------------------------------------ */
    SAY Mylang.42
    PULL smodex
    IF smodex='S' THEN smode="-m s"
    IF smodex='F' THEN smode="-m f"
    IF smodex='J' THEN smode="-m j"
    IF smodex='M' THEN DO
      smode="-m m"
      mono=" -a "
    END
    
    SAY Mylang.43
    PULL askq
    IF askq='H' THEN quality=' -h '
    IF askq='F' THEN quality=' -f '
    IF askq='N' THEN quality='    '
    
    SAY Mylang.44
    PULL vari
    IF vari='Y' THEN DO
       SAY Mylang.45
       PULL vbr
       tmp=vbr
       vbr='-V 'tmp
       SAY Mylang.46
       vari=' -v '
    END
    ELSE vari=' '
    
    SAY Mylang.47
    PULL br
  END         /* ------------------------------------------------------------ */
RETURN
    
/*-----------------------------------------------------------------------------+
|  Fin: Tiedostonimen muuttaminen                                              |
|  Eng: Changing file name...                                                  |
|  Pol: Zmiana nazwy pliku                                                     |
+-----------------------------------------------------------------------------*/
FILENAMECHANGE:
  SAY
  SAY Mylang.48 filename gray
  SAY Mylang.49
  PARSE PULL filename
  SAY
RETURN

/*-----------------------------------------------------------------------------+
|  Fin: Kielen valinta                                                         |
|  Eng: Select language                                                        |
|  Pol: Wybierz j�zyk                                                          |
+-----------------------------------------------------------------------------*/
SELECTLANGUAGE:
  DO FOREVER
    SAY Mylang.3
    SAY Mylang.4
    SAY Mylang.5
    SAY Mylang.6
    SAY ''
    SAY Mylang.50
    SAY ''
    SAY Mylang.51
    SAY Mylang.52
    SAY Mylang.53
    SAY ''
    SAY Mylang.54
    PULL lang

    IF lang < 1 | lang > 3 THEN DO
      SAY Mylang.55
      iterate
    END
    IF lang >= 1 & lang<=3 THEN LEAVE
  END  /* DO FOREVER */

  SELECT
    WHEN lang = 1 THEN CALL Finnish_language
    WHEN lang = 2 THEN CALL English_language
    WHEN lang = 3 THEN CALL Polish_language
  OTHERWISE 
    CALL English_language
  END /* Select */ 

RETURN

/*-----------------------------------------------------------------------------+
|  Fin: Suomi                                                                        |
|  Eng: Finnish Language                                                       |
|  Pol: J�zyk fi�ski                                                           |
+-----------------------------------------------------------------------------*/
FINNISH_LANGUAGE:
  Mylang.0  = 58
  Mylang.1  = gr'Kiitokset mp3PuRiStiMeN k�yt�st�, k�y my�s katsomassa'
  Mylang.2  = gr'uudet versiot yms. http://www.tec.puv.fi/~k3 'gray
  Mylang.3  = cy'�������������������������������������Ŀ'
  Mylang.4  = cy'� 'gr'MP3PuRiSTiN  RL 2000.03.20 for OS/2 'cy'�'
  Mylang.5  = cy'� 'gr'(v0.25)     (c)2000 HaLPaRoTuKTioNS 'cy'�'
  Mylang.6  = cy'��������������������������������������� '
  Mylang.7  = cy'Kiitokset Andreas Ebbertille nimenmuutosoptiosta'
  Mylang.8  = gr'MP3PuRiSTiN on Freewarea... eli t�ysin ilmainen '||,
              'Jos pid�t t�st� ohjelmasta niin l�het� e-mailia!!!'
Mylang.9  = gr'Nykyinen MP3PuRiSTiMeN versio osaa k�ytt�� vain ' ||,
                  'Grabauksee 'bl'leechi�'gr' ja encoodaukseen'bl' lamea'
  Mylang.10 = re'SCRIPTISS� EI OLE VIRHETARKISTUKSIA, JOTEN ' ||,
                  'KATSO HUOLELLA N�PYTTELYSI SIS��N!!!'
  Mylang.11 = re'Jos jokin menee pieleen -> paina CTRL-C lopettaaksesi...'
  Mylang.12 = wh'Vakioasetukset:'
  Mylang.13 = gr'Mode:    ' cy'joint stereo'
  Mylang.14 = gr'Bitrate: ' cy'128'
  Mylang.15 = gr'Quality: ' cy'High (less speed)'
  Mylang.16 = gr'Grabber: ' cy'Leech'
  Mylang.17 = gr'Encoder: ' cy'Lame'
  Mylang.18 = pu'Haluatko vaihtaa n�it� asetuksia? (y/n)'gray
  Mylang.19 = gr'Tiedoston nimi: ' cy''
  Mylang.20 = pu'Haluatko muuttaa tiedoston nime�? (y/n)'gray
  Mylang.21 = wh'T�ss� ovat kaikki parametrit ilman sepostuksia... ' ||,
                  '�l� v�lit� niist� jos et ymm�rr� :)'
  Mylang.22 = gr'mode     'cy
  Mylang.23 = gr'bitrate  'cy
  Mylang.24 = gr'quality  'cy
  Mylang.25 = gr'variable 'cy
  Mylang.26 = gr'vbr      'cy
  Mylang.27 = pu'Miss� asemassa audio-CD on?'gray
  Mylang.28 = 'Anna ainoastaan asematunnus ilman kaksoispistett�'
  Mylang.29 = pu'Kohdehakemisto?'gray
  Mylang.30 = 'Anna asematunnus + hakemisto, muista kenoviiva per��n!' ||,
                  'Esim. v:\my_mp3\'
  Mylang.31 = 'Tai pelkk� asematunnus, muista kenoviiva per��n       ' ||,
                  'Esim v:\'
  Mylang.32 = wh'Table of Contents / Levyn sis�lt�'gray
  Mylang.33 = wh'Ylh��ll� on TOC, siit� n�et mm. kuinka monta raitaa ' ||,
                'audio-CD:ll� '
  Mylang.34 = pu'Ensimm�inen raita joka encoodataan?'gray
  Mylang.35 = pu'Viimeinen raita joka encoodataan?'gray
  Mylang.36 = wh'Valitse jokin seuraavista vaihtoehdoista:'
  Mylang.37 = pu'a)'wh' Custom (Valitse itse parametrit)'
  Mylang.38 = pu'b)'wh' Stereo, br 160, High quality'
  Mylang.39 = pu'c)'wh' Stereo, br 192, High quality'
Mylang.56   = pu'd)'wh' Joint Stereo, Variable br, min br 112, ' ||,
                  'Vquality 4 (br will be 128-160)'
  Mylang.40 = pu'e)'wh' Stereo, Variable br, min br 128, Vquality 6...'
  Mylang.41 = pu'f)'wh' Mono, br 80... not so good...'
  Mylang.42 = gr'MODE:    'pu'(s)tereo (j)oint, (f)orce or (m)ono? 'gray
  Mylang.43 = gr'QUALITY: 'pu'(h)igh, (f)ast or (n)ormal?'gray
  Mylang.44 = gr'VARIABLE BITRATE: 'pu'(y/n)'gray
  Mylang.45 = gr'VBR QUALITY:'pu' 0=high quality... 9=lowest'gray
  Mylang.46 = wh'OK, seuraava bitrate asettaa pienimm�n sallitun bitraten'gray
  Mylang.47 = gr'BITRATE:'pu' 32,40,56,64,80,96,112,128,160,192,224,256' ||,
                  ' or 320? 'gray
  Mylang.48 = gr'Nykyinen tiedostonimi:'pu 
  Mylang.49 = gr'Uusi nimi (voi sis�lt�� v�lily�ntej� jne.): 'pu
  Mylang.50 = gr'Valitse kieli:'gray
  Mylang.51 = gr'1. Suomi'
  Mylang.52 = cy'2. Englanti'
  Mylang.53 = ye'3. Puola'
  Mylang.54 = gr'Mik� sopii parhaiten:'wh
  Mylang.55 = re'Valitse joko 1, 2 tai 3'
  Mylang.57 = cy'� 'ye'Andreas Ebbert 'cy'- FileNameChange optionista'
  Mylang.58 = cy'� 'ye'Przemyslaw Pawelczyk 'cy'- LanguageSelection optionista'
  Mylang.70 = ye'J�tt�m�ll� t�m�n tyhj�ksi -> nykyinen hakemisto'
    
RETURN

/*-----------------------------------------------------------------------------+
|  Fin: Englanti                                                               |
|  Eng: English Language                                                       |
|  Pol: J�zyk angielski                                                        |
+-----------------------------------------------------------------------------*/
ENGLISH_LANGUAGE:
  Mylang.0  = 58
  Mylang.1  = gr'Thank you for using this product for '
  Mylang.2  = gr'Look also http://www.tec.puv.fi/~k3 for updates etc...'gray
  Mylang.3  = cy'�������������������������������������Ŀ'
  Mylang.4  = cy'� 'gr'MP3PuRiSTiN  RL 2000.03.20 for OS/2 'cy'�'
  Mylang.5  = cy'� 'gr'(v0.25)     (c)2000 HaLPaRoTuKTioNS 'cy'�'
  Mylang.6  = cy'��������������������������������������� '
  Mylang.7  = cy'My acknowledgments to:'
  Mylang.8  = gr'MP3PuRiSTiN is Freeware... ' ||,
                 'if you like this send me e-mail!!!'
  Mylang.9  = gr'This version of MP3PuRiSTiN '||,
                 'can only use 'bl'leech'gr' and'bl' lame'
  Mylang.10 = re'THERE IS NO CHECKINGS IN THIS SCRIPT, ' ||,
                'SO BE CAREFUL WHAT YOU TYPE IN!!!'
  Mylang.11 = re'If something goes wrong -> hit CTRL-C to exit...'
  Mylang.12 = wh'Default Parameters:'
  Mylang.13 = gr'Mode:    ' cy'joint stereo'
  Mylang.14 = gr'Bitrate: ' cy'128'
  Mylang.15 = gr'Quality: ' cy'High (less speed)'
  Mylang.16 = gr'Grabber: ' cy'Leech'
  Mylang.17 = gr'Encoder: ' cy'Lame'
  Mylang.18 = pu'Do you want to change these options? (y/n)'gray
  Mylang.19 = gr'Filename: ' cy''
  Mylang.20 = pu'Do you want to change the filename? (y/n)'gray
  Mylang.21 = wh'Here are all the switches... Ingnore if you ' ||,
                'do not undestand :)'
  Mylang.22 = gr'mode     'cy
  Mylang.23 = gr'bitrate  'cy
  Mylang.24 = gr'quality  'cy
  Mylang.25 = gr'variable 'cy
  Mylang.26 = gr'vbr      'cy
  Mylang.27 = pu'In which drive you have the audio cd...?'
  Mylang.28 = ye'Give only the drive letter... without the :'wh
  Mylang.29 = pu'Where do you want the MP3 files to go to?'
  Mylang.30 = ye'Give drive letter with a path and backslash!      ' ||,
                '      E.g. v:\my_mp3\'
  Mylang.31 =   'Or give drive letter w/o a path but with backslash' ||,
                ' too! E.g. v:\'wh
  Mylang.32 = wh'Table of Contents'gray
  Mylang.33 = wh'Above is TOC, you can see there how many tracks ' ||,
                'there are on CD'
  Mylang.34 = pu'First track to encode?'gray
  Mylang.35 = pu'Last track to encode?'gray
  Mylang.36 = wh'Choose one of the following:'
  Mylang.37 = pu'a)'wh' Custom (make your own decicions)'
  Mylang.38 = pu'b)'wh' Stereo, br 160, High quality'
  Mylang.39 = pu'c)'wh' Stereo, br 192, High quality'
Mylang.56   = pu'd)'wh' Joint Stereo, Variable br, min br 112, ' ||,
                'Vquality 4 (br will be 128-160)'
  Mylang.40 = pu'e)'wh' Stereo, Variable br, min br 128, Vquality 6...'
  Mylang.41 = pu'f)'wh' Mono, br 80... not so good...'
  Mylang.42 = gr'MODE:    'pu'(s)tereo (j)oint, (f)orce or (m)ono? 'gray
  Mylang.43 = gr'QUALITY: 'pu'(h)igh, (f)ast or (n)ormal?'gray
  Mylang.44 = gr'VARIABLE BITRATE: 'pu'(y/n)'gray
  Mylang.45 = gr'VBR QUALITY:'pu' 0=high quality... 9=lowest'gray
  Mylang.46 = wh'OK, the next bitrate sets the allowed minimum bitrate'gray
  Mylang.47 = gr'BITRATE:'pu' 32,40,56,64,80,96,112,128,160,192,224,256' ||,
                ' or 320? 'gray
  Mylang.48 = gr'Current filename:'pu 
  Mylang.49 = gr'New filename (may contain spaces, etc.): 'pu
  Mylang.50 = ye'Select your language:'gray
  Mylang.51 = gr'1. Finnish'
  Mylang.52 = cy'2. English'
  Mylang.53 = ye'3. Polish'
  Mylang.54 = pu'What is your choice (write NUMBER then press ENTER):'wh
  Mylang.55 = re'Please answer either 'cy'1, 2 or 3'
  Mylang.57 = cy'� 'ye'Andreas Ebbert 'cy'- for FileNameChange option'
  Mylang.58 = cy'� 'ye'Przemyslaw Pawelczyk 'cy'- for LanguageSelection option'
  Mylang.70 = ye'Leave empty for current directory'    
RETURN

/*-----------------------------------------------------------------------------+
|  Fin: Puola                                                                  |
|  Eng: Polish Language                                                        |
|  Pol: J�zyk polski                                                           |
+-----------------------------------------------------------------------------*/
POLISH_LANGUAGE:
  Mylang.0  = 58
  Mylang.1  = gr'Dzi�kuj� za u�ywanie programu przez... '
  Mylang.2  = gr'Uaktualnienia pod adresem: http://www.tec.puv.fi/~k3...'gray
  Mylang.3  = cy'�������������������������������������Ŀ'
  Mylang.4  = cy'� 'gr'MP3PuRiSTiN  RL 2000.03.20 for OS/2 'cy'�'
  Mylang.5  = cy'� 'gr'(v0.25)     (c)2000 HaLPaRoTuKTioNS 'cy'�'
  Mylang.6  = cy'��������������������������������������� '
  Mylang.7  = cy'Na specjalne podzi�kowania zas�uguj�:'
  Mylang.8  = gr'MP3PuRiSTiN nale�y do kategorii Freeware. ' ||,
                'Czekam na Wasze listy!!!'
  Mylang.9  = gr'Bie��ca wersja programu obs�uguje jedynie 'bl ||,
                'leech'gr' i'bl' lame.'
  Mylang.10 = re'SKRYPT NIE KONTROLUJE B��D�W, PROSZ� UWA�A� PODCZAS ' ||,
                'WPISYWANIA!!'
  Mylang.11 = re'Je�li co� b�dzie nie tak, prosz� nacisn�� CTRL-C...'
  Mylang.12 = wh'Parametry domy�lne:'
  Mylang.13 = gr'Mode    (tryb    ): ' cy'joint stereo (wsp�lne stereo)'
  Mylang.14 = gr'Bitrate (pasmo   ): ' cy'128'
  Mylang.15 = gr'Quality (jako��  ): ' cy'b. du�a   (mniejsza szybko��)'
  Mylang.16 = gr'Grabber (chwytacz): ' cy'Leech'
  Mylang.17 = gr'Encoder (koder   ): ' cy'Lame'
  Mylang.18 = pu'Zmieni� ustawienia? (y/n)'gray
  Mylang.19 = gr'Nazwa pliku: ' cy''
  Mylang.20 = pu'Zmieni� nazw� pliku? (y/n)'gray
  Mylang.21 = wh'Pokazuj� wszystkie opcje... Je�li nic nie m�wi�' ||,
                ' prosz� je zignorowa�.'
  Mylang.22 = gr'mode    (tryb  ) 'cy
  Mylang.23 = gr'bitrate (pasmo ) 'cy
  Mylang.24 = gr'quality (jako��) 'cy
  Mylang.25 = gr'variable (zmienno��)'cy
  Mylang.26 = gr'vbr  (zmienne pasmo)'cy
  Mylang.27 = pu'Jak� liter� oznaczony jest nap�d CD...?'
  Mylang.28 = ye'Prosz� poda� liter�... bez dwukropka :'wh
  Mylang.29 = pu'W kt�rej partycji (dysku) sk�adowane s� pliki MP3...?'
  Mylang.30 = ye'Prosz� poda� liter� z dwukropkiem i �cie�k�.'
  Mylang.31 =   'Prosz� nazw� zamkn�� uko�nikiem "\", np. v:\mp3\, v:\'wh
  Mylang.32 = wh'Spis �cie�ek na CD 'gray
  Mylang.33 = ye'Powy�szy spis pokazuje liczb� �cie�ek na CD.'
  Mylang.34 = pu'Pierwsza �cie�ka do kodowania?'gray
  Mylang.35 = pu'Ostatnia �cie�ka do kodowania?'gray
  Mylang.36 = wh'Mo�na wybra� jeden z tryb�w pracy:'
  Mylang.37 = pu'a)'wh' Definiowany przez u�ytkownika'
  Mylang.38 = pu'b)'wh' Stereo, br 160, High quality (wysoka jako��)'
  Mylang.39 = pu'c)'wh' Stereo, br 192, High quality (wysoka jako��)'
Mylang.56   = pu'd)'wh' wsp�lne stereo, zmienne pasmo, pasmo min 112, ' ||,
                   'jako�� pasma 4 (pasmo pomi�dzy 128-160)'
  Mylang.40 = pu'e)'wh' Stereo, zmienne pasmo, min. pasmo 128, jako�� pasma 6...'
  Mylang.41 = pu'f)'wh' Mono, br 80... niezbyt dobry...'
  Mylang.42 = gr'TRYB: 'pu'wsp�lne-(j) stereo-(s), wymuszony-(f)' ||,
                ' czy (m)ono? 'gray
  Mylang.43 = gr'JAKO��:  'pu'wysoka-(h), szybka-(f) czy typowa-(n) ?'gray
  Mylang.44 = gr'ZMIENNE PASMO: 'pu'(y/n)'gray
  Mylang.45 = gr'Jako�� pasma:   'pu'0=wysoka...    9=najni�sza'gray
  Mylang.46 = wh'OK, nast�pny wyb�r pasma ustawi najni�sze dopuszczalne' ||,
                ' pasmo'gray
  Mylang.47 = gr'PASMO:'pu' 32,40,56,64,80,96,112,128,160,192,224,256' ||,
                ' or 320? 'gray
  Mylang.48 = gr'Nazwa bie��ca:'pu 
  Mylang.49 = gr'Nowa nazwa (mo�e zawiera� spacje, itp.): 'pu
  Mylang.50 = ye'Prosz� wybiera� j�zyk:'gray
  Mylang.51 = gr'1. Fi�ski'
  Mylang.52 = cy'2. Angielski'
  Mylang.53 = ye'3. Polski'
  Mylang.54 = pu'Dokonany wyb�r (wpisa� NUMER potem ENTER):'wh
  Mylang.55 = re'Prosz� odpowiedzie� 'cy'1, 2 lub 3'
  Mylang.57 = cy'� 'ye'Andreas Ebbert 'cy'- za opcj� zmiany nazwy pliku.'
  Mylang.58 = cy'� 'ye'Przemys�aw Pawe�czyk 'cy'- za opcj� zmiany j�zyka i wyboru katalogu MP3.'
  Mylang.70 = ye'Leave empty for current directory (bratislava za wyzywyzy)'        
    
RETURN  ' - Andreasa Ebberta za opcj� zmiany nazwy pliku.'
