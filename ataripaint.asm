        processor 6502
        include includes/vcs.h
        include includes/macro.h
;Start Program
        SEG.U vars
        ORG $80
AudDur0                 ds 1            ; 
AudDur1                 ds 1            ; 
AudVol0                 ds 1            ; 
;AudVol1                 ds 1            ; 
AudFrq0                 ds 1            ; 
;AudFrq1                 ds 1            ; 
AudCtl0                 ds 1            ; 
;AudCtl1                 ds 1            ; 
AudChannel              ds 1
AudTmp                  ds 1

;AudSelect               ds 1            ; 
;AudDir                  ds 1            ; 

FrameCtr                ds 1            ; 
NoteDuration            ds 1            ; 

NotePtr                 ds 2            ; 16

DurGfxSelect            ds 1            ; 
DurGfxValue             ds 5            ; 

VolGfxSelect            ds 1            ; 
VolGfxValue             ds 5            ; 

FrqGfxSelect            ds 1            ; 
FrqGfxValue             ds 5            ; 

CtlGfxSelect            ds 1            ; 
CtlGfxValue             ds 5            ; 40

PlayGfxValue            ds 5            ; 
PlayGfxSelect           ds 1

PlayAllGfxValue         ds 5            ; 
PlayAllGfxSelect        ds 1

ChannelGfxValue         ds 5            ; 
ChannelGfxSelect        ds 1            ; 58

AddGfxSelect            ds 1
RemoveGfxSelect         ds 1

PlayButtonMask          ds 5
PlayAllButtonMask       ds 5

NumberPtr               ds 2

DebounceCtr             ds 1

CurrentSelect           ds 1

PlayNoteFlag            ds 1

TrackBuilder            ds #TRACKSIZE+1           ; 108

TrackBuilderPtr         ds 1

AddNoteFlag             ds 1
RemoveNoteFlag          ds 1
PlayAllFlag             ds 1
LetterBuffer            ds 1
LineTemp                ds 1
YTemp                   ds 1            ; 115
;FrameShifter            ds 1

        echo "----",($100 - *) , "bytes of RAM left"
;TODO Optimize Memory Usage

        SEG
        ORG $F000

;PATTERN           = $80 ; storage Location (1st byte in RAM)
P0HEIGHT   =  #28
TITLETEXTXSTARTPOSITION = #57
SLEEPTIMER=TITLETEXTXSTARTPOSITION/3 +51
TRACKSIZE=#32                                   ; Must be a multiple of 4 +1


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

        ldx #0
        lda #TITLETEXTXSTARTPOSITION
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #1
        lda #TITLETEXTXSTARTPOSITION+8
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        lda #132
        sta COLUP0
        ;lda #32
        sta COLUP1

        lda #%00100101
        sta CTRLPF       

        lda #%00000011
        sta NUSIZ0
        sta NUSIZ1

        ; lda #<Track                                   ; Init for Rom Music Player
        ; sta NotePtr
        ; lda #>Track
        ; sta NotePtr+1

        lda #<TrackBuilder
        sta NotePtr


        lda #<Zero
        sta NumberPtr
        lda #>Zero
        sta NumberPtr+1

        lda #<TrackBuilder
        sta TrackBuilderPtr

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
        IF TITLETEXTXSTARTPOSITION <= 47
         sta WSYNC                                      ; 3     64
        ENDIF
ViewableScreenStart
        inx                                             ; 2     59
        ldy #0
        cpx #3                                          ; 2     61
        sta WSYNC                                       ; 3     64
        bne ViewableScreenStart                         ; 2/3   2/3

; TODO: Multiplex Characters for more than 12 chars per line
; TODO: Add support for Channel 1
;               -Play All Button Plays Channel 1
;               -Add/Remove Button performs based on Channel select
; TODO: Finalize Colors and Decor
        SLEEP SLEEPTIMER
        inx
