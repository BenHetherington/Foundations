INCLUDE "Sound/Macros.asm"
INCLUDE "lib/AddSub1.inc"

INCLUDE "Sound/MusicPointers.asm"

SECTION "SoundVariables", WRAMX
; Must define some important sound-y variables

MuTempo: db
MuCounter: db
FXTempo: db
FXCounter: db

; Waits - equivelent to length of note, decremented and
PU1MuWait: db
PU1FXWait: db
PU2MuWait: db
PU2FXWait: db
WAVMuWait: db
NOIMuWait: db
NOIFXWait: db

; For remembering where we were!
; If address bank is 0, assume all mu/all FX channels are not active
; If bit 7 of MSB is set, assume it's not active <- (actual implementation)
MuAddressBank: db
FXAddressBank: db
PU1MuAddress: dw
PU1FXAddress: dw
PU2MuAddress: dw
PU2FXAddress: dw
WAVMuAddress: dw
WAVFXAddress: dw
NOIMuAddress: dw
NOIFXAddress: dw

; For returning from a called phrase
; Must be in same bank as original phrase
PU1MuOriginalAddress: dw
PU1FXOriginalAddress: dw
PU2MuOriginalAddress: dw
PU2FXOriginalAddress: dw
WAVMuOriginalAddress: dw
WAVFXOriginalAddress: dw
NOIMuOriginalAddress: dw
NOIFXOriginalAddress: dw

; For looping called phrases
PU1MuLoopCounter: db
PU1FXLoopCounter: db
PU2MuLoopCounter: db
PU2FXLoopCounter: db
WAVMuLoopCounter: db
WAVFXLoopCounter: db
NOIMuLoopCounter: db
NOIFXLoopCounter: db

; Backup for if the envelope is changed by FX channel
PU1MuEnvelopeBackup: db
PU2MuEnvelopeBackup: db
WAVMuEnvelopeBackup: db
NOIMuEnvelopeBackup: db

; Backup for if the sweep is changed by FX channel
PU1MuSweepBackup: db

; Backup for if the waveform is changed by FX channel
PU1MuWaveformBackup: db
PU2MuWaveformBackup: db

; Backup for if the wave data is changed by FX channel
WAVMuWaveDataBackup: db

; Backup for if the length data is changed by FX channel
PU1MuLengthBackup: db
PU2MuLengthBackup: db
NOIMuLengthBackup: db

; Tables
; high nibble (7-4) = Table ID; low nibble (3-0) = Table Position
PU1MuTable: db
PU1FXTable: db
PU2MuTable: db
PU2FXTable: db
WAVMuTable: db
WAVFXTable: db
NOIMuTable: db
NOIFXTable: db

; Slide/vibrato active flags
VibratoOrSlideActive: db ; 1 if either is active, 0 if not; bit 7 = PU1Mu, ..., 0 = NOIFX
VibratoActive: db        ; 1 if vibrato, 0 if slide; as above

; Slide destinations or vibrato bases
PU1MuSlideDestOrVibratoBase: db
PU1FXSlideDestOrVibratoBase: db
PU2MuSlideDestOrVibratoBase: db
PU2FXSlideDestOrVibratoBase: db
WAVMuSlideDestOrVibratoBase: db
WAVFXSlideDestOrVibratoBase: db
NOIMuSlideDestOrVibratoBase: db
NOIFXSlideDestOrVibratoBase: db

; Slide or vibrato amounts
; high nibble (7-4) = Mu; low nubble (3-0) = FX
PU1SlideOrVibratoAmount: db
PU2SlideOrVibratoAmount: db
WAVSlideOrVibratoAmount: db
NOISlideOrVibratoAmount: db

SoundVariableBytes EQU 86

SECTION "SoundEngine", ROM0
FrequencyTable:
    INCBIN "Sound/FrequencyTable"

InitSoundEngine::
    PushWRAMBank
    SwitchWRAMBank BANK(MuTempo)

    xor a
    ld b, SoundVariableBytes
    ld hl, MuTempo
.Loop
    ld [hl+], a
    dec b
    jr nz, .Loop

    PopWRAMBank
    ret

PlayMusic::
; TODO: Start playing some sweet music
; Assume that a contains the song to be played
    push hl
    push bc

    ld hl, MusicPointers
    ld c, a
    ld b, 0

    sla16 bc, 3
    add a, c
    jr nc, .Continue

.Carry
    inc b

.Continue
    ld c, a
    add hl, bc ; hl now contains the address to the song data

    PushROMBank
    SwitchROMBank BANK(MusicPointers)

    PushWRAMBank
    SwitchWRAMBank BANK(MuAddressBank)

.GetBank
    ld a, [hl+]
    ld [MuAddressBank], a

.PU1
    ld a, [hl+]
    ld [PU1MuAddress], a
    ld a, [hl+]
    ld [PU1MuAddress + 1], a

.PU2
    ld a, [hl+]
    ld [PU2MuAddress], a
    ld a, [hl+]
    ld [PU2MuAddress + 1], a

.WAV
    ld a, [hl+]
    ld [WAVMuAddress], a
    ld a, [hl+]
    ld [WAVMuAddress + 1], a

.NOI
    ld a, [hl+]
    ld [NOIMuAddress], a
    ld a, [hl]
    ld [NOIMuAddress + 1], a

