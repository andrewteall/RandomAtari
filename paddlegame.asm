        processor 6502
        include "includes/vcs.h"
        include "macro.h"
;Start Program
        SEG.U vars
        ORG $80

P0VPos          ds 1            ; $80
P0HPos          ds 1            ; $81

P1VPos          ds 1            ; $82
P1HPos          ds 1            ; $83

BlVPos          ds 1            ; $84
BlHPos          ds 1            ; $85
BLHDir          ds 1            ; $86
BLVDir          ds 1            ; $87

P0SpritePtr     ds 2            ; $88
P1SpritePtr     ds 2            ; $8a

P0Height        ds 1            ; $8c
P1Height        ds 1            ; $8d

P0GREnd         ds 1            ; $8e
P1GREnd         ds 1            ; $8f

P0Score1        ds 1            ; $90
P0Score2        ds 1            ; $91

P1Score1        ds 1            ; $92
P1Score2        ds 1            ; $93

P0Score1idx     ds 1            ; $94
P0Score2idx     ds 1            ; $95
P1Score1idx     ds 1            ; $96
P1Score2idx     ds 1            ; $97

P0ScoreTmp      ds 1
P1ScoreTmp      ds 1

P0ScoreArr      ds 5
P1ScoreArr      ds 5

P0ScorePtr      ds 2
P1ScorePtr      ds 2

P0Score1DigitPtr ds 2
P0Score2DigitPtr ds 2
P1Score1DigitPtr ds 2
P1Score2DigitPtr ds 2

CoarseCounter   ds 1      
FineCounter     ds 1        

SkipGameFlag    ds 1
BallFired       ds 1
FrameCounter    ds 1
SkipInit        ds 1
GameMode        ds 1
GameSelectFlag  ds 1     

TextBuffer1     ds 5
TextBuffer2     ds 5
TextBuffer3     ds 5
TextBuffer4     ds 5
TextBuffer5     ds 5
TextBuffer6     ds 5

TextTemp ds 1


        SEG
        ORG $F000

;PATTERN           = $80 ; storage Location (1st byte in RAM)
P0XSTARTPOS        = #15
P0YSTARTPOS        = #77
BLXSTARTPOS        = #6
BLYSTARTPOS        = #92
BlHPOS             = #80                                 ; #2 is ideal
BGCOLOR            = #155
PFCOLOR            = #$23
P0COLOR            = #133
P0PADDLEHEIGHT     = #35
P1PADDLEHEIGHT     = #35


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; Global Config ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        sta SWACNT                                      ; Make Controllers Input. A should be 0 from initialization

        ldx #P0PADDLEHEIGHT
        stx P0Height
        stx P1Height

        ldx #P0YSTARTPOS
        stx P0VPos        
        stx P1VPos
        
        ldx #BLYSTARTPOS
        stx BlVPos

        lda #BlHPOS                                     ; Setting the starting count for the ball
        sta BlHPos

        lda #15                                         ; Setting the starting count for the ball
        sta FrameCounter

        sec
        bcs CheckGameStart

StartGame

        lda SkipInit
        bne SkipCheck
        ldx #0
        lda #20                                         ; P0 Needs to start after position 3 because draw ball timing
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #4
        lda #BlHPOS
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #1
        lda #132
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        lda #%00000000
        sta NUSIZ0
        sta NUSIZ1

        ldx #P0COLOR
        stx COLUP0
        stx COLUP1

        lda #1
        sta SkipInit
        lda SkipGameFlag                                ; 3
        bne SkipCheck
        jmp StartMenu                                   ; 3
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Check to see if we're starting the game or continuing to load the start
; menu. Can possibly remove this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckGameStart
        lda SkipGameFlag                                ; 3
        bne StartGame                                   ; 2/3
        jmp StartMenu                                   ; 3
SkipCheck
        ; 37 scanlines of vertical blank...
        ldx #37                                         ; 2
