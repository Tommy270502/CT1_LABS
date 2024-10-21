; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; -- 
; -- table.s 
; -- 
; -- CT1 P04 Ein- und Ausgabe von Tabellenwerten 
; -- 
; -- $Id: table.s 800 2014-10-06 13:19:25Z ruan $ 
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB
; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
ADDR_DIP_SWITCH_7_0         EQU     0x60000200
ADDR_DIP_SWITCH_15_8        EQU     0x60000201
ADDR_DIP_SWITCH_23_16       EQU     0x60000202
ADDR_DIP_SWITCH_31_24       EQU     0x60000203
ADDR_LED_7_0                EQU     0x60000100
ADDR_LED_15_8               EQU     0x60000101
ADDR_LED_23_16              EQU     0x60000102
ADDR_LED_31_24              EQU     0x60000103
ADDR_BUTTONS                EQU     0x60000210

BITMASK_KEY_T0              EQU     0x01
BITMASK_LOWER_NIBBLE        EQU     0x0F
    
SEV_SEG_1_0                 EQU     0x60000114
SEV_SEG_3_2                 EQU     0x60000115

; ------------------------------------------------------------------
; -- Variables
; ------------------------------------------------------------------
        AREA MyAsmVar, DATA, READWRITE
; STUDENTS: To be programmed

;define array with 16 8-bit values.
byte_array        SPACE     16

input_value        DCB        0x00
input_index        DCB     0x00

output_value     DCB     0x00
output_index     DCB     0x00

; END: To be programmed
        ALIGN

; ------------------------------------------------------------------
; -- myCode BY THOMAS S. PERRI
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY

main    PROC
        EXPORT main

readInput
        BL    waitForKey                    ; wait for key to be pressed and released

        ; ----------------------------------------------------
        ; Input Value (DIP Switches 7-0 -> LEDs 7-0)
        ; ----------------------------------------------------
        LDR     R0, =ADDR_DIP_SWITCH_7_0    ; Load the address of DIP switches 7-0
        LDR     R1, [R0]                    ; Load the value from the DIP switches into R1
        LDR     R0, =ADDR_LED_7_0           ; Load the address of LEDs into R0
        STR     R1, [R0]                    ; Store the value from R1 into LEDs 7-0

        ; SAVE R1 (DIP Switches 7-0) to input_value
        LDR     R0, =input_value            ; Load the address of input_value
        STRB    R1, [R0]                    ; Store R1 (DIP switches 7-0) into input_value
        
        ; ----------------------------------------------------
        ; Apply mask to DIP switches 11-8 for input index
        ; ----------------------------------------------------
        LDR     R0, =ADDR_DIP_SWITCH_15_8   ; Load the address of DIP switches 15-8
        LDR     R1, [R0]                    ; Load the value from the DIP switches into R1
        LDR     R2, =BITMASK_LOWER_NIBBLE   ; Load the bitmask for lower nibble into R2
        ANDS     R1, R1, R2                  ; Mask to keep only the lower nibble (switches 11-8)
        
        ; SAVE R1 (DIP Switches 11-8) to input_index
        LDR     R0, =input_index            ; Load the address of input_index
        STRB    R1, [R0]                    ; Store R1 (masked DIP switches 11-8) into input_index

        ; Display masked value (input_index) on LEDs 15-8
        LDR     R0, =ADDR_LED_15_8          ; Load the address of LEDs 15-8
        STR     R1, [R0]                    ; Store R1 (input_index) to LEDs 15-8

        ; ----------------------------------------------------
        ; Save input_value to byte_array at input_index
        ; ----------------------------------------------------
        LDR     R0, =input_value            ; Load the value of input_value
        LDRB    R2, [R0]                    ; Load input_value into R2

        LDR     R0, =input_index            ; Load the value of input_index
        LDRB    R1, [R0]                    ; Load input_index into R1

        LDR     R0, =byte_array             ; Load the base address of byte_array
        ADD     R0, R0, R1                  ; Calculate the address in byte_array using input_index

        STRB    R2, [R0]                    ; Store input_value in byte_array at input_index

        ; ----------------------------------------------------
        ; Input Value (DIP Switches 24-27) for byte_array to display on led 16-23
        ; ----------------------------------------------------
        LDR        R0, =ADDR_DIP_SWITCH_31_24    ; Load base address of SW23-16
        LDR     R1, [R0]                    ; Load the value from the DIP switches into R1
        LDR     R2, =BITMASK_LOWER_NIBBLE   ; Load the bitmask for lower nibble into R2
        ANDS    R1, R1, R2                  ; Mask to keep only the lower nibble (switches 24-27)
        
        LDR        R0, =ADDR_LED_31_24            ; Load base address of SW23-16
        STR        R1, [R0]                    ; Store R1 (output_index) to LED 24-27 
        
        ; ----------------------------------------------------
        ; Use output index to get value from byte_array
        ; ----------------------------------------------------
        LDR     R0, =output_index          ; Load the address of output_index
        STRB    R1, [R0]                   ; Store R1 (masked DIP switches 24-27) into output_index

        LDR     R0, =output_index          ; Load the address of output_index
        LDRB    R1, [R0]                   ; Load the value of output_index into R1

        LDR     R0, =byte_array            ; Load the base address of byte_array
        ADD     R0, R0, R1                 ; Calculate the address in byte_array using output_index
        LDRB    R2, [R0]                   ; Load the value from byte_array at the output_index into R2

        ; ----------------------------------------------------
        ; Output the byte_array value to LEDs
        ; ----------------------------------------------------
        LDR     R0, =ADDR_LED_23_16        ; Load base address of LEDs 23-16
        STRB    R2, [R0]                   ; Store the byte (R2) into LEDs 23-16

        ; ----------------------------------------------------
        ; Display the value on the seven-segment display
        ; ----------------------------------------------------
        LDR     R0, =SEV_SEG_1_0           ; Load base address of seven-segment display
        STRB    R2, [R0]                   ; Output the byte_array value (R2) to the seven-segment display

        ; ----------------------------------------------------
        ; Display index on another seven-segment display (3-2)
        ; ----------------------------------------------------
        LDR     R0, =SEV_SEG_3_2           ; Load base address of second seven-segment display
        STRB    R1, [R0]                   ; Output the index value (R1) to the second seven-segment display

        ; Repeat the process
        B       readInput                   ; Loop to start again

        ALIGN

; ------------------------------------------------------------------
; Subroutines
; ------------------------------------------------------------------

; wait for key to be pressed and released
waitForKey
        PUSH    {R0, R1, R2}
        LDR     R1, =ADDR_BUTTONS           ; load base address of keys
        LDR     R2, =BITMASK_KEY_T0         ; load key mask T0

waitForPress
        LDRB    R0, [R1]                    ; load key values
        TST     R0, R2                      ; check, if key T0 is pressed
        BEQ     waitForPress

waitForRelease
        LDRB    R0, [R1]                    ; load key values
        TST     R0, R2                      ; check, if key T0 is released
        BNE     waitForRelease
                
        POP     {R0, R1, R2}
        BX      LR
        ALIGN

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        ENDP
        END
