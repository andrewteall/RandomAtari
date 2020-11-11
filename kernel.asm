        processor 6502
        include "includes/vcs.h"
        include "includes/macro.h"
;Start Program
        SEG.U vars
        ORG $80
temp ds 1
Label1 .byte 3

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


MiddleLines
        dex                                             ; 2
        ldy #0                                          ; 2
        sty PF1                                         ; 3
        sty PF2                                         ; 3
        ldy #%00010000                                  ; 2
        sty PF0                                         ; 3
        cpx #8                                        ; 2
        bne Sprite                                      ; 3
        ldy 4                                           ; 2
HorizontalMove
        ;dey
        ;bne HorizontalMove
        ;ldy #%11111111
        ;sty GRP0
        ;sta RESP0
Sprite 
        ldy #0
        sty GRP0
        sta WSYNC
        ;ldy #%00001000
        ;sty HMP0
        ;sta HMOVE
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

        jmp StartOfFrame

;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END