VerticalBlank
        sta WSYNC                                       ; 3
        dex                                             ; 2
        bne VerticalBlank                               ; 2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 192 scanlines of picture...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldx #BGCOLOR                                    ; 2     Load Background color into X
        stx COLUBK                                      ; 3     Set background color
        ldx #PFCOLOR                                    ; 2
        stx COLUPF                                      ; 3
        ldx #0                                          ; 2 this counts our scanline number ; scanline 38 
        stx CTRLPF                                      ; 3
        
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
        ldy #0                                          ; 2     Set Y to 0 to be used to reset the Player Graphics later on
        inx                                             ; 2     Increment line counter 
        sta WSYNC                                       ; 3     Move to next line. This prevents the very top line of the play field
                                                        ;       from being drawable but lets us start fresh when drawing the players
                                                        ;       and the ball.
GameBoard

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; Determine if we draw Ball ;;;;;;;;;;;;;;;;;;;;;;;;; 
; 12 Cycles to Draw the Ball
; 11 Cycles to Not Draw the Ball
; TODO: ADD Ball Height
; X - Current line number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #%00000000                                  ; 2     Load 0 to A to prepare to disable the ball
        cpx BlVPos                                      ; 3     Determine whether or not we're going to draw the ball on this line         
        bne BallDisabled                                ; 2/3   Go to enabling the ball or not  
;;;;;;;;;;;;;;;;; Horizontal Ball Position ;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #%00000010                                  ; 2     Load #2 to A to prepare to enable the ball
BallDisabled
        sta ENABL                                       ; 3     Store A to Ball Regiter to enable or disable for this line 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; End Horizontal Ball Position ;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; Drawing PLayers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 26 Cycles to Draw PX          
; 14 Cycles to NOT Draw PX and reset the index
; 12 Cycles to NOT Draw PX   
; X - Line Counter
; Y - #0 To be used to reset the graphics registers
; A - 
; PXGREnd - Determine what line to turn off the graphics for the
;           respective players 
; Note: Drawing PX AND Disabling PX should never happen on the same
;       Scanline.
;       Also we can't clear the carry before adding so we need to 
;       keep an eye on it
;       P0 Should be positioned horizontally past coordinate #3 in
;       order to avoid conflict with drawing the ball on the first
;       line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;; Drawing P0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx P0VPos                                      ; 3     Compare P0's Top Postion with what line we're on 
        bne SkipP0Draw                                  ; 2/3   If they match then start drawing P0
;;;;;;;;;;;;;;;;; Drawing P0 Sprite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda P0SpriteF1                                  ; 4     Load the graphics bitmap
        sta GRP0                                        ; 3     Set P0's grpahics
        txa                                             ; 2     Transfer the line number to A for math
        adc P0Height                                    ; 3     Add P0's Sprite height to know what line to stop drawing
        sta P0GREnd                                     ; 3     Store that number to ram
 ;;;;;;;;;;;;;;;;; End Drawing P0 Sprite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipP0Draw
        cpx P0GREnd                                     ; 3     Compare where we stop drawing P0 to the line number
        bne SkipP0ResetHeight                           ; 2/3   If they match then stop drawing P0
        sty GRP0                                        ; 3     Set P0's graphics to 0 from Y
SkipP0ResetHeight

;;;;;;;;;;;;;;;;;;;;;;;;;; Drawing P1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx P1VPos                                      ; 3
        bne SkipP1Draw                                  ; 2/3
;;;;;;;;;;;;;;;;; Drawing P1 Sprite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda P0SpriteF1                                  ; 4
        sta GRP1                                        ; 3
        txa                                             ; 2
        adc P1Height                                    ; 3
        sta P1GREnd                                     ; 3
 ;;;;;;;;;;;;;;;;; End Drawing P1 Sprite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipP1Draw
        cpx P1GREnd                                     ; 3
        bne SkipP1ResetHeight                           ; 2/3
        sty GRP1                                        ; 3     Y is set before we enter the game board
