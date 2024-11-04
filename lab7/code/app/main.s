;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 7
;* -- Description : Control structures
;* -- 
;* -- $Id: main.s 3748 2016-10-31 13:26:44Z kesr $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
    
                AREA myCode, CODE, READONLY
                    
                THUMB

BACKLIGHT_FULL              EQU     0xffff
BACKLIGHT_NONE              EQU     0x0000
BACKLIGHT_HALF              EQU     0x0fff

ADDR_LCD_RED                EQU     0x60000340
ADDR_LCD_GREEN              EQU     0x60000342
ADDR_LCD_BLUE               EQU     0x60000344
ADDR_LCD_BIN                EQU     0x60000330

ADDR_LED_15_0           EQU     0x60000100
ADDR_LED_31_16          EQU     0x60000102
ADDR_7_SEG_BIN_DS1_0    EQU     0x60000114
ADDR_DIP_SWITCH_15_0    EQU     0x60000200
ADDR_HEX_SWITCH         EQU     0x60000211

NR_CASES                EQU     0xB

jump_table      ; ordered table containing the labels of all cases
                ; STUDENTS: To be programmed 
				DCD		case_dark
				DCD		case_add
				DCD		case_sub
				DCD		case_mult
				DCD		case_AND
				DCD		case_OR
				DCD		case_XOR
				DCD		case_NOT
				DCD		case_NAND
				DCD		case_NOR
				DCD		case_XNOR
				DCD		case_bright
                ; END: To be programmed
    

; -------------------------------------------------------------------
; -- Main
; -------------------------------------------------------------------   
                        
main            PROC
                EXPORT main

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


read_dipsw      ; Read operands into R0 and R1 and display on LEDs
                ; STUDENTS: To be programmed
				LDR 	R3, =ADDR_DIP_SWITCH_15_0
				LDRB	R1, [R3]		;8bit op2
				LDRB	R0, [R3,#1]		;8bit op1
				
				LDR		R3, =ADDR_LED_15_0 
				STRB	R1, [R0]
				STRB	R0, [R0,#1]
				
				UXTB	R0, R0			;32bit op2
				UXTB	R1, R1			;32bit op2
                ; END: To be programmed
                    
read_hexsw      ; Read operation into R2 and display on 7seg.
                ; STUDENTS: To be programmed
				LDR		R2, =ADDR_HEX_SWITCH
				LDRB	R2, [R2]
				MOVS	R3, #0x0f
				ANDS	R2, R2, R3
				LDR		R3, =ADDR_7_SEG_BIN_DS1_0
				STRB	R2, [R3]
                ; END: To be programmed
                
case_switch     ; Implement switch statement as shown on lecture slide
                ; STUDENTS: To be programmed
				CMP   R2, #NR_CASES 
				BHS   case_bright 
				LSLS  R2, #2   ; * 4 
				LDR   R7, =jump_table 
				LDR   R7, [R7, R2] 
				BX    R7
                ; END: To be programmed


; Add the code for the individual cases below
; - operand 1 in R0
; - operand 2 in R1
; - result in R0

case_dark       

				LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]
				
                ; Set LEDs to dark (0)
                LDR  	R0, =0
                B    	display_result

case_add        
				LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
				LDR    R6, 	=BACKLIGHT_FULL
				STRH    R6, [R7]
				
                ; Add R0 and R1, store result in R0
                ADDS 	R0, R0, R1
                B    	display_result

case_sub        
				LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
				LDR    R6, 	=BACKLIGHT_NONE
				STRH    R6, [R7]
				
                ; Subtract R1 from R0, store result in R0
                SUBS 	R0, R0, R1
                B    	display_result

case_mult       
				LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
				LDR    R6, 	=BACKLIGHT_NONE
				STRH    R6, [R7]
				
				MULS	R0, R1, R0
				B    	display_result

case_AND        
				LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
				LDR    R6, 	=BACKLIGHT_NONE
				STRH    R6, [R7]
	
                ; Bitwise AND between R0 and R1, store result in R0
                ANDS 	R0, R0, R1
                B    	display_result

case_OR         
				LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_NONE             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
				LDR    R6, 	=BACKLIGHT_FULL
				STRH    R6, [R7]
				
                ; Bitwise OR between R0 and R1, store result in R0
                ORRS 	R0, R0, R1
                B    	display_result

case_XOR        
				LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_HALF             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
				LDR    R6, 	=BACKLIGHT_FULL
				STRH    R6, [R7]
					
                ; Bitwise XOR between R0 and R1, store result in R0
                EORS 	R0, R0, R1
                B    	display_result

case_NOT        
				LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_HALF             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
				LDR    R6, 	=BACKLIGHT_FULL
				STRH    R6, [R7]

                ; Bitwise NOT of R0, store result in R0
                MVNS 	R0, R0
                B    	display_result

case_NAND       
				LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
				LDR    R6, 	=BACKLIGHT_HALF
				STRH    R6, [R7]

                ; Bitwise NAND between R0 and R1, store result in R0
                ANDS 	R0, R0, R1
                MVNS 	R0, R0
                B    	display_result

case_NOR        
				LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_HALF             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_HALF             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
				LDR    R6, 	=BACKLIGHT_FULL
				STRH    R6, [R7]

                ; Bitwise NOR between R0 and R1, store result in R0
                ORRS 	R0, R0, R1
                MVNS 	R0, R0
                B    	display_result

case_XNOR       

				LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_HALF             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
				LDR    R6, 	=BACKLIGHT_HALF
				STRH    R6, [R7]
				
                ; Bitwise XNOR between R0 and R1, store result in R0
                EORS 	R0, R0, R1
                MVNS 	R0, R0
                B    	display_result

case_bright     
				LDR     R7, =ADDR_LCD_BLUE              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_RED              ; Load base address of pwm blue
				LDR     R6, =BACKLIGHT_FULL             ; Set backlight to full brightness (blue)
				STRH    R6, [R7]                        ; Write pwm register for blue backlight
				
				LDR     R7, =ADDR_LCD_GREEN              ; Load base address of pwm blue
				LDR    R6, 	=BACKLIGHT_FULL
				STRH    R6, [R7]

                ; Set LEDs to bright (all on)
                LDR  	R0, =0xFFFF
                B    	display_result


; STUDENTS: To be programmed


; END: To be programmed


display_result  ; Display result on LEDs
                ; STUDENTS: To be programmed
				LDR  R3, =ADDR_LED_31_16
                STRH R0, [R3]         ; Store lower 8 bits to LED
				LSRS R0, #16
                STRH R0, [R3, #2]     ; Store higher 8 bits to LED
                ; END: To be programmed

                B    read_dipsw
                
                ALIGN
                ENDP

; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END

