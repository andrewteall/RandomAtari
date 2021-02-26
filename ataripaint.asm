        processor 6502
        include includes/vcs.h
        include includes/macro.h
;Start Program
        SEG.U vars
        ORG $80
                      
AudChannel              ds 1

AudVolCtl               ds 1            
AudFrqDur               ds 1
;AudChannelDebouceCtr    ds 1

; Flags
FlagsSelection          ds 1                    ; 0-4 Current Selection (#0-#8) - (#9-#15 Not Used)
                                                ; 5 - Play note flag - 0 plays note
                                                ; 6 - Add note flag - 1 adds note
                                                ; 7 - Remove note flag - 1 removes note
                                                ; 8 - Play track flag - 1 plays tracks

; Counters
FrameCtrTrk0            ds 1            ;
FrameCtrTrk1            ds 1            ;
DebounceCtr             ds 1                    ; Currently set to 10 probably won't be over 15 - XXXXX000

; Selection
DurGfxSelect            ds 1            ; 
VolGfxSelect            ds 1            ; 
FrqGfxSelect            ds 1            ; 
CtlGfxSelect            ds 1            ; 
PlayGfxSelect           ds 1
PlayAllGfxSelect        ds 1
ChannelGfxSelect        ds 1            
AddGfxSelect            ds 1
RemoveGfxSelect         ds 1

; Rom Pointers
PlayButtonMaskPtr       ds 2                    
PlayAllButtonMaskPtr    ds 2 
ChannelGfxPtr           ds 2
CtlGfxPtr               ds 2
VolGfxPtr               ds 2
DurGfxPtr               ds 2
FrqGfxPtr               ds 2

; Ram Pointers
Track0BuilderPtr        ds 1                    ; 
YTemp                   ds 1                    ; This will get zeroed so that the Trackpointer load
Track1BuilderPtr        ds 1                    ; 
LineTemp                ds 1                    ; will seem like it has 2 bytes

NotePtrCh0              ds 2                     

NotePtrCh1              ds 1
LetterBuffer            ds 1                    ; 00000000               

; Ram Music Tracks
Track0Builder           ds #TRACKSIZE+1
Track1Builder           ds #TRACKSIZE+1


        echo "----",(* - $80) , "bytes of RAM Used"
        echo "----",($100 - *) , "bytes of RAM left"
; TODO: Flag to not use Channel 1 - doubles play time
;       - Could also have channel 1 count from top so the tracks meet in the middle
; TODO: Multiplex Characters for more than 12 chars per line
; TODO: Finalize Colors and Decor and Name
; TODO: Draw Note letters from memory location
; TODO: Add note count left on track
; TODO: Add note spacer inbetween plays

        SEG
        ORG $F000

;PATTERN           = $80 ; storage Location (1st byte in RAM)
TITLETEXTXSTARTPOSITION = #57
SLEEPTIMER=TITLETEXTXSTARTPOSITION/3 +51
TRACKSIZE=#24                                   ; Must be a multiple of 4


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

        lda #<Track0Builder
        sta NotePtrCh0

        lda #<Track1Builder
        sta NotePtrCh1

        lda #<Track0Builder
        sta Track0BuilderPtr

        lda #<Track1Builder
        sta Track1BuilderPtr

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
        sbc #19
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

        lsr                                             ; 2     7       Divide by 2 to get index twice for double height
        lsr                                             ; 2     9       Divide by 2 to get index twice for quadruple height
        lsr                                             ; 2     11      Divide by 2 to get index twice for octuple height
        tay                                             ; 2     13      Transfer A to Y so we can index off Y
        
        lda (PlayButtonMaskPtr),y                       ; 5     17      Get the Score From our Play Button Mask Array
        sta PF0                                         ; 3     20      Store the value to PF0

        lda (DurGfxPtr),y                               ; 5     24      Get the Score From our Duration Gfx Array
        sta PF1                                         ; 3     27      Store the value to PF1
        
        lda (VolGfxPtr),y                               ; 5     31      Get the Score From our Volume Gfx Array
        asl
        sta PF2                                         ; 3     34      Store the value to PF2

        SLEEP 2                                         ; 6     40      Waste 6 cycles to line up the next Pf draw

        lda (FrqGfxPtr),y                               ; 4     44      Get the Score From our Frequency Gfx Array
        sta PF2                                         ; 3     47      Store the value to PF2
        
        lda (CtlGfxPtr),y                               ; 5     50      Get the Score From our Control Gfx Array        
        sta PF1                                         ; 3     53      Store the value to PF1        

        inx                                             ; 2     55      Increment our line number
        
        ldy #0                                          ; 2     57      Reset and clear the playfield
        txa                                             ; 2     59      Transfer the line number in preparation
                                                        ;               for the next line
        sbc #19                                         ; 2     5       Subtract #19 since the carry is cleared above
                                                        ;               and we want to start on line 20
        sty PF0                                         ; 3     62      Reset and clear the playfield
        sty PF1                                         ; 3     68      Reset and clear the playfield
        
        cpx #60                                         ; 2     70      Have we reached line #60
        sta WSYNC                                       ; 3     73      Wait for New line
        bne NoteRow                                     ; 2/3+1 2/3+1   No then repeat,Currently Crossing Page Boundary 
                                                        ;               So Add one cycle


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Note Selection - 1-Line Kernel 
; Line 1 - 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0
        sty PF2                                         ; 3     65      Reset and clear the playfield
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
        
        lda (PlayAllButtonMaskPtr),y                                ; 4     19      Get the Score From our Player 0 Score Array
        sta PF0                                         ; 3     22      

        lda PlusBtn,y                               ; 4     26      Get the Score From our Player 0 Score Array
        sta PF1                                         ; 3     29      
        
        SLEEP 5                                         ; 5     34
        
        lda MinusBtn,y                               ; 4     38      Get the Score From our Player 0 Score Array
        sta PF2                                         ; 3     41
        
        lda (ChannelGfxPtr),y                               ; 4     45      Get the Score From our Player 0 Score Array
        sta PF2                                         ; 3     48      Store Score to PF2
        
        SLEEP 4                                         ; 7     62
        
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
;;;;;;;;;;;;;;;;;;;;;;;;;; Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #30
        sta TIM64T

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
        lda FlagsSelection                                       ;       10100000 10100010
        and #%00001111                                  ;       00000000 00000010
        beq SetCurrentSelectionto8
        dec FlagsSelection                                       ; 5     28
        sec
        bcs SkipSetCurrentSelectionto8
SetCurrentSelectionto8
        lda FlagsSelection
        eor #%00001000
        sta FlagsSelection
SkipSetCurrentSelectionto8
CursorLeft

        lda #%10000000                                  ; 2     30
        bit SWCHA                                       ; 4     34
        bne CursorRight                                 ; 2/3   36/37
        lda #10                                         ; 2     38
        sta DebounceCtr                                 ; 3     41
        lda FlagsSelection                                       ;       10100000 10101000
        and #%00001000                                  ;       00000000 00001000
        bne SetCurrentSelectionto0
        inc FlagsSelection
        sec
        bcs SkipSetCurrentSelectionto0
SetCurrentSelectionto0
        lda FlagsSelection
        eor #%00001000
        sta FlagsSelection                          
SkipSetCurrentSelectionto0                
CursorRight

SkipCursorMove

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

        lda FlagsSelection
        and #%00001111
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp #0
        bne Selection0
        lda #%11100000
        sta PlayGfxSelect

        ldy INPT4
        bmi Selection0
        tay
        lda FlagsSelection               ;00000   00100
        and #%11101111          ;00000   00000 
        sta FlagsSelection               ;00000   00000
        tya 
Selection0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp #1
        bne Selection1
        lda #%01111111
        sta DurGfxSelect
        ldy INPT4
        bmi PlayNote1
        tay
        lda FlagsSelection               ;00000   00100
        and #%11101111          ;11110   11110 
        sta FlagsSelection               ;11110   11110
        tya 
PlayNote1
        lda DebounceCtr
        beq AllowBtn1
        jmp SkipSelectionSet
AllowBtn1
        lda #%00010000
        bit SWCHA
        bne Dur0Down
        lda AudFrqDur
        and #%00000111
        cmp #7
        bne IncAudDur0
        lda AudFrqDur
        and #%11111000
        sta AudFrqDur
        sec
        bcs SetAud0ToZero
IncAudDur0
        inc AudFrqDur
SetAud0ToZero
        jmp SelectionSet
Dur0Down
        lda #%00100000
        bit SWCHA
        bne Dur0Up

        lda AudFrqDur
        and #%00000111
        cmp #0
        bne DecAudDur0
        lda AudFrqDur
        ora #%00000111
        sta AudFrqDur
        sec
        bcs SetAud0To8
DecAudDur0
        dec AudFrqDur
SetAud0To8

        jmp SelectionSet
Dur0Up
Selection1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp #2
        beq SkipSelection2Jump
        jmp Selection2
SkipSelection2Jump
        lda #%00111110
        sta VolGfxSelect
        ldy INPT4
        bmi PlayNote2
        tay
        lda FlagsSelection               ;00000   00100
        and #%11101111          ;00000   00000 
        sta FlagsSelection               ;00000   00000
        tya 
PlayNote2
        lda DebounceCtr
        beq AllowBtn2
        jmp SkipSelectionSet
AllowBtn2
        lda #%00010000            
        bit SWCHA
        bne Vol0Down


        lda AudVolCtl
        and #%11110000
        lsr
        lsr
        lsr
        lsr
        cmp #15
        bne IncAudVol0
        lda AudVolCtl
        and #%00001111
        sta AudVolCtl
        sec
        bcs SetAudVol0ToZero
IncAudVol0
        lda AudVolCtl
        tay
        and #%00001111
        sta AudVolCtl
        tya
        and #%11110000
        lsr
        lsr
        lsr
        lsr
        clc
        adc #1
        asl
        asl
        asl
        asl
        ora AudVolCtl
        sta AudVolCtl
SetAudVol0ToZero


        jmp SelectionSet
Vol0Down
        lda #%00100000            
        bit SWCHA
        bne Vol0Up


        lda AudVolCtl
        and #%11110000
        lsr
        lsr
        lsr
        lsr
        cmp #0
        bne DecAudVol0
        lda AudVolCtl
        ora #%11110000
        sta AudVolCtl
        sec
        bcs SetAudVol0To15
DecAudVol0
        lda AudVolCtl
        tay
        and #%00001111
        sta AudVolCtl
        tya
        and #%11110000
        lsr
        lsr
        lsr
        lsr
        sec
        sbc #1
        asl
        asl
        asl
        asl
        ora AudVolCtl
        sta AudVolCtl
SetAudVol0To15


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
        lda FlagsSelection               ;00000   00100
        and #%11101111          ;00000   00000 
        sta FlagsSelection               ;00000   00000
PlayNote3
        lda DebounceCtr
        beq AllowBtn3
        jmp SkipSelectionSet
AllowBtn3
        lda #%00010000            
        bit SWCHA
        bne Frq0Down

        lda AudFrqDur
        and #%11111000
        lsr
        lsr
        lsr
        cmp #31
        bne IncAudFrq0
        lda AudFrqDur
        and #%00000111
        sta AudFrqDur
        sec
        bcs SetAudFrq0ToZero
IncAudFrq0
        lda AudFrqDur
        tay
        and #%00000111
        sta AudFrqDur
        tya
        and #%11111000
        lsr
        lsr
        lsr
        clc
        adc #1
        asl
        asl
        asl
        ora AudFrqDur
        sta AudFrqDur
SetAudFrq0ToZero

        jmp SelectionSet
Frq0Down
        lda #%00100000            
        bit SWCHA
        bne Frq0Up

        lda AudFrqDur
        and #%11111000
        lsr
        lsr
        lsr
        cmp #0
        bne DecAudFrq0
        lda AudFrqDur
        ora #%11111000
        sta AudFrqDur
        sec
        bcs SetAudFrq0To31
DecAudFrq0
        lda AudFrqDur
        tay
        and #%00000111
        sta AudFrqDur
        tya
        and #%11111000
        lsr
        lsr
        lsr
        sec
        sbc #1
        asl
        asl
        asl
        ora AudFrqDur
        sta AudFrqDur
SetAudFrq0To31

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
        lda FlagsSelection               ;00000   00100
        and #%11101111          ;00000   00000 
        sta FlagsSelection               ;00000   00000
PlayNote4
        lda DebounceCtr
        beq AllowBtn4
        jmp SkipSelectionSet
AllowBtn4
        lda #%00010000            
        bit SWCHA
        bne Ctl0Down

        lda AudVolCtl
        and #%00001111
        cmp #15
        bne IncAudCtl0
        lda AudVolCtl
        and #%11110000
        sta AudVolCtl
        sec
        bcs SetAudCtl0ToZero
IncAudCtl0
        inc AudVolCtl
SetAudCtl0ToZero

        jmp SelectionSet
Ctl0Down
        lda #%00100000            
        bit SWCHA
        bne Ctl0Up
        
        lda AudVolCtl
        and #%00001111
        cmp #0
        bne DecAudCtl0
        lda AudVolCtl
        ora #%00001111
        sta AudVolCtl
        sec
        bcs SetAudCtl0To15
DecAudCtl0
        dec AudVolCtl
SetAudCtl0To15

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
        lda #128
        bit FlagsSelection
        bne SetPlayAllFlagToZero 
        lda FlagsSelection               ;0000   0000
        and #%01111111          ;0000   0000 
        eor #128                  ;1000   1000     
        sta FlagsSelection               ;1000   1000
        jmp SelectionSet
SetPlayAllFlagToZero
        lda FlagsSelection               ;0000   0010
        and #%01111111          ;0000   0000 
        sta FlagsSelection               ;0000   0000 
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
        lda FlagsSelection               ;0000   0010
        and #%11011111          ;0000   0000 
        eor #32                  ;0010   0010     
        sta FlagsSelection               ;0010   0010
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
        lda FlagsSelection               ;00000   00100
        and #%10111111          ;00000   00000 
        eor #64                  ;00100   00100    
        sta FlagsSelection               ;00100   00100
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; Build Audio Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; Build Audio Duration Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #<(Zero)
        sta DurGfxPtr

        lda #>(Zero)
        sta DurGfxPtr+1 

        lda AudFrqDur
        sta LineTemp
        and #%11111000
        sta YTemp
        lda AudFrqDur
        and #%00000111
        sta AudFrqDur
        asl
        asl
        clc
        adc AudFrqDur
        ;ora YTemp
        ;sta AudFrqDur

        clc
        adc DurGfxPtr
        sta DurGfxPtr

        lda DurGfxPtr+1
        sta DurGfxPtr+1
        lda LineTemp
        sta AudFrqDur

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Build Audio Volume Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #<(RZero)
        sta VolGfxPtr

        lda #>(RZero)
        sta VolGfxPtr+1

        lda AudVolCtl
        sta LineTemp
        and #%00001111
        sta YTemp
        lda AudVolCtl
        and #%11110000
        lsr
        lsr
        lsr
        lsr
        sta AudVolCtl
        asl
        asl
        ;clc
        adc AudVolCtl
        ;clc
        adc VolGfxPtr
        sta VolGfxPtr
GetVolIdx
        ;asl
        lda VolGfxPtr+1
        sta VolGfxPtr+1

        lda LineTemp
        sta AudVolCtl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; Build Audio Frequency Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda #<(Zero)
        sta FrqGfxPtr

        lda #>(Zero)
        sta FrqGfxPtr+1  
 
        lda AudFrqDur
        sta LineTemp
        and #%00000111
        sta YTemp
        lda AudFrqDur
        and #%11111000
        lsr
        lsr
        lsr
        sta AudFrqDur
        asl
        asl
        ;clc
        adc AudFrqDur
        ;clc
        adc FrqGfxPtr
        sta FrqGfxPtr
GetFrqIdx
        lda FrqGfxPtr+1
        sta FrqGfxPtr+1
        lda LineTemp
        sta AudFrqDur


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Build Audio Control Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #<(RSZero)
        sta CtlGfxPtr

        lda #>(RSZero)
        sta CtlGfxPtr+1  

        lda AudVolCtl
        sta LineTemp
        and #%11110000
        sta YTemp
        lda AudVolCtl
        and #%00001111
        sta AudVolCtl
        asl
        asl
        clc
        adc AudVolCtl

        clc
        adc CtlGfxPtr
        sta CtlGfxPtr
GetCtlIdx
        lda CtlGfxPtr
        ldx CtlGfxPtr+1
        sta CtlGfxPtr
        stx CtlGfxPtr+1 

        lda LineTemp
        sta AudVolCtl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Build Audio Channel Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #<(Zero)
        sta ChannelGfxPtr

        lda #>(Zero)
        sta ChannelGfxPtr+1  

        lda AudChannel
        asl
        asl
        clc
        adc AudChannel

        ldy #0
        clc
        adc ChannelGfxPtr
        sta ChannelGfxPtr
GetChannelIdx
        lda ChannelGfxPtr+1
        sta ChannelGfxPtr+1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Note Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx AudChannel
        lda #16
        bit FlagsSelection
        bne SkipPlayNote
        lda AudFrqDur
        and #%00000111
        tay
        lda NoteDurations,y
        cmp FrameCtrTrk0,x
        beq TurnOffNote

        lda AudVolCtl
        and #%11110000
        lsr
        lsr
        lsr
        lsr
        sta AUDV0,x

        lda AudFrqDur
        and #%11111000
        lsr
        lsr
        lsr
        sta AUDF0,x

        lda AudVolCtl
        and #%00001111
        sta AUDC0,x
        inc FrameCtrTrk0,x


LoadPauseButton
        lda #<PauseButton
        sta PlayButtonMaskPtr
        lda #>PauseButton
        sta PlayButtonMaskPtr+1


        sec
        bcs SkipPlayNote
TurnOffNote
        ldx AudChannel
        lda #0
        sta AUDV0,x
        sta AUDF0,x
        sta AUDC0,x
        sta FrameCtrTrk0,x
        lda FlagsSelection               ;00000   00100
        and #%11101111          ;00000   00000 
        eor #16                  ;00100   00100    
        sta FlagsSelection               ;00100   00100

LoadPlayButton
        lda #<PlayButton
        sta PlayButtonMaskPtr
        lda #>PlayButton
        sta PlayButtonMaskPtr+1
SkipPlayNote

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Note ptr Fix ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
        lda #0
        sta YTemp
        sta LineTemp
        sta LetterBuffer


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Add Note ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda #32
        bit FlagsSelection
        beq SkipAddNote

        ldx AudChannel
        cpx #1
        beq AddNoteChannel1

        lda Track0BuilderPtr
        cmp #<Track0Builder+#TRACKSIZE
        beq SkipAddNote

        ldy #0

        lda AudFrqDur
        sta (Track0BuilderPtr),y
        iny
        lda AudVolCtl
        sta (Track0BuilderPtr),y
        iny
        lda #0
        sta (Track0BuilderPtr),y
        
        lda Track0BuilderPtr
        clc
        adc #2
        sta Track0BuilderPtr

        sec
        bcs AddNoteChannel0
AddNoteChannel1
        lda Track1BuilderPtr
        cmp #<Track1Builder+#TRACKSIZE
        beq SkipAddNote

        ldy #0

        lda AudFrqDur
        sta (Track1BuilderPtr),y
        iny
        lda AudVolCtl
        sta (Track1BuilderPtr),y
        iny
        lda #0
        sta (Track1BuilderPtr),y
        
        lda Track1BuilderPtr
        clc
        adc #2
        sta Track1BuilderPtr

AddNoteChannel0
        lda FlagsSelection               ;0000   0010
        and #%11011111          ;0000   0000 
        sta FlagsSelection               ;0000   0000      
SkipAddNote
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Remove Note ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda #64
        bit FlagsSelection
        beq SkipRemoveNote

        ldx AudChannel
        cpx #1
        beq RemNoteChannel1

        lda Track0BuilderPtr
        cmp #<Track0Builder
        beq SkipRemoveNote
        
        lda #0
        ldy #0        
        sta (Track0BuilderPtr),y

        ldy #$FF
        sta (Track0BuilderPtr),y
        dey
        lda #0
        sta (Track0BuilderPtr),y
        
        lda Track0BuilderPtr
        sec
        sbc #2
        sta Track0BuilderPtr
        sec
        bcs RemNoteChannel0
RemNoteChannel1
        lda Track1BuilderPtr
        cmp #<Track1Builder
        beq SkipRemoveNote
        
        lda #0
        ldy #0        
        sta (Track1BuilderPtr),y

        ldy #$FF
        sta (Track1BuilderPtr),y
        dey
        lda #0
        sta (Track1BuilderPtr),y
        
        lda Track1BuilderPtr
        sec
        sbc #2
        sta Track1BuilderPtr
RemNoteChannel0
        lda FlagsSelection               ;00000   00100
        and #%10111111          ;00000   00000 
        sta FlagsSelection               ;00000   00000      
SkipRemoveNote
        

        lda #128
        bit FlagsSelection
        bne SkipRamMusicPlayerJump
        jmp SkipRamMusicPlayer
SkipRamMusicPlayerJump
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; Ram Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0                                          ; 2     Initialize Y-Index to 0
        lda (NotePtrCh0),y                              ; 5     Load first note duration to A
        and #%00000111
        tay
        lda NoteDurations,y
        cmp FrameCtrTrk0                                ; 3     See if it equals the Frame Counter
        bne NextRamNote                                 ; 2/3   If so move the NotePointer to the next note

        lda NotePtrCh0                                  ; 3     Load the Note Pointer to A
        clc                                             ; 2     Clear the carry 
        adc #2                                          ; 2     Add 4 to move the Notep pointer to the next note
        sta NotePtrCh0                                  ; 3     Store the new note pointer

        lda #0                                          ; 2     Load Zero to
        sta FrameCtrTrk0                                ; 3     Reset the Frame counter
NextRamNote
        lda (NotePtrCh0),y                              ; 5     Load first note duration to A
        and #%00000111
        cmp #0                                          ; 2     See if the notes duration equals 255
        bne SkipResetRamTrack0                          ; 2/3   If so go back to the beginning of the track

        lda #<Track0Builder                             ; 4     Store the low byte of the track to 
        sta NotePtrCh0                                  ; 3     the Note Pointer
SkipResetRamTrack0

        ;iny                                             ; 2     Increment Y (Y=1) to point to the Note Volume
        lda (NotePtrCh0),y                              ; 5     Load Volume to A
        and #%11111000
        lsr
        lsr
        lsr
        sta AUDF0                                       ; 3     and set the Note Volume
        iny                                             ; 2     Increment Y (Y=2) to point to the Note Frequency
        lda (NotePtrCh0),y                              ; 5     Load Frequency to A
        and #%11110000
        lsr
        lsr
        lsr
        lsr
        sta AUDV0                                       ; 3     and set the Note Frequency
        ;iny                                             ; 2     Increment Y (Y=3) to point to the Note Control
        lda (NotePtrCh0),y                              ; 5     Load Control to A
        and #%00001111
        sta AUDC0                                       ; 3     and set the Note Control
        inc FrameCtrTrk0                                ; 5     Increment the Frame Counter to duration compare later


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0                                          ; 2     Initialize Y-Index to 0
        lda (NotePtrCh1),y                              ; 5     Load first note duration to A
        and #%00000111
        tay
        lda NoteDurations,y
        cmp FrameCtrTrk1                                ; 3     See if it equals the Frame Counter
        bne NextRamNote1                                ; 2/3   If so move the NotePointer to the next note

        lda NotePtrCh1                                  ; 3     Load the Note Pointer to A
        clc                                             ; 2     Clear the carry 
        adc #2                                          ; 2     Add 4 to move the Notep pointer to the next note
        sta NotePtrCh1                                  ; 3     Store the new note pointer

        lda #0                                          ; 2     Load Zero to
        sta FrameCtrTrk1                                ; 3     Reset the Frame counter
NextRamNote1
        lda (NotePtrCh1),y                              ; 5     Load first note duration to A
        and #%00000111
        cmp #0                                          ; 2     See if the notes duration equals 255
        bne SkipResetRamTrack1                          ; 2/3   If so go back to the beginning of the track

        lda #<Track1Builder                             ; 4     Store the low byte of the track to 
        sta NotePtrCh1                                  ; 3     the Note Pointer
SkipResetRamTrack1

        ;iny                                             ; 2     Increment Y (Y=1) to point to the Note Volume
        lda (NotePtrCh1),y                              ; 5     Load Volume to A
        and #%11111000
        lsr
        lsr
        lsr
        sta AUDF1                                       ; 3     and set the Note Volume
        iny                                             ; 2     Increment Y (Y=2) to point to the Note Frequency
        lda (NotePtrCh1),y                              ; 5     Load Frequency to A
        and #%11110000
        lsr
        lsr
        lsr
        lsr
        sta AUDV1                                       ; 3     and set the Note Frequency
        ;iny                                             ; 2     Increment Y (Y=3) to point to the Note Control
        lda (NotePtrCh1),y                              ; 5     Load Control to A
        and #%00001111
        sta AUDC1                                       ; 3     and set the Note Control
        inc FrameCtrTrk1                                ; 5     Increment the Frame Counter to duration compare later

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



LoadPauseAllButton
        lda #<PauseButton
        sta PlayAllButtonMaskPtr
        lda #>PauseButton
        sta PlayAllButtonMaskPtr+1

        sec
        bcs SkipResetPlayAllButton

SkipRamMusicPlayer
        lda #16
        bit FlagsSelection
        beq SkipResetAud

LoadPlayAllButton
        lda #<PlayButton
        sta PlayAllButtonMaskPtr
        lda #>PlayButton
        sta PlayAllButtonMaskPtr+1

        lda #<Track0Builder                              ; 4     Store the low byte of the track to 
        sta NotePtrCh0                                   ; 3     the Note Pointer
        
        lda #0
        sta AUDV0
        sta AUDV1
        sta AUDC0
        sta AUDC1
        sta AUDF0
        sta AUDF1
        sta FrameCtrTrk0
        sta FrameCtrTrk1
SkipResetAud
SkipResetPlayAllButton
;;;;;;;;;;;;;;;;;; End Ram Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
        ldy #26                                         ; 2

        lda FlagsSelection               ;00000   00100
        and #%10111111          ;00000   00000 
        sta FlagsSelection               ;00000   00000 
        
        lda FlagsSelection               ;0000   0010
        and #%11011111          ;0000   0000 
        sta FlagsSelection               ;0000   0000  
WaitLoop
        lda INTIM
        bne WaitLoop
; overscan
        ldx #6                                         ; 2
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


NoteDurations   .byte 0         ; control note - 0
                .byte 3
                .byte 9         ; 32nd note - 9/?       2^3 8
                .byte 18        ; 16th note - 18/15     2^4 16
                .byte 36        ; eighth note - 36/30   2^5 32
                .byte 48        ; triplet note - 48/40  2^6 64
                .byte 72        ; quarter note - 72/60  2^7 128
                .byte 144       ; half note - 144/120   2^9 256
                ;.byte 216       ; whole(3/4) note - 216 or maybe half triplets

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

OneZero    .byte  #%01100111
           .byte  #%00100101
           .byte  #%00100101
           .byte  #%00100101
           .byte  #%01110111

OneOne     .byte  #%01100110
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%01110111

OneTwo     .byte  #%01100111
           .byte  #%00100001
           .byte  #%00100111
           .byte  #%00100100
           .byte  #%01110111

OneThree   .byte  #%01100111
           .byte  #%00100001
           .byte  #%00100111
           .byte  #%00100001
           .byte  #%01110111

OneFour    .byte  #%01100101
           .byte  #%00100101
           .byte  #%00100111
           .byte  #%00100001
           .byte  #%01110001

OneFive    .byte  #%01100111
           .byte  #%00100100
           .byte  #%00100111
           .byte  #%00100001
           .byte  #%01110111

OneSix     .byte  #%01100111
           .byte  #%00100100
           .byte  #%00100111
           .byte  #%00100101
           .byte  #%01110111

OneSeven   .byte  #%01100111
           .byte  #%00100001
           .byte  #%00100001
           .byte  #%00100001
           .byte  #%01110001

OneEight   .byte  #%01100111
           .byte  #%00100101
           .byte  #%00100111
           .byte  #%00100101
           .byte  #%01110111

OneNine    .byte  #%01100111
           .byte  #%00100101
           .byte  #%00100111
           .byte  #%00100001
           .byte  #%01110111

OneA       .byte  #%01100111
           .byte  #%00100101
           .byte  #%00100111
           .byte  #%00100101
           .byte  #%01110101

OneB       .byte  #%01100110
           .byte  #%00100101
           .byte  #%00100110
           .byte  #%00100101
           .byte  #%01110110

OneC       .byte  #%01100111
           .byte  #%00100100
           .byte  #%00100100
           .byte  #%00100100
           .byte  #%01110111

OneD       .byte  #%01100110
           .byte  #%00100101
           .byte  #%00100101
           .byte  #%00100101
           .byte  #%01110110

OneE       .byte  #%01100111
           .byte  #%00100100
           .byte  #%00100111
           .byte  #%00100100
           .byte  #%01110111

OneF       .byte  #%01100111
           .byte  #%00100100
           .byte  #%00100111
           .byte  #%00100100
           .byte  #%01110100


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

        align 256
RSZero      .byte  #%11100000
           .byte  #%10100000
           .byte  #%10100000
           .byte  #%10100000
           .byte  #%11100000

RSOne       .byte  #%01100000
           .byte  #%01000000
           .byte  #%01000000
           .byte  #%01000000
           .byte  #%11100000

RSTwo       .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000
           .byte  #%00100000
           .byte  #%11100000

RSThree     .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000

RSFour      .byte  #%10100000
           .byte  #%10100000
           .byte  #%11100000
           .byte  #%10000000
           .byte  #%10000000

RSFive      .byte  #%11100000
           .byte  #%00100000
           .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000

RSSix       .byte  #%11100000
           .byte  #%00100000
           .byte  #%11100000
           .byte  #%10100000
           .byte  #%11100000

RSSeven     .byte  #%11100000
           .byte  #%10000000
           .byte  #%10000000
           .byte  #%10000000
           .byte  #%10000000

RSEight     .byte  #%11100000
           .byte  #%10100000
           .byte  #%11100000
           .byte  #%10100000
           .byte  #%11100000

RSNine      .byte  #%11100000
           .byte  #%10100000
           .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000

RSA         .byte  #%11100000
           .byte  #%10100000
           .byte  #%11100000
           .byte  #%10100000
           .byte  #%10100000

RSB         .byte  #%01100000
           .byte  #%10100000
           .byte  #%01100000
           .byte  #%10100000
           .byte  #%01100000

RSC         .byte  #%11100000
           .byte  #%00100000
           .byte  #%00100000
           .byte  #%00100000
           .byte  #%11100000

RSD         .byte  #%01100000
           .byte  #%10100000
           .byte  #%10100000
           .byte  #%10100000
           .byte  #%01100000

RSE         .byte  #%11100000
           .byte  #%00100000
           .byte  #%11100000
           .byte  #%00100000
           .byte  #%11100000

RSF         .byte  #%11100000
           .byte  #%00100000
           .byte  #%11100000
           .byte  #%00100000
           .byte  #%00100000

        align 256

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

;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END