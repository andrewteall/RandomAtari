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
BLVDir ds 1             ; $85
P0SpritePtr ds 2        ; $86
P0Offset ds 1           ; $88
P0Offsetidx ds 1        ; $89
P0Height ds 1           ; $8a

P0Score1 ds 1           ; $8b
P0Score2 ds 1           ; $8c

P1Score1 ds 1
P1Score2 ds 1

P0Score1idx ds 1        ; $8d
P0Score2idx ds 1        ; $8e
P1Score1idx ds 1        ; $8d
P1Score2idx ds 1        ; $8e

P0ScoreTmp ds 1
P1ScoreTmp ds 1

P0ScoreArr ds 5
P1ScoreArr ds 5

P0ScorePtr ds 2
P1ScorePtr ds 2

P0Score1DigitPtr ds 2
P0Score2DigitPtr ds 2
P1Score1DigitPtr ds 2
P1Score2DigitPtr ds 2
;CoarseCounter ds 1      ; $85
;FineCounter ds 1        ; $86

P0VPosTmp ds 1


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
        ldx #$23
        stx COLUPF
        ldx #%00010000
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
        
        ldx #37
        stx P0Height

        lda #0          ; Make Controllers Input
        sta SWACNT      ; Make Controllers Input

        lda #<P0SpriteF1
        sta P0SpritePtr

        lda #>P0SpriteF1
        sta P0SpritePtr+1

        lda #<Zero
        sta P0Score1DigitPtr

        lda #>Zero
        sta P0Score1DigitPtr+1

        lda #<Zero
        sta P0Score2DigitPtr

        ; lda #>P0Score
        ; sta P0Score2DigitPtr+1
                                                                 
        lda #0
        sta P0Offset

        lda #0
        sta P0Offsetidx

        lda #0
        sta P0Score1

        lda #0
        sta P0Score2

        lda #0
        sta P0Score1idx

        lda #0
        sta P0Score2idx

        lda #0
        sta P1Score2

        lda #0
        sta P1Score1

        lda #%11110000
        sta BLHDir

        lda #%00000000
        sta BLVDir

        

;;;;;;;;;;;;;;;;; Set P0 Sprite & Ball Horizontal Position ;;;;;;;;;;;;;;;;;;;;;;;;;;

        sta WSYNC                                          
        sta RESP0                                       ; 3     
        sta RESBL                                       ; 3
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        sta RESP1                                       ; 3 
       
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
VerticalBlank
        sta WSYNC
        inx                                             ; 2
        cpx #37                                         ; 2
        bne VerticalBlank                               ; 2/3
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 192 scanlines of picture...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #155                                        ; Load Background color into X
        stx COLUBK                                      ; Set background color
        ldx #0                                          ; 2 this counts our scanline number ; scanline 38               
ViewableScreenStart

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; Drawing Score Area ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Using PF1 of the Playfield Grpahics to draw a 2 digit score for each 
; player. Scores are calcualted in overscan and stored in memory in a 5
; byte array for each player housing the bitmap score graphics.
;
; X - Still is the line number we're on
; 30 cycles for the drawing the first line. Counting cycles from above 1
; 19 cycles to draw each line 2-3
; 48 cycles to draw each line of the scores 4-13
; 24 cycles to draw each remianing line 14-16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ScoreArea 
        cpx #3                                          ; 2     Draw Between lines 3 - 13 exclusive
        bcc SkipDrawScore                               ; 2/3   Draw Between lines 3 - 13 exclusive
        cpx #13                                         ; 2     Draw Between lines 3 - 13 exclusive
        bcs SkipDrawScore                               ; 2/3   Draw Between lines 3 - 13 exclusive
        
        txa                                             ; 2     Transfer X to the Accumulator so we can subtract
        sbc #2                                          ; 2     Subtract 2 to account for starting on line 3
        lsr                                             ; 2     Divide by 2 to get index twice for double height
        tay                                             ; 2     Transfer A to Y so we can index off Y

        lda P0ScoreArr,y                                ; 4     Get the Score From our Player 0 Score Array
        sta PF1                                         ; 3     Store Score to PF1

        nop                                             ; 2     Wait 2 cycles to get past drawing player 0's score
        nop                                             ; 2     Wait 2 cycles more to get past drawing player 0's score

        lda P1ScoreArr,y                                ; 4     Get the Score From our Player 1 Score Array
        sta PF1                                         ; 3     Store Score to PF1  
        clc                                             ; 2     Clear to Carry so we always branch
        bcc DrawScore                                   ; 2/3   Skip clearing the playfield
