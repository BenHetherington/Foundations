INCLUDE "Strings/charmap.inc"
INCLUDE "lib/16-bitMacros.inc"
INCLUDE "lib/AddSub1.inc"
INCLUDE "SubroutineMacros.inc"

SECTION "Keyboard Entry Vars", WRAMX
KeyboardEntryVars:
KBMaxCharacters: db
KBDestination: dw

OAMDataTemp EQU $D000
OAMDataLength EQU 160

TilesTemp EQU OAMDataTemp + OAMDataLength
TilesTempSource EQU $8800 ; in Bank 2
TilesTempLength EQU $640

Map1Temp EQU TilesTemp + TilesTempLength
Map1TempSource EQU $9800
Map1TempLength EQU 20 * 11 * 2 ; Second half is for attributes

Map2Temp EQU Map1Temp + Map1TempLength
Map2TempSource EQU $9C00
Map2TempLength EQU 20 * 17 * 2 ; More of this map is revealed (+ as above)

BGPalette6Temp EQU Map2Temp + Map2TempLength
BGPalette6TempLength EQU 4 * 2

SECTION "Keyboard Entry", ROMX

IMPORT TextTilesPointer

KBPalettes:
    db $C6,$18,$00,$7F,$00,$00,$94,$52

SpikeTiles:
    db $00,$FE,$00,$FC,$00,$F8,$00,$F0,$00,$E0,$00,$C0,$00,$80,$00,$00 ; Left
    db $00,$FF,$00,$7F,$00,$3F,$00,$1F,$00,$0F,$00,$07,$00,$03,$00,$01 ; Right

ControlsHelp:
    db "_#3_"
    db "_(B)_ Del  ^^^"
    db "SL   " ; TODO: Replace with _select_
    db "ST OK\\" ; TODO: Replace with _start_

UpperString:
    db "Upper\\"

LowerString:
    db "Lower\\"

SymbolString:
    db "Symbol\\"

; Used to lookup the character to append
UpperChars:
    db "ABCDEFGHIJKLMNOPQRSTUVWXYZ \\"
LowerChars:
    db "abcdefghijklmnopqrstuvwxyz \\"
SymbolChars:
    db "123.,!?:;456'“”()/7890&+-_=\\"

ShowKeyboard::
    ; Shows the keyboard, and requests that the player enter some text.
    ; This will be capped to a characters, and the resulting string will be stored in de.
    PushSwitchWRAMBank BANK(KeyboardEntryVars)
    ld [KBMaxCharacters], a
    ld16a KBDestination, de

    call InitKeyboard

    ld d, 120
.Runloop
    ; TODO: Handle the runloop
    call AnimateCursor

    call WaitFrame
    dec d
    jr nz, .Runloop

    jp DeinitKeyboard

InitKeyboard:
; Backup the tile IDs on both maps (to WRAM Bank 7 - only need to copy some of each)
    call BackupTileIDs

; Set the visible map below the text box (in map 2) to $00
    call ClearMapBelowDialog
    call SetMapAttributesBelowDialog

    ; TODO: Must ensure that tile $00 has priority over sprites
    ;       or just disable sprites below the given scanline

; Scroll the window up, so that it fills the screen
    ld a, 96
.ScrollWindow
    sub a, 6
    ld [WY], a

    ld b, a
    call WaitFrame
    ld a, b

    or a
    jr nz, .ScrollWindow

; Set BG origin to 0,0.
    ; a is already 0
    ld [SCY], a
    ld [SCX], a

; Swap window and BG maps, and hide the window
    ld b, %01101000 ; ld b, %01101000
    call InvertLCDCFlags

; Backup the OAM Data (to WRAM Bank 7)
    PushSwitchWRAMBank 7
    MemCopy OAMData, OAMDataTemp, OAMDataLength

; Backup non-text tiles in VRAM Bank 2 (to WRAM Bank 7)
    ; - $36 for character tiles
    ; - $08 for "input field"
    ; - $02 for spikey effect
    ; - $24 for control info at bottom of screen
    ld a, 1
    ld [VBK], a
    VRAMCopy TilesTempSource, TilesTemp, TilesTempLength

    PopWRAMBank

