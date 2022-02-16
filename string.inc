;------------------------------------------------------------------------
;  string.inc
;
;  String and memory manipulation routines.
;
;  Copyright (c)2021 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

	.Z80

; MAX_DEC_STR is the size of buffer needed to store a decimal 
;   representation of a signed 16-bit integer, including the
;   terminating zero. "-32767[0]" 
	MAX_DEC_STR	equ	7

;------------------------------------------------------------------------
; strlen 
; Length returned in DE of a zero-terminated string in HL. The result
;  does not include the zero terminator (just like in C)
;------------------------------------------------------------------------
external strlen 

;------------------------------------------------------------------------
; streverse
; Reverse the zero-termnated string whose starting address is in HL.
; The length (not including terminator) is in DE. If DE == 0,
;   calculate the length by counting (slow).
;------------------------------------------------------------------------
external streverse

;------------------------------------------------------------------------
; utoa
; Signed 16-bit integer in DE, to a zero-terminated decimal string stored
;   at HL. The buffer at HL must have room to fit the converted number,
;   including the minus sign if negative
;------------------------------------------------------------------------
external itoa

;------------------------------------------------------------------------
; utoa
; Unsigned 16-bit integer in DE, to a zero-terminated decimal string stored
;   at HL. The buffer at HL must have room to fit the converted number. 
;------------------------------------------------------------------------
external utoa

;------------------------------------------------------------------------
; is_digit
; Returns with the zero flag set if the ASCII char in A is in the
;   range '0'-'9'
;------------------------------------------------------------------------
external is_digit

;------------------------------------------------------------------------
; is_hex_digit
; Returns with the zero flag set if the ASCII char in A is in the
;   range '0'-'9', 'A'-'F', or 'a'-'F'
;------------------------------------------------------------------------
external is_hex_digit

;------------------------------------------------------------------------
; is_space
; Returns with the zero flag set if the ASCII char in A is 
;   ' ' or '\t' 
;------------------------------------------------------------------------
external is_space

;------------------------------------------------------------------------
; Returns in A the numerical value of the ASCII hex digit in A. If 
;   A does not contain a hex digit, returns 0xFF
;------------------------------------------------------------------------
external digtohex

;------------------------------------------------------------------------
; memset 
; Set BC bytes of memory starting at HL to A
;------------------------------------------------------------------------
external memset

