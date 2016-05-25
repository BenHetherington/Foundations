; Hardware macros
; TODO: Split out of this if possible
JOYP  EQU $FF00 ; Joypad
SB    EQU $FF01 ; Serial buffer
SC    EQU $FF02 ; Serial control
DIVI  EQU $FF04 ; Divider
TMA   EQU $FF06 ; Timer modulo
TAC   EQU $FF07 ; Timer control
NR11  EQU $FF11 ; PU1 Length & Wave duty
NR12  EQU $FF12 ; PU1 Envelope
NR13  EQU $FF13 ; PU1 Freq low
NR14  EQU $FF14 ; PU1 Freq high +
NR23  EQU $FF18 ; PU2 Freq low
NR33  EQU $FF1D ; WAV Freq low
LCDC  EQU $FF40 ; LCD Control
STAT  EQU $FF41 ; LCDC Status
SCY   EQU $FF42 ; Background Scroll Y
SCX   EQU $FF43 ; Background Scroll X
LY    EQU $FF44 ; LY
LYC   EQU $FF45 ; LY Compare
ODMA  EQU $FF46 ; OAM DMA Register
BGP   EQU $FF47 ; Original GB colour palettes
BGPI  EQU $FF68 ; Background Palette Index
BGPD  EQU $FF69 ; Background Palette Data
OBPI  EQU $FF6A ; Sprite Palette Index
OBPD  EQU $FF6B ; Sprite Palette Data
WY    EQU $FF4A ; Window Scroll Y
WX    EQU $FF4B ; Window Scroll X - 7
VBK   EQU $FF4F ; VRAM Bank Select
HDMA1 EQU $FF51 ; DMA Source (High)
HDMA2 EQU $FF52 ; DMA Source (Low)
HDMA3 EQU $FF53 ; DMA Destination (High)
HDMA4 EQU $FF54 ; DMA Destination (Low)
HDMA5 EQU $FF55 ; DMA Mode/Length/Start
IE    EQU $FFFF ; Interrupts

; Definitions
SRAMEnableLocation EQU $0000
ROMBankSwitchLocation EQU $2000
SRAMBankSwitchLocation EQU $4000
WRAMBankSwitchLocation EQU $FF70

; Bank Switching

CallToOtherBank: MACRO
    ld c, BANK(\1)
    ld hl, \1
    call CallToOtherBankFunction
    ENDM


JumpToOtherBank: MACRO
    ld a, BANK(\1)
    ld hl, \1
    jp JumpToOtherBankFunction
    ENDM


SwitchROMBank: MACRO
    ld a, \1
    SwitchROMBankFromRegister
    ENDM


SwitchROMBankFromRegister: MACRO
; assumes *a* is the requested bank
    ldh [CurrentROMBank], a
    ld [ROMBankSwitchLocation], a
    ENDM


PushROMBank: MACRO
    ldh a, [CurrentROMBank]
    push af
    ENDM


PopROMBank: MACRO
    pop af
    SwitchROMBankFromRegister
    ENDM


EnableSRAM: MACRO
    ld a, $0A
    ld [ResetDisallowed], a
    ld [SRAMEnableLocation], a
    ENDM


DisableSRAM: MACRO
    xor a
    ld [SRAMEnableLocation], a
    ld [ResetDisallowed], a
    ENDM


SwitchSRAMBank: MACRO
    ld a, \1
    ld [SRAMBankSwitchLocation], a
    ENDM


SwitchWRAMBank: MACRO
    ld a, \1
    ld [WRAMBankSwitchLocation], a
    ENDM


PushWRAMBank: MACRO
    ld a, [WRAMBankSwitchLocation]
    push af
    ENDM


PopWRAMBank: MACRO
    pop af
    ld [WRAMBankSwitchLocation], a
    ENDM

; DMA & Double Speed

KEY1 EQU $FF4D ; TODO: Move into a seperate include file

SwitchSpeed: MACRO
    ld a, 1
    ld [KEY1], a
    stop
    ENDM

EnableDoubleSpeed: MACRO
; Switches to double speed if we're not already in double speed mode.
    ld a, [KEY1]
    bit 7, a
    jr nz, .Done\@
.Switch\@
    SwitchSpeed
.Done\@
    ENDM

DisableDoubleSpeed: MACRO
; Switches to regular speed if we're currently in double speed mode.
    ld a, [KEY1]
    bit 7, a
    jr z, .Done\@
.Switch\@
    SwitchSpeed
.Done\@
    ENDM


StartVRAMDMA: MACRO
; Assuming the DMA Wait Routine is in HRAM already
; \1: Source, \2: Destination, \3: Length, \4: 0 = General, 1 = H-Blank
    ;IF \1 & $F != 0
    ;WARN "DMA Souce address's lower four bits must be 0."
    ;ENDC

    ;IF \2 & $F != 0
    ;WARN "DMA Destination address's lower four bits must be 0."
    ;ENDC

    ld a, ((\1) >> 8)
    ld [HDMA1], a
    ld a, ((\1) & $FF)
    ld [HDMA2], a

    ld a, ((\2) >> 8)
    ld [HDMA3], a
    ld a, ((\2) & $FF)
    ld [HDMA4], a

    ld a, ((((\3) / $10) - 1) & $7F) | (((\4) & 1) << 7)
    ld [HDMA5], a
    ENDM


StartOAMDMA: MACRO
    di
    ld a, \1 >> 8
    call OAMDMAWait
    ei
    ENDM

; Memory copying

MemCopy: MACRO
; A wrapper for the MemCopyRoutine
; \1 = source, \2 = destination, \3 = byte count
    ld hl, \1
    ld de, \2

IF \3 == 0
    WARN "Invalid parameter: Bytes must be greater than 0."
ENDC

IF \3 > $FF
    ld bc, \3
    call MemCopyRoutine
ENDC

IF \3 < $100
    ld b, \3
    call SmallMemCopyRoutine
ENDC
    ENDM


MemCopyFixedDest: MACRO
; \1 = source, \2 = destination (fixed), \3 = byte count
    ld hl, \1
    ld c, (\2 & $FF)
    ld b, \3
    call MemCopyFixedDestRoutine
    ENDM
    