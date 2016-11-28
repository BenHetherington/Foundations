INCLUDE "Strings/charmap.inc"
INCLUDE "SubroutineMacros.inc"
INCLUDE "Strings/StringMacros.inc"
INCLUDE "lib/16-bitMacros.inc"
INCLUDE "lib/AddSub1.inc"
INCLUDE "lib/Shift.inc"

SECTION "Prompt Data", WRAMX

SelectedOption: db ; The index of the currently selected option
SelectedOptionLocation: dw ; The position in the map that the cursor currently occupies
CursorTile: db ; The tile in which the cursor was printed.
BackupPrintSettings: db ; The previous print settings, before we overwrote them

OptionCount: db
BButtonOption: db ; $FF = disable

Option0Data: ds 6
; Data strucutre:
; - PositionY: db
; - PositionX: db
; - TextPointer: dw
; - Pointers: - db %?lll?rrr
;             - db %?uuu?ddd
Option1Data: ds 6
Option2Data: ds 6
Option3Data: ds 6
Option4Data: ds 6
Option5Data: ds 6
Option6Data: ds 6
Option7Data: ds 6

CursorAnimation: db ; bit 7 - direction
                    ; bit 0-6 - frames left before swapping
CursorAnimationWait: db

SECTION "Prompt Text", ROMX

CursorText:
    db "_#3__right_\\"

YesText:
    db "Yes\\"
NoText:
    db "No\\"

YesNoPrompt::
    db 2 ; Two options
    db 1 ; B button = No

    ; Yes
    db 2, 4 ; Y, X
    dw YesText
    db %00001001 ; right -> No
    db $00 ; No vertical movement

    ; No
    db 2, 12 ; Y, X
    dw NoText
    db %10000000 ; left -> Yes
    db $00 ; No vertical movement

NoYesPrompt::
    db 2 ; Two options
    db 0 ; B button = No

    ; No
    db 2, 12 ; Y, X
    dw NoText
    db %10010000 ; left -> Yes
    db $00 ; No vertical movement

    ; Yes
    db 2, 4 ; Y, X
    dw YesText
    db %00001000 ; right -> No
    db $00 ; No vertical movement

FightText:
    db "Fight\\"

MagicText:
    db "Magic\\"

TauntText:
    db "Taunt\\"

ItemText:
    db "Item\\"

TattleText:
    db "Tattle\\"

RunAwayText:
    db "Run Away\\"

BattleScreenPrompt::
    db 6 ; Six options
    db $FF ; B button disabled

    ; Fight
    db 1, 1 ; Y, X
    dw FightText
    db %00001001 ; right -> Magic
    db %10110000 ; down -> Item

    ; Magic
    db 1, 6
    dw MagicText
    db %10001010 ; left -> Fight; right -> Taunt
    db %11000000 ; down -> Tattle

    ; Taunt
    db 1, 12
    dw TauntText
    db %10010000 ; left -> Magic
    db %11010000 ; down -> Run Away

    ; Item
    db 2, 1
    dw ItemText
    db %00001100 ; right -> Tattle
    db %00001000 ; up -> Fight

    ; Tattle
    db 2, 6
    dw TattleText
    db %10111101 ; left -> Item; right -> Run Away
    db %00001001 ; up -> Magic

    ; Run Away
    db 2, 12
    dw RunAwayText
    db %11000000 ; left -> Tattle
    db %00001010 ; up -> Taunt

SECTION "Prompts", ROM0

; Given a pointer to prompt data (hl), begin the prompt.
; Returns the index of the chosen option in a.
Prompt::
    PushSwitchWRAMBank BANK(OptionCount)
    PushSwitchROMBank BANK(YesNoPrompt)

    ld de, OptionCount
    ld b, 2 + (6 * 8)
    call SmallMemCopyRoutine
    ; fallthrough

; Starts a prompt with the saved selections.
; Returns the index of the chosen option in a.
InitPrompt:
.InitSelectedOption
    xor a
    ld [SelectedOption], a

.SetPrintSettings
    SwitchWRAMBank BANK(PrintSettings)

    ld a, [PrintSettings]
    ld b, a

    ld a, %111 ; No beeps, fastest
    ld [PrintSettings], a

    ld a, 2 ; Set to use text colour 2
    ld [TextColour], a

    ld a, (2 * 2) + (8 * 7) + %10000000 ; Set text colour 2
    ld [BGPI], a

    xor a ; Black
    ld [BGPD], a
    ld [BGPD], a
    ; fallthrough

PrintOptions:
    SwitchWRAMBank BANK(BackupPrintSettings)
    ld a, b
    ld [BackupPrintSettings], a

    ld hl, OptionCount
    ld a, [hl+]
    ld b, a
    inc hl

.Loop
; Reset subtiles position
    xor a
    ld [TextSubtilesPositionX], a

; Get Y coordinates
    ld a, [hl+]
    call GetYTilePointer
    ld [TextSubtilesPositionY], a

; Get X coordinates
    call GetXTileOffset

; Set text tile pointer
    ld16a TextTilesPointer, de

; Load text pointer
    push hl
    push bc
    ld a, [hl+]
    ld h, [hl]
    ld l, a

; Print option text
    call PrintString
    pop bc
    pop hl
    inc hl ; TODO: Refactor?
    inc hl
    inc hl
    inc hl

; Check counter
    dec b
    jr nz, .Loop

.Finish
    PopROMBank
    PopWRAMBank
    ; fallthrough

ShowPrompt:
    call PrepareCursor

    xor a
    call SetCursor
    call BattleTextFadeIn
    ; fallthrough

PromptLoop:
    ldh a, [ButtonsPressed]
    ; TODO: Handle button presses sensibly

    cp 0
    jr z, .Wait

    bit 0, a ; TODO: Overhaul!
    jr nz, .AButton

    bit 1, a ; TODO: Overhaul!
    jr nz, .BButton

