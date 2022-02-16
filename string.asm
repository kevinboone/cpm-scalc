;------------------------------------------------------------------------
;  string.asm 
;
;  See string.inc for function definitions.
;
;  Copyright (c)2022 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

 	.Z80

	global strlen, streverse, utoa, is_digit, is_space
	global itoa, digtohex, is_hex_digit, memset
	include intmath.inc
	include dbgutl.inc

;------------------------------------------------------------------------
; strlen 
; HL = addr; result in DE
;------------------------------------------------------------------------
strlen:
	PUSH	HL
	PUSH	BC
	PUSH	AF	
	XOR	A
	LD	C, A
	LD	B, A
	CPIR
	LD	HL, -1
	SBC	HL, BC
	LD	D, H
	LD	E, L
	POP	AF
	POP	BC
	POP	HL
	RET

;------------------------------------------------------------------------
; streverse
;------------------------------------------------------------------------
streverse:
	; HL = start of string, DE = count

	PUSH 	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF

	; If DE == 0, we must calculate the string length
	LD	A, D
	OR	E
	JR	NZ, .st_hasl
	CALL	strlen

.st_hasl:
	; Don't try to reverse a string of length 1 -- it goes
	;   horribly wrong
	LD	A, D
	OR	A
	JR	NZ, .st_nzl
	LD	A, E
	CP	1	
	JR	NZ, .st_nzl
	JR	.st_done	
.st_nzl:
	PUSH	HL
	ADD	HL, DE
	DEC	HL
	POP	BC
	; BC = start, HL = end 

	; Divide DE (the count) by two, once we've used it to 
	;  calculate the address of the end of the string. Otherwise
	;  we'll reverse the string and then reverse it back
	SRL	D
	RR	E

.strv0:	
	PUSH	DE
	LD	A, (BC)
	LD	E, A
	LD	A, (HL)
	LD	(BC), A
	LD	(HL), E
	POP	DE

	DEC	HL
	INC	BC
	
	DEC 	DE
	LD	A, D
	OR	E
	JR	NZ, .strv0 
.st_done:
	POP	AF
	POP	BC
	POP	DE
	POP	HL

	RET

;------------------------------------------------------------------------
; utoa 
; HL = buff, DE = num
;------------------------------------------------------------------------
utoa:
	PUSH	BC	
	PUSH	DE
	PUSH	HL	

	LD	B, H
	LD	C, L
	; BC now = start address

	LD	H, D
	LD	L, E
	; HL now = running total

.ut_loop:
	LD	DE, 10
	call	div16	
	; HL = quotient, DE = remainder

	LD	A, E
	ADD	A, '0'
	LD	(BC), A
	INC	BC
	LD	A, 0
	LD	(BC), A
	
	LD	A, H
	OR	L
	JR 	Z, .ut_done
	JR	.ut_loop

.ut_done:
	POP	HL	
	LD	DE, 0
	CALL	streverse
	POP	DE
	POP	BC	

	RET

;------------------------------------------------------------------------
; itoa 
; HL = buff, DE = num
;------------------------------------------------------------------------
itoa:
	PUSH	HL
	LD	A, D
	AND	080h
	JR	Z, .it_pos
	LD	A, '-'
	LD	(HL), A
	INC	HL
	PUSH	HL
	LD	H, D
	LD	L, E
	CALL	neg16
	LD	D, H
	LD	E, L
	POP	HL

.it_pos:
	CALL	utoa
	POP	HL
	RET

;------------------------------------------------------------------------
; is_space
;------------------------------------------------------------------------
is_space:
	CP	' '
	JR	Z, .retno
	CP	08
	JR	Z, .retno
	JR	.retyes

;------------------------------------------------------------------------
; is_hex_digit 
; Z flag set if A is a hex digit
;------------------------------------------------------------------------
is_hex_digit:
	PUSH	BC
	LD	B, A
	CALL 	digtohex	
	CP	0FFh
	LD	A, B
	POP	BC
	JR	Z, .retyes
	JR	.retno


;------------------------------------------------------------------------
; is_digit 
; Z flag set if A is a digit
;------------------------------------------------------------------------
is_digit:
	CP	'0'
	JR	C, .retyes
	CP	'9' + 1
	JR	NC, .retyes
	JR	.retno
.retyes:		; Ret with Z flag clear
	PUSH	BC
	LD	B, A
 	LD 	A, 1
	OR	A	
	LD	A, B
	POP	BC
	RET
.retno:			; Ret with Z flag set
	PUSH	BC
	LD	B, A
 	LD 	A, 0
	OR	A	
	LD	A, B
	POP	BC
	RET

;------------------------------------------------------------------------
; digtohex 
; digit in A, value returned in A 
;------------------------------------------------------------------------
digtohex:
	CP	'0'
	JR	C, .dtherr
	; char is >= '0'
	CP	'9' + 1
	JR	NC, .dtnodig
	JR	.dtdig

.dtnodig:
	; char is not a digit
	CP	'A'
	JR	C, .dtherr
	CP	'F' + 1
	JR	NC, .dtnoupr
	JR	.dthudig

.dtnoupr:
	; char is not UC A-F
	CP	'a'
	JR	C, .dtherr
	CP	'f' + 1
	JR	NC, .dtnolwr
	JR	.dthldig

.dtnolwr:
	JR	.dtherr

.dtdig:	
	SUB	'0'
	RET	

.dthudig:	
	SUB	'A' - 10
	RET	

.dthldig:	
	SUB	'a' - 10
	RET	

.dtherr:
 	LD A, 0ffh;
	RET


;------------------------------------------------------------------------
; memset         
;------------------------------------------------------------------------
memset:
        PUSH    BC
        PUSH    HL
        PUSH    DE
        LD      E, A
.ms_next:
        LD      A, B
        OR      C
        JR      Z, .ms_done
        LD      (HL), E
        DEC     BC
        INC     HL
        JR      .ms_next
.ms_done:
        POP     DE
        POP     HL
        POP     BC
        RET

END


