        processor 6502
        include "includes/vcs.h"
        include "includes/macro.h"
;Start Program
        SEG.U vars
        ORG $80
P0VPos ds 1             ; $80
P0HPos ds 1             ; $81
BlVPos ds 1             ; $82
BlHPos ds 1             ; $83
BLHDir ds 1             ; $84
CoarseCounter ds 1      ; $85
FineCounter ds 1        ; $86
P0SpritePtr ds 2        ; $87
P0Offset ds 1           ; $89
P0Offsetidx ds 1        ; $8a
P0Height ds 1           ; $8b

        SEG
        ORG $F000

;PATTERN           = $80 ; storage Location (1st byte in RAM)
P0XSTARTPOS        = #15
P0YSTARTPOS        = #100
BLXSTARTPOS        = #6
BLYSTARTPOS        = #20
BGCOLOR            = #0     
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
        ldx #$F4
        stx COLUPF
        ldx #%00010001
        stx CTRLPF
        ldx #133
        stx COLUP0

        ldx #133
        ;stx COLUBL

        ldx #P0YSTARTPOS
        stx P0VPos
        
        ldx #P0XSTARTPOS
        stx P0HPos

        ldx #BLYSTARTPOS
        stx BlVPos
        
        ldx #BLXSTARTPOS
        stx BlHPos
        
        ldx #38
        stx P0Height

        lda #0          ; Make Controllers Input
        sta SWACNT      ; Make Controllers Input

        lda #<P0SpriteF1
        sta P0SpritePtr

        lda #>P0SpriteF1
        sta P0SpritePtr+1
        
        sta RESBL                                       ; 3                                                            

        lda #0
        sta P0Offset

        lda #0
        sta P0Offsetidx

        lda #%00010000
        sta BLHDir

;;;;;;;;;;;;;;;;; Set P0 Sprite & Ball Horizontal Position ;;;;;;;;;;;;;;;;;;;;;;;;;;

        sta WSYNC                                          
        sta RESP0                                       ; 3     
        sta RESBL                                       ; 3
       
;;;;;;;;;;;;;;;;; End Set P0 Sprite & Ball Horizontal Position ;;;;;;;;;;;;;;;;;;;;;;

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
        inx                                             ; 2
        cpx #37                                         ; 2
        bne VerticalBLank                               ; 2/3
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 192 scanlines of picture...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #0                                          ; 2 this counts our scanline number ; scanline 38               
ViewableScreenStart
;;;;;;;;;;;;;;;;; Determine if we draw P0 Sprite ;;;;;;;;;;;;;;;;;;;;;;;;;
        lda P0VPos                                      ; 3   Load the Vertical Y Coordinate into the Accumulator
        clc                                             ; 2   We do nothing to set the carry so no need to clear
        adc P0Offset                                    ; 3   Add the P0 Offset to the Vertical Y Coordinate
        sta P0Offsetidx                                 ; 3   Save the new value to the P0 Offset Index
        cpx P0Offsetidx                                 ; 3   Compare P0Offset + P0VPos to X              
        bne SkipP0Draw                                  ; 2/3 Draw Sprite or Not                                        
 
;;;;;;;;;;;;;;;;; Drawing P0 Sprite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Draw 
        ldy P0Offset                                    ; 3                   
        lda (P0SpritePtr),y                             ; 5             
        sta GRP0                                        ; 3             
        inc P0Offset                                    ; 5             
        
        lda P0Height                                    ; 3             
        cmp P0Offset                                    ; 3             
        bne SkipResetOffset                             ; 2/3           
        lda #0                                          ; 2   Reset the offset to zero when we're done drawing the Sprite
        sta P0Offset                                    ; 3             
SkipResetOffset        
;;;;;;;;;;;;;;;;; End Drawing P0 Sprite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
SkipP0Draw

;;;;;;;;;;;;;;;;; Determine if we draw Ball ;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx BlVPos                                      ; 3             
        bne SkipBLDraw                                  ; 2/3 Draw Ball or Not  
