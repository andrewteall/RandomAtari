        processor 6502
        include "includes/vcs.h"
        include "macro.h"
;Start Program
        SEG.U vars
        ORG $80
BlVPos                  ds 1            ; $80
BlHPos                  ds 1            ; $81
P0VPos                  ds 1            ; $82

P0VPosIdx               ds 1            ; $83

AudDur0                 ds 1            ; $84
AudDur1                 ds 1            ; $85
AudVol0                 ds 1            ; $84
AudVol1                 ds 1            ; $85
AudFrq0                 ds 1            ; $86
AudFrq1                 ds 1            ; $87
AudCtl0                 ds 1            ; $88
AudCtl1                 ds 1            ; $89
AudChannel              ds 1

AudSelect               ds 1            ; 
AudDir                  ds 1            ; 

FrameCtr                ds 1            ; 
NoteDuration            ds 1            ; 

NotePtr                 ds 2            ; 

DurGfxSelect            ds 1            ; 
DurGfxValue             ds 5            ; 


VolGfxSelect            ds 1            ; 
VolGfxValue             ds 5            ; 

FrqGfxSelect            ds 1            ; 
FrqGfxValue             ds 5            ; 

CtlGfxSelect            ds 1            ; 
CtlGfxValue             ds 5            ; 

PlayGfxValue            ds 5            ; 
PlayGfxSelect           ds 1

PlayAllGfxValue         ds 5            ; 
PlayAllGfxSelect        ds 1

ChannelGfxValue         ds 5            ; 
ChannelGfxSelect        ds 1

AddGfxSelect            ds 1
RemoveGfxSelect         ds 1

NumberPtr               ds 2

DebounceCtr             ds 1
PFVPos                  ds 1

CurrentSelect           ds 1

PlayNote                ds 1

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
        lda #32
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #1
        lda #40
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

        lda #%00000000
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
        
        lda #%00000001
        sta VDELP0
        sta VDELP1


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
        ldy #0
ViewableScreenStart
;         cpx #12
;         bmi SkipDrawTopTxt
;         cpx #19
;         bpl SkipDrawTopTxt
;         lda DU,y                                        ; 4     
;         sta GRP0                                        ; 3

;         lda R,y                                        ; 4     
;         sta GRP1                                        ; 3
;         iny

; SkipDrawTopTxt
        inx                                             ; 2
        cpx #18                                         ; 2
        sta WSYNC                                       ; 3
        bne ViewableScreenStart                         ; 2/3
        
        inx                                             ; 2
        inx                                             ; 2
        sta WSYNC                                       ; 3
        sta WSYNC                                       ; 3
        SLEEP 3                                         ; 3
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
        
        lda ChannelGfxValue,y                               ; 4     45      Get the Score From our Player 0 Score Array
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
; Control Selection - 1-Line Kernel 
; Line 1 - 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        inx                                             ; 2     4
        inx                                             ; 2     6
        lda #123
        sta COLUPF
        sta WSYNC                                       ; 3     9
        sta WSYNC                                       ; 3     3
        SLEEP 3                                         ; 3     3
ControlSelection
        lda PlayAllGfxSelect                               ; 3     6
        sta PF0                                         ; 3     9
        lda AddGfxSelect                                ; 3     12
        sta PF1                                         ; 3     15         
        lda RemoveGfxSelect                                ; 3     18
        sta PF2                                         ; 3     21

        SLEEP 22                                        ; 5  

        lda ChannelGfxSelect                                ; 3     45
        sta PF2                                         ; 3     48
        
        
        SLEEP 5                                         ; 7     62
        
        lda #0                                          ; 2     64
        sta PF1
        sta PF0                                         ; 3     67



        inx                                             ; 2     4
        cpx #128                                         ; 2     6
        sta WSYNC                                       ; 3     9
        bne ControlSelection                               ; 2/3   2/3

        
        lda #0                                          ; 2     64
        sta PF1                                         ; 3     67
        sta PF2                                         ; 3     67
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spacer - 1-Line Kernel 
; Line 1 - 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #9
        sta COLUPF

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
        lda CurrentSelect
        bpl SkipSelectionResetDown
        lda #8
        sta CurrentSelect
SkipSelectionResetDown

        lda CurrentSelect
        cmp #9
        bne SkipSelectionResetUp
        lda #0
        sta CurrentSelect
SkipSelectionResetUp


;;;;;;;;;;;;;;;;;;;;; Selection Detection ;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Selection
        lda #0
        sta PlayGfxSelect
        sta DurGfxSelect
        sta VolGfxSelect
        sta FrqGfxSelect
        sta CtlGfxSelect
        sta PlayAllGfxSelect
        sta AddGfxSelect
        sta RemoveGfxSelect
        sta ChannelGfxSelect

        lda CurrentSelect
        cmp #0
        bne Selection0
        lda #%11100000
        sta PlayGfxSelect
        
        sta WSYNC

        ldy INPT4
        bmi Selection0
        lda #0
        sta PlayNote
Selection0
        cmp #1
        bne Selection1
        lda #%00011111
        sta DurGfxSelect
        
        lda DebounceCtr
        beq AllowBtn1
        jmp SkipSelectionSet
