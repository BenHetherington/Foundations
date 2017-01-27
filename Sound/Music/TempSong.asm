INCLUDE "Sound/Macros.inc"

SECTION "TempSong", ROMX

; TODO: Make these not need to be exported

TempSong::
    envelope $F8
    tempo 136
    waveform 50
    length 8
    note C_4, 4
    length 8
    note E_4, 4
    length 8
    note B_4, 6
    length 8
    note D_5, 2
    length 8
    note C_5, 4
    length 8
    note E_5, 4
    length 8
    note B_5, 6
    length 8
    note D_6, 2
    soundjp TempSong

TempSongPU2::
    envelope $F1
    waveform 25
    pan _R
    note G_3, 4
    note C_4, 4
    pan L_
    note E_4, 6
    note B_4, 2
    pan _R
    note D_5, 4
    note C_5, 4
    pan L_
    note E_5, 6
    note B_5, 2
    soundjp TempSongPU2

TempSongWAV::
    vol 3
    wavedata $00
    pan L_
    note C_4, 16
    pan _R
    note G_3, 16
    soundjp TempSongWAV
