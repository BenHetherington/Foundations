SECTION "Music Pointers",ROMX

; Contains pointers to the music data for each channel.
; Each song's entry is nine bytes long, and consists of a 8-bit bank and four 16-bit pointers
; e.g. db DataBank
;      dw PU1Data
;      dw PU2Data
;      dw WAVData
;      dw NOIData
; Additional metadata, such as tempo and key, should be specified at the start of the PU1 music data.
; If there is no data for a channel, use dw NO_DATA. Bank must be nonzero.

NO_DATA EQU $0000

MusicPointers::
.TestSong
    ; ID = 0
    ; A test song, for sound engine development purposes
    db $01      ; Bank
    dw TempSong ; PU1
    dw TempSongPU2  ; PU2
    dw NO_DATA  ; WAV
    dw NO_DATA  ; NOI

.NullSong
    ; ID = 1
    ; A test song, which stops playback
    db $00     ; Bank
    dw NO_DATA ; PU1
    dw NO_DATA ; PU2
    dw NO_DATA ; WAV
    dw NO_DATA ; NOI
    