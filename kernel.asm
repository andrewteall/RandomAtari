        processor 6502
        include "includes/vcs.h"
        include "includes/macro.h"
;Start Program
        SEG.U vars
        ORG $80
P0VPos ds 1
P0HPos ds 1
P0Height ds 1
CoarseCounter ds 1
FineCounter ds 1

        SEG
        ORG $F000

;PATTERN           = $80 ; storage Location (1st byte in RAM)
P0XSTARTPOS        = #50
P0YSTARTPOS        = #100    
Reset
        ldx #0
        txa
Clear
        dex
        txs
        pha
        bne Clear

        ldx #$AE
        stx COLUBK         ; set the background color
        ldx #$F4
        stx COLUPF
        ldx #%00000001
        stx CTRLPF
        ldx #133
        stx COLUP0
        
        ldx #P0YSTARTPOS
        ;ldx #100
        stx P0VPos
        
        ldx #P0XSTARTPOS
        ;ldx #3
        stx P0HPos
        
        ldx #9
        stx P0Height
       
StartOfFrame
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

;-------------------------------------------------------------------------------
        ; 37 scanlines of vertical blank...
        ldx #0
VerticalBLank
        sta WSYNC
        inx
        cpx #37
        bne VerticalBLank

--------------------------------------------------------------------
; 192 scanlines of picture...
        ldx #192                                        ; 2 this counts our scanline number
        ldy #%11111111                                  ; 2
        sty PF0                                         ; 3
        sty PF1                                         ; 3        
        sty PF2                                         ; 3
        lda #$AE                                        ; 2
        sta COLUBK         ; set the background color   ; 2
Top8Lines
        dex                                             ; 2
        sta WSYNC                                       ; 2

        cpx #184                                        ; 2
        bne Top8Lines                                   ; 2/3

; Setup Middle PlayField                                ; Makes Sprite Shift at Topmost Row
        ldy #0                                          ; 2
        sty PF1                                         ; 3
        sty PF2                                         ; 3
        ldy #%00010000                                  ; 2
        sty PF0                                         ; 3
; End Setup Middle PlayField
; x = linenumber
; y = 16
; a = 0

        lda #0
        sta CoarseCounter
        lda P0HPos                                      ;2    
Divide15 
        inc CoarseCounter
        sec
        sbc #15
        bcs Divide15
        adc #15
        dec CoarseCounter

        eor #$07
        asl
        asl
        asl
        asl
        sta FineCounter
        sta HMP0

MiddleLines
        cpx P0VPos                                      ; 3
        bne SkipDraw                                    ; 2/3 Draw Sprite or Not

;;;;;;;;;;;;;;;;; Horizontal Sprite Position ;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy CoarseCounter          ;Horizontal Delay     ; 2
HorizontalDelay
        dey                        ;Horizontal Delay     ; 2
        bne HorizontalDelay        ;Horizontal Delay     ; 2/3
        ldy
        sta HMP0
        sta RESP0                                        ; 3         
        sta WSYNC 
        sta HMOVE 
;;;;;;;;;;;;;;;;; End Horizontal Sprite Position ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; Drawing Sprite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy P0Height              ;Sprite Drawing       ; 3
DrawSprite
        dey                                             ; 2
        lda P0Sprite,y                                  ; 4/5
        sta GRP0                                        ; 3
        sta WSYNC      
        bne DrawSprite                                  ; 2/3

        txa                                             ; 2
        sbc P0Height                                    ; 3
        tax                                             ; 2
;;;;;;;;;;;;;;;;; End Drawing Sprite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
SkipDraw
        ;cpx #110                                        ; 2
        ;bne CHBGColor                                   ; 2/3
        ;ldy #$9E                                        ; 2
        ;sty COLUBK                                      ; 3
CHBGColor
        dex                                             ; 2
        sta WSYNC                                       ; 3
        cpx #8                                          ; 2
        bne MiddleLines                                 ; 2/3



Bottom8Lines
        sta WSYNC                                       ; 3
        ldy #%11111111                                  ; 2
        sty PF0                                         ; 3
        sty PF1                                         ; 3
        sty PF2                                         ; 3
        dex                                             ; 2
        bne Bottom8Lines                                ; 2/3

;-------------------------------------------------------------------------------

        lda #%01000010
        sta VBLANK                     ; end of screen - enter blanking
        ldy #0
        sty PF0
        sty PF1
        sty PF2

MoveP0
        ldy P0VPos
        lda #0
        sta SWACNT
        lda SWCHA
        cmp #%11101111
        bne SkipUp
        iny 
SkipUp
        cmp #%11011111
        bne SkipDown
        dey
SkipDown
        cpy #17
        bne ZeroVPos
        ldy #18
ZeroVPos
        cpy #184
        bne MaxVPos
        ldy #183
MaxVPos
        sty P0VPos

        ldy P0HPos
        cmp #%10111111
        bne SkipLeft
        dey
SkipLeft
        cmp #%01111111
        bne SkipRight
        iny
SkipRight
;        cpy #0
;        bne ZeroHPos
;        ldy #1
;ZeroHPos
;        cpy #40
;        bne MaxHPos
;        ldy #39
MaxHPos
        sty P0HPos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 

; 30 scanlines of overscan...
        ldx #0
Overscan
        sta WSYNC
        inx
        cpx #29
        bne Overscan


        jmp StartOfFrame


P0Sprite .byte  #%00000000
         .byte  #%10011001
         .byte  #%11111111
         .byte  #%10011001
         .byte  #%11111111
         .byte  #%10011001
         .byte  #%11111111
         .byte  #%10011001
         

;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END
