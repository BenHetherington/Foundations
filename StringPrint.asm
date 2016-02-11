SECTION "Text Box Variables", WRAMX
; Current position, for knowing where to put the next character.
TextTilesPointer: dw         ; The address of the tile to start at.
                             ; Stored big-endian (just because)
TextSubtilesPositionX: db    ; The number of pixels across within a tile.
TextSubtilesPositionY: db    ; The number of pixels down within a tile.
TextTilesPositionY: db       ; The number of tiles down.
TextTilesWorkSpace: ds 8 * 4 ; Work space for creating the tiles.
                             ; Could instead use more general-purpose work space.
TextColour: db               ; The current text colour.
PrintSettings: db            ; 0000 0bss: - ss = 00 for normal, 01 for faster, 11 for fastest.
                             ;            - b = 0 for beeps, 1 for no beeps (SFX)
                             ; Remaining bits are yet to be decided (but are currently unused)

SpecialCharactersLimit EQU $E0

SECTION "Blank Tile Data", ROMX[$7000]
BlankTiles:
REPT $5B0
    db $00
ENDR

SECTION "Text Boxes", ROM0
CharacterTiles
    db $00,$00,$00,$00,$00,$00,$00,$00 ; 00) space/tab/null
    db $78,$84,$84,$FC,$84,$84,$84,$00 ; 01) A
    db $F8,$84,$84,$F8,$84,$84,$F8,$00 ; 02) B
    db $3C,$40,$80,$80,$80,$40,$3C,$00 ; 03) C
    db $F0,$88,$84,$84,$84,$88,$F0,$00 ; 04) D
    db $FC,$80,$80,$FC,$80,$80,$FC,$00 ; 05) E
    db $FC,$80,$80,$FC,$80,$80,$80,$00 ; 06) F
    db $3C,$40,$80,$9C,$84,$44,$3C,$00 ; 07) G
    db $84,$84,$84,$FC,$84,$84,$84,$00 ; 08) H
    db $F8,$20,$20,$20,$20,$20,$F8,$00 ; 09) I
    db $FC,$10,$10,$10,$10,$90,$60,$00 ; 0A) J
    db $88,$90,$A0,$C0,$A0,$90,$88,$00 ; 0B) K
    db $80,$80,$80,$80,$80,$80,$F8,$00 ; 0C) L
    db $82,$C6,$AA,$92,$82,$82,$82,$00 ; 0D) M
    db $88,$C8,$A8,$98,$88,$88,$88,$00 ; 0E) N
    db $38,$44,$82,$82,$82,$44,$38,$00 ; 0F) O
    db $F8,$84,$84,$F8,$80,$80,$80,$00 ; 10) P
    db $38,$44,$82,$92,$8A,$44,$3A,$00 ; 11) Q
    db $F8,$84,$84,$F8,$90,$88,$84,$00 ; 12) R
    db $7C,$80,$80,$78,$04,$04,$F8,$00 ; 13) S
    db $FE,$10,$10,$10,$10,$10,$10,$00 ; 14) T
    db $84,$84,$84,$84,$84,$84,$78,$00 ; 15) U
    db $82,$82,$44,$44,$28,$28,$10,$00 ; 16) V
    db $82,$82,$82,$92,$AA,$C6,$82,$00 ; 17) W
    db $88,$88,$50,$20,$50,$88,$88,$00 ; 18) X
    db $82,$44,$28,$10,$10,$10,$10,$00 ; 19) Y
    db $F8,$08,$10,$20,$40,$80,$F8,$00 ; 1A) Z
    db $70,$88,$88,$88,$88,$88,$70,$00 ; 1B) 0
    db $20,$60,$20,$20,$20,$20,$F8,$00 ; 1C) 1
    db $70,$88,$08,$10,$20,$40,$F8,$00 ; 1D) 2
    db $70,$88,$08,$70,$08,$88,$70,$00 ; 1E) 3
    db $10,$30,$50,$90,$F8,$10,$10,$00 ; 1F) 4
    db $F8,$80,$80,$F0,$08,$08,$F0,$00 ; 20) 5
    db $30,$40,$80,$F0,$88,$88,$70,$00 ; 21) 6
    db $F8,$08,$08,$10,$10,$20,$20,$00 ; 22) 7
    db $70,$88,$88,$70,$88,$88,$70,$00 ; 23) 8
    db $70,$88,$88,$78,$08,$08,$70,$00 ; 24) 9
    db $00,$70,$08,$78,$88,$88,$78,$00 ; 25) a
    db $80,$80,$80,$F8,$84,$84,$F8,$00 ; 26) b
    db $00,$00,$78,$80,$80,$80,$78,$00 ; 27) c
    db $04,$04,$04,$7C,$84,$84,$7C,$00 ; 28) d
    db $00,$00,$70,$88,$F8,$80,$78,$00 ; 29) e
    db $1C,$20,$F8,$20,$20,$20,$20,$00 ; 2A) f
    db $00,$00,$70,$88,$88,$88,$78,$08 ; 2B) g
    db $80,$80,$80,$F0,$88,$88,$88,$00 ; 2C) h
    db $00,$80,$00,$80,$80,$80,$80,$00 ; 2D) i
    db $00,$20,$00,$20,$20,$20,$20,$C0 ; 2E) j
    db $80,$80,$90,$A0,$C0,$A0,$90,$00 ; 2F) k
    db $80,$80,$80,$80,$80,$80,$60,$00 ; 30) l
    db $00,$00,$AC,$D2,$92,$92,$92,$00 ; 31) m
    db $00,$00,$B0,$C8,$88,$88,$88,$00 ; 32) n
    db $00,$00,$70,$88,$88,$88,$70,$00 ; 33) o
    db $00,$00,$F0,$88,$88,$88,$F0,$80 ; 34) p
    db $00,$00,$78,$88,$88,$88,$78,$0A ; 35) q
    db $00,$00,$B8,$C0,$80,$80,$80,$00 ; 36) r
    db $00,$00,$78,$80,$70,$08,$F0,$00 ; 37) s
    db $20,$20,$F8,$20,$20,$20,$18,$00 ; 38) t
    db $00,$00,$88,$88,$88,$88,$70,$00 ; 39) u
    db $00,$00,$88,$88,$50,$50,$20,$00 ; 3A) v
    db $00,$00,$88,$88,$A8,$A8,$50,$00 ; 3B) w
    db $00,$00,$88,$50,$20,$50,$88,$00 ; 3C) x
    db $00,$00,$88,$88,$88,$88,$78,$08 ; 3D) y
    db $00,$00,$F8,$10,$20,$40,$F8,$00 ; 3E) z
    db $00,$00,$00,$00,$00,$00,$80,$00 ; 3F) .
    db $00,$00,$00,$00,$00,$40,$40,$80 ; 40) ,
    db $40,$40,$80,$00,$00,$00,$00,$00 ; 41) '
    db $48,$90,$D8,$00,$00,$00,$00,$00 ; 42) “
    db $D8,$48,$90,$00,$00,$00,$00,$00 ; 43) ”
    db $00,$00,$80,$00,$00,$80,$00,$00 ; 44) :
    db $00,$00,$40,$00,$00,$40,$40,$80 ; 45) ;
    db $80,$80,$80,$80,$80,$00,$80,$00 ; 46) !
    db $40,$80,$80,$80,$80,$80,$40,$00 ; 47) (
    db $80,$40,$40,$40,$40,$40,$80,$00 ; 48) )
    db $F0,$08,$08,$30,$20,$00,$20,$00 ; 49) ?
    db $20,$20,$20,$40,$40,$80,$80,$00 ; 4A) /
    db $A8,$70,$F8,$70,$A8,$00,$00,$00 ; 4B) *
    db $00,$20,$20,$F8,$20,$20,$00,$00 ; 4C) +
    db $00,$00,$00,$F8,$00,$00,$00,$00 ; 4D) -
    db $00,$00,$F8,$00,$F8,$00,$00,$00 ; 4E) =
    db $00,$00,$00,$00,$00,$00,$FE,$00 ; 4F) _
    db $30,$48,$48,$B0,$94,$88,$74,$00 ; 50) &
    db $38,$44,$40,$F0,$40,$40,$FC,$00 ; 51) £
    db $38,$6C,$D6,$C6,$D6,$54,$38,$00 ; 52) (A)
    db $38,$4C,$D6,$CE,$D6,$4C,$38,$00 ; 53) (B)
    db $00,$30,$30,$FC,$FC,$30,$30,$00 ; 54) D-Pad
    db $00,$00,$10,$38,$7C,$FE,$00,$00 ; 55) ⬆︎
    db $00,$00,$FE,$7C,$38,$10,$00,$00 ; 56) ⬇︎
    db $10,$30,$70,$F0,$70,$30,$10,$00 ; 57) ⬅︎
    db $80,$C0,$E0,$F0,$E0,$C0,$80,$00 ; 58) ➡︎
    db $08,$70,$00,$00,$00,$00,$00,$00 ; 59) g (lower)
    db $80,$80,$00,$00,$00,$00,$00,$00 ; 5A) p (lower)
    db $0C,$08,$00,$00,$00,$00,$00,$00 ; 5B) q (lower)
    db $00,$00,$00,$00,$00,$F8,$70,$20 ; 5C) next text prompt arrow
    db $7E,$A5,$E5,$85,$85,$FD,$81,$7E ; 5D) save anim f0
    db $7E,$93,$93,$F3,$83,$83,$FF,$7E ; 5E) save anim f1
    db $7E,$C9,$89,$89,$F9,$81,$81,$7E ; 5F) save anim f2
    db $7E,$81,$A1,$89,$81,$C1,$81,$7E ; 60) link anim f0
    db $7E,$91,$81,$95,$A1,$81,$81,$7E ; 61) link anim f1
    db $7E,$81,$81,$93,$89,$81,$91,$7E ; 62) link anim f2
    db $7E,$81,$89,$C1,$81,$A5,$81,$7E ; 63) link anim f3
    db $7E,$81,$81,$A5,$91,$81,$83,$7E ; 64) link anim f4
    db $7E,$C1,$81,$91,$83,$81,$81,$7E ; 65) link anim f5


