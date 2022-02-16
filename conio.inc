;------------------------------------------------------------------------
;  conio.inc
;
;  Console I/O functions.
;
;  Copyright (c)2021 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

; List of the global symbols in conio.asm

	.Z80

	external exit		; Exit to CP/M 
	external newline
	external puth8		; Argument in A
	external puth16		; Argument in HL
	external putch		;  "
	external putdigit 	;  "
	external puts 		; Address in HL
	external space 