SkipP1ResetHeight

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; End Drawing PLayers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;; Housekeeping ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 10 cycles to loop
; 9 cycles not to loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        inx                                             ; 2     Increment the line counter
        cpx #184                                        ; 2
        sta WSYNC                                       ; 3     P0-57 All-107 move to next line
        bne GameBoard                                   ; 2/3   No? Draw next scanline

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; Drawing Bottom Play area Separator ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Creating a line across the screen to separate the bottom from the 
; play area. Not logic to accompany this, just Drawing a line. Could 
; Possibly use background color
;
; X - Line Number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw Bottom Bar
BottomBar
        lda #%11111111
        sta PF0
        sta PF1
        sta PF2
        inx
        cpx #193
        sta WSYNC
        bne BottomBar

        lda #%0
        sta PF0
        sta PF1
        sta PF2

;;;;;;;;;;;;;;;;; End Drawing Bottom Play area Separator ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; end of screen - enter blanking
        lda #%00000010
        sta VBLANK
          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; Game Logic  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PlayerControl
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

        cpy #24
        bne ZeroVPos
        ldy #25
ZeroVPos

        cpy #148
        bne MaxVPos
        ldy #147
MaxVPos
        sty P0VPos

;;;;;;;;
        ldy P1VPos
        lda SWCHA
        ora #%11111110
        cmp #%11111110
        bne SkipP1Up
        dey
SkipP1Up

        lda SWCHA
        ora #%11111101
        cmp #%11111101
        bne SkipP1Down
        iny
SkipP1Down
        lda GameSelectFlag
        beq TwoPlayerMode
        ldy BlVPos
        cpy P0VPos
        bmi SkipCPUUp
        dey
SkipCPUUp

        ldy BlVPos
        cpy P0VPos
        bpl SkipCPUDown
        iny
SkipCPUDown
TwoPlayerMode
        cpy #24
        bne ZeroP1VPos
        ldy #25
ZeroP1VPos

        cpy #148
        bmi MaxP1VPos
        ldy #147
MaxP1VPos
        sty P1VPos       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CollisionDetection
        lda CXP0FB
        and #%01000000
        cmp #%01000000
        bne SkipP0Collision
        lda #%11110000
        sta BLHDir
SkipP0Collision

        lda CXP1FB
        and #%01000000
        cmp #%01000000
        bne SkipP1Collision
        lda #%00010000
        sta BLHDir
SkipP1Collision
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BallInit                               
        lda BallFired
        bne BallControl
        sta WSYNC
        sta WSYNC
        lda FrameCounter
        beq SkipDec

        dec FrameCounter
SkipDec
        lda FrameCounter
        bne BallNotFired

        lda INPT4
        bmi BallNotFired

        lda #%11110000                                  ; Right
        sta BLHDir

        lda #1
        sta BallFired
        sec
        bcs BallControl

BallNotFired
        lda INPT5
        bmi BallNotFired2

        lda #%00010000                                  ; Right
        sta BLHDir

        lda #1
        sta BallFired
        sta GameMode
        sec
        bcs BallNotFired2

BallControl
        ldy BlHPos                         

        cpy #160
        bne MaxHBPos
        lda #%00010000                                  ; Set Direction Left
        sta BLHDir

        inc P0Score1
        lda P0Score1
        cmp #10
        bne MinHBPos
        lda #0
        sta P0Score1
        inc P0Score2
MaxHBPos
        cpy #1
        bne MinHBPos
        lda #%11110000
        sta BLHDir

        inc P1Score1
        lda P1Score1
        cmp #10
        bne MinHBPos
        lda #0
        sta P1Score1
        inc P1Score2
MinHBPos

        lda BLVDir
        cmp #0
        bne BallDown
        dec BlVPos
        sec
        bcs BallUp
BallDown
        inc BlVPos
BallUp

        lda BlVPos
        cmp #183
        bcc BallChangeDown
        lda #182
        sta BlVPos
        lda #0
        
        sta BLVDir
