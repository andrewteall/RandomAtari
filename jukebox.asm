        processor 6502
        include includes/vcs.h
        include includes/globalconsts.h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CONTROL_MASK                    = #%00001111
FREQUENCY_MASK                  = #%11111000
VOLUME_MASK                     = #%00000111
DURATION_MASK                   = #%11110000

REPEAT_TYPE_MASK                = #%00000111
REPEAT_TYPE_TEST_BIT            = #%00000001
REPEAT_COUNT_MASK               = #%00001111
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        SEG.U vars
        ORG $80

JukeboxNotePtrCh0               ds 2
JukeboxNotePtrCh1               ds 2
JukeboxFrameCtrTrk0             ds 1
JukeboxFrameCtrTrk1             ds 1
 IF [ ENABLE_REPEATS ]
JukeboxRepeatCtrTrk0            ds 1
JukeboxRepeatCtrTrk1            ds 1
  IF [ ENABLE_NESTED_REPEATS ]
JukeboxNestedRepeatCtrTrk0      ds 1
JukeboxNestedRepeatCtrTrk1      ds 1
  ENDIF
 ENDIF
 IF [ ENABLE_MULTIPLE_SONGS ]
JukeboxSongPtrTrk0              ds 2
JukeboxSongPtrTrk1              ds 2
 
JukeboxNoteDurationsTrk0Ptr     ds 2
JukeboxNoteDurationsTrk1Ptr     ds 2
  IF [ ALL_SONGS_LT_255_BYTES ]
JukeboxLengthTrk0               ds 1
JukeboxLengthTrk1               ds 1
  ENDIF
 ENDIF
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

JukeBoxSongInit
 IF [ ENABLE_MULTIPLE_SONGS ]
        ; Configure which song to play
        ; Optimization can be done here if tracks are in the same page
        ; lda Song0Track0                 ; Initialize Note Pointer 0 to the
        ; sta JukeboxSongPtrTrk0          ; beginning of Title Music Track 0 in
        ; lda Song0Track0+1               ; Rom for the Music Player
        ; sta JukeboxSongPtrTrk0+1        ;
        
        ; lda Song0Track1                 ; Initialize Note Pointer 0 to the
        ; sta JukeboxSongPtrTrk1          ; beginning of Title Music Track 0 in
        ; lda Song0Track1+1               ; Rom for the Music Player
        ; sta JukeboxSongPtrTrk1+1        ;

        lda #<JukeboxTrack0             ; Initialize Note Pointer 0 to the
        sta JukeboxSongPtrTrk0           ; beginning of Title Music Track 1 in
        lda #>JukeboxTrack0             ; Rom for the Music Player
        sta JukeboxSongPtrTrk0+1         ;

        lda #<JukeboxTrack1             ; Initialize Note Pointer 1 to the
        sta JukeboxSongPtrTrk0           ; beginning of Title Music Track 1 in
        lda #>JukeboxTrack1             ; Rom for the Music Player
        sta JukeboxSongPtrTrk0+1         ;

        lda JukeboxSongPtrTrk0          ; Initialize Note Pointer 0 to the
        sta JukeboxNotePtrCh0           ; beginning of Title Music Track 0 in
        lda JukeboxSongPtrTrk0+1        ; Rom for the Music Player
        sta JukeboxNotePtrCh0+1         ;
        
        lda JukeboxSongPtrTrk1          ; Initialize Note Pointer 0 to the
        sta JukeboxNotePtrCh1           ; beginning of Title Music Track 0 in
        lda JukeboxSongPtrTrk1+1        ; Rom for the Music Player
        sta JukeboxNotePtrCh1+1         ;

        lda #<JukeboxNoteDurations      ; Initialize Note Pointer 0 to the
        sta JukeboxNoteDurationsTrk0Ptr ; beginning of Title Music Track 1 in
        lda #>JukeboxNoteDurations      ; Rom for the Music Player
        sta JukeboxNoteDurationsTrk0Ptr+1 ;

  IF [ ALL_SONGS_LT_255_BYTES ]
        lda JukeboxTrack0End-JukeboxTrack0-#2 ; Initialize Note Pointer 0 to the
        sta JukeboxLengthTrk0           ; beginning of Title Music Track 1 in
  ENDIF

 ELSE
        lda #<JukeboxTrack0             ; Initialize Note Pointer 0 to the
        sta JukeboxNotePtrCh0           ; beginning of Title Music Track 1 in
        lda #>JukeboxTrack0             ; Rom for the Music Player
        sta JukeboxNotePtrCh0+1         ;

        lda #<JukeboxTrack1             ; Initialize Note Pointer 1 to the
        sta JukeboxNotePtrCh1           ; beginning of Title Music Track 1 in
        lda #>JukeboxTrack1             ; Rom for the Music Player
        sta JukeboxNotePtrCh1+1         ;
 ENDIF
        echo "----"
        echo "Rom Total for Jukebox Init:"
        echo "----",([(.-JukeBoxSongInit)]d), "bytes used for Jukebox Init"
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
; Byte 0 - %0000XXXX - Note Duration 0-15. Used to select values from a table
; Byte 0 - %XXXX0000 - Note Control 0-15
; Byte 1 - %00000XXX - Note Frequency 0-31
; Byte 1 - %XXXXX000 - Note Volume 0-7. Doubled so that only even volumes are allowed


