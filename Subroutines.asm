SECTION "BankSwitchData", WRAM0
CurrentROMBank:  db

SECTION "BankSwitch", HOME
SRAMEnableLocation EQU $0000
ROMBankSwitchLocation EQU $2000
SRAMBankSwitchLocation EQU $4000
WRAMBankSwitchLocation EQU $FF70

CallToOtherBankFunction:
; assumes *c* is the requested bank - different to other functions!
; assumes hl is the address required within said bank
; use b and de to pass data there, and bc, de, and hl to pass data back
; requires 6 bytes of stack space for each inter-bank call.
    ld a, [CurrentROMBank]
    push af
    ld a, c

    ld [CurrentROMBank], a
    ld [ROMBankSwitchLocation], a

; Simulate a call
    ld a, b
    ld bc, .Return
    push bc
    ld b, a
    jp hl
.Return
    pop af
    ld [CurrentROMBank], a

    ld [ROMBankSwitchLocation], a
    ret

CallToOtherBank: MACRO
    ld c, BANK(\1)
    ld hl, \1
    call CallToOtherBankFunction
    ENDM

JumpToOtherBankFunction:
; assumes *a* is the requested bank
; assumes hl is the address required within said bank
; use bc and de to pass data there
    ld [CurrentROMBank], a
    ld [ROMBankSwitchLocation], a
    jp hl

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
    ld [CurrentROMBank], a
    ld [ROMBankSwitchLocation], a
    ENDM

PushROMBank: MACRO
    ld a, [CurrentROMBank]
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

SECTION "GBC Subroutines", ROM0

KEY1 EQU $FF4D

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
; TODO: STOP CONFUSING OAM DMA AND VRAM DMA
; \1: Source, \2: Destination, \3: Length, \4: 0 = General, 1 = H-Blank
    ;IF \1 & $F != 0
    ;WARN "DMA Souce address's lower four bits must be 0."
    ;ENDC

    ;IF \2 & $F != 0
    ;WARN "DMA Destination address's lower four bits must be 0."
    ;ENDC

    ld a, (\1 >> 8)
    ld [HDMA1], a
    ld a, (\1 & $FF)
    ld [HDMA2], a

    ld a, (\2 >> 8)
    ld [HDMA3], a
    ld a, (\2 & $FF)
    ld [HDMA4], a

    ld a, (((\3 / $10) - 1) & $7F) | ((\4 & 1) << 7)
    ld [HDMA5], a
    ENDM

WaitForVRAMDMAToFinish: MACRO
.Loop\@
    ld a, [HDMA5]
    cp $FF
    jr nz, .Loop\@
    ENDM

SECTION "DMA Wait Location", HRAM

SECTION "DMA Wait Subroutine", ROMX
; TODO: Take another look at this stuff.
DMAWaitInROM:
    ld [HDMA5], a
    ld a, $28
.Wait
    dec a
    jr nz, .Wait



SECTION "Graphics Subroutines", HOME
WaitFrame:
; Returns after the next V-Blank begins, and the interrupt is finished.
    ld a, 1
    ld [VBlankOccurred], a
    ei
.Wait
    halt
    ld a, [VBlankOccurred]
    and a
    jr nz, .Wait
    ret

WaitFrames:
; Waits for c frames.
    call WaitFrame
    dec c
    jr nz, WaitFrames
    ret

EnsureVBlank:
; Returns immediately if in V-Blank, else returns once we're in it.
    call CheckVBlank
    ret nz
.CheckIfHBlankInterruptsAreEnabled
; TODO: Check if this is needed! This is unnecessary if H-Blank interrupts are always enabled.
    ld a, [STAT]
    bit 3, a
    jr z, EnsureVBlank
.Halt
; Wait until the H-Blank interrupt fires.
    halt
.CheckAgain
; Acts like a busy-wait loop if not using the interrupt.
    jr EnsureVBlank

CheckVBlank:
; If a is non-zero, we're in V-Blank. If a is zero, we're not in V-Blank.
; Can also just check the z flag after this returns!
    ld a, [STAT]
    bit 1, a
    jr nz, .NotInVBlank
.InVBlank
    inc a ; returns 1 if in H-Blank, 2 if in V-Blank
    ret
.NotInVBlank
    xor a
    ret


SECTION "Random Number Generator", HOME
Random:
; Generates an 8-bit pseudorandom number (in a)
; Relies on the divider
; TODO: Write this!
    ret

RandNum:
; Generates a random number between 0-c.
    call Random
    ret


SECTION "Subroutines", ROM0

WordMultiply::
    ; Multiplies two 16-bit numbers.
    ; Returns the result in hl
    ; bc = operand 1; de = operand 2
    ; Destroys all registers in the process.
    ; Adapted from http://cpctech.cpc-live.com/docs/mult.html

    ld a, 16     ; Number of bits to process
    ld hl, 0     ; Holds the partial and final result

.Loop
    srl16 bc, 1 ; divides bc by 2
    ;; if carry = 0, then state of bit 0 was 0, (the rightmost digit was 0)
    ;; if carry = 1, then state of bit 1 was 1. (the rightmost digit was 1)
    ;; if rightmost digit was 0, then the result would be 0, and we do the add.
    ;; if rightmost digit was 1, then the result is DE and we do the add.
    jr nc, .NoAdd

    ;; will get to here if carry = 1
    add hl, de

.NoAdd
    ;; at this point BC has already been divided by 2

    sla16 de, 1
    ; TODO: Handle overflow

    ;; at this point DE has been multiplied by 2

    dec a
    jr nz, .Loop ; Continue processing the rest of the bits
    ret

Multiply::
    ; Multiplies two 8-bit numbers, stopping early if possible.
    ; Returns the result in hl
    ; a = operand 1; e = operand 2
    ; Only b is unaffected.
    ; Adapted from WordMultiply

    ld c, 8  ; No. of bits to process
    ld d, 0  ; Necessary for 16-bit addition
    ld hl, 0 ; Holds the partial and final result

.Loop
    or a
    ret z ; If we're done, return now!

    srl a ; Divides a by 2
    jr nc, .NoAdd

.Carry
    add hl, de

.NoAdd
    sla16 de, 1 ; Multiplies de by 2

    dec c
    jr nz, .Loop
    ret

SmallMultiply::
; Multiplies two 8-bit numbers, returning the result in an 8-bit number
; Uses less registers, and stops early if possible.
; Returns the result in a
; ? = operand 1; ? = operand 2
; Adapted from Multiply, which was adapted from WordMultiply

    ld d, 8 ; No. of bits to process
    xor a   ; Holds the result

.Loop
    srl b ; Divides b by 2
    ret z
    jr nc, .NoAdd

.Carry
    add a, c

.NoAdd
    sla c ; Multiplies c by 2
    ; TODO: Handle overflow

    dec c
    jr nz, .Loop
    ret

