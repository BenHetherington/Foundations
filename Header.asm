INCLUDE "SubroutineMacros.inc"

SECTION	"Org $00",ROM0[$00]
RST_00:
    ld b, b
	jp	$100

SECTION	"Org $08",ROM0[$08]
RST_08:
    ld b, b
	jp	$100

SECTION	"Org $10", ROM0[$10]
RST_10:
    ld b, b
	jp	$100

SECTION	"Org $18", ROM0[$18]
RST_18:
    ld b, b
	jp	$100

SECTION	"Org $20", ROM0[$20]
RST_20:
    ld b, b
	jp	$100

SECTION	"Org $28", ROM0[$28]
RST_28:
    ld b, b
	jp	$100

SECTION	"Org $30", ROM0[$30]
RST_30:
    ld b, b
	jp	$100

SECTION	"Org $38", ROM0[$38]
RST_38:
    ld b, b
	jp	$100

SECTION	"V-Blank IRQ Vector", ROM0[$40]
VBlankInterrupt:
    jp VBlankHandler
	
SECTION	"LCD IRQ Vector", ROM0[$48]
LCDInterrupt:
; Is only called for H-Blanks
; Not got anything to do just yet
	jp HBlankHandler

SECTION	"Timer IRQ Vector", ROM0[$50]
TimerInterrupt:
	reti

SECTION	"Serial IRQ Vector", ROM0[$58]
SerialInterrupt:
; Will we need link capabilities? Expand if so!
	reti

SECTION	"Joypad IRQ Vector", ROM0[$60]
ControllerInterrupt:
	reti
	
SECTION	"Header",ROM0[$100]
	ld c, a
	jp Start

	; Nintendo logo
	db $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
	db $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
	db $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

	; Game title
    db $46,$4F,$55,$4E,$44,$41,$54,$49,$4F,$4E,$53 ; FOUNDATIONS in ASCII
       ;0123456789A

	; Product code
	db $00,$00,$00,$00
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

	; Destination code
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