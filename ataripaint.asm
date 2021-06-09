        processor 6502
        include includes/vcs.h
        include includes/macro.h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Global Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

BALL_SIZE_ONE_CLOCK             = #0
BALL_SIZE_TWO_CLOCKS            = #16
BALL_SIZE_FOUR_CLOCKS           = #32
BALL_SIZE_EIGHT_CLOCKS          = #48

P1_JOYSTICK_UP                  = #%00000001
P1_JOYSTICK_DOWN                = #%00000010
P1_JOYSTICK_LEFT                = #%00000100
P1_JOYSTICK_RIGHT               = #%00001000
P0_JOYSTICK_UP                  = #%00010000
P0_JOYSTICK_DOWN                = #%00100000
P0_JOYSTICK_LEFT                = #%01000000
P0_JOYSTICK_RIGHT               = #%10000000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Global Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

        echo "Ram Total Atari Music 0):"
        echo "----",([* - $80]d) ,"/", (* - $80) ,"bytes of RAM Used for Atari Music in Bank 0"
        echo "----",([$100 - *]d) ,"/", ($100 - *) , "bytes of RAM left for Atari Music in Bank 0"


        
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

; TODO: Atari Music
; TODO: Add Labels under controls to display usage
; TODO: Finalize Colors and Decor and Name

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
FLY_GAME_TITLE_HPOS                     = #59

FLY_GAME_GAME_BACKGROUND_COLOR          = #$0A
FLY_GAME_GAME_OVER_BACKGROUND_COLOR     = #$0A
FLY_GAME_GAME_OVER_RESTART_DELAY        = #60
FLY_GAME_COUNTDOWN_TIMER_SECOND_DIVIDER = #60
FLY_GAME_TIMER_DURATION                 = #153  ;#9  

P0XSTARTPOS                             = #15
P0YSTARTPOS                             = #78
P1XSTARTPOS                             = #125
P1YSTARTPOS                             = #78

PLAYERHEIGHT                            = #24
ENEMYHEIGHT                             = #4

PLAYER2JOIN_H_POS                       = #100
P2_JOIN_FLASHRATE                       = #52

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
P1FireDebounceCtr       ds 1
BlockP0Fire             ds 1
BlockP1Fire             ds 1
LetterBuffer2           ds 1
LineTemp2               ds 1
YTemp2                  ds 1
Flasher                 ds 1
GameOverFlag            ds 1
Winner                  ds 5
CountdownTimer          ds 1
CountdownTimerInterval  ds 1
CountdownTimerTmp1      ds 1
CountdownTimerTmp2      ds 1
CountdownTimerIdx       ds 1
CountdownTimerGfx       ds 5
CountdownTimerGfxPtr    ds 2


Player0XPos             ds 1
Player1XPos             ds 1

Player0YPos             ds 1
Player1YPos             ds 1

Player0YPosEnd          ds 1
Player1YPosEnd          ds 1

Player0YPosTmp          ds 1
Player1YPosTmp          ds 1

DrawP0Sprite            ds 1
DrawP1Sprite            ds 1

P0SprIdx                ds 1
P1SprIdx                ds 1

Player0GfxPtr           ds 2
Player1GfxPtr           ds 2

P0Height                ds 1
P1Height                ds 1

Enemy0XPos              ds 1
Enemy1XPos              ds 1

Enemy0YPos              ds 1
Enemy1YPos              ds 1

Enemy0YPosEnd           ds 1
Enemy1YPosEnd           ds 1

Enemy0StartEdge         ds 1
Enemy1StartEdge         ds 1

Enemy0Alive             ds 1
Enemy1Alive             ds 1

Enemy0GenTimer          ds 1
Enemy1GenTimer          ds 1

Enemy0HWayPoint         ds 1
Enemy1HWayPoint         ds 1

Enemy0VWayPoint         ds 1
Enemy1VWayPoint         ds 1

P0Score                 ds 1
P1Score                 ds 1

P0Score1                ds 1
P1Score1                ds 1

P0Score2                ds 1
P1Score2                ds 1

P0Score1idx             ds 1
P1Score1idx             ds 1

P0Score1DigitPtr        ds 2
P1Score1DigitPtr        ds 2

P0ScoreTmp              ds 1
P1ScoreTmp              ds 1

P0Score2idx             ds 1
P1Score2idx             ds 1

P0Score2DigitPtr        ds 2
P1Score2DigitPtr        ds 2

P0ScoreArr              ds 5
P1ScoreArr              ds 5

FlyGameNotePtrCh0     ds 2
FlyGameNotePtrCh1     ds 2
FlyGameFrameCtrTrk0   ds 1
FlyGameFrameCtrTrk1   ds 1


        echo "----"
        echo "Ram Total Fly Game(Bank 1):"
        echo "----",([* - $80]d) ,"/", (* - $80) ,"bytes of RAM Used for Fly Game in Bank 1"
        echo "----",([$100 - *]d) ,"/", ($100 - *) , "bytes of RAM left for Fly Game in Bank 1"
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
        sta P1FireDebounceCtr

        ldy #FLY_GAME_TITLE_COLOR
        sty COLUPF

        ldy #FLY_GAME_TITLE_COLOR
        sty COLUP0
        sty COLUP1

        ldx #0
        lda #FLY_GAME_TITLE_HPOS
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
        
        ldx #1
        lda #FLY_GAME_TITLE_HPOS+8
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
                
        lda #TWO_COPIES_CLOSE
        sta NUSIZ0

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

FlyGameTitleLine1
        cpx #FLY_GAME_TITLE_VPOS
        bmi SkipFlyGameTitleLine1
        txa
        sbc #FLY_GAME_TITLE_VPOS
        lsr
        lsr
        tay

        lda FL,y
        sta PF1
        lda Y_,y
        sta PF2
        
        SLEEP 3

        lda #0
        sta PF1
        sta PF2
SkipFlyGameTitleLine1
        inx
        cpx #FLY_GAME_TITLE_VPOS+20
        sta WSYNC
        bmi FlyGameTitleLine1
        
FlyGameTitleLine2
        cpx #FLY_GAME_TITLE_VPOS+26
        bmi SkipFlyGameTitleLine2
        txa
        sbc #FLY_GAME_TITLE_VPOS+26
        lsr
        lsr
        tay

        lda GA,y
        sta PF1
        lda MER,y
        sta PF2

        SLEEP 8

        lda #0
        sta PF1
        sta PF2
SkipFlyGameTitleLine2
        inx
        cpx #FLY_GAME_TITLE_VPOS+46
        sta WSYNC
        bmi FlyGameTitleLine2


;;;;;;;;;;;;;;; End Draw Playfield ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
FlyGameNumPlayersSelectLine1 
        cpx #135
        bmi SkipFlyGameNumPlayersSelectLine1
        txa                                             ; 2
        sec                                             ; 2
        sbc #135                                        ; 2
        tay                                             ; 2
        lda (Game1SelectionGfx),y                       ; 4
        sta GRP0                                        ; 3
        lda ON,y                                        ; 4
        sta GRP1                                        ; 3

        SLEEP 8                                        ; 12

        lda E_,y                                        ; 4
        sta GRP0                                        ; 3
SkipFlyGameNumPlayersSelectLine1
        inx
        cpx #141
        sta WSYNC
        bne FlyGameNumPlayersSelectLine1

FlyGameNumPlayersSelectLine2 
        cpx #145
        bmi SkipFlyGameNumPlayersSelectLine2
        txa                                             ; 2
        sec
        sbc #145                                        ; 2
        tay                                             ; 2 
        lda (Game2SelectionGfx),y                       ; 4
        sta GRP0                                        ; 3
        lda TW,y                                        ; 4
        sta GRP1                                        ; 3

        SLEEP 8                                        ; 12

        lda O_,y                                        ; 4
        sta GRP0                                        ; 3
SkipFlyGameNumPlayersSelectLine2
        inx
        cpx #151
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
        lda #37
        sta TIM64T

        lda DebounceCtr
        beq SkipDecDebounceCtr_FlyGameTitleScreen
        dec DebounceCtr
SkipDecDebounceCtr_FlyGameTitleScreen

        lda SWCHB
        and #%00000010
        ora DebounceCtr
        ;bne SkipSwitchToBank0
        bne SkipSwitchToAtariPaint
        ; Put game select logic code here
        ;jmp SwitchToBank0
        jmp AtariPaint
