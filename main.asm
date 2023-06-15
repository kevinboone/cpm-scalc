;------------------------------------------------------------------------
;  SCALC utility -- a simple (but algebraically correct) 16-bit
;    calculator for CP/M
;
;  main.asm 
;
;  Copyright (c)2021 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

	.Z80

	ORG    0100H

	include conio.inc
	include dbgutl.inc
	include string.inc
	include intmath.inc
	include bdos.inc

	; Input buffer (use the command line area)
	EXPR_IN	EQU	080h
	EXPR	EQU	081h

	; Token type codes return by nexttok()
	TOK_EOF EQU     0
	TOK_NUM EQU	1	

	JP	main

;------------------------------------------------------------------------
;  nextchar 
;  Read the next character in the input expression into A and increment
;   (pos). In practice, there's no point doing this with 16-bit
;   arithmetic, because the BDOS line read function only accepts up
;   to 256 characters.
;------------------------------------------------------------------------
nextchar:
	PUSH	BC
	PUSH	HL
	LD 	HL, EXPR
	LD	B, H
	LD	C, L
	LD	HL, (pos)
	ADD	HL, BC
	LD	A, (HL)
	LD	HL, (pos)
	INC	HL
	LD	(pos), HL
	POP	HL
	POP	BC
	RET

;------------------------------------------------------------------------
;  charback 
;  Move the current parse position (pos) back one position
;------------------------------------------------------------------------
charback:
	PUSH	HL
	LD	HL, (pos)
	DEC	HL	
	LD	(pos), HL
	POP	HL
	RET

;------------------------------------------------------------------------
;  nexttok
;  Gets the next token from the expression. The return value in A 
;  is TOK_EOF if we are at the end of input, TOK_NUM if the token is a 
;  number, and the actual token if anything else. If the token is a 
;  number, it's value is returned in HL.
;------------------------------------------------------------------------
nexttok:
	PUSH	DE
	; Reset the ASCII-to-binary conversion accumulator
	LD	HL, 0	
	LD 	(numtotal), HL	
	CALL	nextchar
.nt_next:
	; Char is in A
	OR	A
	JR	NZ, .nt_nonull
	LD	A, TOK_EOF
	JR	.ntdone		; End of input - we are done

.nt_nonull:
	CALL	is_digit
	JR	NZ, .nt_nodig

	; If we get here, the character is a digit
	; Loop around, converting decimal digits to binary
.nt_nxtdig:
	LD	HL, (numtotal)
	LD	DE, 10
	CALL	mul16
	SUB	'0'
	LD	B, 0
	LD	C, A
	ADD	HL, BC
	LD	(numtotal), HL
 	CALL	nextchar
	CALL	is_digit
	JR	Z, .nt_nxtdig
	CALL	charback
	LD	HL, (numtotal)
	LD	A, TOK_NUM
	JR	.ntdone;

.nt_nodig:
	; If we get here, the character is not a number or EOF 
	CP	'#'
	JR	NZ, .nt_nohash

	; It's a #. If it's followed by a hex digit, read all the
        ;   hex digits. Otherwise, return it as the literal '#'
        ;   which will probably raise a syntax error later 
	CALL	nextchar
	CALL	is_hex_digit
	JR	Z, .nt_nxthex
	LD	A, '#'
	JR      .ntdone 

	; Loop to read hex digits into (numtotal)
.nt_nxthex:
	LD	HL, (numtotal)
	LD	DE, 16
	CALL	mul16
	CALL	digtohex
	LD	B, 0
	LD	C, A
	ADD	HL, BC
	LD	(numtotal), HL
 	CALL	nextchar
	CALL	is_hex_digit
	JR	Z, .nt_nxthex
	CALL	charback
	LD	HL, (numtotal)
	LD	A, TOK_NUM
	JR	.ntdone
	
	; Character is not EOF or any kind of number that we understand
.nt_nohash:
	CALL	is_space
	JR	NZ, .nt_nospc

	CALL	nextchar	; Swallow the space and loop
	JR	.nt_next

.nt_nospc:
	CP	'@'
	JR	NZ, .nt_noat

	LD	HL, (lastval) 
	LD	A, TOK_NUM
	JR	.ntdone

.nt_noat:

	; The token should now be in A		
.ntdone:
	POP	DE
	RET

;------------------------------------------------------------------------
;  savepos 
;  Save the value of (pos) in case a parse fails, and we need to 
;    wind it back.
;------------------------------------------------------------------------
savepos:
	PUSH	HL
	LD	HL, (pos)
	LD	(lastpos), HL	
	POP	HL
	RET

