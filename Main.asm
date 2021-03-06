; Libraries
INCLUDE "lib/16-bitMacros.inc"
INCLUDE "lib/Shift.inc"
INCLUDE "SubroutineMacros.inc"
;INCLUDE "Hardware.inc"
INCLUDE "Strings/StringMacros.inc"

INCLUDE "Strings/charmap.inc"

SECTION "Quick-access Variables", HRAM
VBlankOccurred:: db
ResetDisallowed:: db
PlayingOnGBA:: db
ButtonsPressed:: db
ButtonsHeld:: db

GradientData:: ds 2 * 18

SECTION "General Variables", WRAM0
TempAnimFrame:: db
TempAnimWait:: db

SECTION "OAM Data", WRAM0, ALIGN[8]
OAMData:: ds 160

StackSize EQU $80

SECTION "Stack Space", WRAM0[$D000 - StackSize]
StackSpace: ds StackSize
StackEnd:

SECTION "Start",HOME[$0150]
Start::
; ld c, a already executed
    JumpToOtherBank Setup


SECTION "Setup", ROMX
Setup:
; b contains the GBA status bit
; c contains the GBC status byte
    di
    ld a, c
    cp $11
    jp nz, .OriginalGameBoy

.GBACheck
    xor a
    bit 0, b
    jr z, .WriteGBAByte

.IsPlayingOnGBA
    inc a

.WriteGBAByte
    ldh [PlayingOnGBA], a
    jr GameStartup

.OriginalGameBoy
    JumpToOtherBank IncompatibleGB

GameStartup::
; This is the point where the game returns to on reset
    ld a, 1
    ldh [ResetDisallowed], a

; Set up stack
    ld sp, StackEnd - 1

; Ensure double speed mode
    call EnableDoubleSpeed

; Temporarily disable interrupts
    xor a
    ld [IE], a

    call ResetInterruptHandlers
    call InitSoundEngine

; Set up the OAM DMA Subroutine
    MemCopy DMAWaitInROM, OAMDMAWait, 8

; Switch off the display, reset the maps and sprites, and switch it back on
    call EnsureVBlank
    xor a
    ld [LCDC], a

    xor a
    ld [VBK], a
    VRAMClear $8000, $800

    ld a, 1
    ld [VBK], a
    VRAMClear $8000, $800

    MemClear OAMData, 160
    StartOAMDMA OAMData

    ld a, %10000001
    ld [LCDC], a

; Start the temporary animation frame counter
    xor a
    ld [TempAnimWait], a
    ei

; Set up the button variables
    xor a
    ldh [ButtonsPressed], a
    ldh [ButtonsHeld], a

; Enable the correct interrupts
    ld a, %00000101 ; Timer, [No LYC (LCD STAT)], V-Blank
    ld [IE], a      ; TODO: Add serial to this to add link capablilities?

.WaitUntilResetDone
    call WaitFrame ; Wait until the reset keys have been released
    ldh a, [ButtonsHeld]
    cp %00001111
    jr z, .WaitUntilResetDone

    xor a
    ldh [ResetDisallowed], a

.SRAMTest
    call EnableSRAM

    ld hl, $A000
    ld c, [hl]

    xor a
    ld [hl], a

    ld b, [hl]

    ld [hl], c

    call DisableSRAM

    ld a, b
    or a
    jp nz, SRAMBroken

.MainBit
    ; ld b, b
    ; ld a, 1
    ; ld d, a
    ; call PlaySample

    ; ld c, 60
    ; call WaitFrames

    CallToOtherBank ShowBen10doScreen

    ld hl, LCDC
    res 4, [hl]

    MemClear OAMData, 160


ATextBasedAdventure::
    ld a, 3
    call PlayMusic

    ; TODO: Remove
    call ShowTextBox
    ld hl, SomeKindaPrompt
    call PrintString
    ld hl, YesNoPrompt
    call Prompt
    push af
    call CloseTextBox
    pop af
    or a
    jr nz, .Text

.Overworld
    call PrepareOverworld
    jp OverworldGameLoop

.Text
    call ShowTextBox
    ld hl, AssemblyString
    call PrintString

    ld hl, KeyboardTest
    call PrintString
    call ShowKeyboard

    call FastFadeText
    call ClearTextBox
    call SetDefaultTextColours
    
    ld hl, DemoStringOne
    call PrintString
    call CloseTextBox

    ld c, 240
    call WaitFrames

    call ShowTextBox
    ld hl, DemoStringTwo
    call PrintString

    call FastFadeText
    call ClearTextBox
    call SetDefaultTextColours

    ld hl, EraseSaveDataConfirmation
    call PrintString
    ld hl, NoYesPrompt
    call Prompt
    or a
    jr z, .SkipSave

    ld hl, SavingString
    call PrintString

    jr .StartSave

