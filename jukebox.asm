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

DURATION_MASK                   = #%00001111
FREQUENCY_MASK                  = #%11111000
VOLUME_MASK                     = #%00000111
CONTROL_MASK                    = #%11110000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Global Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        SEG.U vars
        ORG $80

JukeboxNotePtrCh0               ds 2
JukeboxNotePtrCh1               ds 2
JukeboxFrameCtrTrk0             ds 1
JukeboxFrameCtrTrk1             ds 1
JukeboxRepeatCtrTrk0            ds 1
JukeboxRepeatCtrTrk1            ds 1
JukeboxRepeatNumNotesTrk0       ds 1
JukeboxRepeatNumNotesTrk1       ds 1

        echo "----"
        echo "Ram Jukebox:"
        echo "----",([* - $80]d) ,"/", (* - $80) ,"bytes of RAM Used for Jukebox"
        echo "----",([$100 - *]d) ,"/", ($100 - *) , "bytes of RAM left for Jukebox"
        SEG
        ORG $F000

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Jukebox Start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Jukebox
        
        lda #<JukeboxTrack0             ; Initialize Note Pointer 0 to the
        sta JukeboxNotePtrCh0           ; beginning of Title Music Track 0 in
        lda #>JukeboxTrack0             ; Rom for the Music Player
        sta JukeboxNotePtrCh0+1         ;

        lda #<JukeboxTrack1             ; Initialize Note Pointer 1 to the
        sta JukeboxNotePtrCh1           ; beginning of Title Music Track 1 in
        lda #>JukeboxTrack1             ; Rom for the Music Player
        sta JukeboxNotePtrCh1+1         ;

JukeboxStartOfFrame
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

JukeboxVerticalBlankEndWaitLoop
        lda TIMINT
        and #%10000000
        beq JukeboxVerticalBlankEndWaitLoop
        sta WSYNC
        sty VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End VBLANK ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Viewable Screen Start ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ldx #192
DrawScreen
        dex
        sta WSYNC
        bne DrawScreen

EndofViewableScreen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End of Viewable Screen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Setup Overscan  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #2
        sta VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Setup Overscan  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #36
        sta TIM64T
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Load Overscan Timer ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Rom Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Note format
;
; Byte 0 - %XXXX0000 - Note Duration 0-15. Used to select values from a table
; Byte 0 - %0000XXXX - Note Control 0-15
; Byte 1 - %00000XXX - Note Frequency 0-31
; Byte 1 - %XXXXX000 - Note Volume 0-7. Doubled so that only even volumes are allowed


; Note controls
; Repeat Track 0,0
;
; Repeat N Num notes
; Byte 0 - %XXXX0000 - Signifies Control Note
; Byte 0 - %0000XXXX - How many times to Repeat ( Total times you want it played -1 )
; Byte 1 - %00000XXX - Number of Notes back to Repeat(limit 31 right now)
; Byte 1 - %XXXXX001 - This Value signifies that this is a repeat control note
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TODO: Repeatable Repeats
; TODO: Track 1
; TODO: Optimize
JukeboxRomMusicPlayer
; Track 0
        ; Each frame check if the duration of the current note playing
        ; is equal to the FrameCounter for it's respective track.
        ldy #0                          ; 2     Initialize Y-Index to 0
        lda (JukeboxNotePtrCh0),y       ; 5     Load first note duration to A
        and #DURATION_MASK              ; 2     Mask so we only have the note duration
        tay                             ; 2     Make A the Y index
        lda JukeboxNoteDurations,y      ; 4     Get the actual duration based on the duration setting
        cmp JukeboxFrameCtrTrk0         ; 3     See if it equals the Frame Counter
        bne SkipJukeboxTrack0NextNote   ; 2/3   If so move the NotePtr to the next note
        
        ; If the duration of the currently playing is equal to the
        ; FrameCounter then advance to the next note. After Advancing
        ; the note we'll skip over seeing if we need to mute the note
        ; and move to loading all the new note's values to be heard