;------------------------------------------------------------------------
;  restpos 
;  Wind back (pos) to (lastpos); used when a parse operation consumes
;    a token that it cannot parse
;------------------------------------------------------------------------
restpos:
	PUSH	HL
	LD	HL, (lastpos)
	LD	(pos), HL	
	POP	HL
	RET

;------------------------------------------------------------------------
;  swaphlde 
;------------------------------------------------------------------------
swaphlde:
	PUSH 	HL
	LD 	H, D
	LD 	L, E
	POP 	DE
	RET

;------------------------------------------------------------------------
; syn_err
; Print the syntax error message, and use the value of (pos) to display
;   a pointer to where the error (roughly) was.
;------------------------------------------------------------------------
syn_err:
	PUSH	AF
	PUSH	HL
	LD	HL, m_synerr
	CALL	puts
	CALL	newline
	LD	HL, EXPR
	CALL	puts
	CALL	newline

	LD	HL, (pos)

.se0:
	LD	A, L
	OR	H
	JR	Z, .se1

	DEC	HL
	call	space
	JR	.se0

.se1:
	LD	A, '^'
	CALL	putch
	CALL	newline
	POP	HL
	POP	AF
	RET

;------------------------------------------------------------------------
; div_zero 
; Print the divide-by-zero message
;------------------------------------------------------------------------
div_zero:
	PUSH	HL
	PUSH	AF	
	LD	HL, m_divzero
	LD	A, 1
	LD	(rterr), A
	CALL	puts
	POP	AF
	POP	HL
	RET

;------------------------------------------------------------------------
; dmppos
; For debugging only 
;------------------------------------------------------------------------
;dmppos:
;	PUSH	HL
;	LD	HL, (pos)
;	CALL	puth16
;	POP	HL
;	RET

;------------------------------------------------------------------------
;  prs_num 
;  See GRAMMAR.TXT
;  Ret 1 is a number was parsed, and value will be in HL; 0 otherwise
;------------------------------------------------------------------------
prs_num:
	CALL	nexttok
	CP	TOK_NUM
	JR	Z, .pn_1
	LD	A, 0
	RET
.pn_1:
	LD	A, 1
	RET

;------------------------------------------------------------------------
;  prs_expr
;  See GRAMMAR.TXT
;  Ret 1 is an expression was parsed, and value will be in HL; 0 otherwise
;------------------------------------------------------------------------
prs_expr:
	PUSH	DE
	CALL	savepos
	CALL	prs_term
	OR	A
	JR	Z, .pe_none
	; If we get here, we matched at least one term
	; The numerical result is in HL but we'll save it in DE
.pe1:
	LD	D, H
	LD	E, L
	CALL	savepos
	CALL	nexttok
	CP	'+'
	JR	NZ, .pe_nopls

	CALL	prs_term
	OR	A
	JR	Z, .pe_synerr
	ADD	HL, DE
	CALL	savepos
	JR	.pe1

.pe_nopls:
	CP	'-'
	JR	NZ, .pe_nomin

	CALL	prs_term
	OR	A
	JR	Z, .pe_synerr
	CALL	swaphlde
	SBC	HL, DE
	CALL	savepos
	JR	.pe1

.pe_nomin:
	CP	TOK_EOF
	JR	NZ, .pe_noeof
	LD	A, 1
	JR	.pe_done

.pe_noeof:
	CP	'|'
	JR	NZ, .pe_noor

	CALL	prs_term
	OR	A
	JR	Z, .pe_synerr
	LD	A, H
	OR	D
	LD	H, A
	LD	A, L
	OR	E
	LD	L, A

	CALL	savepos
	JR	.pe1

.pe_noor:
	CP	'&'
	JR	NZ, .pe_noand

	CALL	prs_term
	OR	A
	JR	Z, .pe_synerr
	LD	A, H
	AND	D
	LD	H, A
	LD	A, L
	AND	E
	LD	L, A

	CALL	savepos
	JR	.pe1

.pe_noand:
	CP	'^'
	JR	NZ, .pe_noxor

	CALL	prs_term
	OR	A
	JR	Z, .pe_synerr
	LD	A, H
	XOR	D
	LD	H, A
	LD	A, L
	XOR	E
	LD	L, A

	CALL	savepos
	JR	.pe1

.pe_noxor:
	CALL	restpos
	LD	A, 1
	JR	.pe_done

.pe_none:
	CALL	restpos
	LD	A, 0
.pe_done:
	LD	H, D
	LD	L, E
	POP	DE
	RET