DrawText
        
        stx LineTemp                                    ; 3     6
        sty YTemp                                       ; 3     9
        
        ldx RSpace,y                                    ; 4     13
        stx LetterBuffer                                ; 3     16
        
        ldx KE,y                                        ; 4     20

        lda MU,y                                        ; 4     24
        sta GRP0                                        ; 3     27      MU -> [GRP0]
        
        lda SI,y                                        ; 4     31
        sta GRP1                                        ; 3     34      SI -> [GRP1], [GRP0] -> GRP0
        
        lda CSpace,y                                    ; 4     38
        sta GRP0                                        ; 3     41      C  -> [GRP0]. [GRP1] -> GRP1
        
        lda MA,y                                        ; 4     45
        ldy LetterBuffer                                ; 3     48
        sta GRP1                                        ; 3     51      MA -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     54      KE -> [GRP0], [GRP1] -> GRP1
        sty GRP1                                        ; 3     57      R  -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     60      ?? -> [GRP0], [GRP1] -> GRP1
        
        ldx LineTemp                                    ; 3     63
        ldy YTemp                                       ; 3     66
        iny                                             ; 2     68

        inx                                             ; 2     70
        cpx #10                                         ; 2     72
        ;sta WSYNC                                       ; 3     75
        nop
        nop
        bne DrawText                                    ; 2/3   2/3

TopBuffer
        inx                                             ; 2     59
        cpx #20                                         ; 2     61
        sta WSYNC                                       ; 3     64
        bne TopBuffer                                   ; 2/3   2/3

        lda #0                                          ; 2     This isn't needed but pushes the next NoteRow
        sta GRP0                                        ; 3     section branch over the oage boundary
        sta GRP1                                        ; 3     " "    " "    " "   
        inx                                             ; 2
        txa
        sta WSYNC                                       ; 3
        SLEEP 4                                         ; 3     4       Set to 4 because our branch below crosses the
                                                        ;               page boundary so it takes an extra cycle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Note Row - 1-Line Kernel 
; Line 1 - 74 Cycles
; Improvement: Extra 6 cycles from sleep and removing WSYNC
; Improvement: Relocate Code away from away from Page boundary
;              to skip extra cycle needed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NoteRow 
        sbc #19                                         ; 2     5       Subtract #19 since the carry is cleared above   
                                                        ;               and we want to start on line 20
        lsr                                             ; 2     7       Divide by 2 to get index twice for double height
        lsr                                             ; 2     9       Divide by 2 to get index twice for quadruple height
        lsr                                             ; 2     11      Divide by 2 to get index twice for octuple height
        tay                                             ; 2     13      Transfer A to Y so we can index off Y
        
        lda PlayButtonMask,y                            ; 4     17      Get the Score From our Play Button Mask Array
        sta PF0                                         ; 3     20      Store the value to PF0

        lda DurGfxValue,y                               ; 4     24      Get the Score From our Duration Gfx Array
        sta PF1                                         ; 3     27      Store the value to PF1
        
        lda VolGfxValue,y                               ; 4     31      Get the Score From our Volume Gfx Array
        sta PF2                                         ; 3     34      Store the value to PF2

        SLEEP 6                                         ; 6     40      Waste 6 cycles to line up the next Pf draw

        lda FrqGfxValue,y                               ; 4     44      Get the Score From our Frequency Gfx Array
        sta PF2                                         ; 3     47      Store the value to PF2
        
        lda CtlGfxValue,y                               ; 4     50      Get the Score From our Control Gfx Array        
        sta PF1                                         ; 3     53      Store the value to PF1        

        inx                                             ; 2     55      Increment our line number
        
        ldy #0                                          ; 2     57      Reset and clear the playfield
        txa                                             ; 2     59      Transfer the line number in preparation
                                                        ;               for the next line
        sty PF0                                         ; 3     62      Reset and clear the playfield
        sty PF2                                         ; 3     65      Reset and clear the playfield
        sty PF1                                         ; 3     68      Reset and clear the playfield
        
        cpx #60                                         ; 2     70      Have we reached line #60
        sta WSYNC                                       ; 3     73      Wait for New line
        bne NoteRow                                     ; 2/3+1 2/3+1   No then repeat,Currently Crossing Page Boundary 
                                                        ;               So Add one cycle


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Note Selection - 1-Line Kernel 
; Line 1 - 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        sta WSYNC                                       ; 3     9
        inx                                             ; 2     4
        inx                                             ; 2     6
        lda #123
        sta COLUPF
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
        
        lda PlayAllButtonMask,y                                ; 4     19      Get the Score From our Player 0 Score Array
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
        lda PlayAllGfxSelect                            ; 3     6
        sta PF0                                         ; 3     9
        lda AddGfxSelect                                ; 3     12
        sta PF1                                         ; 3     15         
        lda RemoveGfxSelect                             ; 3     18
        sta PF2                                         ; 3     21

        SLEEP 22                                        ; 5  

        lda ChannelGfxSelect                            ; 3     45
        sta PF2                                         ; 3     48
        
        
        SLEEP 5                                         ; 7     62
        
        lda #0                                          ; 2     64
        sta PF1
        sta PF0                                         ; 3     67



        inx                                             ; 2     4
        cpx #128                                        ; 2     6
        sta WSYNC                                       ; 3     9
        bne ControlSelection                            ; 2/3   2/3

        
        lda #0                                          ; 2     64
        sta PF1                                         ; 3     67
        sta PF2                                         ; 3     67
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spacer - 1-Line Kernel 
; Line 1 - 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #9
        sta COLUPF