LetterWidths
; Could be compressed or moved into another bank, but not as essential as for the tiles.
; Currently uses 91 bytes. Combine into pairs of nibbles to use 46 bytes instead.
    db 6, 6, 6, 6, 6, 6, 6, 6, 5, 6, 5, 5, 7, 5, 7, 6, 7, 6, 6, 7, 6, 7, 7, 5, 7, 5
    ;  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z

    db 5, 5, 5, 5, 5, 5, 5, 5, 5, 5
    ;  0  1  2  3  4  5  6  7  8  9

    db 5, 6, 5, 6, 5, 6, 5, 5, 1, 3, 4, 3, 7, 5, 5, 5, 7, 5, 5, 5, 5, 5, 5, 5, 5, 5
    ;  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z

    db 1, 2, 2, 5, 5, 1, 2, 1, 2, 2, 5, 3, 5, 5, 5, 5, 7, 6, 6, 7, 7, 6, 7, 7, 4, 4
    ;  .  ,  '  “  ”  :  ;  !  (  )  ?  /  +  -  *  =  _  &  £  (A)(B) +D ⬆︎ ⬇︎ ⬅︎ ➡︎

; Colour Definitions
WhiteColour EQUS "$FF, $7F"
RedColour   EQUS "$1F, $00"
BlueColour  EQUS "$00, $FF"
GreenColour EQUS "$E0, $03"

