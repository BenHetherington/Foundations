INCLUDE "SubroutineMacros.inc"
INCLUDE "Strings/charmap.inc"

SECTION "Overworld Game Loop", ROM0

PrepareOverworld::
; To be called before entering the overworld game loop
; Prepares sprites, map, etc.
    call AddPlayerToScreen
    call LoadMap
    ; TODO: Load other NPCs

; Enable 16x8 sprites
    ld hl, LCDC
    set 2, [hl]

; Reset encounter flag
    xor a
    ld [CheckEncounterFlag], a

    ret


OverworldGameLoop::
; The main game loop for the overworld!
    call HandlePlayer
    call CheckEncounter

    call WaitFrame
    jr OverworldGameLoop


HandlePlayer:
    ld a, [PlayerAnimationFrame]
    or a
    jr z, .NotAnimatingPlayer

.AnimatingPlayer
    jp AnimateMovement

.NotAnimatingPlayer
    jp HandleOverworldController


HandleOverworldController:
; TODO: Need to check if a button has been pressed down (not as present, and if the button is currently pressed)
    SwitchWRAMBank BANK(PlayerAnimationFrame)

    ldh a, [ButtonsPressed]

.CheckA
    bit 0, a
    jr z, .CheckDirection

    ; The A button has been pressed
    call ShowTextBox
    ld hl, PlaceholderMessage
    call PrintString
    jp CloseTextBox


.CheckDirection
    xor a
    ld [VBK], a

    ldh a, [ButtonsHeld]
    swap a
    and a, %00001111
    dec a

    cp 10 ; No direction pressed, or impossible combination pressed
    ret nc

    cp 2 ; Impossible combination
    ret z

    cp 6 ; Impossible combination
    ret z

.CheckDiagonal
    ld [PlayerAnimationDirection], a
    ld b, a

    cp 4 ; Above 'Up'
    jr c, .NotDiagonal

    cp 7
    jr z, .NotDiagonal

.IsDiagonal
    ld a, 4
    jr .GetMoving

.NotDiagonal
    xor a
    ; fallthrough

.GetMoving
    ld [PlayerAnimationDiagonalFrameSkip], a
    ld a, b

    add a, a
    ld hl, .IncrementData
    AddTo16 hl, a

    ld a, [hl+]
    ld [PlayerMovementIncrementX], a
    ld a, [hl]
    ld [PlayerMovementIncrementY], a

    ld a, 16
    ld [PlayerAnimationFrame], a
    jp AnimateMovement ; TODO: Jump to something that'll animate the whole map too (if needed)

.IncrementData
    db  1,  0  ; Right
    db -1,  0  ; Left
    db  0,  0
    db  0, -1  ; Up
    db  1, -1  ; Right-up
    db -1, -1  ; Left-up
    db  0,  0
    db  0,  1  ; Down
    db  1,  1  ; Right-down
    db -1,  1  ; Left-down

CheckEncounter:
    ld a, [CheckEncounterFlag]
    or a
    ret z

.PerformEncounterCheck
    xor a
    ld [CheckEncounterFlag], a

    ; TODO: Allow you to move a certain number of steps without another encounter

    call Random
    cp 15 ; This controls the encounter rate!
    ret nc

.StartEncounter
; TODO: Replace this stub, and actually transition to a battle
    call ShowTextBox
    ld hl, EncounterMessage
    call PrintString

    ld hl, DidYouWinPrompt
    call PrintString

    ld hl, YesNoPrompt
    call Prompt

    push af
    call CloseTextBox
    pop af

    or a
    ret z

    ld a, 2
    call FadeSound

    call FastFadeToWhite

; Get rid of the sprites here
    MemClear OAMData, 160
    StartOAMDMA OAMData

    ld c, 20
    call WaitFrames
    JumpToOtherBank ShowGameOverScreen


PlaceholderMessage:
    db "No problem here.~\\"

EncounterMessage:
    db "An insignificant\nbug appeared!~\\"

DidYouWinPrompt:
    db "Did you win the battle?\\"


; TODO: Refactor overworld character handling to somewhere else

AddPlayerToScreen::
    call EnsureVRAMAccess
    ei

    xor a
    ld [VBK], a
    SwitchROMBank BANK(TempDownStanding)

    StartVRAMDMA TempDownStanding, $8000, 64, 0

    ld a, %10000000
    ld [OBPI], a
    MemCopyFixedDest TempPalette, OBPD, 8

    MemCopy TempOAM, OAMData, 8
    StartOAMDMA OAMData

    SwitchWRAMBank BANK(PlayerAnimationFrame)
    MemClear PlayerAnimationStateStart, (PlayerAnimationStateEnd - PlayerAnimationStateStart)

    ret