;TODO: Draw Note letters from memory location
;TODO: Add Multi-Channel Playback


        ldy #0
        sty VDELP0
        sty VDELP1
        lda #11
        sta NUSIZ0 
        sta NUSIZ1
        
PostNoteControlBuffer
        inx                                             ; 2
        cpx #144                                        ; 2
        sta WSYNC                                       ; 3
        bne PostNoteControlBuffer                       ; 2/3
        
        inx
        sta WSYNC
        SLEEP 4                                         ; 4

        
TrackDisplay
        
        txa                                             ; 2     
        and #1                                          ; 2     
        bne DrawSprite1                                 ; 2/3   
        lda MU,y                                        ; 4
        sta GRP0                                        ; 3
        stx LineTemp
        ldx KE,y                                        ; 4

        sta RESP0                                       ; 3
        ; SLEEP 3
        ; SLEEP 3
        ; SLEEP 3
        nop
        lda CSpace,y                                        ; 4
        sta GRP0                                        ; 3
        ;SLEEP 3
        SLEEP 2
        stx GRP0
        sta RESP0                                       ; 3
        SLEEP 3
        SLEEP 3
        SLEEP 3
        SLEEP 3
        SLEEP 2
        ;sta RESP0  

        

        iny                                             ; 2     
        sec                                             ; 2     
        bcs DrawSprite0                                 ; 2/3   
DrawSprite1
        
        lda SI,y                                        ; 4
        sta GRP1                                        ; 3
        ;SLEEP 4
        stx LineTemp
        ldx RSpace,y                                        ; 4
        sta RESP1                                       ; 3
        nop
        lda MA,y                                        ; 4
        sta GRP1
        
        ; SLEEP 3
        ; SLEEP 3
        ; SLEEP 3
        ; SLEEP 3
        ; SLEEP 2
        sta RESP1                                       ; 3
        SLEEP 3
        SLEEP 3
        SLEEP 3
        SLEEP 3
        SLEEP 2
        ;sta RESP1                                       ; 3

        
DrawSprite0
        ldx LineTemp
        inx                                             ; 2    
        cpx #157                                        ; 2    
        sta WSYNC                                       ; 3    
        
        bne TrackDisplay                                ; 2/3   2/3

        lda #1
        sta VDELP0
        sta VDELP1
        lda #11
        sta NUSIZ0 
        sta NUSIZ1
        lda #0
        sta GRP0
        sta GRP1

EndofScreenBuffer
        inx                                             ; 2
        cpx #192                                        ; 2
        sta WSYNC                                       ; 3
        bne EndofScreenBuffer                         ; 2/3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; End of Viewable Screen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        lda #%00000010                                  ; 2     4       ; end of screen - enter blanking
        sta VBLANK                                      ; 3     7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Left Right Crusor Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda DebounceCtr                                 ; 3     10
        bne SkipCursorMove                              ; 2/3   12/13
        
        lda #%01000000                                  ; 2     14
        bit SWCHA                                       ; 4     16
        bne CursorLeft                                  ; 2/3   18/19
        lda #10                                         ; 2     20
        sta DebounceCtr                                 ; 3     23
        dec CurrentSelect                               ; 5     28