;SkipSwitchToBank0
SkipSwitchToAtariPaint

        lda DebounceCtr
        bne DontStartGame
SkipDecDebounceCtr_Bank1
        lda INPT4
        bmi DontStartGame
        sta SkipGameFlag
DontStartGame

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
        
        ; if down pressed Game2SelectionGfx
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
        
FlyGameTitleScreenOverscanWaitLoop
        lda INTIM
        bne FlyGameTitleScreenOverscanWaitLoop

        jmp StartOfFlyGameTitleScreenFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Game Start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TODO: FlyGame

; TODO: Enemy position seems off
; TODO: Add Music
; TODO: Set Player and Game Colors

; TODO: Condense Ram
; TODO: Add Enemy Lifecycle
; TODO: More Randomization in Enemy Gen


PlayFlyGame
FlyGameScreen
        lda #P0XSTARTPOS
        sta Player0XPos

        ldx #P0YSTARTPOS
        stx Player0YPos

        lda GameSelectFlag
        beq OnePlayerGame
        lda #P1XSTARTPOS
        sta Player1XPos
        lda #P1YSTARTPOS
        sta Player1YPos
OnePlayerGame

        ldx #100
        stx Enemy0GenTimer
        stx Enemy1GenTimer

        lda #<FlyGameTrack0                     ; Init for Rom Music Player
        sta FlyGameNotePtrCh0
        lda #>FlyGameTrack0
        sta FlyGameNotePtrCh0+1

        lda #<FlyGameTrack1                     ; Init for Rom Music Player
        sta FlyGameNotePtrCh1
        lda #>FlyGameTrack1
        sta FlyGameNotePtrCh1+1
        
        ldx #FLY_GAME_TIMER_DURATION
        stx CountdownTimer

        lda #FLY_GAME_COUNTDOWN_TIMER_SECOND_DIVIDER
        sta CountdownTimerInterval

FlyGameStartOfFrame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start VBLANK Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
        lda #43
        sta TIM64T

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Scoring ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0ScoreCalc
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
P1ScoreCalc
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
CalcScoreGraphics
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
        bcc CalcScoreGraphics                           ; 2/3 
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
        cmp #$0F
        bne SkipResetTimerHex
        
        lda CountdownTimer
        sec
        sbc #6
        sta CountdownTimer
SkipResetTimerHex

        lda #FLY_GAME_COUNTDOWN_TIMER_SECOND_DIVIDER
        sta CountdownTimerInterval
SkipCountdownTimer
        dec CountdownTimerInterval
SkipTimer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Time Countdown Timer  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Determine Winner  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda GameOverFlag
        beq SkipDetermineWinner
        ldy #0
LoadWinner
        
        lda P0Score
        sec
        sbc P1Score
        bpl Player0Wins
        lda Two_bank1,y
        and #$0F
        sta Winner,y
        jmp Player1Wins
Player0Wins
        lda One_bank1,y
        and #$0F
        sta Winner,y
Player1Wins

        iny
        cpy #5
        bne LoadWinner
SkipDetermineWinner
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Determine Winner  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Build Countdown Timer Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
        
        lda #0
        sta GRP0
        sta GRP1
        sta GRP0
        
        ldx #0
        lda #PLAYER2JOIN_H_POS
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE

        ldx #1
        lda #PLAYER2JOIN_H_POS+8
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE

        lda #THREE_COPIES_CLOSE
        sta NUSIZ0
        sta NUSIZ1
        
FlyGameVerticalBlank
        lda TIMINT
        and #%10000000
        beq FlyGameVerticalBlank
        sta WSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End VBLANK Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda CountdownTimer
        bne SkipFlyGameGameoverScreen

        lda GameOverFlag
        bne SkipSetGameOverRestartDelay
        ldy #FLY_GAME_GAME_OVER_RESTART_DELAY
        sty BlockP0Fire
SkipSetGameOverRestartDelay
        lda #1
        sta GameOverFlag
SkipFlyGameGameoverScreen

        lda #FLY_GAME_GAME_BACKGROUND_COLOR
        sta COLUBK

        ldy #1
        sty VDELP0
        sty VDELP1

        ldx #0
        IF PLAYER2JOIN_H_POS <= 47
         sta WSYNC
        ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Viewable Screen Start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda GameSelectFlag
        bne FlashFire

        ldy #0
        lda Flasher
        cmp #P2_JOIN_FLASHRATE/2-10
        bcs GameViewableScreen

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Player 2 Join Text ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #65
        sta TIM1T

FlyGamePlayer2JoinTextTimerDelay
        lda TIMINT
        and #%10000000
        beq FlyGamePlayer2JoinTextTimerDelay
        SLEEP 5  

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
        stx GRP0                                        ; 3     60       ?? -> [GRP0], [GRP1] -> GRP1
        
        ldx LineTemp2                                   ; 3     63
        ldy YTemp2                                      ; 3     66
        iny                                             ; 2     68

        inx                                             ; 2     70
        cpx #9                                          ; 2     72
        nop                                             ; 2     74
        nop                                             ; 2     76
        bne DrawPlayer2JoinText                         ; 2/3   2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Player 2 Join Text ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
Player2Buffer
        lda #DOUBLE_SIZE_PLAYER
        sta NUSIZ0
        sta NUSIZ1
        lda #0
        sta VDELP0
        sta VDELP1
        sta GRP0
        sta GRP1
        inx
        sta WSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Align Countdown Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #22
        sta TIM1T

PositionCountdownTimer
        lda TIMINT
        and #%10000000
        beq PositionCountdownTimer
        
        SLEEP 3

        sta RESP0

        inx
        sta WSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Align Countdown Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Drawing Score Area ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
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
        
        lda #0                                          ; 2
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
        sta PF2                                         ; 3
        
        sta WSYNC                                       ; 3
        sta WSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Drawing Score Area ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldx #0
        stx COLUBK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Adjust WSYNC for Player 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda Player0XPos
        cmp #$87
        bcs SkipWSYNC
        sta WSYNC
SkipWSYNC

        lda Player1XPos
        cmp #$87
        bcs SkipWSYNC2
        sta WSYNC
SkipWSYNC2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Adjust WSYNC for Player 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        ldx #0
        lda Player0XPos
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE

        ldx #1
        lda Player1XPos
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
        
        ldx #1
        stx VDELP0
        
        ldx #39
        
ScoreAreaBuffer
        inx
        lda #FLY_GAME_GAME_BACKGROUND_COLOR
        sta WSYNC
        ldy GameOverFlag
        bne DrawGameOverScreen
        
        sta COLUBK
        lda #0
        ldy #2
        inx 
        sta WSYNC
        inx 
        
        sta WSYNC
        SLEEP 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Drawing Players and Enemy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FlyGameBoard        
        cpx Enemy0YPos                          ; 3
        bne SkipDrawE0                          ; 2/3
        sty ENAM0                               ; 3     (8)
SkipDrawE0

        cpx Enemy1YPos                          ; 3
        bne SkipDrawE1                          ; 2/3
        sty ENAM1                               ; 3     (8)
SkipDrawE1

        cpx Player0YPos                         ; 3
        bne SkipSetDrawP0Flag                   ; 2/3
        sty DrawP0Sprite                        ; 3     (10)
SkipSetDrawP0Flag

        cpx Player1YPos                         ; 3
        bne SkipSetDrawP1Flag                   ; 2/3
        sty DrawP1Sprite                        ; 3     (8)
SkipSetDrawP1Flag

        ldy P0SprIdx                            ; 3
        cpy P0Height                            ; 2
        bne SkipP0ResetHeight                   ; 2/3
        sta P0SprIdx                            ; 3
        sta DrawP0Sprite                        ; 3     (13)
SkipP0ResetHeight

        lda DrawP0Sprite                        ; 3
        beq SkipP0Draw                          ; 2/3
        ldy P0SprIdx                            ; 3
        lda (Player0GfxPtr),y                   ; 5
        sta GRP0                                ; 3
        inc P0SprIdx                            ; 5     (21)
