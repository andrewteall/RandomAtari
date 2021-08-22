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

MISSLE_BALL_ENABLE              = #2
MISSLE_BALL_DISABLE             = #0

SWITCH_GAME_RESET               = #1
SWITCH_GAME_SELECT              = #2
SWITCH_COLOR_TV                 = #8
SWITCH_P0_PRO_DIFFICULTY        = #64
SWITCH_P1_PRO_DIFFICULTY        = #128

P1_JOYSTICK_UP                  = #%00000001
P1_JOYSTICK_DOWN                = #%00000010
P1_JOYSTICK_LEFT                = #%00000100
P1_JOYSTICK_RIGHT               = #%00001000
P0_JOYSTICK_UP                  = #%00010000
P0_JOYSTICK_DOWN                = #%00100000
P0_JOYSTICK_LEFT                = #%01000000
P0_JOYSTICK_RIGHT               = #%10000000

DURATION_MASK                   = #%00000111
FREQUENCY_MASK                  = #%11111000
VOLUME_MASK                     = #%11110000
CONTROL_MASK                    = #%00001111
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

        echo "Ram Total Atari Music(Bank 0):"
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
; TODO: Allow single track for track length

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
        and #SWITCH_GAME_SELECT
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Fly Game Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FLY_GAME_TITLE_BACKGROUND_COLOR         = #$9E ;57
FLY_GAME_TITLE_TEXT_COLOR               = #$02

FLY_GAME_TITLE_VPOS                     = #41 ;56
FLY_GAME_TITLE_HPOS                     = #59
FLY_GAME_TITLE_MENU_VPOS                = #121 ;#135
FLY_GAME_GAME_OVER_TEXT_HPOS            = #57

FLY_GAME_GAME_BACKGROUND_COLOR          = #$9E ;0A
FLY_GAME_SCORE_COLOR                    = #$96;86;72
FLY_GAME_JOIN_COLOR                     = #$48 ;46
FLY_GAME_TIMER_COLOR                    = #$0F ;62
FLY_GAME_PLAYER0_COLOR                  = #$02
FLY_GAME_PLAYER1_COLOR                  = #$48 ;0F  ;83

FLY_GAME_GAME_OVER_RESTART_DELAY        = #60
FLY_GAME_COUNTDOWN_TIMER_SECOND_DIVIDER = #60
FLY_GAME_TIMER_DURATION                 = #$5
FLY_GAME_ENEMY_GENERATION_DELAY         = #50

FLY_GAME_P0_X_START_POS                 = #15
FLY_GAME_P0_Y_START_POS                 = #78
FLY_GAME_P1_X_START_POS                 = #125
FLY_GAME_P1_Y_START_POS                 = #78

FLY_GAME_PLAYER_HEIGHT                  = #24
FLY_GAME_ENEMY_HEIGHT                   = #4

FLY_GAME_FIELD_START_LINE               = #40
FLY_GAME_P1_JOIN_HPOS                   = #100
FLY_GAME_P1_JOIN_FLASH_RATE             = #52

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Fly Game Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        SEG.U bank1vars
        ORG Overlay

TempXPos                ds 1
TempYPos                ds 1
PlayerScoreTmp
TempLetterBuffer        ds 1

GameSelectFlag          ds 1
StartGameFlag           ds 1
GameOverFlag            ds 1

DebounceCtr             ds 1                    ; Gotta Keep this in spot 7 to match Bank0
P1FireDebounceCtr       ds 1
OptionsLoopCtr          ds 1

Game1SelectionGfx       ds 2
Game2SelectionGfx       ds 2
EnemyOptionGfx1         ds 2
EnemyOptionGfx2         ds 2

BlockP0SwatCtr          ds 1
BlockP1SwatCtr          ds 1
FlasherCtr              ds 1
Winner                  ds 5
CountdownTimer          ds 1
CountdownTimerInterval  ds 1
CountdownTimerTmp1      ds 1
CountdownTimerTmp2      ds 1
CountdownTimerIdx       ds 1
CountdownTimerGfx       ds 5

Player0XPos             ds 1
Player1XPos             ds 1
Player0YPos             ds 1
Player1YPos             ds 1
Player0YPosEnd          ds 1
Player1YPosEnd          ds 1
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
P0Score1idx             ds 1
P1Score1idx             ds 1
P0Score2idx             ds 1
P1Score2idx             ds 1
P0ScoreArr              ds 5
P1ScoreArr              ds 5

FlyGameNotePtrCh0       ds 2
FlyGameNotePtrCh1       ds 2
FlyGameFrameCtrTrk0     ds 1
FlyGameFrameCtrTrk1     ds 1


        echo "----"
        echo "Ram Total Fly Game(Bank 1):"
        echo "----",([* - $80]d) ,"/", (* - $80) ,"bytes of RAM Used for Fly Game in Bank 1"
        echo "----",([$100 - *]d) ,"/", ($100 - *) , "bytes of RAM left for Fly Game in Bank 1"
        SEG
        ORG  $2000
        RORG $F000
        
; TODO: FlyGame

; TODO: Add Game Title Music
; TODO: Add Game Music
; TODO: Add Game Sound FX
; TODO: Optimize Code


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Fly Game Start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PlayFlyGame
        lda #30                         ; Initialize the Deboucer Counters to
        sta DebounceCtr                 ; 30 frames to prevent reading any 
        sta P1FireDebounceCtr           ; button presses during each start up

        lda #FLY_GAME_TITLE_BACKGROUND_COLOR
        sta COLUBK

        lda StartGameFlag               ; Check to see if the game is started
        beq FlyGameTitleInit            ; and init the game or the title screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Fly Game Game Init  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #FLY_GAME_P0_X_START_POS
        sta Player0XPos
        ldx #FLY_GAME_P0_Y_START_POS
        stx Player0YPos

        lda GameSelectFlag
        beq OnePlayerGame
        lda #FLY_GAME_P1_X_START_POS
        sta Player1XPos
        lda #FLY_GAME_P1_Y_START_POS
        sta Player1YPos
OnePlayerGame

        ldy #FLY_GAME_PLAYER0_COLOR
        sty COLUP0
        ldy #FLY_GAME_PLAYER1_COLOR
        sty COLUP1

        ldx #FLY_GAME_ENEMY_GENERATION_DELAY
        stx Enemy0GenTimer
        stx Enemy1GenTimer

        ldx #FLY_GAME_TIMER_DURATION
        stx CountdownTimer

        lda #FLY_GAME_COUNTDOWN_TIMER_SECOND_DIVIDER
        sta CountdownTimerInterval

        lda #<FlyGameTrack0             ; Initialize Note Pointer 0 to the
        sta FlyGameNotePtrCh0           ; beginning of Game Music Track 0 in
        lda #>FlyGameTrack0             ; Rom for the Music Player
        sta FlyGameNotePtrCh0+1         ;

        lda #<FlyGameTrack1             ; Initialize Note Pointer 1 to the
        sta FlyGameNotePtrCh1           ; beginning of Game Music Track 1 in
        lda #>FlyGameTrack1             ; Rom for the Music Player
        sta FlyGameNotePtrCh1+1

        jmp FlyGameStartOfFrame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Fly Game Game Init  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Fly Game Title Init  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FlyGameTitleInit
        ldy #FLY_GAME_TITLE_TEXT_COLOR  ; Set the color for all the text on the
        sty COLUPF                      ; title screen
        sty COLUP0                      ;
        sty COLUP1                      ;

        ldx #1                          ; and Player 1 is positioned 8 pixels
        lda #FLY_GAME_TITLE_HPOS+8      ; to the right of Player 0 since our
        jsr CalcXPos_bank1              ; font is 8 pixels wide
        sta WSYNC                       ;
        sta HMOVE                       ;

        ldx #0                          ; Horizontally position the player
        lda #FLY_GAME_TITLE_HPOS        ; sprites to draw the Start Menu
        jsr CalcXPos_bank1              ; on the Title Screen
        sta WSYNC                       ; Player 0 is positioned according to
        sta HMOVE                       ; FLY_GAME_TITLE_HPOS

        lda #<Cursor                    ; Set the Start Menu Cursor to default
        sta Game1SelectionGfx           ; to a One player Game
        lda #>Cursor                    ; 
        sta Game1SelectionGfx+1         ; 

        lda #<Space                     ; Make the Two player game not selected
        sta Game2SelectionGfx           ; in the Start Menu
        lda #>Space                     ;
        sta Game2SelectionGfx+1         ;

        lda #<FlyGameTitleTrack0        ; Initialize Note Pointer 0 to the
        sta FlyGameNotePtrCh0           ; beginning of Title Music Track 0 in
        lda #>FlyGameTitleTrack0        ; Rom for the Music Player
        sta FlyGameNotePtrCh0+1         ;

        lda #<FlyGameTitleTrack1        ; Initialize Note Pointer 1 to the
        sta FlyGameNotePtrCh1           ; beginning of Title Music Track 1 in
        lda #>FlyGameTitleTrack1        ; Rom for the Music Player
        sta FlyGameNotePtrCh1+1         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Fly Game Title Init  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


FlyGameStartOfFrame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start VBLANK ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #0
        lda #2

        sta VSYNC                       ; Turn on VSYNC
        sta WSYNC                       ; Wait 3 lines
        sta WSYNC                       ;
        sta WSYNC                       ;
        sty VSYNC                       ; Turn off VSYNC

        lda #43                         ; Set a Timer to take 37 lines for the
        sta TIM64T                      ; VBLANK 

        lda StartGameFlag
        bne FlyGameVBLANKProcessing
        jmp FlyGameVerticalBlankEndWaitLoop
FlyGameVBLANKProcessing

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Scoring ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CalcPlayerScoreIdx
        lda P0Score,y
        and #$0F
        sta P0Score1idx,y
        asl
        asl
        adc P0Score1idx,y
        sta P0Score1idx,y

        lda P0Score,y
        lsr
        lsr
        lsr
        lsr
        sta P0Score2idx,y
        asl
        asl
        adc P0Score2idx,y
        sta P0Score2idx,y

        iny
        cpy #2
        bne CalcPlayerScoreIdx
                
        ldx #0
        clc
CalcScoreGraphics
        ;P0
        txa
        adc P0Score1idx
        tay
        lda Zero_bank1,y
        and #$0F
        sta PlayerScoreTmp

        txa
        adc P0Score2idx
        tay
        lda Zero_bank1,y
        and #$F0

        ora PlayerScoreTmp
        sta P0ScoreArr,x

        ;P1
        txa
        adc P1Score1idx
        tay
        lda Zero_bank1,y
        and #$0F
        sta PlayerScoreTmp

        txa
        adc P1Score2idx
        tay
        lda Zero_bank1,y
        and #$F0

        ora PlayerScoreTmp
        sta P1ScoreArr,x

        inx
        cpx #5
        bcc CalcScoreGraphics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Scoring ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Determine Winner  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda GameOverFlag
        beq SkipDetermineWinner
        ldy #0
