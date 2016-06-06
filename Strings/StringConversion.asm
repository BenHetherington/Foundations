INCLUDE "Strings/charmap.inc"

SECTION "String Conversion", ROMX

UInt8ToString::
; Converts the unsigned 8-bit number in *b* to a string
; The result will be stored in StringBuffer
    ld a, b
    ld hl, StringBuffer

    cp 100 - 1
    jr c, .Tens

    cp 200 - 1
    jr c, .OneHundred

.TwoHundred
    sub a, 200
    ld b, a

    ld a, "2"
    ld [hl+], a

    ld a, b
    jr .Tens

.OneHundred
    sub a, 100
    ld b, a

    ld a, "1"
    ld [hl+], a

    ld a, b
    ; fallthrough

.Tens
; TODO: Don't show the leading zero if there aren't any hundreds
    call BinaryToBCD
    ld b, a
    swap a
    and a, $0F
    add a, "0"
    ld [hl+], a

.Units
    ld a, b
    and a, $0F
    add a, "0"
    ld [hl+], a

    ld a, "\\"
    ld [hl+], a

    ret
