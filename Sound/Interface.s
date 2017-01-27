InitSoundEngine::
    MemClear StartSoundVars, SoundVariableBytes
    ld a, 8
    ld [FadeOutCounter + 1], a

    ; TODO: Reset the sound hardware!

    ld a, %110
    ld [TAC], a ; 128kHz / 128 = Fires at 512Hz

    ld a, $80
    ld [TMA], a

    xor a
    ld [TIMA], a
    ; fallthrough

PlayMusic::
; Assume that a contains the song to be played
    di
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

.ResetTables
    MemClear PU1MuTable, 2 * 8

.ResetTransposition
    MemClear PU1MuTranspose, 2 * 8

.ResetPan
; TODO: Also set backup pan
    ld a, $FF
    ld [NR51], a

.SilenceChannels
    xor a
    ld [NR12], a
    ld [NR22], a
    ld [NR30], a
    ld [NR42], a

    ld a, $77
    ld [NR50], a

.CleanUp
    PopROMBank
    pop de
    pop bc
    pop hl
    reti

PlaySFX::
; TODO: Start playing a sound effect
    ret

FadeSound::
    ld [FadeOut], a
    ld [FadeOutCounter], a
    ret

SoundEngineUpdate::
; Updates the music and FX for the next tick.
    push af
    push hl
    push bc
    push de
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
    call CheckFade

    PopROMBank
    pop de
    pop bc
    pop hl
    pop af
    reti