BallChangeDown
        
        lda BlVPos
        cmp #25
        bcs BallChangeUp
        lda #25
        sta BlVPos
        lda #1
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
BallNotFired2

;; Calculate Score
Score
        lda P0Score1
        sta P0Score1idx   
        asl
        asl
        adc P0Score1idx
        sta P0Score1idx
        
        lda #<(Zero)
        sta P0Score1DigitPtr

        lda #>(Zero)
        sta P0Score1DigitPtr+1

        lda P0Score2
        sta P0Score2idx   
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
        asl
        asl
        adc P1Score1idx
        sta P1Score1idx
        
        lda #<(Zero)
        sta P1Score1DigitPtr

        lda #>(Zero)
        sta P1Score1DigitPtr+1

        lda P1Score2
        sta P1Score2idx   
        asl
        asl
        adc P1Score2idx
        sta P1Score2idx
        
        lda #<(Zero)
        sta P1Score2DigitPtr

        lda #>(Zero)
        sta P1Score2DigitPtr+1   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
        ldx #0                                          ; 2
        stx COLUBK                                      ; 3
        stx CXCLR                                       ; 3

; 30 scanlines of overscan...        
        ldx #19                                         ; 2
Overscan
        sta WSYNC                                       ; 2
        dex                                             ; 3
        bne Overscan                                    ; 2/3
        jmp StartOfFrame                                ; 3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; Start Menu ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartMenu
        ldx #1                                          ; 2
        lda #67                                         ; 2
        jsr CalcXPos                                    ; 6
        sta WSYNC                                       ; 3
        sta HMOVE                                       ; 3
        SLEEP 24                                        ; 24
        sta HMCLR                                       ; 3
        
        ldx #0
        lda #59                                         
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #33
VerticalBlankStartMenu
        sta WSYNC
        dex                                             ; 2
        bne VerticalBlankStartMenu                      ; 2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 192 scanlines of picture...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldy #$0A                                        ; 2
        sty COLUPF                                      ; 3
        ldy #$84                                        ; 2
        sty COLUBK                                      ; 3
        ldx #10                                         ; 2
        stx COLUP0                                      ; 3
        stx COLUP1                                      ; 3
        ldy #%00000000                                  ; 2
        sty CTRLPF                                      ; 3
        lda #%00000001                                  ; 2
        sta NUSIZ0                                      ; 3
        sta NUSIZ1                                      ; 3
        ldx #0                                          ; 2
        

        sta WSYNC                                       ; 3
StartMenuScreen

        inx
        cpx #9
        sta WSYNC
        bne StartMenuScreen
;;;;;;;;;;;;;;;; Draw Playfield ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; X cycles to draw/erase the playfield
; X cycles to not draw/not erase the playfield
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #0000001
        sta CTRLPF
TopOutline  
        ldy #%11111111                                  ; 2
        sty PF2                                         ; 3
        ldy #%11111111                                  ; 2
        sty PF1                                         ; 3

        inx
        cpx #17
        sta WSYNC
        bne TopOutline
        ldy #0                                          ; 2
        sty PF0                                         ; 3
        sty PF1                                         ; 3
        sty PF2                                         ; 3
;;;;;;;;;;;;;;;; End Draw Playfield ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        sty CTRLPF                                      ; 3 Using Y from above
TitleContent 
        cpx #21
        bmi SkipTitle

        txa
        sbc #20
        lsr
        lsr
        tay
        
        lda GE,y
        sta PF1
        
        lda NE,y
        sta PF2

        lda BR,y
        sta PF0

        lda IC,y
        sta PF1
        nop
        nop
        nop


SkipTitle        
        inx
        lda #0                                          ; 2
        sta PF0                                         ; 3
        sta PF1                                         ; 3
        sta PF2                                         ; 3
        cpx #40
        sta WSYNC
        bne TitleContent

        ldy #0
