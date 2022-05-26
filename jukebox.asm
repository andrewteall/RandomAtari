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

CONTROL_MASK                    = #%00001111
FREQUENCY_MASK                  = #%11111000
VOLUME_MASK                     = #%00000111
DURATION_MASK                   = #%11110000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Global Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

REPEAT_TYPE_MASK                = #%00000111
REPEAT_TYPE_TEST_BIT            = #%00000001
REPEAT_COUNT_MASK               = #%00001111

        SEG.U vars
        ORG $80

JukeboxNotePtrCh0               ds 2
JukeboxNotePtrCh1               ds 2
JukeboxFrameCtrTrk0             ds 1
JukeboxFrameCtrTrk1             ds 1
JukeboxRepeatCtrTrk0            ds 1
JukeboxRepeatCtrTrk1            ds 1
JukeboxNestedRepeatTrk0            ds 1
JukeboxRepeatTmpTrk1            ds 1

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
; Byte 1 - %XXXXX010 - This Value signifies that this is a repeat control note
;
; Repeat N Num notes with another Repeat
; Byte 0 - %XXXX0000 - Signifies Control Note
; Byte 0 - %0000XXXX - How many times to Repeat ( Total times you want it played -1 )
; Byte 1 - %00000XXX - Number of Notes back to Repeat(limit 31 right now)
; Byte 1 - %XXXXX011 - This Value signifies that this is a nested repeat control note
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TODO: Optimize
; TODO: Track 1
; Search String b[e,n,c,s,m,p][e,q,c,s,i,l]|jmp
JukeboxRomMusicPlayer
; Track 0
        ; Each frame check if the duration of the current note playing
        ; is equal to the FrameCounter for it's respective track.
        ldy #0                          ; 2     Initialize Y-Index to 0
        lda (JukeboxNotePtrCh0),y       ; 5     Load first note duration to A
        beq JukeboxSetupRepeatAllTrack0 ; 2/3   
        lsr
        lsr
        lsr
        lsr
        beq JukeboxRepeatNumNotesTrack0 ; 2/3   If Duration is 0 then jump to repeats 

        tay                             ; 2     Make A the Y index
        lda JukeboxNoteDurations,y      ; 4     Get the actual duration based on the duration setting
        sec
        sbc JukeboxFrameCtrTrk0         ; 3     See if it equals the Frame Counter
        beq JukeboxTrack0NextNote       ; 2/3   If so move the NotePtr to the next note
        
        ; If the duration of the currently playing is not equal to the
        ; FrameCounter then check to see if the FrameCounter is equal
        ; to one less than the currently playing note to provide a break
        ; between notes by turning the volume to 0 for the last frame.

        eor #1
        bne JukeboxTrack0ProcessNote
        beq JukeboxMuteTrack0NoteSeparation

        ; If the duration of the note is 0 and volume is set to 0 then we just
        ; jump back to the begining of the track and load the rest of the note
        ; values like normal
JukeboxSetupRepeatAllTrack0                ; Can only repeat less than 128 notes
        lda JukeboxTrack1-JukeboxTrack0-#2 ; Length of Track0(58) -#2 - #1 for carry
        bne JukeboxRepeatAllTrack0         ; Won't ever be 0

        ; There are certain control notes that can change the flow of the track
        ; We start by checking to see if the duration of a note is 0. If not
        ; We'll jump processing it normally

        ; If Duration is equal to 0 Volume is equal to 1 then we will repeat a
        ; section of notes a certain number of times. Otherwise, if only 
        ; Duration is equal to 0 we will jump back to the beginnging of the
        ; track

JukeboxRepeatNumNotesTrack0
        sec

        iny
        lda (JukeboxNotePtrCh0),y
        dey
        and #REPEAT_TYPE_TEST_BIT
        pha

        beq JukeboxCheckRepeatTrk0
        lda JukeboxNestedRepeatTrk0
        bcs JukeboxCheckNestedRepeatTrk0