SkipDrawScore
        lda #0                                          ; 2     We're on lines that don't have the score so clear the playfield(PF1)
        sta PF1                                         ; 3     We're on lines that don't have the score so clear the playfield(PF1)
DrawScore
        inx                                             ; 2     Increment our line counter
        cpx #16                                         ; 2     See if we're at line 16
        sta WSYNC                                       ; 3     Go to Next line
        bne ScoreArea                                   ; 2/3   If at line 16 then move on else branch back
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; End Drawing Score Area ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; Drawing Top Play area Separator ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Creating a line across the screen to separate the score area from the 
; play area. Not logic to accompany this, just Drawing a line. Could 
; Possibly use background color
;
; X - Line Number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw Top Bar
TopPlayAreaSeparator
        lda #%11111111                                  ; 2     
        sta PF0                                         ; 3
        sta PF1                                         ; 3
        sta PF2                                         ; 3
        inx                                             ; 2
        cpx #24                                         ; 2
        sta WSYNC                                       ; 3
        bne TopPlayAreaSeparator                        ; 2/3

        lda #%0                                         ; 2
        sta PF0                                         ; 3
        sta PF1                                         ; 3
        sta PF2                                         ; 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; End Drawing Top Play area Separator ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldy #0                                          ; 2
        inx                                             ; 2     Increment line counter 
        sta WSYNC                                       ; 3     Move to next line. This prevents th very top line of the play field
                                                        ;       from being drawable but lets us start fresh when drawing the players
                                                        ;       and the ball.
GameBoard

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; Determine if we draw Ball ;;;;;;;;;;;;;;;;;;;;;;;;; 
; 15 Cycles to Draw the Ball - 13 Cycles if we can use the trick below
; 11 Cycles to Not Draw the Ball
; TODO: ADD Ball Height
; X - Current line number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx BlVPos                                      ; 3     Determine whether or not we're going to draw the ball on this line
                                                        ;       and set the carry flag for the BallEnabled Branch below         
        bne DisableBall                                 ; 2/3   Go to enabling the ball or not  
;;;;;;;;;;;;;;;;; Horizontal Ball Position ;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #%00000010                                  ; 2     Load #2 to A to prepare to enable the ball 
        bcs BallEnabled                                 ; 2/3   Always skip to Enable the ball
DisableBall
        lda #%00000000                                  ; 2     Load #0 to A to prepare to disable the ball  
BallEnabled
        sta ENABL                                       ; 3     Store A to Ball Regiter to enable or disable for this line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; End Horizontal Ball Position ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;; Determine if we draw P0 Sprite ;;;;;;;;;;;;;;;;;;;;;;;;;
; 14 Cycles to Draw P0
; 5 Cycles to NOT Draw P0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        cpx P0VPosTmp                                   ; 2     
        bne SkipP0Draw                                  ; 2/3
;;;;;;;;;;;;;;;;; Drawing P0 Sprite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        lda (P0SpritePtr),y                             ; 5          
        sta GRP0                                        ; 3
        iny                                             ; 2
        inc P0VPosTmp                                   ; 2
 ;;;;;;;;;;;;;;;;; End Drawing P0 Sprite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
SkipP0Draw


        inx                                             ; 2     increment line counter
        cpy P0Height
        bne SkipResetHeight
        ldy #0
        lda P0VPos
        sta P0VPosTmp
SkipResetHeight
        cpx #184                                        ; 2
        sta WSYNC                                       ; 3     move to next line
        bne GameBoard                                   ; 2/3   No? Draw next scanline

; Draw Bottom Bar
BottomBar
        lda #%11111111
        sta PF0
        sta PF1
        sta PF2
        inx
        cpx #192
        sta WSYNC
        bne BottomBar

        lda #%0
        sta PF0
        sta PF1
        sta PF2
        
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
BallDirection
        ldy P0VPos
        lda SWCHA                     
        ora #%11101111                
        cmp #%11101111    
        bne SkipUp
        dey
        dec BlVPos
SkipUp

        lda SWCHA  
        ora #%11011111
        cmp #%11011111   
        bne SkipDown
        iny       
        inc BlVPos 
SkipDown

        cpy #24
        bne ZeroVPos
        ldy #25
ZeroVPos

        cpy #147
        bne MaxVPos
        ldy #146