SkipP0Draw

        sta WSYNC                               ; 3     (3)     (71)+3 from branch
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #0                                  ; 2
        sta GRP1                                ; 3     (5)
        
        lda DrawP1Sprite                        ; 3
        beq SkipP1Draw                          ; 2/3
        ldy P1SprIdx                            ; 3
        lda (Player1GfxPtr),y                   ; 5
        sta GRP1                                ; 3
        inc P1SprIdx                            ; 5     (21)
SkipP1Draw
        
        lda #0                                  ; 2
        cpx Enemy0YPosEnd                       ; 3
        bne SkipE0Reset                         ; 2/3
        sta ENAM0                               ; 3     (10)
SkipE0Reset

        cpx Enemy1YPosEnd                       ; 3
        bne SkipE1Reset                         ; 2/3
        sta ENAM1                               ; 3     (8)
SkipE1Reset

        ldy P1SprIdx                            ; 3
        cpy P1Height                            ; 2
        bne SkipP1ResetHeight                   ; 2/3
        sta P1SprIdx                            ; 3
        sta DrawP1Sprite                        ; 3     (13)
SkipP1ResetHeight
        ldy #2                                  ; 2
        inx                                     ; 2
        inx                                     ; 2
        cpx #192                                ; 2
        sta WSYNC                               ; 3
        bne FlyGameBoard                        ; 2/3   (14)    (71)
        
        jmp EndofViewableScreen                 ; 3
        
        ; TODO: Game Over
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Game Over Screen Start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DrawGameOverScreen
        sta COLUBK
        lda #1
        sta VDELP0
        sta VDELP1

        lda #THREE_COPIES_CLOSE
        sta NUSIZ0
        sta NUSIZ1

        ldx #0                                  ; Set Player 0 Position
        lda #ATARI_PAINT_TITLE_H_POS
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE

        ldx #1                                  ; Set Player 1 Position
        lda #ATARI_PAINT_TITLE_H_POS+8
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE

        ldx #46
DrawGameOverScreenTop
        inx
        cpx #57
        sta WSYNC
        bne DrawGameOverScreenTop

        lda GameSelectFlag
        bne TwoPlayerGameOver

        ldy #0
        inx
        sta WSYNC

        lda #55
        sta TIM1T

OnePlayerGameOverTextDelay
        lda TIMINT
        and #%10000000
        beq OnePlayerGameOverTextDelay
        SLEEP 5  


DrawGameOverScreenText1Player
        stx LineTemp2                                   ; 3     6
        sty YTemp2                                      ; 3     9
        
        ldx Zero_bank1,y                                ; 4     13
        stx LetterBuffer2                               ; 3     16
        
        ldx P0ScoreArr,y                                ; 4     20

        lda SC,y                                        ; 4     24
        sta GRP0                                        ; 3     27       -> [GRP0]
        
        lda OR,y                                        ; 4     31
        sta GRP1                                        ; 3     34       -> [GRP1], [GRP0] -> GRP0
        
        lda EColon,y                                    ; 4     38
        sta GRP0                                        ; 3     41       -> [GRP0]. [GRP1] -> GRP1
        
        lda Space,y                                     ; 4     45
        ldy LetterBuffer2                               ; 3     48
        sta GRP1                                        ; 3     51       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     54       -> [GRP0], [GRP1] -> GRP1
        sty GRP1                                        ; 3     57       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     60       ?? -> [GRP0], [GRP1] -> GRP1
        
        ldx LineTemp2                                   ; 3     63
        ldy YTemp2                                      ; 3     66
        iny                                             ; 2     68

        inx                                             ; 2     70

        cpx #63                                         ; 2     72
        nop                                             ; 2     74
        nop                                             ; 2     76
        ; SLEEP 3
        bne DrawGameOverScreenText1Player

        lda #0
        sta GRP0
        sta GRP1
        sta GRP0
        jmp DrawGameOverScreenMiddle

TwoPlayerGameOver
        
        ldy #0
        inx
        sta WSYNC

        lda #55
        sta TIM1T

        lda P0Score
        cmp P1Score
        beq DrawGameOverScreenText2PlayerTieGame

TwoPlayerGameOverTextDelay
        lda TIMINT
        and #%10000000
        beq TwoPlayerGameOverTextDelay
        SLEEP 5  

        ;inx
DrawGameOverScreenText2Player
        stx LineTemp2                                   ; 3     6
        sty YTemp2                                      ; 3     9
        
        ldx IN,y                                        ; 4     13
        stx LetterBuffer2                               ; 3     16
        
        ldx _W,y                                        ; 4     20

        lda PL,y                                        ; 4     24
        sta GRP0                                        ; 3     27       -> [GRP0]
        
        lda AY,y                                        ; 4     31
        sta GRP1                                        ; 3     34       -> [GRP1], [GRP0] -> GRP0
        
        lda ER,y                                        ; 4     38
        sta GRP0                                        ; 3     41       -> [GRP0]. [GRP1] -> GRP1
        
        lda Winner,y                                    ; 4     45
        ldy LetterBuffer2                               ; 3     48
        sta GRP1                                        ; 3     51       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     54       -> [GRP0], [GRP1] -> GRP1
        sty GRP1                                        ; 3     57       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     60       ?? -> [GRP0], [GRP1] -> GRP1
        
        ldx LineTemp2                                   ; 3     63
        ldy YTemp2                                      ; 3     66
        iny                                             ; 2     68

        inx                                             ; 2     70

        cpx #63                                         ; 2     72
        nop                                             ; 2     74
        nop                                             ; 2     76
        bne DrawGameOverScreenText2Player

        lda #0
        sta GRP0
        sta GRP1
        sta GRP0
        jmp DrawGameOverScreenMiddle

DrawGameOverScreenText2PlayerTieGame

TwoPlayerGameOverTieGameTextDelay
        lda TIMINT
        and #%10000000
        beq TwoPlayerGameOverTieGameTextDelay
        SLEEP 4 

DrawGameOverScreenTieGameText2Player
        stx LineTemp2                                   ; 3     6
        sty YTemp2                                      ; 3     9
        
        ldx Space,y                                        ; 4     13
        stx LetterBuffer2                               ; 3     16
        
        ldx ME,y                                        ; 4     20

        lda _T,y                                        ; 4     24
        sta GRP0                                        ; 3     27       -> [GRP0]
        
        lda IE,y                                        ; 4     31
        sta GRP1                                        ; 3     34       -> [GRP1], [GRP0] -> GRP0
        
        lda Space,y                                        ; 4     38
        sta GRP0                                        ; 3     41       -> [GRP0]. [GRP1] -> GRP1
        
        lda GA,y                                        ; 4     45
        ldy LetterBuffer2                               ; 3     48
        sta GRP1                                        ; 3     51       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     54       -> [GRP0], [GRP1] -> GRP1
        sty GRP1                                        ; 3     57       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     60       ?? -> [GRP0], [GRP1] -> GRP1
        
        ldx LineTemp2                                   ; 3     63
        ldy YTemp2                                      ; 3     66
        iny                                             ; 2     68

        inx                                             ; 2     70

        cpx #63                                         ; 2     72
        nop                                             ; 2     74
        nop                                             ; 2     76
        bne DrawGameOverScreenTieGameText2Player

        lda #0
        sta GRP0
        sta GRP1
        sta GRP0


DrawGameOverScreenMiddle
        inx
        cpx #100
        sta WSYNC
        bne DrawGameOverScreenMiddle

        ldy #0
        inx
        sta WSYNC
        
        lda #55
        sta TIM1T

GameOverTextDelay
        lda TIMINT
        and #%10000000
        beq GameOverTextDelay
        SLEEP 4


        ;inx
DrawGameOverScreenBottomText
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
        stx GRP0                                        ; 3     60       ?? -> [GRP0], [GRP1] -> GRP1
        
        ldx LineTemp2                                   ; 3     63
        ldy YTemp2                                      ; 3     66
        iny                                             ; 2     68

        inx                                             ; 2     70
        cpx #106                                        ; 2     72
        nop                                             ; 2     74
        nop                                             ; 2     76
        bne DrawGameOverScreenBottomText

        lda #0
        sta GRP0
        sta GRP1
        sta GRP0
        
DrawGameOverScreenBottom
        inx                                     ; 2
        cpx #192                                ; 2
        sta WSYNC
        bne DrawGameOverScreenBottom
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Game Over Screen Start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; TODO: FlyGame Overscan
EndofViewableScreen
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

        lda P1FireDebounceCtr
        beq GameSkipP1FireDecDebounceCtr
        dec P1FireDebounceCtr
