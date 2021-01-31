        processor 6502
        include "includes/vcs.h"
        include "macro.h"
;Start Program
        SEG.U vars
        ORG $80
BlVPos          ds 1            ; $80
BlHPos          ds 1            ; $81
P0VPos          ds 1            ; $82

P0VPosIdx       ds 1            ; $83

AudVol0         ds 1            ; $84
AudVol1         ds 1            ; $85
AudFrq0         ds 1            ; $86
AudFrq1         ds 1            ; $87
AudCtl0         ds 1            ; $88
AudCtl1         ds 1            ; $89

AudSelect       ds 1            ; $8a

FrameCtr        ds 1            ; $8b
NoteDuration    ds 1            ; $8c

NotePtr        ds 2            ; $b5
        SEG
        ORG $F000

;PATTERN           = $80 ; storage Location (1st byte in RAM)



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
        lda #26
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #1
        lda #126
        jsr CalcXPos
        sta WSYNC
        sta HMOVE
        SLEEP 24
        sta HMCLR

        ldx #4
        lda #80
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


        lda #<Track
        sta NotePtr
        lda #>Track
        sta NotePtr+1



StartOfFrame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Vertical Blank is the only section shared by screens
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
        ldx #0
        lda #155
        sta COLUBK
ViewableScreenStart

;;;;;;;;;;;;;;;;; Determine if we draw Cursor ;;;;;;;;;;;;;;;;;;;;;;; 
; 12 Cycles to Draw the Cursor
; 11 Cycles to Not Draw the Cursor
; TODO: ADD Cursor Height
; X - Current line number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #0                                          ; 2     Load 0 to A to prepare to disable the Cursor
        cpx BlVPos                                      ; 3     Determine whether or not we're going to draw the Cursor
        bne CursorDisabled                              ; 2/3   Go to enabling the Cursor or not  
        lda #2                                          ; 2     Load #2 to A to prepare to enable the Cursor
CursorDisabled
        sta ENABL                                       ; 3     14/15 cycles

;;;;;;;;;;;;;;;;; Determine if we Player Sprites ;;;;;;;;;;;;;;;;;;;; 
; XX Cycles to Player Sprite
; 11 Cycles to Not Player Sprite
; X - Current line number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        lda #0                                          ; 2
        cpx P0VPosIdx                                   ; 3
        bne PlayerDisabled                              ; 2/3
DrawP0

        txa
        clc
        adc #2
        sta P0VPosIdx

        txa
        sec
        sbc P0VPos
        tay
        lda P0Grfx,y

        cpy P0Height
        bne PlayerDisabled

        ldy #26
        sty P0VPos
        sty P0VPosIdx
PlayerDisabled
 
        cpx #66
        bne SkipMoveP0
        ldy #86
        sty P0VPos
        sty P0VPosIdx
SkipMoveP0

        cpx #126
        bne SkipMoveP02
        ldy #146
        sty P0VPos
        sty P0VPosIdx
SkipMoveP02
        sta GRP0                                        ; 3
        sta GRP1                                        ; 3

        sta WSYNC
        ldy #0                                          ; 2
        sty PF1
        lda #%0000111
;;;;;;;;;;;;;;;;; --------------------------- ;;;;;;;;;;;;;;;;;;;;;;; 
; 11 Cycles to Draw the Button
; 5 or 9 Cycles to Not Draw the Button
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cpx #60                                         ; 2
        bpl Button1                                     ; 2/3
        cpx #20                                         ; 2
        bmi Button1                                     ; 2/3
        sta PF1                                         ; 3
Button1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        cpx #120                                        ; 2
        bpl Button2                                     ; 2/3
        cpx #80                                         ; 2
        bmi Button2                                     ; 2/3
        sta PF1                                         ; 3
Button2

        cpx #180                                        ; 2
        bpl Button3                                     ; 2/3
        cpx #140                                        ; 2
        bmi Button3                                     ; 2/3
        sta PF1                                         ; 3
Button3

        lda INPT4
        bmi SkipCheckCollision
        lda BlVPos
        sta AudSelect
SkipCheckCollision

EndofScreenBuffer
        
        inx
        inx                                             ; 2
        cpx #192                                        ; 2
        sta WSYNC                                       ; 3
        bne ViewableScreenStart                         ; 2/3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; End of Viewable Screen ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        lda #0
        sta PF0
        sta PF1
        sta PF2

