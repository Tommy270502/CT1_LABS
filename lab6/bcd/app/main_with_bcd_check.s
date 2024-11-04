; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- main.s
; --
; -- CT1 P06 "ALU und Sprungbefehle" mit MUL
; --
; -- $Id: main.s 4857 2019-09-10 17:30:17Z akdi $
; ------------------------------------------------------------------
; Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Address Defines
; ------------------------------------------------------------------

ADDR_LED_15_0           EQU     0x60000100
ADDR_LED_31_16          EQU     0x60000102
ADDR_DIP_SWITCH_7_0     EQU     0x60000200
ADDR_DIP_SWITCH_15_8    EQU     0x60000201
ADDR_7_SEG_BIN_DS3_0    EQU     0x60000114
ADDR_BUTTONS            EQU     0x60000210
ADDR_DIPSW              EQU     0x60000200
ADDR_LEDS               EQU     0x60000100

ADDR_LCD_RED            EQU     0x60000340
ADDR_LCD_GREEN          EQU     0x60000342
ADDR_LCD_BLUE           EQU     0x60000344
LCD_BACKLIGHT_FULL      EQU     0xffff
LCD_BACKLIGHT_OFF       EQU     0x0000

MASK_DIPSW              EQU     0xf0f0
MASK_DIPSW_BCD_ONES     EQU     0xfff0
MASK_DIPSW_BCD_TENS     EQU     0xf0ff

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY

        ENTRY

main    PROC
        EXPORT main

        ; Load DIP switch value
        LDR     R0, =ADDR_DIPSW
        LDR     R1, [R0]

        ; Mask unnecessary switches
        LDR     R0, =MASK_DIPSW
        BICS    R1, R1, R0         ; R1 now stores all necessary switches for the BCD stuff

        MOVS    R2, R1             ; R2 stores all switches (DIP switch value)

        ; Isolate BCD ones (lowest 4 bits)
        LDR     R0, =MASK_DIPSW_BCD_ONES
        BICS    R2, R2, R0         ; R2 now stores BCD ones

        ; Isolate BCD tens (next 4 bits)
        MOVS    R3, R1             ; R3 stores all switches
        LDR     R0, =MASK_DIPSW_BCD_TENS
        BICS    R3, R3, R0         ; R3 now stores BCD tens (shifted left by 4)
        LSRS    R3, R3, #4         ; Shift right to align the tens value in R3

        ; Store BCD tens in R4
        MOVS    R4, R3             ; R4 now stores BCD tens

        ; Combine BCD ones and tens for LEDs output
        ORRS    R4, R4, R2         ; R4 stores LED values (BCD ones and tens combined)

        ; Multiply BCD tens by 10
        LSRS    R3, R3, #4
        MOVS    R5, R3             ; Copy the tens value from R3 to R5

        LSLS    R3, R3, #3         ; R3 = value * 8 (left shift by 3)
        LSLS    R5, R5, #1         ; R5 = value * 2 (left shift by 1)

        ADDS    R3, R3, R5         ; R3 = (value * 8) + (value * 2), which is value * 10

        ; Initialize R6 to zero before accumulating the result
        MOVS    R6, #0

        ; Add the multiplied value to R6 (result)
        ADDS    R6, R6, R3
        ADDS    R6, R6, R2         ; Add the BCD ones value

        ; Store decimal value of BCD total to LEDs 15-8
        LDR     R0, =ADDR_LEDS
        STRB    R6, [R0, #1]

        ; Store result on 7-segment display
        LDR     R0, =ADDR_7_SEG_BIN_DS3_0
        STRB    R4, [R0, #0]       ; Store ones and tens combined in 7-segment display lower part
        STRB    R6, [R0, #1]       ; Store the multiplied tens + ones in another segment

        ; Store combined BCD ones and tens on LEDs 7-0
        LDR     R0, =ADDR_LEDS
        STRB    R4, [R0]

        ; TASK 2 DISCO LIGHTS
        

        MOVS    R0, R6             ; Load the value for which to count bits

        ; Count bits in R0 and store result in R1
        BL      count_bits

		MOVS    R2, R1
		LSLS    R2, R2, #16
		ORRS	R2,R2,R1
		MOVS	R3, #1
		RORS	R2,R2,R3

        ; Display bit count result on LEDs
        LDR     R0, =ADDR_LEDS
        STRH    R2, [R0,#2]        ; Store count result on LEDs
		BL      pause
        ; Return to main loop
        B       main               ; Loop
        ENDP

            
;----------------------------------------------------
; Subroutines
;----------------------------------------------------

count_bits    PROC
        MOVS    R1, #0             ; Initialize counter to 0
        MOVS    R2, #1             ; Load 1 into R2 as a mask for LSB check

count_loop
        TST     R0, R2             ; Test if LSB is 1 by ANDing with mask in R2
        BEQ     skip_increment     ; If LSB is 0, skip increment
        ADDS    R1, R1, #1         ; Increment counter if LSB is 1

skip_increment
        LSRS    R0, R0, #1         ; Shift R0 right by 1 bit
        BNE     count_loop         ; Repeat until all bits are shifted out

        BX      LR                 ; Return from subroutine
        ENDP

;----------------------------------------------------
pause           PROC
        PUSH    {R0, R1}
        LDR     R1, =1
        LDR     R0, =0x000FFFFF

loop        
        SUBS    R0, R0, R1
        BCS     loop

        POP     {R0, R1}
        BX      LR
        ALIGN
        ENDP

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        END

        ; BCD Validation Check for Ones and Tens

        ; Check if BCD ones (R2) is greater than 9
        CMP     R2, #9
        BHI     BCD_Error           ; Branch to error handling if BCD ones exceed 9

        ; Check if BCD tens (R4) is greater than 9
        CMP     R4, #9
        BHI     BCD_Error           ; Branch to error handling if BCD tens exceed 9

        ; Continue with normal processing if BCD values are valid
        B       Continue_Normal_Processing

BCD_Error
        ; Error handling: set an error flag or reset the values
        MOVS    R4, #0              ; Example: reset BCD value to 0 if invalid
        MOVS    R2, #0              ; Reset BCD ones as well
        ; You could also light up a specific LED here for error indication

Continue_Normal_Processing