.CleanUp
    ld a, 1
    ld [MuCounter], a
    ld [PU1MuWait], a
    ld [PU2MuWait], a
    ld [WAVMuWait], a
    ld [NOIMuWait], a

    PopWRAMBank
    PopROMBank
    pop bc
    pop hl
    ret

PlaySFX::
; TODO: Start playing a sound effect
    ret

SoundEngineUpdate::
; Updates the music and FX into the next frame.
; Assume that all registers are destroyed after the call.
    PushWRAMBank
    SwitchWRAMBank BANK(MuTempo)
    PushROMBank

CheckIfMusicIsActive
    ld a, [MuAddressBank]
    or a
    jr nz, UpdateMusic

CheckIfSFXIsActive
    ld a, [FXAddressBank]
    or a
    jr nz, UpdateSFX
    
FinishSoundEngineUpdate
    PopROMBank
    PopWRAMBank
    ret


UpdateMusic
    SwitchROMBank [MuAddressBank]

    ld a, [MuCounter]
    dec a
    ld [MuCounter], a
    jr nz, CheckIfSFXIsActive

    ld a, [MuTempo]
    ld [MuCounter], a
    ld hl, PU1MuAddress + 1
    ld c, 0

.ChannelLoop
    ld a, [hl+]
    inc hl
    or a
    jr z, .PreIncContinueLoop

    ld a, [hl+]
    or a
    jr nz, .ContinueLoop

    call UpdateChannel
    jr .ContinueLoop

.PreIncContinueLoop
    inc hl
.ContinueLoop
    inc hl
    inc c
    ld a, c
    cp 4
    jr nz, .ChannelLoop


    jr CheckIfSFXIsActive

UpdateSFX
    SwitchROMBank [FXAddressBank]

    ld a, [FXCounter]
    dec a
    ld [FXCounter], a
    jr nz, FinishSoundEngineUpdate
    ld b, a

.Continue
    ; Implement
    ld a, 4


    jr FinishSoundEngineUpdate


UpdateChannel
; b = counter (e.g. MuCounter)
; c = channel no. (0 = PU1Mu, 7 = NOIFX)
; NOTE: Modifies de; push it to the stack if needed
    push hl
    push bc

    ; TODO: Implement!

.CheckCounter
    ld b, a
    or a
    jr nz, .CheckVibratoAndSlide

    ld hl, PU1MuWait
    ld b, 0
    add hl, bc

    ld a, [hl]
    dec a
    jr z, .GetNextCommand
    ld [hl], a

.CheckVibratoAndSlide
    ; TODO: Implement

.FinishUp
    pop bc
    pop hl

    ret


.GetNextCommand
; c = channel no. (as UpdateChannel)
    call CalculateAddress

.GetNextCommandLoop
.CheckNoteCommand
    ld a, [hl+]
    cp CommandByte
    jr nc, .CheckEnvelopeCommand

.NoteCommand
    ; TODO: Deal with $00
    ; TODO: Transpose the note as necessary
    push hl
    ld hl, FrequencyTable - 2

    ld d, 0
    ld e, a
    sla e
    add hl, de

; Putting the frequency into de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a

; Calculating the destination address
; TODO: Sort out noise channel
    ld b, c
    srl c ; a is now 0-3, for each channel

.PU1Check
    inc c
    dec c
    jr nz, .PU2Check

.PU1Destination
    ld c, (NR13 & $FF)
    jr .WriteToDestination

.PU2Check
    dec c
    jr nz, .WAVCheck

.PU2Destination
    ld c, (NR23 & $FF)
    jr .WriteToDestination

.WAVCheck
    dec c
    jr nz, .CleanUp ; TODO: Change this to somewhere sensible!

.WAVDestination
    ld c, (NR33 & $FF)

.WriteToDestination
    ld a, e
    ld [$FF00+c], a
    inc c
    ld a, d
    set 7, a ; Restart sound; TODO: Set only if necessary
    ld [$FF00+c], a

.CleanUp
    ld c, b
    pop hl

    ld a, [hl+]

    push hl
    ld hl, PU1MuWait
    ld b, 0
    add hl, bc

    ld [hl], a
    pop hl

    jr .FinishCommandLoop
    

.CheckEnvelopeCommand
    ;ld b, b
    ;jr .CheckNoteCommand

    ; TODO: Implement!


.CheckTempoCommand
    cp TempoByte
    jr nz, .CheckNoteCommand

.Tempo
    bit 2, a
    jr nz, .FXTempo

.MuTempo
    ld a, [hl+]
    ld [MuTempo], a
    ld [MuCounter], a
    jr .GetNextCommandLoop

.FXTempo
    ld a, [hl+]
    ld [FXTempo], a
    ld [FXCounter], a
    jr .GetNextCommandLoop


.CheckTableCommand
    ld b, b
    jr .CheckNoteCommand
    ; cp TableByte
    ; jr nz, .CheckNoteCommand

.FinishCommandLoop
    push hl             ; Writing the new address into memory
    ld hl, PU1MuAddress
    ld b, 0
    add hl, bc
    pop de

    ld a, e
    ld [hl+], a
    ld a, d
    ld [hl], a

    jr .CheckVibratoAndSlide


CalculateAddress
; Returns with the address in hl
; c = channel no. (as UpdateChannel)
; Modifies hl, b, and a
    ld hl, PU1MuAddress
    ld b, 0
    add hl, bc

    ld a, [hl+] ; LSB
    ld b, a
    ld a, [hl]  ; MSB

    ld h, a
    ld l, b
    ret