AllowBtn1
        lda #%00010000            
        bit SWCHA
        bne Dur0Down
        inc AudDur0
        jmp SelectionSet
Dur0Down
        lda #%00100000            
        bit SWCHA
        bne Dur0Up
        dec AudDur0
        jmp SelectionSet
Dur0Up
Selection1
        cmp #2
        bne Selection2
        lda #%11111000
        sta VolGfxSelect

        lda DebounceCtr
        beq AllowBtn2
        jmp SkipSelectionSet
AllowBtn2
        lda #%00010000            
        bit SWCHA
        bne Vol0Down
        inc AudVol0
        jmp SelectionSet
Vol0Down
        lda #%00100000            
        bit SWCHA
        bne Vol0Up
        dec AudVol0
        jmp SelectionSet
Vol0Up

Selection2
        cmp #3
        bne Selection3
        lda #%00011111
        sta FrqGfxSelect

        lda DebounceCtr
        beq AllowBtn3
        jmp SkipSelectionSet
AllowBtn3
        lda #%00010000            
        bit SWCHA
        bne Frq0Down
        inc AudFrq0
        jmp SelectionSet
Frq0Down
        lda #%00100000            
        bit SWCHA
        bne Frq0Up
        dec AudFrq0
        jmp SelectionSet
Frq0Up

        
Selection3
        cmp #4
        bne Selection4
        lda #%11111000
        sta CtlGfxSelect

        lda DebounceCtr
        beq AllowBtn4
        jmp SkipSelectionSet
AllowBtn4
        lda #%00010000            
        bit SWCHA
        bne Ctl0Down
        inc AudCtl0
        jmp SelectionSet
Ctl0Down
        lda #%00100000            
        bit SWCHA
        bne Ctl0Up
        dec AudCtl0
        jmp SelectionSet
Ctl0Up        
        
Selection4
        cmp #5
        bne Selection5
        lda #%11100000
        sta PlayAllGfxSelect
Selection5
        cmp #6
        bne Selection6
        lda #%00011111
        sta AddGfxSelect
Selection6
        cmp #7
        bne Selection7
        lda #%11111000
        sta RemoveGfxSelect
Selection7
        cmp #8
        bne Selection8
        lda #%00011111
        sta ChannelGfxSelect

        lda DebounceCtr
        beq AllowBtn8
        jmp SkipSelectionSet
AllowBtn8
        lda #%00010000            
        bit SWCHA
        bne Chl0Down
        lda #1
        sta AudChannel
        jmp SelectionSet
Chl0Down
        lda #%00100000            
        bit SWCHA
        bne Chl0Up
        lda #0
        sta AudChannel
        jmp SelectionSet
Chl0Up

Selection8

        jmp SkipSelectionSet
SelectionSet
        lda #10
        sta DebounceCtr

        ldx AudVol0
        bpl SkipVol0ResetDown
        ldx #15
        stx AudVol0
SkipVol0ResetDown

        ldx AudVol0
        cpx #16
        bne SkipVol0ResetUp
        ldx #0
        stx AudVol0
SkipVol0ResetUp

        ldx AudCtl0
        bpl SkipCtl0ResetDown
        ldx #15
        stx AudCtl0
SkipCtl0ResetDown

        ldx AudCtl0
        cpx #16
        bne SkipCtl0ResetUp
        ldx #0
        stx AudCtl0
SkipCtl0ResetUp

        ldx AudFrq0
        bpl SkipFrq0ResetDown
        ldx #31
        stx AudFrq0
SkipFrq0ResetDown

        ldx AudFrq0
        cpx #32
        bne SkipFrq0ResetUp
        ldx #0
        stx AudFrq0
SkipFrq0ResetUp

        ldx AudDur0
        bpl SkipDur0ResetDown
        ldx #254
        stx AudDur0
SkipDur0ResetDown

        ldx AudDur0
        cpx #255
        bne SkipDur0ResetUp
        ldx #0
        stx AudDur0
SkipDur0ResetUp

SkipSelectionSet

;;;;;;;;;;;;;;;;;;;;;;;; Number Drawing ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda AudChannel
        asl
        asl
        clc
        adc AudChannel

        ldy #0
        adc NumberPtr
        sta NumberPtr
GetChannelIdx
        lda (NumberPtr),y
        sta ChannelGfxValue,y
        iny
        cpy #5
        bne GetChannelIdx

        lda #<(Zero)
        sta NumberPtr

        lda #>(Zero)
        sta NumberPtr+1  


;;;;;;;;;;;;;; Note Player
        lda PlayNote
        bne SkipPlayNote
        lda AudDur0
        cmp FrameCtr
        beq TurnOffNote
        
        lda AudVol0
        sta AUDV0

        lda AudFrq0
        sta AUDF0

        lda AudCtl0
        sta AUDC0
        inc FrameCtr

        sec
        bcs SkipPlayNote
TurnOffNote
        lda #0
        sta AUDV0
        sta AUDF0
        sta AUDC0
        sta FrameCtr
        lda #1
        sta PlayNote
