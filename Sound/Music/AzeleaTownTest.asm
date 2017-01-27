INCLUDE "Sound/Macros.inc"

SECTION "Azelea Town Test", ROMX

; It's not really Azelea Town anymore, but I can't be bothered to change the name
; TODO: Delete this or something

; TODO: Make these not need to be exported

AzeleaTownTestPU1::
    tempo 187
    envelope $F1
    waveform 50

    transpose 0
REPT 2
    soundcall .Phrase
ENDR

    transpose -2
REPT 2
    soundcall .Phrase
ENDR

    soundjp AzeleaTownTestPU1

.Phrase
    note A_4, 2
    note D_5, 1
    note E_5, 2
    note G_5, 1
    note E_5, 2
    note A_5, 2
    note D_5, 1
    note G_5, 2
    note E_5, 1
    note D_5, 2
    soundret