; Copy the spikey tiles to VRAM
    VRAMCopy SpikeTiles, $8800, $20

; Print the character tiles to VRAM
    ld hl, UpperChars
    call PrintCharacters

    ; Print the input field to VRAM

; Print the control info to VRAM
    ld a, $8B
    ld [TextTilesPointer + 1], a
    ld a, $80
    ld [TextTilesPointer], a

    ld hl, ControlsHelp
    call PrintString

; Copy the keyboard map to map 1 (which is being used by the window)
    call SetKeyboardMap

; Set up palette 6
    ld a, %10000000 | 6 * (2 * 4)
    ld [BGPI], a
    MemCopyFixedDest KBPalettes, BGPD, 8

; Show the cursor
    call PrepareCursor

; (Switch on and) Scroll the window up from the bottom of the screen (ease out)
    call WaitFrame ; To avoid screen tearing
    ld b, %00100000
    call InvertLCDCFlags

    ld a, 144
    ld c, 26
    ld hl, SineTable + 140
.ScrollKeyboard
    ld a, [hl+]
    inc hl
    add a, a
    add a, a
    add a, 56
    ld [WY], a

    call WaitFrame
    dec c
    jr nz, .ScrollKeyboard

    ret

DeinitKeyboard:
    ; TODO: Do something about the on-screen entered text!

; Scroll the window to the bottom of the screen (ease in)
    ld a, 56
    ld c, 26
    ld hl, SineTable + 192
.ScrollKeyboard
    ld a, [hl+]
    inc hl
    add a, a
    add a, a
    add a, 56
    ld [WY], a

    call WaitFrame
    dec c
    jr nz, .ScrollKeyboard

; Restore the tiles in VRAM Bank 2
    PushSwitchWRAMBank 7
    ld a, 1
    ld [VBK], a
    StartVRAMDMA TilesTemp, TilesTempSource, TilesTempLength, 1

; Restore the OAM Data
    MemCopy OAMDataTemp, OAMData, OAMDataLength

    call WaitForVRAMDMAToFinish
    StartOAMDMA OAMData

    PopWRAMBank

; Swap window and BG maps, and show window at top-left of screen
    call WaitFrame ; Try to reduce screen tearing
    ld b, %01001000 ; ld b, %01101000
    call InvertLCDCFlags

; Restore the tile IDs on map 1
    call RestoreMap1

; Scroll the window back to the text display's normal position
    xor a
.ScrollWindow
    add a, 6
    ld [WY], a

    ld b, a
    call WaitFrame
    ld a, b

    cp 96
    jr nz, .ScrollWindow

    ; Restore the tile IDs on map 2
    call RestoreMap2

    PopWRAMBank
    ret

InvertLCDCFlags::
; Swaps the BG and window maps, and inverts the window's status
; Set b to %01101000 to do this
    ld c, LCDC & $FF
    ld a, [$FF00+c]
    xor a, b
    ld [$FF00+c], a
    ret

ClearMapBelowDialog:
    xor a
    ld [VBK], a

    ld hl, $9CC0
    ld c, 12
    ld d, 0
.Loop
    ld b, 20
    call SmallVRAMSetRoutine
    dec c
    ret z

    add16i hl, 12
    jr .Loop

SetMapAttributesBelowDialog:
    ld a, 1
    ld [VBK], a

    ld hl, $9CC0
    ld c, 12
    ld d, $0F
.Loop
    ld b, 20
    call SmallVRAMSetRoutine
    dec c
    ret z

    add16i hl, 12
    jr .Loop

SetKeyboardMap:
    xor a
    ld [VBK], a

.ClearMap
    ld hl, $9800 ; Destination address
    ld d, 11 ; Outer counter

.ClearMapLoop
    ld bc, 20 + $101 ; Inner counter
    call VRAMClearRoutine

    add16i hl, 12
    dec d
    jr nz, .ClearMapLoop

.Spikes
    ld hl, $9800 ; Destination address
    ld c, 10 ; Counter (no. tiles / 2)

.SpikesLoop
    call EnsureVRAMAccess
    ld a, $80
    ld [hl+], a
    ei

    call EnsureVRAMAccess
    ld a, $81
    ld [hl+], a
    ei

    dec c
    jr nz, .SpikesLoop

