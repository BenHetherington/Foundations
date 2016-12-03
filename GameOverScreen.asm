INCLUDE "SubroutineMacros.inc"
INCLUDE "Strings/StringMacros.inc"
INCLUDE "Strings/charmap.inc"

SECTION "Game Over Screen", ROMX

GameOverGradient:
.Whiteness
    dw $7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF
    dw $7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF
.AnimationGradient
    dw $7BBE,$739C,$6F5B,$6B19,$66D8,$5EB6,$5A75,$5633
    dw $4DF2,$49D0,$458F,$414D,$392C,$34EA,$30A9,$2C67,$2446
FinalGradient:
    dw $2004,$1C04,$1803,$1403,$1002,$0C02,$0801,$0401,$0000
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
.Blackness
    dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000


EncouragementText1:
    db "Come on! ```\n_@_", 1, GreenColour
    db "_#1_You can do it!~\\"

EncouragementText2:
    db "That didn't go so well...~\\"

; TODO: Add another encouragement message?

PromptText:
    db "Give it another go?\\"

QuitText:
    db "_PLAYER_ realised that it\n"
    db "was just a bad dream.~\\" ; No EarthBound references here...

GradientEnableStart:
    ; TODO: Move this somewhere sensible
    jp Gradient
GradientEnableEnd:

ShowGameOverScreen::
    ld c, 5
    call WaitFrames

    ld a, 5
    call PlayMusic

    call EnableDoubleSpeed

; Set the background map and tiles
; TODO: Check if the BlankTiles will be accessible from this bank
    ld a, 1
    ld [VBK], a

    StartVRAMDMA BlankTiles, $9800, 1024, 1
    call WaitForVRAMDMAToFinish

    xor a
    ld [VBK], a

    StartVRAMDMA BlankTiles, $9800, 1024, 1
    call WaitForVRAMDMAToFinish

    StartVRAMDMA BlankTiles, $9000, $10, 1
    call WaitForVRAMDMAToFinish

; Copy the initial gradient data
    MemCopy GameOverGradient, GradientData, 18 * 2

; Enable gradients; change if this is refactored later
    MemCopy GradientEnableStart, LCDStatDIH, GradientEnableEnd - GradientEnableStart

    ld hl, STAT
    set 3, [hl]

    ld hl, IE
    set 1, [hl]

; Animate the gradient
    ld hl, GameOverGradient
    ld c, 36

.AnimateGradientIn
    ; hl contains the source
    ld de, GradientData
    ld b, 18 * 2
    push hl
    call SmallMemCopyRoutine
    pop hl

    call WaitFrame
    inc hl
    inc hl
    dec c
    jr nz, .AnimateGradientIn
    ; fallthrough

GameOverMessage:
    call ShowTextBox

    ld hl, EncouragementText1
    call PrintString

    ld hl, PromptText
    call PrintString

    ld hl, YesNoPrompt
    call Prompt

    cp 0
    jr nz, Quit
    ; fallthrough

Continue:
    call CloseTextBox

    ld a, 6
    call FadeSound

; Animate the gradient
    ld hl, FinalGradient
    ld c, 36

.AnimateGradientOut
    ; hl contains the source
    ld de, GradientData
    ld b, 18 * 2
    push hl
    call SmallMemCopyRoutine
    pop hl

    call WaitFrame
    dec hl
    dec hl
    dec c
    jr nz, .AnimateGradientOut

; Disable gradients
    ld hl, IE
    res 1, [hl]

    ld a, $D9 ; reti
    ld [LCDStatDIH], a

    ld c, 15
    call WaitFrames

    JumpToOtherBank ATextBasedAdventure

Quit:
    ld hl, QuitText
    call PrintString
    call CloseTextBox

    ld a, 10
    call FadeSound

; Animate the gradient
    ld hl, FinalGradient
    ld c, 9

.AnimateGradientOut
    ; hl contains the source
    ld de, GradientData
    ld b, 18 * 2
    push hl
    call SmallMemCopyRoutine
    pop hl

    push bc
    ld c, 4
    call WaitFrames
    pop bc
    inc hl
    inc hl
    dec c
    jr nz, .AnimateGradientOut

; Disable gradients
    ld hl, IE
    res 1, [hl]

    ld a, $D9 ; reti
    ld [LCDStatDIH], a

    ld c, 45
    call WaitFrames

    call FastFadeToWhite
    JumpToOtherBank GameStartup