ShowTextBox:
    SwitchWRAMBank BANK(TextTilesPointer)
    xor a
    ld [PrintSettings], a
    call EnsureVBlank

.SetUpWindow
    ld a, [LCDC]
    set 6, a ; Set tiles for the window
             ; Perhaps shouldn't be necessary if this is set once at the start
    set 5, a ; Enables window
    ld [LCDC], a

.SetInitialWindowPosition
    ld a, 144
    ld [WY], a
    ld a, 7
    ld [WX], a

.SetPalettes
    call SetDefaultTextColours
    call EnsureVBlank

.SetMapAttributes
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
    xor a
    ld [VBK], a ; Use VRAM Bank 0

    ld hl, $9C00 + $21
    inc a
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
    jr .AnimationLoop

.AnimationSoundFX
; TODO: Eliminate this in favour of a much better sound engine
;and 2
;jr z, .AnimationLoop
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

.AnimationLoop
; Move the window up by 4px every frame, until it's 48px tall.
    call WaitFrame
    ld a, [WY]
    sub a, 4
    ld [WY], a
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

CloseTextBox:
    ld de, ClosingSound

.AnimationLoop
; Move the window down by 4px every frame, until it's off-screen.
    call WaitFrame
    ld a, [WY]
    add a, 4
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

PlayTextBeep
    ld a, %10000000 | $3B
    ld [NR11], a

    ld a, $31
    ld [NR12], a

    ld a, %10001000
    ld [NR13], a

    ld a, %11000110
    ld [NR14], a

    ret