GameSkipP1FireDecDebounceCtr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Check Debouce Counter ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check Bank Switching ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda SWCHB
        and #%00000010
        ora DebounceCtr
        ;bne GameSkipSwitchToBank0
        bne GameSkipSwitchToAtariPaint
        ; Put game select logic code here
        jmp AtariPaint
        ;jmp SwitchToBank0
;GameSkipSwitchToBank0
GameSkipSwitchToAtariPaint
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Restart Fly Game ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda DebounceCtr
        bne SkipRestartFlyGame
        lda GameOverFlag
        cmp #1
        bne SkipRestartFlyGame
        
        lda BlockP0Fire
        bne DecrementP0BlockFire

        lda INPT4
        bmi SkipRestartFlyGame
        jmp RestartFlyGame
DecrementP0BlockFire
        
        dec BlockP0Fire
SkipRestartFlyGame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Restart Fly Game ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Game Over Skip Controls ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda GameOverFlag
        beq SkipDisableControls
        jmp SkipPlayerControls
SkipDisableControls
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Game Over Skip Controls ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Player 2 Join Game ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda GameSelectFlag
        bne SkipP1JoinGame
        
        lda INPT5
        bmi SkipP1JoinGame

        lda #1
        sta GameSelectFlag

        lda #P1XSTARTPOS
        sta Player1XPos
        lda #P1YSTARTPOS
        sta Player1YPos
        
SkipP1JoinGame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Player 2 Join Game ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

        cpy #40
        bne SkipSetP0MinVPos
        ldy #42
SkipSetP0MinVPos

        cpy #168
        bne SkipSetP0MaxVPos
        ldy #166
SkipSetP0MaxVPos
        sty Player0YPos

; Player 0 Left/Right Control
        lda #P0_JOYSTICK_LEFT         
        and SWCHA
        bne SkipMoveP0Left
        dec Player0XPos
SkipMoveP0Left

        lda #P0_JOYSTICK_RIGHT
        and SWCHA
        bne SkipMoveP0Right
        inc Player0XPos
SkipMoveP0Right
       
        ldy #0
        ldx Player0XPos
        bne SkipSetP0MinHPos
        inc Player0XPos
SkipSetP0MinHPos

        cpx #160-#16
        bne SkipSetP0MaxHPos
        dec Player0XPos
SkipSetP0MaxHPos
SkipP0Move
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Player 0 Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Player 1 Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Player1Control
; Player 1 Up/Down Control
        ldy Player1YPos
        
        lda #P1_JOYSTICK_UP            
        bit SWCHA
        bne SkipMoveP1Up
        dey
        dey
SkipMoveP1Up

        lda #P1_JOYSTICK_DOWN
        bit SWCHA
        bne SkipMoveP1Down
        iny
        iny
SkipMoveP1Down

        cpy #40
        bne SkipSetP1MinVPos
        ldy #42
SkipSetP1MinVPos

        cpy #168
        bne SkipSetP1MaxVPos
        ldy #166
SkipSetP1MaxVPos
        sty Player1YPos

; Player 1 Left/Right Control
        lda #P1_JOYSTICK_LEFT         
        and SWCHA
        bne SkipMoveP1Left
        dec Player1XPos
SkipMoveP1Left

        lda #P1_JOYSTICK_RIGHT
        and SWCHA
        bne SkipMoveP1Right
        inc Player1XPos
SkipMoveP1Right
       
        ; ldy #0
        ldx Player1XPos
        bne SkipSetP1MinHPos
        inc Player1XPos
SkipSetP1MinHPos

        cpx #160-#16
        bne SkipSetP1MaxHPos
        dec Player1XPos
SkipSetP1MaxHPos
SkipP1Move
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Player 1 Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Hide Players Sprite Overflow ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0
HidePlayerSpriteOverflow
        
        lda #PLAYERHEIGHT
        sta P0Height,Y
        
        lda #135
        cmp Player0YPos,y
        bcs SkipHideP0Overflow
        
        lda #192
        sbc Player0YPos,y               ; need carry not set so it's even
        lsr
        sta P0Height,y

SkipHideP0Overflow
        iny
        cpy #2
        bne HidePlayerSpriteOverflow 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Hide Players Sprite Overflow ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Players Detect Hit ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #0
PlayerDetectHit
        ldy #0

        lda DebounceCtr,x
        beq P0Fire2
        jmp P0SkipFire
P0Fire2

        lda BlockP0Fire,x
        beq P0Fire3
        jmp SkipP0HitDetection
P0Fire3

        lda INPT4,x
        bpl P0Fire
        jmp P0NotFire 
P0Fire
        lda #1
        sta BlockP0Fire,x

        lda #8
        sta DebounceCtr,x

        cpx #0
        bne LoadPlayer1SwatGfx
        lda #<PlayerSlapGfx
        sta Player0GfxPtr

        lda #>PlayerSlapGfx
        sta Player0GfxPtr+1
        jmp CheckEnemyHitP0
LoadPlayer1SwatGfx
        lda #<PlayerSlapGfx
        sta Player1GfxPtr

        lda #>PlayerSlapGfx
        sta Player1GfxPtr+1

CheckEnemyHitP0
        lda Player0XPos,x
        cmp Enemy0XPos,y
        bcs SkipP0Enemy0Hit
        clc
        adc #17
        cmp Enemy0XPos,y
        bcc SkipP0Enemy0Hit

        lda Player0YPos,x
        sec
        sbc #ENEMYHEIGHT*2-1
        cmp Enemy0YPos,y
        bcs SkipP0Enemy0Hit
        clc
        adc #28
        cmp Enemy0YPos,y
        bcc SkipP0Enemy0Hit

        lda #0
        sta Enemy0Alive,y
        sta Enemy0YPos,y

        lda #150
        sta Enemy0GenTimer,y

        inc P0Score,x
        inc P0Score1,x
        lda P0Score1,x
        cmp #10
        bne SkipP0Enemy0Hit
        lda #0
        sta P0Score1,x
        inc P0Score2,x

SkipP0Enemy0Hit

        iny 
        cpy #2
        bne CheckEnemyHitP0

        jmp P0SkipFire

SkipP0HitDetection

P0NotFire
        lda INPT4,x
        bpl P0NotFire2
        lda #0
        sta BlockP0Fire,x
P0NotFire2
        lda DebounceCtr,x
        bne P0SkipFire

        cpx #0
        bne LoadPlayer1Gfx
        lda #<PlayerGfx
        sta Player0GfxPtr

        lda #>PlayerGfx
        sta Player0GfxPtr+1
        jmp P0SkipFire
LoadPlayer1Gfx
        lda #<PlayerGfx
        sta Player1GfxPtr

        lda #>PlayerGfx
        sta Player1GfxPtr+1

P0SkipFire
        inx 
        cpx #2
        beq SkipPlayerDetectHit
        jmp PlayerDetectHit
SkipPlayerDetectHit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Players Detect Hit ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Enemys Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        

        ldx #0
EnemyMovement
        lda Enemy0GenTimer,x
        beq SkipEnemy0CountdownTimer
        dec Enemy0GenTimer,x
SkipEnemy0CountdownTimer

        lda SWCHB
        and #%01000000
        bne MoveEnemies
        lda Flasher
        and #1
        beq MoveEnemies
        jmp SkipEnemyMovement2
MoveEnemies
        lda Enemy0GenTimer,x
        cmp #1
        bne SkipGenerateEnemy0
DetermineEdge
        lda INPT4
        jsr GetRandomNumber
        and #3
        sta Enemy0StartEdge,x

        lda #1
        sta Enemy0Alive,x

        ; Generate Start Pos
        lda Enemy0StartEdge,x
        ; cmp #0
        bne SkipTopE0StartEdge
        lda #0
        sta Enemy0YPos,x
        jmp E0StartEdgeSet
SkipTopE0StartEdge
        cmp #1
        bne SkipRightSideE0StartEdge
        lda #0
        sta Enemy0YPos,x
        jmp E0StartEdgeSet
SkipRightSideE0StartEdge
        cmp #2
        bne SkipBottomE0StartEdge
        lda #192-#ENEMYHEIGHT-4
        sta Enemy0YPos,x
        jmp E0StartEdgeSet
