; Here's some syntax:

; note C_3, 1 (pitch, length in semiquavers) (use ___ as pitch to kill note)
; envelope $A8 (copied directly to NRx2)
; vol 3 (for wave channel)
; tempo 50 (still yet to decide how this works)
; table ArpTable (pointer to a table to use)
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

; Note equates
___ EQU $F00F ; Not really a note, but will silence the channel
C_3 EQU $00
C#3 EQU $01
D_3 EQU $02
D#3 EQU $03
E_3 EQU $04
F_3 EQU $05
F#3 EQU $06
G_3 EQU $07
G#3 EQU $08
A_3 EQU $09
A#3 EQU $0A
B_3 EQU $0B
C_4 EQU $0C
C#4 EQU $0D
D_4 EQU $0E
D#4 EQU $0F
E_4 EQU $10
F_4 EQU $11
F#4 EQU $12
G_4 EQU $13
G#4 EQU $14
A_4 EQU $15
A#4 EQU $16
B_4 EQU $17
C_5 EQU $18
C#5 EQU $19
D_5 EQU $1A
D#5 EQU $1B
E_5 EQU $1C
F_5 EQU $1D
F#5 EQU $1E
G_5 EQU $1F
G#5 EQU $20
A_5 EQU $21
A#5 EQU $22
B_5 EQU $23
C_6 EQU $24
C#6 EQU $25
D_6 EQU $26
D#6 EQU $27
E_6 EQU $28
F_6 EQU $29
F#6 EQU $2A
G_6 EQU $2B
G#6 EQU $2C
A_6 EQU $2D
A#6 EQU $2E
B_6 EQU $2F
C_7 EQU $30
C#7 EQU $31
D_7 EQU $32
D#7 EQU $33
E_7 EQU $34
F_7 EQU $35
F#7 EQU $36
G_7 EQU $37
G#7 EQU $38
A_7 EQU $39
A#7 EQU $3A
B_7 EQU $3B
C_8 EQU $3C
C#8 EQU $3D
D_8 EQU $3E
D#8 EQU $3F
E_8 EQU $40
F_8 EQU $41
F#8 EQU $42
G_8 EQU $43
G#8 EQU $44
A_8 EQU $45
A#8 EQU $46
B_8 EQU $47
C_9 EQU $48
C#9 EQU $49
D_9 EQU $4A
D#9 EQU $4B
E_9 EQU $4C
F_9 EQU $4D
F#9 EQU $4E
G_9 EQU $4F
G#9 EQU $50
A_9 EQU $51
A#9 EQU $52
B_9 EQU $53
C_A EQU $54
C#A EQU $55
D_A EQU $56
D#A EQU $57
E_A EQU $58
F_A EQU $59
F#A EQU $5A
G_A EQU $5B
G#A EQU $5C
A_A EQU $5D
A#A EQU $5E
B_A EQU $5F
C_B EQU $60
C#B EQU $61
D_B EQU $62
D#B EQU $63
E_B EQU $64
F_B EQU $65
F#B EQU $66
G_B EQU $67
G#B EQU $68
A_B EQU $69
A#B EQU $6A
B_B EQU $6B

; TODO: Deal with $6C-$7F

; Pan equates
LR EQU %00010001
L_ EQU %00010000
_R EQU %00000001
__ EQU %00000000

; Wave equates (for use with wavedata)
SawtoothWave EQU $00

; Command bytes
; (Numbers less than $80 are reserved for notes)
CommandByte EQU $80
BiggestCommand EQU $96

EnvelopeByte EQU $80
TempoByte EQU $81
SetTableByte EQU $82
SlideByte EQU $83
MasterVolByte EQU $84
PanByte EQU $85
SweepByte EQU $86
VibratoByte EQU $87
WaveformByte EQU $88
WaveDataByte EQU $89
InlineWaveDataByte EQU $8A
LengthByte EQU $8B
MicrotuneByte EQU $8C
WaitByte EQU $8D
TableWaitByte EQU $8E
TransposeByte EQU $8F
TableTransposeByte EQU $90
KillNoteByte EQU $91
NoiseByte EQU $92

; Organisational bytes
SoundJPByte EQU $93
SoundCallByte EQU $94
SoundRetByte EQU $95
SoundEndByte EQU $96