ClearTextBox:
; Clears all of the text box tiles.
    StartVRAMDMA BlankTiles, $8000, $5B0, 1
    WaitForVRAMDMAToFinish

SetPrintVariables:
; Sets up the default variables for string printing.
    SwitchWRAMBank BANK(TextTilesPointer)

    xor a
    ld [TextSubtilesPositionX], a
    ld [TextSubtilesPositionY], a
    ld [TextTilesPositionY], a

    ld a, $80
    ld [TextTilesPointer], a
    ld a, $10
    ld [TextTilesPointer + 1], a

    ld a, $03
    ld [TextColour], a

    ret

PrintString:
; NOTE: Must aim to keep this function compatible with the original GB, except when
; GBC-specific characters are included. This is because this proceedure is also used
; for the Incompatible GB screen.

; Assumes that the pointer to the string to print is in hl
    SwitchWRAMBank BANK(TextTilesPointer)
    ld a, [hl+]
.EndOfStringCheck
    and a ; "\\"
    ret z

    cp SpecialCharactersLimit
    jr nc, ProcessSpecialCharacter

.Print
    push af
    push hl
    call PutChar
    ld a, [PrintSettings]
    bit 2, a
    jr nz, .WaitFrame
    call PlayTextBeep ; TODO: Replace with proper call to sound engine

.WaitFrame
    ld a, [PrintSettings]
    bit 0, a
    jr nz, .Finish
    call WaitFrame

    ;ld a, [PrintSettings]
    ;bit 1, a
    ;jr nz, .Finish
    ;call WaitFrame

.Finish
    pop hl
    pop af
    jr PrintString


ProcessSpecialCharacter
; Deals with the special characters
; TODO: Add "_EXEC_"
.WaitCheck
    cp "~"
    jr nz, .NewlineCheck
.Wait
    call Wait
    jr PrintString

.NewlineCheck
    cp "\n"
    jr nz, .TabCheck
.Newline
    call MoveToNextLine
    jr PrintString

.TabCheck
    cp "\t"
    jr nz, .PauseCheck
.Tab
    ld b, 8
    call AdvanceTextPosition
    jr PrintString

.PauseCheck
    cp "`"
    jr nz, .LongPauseCheck
.Pause
    ld c, 2
    call WaitFrames
    jr PrintString

.LongPauseCheck
    cp "_`_"
    jr nz, .PixelAdvanceCheck