; Note controls
; Repeat Track 0,0
;
; Repeat N Num notes
; Byte 0 - %0000XXXX - Signifies Control Note
; Byte 0 - %XXXX0000 - How many times to Repeat ( Total times you want it played -1 )
; Byte 1 - %00000XXX - Number of Notes back to Repeat(limit 31 right now)
; Byte 1 - %XXXXX010 - This Value signifies that this is a repeat control note
;
; Repeat N Num notes with another Repeat
; Byte 0 - %0000XXXX - Signifies Control Note
; Byte 0 - %XXXX0000 - How many times to Repeat ( Total times you want it played -1 )
; Byte 1 - %00000XXX - Number of Notes back to Repeat(limit 31 right now)
; Byte 1 - %XXXXX011 - This Value signifies that this is a nested repeat control note
;

; Jukebox Configuration
ENABLE_NOTE_SEPARATION=#1       ; Provides spacing between each note by muting the last frame of the note
ENABLE_REPEATS=#1               ; Allows for the use of repeating groups of notes
ENABLE_NESTED_REPEATS=#1        ; Allows for the use of nested repeats inside of another repeat
ENABLE_MULTIPLE_SONGS=#1
ALL_SONGS_LT_255_BYTES=#1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TODO: Optimize
; TODO: Option Shared Durations between track
; TODO: Documentation
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
 IF [ ENABLE_REPEATS ]
        beq JukeboxRepeatNumNotesTrack0 ; 2/3   If Duration is 0 then jump to repeats
 ENDIF
        tay                             ; 2     Make A the Y index
 IF [ ENABLE_MULTIPLE_SONGS ]
        lda (JukeboxNoteDurationsTrk0Ptr),y      ; 4     Get the actual duration based on the duration setting
 ELSE
        lda JukeboxNoteDurations,y      ; 4     Get the actual duration based on the duration setting
 ENDIF
        sec
        sbc JukeboxFrameCtrTrk0         ; 3     See if it equals the Frame Counter
        beq JukeboxTrack0NextNote       ; 2/3   If so move the NotePtr to the next note
        
        ; If the duration of the currently playing is not equal to the
        ; FrameCounter then check to see if the FrameCounter is equal
        ; to one less than the currently playing note to provide a break
        ; between notes by turning the volume to 0 for the last frame.
 IF [ ENABLE_NOTE_SEPARATION ]
        eor #1
        beq JukeboxMuteTrack0NoteSeparation
 ENDIF
        bne JukeboxTrack0ProcessNote
 
        ; If the duration of the note is 0 and volume is set to 0 then we just
        ; jump back to the begining of the track and load the rest of the note
        ; values like normal