TitleContentLine2 
        cpx #46
        bmi SkipTitleLine2

        txa
        sbc #45
        lsr
        lsr
        tay

        
        lda PA,y
        sta PF1
        
        lda DD,y
        sta PF2

        lda BL,y
        sta PF0

        lda LE,y
        sta PF1        
        nop
        nop
        


SkipTitleLine2        
        inx
        lda #0                                          ; 2
        sta PF0                                         ; 3
        sta PF1                                         ; 3
        sta PF2                                         ; 3
        cpx #65
        sta WSYNC
        bne TitleContentLine2

        ldy #0
TitleContentLine3 
        cpx #71
        bmi SkipTitleLine3

        txa
        sbc #70
        lsr
        lsr
        tay

        
        lda GA,y
        sta PF1
        
        lda ME,y
        sta PF2
        nop
        nop
        nop

SkipTitleLine3
        inx
        lda #0                                          ; 2
        sta PF1                                         ; 3
        sta PF2                                         ; 3
        cpx #90
        sta WSYNC
        bne TitleContentLine3


TitleBuffer
        inx
        sta WSYNC
        cpx #94
        bne TitleBuffer


;;;;;;;;;;;;;;;; Draw Playfield ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; X cycles to draw/erase the playfield
; X cycles to not draw/not erase the playfield
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #00000001
        sta CTRLPF
BottomOutline  

        ldy #%11111111                                  ; 2
        sty PF2                                         ; 3
        ldy #%11111111                                  ; 2
        sty PF1                                         ; 3

        inx
        cpx #102
        sta WSYNC
        bne BottomOutline
        ldy #0                                          ; 2
        sty PF0                                         ; 3
        sty PF1                                         ; 3
        sty PF2                                         ; 3

        lda #0000000
        sta CTRLPF
;;;;;;;;;;;;;;;; End Draw Playfield ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

TitleSpace
        inx
        cpx #135
        sta WSYNC
        bne TitleSpace
        sec                                             ; 2     Not sure why this is needed
        bcs SkipDrawText                                ; 2/3   Not sure why this is needed

TextArea 
        txa                                             ; 2
        sbc #135                                        ; 2
        tay                                             ; 2 
        lda TextBuffer3,y                               ; 4
        sta GRP0                                        ; 3
        lda TextBuffer1,y                               ; 4
        sta GRP1                                        ; 3
        SLEEP 15
        lda TextBuffer2,y                               ; 4
        sta GRP0                                        ; 3

        lda #0
        sta GRP1
        sta GRP0

        clc                                             ; 2
        bcc DrawText                                    ; 2/3
SkipDrawText
        lda #0                                          ; 2
        sta GRP1                                        ; 3
        sta GRP0                                        ; 3
DrawText
        inx
        cpx #141
        sta WSYNC
        bne TextArea

TitleSpace2
        inx
        cpx #145
        sta WSYNC
        bne TitleSpace2
        sec                                              ; 2     Not sure why this is needed
        bcs SkipDrawText2                                ; 2/3   Not sure why this is needed

TextArea2 
        txa                                             ; 2
        sbc #145                                        ; 2
        tay                                             ; 2 
        lda TextBuffer4,y                               ; 4
        sta GRP0                                        ; 3
        lda TextBuffer5,y                               ; 4
        sta GRP1                                        ; 3
        SLEEP 15
        lda TextBuffer6,y                               ; 4
        sta GRP0                                        ; 3

        lda #0
        sta GRP1
        sta GRP0

        clc                                             ; 2
        bcc DrawText2                                    ; 2/3
SkipDrawText2
        lda #0                                          ; 2
        sta GRP1                                        ; 3
        sta GRP0                                        ; 3
DrawText2
        inx
        cpx #151
        sta WSYNC
        bne TextArea2


