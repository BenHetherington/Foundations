INCLUDE "Sound/Macros.asm"

SECTION "Azelea Town Test", ROMX

; It's not really Azelea Town anymore, but I can't be bothered to change the name
; TODO: Delete this or something

; TODO: Make these not need to be exported

AzeleaTownTestPU1::
    tempo $0B
REPT 100
REPT 2
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
ENDR

REPT 2
    note G_4, 2
    note C_5, 1
    note D_5, 2
    note F_5, 1
    note D_5, 2
    note G_5, 2
    note C_5, 1
    note F_5, 2
    note D_5, 1
    note C_5, 2
ENDR
ENDR
