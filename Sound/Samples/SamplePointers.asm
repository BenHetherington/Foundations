SECTION "Sample Pointers", ROMX

; Contains pointers to the samples.
; Each sample's entry is eight bytes long, and arranged as follows:
;  db SampleBank
;  dw SampleData
;  dw SampleLength (in samples)
;  dw WaveChannelFreq (NR34/35 value)
;  db TMAValue (for modifying the timer)

SamplePointers::
.Luc
    ; ID = 00
    ; Test sample! I dunno if we'd get away with keeping this...
    ; Default sample rate = 4096 Hz
    db BANK(Luc)
    dw Luc
    dw 2693 + $101 ; Length
    dw 1536 ; 128 Hz
    db $00 ; TODO: Set!
    