CursorLeft
        lda #%10000000                                  ; 2     30
        bit SWCHA                                       ; 4     34
        bne CursorRight                                 ; 2/3   36/37
        lda #10                                         ; 2     38
        sta DebounceCtr                                 ; 3     41
        inc CurrentSelect                               ; 5     46
CursorRight
SkipCursorMove

        lda CurrentSelect                               ; 3     49
        bpl SkipSelectionResetDown                      ; 2/3   51/52
        lda #8                                          ; 2     53
        sta CurrentSelect                               ; 3     56
SkipSelectionResetDown
        lda CurrentSelect                               ; 3     59
        cmp #9                                          ; 2     61
        bne SkipSelectionResetUp                        ; 2/3   63/64
        lda #0                                          ; 2     65
        sta CurrentSelect                               ; 3     68
SkipSelectionResetUp
        sta WSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #30
        sta TIM64T

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; Selection Detection ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp #0
        bne Selection0
        lda #%11100000
        sta PlayGfxSelect

        ldy INPT4
        bmi Selection0
        lda #0
        sta PlayNoteFlag
Selection0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp #1
        bne Selection1
        lda #%01111111
        sta DurGfxSelect
        ldy INPT4
        bmi PlayNote1
        lda #0
        sta PlayNoteFlag
PlayNote1
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp #2
        bne Selection2
        lda #%00111110
        sta VolGfxSelect
        ldy INPT4
        bmi PlayNote2
        lda #0
        sta PlayNoteFlag
PlayNote2
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp #3
        bne Selection3
        lda #%11111111
        sta FrqGfxSelect
        ldy INPT4
        bmi PlayNote3
        lda #0
        sta PlayNoteFlag
PlayNote3
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp #4
        bne Selection4
        lda #%11111000
        sta CtlGfxSelect
        ldy INPT4
        bmi PlayNote4
        lda #0
        sta PlayNoteFlag
PlayNote4
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp #5
        bne Selection5
        lda #%11100000
        sta PlayAllGfxSelect

        ldy INPT4
        bmi Selection5
        lda DebounceCtr
        beq AllowBtn5
        jmp SkipSelectionSet
AllowBtn5
        lda PlayAllFlag
        bne SetPlayAllFlagToZero 
        lda #1
        sta PlayAllFlag
        jmp SelectionSet
SetPlayAllFlagToZero
        lda #0
        sta PlayAllFlag
        jmp SelectionSet
Selection5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 6 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp #6
        bne Selection6
        lda #%00011111
        sta AddGfxSelect

        ldy INPT4
        bmi Selection6
        lda DebounceCtr
        beq AllowBtn6
        jmp SkipSelectionSet
AllowBtn6
        lda #1
        sta AddNoteFlag
        jmp SelectionSet
Selection6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp #7
        bne Selection7
        lda #%11111000
        sta RemoveGfxSelect

        ldy INPT4
        bmi Selection7
        lda DebounceCtr
        beq AllowBtn7
        jmp SkipSelectionSet
AllowBtn7
        lda #1
        sta RemoveNoteFlag
        jmp SelectionSet
Selection7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 8 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
SkipSelectionSet

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check Audio Bounds ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; Build Audio Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; Build Audio Duration Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda AudDur0
        and #$0F
        sta AudTmp
        asl
        asl
        clc
        adc AudTmp

        ldy #0
        clc
        adc NumberPtr
        sta NumberPtr
GetDurLoIdx
        lda (NumberPtr),y
        sta DurGfxValue,y
        iny
        cpy #5
        bne GetDurLoIdx

        lda #<(Zero)
        sta NumberPtr

        lda #>(Zero)
        sta NumberPtr+1

        lda AudDur0
        and #$F0
        lsr
        lsr
        lsr
        lsr
        sta AudTmp
        asl
        asl
        clc
        adc AudTmp

        ldy #0
        clc
        adc NumberPtr
        sta NumberPtr