LoadWinner
        
        lda P0Score
        ; sec
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Time Countdown Timer  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda CountdownTimer
        beq SkipTimer
        
        ldy CountdownTimerInterval
        bne SkipCountdownTimer
        
        sed
        sbc #1
        sta CountdownTimer
        cld

        lda #FLY_GAME_COUNTDOWN_TIMER_SECOND_DIVIDER
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
        
        ldx #0
BuildCountdownTimerGraphics
        stx CountdownTimerIdx

        lda CountdownTimer
        and #$0F
        sta CountdownTimerTmp1
        asl
        asl
        adc CountdownTimerTmp1
        adc CountdownTimerIdx
        tay 
        lda Zero_bank1,y 
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
        adc CountdownTimerTmp2
        adc CountdownTimerIdx
        tay 
        lda Zero_bank1,y 
        and #$F0

        ora CountdownTimerTmp1

        sta CountdownTimerGfx,x
        inx
        cpx #5
        bne BuildCountdownTimerGraphics 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Build Countdown Timer Graphics ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Fly Game Game Values Reset ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #1
        lda #FLY_GAME_P1_JOIN_HPOS+8
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE

        ldx #0
        stx GRP0
        stx GRP1
        stx GRP0
        lda #FLY_GAME_P1_JOIN_HPOS
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE

        lda #THREE_COPIES_CLOSE
        sta NUSIZ0
        sta NUSIZ1

        lda #FLY_GAME_JOIN_COLOR
        sta COLUP0
        sta COLUP1

        lda #FLY_GAME_SCORE_COLOR
        sta COLUPF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Fly Game Game Values Reset ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FlyGameVerticalBlankEndWaitLoop
        lda TIMINT
        and #%10000000
        beq FlyGameVerticalBlankEndWaitLoop
        sta WSYNC
        stx VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End VBLANK ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda StartGameFlag
        beq SkipFlyGameScreenSelect

        lda CountdownTimer
        bne SkipFlyGameGameoverScreen

        lda GameOverFlag
        bne SkipSetGameOverRestartDelay
        ldy #FLY_GAME_GAME_OVER_RESTART_DELAY
        sty BlockP0SwatCtr
SkipSetGameOverRestartDelay
        lda #1
        sta GameOverFlag
SkipFlyGameGameoverScreen

        ldy #1
        sty VDELP0
        sty VDELP1

SkipFlyGameScreenSelect
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Viewable Screen Start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        lda StartGameFlag               ; Determine whether or not to draw the
        beq FlyGameTitleScreen          ; Title screen or the actual game 
        jmp FlyGameGameScreen           ; screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Fly Game Title Screen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Fly Game Title Screen Draw Title ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FlyGameTitleScreen
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Fly Game Title Screen Draw Title ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Fly Game Title Screen Draw Menu ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FlyGameNumPlayersSelectLine1 
        cpx #FLY_GAME_TITLE_MENU_VPOS
        bmi SkipFlyGameNumPlayersSelectLine1
        txa                                             ; 2
        sec                                             ; 2
        sbc #FLY_GAME_TITLE_MENU_VPOS                   ; 2
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
        cpx #FLY_GAME_TITLE_MENU_VPOS+6
        sta WSYNC
        bne FlyGameNumPlayersSelectLine1

FlyGameNumPlayersSelectLine2 
        cpx #FLY_GAME_TITLE_MENU_VPOS+10
        bmi SkipFlyGameNumPlayersSelectLine2
        txa                                             ; 2
        sec
        sbc #FLY_GAME_TITLE_MENU_VPOS+10                ; 2
        tay                                             ; 2 
        lda (Game2SelectionGfx),y                       ; 4
        sta GRP0                                        ; 3
        lda TW,y                                        ; 4
        sta GRP1                                        ; 3

        SLEEP 6                                        ; 12

        lda ON,y                                        ; 4
        and #$F0
        sta GRP0                                        ; 3
SkipFlyGameNumPlayersSelectLine2
        inx
        cpx #FLY_GAME_TITLE_MENU_VPOS+16
        sta WSYNC
        bne FlyGameNumPlayersSelectLine2

        lda #THREE_COPIES_CLOSE
        sta NUSIZ0
        sta NUSIZ1
        lda #1
        sta VDELP0
        sta VDELP1

        ldy #0
        sty OptionsLoopCtr

        lda #>FA
        sta EnemyOptionGfx1+1
        sta EnemyOptionGfx2+1

        lda SWCHB
        and #SWITCH_P0_PRO_DIFFICULTY
        bne FastEnemies
        lda #<SL
        sta EnemyOptionGfx1
        ; lda #>SL
        ; sta EnemyOptionGfx1+1

        lda #<OW
        sta EnemyOptionGfx2
        ; lda #>OW
        ; sta EnemyOptionGfx2+1
        jmp SlowEnemies
FastEnemies
        lda #<FA
        sta EnemyOptionGfx1
        ; lda #>FA
        ; sta EnemyOptionGfx1+1

        lda #<ST
        sta EnemyOptionGfx2
        ; lda #>ST
        ; sta EnemyOptionGfx2+1
SlowEnemies


DrawOptions
        ldx #4
FlyGameOptionsLineBuffer
        dex
        sta WSYNC
        bne FlyGameOptionsLineBuffer

        lda #50
        sta TIM1T                       
PositionFlyGameOptionsLine
        lda TIMINT
        beq PositionFlyGameOptionsLine
        SLEEP 2

        lda #5
        sta TIM64T
FlyGameOptionsLine
        SLEEP 2
        sty TempYPos                    ; 3     9
        
        ldx Space,y                        ; 4     13
        stx.w TempLetterBuffer          ; 3     16
        
        ldx ES,y                        ; 4     20

        lda (EnemyOptionGfx1),y         ; 4     24
        sta GRP0                        ; 3     27 -> [GRP0]
        
        lda (EnemyOptionGfx2),y         ; 4     31
        sta GRP1                        ; 3     34 -> [GRP1], [GRP0] -> GRP0
        
        lda _F,y                        ; 4     38
        sta GRP0                        ; 3     41 -> [GRP0]. [GRP1] -> GRP1
        
        lda LI,y                        ; 4     45
        ldy TempLetterBuffer            ; 3     48
        sta GRP1                        ; 3     51 -> [GRP1], [GRP0] -> GRP0
        stx GRP0                        ; 3     54 -> [GRP0], [GRP1] -> GRP1
        sty GRP1                        ; 3     57 -> [GRP1], [GRP0] -> GRP0
        stx GRP0                        ; 3     60 ?? -> [GRP0], [GRP1] -> GRP1
        
        ldy TempYPos                    ; 3     66
        iny                             ; 2     68
        
        SLEEP 5                         
        lda TIMINT                      ; 4
        beq FlyGameOptionsLine          ; 2/3   2/3

        ldy #0
        sty GRP0
        sty GRP1
        sty GRP0

        ; lda #>WI
        ; sta EnemyOptionGfx1+1
        ; sta EnemyOptionGfx2+1

        lda SWCHB
        and #SWITCH_P1_PRO_DIFFICULTY
        bne WildEnemies
        lda #<TA
        sta EnemyOptionGfx1

        lda #<ME
        sta EnemyOptionGfx2
        jmp TameEnemies
WildEnemies
        lda #<WI
        sta EnemyOptionGfx1

        lda #<LD
        sta EnemyOptionGfx2
TameEnemies

        inc OptionsLoopCtr
        lda OptionsLoopCtr
        cmp #2
        bne DrawOptions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Fly Game Title Screen Draw Menu ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldx #21+(#135-#FLY_GAME_TITLE_MENU_VPOS)
FlyGameTitleScreenBottomBuffer
        dex
        sta WSYNC
        bne FlyGameTitleScreenBottomBuffer

        jmp EndofViewableScreen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Fly Game Title Screen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Fly Game Game Screen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FlyGameGameScreen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Player 2 Join Text ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda GameSelectFlag              ; Check to see if it's a two player
        bne FlyGameSkipDrawPlayer2Join  ; game. If so don't show the Flasher

        lda FlasherCtr                  ; For a one Player game, check the
        cmp #FLY_GAME_P1_JOIN_FLASH_RATE/2-10 ; Flasher Timer to see if we
        bcs FlyGameDrawPlayer2Join      ; should draw the Join Flasher or not

FlyGameSkipDrawPlayer2Join
        inx                             ; If we're not drawing the flasher then
        cpx #9                          ; draw empty lines until line 9 then
        sta WSYNC                       ; move to the Player2Buffer
        bne FlyGameSkipDrawPlayer2Join  ;
        jmp Player2Buffer               ;
  
FlyGameDrawPlayer2Join                  
        inx                             ; If we are drawing the flasher then
        cpx #3                          ; draw 3 blank lines then start drawing
        sta WSYNC                       ; the flasher
        bne FlyGameDrawPlayer2Join      ;

        lda #60                         ; Setup the timer to align the Flasher
        sta TIM1T                       ; text and wait til it expires
PositionFlyGamePlayer2JoinText
        lda TIMINT                      ;
        and #%10000000                  ;
        beq PositionFlyGamePlayer2JoinText

        lda #5                          ; Setup a timer to draw 6 lines to draw
        sta TIM64T                      ; the Flasher from line 4 to 9 so that
        ldy #0                          ; the timer expires when we're done
DrawPlayer2JoinText
        ; stx TempXPos                    ; 3     6
        SLEEP 3                         ; 3     6
        sty TempYPos                    ; 3     9
        
        ldx E_,y                        ; 4     13
        stx TempLetterBuffer            ; 3     16
        
        ldx IR,y                        ; 4     20

        lda _P,y                        ; 4     24
        sta GRP0                        ; 3     27 -> [GRP0]
        
        lda RE_bank1,y                  ; 4     31
        sta GRP1                        ; 3     34 -> [GRP1], [GRP0] -> GRP0
        
        lda SS,y                        ; 4     38
        sta GRP0                        ; 3     41 -> [GRP0]. [GRP1] -> GRP1
        
        lda _F,y                        ; 4     45
        ldy TempLetterBuffer            ; 3     48
        sta GRP1                        ; 3     51 -> [GRP1], [GRP0] -> GRP0
        stx GRP0                        ; 3     54 -> [GRP0], [GRP1] -> GRP1
        sty GRP1                        ; 3     57 -> [GRP1], [GRP0] -> GRP0
        stx GRP0                        ; 3     60 ?? -> [GRP0], [GRP1] -> GRP1
        
        ldy TempYPos                    ; 3     63
        iny                             ; 2     65
        ; ldx TempXPos                    ; 3     68
        ; inx                             ; 2     70
        ; cpx #9                          ; 2     72
        ; nop                             ; 2     74
        ; nop                             ; 2     76
        lda TIMINT                      ; 4     69
        SLEEP 7
        beq DrawPlayer2JoinText         ; 2/3   2/3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Player 2 Join Text ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Setup Score and Timer Area ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
Player2Buffer
        ldx #11
        lda #DOUBLE_SIZE_PLAYER
        sta NUSIZ0
        sta NUSIZ1

        lda #0
        sta VDELP0
        sta VDELP1
        sta GRP0
        sta GRP1

        lda #FLY_GAME_TIMER_COLOR
        sta COLUP0

        sta WSYNC