SkipBottomE0StartEdge
        cmp #3
        bne SkipLeftSideE0StartEdge
        lda #192-#ENEMYHEIGHT-4
        sta Enemy0YPos,x
        
SkipLeftSideE0StartEdge
E0StartEdgeSet
        lda INPT4
        jsr GetRandomNumber
        and #159
        sta Enemy0XPos,x

SkipGenerateEnemy0

        lda Enemy0XPos,x
        stx LineTemp
        
        cpx #0
        bne ExecuteEnemy1Pos
        ldx #2
        jmp ExecuteEnemy0Pos
ExecuteEnemy1Pos
        ldx #3
ExecuteEnemy0Pos
        jsr CalcXPos_bank1


        sta WSYNC
        sta HMOVE    
        ldx LineTemp

        lda Enemy0GenTimer,x
        bne SkipEnemy0Alive
        lda #1
        sta Enemy0Alive,x
SkipEnemy0Alive

        lda Enemy0Alive,x
        beq SkipEnemy0Movement
Enemy0VectorPath
        ;; Do vector path code here
        lda Enemy0HWayPoint,x
        bne SkipGenerateNewE0WayPoints

RegenE0HSeed
        lda INPT4
        beq RegenE0HSeed
        jsr GetRandomNumber
        and #158
        ; and #2
        ; clc
        ; adc #70
        sta Enemy0HWayPoint,x

RegenE0VSeed
        lda INPT4,x
        beq RegenE0VSeed
        jsr GetRandomNumber
        and #148
        clc
        adc #38
        ; and #2
        ; clc
        ; adc #72
        sta Enemy0VWayPoint,x
SkipGenerateNewE0WayPoints

        lda Enemy0HWayPoint,x
        sec
        sbc Enemy0XPos,x
        bne SkipSetE0HMoveFlat
        ; lda #$0
        ; sta HMM0,x
        jmp SkipSetE0HMoveRight
SkipSetE0HMoveFlat
        bcc SkipSetE0HMoveLeft
        ; lda #$F0
        ; sta HMM0,x
        inc Enemy0XPos,x
        jmp SkipSetE0HMoveRight
SkipSetE0HMoveLeft
        bcs SkipSetE0HMoveRight
        ; lda #$10
        ; sta HMM0,x
        dec Enemy0XPos,x
SkipSetE0HMoveRight

        lda Enemy0VWayPoint,x
        sec
        sbc Enemy0YPos,x
        bne SkipSetE0VMoveFlat
        jmp SkipSetE0VMoveRight
SkipSetE0VMoveFlat
        bcc SkipSetE0VMoveLeft
        inc Enemy0YPos,x
        inc Enemy0YPos,x
        jmp SkipSetE0VMoveRight
SkipSetE0VMoveLeft
        bcs SkipSetE0VMoveRight
        dec Enemy0YPos,x
        dec Enemy0YPos,x
SkipSetE0VMoveRight

        lda SWCHB
        and #%10000000
        bne CrazyEnemies

        lda Enemy0XPos,x
        sec
        sbc Enemy0HWayPoint,x
        bne SkipRegenWayPoints
        jmp SkipCrazyEnemies
CrazyEnemies
        lda Enemy0XPos,x
        sec
        sbc Enemy0HWayPoint,x
        beq RegenWayPoints
SkipCrazyEnemies
        lda Enemy0YPos,x
        sec
        sbc Enemy0VWayPoint,x
        bne SkipRegenWayPoints
RegenWayPoints
        lda #0 
        sta Enemy0HWayPoint,x
SkipRegenWayPoints

SkipEnemy0Movement   
        sta HMCLR

        lda Enemy0YPos,x
        clc
        adc #ENEMYHEIGHT*2
        sta Enemy0YPosEnd,x
SkipEnemyMovement2
        inx
        cpx #2
        beq SkipEnemyMovement
        jmp EnemyMovement
SkipEnemyMovement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Enemys Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipPlayerControls

;;;;;;;;;;;;;;;;;;;; Rom Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0                                          ; 2     Initialize Y-Index to 0
        lda (FlyGameNotePtrCh0),y                       ; 5     Load first note duration to A
        cmp FlyGameFrameCtrTrk0                         ; 3     See if it equals the Frame Counter
        beq FlyGameTrack0NextNote                       ; 2/3   If so move the NotePtr to the next note

        cmp #255                                        ; 2     See if the notes duration equals 255
        bne FlyGameSkipResetTrack0                      ; 2/3   If so go back to the beginning of the track

        lda #<FlyGameTrack0                             ; 4     Store the low byte of the track to 
        sta FlyGameNotePtrCh0                           ; 3     the Note Pointer
        lda #>FlyGameTrack0                             ; 4     Store the High byte of the track to
        sta FlyGameNotePtrCh0+1                         ; 3     the Note Pointer + 1
FlyGameSkipResetTrack0

        iny                                             ; 2     Increment Y (Y=1) to point to the Note Volume
        lda (FlyGameNotePtrCh0),y                       ; 5     Load Volume to A
        sta AUDV0                                       ; 3     and set the Note Volume
        iny                                             ; 2     Increment Y (Y=2) to point to the Note Frequency
        lda (FlyGameNotePtrCh0),y                       ; 5     Load Frequency to A
        sta AUDF0                                       ; 3     and set the Note Frequency
        iny                                             ; 2     Increment Y (Y=3) to point to the Note Control
        lda (FlyGameNotePtrCh0),y                       ; 5     Load Control to A
        sta AUDC0                                       ; 3     and set the Note Control
        inc FlyGameFrameCtrTrk0                         ; 5     Increment the Frame Counter to duration compare later
        sec                                             ; 2     Set the carry to prepare to always branch
        bcs KeepPlaying                                 ; 3     Branch to the end of the media player
FlyGameTrack0NextNote
        lda FlyGameNotePtrCh0                           ; 3     Load the Note Pointer to A
        clc                                             ; 2     Clear the carry 
        adc #4                                          ; 2     Add 4 to move the Notep pointer to the next note
        sta FlyGameNotePtrCh0                           ; 3     Store the new note pointer

        lda #0                                          ; 2     Load Zero to
        sta FlyGameFrameCtrTrk0                         ; 3     Reset the Frame counter

KeepPlaying

;;;;;;;;;;;;;;;;;; End Rom Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FlyGameOverscanWaitLoop
        lda TIMINT
        beq FlyGameOverscanWaitLoop

        jmp FlyGameStartOfFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Atari Paint  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Atari Paint Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ATARI_PAINT_TITLE_H_POS                     = #57
ATARI_PAINT_TITLE_SLEEPTIMER                = TITLE_H_POS/#3 +#51
ATARI_PAINT_TITLE_COLOR                     = #$02

ATARI_PAINT_BACKGROUND_COLOR                = #$0F
ATARI_PAINT_FOREGROUND_SELECTED_COLOR       = #$88
ATARI_PAINT_BACKGROUND_SELECTED_COLOR       = #$42
ATARI_PAINT_CANVAS_OVERFLOW_MASK_POS        = #129

ATARI_PAINT_BRUSH_START_XPOS                = #78
ATARI_PAINT_BRUSH_START_YPOS                = #99
ATARI_PAINT_MOVE_BRUSH_DELAY                = #8
ATARI_PAINT_BRUSH_HORIZONTAL_OVERFLOW       = #$8A

ATARI_PAINT_CANVAS_SIZE                     = #104

BLACK                                       = #$00
WHITE                                       = #$0F
RED                                         = #$42
BLUE                                        = #$86
YELLOW                                      = #$1E
GREEN                                       = #$B2
ORANGE                                      = #$36
GRAY                                        = #$0A
BROWN                                       = #$F0
SKY                                         = #$9C
PURPLE                                      = #$64


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Atari Paint Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        SEG.U AtariPaintVars
        ORG Overlay
TempXPos                        ds 1
TempYPos                        ds 1
TempLetterBuffer                ds 1

BrushXPos                       ds 1
BrushYPos                       ds 1

CanvasRowLineCtr                ds 1
DebounceCtr                     ds 1

ToolSelectXPos                  ds 1

BrushColor                      ds 1
BackgroundColor                 ds 1
ControlColor                    ds 1