GetDurHiIdx
        lda (NumberPtr),y
        asl
        asl
        asl
        asl
        ora DurGfxValue,y
        sta DurGfxValue,y
        iny
        cpy #5
        bne GetDurHiIdx

        lda #<(RZero)
        sta NumberPtr

        lda #>(RZero)
        sta NumberPtr+1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Build Audio Volume Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
        sta VolGfxValue,y
        iny
        cpy #5
        bne GetVolIdx

        lda #<(Zero)
        sta NumberPtr

        lda #>(Zero)
        sta NumberPtr+1  
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; Build Audio Frequency Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda AudFrq0
        and #$0F
        sta AudTmp
        asl
        asl
        clc
        adc AudTmp

        ldy #0
        clc
        adc NumberPtr
        sta NumberPtr
GetFrqLoIdx
        lda (NumberPtr),y
        sta FrqGfxValue,y
        iny
        cpy #5
        bne GetFrqLoIdx

        lda #<(Zero)
        sta NumberPtr

        lda #>(Zero)
        sta NumberPtr+1 


        lda AudFrq0
        and #$F0
        lsr
        lsr
        lsr
        lsr
        sta AudTmp
        asl
        asl
        clc
        adc AudTmp

        ldy #0
        clc
        adc NumberPtr
        sta NumberPtr
GetFrqHiIdx
        lda (NumberPtr),y
        asl
        asl
        asl
        asl
        ora FrqGfxValue,y
        sta FrqGfxValue,y
        iny
        cpy #5
        bne GetFrqHiIdx

        lda #<(RZero)
        sta NumberPtr

        lda #>(RZero)
        sta NumberPtr+1  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Build Audio Control Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Build Audio Channel Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Note Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda PlayNoteFlag
        bne SkipPlayNote
        lda AudDur0
        cmp FrameCtr
        beq TurnOffNote
        
        ldy AudChannel

        lda AudVol0
        sta AUDV0,y

        lda AudFrq0
        sta AUDF0,y

        lda AudCtl0
        sta AUDC0,y
        inc FrameCtr

        ldy #0
LoadPauseButton
        lda PauseButton,y
        sta PlayButtonMask,y
        iny
        cpy #5
        bne LoadPauseButton

        sec
        bcs SkipPlayNote
TurnOffNote
        ldy AudChannel
        lda #0
        sta AUDV0,y
        sta AUDF0,y
        sta AUDC0,y
        sta FrameCtr
        lda #1
        sta PlayNoteFlag

        ldy #0
LoadPlayButton
        lda PlayButton,y
        sta PlayButtonMask,y
        iny
        cpy #5
        bne LoadPlayButton
SkipPlayNote

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Add Note ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda AddNoteFlag
        beq SkipAddNote

        lda TrackBuilderPtr
        cmp #<TrackBuilder+#TRACKSIZE
        beq SkipAddNote

        ldy #0

        lda AudDur0
        sta (TrackBuilderPtr),y
        iny
        lda AudVol0
        sta (TrackBuilderPtr),y
        iny
        lda AudFrq0
        sta (TrackBuilderPtr),y
        iny
        lda AudCtl0
        sta (TrackBuilderPtr),y
        iny
        lda #255
        sta (TrackBuilderPtr),y
        
        lda TrackBuilderPtr
        clc
        adc #4
        sta TrackBuilderPtr

        lda #0
        sta AddNoteFlag        
SkipAddNote

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Remove Note ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda RemoveNoteFlag
        beq SkipRemoveNote

        lda TrackBuilderPtr
        cmp #<TrackBuilder
        beq SkipRemoveNote
        
        lda #0
        ldy #0        
        sta (TrackBuilderPtr),y

        ldy #$FF
        sta (TrackBuilderPtr),y
        dey
        sta (TrackBuilderPtr),y
        dey
        sta (TrackBuilderPtr),y
        dey
        lda #255
        sta (TrackBuilderPtr),y
        
        lda TrackBuilderPtr
        sec
        sbc #4
        sta TrackBuilderPtr

        lda #0
        sta RemoveNoteFlag        
SkipRemoveNote


