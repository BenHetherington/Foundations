INCLUDE "SubroutineMacros.inc"
INCLUDE "lib/Shift.inc"

SECTION "Sample Vars", WRAM0
StopSampling: db
SampleBank: db
SamplePointer: dw
SamplesLeft: dw
SampleFreqHi: db
SampleTempLR: db
SampleStartingPointer: dw
SamplesTotal: dw
SampleShouldLoop: db

SECTION "Sample Player", ROM0

; This is a temporary sample player, for use for development.
; TODO: Refactor this back into the sound engine!

PlaySample::
    push hl
    push bc

    ld c, a
    ld b, 0
    sla16 bc, 1 ; hl = SamplePointers + (a * 6)

    ld hl, SamplePointers
    add hl, bc

    sla16 bc, 1
    add hl, bc

    xor a
    ld [TIMA], a
    ld [StopSampling], a

    ld a, [hl+]
    ld [SampleBank], a

    ld a, [hl+]
    ld [SamplePointer], a
    ld [SampleStartingPointer], a

    ld a, [hl+]
    ld [SamplePointer + 1], a
    ld [SampleStartingPointer + 1], a

    ld a, [hl+]
    ld [SamplesLeft], a
    ld [SamplesTotal], a

    ld a, [hl+]
    ld [SamplesLeft + 1], a
    ld [SamplesTotal + 1], a

    ld a, d
    ld [SampleShouldLoop], a

;Set up timer
    ld a, %100 ; 4096 Hz timer
    ld [TAC], a

    ld a, [hl]
    ld b, a
    cpl
    inc a
    ld [TMA], a ; Reset the timer modulo value
    ; TODO: Take double speed mode into account!

    ld hl, IE
    set 2, [hl] ; Enable the timer interrupt

    ld a, 255
    ld [TIMA], a

; Stop sound playback
; TODO: Should we incorporate the antispike technique here too?
    xor a
    ld [NR30], a

; Set playback frequency
; Effectively does 2048 - (b << 4) and put it in NR33/34
    swap b
    ld a, b
    and a, $F0

    cpl
    inc a
    ld [NR33], a

    ld a, b
    jr nz, .SkipOverflow

.Overflow
    dec a

.SkipOverflow
    cpl
    and a, $07
    ld [NR34], a

    set 7, a
    ld [SampleFreqHi], a


    ; TODO: Try and remove this hack; don't change balance if we don't have to!
    ld hl, NR51
    ld a, %01000100
    or a, [hl]
    ld [hl], a

    pop bc
    pop hl
    ret


SampleUpdate::
    push af
    push bc
    push de
    push hl
    PushROMBank

    ld a, [StopSampling]
    or a
    jp nz, .StopPlayingSample

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

; "Antispike" technique
    ld a, [NR51]
    ld [SampleTempLR], a
    and a, %10111011
    ld [NR51], a

; Stop WAV playback
    xor a
    ld [NR30], a

.CopyLoop
    ld a, [hl+]
    ld [$FF00+c], a
    inc c

    dec e
    jr z, .Dec1Carry

    dec e
    jr nz, .CheckForFinish
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
    ld a, [SampleShouldLoop]
    or a
    jr z, .FinishSample

.LoopSample
    ; TODO: Make this dynamic! Decide how long it should be before next interrupt!
    ld b, b
    ld a, 256 - (2 * 2)
    ld [TIMA], a

    ld a, [SampleStartingPointer]
    ld l, a
    ld a, [SampleStartingPointer + 1]
    ld h, a

    ld a, [SamplesTotal]
    ld e, a
    ld a, [SamplesTotal + 1]
    ld d, a
    jr .ConsiderPadding

.FinishSample
    ld a, 1
    ld [StopSampling], a
    ; fallthrough

.ConsiderPadding
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

    ld a, [SampleFreqHi]
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
