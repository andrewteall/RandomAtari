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

AudSelect       ds 1            ; 
AudDir          ds 1            ; 

FrameCtr        ds 1            ; 
NoteDuration    ds 1            ; 

NotePtr         ds 2            ; 

DurGfxSelect    ds 1            ; 
DurGfxValue     ds 5            ; 


VolGfxSelect    ds 1            ; 
VolGfxValue     ds 5            ; 

FrqGfxSelect    ds 1            ; 
FrqGfxValue     ds 5            ; 

CtlGfxSelect    ds 1            ; 
CtlGfxValue     ds 5            ; 

PlayGfxValue    ds 5            ; 
PlayGfxSelect   ds 1

NumberPtr       ds 2

DebounceCtr     ds 1
PFVPos          ds 1

CurrentSelect   ds 1

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

        lda #%00000111
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
        inx                                             ; 2     5
        cpx #18                                         ; 2     7
        sta WSYNC                                       ; 3     10
        bne ViewableScreenStart                         ; 2/3   2/3
        
        inx                                             ; 2     4
        inx                                             ; 2     6
        sta WSYNC                                       ; 3     9
        sta WSYNC                                       ; 3     3
        SLEEP 3                                         ; 3     3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Note Row - 2-Line Kernel 
; Line 1 - 76 Cycles
; Line 2 - 9 Cycles
; Improvement: Could save cycles by starting at 0 vs 20 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NoteRow
        txa                                             ; 2     5
        sbc #19                                         ; 2     7
        lsr                                             ; 2     9       Divide by 2 to get index twice for double height
        lsr                                             ; 2     11      Divide by 2 to get index twice for double height
        lsr                                             ; 2     13      Divide by 2 to get index twice for double height
        tay                                             ; 2     15      Transfer A to Y so we can index off Y
        
        lda PlayButton,y                                ; 4     19      Get the Score From our Player 0 Score Array
        sta PF0                                         ; 3     22      

        lda DurGfxValue,y                               ; 4     26      Get the Score From our Player 0 Score Array
        sta PF1                                         ; 3     29      
        
        SLEEP 5                                         ; 5     34
        
        lda VolGfxValue,y                               ; 4     38      Get the Score From our Player 0 Score Array
        sta PF2                                         ; 3     41
        
        lda FrqGfxValue,y                               ; 4     45      Get the Score From our Player 0 Score Array
        sta PF2                                         ; 3     48      Store Score to PF2
        
        lda CtlGfxValue,y                               ; 4     52      Get the Score From our Player 0 Score Array
        
        sta PF1                                         ; 3     55      Store Score to PF1        
        SLEEP 7                                         ; 7     62
        
        lda #0                                          ; 2     64
        sta PF0                                         ; 3     67
        sta PF1                                         ; 3     70
        sta PF2                                         ; 3     73
        sta WSYNC                                       ; 3     76

        inx                                             ; 2     2
        inx                                             ; 2     4
        cpx #60                                         ; 2     6
        sta WSYNC                                       ; 3     9
        bne NoteRow                                     ; 2/3   2/3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Note Selection - 1-Line Kernel 
; Line 1 - 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        inx                                             ; 2     4
        inx                                             ; 2     6
        lda #123
        sta COLUPF
        sta WSYNC                                       ; 3     9
        sta WSYNC                                       ; 3     3
        SLEEP 3                                         ; 3     3
NoteSelection
        lda PlayGfxSelect                               ; 3     6
        sta PF0                                         ; 3     9
        lda DurGfxSelect                                ; 3     12
        sta PF1                                         ; 3     15         
        lda VolGfxSelect                                ; 3     18
        sta PF2                                         ; 3     21

        SLEEP 22                                        ; 5  

        lda FrqGfxSelect                                ; 3     45
        sta PF2                                         ; 3     48
        lda CtlGfxSelect                                ; 3     52
        sta PF1                                         ; 3     55
        
        SLEEP 2                                         ; 7     62
        
        lda #0                                          ; 2     64
        sta PF0                                         ; 3     67

        inx                                             ; 2     4
        cpx #68                                         ; 2     6
        sta WSYNC                                       ; 3     9
        bne NoteSelection                               ; 2/3   2/3

        
        lda #0                                          ; 2     64
        sta PF1                                         ; 3     67
        sta PF2                                         ; 3     67
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spacer - 1-Line Kernel 
; Line 1 - 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #9
        sta COLUPF
Spacer
        inx                                             ; 2     4
        cpx #80                                         ; 2     6
        sta WSYNC                                       ; 3     9
        bne Spacer                                      ; 2/3   2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Control Row - 1-Line Kernel 
; Line 1 - 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ControlRow
        txa                                             ; 2     5
        sbc #79                                         ; 2     7
        lsr                                             ; 2     9       Divide by 2 to get index twice for double height
        lsr                                             ; 2     11      Divide by 2 to get index twice for double height
        lsr                                             ; 2     13      Divide by 2 to get index twice for double height
        tay                                             ; 2     15      Transfer A to Y so we can index off Y
        
        lda PlayButton,y                                ; 4     19      Get the Score From our Player 0 Score Array
        sta PF0                                         ; 3     22      

        lda PlusBtn,y                               ; 4     26      Get the Score From our Player 0 Score Array
        sta PF1                                         ; 3     29      
        
        SLEEP 5                                         ; 5     34
        
        lda MinusBtn,y                               ; 4     38      Get the Score From our Player 0 Score Array
        sta PF2                                         ; 3     41
        
        lda FrqGfxValue,y                               ; 4     45      Get the Score From our Player 0 Score Array
        sta PF2                                         ; 3     48      Store Score to PF2
        
        SLEEP 6                                         ; 7     62
        
        lda #0                                          ; 2     64
        sta PF1                                         ; 3     70
        sta PF0                                         ; 3     67
        
        sta PF2                                         ; 3     73
        ;sta WSYNC                                       ; 3     76

        ;inx                                             ; 2     2
        inx                                             ; 2     4
        cpx #120                                         ; 2     6
        sta WSYNC                                       ; 3     9
        bne ControlRow                                     ; 2/3   2/3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 26 cycles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ; ldy DebounceCtr                                 ; 2
        ; bne SkipCheckCollision                          ; 2/3
        ; ldy INPT4                                       ; 3
        ; bmi SkipCheckCollision                          ; 2/3
        ; ldy #15                                         ; 2
        ; sty DebounceCtr                                 ; 3
        ; ldy BlHPos                                      ; 3
        ; sty AudSelect                                   ; 3
        ; ldy BlVPos                                      ; 3
        ; sty AudDir                                      ; 3

