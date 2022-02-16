;------------------------------------------------------------------------
;  dbgutil.inc
; 
;  Various handy debugging routines.
;
;  Copyright (c)2021 Kevin Boone, GPL v3.0
;------------------------------------------------------------------------

; List of the global symbols in dbgutl

	.Z80


;------------------------------------------------------------------------
; dmpreg
; Dump register contents to the console
;------------------------------------------------------------------------
external dmpreg 

;------------------------------------------------------------------------
; dmp16
; Dump 16 bytes starting at HL 
;------------------------------------------------------------------------
external dmp16

