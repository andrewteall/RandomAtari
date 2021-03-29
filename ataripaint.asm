        processor 6502
        include includes/vcs.h
        include includes/macro.h

; TODO: Flag to not use Channel 1 - doubles play time
;       - Could also have channel 1 count from top so the tracks meet in the middle

; TODO: Multiplex Characters for more than 12 chars per line
; TODO: Draw Note letters from memory location

; TODO: Add total Duration of each track?

; TODO: Add Step through notes and display values
;       - Fire button plays notes
;               maybe individual track selection
;       - Make Track B solo Step backwards through notes
;       - Need to line up note playing with actual durations
;       - Add indicator to know you're in the right section(selection)

; TODO: Add Labels under controls to display usage

; TODO: Reuse Play Button Pointers

; TODO: Finalize Colors and Decor and Name
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PATTERN                        = $80                   ; storage Location (1st byte in RAM)
TITLE_H_POS                     = #57
TRACKDISPLAY_LEFT_H_POS         = #20
TRACKDISPLAY_RIGHT_H_POS        = #68
TRACKSIZE                       = #48                   ; Must be a multiple of 2

PLAY_NOTE_FLAG                  = #16
ADD_NOTE_FLAG                   = #32
REMOVE_NOTE_FLAG                = #64
PLAY_TRACK_FLAG                 = #128

DURATION_MASK                   = #%00000111
FREQUENCY_MASK                  = #%11111000
VOLUME_MASK                     = #%11110000
CONTROL_MASK                    = #%00001111
SELECTION_MASK                  = #%00001111
PLAY_NOTE_FLAG_MASK             = #%11101111

SLEEPTIMER_TITLE                = TITLE_H_POS/3 +51
SLEEPTIMER_TRACK_LEFT           = TRACKDISPLAY_LEFT_H_POS/3 +51
SLEEPTIMER_TRACK_RIGHT          = TRACKDISPLAY_RIGHT_H_POS/3 +51

BACKGROUND_COLOR                = #155          ; #155
TITLE_COLOR                     = #132          ; #132
CONTROLS_COLOR                  = #123          ; #123
SELECTION_COLOR                 = #9            ; #9

ONE_COPY                        = #0
TWO_COPIES_CLOSE                = #1
TWO_COPIES_MEDIUM               = #2
THREE_COPIES_CLOSE              = #3
TWO_COPIES_WIDE                 = #4
DOUBLE_SIZE_PLAYER              = #5
THREE_COPIES_MEDIUM             = #6
QUAD_SIZED_PLAYER               = #7
MISSLE_SIZE_ONE_CLOCK           = #0
MISSLE_SIZE_TWO_CLOCKS          = #16
MISSLE_SIZE_FOUR_CLOCKS         = #32
MISSLE_SIZE_EIGHT_CLOCKS        = #48

P1_JOYSTICK_UP                  = #%00000001
P1_JOYSTICK_DOWN                = #%00000010
P1_JOYSTICK_LEFT                = #%00000100
P1_JOYSTICK_RIGHT               = #%00001000
P0_JOYSTICK_UP                  = #%00010000
P0_JOYSTICK_DOWN                = #%00100000
P0_JOYSTICK_LEFT                = #%01000000
P0_JOYSTICK_RIGHT               = #%10000000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Ram ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        SEG.U vars
        ORG $80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Audio Working Values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AudVolCtl               ds 1                    ; 0000XXXX - Volume | XXXX0000 - Control/Timbre
