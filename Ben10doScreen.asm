INCLUDE "SubroutineMacros.inc"

SECTION "Decompression Work Space", WRAMX, BANK[7]
; TODO: Move!
DecompressionWorkSpace::
ds $1000

OAMData       EQU $D000 ; TODO: See if we can make these not constant
Tiles         EQU $D0A0
Map           EQU $D340
MapAttributes EQU $D3F0 ; TODO: May need to change!
BGPalettes    EQU $D460 ; TODO: May need to change!
SprPalettes   EQU $D4A0 ; TODO: May need to change!

SECTION "Ben10do Screen", ROMX

;OAMData:
;    db $38,$58,$1F,$00,$38,$60,$20,$01,$40,$58,$21,$02,$40,$60,$22,$02
;    db $48,$50,$23,$03,$48,$58,$24,$04,$48,$60,$25,$05,$48,$68,$26,$03
;    db $50,$50,$27,$06,$50,$58,$28,$07,$50,$60,$29,$07,$50,$68,$2A,$06
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;
;Tiles:
;INCLUDE "Graphics/Ben10do Logo Tiles.asm"
;
;; TODO: Compress?
;
;Map:
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00
;REPT $20
;    db $00
;ENDR
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$04,$00,$00,$00,$00
;REPT $20
;    db $00
;ENDR
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$06,$07,$08,$00,$00,$00
;REPT $20
;    db $00
;ENDR
;    db $00,$00,$00,$00,$00,$00,$00,$0D,$0E,$09,$0A,$0B,$0C,$00,$00,$00
;REPT $20
;    db $00
;ENDR
;    db $00,$00,$00,$00,$00,$00,$0F,$11,$13,$15,$17,$19,$1B,$1D,$00,$00
;REPT $20
;    db $00
;ENDR
;    db $00,$00,$00,$00,$00,$00,$10,$12,$14,$16,$18,$1A,$1C,$1E,$00,$00
;REPT $20
;    db $00
;ENDR
;
;MapAttributes:
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00
;REPT $20
;    db $00
;ENDR
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$03,$00,$00,$00,$00
;REPT $20
;    db $00
;ENDR
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$05,$05,$04,$00,$00,$00
;REPT $20
;    db $00
;ENDR
;    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$07,$07,$06,$00,$00,$00
;REPT $20
;    db $00
;ENDR
;
;BGPalettes:
;    db $FF,$7F,$52,$4A,$6B,$2D,$00,$00,$FF,$7F,$33,$3E,$2C,$19,$A8,$10
;    db $FF,$7F,$71,$25,$4F,$21,$EA,$18,$FF,$7F,$91,$29,$70,$25,$4F,$21
;    db $FF,$7F,$05,$66,$A0,$55,$C0,$4C,$FF,$7F,$E0,$40,$B0,$2D,$EB,$14
;    db $FF,$7F,$C0,$48,$A0,$38,$00,$14,$C0,$48,$80,$34,$80,$2C,$40,$2C
;
;SprPalettes:
;    db $FF,$7F,$CA,$10,$88,$10,$C7,$00,$FF,$7F,$6E,$25,$EA,$10,$05,$00
;    db $FF,$7F,$ED,$18,$EB,$14,$88,$14,$FF,$7F,$58,$77,$58,$77,$13,$6F
;    db $FF,$7F,$0D,$1D,$0C,$19,$A8,$10,$FF,$7F,$4E,$21,$EC,$18,$A9,$0C
;    db $FF,$7F,$80,$34,$40,$20,$00,$10,$FF,$7F,$A8,$10,$60,$24,$60,$24

CompressedBen10doScreenData:
INCBIN "Ben10doScreenData.pu"

ShowBen10doScreen::
    xor a
    ld [VBK], a ; Use VRAM Bank 0
    ld [STAT], a ; Turn off gradient-y stuffs

    ld a, %10010001 ; Use tiles at $8800 and map at $9800
    ld [LCDC], a

.Decompress
    PushWRAMBank
    SwitchWRAMBank BANK(DecompressionWorkSpace)

    EnableDoubleSpeed

    ld de, DecompressionWorkSpace
    ld hl, CompressedBen10doScreenData

    call Unpack

    DisableDoubleSpeed

.CopyTiles
    StartVRAMDMA Tiles, $8010, $2A0, 1
    WaitForVRAMDMAToFinish

.CopyMap
    StartVRAMDMA Map, $98A0, $B0, 1
    WaitForVRAMDMAToFinish

.CopyMapAttributes
    ld a, 1
    ld [VBK], a

    StartVRAMDMA MapAttributes, $98A0, $70, 1
    WaitForVRAMDMAToFinish

.CopyDMA
    StartOAMDMA OAMData

.CopyPalettes
    ld a, %10000000
    ld [BGPI], a
    MemCopyFixedDest BGPalettes, BGPD, 64

    ld a, %10000000
    ld [OBPI], a
    MemCopyFixedDest SprPalettes, OBPD, 64

    ld a, %10010011
    ld [LCDC], a

    PopWRAMBank

    ld c, 255
    call WaitFrames

    call FastFadeToWhite

    PushROMBank
    SwitchROMBank BANK(BlankTiles)

    xor a
    ld [VBK], a

    StartVRAMDMA BlankTiles, $98A0, $B0, 1 ; Clear map
    WaitForVRAMDMAToFinish

    ld a, 1
    ld [VBK], a

    StartVRAMDMA BlankTiles, $98A0, $B0, 1 ; Clear attributes
    WaitForVRAMDMAToFinish

    StartOAMDMA BlankTiles

    PopROMBank

    ret
