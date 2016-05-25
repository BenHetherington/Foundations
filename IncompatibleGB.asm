INCLUDE "SubroutineMacros.inc"
INCLUDE "Strings/StringMacros.inc"
INCLUDE "Strings/charmap.inc"

SECTION "Incompatible GB", ROMX

IncompatibleGBText:
    db "§", %111 ; Setting max speed, no SFX
    db "\t\t This game does not\n"
    db "\t\t\t\t\tsupport the\n"
    db "\t\t\t^Original Game Boy.\\"

IncompatibleGB::
; Play sound #1
    ld a, $0D ; envelope
    ld [NR12], a
    ld a, $7 | %10000000
    ld [NR14], a

; Slide out the Nintendo logo
    ld hl, SCX
    ld b, 3
.OuterLoop
    ld c, 4
.InnerLoop
    call BusyWaitFrame
    dec [hl]
    dec c
    jr nz, .InnerLoop

    ld a, [BGP]
    sub %01000100
    ld [BGP], a
    dec b
    jr nz, .OuterLoop


IncompatibleGBPrint
    call BusyWaitFrame
    ld [LCDC], a ; As a should be $00 at this point

    ld a, 12 ; Get the scrolling ready in advance
    ld [SCX], a

    call SetPrintVariables

    ld hl, IncompatibleGBText
    call PrintString

.SetMapLayout
    call EnsureVBlank
    ; TODO: Replace with standard copying subroutine

    ld hl, $9800 + $E1
    ld a, TileID + 1
    ld b, 5
    ld c, 18
    ld de, 14
.MapLayoutLoop
    ld [hl+], a
    inc a
    dec c
    jr nz, .MapLayoutLoop

    add hl, de
    ld c, 18
    dec b
    jr nz, .MapLayoutLoop


IncompatibleGBSlideIn
; Play sound #2
    ld a, $72 ; envelope
    ld [NR12], a
    ld a, $2D
    ld [NR13], a
    ld a, $7 | %10000000
    ld [NR14], a

; Slide in the new message
    ld a, %10000001
    ld [LCDC], a

    ld hl, SCX
    ld b, 3
.OuterLoop
    ld c, 4
.InnerLoop
    call BusyWaitFrame
    dec [hl]
    dec c
    jr nz, .InnerLoop

    ld a, [BGP]
    add %01000000
    ld [BGP], a
    dec b
    jr nz, .OuterLoop

.LockUp
    jr .LockUp

BusyWaitFrame:
    push af

.Loop1
    ld a, [LY]
    cp $90
    jr nz, .Loop1

.Loop2
    ld a, [LY]
    cp $91
    jr nz, .Loop2

    pop af
    ret
