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
; -- CT1 P08 "Strukturierte Codierung" mit Assembler
; --
; -- $Id: struct_code.s 3787 2016-11-17 09:41:48Z kesr $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Address-Defines
; ------------------------------------------------------------------
; input
ADDR_DIP_SWITCH_7_0       EQU        0x60000200
ADDR_BUTTONS              EQU        0x60000210

; output
ADDR_LED_31_0             EQU        0x60000100
ADDR_7_SEG_BIN_DS3_0      EQU        0x60000114

ADDR_LCD_ASCII            EQU        0x60000300
ADDR_LCD_ASCII_BIT_POS    EQU        0x60000302
ADDR_LCD_ASCII_2ND_LINE   EQU        0x60000314
	
BACKLIGHT_FULL              EQU     0xffff
BACKLIGHT_NONE              EQU     0x0000
BACKLIGHT_HALF              EQU     0x0fff

ADDR_LCD_RED                EQU     0x60000340
ADDR_LCD_GREEN              EQU     0x60000342
ADDR_LCD_BLUE               EQU     0x60000344



; ------------------------------------------------------------------
; -- Program-Defines
; ------------------------------------------------------------------
; value for clearing lcd
ASCII_DIGIT_CLEAR        EQU         0x00000000
LCD_LAST_OFFSET          EQU         0x00000028

; offset for showing the digit in the lcd
ASCII_DIGIT_OFFSET        EQU        0x00000030

; lcd background colors to be written
DISPLAY_COLOUR_RED        EQU        0
DISPLAY_COLOUR_GREEN      EQU        2
DISPLAY_COLOUR_BLUE       EQU        4

; ------------------------------------------------------------------
; -- myConstants
; ------------------------------------------------------------------
        AREA myConstants, DATA, READONLY
; display defines for hex / dec
DISPLAY_BIT               DCB        "Bit "
DISPLAY_2_BIT             DCB        "2"
DISPLAY_4_BIT             DCB        "4"
DISPLAY_8_BIT             DCB        "8"
        ALIGN

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY
        ENTRY

        ; imports for calls
        import adc_init
        import adc_get_value

main    PROC
        export main
        ; 8 bit resolution, cont. sampling
        BL         adc_init 
        BL         clear_lcd

user_prog
        LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		
		LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		
		LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		
		LDR		R7, =ADDR_7_SEG_BIN_DS3_0
		MOVS	R0, #0
		MOVS	R1, #0
		MOVS	R2, #0
		STR	R0, [R7, #0]
		
main_loop
; STUDENTS: To be programmed
		BL 		adc_get_value 		;stores adc_val in R0
		
		;read out buttons
		LDR 	R1, =ADDR_BUTTONS
		LDRB	R2, [R1];			;stores button values
		
		;check if button t0 is pressed
		MOVS 	R3, #1
		TST		R2, R3
		BNE		t0_pressed		
		
		LDR 	R1, =ADDR_DIP_SWITCH_7_0
		LDRB	R1, [R1]
		SUBS	R1, R0
		BGE     result_ge_zero ; Branch if the result is >= 0
		;if negative
		BL 		set_red
		LDR		R7, =ADDR_7_SEG_BIN_DS3_0
		STRB	R1, [R7, #1]
		
		
; END: To be programmed
        B          main_loop
		
set_red
		LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		
		BX 		LR

result_ge_zero
		LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
        LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
        STRH    R6, [R7]                        ; Write pwm register for blue backlight
		
		LDR		R7, =ADDR_7_SEG_BIN_DS3_0
		STRB	R1, [R7, #1]
		
		ADDR_LCD_ASCII  EQU      0x60000300
 
                LDR      r0, =ADDR_LCD_ASCII
                LDR      r1, ="E"                         ; Load value of ASCII char 'E' into r1.                
                STRB     r1, [r0, #12]                    ; Write 'E' at position 13 on the LCD.

		B main_loop
		
t0_pressed
	; Set the background color of the LCD to green
	LDR     R7, =ADDR_LCD_GREEN              ; Load base address of green backlight
    LDR     R6, =BACKLIGHT_FULL              ; Set backlight to full brightness (green)
    STRH    R6, [R7]                         ; Write PWM register for green backlight
	LDR     R7, =ADDR_LCD_RED                ; Load base address of red backlight
    LDR     R6, =BACKLIGHT_NONE              ; Turn off red backlight
    STRH    R6, [R7]                         ; Write PWM register for red backlight
	LDR     R7, =ADDR_LCD_BLUE               ; Load base address of blue backlight
    LDR     R6, =BACKLIGHT_NONE              ; Turn off blue backlight
    STRH    R6, [R7]                         ; Write PWM register for blue backlight
	
	; Display the ADC value on the 7-segment display
	LDR		R7, =ADDR_7_SEG_BIN_DS3_0
	STRB	R0, [R7, #0]

	; Initialize LED bar based on ADC value
	LSRS    R0, R0, #3            ; Scale ADC value from 8-bit to 5-bit by dividing by 8
	MOVS    R1, #1                ; Initialize R1 with LED0 (first LED bit)

led_bar_loop
	CMP     R0, #0                 ; Compare scaled ADC value with 0
	BEQ     end_led_bar            ; Exit loop if no more LEDs to turn on
	LSLS    R2, R1, #1             ; Shift R1 left by 1 to set the next LED bit in R2
	ORRS    R1, R1, R2             ; OR the shifted bit to R1 to turn on the next LED
	SUBS    R0, R0, #1             ; Decrease scaled ADC value by 1
	B       led_bar_loop           ; Repeat until R0 is 0

end_led_bar
	LDR     R2, =ADDR_LED_31_0    ; Load the LED base address
	STR     R1, [R2]              ; Write result to display LED bar on LED31..0

	B main_loop

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

clear_lcd
        PUSH       {R0, R1, R2}
        LDR        R2, =0x0
clear_lcd_loop
        LDR        R0, =ADDR_LCD_ASCII
        ADDS       R0, R0, R2                       ; add index to lcd offset
        LDR        R1, =ASCII_DIGIT_CLEAR
        STR        R1, [R0]
        ADDS       R2, R2, #4                       ; increas index by 4 (word step)
        CMP        R2, #LCD_LAST_OFFSET             ; until index reached last lcd point
        BMI        clear_lcd_loop
        POP        {R0, R1, R2}
        BX         LR

write_bit_ascii
        PUSH       {R0, R1}
        LDR        R0, =ADDR_LCD_ASCII_BIT_POS 
        LDR        R1, =DISPLAY_BIT
        LDR        R1, [R1]
        STR        R1, [R0]
        POP        {R0, R1}
        BX         LR

        ENDP
        ALIGN


; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        END