AnimateMovement::
    ; TODO: Move the map movement out of here, if necessary?
    SwitchROMBank BANK(TempDownStanding)
    SwitchWRAMBank BANK(PlayerAnimationFrame)

    ld a, [PlayerAnimationDiagonalFrameSkip]
    or a
    jr z, .MoveMap

    dec a
    ld [PlayerAnimationDiagonalFrameSkip], a
    jr nz, .MoveMap

.DiagonalFrameSkip
    ld a, 4
    ld [PlayerAnimationDiagonalFrameSkip], a
    ret

.MoveMap
    ld a, [SCY]
    ld hl, PlayerMovementIncrementY
    add a, [hl]
    ld [SCY], a

    ld a, [SCX]
    dec hl
    add a, [hl]
    ld [SCX], a

    ld hl, PlayerAnimationFrame
    dec [hl]
    jr nz, .AnimateSprite

.SetEncounterFlag
    ld a, 1
    ld [CheckEncounterFlag], a

.AnimateSprite
    ld a, [hl+]
    ld b, a
    and a, %111
    cp %100
    ret nz

    call GetNewFrame

    call ConfigurePlayerSprite
    StartOAMDMA OAMData

    call EnsureVRAMAccess
    StartVRAMDMA hl, $8000, 64, 0
    ei
    ret


ConfigurePlayerSprite:
    ; a is non-zero if the sprite should be flipped horizontally
    push hl
    or a
    jr nz, .Flipped

.NotFlipped
    ld hl, OAMData + (0 * 4) + 2
    ld a, 0
    ld [hl+], a
    res 5, [hl]

    ld hl, OAMData + (1 * 4) + 2
    ld a, 2
    ld [hl+], a
    res 5, [hl]
    pop hl
    ret

.Flipped
    ld hl, OAMData + (0 * 4) + 2
    ld a, 2
    ld [hl+], a
    set 5, [hl]

    ld hl, OAMData + (1 * 4) + 2
    ld a, 0
    ld [hl+], a
    set 5, [hl]
    pop hl
    ret


GetNewFrame:
    ld a, [hl]
    add a, a
; Loading the address in the vector table
    AddTo16 hl, .DirectionsVector

; Loading hl with the address to jump to
    ld a, [hl+]
    ld h, [hl]
    ld l, a

; Before jumping, set the 'z' flag
; Set   = show walking
; Clear = show standing
    ld a, %1000
    and a, b
    jr z, .Skip

.Walking
    ld a, 64

.Skip
; Boing!
    jp [hl]


.Right
    ld c, 1
    jr .Side

.Left
    ld c, 0
    ; fallthrough

.Side
    ld hl, TempSideStanding
    AddTo16 hl, a
    ld a, c
    ret


.Up
    ld hl, TempUpStanding
    ld b, a
    AddTo16 hl, a
    jr .UpOrDownFlip

.Down
    ld hl, TempDownStanding
    ld b, a
    AddTo16 hl, a
    ; fallthrough

.UpOrDownFlip
    ld a, b
    or a
    ret z

    ld a, [PlayerAnimationFlip]
    cpl
    ld [PlayerAnimationFlip], a
    ret


.RightUp
    ld c, 1
    jr .SideUp

.LeftUp
    ld c, 0
    ; fallthrough

.SideUp
    ld hl, TempUpSideStanding
    ld b, a
    AddTo16 hl, a
    jr .DiagonalAlternate


.RightDown
    ld c, 1
    jr .SideDown

.LeftDown
    ld c, 0
    ; fallthrough

.SideDown
    ld hl, TempDownSideStanding
    ld b, a
    AddTo16 hl, a
    ; fallthrough


.DiagonalAlternate
    ld a, b
    or a
    ret z

    ld a, [PlayerAnimationFlip]
    cpl
    ld [PlayerAnimationFlip], a

    or a
    jr z, .Finish

.UseFrameB
    ld a, 64
    AddTo16 hl, a

.Finish
    ld a, c
    ret


.DirectionsVector
    dw .Right               ; Right
    dw .Left                ; Left
    dw InvalidInstruction
    dw .Up                  ; Up
    dw .RightUp             ; Right-up
    dw .LeftUp              ; Left-up
    dw InvalidInstruction
    dw .Down                ; Down
    dw .RightDown           ; Right-down
    dw .LeftDown            ; Left-down


