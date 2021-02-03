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

AudDur0         ds 1            ; $84
AudDur1         ds 1            ; $85
AudVol0         ds 1            ; $84
AudVol1         ds 1            ; $85
AudFrq0         ds 1            ; $86
AudFrq1         ds 1            ; $87
AudCtl0         ds 1            ; $88
AudCtl1         ds 1            ; $89

AudSelect       ds 1            ; $8a
AudDir       ds 1            ; $8a

FrameCtr        ds 1            ; $8b
NoteDuration    ds 1            ; $8c

NotePtr         ds 2            ; $8d

DurGfxTemp      ds 1            ; $8f
DurGfxValue     ds 5            ; $94

VolGfxTemp      ds 1            ; $95
VolGfxValue     ds 5            ; $9a

FrqGfxTemp      ds 1            ; $9f
FrqGfxValue     ds 5            ; $a0

CtlGfxTemp      ds 1            ; $a5
CtlGfxValue     ds 5            ; $a6

NumberPtr       ds 2

DebounceCtr     ds 1
PFVPos          ds 1

        SEG
        ORG $F000

;PATTERN           = $80 ; storage Location (1st byte in RAM)
P0HEIGHT   =  #28



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
        lda #5
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #1
        lda #83
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #4
        lda BlHPos
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        lda #132
        sta COLUP0
        sta COLUP1

        lda #9
        sta COLUPF

        lda #%00100101
        sta CTRLPF       

        lda #26
        sta P0VPos 
        sta P0VPosIdx     

        lda #%00000100
        sta NUSIZ0
        sta NUSIZ1


        lda #<Track
        sta NotePtr
        lda #>Track
        sta NotePtr+1

        lda #<(Zero)
        sta NumberPtr

        lda #>(Zero)
        sta NumberPtr+1

        lda #19
        sta PFVPos


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

        ; 37 scanlines of vertical blank...
        ldx #37                                         ; 2
VerticalBlank
        sta WSYNC                                       ; 3
        dex                                             ; 2
        bne VerticalBlank                               ; 2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 192 scanlines of picture...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #155
        stx COLUBK
        ldx #0
ViewableScreenStart

;;;;;;;;;;;;;;;;; Determine if we draw Cursor ;;;;;;;;;;;;;;;;;;;;;;; 
; 12 Cycles to Draw the Cursor
; 11 Cycles to Not Draw the Cursor
; TODO: ADD Cursor Height
; X - Current line number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         lda #0                                          ; 2     Load 0 to A to prepare to disable the Cursor
;         cpx BlVPos                                      ; 3     Determine whether or not we're going to draw the Cursor
;         bne CursorDisabled                              ; 2/3   Go to enabling the Cursor or not  
;         lda #2                                          ; 2     Load #2 to A to prepare to enable the Cursor
; CursorDisabled
;         sta ENABL                                       ; 3     14/15 cycles

;;;;;;;;;;;;; Determine if we Draw Player Sprites ;;;;;;;;;;;;;;;;;;;
; 41 Cycles to Player Sprite + 7 to disable
; 10 Cycles to Not Player Sprite
; + 3 from branch back to top
; X - Current line number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0                                          ; 2
        cpx P0VPosIdx                                   ; 3
        bne PlayerDisabled                              ; 2/3
DrawP0
        txa                                             ; 2
        clc                                             ; 2
        adc #2                                          ; 2
        sta P0VPosIdx                                   ; 3

        txa                                             ; 2
        sec                                             ; 2
        sbc P0VPos                                      ; 3
        tay                                             ; 2
        lda P0Grfx,y                                    ; 4
        cpy #P0HEIGHT                                   ; 4
        bne PlayerDisabled                              ; 2/3

        ldy #86                                         ; 2
        sty P0VPos                                      ; 3
        sty P0VPosIdx                                   ; 3
PlayerDisabled
        tay                                             ; 2

;;;;;;;;;;;;;;;;; Setup Y index to draw PF ;;;;;;;;;;;;;;;;;;;;;;;;;
; 20 cycles + WSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        txa
        sbc #19                                         ; 2
        cpx #65                                         ; 2
        bpl SetPFVPOS79                                 ; 2/3
        bmi SetPFVPOS19                                 ; 2/3
SetPFVPOS79
        sbc #60                                         ; 2
SetPFVPOS19
        sta PFVPos                                      ; 3     12
        lsr                                             ; 2     Divide by 2 to get index twice for double height
        lsr                                             ; 2     Divide by 2 to get index twice for double height
        lsr                                             ; 2     Divide by 2 to get index twice for double height
        sty GRP0
        tay                                             ; 2     Transfer A to Y so we can index off Y

        sta WSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 35 cycles to draw either button
