        processor 6502
        include "includes/vcs.h"
        include "includes/macro.h"
;Start Program
        SEG.U vars
        ORG $80
P0VPos ds 1
P0HPos ds 1
Label1 .byte 3
P0Height ds 1

        SEG
        ORG $F000

;PATTERN           = $80 ; storage Location (1st byte in RAM)    
Reset
        ldx #0
        txa
Clear
        dex
        txs
        pha
        bne Clear

        ldx #0
        stx COLUBK         ; set the background color
        ldx #100
        stx COLUPF
        ldx #%00000001
        stx CTRLPF
        ldx #133
        stx COLUP0
        ldx #100
        stx P0VPos
        ldx #4
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
        ldx #192                ; this counts our scanline number
        ldy #%11111111
        sty PF0
        sty PF1
        sty PF2
Top8Lines
        dex
        sta WSYNC
        cpx #184
        bne Top8Lines

        ldy #0                                          ; 2
        sty PF1                                         ; 3
        sty PF2                                         ; 3
        ldy #%00010000                                  ; 2
        sty PF0                                         ; 3
MiddleLines
        dex                                             ; 2
        cpx P0VPos
        bne SkipDraw
        ldy P0HPos                      ;Horizontal Delay
HorizontalDelay
        dey                             ;Horizontal Delay
        bne HorizontalDelay             ;Horizontal Delay
        sta RESP0
        ldy P0Height                    ;Sprite Drawing
DrawSprite
        dey
        lda P0Sprite,y
        sta GRP0
        sta WSYNC
        bne DrawSprite
        ;sty HMP0
        ;sta HMOVE
        txa
        sbc P0Height
        tax
SkipDraw
        sta WSYNC
        cpx #8
        bne MiddleLines



Bottom8Lines
        sta WSYNC
        ldy #%11111111
        sty PF0
        sty PF1
        sty PF2
        dex
        bne Bottom8Lines

;-------------------------------------------------------------------------------

        lda #%01000010
        sta VBLANK                     ; end of screen - enter blanking
        ldy #0
        sty PF0
        sty PF1
        sty PF2
; 30 scanlines of overscan...

        ldx #0
Overscan
        sta WSYNC
        inx
        cpx #30
        bne Overscan

MoveP0
        ldy P0VPos
        dey 
        cpy #16
        bne ZeroVPos
        ldy #184
ZeroVPos
        sty P0VPos

        jmp StartOfFrame

P0Sprite .byte  00000000
         .byte  10010001
         .byte  11111111
         .byte  10010001
         .byte  11111111
         .byte  10010001
         .byte  11111111
         .byte  10010001
         

;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END



