INCLUDE "Sound/Macros.inc"
INCLUDE "lib/AddSub1.inc"
INCLUDE "lib/Shift.inc"
INCLUDE "SubroutineMacros.inc"

CalculateChannelAddress: MACRO
; Given PU1's sound register, calculate the equivalent for the channel in c
; The result will be in a. This *will* modify c, so back it up beforehand!
    ld a, c
; Multiply by 5
    rlca
    srl c
    add a, c

    ld c, ((\1) & $FF)
    add a, c
    ld c, a
ENDM

CalculateBackupAddress: MACRO
; Given the backup memory address for PU1Mu, calculate the equivalent for the channel in c
; The result will be in hl.
    ld a, c

    add a, (\1) % $100
    ld l, a
    adc a, (\1) / $100
    sub a, l
    ld h, a
ENDM

INCLUDE "Sound/Variables.inc"

SECTION "SoundEngine", ROM0
FrequencyTable:
    INCBIN "Sound/FrequencyTable"

INCLUDE "Sound/Interface.s"

UpdateMusic
    SwitchROMBank [MuAddressBank]

    ld hl, MuCounter
    dec [hl]
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
    inc c
    ld a, c
    cp 8
    jr nz, .ChannelLoop


    jr CheckIfSFXIsActive

UpdateSFX
    SwitchROMBank [FXAddressBank]

    ld hl, FXCounter
    dec [hl]
    jr nz, FinishSoundEngineUpdate
    ld b, a

.Continue
    ; Implement
    ld a, 4


    jr FinishSoundEngineUpdate


UpdateChannel
; TODO: In future, perhaps switch bc and de? Major refactoring!
; b = counter (e.g. MuCounter)
; c = channel no. (0 = PU1Mu, 7 = NOIFX)
; NOTE: Modifies de; push it to the stack if needed
    push hl
    push bc

.CheckCounter
    ld b, a
    or a
    jr nz, .CheckVibratoAndSlide

    ld hl, PU1MuWait
    ld b, 0
    add hl, bc

    dec [hl]
    jr z, .GetNextCommand

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
    jp nc, .ProcessCommand ; TODO: Make jr?

.NoteCommand
    ; TODO: Transpose the note as necessary

    and a ; TODO: Make this a command?
    jp z, .KillNote

    push hl
    ld hl, FrequencyTable - 2

    ld d, 0
    ld e, a
    sla e
    add hl, de

; Calculating the destination address
; TODO: Sort out noise channel
    ld b, c

    CalculateChannelAddress NR13

; Putting the frequency into a and d
    ld a, [hl+]
    ld d, [hl]

.WriteLo
    ld [$FF00+c], a
    inc c
    ld a, d
    ; set 6, a ; TODO: Set finite length only if necessary
    jr c, .WriteHi ; TODO: Only skip if necessary

.TriggerNote
    set 7, a ; Restart sound
    ld d, a
    ld a, b ; Backup frequency and place current channel in a

    srl a
    cp 2 ; Check if we're in WAV
    jr z, .TriggerWavNote

.TriggerEnvelopedNote
    ld e, c
    ld c, b

    CalculateBackupAddress PU1MuEnvelopeBackup
    CalculateChannelAddress NR12

    ld a, [hl]
    ld [$FF00+c], a

    ld c, e
    ld a, d
    jr .WriteHi

.TriggerWavNote
    ld a, $80
    ld [NR30], a

    ld a, d

.WriteHi
    ld [$FF00+c], a

.CleanUp
    ld c, b
    pop hl

    ; TODO: Set note length (i.e. NRx1 value!) from PU1MuLength, etc.
    ; TODO: Turn on the wave channel, if necessary!

.GetLength
    ld a, [hl+]
    jp .DoWait


.KillNote
; TODO: Make this a command
; Stops the current note from playing
    ld a, c
    srl a
    cp 2
    jr z, .KillWavNote

    ld d, c
    CalculateChannelAddress NR12

    xor a
    ld [$FF00+c], a

    ld c, d
    jr .GetLength

.KillWavNote
    xor a
    ld [NR30], a
    jr .GetLength

.ProcessCommand
; Deals with the non-note commands
    sla a

; Checking that an invalid character isn't used
    cp BiggestCommand
    ret nc ; TODO: Decide what to do if an invalid command is found

    push hl

; Loading the address in the vector table
    add a, .CommandsVector % $100
    ld l, a
    adc a, .CommandsVector / $100
    sub a, l
    ld h, a

; Loading hl with the address to jump to
    ld a, [hl+]
    ld h, [hl]
    ld l, a

; Boing!
    jp [hl]
    

.Envelope
    ; TODO: Should probably save to the backup envelope in memory, if necessary
    ld d, c ; Backing up c
    CalculateChannelAddress NR12

    pop hl
    ld a, [hl+]
    ld [$FF00+c], a

    ld c, d ; Restoring c
    push hl

    ld d, a
    CalculateBackupAddress PU1MuEnvelopeBackup
    ld [hl], d

    pop hl
    jp .CheckNoteCommand



.Tempo
    pop hl
    bit 2, c
    jr nz, .FXTempo

