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

SECTION "General Variables", WRAM0
PlayingOnGBA:: db
TempAnimFrame:: db
TempAnimWait:: db

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
    ld [PlayingOnGBA], a
    jr GameStartup

.OriginalGameBoy
    JumpToOtherBank IncompatibleGB

GameStartup:
; This is the point where the game returns to on reset
    xor a
    ld [ResetDisallowed], a

; Set up stack
    ld sp, StackEnd - 1

; Use single speed mode, if we were in double speed when we reset
    call DisableDoubleSpeed

; Set up timer
    ;ld [TMA], a ; Reset the timer modulo value

    ;ld a, %100  ; 4096 Hz timer, interrupts at 16 Hz. Could be subject to change!
    ;ld [TAC], a

; Enable the correct interrupts
    ld a, %00000001 ; [No Timer], [No LYC (LCD STAT)], V-Blank
    ld [IE], a      ; TODO: Add serial to this to add link capablilities?

    call InitSoundEngine

; Start the temporary animation frame counter
    xor a
    ld [TempAnimWait], a
    ei

; Set up the OAM DMA Subroutine
    MemCopy DMAWaitInROM, OAMDMAWait, 8

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
    jp nz, .SRAMBroken

.MainBit
    call PlayLucSample

    ld c, 60
    call WaitFrames

    ; ld a, 3
    ; call PlayMusic

    CallToOtherBank ShowBen10doScreen

    ld hl, LCDC
    res 4, [hl]

    call ShowTextBox
    ld hl, AssemblyString
    call PrintString
    
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

    call EnableDoubleSpeed

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

    call CloseTextBox

    call FastFadeToBlack

    call DisableDoubleSpeed

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
    call BattleTextFadeIn
    jr .FillerHalt

.AttemptingAnRPGTextBox
    ld c, 15
    call WaitFrames

    call FastFadeToWhite
    call ShowTextBox

    ld hl, FakeRPGTextB
    ; call PrintString
    ; jr .FillerHalt

;    SwitchSpeed
    ;ld hl, FakeRPGText
    ld hl, FileOptionsTest
    call PrintString
;    SwitchSpeed
    ; call BattleTextFadeIn


.FillerHalt
    halt
    jr .FillerHalt

.SRAMBroken
    ld hl, LCDC
    res 4, [hl]

    call ShowTextBox
    ld hl, FoolishFools
    call PrintString
    jr .FillerHalt

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

FakeRPGText:
    db "What now?\n"
    db "§", %111, "_@_", 1, $00, $00, "_@_", 2, $00, $00, "_#2_" ; Setting max speed, no SFX, black colours
    db "^_right_^^", "Fight", "\t^_#1_ ", "Magic",  "\t\t ", "Taunt\n"
    db "\t", "Item",  "\t^^ ",    "Tattle", "\t ",   "Run Away", "§", 0, "\\"

FileOptionsTest:
    db "_@_", 2, GreenColour, "_@_", 1, BlueColour
    db "What of _#2_File 2_#3_?_#1_\n"
    db "^_right_^^", "Copy", "\t^^^_#3_ ", "Erase", "\t\t^Cancel\\"

FakeQuicksaveText:
    db "§", %111, "_@_", 1, $00, $00, "_@_", 2, $00, $00, "_#1_" ; Setting max speed, no SFX, black colours
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

; Fast Fade Functions
; TODO: Refactor these, since there's tonnes of code reuse!

BattleTextFadeIn:
; TODO; Redo this
; Instead, have the colour fade to white, and then fade the selection to blue
; This enables me to use one less colour, enabling me to use the 'other' spare
; colour in the text above the selection
; Also, don't make this battle-specific!

    ld c, $40 ; Colour
    ld b, 3 ; Counter
.Loop
    call WaitFrame

.Blue
    ld a, (2 * 2) + (8 * 7) + %10000000
    ld [BGPI], a

    xor a
    ld [BGPD], a
    ld a, c
    ld [BGPD], a

