INCLUDE "Sound/Macros.inc"

SECTION "Ben10do Intro", ROMX

; TODO: Make these not need to be exported

Ben10doIntroPU1::
    tempo $03
    envelope $A8
    waveform 12.5

    note D#4, 3
    note ___, 3
    note B_3, 3
    note A#4, 27
    envelope $87

    soundend

Ben10doIntroPU2::
    envelope $1F
    waveform 12.5

    note ___, 9
    table .ArpTable
    note B_4, 30
    envelope $D7

    wait 18

    soundend

.ArpTable
    ttrans 0
    pan L_
    twait

    ttrans 4
    pan _R
    twait

    ttrans 11
    pan L_
    twait

    ttrans 0
    pan _R
    twait

    ttrans 4
    pan L_
    twait

    ttrans 11
    pan _R
    twait

    soundjp .ArpTable

Ben10doIntroWAV::
    vol 3
    wavedata SawtoothWave

    note D#4, 3
    note ___, 3
    note B_3, 3
    note B_4, 18

    vol 3
    wait 9
    vol 2
    wait 9
    vol 1
    wait 9

    vol 0
    soundend

Ben10doIntroNOI::
    envelope $81
    noise $79, 6
    noise $57, 3

    envelope $85
    noise $90, 3
    soundend
