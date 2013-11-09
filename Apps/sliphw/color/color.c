/*
 *	COLOR uses the OS/2 ANSI driver to set screen foreground and
 *	background colors in protected mode.  Syntax is:
 *
 *		COLOR fb
 *
 *	where f = foreground color (X,x,B,b,G,g,C,c,R,r,M,m,Y,y,W,w), and
 *	      b = background color (x,b,g,c,r,m,y,w)
 *
 *	Compile and link with:  cl -Lp -G2 color.c
 *
 *	Copyright (c) 1989 Ziff Communications Co.
 *	Written March 1989 for PC Magazine by Jeff Prosise
 */

#include <stdio.h>
#include <string.h>

#define API unsigned extern far pascal

API DosExit(int, int);
API VioSetAnsi(int, int);
API VioWrtTTY(char far *, int, int);

unsigned char ForeNum, BackNum;
unsigned short EscLength = 4;
char EscSeq[13] = "\033[0;";

char *ForeColor[8] = { "30;", "34;", "32;",
		       "36;", "31;", "35;",
		       "33;", "37;" };

char *BackColor[8] = { "40m", "44m", "42m",
		       "46m", "41m", "45m",
		       "43m", "47m" };

char *ErrTxt1 = "Usage: COLOR fb";
char *ErrTxt2 = "Invalid color ID";

main(int argc, char *argv[])
{
	if (argc < 2) {
		printf("%s\n", ErrTxt1);
		DosExit(1, 1);
	}

	if (strlen(argv[1]) < 2) {
		printf("%s\n", ErrTxt1);
		DosExit(1, 1);
	}

	switch(argv[1][0]) {

		case 'X' :
			EscLength += 2;
		case 'x' :
			ForeNum = 0;
			break;

		case 'B' :
			EscLength += 2;
		case 'b' :
			ForeNum = 1;
			break;

		case 'G' :
			EscLength += 2;
		case 'g' :
			ForeNum = 2;
			break;

		case 'C' :
			EscLength += 2;
		case 'c' :
			ForeNum = 3;
			break;

		case 'R' :
			EscLength += 2;
		case 'r' :
			ForeNum = 4;
			break;

		case 'M' :
			EscLength += 2;
		case 'm' :
			ForeNum = 5;
			break;

		case 'Y' :
			EscLength += 2;
		case 'y' :
			ForeNum = 6;
			break;

		case 'W' :
			EscLength += 2;
		case 'w' :
			ForeNum = 7;
			break;

		default :
			printf("%s\n", ErrTxt2);
			DosExit(1, 1);
	}
	
	if (EscLength == 6)
		strcat(EscSeq, "1;");
	strcat(EscSeq, ForeColor[ForeNum]);
	EscLength += 3;

	switch (argv[1][1]) {

		case 'x' :
			BackNum = 0;
			break;

		case 'b' :
			BackNum = 1;
			break;

		case 'g' :
			BackNum = 2;
			break;

		case 'c' :
			BackNum = 3;
			break;

		case 'r' :
			BackNum = 4;
			break;

		case 'm' :
			BackNum = 5;
			break;

		case 'y' :
			BackNum = 6;
			break;

		case 'w' :
			BackNum = 7;
			break;

		default :
			printf("%s\n", ErrTxt2);
			DosExit(1, 1);
	}

	strcat(EscSeq, BackColor[BackNum]);
	EscLength += 3;

	VioSetAnsi(1, 0);

	VioWrtTTY(EscSeq, EscLength, 0);

	DosExit(1, 0);
}