.PromptLoop
    ld b, NextTextPromptArrow
    call ReplaceLastTile

    ld c, 15
    call WaitFrames

    ld b, $00
    call ReplaceLastTile

    ld c, 15
    call WaitFrames

    jr .PromptLoop

.StartSave
    ld a, 5
    ld [TempAnimWait], a
    xor a
    ld [TempAnimFrame], a

    call WipeSaveData

    xor a
    ld [TempAnimWait], a

    ld b, a
    call ReplaceLastTile

.SkipSave
    call CloseTextBox

    call FastFadeToBlack

    ; TODO: Must include a suitable seed in a
    ld a, [$DD9B] ; This is very temporary
    call SeedRNG

    call Random
    bit 0, a

    ;call VerifyChecksum
    ;or a
    jr nz, .AttemptingAnRPGTextBox

.AttemptingAQuicksaveBlackout
    ld c, 15
    call WaitFrames

    call ShowTextBox
    ld hl, FakeQuicksaveText
    call PrintString
    call PromptTextFadeIn ; TODO: Fade this to red, not blue
    jr FillerHalt

.AttemptingAnRPGTextBox
    ld c, 15
    call WaitFrames

    call FastFadeToWhite
    call ShowTextBox

    ld hl, WhatNow
    call PrintString

    ld hl, BattleScreenPrompt
    call Prompt
    jr FillerHalt

;    SwitchSpeed
    ;ld hl, FakeRPGText
    ld hl, FileOptionsTest
    call PrintString
;    SwitchSpeed
    ; call PromptTextFadeIn

SRAMBroken:
    ld a, 1
    ldh [ResetDisallowed], a

    ld hl, LCDC
    res 4, [hl]

    call ShowTextBox
    ld hl, FoolishFools
    call PrintString
    ; fallthrough

FillerHalt
    halt
    jr FillerHalt

WipeSaveData:
    ld a, $01
    ld [VBK], a

    call EnableSRAM

    ld b, 15 ; Number of banks
.OuterSaveLoop
    SwitchSRAMBank b
    ld hl, $A000
.InnerSaveLoop
    xor a
    ld [hl+], a

    ld a, h
    cp $C0
    jr nz, .InnerSaveLoop

    dec b
    ld a, b
    cp $FF
    jr nz, .OuterSaveLoop

    call DisableSRAM
    ret

DemoStringOne:
    db "Huh?\n_@_", 1, GreenColour, "`````"
    db "Is this a _#1_Plot Coupon?!~\\"

DemoStringTwo:
    db "_@_", 1, GreenColour
    db "You got a _#1_Plot Coupon!_#3_``````````\n"
    db "Only loads more to go!``````````````````````````````````~\\"

WarningString:
    db "The save data must \nbe initialised._@_", 1, RedColour, "_#1__`_", 12
    db " Previous\ndata will be lost._`_", 20, "~\\"

SavingString:
    db "Saving...\n_@_", 1, RedColour, "_#1__`_", 8, "Do not turn off\nthe power._#3_\\"

FoolishFools:
    db "This cartridge does not\n"
    db "contain any save memory,\n"
    db "or the battery has died.\\"

FakeRPGTextB:
    db "Sam used\nFunctional Harmony!\n"
    db "_`_", 15, "...but nothing happened.~\\'"

WhatNow:
    db "What now?\\"

FileOptionsTest:
    db "_@_", 2, GreenColour, "_@_", 1, BlueColour
    db "What of _#2_File 2_#3_?_#1_\n"
    db "^_right_^^", "Copy", "\t^^^_#3_ ", "Erase", "\t\t^Cancel\\"

FakeQuicksaveText:
    db "§", %111, "_@_", 2, $00, $00, "_@_", 2, $00, $00, "_#2_" ; Setting max speed, no SFX, black colours
    ;db "Don't turn off\n"
    ;db "the power.\\"
    db "Don't remove the\n"
    db "memory card\n"
    db "in Slot A.\\"

    ; Ideas for silly quicksave messages:
    ; "Don't turn off the power."
    ; "Don't remove the Game Pak."
    ; "Don't drop the Game Boy."
    ; "Don't remove the memory card in Slot A."
    ; "Don't throw the Game Boy into a fire."
    ; "Don't corrupt your save data."

SomeKindaPrompt:
    db "Is this some kinda prompt?\\"

