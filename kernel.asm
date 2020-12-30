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

        lda #0          ; Make Controllers Input
        sta SWACNT
       
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

;;;;;;;;;;;; Calculate Horizontal Sprite Position ;;;;;;;;;;;;;;;;;;;;;
        lda #0                                          ; 2
        sta CoarseCounter                               ; 3 Reset Course Positioning to 0
        lda P0HPos                                      ; 2    
Divide15 
        inc CoarseCounter                               ; 2
        sec                                             ; 2
        sbc #15                                         ; 2
        bcs Divide15                                    ; 2/3
        adc #15                                         ; 2
        dec CoarseCounter                               ; 5
        eor #$07                                        ; 2
        asl                                             ; 2
        asl                                             ; 2
        asl                                             ; 2
        asl                                             ; 2
        sta FineCounter                                 ; 3
        sta HMP0                                        ; 3
;;;;;;;;;;;; End Calculate Horizontal Sprite Position ;;;;;;;;;;;;;;;;;

MiddleLines
        cpx P0VPos                                      ; 3
        bne SkipDraw                                    ; 2/3 Draw Sprite or Not

;;;;;;;;;;;;;;;;; Horizontal Sprite Position ;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy CoarseCounter                               ; 2 Horizontal Delay
HorizontalDelay
        dey                                             ; 2 Horizontal Delay
        bne HorizontalDelay                             ; 2/3 Horizontal Delay
        
        sta HMP0
        sta RESP0                                       ; 3         
        sta WSYNC 
        sta HMOVE 
;;;;;;;;;;;;;;;;; End Horizontal Sprite Position ;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;; Drawing Sprite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy P0Height                                    ; 3
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
        cpx #110                                        ; 2
        bne CHBGColor                                   ; 2/3
        ldy #$9E                                        ; 2
        sty COLUBK                                      ; 3
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

;;;;;;;;;;;;;;;;; Game Logic  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MoveP0
        ldy P0VPos
        lda SWCHA                     
        eor #%11111111
        and #%00010000                         
        cmp #%00010000    
        bne SkipUp
        iny 
SkipUp
        lda SWCHA  
        eor #%11111111
        and #%00100000                         
        cmp #%00100000   
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
        lda SWCHA  
        eor #%11111111
        and #%01000000                         
        cmp #%01000000   
        bne SkipLeft
        lda #%00000000
        sta REFP0
        dey
SkipLeft

        lda SWCHA  
        eor #%11111111
        and #%10000000                         
        cmp #%10000000   
        bne SkipRight
        lda #%00001000
        sta REFP0
        iny
SkipRight

        cpy #19
        bne ZeroHPos
        ldy #20
ZeroHPos
        cpy #$A5
        bne MaxHPos
        ldy #$A4
MaxHPos
        sty P0HPos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 

; 30 scanlines of overscan...
        ldx #0
Overscan
        sta WSYNC
        inx
        cpx #7
        bne Overscan


        jmp StartOfFrame


P0Sprite .byte  #%00000000
         .byte  #%01101100
         .byte  #%00100100
         .byte  #%11111111
         .byte  #%11111111
         .byte  #%10011001
         .byte  #%10011001
         .byte  #%11111111
         

;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END
