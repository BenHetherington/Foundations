SECTION	"Org $00",HOME[$00]
RST_00:	
	jp	$100

SECTION	"Org $08",HOME[$08]
RST_08:	
	jp	$100

SECTION	"Org $10", HOME[$10]
RST_10:
	jp	$100

SECTION	"Org $18", HOME[$18]
RST_18:
	jp	$100

SECTION	"Org $20", HOME[$20]
RST_20:
	jp	$100

SECTION	"Org $28", HOME[$28]
RST_28:
	jp	$100

SECTION	"Org $30", HOME[$30]
RST_30:
	jp	$100

SECTION	"Org $38", HOME[$38]
RST_38:
	jp	$100

SECTION	"V-Blank IRQ Vector", HOME[$40]
VBL_VECT:
    jp VBlankHandler
	
SECTION	"LCD IRQ Vector", HOME[$48]
LCD_VECT:
; Is only called for H-Blanks
; Not got anything to do just yet
	reti

SECTION	"Timer IRQ Vector", HOME[$50]
TIMER_VECT:
	reti

SECTION	"Serial IRQ Vector", HOME[$58]
SERIAL_VECT:
; Will we need link capabilities? Expand if so!
	reti

SECTION	"Joypad IRQ Vector", HOME[$60]
JOYPAD_VECT:
	reti

SECTION "BankSwitchData", WRAM0
CurrentROMBank:  db

SECTION "BankSwitch", HOME
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



SECTION "Subroutines", HOME
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

	
SECTION	"Header",HOME[$100]
	ld c, a
	jp	Start

	; Nintendo logo
	db	$CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
	db	$00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
	db	$BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

	; Game title
    db	$46,$4F,$55,$4E,$44,$41,$54,$49,$4F,$4E,$53 ; FOUNDATIONS in ASCII
		;0123456789A

	; Product code
	db	"    "
		;0123

	; Color GameBoy compatibility
	db	$C0	; GBC Only

	; License code
	db	"ME"

	; GameBoy/Super GameBoy indicator
	db	$00	; No SGB compatibility

	; Cartridge type
	db	$1A	; MBC5+RAM recommended $1A ($19)

	; ROM size
	db	$07	; 4MB (256 banks)

	; RAM size
    db	$04	; 128KB (16 banks) $04 ($00)

	; $Destination code
	db	$01	; $01 - Non-Japanese

	; Old Licensee Code
	db	$33	; $33 - Check $0144/$0145 for Licensee code.

	; Mask ROM version - handled by RGBFIX
	db	$00

	; Complement check - handled by RGBFIX
	db	$00

	; Cartridge checksum - handled by RGBFIX
	dw	$0000


; End header