JukeboxSetupRepeatAllTrack0
 IF [ ALL_SONGS_LT_255_BYTES ]
        ; Can only repeat less than 128 notes
  IF [ !ENABLE_REPEATS ]
        sec
  ENDIF
  IF [ ENABLE_MULTIPLE_SONGS ]
        lda JukeboxLengthTrk0
  ELSE
        lda JukeboxTrack0End-JukeboxTrack0-#2 ; Length of Track0(58) -#2 - #1 for carry
  ENDIF
        bne JukeboxRepeatAllTrack0         ; Won't ever be 0
 ELSE
  IF [ ENABLE_MULTIPLE_SONGS ]
        lda JukeboxSongPtrTrk0          ; Initialize Note Pointer 0 to the
        sta JukeboxNotePtrCh0           ; beginning of Title Music Track 0 in
        lda JukeboxSongPtrTrk0+1        ; Rom for the Music Player
        sta JukeboxNotePtrCh0+1         ;
  ELSE
        lda #<JukeboxTrack0             ; Initialize Note Pointer 0 to the
        sta JukeboxNotePtrCh0           ; beginning of Title Music Track 0 in
        lda #>JukeboxTrack0             ; Rom for the Music Player
        sta JukeboxNotePtrCh0+1         ;
  ENDIF

        jmp JukeboxTrack0ProcessNote
 ENDIF

        ; There are certain control notes that can change the flow of the track
        ; We start by checking to see if the duration of a note is 0. If not
        ; We'll jump processing it normally

        ; If Duration is equal to 0 Volume is equal to 1 then we will repeat a
        ; section of notes a certain number of times. Otherwise, if only 
        ; Duration is equal to 0 we will jump back to the beginnging of the
        ; track
 IF [ ENABLE_REPEATS ]
JukeboxRepeatNumNotesTrack0
        sec
  IF [ ENABLE_NESTED_REPEATS ]
        iny
        lda (JukeboxNotePtrCh0),y
        dey
        and #REPEAT_TYPE_TEST_BIT
        pha
        
        beq JukeboxCheckRepeatTrk0
        lda JukeboxNestedRepeatCtrTrk0
        bcs JukeboxCheckNestedRepeatTrk0
JukeboxCheckRepeatTrk0
  ENDIF
        lda JukeboxRepeatCtrTrk0
JukeboxCheckNestedRepeatTrk0
 
  IF [ ENABLE_NESTED_REPEATS ]
        ; Repeatable Repeats
        echo "----"
        echo "Rom Total for Nested Repeats:"
        echo "----",([(.-Reset)-(JukeboxRepeatNumNotesTrack0-Reset)+12-3]d), "bytes used for Nested Repeats"
  ENDIF
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
  IF [ ENABLE_NESTED_REPEATS ]
        sta JukeboxNestedRepeatCtrTrk0
        pla
        bne JukeboxResetRepeatCtrTrk0
  ENDIF
        sta JukeboxRepeatCtrTrk0
JukeboxResetRepeatCtrTrk0
 ENDIF
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
 IF [ ENABLE_REPEATS ]
JukeboxTrack0RepeatNumNotes
 IF [ ENABLE_NESTED_REPEATS ]
        inc JukeboxNestedRepeatCtrTrk0
        pla
        bne JukeboxIncRepeatCtrTrk0
        dec JukeboxNestedRepeatCtrTrk0
 ENDIF
        inc JukeboxRepeatCtrTrk0
JukeboxIncRepeatCtrTrk0
        
        iny
        lda (JukeboxNotePtrCh0),y       ; #FREQUENCY_MASK During repeats bit 2 will always be 0
        lsr                             ; Shift right 2 times to effectively multiply the value
        lsr                             ; of the frequency by 2 since each note takes 2 bytes
 ENDIF
 IF [ ENABLE_REPEATS || ALL_SONGS_LT_255_BYTES ]
JukeboxRepeatAllTrack0        
        sbc JukeboxNotePtrCh0           ; During repeats bit 1 will always be 1 so C will be set
        bcc JukeboxSkipDecNotePtrCh0MSB ; via the lsr's above or handled in the repeat all setup
        dec JukeboxNotePtrCh0+1