;;;;;;;;;;;;;;;;; Horizontal Ball Position ;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #%00000010                                  ; 2 turn on the ball 
        sta ENABL                                       ; 3 turn on the ball
        sec
        bcs BallEnabled
SkipBLDraw
        lda #%00000000                                  ; 2 disable ball        
        sta ENABL                                       ; 3 disable ball        
BallEnabled

;;;;;;;;;;;;;;;; End Horizontal Sprite Position ;;;;;;;;;;;;;;;;;;;;;;     
        inx                                             ; 2 increment line counter
        cpx #192
        sta WSYNC                                       ; 3 move to next line
        bne ViewableScreenStart                         ; 2/3 No? Draw next scanline
        
;-------------------------------------------------------------------------------
;-------- Blanking -------------------------------------------------------------
;-------------------------------------------------------------------------------

        lda #%01000010
        sta VBLANK                                      ; end of screen - enter blanking
        ldy #0                                          ; Clear the Playfield
        sty PF0                                         ; Clear the Playfield
        sty PF1                                         ; Clear the Playfield
        sty PF2                                         ; Clear the Playfield

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; Game Logic  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy P0VPos
        lda SWCHA                     
        ora #%11101111                
        cmp #%11101111    
        bne SkipUp
        dey
SkipUp

        lda SWCHA  
        ora #%11011111
        cmp #%11011111   
        bne SkipDown
        iny        
SkipDown

        cpy #0
        bne ZeroVPos
        ldy #1
ZeroVPos

        cpy #155
        bne MaxVPos
        ldy #154
MaxVPos
        sty P0VPos

        ldy BlHPos
        cpy #$a0                
        bne MaxHBPos
        lda #%00010000                                  ; Set Direction Left
        sta BLHDir
MaxHBPos

        cpy #$05
        bne MinHBPos
        lda #%11110000                                  ; Set Direction Right
        sta BLHDir
MinHBPos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 30 scanlines of overscan...
        ldx #0
        stx COLUBK

        inc BlVPos
        lda BLHDir                                      ; 2 Load ball direction and speed
        sta HMBL                                        ; 3 set ball direction and speed
        and #%10000000                                  ; 2
        cmp #%10000000                                  ; 2 
        bne SkipBLLeft                                  ; 2/3
        inc BlHPos                                      ; 5
        sec 
        bcs SkipBLRight
SkipBLLeft
        dec BlHPos                                      ; 5
SkipBLRight
        sta WSYNC
        sta HMOVE                                       ; 3
Overscan
        sta WSYNC
        inx
        cpx #28
        bne Overscan
        jmp StartOfFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
;;;;;;;;;;;; Calculate Horizontal Sprite Position ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Min 38 cycles
;; Max 146 cycles 
;; 1 scan line 76                       (16*x) + 38 = 152
;; 2 scan lines 152
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CalcXPos: 
;         lda #0                                          ; 2
;         sta CoarseCounter                               ; 3 Reset Course Positioning to 0
;         lda BlHPos                                      ; 2    
;         sec                                             ; 2
; Divide15 
;         inc CoarseCounter                               ; 2
;         sbc #15                                         ; 2
;         bcs Divide15                                    ; 2/3
;         cmp #1
;         bpl Skip1Wsync
;         sta WSYNC
; Skip1Wsync
;         cmp #7
;         bpl Skip2Wsync
;         sta WSYNC
; Skip2Wsync
;         adc #15                                         ; 2
;         dec CoarseCounter                                 ; 5
;         eor #$07                                        ; 2
;         asl                                             ; 2
;         asl                                             ; 2
;         asl                                             ; 2
;         asl                                             ; 2
;         sta FineCounter                                   ; 3
;         sta HMBL                                        ; 3
;         rts                                             ; 6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; End Calculate Horizontal Sprite Position ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

P0SpriteF1 .byte  #%00000000
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00011000
           .byte  #%00111100
           .byte  #%00000000

;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END
