INCLUDE "Sound/Macros.inc"

SECTION "Game Over", ROMX

GameOverPU1::
    tempo 12
    waveform 50

    transpose 0
    soundcall .Phrase1
    transpose -12
    soundcall .Phrase1

    transpose 0
    soundcall .Phrase1
    transpose -12
    soundcall .Phrase1

    transpose 0
    soundcall .Phrase2
    transpose -12
    soundcall .Phrase2

    transpose 0
    soundcall .Phrase1
    transpose -12
    soundcall .Phrase1

    soundjp GameOverPU1

.Phrase1
    table .Table
    envelope $82
    note ___, 1
    note E_5, 1
    note F_5, 1
    note C_6, 4

    note B_4, 1
    note C_5, 1
    note G_5, 1
    note B_5, 1
    note C_6, 1
    note G_6, 1
    note C_6, 1
    note B_5, 1
    note G_5, 1
    note C_5, 1
    note B_4, 1
    note C_5, 1
    note G_5, 1

    table $0000 ; TODO: Set!
    envelope $52
    note G_5, 1
    envelope $32
    note G_5, 3
    soundret

.Phrase2
    envelope $82
    table .Table
    note ___, 1
    note B_5, 1
    note C_6, 1
    note G_6, 4

    note E_5, 1
    note F_5, 1
    note C_6, 1
    note E_6, 1
    note F_6, 1
    note C_7, 1
    note F_6, 1
    note E_6, 1
    note C_6, 1
    note F_5, 1
    note E_5, 1
    note F_5, 1
    note C_6, 2

    envelope $35
    note E_6, 2

    envelope $2B
    note E_6, 1
    soundret

.Table
; NOTE: Disabled until support for faster tables is implemented
    ; pan _R
    ; twait
    ; pan LR
    soundend


GameOverPU2::
    waveform 50

    transpose 0
    soundcall .Phrase1
    transpose -12
    soundcall .Phrase1

    transpose 0
    soundcall .Phrase1
    transpose -12
    soundcall .Phrase1

    transpose 0
    soundcall .Phrase2
    transpose -12
    soundcall .Phrase2

    transpose 0
    soundcall .Phrase1
    transpose -12
    soundcall .Phrase1

    soundjp GameOverPU2

.Phrase1
    table .Table
    envelope $F1
    note E_5, 1
    note F_5, 1
    note C_6, 1
    note E_6, 3

    note B_4, 1
    note C_5, 1
    note G_5, 1
    note B_5, 1
    note C_6, 1
    note G_6, 1
    note C_6, 1
    note B_5, 1
    note G_5, 1
    note C_5, 1
    note B_4, 1
    note C_5, 1
    note G_5, 1
    note B_5, 1

    table SharedTable
    envelope $52
    note B_5, 1
    envelope $32
    note B_5, 3
    soundret

.Phrase2
    table .Table
    envelope $F1
    note B_5, 1
    note C_6, 1
    note G_6, 1
    note B_6, 3

    note E_5, 1
    note F_5, 1
    note C_6, 1
    note E_6, 1
    note F_6, 1
    note C_7, 1
    note F_6, 1
    note E_6, 1
    note C_6, 1
    note F_5, 1
    note E_5, 1
    note F_5, 1
    note C_6, 1
    note E_6, 1

    table SharedTable
    envelope $52
    note E_6, 1
    envelope $32
    note E_6, 3
    soundret

.Table
; NOTE: Disabled until support for faster tables is implemented
    ;pan L_
    ;twait
    ;pan LR
    soundend


SharedTable:
    pan L_
    twait
    pan LR
    twait
    pan _R
    twait
    pan LR
    twait
    soundjp SharedTable


GameOverWAV::
    wavedata OpenFifthV14

    transpose 0
    soundcall .Phrase1
    transpose -12
    soundcall .Phrase1

    transpose 0
    soundcall .Phrase1
    transpose -12
    soundcall .Phrase1

    transpose 0
    soundcall .Phrase2
    transpose -12
    soundcall .Phrase2

    transpose 0
    soundcall .Phrase1
    transpose -12
    soundcall .Phrase1

    soundjp GameOverWAV

.Phrase1
    vol 3
    note D_5, 4
    note ___, 2
    note A_4, 12

    vol 2
    wait 1
    vol 1
    wait 1
    note ___, 4
    soundret

.Phrase2
    vol 3
    note A_5, 4
    note ___, 2
    note D_5, 12

    vol 2
    wait 1
    vol 1
    wait 1
    note ___, 4
    soundret


GameOverNOI::
    wait 4

    envelope $71
    pan LR
    noise $30, 1

    envelope $41
    pan _R
    noise $41, 7 ; TODO: Set!

    envelope $71
    pan LR
    noise $30, 8

    noise $30, 1

    envelope $41
    pan L_
    noise $41, 1

    envelope $11
    pan _R
    noise $41, 2

    soundjp GameOverNOI
