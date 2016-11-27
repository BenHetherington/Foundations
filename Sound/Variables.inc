SECTION "SoundVariables", WRAM0
; Must define some important sound-y variables

StartSoundVars:
MuTempo: db
MuCounter: db
FXTempo: db
FXCounter: db

FadeOut: db
FadeOutCounter: db

; Waits - equivelent to length of note, decremented and
PU1MuWait: db
PU1FXWait: db
PU2MuWait: db
PU2FXWait: db
WAVMuWait: db
WAVFXWait: db
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

; Note backup, so it can be transposed by a table
PU1MuNoteBackup: db
PU1FXNoteBackup: db
PU2MuNoteBackup: db
PU2FXNoteBackup: db
WAVMuNoteBackup: db
WAVFXNoteBackup: db
NOIMuNoteBackup: db
NOIFXNoteBackup: db

; Backup for if the envelope is changed by FX channel
PU1MuEnvelopeBackup: db
PU1FXEnvelopeBackup: db
PU2MuEnvelopeBackup: db
PU2FXEnvelopeBackup: db
WAVMuEnvelopeBackup: db
WAVFXEnvelopeBackup: db
NOIMuEnvelopeBackup: db
NOIFXEnvelopeBackup: db

; Backup for if the sweep is changed by FX channel
PU1MuSweepBackup: db

; Backup for if the waveform is changed by FX channel
PU1MuWaveformBackup: db
PU2MuWaveformBackup: db

; Backup for if the wave data is changed by FX channel
WAVMuWaveDataBackup: db

; Backup for if the length data is changed by FX channel
PU1MuLength: db
PU1FXLength: db
PU2MuLength: db
PU2FXLength: db
WAVMuLength: db
WAVFXLength: db
NOIMuLength: db
NOIFXLength: db

; TODO: Add pan backup

; Transposition
PU1MuTranspose: db
PU1FXTranspose: db
PU2MuTranspose: db
PU2FXTranspose: db
WAVMuTranspose: db
WAVFXTranspose: db
NOIMuTranspose: db
NOIFXTranspose: db

; Table Pointers
PU1MuTable: dw
PU1FXTable: dw
PU2MuTable: dw
PU2FXTable: dw
WAVMuTable: dw
WAVFXTable: dw
NOIMuTable: dw
NOIFXTable: dw

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

EndSoundVars:

SoundVariableBytes EQU (EndSoundVars - StartSoundVars)
