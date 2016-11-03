INCLUDE "Sound/Macros.inc"

SECTION "Idea 09/06", ROMX

Idea0906PU1::
    tempo $02
    envelope $A8
    waveform 12.5

; TODO: Call this over and over, but with transposition
REPT 2
    note C_4, 12
    note C_5, 8
    note ___, 4
    note C_4, 8
    note C_5, 8
    note ___, 4
    note C_4, 4
    note C_5, 12
    note C_4, 8
    note C_5, 12
    note C_4, 4
    note C_5, 12

    note A_3, 12
    note A_4, 8
    note ___, 4
    note A_3, 8
    note A_4, 8
    note ___, 4
    note A_3, 4
    note A_4, 12
    note A_3, 8
    note A_4, 12
    note A_3, 4
    note A_4, 12

    note F_3, 12
    note F_4, 8
    note ___, 4
    note F_3, 8
    note F_4, 8
    note ___, 4
    note F_3, 4
    note F_4, 12
    note F_3, 8
    note F_4, 12
    note F_3, 4
    note F_4, 12

    note A_3, 12
    note A_4, 8
    note ___, 4
    note A_3, 8
    note A_4, 8
    note ___, 4
    note A_3, 4
    note A_4, 12
    note A_3, 8
    note A_4, 12
    note A_3, 4
    note A_4, 12
ENDR

    note D_3, 12
    note D_4, 8
    note ___, 4
    note D_3, 8
    note D_4, 8
    note ___, 4
    note D_3, 4
    note D_4, 12
    note D_3, 8
    note D_4, 12
    note D_3, 4
    note D_4, 12

    note F_3, 12
    note F_4, 8
    note ___, 4
    note F_3, 8
    note F_4, 8
    note ___, 4
    note F_3, 4
    note F_4, 12
    note F_3, 8
    note F_4, 12
    note F_3, 4
    note F_4, 12

    note E_3, 12
    note E_4, 8
    note ___, 4
    note E_3, 8
    note E_4, 8
    note ___, 4
    note E_3, 4
    note E_4, 12
    note E_3, 8
    note E_4, 12
    note E_3, 4
    note E_4, 12

    note F_3, 12
    note F_4, 8
    note ___, 4
    note F_3, 8
    note F_4, 8
    note ___, 4
    note G_3, 4
    note G_4, 12
    note G_3, 8
    note G_4, 12
    note G_3, 4
    note G_4, 12

    soundjp Idea0906PU1


Idea0906PU2::
    envelope $A8
    waveform 12.5

; TODO: Call this over and over, but with transposition
REPT 2
    note G_4, 12
    note E_5, 8
    note ___, 4
    note G_4, 8
    note E_5, 8
    note ___, 4
    note G_4, 4
    note E_5, 12
    note G_4, 8
    note E_5, 12
    note G_4, 4
    note E_5, 12

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

    note C_4, 12
    note A_4, 8
    note ___, 4
    note C_4, 8
    note A_4, 8
    note ___, 4
    note C_4, 4
    note A_4, 12
    note C_4, 8
    note A_4, 12
    note C_4, 4
    note A_4, 12

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
ENDR

    note A_3, 12
    note F_4, 8
    note ___, 4
    note A_3, 8
    note F_4, 8
    note ___, 4
    note A_3, 4
    note F_4, 12
    note A_3, 8
    note F_4, 12
    note A_3, 4
    note F_4, 12

    note C_4, 12
    note A_4, 8
    note ___, 4
    note C_4, 8
    note A_4, 8
    note ___, 4
    note C_4, 4
    note A_4, 12
    note C_4, 8
    note A_4, 12
    note C_4, 4
    note A_4, 12

    note B_3, 12
    note G_4, 8
    note ___, 4
    note B_3, 8
    note G_4, 8
    note ___, 4
    note B_3, 4
    note G_4, 12
    note B_3, 8
    note G_4, 12
    note B_3, 4
    note G_4, 12

    note C_4, 12
    note A_4, 8
    note ___, 4
    note C_4, 8
    note A_4, 8
    note ___, 4
    note D_4, 4
    note B_4, 12
    note D_4, 8
    note B_4, 12
    note D_4, 4
    note B_4, 12

    soundjp Idea0906PU2


Idea0906WAV::
    vol 3
    wavedata SawtoothWave

; TODO: Call this over and over, but with transposition
REPT 2
    note ___, 12
    note B_6, 8
    note ___, 4 + 8
    note B_6, 8
    note ___, 4 + 4
    note B_6, 12
    note ___, 8
    note B_6, 12
    note ___, 4
    note B_6, 12

    note ___, 12
    note G_6, 8
    note ___, 4 + 8
    note G_6, 8
    note ___, 4 + 4
    note G_6, 12
    note ___, 8
    note G_6, 12
    note ___, 4
    note G_6, 12

    note ___, 12
    note E_6, 8
    note ___, 4 + 8
    note E_6, 8
    note ___, 4 + 4
    note E_6, 12
    note ___, 8
    note E_6, 12
    note ___, 4
    note E_6, 12

    note ___, 12
    note G_6, 8
    note ___, 4 + 8
    note G_6, 8
    note ___, 4 + 4
    note G_6, 12
    note ___, 8
    note G_6, 12
    note ___, 4
    note G_6, 12
ENDR

    note ___, 12
    note C_6, 8
    note ___, 4 + 8
    note C_6, 8
    note ___, 4 + 4
    note C_6, 12
    note ___, 8
    note C_6, 12
    note ___, 4
    note C_6, 12

    note ___, 12
    note E_6, 8
    note ___, 4 + 8
    note E_6, 8
    note ___, 4 + 4
    note E_6, 12
    note ___, 8
    note E_6, 12
    note ___, 4
    note E_6, 12

    note ___, 12
    note D_6, 8
    note ___, 4 + 8
    note D_6, 8
    note ___, 4 + 4
    note D_6, 12
    note ___, 8
    note D_6, 12
    note ___, 4
    note D_6, 12

    note ___, 12
    note E_6, 8
    note ___, 4 + 8
    note E_6, 8
    note ___, 4 + 4
    note F_6, 12
    note ___, 8
    note F_6, 12
    note ___, 4
    note F_6, 12

    soundjp Idea0906WAV
