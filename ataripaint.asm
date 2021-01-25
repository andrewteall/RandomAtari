        processor 6502
        include "includes/vcs.h"
        include "macro.h"
;Start Program
        SEG.U vars
        ORG $80
BlVPos          ds 1            ; $80
BlHPos          ds 1            ; $81
P0VPos          ds 1            ; $82

P0VPosIdx       ds 1            ; $83
        SEG
        ORG $F000

;PATTERN           = $80 ; storage Location (1st byte in RAM)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; Console Initialization ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Reset
        ldx #0
        txa
Clear
        dex
        txs
        pha
        bne Clear
        cld                                             ;       Clear Decimal. Seems to be an issue 
                                                        ;       when the processor status is 
                                                        ;       randomized in Stella

        ldx #76
        stx BlVPos

        lda #80                                     ; Setting the starting count for the Cursor
        sta BlHPos

        ldx #0
        lda #24
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #4
        lda #80
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        lda #132
        sta COLUP0

        lda #9
        sta COLUPF

        lda #%00100001
        sta CTRLPF       

        lda #26
        sta P0VPos 

        ldy P0VPos
        sty P0VPosIdx      

StartOfFrame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Vertical Blank is the only section shared by screens
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Start of vertical blank processing
        lda #0
        sta VBLANK

        lda #2
        sta VSYNC ; Turn on VSYNC

        ; 3 scanlines of VSYNCH signal...
        sta WSYNC
        sta WSYNC
        sta WSYNC
        lda #0
        sta VSYNC ; Turn off VSYNC

        ; 37 scanlines of vertical blank...
        ldx #37                                         ; 2
VerticalBlank
        sta WSYNC                                       ; 3
        dex                                             ; 2
        bne VerticalBlank                               ; 2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 192 scanlines of picture...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #0
        lda #155
        sta COLUBK
ViewableScreenStart

;;;;;;;;;;;;;;;;; Determine if we draw Cursor ;;;;;;;;;;;;;;;;;;;;;;; 
; 12 Cycles to Draw the Cursor
; 11 Cycles to Not Draw the Cursor
; TODO: ADD Cursor Height
; X - Current line number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #0                                          ; 2     Load 0 to A to prepare to disable the Cursor
        cpx BlVPos                                      ; 3     Determine whether or not we're going to draw the Cursor
        bne CursorDisabled                              ; 2/3   Go to enabling the Cursor or not  
        lda #2                                          ; 2     Load #2 to A to prepare to enable the Cursor
CursorDisabled
        sta ENABL                                       ; 3     14/15 cycles

;;;;;;;;;;;;;;;;; Determine if we Player Sprites ;;;;;;;;;;;;;;;;;;;; 
; XX Cycles to Player Sprite
; 11 Cycles to Not Player Sprite
; X - Current line number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #0                                          ; 2
        cpx P0VPosIdx                                   ; 3
        bne PlayerDisabled                              ; 2/3
DrawP0

        txa
        clc
        adc #2
        sta P0VPosIdx

        txa
        sec
        sbc #26
        tay
        lda P0Grfx,y

        cpy P0Height
        bne PlayerDisabled
        ldy P0VPos
        sty P0VPosIdx
PlayerDisabled
        sta GRP0                                        ; 3



        sta WSYNC
        ldy #0                                          ; 2
        sty PF1   
        lda #%00111111                                  ; 2
;;;;;;;;;;;;;;;;; --------------------------- ;;;;;;;;;;;;;;;;;;;;;;; 
; 11 Cycles to Draw the Button
; 5 or 9 Cycles to Not Draw the Button
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #60                                         ; 2
        bpl Button1                                     ; 2/3
        cpx #20                                         ; 2
        bmi Button1                                     ; 2/3
        sta PF1                                         ; 3
Button1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        cpx #120                                        ; 2
        bpl Button2                                     ; 2/3
        cpx #80                                         ; 2
        bmi Button2                                     ; 2/3
        sta PF1                                         ; 3
Button2

        cpx #180                                        ; 2
        bpl Button3                                     ; 2/3
        cpx #140                                        ; 2
        bmi Button3                                     ; 2/3
        sta PF1                                         ; 3
Button3

EndofScreenBuffer
        
        inx
        inx                                             ; 2
        cpx #192                                        ; 2
        sta WSYNC                                       ; 3
        bne ViewableScreenStart                         ; 2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; End of Viewable Screen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda #0
        sta PF0
        sta PF1
        sta PF2

; end of screen - enter blanking
        lda #%00000010
        sta VBLANK

        lda #%00010000            
        bit SWCHA
        bne CursorDown
        dec BlVPos
        dec BlVPos
CursorDown
        lda #%00100000            
        bit SWCHA
        bne CursorUp
        inc BlVPos
        inc BlVPos
CursorUp

        ldy #0 
        lda #%01000000            
        bit SWCHA
        bne CursorLeft
        ldy #%00010000 
CursorLeft
        lda #%10000000            
        bit SWCHA
        bne CursorRight
        ldy #%11110000 
CursorRight
        sty HMBL

        sta WSYNC
        sta HMOVE   
          
; 30 scanlines of overscan...        
        ldx #29                                         ; 2
        lda #0
        sta COLUBK
Overscan
        sta WSYNC                                       ; 2
        dex                                             ; 3
        bne Overscan                                    ; 2/3
        jmp StartOfFrame                                ; 3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; Sub-Routines ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
;;;;;;;;;;; Calculate Horizontal Sprite Position ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Min 38 cycles
; Max 146 cycles 
; 
; X - The Object to place
; A - X Coordinate
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CalcXPos:
        sta WSYNC                                       ; 3
        sta HMCLR                                       ; 3
        sec                                             ; 2
.Divide15 
        sbc #15                                         ; 2
        bcs .Divide15                                   ; 2/3
        eor #$07                                        ; 2
        asl                                             ; 2
        asl                                             ; 2
        asl                                             ; 2
        asl                                             ; 2
        sta RESP0,x                                     ; 3     Set Coarse Position
        sta HMP0,x                                      ; 3
        
        rts                                             ; 6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; End Calculate Horizontal Sprite Position ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; End Sub-Routines ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; Rom Data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

P0Grfx     .byte  #%00011000
           .byte  #%00000000
           .byte  #%00100100
           .byte  #%00000000
           .byte  #%01000010
           .byte  #%00000000
           .byte  #%10000001
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%10000001
           .byte  #%00000000
           .byte  #%01000010
           .byte  #%00000000
           .byte  #%00100100
           .byte  #%00000000
           .byte  #%00011000
           .byte  #0

P0Height   .byte  #16
;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END