JukeboxTrack0NextNote
        lda JukeboxNotePtrCh0           ; 3     Load the Note Pointer to A
        clc                             ; 2     Clear the carry 
        adc #2                          ; 2     Add 2 to move the Note pointer to the next note
        sta JukeboxNotePtrCh0           ; 3     Store the new note pointer
        bcc SkipIncNotePtrCh0HighByte
        lda JukeboxNotePtrCh0+1
        adc #0
        sta JukeboxNotePtrCh0+1
SkipIncNotePtrCh0HighByte
        lda #0                          ; 2     Load Zero to
        sta JukeboxFrameCtrTrk0         ; 3     Reset the Frame counter
        jmp SkipJukeboxMuteTrack0NoteGap

        ; If the duration of the currently playing is not equal to the
        ; FrameCounter then check to see if the FrameCounter is equal
        ; to one less than the currently playing note to provide a break
        ; between notes by turning the volume to 0 for the last frame.
SkipJukeboxTrack0NextNote
        sec
        sbc #1
        cmp JukeboxFrameCtrTrk0
        bne SkipJukeboxMuteTrack0NoteGap
        lda #0
        sta AUDV0
        jmp IncrementTrack0FrameCounter

        ; There are certain control notes that can change the flow of the track
        ; We start by checking to see if the duration of a note is 0. If not
        ; We'll jump processing it normally
SkipJukeboxMuteTrack0NoteGap
        ldy #0
        lda (JukeboxNotePtrCh0),y       ; 5     Load first note duration to A
        and #DURATION_MASK              ; 2     Mask so we only have the note duration
        cmp #0                          ; 2     See if the notes duration equals 0
        bne JukeboxSkipResetTrack0      ; 2/3   If so go back to the beginning of the track

        ; If Duration is equal to 0 Volume is equal to 1 then we will repeat a
        ; section of notes a certain number of times. Otherwise, if only 
        ; Duration is equal to 0 we will jump back to the beginnging of the
        ; track
        iny
        lda (JukeboxNotePtrCh0),y
        dey
        and #VOLUME_MASK
        ; cmp #0
        ; beq SkipRepeatTrack0
        cmp #1
        bne SkipRepeatTrack0

        ; If Duration is equal to 0 Volume is equal to 1 then check the control
        ; value to see if it's equal to the repeat counter for the respective
        ; track. If it's equal then set the repeat counter to 0 and move to the
        ; next not to play by jumping back above
        ; iny
        lda (JukeboxNotePtrCh0),y
        ; dey
        and #CONTROL_MASK
        lsr
        lsr
        lsr
        lsr
        cmp JukeboxRepeatCtrTrk0
        bne JukeboxTrack0Repeat
        lda #0
        sta JukeboxRepeatCtrTrk0
        jmp JukeboxTrack0NextNote

        ; If the repeat counter isn't equal to the control value then increment
        ; the repeat counter and jump back the specified number of notes
JukeboxTrack0Repeat
        inc JukeboxRepeatCtrTrk0
        iny
        lda (JukeboxNotePtrCh0),y
        dey                             ; Possibly can remove
        and #FREQUENCY_MASK
        lsr                             ; Shift right 2 times to effectively multiply the value
        lsr                             ; of the frequency by 2 since each note takes 2 bytes
        sta JukeboxRepeatNumNotesTrk0
        ;subtract A from JukeboxNotePtrCh0 TODO: if we cross 0 decrease JukeboxNotePtrCh0+1 by 1
        lda JukeboxNotePtrCh0
        sec
        sbc JukeboxRepeatNumNotesTrk0
        sta JukeboxNotePtrCh0
        ; sec                             ; Need to see if the 1's complement
        ; sbc JukeboxNotePtrCh0           ; math works out here to save
        ; and $FF                         ; memory
        ; sta JukeboxNotePtrCh0
        bcs SkipDecNotePtrCh0HighByte
        lda JukeboxNotePtrCh0+1
        sec
        sbc #1
        sta JukeboxNotePtrCh0+1
SkipDecNotePtrCh0HighByte
        ; If we've repeated a section of track we don't need to jump back to
        ; beginning of the track so we jump over that portion of code
        jmp JukeboxSkipResetTrack0

        ; If the duration of the note is 0 and volume is not set to 1 then we just 
        ; jump back to the begining of the track and load the rest of the note
        ; values like normal
