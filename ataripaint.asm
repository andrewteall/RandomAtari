        processor 6502
        include "includes/vcs.h"
        include "macro.h"
;Start Program
        SEG.U vars
        ORG $80

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

        ldx #0
        lda #40
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        lda #132
        sta COLUP0

        lda #9
        sta COLUPF

        ; lda P0Grfx
        ; sta GRP0

        lda #%00000001
        sta CTRLPF

       

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
        inx
        sta WSYNC
        cpx #20
        bne ViewableScreenStart

Button1
        ldy #%00111111
        sty PF1
        inx
        sta WSYNC
        cpx #60
        bne Button1

MiddleBuffer1
        ldy #%0
        sty PF1
        inx
        sta WSYNC
        cpx #80
        bne MiddleBuffer1

Button2
        ldy #%00111111
        sty PF1
        inx
        sta WSYNC
        cpx #120
        bne Button2

MiddleBuffer2
        ldy #%0
        sty PF1
        inx
        sta WSYNC
        cpx #140
        bne MiddleBuffer2

Button3
        ldy #%00111111
        sty PF1
        inx
        sta WSYNC
        cpx #180
        bne Button3

EndofScreenBuffer
        ldy #%0
        sty PF1
        inx
        cpx #192
        sta WSYNC
        bne EndofScreenBuffer
        

        lda #0
        sta PF0
        sta PF1
        sta PF2

; end of screen - enter blanking
        lda #%00000010
        sta VBLANK
          
; 30 scanlines of overscan...        
        ldx #30                                         ; 2
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

Space      .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000

Cursor     .byte  #%10001000
           .byte  #%11001100
           .byte  #%11101110
           .byte  #%11001100
           .byte  #%10001000

P0Grfx     .byte  #%11111111
           .byte  #%11111111
           .byte  #%11111111
           .byte  #%11111111
           .byte  #%11111111
           .byte  #%11111111
           .byte  #%11111111
           .byte  #%11111111
           .byte  #%11111111
           .byte  #0
;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END