AudFrqDur               ds 1                    ; 00000XXX - Frquency | XXXXX000 - Duration
AudCntChnl              ds 1                    ; XXXXXXX0 - Channel | 0000000X - Note Count Left

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Flags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FlagsSelection          ds 1                    ; 0-4 Current Selection (#0-#9) - (#10-#15 Not Used)
                                                ; 5 - Play note flag - 0 plays note
                                                ; 6 - Add note flag - 1 adds note
                                                ; 7 - Remove note flag - 1 removes note
                                                ; 8 - Play track flag - 1 plays tracks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Counters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FrameCtrTrk0            ds 1
FrameCtrTrk1            ds 1
DebounceCtr             ds 1                    ; XXXX0000 - Top 4 bits not used
DurationLeftNoteA       ds 1
DurationLeftNoteB       ds 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rom Pointers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PlayButtonMaskPtr       ds 2                    
PlayAllButtonMaskPtr    ds 2 

VolGfxPtr               ds 2
DurGfxPtr               ds 2

FrqCntGfxPtr            ds 2
CtlChnlGfxPtr           ds 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ram Pointers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Track0BuilderPtr        ds 1                    ; 
YTemp                   ds 1                    ; This will get zeroed so that the Trackpointer load
Track1BuilderPtr        ds 1                    ; 
LineTemp                ds 1                    ; will seem like it has 2 bytes

NotePtrCh0              ds 2                    ; 
;Space Available
NotePtrCh1              ds 1
LetterBuffer            ds 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ram Music Tracks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Track0Builder           ds #TRACKSIZE+1         ; Memory Allocation to store the bytes(notes) saved to track 0
Track1Builder           ds #TRACKSIZE+1         ; Memory Allocation to store the bytes(notes) saved to track 1

;TestCounter             ds 1

        echo "----",([* - $80]d) , (* - $80) ,"bytes of RAM Used"
        echo "----",([$100 - *]d) , ($100 - *) , "bytes of RAM left"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Ram ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Console Initialization ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        SEG
        ORG $1000
        RORG $F000

SwitchToBank1
        lda $1FF9

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
        lda #30
        sta DebounceCtr

        ldx #0
        lda #TITLE_H_POS
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #1
        lda #TITLE_H_POS+8
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        lda #TITLE_COLOR
        sta COLUP0
        sta COLUP1

        lda #%00100101
        sta CTRLPF       

        lda #THREE_COPIES_CLOSE
        sta NUSIZ0
        sta NUSIZ1

        lda #1
        sta VDELP0
        sta VDELP1

        lda #<Track0Builder
        sta NotePtrCh0

        lda #<Track1Builder
        sta NotePtrCh1

        lda #<Track0Builder
        sta Track0BuilderPtr

        lda #<Track1Builder
        sta Track1BuilderPtr

        lda AudFrqDur
        and #FREQUENCY_MASK
        ora #00000001
        sta AudFrqDur

        ; lda #0
        ; sta TestCounter
        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Console Initialization ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


StartOfFrame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start VBLANK Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #0
        sta VBLANK

; 3 VSYNC Lines
        lda #2
        sta VSYNC ; Turn on VSYNC

        sta WSYNC
        sta WSYNC
        sta WSYNC
        lda #0
        sta VSYNC ; Turn off VSYNC

        lda #0
        sta Track1Builder+TRACKSIZE
; 37 VBLANK lines
        ldx #37                                         ; 2
VerticalBlank
        sta WSYNC                                       ; 3
        dex                                             ; 2
        bne VerticalBlank                               ; 2/3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End VBLANK Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start 192 Lines of Viewable Picture
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #BACKGROUND_COLOR
        stx COLUBK
        ldx #0
        IF TITLE_H_POS <= 47
         sta WSYNC                                      ; 3     
        ENDIF

ViewableScreenStart
        inx                                             ; 2     
        ldy #0
        cpx #3                                          ; 2     
        sta WSYNC                                       ; 3     
        bne ViewableScreenStart                         ; 2/3   2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Title Text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        SLEEP SLEEPTIMER_TITLE
        inx                                             ; 2
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
        nop                                             ; 2     74
        nop                                             ; 2     76
        bne DrawText                                    ; 2/3   2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TopBuffer
        inx                                             ; 2     59
        cpx #20                                         ; 2     61
        sta WSYNC                                       ; 3     64
        bne TopBuffer                                   ; 2/3   2/3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Note Values Row 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        inx                                     ; 2     4
        txa                                     ; 2     6
        sbc #19                                 ; 2     8
        lsr                                     ; 2     10      Divide by 2 to get index twice for double height
        lsr                                     ; 2     12      Divide by 2 to get index twice for quad height
        sta WSYNC                               ; 3     14     
        SLEEP 4                                 ; 4     4       Account for 4 cycle branch to keep timing aligned
NoteRow 
        lsr                                     ; 2     6       Divide by 2 to get index twice for octuple height
        tay                                     ; 2     8       Transfer A to Y so we can index off Y
        
        lda (PlayButtonMaskPtr),y               ; 5     13      Get the Score From our Play Button Mask Array
        sta PF0                                 ; 3     16      Store the value to PF0

        lda (DurGfxPtr),y                       ; 5     21      Get the Score From our Duration Gfx Array
        asl                                     ; 2     23
        asl                                     ; 2     25
        sta PF1                                 ; 3     28      Store the value to PF1
        
        lda (VolGfxPtr),y                       ; 5     33      Get the Score From our Volume Gfx Array
        asl                                     ; 2     35
        sta PF2                                 ; 3     38      Store the value to PF2

        nop                                     ; 2     40      Waste 2 cycles to line up the next Pf draw

        lda (FrqCntGfxPtr),y                    ; 5     45      Get the Score From our Frequency Gfx Array
        sta PF2                                 ; 3     48      Store the value to PF2
        
        lda (CtlChnlGfxPtr),y                   ; 5     53      Get the Score From our Control Gfx Array
        sta PF1                                 ; 3     56      Store the value to PF1        

        inx                                     ; 2     58      Increment our line number
        
        ldy #0                                  ; 2     60      Reset and clear the playfield
        txa                                     ; 2     62      Transfer the line number in preparation for the next line
        sbc #19                                 ; 2     64      Subtract #19 since the carry is cleared above
        lsr                                     ; 2     66      Divide by 2 to get index twice for double height
        sty PF0                                 ; 3     69      Reset and clear the playfield
        lsr                                     ; 2     71      Divide by 2 to get index twice for quadruple height
        sty.w PF1                                 ; 3     74      Reset and clear the playfield

        cpx #60                                 ; 2     76      Have we reached line #60   
        bne NoteRow                             ; 2/4   2/4     No then repeat,Currently Crossing Page Boundary 
                                                ;               So Add one cycle

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Note Values Selection Row
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0
        sty PF2                                         ; 3     65      Reset and clear the playfield
        inx                                             ; 2     6
        lda #CONTROLS_COLOR
        sta COLUPF
        sta WSYNC                                       ; 3     3
        SLEEP 3                                         ; 3     3
        
NoteSelection
        stx LineTemp
        lda FlagsSelection                              ; 3
        and #SELECTION_MASK                             ; 2

        bne SkipSelectPlayButton                        ; 2/3
        ldx #%11100000                                  ; 2
        stx PF0                                         ; 3
SkipSelectPlayButton

        sty PF1
        cmp #1                                          ; 2
        bne SkipSelectDuration                          ; 2/3
        ldx #%01111111                                  ; 2
        stx PF1                                         ; 3
SkipSelectDuration

        cmp #2
        bne SkipSelectVolume
        ldx #%00111110
        stx PF2
SkipSelectVolume
                
        SLEEP 9

        cmp #3
        sty PF2
        bne SkipSelectFreq
        ldx #%11111111
        stx PF2
SkipSelectFreq

        cmp #4
        sty PF1        
        bne SkipSelectControl
        ldx #%11111000
        stx PF1
SkipSelectControl
        
        sty PF0                                         ; 3     67
        sty PF2                                         ; 3     67

        ldx LineTemp
        inx                                             ; 2     4
        cpx #68                                         ; 2     6
        sta WSYNC                                       ; 3     9
        bne NoteSelection                               ; 2/3   2/3

        lda #0                                          ; 2     64
        sta PF1                                         ; 3     67
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spacer 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #SELECTION_COLOR
        sta COLUPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Build Audio Channel Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #<(ZeroChnl)
        sta CtlChnlGfxPtr

        lda #>(ZeroChnl)
        sta CtlChnlGfxPtr+1  
        
        lda AudCntChnl
        and #1
        sta LineTemp
        asl
        asl
        clc
        adc LineTemp

        clc
        adc CtlChnlGfxPtr
        sta CtlChnlGfxPtr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; Build Notes Left Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #<(RSDZero)
        sta FrqCntGfxPtr

        lda #>(RSDZero)
        sta FrqCntGfxPtr+1  

        lda AudCntChnl
        and #%11111110
        lsr
        sta LineTemp
        asl
        asl
        clc
        adc LineTemp

        clc
        adc FrqCntGfxPtr
        sta FrqCntGfxPtr
        inx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Spacer
        inx                                             ; 2     4
        cpx #80                                         ; 2     6
        sta WSYNC                                       ; 3     9
        bne Spacer                                      ; 2/3   2/3
        SLEEP 3
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Track Controls Row 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ControlRow
        txa                                             ; 2     5
        sbc #79                                         ; 2     7
        lsr                                             ; 2     9       Divide by 2 to get index twice for double height
        lsr                                             ; 2     11      Divide by 2 to get index twice for double height
        lsr                                             ; 2     13      Divide by 2 to get index twice for double height
        tay                                             ; 2     15      Transfer A to Y so we can index off Y
        
        lda (PlayAllButtonMaskPtr),y                    ; 5     20      Get the Score From our Player 0 Score Array
        sta PF0                                         ; 3     23      

        lda PlusBtn,y                                   ; 4     27      Get the Score From our Player 0 Score Array
        sta PF1                                         ; 3     30      
        
        SLEEP 3                                         ; 3     33
        
        lda MinusBtn,y                                  ; 4     37      Get the Score From our Player 0 Score Array
        sta PF2                                         ; 3     40
        
        lda (CtlChnlGfxPtr),y                           ; 5     45      Get the Score From our Player 0 Score Array
        sta PF2                                         ; 3     48      Store Score to PF2
        
        lda (FrqCntGfxPtr),y                            ; 5     53      Get the Score From our Player 0 Score Array
        sta PF1                                         ; 3     56      Store Score to PF2
        
        lda #0                                          ; 2     58
        sta PF0                                         ; 3     61
        
        

        inx                                             ; 2     63
        cpx #120                                        ; 2     65
        sta PF2                                         ; 3     68
        sta PF1                                         ; 3     71
        sta WSYNC                                       ; 3     74
        
        bne ControlRow                                  ; 2/3   2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Track Selection Row
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #CONTROLS_COLOR
        sta COLUPF
        ldy #0
        inx                                             ; 2     4
        sta WSYNC                                       ; 3     3
        SLEEP 4                                         ; 3     3

ControlSelection
        stx LineTemp
        lda FlagsSelection                              ; 3
        and #SELECTION_MASK                                 ; 2

        cmp #5
        bne SkipSelectPlayAllButton                     ; 2/3
        lda #%11100000                                  ; 2
        sta PF0                                         ; 3
SkipSelectPlayAllButton

        sty PF1
        cmp #6                                          ; 2
        bne SkipSelectAddNote                           ; 2/3
        lda #%00011111                                  ; 2
        sta PF1                                         ; 3
SkipSelectAddNote

        cmp #7
        bne SkipSelectRemoveNote
        lda #%11111000
        sta PF2
SkipSelectRemoveNote

        SLEEP 9

        cmp #8
        sty PF2
        bne SkipSelectRemoveChannel
        lda #%01111100
        sta PF2
SkipSelectRemoveChannel

        sty PF1
        sty PF0
        sty PF2
        
        ldx LineTemp
        inx                                             ; 2     4
        cpx #128                                        ; 2     6
        sta WSYNC                                       ; 3     9
        bne ControlSelection                            ; 2/3   2/3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda #SELECTION_COLOR
        sta COLUPF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0
        lda #<(Zero)
        sta DurGfxPtr

        lda #>(Zero)
        sta DurGfxPtr+1 

        lda (NotePtrCh0),y
        sta LineTemp
        and #FREQUENCY_MASK
        sta YTemp
        lda (NotePtrCh0),y
        and #DURATION_MASK
        sta (NotePtrCh0),y
        asl
        asl
        clc
        adc (NotePtrCh0),y
        clc
        adc DurGfxPtr
        sta DurGfxPtr
        lda LineTemp
        sta (NotePtrCh0),y
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #1
        lda #<(RZero)
        sta VolGfxPtr

        lda #>(RZero)
        sta VolGfxPtr+1

        lda (NotePtrCh0),y
        sta LineTemp
        and #CONTROL_MASK
        sta YTemp
        lda (NotePtrCh0),y
        and #VOLUME_MASK
        lsr
        lsr
        lsr
        lsr
        sta (NotePtrCh0),y
        asl
        asl
        clc
        adc (NotePtrCh0),y
        clc
        adc VolGfxPtr
        sta VolGfxPtr
        lda LineTemp
        sta (NotePtrCh0),y
        inx
        inx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0
        lda #<(Zero)
        sta FrqCntGfxPtr

        lda #>(Zero)
        sta FrqCntGfxPtr+1  
 
        lda (NotePtrCh0),y
        sta LineTemp
        and #DURATION_MASK
        sta YTemp
        lda (NotePtrCh0),y
        and #FREQUENCY_MASK
        lsr
        lsr
        lsr
        sta (NotePtrCh0),y
        asl
        asl
        clc
        adc (NotePtrCh0),y
        clc
        adc FrqCntGfxPtr
        sta FrqCntGfxPtr
        lda LineTemp
        sta (NotePtrCh0),y
        inx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #1
        lda #<(RSZero)
        sta CtlChnlGfxPtr

        lda #>(RSZero)
        sta CtlChnlGfxPtr+1  

        lda (NotePtrCh0),y
        sta LineTemp
        and #VOLUME_MASK
        sta YTemp
        lda (NotePtrCh0),y
        and #CONTROL_MASK
        sta (NotePtrCh0),y
        asl
        asl
        clc
        adc (NotePtrCh0),y

        clc
        adc CtlChnlGfxPtr
        sta CtlChnlGfxPtr
        lda LineTemp
        sta (NotePtrCh0),y
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; lda #<TopPlayButton
        ; sta PlayButtonMaskPtr
        ; lda #>TopPlayButton
        ; sta PlayButtonMaskPtr+1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BottomSpacer
        inx                                             ; 2     4
        cpx #140                                        ; 2     6
        sta WSYNC                                       ; 3     9
        bne BottomSpacer                                ; 2/3   2/3
        
        inx                                     ; 2     4
        txa                                     ; 2     6
        sbc #139                                ; 2     8
        nop
        lsr                                     ; 2     12      Divide by 2 to get index twice for quad height
        sta WSYNC                               ; 3     14     
        SLEEP 4                                 ; 4     4       Account for 4 cycle branch to keep timing aligned
BottomRow 
        lsr                                     ; 2     6       Divide by 2 to get index twice for octuple height
        tay                                     ; 2     8       Transfer A to Y so we can index off Y
        
        ;lda (PlayButtonMaskPtr),y               ; 5     13      Get the Score From our Play Button Mask Array
        ;sta PF0                                 ; 3     16      Store the value to PF0
        SLEEP 8

        lda (DurGfxPtr),y                       ; 5     21      Get the Score From our Duration Gfx Array
        asl                                     ; 2     23
        asl                                     ; 2     25
        sta PF1                                 ; 3     28      Store the value to PF1
        
        lda (VolGfxPtr),y                       ; 5     33      Get the Score From our Volume Gfx Array
        asl                                     ; 2     35
        sta PF2                                 ; 3     38      Store the value to PF2

        nop                                     ; 2     40      Waste 2 cycles to line up the next Pf draw

        lda (FrqCntGfxPtr),y                    ; 5     45      Get the Score From our Frequency Gfx Array
        sta PF2                                 ; 3     48      Store the value to PF2

        lda (CtlChnlGfxPtr),y                   ; 5     53      Get the Score From our Control Gfx Array
        sta PF1                                 ; 3     56      Store the value to PF1        

        inx                                     ; 2     58      Increment our line number
        
        ldy #0                                  ; 2     60      Reset and clear the playfield
        txa                                     ; 2     62      Transfer the line number in preparation for the next line
        sbc #139                                ; 2     64      Subtract #19 since the carry is cleared above
        nop
        sty PF0                                 ; 3     69      Reset and clear the playfield
        lsr                                     ; 2     71      Divide by 2 to get index twice for quadruple height
        sty PF1                                 ; 3     74      Reset and clear the playfield

        cpx #160                                ; 2     76      Have we reached line #60   
        
        bne BottomRow                           ; 2/3   2/3
        
        ldy #0
        sty PF2                                 ; 3     65      Reset and clear the playfield



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0
        lda #<(Zero)
        sta DurGfxPtr

        lda #>(Zero)
        sta DurGfxPtr+1 

        lda (NotePtrCh1),y
        sta LineTemp
        and #FREQUENCY_MASK
        sta YTemp
        lda (NotePtrCh1),y
        and #DURATION_MASK
        sta (NotePtrCh1),y
        asl
        asl
        clc
        adc (NotePtrCh1),y
        clc
        adc DurGfxPtr
        sta DurGfxPtr
        lda LineTemp
        sta (NotePtrCh1),y
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #1
        lda #<(RZero)
        sta VolGfxPtr

        lda #>(RZero)
        sta VolGfxPtr+1

        lda (NotePtrCh1),y
        sta LineTemp
        and #CONTROL_MASK
        sta YTemp
        lda (NotePtrCh1),y
        and #VOLUME_MASK
        lsr
        lsr
        lsr
        lsr
        sta (NotePtrCh1),y
        asl
        asl
        clc
        adc (NotePtrCh1),y
        clc
        adc VolGfxPtr
        sta VolGfxPtr
        lda LineTemp
        sta (NotePtrCh1),y
        inx
        inx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0
        lda #<(Zero)
        sta FrqCntGfxPtr

        lda #>(Zero)
        sta FrqCntGfxPtr+1  
 
        lda (NotePtrCh1),y
        sta LineTemp
        and #DURATION_MASK
        sta YTemp
        lda (NotePtrCh1),y
        and #FREQUENCY_MASK
        lsr
        lsr
        lsr
        sta (NotePtrCh1),y
        asl
        asl
        clc
        adc (NotePtrCh1),y
        clc
        adc FrqCntGfxPtr
        sta FrqCntGfxPtr
        lda LineTemp
        sta (NotePtrCh1),y
        inx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #1
        lda #<(RSZero)
        sta CtlChnlGfxPtr

        lda #>(RSZero)
        sta CtlChnlGfxPtr+1  

        lda (NotePtrCh1),y
        sta LineTemp
        and #VOLUME_MASK
        sta YTemp
        lda (NotePtrCh1),y
        and #CONTROL_MASK
        sta (NotePtrCh1),y
        asl
        asl
        clc
        adc (NotePtrCh1),y

        clc
        adc CtlChnlGfxPtr
        sta CtlChnlGfxPtr
        lda LineTemp
        sta (NotePtrCh1),y

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; lda #<BottomPlayButton
        ; sta PlayButtonMaskPtr
        ; lda #>BottomPlayButton
        ; sta PlayButtonMaskPtr+1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        jmp SkipBuffer
        REPEAT 30
        nop
        REPEND
SkipBuffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BottomSpacer2
        inx                                             ; 2     4
        cpx #165                                        ; 2     6
        sta WSYNC                                       ; 3     9
        bne BottomSpacer2                                ; 2/3   2/3
        
        inx                                     ; 2     4
        txa                                     ; 2     6
        sbc #164                                ; 2     8
        nop
        lsr                                     ; 2     12      Divide by 2 to get index twice for quad height
        sta WSYNC                               ; 3     14     
        SLEEP 3                                 ; 4     4       Account for 4 cycle branch to keep timing aligned
BottomRow2 
        lsr                                     ; 2     6       Divide by 2 to get index twice for octuple height
        tay                                     ; 2     8       Transfer A to Y so we can index off Y
        
        ;lda (PlayButtonMaskPtr),y               ; 5     13      Get the Score From our Play Button Mask Array
        ;sta PF0                                 ; 3     16      Store the value to PF0
        SLEEP 8

        lda (DurGfxPtr),y                       ; 5     21      Get the Score From our Duration Gfx Array
        asl                                     ; 2     23
        asl                                     ; 2     25
        sta PF1                                 ; 3     28      Store the value to PF1
        
        lda (VolGfxPtr),y                       ; 5     33      Get the Score From our Volume Gfx Array
        asl                                     ; 2     35
        sta PF2                                 ; 3     38      Store the value to PF2

        nop                                     ; 2     40      Waste 2 cycles to line up the next Pf draw

        lda (FrqCntGfxPtr),y                    ; 5     45      Get the Score From our Frequency Gfx Array
        sta PF2                                 ; 3     48      Store the value to PF2

        lda (CtlChnlGfxPtr),y                   ; 5     53      Get the Score From our Control Gfx Array
        sta PF1                                 ; 3     56      Store the value to PF1        

        inx                                     ; 2     58      Increment our line number
        
        ldy #0                                  ; 2     60      Reset and clear the playfield
        txa                                     ; 2     62      Transfer the line number in preparation for the next line
        sbc #164                                ; 2     64      Subtract #19 since the carry is cleared above
        nop
        sty PF0                                 ; 3     69      Reset and clear the playfield
        lsr                                     ; 2     71      Divide by 2 to get index twice for quadruple height
        sty PF1                                 ; 3     74      Reset and clear the playfield

        cpx #185                                ; 2     76      Have we reached line #60   
        
        bne BottomRow2                           ; 2/3   2/3
        
        ldy #0
        sty PF2                                 ; 3     65      Reset and clear the playfield


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spacer - 1-Line Kernel 
; Line 1 - 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        stx LineTemp
        lda #SELECTION_COLOR
        sta COLUPF

EndofScreenBuffer
        inx                                             ; 2
        cpx #192                                        ; 2
        sta WSYNC                                       ; 3
        bne EndofScreenBuffer                           ; 2/3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of Viewable Screen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        lda #%00000010                                  ; 2 end of screen - enter blanking
        sta VBLANK                                      ; 3 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #30
        sta TIM64T

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Left Right Cursor Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda DebounceCtr                                 
        bne SkipCursorMove                              
        
        lda #P0_JOYSTICK_LEFT                                 
        bit SWCHA                                       
        bne CursorLeft                                  
        lda #10                                         
        sta DebounceCtr                                 
        lda FlagsSelection
        and #SELECTION_MASK
        beq SetCurrentSelectionto9
        dec FlagsSelection                              
        jmp SkipSetCurrentSelectionto9
SetCurrentSelectionto9
        lda FlagsSelection
        eor #%00001001
        sta FlagsSelection
SkipSetCurrentSelectionto9
CursorLeft

        lda #P0_JOYSTICK_RIGHT
        bit SWCHA
        bne CursorRight
        lda #10
        sta DebounceCtr
        lda FlagsSelection
        and #%00001001
        cmp #9
        beq SetCurrentSelectionto0
        inc FlagsSelection
        jmp SkipSetCurrentSelectionto0
SetCurrentSelectionto0
        lda FlagsSelection
        and #%11110000
        sta FlagsSelection                          
SkipSetCurrentSelectionto0                
CursorRight

SkipCursorMove

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Control Selection Detection ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda FlagsSelection                      ; Load Flags and Control Selection from Ram to the Accumulator
        and #SELECTION_MASK                     ; AND Accumulator with the SELECTION_MASK to get the selected control
        tax                                     ; Transfer the Accumulator to the X Register to free up the Accumulator
                                                ; and so we can determine which control is selected later


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check To See if Debounce Backoff is in Effect ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda DebounceCtr                         ; Check the Debounce Counter to be 0 before moving onward
        beq SetPlayNoteFlag                     ; If so then check to see if we need to enable the Play Note Flag
        jmp SkipSelectionSet                    ; If not then skip checking to enable Play Note Flag
SetPlayNoteFlag
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check To Enable Play Note Flag  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #5                                  ; Check to see if any of top row controls are selected
        bpl SkipSetPlayNoteFlag                 ; If not then skip checking to enable Play Note Flag

        ldy INPT4                               ; Check to see if the Fire Button is being pressed
        bmi SkipSetPlayNoteFlag                 ; If not then skip checking to enable Play Note Flag
                                                
        lda FlagsSelection                      ; If so then load the Flags and Controls Selection variable from Ram
        and #PLAY_NOTE_FLAG_MASK                ; Set the Play Note Flag to 0 so it is enabled while keeping all other
        sta FlagsSelection                      ; values the same. Store the values back to the Flags and Controls 
                                                ; Selection variable

        jmp SelectionSet                        ; Jump to the SelectionSet label to enable the Debounce backoff

SkipSetPlayNoteFlag
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #0                                  ; See if the Play Note Control is currently selected
        bne Selection0                          ; If not then Skip the Selection0 Routine          
        ; Turn off Track Player
        lda FlagsSelection
        and #%01111111
        sta FlagsSelection
        ; Nothing to Do Currently
Selection0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #1                                  ; See if the Note Duration Control is currently selected
        bne Selection1                          ; If not then Skip the Selection1 Routine          
DurationCheckJoystickUp
        ; Turn off Track Player
        lda FlagsSelection
        and #%01111111
        sta FlagsSelection

        lda #P0_JOYSTICK_UP                     ; Check to see if the the Joystick is pressed up
        bit SWCHA                               ; If not the skip the Joystick Up routine
        bne DurationCheckJoystickDown           ; If so then increment the Duration Value by 1
        
        lda AudFrqDur                           ; Load the Frequency and Duration variable to the Accumulator
        and #DURATION_MASK                      ; Get the lower 3 bits to compare for duration
        cmp #7                                  ; See if Duration Value is equal to #7(Max Duration Value)
        bne IncrementDuration                   ; If so set the Duration to 0 since we are increasing the duration
        
        lda AudFrqDur                           ; Load the Frequency and Duration variable to the Accumulator
        and #FREQUENCY_MASK                     ; Get the upper 5 bits for the Frequency Value and zero out Duration
        ora #%00000001
        sta AudFrqDur                           ; Store the existing Frequency Value and zeroed duration back to the
                                                ; Frequency and Duration variable
        jmp SelectionSet                        ; Jump to the SelectionSet label to enable the Debounce backoff 
IncrementDuration
        inc AudFrqDur                           ; Increment the the Frequency and Duration variable by 1 since 
                                                ; Duration is the lower 3 bits and we are not at our max Duration value

        jmp SelectionSet                        ; Jump to the SelectionSet label to enable the Debounce backoff
        
DurationCheckJoystickDown
        lda #P0_JOYSTICK_DOWN                   ; Check to see if the the Joystick is pressed down
        bit SWCHA                               ; If not the skip the Joystick Down routine
        bne Selection1                          ; If so then decrement the Duration Value by 1

        lda AudFrqDur                           ; Load the Frequency and Duration variable to the Accumulator
        and #DURATION_MASK                      ; Get the lower 3 bits to compare for duration
        cmp #1                                  ; See if Duration Value is equal to #1(Min Duration Value)
        bne DecrementDuration                   ; If so set the Duration to 7 since we are decreasing the duration

        lda AudFrqDur                           ; Load the Frequency and Duration variable to the Accumulator
        ora #DURATION_MASK                      ; Get the upper 5 bits for the Frequency Value and Max out Duration
        sta AudFrqDur                           ; Store the existing Frequency Value and zeroed duration back to the
                                                ; Frequency and Duration variable
        jmp SelectionSet                        ; Jump to the SelectionSet label to enable the Debounce backoff
DecrementDuration
        dec AudFrqDur                           ; Decrement the the Frequency and Duration variable by 1 since 
                                                ; Duration is the lower 3 bits and we are not at our min Duration value

        jmp SelectionSet                        ; Jump to the SelectionSet label to enable the Debounce backoff
Selection1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #2
        beq SkipSelection2Jump
        jmp Selection2
SkipSelection2Jump
        ; Turn off Track Player
        lda FlagsSelection
        and #%01111111
        sta FlagsSelection

        lda #P0_JOYSTICK_UP            
        bit SWCHA
        bne Vol0Down

        lda AudVolCtl
        and #VOLUME_MASK
        lsr
        lsr
        lsr
        lsr
        cmp #15
        bne IncAudVol0
        lda AudVolCtl
        and #CONTROL_MASK
        sta AudVolCtl
        sec
        bcs SetAudVol0ToZero
IncAudVol0
        lda AudVolCtl
        tay
        and #CONTROL_MASK
        sta AudVolCtl
        tya
        and #VOLUME_MASK
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
        lda #P0_JOYSTICK_DOWN            
        bit SWCHA
        bne Vol0Up

        lda AudVolCtl
        and #VOLUME_MASK
        lsr
        lsr
        lsr
        lsr
        cmp #0
        bne DecAudVol0
        lda AudVolCtl
        ora #VOLUME_MASK
        sta AudVolCtl
        sec
        bcs SetAudVol0To15
DecAudVol0
        lda AudVolCtl
        tay
        and #CONTROL_MASK
        sta AudVolCtl
        tya
        and #VOLUME_MASK
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
        cpx #3
        bne Selection3

; PlayNote3
;         lda DebounceCtr
;         beq AllowBtn3
;         jmp SkipSelectionSet
        ; Turn off Track Player
        lda FlagsSelection
        and #%01111111
        sta FlagsSelection
AllowBtn3
        lda #P0_JOYSTICK_UP            
        bit SWCHA
        bne Frq0Down

        lda AudFrqDur
        and #FREQUENCY_MASK
        lsr
        lsr
        lsr
        cmp #31
        bne IncAudFrq0
        lda AudFrqDur
        and #DURATION_MASK
        sta AudFrqDur
        sec
        bcs SetAudFrq0ToZero
IncAudFrq0
        lda AudFrqDur
        tay
        and #DURATION_MASK
        sta AudFrqDur
        tya
        and #FREQUENCY_MASK
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
        lda #P0_JOYSTICK_DOWN            
        bit SWCHA
        bne Frq0Up

        lda AudFrqDur
        and #FREQUENCY_MASK
        lsr
        lsr
        lsr
        cmp #0
        bne DecAudFrq0
        lda AudFrqDur
        ora #FREQUENCY_MASK
        sta AudFrqDur
        sec
        bcs SetAudFrq0To31
DecAudFrq0
        lda AudFrqDur
        tay
        and #DURATION_MASK
        sta AudFrqDur
        tya
        and #FREQUENCY_MASK
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
        cpx #4
        bne Selection4
        ; Turn off Track Player
        lda FlagsSelection
        and #%01111111
        sta FlagsSelection
AllowBtn4
        lda #P0_JOYSTICK_UP            
        bit SWCHA
        bne Ctl0Down

        lda AudVolCtl
        and #CONTROL_MASK
        cmp #15
        bne IncAudCtl0
        lda AudVolCtl
        and #VOLUME_MASK
        sta AudVolCtl
        sec
        bcs SetAudCtl0ToZero
IncAudCtl0
        inc AudVolCtl
SetAudCtl0ToZero

        jmp SelectionSet
Ctl0Down
        lda #P0_JOYSTICK_DOWN            
        bit SWCHA
        bne Ctl0Up
        
        lda AudVolCtl
        and #CONTROL_MASK
        cmp #0
        bne DecAudCtl0
        lda AudVolCtl
        ora #CONTROL_MASK
        sta AudVolCtl
        jmp SelectionSet
DecAudCtl0
        dec AudVolCtl
SetAudCtl0To15

        jmp SelectionSet
Ctl0Up                
Selection4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #5
        bne Selection5
        ldy INPT4
        bmi Selection5
AllowBtn5
        lda #PLAY_TRACK_FLAG
        bit FlagsSelection
        bne SetPlayAllFlagToZero 
        lda FlagsSelection
        and #%01111111
        eor #PLAY_TRACK_FLAG
        sta FlagsSelection
        jmp SelectionSet
SetPlayAllFlagToZero
        lda FlagsSelection
        and #%01111111
        sta FlagsSelection
        jmp SelectionSet
Selection5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 6 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #6
        bne Selection6
        ; Turn off Track Player
        lda FlagsSelection
        and #%01111111
        sta FlagsSelection

        ldy INPT4
        bmi Selection6
AllowBtn6
        lda FlagsSelection
        and #%11011111
        eor #ADD_NOTE_FLAG
        sta FlagsSelection
        jmp SelectionSet
Selection6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #7
        bne Selection7
        ldy INPT4
        bmi Selection7

        ; Turn off Track Player
        lda FlagsSelection
        and #%01111111
        sta FlagsSelection
AllowBtn7
        lda FlagsSelection
        and #%10111111
        eor #REMOVE_NOTE_FLAG
        sta FlagsSelection
        jmp SelectionSet
Selection7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 8 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #8
        bne Selection8

        ; Turn off Track Player
        lda FlagsSelection
        and #%01111111
        sta FlagsSelection

AllowBtn8
        lda #P0_JOYSTICK_UP            
        bit SWCHA
        bne Chl0Down
        lda #1
        ora AudCntChnl
        sta AudCntChnl
        jmp SelectionSet
Chl0Down
        lda #P0_JOYSTICK_DOWN            
        bit SWCHA
        bne Chl0Up
        lda #%11111110
        and AudCntChnl
        sta AudCntChnl
        jmp SelectionSet
Chl0Up
Selection8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 9 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #9
        beq SkipJumpSelection9
        jmp Selection9
SkipJumpSelection9
        ; Turn off Track Player
        lda FlagsSelection
        and #%01111111
        sta FlagsSelection

        lda #P0_JOYSTICK_UP            
        bit SWCHA
        beq PtrRight
        jmp SkipPtrRight
PtrRight
        ;inc TestCounter

        lda DurationLeftNoteA
        bne SkipDurationACheck

        ldy #0 
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipResetPtrTrackZero                          

        lda #<Track0Builder                             
        sta NotePtrCh0                                  
        
        lda (NotePtrCh0),y                              
        and #DURATION_MASK

SkipResetPtrTrackZero
        tay
        lda NoteDurations,y
        sta DurationLeftNoteA

SkipDurationACheck
        
        lda DurationLeftNoteB
        bne SkipDurationBCheck

        ldy #0 
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipResetPtrTrackOne                          

        lda #<Track1Builder
        sta NotePtrCh1
        
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
SkipResetPtrTrackOne
        tay
        lda NoteDurations,y
        sta DurationLeftNoteB

SkipDurationBCheck

SkipDurationCheck
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Check to see which duration is longer
        lda DurationLeftNoteA
        cmp DurationLeftNoteB
        bne SkipJump
        jmp AdvanceBothPointers
SkipJump
        lda DurationLeftNoteA
        beq AdvancePointerB

        lda DurationLeftNoteB
        beq AdvancePointerA

        lda DurationLeftNoteA
        cmp DurationLeftNoteB
        bpl AdvancePointerB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AdvancePointerA
        ;Advance Pointer for Track0
        lda NotePtrCh0                                  
        clc                                             
        adc #2                                          
        sta NotePtrCh0                                  

        ; Subtract the Duration of NoteA from NoteB
        lda DurationLeftNoteB
        beq SkipSubtractA
        sec 
        sbc DurationLeftNoteA
        sta DurationLeftNoteB
SkipSubtractA
        ; Get the new Note Duration Left for Track0
        ldy #0 
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipResetPtrTrack0                          

        ; lda #<Track0Builder                             
        ; sta NotePtrCh0

        dec NotePtrCh0
        dec NotePtrCh0
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
SkipResetPtrTrack0
        tay
        lda NoteDurations,y
        sta DurationLeftNoteA

        jmp AdvanceDone
AdvancePointerB

        ;Advance Pointer for Track1
        lda NotePtrCh1                                  
        clc                                             
        adc #2                                          
        sta NotePtrCh1                                  

        ; Subtract the Duration of NoteB from NoteA
        lda DurationLeftNoteA
        beq SkipSubtractB
        sec 
        sbc DurationLeftNoteB
        sta DurationLeftNoteA
SkipSubtractB
        ; Get the new Note Duration Left for Track1
        ldy #0 
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipResetPtrTrack1                          

        ; lda #<Track1Builder                             
        ; sta NotePtrCh1                                  
        
        dec NotePtrCh1
        dec NotePtrCh1
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
SkipResetPtrTrack1
        tay
        lda NoteDurations,y
        sta DurationLeftNoteB

        jmp AdvanceDone


AdvanceBothPointers
        lda NotePtrCh0                                  ; 3     Load the Note Pointer to A
        clc                                             ; 2     Clear the carry 
        adc #2                                          ; 2     Add 4 to move the Note pointer to the next note
        sta NotePtrCh0                                  ; 3     Store the new note pointer

        ldy #0 
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipResetPtrTrk0                          

        ; lda #<Track0Builder                             
        ; sta NotePtrCh0                                  
        
        dec NotePtrCh0
        dec NotePtrCh0
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
SkipResetPtrTrk0
        tay
        lda NoteDurations,y
        sta DurationLeftNoteA


        lda NotePtrCh1                                  ; 3     Load the Note Pointer to A
        clc                                             ; 2     Clear the carry 
        adc #2                                          ; 2     Add 2 to move the Note pointer to the next note
        sta NotePtrCh1                                  ; 3     Store the new note pointer

        ldy #0 
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipResetPtrTrk1                          

        ; lda #<Track1Builder                             
        ; sta NotePtrCh1                                  
        
        dec NotePtrCh1
        dec NotePtrCh1
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
SkipResetPtrTrk1
        tay
        lda NoteDurations,y
        sta DurationLeftNoteB
AdvanceDone
        jmp SelectionSet
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; Decrement Pointers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SkipPtrRight
        lda #P0_JOYSTICK_DOWN            
        bit SWCHA
        beq PtrRightDec
        jmp SkipDecPtrLeft
PtrRightDec
        ; dec TestCounter
        ; lda #0
        ; sta LetterBuffer

        lda NotePtrCh0
        cmp #<Track0Builder
        beq SkipAdd0
        clc
        adc #$FE
SkipAdd0
        sta LineTemp

        lda NotePtrCh1
        cmp #<Track1Builder
        beq SkipAdd1
        clc
        adc #$FE
SkipAdd1
        sta YTemp

        lda #<Track0Builder                             
        sta NotePtrCh0 

        lda #<Track1Builder                             
        sta NotePtrCh1

        lda #0
        sta DurationLeftNoteA
        sta DurationLeftNoteB

DecPointerLoop
;         lda TestCounter
;         cmp LetterBuffer
;         bne SkipFin
;         jmp DecFin
; SkipFin
;         inc LetterBuffer


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Something here needs to be re-worked to make decremenmt work when Track A is
; empty or Track B had the greater amount of notes
        lda NotePtrCh0
        cmp LineTemp
        bne SkipDecCheck0
        lda NotePtrCh1
        cmp YTemp
        bmi SkipDecCheck0
        jmp DecFin
SkipDecCheck0

        lda NotePtrCh1
        cmp YTemp
        bne SkipDecCheck1
        lda NotePtrCh0
        cmp LineTemp
        bmi SkipDecCheck1
        jmp DecFin
SkipDecCheck1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda DurationLeftNoteA
        bne SkipDecDurationACheck

        ldy #0 
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipRstPtrTrackZero                          

        lda #<Track0Builder                             
        sta NotePtrCh0                                  
        
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
SkipRstPtrTrackZero
        tay
        lda NoteDurations,y
        sta DurationLeftNoteA

SkipDecDurationACheck
        
        lda DurationLeftNoteB
        bne SkipDecDurationBCheck

        ldy #0 
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipRstPtrTrackOne                          

        lda #<Track1Builder
        sta NotePtrCh1
        
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
SkipRstPtrTrackOne
        tay
        lda NoteDurations,y
        sta DurationLeftNoteB

SkipDecDurationBCheck

SkipDecDurationCheck
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Check to see which duration is longer
;         lda NotePtrCh0
;         cmp LineTemp
;         bne SkipDecPointerA
;         jmp DecPointerB
; SkipDecPointerA

;         lda NotePtrCh1
;         cmp YTemp
;         bne SkipDecPointerB
;         jmp DecPointerA
; SkipDecPointerB

        lda DurationLeftNoteA
        cmp DurationLeftNoteB
        bne SkipDecJump
        jmp DecBothPointers
SkipDecJump

        lda DurationLeftNoteA
        beq DecPointerB

        lda DurationLeftNoteB
        beq DecPointerA

        lda DurationLeftNoteA
        cmp DurationLeftNoteB
        bpl DecPointerB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DecPointerA
        ;Advance Pointer for Track0
        lda NotePtrCh0                                  
        clc                                             
        adc #2                                          
        sta NotePtrCh0                                  

        ; Subtract the Duration of NoteA from NoteB
        lda DurationLeftNoteB
        beq SkipDecSubtractA
        sec 
        sbc DurationLeftNoteA
        sta DurationLeftNoteB
SkipDecSubtractA
        ; Get the new Note Duration Left for Track0
        ldy #0 
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipRstPtrTrack0                          

        lda #<Track0Builder                             
        sta NotePtrCh0                                  
        
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
SkipRstPtrTrack0
        tay
        lda NoteDurations,y
        sta DurationLeftNoteA

        jmp DecDone

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DecPointerB

        ;Advance Pointer for Track1
        lda NotePtrCh1                                  
        clc                                             
        adc #2                                          
        sta NotePtrCh1                                  

        ; Subtract the Duration of NoteB from NoteA
        lda DurationLeftNoteA
        beq SkipDecSubtractB
        sec 
        sbc DurationLeftNoteB
        sta DurationLeftNoteA
SkipDecSubtractB
        ; Get the new Note Duration Left for Track1
        ldy #0 
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipRstPtrTrack1                          

        lda #<Track1Builder                             
        sta NotePtrCh1                                  
        
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
SkipRstPtrTrack1
        tay
        lda NoteDurations,y
        sta DurationLeftNoteB

        jmp DecDone
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DecBothPointers
        lda NotePtrCh0                                  ; 3     Load the Note Pointer to A
        clc                                             ; 2     Clear the carry 
        adc #2                                          ; 2     Add 4 to move the Note pointer to the next note
        sta NotePtrCh0                                  ; 3     Store the new note pointer

        ldy #0 
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipRstPtrTrk0                          

        lda #<Track0Builder                             
        sta NotePtrCh0                                  
        
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
SkipRstPtrTrk0
        tay
        lda NoteDurations,y
        sta DurationLeftNoteA

;         lda NotePtrCh0
;         cmp LineTemp
;         bne SkipDecCheck20
;         cmp YTemp
;         bpl SkipDecCheck20
;         jmp DecFin
; SkipDecCheck20

;         lda NotePtrCh1
;         cmp YTemp
;         bne SkipDecCheck21
;         cmp LineTemp
;         bpl SkipDecCheck21
;         jmp DecFin
; SkipDecCheck21

        ; lda DurationLeftNoteB
        ; beq DecDone

        lda NotePtrCh1                                  ; 3     Load the Note Pointer to A
        clc                                             ; 2     Clear the carry 
        adc #2                                          ; 2     Add 2 to move the Note pointer to the next note
        sta NotePtrCh1                                  ; 3     Store the new note pointer

        ldy #0 
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipRstPtrTrk1                          

        lda #<Track1Builder                             
        sta NotePtrCh1                                  
        
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
SkipRstPtrTrk1
        tay
        lda NoteDurations,y
        sta DurationLeftNoteB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DecDone
        ; inc LetterBuffer
        ; lda TestCounter
        ; cmp LetterBuffer
        ; beq DecFin
        jmp DecPointerLoop
DecFin
        jmp SelectionSet
SkipDecPtrLeft

Selection9
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
        and #FREQUENCY_MASK
        sta YTemp
        lda AudFrqDur
        and #DURATION_MASK
        sta AudFrqDur
        asl
        asl
        clc
        adc AudFrqDur
        clc
        adc DurGfxPtr
        sta DurGfxPtr
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
        and #CONTROL_MASK
        sta YTemp
        lda AudVolCtl
        and #VOLUME_MASK
        lsr
        lsr
        lsr
        lsr
        sta AudVolCtl
        asl
        asl
        clc
        adc AudVolCtl
        clc
        adc VolGfxPtr
        sta VolGfxPtr
        lda LineTemp
        sta AudVolCtl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; Build Audio Frequency Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda #<(Zero)
        sta FrqCntGfxPtr

        lda #>(Zero)
        sta FrqCntGfxPtr+1  
 
        lda AudFrqDur
        sta LineTemp
        and #DURATION_MASK
        sta YTemp
        lda AudFrqDur
        and #FREQUENCY_MASK
        lsr
        lsr
        lsr
        sta AudFrqDur
        asl
        asl
        clc
        adc AudFrqDur
        clc
        adc FrqCntGfxPtr
        sta FrqCntGfxPtr
        lda LineTemp
        sta AudFrqDur


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Build Audio Control Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #<(RSZero)
        sta CtlChnlGfxPtr

        lda #>(RSZero)
        sta CtlChnlGfxPtr+1  

        lda AudVolCtl
        sta LineTemp
        and #VOLUME_MASK
        sta YTemp
        lda AudVolCtl
        and #CONTROL_MASK
        sta AudVolCtl
        asl
        asl
        clc
        adc AudVolCtl

        clc
        adc CtlChnlGfxPtr
        sta CtlChnlGfxPtr
        lda LineTemp
        sta AudVolCtl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Build Audio Channel Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; lda #<(Zero)
        ; sta ChannelGfxPtr

        ; lda #>(Zero)
        ; sta ChannelGfxPtr+1  

        ; lda AudCntChnl
        ; asl
        ; asl
        ; clc
        ; adc AudCntChnl

        ; clc
        ; adc ChannelGfxPtr
        ; sta ChannelGfxPtr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Note Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda AudCntChnl
        and #1
        tax
        lda #PLAY_NOTE_FLAG
        bit FlagsSelection
        bne SkipPlayNote
        lda AudFrqDur
        and #DURATION_MASK
        tay
        lda NoteDurations,y
        cmp FrameCtrTrk0,x
        beq TurnOffNote

        lda AudVolCtl
        and #VOLUME_MASK
        lsr
        lsr
        lsr
        lsr
        sta AUDV0,x

        lda AudFrqDur
        and #FREQUENCY_MASK
        lsr
        lsr
        lsr
        sta AUDF0,x

        lda AudVolCtl
        and #CONTROL_MASK
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
        lda AudCntChnl
        and #1
        tax
        lda #0
        sta AUDV0,x
        sta AUDF0,x
        sta AUDC0,x
        sta FrameCtrTrk0,x
        lda FlagsSelection
        and #PLAY_NOTE_FLAG_MASK
        eor #PLAY_NOTE_FLAG
        sta FlagsSelection

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

        lda #ADD_NOTE_FLAG
        bit FlagsSelection
        beq SkipAddNote

        lda AudCntChnl
        and #1
        tax
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
        
        lda Track1BuilderPtr
        clc
        adc #2
        sta Track1BuilderPtr

AddNoteChannel0
        lda FlagsSelection
        and #%11011111
        sta FlagsSelection
SkipAddNote
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Remove Note ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda #REMOVE_NOTE_FLAG
        bit FlagsSelection
        beq SkipRemoveNote

        lda AudCntChnl
        and #1
        tax
        cpx #1
        beq RemNoteChannel1

        lda Track0BuilderPtr
        cmp #<Track0Builder
        beq SkipRemoveNote
        
        lda #0

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
        lda FlagsSelection
        and #%10111111
        sta FlagsSelection
SkipRemoveNote
        

        lda #PLAY_TRACK_FLAG
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
        lda (NotePtrCh0),y                              ; 5     Load first note combo to A
        and #DURATION_MASK                              ; 2     Mask so we only have the note duration
        tay                                             ; 2     Make A the y index
        lda NoteDurations,y                             ; 4     Get the actual duration based on the duration setting
        cmp FrameCtrTrk0                                ; 3     See if it equals the Frame Counter
        bne NextRamNote                                 ; 2/3   If so move the NotePointer to the next note

        lda NotePtrCh0                                  ; 3     Load the Note Pointer to A
        clc                                             ; 2     Clear the carry 
        adc #2                                          ; 2     Add 4 to move the Note pointer to the next note
        sta NotePtrCh0                                  ; 3     Store the new note pointer

        lda #0                                          ; 2     Load Zero to
        sta FrameCtrTrk0                                ; 3     Reset the Frame counter
NextRamNote
        ldy #0                                          ; 2     Initialize Y-Index to 0
        lda (NotePtrCh0),y                              ; 5     Load first note combo to A
        and #DURATION_MASK                              ; 2     Mask so we only have the note duration
        cmp #0                                          ; 2     See if the notes duration equals 0
        bne SkipResetRamTrack0                          ; 2/3   If so go back to the beginning of the track

        lda #<Track0Builder                             ; 4     Store the low byte of the track to 
        sta NotePtrCh0                                  ; 3     the Note Pointer
SkipResetRamTrack0

        lda (NotePtrCh0),y                              ; 5     Load first note combo to A
        and #FREQUENCY_MASK                             ; 2     Mask so we only have the note frequency
        lsr                                             ; 2     Shift right to get the correct placement
        lsr                                             ; 2     Shift right to get the correct placement
        lsr                                             ; 2     Shift right to get the correct placement
        sta AUDF0                                       ; 3     and set the Note Frequency
        iny                                             ; 2     Increment Y (Y=1) to point to the Note Volume
        lda (NotePtrCh0),y                              ; 5     Load second note combo to A
        and #VOLUME_MASK                                ; 2     Mask so we only have the note Volume
        lsr                                             ; 2     Shift right to get the correct placement
        lsr                                             ; 2     Shift right to get the correct placement
        lsr                                             ; 2     Shift right to get the correct placement
        lsr                                             ; 2     Shift right to get the correct placement
        sta AUDV0                                       ; 3     and set the Note Volume
        lda (NotePtrCh0),y                              ; 5     Load second note combo to A
        and #CONTROL_MASK                               ; 2     Mask so we only have the note Control
        sta AUDC0                                       ; 3     and set the Note Control
        inc FrameCtrTrk0                                ; 5     Increment the Frame Counter to compare duration later


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0                                          ; 2     Initialize Y-Index to 0
        lda (NotePtrCh1),y                              ; 5     Load first note duration to A
        and #DURATION_MASK
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
        ldy #0 
        lda (NotePtrCh1),y                              ; 5     Load first note duration to A
        cmp #0                                          ; 2     See if the notes duration equals 255
        bne SkipResetRamTrack1                          ; 2/3   If so go back to the beginning of the track

        lda #<Track1Builder                             ; 4     Store the low byte of the track to 
        sta NotePtrCh1                                  ; 3     the Note Pointer
SkipResetRamTrack1

        lda (NotePtrCh1),y                              ; 5     Load Volume to A
        and #FREQUENCY_MASK
        lsr
        lsr
        lsr
        sta AUDF1                                       ; 3     and set the Note Volume
        iny                                             ; 2     Increment Y (Y=1) to point to the Note Frequency
        lda (NotePtrCh1),y                              ; 5     Load Frequency to A
        and #VOLUME_MASK
        lsr
        lsr
        lsr
        lsr
        sta AUDV1                                       ; 3     and set the Note Frequency
        lda (NotePtrCh1),y                              ; 5     Load Control to A
        and #CONTROL_MASK
        sta AUDC1                                       ; 3     and set the Note Control
        inc FrameCtrTrk1                                ; 5     Increment the Frame Counter to duration compare later

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



LoadPauseAllButton
        lda #<PauseButton
        sta PlayAllButtonMaskPtr
        lda #>PauseButton
        sta PlayAllButtonMaskPtr+1

        jmp SkipResetPlayAllButton

SkipRamMusicPlayer
        lda #PLAY_NOTE_FLAG
        bit FlagsSelection
        beq SkipResetAud

LoadPlayAllButton
        lda #<PlayButton
        sta PlayAllButtonMaskPtr
        lda #>PlayButton
        sta PlayAllButtonMaskPtr+1


        lda FlagsSelection
        and #SELECTION_MASK 
        cmp #9
        beq SkipResetTrack
        lda #<Track0Builder                              ; 4     Store the low byte of the track to 
        sta NotePtrCh0                                   ; 3     the Note Pointer
        lda #<Track1Builder                              ; 4     Store the low byte of the track to 
        sta NotePtrCh1
        lda #0
        sta DurationLeftNoteA
        sta DurationLeftNoteB
SkipResetTrack

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

        lda AudCntChnl
        and #1
        sta AudCntChnl
        bne LoadChannel1Cnt
        lda Track0Builder+#TRACKSIZE
        sec
        sbc Track0BuilderPtr
        ;lsr
        and #%11111110
        ora AudCntChnl
        sta AudCntChnl
        jmp LoadChannel0Cnt
LoadChannel1Cnt
        lda Track1Builder+#TRACKSIZE
        sec
        sbc Track1BuilderPtr
        ;lsr
        and #%11111110
        ora AudCntChnl
        sta AudCntChnl
LoadChannel0Cnt

        lda DebounceCtr
        beq SkipDecDebounceCtr_Bank0
        dec DebounceCtr
SkipDecDebounceCtr_Bank0
        

        lda SWCHB
        and #%00000010
        ora DebounceCtr
        bne SkipSwitchToBank1
        ; Put game select logic code here

        jmp SwitchToBank1
SkipSwitchToBank1

; ; Reset Player positions for title
;         ldx #0
;         lda #TITLE_H_POS
;         jsr CalcXPos
;         sta WSYNC
;         sta HMOVE
;         SLEEP 24
;         sta HMCLR

;         ldx #1
;         lda #TITLE_H_POS+8
;         jsr CalcXPos
;         sta WSYNC
;         sta HMOVE
;         SLEEP 24
;         sta HMCLR

;         lda #THREE_COPIES_CLOSE
;         sta NUSIZ0
;         sta NUSIZ1

;         lda #1
;         sta VDELP0
;         sta VDELP1


; Reset Backgruond,Audio,Collisions,Note Flags
        lda #0
        sta COLUBK
        sta CXCLR  
        ldy #26                                         ; 2

        lda FlagsSelection
        and #%10111111
        sta FlagsSelection
        
        lda FlagsSelection
        and #%11011111
        sta FlagsSelection
WaitLoop
        lda INTIM
        bne WaitLoop
; overscan
        ldx #6                                          ; 2
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

ZeroChnl   .byte  #%11100
           .byte  #%10100
           .byte  #%10100
           .byte  #%10100
           .byte  #%11100

OneChnl    .byte  #%11000
           .byte  #%01000
           .byte  #%01000
           .byte  #%01000
           .byte  #%11100

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

PlayButton .byte  #%00100000
           .byte  #%01100000
           .byte  #%11100000
           .byte  #%01100000
           .byte  #%00100000
           .byte  #0

TopPlayButton           .byte  #%00100000
                        .byte  #%00100000
                        .byte  #%01100000
                        .byte  #%01100000
                        .byte  #%11100000
                        .byte  #0

BottomPlayButton        .byte  #%11100000
                        .byte  #%01100000
                        .byte  #%01100000
                        .byte  #%00100000
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
           .byte  #%11111000
           .byte  #%00000000
           .byte  #%00000000

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

RSOneZero  .byte  #%11100110
           .byte  #%10100100
           .byte  #%10100100
           .byte  #%10100100
           .byte  #%11101110

RSOneOne   .byte  #%01100110
           .byte  #%01000100
           .byte  #%01000100
           .byte  #%01000100
           .byte  #%11101110

RSOneTwo   .byte  #%11100110
           .byte  #%10000100
           .byte  #%11100100
           .byte  #%00100100
           .byte  #%11101110

RSOneThree .byte  #%11100110
           .byte  #%10000100
           .byte  #%11100100
           .byte  #%10000100
           .byte  #%11101110

RSOneFour  .byte  #%10100110
           .byte  #%10100100
           .byte  #%11100100
           .byte  #%10000100
           .byte  #%10001110

RSOneFive  .byte  #%11100110
           .byte  #%00100100
           .byte  #%11100100
           .byte  #%10000100
           .byte  #%11101110

RSOneSix   .byte  #%11100110
           .byte  #%00100100
           .byte  #%11100100
           .byte  #%10100100
           .byte  #%11101110

RSOneSeven .byte  #%11100110
           .byte  #%10000100
           .byte  #%10000100
           .byte  #%10000100
           .byte  #%10001110

RSOneEight .byte  #%11100110
           .byte  #%10100100
           .byte  #%11100100
           .byte  #%10100100
           .byte  #%11101110

RSOneNine  .byte  #%11100110
           .byte  #%10100100
           .byte  #%11100100
           .byte  #%10000100
           .byte  #%11101110

RSOneA     .byte  #%11100110
           .byte  #%10100100
           .byte  #%11100100
           .byte  #%10100100
           .byte  #%10101110

RSOneB     .byte  #%01100110
           .byte  #%10100100
           .byte  #%01100100
           .byte  #%10100100
           .byte  #%01101110

RSOneC     .byte  #%11100110
           .byte  #%00100100
           .byte  #%00100100
           .byte  #%00100100
           .byte  #%11101110

RSOneD     .byte  #%01100110
           .byte  #%10100100
           .byte  #%10100100
           .byte  #%10100100
           .byte  #%01101110

RSOneE     .byte  #%11100110
           .byte  #%00100100
           .byte  #%11100100
           .byte  #%00100100
           .byte  #%11101110

RSOneF     .byte  #%11100110
           .byte  #%00100100
           .byte  #%11100100
           .byte  #%00100100
           .byte  #%00101110

RSTwoZero  .byte  #%11101110
           .byte  #%10101000
           .byte  #%10101110
           .byte  #%10100010
           .byte  #%11101110

RSTwoOne   .byte  #%01101110
           .byte  #%01001000
           .byte  #%01001110
           .byte  #%01000010
           .byte  #%11101110

RSTwoTwo   .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110

RSTwoThree .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%10000010
           .byte  #%11101110

RSTwoFour  .byte  #%10101110
           .byte  #%10101000
           .byte  #%11101110
           .byte  #%10000010
           .byte  #%10001110

RSTwoFive  .byte  #%11101110
           .byte  #%00101000
           .byte  #%11101110
           .byte  #%10000010
           .byte  #%11101110

RSTwoSix   .byte  #%11101110
           .byte  #%00101000
           .byte  #%11101110
           .byte  #%10100010
           .byte  #%11101110

RSTwoSeven .byte  #%11101110
           .byte  #%10001000
           .byte  #%10001110
           .byte  #%10000010
           .byte  #%10001110

RSTwoEight .byte  #%11101110
           .byte  #%10101000
           .byte  #%11101110
           .byte  #%10100010
           .byte  #%11101110

RSTwoNine  .byte  #%11101110
           .byte  #%10101000
           .byte  #%11101110
           .byte  #%10000010
           .byte  #%11101110

RSTwoA     .byte  #%11101110
           .byte  #%10101000
           .byte  #%11101110
           .byte  #%10100010
           .byte  #%10101110

RSTwoB     .byte  #%01101110
           .byte  #%10101000
           .byte  #%01101110
           .byte  #%10100010
           .byte  #%01101110

RSTwoC     .byte  #%11101110
           .byte  #%00101000
           .byte  #%00101110
           .byte  #%00100010
           .byte  #%11101110

RSTwoD     .byte  #%01101110
           .byte  #%10101000
           .byte  #%10101110
           .byte  #%10100010
           .byte  #%01101110

RSTwoE     .byte  #%11101110
           .byte  #%00101000
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110

RSTwoF     .byte  #%11101110
           .byte  #%00101000
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%00101110

RSThrZero  .byte  #%11101110
           .byte  #%10101000
           .byte  #%10101100
           .byte  #%10101000
           .byte  #%11101110

        align 256
RSDZero      .byte  #%11100000
           .byte  #%10100000
           .byte  #%10100000
           .byte  #%10100000
           .byte  #%11100000

RSDOne       .byte  #%01100000
           .byte  #%01000000
           .byte  #%01000000
           .byte  #%01000000
           .byte  #%11100000

RSDTwo       .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000
           .byte  #%00100000
           .byte  #%11100000

RSDThree     .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000

RSDFour      .byte  #%10100000
           .byte  #%10100000
           .byte  #%11100000
           .byte  #%10000000
           .byte  #%10000000

RSDFive      .byte  #%11100000
           .byte  #%00100000
           .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000

RSDSix       .byte  #%11100000
           .byte  #%00100000
           .byte  #%11100000
           .byte  #%10100000
           .byte  #%11100000

RSDSeven     .byte  #%11100000
           .byte  #%10000000
           .byte  #%10000000
           .byte  #%10000000
           .byte  #%10000000

RSDEight     .byte  #%11100000
           .byte  #%10100000
           .byte  #%11100000
           .byte  #%10100000
           .byte  #%11100000

RSDNine      .byte  #%11100000
           .byte  #%10100000
           .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000


RSDOneZero  .byte  #%11100110
           .byte  #%10100100
           .byte  #%10100100
           .byte  #%10100100
           .byte  #%11101110

RSDOneOne   .byte  #%01100110
           .byte  #%01000100
           .byte  #%01000100
           .byte  #%01000100
           .byte  #%11101110

RSDOneTwo   .byte  #%11100110
           .byte  #%10000100
           .byte  #%11100100
           .byte  #%00100100
           .byte  #%11101110

RSDOneThree .byte  #%11100110
           .byte  #%10000100
           .byte  #%11100100
           .byte  #%10000100
           .byte  #%11101110

RSDOneFour  .byte  #%10100110
           .byte  #%10100100
           .byte  #%11100100
           .byte  #%10000100
           .byte  #%10001110

RSDOneFive  .byte  #%11100110
           .byte  #%00100100
           .byte  #%11100100
           .byte  #%10000100
           .byte  #%11101110

RSDOneSix   .byte  #%11100110
           .byte  #%00100100
           .byte  #%11100100
           .byte  #%10100100
           .byte  #%11101110

RSDOneSeven .byte  #%11100110
           .byte  #%10000100
           .byte  #%10000100
           .byte  #%10000100
           .byte  #%10001110

RSDOneEight .byte  #%11100110
           .byte  #%10100100
           .byte  #%11100100
           .byte  #%10100100
           .byte  #%11101110

RSDOneNine  .byte  #%11100110
           .byte  #%10100100
           .byte  #%11100100
           .byte  #%10000100
           .byte  #%11101110

RSDTwoZero  .byte  #%11101110
           .byte  #%10101000
           .byte  #%10101110
           .byte  #%10100010
           .byte  #%11101110

RSDTwoOne   .byte  #%01101110
           .byte  #%01001000
           .byte  #%01001110
           .byte  #%01000010
           .byte  #%11101110

RSDTwoTwo   .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110

RSDTwoThree .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%10000010
           .byte  #%11101110

RSDTwoFour  .byte  #%10101110
           .byte  #%10101000
           .byte  #%11101110
           .byte  #%10000010
           .byte  #%10001110

RSDTwoFive  .byte  #%11101110
           .byte  #%00101000
           .byte  #%11101110
           .byte  #%10000010
           .byte  #%11101110

RSDTwoSix   .byte  #%11101110
           .byte  #%00101000
           .byte  #%11101110
           .byte  #%10100010
           .byte  #%11101110

RSDTwoSeven .byte  #%11101110
           .byte  #%10001000
           .byte  #%10001110
           .byte  #%10000010
           .byte  #%10001110

RSDTwoEight .byte  #%11101110
           .byte  #%10101000
           .byte  #%11101110
           .byte  #%10100010
           .byte  #%11101110

RSDTwoNine  .byte  #%11101110
           .byte  #%10101000
           .byte  #%11101110
           .byte  #%10000010
           .byte  #%11101110

RSDThrZero  .byte  #%11101110
           .byte  #%10101000
           .byte  #%10101100
           .byte  #%10101000
           .byte  #%11101110



        echo "----",([$FFFC-.]d), "bytes free in Bank 0"
;-------------------------------------------------------------------------------
        ORG $1FFA
        RORG $FFFA
InterruptVectorsBank1
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
ENDBank1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ORG $2000
        RORG $F000

SwitchToBank0
        lda $1FF8

Reset
        ldx #0
        txa
Clear
        dex
        txs
        pha
        bne Clear
        cld

        lda #30
        sta DebounceCtr

_StartOfFrame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start VBLANK Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #0
        sta VBLANK

; 3 VSYNC Lines
        lda #2
        sta VSYNC ; Turn on VSYNC

        sta WSYNC
        sta WSYNC
        sta WSYNC
        lda #0
        sta VSYNC ; Turn off VSYNC

; 37 VBLANK lines
        ldx #37                                         ; 2
VerticalBlank2
        sta WSYNC                                       ; 3
        dex                                             ; 2
        bne VerticalBlank2                               ; 2/3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End VBLANK Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldx #192
Screen
        stx COLUBK
        sta WSYNC
        dex
        bne Screen

        lda DebounceCtr
        beq SkipDecDebounceCtr_Bank1
        dec DebounceCtr
SkipDecDebounceCtr_Bank1

        lda SWCHB
        and #%00000010
        ora DebounceCtr
        bne SkipSwitchToBank0
        ; Put game select logic code here
        
        jmp SwitchToBank0
SkipSwitchToBank0

        ldx #30
Overscan2
        sta WSYNC
        dex
        bne Overscan2
        jmp _StartOfFrame



        echo "----",([$FFFC-.]d), "bytes free in Bank 1"
;-------------------------------------------------------------------------------
        ORG $2FFA
        RORG $FFFA
InterruptVectorsBank2
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
ENDBank2