INCLUDE "SubroutineMacros.inc"
INCLUDE "Strings/StringMacros.inc"
INCLUDE "lib/Shift.inc"

IMPORT TextTilesPointer, CopyChar

SECTION "Text Boxes", ROM0

ShowTextBox::
    SwitchWRAMBank BANK(TextTilesPointer)
    xor a
    ld [PrintSettings], a
    call EnsureVBlank

.SetUpWindow
    ld hl, LCDC
    ld a, %01100000 ; Set the map for the window, and enable the window.
    or a, [hl]
    ld [hl], a

.SetInitialWindowPosition
    ld a, 144
    ld [WY], a
    ld a, 7
    ld [WX], a

.SetPalettes
    call SetDefaultTextColours
    call EnsureVBlank

.SetMapAttributes
    ; TODO: Use DMA
    ld a, 1
    ld [VBK], a

    ld hl, $9C00
    ld de, 12
    ld b, 6
    ld c, 20
.MapAttributesLoop
    call EnsureVBlank
    ld a, (7 | %1000) ; TODO: Write a description
    ld [hl+], a
    dec c
    jr nz, .MapAttributesLoop

    add hl, de
    ld c, 20
    dec b
    jr nz, .MapAttributesLoop
    jr .SetTiles

.SetMapLayout
    call EnsureVBlank
    ; TODO: Use DMA
    xor a
    ld [VBK], a ; Use VRAM Bank 0

    ld hl, $9C00 + $21
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
    ld de, OpeningSound
    ld hl, WY
    jr .AnimationLoop

.AnimationSoundFX
; TODO: Eliminate this in favour of a much better sound engine
    ld a, $81
    ld [NR12], a
    ld a, [de]
    ld [NR13], a
    inc de
    ld a, [de]
    ld [NR14], a
    inc de
    jr .AnimationLoop

.SetTiles
    call ClearTextBox
    ld hl, WY

.AnimationLoop
; Move the window up by 4px every frame, until it's 48px tall.
    call WaitFrame
    ld a, ($100 - 4)
    add a, [hl]
    ld [hl], a
    cp (144 - 4)
    jr z, .SetMapLayout
    cp (144 - 24)
    jr nc, .AnimationSoundFX
    cp (144 - 48)
    jr nz, .AnimationLoop

.DelayReturn
    ld c, 8
    jp WaitFrames

OpeningSound
    db %00010001, %10000101
    db %10110100, %10000101
    db %01000100, %10000111
    db %01110011, %00000111
    db %01000100, %10000111

CloseTextBox::
    ld de, ClosingSound
    ld hl, WY

.AnimationLoop
; Move the window down by 4px every frame, until it's off-screen.
    call WaitFrame
    ld a, 4
    add a, [hl]
    ld [WY], a
    cp (144 - 24)
    jr c, .AnimationSoundFX
    cp 144
    jr nz, .AnimationLoop

    ret

.AnimationSoundFX
; Replace with call to sound engine!
    ld a, $81
    ld [NR12], a
    ld a, [de]
    ld [NR13], a
    inc de
    ld a, [de]
    ld [NR14], a
    inc de
    jr .AnimationLoop

ClosingSound:
    db %01000100, %10000111
    db %00000101, %10000111
    db %01110010, %10000110
    db %00010101, %00000100
    db %00010001, %10000101

PlayTextBeep::
    ld a, %10000000 | $3B
    ld [NR11], a

    ld a, $31
    ld [NR12], a

    ld a, %10001000
    ld [NR13], a

    ld a, %11000110
    ld [NR14], a

    ret


ReplaceLastTile::
; assume that *b* has the desired tile no., e.g. the next arrow
    ld a, $84
    ld a, $80
    ld a, b
    call CopyChar

; Source in bc
; Destination in hl
; Current tile in a
; Counter in d
; e has the colouration
    ld a, 1
    ld [VBK], a
    ld bc, TextTilesWorkSpace
    ld hl, TilesPosition + (4 * TilesPerLine) ; $8480
    ld e, 1
    push de
    ld e, 3
    ld d, 8

.TileCopyLoop
    ld a, [bc]
    push bc
    call Convert1BitTileLine
    call EnsureVBlank
    ld a, b
    ld [hl+], a
    ld a, c
    ld [hl+], a
    pop bc
    inc bc
    dec d
    jr nz, .TileCopyLoop

    pop de
    dec e
    ret z
    push de
    ld e, 3
    jr .TileCopyLoop


FastFadeText::
; A more specialised version of the function that was once above it
; Fades out the text
    call WaitFrame
    ld d, 3 ; Outer counter
.OuterLoop
    ld b, 4 ; Number of colours to modify
    ld c, 56 ; Address
.BGPaletteLoop
    call EnsureVBlank

; Load the palette into hl
    inc c
    ld a, c
    ld [BGPI], a

    ld a, [BGPD]
    ld h, a

    dec c
    ld a, c
    inc c
    inc c

    set 7, a ; Increment after writing
    ld [BGPI], a
    ld a, [BGPD]
    ld l, a

; Manipulate the palette data
    call EnsureVBlank
    srl16 hl, 1
    ld a, l
    and %11100111
    ld [BGPD], a

    ld a, h
    and %00011100
    ld [BGPD], a

    dec b
    jr nz, .BGPaletteLoop

    call WaitFrame
    dec d
    jr nz, .OuterLoop
    ret