;;;;;;;;;;; Housekeeping ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EndofScreenBuffer
        inx                                             ; 2
        sta WSYNC                                       ; 3
        cpx #192                                        ; 2
        bne EndofScreenBuffer                           ; 2/3
        
        ldy #0                                          ; 2
        sty COLUBK                                      ; 3

; end of screen - enter blanking
        lda #%00000010                                  ; 2
        sta VBLANK                                      ; 3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; Start Menu Logic ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartGameCheck
        lda INPT4
        bmi DontStartGame
        sta SkipGameFlag
DontStartGame
        ldx #0

TextBuilder
        lda O,x
        and #%11110000
        sta TextTemp

        lda N,x
        and #%00001111

        ora TextTemp
        sta TextBuffer1,x

        lda E,x
        and #%11110000
        sta TextTemp

        lda Space,x
        and #%00001111

        ora TextTemp
        sta TextBuffer2,x

        lda T,x
        and #%11110000
        sta TextTemp

        lda W,x
        and #%00001111

        ora TextTemp
        sta TextBuffer5,x

        lda O,x
        and #%11110000
        sta TextTemp

        lda Space,x
        and #%00001111

        ora TextTemp
        sta TextBuffer6,x

        lda Space,x
        and #%11110000
        sta TextTemp

        lda Cursor,x
        and #%00001111

        ora TextTemp

        ; if up pressed textBuffer3
        ldy SWCHA
        cpy #%11101111
        bne skipTop
        ldy #0
        sty GameSelectFlag
skipTop
        ldy SWCHA
        cpy #%11011111
        bne skipBottom
        ldy #1
        sty GameSelectFlag
skipBottom

        ldy GameSelectFlag
        cpy #0
        beq onePlayer
        sta TextBuffer4,x
        lda #0
        sta TextBuffer3,x
        sec 
        bcs twoPlayer
onePlayer
        sta TextBuffer3,x
        lda #0
        sta TextBuffer4,x
twoPlayer
        
        
        inx
        cpx #5

        bne TextBuilder

        ldx #19
StartMenuOverscan
        sta WSYNC
        dex
        bne StartMenuOverscan
        jmp StartOfFrame



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

P          .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%10001000
           .byte  #%10001000

R          .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%11001100
           .byte  #%10101010
        
E          .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110

S          .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110

T          .byte  #%11101110
           .byte  #%01000100
           .byte  #%01000100
           .byte  #%01000100
           .byte  #%01000100

A          .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%10101010
           .byte  #%10101010

TITLE      .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101010
           .byte  #%10001010
           .byte  #%10001110

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

O          .byte  #%11101110
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%11101110

N          .byte  #%11101110
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%10101010

G          .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110

L          .byte  #%10001000
           .byte  #%10001000
           .byte  #%10001000
           .byte  #%10001000
           .byte  #%11101110

Y          .byte  #%10101010
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%01000100
           .byte  #%01000100

W          .byte  #%10101010
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%11101110
           .byte  #%11101110

GE         .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%10101000
           .byte  #%11101110

NE         .byte  #%01110111
           .byte  #%00010101
           .byte  #%01110101
           .byte  #%00010101
           .byte  #%01110101

IC         .byte  #%11101110
           .byte  #%01001000
           .byte  #%01001000
           .byte  #%01001000
           .byte  #%11101110

BR         .byte  #%01110000
           .byte  #%01010000
           .byte  #%01110000
           .byte  #%00110000
           .byte  #%01010000

PA         .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%10001010
           .byte  #%10001010

DD         .byte  #%00110011
           .byte  #%01010101
           .byte  #%01010101
           .byte  #%01010101
           .byte  #%00110011

BL         .byte  #%00010000
           .byte  #%00010000
           .byte  #%00010000
           .byte  #%00010000
           .byte  #%01110000

LE         .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000

GA         .byte  #%11101110
           .byte  #%10001010
           .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101010

ME         .byte  #%01110101
           .byte  #%00010111
           .byte  #%01110101
           .byte  #%00010101
           .byte  #%01110101

;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END