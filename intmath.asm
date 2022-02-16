;------------------------------------------------------------------------
;  intmath.asm 
;
;  Various routines for 16-bit integer math. See intmath.inc for
;    descriptions.
;
;  Copyright (c)2022 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

 	.Z80

	global mul16, div16, neg16, sdiv16
	include dbgutl.inc

;------------------------------------------------------------------------
; mul16 
;------------------------------------------------------------------------
mul16:
	PUSH 	DE 
	PUSH	BC
	PUSH 	AF	
	LD 	B, H
	LD 	C, L
    	LD 	A, 16 ; No. of bits to process    
    	LD 	HL, 0 ; Cumulative result
.m16_loop:
	SRL 	B
	RR 	C        
	JR 	NC, .m16_no 
	ADD 	HL, DE   
.m16_no:
	EX 	DE, HL    
	ADD 	HL, HL   
	EX 	DE, HL    
	DEC 	A
	JR 	NZ, .m16_loop 
	POP	AF
	POP 	BC 
	POP	DE
	RET

;------------------------------------------------------------------------
; div16 
;------------------------------------------------------------------------

div16:
	PUSH	BC
	PUSH	AF	
	LD 	B, H
	LD 	C, L
	LD 	HL, 0
	LD 	A, B
	LD 	B, 8
.d16_l1:
	RLA
	ADC HL, HL
	SBC HL, DE
	JR NC, .D16_NO1
	ADD HL,DE
.d16_no1:
	DJNZ .d16_l1
	RLA
	CPL
	LD B ,A
	LD A, C
	LD C, B
	LD B, 8
.d16_l2:
	RLA
	ADC HL,HL
	SBC HL,DE
	JR NC, .d16_no2
	ADD 	HL, DE
.d16_no2:
	DJNZ .d16_l2
	RLA
	CPL
	LD 	B, C
	LD 	C, A
	POP	AF
	LD 	D, H
	LD 	E, L
	LD 	H, B
	LD 	L, C
	POP 	BC
	RET

;------------------------------------------------------------------------
; sdiv16 
;------------------------------------------------------------------------
sdiv16:
	PUSH	BC
	PUSH	AF

	LD	B, 0	; B will store the number of args that are -ve
	LD	A, H
	AND	080h
	JR	Z, .sdhlpos
	; HL is negative
	CALL	neg16	; Negate HL if necessary and inc B
	INC	B

.sdhlpos:
	PUSH	HL

	LD	H, D
	LD	L, E

	LD	A, H
	AND	080h
	JR	Z, .sddepos
	
	CALL	neg16	; Negate DE if necessary, and inc B
	INC	B

.sddepos:
	LD	D, H
	LD	E, L
	POP	HL

	CALL    div16	; Do the division as unsigned

	LD	A, B
	AND	1
	JR	Z, .sdsgn
	CALL	neg16	; If zero or two args were signed, negate result
.sdsgn:

	POP	AF
	POP	BC
	RET


;------------------------------------------------------------------------
; neg16 
;------------------------------------------------------------------------
neg16:
	PUSH	AF
	XOR 	A
	SUB 	L
	LD 	L, A
	SBC 	A, A
	SUB 	H
	LD 	H, A
	POP	AF
	RET

END