.Characters
    ld hl, $9842 ; Destination address
    ld b, 6      ; Outer counter
    ld c, 9      ; Inner counter
    ld d, $82    ; Current tile value

.CharactersLoop
    call EnsureVRAMAccess
    ld a, d
    ld [hl+], a
    ei

    inc hl
    inc d
    dec c
    jr nz, .CharactersLoop

    ld c, 9
    add16i hl, 14
    dec b
    jr nz, .CharactersLoop

.Controls
    ld hl, $9921 ; Destination address
    ld b, 2      ; Outer counter
    ld c, 18     ; Inner counter
    ld d, $B8    ; Current tile value

.ControlsLoop
    call EnsureVRAMAccess
    ld a, d
    ld [hl+], a
    ei

    inc d
    dec c
    jr nz, .ControlsLoop

    add16i hl, 14
    ld c, 18
    dec b
    jr nz, .ControlsLoop

.SetAttributes
    ld a, 1
    ld [VBK], a

    ld hl, $9800 ; Destination address
    ld c, 11 ; Outer counter
    ld d, %1000 | 6

.SetAttributesLoop
    ld b, 20 ; Inner counter
    call SmallVRAMSetRoutine

    add16i hl, 12
    dec c
    jr nz, .SetAttributesLoop

    ret


PrintCharacters:
    ld a, 1
    ld [VBK], a

.Setup
    PushSwitchWRAMBank BANK(TextTilesPointer)
    call SetPrintVariables

    ld a, $88
    ld [TextTilesPointer + 1], a
    ld a, $20
    ld [TextTilesPointer], a

    ld a, $00
    ld [TextLineLength + 1], a
    ld a, $70
    ld [TextLineLength], a

    ld a, %111
    ld [PrintSettings], a

    ld a, 1
    ld [TextColour], a

.StartLoop
    ld b, 3
    ld c, 9

.Loop
    ld a, [hl+]
    push hl
    push bc
    call PutChar

    ld hl, TextSubtilesPositionX
    ld a, [hl]
    or a
    jr z, .SkipIncrement

    add16i TextTilesPointer, $10

.SkipIncrement
    xor a
    ld [hl], a
    
    pop bc
    pop hl

    dec c
    jr nz, .Loop

    ld c, 9
    add16i TextTilesPointer, $90
    dec b
    jr nz, .Loop

    PopWRAMBank
    ret

; TODO: Reduce the code duplication!
BackupTileIDs:
    xor a
    ld [VBK], a

    ld de, Map1Temp
.Map1
; The map will be iterated over twice, so that both tile IDs and attributes are copied.
    ld hl, Map1TempSource
    ld c, 11
.Loop1
    ld b, 20
    call SmallVRAMCopyRoutine

    add16i hl, 12
    dec c
    jr nz, .Loop1

    ld a, [VBK]
    xor a, $FF
    ld [VBK], a

    jr nz, .Map1

    ld de, Map2Temp
.Map2
; de and VBK are correctly set
    ld hl, Map2TempSource
    ld c, 18
.Loop2
    ld b, 20
    call SmallVRAMCopyRoutine

    add16i hl, 12
    dec c
    jr nz, .Loop2

    ld a, [VBK]
    xor a, $FF
    ld [VBK], a

    jr nz, .Map2
    ret

RestoreMap1:
    xor a
    ld [VBK], a

    ld hl, Map1Temp
.Map1
; The map will be iterated over twice, so that both tile IDs and attributes are copied.
    ld de, Map1TempSource
    ld c, 11
.Loop1
    ld b, 20
    call SmallVRAMCopyRoutine

    add16i de, 12
    dec c
    jr nz, .Loop1

    ld a, [VBK]
    xor a, $FF
    ld [VBK], a

    jr nz, .Map1
    ret

RestoreMap2:
    xor a
    ld [VBK], a

    ld hl, Map2Temp
.Map2
; de and VBK are correctly set
    ld de, Map2TempSource
    ld c, 18
.Loop2
    ld b, 20
    call SmallVRAMCopyRoutine

    add16i de, 12
    dec c
    jr nz, .Loop2

    ld a, [VBK]
    xor a, $FF
    ld [VBK], a

    jr nz, .Map2
    ret