MaxVPos
        sty P0VPos
        sty P0VPosTmp                                   

        ldy BlHPos
        
        lda SWCHA                     
        ora #%10111111                
        cmp #%10111111 
        ;cpy #$a0                
        bne MaxHBPos
        lda #%00010000                                  ; Set Direction Left
        sta BLHDir

        inc P1Score1
        lda P1Score1
        cmp #10
        bne MinHBPos
        lda #0
        sta P1Score1
        ;inc P1Score2
MaxHBPos
        lda SWCHA                     
        ora #%01111111                
        cmp #%01111111 
        ;cpy #$00
        bne MinHBPos
        lda #%11110000                                  ; Set Direction Right
        sta BLHDir
        
        ;inc P0Score1
        lda P0Score1
        cmp #10
        bne MinHBPos
        lda #0
        sta P0Score1
        inc P0Score2
MinHBPos


;; Calculate Score
Score
        lda P0Score1
        sta P0Score1idx   
        lda P0Score1idx
        asl
        asl
        adc P0Score1idx
        sta P0Score1idx
        
        lda #<(Zero)
        sta P0Score1DigitPtr

        lda #>(Zero)
        sta P0Score1DigitPtr+1

        lda P0Score2
        ;lda #1
        sta P0Score2idx   
        lda P0Score2idx
        asl
        asl
        adc P0Score2idx
        sta P0Score2idx
        
        lda #<(Zero)
        sta P0Score2DigitPtr

        lda #>(Zero)
        sta P0Score2DigitPtr+1
;;;;;;
        lda P1Score1
        sta P1Score1idx   
        lda P1Score1idx
        asl
        asl
        adc P1Score1idx
        sta P1Score1idx
        
        lda #<(Zero)
        sta P1Score1DigitPtr

        lda #>(Zero)
        sta P1Score1DigitPtr+1

        lda P1Score2
        ;lda #1
        sta P1Score2idx   
        lda P1Score2idx
        asl
        asl
        adc P1Score2idx
        sta P1Score2idx
        
        lda #<(Zero)
        sta P1Score2DigitPtr

        lda #>(Zero)
        sta P1Score2DigitPtr+1   




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #0
CalcScore
        ;P0
        txa
        adc P0Score1idx                                 ; 3
        tay                                             ; 2
        lda (P0Score1DigitPtr),y                        ; 5
        and #%00001111                                  ; 2    
        sta P0ScoreTmp                                  ; 3     

        txa   
        adc P0Score2idx                                 ; 3
        tay                                             ; 2
        lda (P0Score2DigitPtr),y                        ; 5
        and #%11110000                                  ; 2     

        ora P0ScoreTmp                                  ; 3     
        sta P0ScoreArr,x                                ; 3

        ;P1
        txa
        adc P1Score1idx                                 ; 3
        tay                                             ; 2
        lda (P1Score1DigitPtr),y                        ; 5
        and #%00001111                                  ; 2    
        sta P1ScoreTmp                                  ; 3     

        txa   
        adc P1Score2idx                                 ; 3
        tay                                             ; 2
        lda (P1Score2DigitPtr),y                        ; 5
        and #%11110000                                  ; 2     

        ora P1ScoreTmp                                  ; 3     
        sta P1ScoreArr,x                                ; 3

        inx
        cpx #5
        bcc CalcScore                                   ; 2/3   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #0
        stx COLUBK
; 30 scanlines of overscan...
        ldx #0

        lda BLVDir
        cmp #0
        bne BallDown
        ;dec BlVPos
        sec
        bcs BallUp
BallDown
        ;inc BlVPos
BallUp

        lda BlVPos
        cmp #183
        bcc BallChangeDown
        lda #182
        sta BlVPos
        ;lda #0
        
        sta BLVDir
BallChangeDown
        
        lda BlVPos
        cmp #24
        bcs BallChangeUp
        lda #25
        sta BlVPos
        ;lda #1
        sta BLVDir
BallChangeUp
        

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
        lda #%00000000                                  ; Set Direction Left
        sta BLHDir
Overscan
        sta WSYNC
        inx
        cpx #21
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

P0SpriteF1 .byte  #%00011000
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

Zero       .byte  #%11101110
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%11101110

One        .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010

Two        .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110

Three      .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110

Four       .byte  #%10101010
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%00100010

Five       .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110

Six        .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110

Seven      .byte  #%11101110
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010

Eight      .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110

Nine       .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110

;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END
