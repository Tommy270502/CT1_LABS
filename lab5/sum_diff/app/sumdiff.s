; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- sumdiff.s
; --
; -- CT1 P05 Summe und Differenz
; --
; -- $Id: sumdiff.s 705 2014-09-16 11:44:22Z muln $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
ADDR_DIP_SWITCH_7_0     EQU     0x60000200
ADDR_DIP_SWITCH_15_8    EQU     0x60000201
ADDR_LED_7_0            EQU     0x60000100
ADDR_LED_15_8           EQU     0x60000101
ADDR_LED_23_16          EQU     0x60000102
ADDR_LED_31_24          EQU     0x60000103

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA MyCode, CODE, READONLY

main    PROC
        EXPORT main

user_prog
        
		;INPUT
		;----------------------------------------------------------------------------------|			
		; Operand B                                                                        |
		LDR     R0, =ADDR_DIP_SWITCH_7_0 	; Load the value from DIP switches 7-0 into R1 |				
		LDRB    R1, [R0]                 	; Load the 8-bit value from switches S7-S0	   |
		; Operand A																		   |																						
		LDR     R0, =ADDR_DIP_SWITCH_15_8	; Load the value from DIP switches 15-8 into R2|
		LDRB    R2, [R0]                    ; Load the 8-bit value from switches S15-S8	   |
		;----------------------------------------------------------------------------------|

		;ADDITION & FLAGS
		;------------------------------------------------------------------|
		ADDS    R3, R2, R1	; ADD R1 and R2 and store the result in R3	   |
		MRS     R5, APSR	; Move APSR flags into R5                      |
		LSRS    R5, R5, #28 ; Move N, Z, C, V to bits 3-0                  | 
		;------------------------------------------------------------------|

		;LEDs for ADD and FLAGS
		;-------------------------------------------------------------------|
		LDR     R0, =ADDR_LED_7_0	; Store the sum (R3) into LEDs 7-0      |
		STRB    R3, [R0]            ; Store the MSB of the sum into LEDs 7-0|					
		;																	|
		LDR     R0, =ADDR_LED_15_8	; Store the flags to LED 15-12			|
		STRB    R5, [R0]            ; Store the flags into LEDs 15-12       |
		;-------------------------------------------------------------------|

		;SUBTRACTION & FLAGS
		;-------------------------------------------------------------------|
		SUBS    R4, R2, R1	; SUBTRACT R2 from R1 and store the result in R4|
		MRS     R6, APSR	; Move APSR flags into R6						|
		LSRS    R6, R6, #28 ; Move N, Z, C, V to bits 3-0					| 
		;-------------------------------------------------------------------|

		;LEDs for SUB and FLAGS
		;----------------------------------------------------------------------------|
		LDR     R0, =ADDR_LED_31_24	; Store the flags to LED 31-28					 |
		STRB    R6, [R0]            ; Store the flags into LEDs 31-28				 |
		;																			 |
		LDR     R0, =ADDR_LED_23_16 ; Store the MSB of the difference into LEDs 23-16|
		STRB    R4, [R0]            ; Store the MSB of the difference into LEDs 23-16|
		;----------------------------------------------------------------------------|
		
        B       user_prog
        ALIGN
        ENDP
        END
