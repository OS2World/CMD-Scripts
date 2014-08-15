/* TestFile.CMD */

CALL CharOut '','What is your name? '
PARSE PULL name
SAY 'Hello,' name || '.'

EXIT