DrawOrEraseFlag                 ds 1
ClearCanvasFlag                 ds 1
ForegroundBackgroundFlag        ds 1

CanvasByteIdx                   ds 1
CanvasByteMask                  ds 1
CanvasRow                       ds 1
CanvasIdx                       ds 1

Canvas                          ds ATARI_PAINT_CANVAS_SIZE

        echo "----"
        echo "Ram Total Atari Paint(Bank 1):"
        echo "----",([* - $80]d) ,"/", (* - $80) ,"bytes of RAM Used for Atari Paint in Bank 1"
        echo "----",([$100 - *]d) ,"/", ($100 - *) , "bytes of RAM left for Atari Paint in Bank 1"
        SEG
        
; TODO: Atari Paint
AtariPaint
        ldx #0
        txa
ClearRam
        dex
        txs
        pha
        bne ClearRam
        cld      

        lda #30
        sta DebounceCtr

        lda #58
        sta ToolSelectXPos

        lda #BALL_SIZE_FOUR_CLOCKS
        sta CTRLPF

        lda #ATARI_PAINT_BACKGROUND_COLOR
        sta BackgroundColor

        lda #ATARI_PAINT_BRUSH_START_XPOS
        sta BrushXPos
        lda #ATARI_PAINT_BRUSH_START_YPOS
        sta BrushYPos

        ldx #0                                  ; Set Player 0 Position
        lda #ATARI_PAINT_TITLE_H_POS
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE

        ldx #1                                  ; Set Player 1 Position
        lda #ATARI_PAINT_TITLE_H_POS+8
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE

        ldx #3                                  ; Set Missle 1 Position
        lda #ATARI_PAINT_CANVAS_OVERFLOW_MASK_POS
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE

AtariPaintFrame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start VBLANK Processing ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End VBLANK Processing ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        IF ATARI_PAINT_TITLE_H_POS <= 47
         sta WSYNC
        ENDIF
        
        ldx #ATARI_PAINT_BACKGROUND_COLOR
        stx COLUBK

        ldx #0
        ldy #0
AtariPaintViewableScreen
        sta WSYNC
        inx
        cpx #3
        bne AtariPaintViewableScreen


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Title Text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #48
        sta TIM1T

AtariPaintTitleWaitLoop
        lda TIMINT
        and #%10000000
        beq AtariPaintTitleWaitLoop
                
        inx                                             ; 2
AtariPaintDrawTitle
        stx TempXPos                                    ; 3     6
        sty TempYPos                                    ; 3     9
        
        ldx T_,y                                        ; 4     13
        stx TempLetterBuffer                                  ; 3     16
        
        ldx IN,y                                        ; 4     20

        lda AT,y                                        ; 4     24
        sta GRP0                                        ; 3     27      MU -> [GRP0]
        
        lda AR,y                                        ; 4     31
        sta GRP1                                        ; 3     34      SI -> [GRP1], [GRP0] -> GRP0
        
        lda I_,y                                        ; 4     38
        sta GRP0                                        ; 3     41      C  -> [GRP0]. [GRP1] -> GRP1
        
        lda PA,y                                        ; 4     45
        ldy TempLetterBuffer                                  ; 3     48
        sta GRP1                                        ; 3     51      MA -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     54      KE -> [GRP0], [GRP1] -> GRP1
        sty GRP1                                        ; 3     57      R  -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     60      ?? -> [GRP0], [GRP1] -> GRP1
        
        ldx TempXPos                                    ; 3     63
        ldy TempYPos                                    ; 3     66
        iny                                             ; 2     68

        inx                                             ; 2     70
        cpx #10                                         ; 2     72
        nop                                             ; 2     74
        nop                                             ; 2     76
        bne AtariPaintDrawTitle                         ; 2/3   2/3
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End Title Text
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Control Row
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #MISSLE_SIZE_FOUR_CLOCKS | #TWO_COPIES_MEDIUM
        sta NUSIZ0
        sta NUSIZ1
        ldy #0
AtariPaintControlRow
        cpx #15
        bmi SkipControlRow

        lda ControlColor
        sta COLUP0
        sta COLUP1

        lda F_,y
        sta GRP0
        
        lda B_,y
        sta GRP1

        lda E_,y
        sta GRP0
        
        lda C_,y
        sta GRP1

        sta GRP0
        
        inc ControlColor
        iny

        lda #ATARI_PAINT_TITLE_COLOR
        sta COLUP0
SkipControlRow
        inx
        sta WSYNC
        cpx #21
        bne AtariPaintControlRow
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End Control Row
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Control Select Row
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #MISSLE_SIZE_FOUR_CLOCKS
        sta NUSIZ0

        lda #0
        ldy BrushYPos
        cpy #21
        bne ControlSkipDrawBrush
        lda #2
ControlSkipDrawBrush
        sta ENAM0

        lda #2
        sta ENABL

        sta WSYNC
        lda #0
        sta ENABL
        sta ENAM0

        lda #MISSLE_SIZE_TWO_CLOCKS
        sta NUSIZ0
        sta NUSIZ1

        sta WSYNC
        sta WSYNC
        lda #255
        sta PF0
        sta PF1
        sta PF2

        ldx #24
        inx
        
        sta WSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End Control Select Row
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Palette
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        SLEEP 3
AtariPaintPalette
        lda #GRAY
        sta COLUPF
        
        cpx BrushYPos
        bne PaletteSkipDrawBrush
        lda #2
        jmp PaletteDrawBrush
PaletteSkipDrawBrush
        lda #0
        nop
PaletteDrawBrush

        ; sta.w ENAM0
        sta ENAM0

        lda #WHITE
        sta COLUPF

        lda #RED
        sta COLUPF

        lda #PURPLE
        sta COLUPF

        lda #BLUE
        sta COLUPF

        lda #SKY
        sta COLUPF

        lda #GREEN
        sta COLUPF

        lda #YELLOW
        sta COLUPF

        lda #ORANGE
        sta COLUPF

        lda #BROWN
        sta COLUPF

        lda #BLACK
        sta COLUPF

        inx
        cpx #34
        bne AtariPaintPalette                           ; (76)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End Palette
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldy #0
        inx 
        
        sty ENAM0
        lda BackgroundColor
        sta COLUBK
        sta WSYNC
        lda #0
        sta PF0
        sta PF1
        sta PF2
        
        lda BackgroundColor
        sta COLUP1
        lda #MISSLE_SIZE_FOUR_CLOCKS
        sta NUSIZ1
        lda #2
        sta ENAM1
        
        lda BrushColor
        sta COLUPF
        
        lda #0
        inx
        sta WSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Canvas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AtariPaintCanvas
        cpx BrushYPos                                   ; 3
        bne SkipDrawBrush                               ; 2/3
        lda #2                                          ; 2
SkipDrawBrush
        sta ENAM0                                       ; 3     (10)
        
        lda Canvas,y                                    ; 4
        sta PF1                                         ; 3
        lda Canvas+1,y                                  ; 4
        sta PF2                                         ; 3
        lda Canvas+2,y                                  ; 4
        sta PF0                                         ; 3
        lda Canvas+3,y                                  ; 4
        sta PF1                                         ; 3     (28)
        
        dec CanvasRowLineCtr                            ; 5
        bne SkipResetCanvasRowLineCtr                   ; 2/3
        
        tya                                             ; 2
        clc                                             ; 2
        adc #4                                          ; 2 
        tay                                             ; 2
        
        lda #6                                          ; 2
        sta CanvasRowLineCtr                            ; 3     (20)
        ; iny                                             ; 2
        ; iny                                             ; 2
        ; iny                                             ; 2
        ; iny                                             ; 2     (20)
SkipResetCanvasRowLineCtr

        lda #0                                          ; 2
        sta PF2                                         ; 3
        sta PF0                                         ; 3     (8)

        inx                                             ; 2
        cpx #191                                        ; 2
        sta WSYNC                                       ; 3
        bne AtariPaintCanvas                            ; 2/3   (10)    (76)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End Canvas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda #0
        sta PF2
        sta PF0
        sta PF1