; Align Countdown Timer 
        lda #31
        sta TIM1T
PositionCountdownTimer
        lda TIMINT
        beq PositionCountdownTimer
        SLEEP 4
        sta RESP0

        sta WSYNC
; End Align Countdown Timer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Setup Score and Timer Area ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Drawing Score Timer Area ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
ScoreArea
        txa                             ; 2
        sbc #10                         ; 2
        lsr                             ; 2
        lsr                             ; 2
        tay                             ; 2
        lda P0ScoreArr,y                ; 4     Get the Score From our Player 0 Score Array
        sta PF1                         ; 3     Store Score to PF1
        lda Zero_bank1,y                ; 4     Get the Score From our Player 0 Score Array
        lsr                             ; 2
        sta PF2                         ; 3     Store Score to PF1 
        nop                             ; 2     Wait 2 cycles to get past drawing player 0's score
        nop                             ; 2  30 Wait 2 cycles more to get past drawing player 0's score
        
        lda P1ScoreArr,y                ; 4     Get the Score From our Player 1 Score Array
        sta PF1                         ; 3  7  Store Score to PF1
        
        lda #0                          ; 2
        cpx #15                         ; 2
        bmi SkipDisplayTimer            ; 2/3
        cpx #25                         ; 2
        bpl SkipDisplayTimer            ; 2/3 10

        txa                             ; 2
        sec                             ; 2
        sbc #15                         ; 2
        lsr                             ; 2
        tay                             ; 2
        lda CountdownTimerGfx,y         ; 4  14
        
SkipDisplayTimer
        sta GRP0                        ; 3
        inx                             ; 2     Increment our line counter
        cpx #31                         ; 2     See if we're at line 30
        sta WSYNC                       ; 3     Go to Next line
        bne ScoreArea                   ; 2/3 13If at line 30 then move on else branch back
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Drawing Score and Timer Area ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Setup Gameover Screen and Game Board ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        sta PF1                         ; The Accumulator should still be set
        sta PF2                         ; to 0 so clear the playfield
        
        sta WSYNC                       ; Wait 2 lines for spacing
        sta WSYNC                       ;

        sta COLUBK                      ; Set the Background to black to hide
                                        ; HMOVE lines

        lda #FLY_GAME_PLAYER0_COLOR     ; Set the player colors
        sta COLUP0                      ;
        lda #FLY_GAME_PLAYER1_COLOR     ;
        sta COLUP1                      ;
        
        ldy GameOverFlag                ; If we're at the end of the game then
        beq SkipLoadGameOverTextPosition ; load the Positions of the game over
        lda #FLY_GAME_GAME_OVER_TEXT_HPOS ; text into the Players Horizontal
        sta Player0XPos                 ; position
        lda #FLY_GAME_GAME_OVER_TEXT_HPOS+8 ;
        sta Player1XPos                 ;
SkipLoadGameOverTextPosition

        ldx #0                          ; Set the players Horizontal position
        lda Player0XPos                 ; since we reused the players sprites
        cmp #$87                        ; for other features of the game
        bcs SkipWSYNCP0                 ; previously
        sta WSYNC                       ; If we're drawing the player after 
SkipWSYNCP0                             ; position $87 then we need to forgo a
        jsr CalcXPos_bank1              ; WSYNC since the positioning routine
        sta WSYNC                       ; will take more than a line to finish
        sta HMOVE

        ldx #1                          ;
        lda Player1XPos                 ;
        cmp #$87                        ;
        bcs SkipWSYNCP1                 ;
        sta WSYNC                       ;
SkipWSYNCP1
        jsr CalcXPos_bank1              ;
        sta WSYNC                       ;
        sta HMOVE                       ;
        
        stx VDELP0                      ; Set Vertical Delay ON for Player 0
        
        ldx #FLY_GAME_FIELD_START_LINE  ; Set X to the line the board starts
ScoreAreaBuffer
        lda #FLY_GAME_GAME_BACKGROUND_COLOR ; Load the background color
        ldy #MISSLE_BALL_ENABLE         ; Set Y enable Missles or Ball Sprites
        sta WSYNC                       ; Move to a new line
        sta COLUBK                      ; Turn the background color back on

        lda GameOverFlag                ; If we're at the end of the game then
        bne DrawGameOverScreen          ; branch to gameover screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Setup Gameover Screen and Game Board ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
        ldy #MISSLE_BALL_ENABLE                 ; 2
        inx                                     ; 2
        inx                                     ; 2
        cpx #192                                ; 2
        sta WSYNC                               ; 3     (11)    (68)
        bne FlyGameBoard                        ; 2/3
        
        jmp EndofViewableScreen                 ; 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Drawing Players and Enemy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Game Over Screen Start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DrawGameOverScreen
        lda #1
        sta VDELP1

        lda #FLY_GAME_PLAYER0_COLOR
        sta COLUP1

        lda #THREE_COPIES_CLOSE
        sta NUSIZ0
        sta NUSIZ1

        ldx #FLY_GAME_FIELD_START_LINE+2
DrawGameOverScreenTop
        inx
        cpx #57
        sta WSYNC
        bne DrawGameOverScreenTop
        
        ldy #0
        inx
        lda GameSelectFlag
        bne TwoPlayerGameOver

        sta WSYNC

        ; lda #51
        lda #55
        sta TIM1T
OnePlayerGameOverTextDelay
        lda TIMINT
        beq OnePlayerGameOverTextDelay
        SLEEP 4

DrawGameOverScreenText1Player
        stx TempXPos                                    ; 3     6
        sty TempYPos                                    ; 3     9
        
        ldx Zero_bank1,y                                ; 4     13
        stx TempLetterBuffer                            ; 3     16
        
        ldx P0ScoreArr,y                                ; 4     20

        lda SC,y                                        ; 4     24
        sta GRP0                                        ; 3     27       -> [GRP0]
        
        lda OR,y                                        ; 4     31
        sta GRP1                                        ; 3     34       -> [GRP1], [GRP0] -> GRP0
        
        lda EColon,y                                    ; 4     38
        sta GRP0                                        ; 3     41       -> [GRP0]. [GRP1] -> GRP1
        
        lda Space,y                                     ; 4     45
        ldy TempLetterBuffer                            ; 3     48
        sta GRP1                                        ; 3     51       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     54       -> [GRP0], [GRP1] -> GRP1
        sty GRP1                                        ; 3     57       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     60       ?? -> [GRP0], [GRP1] -> GRP1
        
        ldx TempXPos                                    ; 3     63
        ldy TempYPos                                    ; 3     66
        iny                                             ; 2     68

        inx                                             ; 2     70

        cpx #63                                         ; 2     72
        ; nop                                             ; 2     74
        ; nop                                             ; 2     76
        SLEEP 4
        bne DrawGameOverScreenText1Player

        lda #0
        sta GRP0
        sta GRP1
        sta GRP0
        jmp DrawGameOverScreenMiddle

TwoPlayerGameOver

        sta WSYNC

        lda #55
        sta TIM1T

        lda P0Score
        cmp P1Score
        beq DrawGameOverScreenText2PlayerTieGame

TwoPlayerGameOverTextAlignDelay
        lda TIMINT
        beq TwoPlayerGameOverTextAlignDelay
        SLEEP 4

DrawGameOverScreenText2Player
        stx TempXPos                                    ; 3     6
        sty TempYPos                                    ; 3     9
        
        ldx IN,y                                        ; 4     13
        stx TempLetterBuffer                            ; 3     16
        
        ldx _W,y                                        ; 4     20

        lda PL,y                                        ; 4     24
        sta GRP0                                        ; 3     27       -> [GRP0]
        
        lda AY,y                                        ; 4     31
        sta GRP1                                        ; 3     34       -> [GRP1], [GRP0] -> GRP0
        
        lda ER,y                                        ; 4     38
        sta GRP0                                        ; 3     41       -> [GRP0]. [GRP1] -> GRP1
        
        lda Winner,y                                    ; 4     45
        ldy TempLetterBuffer                            ; 3     48
        sta GRP1                                        ; 3     51       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     54       -> [GRP0], [GRP1] -> GRP1
        sty GRP1                                        ; 3     57       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     60       ?? -> [GRP0], [GRP1] -> GRP1
        
        ldx TempXPos                                    ; 3     63
        ldy TempYPos                                    ; 3     66
        iny                                             ; 2     68

        inx                                             ; 2     70

        cpx #64                                         ; 2     72
        ; nop                                             ; 2     74
        ; nop                                             ; 2     76
        SLEEP 3
        bne DrawGameOverScreenText2Player

        jmp DrawGameOverScreenMiddle

DrawGameOverScreenText2PlayerTieGame

TwoPlayerGameOverTieGameTextAlignDelay
        lda TIMINT
        and #%10000000
        beq TwoPlayerGameOverTieGameTextAlignDelay
        SLEEP 4 

DrawGameOverScreenTieGameText2Player
        stx TempXPos                                    ; 3     6
        sty TempYPos                                    ; 3     9
        
        ldx Space,y                                     ; 4     13
        stx TempLetterBuffer                            ; 3     16
        
        ldx ME,y                                        ; 4     20

        lda _T,y                                        ; 4     24
        sta GRP0                                        ; 3     27       -> [GRP0]
        
        lda IE,y                                        ; 4     31
        sta GRP1                                        ; 3     34       -> [GRP1], [GRP0] -> GRP0
        
        lda Space,y                                     ; 4     38
        sta GRP0                                        ; 3     41       -> [GRP0]. [GRP1] -> GRP1
        
        lda GA,y                                        ; 4     45
        ldy TempLetterBuffer                            ; 3     48
        sta GRP1                                        ; 3     51       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     54       -> [GRP0], [GRP1] -> GRP1
        sty GRP1                                        ; 3     57       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     60       ?? -> [GRP0], [GRP1] -> GRP1
        
        ldx TempXPos                                    ; 3     63
        ldy TempYPos                                    ; 3     66
        iny                                             ; 2     68

        inx                                             ; 2     70

        cpx #64                                         ; 2     72
        nop                                             ; 2     74
        nop                                             ; 2     76
        bne DrawGameOverScreenTieGameText2Player

DrawGameOverScreenMiddle
        inx
        cpx #101
        sta WSYNC
        bne DrawGameOverScreenMiddle

        ldy #0
        lda #55
        sta TIM1T
GameOverBottomTextAlignDelay
        lda TIMINT
        beq GameOverBottomTextAlignDelay

