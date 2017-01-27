INCLUDE "SubroutineMacros.inc"
INCLUDE "Strings/charmap.inc"

SECTION "Dynamic Interrupt Handlers", WRAM0
DIHStart:
VBlankDIH: ds 32
VBlankDIHCounter: db ; This is always one less than the count (so if there are no handlers, this is $FF)
LCDStatDIH:: ds 8
DIHEnd:

SECTION "Dynamic Interrupt Handler Routines", ROM0
ResetInterruptHandlers::
    di
    MemClear DIHStart, DIHEnd - DIHStart

    ld a, $FF
    ld [VBlankDIHCounter], a

    ld a, $C9 ; ret - required, else we'll start executing arbitrary RAM
    ld [VBlankDIH], a
    ld a, $D9 ; reti
    ld [LCDStatDIH], a

    reti

PopVBlankHandler::
    di
    ld hl, VBlankDIHCounter
    dec [hl]
    ld a, [hl]

    ld b, a
    add a, a
    add a, b ; Multiply a by 3

    jr c, .Zero

.NonZero
; Replace the max element's call with a jp (equivalent to call; ret)
    AddTo16 hl, VBlankDIH
    ld a, $C3 ; jp
    ld [hl], a
    jr .Finish

.Zero
; Just return straight away from the DIH
    ld a, $C9 ; ret
    ld [VBlankDIH], a
    ; fallthrough

.Finish
    reti

PushVBlankHandler::
; de = The new handler to push
    di

; First, replace the previous handler's jp with a call
    ld hl, VBlankDIHCounter
    ld a, [hl]
    cp $FF
    jr z, .Continue

.AmendExisitingHandler
    ld b, a
    add a, a
    add a, b ; Multiply a by 3

    AddTo16 hl, VBlankDIH
    ld a, $CD ; call
    ld [hl], a

.Continue
; Now, push the new handler (as a jp)
    ld hl, VBlankDIHCounter
    inc [hl]
    ld a, [hl]

    ld b, a
    add a, a
    add a, b ; Multiply a by 3

    AddTo16 hl, VBlankDIH
    ld a, $C3 ; jp

; Write the jp, followed by the address
    ld [hl+], a
    ld a, e
    ld [hl+], a
    ld a, d
    ld [hl+], a

    reti


SECTION "Fixed Interrupt Handlers", ROM0

HandleButtons: MACRO
    ld c, (JOYP & $FF)
    ld a, %11011111 ; Select buttons
    ld [$FF00+c], a

    ld a, [$FF00+c]
    cpl
    and a, %00001111
    ld b, a

    ld a, %11101111 ; Select directions
    ld [$FF00+c], a

    ld a, [$FF00+c]
    cpl
    and a, %00001111
    swap a
    or a, b

    ld b, a
    ldh a, [ButtonsHeld]

    xor a, b
    and a, b

    ldh [ButtonsPressed], a
    ld a, b
    ldh [ButtonsHeld], a
    ENDM

VBlankHandler::
    push af ; Push everything
    push bc
    push de
    push hl

.CheckReset
    ldh a, [ResetDisallowed]
    or a
    jr nz, .SetVBlankOccurredFlag

    ld a, %11011111 ; Set buttons; need to reset them to what they were before!
    ld [JOYP], a

    ld a, [JOYP]
    and a, %00001111
    jr nz, .SetVBlankOccurredFlag

.Reset
    SwitchROMBank BANK(GameStartup)
    jp GameStartup

.SetVBlankOccurredFlag
    xor a
    ldh [VBlankOccurred], a

    HandleButtons

.DynamicHandlers
    call VBlankDIH

    pop hl ; Pop everything
    pop de
    pop bc
    pop af
    reti

; TODO: Move this somewhere sensible
Gradient::
    push af

    ld a, [STAT]
    bit 1, a
    jr nz, .SetUpHBlankInterrupt

    push bc

    ld a, [LY]
    and a, %11111000
    ld b, a ; Save LY for later on
    rrca
    rrca

    add a, GradientData & $FF
    ld c, a

    ld a, %10000000
    ld [BGPI], a

    ld a, [$FF00+c]
    ld [BGPD], a

    inc c
    ld a, [$FF00+c]
    ld [BGPD], a

    ld a, b
    add a, 8
    cp $90
    jr c, .Continue

.Overflow
    xor a

.Continue
    ld [LYC], a

    ld a, %01000000
    ld [STAT], a
    pop bc
    pop af
    reti

.SetUpHBlankInterrupt
    ld a, %00001000
    ld [STAT], a
    pop af
    reti
