;------------------------------------------------------------------------
;  conio.asm 
;
;  See conio.inc for descriptions.
;
;  Copyright (c)2022 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

 	.Z80

	include bdos.inc

	global putch, putdigit, puth8, puts, space, newline, exit
	global puth16

;------------------------------------------------------------------------
; exit
; Return to BDOS
;------------------------------------------------------------------------
exit:
       LD C, 0
       CALL  BDOS 

;------------------------------------------------------------------------
;  newline
;  Output CR+LF; all registers preserved
;------------------------------------------------------------------------
newline:
       PUSH   AF
       LD     A, 13
       CALL   putch
       LD     A, 10
       CALL   putch
       POP    AF
       RET

;------------------------------------------------------------------------
;  putch
;  Output the character in A; other registers preserved.
;------------------------------------------------------------------------
putch:
       PUSH   HL        ; We must preserve HL, as the BDOS call sets it
       PUSH   BC
       PUSH   AF
       PUSH   DE 
       LD     C, CONOUT 
       LD     E, A 
       CALL   BDOS 
       POP    DE
       POP    AF
       POP    BC
       POP    HL
       RET

;------------------------------------------------------------------------
;  putdigit
;  Output a single hex digit in A; other registers preserved 
;------------------------------------------------------------------------
putdigit:
	PUSH   AF
	CP     10        ; Digit >= 10
	JR     C, putdigit_lt
	ADD    A, 'A' - 10 
	CALL   putch
	POP    AF
	RET
putdigit_lt:            ; Digit < 10
	ADD    A, '0'
	CALL   putch
	POP    AF
	RET

;------------------------------------------------------------------------
;  puth8
;  Output the 8-bit hex nunber A; other registers preserved 
;------------------------------------------------------------------------
puth8:
	PUSH 	AF
	PUSH 	AF
	SRA	A
	SRA	A
	SRA	A
	SRA	A
	AND	0Fh
	CALL	putdigit
	POP 	AF
	AND	0Fh
	CALL	putdigit
	POP 	AF
	RET


;------------------------------------------------------------------------
;  puth16
;  Output the 16-bit hex nunber HL; other registers preserved 
;------------------------------------------------------------------------
puth16:
	PUSH	AF
	LD	A, H
	CALL	puth8
	LD	A, L
	CALL 	puth8
	POP 	AF
	RET


;------------------------------------------------------------------------
;  putnum
;  Output the value in A as two-digit hex number; other reg. perserved
;------------------------------------------------------------------------
putnum:
       PUSH   AF
       SRA    A         ; Is there a nicer way to divide by 16?
       SRA    A
       SRA    A
       SRA    A
       AND    0Fh 
       CALL   putdigit
       POP    AF
       PUSH   AF
       AND    0Fh 
       CALL   putdigit
       POP    AF
       RET

;------------------------------------------------------------------------
;  puts 
;  Output a zero-terminated string whose address is in HL; all 
;  registers preserved.
;------------------------------------------------------------------------
puts:
       PUSH   HL
       PUSH   AF
       PUSH   BC 
       PUSH   DE 
puts_next:
       LD     A,(HL) 
       OR     0 
       JR     Z, puts_done

       LD     C, 2
       LD     E, A 
       PUSH   HL
       CALL   BDOS 
       POP    HL

       INC    HL
       JR     puts_next
puts_done:
       POP    DE 
       POP    BC 
       POP    AF
       POP    HL
       RET

;------------------------------------------------------------------------
;  space 
;  Output a space; all registers preserved
;------------------------------------------------------------------------
space:
       PUSH   AF
       LD     A,' ' 
       CALL   putch
       POP    AF
       RET

end