.LongPause
    ld a, [hl+]
    ld c, a
    call WaitFrames
    jr PrintString

.PixelAdvanceCheck
    cp "^"
    jr nz, .SpaceCheck
.PixelAdvance
    ld b, 1
    call AdvanceTextPosition
    jr PrintString

.SpaceCheck
    cp " "
    jr nz, .Palette0Check
.Space
    ld b, 4
    call AdvanceTextPosition
    ld a, [PrintSettings]
    bit 1, a
    jr PrintString
    call WaitFrame
    jp PrintString

.Palette0Check
    cp "_#0_"
    jp nz, .Palette1Check
.Palette0
    xor a
    ld [TextColour], a
    jp PrintString

.Palette1Check
    cp "_#1_"
    jr nz, .Palette2Check
.Palette1
    ld a, $01
    ld [TextColour], a
    jp PrintString

.Palette2Check
    cp "_#2_"
    jr nz, .Palette3Check
.Palette2
    ld a, $02
    ld [TextColour], a
    jp PrintString

.Palette3Check
    cp "_#3_"
    jr nz, .SetPaletteCheck
.Palette3
    ld a, $03
    ld [TextColour], a
    jp PrintString

.SetPaletteCheck
    cp "_@_"
    jr nz, .SetSettingsCheck
.SetPalette
    ld a, [hl+]
    sla a
    add a, (8 * 7) + %10000000
    ld [BGPI], a
    ld a, [hl+]
    ld [BGPD], a
    ld a, [hl+]
    ld [BGPD], a
    jp PrintString

.SetSettingsCheck
    cp "§"
    jp nz, PrintString ; Ignore invalid character
.SetSettings
    ld a, [hl+]
    ld [PrintSettings], a
    jp PrintString


Wait
; Waits for the player to press the A or B button
    push hl
    ld a, 5
    ld [TempAnimWait], a
    xor a
    ld [TempAnimFrame], a

.Loop
    call WaitFrame

    ld a, %00010000 ; Select buttons
    ld [JOYP], a

.CheckA
    ld a, [JOYP]
    bit 0, a ; Check the A button (0 = pressed)
    jr z, .Continue

.CheckB
    bit 1, a ; Check the B button
    jr nz, .Loop

.Continue
    xor a
    ld [TempAnimWait], a

    call FastFadeText
    call ClearTextBox
    call SetDefaultTextColours
    pop hl
    ret


PutChar:
; Assumes that the character to put is in a
; Does not handle special values (e.g. for spaces)
    push af
    call PrepareChar

; Source in bc
; Destination in hl
; Current tile in a
; Counter in d
; e has the colouration
    ld a, 1
    ld [VBK], a ; Putting the tiles in bank 2

    ld bc, TextTilesWorkSpace
    ld a, [TextTilesPointer]
    ld h, a
    ld a, [TextTilesPointer + 1]
    ld l, a

    ld e, 2 ; Some sort of counter
    ld d, 2 * 8
    push de

    ld a, [TextColour]
    ld e, a
.TileCopyLoop
    ld a, [bc]
    and a              ; Checks to see if there's actually any
    jr nz, .BeginCopy  ; data for this line that needs copying.

.NoNeedToCopy
    inc hl
    inc hl
    jr .Continue

.BeginCopy
    push bc
; Now, the tile is in bc
    call Convert1BitTileLine

; OR-ing new tile with old tile

.CheckFirstByte
    bit 0, e               ; If bit 0 of the colour is zero, there
    jr z, .CheckSecondByte ; won't be any data to copy in the first byte.

.FirstByte
    call EnsureVBlank
    ld a, [hl]
    or b
    ld [hl], a

.CheckSecondByte
    inc hl
    bit 1, e          ; If bit 1 of the colour is zero, there
    jr z, .FinishCopy ; won't be any data to copy in the second byte.

.SecondByte
    call EnsureVBlank
    ld a, [hl]
    or c
    ld [hl], a

.FinishCopy
    inc hl
    pop bc

