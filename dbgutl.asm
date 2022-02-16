;------------------------------------------------------------------------
;  dbgutl.asm 
;
;  See dbgutl.inc for descriptions. 
;
;  Copyright (c)2022 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

 	.Z80

	include conio.inc

	global dmpreg, dmp16

;------------------------------------------------------------------------
; dmpreg 
;------------------------------------------------------------------------
dmpreg:
	PUSH 	HL
	PUSH 	HL
	LD	HL, s_hl
	CALL	puts
	POP	HL
	CALL	puth16
	CALL	newline
	LD	HL, s_de
	CALL	puts
	LD	H, D
	LD	L, E
	CALL	puth16
	CALL	newline
	LD	HL, s_bc
	CALL	puts
	LD	H, B
	LD	L, C
	CALL	puth16
	CALL	newline
	LD	HL, s_sp
	CALL	puts
	LD	HL, 0
	ADD	HL, SP
	CALL	puth16
	CALL	newline
	LD	HL, s_a
	CALL	puts
	CALL	puth8
	CALL	newline
	POP	HL
	RET

;------------------------------------------------------------------------
; dmp16
;------------------------------------------------------------------------
dmp16:
	PUSH	HL
	PUSH	BC
	PUSH	AF
	LD	B, 16
.dp16next:
	LD	A, (HL)
	CALL	puth8
	CALL	space

	INC	HL
	DJNZ	.dp16next

	CALL	newline
	POP	AF
	POP	BC
	POP	HL
	RET

;------------------------------------------------------------------------
; Data 
;------------------------------------------------------------------------
s_hl: 	db "HL ", 0
s_de: 	db "DE ", 0
s_bc: 	db "BC ", 0
s_sp: 	db "SP ", 0
s_a: 	db "A  ", 0

end


