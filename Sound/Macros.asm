; Here's some syntax:

; note C_3, 1 (pitch, length in semiquavers) (use ___ as pitch to kill note)
; envelope $A8 (as LSDJ)
; vol 3 (for wave channel)
; tempo 50 (still yet to decide how this works)
; table 1 (table ID, use 0 to stop table) (still yet to decide how this works)
; slide 3 (start using slide from next note onwards; use 0 to stop)
; mastervol $77 (copied directly to NR50)
; pan L_ (either LR, L_, _R, or __)
; sweep $19 (to add sometime in the future)
; vibrato 1 (still yet to decide how this works)
; waveform 12.5 (for pulse, either 12.5, 25, 50, or 75)
; wavedata 1 (give an ID for a preset wave pattern)
; inlinewavedata $00FF00FF00FF00FF00FF00FF00FF00FF (directly give the wave pattern to use)
; length $20 (use inf for infinite note length)
; microtune $00 (8-bit signed; will be added to the current note)


; Organisational stuffs:

; soundjp .Start (address/label)
; soundcall .Motif, 0 (address/label, times to repeat) (can only call once!)
; soundret (returns from the phrase)
; soundend (stops the sound)


; tables will be in similar vain to LSDJ; still yet to implement precisely how

; Note equates
___ EQU $00
C_3 EQU $01
C#3 EQU $02
D_3 EQU $03
D#3 EQU $04
E_3 EQU $05
F_3 EQU $06
F#3 EQU $07
G_3 EQU $08
G#3 EQU $09
A_3 EQU $0A
A#3 EQU $0B
B_3 EQU $0C
C_4 EQU $0D
C#4 EQU $0E
D_4 EQU $0F
D#4 EQU $10
E_4 EQU $11
F_4 EQU $12
F#4 EQU $13
G_4 EQU $14
G#4 EQU $15
A_4 EQU $16
A#4 EQU $17
B_4 EQU $18
C_5 EQU $19
C#5 EQU $1A
D_5 EQU $1B
D#5 EQU $1C
E_5 EQU $1D
F_5 EQU $1E
F#5 EQU $1F
G_5 EQU $20
G#5 EQU $21
A_5 EQU $22
A#5 EQU $23
B_5 EQU $24
C_6 EQU $25
C#6 EQU $26
D_6 EQU $27
D#6 EQU $28
E_6 EQU $29
F_6 EQU $2A
F#6 EQU $2B
G_6 EQU $2C
G#6 EQU $2D
A_6 EQU $2E
A#6 EQU $2F
B_6 EQU $30
C_7 EQU $31
C#7 EQU $32
D_7 EQU $33
D#7 EQU $34
E_7 EQU $35
F_7 EQU $36
F#7 EQU $37
G_7 EQU $38
G#7 EQU $39
A_7 EQU $3A
A#7 EQU $3B
B_7 EQU $3C
C_8 EQU $3D
C#8 EQU $3E
D_8 EQU $3F
D#8 EQU $40
E_8 EQU $41
F_8 EQU $42
F#8 EQU $43
G_8 EQU $44
G#8 EQU $45
A_8 EQU $46
A#8 EQU $47
B_8 EQU $48
C_9 EQU $49
C#9 EQU $4A
D_9 EQU $4B
D#9 EQU $4C
E_9 EQU $4D
F_9 EQU $4E
F#9 EQU $4F
G_9 EQU $50
G#9 EQU $51
A_9 EQU $52
A#9 EQU $53
B_9 EQU $54
C_A EQU $55
C#A EQU $56
D_A EQU $57
D#A EQU $58
E_A EQU $59
F_A EQU $5A
F#A EQU $5B
G_A EQU $5C
G#A EQU $5D
A_A EQU $5E
A#A EQU $5F
B_A EQU $60
C_B EQU $61
C#B EQU $62
D_B EQU $63
D#B EQU $64
E_B EQU $65
F_B EQU $66
F#B EQU $67
G_B EQU $68
G#B EQU $69
A_B EQU $6A
A#B EQU $6B
B_B EQU $6C

; Pan equates
LR EQU %11
L_ EQU %10
_R EQU %01
__ EQU %00

; Command bytes
; (Numbers less than $6D are reserved for notes)
EnvelopeByte EQU $70
WaveVolumeByte EQU $71
TempoByte EQU $72
TableByte EQU $73
SlideByte EQU $74
MasterVolByte EQU $75
PanByte EQU $76
SweepByte EQU $77
VibratoByte EQU $78
WaveformByte EQU $79
WaveDataByte EQU $7A
InlineWaveDataByte EQU $7D
LengthByte EQU $7B
MicrotuneByte EQU $7C

; Organisational bytes
SoundJPByte EQU $F0
SoundCallByte EQU $F1
SoundRetByte EQU $F2
SoundEndByte EQU $FF

; Command macros

note: MACRO
    db \1, \2 ; (decide if this needs changing)
    ENDM

envelope: MACRO
    db EnvelopeByte, \1
    ENDM

vol: MACRO
    ; TODO: Can merge into one byte (2-bit)
    db WaveVolumeByte
    IF \1 < 0 || \1 > 3
        WARN "vol macro must have an operand of 0-3."
    ENDC

    IF \1 == 0
        db 0
    ELSE
        db (4 - \1)
    ENDC
    ENDM

tempo: MACRO
    db TempoByte, \1
    ENDM

table: MACRO
    db TableByte, \1
    ENDM

slide: MACRO
    db SlideByte, \1
    ENDM

mastervol: MACRO
    db MasterVolByte, \1
    ENDM

pan: MACRO
    ; TODO: Can merge into one byte (2-bit)
    db OutputByte, \1 ; Do some conversion
    ENDM

sweep: MACRO
    db SweepByte, \1 ; Might not be implemented at first
    ENDM

vibrato: MACRO
    db VibratoByte, \1
    ENDM

waveform: MACRO
    ; TODO: Can merge into one byte (2-bit)
    db WaveformByte

    IF \1==12.5
        db $00
    ELSE

        IF \1==25
            db $01
        ELSE

            IF \1==50
                db $02
            ELSE

                IF \1==75
                    db $03
                ELSE

                    WARN "waveform must have an operand of 12.5, 25, 50, or 75."
                ENDC
            ENDC
        ENDC
    ENDC

    ENDM

wavedata: MACRO
    db WaveDataByte, \1
    ENDM

inlinewavedata: MACRO
    db InlineWaveDataByte
ShiftAmount SET 15 * 8
REPT 16
    db ((\1 >> ShiftAmount) & $FF)
    db $64, $64, $64, $64, $64, $64
    db ShiftAmount
ShiftAmount SET ShiftAmount + -8 ; I know it looks silly, but this was the only way I got it to work
ENDR
    ENDM

length: MACRO
    db LengthByte

    IF !STRCMP("\1", "inf")
        db $FF
    ELSE
        IF \1 < 64
            db (63 - \1) ; Check that this conversion is correct
        ELSE
            WARN "length must have an operand 63 or less, or inf."
        ENDC
    ENDC
    ENDM

microtune: MACRO
    db MicrotuneByte, \1
    ENDM


; Organisational macros

soundjp: MACRO
    db SoundJPByte
    dw \1
    ENDM

soundcall: MACRO
    db SoundCallByte
    dw \1
    ENDM

soundret: MACRO
    db SoundRetByte
    ENDM

soundend: MACRO
    db SoundEndByte
    ENDM

