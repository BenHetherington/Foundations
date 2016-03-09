INCLUDE "Subroutines.asm"

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
	jp HBlankHandler

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