JukeboxSkipDecNotePtrCh0MSB
        eor #$FF
        sta JukeboxNotePtrCh0
        inc JukeboxNotePtrCh0
 ENDIF
        ; If the duration of a note is not 0 then continue loading the rest of
        ; the note's values into the correct channel's registers
JukeboxTrack0ProcessNote
        ldy #0                          ; 2     Reset the Note Pointer Offset to 0
        lda (JukeboxNotePtrCh0),y       ; 5     Load Duration/Control to A
        sta AUDC0                       ; 3     and set the Note Control

        iny                             ; 2     Increment Y (Y=1) to point to the Note Volume/Frequency
        lda (JukeboxNotePtrCh0),y       ; 5     Load Volume to A
        asl                             ; 2     Shift left to get wider range of volume
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
EndOfOverscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; End Wait for Overscan Timer to Expire  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Sub-Routines ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Song List ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SongList
; Song0Track0        TrackAddress0(2bytes),Track0 Length(2bytes),Track0NoteDurationsAddress(2bytes)
; Song0Track1        TrackAddress1(2bytes),Track1 Length(2bytes),Track1NoteDurationsAddress(2bytes)
; Song0Track0             .word JukeboxTrack0, JukeboxTrack0End-JukeboxTrack0-#2
; Song0Track1             .word $0000

; Song1Track0             .word $0000
; Song1Track1             .word $0000

SongListEnd

        echo "----"
        echo "Rom Total Music Player Overhead:"
        echo "----",([.-Reset- (#55) -(EndOfOverscan-JukeboxRomMusicPlayer)]d), "bytes used for Music Player Overhead"

JukeboxNoteDurations    .byte $0
                        .byte $3
                        .byte $4
                        .byte $8
                        .byte $96
                        .byte $f
                        .byte $1e
                        .byte $87
                        .byte $7

                        
        align 2
JukeboxTrack0           .byte $14,$fc,$24,$d4,$34,$94,$14,$fc,$24,$d4,$34,$ac,$40,$0,$54,$dc,$64,$c4,$70,$0,$34,$9c
                        .byte $80,$0,$34,$d4,$80,$0,$34,$ac,$80,$0,$84,$d4,$34,$9c,$80,$0,$34,$9c,$34,$d4,$80,$0,$34
                        .byte $ac,$80,$0,$34,$d4,$80,$0,%00000010,%10000011,%00000010,%10001010,$0,$0
JukeboxTrack0End

JukeboxTrack1           ;.byte $a3,$86,$3,$0,$db,$86,$3,$0,$b3,$86,$3,$0,$db,$86,$a3,$86,$3,$0,$a3,$86,$db,$86
                        ;.byte $3,$0,$b3,$86,$3,$0,$db,$86,$3,$0,$3,$0,$0,$0
JukeboxTrack1End

JukeboxNoRepeatTrack0   .byte $14,$fc,$24,$d4,$34,$94,$14,$fc,$24,$d4,$34,$ac,$40,$0,$54,$dc,$64,$c4,$70,$0,$34,$9c
                        .byte $80,$0,$34,$d4,$80,$0,$34,$ac,$80,$0,$84,$d4,$34,$9c,$80,$0,$34,$9c,$34,$d4,$80,$0,$34
                        .byte $ac,$80,$0,$34,$d4,$80,$0,$0,$0
JukeboxNoRepeatTrack0End

JukeboxNoNestedRepeatTrack0 .byte $14,$fc,$24,$d4,$34,$94,$14,$fc,$24,$d4,$34,$ac,$40,$0,$54,$dc,$64,$c4,$70,$0,$34,$9c
                        .byte $80,$0,$34,$d4,$80,$0,$34,$ac,$80,$0,$84,$d4,$34,$9c,$80,$0,$34,$9c,$34,$d4,$80,$0,$34
                        .byte $ac,$80,$0,$34,$d4,$80,$0,%00000010,%10000010,$0,$0
JukeboxNoNestedRepeatTrack0End

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