; ; Frame Toggle
;         lda FrameShifter
;         bne ToggleFrame0
;         lda #1
;         sta FrameShifter
;         ldx #0
;         lda #72
;         jsr CalcXPos
;         sta WSYNC
;         sta HMOVE
;         SLEEP 24
;         sta HMCLR

;         ldx #1
;         lda #80
;         jsr CalcXPos
;         sta WSYNC
;         sta HMOVE
;         SLEEP 24
;         sta HMCLR

;         sec
;         bcs ToggleFrame1
; ToggleFrame0        
;         lda #0
;         sta FrameShifter
;         ldx #0
;         lda #12
;         jsr CalcXPos
;         sta WSYNC
;         sta HMOVE
;         SLEEP 24
;         sta HMCLR

;         ldx #1
;         lda #20
;         jsr CalcXPos
;         sta WSYNC
;         sta HMOVE
;         SLEEP 24
;         sta HMCLR
; ToggleFrame1
;         sec
;         bcs SkipRomMusicPlayer
; ;;;;;;;;;;;;;;;;;;;; Rom Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; ; TODO: Potentially Optimize Flow
; ; TODO: Add Second Channel
; ; TODO: Add advanced Looping control. Repeat Track, Repeat whole song
; ; TODO: Add Sub-Routine Option
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         ldy #0                                          ; 2     Initialize Y-Index to 0
;         lda (NotePtr),y                                 ; 5     Load first note duration to A
;         cmp FrameCtr                                    ; 3     See if it equals the Frame Counter
;         beq NextNote                                    ; 2/3   If so move the NotePtr to the next note

;         cmp #255                                        ; 2     See if the notes duration equals 255
;         bne SkipResetTrack                              ; 2/3   If so go back to the beginning of the track

;         lda #<Track                                     ; 4     Store the low byte of the track to 
;         sta NotePtr                                     ; 3     the Note Pointer
;         lda #>Track                                     ; 4     Store the High byte of the track to
;         sta NotePtr+1                                   ; 3     the Note Pointer + 1
; SkipResetTrack

;         iny                                             ; 2     Increment Y (Y=1) to point to the Note Volume
;         lda (NotePtr),y                                 ; 5     Load Volume to A
;         sta AUDV0                                       ; 3     and set the Note Volume
;         iny                                             ; 2     Increment Y (Y=2) to point to the Note Frequency
;         lda (NotePtr),y                                 ; 5     Load Frequency to A
;         sta AUDF0                                       ; 3     and set the Note Frequency
;         iny                                             ; 2     Increment Y (Y=3) to point to the Note Control
;         lda (NotePtr),y                                 ; 5     Load Control to A
;         sta AUDC0                                       ; 3     and set the Note Control
;         inc FrameCtr                                    ; 5     Increment the Frame Counter to duration compare later
;         sec                                             ; 2     Set the carry to prepare to always branch
;         bcs KeepPlaying                                 ; 3     Branch to the end of the media player
; NextNote
;         lda NotePtr                                     ; 3     Load the Note Pointer to A
;         clc                                             ; 2     Clear the carry 
;         adc #4                                          ; 2     Add 4 to move the Notep pointer to the next note
;         sta NotePtr                                     ; 3     Store the new note pointer

;         lda #0                                          ; 2     Load Zero to
;         sta FrameCtr                                    ; 3     Reset the Frame counter

;         sta WSYNC
; KeepPlaying

; ;;;;;;;;;;;;;;;;;; End Rom Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; ;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SkipRomMusicPlayer

        lda PlayAllFlag
        beq SkipRamMusicPlayer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; Ram Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0                                          ; 2     Initialize Y-Index to 0
        lda (NotePtr),y                                 ; 5     Load first note duration to A
        cmp FrameCtr                                    ; 3     See if it equals the Frame Counter
        beq NextRamNote                                 ; 2/3   If so move the NotePtr to the next note

        cmp #255                                        ; 2     See if the notes duration equals 255
        bne SkipResetRamTrack                           ; 2/3   If so go back to the beginning of the track

        lda #<TrackBuilder                              ; 4     Store the low byte of the track to 
        sta NotePtr                                     ; 3     the Note Pointer

