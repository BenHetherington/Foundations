SECTION "Sample Pointers", ROMX

; Contains pointers to the samples.
; Each sample's entry is eight bytes long, and arranged as follows:
;  db SampleBank
;  dw SampleData
;  dw SampleLength (in samples) + $101 (due to programming quirk)
;  db TMAValue (timer value in Normal Speed Mode); used to determine frequency

Sample: MACRO
    db BANK(\1)
    dw (\1)
    dw ((\2) + $101) & $FFFF
    db (\3)
ENDM

SamplePointers::
.Luc
    ; ID = 00
    ; Test sample! I dunno if we'd get away with keeping this...
    ; Default sample rate = 4096 Hz
    Sample Luc, 2693, 32


.Chord
    ; ID = 01
    ; An Fmaj7 with a D5 in the bass. Potentially part of a sad song or game over music (loop)
    Sample Chord, 4096, 64 ; 223
