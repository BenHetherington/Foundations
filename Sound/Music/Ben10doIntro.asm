INCLUDE "Sound/Macros.inc"

SECTION "Ben10do Intro", ROMX

; TODO: Make these not need to be exported

Ben10doIntroPU1::
    tempo $09
    envelope $A8
    waveform 12.5

    note D#4, 1
    note ___, 1
    note B_3, 1
    note A#4, 9
    envelope $87

    soundend

Ben10doIntroPU2::
    envelope $1F
    waveform 12.5

    note ___, 3
    note B_4, 10 ; TODO: Arpeggiate!
    envelope $D7

    soundend

Ben10doIntroWAV::
    vol 3
    wavedata $00

    note D#4, 1
    note ___, 1
    note B_3, 1
    note B_4, 6

    vol 3
    wait 3
    vol 2
    wait 3
    vol 1
    wait 3

    vol 0
    soundend

Ben10doIntroNOI::
    ; TODO: Populate!
    soundend