; 22 cycles < 20; > 120
; 18 cycles >60; < 80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        cpx #60                                         ; 2
        bpl Button1                                     ; 2/3
        cpx #20                                         ; 2
        bmi Button1                                     ; 2/3

        lda DurGfxValue,y                               ; 4     Get the Score From our Player 0 Score Array
        sta PF1                                         ; 3
        ;sta DurGfxTemp                                  ; 3     Store Score to PF1
        
        lda VolGfxValue,y                               ; 4     Get the Score From our Player 0 Score Array
        sta PF2                                         ; 3
        ;sta VolGfxTemp                                  ; 3     Store Score to PF1
Button1

        cpx #80                                         ; 2
        bmi Button2                                     ; 2/3   ;42
        cpx #120                                        ; 2
        bpl Button2                                     ; 2/3

        lda FrqGfxValue,y                               ; 4     Get the Score From our Player 0 Score Array
        sta PF1                                         ; 3     Store Score to PF1
        ;sta FrqGfxTemp                                  ; 3
        
        lda CtlGfxValue,y                               ; 4     Get the Score From our Player 0 Score Array
        sta PF2                                         ; 3     Store Score to PF2
        ;sta CtlGfxTemp                                  ; 3
Button2
        SLEEP 10

        lda #%0                                         ; 2
        sta PF1                                         ; 3
        sta PF2                                         ; 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 26 cycles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldy DebounceCtr                                 ; 2
        bne SkipCheckCollision                          ; 2/3
        ldy INPT4                                       ; 3
        bmi SkipCheckCollision                          ; 2/3
        ldy #15                                         ; 2
        sty DebounceCtr                                 ; 3
        ldy BlHPos                                      ; 3
        sty AudSelect                                   ; 3
        ldy BlVPos                                      ; 3
        sty AudDir                                      ; 3

SkipCheckCollision

EndofScreenBuffer
        
        inx
        inx                                             ; 2
        cpx #192                                        ; 2
        sta WSYNC                                       ; 3
        ; beq EndOfViewableScreen                         ; 2/3
        ; jmp ViewableScreenStart
        bne ViewableScreenStart
EndOfViewableScreen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; End of Viewable Screen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; end of screen - enter blanking

        lda #%00000010
        sta VBLANK
        
        sta WSYNC

        lda #26
        sta P0VPos

        lda DebounceCtr
        bne SkipCursorMove
        lda #15
        sta DebounceCtr

        lda #%00010000            
        bit SWCHA
        bne CursorDown
        dec BlVPos
        dec BlVPos
        inc AudVol0
CursorDown
        lda #%00100000            
        bit SWCHA
        bne CursorUp
        inc BlVPos
        inc BlVPos
        inc AudDur0
CursorUp

        ldy #0 
        lda #%01000000            
        bit SWCHA
        bne CursorLeft
        ldy #%00010000 
        dec BlHPos
        inc AudFrq0
CursorLeft
        lda #%10000000            
        bit SWCHA
        bne CursorRight
        ldy #%11110000
        inc BlHPos
        inc AudCtl0
CursorRight
        sty HMBL

        sta WSYNC
        sta HMOVE
        sec
        bcs CollisionDetection

;;;;;;;;;;;;;;;;;;;;; Collision Detection ;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipCursorMove
        sta WSYNC
CollisionDetection
        lda CXP0FB
        eor CXP1FB
        and #%01000000
        cmp #%01000000
        bne SkipP0Collision

        

        
        ldy AudDir
        ldx AudSelect
         
        cpy #40                                      
        bpl SkipAud0Up                               
        cpy #20                                      
        bmi SkipAud0Up   
        
        cpx #14
        bpl SkipDur0Up                               
        cpx #2
        bmi SkipDur0Up  

        inc AudDur0                                  
SkipDur0Up

        cpx #78                                      
        bpl SkipVol0Up                               
        cpx #66                                     
        bmi SkipVol0Up 

        inc AudVol0                                  
SkipVol0Up

        cpx #92
        bpl SkipFrq0Up                               
        cpx #80
        bmi SkipFrq0Up                               
        inc AudFrq0                                  
SkipFrq0Up

        cpx #156                                      
        bpl SkipCtl0Up                               
        cpx #144                                      
        bmi SkipCtl0Up                               
        inc AudCtl0                                  
