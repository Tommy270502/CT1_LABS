AREA myCode, CODE, READONLY
THUMB
;---------------------------------------------
;  to be programmed ..
EXPORT out_word
EXPORT in_word

; Parameter:
; R0 - Address (out_address)
; R1 - Value (out_value)
out_word
	STR R1, [R0]	;store the value inside the R1 register into the address written in the R0 register.
	BX LR			;return to function call.

; Parameter:
; R0 - Address (in_address)
; Return value:
; R0 - Read value
in_word
	LDR R0, [R0]
	BX LR

;  .. end to be programmed
;---------------------------------------------

	ALIGN
	END

