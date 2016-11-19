INCLUDE "Sound/Macros.inc"

SECTION "Idea 09/06", ROMX

Idea0906PU1::
    tempo $02
    envelope $A8
    waveform 12.5

REPT 2
    transpose 0
    soundcall .Phrase1
    soundcall .Phrase2

    transpose -3
    soundcall .Phrase1
    soundcall .Phrase2

    transpose -7
    soundcall .Phrase1
    soundcall .Phrase2

    transpose -3
    soundcall .Phrase1
    soundcall .Phrase2
ENDR

    transpose -10
    soundcall .Phrase1
    soundcall .Phrase2

    transpose -7
    soundcall .Phrase1
    soundcall .Phrase2

    transpose -8
    soundcall .Phrase1
    soundcall .Phrase2

    transpose -7
    soundcall .Phrase1
    transpose -5
    soundcall .Phrase2

    soundjp Idea0906PU1

.Phrase1:
    note C_4, 12
    note C_5, 8
    note ___, 4
    note C_4, 8
    note C_5, 8
    note ___, 4
    soundret

.Phrase2:
    note C_4, 4
    note C_5, 12
    note C_4, 8
    note C_5, 12
    note C_4, 4
    note C_5, 12
    soundret


Idea0906PU2::
    envelope $A8
    waveform 12.5

REPT 2
    transpose 0
    soundcall .Phrase1
    soundcall .Phrase2

    soundcall .Phrase3

    transpose -7
    soundcall .Phrase1
    soundcall .Phrase2

    transpose 0
    soundcall .Phrase3
ENDR

    transpose -7
    soundcall .Phrase3

    soundcall .Phrase1
    soundcall .Phrase2

    transpose -5
    soundcall .Phrase3

    transpose -7
    soundcall .Phrase1
    transpose -5
    soundcall .Phrase2

    soundjp Idea0906PU2

.Phrase1:
    note G_4, 12
    note E_5, 8
    note ___, 4
    note G_4, 8
    note E_5, 8
    note ___, 4
    soundret

.Phrase2:
    note G_4, 4
    note E_5, 12
    note G_4, 8
    note E_5, 12
    note G_4, 4
    note E_5, 12
    soundret

.Phrase3:
    note E_4, 12
    note C_5, 8
    note ___, 4
    note E_4, 8
    note C_5, 8
    note ___, 4
    note E_4, 4
    note C_5, 12
    note E_4, 8
    note C_5, 12
    note E_4, 4
    note C_5, 12
    soundret


Idea0906WAV::
    vol 3
    wavedata SawtoothWave

REPT 2
    transpose 0
    soundcall .Phrase1
    soundcall .Phrase2

    transpose -4
    soundcall .Phrase1
    soundcall .Phrase2

    transpose -7
    soundcall .Phrase1
    soundcall .Phrase2

    transpose -4
    soundcall .Phrase1
    soundcall .Phrase2
ENDR

    transpose -11
    soundcall .Phrase1
    soundcall .Phrase2

    transpose -7
    soundcall .Phrase1
    soundcall .Phrase2

    transpose -9
    soundcall .Phrase1
    soundcall .Phrase2

    transpose -7
    soundcall .Phrase1
    transpose -6
    soundcall .Phrase2

    soundjp Idea0906WAV

.Phrase1:
    note ___, 12
    note B_6, 8
    note ___, 4 + 8
    note B_6, 8
    note ___, 4 + 4
    soundret

.Phrase2:
    note B_6, 12
    note ___, 8
    note B_6, 12
    note ___, 4
    note B_6, 12
    soundret