DrawGameOverScreenBottomText
        SLEEP 3                                         ; 3     6
        sty TempYPos                                    ; 3     9
        
        ldx E_,y                                        ; 4     13
        stx TempLetterBuffer                            ; 3     16
        
        ldx IR,y                                        ; 4     20

        lda _P,y                                        ; 4     24
        sta GRP0                                        ; 3     27       -> [GRP0]
        
        lda RE_bank1,y                                  ; 4     31
        sta GRP1                                        ; 3     34       -> [GRP1], [GRP0] -> GRP0
        
        lda SS,y                                        ; 4     38
        sta GRP0                                        ; 3     41       -> [GRP0]. [GRP1] -> GRP1
        
        lda _F,y                                        ; 4     45
        ldy TempLetterBuffer                            ; 3     48
        sta GRP1                                        ; 3     51       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     54       -> [GRP0], [GRP1] -> GRP1
        sty GRP1                                        ; 3     57       -> [GRP1], [GRP0] -> GRP0
        stx GRP0                                        ; 3     60       ?? -> [GRP0], [GRP1] -> GRP1
        
        ldy TempYPos                                    ; 3     63
        iny                                             ; 2     65
        cmp #0                                          ; 2     67
        SLEEP 9                                         ; 9     76
        bne DrawGameOverScreenBottomText

        ldx #85
DrawGameOverScreenBottom
        dex
        sta WSYNC
        bne DrawGameOverScreenBottom
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Game Over Screen Start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EndofViewableScreen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of Viewable Screen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Setup Overscan  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #2
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
        beq FlyGameSkipDecDebounceCtr
        dec DebounceCtr
FlyGameSkipDecDebounceCtr

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
        and #SWITCH_GAME_SELECT
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

        lda StartGameFlag
        beq FlyGameTitleOverscan
        jmp SkipFlyGameTitleOverscan
FlyGameTitleOverscan

        lda DebounceCtr
        bne DontStartGame
        lda INPT4
        bmi DontStartGame
        sta StartGameFlag
        jmp PlayFlyGame
DontStartGame

        ; if up pressed Game1SelectionGfx
        lda #P0_JOYSTICK_UP
        bit SWCHA 
        bne SkipSelectFlyGame1Player
        lda #0
        sta GameSelectFlag
        
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
        lda #P0_JOYSTICK_DOWN
        bit SWCHA
        bne SkipSelectFlyGame2Player
        lda #1
        sta GameSelectFlag

        lda #<Cursor
        sta Game2SelectionGfx
        lda #>Cursor
        sta Game2SelectionGfx+1
        
        lda #<Space
        sta Game1SelectionGfx
        lda #>Space
        sta Game1SelectionGfx+1
SkipSelectFlyGame2Player

        lda #TWO_COPIES_CLOSE
        sta NUSIZ0
        lda #ONE_COPY
        sta NUSIZ1
        lda #0
        sta VDELP0
        sta VDELP1

        jmp FlyGameRomMusicPlayer

SkipFlyGameTitleOverscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Player 2 Join Flasher ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda FlasherCtr
        bne DecFlasher
        lda #FLY_GAME_P1_JOIN_FLASH_RATE
        sta FlasherCtr
        jmp SkipFlasher
DecFlasher
        dec FlasherCtr
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
        beq SkipRestartFlyGame
        
        lda BlockP0SwatCtr
        bne DecrementP0BlockFireCtr

        lda INPT4
        bmi SkipRestartFlyGame
        jmp Reset
DecrementP0BlockFireCtr
        dec BlockP0SwatCtr
SkipRestartFlyGame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Restart Fly Game ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Game Over Skip Controls ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda GameOverFlag                ; If the Gameover flag is set then
        beq SkipDisableControls         ; do not allow any movement of the
        jmp SkipPlayerControls          ; players
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

        lda #FLY_GAME_P1_X_START_POS
        sta Player1XPos
        lda #FLY_GAME_P1_Y_START_POS
        sta Player1YPos
        
SkipP1JoinGame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Player 2 Join Game ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Player Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldx #0
PlayerControl
; Player Up/Down Control
        ldy Player0YPos,x
        
        lda P0JoyStickUp,x
        bit SWCHA
        bne SkipMovePlayerUp
        cpy #FLY_GAME_FIELD_START_LINE
        beq SkipMovePlayerUp
        dey
        dey
SkipMovePlayerUp

        lda P0JoyStickDown,x
        bit SWCHA
        bne SkipMovePlayerDown
        cpy #192-#FLY_GAME_PLAYER_HEIGHT
        beq SkipMovePlayerDown
        iny
        iny
SkipMovePlayerDown
        sty Player0YPos,x

        ldy Player0XPos,x
; Player Left/Right Control
        lda P0JoyStickLeft,x
        and SWCHA
        bne SkipMovePlayerLeft
        cpy #0
        beq SkipMovePlayerLeft
        dec Player0XPos,x
SkipMovePlayerLeft

        lda P0JoyStickRight,x
        and SWCHA
        bne SkipMovePlayerRight
        cpy #160-#17
        beq SkipMovePlayerRight
        inc Player0XPos,x
SkipMovePlayerRight

;; Hide Player Overflow
        lda #FLY_GAME_PLAYER_HEIGHT
        sta P0Height,x
        
        lda #192-#FLY_GAME_PLAYER_HEIGHT*2-4
        cmp Player0YPos,x
        bcs SkipHidePlayerOverflow
        lda #192
        sbc Player0YPos,x               ; need carry not set so it's even
        lsr
        sta P0Height,x
SkipHidePlayerOverflow

        inx
        lda GameSelectFlag
        beq SkipPlayer1Move
        cpx #1
        beq PlayerControl
SkipPlayer1Move

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Player Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Players Detect Hit ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #0
PlayerDetectHit
        ldy #0

        lda DebounceCtr,x
        beq PlayerSwatOk1
        jmp PlayerSkipSwat
PlayerSwatOk1

        lda BlockP0SwatCtr,x
        beq PlayerSwatOk2
        jmp SkipP0HitDetection
PlayerSwatOk2

        lda INPT4,x
        bpl PlayerSwatOk3
        jmp PlayerNotSwat1 
PlayerSwatOk3
        lda #1
        sta BlockP0SwatCtr,x

        lda #8
        sta DebounceCtr,x

        cpx #0
        bne LoadPlayer1SwatGfx
        lda #<PlayerSwatGfx
        sta Player0GfxPtr

        lda #>PlayerSwatGfx
        sta Player0GfxPtr+1
        jmp CheckEnemyHit
LoadPlayer1SwatGfx
        lda #<PlayerSwatGfx
        sta Player1GfxPtr

        lda #>PlayerSwatGfx
        sta Player1GfxPtr+1

CheckEnemyHit
        lda Player0XPos,x
        clc
        adc #1
        cmp Enemy0XPos,y
        bcs SkipPlayerEnemyHit
        clc
        adc #16
        cmp Enemy0XPos,y
        bcc SkipPlayerEnemyHit

        lda Player0YPos,x
        sec
        sbc #FLY_GAME_ENEMY_HEIGHT*2-1
        cmp Enemy0YPos,y
        bcs SkipPlayerEnemyHit
        clc
        adc #28
        cmp Enemy0YPos,y
        bcc SkipPlayerEnemyHit

        lda #0
        sta Enemy0Alive,y
        sta Enemy0YPos,y

        lda #FLY_GAME_ENEMY_GENERATION_DELAY
        sta Enemy0GenTimer,y

        sed
        lda P0Score,x
        clc
        adc #1
        sta P0Score,x
        cld
SkipPlayerEnemyHit

        iny 
        cpy #2
        bne CheckEnemyHit

        jmp PlayerSkipSwat

SkipP0HitDetection

PlayerNotSwat1
        lda INPT4,x
        bpl PlayerNotSwat2
        lda #0
        sta BlockP0SwatCtr,x
PlayerNotSwat2
        lda DebounceCtr,x
        bne PlayerSkipSwat

        cpx #0
        bne LoadPlayer1Gfx
        lda #<PlayerGfx
        sta Player0GfxPtr

        lda #>PlayerGfx
        sta Player0GfxPtr+1
        jmp PlayerSkipSwat
LoadPlayer1Gfx
        lda #<PlayerGfx
        sta Player1GfxPtr

        lda #>PlayerGfx
        sta Player1GfxPtr+1

PlayerSkipSwat
        inx 
        cpx #2
        beq SkipPlayerDetectHit
        jmp PlayerDetectHit
SkipPlayerDetectHit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Players Detect Hit ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Enemies Lifecycle ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #0
EnemyMovement

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Do Enemies Movement? ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda SWCHB                       ; Check to see is Player 0 difficulty
        and #SWITCH_P0_PRO_DIFFICULTY   ; is set to A or B. If it's Be then 
        bne MoveEnemies                 ; we use the modulus of the flasher
        lda FlasherCtr                     ; to skip moving every other frame
        and #1                          ; to simulate slow moving enemies
        beq MoveEnemies                 ; by skipping the enemy movement
        jmp SkipEnemyMovement          ; code
MoveEnemies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Do Enemies Movement? ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Enemies Timer Countdown ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda Enemy0GenTimer,x            ; Check to see if the Enemy countdown
        beq SkipEnemy0CountdownTimer    ; timer is not 0. If it is not then we
        dec Enemy0GenTimer,x            ; decrement it
SkipEnemy0CountdownTimer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Enemies Timer Countdown ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Check Generate Enemy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda Enemy0GenTimer,x            ; See if the Enemy Generation Countdown
        cmp #1                          ; timer is equal to 1. If so then
        bne SkipGenerateEnemy           ; execute the enemy generation code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Check Generate Enemy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Set Enemy Alive ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetEnemyAlive
        lda #1                          ; Start Enemy Generation by setting the
        sta Enemy0Alive,x               ; enemy to now be alive
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Set Enemy Alive ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Determine Start Edge ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DetermineEdge
        lda FlasherCtr                     ; Generate a random number between
        jsr GetRandomNumber             ; 0-3 to determine what edge to
        and #3                          ; start on
        sta Enemy0StartEdge,x
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Determine Start Edge ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Set Enemy Start Position ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda INPT2                       ; Generate a random number to be used
        jsr GetRandomNumber             ; as a starting X position for the
        and #158 ;#159 127              ; enemies
        tay                             ;

        ; Generate Start Pos
        lda Enemy0StartEdge,x           ; Using the start edge determined above
        bne SkipTopE0StartEdge          ; Set the enemies X and Y coodinates
        lda #FLY_GAME_FIELD_START_LINE ; for their starting positions with
        sta Enemy0YPos,x                ; "Randomly" generated numbers
        sty Enemy0XPos,x                ;
        jmp SkipGenerateEnemy           ;
SkipTopE0StartEdge
        
        cmp #1
        bne SkipRightSideE0StartEdge
        lda #158
        sta Enemy0XPos,x
        
        lda INPT2
        jsr GetRandomNumber
        and #192-#FLY_GAME_FIELD_START_LINE-(FLY_GAME_ENEMY_HEIGHT*2)-2
        clc
        adc #FLY_GAME_FIELD_START_LINE
        ; and #254
        sta Enemy0YPos,x
        jmp SkipGenerateEnemy
SkipRightSideE0StartEdge
        cmp #2
        bne SkipBottomE0StartEdge
        lda #192-(#FLY_GAME_ENEMY_HEIGHT*2)
        sta Enemy0YPos,x
        sty Enemy0XPos,x
        jmp SkipGenerateEnemy