.pe_synerr:
	;CALL	syn_err
	JR	.pe_done

;------------------------------------------------------------------------
;  prs_term
;  See GRAMMAR.TXT
;  Ret 1 is an expression was parsed, and value will be in HL; 0 otherwise
;------------------------------------------------------------------------
prs_term:
	PUSH	DE
	CALL	savepos
	CALL	prs_factor
	OR	A
	JR	Z, .pt_none
	; If we get here, we matched at least one term
	; The numerical result is in HL but we'll save it in DE
.pt1:
	LD	D, H
	LD	E, L
	CALL	savepos
	CALL	nexttok
	CP	'*'
	JR	NZ, .pt_nomul

	CALL	prs_factor
	OR	A
	JR	Z, .pt_synerr
	CALL	mul16
	CALL	savepos
	JR	.pt1

.pt_nomul:
	CP	'/'
	JR	NZ, .pt_nodiv

	CALL	prs_factor
	OR	A
	JR	Z, .pt_synerr
	LD	A, H
	OR	L
	JR	Z, .pt_divz
	CALL	swaphlde
	CALL	sdiv16	
	CALL	savepos
	JR	.pt1

.pt_nodiv:
	CP	'%'
	JR	NZ, .pt_nomod

	CALL	prs_factor
	OR	A
	JR	Z, .pt_synerr
	LD	A, H
	OR	L
	JR	Z, .pt_divz
	CALL	swaphlde
	CALL	sdiv16	
	;  Remainder comes out of sdiv16 in DE
	LD	H, D
	LD	L, E
	CALL	savepos
	JR	.pt1

.pt_nomod:
	CP	TOK_EOF
	JR	NZ, .pt_noeof
	LD	A, 1
	JR	.pt_done

.pt_noeof:
	CALL	restpos
	LD	A, 1
	JR	.pt_done

.pt_none:
	CALL	restpos
	LD	A, 0
.pt_done:
	LD	H, D
	LD	L, E
	POP	DE
	RET

.pt_synerr:
	;CALL	syn_err
	JR	.pt_done

.pt_divz:
	CALL	div_zero
	JR	.pt_done

;------------------------------------------------------------------------
;  prs_factor 
;  See GRAMMAR.TXT
;  Ret 1 if an expression was parsed, and value will be in HL; 0 otherwise
;------------------------------------------------------------------------
prs_factor:
	PUSH	DE
	CALL	nexttok
	CP	TOK_NUM
	JR	NZ, .prs_nonum
	LD	A, 1
	JR	.prs_f_done
.prs_nonum:
	; If we get here, the last token was not a number
	CP	'('
	JR	NZ, .prs_n_paren
	CALL	prs_expr
	OR	A
	JR	Z, .prs_f_err
	; We got an expression, and the result is in HL
	; Check that the next is a ")"
	LD	D, H
	LD	E, L
	CALL	nexttok
	CP	')'
	JR	NZ, .prs_f_err
	LD	H, D
	LD	L, E
	LD	A, 1
	JR	.prs_f_done

.prs_n_paren:
	CP	'-'
	JR	NZ, .prs_n_min
	CALL	prs_factor
	OR	A
	JR	Z, .prs_f_err
	CALL	neg16
	LD	A, 1
	JR	.prs_f_done	

.prs_n_min:
.prs_f_err:
	LD	A, 0
.prs_f_done:
	POP	DE
	RET

;------------------------------------------------------------------------
; prt_rslt
; Print the number in HL as a signed decimal and hex
;------------------------------------------------------------------------
prt_rslt:
	PUSH	DE
	PUSH	HL
	LD	D, H
	LD	E, L
	LD	HL, numbuf
	CALL	itoa
	CALL	puts
	CALL	space
	LD	A, '#'
	CALL	putch
	POP	HL
	CALL	puth16
	CALL	newline
	POP	DE
	RET

;------------------------------------------------------------------------
; rst_eval 
; Reset (pos) and (lastpos), etc., ready for the next expression.
;------------------------------------------------------------------------
rst_eval:
	LD 	A, 0
	LD	(pos), A
	LD	(lastpos), A
	LD	(rterr), A
	RET

;------------------------------------------------------------------------
; eval
; evaluate the expression at EXPR, whose length is in (EXPR_IN), and
;   print the result
;------------------------------------------------------------------------
eval:
	CALL	rst_eval
	LD	HL, EXPR_IN
	LD	A, (HL)		; Input length
	CP	1
	JR	C, .done	; No input
	INC	A
	LD	B, 0
	LD	C, A
	ADD	HL, BC
	LD	(HL), 0		; Zero-terminate the expression string