EraseSaveDataConfirmation:
    db "Erase all save data?````\n"
    db "_@_", 1, RedColour, "_#1_"
    db "T`h`i`s` `c`a`n`'`t` `b`e` `u`n`d`o`n`e`._`_", 15 ,"\\"

KeyboardTest:
    db "So then, what's\nyour name?\\"

; Fast Fade Functions
; TODO: Refactor these, since there's tonnes of code reuse!
SECTION "Fast Fade Functions", ROM0

PromptTextFadeIn::
    ld c, $40 ; Colour
    ld b, 3 ; Counter
.Loop
    call WaitFrame

.Blue
    ld a, (2 * 2) + (8 * 7) + %10000000
    ld [BGPI], a

    ld a, (3 * 2) + (8 * 7) + %10000000
    ld [OBPI], a

    call EnsureVRAMAccess
    xor a
    ld [BGPD], a
    ld [OBPD], a
    ei

    call EnsureVRAMAccess
    ld a, c
    ld [BGPD], a
    ld [OBPD], a
    ei

    dec b
    ret z

    ld a, c
    add a, $80
    ld c, a
    jr nc, .Loop

    ld c, $FF
    jr .Loop


FastFadeToBlack::
    call WaitFrame
    ld d, 5 ; Outer counter
.OuterLoop
    ld b, 32 ; Number of colours to modify
    ld c, 0 ; Address
.BGPaletteLoop
; Load the palette into hl
    inc c
    ld a, c
    ld [BGPI], a

    call EnsureVRAMAccess
    ld a, [BGPD]
    ei
    ld h, a

    dec c
    ld a, c
    inc c
    inc c

    set 7, a ; Increment after writing
    ld [BGPI], a
    call EnsureVRAMAccess
    ld a, [BGPD]
    ei
    ld l, a

; Manipulate the palette data
    srl16 hl, 1
    call EnsureVRAMAccess
    ld a, l
    and %11101111
    ld [BGPD], a
    ei

    call EnsureVRAMAccess
    ld a, h
    and %00111101
    ld [BGPD], a
    ei

    dec b
    jr nz, .BGPaletteLoop

.SpritePalettes
    ld b, 32
.SpritePaletteLoop
; Load the palette into hl
    ld c, b
    sla c
    dec c
    ld a, c
    ld [OBPI], a

    call EnsureVRAMAccess
    ld a, [OBPD]
    ei
    ld h, a

    dec c
    ld a, c
    set 7, a ; Increment after writing
    ld [OBPI], a
    call EnsureVRAMAccess
    ld a, [OBPD]
    ei
    ld l, a

; Manipulate the palette data
    srl16 hl, 1
    call EnsureVRAMAccess
    ld a, l
    and %11101111
    ld [OBPD], a
    ei

    call EnsureVRAMAccess
    ld a, h
    and %00111101
    ld [OBPD], a
    ei

    dec b
    jr nz, .SpritePaletteLoop

    call WaitFrame
    dec d
    jr nz, .OuterLoop
    ret

FastFadeToWhite::
    call WaitFrame
    ld d, 5 ; Outer counter
.OuterLoop
    ld b, 32 ; Number of colours to modify
    ld c, 0 ; Address
.BGPaletteLoop
; Load the palette into hl
    inc c
    ld a, c
    ld [BGPI], a
    call EnsureVRAMAccess
    ld a, [BGPD]
    ei
    ld h, a

    dec c
    ld a, c
    inc c
    inc c

    set 7, a ; Increment after writing
    ld [BGPI], a
    call EnsureVRAMAccess
    ld a, [BGPD]
    ei
    ld l, a

; Manipulate the palette data
    sla16 hl, 1
    ld a, l
    bit 5, a
    jr z, .BGSkipOverflowR
.BGOverflowR
    or a, %00011111

.BGSkipOverflowR
    or a, %00100001
    ld e, a
    call EnsureVRAMAccess
    ld a, e
    ld [BGPD], a
    ei

    ld a, h
    bit 2, a
    jr z, .BGSkipOverflowG
.BGOverflowG
    ; Note, this won't give a perfect result for green
    or a, %00000011

.BGSkipOverflowG
    bit 7, a
    jr z, .BGSkipOverflowB
.BGOverflowB
    or a, %01111100

.BGSkipOverflowB
    or a, %00000100
    ld e, a
    call EnsureVRAMAccess
    ld a, e
    ld [BGPD], a
    ei

    dec b
    jr nz, .BGPaletteLoop

.SpritePalettes
    ld b, 32
