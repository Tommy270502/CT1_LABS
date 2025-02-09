;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 10
;* -- Description : Search Max
;* -- 
;* -- $Id: search_max.s 879 2014-10-24 09:00:00Z muln $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
                AREA myCode, CODE, READONLY
                THUMB
                    
; STUDENTS: To be programmed

TABLE_LENGTH_0  EQU     0x80000000 


; END: To be programmed
; -------------------------------------------------------------------                    
; Searchmax
; - tableADDSress in R0
; - table length in R1
; - result returned in R0
; -------------------------------------------------------------------   
search_max      PROC
                EXPORT search_max

                PUSH    {R4, R5, R6, R7} ; Save registers before using them

                CMP     R1, #0           ; Check if table length is 0
                BEQ     handle_empty     ; If length is 0, handle special case

                MOVS    R4, R0           ; Base address of the table
                LDR     R0, [R4]         ; Load the first value as the initial max
                MOVS    R6, #4           ; Offset for 32-bit elements
                MOVS    R5, #1           ; Start from the second element (index 1)

loop
                CMP     R5, R1           ; Compare index with table length
                BGE     exit_search_max  ; Exit if all elements processed

                LSLS    R7, R5, #2       ; Multiply index (R5) by 4 (shift left by 2)
                ADDS    R7, R7, R4       ; Add base address to offset
                LDR     R2, [R7]         ; Load current element
                CMP     R2, R0           ; Compare with current max (signed)
                BLE     next             ; Skip if current element <= max (signed)

                MOVS    R0, R2           ; Update max

next
                ADDS    R5, R5, #1       ; Increment index
                B       loop             ; Repeat loop

handle_empty
                LDR     R0, =TABLE_LENGTH_0 ; Return 0x80000000 for empty table
                B       exit_search_max

exit_search_max
                POP     {R4, R5, R6, R7} ; Restore saved registers
                BX      LR               ; Return to caller

                ALIGN
                ENDP


; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END

