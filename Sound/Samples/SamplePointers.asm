SECTION "Sample Pointers", ROMX

; Contains pointers to the samples.
; Each sample's entry is eight bytes long, and arranged as follows:
;  db SampleBank
;  dw SampleData
;  dw SampleLength (in samples) + $101 (due to programming quirk)
;  db TMAValue (timer value in Normal Speed Mode); used to determine frequency

SamplePointers::
.Luc
    ; ID = 00
    ; Test sample! I dunno if we'd get away with keeping this...
    ; Default sample rate = 4096 Hz
    db BANK(Luc)
    dw Luc
    dw 2693 + $101 ; Length
    db 32 ; 128 Hz interrupt
    