SkipBottomE0StartEdge
        cmp #3
        bne SkipLeftSideE0StartEdge
        lda #1
        sta Enemy0XPos,x
        
        lda INPT2
        jsr GetRandomNumber
        and #192-#FLY_GAME_FIELD_START_LINE-(FLY_GAME_ENEMY_HEIGHT*2)-2 ;142
        clc
        adc #FLY_GAME_FIELD_START_LINE
        ; and #254
        sta Enemy0YPos,x
SkipLeftSideE0StartEdge
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Set Enemy Start Position ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Set Enemy Horizontal Position ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipGenerateEnemy
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Set Enemy Horizontal Position ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Determine Moving Enemies ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda Enemy0Alive,x               ; Check to see if the enemies are alive
        beq SkipEnemyMovement           ; if so then do movement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Determine Moving Enemies ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Determine Generating New Way Points ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Enemy0VectorPath
        ;; Do vector path code here
        lda Enemy0HWayPoint,x           ; Check to see if the Horizontal Way
        bne SkipGenerateNewE0WayPoints  ; Point is 0 and we need new ones
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Determine Generating New Way Points ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Generate New Way Points ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RegenE0HSeed
        lda INPT4
        beq RegenE0HSeed
        jsr GetRandomNumber
        and #158
        sta Enemy0HWayPoint,x

RegenE0VSeed
        lda INPT4
        beq RegenE0VSeed
        jsr GetRandomNumber
        and #192-#FLY_GAME_FIELD_START_LINE-(FLY_GAME_ENEMY_HEIGHT*2)-2 ;#148
        clc
        adc #FLY_GAME_FIELD_START_LINE
        sta Enemy0VWayPoint,x
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Generate New Way Points ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Do Enemy Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipGenerateNewE0WayPoints
        lda Enemy0HWayPoint,x           ; Subtract Enemy Positions from Way 
        sec                             ; Points to determine which way the
        sbc Enemy0XPos,x                ; enemy should move to move toward the
        bne SkipSetE0HMoveFlat          ; Way Point
        jmp SkipSetE0HMoveRight
SkipSetE0HMoveFlat
        bcc SkipSetE0HMoveLeft
        inc Enemy0XPos,x
        jmp SkipSetE0HMoveRight
SkipSetE0HMoveLeft
        bcs SkipSetE0HMoveRight
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Do Enemy Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Use Crazy Enemies Or Not ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda SWCHB                       ; Check the Player difficulty switch
        and #SWITCH_P1_PRO_DIFFICULTY   ; to see if it's set to A to use crazy
        bne CrazyEnemies                ; Enemies.

        lda Enemy0XPos,x                ; Crazy enemies regenerate way points
        sec                             ; as soon as they reach an endpoint so
        sbc Enemy0HWayPoint,x           ; they never travel in a straight 
        bne SkipRegenWayPoints          ; horizontal or vertical line
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Use Crazy Enemies Or Not ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Set Enemy End Point ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda Enemy0YPos,x                ; Add Enemy height to the current enemy
        clc                             ; Y Position to determine when we 
        adc #FLY_GAME_ENEMY_HEIGHT*2    ; should stop drawing the enemy
        sta Enemy0YPosEnd,x             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Set Enemy End Point ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SkipEnemyMovement
        inx                             ; Increment our enemy index to process
        cpx #2                          ; enemy movement for the next enemy
        beq EnemyMovementDone           ;
        jmp EnemyMovement               ;
EnemyMovementDone
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Enemies Lifecycle ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipPlayerControls

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Rom Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FlyGameRomMusicPlayer
; Track 0
        ldy #0                          ; 2     Initialize Y-Index to 0
        lda (FlyGameNotePtrCh0),y       ; 5     Load first note duration to A
        and #DURATION_MASK              ; 2     Mask so we only have the note duration
        tay                             ; 2     Make A the y index
        lda FlyGameNoteDurations,y      ; 4     Get the actual duration based on the duration settin
        cmp FlyGameFrameCtrTrk0         ; 3     See if it equals the Frame Counter
        bne FlyGameTrack0NextNote       ; 2/3   If so move the NotePtr to the next note

        lda FlyGameNotePtrCh0           ; 3     Load the Note Pointer to A
        clc                             ; 2     Clear the carry 
        adc #2                          ; 2     Add 4 to move the Note pointer to the next note
        sta FlyGameNotePtrCh0           ; 3     Store the new note pointer

        lda #0                          ; 2     Load Zero to
        sta FlyGameFrameCtrTrk0         ; 3     Reset the Frame counter
FlyGameTrack0NextNote
        ldy #0
        lda (FlyGameNotePtrCh0),y       ; 5     Load first note duration to A
        and #DURATION_MASK              ; 2     Mask so we only have the note duration
        cmp #0                          ; 2     See if the notes duration equals 0
        bne FlyGameSkipResetTrack0      ; 2/3   If so go back to the beginning of the track

        lda #<FlyGameTrack0             ; 4     Store the low byte of the track to 
        sta FlyGameNotePtrCh0           ; 3     the Note Pointer
        lda #>FlyGameTrack0             ; 4     Store the High byte of the track to
        sta FlyGameNotePtrCh0+1         ; 3     the Note Pointer + 1
        
        lda StartGameFlag               ; 3     Check to see if the game has started
        bne SkipLoadGameTitleTrack0     ; 2/3   If so then don't load the title track
        lda #<FlyGameTitleTrack0        ; 4     Store the low byte of the track to 
        sta FlyGameNotePtrCh0           ; 3     the Note Pointer
        lda #>FlyGameTitleTrack0        ; 4     Store the High byte of the track to
        sta FlyGameNotePtrCh0+1         ; 3     the Note Pointer + 1
SkipLoadGameTitleTrack0
FlyGameSkipResetTrack0

        lda (FlyGameNotePtrCh0),y       ; 5     Load Volume to A
        and #FREQUENCY_MASK             ; 2     Mask so we only have the note frequency
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        sta AUDF0                       ; 3     and set the Note Frequency
        iny                             ; 2     Increment Y (Y=1) to point to the Note Frequency
        lda (FlyGameNotePtrCh0),y       ; 5     Load Frequency to A
        and #VOLUME_MASK                ; 2     Mask so we only have the note Volume
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        sta AUDV0                       ; 3     and set the Note Volume
        
        lda (FlyGameNotePtrCh0),y       ; 5     Load Control to A
        and #CONTROL_MASK               ; 2     Mask so we only have the note Control
        sta AUDC0                       ; 3     and set the Note Control
        inc FlyGameFrameCtrTrk0         ; 5     Increment the Frame Counter to duration compare later

; Track 1
        ldy #0                          ; 2     Initialize Y-Index to 0
        lda (FlyGameNotePtrCh1),y       ; 5     Load first note duration to A
        and #DURATION_MASK              ; 2     Mask so we only have the note duration
        tay                             ; 2     Make A the y index
        lda FlyGameNoteDurations,y      ; 4     Get the actual duration based on the duration settin
        cmp FlyGameFrameCtrTrk1         ; 3     See if it equals the Frame Counter
        bne FlyGameTrack1NextNote       ; 2/3   If so move the NotePtr to the next note

        lda FlyGameNotePtrCh1           ; 3     Load the Note Pointer to A
        clc                             ; 2     Clear the carry 
        adc #2                          ; 2     Add 4 to move the Note pointer to the next note
        sta FlyGameNotePtrCh1           ; 3     Store the new note pointer

        lda #0                          ; 2     Load Zero to
        sta FlyGameFrameCtrTrk1         ; 3     Reset the Frame counter
FlyGameTrack1NextNote
        ldy #0
        lda (FlyGameNotePtrCh1),y       ; 5     Load first note duration to A
        and #DURATION_MASK              ; 2     Mask so we only have the note duration
        cmp #0                          ; 2     See if the notes duration equals 0
        bne FlyGameSkipResetTrack1      ; 2/3   If so go back to the beginning of the track

        lda #<FlyGameTrack1             ; 4     Store the low byte of the track to 
        sta FlyGameNotePtrCh1           ; 3     the Note Pointer
        lda #>FlyGameTrack1             ; 4     Store the High byte of the track to
        sta FlyGameNotePtrCh1+1         ; 3     the Note Pointer + 1
        
        lda StartGameFlag               ; 3     Check to see if the game has started
        bne SkipLoadGameTitleTrack1     ; 2/3   If so then don't load the title track
        lda #<FlyGameTitleTrack1        ; 4     Store the low byte of the track to 
        sta FlyGameNotePtrCh1           ; 3     the Note Pointer
        lda #>FlyGameTitleTrack1        ; 4     Store the High byte of the track to
        sta FlyGameNotePtrCh1+1         ; 3     the Note Pointer + 1
SkipLoadGameTitleTrack1
FlyGameSkipResetTrack1

        lda (FlyGameNotePtrCh1),y       ; 5     Load Volume to A
        and #FREQUENCY_MASK             ; 2     Mask so we only have the note frequency
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        sta AUDF1                       ; 3     and set the Note Frequency
        iny                             ; 2     Increment Y (Y=1) to point to the Note Frequency
        lda (FlyGameNotePtrCh1),y       ; 5     Load Frequency to A
        and #VOLUME_MASK                ; 2     Mask so we only have the note Volume
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        sta AUDV1                       ; 3     and set the Note Volume
        
        lda (FlyGameNotePtrCh1),y       ; 5     Load Control to A
        and #CONTROL_MASK               ; 2     Mask so we only have the note Control
        sta AUDC1                       ; 3     and set the Note Control
        inc FlyGameFrameCtrTrk1         ; 5     Increment the Frame Counter to duration compare later


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Rom Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Reset Game ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda SWCHB
        and #SWITCH_GAME_RESET
        bne SkipSwitchReset
        jmp Reset
SkipSwitchReset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Reset Game ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FlyGameOverscanWaitLoop
        lda TIMINT
        and #%10000000
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
ATARI_PAINT_TITLE_COLOR                     = #$02
ATARI_PAINT_TITLE_ALIGNMENT_TIMER           = #56;48

ATARI_PAINT_BACKGROUND_COLOR                = #$0F
ATARI_PAINT_FOREGROUND_SELECTED_COLOR       = #$88

ATARI_PAINT_CONTROL_INITIAL_SELECTION_POS   = #58

ATARI_PAINT_BRUSH_START_XPOS                = #78
ATARI_PAINT_BRUSH_START_YPOS                = #99
ATARI_PAINT_BRUSH_MOVE_DELAY                = #8

ATARI_PAINT_CANVAS_SIZE                     = #104
ATARI_PAINT_CANVAS_OVERFLOW_MASK_POS        = #127
ATARI_PAINT_CANVAS_ROW_HEIGHT               = #6

ATARI_PAINT_PALETTE_START_POS               = #14

BLACK                                       = #$00
WHITE                                       = #$0F
RED                                         = #$42
BLUE                                        = #$86
YELLOW                                      = #$1D;$1E
GREEN                                       = #$B2
ORANGE                                      = #$36
GRAY                                        = #$09;$0A
BROWN                                       = #$F0
SKY                                         = #$9B;$9C
PURPLE                                      = #$64


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Atari Paint Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        SEG.U AtariPaintVars
        ORG Overlay