SkipRepeatTrack0
        lda #<JukeboxTrack0             ; 4     Store the low byte of the track to 
        sta JukeboxNotePtrCh0           ; 3     the Note Pointer
        lda #>JukeboxTrack0             ; 4     Store the High byte of the track to
        sta JukeboxNotePtrCh0+1         ; 3     the Note Pointer + 1

        ; If the duration of a note is not 0 then continue loading the rest of
        ; the note's values into the correct channel's registers
JukeboxSkipResetTrack0
        ldy #0                          ; 2     Load 0 to the Y register(maybe not needed)
        lda (JukeboxNotePtrCh0),y       ; 5     Load Volume to A
        and #CONTROL_MASK               ; 2     Mask so we only have the note frequency
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        sta AUDC0                       ; 3     and set the Note Frequency

        iny                             ; 2     Increment Y (Y=1) to point to the Note Frequency
        lda (JukeboxNotePtrCh0),y       ; 5     Load Frequency to A
        and #FREQUENCY_MASK             ; 2     Mask so we only have the note Volume
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        sta AUDF0                       ; 3     and set the Note Volume

        lda (JukeboxNotePtrCh0),y       ; 5     Load Control to A
        and #VOLUME_MASK                ; 2     Mask so we only have the note Control
        asl                             ; 2     Shift left to get wider range of volume
        sta AUDV0                       ; 3     and set the Note Control

        ; Each Frame we need to increment the FrameCounter by 1 to continue to
        ; count the duration of each note
IncrementTrack0FrameCounter
        inc JukeboxFrameCtrTrk0         ; 5     Increment the Frame Counter to duration compare later


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Rom Music Player ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Wait for Overscan Timer to Expire  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JukeboxOverscanWaitLoop
        lda TIMINT                      ; Check to see if our timer has expired
        beq JukeboxOverscanWaitLoop     ; and we are done with our overscan 
                                        
        jmp JukeboxStartOfFrame         ; Then we start the next Frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Wait for Overscan Timer to Expire  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
        sta RESP0,x                                     ; 3
        sta HMP0,x                                      ; 3
        
        rts                                             ; 6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; End Calculate Horizontal Sprite Position ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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



JukeboxNoteDurations    ; .byte 0         ; control note - 0
                        ; .byte 3
                        ; .byte 9         ; 32nd note 
                        ; .byte 18        ; 16th note 
                        ; .byte 36        ; eighth note 
                        ; .byte 48        ; triplet note 
                        ; .byte 72        ; quarter note 
                        ; .byte 144       ; half note
                        .byte $0
                        .byte $3
                        .byte $b1
                        .byte $f
                        .byte $1e
                        .byte $87
                        .byte $8
                        .byte $7
        ; align 256

JukeboxTrack0           .byte $41,$ac,$2,$0,$43,$9c,$44,$7c,$5,$0,$66,$a4,$7,$0,$66,$dc,$7,$0,$67,$b4,$6,$0
                        .byte $67,$dc,$66,$a4,$7,$0,$66,$a4,$66,$dc,$7,$0,$66,$b4,$7,$0,$66,$dc,$7,$0,%10000000,%10000001,$0,$0
                        ; .byte $a8,$84,$1,$0,$9a,$84,$7b,$84,$4,$0,$a5,$86,$6,$0,$dd,$86,$6,$0,$b6,$86,$5,$0
                        ; .byte $de,$86,$a5,$86,$6,$0,$a5,$86,$dd,$86,$6,$0,$b5,$86,$6,$0,$dd,$86,$6,$0,%10000000,%00011000,$0,$0;
JukeboxTrack1           ;.byte $a3,$86,$3,$0,$db,$86,$3,$0,$b3,$86,$3,$0,$db,$86,$a3,$86,$3,$0,$a3,$86,$db,$86
                        ;.byte $3,$0,$b3,$86,$3,$0,$db,$86,$3,$0,$3,$0,$0,$0

        echo "----"
        echo "Rom Total Bank1:"
        echo "----",([$FFFC-.]d), "bytes free in Bank 1"
;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectorsBank2
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
ENDBank2