.Continue
    inc bc
    dec d
    jr nz, .TileCopyLoop

    pop de ; Getting the counter for e
    dec e
    jr z, .UpdateTextPositions
    push de

    ld bc, $100
    add hl, bc ; Updating the tiles below.
    ld bc, TextTilesWorkSpace + (2 * 8)

    ld a, [TextColour]
    ld e, a
    jr .TileCopyLoop

.UpdateTextPositions
    pop af
    jp UpdateTextPositions


CopyChar:
; Copies a character tile into the tiles workspace memory.
; Assumes that the character to put is in a
.TileCopy
    push af
    ld de, TextTilesWorkSpace
    call .TileCopyFunction

.ZeroWorkSpace
    xor a
    ld b, 8 * 3 ; Since we've already filled some of the work space
    ld h, d     ; Relies on .TileCopyFunction having the next address to write
    ld l, e     ; to (TextTilesWorkSpace + (2 * 8)) in the de register. This is done for efficiency.
.ZeroWorkSpaceLoop
    ld [hl+], a
    dec b
    jp nz, .ZeroWorkSpaceLoop


.AddDanglers
; Adds the dangler, if the character needs one.
    pop af
.gCheck
    cp "g"
    jr nz, .pCheck
    ld a, "‡g‡"
    ld de, TextTilesWorkSpace + (2 * 8)
    jr .TileCopyFunction

.pCheck
    cp "p"
    jr nz, .qCheck
    ld a, "‡p‡"
    ld de, TextTilesWorkSpace + (2 * 8)
    jr .TileCopyFunction
    ret

.qCheck
    cp "q"
    jr nz, .yCheck
    ld a, "‡q‡"
    ld de, TextTilesWorkSpace + (2 * 8)
    jr .TileCopyFunction
    ret

.yCheck
    cp "y"
    ret nz
    ld a, "‡g‡"
    ld de, TextTilesWorkSpace + (2 * 8)
    jr .TileCopyFunction
    ret


.TileCopyFunction
    ld c, a
    ld b, 0
    sla16 bc, 3
    ld hl, CharacterTiles
    add hl, bc
    ld b, 8
.TileCopyLoop
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .TileCopyLoop
    ret


PrepareChar:
; Copies and shifts a character, ready for printing.
; Assumes that the character to put is in a
; Does not handle special values.
; A more general function, allowing you to manually copy the work space data elsewhere
    call CopyChar

    ld a, [TextSubtilesPositionX]
    or a
    jr z, .DownShift

.RightShift
    ld hl, TextTilesWorkSpace
    ld b, 2 ; Outer counter
    ld c, a
    push bc
    ld b, 8 ; Inner counter

.RightShiftNewLine
    ld a, [hl+]
    ld d, a
REPT 7
    inc hl
ENDR
    ld a, [hl]
    ld e, a

.RightShiftLoop
    srl16 de, 1
    dec c
    jr nz, .RightShiftLoop

    ld a, e
    ld [hl-], a
REPT 7
    dec hl
ENDR
    ld a, d
    ld [hl+], a

    ld a, [TextSubtilesPositionX]
    ld c, a
    dec b
    jr nz, .RightShiftNewLine

    pop bc
    dec b
    jr z, .DownShift
    push bc
    ld b, 8
    ld hl, TextTilesWorkSpace + (2 * 8)
    jr .RightShiftNewLine

.DownShift
    ld a, [TextSubtilesPositionY]
    and %00000111
    ret z

; bc is the difference in address between the top and bottom tile
; hl contains the current address (for the top tile)
; d is the current line

; Starts with the bottom-right tile, then goes to the bottom-left tile,
; then goes to the top-right and top-left tiles.
    ld hl, TextTilesWorkSpace + $1B
    ld bc, $4
    ld d, $18
.DownShiftLoop
    ld a, [hl]
    push bc
    add hl, bc
    ld [hl-], a