; end of screen - enter blanking
        lda #%00000010
        sta VBLANK

        lda #26
        sta P0VPos

        lda #%00010000            
        bit SWCHA
        bne CursorDown
        dec BlVPos
        dec BlVPos
CursorDown
        lda #%00100000            
        bit SWCHA
        bne CursorUp
        inc BlVPos
        inc BlVPos
CursorUp

        ldy #0 
        lda #%01000000            
        bit SWCHA
        bne CursorLeft
        ldy #%00010000 
CursorLeft
        lda #%10000000            
        bit SWCHA
        bne CursorRight
        ldy #%11110000 
CursorRight
        sty HMBL

        sta WSYNC
        sta HMOVE

;;;;;;;;;;;;;;;;;;;;; Collision Detection ;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CollisionDetection
        lda CXP0FB
        and #%01000000
        cmp #%01000000
        bne SkipP0Collision
        ldx AudSelect
        beq SkipAudChange
        
        cpx #40                                      
        bpl SkipVol0Up                               
        cpx #20                                      
        bmi SkipVol0Up                               
        inc AudVol0                                  
SkipVol0Up
        cpx #60                                      
        bpl SkipVol0Down                               
        cpx #40                                      
        bmi SkipVol0Down                               
        dec AudVol0                                  
SkipVol0Down

        cpx #100                                      
        bpl SkipFrq0Up                               
        cpx #80                                      
        bmi SkipFrq0Up                               
        inc AudFrq0                                  
SkipFrq0Up
        cpx #120                                      
        bpl SkipFrq0Down                               
        cpx #100                                      
        bmi SkipFrq0Down                               
        dec AudFrq0                                  
SkipFrq0Down

        cpx #160                                      
        bpl SkipCtl0Up                               
        cpx #140                                      
        bmi SkipCtl0Up                               
        inc AudCtl0                                  
SkipCtl0Up
        cpx #180                                      
        bpl SkipCtl0Down                               
        cpx #160                                      
        bmi SkipCtl0Down                               
        dec AudCtl0                                  
SkipCtl0Down

        lda AudVol0
        sta AUDV0

        lda AudCtl0
        sta AUDC0

        lda AudFrq0
        sta AUDF0
SkipP0Collision

SkipAudChange


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
; Reset Backgruond,Audio,Collisions,
        lda #0
        sta COLUBK
        sta CXCLR
        sta AudSelect
; 25 scanlines of overscan...       
        ldx #25                                         ; 2
Overscan
        sta WSYNC                                       ; 2
        dex                                             ; 3
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

P0Height   .byte  #28
Track       .byte  #10,#3,#1,#7,#10,#3,#2,#7,#10,#3,#3,#7,#10,#3,#4,#7,#10,#3,#5,#7,#10,#3,#6,#7,#10,#3,#7,#7,#10,#3,#8,#7,#10,#3,#9,#7,#255,#3,#2,#5
; Track       .byte  #30,#3,#5,#7,#30,#3,#6,#7,#30,#3,#7,#7,#30,#3,#6,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#6,#7,#2,#0,#5,#7,#30,#3,#6,#7,#2,#0,#5,#7,#30,#3,#6,#7,#2,#0,#5,#7,#30,#3,#5,#7,#2,#0,#5,#7,#30,#3,#3,#7,#2,#0,#5,#7,#30,#3,#3,#7,#2,#0,#5,#7,#255,#3,#2,#5



Zero       .byte  #%11101110
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%10101010
           .byte  #%11101110

One        .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010

Two        .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110

Three      .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110

Four       .byte  #%10101010
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%00100010

Five       .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110

Six        .byte  #%11101110
           .byte  #%10001000
           .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110

Seven      .byte  #%11101110
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010
           .byte  #%00100010

Eight      .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110

Nine       .byte  #%11101110
           .byte  #%10101010
           .byte  #%11101110
           .byte  #%00100010
           .byte  #%11101110
;-------------------------------------------------------------------------------
        ORG $FFFA
InterruptVectors
    .word Reset          ; NMI
    .word Reset          ; RESET
    .word Reset          ; IRQ
END