LoadMap::
; TODO: Rejig this so that it loads proper map data
    xor a
    ld [VBK], a
    ld [SCY], a
    ld [SCX], a

    call EnsureVRAMAccess
    StartVRAMDMA TempCaveTile, $9000, 16, 1
    ei
    call WaitForVRAMDMAToFinish

    VRAMClear $9800, $400

    ld a, 1
    ld [VBK], a

    VRAMClear $9800, $400

    ld a, %10000000
    ld [BGPI], a
    MemCopyFixedDest TempCavePalette, BGPD, 8
    ret

SECTION "Player Animation State", WRAMX
; TODO: Generalise this for all NPCs
PlayerAnimationStateStart:
PlayerAnimationFrame: db ; Is 0 if not active
PlayerAnimationDirection: db
PlayerAnimationFlip: db
PlayerAnimationDiagonalFrameSkip: db
PlayerMovementIncrementX: db
PlayerMovementIncrementY: db
PlayerAnimationStateEnd:

; TODO: Should this be in a different section?
CheckEncounterFlag: db

SECTION "Temp Player", ROMX[$6000]

; TODO: Move into a seperate binary file

TempDownStanding:
    db $07, $07, $08, $0F, $10, $1F, $11, $1F, $33, $3F, $3C, $3F, $7F, $50, $7F, $42
    db $3F, $32, $1E, $19, $3B, $37, $7E, $49, $79, $4E, $3F, $3F, $13, $1F, $0E, $0E
    db $E0, $E0, $10, $F0, $08, $F8, $88, $F8, $CC, $FC, $3C, $FC, $FE, $0A, $FE, $42
    db $FC, $4C, $78, $98, $DC, $EC, $7E, $92, $9E, $72, $FC, $FC, $C8, $F8, $70, $70

TempDownWalking:
    db $00, $00, $07, $07, $08, $0F, $10, $1F, $11, $1F, $33, $3F, $3C, $3F, $7F, $50
    db $7F, $42, $7F, $72, $7E, $59, $3F, $37, $19, $1E, $0E, $0F, $09, $0F, $07, $07
    db $00, $00, $E0, $E0, $10, $F0, $08, $F8, $88, $F8, $CC, $FC, $3C, $FC, $FE, $0A
    db $FE, $42, $FC, $4C, $7C, $9C, $F4, $FC, $F8, $48, $78, $C8, $F0, $F0, $00, $00

TempUpStanding:
    db $07, $07, $08, $0F, $10, $1F, $10, $1F, $30, $3F, $3B, $3C, $7F, $5F, $7F, $4F
    db $3F, $3F, $1B, $17, $2F, $3C, $74, $5F, $7F, $5C, $3F, $3F, $13, $1F, $0E, $0E
    db $E0, $E0, $10, $F0, $08, $F8, $08, $F8, $0C, $FC, $DC, $3C, $FE, $FA, $FE, $F2
    db $FC, $FC, $D8, $E8, $F4, $3C, $2E, $FA, $FE, $3A, $FC, $FC, $C8, $F8, $70, $70

TempUpWalking:
    db $00, $00, $07, $07, $08, $0F, $10, $1F, $10, $1F, $30, $3F, $3B, $3C, $7F, $5F
    db $7F, $4F, $7F, $7F, $7B, $57, $3F, $3C, $1C, $1F, $0F, $0C, $0B, $0F, $07, $07
    db $00, $00, $E0, $E0, $10, $F0, $08, $F8, $08, $F8, $0C, $FC, $DC, $3C, $FE, $FA
    db $FE, $F2, $FC, $FC, $D8, $F8, $FC, $24, $3C, $E4, $F8, $38, $E0, $E0, $00, $00

TempSideStanding:
    db $07, $07, $08, $0F, $10, $1F, $18, $1F, $38, $3F, $3F, $3F, $1F, $14, $1F, $14
    db $1F, $10, $0B, $0C, $07, $07, $05, $07, $03, $02, $07, $06, $09, $0F, $07, $07
    db $E0, $E0, $10, $F0, $08, $F8, $1C, $EC, $3E, $C2, $8C, $FC, $FC, $FC, $F8, $98
    db $F0, $10, $F0, $70, $F8, $C8, $C8, $F8, $F8, $48, $F0, $70, $A0, $E0, $C0, $C0

TempSideWalking:
    db $00, $00, $07, $07, $08, $0F, $10, $1F, $18, $1F, $38, $3F, $3F, $3F, $1F, $14
    db $1F, $14, $1F, $10, $0B, $0C, $07, $07, $1C, $1F, $27, $3E, $13, $1F, $0E, $0E
    db $00, $00, $E0, $E0, $10, $F0, $08, $F8, $1C, $EC, $3E, $C2, $8C, $FC, $FC, $FC
    db $F8, $98, $F0, $10, $F0, $70, $78, $E8, $F8, $98, $F4, $9C, $64, $FC, $18, $18