.SpritePaletteLoop
; Load the palette into hl
    ld c, b
    sla c
    dec c
    ld a, c

    and a, %110
    jr nz, .ContinueLoadingColour

.SkipUnusedColour
    dec c
    dec c
    dec b
    jr z, .Finish

.ContinueLoadingColour
    ld a, c
    ld [OBPI], a
    call EnsureVRAMAccess
    ld a, [OBPD]
    ei
    ld h, a

    dec c
    ld a, c
    set 7, a ; Increment after writing
    ld [OBPI], a
    call EnsureVRAMAccess
    ld a, [OBPD]
    ei
    ld l, a

; Manipulate the palette data
    sla16 hl, 1
    ld a, l
    bit 5, a
    jr z, .SpriteSkipOverflowR
.SpriteOverflowR
    or a, %00011111

.SpriteSkipOverflowR
    bit 2, h
    jr z, .SpriteSkipOverflowG1
.SpriteOverflowG1
    or a, %1100000

.SpriteSkipOverflowG1
    or a, %00100001
    ld e, a
    call EnsureVRAMAccess
    ld a, e
    ld [OBPD], a
    ei

    ld a, h
    bit 2, a
    jr z, .SpriteSkipOverflowG
.SpriteOverflowG
    ; Note, this won't give a perfect result for green
    or a, %00000011

.SpriteSkipOverflowG
    bit 7, a
    jr z, .SpriteSkipOverflowB
.SpriteOverflowB
    or a, %01111100

.SpriteSkipOverflowB
    or a, %00000100
    ld e, a
    call EnsureVRAMAccess
    ld a, e
    ld [OBPD], a
    ei

    dec b
    jr nz, .SpritePaletteLoop

.Finish
    call WaitFrame
    dec d
    jp nz, .OuterLoop
    ret


SECTION "Temp Anim", ROM0

; TODO: Move this somewhere sensible!
TempAnim::
    ld a, [TempAnimWait]
    or a
    ret z

    dec a
    jr z, .NextFrame
    ld [TempAnimWait], a
    ret


.NextFrame
    ld a, 15 ; Need to change this from being hard-coded
    ; ld a, 5
    ld [TempAnimWait], a

.SetUpFrame
    ld a, [TempAnimFrame]
    ld [TempAnimFrame], a
    ld c, a
    ; add a, SaveAnim
    or a
    jr nz, .HideArrow

.ShowArrow
    ld a, NextTextPromptArrow
    ld b, a
    jr .IncrementFrame

.HideArrow
    xor a
    ld b, a

.IncrementFrame
    ld a, c
    inc a
    cp 2
    jr c, .Next
.HandleOverflow
    xor a

.Next
    ld [TempAnimFrame], a
    jp ReplaceLastTile
    

SECTION "VerifyChecksums", ROM0

VerifyChecksum:
; Leaves 0 in a if the checksum is correct, 1 otherwise
    PushROMBank
    SwitchROMBank 0
    ld de, 0 ; Checksum
    ld bc, $4000 ; Address
    jr .InnerLoop

.OuterLoop
    ldh a, [CurrentROMBank]
    cp $FF
    jr z, .Done

    inc a
    SwitchROMBankFromRegister
    ld bc, $4000 ; Address

.InnerLoop
    ld16rr hl, bc
    ld a, [hl]
    inc bc

    ld l, a
    xor a
    ld h, a

    add hl, de
    ld16rr de, hl

    ld a, b
    cp $80
    jr nz, .InnerLoop
    jr .OuterLoop

.Done
; Decrement the global checksum from our checksum
; Compare the two checksums
    SwitchROMBank 0

    ld a, [$014E]
    cpl
    inc a
    ld l, a
    ld h, $FF

    add hl, de
    ld16rr de, hl

    ld a, [$014F]
    cpl
    inc a
    ld l, a
    ld h, $FF

    add hl, de

    ld a, [$014E]
    sub h
    jr nz, .Incorrect

    ld a, [$014F]
    sub l
    jr nz, .Incorrect

.Correct
    xor a
    jr .CleanUp

.Incorrect
    ld a, 1

.CleanUp
    ld b, a
    PopROMBank
    ld a, b
    ret


PlayerName::
; TODO: Move this into RAM
    db "You\\"

SineTable::
; 256-byte sine table, with range 0-128.
; TODO: Move this somewhere sensible
ANGLE SET 0.0
REPT 256
    db (MUL(64.0, SIN(ANGLE)) + 64.0) >> 16
ANGLE SET ANGLE+256.0
ENDR
