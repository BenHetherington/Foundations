INCLUDE "Sound/Macros.inc"

SECTION "TempSong", ROMX

; TODO: Make these not need to be exported

TempSong::
    envelope $F8
    tempo 16
    waveform 50
    length 8
    note C_4, 2
    length 8
    note E_4, 2
    length 8
    note B_4, 3
    length 8
    note D_5, 1
    length 8
    note C_5, 2
    length 8
    note E_5, 2
    length 8
    note B_5, 3
    length 8
    note D_6, 1
    soundjp TempSong

TempSongPU2::
    envelope $F1
    waveform 25
    pan _R
    note G_3, 2
    note C_4, 2
    pan L_
    note E_4, 3
    note B_4, 1
    pan _R
    note D_5, 2
    note C_5, 2
    pan L_
    note E_5, 3
    note B_5, 1
    soundjp TempSongPU2

TempSongWAV::
    vol 3
    wavedata $00
    pan L_
    note C_4, 8
    pan _R
    note G_3, 8
    soundjp TempSongWAV