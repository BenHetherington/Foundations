InitSoundEngine::
    ; TODO: Replace with generic memory-clearing function?

    xor a
    ld b, SoundVariableBytes
    ld hl, MuTempo
.Loop
    ld [hl+], a
    dec b
    jr nz, .Loop

    ; TODO: Reset the sound hardware!

    xor a
    ; fallthrough

PlayMusic::
; Assume that a contains the song to be played
    push hl
    push bc
    push de

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

    ld d, 8
    ld bc, MuAddressBank

.LoadBank
    ld a, [hl+]
    ld [bc], a
    inc bc
    inc bc

.AddressLoop
    ld a, [hl+]
    ld [bc], a
    inc bc
    dec d
    jr z, .SetInitialWait

    bit 0, d
    jr nz, .AddressLoop

.SkipSFX
    inc bc
    inc bc

    jr .AddressLoop


.SetInitialWait
    ld a, 1
    ld [MuCounter], a
    ld [PU1MuWait], a
    ld [PU2MuWait], a
    ld [WAVMuWait], a
    ld [NOIMuWait], a

.ResetPan
    ld a, $FF
    ld [NR51], a

.CleanUp
    PopROMBank
    pop de
    pop bc
    pop hl
    ret

PlaySFX::
; TODO: Start playing a sound effect
    ret

SoundEngineUpdate::
; Updates the music and FX into the next frame.
; Assume that all registers are destroyed after the call.
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
    ret