SkipPlayNote
        

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
        sta WSYNC
        dec DebounceCtr
SkipDecDebounceCtr

; Reset Backgruond,Audio,Collisions,
        lda #0
        sta COLUBK
        sta CXCLR
        ldy #26                                         ; 2
; overscan
        ldx #19                                         ; 2
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

A          .byte  #%111
           .byte  #%101
           .byte  #%111
           .byte  #%101
           .byte  #%101

B          .byte  #%110
           .byte  #%101
           .byte  #%110
           .byte  #%101
           .byte  #%110

C          .byte  #%111
           .byte  #%100
           .byte  #%100
           .byte  #%100
           .byte  #%111

D          .byte  #%110
           .byte  #%101
           .byte  #%101
           .byte  #%101
           .byte  #%110

E          .byte  #%111
           .byte  #%100
           .byte  #%111
           .byte  #%100
           .byte  #%111

F          .byte  #%111
           .byte  #%100
           .byte  #%111
           .byte  #%100
           .byte  #%100

OneZero    .byte  #%10010
           .byte  #%10101
           .byte  #%10101
           .byte  #%10101
           .byte  #%10010

OneOne        .byte  #%10010
           .byte  #%10010
           .byte  #%10010
           .byte  #%10010
           .byte  #%10010

OneTwo        .byte  #%10111
           .byte  #%10001
           .byte  #%10111
           .byte  #%10100
           .byte  #%10111

OneThree      .byte  #%10111
           .byte  #%10001
           .byte  #%10111
           .byte  #%10001
           .byte  #%10111

OneFour       .byte  #%10101
           .byte  #%10101
           .byte  #%10111
           .byte  #%10001
           .byte  #%10001

OneFive       .byte  #%10111
           .byte  #%10100
           .byte  #%10111
           .byte  #%10001
           .byte  #%10111

OneSix        .byte  #%10111
           .byte  #%10100
           .byte  #%10111
           .byte  #%10101
           .byte  #%10111

OneSeven      .byte  #%10111
           .byte  #%10001
           .byte  #%10001
           .byte  #%10001
           .byte  #%10001

OneEight      .byte  #%10111
           .byte  #%10101
           .byte  #%10111
           .byte  #%10101
           .byte  #%10111

OneNine       .byte  #%10111
           .byte  #%10101
           .byte  #%10111
           .byte  #%10001
           .byte  #%10111

OneA          .byte  #%10111
           .byte  #%10101
           .byte  #%10111
           .byte  #%10101
           .byte  #%10101

OneB          .byte  #%10110
           .byte  #%10101
           .byte  #%10110
           .byte  #%10101
           .byte  #%10110

OneC          .byte  #%10111
           .byte  #%10100
           .byte  #%10100
           .byte  #%10100
           .byte  #%10111

OneD          .byte  #%10110
           .byte  #%10101
           .byte  #%10101
           .byte  #%10101
           .byte  #%10110

OneE          .byte  #%10111
           .byte  #%10100
           .byte  #%10111
           .byte  #%10100
           .byte  #%10111

OneF          .byte  #%10111
           .byte  #%10100
           .byte  #%10111
           .byte  #%10100
           .byte  #%10100


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

RA         .byte  #%11100
           .byte  #%10100
           .byte  #%11100
           .byte  #%10100
           .byte  #%10100

RB         .byte  #%01100
           .byte  #%10100
           .byte  #%01100
           .byte  #%10100
           .byte  #%01100

RC         .byte  #%11100
           .byte  #%00100
           .byte  #%00100
           .byte  #%00100
           .byte  #%11100

RD         .byte  #%01100
           .byte  #%10100
           .byte  #%10100
           .byte  #%10100
           .byte  #%01100

RE         .byte  #%11100
           .byte  #%00100
           .byte  #%11100
           .byte  #%00100
           .byte  #%11100

RF         .byte  #%11100
           .byte  #%00100
           .byte  #%11100
           .byte  #%00100
           .byte  #%00100

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

FR         .byte  #%11101110
           .byte  #%10001010
           .byte  #%11101110
           .byte  #%10001100
           .byte  #%10001010
           .byte  #0

DU         .byte  #%11001010
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%11001110
           .byte  #0

R          .byte  #%11100000
           .byte  #%10100000
           .byte  #%11100000
           .byte  #%11000000
           .byte  #%10100000
           .byte  #0

Track       .byte  #10,#3,#1,#7,#10,#3,#2,#7,#10,#3,#3,#7,#10,#3,#4,#7,#10,#3,#5,#7,#10,#3,#6,#7,#10,#3,#7,#7,#10,#3,#8,#7,#10,#3,#9,#7,#255,#3,#2,#5
; Track       .byte  #30,#3,#5,#7,#30,#3,#6,#7,#30,#3,#7,#7,#30,#3,#6,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#6,#7,#2,#0,#5,#7,#30,#3,#6,#7,#2,#0,#5,#7,#30,#3,#6,#7,#2,#0,#5,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#3,#7,#2,#0,#5,#7,#30,#3,#3,#7,#2,#0,#5,#7,#255,#3,#2,#5
;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END