SkipResetRamTrack

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

        ldy #0
LoadPauseAllButton
        lda PauseButton,y
        sta PlayAllButtonMask,y
        iny
        cpy #5
        bne LoadPauseAllButton

        sec                                             ; 2     Set the carry to prepare to always branch
        bcs KeepPlayingRam                              ; 3     Branch to the end of the media player
NextRamNote
        lda NotePtr                                     ; 3     Load the Note Pointer to A
        clc                                             ; 2     Clear the carry 
        adc #4                                          ; 2     Add 4 to move the Notep pointer to the next note
        sta NotePtr                                     ; 3     Store the new note pointer

        lda #0                                          ; 2     Load Zero to
        sta FrameCtr                                    ; 3     Reset the Frame counter

        
KeepPlayingRam
        sec
        bcs SkipResetPlayAllButton
;;;;;;;;;;;;;;;;;; End Ram Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipRamMusicPlayer
        ldy #0
LoadPlayAllButton
        lda PlayButton,y
        sta PlayAllButtonMask,y
        iny
        cpy #5
        bne LoadPlayAllButton

        lda #<TrackBuilder                              ; 4     Store the low byte of the track to 
        sta NotePtr                                     ; 3     the Note Pointer
SkipResetPlayAllButton

        lda DebounceCtr
        beq SkipDecDebounceCtr
        dec DebounceCtr
SkipDecDebounceCtr

; Reset Player positions for title
        ldx #0
        lda #TITLETEXTXSTARTPOSITION
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #1
        lda #TITLETEXTXSTARTPOSITION+8
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR



; Reset Backgruond,Audio,Collisions,Note Flags
        lda #0
        sta COLUBK
        sta CXCLR
        sta AddNoteFlag
        sta RemoveNoteFlag
        ldy #26                                         ; 2
        
WaitLoop
        lda INTIM
        bne WaitLoop
; overscan
        ldx #5                                         ; 2
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

        align 256
Zero       .byte  #%111
           .byte  #%101
           .byte  #%101
           .byte  #%101
           .byte  #%111

One        .byte  #%110
           .byte  #%010
           .byte  #%010
           .byte  #%010
           .byte  #%111

Two        .byte  #%0111
           .byte  #%0001
           .byte  #%0111
           .byte  #%0100
           .byte  #%0111

Three      .byte  #%111
           .byte  #%001
           .byte  #%111
           .byte  #%001
           .byte  #%111

Four       .byte  #%101
           .byte  #%101
           .byte  #%111
           .byte  #%001
           .byte  #%001

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


        align 256
RZero      .byte  #%11100
           .byte  #%10100
           .byte  #%10100
           .byte  #%10100
           .byte  #%11100

ROne       .byte  #%01100
           .byte  #%01000
           .byte  #%01000
           .byte  #%01000
           .byte  #%11100

RTwo       .byte  #%11100
           .byte  #%10000
           .byte  #%11100
           .byte  #%00100
           .byte  #%11100

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

PlayAllButton .byte  #%00100000
           .byte  #%01100000
           .byte  #%11100000
           .byte  #%01100000
           .byte  #%00100000
           .byte  #0

PauseButton     .byte  #%10100000
                .byte  #%10100000
                .byte  #%10100000
                .byte  #%10100000
                .byte  #%10100000

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
        
        align 256
MU         .byte  #%10101010
           .byte  #%11101010
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%10101110
           .byte  #0

SI         .byte  #%01101110
           .byte  #%10000100
           .byte  #%11100100
           .byte  #%00100100
           .byte  #%11001110
           .byte  #0

CSpace     .byte  #%01100000
           .byte  #%10000000
           .byte  #%10000000
           .byte  #%10000000
           .byte  #%01100000
           .byte  #0

MA         .byte  #%10100100
           .byte  #%11101010
           .byte  #%10101110
           .byte  #%10101010
           .byte  #%10101010
           .byte  #0

KE         .byte  #%10101110
           .byte  #%10101000
           .byte  #%11001100
           .byte  #%10101000
           .byte  #%10101110
           .byte  #0

RSpace     .byte  #%11000000
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