.White
    ld a, (1 * 2) + (8 * 7) + %10000000
    ld [BGPI], a

    ld a, c
    ld [BGPD], a
    ld [BGPD], a

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
    and %11101111
    ld [BGPD], a

    ld a, h
    and %00111101
    ld [BGPD], a

    dec b
    jr nz, .BGPaletteLoop

.SpritePalettes
    ld b, 32
.SpritePaletteLoop
    call EnsureVBlank

; Load the palette into hl
    ld c, b
    sla c
    dec c
    ld a, c
    ld [OBPI], a

    ld a, [OBPD]
    ld h, a

    dec c
    ld a, c
    set 7, a ; Increment after writing
    ld [OBPI], a
    ld a, [OBPD]
    ld l, a

; Manipulate the palette data
    call EnsureVBlank

    srl16 hl, 1
    ld a, l
    and %11101111
    ld [OBPD], a

    ld a, h
    and %00111101
    ld [OBPD], a

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
    call EnsureVBlank
    ld a, [BGPD]
    ld h, a

    dec c
    ld a, c
    inc c
    inc c

    set 7, a ; Increment after writing
    ld [BGPI], a
    call EnsureVBlank
    ld a, [BGPD]
    ld l, a

; Manipulate the palette data
    call EnsureVBlank
    sla16 hl, 1
    ld a, l
    bit 5, a
    jr z, .BGSkipOverflowR
.BGOverflowR
    or a, %00011111

.BGSkipOverflowR
    or a, %00100001
    ld e, a
    call EnsureVBlank
    ld a, e
    ld [BGPD], a

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
    call EnsureVBlank
    ld a, e
    ld [BGPD], a

    dec b
    jr nz, .BGPaletteLoop

.SpritePalettes
    ld b, 32
.SpritePaletteLoop
    call EnsureVBlank

; Load the palette into hl
    ld c, b
    sla c
    dec c
    ld a, c

    and %110
    jr nz, .ContinueLoadingColour

.SkipUnusedColour
    dec c
    dec c
    dec b
    jr z, .Finish

.ContinueLoadingColour
    ld a, c
    ld [OBPI], a
    call EnsureVBlank
    ld a, [OBPD]
    ld h, a

    dec c
    ld a, c
    set 7, a ; Increment after writing
    ld [OBPI], a
    call EnsureVBlank
    ld a, [OBPD]
    ld l, a

; Manipulate the palette data
    call EnsureVBlank
    sla16 hl, 1
    ld a, h
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
    call EnsureVBlank
    ld a, e
    ld [OBPD], a

    call EnsureVBlank
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
    call EnsureVBlank
    ld a, e
    ld [OBPD], a

    dec b
    jr nz, .SpritePaletteLoop

.Finish
    call WaitFrame
    dec d
    jp nz, .OuterLoop
    ret


SECTION "Temp Anim", ROM0

VBlankHandler::
    push af ; Push everything
    push bc
    push de
    push hl

.CheckReset
    ld a, [ResetDisallowed]
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

.Anim
    call SoundEngineUpdate
    call TempAnim

    pop hl ; Pop everything
    pop de
    pop bc
    pop af
    reti


TempAnim:
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

HBlankHandler::
    push af

    ld a, [STAT]
    bit 1, a
    jr nz, .SetUpHBlankInterrupt

    push bc

    ld a, [BGPI]
    ld b, a

    xor a
    ld [BGPI], a
    ld a, [LY]
    ld c, a
    srl a
    srl a
    srl a
    ld [BGPD], a

    ld a, b
    ld [BGPI], a

    ld a, c
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

SECTION "VerifyChecksums", ROM0

VerifyChecksum:
; Leaves 0 in a if the checksum is correct, 1 otherwise
    call EnableDoubleSpeed
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
    call DisableDoubleSpeed
    ld a, b
    ret