SkipCtl0Up
SkipAud0Up



        cpy #60                    
        bpl SkipAud0Down                               
        cpy #40                                      
        bmi SkipAud0Down                               
                               

        cpx #14
        bpl SkipDur0Down                               
        cpx #2
        bmi SkipDur0Down                               
        dec AudDur0                                  
SkipDur0Down



        cpx #78                                      
        bpl SkipVol0Down                               
        cpx #66                                      
        bmi SkipVol0Down                               
        dec AudVol0                                  
SkipVol0Down


        cpx #92
        bpl SkipFrq0Down                               
        cpx #80
        bmi SkipFrq0Down                               
        dec AudFrq0                                  
SkipFrq0Down


        cpx #156
        bpl SkipCtl0Down                               
        cpx #144
        bmi SkipCtl0Down                               
        dec AudCtl0                                  
SkipCtl0Down
SkipAud0Down

SkipP0Collision



        lda AudDur0
        asl
        asl
        clc
        adc AudDur0

        ldy #0
        clc
        adc NumberPtr
        sta NumberPtr
GetDurIdx
        lda (NumberPtr),y
        asl
        asl
        asl
        sta DurGfxValue,y
        iny
        cpy #5
        bne GetDurIdx

        lda #<(RZero)
        sta NumberPtr

        lda #>(RZero)
        sta NumberPtr+1  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda AudVol0
        asl
        asl
        clc
        adc AudVol0

        ldy #0
        adc NumberPtr
        sta NumberPtr
GetVolIdx
        lda (NumberPtr),y
        sta VolGfxValue,y
        iny
        cpy #5
        bne GetVolIdx

        lda #<(Zero)
        sta NumberPtr

        lda #>(Zero)
        sta NumberPtr+1  
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda AudFrq0
        asl
        asl
        clc
        adc AudFrq0

        ldy #0
        adc NumberPtr
        sta NumberPtr
GetFrqIdx
        lda (NumberPtr),y
        asl
        asl
        asl
        sta FrqGfxValue,y
        iny
        cpy #5
        bne GetFrqIdx

        lda #<(RZero)
        sta NumberPtr

        lda #>(RZero)
        sta NumberPtr+1  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda AudCtl0
        asl
        asl
        clc
        adc AudCtl0

        ldy #0
        adc NumberPtr
        sta NumberPtr
GetCtlIdx
        lda (NumberPtr),y
        sta CtlGfxValue,y
        iny
        cpy #5
        bne GetCtlIdx

        lda #<(Zero)
        sta NumberPtr

        lda #>(Zero)
        sta NumberPtr+1 



        sec
        bcs SkipMusicPlayer
;;;;;;;;;;;;;;;;;;;;;;;; Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; TODO: Potentially Optimize Flow
; TODO: Add Second Channel
; TODO: Add advanced Looping control. Repeat Track, Repeat whole song
; TODO: Add Sub-Routine Option
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0                                          ; 2     Initialize Y-Index to 0
        lda (NotePtr),y                                 ; 5     Load first note duration to A
        cmp FrameCtr                                    ; 3     See if it equals the Frame Counter
        beq NextNote                                    ; 2/3   If so move the NotePtr to the next note

        cmp #255                                        ; 2     See if the notes duration equals 255
        bne SkipResetTrack                              ; 2/3   If so go back to the beginning of the track

        lda #<Track                                     ; 4     Store the low byte of the track to 
        sta NotePtr                                     ; 3     the Note Pointer
        lda #>Track                                     ; 4     Store the High byte of the track to
        sta NotePtr+1                                   ; 3     the Note Pointer + 1
SkipResetTrack

        iny                                             ; 2     Increment Y (Y=1) to point to the Note Volume
        lda (NotePtr),y                                 ; 5     Load Volume to A
        sta AUDV0                                       ; 3     and set the Note Volume
        iny                                             ; 2     Increment Y (Y=2) to point to the Note Frequency
        lda (NotePtr),y                                 ; 5     Load Frequency to A
        sta AUDF0                                       ; 3     and set the Note Frequency
        iny                                             ; 2     Increment Y (Y=3) to point to the Note Control
        lda (NotePtr),y                                 ; 5     Load Control to A
        sta AUDC0                                       ; 3     and set the Note Control
        inc FrameCtr                                    ; 5     Increment the Frame Counter to duration compare later
        sec                                             ; 2     Set the carry to prepare to always branch
        bcs KeepPlaying                                 ; 3     Branch to the end of the media player
NextNote
        lda NotePtr                                     ; 3     Load the Note Pointer to A
        clc                                             ; 2     Clear the carry 
        adc #4                                          ; 2     Add 4 to move the Notep pointer to the next note
        sta NotePtr                                     ; 3     Store the new note pointer

        lda #0                                          ; 2     Load Zero to
        sta FrameCtr                                    ; 3     Reset the Frame counter

        sta WSYNC
