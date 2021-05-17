        processor 6502
        include includes/vcs.h
        include includes/macro.h

; TODO: Add Labels under controls to display usage

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
Overlay                 ds 128

        ORG Overlay
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Audio Working Values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AudVolCtl               ds 1                    ; 0000XXXX - Volume | XXXX0000 - Control/Timbre
AudFrqDur               ds 1                    ; 00000XXX - Frquency | XXXXX000 - Duration
AudCntChnl              ds 1                    ; XXXXXXX0 - Channel | XX00000X - Note Count Left (Max 31)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Flags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FlagsSelection          ds 1                    ; 0-3 Current Selection (#0-#9) - (#11-#15 Not Used)
                                                ; 4 - Play note flag - 0 plays note
                                                ; 5 - Add note flag - 1 adds note
                                                ; 6 - Remove note flag - 1 removes note
                                                ; 7 - Play track flag - 1 plays tracks
                                                ; (#10) - Play Track Note Flag Combined Selection #9
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Counters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FrameCtrTrk0            ds 1                    ; Used to count number of Frames passed since starting a note - Track 0
FrameCtrTrk1            ds 1                    ; Used to count number of Frames passed since starting a note - Track 1
DebounceCtr             ds 1                    ; XXXX0000 - Top 4 bits not used - Used to count down debounce
DurRemainTrk0           ds 1                    ; Used to store how many frames are left when inc or dec notes -Track 0
DurRemainTrk1           ds 1                    ; Used to store how many frames are left when inc or dec notes -Track 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Rom Pointers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PlayButtonMaskPtr       ds 2                    ; Pointer to be used for Play Button Graphics on each row
VolGfxPtr               ds 2                    ; Pointer to be used for Volume Graphics on each row
DurGfxPtr               ds 2                    ; Pointer to be used for Duration Graphics on each row
FrqCntGfxPtr            ds 2                    ; Pointer to be used for Frequency Graphics on each row
CtlChnlGfxPtr           ds 2                    ; Pointer to be used for Channel and Control Graphics on each row

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ram Pointers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Track0BuilderPtr        ds 1                    ; Pointer to the next note to add in the Track0 Array
YTemp                   ds 1                    ; This will get zeroed after use so that the TrackBuilderPointer load-
Track1BuilderPtr        ds 1                    ; Pointer to the next note to add in the Track1 Array
LineTemp                ds 1                    ; -will seem like it has 2 bytes

NotePtrCh0              ds 2                    ; Pointer to the note to play in the Track0 Array
;Space Available
NotePtrCh1              ds 1                    ; Pointer to the note to play in the Track1 Array
LetterBuffer            ds 1                    ; Temp variable
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ram Music Tracks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Track0Builder           ds #TRACKSIZE+1         ; Array Memory Allocation to store the bytes(notes) saved to Track 0
Track1Builder           ds #TRACKSIZE+1         ; Array Memory Allocation to store the bytes(notes) saved to Track 1
                                                ; Plus 1 extra byte to have a control byte at the end of each Track

        echo "Ram Total Bank0:"
        echo "----",([* - $80]d) , (* - $80) ,"bytes of RAM Used for Bank 0"
        echo "----",([$100 - *]d) , ($100 - *) , "bytes of RAM left for Bank 0"


        
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
        lda #30                                 ; Load the debounce counter. This is useful when switching game
        sta DebounceCtr                         ; modes to prevent switching repeatedly and too quickly.

        ldx #0                                  ; Set Player 0 Position
        lda #TITLE_H_POS
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #1                                  ; Set Player 1 Position
        lda #TITLE_H_POS+8
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        lda #TITLE_COLOR                        ; Set the player colors for the title
        sta COLUP0
        sta COLUP1

        lda #1                                  ; Set Playfield to be reflected
        sta CTRLPF       

        lda #THREE_COPIES_CLOSE                 ; Set Player to be three copies close
        sta NUSIZ0
        sta NUSIZ1

        lda #1                                  ; Enable Vertical delay for both players
        sta VDELP0
        sta VDELP1
        sta VDELBL

        lda #<Track0Builder                     ; Initialize the NotePtr0 to the begining of the notes array
        sta NotePtrCh0

        lda #<Track1Builder                     ; Initialize the NotePtr1 to the begining of the notes array
        sta NotePtrCh1

        lda #<Track0Builder                     ; Initialize the BuilderPtr0 to the begining of the notes array
        sta Track0BuilderPtr

        lda #<Track1Builder                     ; Initialize the BuilderPtr0 to the begining of the notes array
        sta Track1BuilderPtr

        lda AudFrqDur                           ; Set Frequency to 1 to initialize since 0 is the control value
        and #FREQUENCY_MASK
        ora #00000001
        sta AudFrqDur

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Console Initialization ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


StartOfFrame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start VBLANK Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
VerticalBlank
        sta WSYNC                                       ; 3
        dex                                             ; 2
        bne VerticalBlank                               ; 2/3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End VBLANK Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start 192 Lines of Viewable Picture ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
; Spacing between Title Text and the Note Values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TopBuffer
        inx                                             ; 2     59
        cpx #20                                         ; 2     61
        sta WSYNC                                       ; 3     64
        bne TopBuffer                                   ; 2/3   2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load the correct graphic for the play button or pause button depending on whether or not a note is being played
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #PLAY_NOTE_FLAG
        bit FlagsSelection
        beq SkipSetPlayNote

        lda #<PlayButton
        sta PlayButtonMaskPtr
        lda #>PlayButton
        sta PlayButtonMaskPtr+1
        jmp SkipSetPauseNote
SkipSetPlayNote
        lda #<PauseButton
        sta PlayButtonMaskPtr
        lda #>PauseButton
        sta PlayButtonMaskPtr+1
SkipSetPauseNote

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
        lsr                                     ; 2     5       Divide by 2 to get index twice for octuple height
        tay                                     ; 2     7       Transfer A to Y so we can index off Y
        
        lda (PlayButtonMaskPtr),y               ; 5     12      Get the Score From our Play Button Mask Array
        sta PF0                                 ; 3     15      Store the value to PF0

        lda (DurGfxPtr),y                       ; 5     20      Get the Score From our Duration Gfx Array
        asl                                     ; 2     22
        asl                                     ; 2     24
        sta PF1                                 ; 3     27      Store the value to PF1
        
        lda (VolGfxPtr),y                       ; 5     32      Get the Score From our Volume Gfx Array
        asl                                     ; 2     34
        sta PF2                                 ; 3     37      Store the value to PF2

        nop                                     ; 2     39      Waste 2 cycles to line up the next Pf draw

        lda (FrqCntGfxPtr),y                    ; 5     44      Get the Score From our Frequency Gfx Array
        sta PF2                                 ; 3     47      Store the value to PF2
        
        lda (CtlChnlGfxPtr),y                   ; 5     52      Get the Score From our Control Gfx Array
        sta PF1                                 ; 3     55      Store the value to PF1        

        inx                                     ; 2     57      Increment our line number
        
        ldy #0                                  ; 2     59      Reset and clear the playfield
        txa                                     ; 2     61      Transfer the line number in preparation for the next line
        sbc #19                                 ; 2     63      Subtract #19 since the carry is cleared above
        lsr                                     ; 2     65      Divide by 2 to get index twice for double height
        sty PF0                                 ; 3     68      Reset and clear the playfield
        lsr                                     ; 2     70      Divide by 2 to get index twice for quadruple height
        sty.w PF1                               ; 4     74      Reset and clear the playfield

        cpx #60                                 ; 2     76      Have we reached line #60   
        bne NoteRow                             ; 2/3   2/3     No then repeat

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Note Values Selection Row
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0
        sty PF2                                 ; 3     65      Reset and clear the playfield
        inx                                     ; 2     6
        lda #CONTROLS_COLOR
        sta COLUPF
        sta WSYNC                               ; 3     3
        SLEEP 3                                 ; 3     3
        
NoteSelection
        stx LineTemp
        lda FlagsSelection                      ; 3
        and #SELECTION_MASK                     ; 2

        bne SkipSelectPlayButton                ; 2/3
        ldx #%11100000                          ; 2
        stx PF0                                 ; 3
SkipSelectPlayButton

        sty PF1
        cmp #1                                  ; 2
        bne SkipSelectDuration                  ; 2/3
        ldx #%01111111                          ; 2
        stx PF1                                 ; 3
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
        
        sty PF0                                 ; 3     67
        sty PF2                                 ; 3     67

        ldx LineTemp
        inx                                     ; 2     4
        cpx #68                                 ; 2     6
        sta WSYNC                               ; 3     9
        bne NoteSelection                       ; 2/3   2/3

        lda #0                                  ; 2     64
        sta PF1                                 ; 3     67
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

        lda #PLAY_TRACK_FLAG
        bit FlagsSelection
        bne SkipSetPlayTrack

        lda #<PlayButton
        sta PlayButtonMaskPtr
        lda #>PlayButton
        sta PlayButtonMaskPtr+1
        jmp SkipSetPauseTrack
SkipSetPlayTrack
        lda #<PauseButton
        sta PlayButtonMaskPtr
        lda #>PauseButton
        sta PlayButtonMaskPtr+1
SkipSetPauseTrack
        jmp SkipBuffer2

        REPEAT 15
        nop
        REPEND
SkipBuffer2

Spacer
        inx                                             ; 2     4
        cpx #78                                         ; 2     6
        sta WSYNC                                       ; 3     9
        bne Spacer                                      ; 2/3   2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Track Controls Row 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ControlRow
        txa                                             ; 2     5
        sbc #77                                         ; 2     7
        lsr                                             ; 2     9       Divide by 2 to get index twice for double height
        lsr                                             ; 2     11      Divide by 2 to get index twice for double height
        lsr                                             ; 2     13      Divide by 2 to get index twice for double height
        tay                                             ; 2     15      Transfer A to Y so we can index off Y
        
        lda (PlayButtonMaskPtr),y                       ; 5     20      Get the Score From our Player 0 Score Array
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
        cpx #118                                        ; 2     65
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
        inx                                             ; 2
        sta WSYNC                                       ; 3
        SLEEP 3                                         ; 3

ControlSelection
        stx LineTemp
        lda FlagsSelection                              ; 3
        and #SELECTION_MASK                             ; 2

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

        SLEEP 10

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
        cpx #125                                        ; 2     6
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
        lda FlagsSelection
        and #SELECTION_MASK
        cmp #10
        beq SkipSetPlayTracks

        lda #<PlayButton
        sta PlayButtonMaskPtr
        lda #>PlayButton
        sta PlayButtonMaskPtr+1
        jmp SkipSetPauseTracks
SkipSetPlayTracks
        lda #<PauseButton
        sta PlayButtonMaskPtr
        lda #>PauseButton
        sta PlayButtonMaskPtr+1
SkipSetPauseTracks
        inx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Track0Spacer
        inx                                     ; 2     4
        cpx #135                                ; 2     6
        sta WSYNC                               ; 3     9
        bne Track0Spacer                        ; 2/3   2/3
        inx
        inx                                     ; 2     4
        txa                                     ; 2     6
        sbc #134                                ; 2     8
        nop
        lsr                                     ; 2     12      Divide by 2 to get index twice for quad height
        sta WSYNC                               ; 3     14     
        SLEEP 3                                 ; 4     4       Account for 3 cycle branch to keep timing aligned

Track0Row 
        lsr                                     ; 2     5       Divide by 2 to get index twice for octuple height
        tay                                     ; 2     7       Transfer A to Y so we can index off Y
        
        lda (PlayButtonMaskPtr),y               ; 5     12      Get the Score From our Play Button Mask Array
        sta PF0                                 ; 3     15      Store the value to PF0

        lda (DurGfxPtr),y                       ; 5     20      Get the Score From our Duration Gfx Array
        asl                                     ; 2     22
        asl                                     ; 2     24
        sta PF1                                 ; 3     27      Store the value to PF1
        
        lda (VolGfxPtr),y                       ; 5     32      Get the Score From our Volume Gfx Array
        asl                                     ; 2     34
        sta PF2                                 ; 3     37      Store the value to PF2
        nop                                     ; 2     39      Waste 2 cycles to line up the next Pf draw
        
        lda (FrqCntGfxPtr),y                    ; 5     44      Get the Score From our Frequency Gfx Array
        sta PF2                                 ; 3     47      Store the value to PF2

        lda (CtlChnlGfxPtr),y                   ; 5     52      Get the Score From our Control Gfx Array
        sta PF1                                 ; 3     55      Store the value to PF1        

        inx                                     ; 2     57      Increment our line number
        
        ldy #0                                  ; 2     59      Reset and clear the playfield
        txa                                     ; 2     61      Transfer the line number in preparation for the next line
        sbc #135                                ; 2     63      Subtract #19 since the carry is cleared above
        nop
        sty PF0                                 ; 3     68      Reset and clear the playfield
        lsr                                     ; 2     70      Divide by 2 to get index twice for quadruple height
        sty.w PF1                               ; 4     74      Reset and clear the playfield

        cpx #155                                ; 2     76      Have we reached line #60   
        bne Track0Row                           ; 2/3   2/3
        
        ldy #0                                  
        sty PF2                                 ; 3     65      Reset and clear the playfield

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda FlagsSelection
        and #SELECTION_MASK
        cmp #10
        beq SkipSetPlayTracks2

        lda #<PlayButton
        sta PlayButtonMaskPtr
        lda #>PlayButton
        sta PlayButtonMaskPtr+1
        jmp SkipSetPauseTracks2
SkipSetPlayTracks2
        lda #<PauseButton
        sta PlayButtonMaskPtr
        lda #>PauseButton
        sta PlayButtonMaskPtr+1
SkipSetPauseTracks2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Track1Spacer
        inx                                             ; 2     4
        cpx #160                                        ; 2     6
        sta WSYNC                                       ; 3     9
        bne Track1Spacer                                ; 2/3   2/3
       
        inx                                     ; 2     4
        txa                                     ; 2     6
        sbc #159                                ; 2     8
        nop
        lsr                                     ; 2     12      Divide by 2 to get index twice for quad height
        sta WSYNC                               ; 3     14     
        SLEEP 3                                 ; 4     4       Account for 4 cycle branch to keep timing aligned

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Track1Row 
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
        sbc #159                                ; 2     64      Subtract #19 since the carry is cleared above
        nop
        sty PF0                                 ; 3     69      Reset and clear the playfield
        lsr                                     ; 2     71      Divide by 2 to get index twice for quadruple height
        sty.w PF1                               ; 3     74      Reset and clear the playfield

        cpx #180                                ; 2     76      Have we reached line #60   
        
        bne Track1Row                          ; 2/3   2/3
        
        ldy #0
        sty PF2                                 ; 3     65      Reset and clear the playfield


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Track1 Selection Row
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #CONTROLS_COLOR
        sta COLUPF
        ldy #0
        inx                                     ; 2     4
        sta WSYNC                               ; 3     3
        SLEEP 3                                 ; 3     3

Track1ControlSelection
        stx LineTemp
        lda FlagsSelection                      ; 3
        and #SELECTION_MASK                     ; 2

        cmp #9
        bmi SkipSelectPlayTrack1Button          ; 2/3
SelectPlayTrack1Button
        lda #%11100000                          ; 2
        sta PF0                                 ; 3
SkipSelectPlayTrack1Button
        SLEEP 8

        sty PF1
        sty PF0
        sty PF2
        
        ldx LineTemp
        inx                                     ; 2     4
        cpx #188                                ; 2     6
        sta WSYNC                               ; 3     9
        bne Track1ControlSelection              ; 2/3   2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Spacer - 1-Line Kernel 
; Line 1 - 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #30
        sta TIM64T

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Left Right Cursor Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check To Reset Play Track "Flag"  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        cpx #11                                 ; Check to see if the note display is selected
        bne SkipResetTrackFlag                ; If not then continue checking to enable Play Note Flag
       
       ; Maybe Set to 0 instead
        dec FlagsSelection
        dec FlagsSelection
        lda FlagsSelection                      ; Load Flags and Control Selection from Ram to the Accumulator
        and #SELECTION_MASK                     ; AND Accumulator with the SELECTION_MASK to get the selected control
        tax                                     ; Transfer the Accumulator to the X Register to free up the Accumulator
                                                ; and so we can determine which control is selected later
SkipResetTrackFlag
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check To See if Debounce Backoff is in Effect ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda DebounceCtr                         ; Check the Debounce Counter to be 0 before moving onward
        beq SetPlayNoteFlag                     ; If so then check to see if we need to enable the Play Note Flag
        jmp SkipSelectionSet                    ; If not then skip checking to enable Play Note Flag
SetPlayNoteFlag

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check To Enable Play Track "Flag"  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #9                                  
        bne SkipSetPlayTrackFlag                

        ldy INPT4                               ; Check to see if the Fire Button is being pressed
        bmi SkipSetPlayTrackFlag                ; If not then skip checking to enable Play Note Flag        
        
        inc FlagsSelection
        jmp SelectionSet
SkipSetPlayTrackFlag

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check To Disable Play Track "Flag"  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #10                                 
        bne SkipSetStopTrackFlag                

        ldy INPT4                               ; Check to see if the Fire Button is being pressed
        bmi SkipSetStopTrackFlag                ; If not then skip checking to enable Play Note Flag        
        dec FlagsSelection

        jmp SelectionSet
SkipSetStopTrackFlag


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #3
        bne Selection3

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 6 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 8 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Selection 9 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #9
        beq SkipJumpSelection9
        cpx #10
        beq SkipJumpSelection9
        jmp Selection9
SkipJumpSelection9

        ; Turn off Track Player
        lda FlagsSelection
        and #%01111111
        sta FlagsSelection

        lda #P0_JOYSTICK_UP            
        bit SWCHA
        beq StepForwardThroughNotes
        jmp SkipStepForwardThroughNotes

StepForwardThroughNotes
        lda DurRemainTrk0
        bne SkipInitTrk0

; Check to Initialize the two tracks for stepping through
        ldy #0 
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipLoadInitValTrk0                          

        lda #<Track0Builder                             
        sta NotePtrCh0                                  
        
        lda (NotePtrCh0),y                              
        and #DURATION_MASK

SkipLoadInitValTrk0
        tay
        lda NoteDurations,y
        sta DurRemainTrk0
SkipInitTrk0
        
        lda DurRemainTrk1
        bne SkipInitTrk1

        ldy #0 
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipLoadInitValTrk1                          

        lda #<Track1Builder
        sta NotePtrCh1
        
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
SkipLoadInitValTrk1
        tay
        lda NoteDurations,y
        sta DurRemainTrk1
SkipInitTrk1

; Figure out which track to advance based on duration left
        ; Check to see which duration is longer
        lda DurRemainTrk0
        cmp DurRemainTrk1
        beq AdvanceBothTracks

        lda DurRemainTrk0
        beq AdvanceTrk1

        lda DurRemainTrk1
        beq AdvanceTrk0

        lda DurRemainTrk0
        cmp DurRemainTrk1
        bpl AdvanceTrk1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AdvanceTrk0
        ;Advance Pointer for Track0
        lda NotePtrCh0                                  
        clc                                             
        adc #2                                          
        sta NotePtrCh0                                  

        ; Subtract the Duration of NoteA from NoteB
        lda DurRemainTrk1
        beq SkipSubtractDurTrk0
        sec 
        sbc DurRemainTrk0
        sta DurRemainTrk1
SkipSubtractDurTrk0
        ; Get the new Note Duration Left for Track0
        ldy #0 
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipResetPtrTrack0AdvTrk0                          

        dec NotePtrCh0
        dec NotePtrCh0
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
SkipResetPtrTrack0AdvTrk0
        tay
        lda NoteDurations,y
        sta DurRemainTrk0

        jmp AdvanceDone

AdvanceTrk1
        ;Advance Pointer for Track1
        lda NotePtrCh1                                  
        clc                                             
        adc #2                                          
        sta NotePtrCh1                                  

        ; Subtract the Duration of NoteB from NoteA
        lda DurRemainTrk0
        beq SkipSubtractDurTrk1
        sec 
        sbc DurRemainTrk1
        sta DurRemainTrk0
SkipSubtractDurTrk1
        ; Get the new Note Duration Left for Track1
        ldy #0 
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipResetPtrTrack1AdvTrk1
                                       
        dec NotePtrCh1
        dec NotePtrCh1
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
SkipResetPtrTrack1AdvTrk1
        tay
        lda NoteDurations,y
        sta DurRemainTrk1

        jmp AdvanceDone

AdvanceBothTracks
        lda NotePtrCh0                                  ; 3     Load the Note Pointer to A
        clc                                             ; 2     Clear the carry 
        adc #2                                          ; 2     Add 4 to move the Note pointer to the next note
        sta NotePtrCh0                                  ; 3     Store the new note pointer

        ldy #0 
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipResetPtrTrack0AdvBothTrk
                                     
        dec NotePtrCh0
        dec NotePtrCh0
        lda (NotePtrCh0),y                              
        and #DURATION_MASK
SkipResetPtrTrack0AdvBothTrk
        tay
        lda NoteDurations,y
        sta DurRemainTrk0


        lda NotePtrCh1                                  ; 3     Load the Note Pointer to A
        clc                                             ; 2     Clear the carry 
        adc #2                                          ; 2     Add 2 to move the Note pointer to the next note
        sta NotePtrCh1                                  ; 3     Store the new note pointer

        ldy #0 
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
        cmp #0                                          
        bne SkipResetPtrTrack1AdvBothTrk                          

        dec NotePtrCh1
        dec NotePtrCh1
        lda (NotePtrCh1),y                              
        and #DURATION_MASK
SkipResetPtrTrack1AdvBothTrk
        tay
        lda NoteDurations,y
        sta DurRemainTrk1
AdvanceDone
        jmp SelectionSet
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; Decrement Pointers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SkipStepForwardThroughNotes
        lda #P0_JOYSTICK_DOWN            
        bit SWCHA
        beq StepBackwardThroughNotes
        jmp SkipStepBackwardThroughNotes
StepBackwardThroughNotes

        lda NotePtrCh0
        cmp #<Track0Builder
        beq SkipRecedeTrk0
        clc
        adc #$FE
SkipRecedeTrk0
        sta LineTemp

        lda NotePtrCh1
        cmp #<Track1Builder
        beq SkipRecedeTrk1
        clc
        adc #$FE
SkipRecedeTrk1
        sta YTemp

        lda #<Track0Builder                             
        sta NotePtrCh0 

        lda #<Track1Builder                             
        sta NotePtrCh1

        lda #0
        sta DurRemainTrk0
        sta DurRemainTrk1

RecedeTrackLoop
        lda NotePtrCh0
        cmp LineTemp
        bne SkipRecedeFinCheck0
        lda NotePtrCh1
        cmp YTemp
        bmi SkipRecedeFinCheck0
        jmp DecFin
SkipRecedeFinCheck0

        lda NotePtrCh1
        cmp YTemp
        bne SkipRecedeFinCheck1
        lda NotePtrCh0
        cmp LineTemp
        bmi SkipRecedeFinCheck1
        jmp DecFin
SkipRecedeFinCheck1

        lda DurRemainTrk0
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
        sta DurRemainTrk0

SkipDecDurationACheck
        
        lda DurRemainTrk1
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
        sta DurRemainTrk1

SkipDecDurationBCheck

SkipDecDurationCheck
        lda DurRemainTrk0
        cmp DurRemainTrk1
        bne SkipDecJump
        jmp DecBothPointers
SkipDecJump

        lda DurRemainTrk0
        beq DecPointerB

        lda DurRemainTrk1
        beq DecPointerA

        lda DurRemainTrk0
        cmp DurRemainTrk1
        bpl DecPointerB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DecPointerA
        ;Advance Pointer for Track0
        lda NotePtrCh0                                  
        clc                                             
        adc #2                                          
        sta NotePtrCh0                                  

        ; Subtract the Duration of NoteA from NoteB
        lda DurRemainTrk1
        beq SkipDecSubtractA
        sec 
        sbc DurRemainTrk0
        sta DurRemainTrk1
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
        sta DurRemainTrk0

        jmp DecDone

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DecPointerB

        ;Advance Pointer for Track1
        lda NotePtrCh1                                  
        clc                                             
        adc #2                                          
        sta NotePtrCh1                                  

        ; Subtract the Duration of NoteB from NoteA
        lda DurRemainTrk0
        beq SkipDecSubtractB
        sec 
        sbc DurRemainTrk1
        sta DurRemainTrk0
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
        sta DurRemainTrk1

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
        sta DurRemainTrk0

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
        sta DurRemainTrk1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DecDone
        jmp RecedeTrackLoop
DecFin
        jmp SelectionSet
SkipStepBackwardThroughNotes

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


        lda #0
        sta YTemp
        sta LineTemp
        sta LetterBuffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Track Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        lda FlagsSelection                      ; Load Flags and Control Selection from Ram to the Accumulator
        and #SELECTION_MASK                     ; AND Accumulator with the SELECTION_MASK to get the selected control

        cmp #9
        beq TurnOffTrackNote

        cmp #10
        beq TrackPlayNote
        jmp SkipTrackPlayNote
TrackPlayNote
        ldx #0
        lda (NotePtrCh0,x)
        and #FREQUENCY_MASK
        lsr
        lsr
        lsr
        sta AUDF0

        inc NotePtrCh0

        lda (NotePtrCh0,x)
        and #VOLUME_MASK
        lsr
        lsr
        lsr
        lsr
        sta AUDV0

        lda (NotePtrCh0,x)
        and #CONTROL_MASK
        sta AUDC0

        dec NotePtrCh0

;;;
        lda (NotePtrCh1,x)
        and #FREQUENCY_MASK
        lsr
        lsr
        lsr
        sta AUDF1

        inc NotePtrCh1

        lda (NotePtrCh1,x)
        and #VOLUME_MASK
        lsr
        lsr
        lsr
        lsr
        sta AUDV1

        lda (NotePtrCh1,x)
        and #CONTROL_MASK
        sta AUDC1


        dec NotePtrCh1
        jmp SkipPlayNote

TurnOffTrackNote
        lda #0
        sta AUDV0
        sta AUDF0
        sta AUDC0
        sta AUDV1
        sta AUDF1
        sta AUDC1

SkipTrackPlayNote
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Note Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #PLAY_NOTE_FLAG
        bit FlagsSelection
        bne SkipPlayNote

        lda FlagsSelection                      ; Load Flags and Control Selection from Ram to the Accumulator
        and #SELECTION_MASK                     ; AND Accumulator with the SELECTION_MASK to get the selected control
        cmp #5                                  ; Check to see if any of top row controls are selected
        bpl TurnOffNote                         ; If not then skip checking to enable Play Note Flag 

        lda AudCntChnl
        and #1
        tax
PlayNote
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

        jmp SkipPlayNote

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

SkipPlayNote


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

; Track 0
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

; Track 1
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

        jmp SkipResetTrack

SkipRamMusicPlayer
        lda #PLAY_NOTE_FLAG
        bit FlagsSelection
        beq SkipResetTrack


        lda FlagsSelection
        and #SELECTION_MASK 
        cmp #9
        beq SkipResetTrack
        cmp #10
        beq SkipResetTrack
        lda #<Track0Builder                              ; 4     Store the low byte of the track to 
        sta NotePtrCh0                                   ; 3     the Note Pointer
        lda #<Track1Builder                              ; 4     Store the low byte of the track to 
        sta NotePtrCh1
        lda #0
        sta DurRemainTrk0
        sta DurRemainTrk1

        lda #0
        sta AUDV0
        sta AUDV1
        sta AUDC0
        sta AUDC1
        sta AUDF0
        sta AUDF1
        sta FrameCtrTrk0
        sta FrameCtrTrk1
SkipResetTrack
;;;;;;;;;;;;;;;;;; End Ram Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Calculate Remaining Notes ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Debounce Check ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda DebounceCtr
        beq SkipDecDebounceCtr_Bank0
        dec DebounceCtr
SkipDecDebounceCtr_Bank0
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Change Bank ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda SWCHB
        and #%00000010
        ora DebounceCtr
        bne SkipSwitchToBank1
        ; Put game select logic code here
        jmp SwitchToBank1
SkipSwitchToBank1

; Reset Backgruond,Audio,Collisions,Note Flags
        lda #0
        sta COLUBK

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

        align 256
        ; 248 bytes used
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

TopPlayButton           .byte  #%0
                        .byte  #%00100000
                        .byte  #%00100000
                        .byte  #%01100000
                        .byte  #%01100000
                        .byte  #0

BottomPlayButton        .byte  #%01100000
                        .byte  #%01100000
                        .byte  #%00100000
                        .byte  #%00100000
                        .byte  #0
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

        align 256
        ; 240 bytes used
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
        ; 245 bytes used
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




        echo "----"
        echo "Rom Total Bank0:"
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
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Bank1 Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLY_GAME_TITLE_BG_COLOR                 = #57
FLY_GAME_TITLE_COLOR                    = #$02

FLY_GAME_TITLE_VPOS                     = #56

FLY_GAME_GAME_OVER_BACKGROUND_COLOR     = #$0A


P0XSTARTPOS        = #15
P0YSTARTPOS        = #78
E0XSTARTPOS        = #55
E0YSTARTPOS        = #78
E1XSTARTPOS        = #75
E1YSTARTPOS        = #78
E2XSTARTPOS        = #95
E2YSTARTPOS        = #78

BLXSTARTPOS        = #6
BLYSTARTPOS        = #92
BlHPOS             = #80

;;
P0HEIGHT           = #27
E0HEIGHT           = #4
E1HEIGHT           = #4
E2HEIGHT           = #4

PLAYER2_H_POS      = #100
SLEEPTIMER_PLAYER2 = PLAYER2_H_POS/3 +51

P2_JOIN_FLASHRATE  = #52

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        SEG.U bank1vars
        ORG Overlay
Game1SelectionGfx       ds 2
Game2SelectionGfx       ds 2
GameSelectFlag          ds 1
SkipGameFlag            ds 1
DebounceCtr             ds 1                    ; Gotta Keep this in spot 7 to match Bank0
Fire                    ds 1
LetterBuffer2           ds 1
LineTemp2               ds 1
YTemp2                  ds 1
Flasher                 ds 1
CountdownTimer          ds 1
CountdownTimerInterval  ds 1
CountdownTimerTmp1      ds 1
CountdownTimerTmp2      ds 1
CountdownTimerIdx       ds 1
CountdownTimerGfx       ds 5
CountdownTimerGfxPtr    ds 2

Player0XPos             ds 1
Player0YPos             ds 1
Player0YPosEnd          ds 1
Player0YPosTmp          ds 1
DrawP0Sprite            ds 1
P0SprIdx                ds 1
Player0GfxPtr           ds 2
P0Height                ds 1

Enemy0XPos              ds 1
Enemy0YPos              ds 1
Enemy0YPosEnd           ds 1
Enemy0StartEdge         ds 1
Enemy0Alive             ds 1
Enemy0GenTimer          ds 1
Enemy0HWayPoint         ds 1
Enemy0VWayPoint         ds 1

Enemy1XPos              ds 1
Enemy1YPos              ds 1
Enemy1YPosEnd           ds 1
Enemy1StartEdge         ds 1
Enemy1Alive             ds 1
Enemy1GenTimer          ds 1
Enemy1HWayPoint         ds 1
Enemy1VWayPoint         ds 1

Enemy2XPos              ds 1
Enemy2YPos              ds 1
Enemy2YPosStr           ds 1
DrawE2Sprite            ds 1
E2SprIdx                ds 1

P0Score1                ds 1
P0Score2                ds 1
P0Score1idx             ds 1
P0Score1DigitPtr        ds 2
P0ScoreTmp              ds 1
P0Score2idx             ds 1
P0Score2DigitPtr        ds 2
P0ScoreArr              ds 5

P1Score1                ds 1
P1Score2                ds 1
P1Score1idx             ds 1
P1Score1DigitPtr        ds 2
P1ScoreTmp              ds 1
P1Score2idx             ds 1
P1Score2DigitPtr        ds 2
P1ScoreArr              ds 5

        echo "----"
        echo "Ram Total Bank1:"
        echo "----",([* - $80]d) , (* - $80) ,"bytes of RAM Used for Bank 1"
        echo "----",([$100 - *]d) , ($100 - *) , "bytes of RAM left for Bank 1"
        SEG
        ORG  $2000
        RORG $F000

SwitchToBank0
        lda $1FF8
RestartFlyGame
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

        ldy #FLY_GAME_TITLE_COLOR                       ; 2
        sty COLUPF                                      ; 3

        ldy #FLY_GAME_TITLE_COLOR                       ; 2
        sty COLUP0                                      ; 3
        sty COLUP1                                      ; 3

        ldy #0                                          ; 2
        sty VDELP0
        sty VDELP1

        ldx #0
        lda #59
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #1
        lda #67
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR
                
        lda #TWO_COPIES_CLOSE
        sta NUSIZ0
        sta NUSIZ1

        lda #<Cursor
        sta Game1SelectionGfx
        lda #>Cursor
        sta Game1SelectionGfx+1

        lda #<Space
        sta Game2SelectionGfx
        lda #>Space
        sta Game2SelectionGfx+1

StartOfFlyGameTitleScreenFrame
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
FlyGameTitleScreenVerticalBlank
        sta WSYNC                                       ; 3
        dex                                             ; 2
        bne FlyGameTitleScreenVerticalBlank             ; 2/3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End VBLANK Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda SkipGameFlag
        beq FlyGameTitleScreenStart
        jmp PlayFlyGame
FlyGameTitleScreenStart
        lda #FLY_GAME_TITLE_BG_COLOR
        sta COLUBK
        ldy #0
FlyGameTitleScreenTopBuffer
        inx
        cpx #FLY_GAME_TITLE_VPOS
        sta WSYNC
        bne FlyGameTitleScreenTopBuffer

FlyGameTitleLine1
        txa
        sbc #FLY_GAME_TITLE_VPOS
        lsr
        lsr
        tay

        lda FL,y
        sta PF1
        lda Y_,y
        sta PF2

        SLEEP 16
        lda #0
        sta PF0
        sta PF1
        sta PF2

        inx
        cpx #FLY_GAME_TITLE_VPOS+21
        sta WSYNC
        bmi FlyGameTitleLine1

        lda #0
        sta PF0
        sta PF1
        sta PF2
FlyGameTitleMiddleBuffer
        inx
        ldy #0
        cpx #FLY_GAME_TITLE_VPOS+27
        sta WSYNC
        bne FlyGameTitleMiddleBuffer

FlyGameTitleLine2
        txa
        sbc #FLY_GAME_TITLE_VPOS+26
        lsr
        lsr
        tay

        lda GA,y
        sta PF1
        lda ME,y
        sta PF2

        SLEEP 16
        lda #0
        sta PF0
        sta PF1
        sta PF2

        inx
        cpx #FLY_GAME_TITLE_VPOS+47
        sta WSYNC
        bmi FlyGameTitleLine2


;;;;;;;;;;;;;;; End Draw Playfield ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
FlyGameTitleBottomBuffer
        inx
        cpx #135
        sta WSYNC
        bne FlyGameTitleBottomBuffer
        nop

;;;;;;;;;;;;;;;;;;;;;; Game Select ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
FlyGameNumPlayersSelectLine1 
        txa                                             ; 2
        sec                                             ; 2
        sbc #135                                        ; 2
        tay                                             ; 2
        lda (Game1SelectionGfx),y                       ; 4
        sta GRP0                                        ; 3
        lda ON,y                                        ; 4
        sta GRP1                                        ; 3
        SLEEP 11                                        ; 11
        lda E_,y                                        ; 4
        sta GRP0                                        ; 3

        lda #0                                          ; 2
        sta GRP1                                        ; 3
        sta GRP0                                        ; 3

        inx
        cpx #140
        sta WSYNC
        bne FlyGameNumPlayersSelectLine1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FlyGameNumPlayersSelectMiddleBuffer
        inx
        cpx #145
        sta WSYNC
        bne FlyGameNumPlayersSelectMiddleBuffer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FlyGameNumPlayersSelectLine2 
        txa                                             ; 2
        sec
        sbc #145                                        ; 2
        tay                                             ; 2 
        lda (Game2SelectionGfx),y                       ; 4
        sta GRP0                                        ; 3
        lda TW,y                                        ; 4
        sta GRP1                                        ; 3
        SLEEP 12                                        ; 12
        lda O_,y                                        ; 4
        sta GRP0                                        ; 3

        lda #0                                          ; 2
        sta GRP1                                        ; 3
        sta GRP0                                        ; 3

        inx
        cpx #150
        sta WSYNC
        bne FlyGameNumPlayersSelectLine2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FlyGameTitleScreenBottomBuffer
        inx
        cpx #192
        sta WSYNC
        bne FlyGameTitleScreenBottomBuffer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of Viewable Screen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #%00000010
        sta VBLANK

        lda #0
        sta COLUBK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #30
        sta TIM64T

        lda DebounceCtr
        beq SkipDecDebounceCtr_FlyGameTitleScreen
        dec DebounceCtr
SkipDecDebounceCtr_FlyGameTitleScreen

        lda SWCHB
        and #%00000010
        ora DebounceCtr
        bne SkipSwitchToBank0
        ; Put game select logic code here
        jmp SwitchToBank0
SkipSwitchToBank0

        lda DebounceCtr
        bne DontStartGame
SkipDecDebounceCtr_Bank1
        lda INPT4
        bmi DontStartGame
        sta SkipGameFlag
DontStartGame

        ldx #0
TextBuilder
        
        ; if up pressed Game1SelectionGfx
        ldy SWCHA
        cpy #%11101111
        bne SkipSelectFlyGame1Player
        ldy #0
        sty GameSelectFlag
        
        lda #<Cursor
        sta Game1SelectionGfx
        lda #>Cursor
        sta Game1SelectionGfx+1
        
        lda #<Space
        sta Game2SelectionGfx
        lda #>Space
        sta Game2SelectionGfx+1
SkipSelectFlyGame1Player

        ldy SWCHA
        cpy #%11011111
        bne SkipSelectFlyGame2Player
        ldy #1
        sty GameSelectFlag

        lda #<Cursor
        sta Game2SelectionGfx
        lda #>Cursor
        sta Game2SelectionGfx+1
        
        lda #<Space
        sta Game1SelectionGfx
        lda #>Space
        sta Game1SelectionGfx+1
SkipSelectFlyGame2Player
        
WaitLoop_bank1
        lda INTIM
        bne WaitLoop_bank1
; overscan
        ldx #6                                          
FlyGameTitleScreenOverscan
        sta WSYNC
        dex
        bne FlyGameTitleScreenOverscan
        jmp StartOfFlyGameTitleScreenFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Game Start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TODO: Add Countdown Timer
; TODO: Add Game Over/Winning Screen
; TODO: More Randomization in Enemy Gen
; TODO: Add Enemy2
; TODO: Add Support for Player 2
; TODO: Set Player and Game Colors
; TODO: Add Enemy Lifecycle
; TODO: Add Boss in single player mode
; TODO: Change Fly types/counts based on what level you are
; TODO: Make Swat Collision detection better
; TODO: Player0 Movement change to be different speed than enemies
; TODO: Condense Ram
; TODO: Debounce Swat so you can't just hold it down and win
; TODO: Add switch to next game
; TODO: Add Trackball Support

PlayFlyGame

FlyGameScreen
        lda #0
        sta GRP0
        sta GRP1

        lda #1
        sta VDELP0
        sta VDELBL
        lda #1
        sta VDELP1

        lda #0
        sta DrawP0Sprite
        sta P0SprIdx

        lda #P0XSTARTPOS
        sta Player0XPos

        lda #E0XSTARTPOS
        sta Enemy0XPos

        lda #E1XSTARTPOS
        sta Enemy1XPos

        ldx #P0YSTARTPOS
        stx Player0YPos

        ; ldx #E0YSTARTPOS
        ldx #0
        stx Enemy0YPos

        ; ldx #E1YSTARTPOS
        ldx #0
        stx Enemy1YPos
        
        ldx #0
        stx Enemy0Alive

        ldx #E2YSTARTPOS
        stx Enemy2YPos
        
        ldx #P0HEIGHT
        stx P0Height

        ldx #100
        stx Enemy0GenTimer
        stx Enemy1GenTimer

        ;ldx #153
        ldx #9
        stx CountdownTimer

        lda #60
        sta CountdownTimerInterval

        ldx #0
        lda Player0XPos
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR
        
        ldx #2
        lda Enemy0XPos
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #3
        lda Enemy1XPos
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #4
        lda #E2XSTARTPOS
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

FlyGameStartOfFrame
        lda #0
        sta VBLANK

        lda #0
        sta COLUBK

; 3 VSYNC Lines
        lda #2
        sta VSYNC ; Turn on VSYNC

        sta WSYNC
        sta WSYNC
        sta WSYNC
        lda #0
        sta VSYNC ; Turn off VSYNC

; 37 VBLANK lines

        ldx #0
        sta GRP0
        sta GRP1
        lda #PLAYER2_H_POS
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #1
        lda #PLAYER2_H_POS+8
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR
        lda #THREE_COPIES_CLOSE
        sta NUSIZ0
        sta NUSIZ1


        ldx #33                                         ; 2
FlyGameVerticalBlank
        sta WSYNC                                       ; 3
        dex                                             ; 2
        bne FlyGameVerticalBlank                          ; 2/3

        lda CountdownTimer
        bne SkipFlyGameGameoverScreen
        jmp FlyGameGameOverScreen
SkipFlyGameGameoverScreen

        
        lda #$0A
        sta COLUBK

        ldy #1                                          ; 2
        sty VDELP0
        sty VDELP1

        ldx #0
        IF PLAYER2_H_POS <= 47
         sta WSYNC                                      ; 3     
        ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Viewable Screen Start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; jmp Filler
        ; REPEAT 20
        ; nop
        ; REPEND
Filler
        ldy #0
        lda Flasher
        cmp #P2_JOIN_FLASHRATE/2 -10
        bpl GameViewableScreen

FlashFire
        inx
        cpx #9
        sta WSYNC
        bne FlashFire
        jmp Player2Buffer
  
GameViewableScreen
        inx
        cpx #3
        sta WSYNC
        bne GameViewableScreen

        SLEEP SLEEPTIMER_PLAYER2
        inx                                             ; 2
DrawPlayer2JoinText
        stx LineTemp2                                   ; 3     6
        sty YTemp2                                      ; 3     9
        
        ldx E_,y                                        ; 4     13
        stx LetterBuffer2                               ; 3     16
        
        ldx IR,y                                        ; 4     20

        lda _P,y                                        ; 4     24
        sta GRP0                                        ; 3     27       -> [GRP0]
        
        lda RE_bank1,y                                  ; 4     31
        sta GRP1                                        ; 3     34       -> [GRP1], [GRP0] -> GRP0
        
        lda SS,y                                        ; 4     38
        sta GRP0                                        ; 3     41       -> [GRP0]. [GRP1] -> GRP1
        
        lda _F,y                                        ; 4     45
        ldy LetterBuffer2                               ; 3     48
        sta GRP1                                        ; 3     51       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     54       -> [GRP0], [GRP1] -> GRP1
        sty GRP1                                        ; 3     57       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     60      ?? -> [GRP0], [GRP1] -> GRP1
        
        ldx LineTemp2                                   ; 3     63
        ldy YTemp2                                      ; 3     66
        iny                                             ; 2     68

        inx                                             ; 2     70
        cpx #9                                          ; 2     72
        nop                                             ; 2     74
        nop                                             ; 2     76
        bne DrawPlayer2JoinText                         ; 2/3   2/3

        
Player2Buffer
        lda #DOUBLE_SIZE_PLAYER
        sta NUSIZ0
        sta NUSIZ1
        lda #0
        sta GRP0
        sta GRP1
        sta GRP0
        sec
        
        inx
        sta WSYNC

        SLEEP 44

        sta RESP0
        lda #0
        sta VDELP0
        lda #DOUBLE_SIZE_PLAYER
        sta NUSIZ0
        sta NUSIZ1
        inx
        sta WSYNC
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
        txa                                             ; 2
        sbc #10                                         ; 2
        lsr                                             ; 2
        lsr                                             ; 2
        tay                                             ; 2
        lda P0ScoreArr,y                                ; 4     Get the Score From our Player 0 Score Array
        sta PF1                                         ; 3     Store Score to PF1
        lda Zero_bank1,y                                ; 4     Get the Score From our Player 0 Score Array
        lsr                                             ; 2
        sta PF2                                         ; 3     Store Score to PF1 
        nop                                             ; 2     Wait 2 cycles to get past drawing player 0's score
        nop                                             ; 2     Wait 2 cycles more to get past drawing player 0's score
        
        lda P1ScoreArr,y                                ; 4     Get the Score From our Player 1 Score Array
        sta PF1                                         ; 3     Store Score to PF1
        
        lda #0
        cpx #15                                         ; 2
        bmi SkipDisplayTimer                            ; 2/3
        cpx #25                                         ; 2
        bpl SkipDisplayTimer                            ; 2/3

        txa                                             ; 2
        sec                                             ; 2
        sbc #15                                         ; 2
        lsr                                             ; 2
        tay                                             ; 2
        lda CountdownTimerGfx,y                         ; 4
        
SkipDisplayTimer
        sta GRP0                                        ; 3
        inx                                             ; 2     Increment our line counter
        cpx #31                                         ; 2     See if we're at line 30
        sta WSYNC                                       ; 3     Go to Next line
        bne ScoreArea                                   ; 2/3   If at line 30 then move on else branch back

        lda #0                                          ; 2     We're on lines that don't have the score 
        sta PF1                                         ; 3     so clear the playfield(PF1)
        sta PF2

        sta GRP0
        lda #DOUBLE_SIZE_PLAYER
        sta NUSIZ0
        sta NUSIZ1
        lda #1
        sta VDELP0
        
        sta WSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; End Drawing Score Area ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda Player0XPos
        cmp #$78
        bcs SkipWSYNC
        sta WSYNC
SkipWSYNC

        ldx #0
        lda Player0XPos
        jsr CalcXPos_bank1
        sta HMP0
        sta WSYNC
        sta HMOVE

        ldx #0
        stx COLUBK
        SLEEP 24
        sta HMCLR
        
        ldx #1
        stx VDELP0
        stx VDELP1
        
        ldx #35
        
ScoreAreaBuffer
        inx
        ;cpx #34
        sta WSYNC
        ;bne ScoreAreaBuffer
        lda #$0A
        sta COLUBK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Drawing Players and Enemy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameBoard
        ldy #2                                  ; 2
        lda #0                                  ; 2     (4)
        
        cpx Enemy0YPos                          ; 3
        bne SkipDrawE0                          ; 2/3
        sty ENAM0                               ; 3     (8)
SkipDrawE0

        cpx Enemy1YPos                          ; 3
        bne SkipDrawE1                          ; 2/3
        sty ENAM1                               ; 3     (8)
SkipDrawE1

        ldy #1                                  ; 2
        cpx Player0YPos                         ; 3
        bne SkipSetDrawP0Flag                   ; 2/3
        sty DrawP0Sprite                        ; 3     (10)
SkipSetDrawP0Flag

        lda DrawP0Sprite                        ; 3
        beq SkipP0Draw                          ; 2/3
        ldy P0SprIdx                            ; 3
        lda (Player0GfxPtr),y                   ; 5
        sta GRP0                                ; 3
        inc P0SprIdx                            ; 5     (21)
SkipP0Draw

        sta WSYNC                               ; 3     (3)     (54)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
        lda #0                                  ; 2
        sta GRP1                                ; 3      (5)

        ldy P0SprIdx                            ; 3
        cpy P0Height                            ; 2
        ;cpx Player0YPosEnd
        bne SkipP0ResetHeight                   ; 2/3
        sta P0SprIdx                            ; 3
        sta DrawP0Sprite                        ; 3     (13)
SkipP0ResetHeight
        
        cpx Enemy0YPosEnd                       ; 3
        bne SkipE0Reset                         ; 2/3
        sta ENAM0                               ; 3     (8)
SkipE0Reset

        cpx Enemy1YPosEnd                       ; 3
        bne SkipE1Reset                         ; 2/3
        sta ENAM1                               ; 3     (8)
SkipE1Reset

        inx                                     ; 2
        inx                                     ; 2
        cpx #192                                ; 2
        sta WSYNC                               ; 3
        bne GameBoard                           ; 2/3   (12)    (46)
        ;beq SkipJumpGameBoard                   ; 2/3
        ;jmp GameBoard
;SkipJumpGameBoard

        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of Viewable Screen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Setup Overscan  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #%00000010
        sta VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Setup Overscan  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #36
        sta TIM64T
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check Debouce Counter ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda DebounceCtr
        beq GameSkipDecDebounceCtr_Bank1
        dec DebounceCtr
GameSkipDecDebounceCtr_Bank1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Check Debouce Counter ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check Bank Switching ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda SWCHB
        and #%00000010
        ora DebounceCtr
        bne GameSkipSwitchToBank0
        ; Put game select logic code here
        
        jmp SwitchToBank0
GameSkipSwitchToBank0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Check Bank Switching ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Player 2 Join Flasher ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda Flasher
        bne DecFlasher
        lda #P2_JOIN_FLASHRATE
        sta Flasher
        jmp SkipFlasher
DecFlasher
        dec Flasher
SkipFlasher
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Player 2 Join Flasher ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Hide Player0 Sprite Overflow ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #135
        cmp Player0YPos
        bcs SkipPlayerHeight
        lda #192
        ;sec
        sbc Player0YPos
        lsr
        sta P0Height
        jmp SetPlayerHeight
SkipPlayerHeight
        lda #P0HEIGHT
        sta P0Height
SetPlayerHeight
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Hide Player0 Sprite Overflow ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Player 0 Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Player0Control
; Player 0 Up/Down Control
        ldy Player0YPos
        
        lda #P0_JOYSTICK_UP            
        bit SWCHA
        bne SkipMoveP0Up
        dey
        dey
SkipMoveP0Up

        lda #P0_JOYSTICK_DOWN
        bit SWCHA
        bne SkipMoveP0Down
        iny
        iny
SkipMoveP0Down

        cpy #34
        bne SkipSetP0MinVPos
        ldy #36
SkipSetP0MinVPos

        cpy #170
        bne SkipSetP0MaxVPos
        ldy #168
SkipSetP0MaxVPos
        sty Player0YPos

; Player 0 Left/Right Control
        lda #P0_JOYSTICK_LEFT          
        and SWCHA
        bne SkipMoveP0Left
        lda #$10
        sta HMP0
        dec Player0XPos
SkipMoveP0Left

        lda #P0_JOYSTICK_RIGHT
        and SWCHA
        bne SkipMoveP0Right
        lda #$F0
        sta HMP0
        inc Player0XPos
SkipMoveP0Right
       
        ldy #0
        ldx Player0XPos
        bne SkipSetP0MinHPos
        sty HMP0
        inc Player0XPos
SkipSetP0MinHPos

        cpx #160-#16
        bne SkipSetP0MaxHPos
        sty HMP0
        dec Player0XPos
SkipSetP0MaxHPos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Player 0 Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Player 0 Detect Hit ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda DebounceCtr
        bne SkipHitDetection
        lda INPT4
        bmi NotFire 
        lda #0
        sta Fire

        lda #8
        sta DebounceCtr

        lda #<PlayerSlapGfx
        sta Player0GfxPtr
        lda #>PlayerSlapGfx
        sta Player0GfxPtr+1

        lda Player0XPos
        cmp Enemy0XPos
        bcs SkipEnemy0Hit
        clc
        adc #16
        cmp Enemy0XPos
        bcc SkipEnemy0Hit

        lda Player0YPos
        cmp Enemy0YPos
        bcs SkipEnemy0Hit
        clc
        adc #16
        cmp Enemy0YPos
        bcc SkipEnemy0Hit

        lda #0
        sta Enemy0Alive
        ; sta Enemy0XPos
        sta Enemy0YPos

        lda #150
        sta Enemy0GenTimer

        inc P0Score1
        lda P0Score1
        cmp #8
        bne SkipEnemy0Hit
        lda #0
        sta P0Score1
        inc P0Score2

SkipEnemy0Hit

        lda Player0XPos
        cmp Enemy1XPos
        bcs SkipEnemy1Hit
        clc
        adc #16
        cmp Enemy1XPos
        bcc SkipEnemy1Hit

        lda Player0YPos
        cmp Enemy1YPos
        bcs SkipEnemy1Hit
        clc
        adc #16
        cmp Enemy1YPos
        bcc SkipEnemy1Hit

        lda #0
        sta Enemy1Alive
        ; sta Enemy1XPos
        sta Enemy1YPos

        lda #150
        sta Enemy1GenTimer

        inc P0Score1
        lda P0Score1
        cmp #8
        bne SkipEnemy1Hit
        lda #1
        sta P0Score1
        inc P0Score2

SkipEnemy1Hit

        jmp SkipFire

SkipHitDetection

NotFire
        lda #1
        sta Fire
        lda DebounceCtr
        bne SkipFire

        lda #<PlayerGfx
        sta Player0GfxPtr
        lda #>PlayerGfx
        sta Player0GfxPtr+1
SkipFire


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Player 0 Detect Hit ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Enemy 0 Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda Enemy0GenTimer
        beq SkipEnemy0CountdownTimer
        dec Enemy0GenTimer
SkipEnemy0CountdownTimer

        lda Enemy0GenTimer
        cmp #1
        bne SkipGenerateEnemy0
DetermineEdge
        lda INPT4
        jsr GetRandomNumber
        and #3
        sta Enemy0StartEdge

        lda #1
        sta Enemy0Alive

        ; Generate Start Pos
        lda Enemy0StartEdge
        cmp #0
        bne SkipTopE0StartEdge
        lda #0
        sta Enemy0YPos
        jmp E0StartEdgeSet
SkipTopE0StartEdge
        cmp #1
        bne SkipRightSideE0StartEdge
        lda #0
        sta Enemy0YPos
        jmp E0StartEdgeSet
SkipRightSideE0StartEdge
        cmp #2
        bne SkipBottomE0StartEdge
        lda #192-#E0HEIGHT-4
        sta Enemy0YPos
        jmp E0StartEdgeSet
SkipBottomE0StartEdge
        cmp #3
        bne SkipLeftSideE0StartEdge
        lda #192-#E0HEIGHT-4
        sta Enemy0YPos
        
SkipLeftSideE0StartEdge
E0StartEdgeSet
        lda INPT4
        jsr GetRandomNumber
        and #159
        sta Enemy0XPos

SkipGenerateEnemy0

        ldx #2
        lda Enemy0XPos
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        lda Enemy0GenTimer
        bne SkipEnemy0Alive
        lda #1
        sta Enemy0Alive
SkipEnemy0Alive

        lda Enemy0Alive
        beq SkipEnemy0Movement
Enemy0VectorPath
        ;; Do vector path code here
        lda Enemy0HWayPoint
        bne SkipGenerateNewE0WayPoints

RegenE0HSeed
        lda INPT4
        beq RegenE0HSeed
        jsr GetRandomNumber
        and #158
        ; and #2
        ; clc
        ; adc #70
        sta Enemy0HWayPoint

RegenE0VSeed
        lda INPT4
        beq RegenE0VSeed
        jsr GetRandomNumber
        and #148
        clc
        adc #34
        ; and #2
        ; clc
        ; adc #72
        sta Enemy0VWayPoint
SkipGenerateNewE0WayPoints

        lda Enemy0HWayPoint
        sec
        sbc Enemy0XPos
        bne SkipSetE0HMoveFlat
        lda #$0
        sta HMM0
        jmp SkipSetE0HMoveRight
SkipSetE0HMoveFlat
        bcc SkipSetE0HMoveLeft
        lda #$F0
        sta HMM0
        inc Enemy0XPos
        jmp SkipSetE0HMoveRight
SkipSetE0HMoveLeft
        bcs SkipSetE0HMoveRight
        lda #$10
        sta HMM0
        dec Enemy0XPos
SkipSetE0HMoveRight

        lda Enemy0VWayPoint
        sec
        sbc Enemy0YPos
        bne SkipSetE0VMoveFlat
        jmp SkipSetE0VMoveRight
SkipSetE0VMoveFlat
        bcc SkipSetE0VMoveLeft
        inc Enemy0YPos
        inc Enemy0YPos
        jmp SkipSetE0VMoveRight
SkipSetE0VMoveLeft
        bcs SkipSetE0VMoveRight
        dec Enemy0YPos
        dec Enemy0YPos
SkipSetE0VMoveRight

        ; lda Flasher
        ; and #1
        ; bne SkipHMOVE        
        sta WSYNC
        sta HMOVE
SkipHMOVE

        lda Enemy0XPos
        sec
        sbc Enemy0HWayPoint
        bne SkipRegenWayPoints
        ;beq RegenWayPoints

        lda Enemy0YPos
        sec
        sbc Enemy0VWayPoint
        bne SkipRegenWayPoints
;RegenWayPoints
        lda #0 
        sta Enemy0HWayPoint
        ;sta Enemy0VWayPoint
SkipRegenWayPoints

SkipEnemy0Movement   
        sta HMCLR

        lda Enemy0YPos
        clc
        adc #E0HEIGHT*2
        sta Enemy0YPosEnd
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Enemy 0 Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Enemy 1 Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        lda Enemy1GenTimer
        beq SkipEnemy1CountdownTimer
        dec Enemy1GenTimer
SkipEnemy1CountdownTimer

        lda Enemy1GenTimer
        cmp #1
        bne SkipGenerateEnemy1
DetermineEdgeE1
        lda INPT4
        jsr GetRandomNumber
        and #3
        sta Enemy1StartEdge

        lda #1
        sta Enemy1Alive
        
        ; Generate Start Pos
        lda Enemy1StartEdge
        cmp #0
        bne SkipTopE1StartEdge
        lda #0
        sta Enemy1YPos
        jmp E1StartEdgeSet
SkipTopE1StartEdge
        cmp #1
        bne SkipRightSideE1StartEdge
        lda #0
        sta Enemy1YPos
        jmp E1StartEdgeSet
SkipRightSideE1StartEdge
        cmp #2
        bne SkipBottomE1StartEdge
        lda #192-#E1HEIGHT-4
        sta Enemy1YPos
        jmp E1StartEdgeSet
SkipBottomE1StartEdge
        cmp #3
        bne SkipLeftSideE1StartEdge
        lda #192-#E1HEIGHT-4
        sta Enemy1YPos
        
SkipLeftSideE1StartEdge
E1StartEdgeSet
        lda INPT4
        jsr GetRandomNumber
        and #159
        sta Enemy1XPos

SkipGenerateEnemy1

        ldx #3
        lda Enemy1XPos
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR


        lda Enemy1GenTimer
        bne SkipEnemy1Alive
        lda #1
        sta Enemy1Alive
SkipEnemy1Alive

        lda Enemy1Alive
        beq SkipEnemy1Movement
Enemy1VectorPath
        ;; Do vector path code here
        lda Enemy1HWayPoint
        bne SkipGenerateNewE1WayPoints

RegenE1HSeed
        lda INPT4
        beq RegenE1HSeed
        jsr GetRandomNumber
        and #158
        ; and #2
        ; clc
        ; adc #70
        sta Enemy1HWayPoint

RegenE1VSeed
        lda INPT4
        beq RegenE1VSeed
        jsr GetRandomNumber
        and #148
        clc
        adc #34
        ; and #2
        ; clc
        ; adc #72
        sta Enemy1VWayPoint
SkipGenerateNewE1WayPoints

        lda Enemy1HWayPoint
        sec
        sbc Enemy1XPos
        bne SkipSetE1HMoveFlat
        lda #$0
        sta HMM1
        jmp SkipSetE1HMoveRight
SkipSetE1HMoveFlat
        bcc SkipSetE1HMoveLeft
        lda #$F0
        sta HMM1
        inc Enemy1XPos
        jmp SkipSetE1HMoveRight
SkipSetE1HMoveLeft
        bcs SkipSetE1HMoveRight
        lda #$10
        sta HMM1
        dec Enemy1XPos
SkipSetE1HMoveRight

        lda Enemy1VWayPoint
        sec
        sbc Enemy1YPos
        bne SkipSetE1VMoveFlat
        jmp SkipSetE1VMoveRight
SkipSetE1VMoveFlat
        bcc SkipSetE1VMoveLeft
        inc Enemy1YPos
        inc Enemy1YPos
        jmp SkipSetE1VMoveRight
SkipSetE1VMoveLeft
        bcs SkipSetE1VMoveRight
        dec Enemy1YPos
        dec Enemy1YPos
SkipSetE1VMoveRight

        ; lda Flasher
        ; and #1
        ; bne SkipHMOVEE1
        sta WSYNC
        sta HMOVE
SkipHMOVEE1

        lda Enemy1XPos
        sec
        sbc Enemy1HWayPoint
        bne SkipRegenWayPointsE1
        ;beq RegenWayPoints

        lda Enemy1YPos
        sec
        sbc Enemy1VWayPoint
        bne SkipRegenWayPointsE1
;RegenWayPoints
        lda #0 
        sta Enemy1HWayPoint
        ;sta Enemy0VWayPoint
SkipRegenWayPointsE1

SkipEnemy1Movement
        sta HMCLR

        lda Enemy1YPos
        clc
        adc #E1HEIGHT*2
        sta Enemy1YPosEnd
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Enemy 1 Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Scoring ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Score
        lda P0Score1
        sta P0Score1idx   
        
        asl
        asl
        clc
        adc P0Score1idx
        
        sta P0Score1idx
        
        lda #<(Zero_bank1)
        sta P0Score1DigitPtr

        lda #>(Zero_bank1)
        sta P0Score1DigitPtr+1

        lda P0Score2
        sta P0Score2idx   
        
        asl
        asl
        clc
        adc P0Score2idx
        sta P0Score2idx
        
        lda #<(Zero_bank1)
        sta P0Score2DigitPtr

        lda #>(Zero_bank1)
        sta P0Score2DigitPtr+1
P1Score
        lda P1Score1
        sta P1Score1idx   
        asl
        asl
        clc
        adc P1Score1idx
        sta P1Score1idx
        
        lda #<(Zero_bank1)
        sta P1Score1DigitPtr

        lda #>(Zero_bank1)
        sta P1Score1DigitPtr+1

        lda P1Score2
        sta P1Score2idx   
        asl
        asl
        clc
        adc P1Score2idx
        sta P1Score2idx
        
        lda #<(Zero_bank1)
        sta P1Score2DigitPtr

        lda #>(Zero_bank1)
        sta P1Score2DigitPtr+1   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #0
CalcScore
        ;P0
        txa
        clc
        adc P0Score1idx                                 ; 3
        tay                                             ; 2
        lda (P0Score1DigitPtr),y                        ; 5
        and #%00001111                                  ; 2    
        sta P0ScoreTmp                                  ; 3     

        txa
        clc   
        adc P0Score2idx                                 ; 3
        tay                                             ; 2
        lda (P0Score2DigitPtr),y                        ; 5
        and #%11110000                                  ; 2     

        ora P0ScoreTmp                                  ; 3     
        sta P0ScoreArr,x                                ; 3

        ;P1
        txa
        clc
        adc P1Score1idx                                 ; 3
        tay                                             ; 2
        lda (P1Score1DigitPtr),y                        ; 5
        and #%00001111                                  ; 2    
        sta P1ScoreTmp                                  ; 3     

        txa
        clc   
        adc P1Score2idx                                 ; 3
        tay                                             ; 2
        lda (P1Score2DigitPtr),y                        ; 5
        and #%11110000                                  ; 2     

        ora P1ScoreTmp                                  ; 3     
        sta P1ScoreArr,x                                ; 3

        inx
        cpx #5
        bcc CalcScore                                   ; 2/3 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Scoring ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Time Countdown Timer  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda CountdownTimer
        beq SkipTimer
        lda CountdownTimerInterval
        bne SkipCountdownTimer
        dec CountdownTimer
        lda CountdownTimer
        and #$0F
        cmp #$F
        bne SkipResetTimerHex
        lda CountdownTimer
        sec
        sbc #6
        sta CountdownTimer
SkipResetTimerHex

        lda #60
        sta CountdownTimerInterval
SkipCountdownTimer
        dec CountdownTimerInterval
SkipTimer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Time Countdown Timer  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Build Countdown Timer Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         jmp AlignBoundary
;         REPEAT 97

;         nop
;         REPEND
; AlignBoundary
        lda #<(Zero_bank1)
        sta CountdownTimerGfxPtr

        lda #>(Zero_bank1)
        sta CountdownTimerGfxPtr+1
        
        ldx #0
CalcCountdownTimer
        stx CountdownTimerIdx

        lda CountdownTimer
        and #$0F
        sta CountdownTimerTmp1
        asl
        asl
        clc
        adc CountdownTimerTmp1
        clc
        adc CountdownTimerIdx
        tay 
        lda (CountdownTimerGfxPtr),y 
        and #$0F
        sta CountdownTimerTmp1
        

        lda CountdownTimer
        and #$F0
        lsr
        lsr
        lsr
        lsr
        sta CountdownTimerTmp2
        asl
        asl
        clc
        adc CountdownTimerTmp2
        clc   
        adc CountdownTimerIdx
        tay 
        lda (CountdownTimerGfxPtr),y 
        and #$F0

        ora CountdownTimerTmp1

        sta CountdownTimerGfx,x
        inx
        cpx #5
        bne CalcCountdownTimer 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Build Countdown Timer Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GameWaitLoop_bank1
        ;lda INTIM
        lda TIMINT
        and #%10000000
        ;bne GameWaitLoop_bank1
        beq GameWaitLoop_bank1
; overscan
        sta HMCLR
;         ldx #1
; GameOverscan
;         sta WSYNC
;         dex
;         bne GameOverscan
        jmp FlyGameStartOfFrame


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Fly Game Game Over Screen  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FlyGameGameOverScreen
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
FlyGameGameOverScreenVerticalBlank
        sta WSYNC                                       ; 3
        dex                                             ; 2
        bne FlyGameGameOverScreenVerticalBlank          ; 2/3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End VBLANK Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldx #0
        
FlyGameGameOverViewableScreen
        lda #FLY_GAME_GAME_OVER_BACKGROUND_COLOR
        sta COLUBK
        sta WSYNC
        inx
        cpx #192
        bne FlyGameGameOverViewableScreen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Setup Overscan  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #2
        sta VBLANK

        lda #0
        sta COLUBK
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Setup Overscan  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #36
        sta TIM64T
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        lda DebounceCtr
        beq SkipDecDebounceCtr_FlyGame
        dec DebounceCtr
SkipDecDebounceCtr_FlyGame

        lda DebounceCtr
        bne SkipRestartGame
        ldy INPT4
        bmi SkipRestartGame
        jmp RestartFlyGame
SkipRestartGame

        ldx #0
GameOverWaitLoop_bank1
        lda TIMINT
        and #%10000000
        beq GameOverWaitLoop_bank1

        jmp FlyGameGameOverScreen


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Atari Paint  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AtariPaint
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
        ldx #37
AtariPaintVerticalBlank
        sta WSYNC
        dex
        bne AtariPaintVerticalBlank
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End VBLANK Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldx #0
        
AtariPaintViewableScreen
        lda #FLY_GAME_GAME_OVER_BACKGROUND_COLOR
        sta COLUBK
        sta WSYNC
        inx
        cpx #192
        bne AtariPaintViewableScreen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Setup Overscan  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #2
        sta VBLANK

        lda #0
        sta COLUBK
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Setup Overscan  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #36
        sta TIM64T
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        lda DebounceCtr
        beq SkipDecDebounceCtr_AtariPaint
        dec DebounceCtr
SkipDecDebounceCtr_AtariPaint


        ldx #0
AtariPaintWaitLoop_bank1
        lda TIMINT
        and #%10000000
        beq AtariPaintWaitLoop_bank1

        jmp AtariPaint

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Sub-Routines ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
;;;;;;;;;;; Calculate Horizontal Sprite Position ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Min 38 cycles
; Max 146 cycles 
; 
; X - The Object to place
; A - X Coordinate
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CalcXPos_bank1:
        sta WSYNC                                       ; 3
        sta HMCLR                                       ; 3
        sec                                             ; 2
.Divide15_bank1 
        sbc #15                                         ; 2
        bcs .Divide15_bank1                             ; 2/3
        eor #$07                                        ; 2
        asl                                             ; 2
        asl                                             ; 2
        asl                                             ; 2
        asl                                             ; 2
        sta RESP0,x                                     ; 3
        sta HMP0,x                                      ; 3
        
        rts                                             ; 6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; End Calculate Horizontal Sprite Position ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
;;;;;;;;;;; Calculate and Return a Random Number ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Min 11 cycles
; Max 12 cycles 
; 
; A - Seed For Random Number
;
; Returns:
; A - Random Number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetRandomNumber:
        lsr                                             ; 2
        bcc Skipeor                                     ; 2/3
        eor #$B4                                        ; 2     ;$8E,95,96,A6,AF,B1,B2,B4,B8,C3,C6,D4,E1,E7,F3,FA
Skipeor:
        rts                                             ; 6   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Sub-Routines ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Rom Data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PlayerGfx  .byte #%01111110
           .byte #%11111111
           .byte #%10000001
           .byte #%10000001
           .byte #%10000001
           .byte #%10000001
           .byte #%10000001
           .byte #%10000001
           .byte #%10000001
           .byte #%11111111
           .byte #%01111110
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000  
           .byte #%00000000
           .byte #%00000000

PlayerSlapGfx  
           .byte #%00000000
           .byte #%00000000
           .byte #%00000000
           .byte #%00000000
           .byte #%00000000
           .byte #%11111111
           .byte #%10000001
           .byte #%10000001
           .byte #%10000001
           .byte #%11111111
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00011000
           .byte #%00000000
           .byte #%00000000
           


        align 256
ON         .byte  #%11101110
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%11101010

O_         .byte  #%11100000
           .byte  #%10100000
           .byte  #%10100000
           .byte  #%10100000
           .byte  #%11100000

TW         .byte  #%11101010
           .byte  #%01001010
           .byte  #%01001110
           .byte  #%01001110
           .byte  #%01001110

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

FL         .byte  #%11101000
           .byte  #%10001000
           .byte  #%11001000
           .byte  #%10001000
           .byte  #%10001110

Y_         .byte  #%00000101
           .byte  #%00000111
           .byte  #%00000010
           .byte  #%00000010
           .byte  #%00000010

Space      .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000

Cursor     .byte  #%00001000
           .byte  #%00001100
           .byte  #%00001110
           .byte  #%00001100
           .byte  #%00001000

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

T          .byte  #%11101110
           .byte  #%01000100
           .byte  #%01000100
           .byte  #%01000100
           .byte  #%01000100

E_Letter   .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110

E_         .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000

_P         .byte  #%00001110
           .byte  #%00001010
           .byte  #%00001110
           .byte  #%00001000
           .byte  #%00001000

RE_bank1   .byte  #%11101110
           .byte  #%10101000
           .byte  #%11101110
           .byte  #%11001000
           .byte  #%10101110

IR         .byte  #%11101110
           .byte  #%01001010
           .byte  #%01001110
           .byte  #%01001100
           .byte  #%11101010

SS         .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110

_F         .byte  #%00001110
           .byte  #%00001000
           .byte  #%00001110
           .byte  #%00001000
           .byte  #%00001000

W          .byte  #%10101010
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%11101110
           .byte  #%11101110


Heart       .byte #%01100110
            .byte #%11111111
            .byte #%01111110
            .byte #%00111100
            .byte #%00011000

Zero_bank1 .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%10101010
           ;.byte  #%10101010
           .byte  #%10101010
           ;.byte  #%10101010
           .byte  #%10101010
           ;.byte  #%10101010
           .byte  #%11101110
           ;.byte  #%11101110

One_bank1        .byte  #%00100010
           ;.byte  #%00100010
           .byte  #%00100010
           ;.byte  #%00100010
           .byte  #%00100010
           ;.byte  #%00100010
           .byte  #%00100010
           ;.byte  #%00100010
           .byte  #%00100010
           ;.byte  #%00100010

Two_bank1  .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%00100010
           ;.byte  #%00100010
           .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%10001000
           ;.byte  #%10001000
           .byte  #%11101110
           ;.byte  #%11101110

Three_bank1 .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%00100010
           ;.byte  #%00100010
           .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%00100010
           ;.byte  #%00100010
           .byte  #%11101110
           ;.byte  #%11101110

Four_bank1 .byte  #%10101010
           ;.byte  #%10101010
           .byte  #%10101010
           ;.byte  #%10101010
           .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%00100010
           ;.byte  #%00100010
           .byte  #%00100010
           ;.byte  #%00100010

Five_bank1 .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%10001000
           ;.byte  #%10001000
           .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%00100010
           ;.byte  #%00100010
           .byte  #%11101110
           ;.byte  #%11101110

Six_bank1  .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%10001000
           ;.byte  #%10001000
           .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%10101010
           ;.byte  #%10101010
           .byte  #%11101110
           ;.byte  #%11101110

Seven_bank1 .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%00100010
           ;.byte  #%00100010
           .byte  #%00100010
           ;.byte  #%00100010
           .byte  #%00100010
           ;.byte  #%00100010
           .byte  #%00100010
           ;.byte  #%00100010

Eight_bank1 .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%10101010
           ;.byte  #%10101010
           .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%10101010
           ;.byte  #%10101010
           .byte  #%11101110
           ;.byte  #%11101110

Nine_bank1 .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%10101010
           ;.byte  #%10101010
           .byte  #%11101110
           ;.byte  #%11101110
           .byte  #%00100010
           ;.byte  #%00100010
           .byte  #%11101110
           ;.byte  #%11101110

        echo "----"
        echo "Rom Total Bank1:"
        echo "----",([$FFFC-.]d), "bytes free in Bank 1"
;-------------------------------------------------------------------------------
        ORG $2FFA
        RORG $FFFA
InterruptVectorsBank2
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
ENDBank2