; nasty bug fix -- it seems that sometimes the parser runs off the end
;   of the expression. zero-terminating is supposed to indicate the
;   end, but somehow the parser skips the zero and carries on. Since
;   I don't have time to seek out the true problem right now, the 'fix'
;   is to add some extra zeros to the end of the command line, so the
;   parser finds a terminating zero, even if it skips the real one.
; This is very nasty, and I should fix it properly when I have time.
; I think it's safe to write these zeros, because nobody's going to
;   enter a 128-character expression when there's no line editing.
inc hl
ld (hl), 0
inc hl
ld (hl), 0
inc hl
ld (hl), 0

 	LD 	HL, EXPR 

	CALL	prs_expr
	OR	A
	JR	Z, .m_synerr


	; If (pos) does not now point to the terminating zero, there was
	;   an error. Print the result, or an error message 
	CALL	nextchar
	OR	A
	JR	Z, .m_prt
	CALL 	syn_err	

	JR	.done
.m_prt:
	CALL    prt_rslt	; Print result	
	LD	(lastval), HL
	JR	.done

.m_synerr:
	LD	A, (rterr)	; Don't print error if we already did
	OR	A
	JR	NZ, .done
	CALL	syn_err

.done:
	RET

;------------------------------------------------------------------------
;  loop 
;  Prompt for an expression, and evaluate it, in a loop.
;    Stop when the user enters and empty line
;------------------------------------------------------------------------
loop:
	; Clear the line input buffer. This is a bit ugly, but
	;   sometimes the value of (pos) in an error condition can
	;   actually be off the end of the input line. It should
	;   be pointing no further than the terminating zero, but
	;   for some reason this doesn't always happen. So when we
	;   look for (pos) pointing to the terminating zero, to see
	;   whether all tokens we consumed, we can get a character
	;   from the last expression entered. Although ugly, it's
	;   easier to zero the buffer than try to work out exactly
	;   what is going wrong with (pos) in a syntax error
	LD	HL, EXPR
	LD	BC, 127
	LD	A, 0
	CALL	memset

	; We start the line input buffer one byte before the command-line,
	;   so we can use the same memory for both command line and
	;   interactive use. BDOS function C_READSTR needs the first
	;   byte to be the maximum buffer size, so if we start one byte
	;   further down, this size byte doesn't become part of the 
	;   input. Actually, the size byte ends up in the default
	;   FCB at location 0x7F, but this program doesn't use FCBs. 
	LD 	DE, EXPR_IN - 1 
	LD 	HL, EXPR_IN - 1 
	LD	A, 127
	LD	(HL), A

	; Read the line
	LD	HL, m_prompt
	CALL	puts
	LD	C, C_READSTR
	CALL	BDOS

	; Check whether anything was entered. If it was, evaluate and
	;   go around again.
	LD	HL, 080h
	LD	A, (HL)
	OR	A
	JR	Z, .loopdone	
	CALL	newline
	CALL 	eval
	JR	loop
.loopdone:
	RET	

;------------------------------------------------------------------------
;  Start here 
;------------------------------------------------------------------------
main:
	
	; Check command line. If none, call loop() to enter
	;  interactive mode.
 	LD 	HL, 080h	
	LD	A, (HL)
	CP	2
	JR	C, .noargs

	CALL	eval
	CALL	exit

.noargs:
	LD	HL, m_banner
	CALL	puts
	CALL	loop
	CALL	exit

;------------------------------------------------------------------------
;  Data 
;------------------------------------------------------------------------

; pos and lastpos are offsets into the expression being evaluated. After
;   a successful parse of a group of tokens, lastpos is advanced to pos.
;   If the parse later fails, pos can be reverted to its previous value.
;   This rigmarole is necessary because parse_expr() and parse_term()
;   can both consume tokens that they cannot parse.
pos: dw 0
lastpos: dw 0

m_synerr: db 'Syntax error',0

m_divzero: db 'Division by zero',13,10,0

m_prompt: db 'scalc> ',0

m_banner: db 'scalc v0.1b Copyright (c)2022 Kevin Boone',13,10,0

; rterr is set to zero if parse_expr() has already produced an error
;   message, so the caller should not.
rterr: db 0

; A scratch buffer for convering binary to decimal
numbuf: db '-65536',0,0,0

; A scratch buffer used for accumulating the result of
;   ASCII-to-binary conversion
numtotal: dw 0

lastval: dw 0

END
 
