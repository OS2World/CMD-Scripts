/* 1/29/1994 John M. Warren  This program is hereby released as FREE PUBLIC DOMAIN software.*/
/* REXX program to ask the user for command line parameters before running a program. */
/* This software comes with NO warranty whatsoever. */

/*
How to use this program :

    1.  Simply create a new program object.   
    2.  Under the "Path and file name" instead of putting the name and path of
         your executable program, put the name and path of this command file.

         example :     C:\OS2\CMDSHELL.CMD

    3.  Next, under the "Parameters" field add the path and filename of your
         program.    (hint : you can parameters that you use ALL the time after the filename too.)  

         example :     C:\PROGRAMS\PKZIP\PKZIP.EXE

For convenience sake I would recommend opening your Templates folder, making a copy of the "Program" object and perform step 2.   From then on you could just copy this template object and would only have to
fill in the path and filename.
*/






/* ASK THE USER TO SUPPLY THE COMMAND LINE PARAMETERS */

/* #include "mental.h"     just kidding, I had to do that for you "C" programmers   :-) */

ECHO OFF
CLS

SAY "CMDSHELL (c) 1993, John M. Warren"
SAY " "
SAY "You have just executed program which requires command line parameters"
SAY " "
SAY "Please enter the parameters for this program below :"
SAY " "
SAY "Current Directory"
CD 
SAY " "
SAY "COMMAND : " ARG(1)
SAY " "
PULL PARAMETERS
RUNLINE = ARG(1)
CLS
ECHO ON
RUNLINE PARAMETERS


/* I really hate when my screen goes to fast to read */
SAY " "
SAY " "
SAY "*** PROGRAM HAS TERMINATED PRESS ENTER TO CONTINUE ***"
PULL DUMMY


/*  
This program is free.  However,  I'm in desperate need of an OS/2 C++ compiler ($350.00) so I can begin writing some really usefull utilites/games/applications and other stuff for OS/2.  So any contributions to fund my continuing education into C++ programming is greatly appreciated.  Please send checks to :

  John M. Warren
  P.O. Box 609
  Vernon, Fl. 32462

   I can also be contacted at my bbs.   The Code 3 BBS, The Programmers Connection 904-535-1705 14.4k
                                                      Source Code, Game Code, & over 1.5G of shareware
                                                      Full access first call.  1 Hour per day.  No UL/DL restrictions.
			

*/