; subtracting bc from hl
    ld a, b
    cpl
    ld b, a

    ld a, c
    cpl
    ld c, a

    inc bc
    add hl, bc
    pop bc

    dec d
    jr z, .RemoveDebris
    ld a, d

    cp $18 - $4
    jr z, .StartBottomLeftTile
    jr nc, .DownShiftLoop

    cp $18 - $8
    jr nc, .DownShiftLoop

    dec a
    and %100
    jr nz, .StartTopToBottomTileOverflow
    jr .StopTopToBottomTileOverflow

.StartBottomLeftTile
    ld hl, TextTilesWorkSpace + $13
    jr .DownShiftLoop

.StartTopToBottomTileOverflow
    ld bc, $C
    jr .DownShiftLoop

.StopTopToBottomTileOverflow
    ld bc, $4
    jr .DownShiftLoop

.RemoveDebris
    xor a
    ld d, 4
    ld e, 2
    ld hl, TextTilesWorkSpace
.RemoveDebrisLoop
    ld [hl+], a
    dec d
    jr nz, .RemoveDebrisLoop

    dec e
    ret z
    ld d, 4
    ld hl, TextTilesWorkSpace + $8
    jr .RemoveDebrisLoop

Convert1BitTileLine
; Assumes that the 1-bit tile line to convert is in a
; Assumes that the desired colouration filter is in e (0, 1, 2, or 3)
; Outputs the resultant tile line into bc

.CopyToBC
    ld b, a
    ld c, a

.FilterB
    xor a
    bit 0, e
    jr nz, .FilterC
    ld b, a
.FilterC
    bit 1, e
    ret nz
    ld c, a
    ret

UpdateTextPositions:
; Assumes that the character put is in a
    ld hl, LetterWidths - 1 ; LetterWidths does not include the string terminator
    ld b, 0
    ld c, a
    add hl, bc
    ld b, [hl]
    inc b
    jr AdvanceTextPosition


AdvanceTextPosition:
; Assume that b contains the number to advance by.
    ld a, [TextSubtilesPositionX]
    add a, b
    ld [TextSubtilesPositionX], a

    ld d, a
    ld a, 8
    sub a, d
    ret nc

.OverflowIntoNewTile
    cpl
    inc a
    ld [TextSubtilesPositionX], a

    ld a, [TextTilesPointer + 1]
    add a, $10
    ld [TextTilesPointer + 1], a

    ret nc

    ld a, [TextTilesPointer]
    inc a
    ld [TextTilesPointer], a

    ret

MoveToNextLine:
    xor a
    ld [TextSubtilesPositionX], a
    ld a, [TextTilesPositionY]
    inc a
    ld [TextTilesPositionY], a
    cp 1
    jr z, .MoveToLine2
    cp 2
    jr z, .MoveToLine3
    jr .IncorrectLine

.MoveToLine2
    ld a, $81
    ld [TextTilesPointer], a
    ld a, $30
    ld [TextTilesPointer + 1], a
    ld a, 4
    ld [TextSubtilesPositionY], a
    ret

.MoveToLine3
    ld a, $83
    ld [TextTilesPointer], a
    ld a, $70
    ld [TextTilesPointer + 1], a
    xor a
    ld [TextSubtilesPositionY], a
    ret

.IncorrectLine
    ld b, b ; Breakpoint
    dec a
    ld [TextTilesPositionY], a
    jr .MoveToLine3


ReplaceLastTile:
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
    ld hl, $8480
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

FastFadeText:
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

SetDefaultTextColours:
; TODO: Put the correct colours here.
    ld a, (8 * 7) | %10000000
    ld [BGPI], a
    ld c, 2
    ld d, 2
    ld b, 0
.PaletteLoop
    call EnsureVBlank
    ld a, b
    ld [BGPD], a
    dec c
    jr nz, .PaletteLoop

    ld c, 6
    ld b, $FF
    dec d
    jr nz, .PaletteLoop
    ret
