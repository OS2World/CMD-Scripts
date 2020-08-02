/* Strippen.CMD */

PARSE ARG bron
IF Left(bron,1)='"' THEN PARSE VAR bron '"' bron '"' .

IF bron='' | bron=='/?' | bron=='-?' THEN DO
   SAY
   SAY 'Strippen zoekt ‚n toont mogelijk onnodige blanco tekens in een gevalideerd' 
   SAY 'OS/2-tekstbestand, zonder dit bestand aan te passen. Het gaat om daarbij' 
   SAY 'om eventuele blanco tekens per regel, tussen het laatste niet-blanco teken'
   SAY 'en het regeleinde.'
   SAY
   SAY 'Gebruik:' 
   SAY
   SAY'   STRIPPEN.CMD <tekstbestand>'
   SAY
   SAY 'De bestandsvalidatie door Strippen kan eveneens worden toegepast om een' 
   SAY 'onjuiste mix van regeleinde-tekens te detecteren.'
   EXIT
END

IF Stream(bron,'C','QUERY EXISTS')='' THEN DO
   SAY
   SAY 'Fout, bestand niet gevonden:' bron
   EXIT
END

enter1=D2C(13)
enter2=D2C(10)
enter3=enter1||enter2
grootte=Stream(bron,'C','QUERY SIZE')

alles=CharIn(bron,1,grootte)
CALL CharOut bron
aantal1=CountStr(enter1,alles)
aantal2=CountStr(enter2,alles)
aantal3=CountStr(enter3,alles)
DROP alles

IF aantal1<>aantal2 | aantal1<>aantal3 THEN DO
   SAY
   SAY 'Fout in:' bron
   SAY
   SAY 'Dit bestand is mogelijk geen geldig OS/2-tekstbestand, of er komen meerdere'
   SAY 'types regeleindes in voor.'
   SAY
   SAY "Aantal keer '0D'x  :" aantal1
   SAY "Aantal keer '0A'x  :" aantal2
   SAY "Aantal keer '0D0A'x:" aantal3
   EXIT
END

netto=grootte-(aantal3*2)
IF aantal1/netto<0.005 THEN DO
   SAY
   SAY 'Fout in:' bron
   SAY
   SAY 'Het aantal regeleinde-tekens is minder dan 0,5% van het netto totaal. Dit'
   SAY 'bestand is mogelijk geen geldig OS/2-tekstbestand.'
   EXIT
END

aantal=0
eerste=0
teller=0
DO WHILE Lines(bron)>0
   regel=LineIn(bron)
   teller=teller+1
   aantal1=Length(regel)
   aantal2=Length(Strip(regel,'T'))
   IF aantal1>aantal2 THEN DO
      aantal=aantal+aantal1-aantal2
      IF eerste=0 THEN DO
         SAY
         eerste=1
      END
      SAY 'Regel' teller||': -->"'||regel||'"<-- ('||aantal1-aantal2||')'
   END
END
CALL LineOut bron

SAY
IF aantal>0 THEN SAY 'Er staan mogelijk' aantal 'onnodige tekens in:' bron
            ELSE SAY 'Geen blanco tekens voor regeleindes gevonden in:' bron

EXIT

