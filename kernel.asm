     processor 6502
     include "includes/vcs.h"
     include "includes/macro.h"
     SEG
     ORG $F000

PATTERN           = $80 ; storage Location (1st byte in RAM)    
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
        ldx #66
        stx COLUP0
        
        
       
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
        ldx #0                ; this counts our scanline number
        ldy #%11111111
        sty PF0
        sty PF1
        sty PF2
Top8Lines
        inx
        sta WSYNC
        cpx #8
        bne Top8Lines


MiddleLines
        inx
        ldy #0
        sty PF1
        sty PF2
        ldy #%00010000
        sty PF0
        cpx #170
        bne Sprite
        ldy #%11111111
        sty GRP0
        sta RESP0
Sprite 
        ldy #0
        sty GRP0
        sta WSYNC
        ;ldy #%00001000
        ;sty HMP0
        ;sta HMOVE
        cpx #184
        bne MiddleLines


Bottom8Lines
        inx
        sta WSYNC
        ldy #%11111111
        sty PF0
        sty PF1
        sty PF2
        cpx #192
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

        jmp StartOfFrame

;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END
