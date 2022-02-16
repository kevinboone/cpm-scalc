;------------------------------------------------------------------------
;  intmath.inc
;
;  Various 16-bit math functions
;
;  Copyright (c)2021 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

	.Z80

; mul16 
; Unsigned multiply HL by DE, result in HL 
external mul16 

; div16 
; Unsigned divide HL by DE, result in HL, remainder in DE
external div16 

; sdiv16 
; Signed divide HL by DE, result in HL, remainder in DE
external sdiv16

; neg16
; Negate the number in HL
external neg16