; SkipCheckCollision

EndofScreenBuffer
        
        inx                                             ; 2
        cpx #192                                        ; 2
        sta WSYNC                                       ; 3
        ;beq EndOfViewableScreen                         ; 2/3
        ;jmp ViewableScreenStart                         ; 3
        bne EndofScreenBuffer                         ; 2/3
EndOfViewableScreen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; End of Viewable Screen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; end of screen - enter blanking

        lda #%00000010
        sta VBLANK
        
        lda #26
        sta P0VPos

        lda DebounceCtr
        bne SkipCursorMove
        
        lda #%01000000            
        bit SWCHA
        bne CursorLeft
        lda #10
        sta DebounceCtr
        dec CurrentSelect
CursorLeft
        lda #%10000000            
        bit SWCHA
        bne CursorRight
        lda #10
        sta DebounceCtr
        inc CurrentSelect
CursorRight
CursorMove

SkipCursorMove


;;;;;;;;;;;;;;;;;;;;; Selection Detection ;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
        lda DebounceCtr
        beq Selection
        jmp SkipSelectionSet
Selection
        lda #0
        sta PlayGfxSelect
        sta DurGfxSelect
        sta VolGfxSelect
        sta FrqGfxSelect
        sta CtlGfxSelect

        lda CurrentSelect
        cmp #0
        bne Selection0
        lda #%11100000
        sta PlayGfxSelect
        jmp SelectionSet
Selection0
        cmp #1
        bne Selection1
        lda #%00011111
        sta DurGfxSelect

        lda #%00010000            
        bit SWCHA
        bne Dur0Down
        inc AudDur0
Dur0Down
        lda #%00100000            
        bit SWCHA
        bne Dur0Up
        dec AudDur0
Dur0Up

        jmp SelectionSet
Selection1
        cmp #2
        bne Selection2
        lda #%11111000
        sta VolGfxSelect

        lda #%00010000            
        bit SWCHA
        bne Vol0Down
        inc AudVol0
Vol0Down
        lda #%00100000            
        bit SWCHA
        bne Vol0Up
        dec AudVol0
Vol0Up

        jmp SelectionSet
Selection2
        cmp #3
        bne Selection3
        lda #%00011111
        sta FrqGfxSelect

        lda #%00010000            
        bit SWCHA
        bne Frq0Down
        inc AudFrq0
Frq0Down
        lda #%00100000            
        bit SWCHA
        bne Frq0Up
        dec AudFrq0
Frq0Up

        jmp SelectionSet
Selection3
        cmp #4
        bne Selection4
        lda #%11111000
        sta CtlGfxSelect

        lda #%00010000            
        bit SWCHA
        bne Ctl0Down
        inc AudCtl0
Ctl0Down
        lda #%00100000            
        bit SWCHA
        bne Ctl0Up
        dec AudCtl0
Ctl0Up        

        jmp SelectionSet
Selection4
        cmp #5
        bne Selection5

        jmp SelectionSet
Selection5
        cmp #6
        bne Selection6

        jmp SelectionSet
Selection6
        cmp #7
        bne Selection7

        jmp SelectionSet
Selection7
        cmp #8
        bne Selection8

        jmp SelectionSet
Selection8
        cmp #9
        bne Selection9

        jmp SelectionSet
Selection9
        jmp SelectionSet
SelectionSet
        lda #10
        sta DebounceCtr
SkipSelectionSet

;;;;;;;;;;;;;;;;;;;;; Collision Detection ;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        sta WSYNC

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
        asl
        asl
        asl
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
        asl
        asl
        asl
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
        ldx #22                                         ; 2
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

        align 256
RZero      .byte  #%01110
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

PlayButton .byte  #%00100000
           .byte  #%01100000
           .byte  #%11100000
           .byte  #%01100000
           .byte  #%00100000
           .byte  #0

PlusBtn    .byte  #%00000100
           .byte  #%00000100
           .byte  #%00011111
           .byte  #%00000100
           .byte  #%00000100

MinusBtn   .byte  #%00000000
           .byte  #%00000000
           .byte  #%11111110
           .byte  #%00000000
           .byte  #%00000000

Track       .byte  #10,#3,#1,#7,#10,#3,#2,#7,#10,#3,#3,#7,#10,#3,#4,#7,#10,#3,#5,#7,#10,#3,#6,#7,#10,#3,#7,#7,#10,#3,#8,#7,#10,#3,#9,#7,#255,#3,#2,#5
; Track       .byte  #30,#3,#5,#7,#30,#3,#6,#7,#30,#3,#7,#7,#30,#3,#6,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#6,#7,#2,#0,#5,#7,#30,#3,#6,#7,#2,#0,#5,#7,#30,#3,#6,#7,#2,#0,#5,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#3,#7,#2,#0,#5,#7,#30,#3,#3,#7,#2,#0,#5,#7,#255,#3,#2,#5
;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END