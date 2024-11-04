; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- add64.s
; --
; -- CT1 P05 64 Bit Addition
; --
; -- $Id: add64.s 3712 2016-10-20 08:44:57Z kesr $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
ADDR_DIP_SWITCH_31_0        EQU     0x60000200
ADDR_BUTTONS                EQU     0x60000210
ADDR_LCD_RED                EQU     0x60000340
ADDR_LCD_GREEN              EQU     0x60000342
ADDR_LCD_BLUE               EQU     0x60000344
ADDR_LCD_BIN                EQU     0x60000330
MASK_KEY_T0                 EQU     0x00000001
MASK_KEY_T1                 EQU     0x00000010
BACKLIGHT_FULL              EQU     0xffff
BACKLIGHT_NONE              EQU     0x0000

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA MyCode, CODE, READONLY

main    PROC
        EXPORT main

user_prog
        LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		
		LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		
		LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight

        MOVS    R0, #0                          ; Initialize lower 32 bits of total sum to 0
        MOVS    R1, #0                          ; Initialize higher 32 bits of total sum to 0

endless
        BL      waitForKey                      ; Wait for key T0 to be pressed
		
		; Load 32-bit value from DIP switches
        LDR     R2, =ADDR_DIP_SWITCH_31_0       ; Load DIP switch address
        LDR     R3, [R2]                        ; Load 32-bit value from DIP switch into R3

        ; Add DIP switch value to the lower 32 bits (R0)
        ADDS    R0, R0, R3                      ; Add DIP switch value to lower 32 bits (R0)

        ; Check if a carry occurred
        BCC     no_carry                        ; If no carry, skip the incrementing of R1

        ; Handle the carry manually: increment the higher 32 bits (R1)
        ADDS    R1, R1, #1                      ; Manually add carry to the higher 32 bits

no_carry
        ; Update the LCD with the new 64-bit value
        LDR     R5, =ADDR_LCD_BIN               ; Load base address of LCD binary display
        STR     R0, [R5]                        ; Store lower 32 bits (R0) to LCD
        STR     R1, [R5, #8]                    ; Store upper 32 bits (R1) to LCD (offset by 4 bytes)

        B       endless                         ; Repeat forever
        ALIGN


;----------------------------------------------------
; Subroutines
;----------------------------------------------------

; wait for key to be pressed and released
waitForKey
		
		LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		
		LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		
		LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		
        PUSH    {R0, R1, R2, R3}
        LDR     R1, =ADDR_BUTTONS               ; Load base address of keys
        LDR     R2, =MASK_KEY_T0                ; Load key mask T0

waitForPress
        
		LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]
		
		LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		
		LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		
		LDRB    R0, [R1]                        ; Load key values
        TST     R0, R2                          ; Check if key T0 is pressed
        BEQ     waitForPress

waitForRelease

		LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]

		LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		
		LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight

        LDRB    R0, [R1]                        ; Load key values
        TST     R0, R2                          ; Check if key T0 is released
        BNE     waitForRelease

        POP     {R0, R1, R2, R3}
        BX      LR
        ALIGN

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        ENDP
        END
