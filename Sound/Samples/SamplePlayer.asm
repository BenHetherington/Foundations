INCLUDE "SubroutineMacros.inc"

SECTION "Sample Vars", WRAM0
StopSampling: db ; Also used as a temporary variable for the current panning
SampleBank: db
SamplePointer: dw
SamplesLeft: dw
SampleTempLR: db

SECTION "Sample Player", ROM0

; This is a temporary sample player, for use for development.
; TODO: Refactor this back into the sound engine!

PlayLucSample::
    xor a
    ld [TIMA], a
    ld [StopSampling], a

    ld hl, SamplePointers ; Sample with ID 0

    ld a, [hl+]
    ld [SampleBank], a

    ld a, [hl+]
    ld [SamplePointer], a

    ld a, [hl+]
    ld [SamplePointer + 1], a

    ld a, [hl+]
    ld [SamplesLeft], a

    ld a, [hl]
    ld [SamplesLeft + 1], a

;Set up timer
    ld a, %100  ; 4096 Hz timer. TODO: Needs to be adjustable.
    ld [TAC], a

    ld a, 256 - 32
    ld [TMA], a ; Reset the timer modulo value

    ld hl, IE
    set 2, [hl] ; Enable the timer interrupt

    ld a, 255
    ld [TIMA], a

    ; TODO: Try and remove this hack; don't change balance if we don't have to!
    ld hl, NR51
    ld a, %01000100
    or a, [hl]
    ld [hl], a

    ret


SampleUpdate::
    push af
    push bc
    push de
    push hl
    PushROMBank

    ld a, [StopSampling]
    or a
    jr nz, .StopPlayingSample

    ld a, [SampleBank]
    SwitchROMBankFromRegister

    ld hl, SamplesLeft
    ld a, [hl+]
    ld d, [hl]
    ld e, a

    ld hl, SamplePointer
    ld a, [hl+]
    ld h, [hl]
    ld l, a

    ld b, $10 ; Max no. of bytes to copy
    ld c, $30 ; Wave data location

    ld a, [NR51]
    ld [SampleTempLR], a
    and a, %10111011
    ld [NR51], a

    xor a ; Stop WAV playback
    ld [NR30], a

.CopyLoop
    ld a, [hl+]
    ld [$FF00+c], a
    inc c

    dec e
    jr z, .Dec1Carry

    dec e
    jr nz, .CheckForFinish ; TODO: Check that this is right
    jr .Dec2Carry

.Dec1Carry
    dec e
.Dec2Carry
    dec d
    jr nz, .CheckForFinish
    jr .HandleSampleFinished

.CheckForFinish
    dec b
    jr nz, .CopyLoop
    jr .Finish

.HandleSampleFinished
    ; TODO: Account for looping samples!
    ld a, 1
    ld [StopSampling], a

    dec b
    jr z, .Finish

    xor a
.PadLoop
    ld [$FF00+c], a
    inc c
    dec b
    jr nz, .PadLoop
    ; fallthrough

.Finish
    ld a, $BF ; Turn it up!
    ld [NR32], a ; TODO: Only do this if we need to!

    ld a, $80 ; Start WAV playback
    ld [NR30], a

    xor a
    ld [NR33], a
    ld a, $06 | (%10000000)
    ld [NR34], a

    ld a, [SampleTempLR]
    ld [NR51], a

    ld a, l
    ld [SamplePointer], a
    ld a, h
    ld [SamplePointer + 1], a

    ld hl, SamplesLeft
    ld a, e
    ld [hl+], a
    ld [hl], d

.CleanUp
    PopROMBank
    pop hl
    pop de
    pop bc
    pop af
    reti

.StopPlayingSample
    xor a
    ld [TAC], a
    ld [NR30], a
    jr .CleanUp