AtariPaintEndOfScreenBuffer
        sta WSYNC
        inx
        cpx #192
        bne AtariPaintEndOfScreenBuffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Setup Overscan  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #2
        sta VBLANK

        lda #0
        sta COLUBK
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Setup Overscan  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #36
        sta TIM64T
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check Bank Switching ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda DebounceCtr
        bne AtariPaintSkipSwitchToBank0
        lda SWCHB
        and #%00000010
        ora DebounceCtr
        bne AtariPaintSkipSwitchToBank0
        ; Put game select logic code here
        
        jmp SwitchToBank0
AtariPaintSkipSwitchToBank0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Check Bank Switching ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check Debouce Counter ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda DebounceCtr
        beq SkipDecDebounceCtr_AtariPaint
        dec DebounceCtr
SkipDecDebounceCtr_AtariPaint
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Check Debouce Counter ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Reset Canvas Row Line Counter ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #6
        sta CanvasRowLineCtr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Reset Canvas Indicies ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Brush  Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BrushControl
        lda DebounceCtr
        beq MoveBrush
        jmp SkipMoveBrush
MoveBrush
; Player 0 Up/Down Control
        ldy BrushYPos
        
        lda #P0_JOYSTICK_UP            
        bit SWCHA
        bne SkipMoveBrushUp
        tya
        sec
        sbc #6
        tay
        lda #ATARI_PAINT_MOVE_BRUSH_DELAY
        sta DebounceCtr
SkipMoveBrushUp

        lda #P0_JOYSTICK_DOWN
        bit SWCHA
        bne SkipMoveBrushDown
        tya
        clc
        adc #6
        tay
        lda #ATARI_PAINT_MOVE_BRUSH_DELAY
        sta DebounceCtr
SkipMoveBrushDown

        cpy #15
        bne SkipSetBrushMinVPos
        ldy #21
SkipSetBrushMinVPos

        cpy #195
        bne SkipSetBrushMaxVPos
        ldy #189
SkipSetBrushMaxVPos
        sty BrushYPos

; Player 0 Left/Right Control
        lda #P0_JOYSTICK_LEFT          
        and SWCHA
        bne SkipMoveBrushLeft
        dec BrushXPos
        dec BrushXPos
        dec BrushXPos
        dec BrushXPos
        lda #ATARI_PAINT_MOVE_BRUSH_DELAY
        sta DebounceCtr
SkipMoveBrushLeft

        lda #P0_JOYSTICK_RIGHT
        and SWCHA
        bne SkipMoveBrushRight
        inc BrushXPos
        inc BrushXPos
        inc BrushXPos
        inc BrushXPos
        lda #ATARI_PAINT_MOVE_BRUSH_DELAY
        sta DebounceCtr
SkipMoveBrushRight
       
        ldy #0

        ldx BrushXPos
        cpx #254
        bne SkipSetBrushMinHPos
        sty HMP0
        inc BrushXPos
        inc BrushXPos
        inc BrushXPos
        inc BrushXPos
SkipSetBrushMinHPos

        cpx #162
        bne SkipSetBrushMaxHPos
        sty HMP0
        dec BrushXPos
        dec BrushXPos
        dec BrushXPos
        dec BrushXPos
SkipSetBrushMaxHPos

;         ldy BrushYPos
;         cpy #21
;         bne SkipMoveBrush

;         cpx #114
;         bcc SkipMoveBrush2

;         lda #110
;         sta BrushXPos
; SkipMoveBrush2

;         cpx #42
;         bcs SkipMoveBrush
        
;         lda #42
;         sta BrushXPos

SkipMoveBrush

        ldx #2                                  ; Set Player Missle 0 Position
        lda BrushXPos
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Brush Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Calculate Tile to Paint ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda INPT4
        bpl PaintTileButtonPressed
        jmp SkipPaintTile
PaintTileButtonPressed

        ldx #0
        lda BrushYPos
        cmp #36
        bcs PaintTileYPosCorrect
        jmp SkipPaintTile
PaintTileYPosCorrect

        sec
        sbc #36
        sec
DivideBy6
        inx
        sbc #6
        bcs DivideBy6
        dex
MultiplyBy4                     ; Multiply X by 4 to find canvas row
        txa
        asl
        asl
        sta CanvasRow


        lda BrushXPos           ; Load the Brush X Position
        cmp #18                 ; If it's less than 18 then
        bpl PaintTileMinXPosCorrect 
        jmp SkipPaintTile       ; Skip over the routine
PaintTileMinXPosCorrect
        cmp #130                ; If it's more than 130 then
        bmi PaintTileMaxXPosCorrect 
        jmp SkipPaintTile       ; Skip over the routine
PaintTileMaxXPosCorrect

        sec                     ; Subtract 18 so that the "canvas" is
        sbc #18                 ; aligned to the left side of the screen

        ldx #0                  ; Set X to 0 to count our divisions
        sec
DivideBy4
        inx                     ; increment x by 1
        sbc #4
        bcs DivideBy4           
        dex

        txa
        sec
Modulo8        
        sbc #8
        bcs Modulo8
        clc
        adc #8
        sta CanvasByteIdx

        lda BrushXPos
        cmp #50
        bpl SkipSetCanvasIdx0

        ldy CanvasByteIdx
        
        lda CanvasSelectTableR,y
        ldx DrawOrEraseFlag
        beq LoadTableErasePF10
        eor #255
LoadTableErasePF10

        sta CanvasByteMask

        ldx #0
        stx CanvasIdx
        jmp CanvasIdxSet
SkipSetCanvasIdx0
        cmp #82
        bpl SkipSetCanvasIdx1

        ldy CanvasByteIdx
        lda CanvasSelectTable,y
        ldx DrawOrEraseFlag
        beq LoadTableErasePF20
        eor #255

LoadTableErasePF20
        sta CanvasByteMask

        ldx #1
        stx CanvasIdx
        jmp CanvasIdxSet
SkipSetCanvasIdx1
        cmp #98
        bpl SkipSetCanvasIdx2

        ldy CanvasByteIdx
        lda CanvasSelectTable,y
        ldx DrawOrEraseFlag
        beq LoadTableErasePF00
        eor #255
LoadTableErasePF00
        asl
        asl
        asl
        asl
        sta CanvasByteMask

        ldx #2
        stx CanvasIdx
        jmp CanvasIdxSet
SkipSetCanvasIdx2
        ldy CanvasByteIdx
        lda CanvasSelectTableR,y
        ldx DrawOrEraseFlag
        beq LoadTableErasePF11
        eor #255
LoadTableErasePF11
        and #%00001111
        clc
        rol
        rol
        rol
        rol
        
        sta TempLetterBuffer

        ldy CanvasByteIdx

        lda CanvasSelectTableR,y
        ldx DrawOrEraseFlag
        beq LoadTableErasePF12
        eor #255
LoadTableErasePF12

        and #%11110000
        
        ror
        ror
        ror
        ror
        
        ora TempLetterBuffer
        sta CanvasByteMask

        ldx #3
        stx CanvasIdx
CanvasIdxSet
        txa
        clc
        adc CanvasRow
        sta CanvasIdx
        
        ldy CanvasIdx
        lda Canvas,y
        
        ldx DrawOrEraseFlag
        beq LoadCanvasByteMask
        and CanvasByteMask
        jmp LoadEraseCanvasByteMask
LoadCanvasByteMask
        ora CanvasByteMask
LoadEraseCanvasByteMask

        sta Canvas,y
        jmp SkipPaintTile

SkipPaintTile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Calculate Tile to Paint ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Set Playfield Control ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda BrushYPos
        cmp #24
        bcs SkipSetCanvasControl

        cmp #14
        bcc SkipSetCanvasControl

        lda INPT4
        bmi SkipSetCanvasControl

        lda BrushXPos
        cmp #62
        bcs SkipSetFGColor
        cmp #58
        bcc SkipSetFGColor

        lda #0
        sta DrawOrEraseFlag
        sta ForegroundBackgroundFlag
        lda BrushXPos
        sta ToolSelectXPos

        jmp SkipSetCanvasControl

SkipSetFGColor
        cmp #70
        bcs SkipSetBGColor
        cmp #66
        bcc SkipSetBGColor

        lda #1
        sta ForegroundBackgroundFlag

        lda BrushXPos
        sta ToolSelectXPos
        jmp SkipSetCanvasControl
SkipSetBGColor
        cmp #94
        bcs SkipSetErase
        cmp #90
        bcc SkipSetErase

        lda #1
        sta DrawOrEraseFlag

        lda BrushXPos
        sta ToolSelectXPos
        
        jmp SkipSetCanvasControl