KeepPlaying

;;;;;;;;;;;;;;;;;;;;;; End Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipMusicPlayer

        lda DebounceCtr
        beq SkipDecDebounceCtr
        dec DebounceCtr
SkipDecDebounceCtr

; Reset Backgruond,Audio,Collisions,
        lda #0
        sta COLUBK
        sta CXCLR
        sta AudSelect
        sta AudDir
        ldy #26                                         ; 2
        sty P0VPos                                      ; 3
        sty P0VPosIdx                                   ; 3
; overscan
        ldx #21                                         ; 2
Overscan
        dex                                             ; 3
        sta WSYNC                                       ; 2
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
           .byte  #%00111100
           .byte  #%00000000
           .byte  #%01111110
           .byte  #%00000000
           .byte  #%11111111
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%11111111
           .byte  #%00000000
           .byte  #%01111110
           .byte  #%00000000
           .byte  #%00111100
           .byte  #%00000000
           .byte  #%00011000
           .byte  #0
           .byte  #0

        align 256
Zero       .byte  #%01110
           .byte  #%10001
           .byte  #%10001
           .byte  #%10001
           .byte  #%01110

One        .byte  #%00110
           .byte  #%00010
           .byte  #%00010
           .byte  #%00010
           .byte  #%00111

Two        .byte  #%01111
           .byte  #%00001
           .byte  #%01111
           .byte  #%01000
           .byte  #%01111

Three      .byte  #%00111
           .byte  #%00001
           .byte  #%00111
           .byte  #%00001
           .byte  #%00111

Four       .byte  #%00101
           .byte  #%00101
           .byte  #%00111
           .byte  #%00001
           .byte  #%00001

Five       .byte  #%111
           .byte  #%100
           .byte  #%111
           .byte  #%001
           .byte  #%111

Six        .byte  #%111
           .byte  #%100
           .byte  #%111
           .byte  #%101
           .byte  #%111

Seven      .byte  #%111
           .byte  #%001
           .byte  #%001
           .byte  #%001
           .byte  #%001

Eight      .byte  #%111
           .byte  #%101
           .byte  #%111
           .byte  #%101
           .byte  #%111

Nine       .byte  #%111
           .byte  #%101
           .byte  #%111
           .byte  #%001
           .byte  #%111

RZero       .byte  #%01110
           .byte  #%10001
           .byte  #%10001
           .byte  #%10001
           .byte  #%01110

ROne       .byte  #%01100
           .byte  #%01000
           .byte  #%01000
           .byte  #%01000
           .byte  #%11100

RTwo       .byte  #%11110
           .byte  #%10000
           .byte  #%11110
           .byte  #%00010
           .byte  #%11110

RThree     .byte  #%11100
           .byte  #%10000
           .byte  #%11100
           .byte  #%10000
           .byte  #%11100

RFour      .byte  #%10100
           .byte  #%10100
           .byte  #%11100
           .byte  #%10000
           .byte  #%10000

RFive      .byte  #%11100
           .byte  #%00100
           .byte  #%11100
           .byte  #%10000
           .byte  #%11100

RSix       .byte  #%11100
           .byte  #%00100
           .byte  #%11100
           .byte  #%10100
           .byte  #%11100

RSeven     .byte  #%11100
           .byte  #%10000
           .byte  #%10000
           .byte  #%10000
           .byte  #%10000

REight     .byte  #%11100
           .byte  #%10100
           .byte  #%11100
           .byte  #%10100
           .byte  #%11100

RNine      .byte  #%11100
           .byte  #%10100
           .byte  #%11100
           .byte  #%10000
           .byte  #%11100

Track       .byte  #10,#3,#1,#7,#10,#3,#2,#7,#10,#3,#3,#7,#10,#3,#4,#7,#10,#3,#5,#7,#10,#3,#6,#7,#10,#3,#7,#7,#10,#3,#8,#7,#10,#3,#9,#7,#255,#3,#2,#5
; Track       .byte  #30,#3,#5,#7,#30,#3,#6,#7,#30,#3,#7,#7,#30,#3,#6,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#6,#7,#2,#0,#5,#7,#30,#3,#6,#7,#2,#0,#5,#7,#30,#3,#6,#7,#2,#0,#5,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#3,#7,#2,#0,#5,#7,#30,#3,#3,#7,#2,#0,#5,#7,#255,#3,#2,#5
;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END