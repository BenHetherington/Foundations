INCLUDE "Sound/Macros.inc"

SECTION "Ben10do Intro", ROMX

; TODO: Make these not need to be exported

Ben10doIntroPU1::
    tempo 25
    envelope $A8
    waveform 12.5

    note D#4, 6
    note ___, 6
    note B_3, 6
    note A#4, 54
    envelope $87

    soundend

Ben10doIntroPU2::
    envelope $1F
    waveform 12.5

    note ___, 18
    table .ArpTable
    note B_4, 60
    envelope $D7

    wait 36

    soundend

.ArpTable
    ttrans 0
    pan L_
    twait

    ttrans 4
    gbapan _R
    twait

    ttrans 11
    gbapan L_
    twait

    ttrans 0
    gbapan _R
    twait

    ttrans 4
    gbapan L_
    twait

    ttrans 11
    gbapan _R
    twait

    soundjp .ArpTable

Ben10doIntroWAV::
    vol 3
    wavedata SawtoothWave

    note D#4, 6
    note ___, 6
    note B_3, 6
    note B_4, 36

    vol 3
    wait 18
    vol 2
    wait 18
    vol 1
    wait 18

    vol 0
    soundend

Ben10doIntroNOI::
    envelope $81
    noise $79, 12
    noise $57, 6

    envelope $85
    noise $90, 6
    soundend