.Arrows
    call MoveCursor

.Wait
    call AnimateCursor
    call WaitFrame
    jr PromptLoop

.AButton
    call FastFadeText
    call ClearCursor
    call ClearTextBox
    call SetDefaultTextColours

    ld a, [BackupPrintSettings]
    ld b, a
    SwitchWRAMBank BANK(PrintSettings)
    ld a, b
    ld [PrintSettings], a

    SwitchWRAMBank BANK(SelectedOption)
    ld a, [SelectedOption]
    ret

.BButton
    ld a, [BButtonOption]
    cp $FF ; Ignore the B button press
    jr z, .Arrows

    ld [SelectedOption], a
    call SetCursor
    jr .AButton

; Prints the cursor to a tile, to be used by a sprite.
PrepareCursor:
; Reset subtile variables
    xor a
    ld [TextSubtilesPositionY], a
    ld [TextSubtilesPositionX], a

; Print the cursor to $87E0
    ld a, $87
    ld [TextTilesPointer + 1], a
    ld a, $E0
    ld [TextTilesPointer], a

; Print the cursor string
    ld hl, CursorText
    call PrintString

; Set the sprite colour
; TODO: Refactor?
    ld de, $00FF
    call EnsureVBlank
    ld c, (OBPI & $FF)

    ld a, $3E | (%10000000)
    ld [$FF00+c], a
    inc c
    ld a, d
    ld [$FF00+c], a
    ld a, e
    ld [$FF00+c], a

; Set up the sprite tile and palette
    ld hl, OAMData + $9C + 2
    ld a, $7E
    ld [hl+], a
    ld a, %1111
    ld [hl+], a
    ei
    ret

ClearCursor:
    xor a
    ld [OAMData + $9C], a
    StartOAMDMA OAMData
    ret

; Given the buttons in a, move the cursor appropriately.
MoveCursor:
    ld c, a
    ld a, [SelectedOption]

; Get pointer to options data (TODO: Refactor!)
    sla a
    ld b, a
    sla a
    add a, b

    ld hl, Option0Data
    AddTo16 hl, a

    inc hl
    inc hl
    inc hl
    inc hl

    ; AddTo16 hl, 4 ; TODO; FIX!
    ; TODO: Figure out which to call in a better fashion
    ; TODO: Handle diagonals
    bit 4, c
    jr nz, .Right

    bit 5, c
    jr nz, .Left

    bit 6, c
    jr nz, .Down

    jr .Up

.Left
    ld a, [hl]
    swap a
    jr .Continue

.Right
    ld a, [hl]
    jr .Continue

.Up
    inc hl
    ld a, [hl]
    swap a
    jr .Continue

.Down
    inc hl
    ld a, [hl]
    ; fallthrough

.Continue
    and a, %1111
    or a
    ret z

    bit 3, a
    ; TODO: Handle scrolling!

    res 3, a
    ld [SelectedOption], a
    jr SetCursor


; Call with the desired option to point at in a.
SetCursor:
; Get pointer to options data (TODO: Refactor!)
    sla a
    ld b, a
    sla a
    add a, b

    ld hl, Option0Data
    AddTo16 hl, a

    call GetSpriteCoordinates

    ld hl, OAMData + $9C
    ld a, d
    ld [hl+], a
    ld a, e
    ld [hl+], a
    StartOAMDMA OAMData

.ResetAnimation
    ld a, 2
    ld [CursorAnimation], a
    ld a, 4
    ld [CursorAnimationWait], a
    ret

AnimateCursor:
; Check if we need to wait more frames
    ld hl, CursorAnimationWait
    dec [hl]
    ret nz

; Resetting the counter
    ld a, 4
    ld [hl-], a

; Checking the direction to animate
    ld a, [hl]
    ld hl, OAMData + $9C + 1

    ld b, a
    and a, %10000000
    ld c, a
    jr nz, .Right

.Left
    dec [hl]
    jr .Continue

.Right
    inc [hl]
    ; fallthrough

.Continue
    ld hl, CursorAnimation
    ld a, b
    and a, %01111111
    dec a
    jr nz, .Finish

.Swap
    ld a, b
    xor a, %10000000
    ld c, 2

.Finish
    or a, c
    ld [hl], a
    StartOAMDMA OAMData
    ret

; Given a y-coordinate in a, produce the tile pointer in de
; and the y-subtile position in a.
GetYTilePointer:
    cp 1 ; TODO: Refactor?
    jr z, .Line2

    cp 2
    jr z, .Line3

.Line1
    ld de, Line1TilePointer
    xor a
    ret

.Line2
    ld de, Line2TilePointer
    ld a, 4
    ret

.Line3
    ld de, Line3TilePointer
    xor a
    ret

; Given an x-coordinate in a, add the offset to de.
GetXTileOffset:
    ld a, [hl] ; Get high nibble
    and a, $F0
    swap a
    add a, d
    ld d, a

    ld a, [hl+] ; Get low nibble
    and a, $0F
    swap a
    AddTo16 de, a
    ret

; Returns the Y-coordinate in d
; and the X-coordinate in e
GetSpriteCoordinates:
    ld a, [hl+]
    cp 1 ; TODO: Refactor?
    jr z, .Line2

    cp 2
    jr z, .Line3

.Line1
    ld d, 104 + 16
    jr .Continue

.Line2
    ld d, 116 + 16
    jr .Continue

.Line3
    ld d, 128 + 16
    ; fallthrough

.Continue
    ld a, [hl+]
    rlca
    rlca
    rlca
    and a, %11111000

    add a, 8 + 2
    ld e, a
    ret
