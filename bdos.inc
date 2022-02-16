;------------------------------------------------------------------------
;  bdos.inc
;
;  Various BDOS constants
;
;  Copyright (c)2022 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

; List of the global symbols in dbgutl

	.Z80

	; BDOS call entry point
	BDOS	equ	5

	; Default FCB address 
	DEFFCB	equ	05Ch

	; Start of DMA buffer
	DMABUF  equ	80h
	
	; Console output character
	CONOUT equ 2 

	; Buffered console input
	C_READSTR equ 10

	; Open file 
	F_OPEN equ 15 

	; Search first 
	F_SFIRST equ 17

	; Close file 
	F_CLOSE equ 16

	; Search first 
	F_SNEXT equ 18

	; Read sequential file 
	F_READ equ 20 

	; Sizefile 
	F_SIZE equ 35 

	; Size in bytes of an FCB
	FCBSIZE	equ 36

	; Size to allow for the stack, which is located just below the
	;   BDOS CCP, and grows downwards. This figure is used when
	;   calculating the amount of memory available to a program and
	;   is, at best, an estimate. Stack-crashing is a well-known
	;   problem in CP/M
	BD_STACK_MAX	equ	256


