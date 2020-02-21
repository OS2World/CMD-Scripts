/*   DIAL         */
'@echo off'
arg number
'echo atz > com2:'
'echo atl2 > com2:'
'sleeper 1'
'echo atdt 'number' > com2:'
'echo < com2:'
SAY 'Press enter for the computer to hang up'
PULL ANS
'echo atz > com2:'