JukeboxCheckRepeatTrk0
        lda JukeboxRepeatCtrTrk0
JukeboxCheckNestedRepeatTrk0
        
        ; Repeatable Repeats
        echo "----"
        echo "Rom Total for Nested Repeats:"
        echo "----",([(.-Reset)-(JukeboxRepeatNumNotesTrack0-Reset)+12-3]d), "bytes used for Nested Repeats"

        ; If Duration is equal to 0 Control is equal to 1 then check the control
        ; value to see if it's equal to the repeat counter for the respective
        ; track. If it's equal then set the repeat counter to 0 and move to the
        ; next note to play by jumping back above

        sbc (JukeboxNotePtrCh0),y       ; Hi nybble will always be 0 for repeat
        bne JukeboxTrack0RepeatNumNotes

        ; If the duration of the currently playing is equal to the
        ; FrameCounter then advance to the next note. After Advancing
        ; the note we'll skip over seeing if we need to mute the note
        ; and move to loading all the new note's values to be heard
        
        sta JukeboxNestedRepeatTrk0
        pla
        bne JukeboxResetRepeatCtrTrk0
        sta JukeboxRepeatCtrTrk0
JukeboxResetRepeatCtrTrk0
        

JukeboxTrack0NextNote
        sta JukeboxFrameCtrTrk0         ; 3     Reset the Frame counter

        inc JukeboxNotePtrCh0
        inc JukeboxNotePtrCh0
        bne SkipIncNotePtrCh0HighByte   ; Make track start on an even address
        inc JukeboxNotePtrCh0+1
SkipIncNotePtrCh0HighByte
        bcs JukeboxRomMusicPlayer       ; Effectively a jmp carry always set
        
        ; If the repeat counter isn't equal to the control value then increment
        ; the repeat counter and jump back the specified number of notes
JukeboxTrack0RepeatNumNotes
        inc JukeboxNestedRepeatTrk0
        pla
        bne JukeboxIncRepeatCtrTrk0
        inc JukeboxRepeatCtrTrk0
        dec JukeboxNestedRepeatTrk0
JukeboxIncRepeatCtrTrk0
        
        iny
        lda (JukeboxNotePtrCh0),y       ; #FREQUENCY_MASK During repeats bit 2 will always be 0
        lsr                             ; Shift right 2 times to effectively multiply the value
        lsr                             ; of the frequency by 2 since each note takes 2 bytes
JukeboxRepeatAllTrack0        
        sbc JukeboxNotePtrCh0           ; During repeats bit 1 will always be 1 so C will be set
        bcc JukeboxSkipDecNotePtrCh0MSB ; via the lsr's above or handled in the repeat all setup
        dec JukeboxNotePtrCh0+1
JukeboxSkipDecNotePtrCh0MSB
        eor #$FF
        sta JukeboxNotePtrCh0
        inc JukeboxNotePtrCh0

        ; If the duration of a note is not 0 then continue loading the rest of
        ; the note's values into the correct channel's registers
JukeboxTrack0ProcessNote
        ldy #0                          ; 2     Load 0 to the Y register(maybe not needed)
        lda (JukeboxNotePtrCh0),y       ; 5     Load Volume to A
        sta AUDC0                       ; 3     and set the Note Control

        iny                             ; 2     Increment Y (Y=1) to point to the Note Frequency
        lda (JukeboxNotePtrCh0),y       ; 5     Load Volume to A
        rol                             ; 2     Roll left to get wider range of volume
JukeboxMuteTrack0NoteSeparation
        sta AUDV0                       ; 3     and set the Note Control

        ror                             ; 2     Roll right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        lsr                             ; 2     Shift right to get the correct placement
        sta AUDF0                       ; 3     and set the Note Frequency

        ; Each Frame we need to increment the FrameCounter by 1 to continue to
        ; count the duration of each note
