/* ------------------------------------------------------------------ */
/*                                                                    */
/* sample external message handling routine for RxLBox v1.30          */
/*                                                                    */
/* This routines implements German messages for RxLBox                */
/*                                                                    */
/* ------------------------------------------------------------------ */

                    /* get the first two parameters                   */
                    /* (the other parameters are processed in the     */
                    /*  do loop below)                                */
  parse arg msgNo, msgFile, .

                    /* define the stem with the messages              */
                    /* Note: Message Numbers begin with n+1, where n  */
                    /*       is the value of the variable             */
                    /*           global.__BaseMsgNo                   */
                    /*       in RxLBOX.CMD.                           */
                    /*       You can change this variable to any      */
                    /*       value you like.                          */
                    /*       In this example we use the default value */
                    /*       1800.                                    */
                    /*                                                */
  msgStr.1801   = ''
  msgStr.1802   = 'Eingabedatei "%1" nicht gefunden'
  msgStr.1803   = 'Eingabedatei "%1" ist leer'
  msgStr.1804   = 'Fehler beim ôffnen der Eingabedatei "%1"'
  msgStr.1805   = 'Die Queue "%1" existiert nicht'
  msgStr.1806   = 'Die Queue "%1" ist leer'
  msgStr.1807   = 'Die Zeile %1 der Menue Beschreibung ist fehlerhaft (Die Zeile lautet: %2)'
  msgStr.1808   = 'Menue "%1" nicht gefunden'
  msgStr.1809   = 'Menue "%1" ist leer'
  msgStr.1810   = 'Zeile %1: Menue %1 ist schon definiert'

                    /* message number 11 is not used anymore          */
  msgStr.1811   = ''

  msgStr.1812   = 'Zeile %1: Macroname ist zu lang'
  msgStr.1813   = 'Fehlerhaftes Menue Kommando gefunden: "%1"'
  msgStr.1814   = 'Zeile %1: Macro "%2" ist schon definiert'
  msgStr.1815   = 'Zeile %1: Keyword fehlt'
  msgStr.1816   = 'Zeile %1: Fehlerhaftes MENUITEM/ACTION keyword gefunden'
  msgStr.1817   = 'Zeile %1: Fehlerhaftes REXX-Statement, die Zeile lautet "%2"'
  msgStr.1818   = 'Zeile %1: Hilfstext "%1" ist schon definiert'
  msgStr.1819   = 'Zeile %1: Hilfstext zu lang (max. 14 Zeilen mîglich)'
  msgStr.1820   = 'Zeile %1: Der Name eines Menues kann nicht mit "!" oder "_" beginnen'
  msgStr.1821   = 'Der Parameter "%1" ist fehlerhaft!'

  msgStr.1899   = '%1 Fehler in Zeile %2, rc = %3 %4'

  msgStr.1900  = 'öberprÅfe die Parameter ...'
  msgStr.1901  = 'Lese die Menue-Beschreibung ...'
  msgStr.1902  = 'Erstelle die Menue-Struktur ...'
  msgStr.1903  = 'Bereite das Menue vor ...'
  msgStr.1904  = '%1'
  msgStr.1910  = 'Liste aller Menue aus'
  msgStr.1911  = 'WÑhlen Sie ein Menue aus der Liste'
  msgStr.1912  = 'Ihre Eingabe:'
  msgStr.1913  = 'Bitte betÑtigen Sie eine Taste'
  msgStr.1914  = 'Liste aller Macros aus'
  msgStr.1915  = '*** Keyword "%1" nicht belegt fÅr dieses Menue! *** '
  msgStr.1916  = 'Liste aller bisher aufgerufenen Menues'
  msgStr.1917  = 'WÑhlen Sie ein Macro aus der Liste'
  msgStr.1918  = 'Fehler beim AusfÅhren von "%1"'

                    /* replace the placeholder with the values        */
  msgText = value( 'msgStr.' || msgNo )

  if pos( '%', msgText ) <> 0 then
  do
                    /* this loop processes the parameter 3 to n       */
    do j = 1 to 9
      pString = '%' || j

      do forever
        if pos( pString, msgText ) = 0 then
          leave
        parse var msgText part1 ( pString ) part2
        msgText = part1 || arg( j+2 ) || part2
      end /* do forever */

    end /* do j = 1 to 9 */

  end /* if pos( '%', msgText ) <> 0 then */

  if msgNo < 1900 then
    return 'ERROR: ' || msgNo || ' : ' || msgText
  else
    return MsgText

/* ------------------------------------------------------------------ */
/*                                                                    */
/* ------------------------------------------------------------------ */