TempDownSideStanding:
    db $07, $07, $08, $0F, $10, $1F, $11, $1F, $33, $3F, $3C, $3F, $7F, $50, $7F, $42
    db $3F, $32, $1E, $19, $3B, $37, $7E, $49, $79, $4E, $3F, $3F, $13, $1F, $0E, $0E
    db $E0, $E0, $10, $F0, $08, $F8, $88, $F8, $CC, $FC, $3C, $FC, $FE, $0A, $FE, $42
    db $FC, $4C, $78, $98, $DC, $EC, $7E, $92, $9E, $72, $FC, $FC, $C8, $F8, $70, $70

TempDownSideWalkingA:
    db $00, $00, $07, $07, $08, $0F, $10, $1F, $11, $1F, $33, $3F, $3C, $3F, $7F, $50
    db $7F, $42, $7F, $72, $7E, $59, $3F, $37, $19, $1E, $0E, $0F, $09, $0F, $07, $07
    db $00, $00, $E0, $E0, $10, $F0, $08, $F8, $88, $F8, $CC, $FC, $3C, $FC, $FE, $0A
    db $FE, $42, $FC, $4C, $7C, $9C, $F4, $FC, $F8, $48, $78, $C8, $F0, $F0, $00, $00

TempDownSideWalkingB:
    db $00, $00, $07, $07, $08, $0F, $10, $1F, $11, $1F, $33, $3F, $3C, $3F, $7F, $50
    db $7F, $42, $7F, $72, $7E, $59, $3F, $37, $19, $1E, $0E, $0F, $09, $0F, $07, $07
    db $00, $00, $E0, $E0, $10, $F0, $08, $F8, $88, $F8, $CC, $FC, $3C, $FC, $FE, $0A
    db $FE, $42, $FC, $4C, $7C, $9C, $F4, $FC, $F8, $48, $78, $C8, $F0, $F0, $00, $00

TempUpSideStanding:
    db $07, $07, $08, $0F, $10, $1F, $10, $1F, $30, $3F, $3B, $3C, $7F, $5F, $7F, $4F
    db $3F, $3F, $1B, $17, $2F, $3C, $74, $5F, $7F, $5C, $3F, $3F, $13, $1F, $0E, $0E
    db $E0, $E0, $10, $F0, $08, $F8, $08, $F8, $0C, $FC, $DC, $3C, $FE, $FA, $FE, $F2
    db $FC, $FC, $D8, $E8, $F4, $3C, $2E, $FA, $FE, $3A, $FC, $FC, $C8, $F8, $70, $70

TempUpSideWalkingA:
    db $00, $00, $07, $07, $08, $0F, $10, $1F, $10, $1F, $30, $3F, $3B, $3C, $7F, $5F
    db $7F, $4F, $7F, $7F, $7B, $57, $3F, $3C, $1C, $1F, $0F, $0C, $0B, $0F, $07, $07
    db $00, $00, $E0, $E0, $10, $F0, $08, $F8, $08, $F8, $0C, $FC, $DC, $3C, $FE, $FA
    db $FE, $F2, $FC, $FC, $D8, $F8, $FC, $24, $3C, $E4, $F8, $38, $E0, $E0, $00, $00

TempUpSideWalkingB:
    db $00, $00, $07, $07, $08, $0F, $10, $1F, $10, $1F, $30, $3F, $3B, $3C, $7F, $5F
    db $7F, $4F, $7F, $7F, $7B, $57, $3F, $3C, $1C, $1F, $0F, $0C, $0B, $0F, $07, $07
    db $00, $00, $E0, $E0, $10, $F0, $08, $F8, $08, $F8, $0C, $FC, $DC, $3C, $FE, $FA
    db $FE, $F2, $FC, $FC, $D8, $F8, $FC, $24, $3C, $E4, $F8, $38, $E0, $E0, $00, $00

    
TempCaveTile:
    db $00, $00, $10, $00, $01, $02, $00, $00, $04, $84, $00, $00, $42, $40, $00, $00


TempPalette:
    db $FF, $7F, $7F, $2A, $FF, $04, $00, $00

TempCavePalette:
    db $45, $00, $AA, $00, $88, $00, $44, $00

TempOAM:
    db 80, 80, 0, $00
    db 80, 88, 2, $00