IncrementTrack0FrameCounter
        inc JukeboxFrameCtrTrk0         ; 5     Increment the Frame Counter to duration compare later

        echo "----"
        echo "Rom Total Music Player:"
        echo "----",([(.-Reset)-(JukeboxRomMusicPlayer-Reset)]d), "bytes used for Music Player"
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
; CalcXPos:
;         sta WSYNC                                       ; 3
;         sta HMCLR                                       ; 3
;         sec                                             ; 2
; .Divide15 
;         sbc #15                                         ; 2
;         bcs .Divide15                                   ; 2/3
;         eor #$07                                        ; 2
;         asl                                             ; 2
;         asl                                             ; 2
;         asl                                             ; 2
;         asl                                             ; 2
;         sta RESP0,x                                     ; 3
;         sta HMP0,x                                      ; 3
        
;         rts                                             ; 6
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
                        ; .byte $0
                        ; .byte $3
                        ; .byte $b1
                        ; .byte $f
                        ; .byte $1e
                        ; .byte $87
                        ; .byte $8
                        ; .byte $7
                        .byte $0
                        .byte $3
                        .byte $4
                        .byte $8
                        .byte $96
                        .byte $f
                        .byte $1e
                        .byte $87
                        .byte $7
        ; align 256
        align 2
        ;%00000010,%10000010,%00000001,%10001011,
JukeboxTrack0           .byte $14,$fc,$24,$d4,$34,$94,$14,$fc,$24,$d4,$34,$ac,$40,$0,$54,$dc,$64,$c4,$70,$0,$34,$9c
                        .byte $80,$0,$34,$d4,$80,$0,$34,$ac,$80,$0,$84,$d4,$34,$9c,$80,$0,$34,$9c,$34,$d4,$80,$0,$34
                        .byte $ac,$80,$0,$34,$d4,$80,$0,%00000010,%10000011,%00000010,%10001010,$0,$0
                        ; .byte $41,$fc,$42,$d4,$43,$94,$41,$fc,$42,$d4,$43,$ac,$4,$0,$45,$dc,$46,$c4,$7,$0,$43
                        ; .byte $9c,$8,$0,$43,$d4,$8,$0,$43,$ac,$8,$0,$48,$d4,$43,$9c,$8,$0,$43,$9c,$43,$d4,$8
                        ; .byte $0,$43,$ac,$8,$0,$43,$d4,$8,$0,%10000000,%10000010,%00010000,%10001011,$0,$0
; JukeboxTrack0           .byte $41,$ac,$2,$0,$43,$9c,$44,$7c,$5,$0,$66,$a4,$7,$0,$66,$dc,$7,$0,$67,$b4,$6,$0
                        ; .byte $67,$dc,$66,$a4,$7,$0,$66,$a4,$66,$dc,$7,$0,$66,$b4,$7,$0,$66,$dc,$7,$0
                        ; .byte %10000000,%10000001,$0,$0
                        ; .byte $a8,$84,$1,$0,$9a,$84,$7b,$84,$4,$0,$a5,$86,$6,$0,$dd,$86,$6,$0,$b6,$86,$5,$0
                        ; .byte $de,$86,$a5,$86,$6,$0,$a5,$86,$dd,$86,$6,$0,$b5,$86,$6,$0,$dd,$86,$6,$0
                        ; .byte %10000000,%00011000,$0,$0;
JukeboxTrack1           ;.byte $a3,$86,$3,$0,$db,$86,$3,$0,$b3,$86,$3,$0,$db,$86,$a3,$86,$3,$0,$a3,$86,$db,$86
                        ;.byte $3,$0,$b3,$86,$3,$0,$db,$86,$3,$0,$3,$0,$0,$0

        echo "----"
        echo "Rom Total Bank1:"
        echo "----",([$FFFC-.]d), "bytes free in Bank 1"
        echo "----",([.-Reset]d), "bytes used in Bank 1"
;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectorsBank2
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
ENDBank2