; Command macros

note: MACRO
; Plays note \1, and then wait for \2 ticks
; e.g. note C_3, 5
; Not to be used in tables
    IF (\1) != ___
        db (\1), (\2)
    ELSE
        db KillNoteByte, (\2)
    ENDC
    ENDM

noise: MACRO
; Plays noise with shape \1, and then wait for \2 ticks
; e.g. noise $FF, 3
; Not to be used in tables
    IF (\1 < CommandByte) || (\1 == ___)
        note (\1), (\2)
    ELSE
        db NoiseByte, (\1), (\2)
    ENDC
    ENDM

envelope: MACRO
; Use the given envelope (volume/attack/release)
    db EnvelopeByte, (\1)
    ENDM

vol: MACRO
; Use the given volume for the WAV channel
    db EnvelopeByte
    IF (\1) < 0 || (\1) > 3
        WARN "vol macro must have an operand of 0-3."
    ENDC

    IF (\1) == 0
        db 0
    ELSE
        db (4 - (\1)) << 5
    ENDC
    ENDM

tempo: MACRO
; Set the music tempo to the given value
    db TempoByte, (\1)
    ENDM

table: MACRO
; Set the table to use for this channel (set to $0000 to revert)
    db SetTableByte
    dw (\1)
    ENDM

slide: MACRO
; Begin to slide to new notes, with \1 speed
    db SlideByte, (\1)
    ENDM

mastervol: MACRO
; Set the master volume of the Game Boy
    db MasterVolByte, (\1)
    ENDM

pan: MACRO
; Pan the current sound channel left, right, neither, or centre
    db PanByte, (\1)
    ENDM

sweep: MACRO
; Start to sweep up/down from notes in PU1
    db SweepByte, (\1)
    ENDM

vibrato: MACRO
; Add a vibrato effect (with \1 intensity)
    db VibratoByte, (\1)
    ENDM

waveform: MACRO
; Set the waveform of PU1 or PU2
; TODO: Can merge into one byte (2-bit)
    db WaveformByte

    IF (\1) == 12.5
        db %00000000
    ELSE

        IF (\1) == 25
            db %01000000
        ELSE

            IF (\1) == 50
                db %10000000
            ELSE

                IF (\1) == 75
                    db %11000000
                ELSE

                    WARN "waveform must have an operand of 12.5, 25, 50, or 75."
                ENDC
            ENDC
        ENDC
    ENDC

    ENDM

wavedata: MACRO
; Set the wavedata to use for the WAV channel
    db WaveDataByte, (\1)
    ENDM

inlinewavedata: MACRO
; Set the wavedata to use for the WAV channel
; This is to be discouraged; if possible, don't include it at all!
    db InlineWaveDataByte
Position SET 1
REPT 16
    db (\1)
    SHIFT
ENDR
    ENDM

length: MACRO
; Set the length to use for non-WAV notes
    db LengthByte

    IF !STRCMP("\1", "inf")
        db $FF
    ELSE
        IF (\1) < 64
            db (63 - (\1)) ; Check that this conversion is correct
        ELSE
            WARN "length must have an operand 63 or less, or inf."
        ENDC
    ENDC
    ENDM

microtune: MACRO
; Detune notes by \1
    db MicrotuneByte, (\1)
    ENDM

wait: MACRO
; Wait for \1 ticks before continuing
; Not to be used in tables
    db WaitByte, (\1)
    ENDM

twait: MACRO
; Wait for the next tick before continuing
; Only for use in tables
    db TableWaitByte
    ENDM

transpose: MACRO
; Transpose future notes by \1 semitones
    db TransposeByte, (\1)
    ENDM

ttrans: MACRO
; Transpose the last note by \1 semitones
; Designed for use in tables
    db TableTransposeByte, (\1)
    ENDM


; Organisational macros

soundjp: MACRO
; Jump to a different part of the sound data
    db SoundJPByte
    dw (\1)
    ENDM

soundcall: MACRO
; Call a reusable phrase
; Not to be used in tables
    db SoundCallByte
    dw (\1)
    ENDM

soundret: MACRO
; Return from a phrase
; Not to be used in tables
    db SoundRetByte
    ENDM

soundend: MACRO
; End a sound channel's table or music
    db SoundEndByte
    ENDM