TempXPos                        ds 1
TempYPos                        ds 1
TempLetterBuffer                ds 1
CanvasRowLineCtr                ds 1
ControlsColor                   ds 1

        ORG Overlay
CanvasByteMask                  ds 1
CanvasRow                       ds 1
CanvasColorIdx
CanvasByteBuffer                ds 1
CanvasIdx                       ds 1
CanvasByteIdx                   ds 1

PaletteColorOffset              ds 1

DebounceCtr                     ds 1

DrawOrEraseFlag                 ds 1
ForegroundBackgroundFlag        ds 1

BrushXPos                       ds 1
BrushYPos                       ds 1
BrushSelectedXPos               ds 1
BrushColor                      ds 1
BackgroundColor                 ds 1
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

        lda #ATARI_PAINT_CONTROL_INITIAL_SELECTION_POS
        sta BrushSelectedXPos

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

        ldx #3                                  ; Set Missle 1 Position
        lda #ATARI_PAINT_CANVAS_OVERFLOW_MASK_POS
        jsr CalcXPos_bank1
        sta WSYNC
        sta HMOVE

        lda #$F0
        sta HMM1
        sta WSYNC
        sta HMOVE
AtariPaintFrame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Start VBLANK ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 3 VSYNC Lines
        lda #2
        sta VSYNC ; Turn on VSYNC
        sta WSYNC
        sta WSYNC
        sta WSYNC
        ldy #0
        sty VSYNC ; Turn off VSYNC

; 37 VBLANK lines
        ldx #37
AtariPaintVerticalBlank
        sta WSYNC
        dex
        bne AtariPaintVerticalBlank
        stx VBLANK                      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End VBLANK ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AtariPaintViewableScreen
        sta WSYNC
        inx
        cpx #3
        bne AtariPaintViewableScreen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Title Text ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #ATARI_PAINT_TITLE_ALIGNMENT_TIMER ; Timer to align the Atari Paint
        sta TIM1T                       ; Title header in the middle of the
AtariPaintTitleWaitLoop                 ; screen
        lda TIMINT                      ; Load the values into the built in  
        and #%10000000                  ; then wait until it has expired
        beq AtariPaintTitleWaitLoop     ;
        nop   
        ; inx                             ; Increment the line counter for timer
AtariPaintDrawTitle
        sty TempYPos                    ; 3     9       Store Y Register so we can use it again
        
        ldx T_,y                        ; 4     13      Load Graphics into the Y Register and
        stx TempLetterBuffer            ; 3     16      store it to memory to save time later
        
        ldx IN,y                        ; 4     20      Load Graphics into the X Register and
                                        ;               store it to memory to save time later

        lda AT,y                        ; 4     24      Load Graphics
        sta GRP0                        ; 3     27      AT -> [GRP0]
        
        lda AR,y                        ; 4     31      Load Graphics
        sta GRP1                        ; 3     34      AR -> [GRP1], [GRP0] -> GRP0
        
        lda I_,y                        ; 4     38      Load Graphics
        sta GRP0                        ; 3     41      I  -> [GRP0], [GRP1] -> GRP1
        
        lda PA,y                        ; 4     45      Load Graphics
        ldy TempLetterBuffer            ; 3     48      Load Graphics previously stored in memory
        sta GRP1                        ; 3     51      PA -> [GRP1], [GRP0] -> GRP0
        stx GRP0                        ; 3     54      IN -> [GRP0], [GRP1] -> GRP1
        sty GRP1                        ; 3     57      T  -> [GRP1], [GRP0] -> GRP0
        stx GRP0                        ; 3     60      ?? -> [GRP0], [GRP1] -> GRP1
        

        ldy TempYPos                    ; 3     66      Restore Y Register to previous value
        iny                             ; 2     68      Increment Y for graphics index
        cpy #6                          ; 2     72      Check if we're on line 10
        SLEEP 6
        sty COLUP0
        sty COLUP1
        bne AtariPaintDrawTitle         ; 2/3   2/3     If not to line 10 cont drawing the letters
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Title Text ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Brush Control Row ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #MISSLE_SIZE_FOUR_CLOCKS | #TWO_COPIES_MEDIUM ; Set the player
        sta NUSIZ1                      ; graphics to two copies and the
                                        ; missle graphics to be 4x wide

        lda ControlsColor               ; Adjust Colors shown for controls text
        cmp #GRAY                       ; because the way the gradient works,
        bne AdjustGrayColor             ; it forces it to change to a different
        sec                             ; color.
        sbc #3
        sta ControlsColor
AdjustGrayColor
        cmp #WHITE
        bne AdjustWhiteColor
        sec
        sbc #6
        sta ControlsColor
AdjustWhiteColor
        cmp #YELLOW
        bne AdjustYellowColor
        dec ControlsColor
        dec ControlsColor
AdjustYellowColor
        
        ldx #10
        ldy #0                          ; Initialize the graphics index to 0
AtariPaintControlRow
        cpx #15                         ; Check to see if we're on line 15
        bmi SkipControlRow              ; yet, if so then
        lda #MISSLE_SIZE_FOUR_CLOCKS | #TWO_COPIES_MEDIUM ; Reset Player and
        sta NUSIZ0                      ; missle size and number
        lda ControlsColor               ; Set the new color for each of the 
        sta COLUP0                      ; players to make the gradient for
        sta COLUP1                      ; the Controls Text

        lda F_,y                        ; Load Graphics
        sta GRP0                        ; F_ -> [GRP0]
        
        lda B_,y                        ; Load Graphics
        sta GRP1                        ; B_ -> [GRP1], [GRP0] -> GRP0

        lda E_,y                        ; Load Graphics
        sta GRP0                        ; E_ -> [GRP0], [GRP1] -> GRP1
        
        lda C_,y                        ; Load Graphics
        sta GRP1                        ; C_ -> [GRP1], [GRP0] -> GRP0

        sta GRP0                        ; ?? -> [GRP0], [GRP1] -> GRP1
        
        inc ControlsColor               ; Increment the ControlsColor gradient
        iny                             ; Increment Y for the graphics index

        lda #ATARI_PAINT_TITLE_COLOR    ; Reset the Player1 color so the cursor
        sta COLUP0                      ; is the correct color becuase we don't
                                        ; have time to do this before the next
                                        ; section
SkipControlRow
        lda #MISSLE_SIZE_FOUR_CLOCKS | #MISSLE_BALL_DISABLE ; Change the ball
        sta NUSIZ0                      ; a line before you want it or else
                                        ; there will be a delay in change

        inx                             ; Increment the line counter
        sta WSYNC                       ; and check to see if we're on line 21
        cpx #21                         ; If not then repeat if so then move
        bne AtariPaintControlRow        ; on to the next section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Brush Control Row ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Brush Control Selection Row ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        cpx BrushYPos                   ; X=21
        bne ControlSkipDrawBrush
        lda #MISSLE_BALL_ENABLE
ControlSkipDrawBrush
        sta ENAM0

        lda #MISSLE_BALL_ENABLE
        sta ENABL
        sta WSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #MISSLE_BALL_DISABLE | #MISSLE_SIZE_TWO_CLOCKS
        sta ENABL
        sta ENAM0
        sta NUSIZ0
        sta WSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        ldy #4
PositionP1Mask
        dey
        bne PositionP1Mask
        SLEEP 3
        sta RESP1
        lda #$30
        sta HMP1
        
        ldy #8
HMOVECountdown
        dey
        bne HMOVECountdown

        sta HMOVE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #255
        sty PF0
        sty PF1
        sty PF2
        
        lda SWCHB
        and #SWITCH_COLOR_TV
        beq SkipColorCanvas
        sty GRP1
SkipColorCanvas
        ldx #25
        sta WSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Brush Control Selection Row ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Color Palette ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        SLEEP 3
AtariPaintPalette
        lda #GRAY
        sta COLUPF
        
        cpx BrushYPos
        bne PaletteSkipDrawBrush
        lda #MISSLE_BALL_ENABLE
        jmp PaletteDrawBrush
PaletteSkipDrawBrush
        lda #MISSLE_BALL_DISABLE
        nop
PaletteDrawBrush

        sta.w ENAM0
        ; sta ENAM0

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Color Palette ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; ldy #MISSLE_BALL_DISABLE
        inx 
        iny                             ; Wrap Y around to #MISSLE_BALL_DISABLE
        sty ENAM0
        lda BackgroundColor
        sta COLUBK
        sta WSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        sty PF0
        sty PF1
        sty PF2
        sty GRP0
        
        ; lda BackgroundColor
        sta COLUP1
        lda #MISSLE_SIZE_FOUR_CLOCKS | #QUAD_SIZED_PLAYER
        sta NUSIZ1
        lda #MISSLE_BALL_ENABLE
        sta ENAM1
        
        lda BrushColor
        sta COLUPF
        
        inx
        
        lda SWCHB
        and #SWITCH_COLOR_TV
        bne SkipSingleColorCanvas
        lda #MISSLE_BALL_DISABLE
        sta WSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Single Color Canvas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AtariPaintCanvas
        cpx BrushYPos                                   ; 3
        bne SkipDrawBrush                               ; 2/3
        lda #MISSLE_BALL_ENABLE                         ; 2
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
        
        iny                                             ; 2
        iny                                             ; 2
        iny                                             ; 2 
        iny                                             ; 2
        
        lda #ATARI_PAINT_CANVAS_ROW_HEIGHT              ; 2
        sta CanvasRowLineCtr                            ; 3     (20)
SkipResetCanvasRowLineCtr

        lda #MISSLE_BALL_DISABLE                        ; 2
        sta PF2                                         ; 3
        sta PF0                                         ; 3     (8)

        inx                                             ; 2
        cpx #192                                        ; 2
        sta WSYNC                                       ; 3
        bne AtariPaintCanvas                            ; 2/3   (10)    (76)
        jmp EndOfCanvas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End Single Color Canvas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Multi Color Canvas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipSingleColorCanvas
        lda #MISSLE_BALL_DISABLE
        sta WSYNC
AtariPaintMultiColorCanvas
        
        cpx BrushYPos                                   ; 3
        bne SkipDrawMultiColorBrush                     ; 2/3
        lda #MISSLE_BALL_ENABLE                         ; 2
SkipDrawMultiColorBrush
        sta ENAM0                                       ; 3     (10)
        
        lda Canvas,y                                    ; 4
        sta COLUPF                                      ; 3
        lda Canvas+1,y                                  ; 4
        sta PF2                                         ; 3
        lda Canvas+2,y                                  ; 4
        sta PF0                                         ; 3
        lda Canvas+3,y                                  ; 4
        sta PF1                                         ; 3     (28)
        
        dec CanvasRowLineCtr                            ; 5
        bne SkipResetMultiColorCanvasRowLineCtr         ; 2/3
        
        iny                                             ; 2
        iny                                             ; 2
        iny                                             ; 2 
        iny                                             ; 2

        lda #ATARI_PAINT_CANVAS_ROW_HEIGHT              ; 2
        sta CanvasRowLineCtr                            ; 3     (20)
