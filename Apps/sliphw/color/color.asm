;; COLOR uses the OS/2 ANSI driver to set screen foreground and background
;; colors in protected mode.  Syntax is:
;;
;;	COLOR fb
;;
;; where f = foreground color (X,x,B,b,G,g,C,c,R,r,M,m,Y,y,W,w), and
;;       b = background color (x,b,g,c,r,m,y,w)
;;
;; Assemble with:  MASM COLOR;
;; Link with:	   LINK COLOR,,NUL,DOSCALLS,COLOR;
;;
;; Module Definition File (COLOR.DEF):
;;	NAME COLOR
;;	STACKSIZE 4096
;;	PROTMODE
;;
;; Copyright (c) 1989 Ziff Communications Co.
;; Written March 1989 for PC Magazine by Jeff Prosise

		.286

		extrn	DosExit:far
		extrn	VioSetAnsi:far
		extrn	VioWrtTTY:far

DGROUP		group	_DATA

_DATA		segment	word public 'DATA'

ErrTxt1		db	"Usage: COLOR fb",13,10
TxtLen1		equ	$ - ErrTxt1

ErrTxt2		db	"Invalid color ID",13,10
TxtLen2		equ	$ - ErrTxt2

EscSeq		db	27,"[0;",8 dup (?)
EscLen		dw	4

FCodes		db	"XBGCRMYW"
BCodes		db	"xbgcrmyw"

FAnsiCodes	db	"37; 33; 35; 31; 36; 32; 34; 30;"
BAnsiCodes	db	"47m 43m 45m 41m 46m 42m 44m 40m"

_DATA		ends

_TEXT		segment	word public 'CODE'
		assume	cs:_TEXT, ds:DGROUP
;;
;; MAIN is the main body of the program.
;;
main		proc	far

		mov	es,ax			;move env selector into ES
		mov	di,bx			;point DI to command line
		cld				;clear direction flag
		xor	al,al			;find first null byte
		repne	scasb

next_char:	cmp	byte ptr es:[di],20h	;skip leading spaces
		jne	get_entry
		inc	di
		jmp	next_char
;
;Build the foreground portion of the ANSI escape string.
;
get_entry:	mov	al,es:[di]		;get foreground ID code
		or	al,al			;see if a foreground code
		jnz	check_next		;  was entered

error1:		push	ds			;display error message
		push	offset DGROUP:ErrTxt1	;  and exit if not
		push	TxtLen1
error2:		push	0
		call	VioWrtTTY

		push	1			;exit with return code of 1
		push	1
		call	DosExit

check_next:	mov	ah,es:[di+1]		;get background ID code
		or	ah,ah			;exit if no background code
		jz	error1			;  was entered

		mov	bx,DGROUP		;point ES to DGROUP
		mov	es,bx
		mov	di,offset DGROUP:FCodes	;point DI to list of valid
		mov	cx,16			;  codes and see if the
		repne	scasb			;  foreground entry is
		je	char_found		;  valid

error3:		push	ds			;error if foreground entry
		push	offset DGROUP:ErrTxT2	;  isn't in the list
		push	TxtLen2
		jmp	error2

char_found:	cmp	cx,8			;check for highlighted
		jb	normal			;  foreground code

		sub	cx,8			;add "1;" to ANSI string
		mov	EscSeq[4],"1"		;  if foreground color
		mov	EscSeq[5],";"		;  is highlighted
		add	EscLen,2

normal:		mov	si,offset DGROUP:FAnsiCodes	;append foreground
		call	append				;  code to string
;
;Build the background portion of the ANSI escape string.
;
		xchg	ah,al				;transfer code to AL
		mov	di,offset DGROUP:BCodes		;check background entry
		mov	cx,8				;  for validity
		repne	scasb
		jne	error3

		mov	si,offset DGROUP:BAnsiCodes	;append background
		call	append				;  code to string
;
;Activate the ANSI driver and send escape string to set colors.
;
		push	1			;enable the ANSI driver
		push	0
		call	VioSetAnsi

		push	ds			;transmit the ANSI escape
		push	offset DGROUP:EscSeq	;  sequence thru VioWrtTTY
		push	EscLen
		push	0
		call	VioWrtTTY

		push	1			;exit program with return
		push	0			;  code of 0
		call	DosExit

main		endp
;;
;; APPEND appends a 3-character string to the ANSI escape string.
;;
append		proc	near

		shl	cx,2			;multiply index by 4
		add	si,cx			;add to absolute offset
		mov	di,offset DGROUP:EscSeq	;point DI to end of
		add	di,EscLen		;  ANSI string
		mov	cx,3			;append 3 bytes
		rep	movsb
		add	EscLen,3		;update pointer
		ret

append		endp

_TEXT		ends

		end	main