.MuTempo
    ld a, [hl+]
    ld [MuTempo], a
    ld [MuCounter], a
    jp .GetNextCommandLoop

.FXTempo
    ld a, [hl+]
    ld [FXTempo], a
    ld [FXCounter], a
    jp .GetNextCommandLoop


.Jump
    pop hl
    ld a, [hl+]
    ld h, [hl]
    ld l, a
    jp .GetNextCommandLoop


.Placeholder
    ld b, b
    pop hl
    jp .CheckNoteCommand ; TODO: Make jr?

.MasterVol
    pop hl
    ld a, [hl+]
    ld [NR50], a
    jp .CheckNoteCommand ; TODO: Make jr?

.Pan
    pop hl
    ld a, [hl+]
    ld e, %11101110
    ld d, c
    srl d
    inc d
    dec d ; TODO: Find better way of checking d without affecting a
    jr z, .ModifyPanning

.PanLoop
    rlc e
    rlca
    dec d
    jr nz, .PanLoop

.ModifyPanning
    ld d, a
    ld a, [NR51]
    and a, e
    or a, d
    ld [NR51], a

    jp .CheckNoteCommand ; TODO: Make jr?

.Sweep
    pop hl
    ld a, [hl+]
    ld [NR10], a
    jp .CheckNoteCommand ; TODO: Make jr?

.Waveform
    CalculateBackupAddress PU1MuLength
    ld e, [hl]

    pop hl
    ld d, c
    CalculateChannelAddress NR11

    ld a, [hl+]
    or a, e
    ld [$FF00+c], a

    ld c, d
    jp .CheckNoteCommand ; TODO: Make jr?

.WaveData
    pop hl
    ld a, [hl+]
    push hl

    ld e, a

; Simulating a left-shift by 4 into de
    swap a
    and %00001111
    ld d, a

    ld a, e
    swap a
    and %11110000
    ld e, a

    ld hl, WaveData
    add hl, de

; hl now contains the wave to copy
    ld de, $FF30 ; Wave data location
    push bc

    ld b, $10

    xor a
    ld [NR30], a
    call SmallMemCopyRoutine

    ld a, $80
    ld [NR30], a

    pop bc
    pop hl
    jp .CheckNoteCommand ; TODO: Make jr?

.Length
    ld b, b
    pop hl
    ld a, [hl+]

    cp 63
    jr nc, .InfiniteLength

.FiniteLength
    push hl

    ld e, a
    CalculateBackupAddress PU1MuLength
    ld [hl], e
    pop hl

    ld d, c
    CalculateChannelAddress NR11

    ld a, [$FF00+c]
    and a, %11000000
    or a, e
    ld [$FF00+c], a

    ld c, d
    jr .EndLength

.InfiniteLength
    ; TODO: Handle inf
    ; fallthrough

.EndLength
    jp .CheckNoteCommand ; TODO: Make jr?

.Wait
    pop hl
    ld a, [hl+]

.DoWait
; Also used to wait after each note
    push hl
    ld hl, PU1MuWait
    ld b, 0
    add hl, bc

    ld [hl], a
    pop hl

    jp .FinishCommandLoop


.InlineWaveData
    pop hl
    ld de, $FF30 ; Wave data location
    push bc
    ld b, $10
    call SmallMemCopyRoutine
    pop bc
    jp .CheckNoteCommand ; TODO: Make jr?

.End
    pop hl
    ld hl, 0
    jr .FinishCommandLoop


.FinishCommandLoop
    push hl             ; Writing the new address into memory
    ld hl, PU1MuAddress
    ld b, 0
    sla c
    add hl, bc
    srl c
    pop de

    ld a, e
    ld [hl+], a
    ld a, d
    ld [hl], a

    jp .CheckVibratoAndSlide ; TODO: Make jr?

.CommandsVector
; TODO: Update this as things get implemented
    dw .Envelope        ; Envelope
    dw .Tempo           ; Tempo
    dw .Placeholder     ; Table
    dw .Placeholder     ; Slide
    dw .MasterVol       ; Master vol
    dw .Pan             ; Pan
    dw .Sweep           ; Sweep
    dw .Placeholder     ; Vibrato
    dw .Waveform        ; Waveform
    dw .WaveData        ; Waveform data
    dw .Length          ; Length
    dw .Placeholder     ; Microtuning
    dw .InlineWaveData  ; Inline waveform data
    dw .Jump            ; Jump
    dw .Placeholder     ; Call
    dw .Placeholder     ; Ret
    dw .End             ; End
    dw .Wait            ; Wait

CalculateAddress
; TODO: Does this need to be a subroutine? Replace with 16-bit macro?
; Returns with the address in hl
; c = channel no. (as UpdateChannel)
; Modifies hl, b, and a
    ld hl, PU1MuAddress
    ld b, 0
    sla c
    add hl, bc
    srl c

    ld a, [hl+] ; LSB
    ld h, [hl]  ; MSB
    ld l, a
    ret

WaveData:
    ; ID = $00; Sawtooth Wave (should probably change this from the default LSDJ one!)
    db $8E,$CD,$CC,$BB,$AA,$A9,$99,$88,$87,$76,$66,$55,$54,$43,$32,$31