SkipResetMultiColorCanvasRowLineCtr

        lda #MISSLE_BALL_DISABLE                        ; 2
        sta PF2                                         ; 3
        sta PF0                                         ; 3     (8)

        inx                                             ; 2
        cpx #192                                        ; 2
        sta WSYNC                                       ; 3
        bne AtariPaintMultiColorCanvas                  ; 2/3   (10)    (76)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End Multi Color Canvas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EndOfCanvas

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Setup Overscan  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldy #2
        sty VBLANK

        sta PF1
        
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
        and #SWITCH_GAME_SELECT
        ora DebounceCtr
        bne AtariPaintSkipSwitchToBank0        
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Brush  Movement ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BrushControl
        lda DebounceCtr
        bne SkipMoveBrush

; Player 0 Up/Down Control
        ldy BrushYPos
        
        lda #P0_JOYSTICK_UP            
        bit SWCHA
        bne SkipMoveBrushUp
        cpy #21
        beq SkipMoveBrushUp
        tya
        sec
        sbc #ATARI_PAINT_CANVAS_ROW_HEIGHT
        tay
        lda #ATARI_PAINT_BRUSH_MOVE_DELAY
        sta DebounceCtr
SkipMoveBrushUp

        lda #P0_JOYSTICK_DOWN
        bit SWCHA
        bne SkipMoveBrushDown
        cpy #189
        beq SkipMoveBrushDown
        tya
        clc
        adc #ATARI_PAINT_CANVAS_ROW_HEIGHT
        tay
        lda #ATARI_PAINT_BRUSH_MOVE_DELAY
        sta DebounceCtr
SkipMoveBrushDown

        sty BrushYPos

; Player 0 Left/Right Control
        lda #P0_JOYSTICK_LEFT          
        and SWCHA
        bne SkipMoveBrushLeft
        lda BrushXPos
        cmp #2
        beq SkipMoveBrushLeft
        sec
        sbc #4
        sta BrushXPos
        lda #ATARI_PAINT_BRUSH_MOVE_DELAY
        sta DebounceCtr
SkipMoveBrushLeft

        lda #P0_JOYSTICK_RIGHT
        and SWCHA
        bne SkipMoveBrushRight
        lda BrushXPos
        cmp #158
        beq SkipMoveBrushRight
        clc
        adc #4
        sta BrushXPos
        lda #ATARI_PAINT_BRUSH_MOVE_DELAY
        sta DebounceCtr
SkipMoveBrushRight
       
SkipMoveBrush

        ldx #2                                  ; Set Missle 0 Position
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

; Determine Canvas Row
        ldx #0
        lda BrushYPos
        cmp #36
        bcs CalculateTilePosition
        jmp SkipPaintTile
CalculateTilePosition
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        sbc #36
DivideBy6
        inx
        sbc #ATARI_PAINT_CANVAS_ROW_HEIGHT
        bcs DivideBy6
        dex
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MultiplyBy4                     ; Multiply X by 4 to find canvas row
        txa
        asl
        asl
        sta CanvasRow
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Determine Canvas Column
        lda BrushXPos           ; Load the Brush X Position
        cmp #18                 ; If it's less than 18 then
        bpl PaintTileMinXPosCorrect 
        jmp SkipPaintTile       ; Skip over the routine
PaintTileMinXPosCorrect
        cmp #130                ; If it's more than 130 then
        bmi PaintTileMaxXPosCorrect 
        jmp SkipPaintTile       ; Skip over the routine
PaintTileMaxXPosCorrect
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        sec                     ; Subtract 18 so that the "canvas" is
        sbc #18                 ; aligned to the left side of the screen
        ldx #0                  ; Set X to 0 to count our divisions
        sec
DivideBy4
        inx                     ; increment x by 1
        sbc #4
        bcs DivideBy4           
        dex
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        txa
        sec
Modulo8        
        sbc #8
        bcs Modulo8
        clc
        adc #8
        sta CanvasByteIdx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        tay
        lda BrushXPos
        cmp #50
        bpl SkipSetCanvasIdx0
        
        lda CanvasSelectTableR,y
        ldx DrawOrEraseFlag
        beq LoadTableErasePF10
        eor #$FF
LoadTableErasePF10
        sta CanvasByteMask
        lda #0
        jmp CanvasIdxSet

SkipSetCanvasIdx0
        cmp #82
        bpl SkipSetCanvasIdx1

        lda CanvasSelectTable,y
        ldx DrawOrEraseFlag
        beq LoadTableErasePF20
        eor #$FF
LoadTableErasePF20
        sta CanvasByteMask
        lda #1
        jmp CanvasIdxSet

SkipSetCanvasIdx1
        cmp #98
        bpl SkipSetCanvasIdx2

        lda CanvasSelectTable,y
        ldx DrawOrEraseFlag
        beq LoadTableErasePF00
        eor #$FF
LoadTableErasePF00
        asl
        asl
        asl
        asl
        sta CanvasByteMask
        lda #2
        jmp CanvasIdxSet

SkipSetCanvasIdx2
        lda CanvasSelectTableR,y
        ldx DrawOrEraseFlag
        beq LoadTableErasePF11
        eor #$FF
LoadTableErasePF11
        asl
        asl
        asl
        asl
        sta CanvasByteBuffer
        lda CanvasSelectTableR,y
        ldx DrawOrEraseFlag
        beq LoadTableErasePF12
        eor #$FF
LoadTableErasePF12
        lsr
        lsr
        lsr
        lsr
        ora CanvasByteBuffer
        sta CanvasByteMask
        lda #3
        
CanvasIdxSet
        sta CanvasColorIdx
        
        clc
        adc CanvasRow
        sta CanvasIdx
        
        sec
        sbc CanvasColorIdx
        sta CanvasColorIdx
        
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

        lda SWCHB
        and #SWITCH_COLOR_TV
        beq SkipPaintTile
        lda DrawOrEraseFlag
        bne SkipPaintTile
        ldy CanvasColorIdx
        lda BrushColor
        sta Canvas,y
SkipPaintTile
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Calculate Tile to Paint ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Set Playfield Control ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda BrushYPos
        cmp #21
        bne SkipSetCanvasControl
        lda INPT4
        bmi SkipSetCanvasControl

        lda BrushXPos

        cmp #58
        bne SkipSetFGColor

        lda #0
        sta ForegroundBackgroundFlag
        jmp SkipClearCanvas

SkipSetFGColor

        cmp #66
        bne SkipSetBGColor

        lda #1
        sta ForegroundBackgroundFlag
        lda #0
        jmp SkipClearCanvas
SkipSetBGColor

        cmp #90
        bne SkipSetErase

        lda #1
        jmp SkipClearCanvas
SkipSetErase

        cmp #98                         ; If the Brush H Pos is 98 and fire
        bne SkipSetCanvasControl        ; then set all canvas array values to 0
        
        lda #0
        ldy #ATARI_PAINT_CANVAS_SIZE    ; Initialize Y to zero
ClearCanvasArray
        dey
        sta Canvas,y
        bne ClearCanvasArray            ; Once Y equal the Cnavas size
        jmp SkipSetCanvasControl
SkipClearCanvas
        sta DrawOrEraseFlag
        lda BrushXPos
        sta BrushSelectedXPos
SkipSetCanvasControl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Set Playfield Control ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Set Brush or Background Color ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda BrushYPos                   ; Make sure the Vertial Brush Position
        cmp #24                         ; is inbetween the upper and lower
        bcc SkipColorSelection          ; limits of the Palette section
        cmp #34                         ; 
        bcs SkipColorSelection          ; If so then
        
        lda INPT4                       ; Check to see is the fire button
        bmi SkipColorSelection          ; is pressed
        
        ldx #0
ColorSelectionLoop    
        lda PaletteColorTable,x
      
        ldy ForegroundBackgroundFlag    ; With the color loaded into
        bne SetBackGroundColor          ; the Accumulator, check the
        sta BrushColor                  ; ForegroundBackgroundFlag to
        jmp SkipSetBrushColor           ; see if we if we should set
SetBackGroundColor                      ; the Brush or Background
        sta BackgroundColor             ; color
SkipSetBrushColor

        inx
        lda PaletteColorOffset
        adc #14
        sta PaletteColorOffset
        
        lda BrushXPos
        cmp PaletteColorOffset
        bcs ColorSelectionLoop

SkipColorSelection        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Set Brush or Background Color ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Reset For Next Frame ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #0                          ; Reset or Diable Player
        stx ENAM1                       ; Grpahics, the Playfield
        stx COLUPF                      ; color, and Missle 1 used for
        stx GRP1                        ; masking the right canvas side
        stx GRP0                        ; overflow
        stx COLUP1                      ;

        lda #ATARI_PAINT_BACKGROUND_COLOR ; Set the Background Color back to 
        sta COLUBK                      ; the default for the top of the screen

        lda #ATARI_PAINT_CANVAS_ROW_HEIGHT ; Reset the Canavs Row Line Counter
        sta CanvasRowLineCtr            ; To the Row Height

        lda BrushColor
        sta ControlsColor                ; Color back to the line height

        lda ATARI_PAINT_PALETTE_START_POS-17
        sta PaletteColorOffset

        lda #THREE_COPIES_CLOSE         ; Reset the players to have
        sta NUSIZ0                      ; 3 copies close for the
        sta NUSIZ1                      ; title

        inx                             ; Enable Vertical Delay on both
        stx VDELP0                      ; Players for the title
        stx VDELP1                      ; 

        lda #ATARI_PAINT_TITLE_H_POS+8  ; Set Player 1 Position reusing
        jsr CalcXPos_bank1              ; X set to 1 from above for the
        sta WSYNC                       ; title since Player 1 is used
        sta HMOVE                       ; to mask the left canvas side

        ldx #4                          ; Set Player Ball Position
        lda BrushSelectedXPos           ; based on what Tool is 
        jsr CalcXPos_bank1              ; selected from the control row
        sta WSYNC                       ;
        sta HMOVE                       ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Reset For Next Frame ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AtariPaintOverscanWaitLoop
        lda TIMINT                      ; Check to see if our timer has expired
        beq AtariPaintOverscanWaitLoop  ; and we are done with our overscan 
                                        
        jmp AtariPaintFrame             ; Then we start the next Frame

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

PlayerGfx               .byte  #%01111110
                        .byte  #%11111111
                        .byte  #%10000001
                        .byte  #%10000001
                        .byte  #%10000001
                        .byte  #%10000001
                        .byte  #%10000001
                        .byte  #%10000001
                        .byte  #%10000001
                        .byte  #%11111111
                        .byte  #%01111110
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
PlayerSwatGfx           .byte  #%00000000
                        .byte  #%00000000
                        .byte  #%00000000
                        .byte  #%00000000
                        .byte  #%00000000
                        .byte  #%11111111
                        .byte  #%10000001
                        .byte  #%10000001
                        .byte  #%10000001
                        .byte  #%11111111
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
                        .byte  #%00011000