SkipSetErase

        cmp #102
        bcs SkipSetClear
        cmp #98
        bcc SkipSetClear

        lda #1
        sta ClearCanvasFlag
SkipSetClear
SkipSetCanvasControl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Set Playfield Control ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Clear Canvas ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda ClearCanvasFlag
        beq SkipClearCanvas
        ldy #0
ClearCanvasArray
        lda #0
        sta Canvas,y
        iny
        cpy #ATARI_PAINT_CANVAS_SIZE
        bne ClearCanvasArray
        sta ClearCanvasFlag
SkipClearCanvas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Clear Canvas ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Set Brush or Background Color ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda BrushYPos
        cmp #34
        bcs SkipSetBrushColor

        cmp #24
        bcc SkipSetBrushColor

        lda INPT4
        bmi SkipSetBrushColor

        lda BrushXPos
        
        cmp #13
        bcs SkipSetColorGray
        lda #GRAY
        jmp SetBrushColor
SkipSetColorGray
        cmp #26
        bcs SkipSetColorWhite
        lda #WHITE
        jmp SetBrushColor
SkipSetColorWhite
        cmp #41
        bcs SkipSetColorRed
        lda #RED
        jmp SetBrushColor
SkipSetColorRed
        cmp #57
        bcs SkipSetColorPurple
        lda #PURPLE
        jmp SetBrushColor
SkipSetColorPurple
        cmp #71
        bcs SkipSetColorBlue
        lda #BLUE
        jmp SetBrushColor
SkipSetColorBlue
        cmp #85
        bcs SkipSetColorSky
        lda #SKY
        jmp SetBrushColor
SkipSetColorSky
        cmp #101
        bcs SkipSetColorGreen
        lda #GREEN
        jmp SetBrushColor
SkipSetColorGreen
        cmp #117
        bcs SkipSetColorYellow
        lda #YELLOW
        jmp SetBrushColor
SkipSetColorYellow
        cmp #132
        bcs SkipSetColorOrange
        lda #ORANGE
        jmp SetBrushColor
SkipSetColorOrange
        cmp #146
        bcs SkipSetColorBrown
        lda #BROWN
        jmp SetBrushColor
SkipSetColorBrown
        cmp #161
        bcs SkipSetColorBlack
        lda #BLACK
        jmp SetBrushColor
SkipSetColorBlack
SetBrushColor
        ldy ForegroundBackgroundFlag
        bne SetBackGroundColor
        sta BrushColor
        jmp SkipSetBrushColor
SetBackGroundColor
        sta BackgroundColor
SkipSetBrushColor
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Set Brush or Background Color ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda #0
        sta ENAM1
        sta COLUPF

        lda #ATARI_PAINT_TITLE_COLOR            ; Set the player colors for the title
        sta COLUP0
        sta COLUP1

        lda #ATARI_PAINT_FOREGROUND_SELECTED_COLOR
        sta ControlColor

        lda #1
        sta VDELP0
        sta VDELP1

        lda #THREE_COPIES_CLOSE
        sta NUSIZ0
        sta NUSIZ1

        ldx #4                                  ; Set Player Ball Position
        lda ToolSelectXPos
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE
        ; SLEEP 24
        ; sta HMCLR

        ldx #0
AtariPaintOverscanWaitLoop
        lda TIMINT
        beq AtariPaintOverscanWaitLoop

        jmp AtariPaintFrame

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
        ;align 256
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
           .byte #0
           .byte #0
           .byte #0
           .byte #0
           .byte #0
           .byte #0

ON         .byte  #%11101110
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%11101010
           .byte  #0

O_         .byte  #%11100000
           .byte  #%10100000
           .byte  #%10100000
           .byte  #%10100000
           .byte  #%11100000
           .byte  #0

TW         .byte  #%11101010
           .byte  #%01001010
           .byte  #%01001110
           .byte  #%01001110
           .byte  #%01001110
           .byte  #0

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
           .byte #%00000000
           .byte #%00000000     ; (22)
           .byte #%00000000
           .byte #%00000000     ; (24)
           .byte #%00000000
           .byte #%00000000     ; (26)
           .byte #%00000000
           .byte #%00000000     ; (28)



GA         .byte  #%11101110
           .byte  #%10001010
           .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101010

MER        .byte  #%01110101
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

E_         .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000
           .byte  #%10000000
           .byte  #%11100000
           .byte  #0

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

F_         .byte  #%11100000
           .byte  #%10000000
           .byte  #%11000000
           .byte  #%10000000
           .byte  #%10000000
           .byte  #0

B_         .byte  #%11000000
           .byte  #%10100000
           .byte  #%11000000
           .byte  #%10100000
           .byte  #%11000000
           .byte  #0

C_         .byte  #%11100000
           .byte  #%10000000
           .byte  #%10000000
           .byte  #%10000000
           .byte  #%11100000
           .byte  #0

Space      .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #%00000000
           .byte  #0

Cursor     .byte  #%00001000
           .byte  #%00001100
           .byte  #%00001110
           .byte  #%00001100
           .byte  #%00001000
           .byte  #0

Zero_bank1 .byte  #%11101110
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%11101110

One_bank1  .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010

Two_bank1  .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110

Three_bank1 .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110

Four_bank1 .byte  #%10101010
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%00100010

Five_bank1 .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110

Six_bank1  .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110

Seven_bank1 .byte  #%11101110
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010

Eight_bank1 .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110

Nine_bank1 .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110
        
AT         .byte  #%01001110
           .byte  #%10100100
           .byte  #%11100100
           .byte  #%10100100
           .byte  #%10100100
           .byte  #0

AR         .byte  #%01001110
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%10101100
           .byte  #%10101010
           .byte  #0

I_         .byte  #%11100000
           .byte  #%01000000
           .byte  #%01000000
           .byte  #%01000000
           .byte  #%11100000
           .byte  #0

PA         .byte  #%11100100
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%10001010
           .byte  #%10001010
           .byte  #0

IN         .byte  #%11101110
           .byte  #%01001010
           .byte  #%01001010
           .byte  #%01001010
           .byte  #%11101010
           .byte  #0

T_         .byte  #%11100000
           .byte  #%01000000
           .byte  #%01000000
           .byte  #%01000000
           .byte  #%01000000
           .byte  #0

PL         .byte  #%11101000
           .byte  #%10101000
           .byte  #%11101000
           .byte  #%10001000
           .byte  #%10001110
           

AY         .byte  #%01001010
           .byte  #%10101010
           .byte  #%11100100
           .byte  #%10100100
           .byte  #%10100100
           

ER         .byte  #%11101110
           .byte  #%10001010
           .byte  #%11001110
           .byte  #%10001100
           .byte  #%11101010
           

_W         .byte  #%00001010
           .byte  #%00001010
           .byte  #%00001110
           .byte  #%00001110
           .byte  #%00001110

SC         .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101000
           .byte  #%00101000
           .byte  #%11101110

OR         .byte  #%11101110
           .byte  #%10101010
           .byte  #%10101110
           .byte  #%10101100
           .byte  #%11101010

EColon     .byte  #%11100000
           .byte  #%10000100
           .byte  #%11000000
           .byte  #%10000100
           .byte  #%11100000

CanvasSelectTable       .byte #%00000001
                        .byte #%00000010
                        .byte #%00000100
                        .byte #%00001000
                        .byte #%00010000
                        .byte #%00100000
                        .byte #%01000000
                        .byte #%10000000

CanvasSelectTableR      .byte #%10000000
                        .byte #%01000000
                        .byte #%00100000
                        .byte #%00010000
                        .byte #%00001000
                        .byte #%00000100
                        .byte #%00000010
                        .byte #%00000001

_T         .byte  #%00001110
           .byte  #%00000100
           .byte  #%00000100
           .byte  #%00000100
           .byte  #%00000100

IE         .byte  #%11101110
           .byte  #%01001000
           .byte  #%01001110
           .byte  #%01001000
           .byte  #%11101110

ME         .byte  #%10101110
           .byte  #%11101000
           .byte  #%10101110
           .byte  #%10101000
           .byte  #%10101110

FlyGameTrack0   .byte 0,0,0,0,255
FlyGameTrack1

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