Space                   .byte  #%00000000
                        .byte  #%00000000
                        .byte  #%00000000
                        .byte  #%00000000     ; (22)
                        .byte  #%00000000
                        .byte  #%00000000     ; (24)

ON                      .byte  #%01001100
                        .byte  #%10101010
                        .byte  #%10101010
                        .byte  #%10101010
                        .byte  #%01001010
                        .byte  #0

GA                      .byte  #%01100100
                        .byte  #%10001010
                        .byte  #%10101110
                        .byte  #%10101010
                        .byte  #%01101010
                        .byte  #0

MER                     .byte  #%01110101
                        .byte  #%00010111
                        .byte  #%00110101
                        .byte  #%00010101
                        .byte  #%01110101

FL                      .byte  #%11101000
                        .byte  #%10001000
                        .byte  #%11001000
                        .byte  #%10001000
                        .byte  #%10001110

Y_                      .byte  #%00000101
                        .byte  #%00000101
                        .byte  #%00000010
                        .byte  #%00000010
                        .byte  #%00000010

E_                      .byte  #%11100000
                        .byte  #%10000000
                        .byte  #%11000000
                        .byte  #%10000000
                        .byte  #%11100000
                        .byte  #0

_P                      .byte  #%00001110
                        .byte  #%00001010
                        .byte  #%00001110
                        .byte  #%00001000
                        .byte  #%00001000
                        .byte  #0

RE_bank1                .byte  #%11001110
                        .byte  #%10101000
                        .byte  #%11101100
                        .byte  #%11001000
                        .byte  #%10101110
                        .byte  #0

SS                      .byte  #%01100110
                        .byte  #%10001000
                        .byte  #%11101110
                        .byte  #%00100010
                        .byte  #%11001100
                        .byte  #0

_F                      .byte  #%00001110
                        .byte  #%00001000
                        .byte  #%00001100
                        .byte  #%00001000
                        .byte  #%00001000
                        .byte  #0

F_                      .byte  #%11100000
                        .byte  #%10000000
                        .byte  #%11000000
                        .byte  #%10000000
                        .byte  #%10000000
                        .byte  #0

Cursor                  .byte  #%00001000
                        .byte  #%00001100
                        .byte  #%00001110
                        .byte  #%00001100
                        .byte  #%00001000
                        .byte  #0

B_                      .byte  #%11000000
                        .byte  #%10100000
                        .byte  #%11000000
                        .byte  #%10100000
                        .byte  #%11000000
                        .byte  #0

C_                      .byte  #%01100000
                        .byte  #%10000000
                        .byte  #%10000000
                        .byte  #%10000000
                        .byte  #%01100000
                        .byte  #0

Zero_bank1              .byte  #%11101110
                        .byte  #%10101010
                        .byte  #%10101010
                        .byte  #%10101010
                        .byte  #%11101110

One_bank1               .byte  #%00100010
                        .byte  #%00100010
                        .byte  #%00100010
                        .byte  #%00100010
                        .byte  #%00100010

Two_bank1               .byte  #%11101110
                        .byte  #%00100010
                        .byte  #%11101110
                        .byte  #%10001000
                        .byte  #%11101110

Three_bank1             .byte  #%11101110
                        .byte  #%00100010
                        .byte  #%11101110
                        .byte  #%00100010
                        .byte  #%11101110

Four_bank1              .byte  #%10101010
                        .byte  #%10101010
                        .byte  #%11101110
                        .byte  #%00100010
                        .byte  #%00100010

Five_bank1              .byte  #%11101110
                        .byte  #%10001000
                        .byte  #%11101110
                        .byte  #%00100010
                        .byte  #%11101110

Six_bank1               .byte  #%11101110
                        .byte  #%10001000
                        .byte  #%11101110
                        .byte  #%10101010
                        .byte  #%11101110

Seven_bank1             .byte  #%11101110
                        .byte  #%00100010
                        .byte  #%00100010
                        .byte  #%00100010
                        .byte  #%00100010

Eight_bank1             .byte  #%11101110
                        .byte  #%10101010
                        .byte  #%11101110
                        .byte  #%10101010
                        .byte  #%11101110

Nine_bank1              .byte  #%11101110
                        .byte  #%10101010
                        .byte  #%11101110
                        .byte  #%00100010
IE                      .byte  #%11101110
                        .byte  #%01001000
                        .byte  #%01001100
                        .byte  #%01001000
                        .byte  #%11101110
                        .byte  #0

OR                      .byte  #%01001100
                        .byte  #%10101010
                        .byte  #%10101110
                        .byte  #%10101100
                        .byte  #%01001010

TW                      .byte  #%11101010
                        .byte  #%01001010
                        .byte  #%01001110
                        .byte  #%01001110
                        .byte  #%01001010
                        .byte  #0

_T                      .byte  #%00001110
                        .byte  #%00000100
                        .byte  #%00000100
                        .byte  #%00000100
                        .byte  #%00000100
                        .byte  #0

LI                      .byte  #%10001110
                        .byte  #%10000100
                        .byte  #%10000100
                        .byte  #%10000100
                        .byte  #%11101110                      

SL                      .byte  #%01101000
                        .byte  #%10001000
                        .byte  #%11101000
                        .byte  #%00101000
                        .byte  #%11001110

WI                      .byte  #%10101110
                        .byte  #%10100100
                        .byte  #%10100100
                        .byte  #%11100100
ME                      .byte  #%10101110
                        .byte  #%11101000
                        .byte  #%10101100
                        .byte  #%10101000
                        .byte  #%10101110
                        .byte  #0
           
ES                      .byte  #%11100110
                        .byte  #%10001000
                        .byte  #%11001110
                        .byte  #%10000010
IR                      .byte  #%11101100
                        .byte  #%01001010
                        .byte  #%01001110
                        .byte  #%01001100
                        .byte  #%11101010
                        .byte  #0
           
FA                      .byte  #%11100100
                        .byte  #%10001010
                        .byte  #%11001110
                        .byte  #%10001010
                        .byte  #%10001010
           
TA                      .byte  #%11100100
                        .byte  #%01001010
                        .byte  #%01001110
                        .byte  #%01001010
OW                      .byte  #%01001010
                        .byte  #%10101010
                        .byte  #%10101110
                        .byte  #%10101110
AY                      .byte  #%01001010
                        .byte  #%10101010
                        .byte  #%11100100
                        .byte  #%10100100
                        .byte  #%10100100
                        .byte  #0

AT                      .byte  #%01001110
                        .byte  #%10100100
                        .byte  #%11100100
                        .byte  #%10100100
                        .byte  #%10100100
                        .byte  #0

AR                      .byte  #%01001100
                        .byte  #%10101010
                        .byte  #%11101110
                        .byte  #%10101100
                        .byte  #%10101010
                        .byte  #0

I_                      .byte  #%11100000
                        .byte  #%01000000
                        .byte  #%01000000
                        .byte  #%01000000
                        .byte  #%11100000
                        .byte  #0

PL                      .byte  #%11101000
                        .byte  #%10101000
                        .byte  #%11101000
                        .byte  #%10001000
                        .byte  #%10001110
                        .byte  #0

ST                      .byte  #%01101110
                        .byte  #%10000100
                        .byte  #%11100100
                        .byte  #%00100100
PA                      .byte  #%11000100
                        .byte  #%10101010
                        .byte  #%11101110
                        .byte  #%10001010
                        .byte  #%10001010
                        .byte  #0

IN                      .byte  #%11101100
                        .byte  #%01001010
                        .byte  #%01001010
                        .byte  #%01001010
                        .byte  #%11101010
                        .byte  #0
           
EColon                  .byte  #%11100000
                        .byte  #%10000100
                        .byte  #%11000000
                        .byte  #%10000100
T_                      .byte  #%11100000
                        .byte  #%01000000
                        .byte  #%01000000
                        .byte  #%01000000
                        .byte  #%01000000
                        .byte  #0

LD                      .byte  #%10001100
                        .byte  #%10001010
                        .byte  #%10001010
                        .byte  #%10001010
ER                      .byte  #%11101100
                        .byte  #%10001010
                        .byte  #%11001110
                        .byte  #%10001100
                        .byte  #%11101010
                        .byte  #0

_W                      .byte  #%00001010
                        .byte  #%00001010
                        .byte  #%00001110
                        .byte  #%00001110
                        .byte  #%00001010
                        .byte  #0

SC                      .byte  #%01100110
                        .byte  #%10001000
                        .byte  #%11101000
                        .byte  #%00101000
                        .byte  #%11000110

CanvasSelectTable       .byte #%00000001
                        .byte #%00000010
                        .byte #%00000100
                        .byte #%00001000
                        .byte #%00010000
                        .byte #%00100000
                        .byte #%01000000
CanvasSelectTableR      .byte #%10000000
                        .byte #%01000000
                        .byte #%00100000
                        .byte #%00010000
                        .byte #%00001000
                        .byte #%00000100
                        .byte #%00000010
                        .byte #%00000001

P0JoyStickUp            .byte #P0_JOYSTICK_UP
P1JoyStickUp            .byte #P1_JOYSTICK_UP
P0JoyStickDown          .byte #P0_JOYSTICK_DOWN
P1JoyStickDown          .byte #P1_JOYSTICK_DOWN
P0JoyStickLeft          .byte #P0_JOYSTICK_LEFT
P1JoyStickLeft          .byte #P1_JOYSTICK_LEFT
P0JoyStickRight         .byte #P0_JOYSTICK_RIGHT
P1JoyStickRight         .byte #P1_JOYSTICK_RIGHT

FlyGameNoteDurations    .byte 0         ; control note - 0
                        .byte 3
                        .byte 9         ; 32nd note 
                        .byte 18        ; 16th note 
                        .byte 36        ; eighth note 
                        .byte 48        ; triplet note 
                        .byte 72        ; quarter note 
                        .byte 144       ; half note

FlyGameTitleTrack0      .byte 0,0,0
FlyGameTitleTrack1      .byte 0,0,0

FlyGameTrack0           .byte $A2,$46,$01,$06,$D2,$46,$01,$06,$B2,$46,$01,$06,$D2,$46,$01,$06,$A2,$46,$01,$06,$A1,$46,$01,$06,$D2,$46,$01,$06,$B2,$46,$01,$06,$D2,$46,$01,$06,0
FlyGameTrack1           .byte $92,$44,$01,$06,$C2,$44,$01,$06,$A2,$44,$01,$06,$C2,$44,$01,$06,$92,$44,$01,$06,$91,$44,$01,$06,$C2,$44,$01,$06,$A2,$44,$01,$06,$C2,$44,$01,$06,0

PaletteColorTable                   .byte #GRAY
                                .byte #WHITE
                                .byte #RED
                                .byte #PURPLE
                                .byte #BLUE
                                .byte #SKY
                                .byte #GREEN
                                .byte #YELLOW
                                .byte #ORANGE
                                .byte #BROWN
                                .byte #BLACK

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