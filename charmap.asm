; Special characters (must be > $E0, apart from "\\")
charmap "\\",   $00 ; End of string. Return to code.
charmap "~",    $FF ; Wait.
charmap "\n",   $FE ; Newline
charmap "\t",   $FD ; Tab (move forwards by eight pixels)
charmap "`",    $FC ; Pause for a frame
charmap "_`_",  $FB ; Pause for multiple frames, e.g. db "_`_",n (p = no. of frames)
charmap "^",    $FA ; Pixel advance (move forwards by one pixel)
charmap " ",    $F9 ; Space (move forwards by four pixels)
charmap "§",    $F8 ; Set settings, e.g. db "_@_",s (settings byte)
charmap "_@_",  $F4 ; Set palette, e.g. db "_@_",p,l,h (p = palette no., l = low byte, h = high byte)
charmap "_#3_", $F3 ; Change palette to #3
charmap "_#2_", $F2 ; Change palette to #2
charmap "_#1_", $F1 ; Change palette to #1
charmap "_#0_", $F0 ; Change palette to #0

; Uppercase
charmap "A", $01
charmap "B", $02
charmap "C", $03
charmap "D", $04
charmap "E", $05
charmap "F", $06
charmap "G", $07
charmap "H", $08
charmap "I", $09
charmap "J", $0A
charmap "K", $0B
charmap "L", $0C
charmap "M", $0D
charmap "N", $0E
charmap "O", $0F
charmap "P", $10
charmap "Q", $11
charmap "R", $12
charmap "S", $13
charmap "T", $14
charmap "U", $15
charmap "V", $16
charmap "W", $17
charmap "X", $18
charmap "Y", $19
charmap "Z", $1A

; Numbers
charmap "0", $1B
charmap "1", $1C
charmap "2", $1D
charmap "3", $1E
charmap "4", $1F
charmap "5", $20
charmap "6", $21
charmap "7", $22
charmap "8", $23
charmap "9", $24

; Lowercase
charmap "a", $25
charmap "b", $26
charmap "c", $27
charmap "d", $28
charmap "e", $29
charmap "f", $2A
charmap "g", $2B
charmap "h", $2C
charmap "i", $2D
charmap "j", $2E
charmap "k", $2F
charmap "l", $30
charmap "m", $31
charmap "n", $32
charmap "o", $33
charmap "p", $34
charmap "q", $35
charmap "r", $36
charmap "s", $37
charmap "t", $38
charmap "u", $39
charmap "v", $3A
charmap "w", $3B
charmap "x", $3C
charmap "y", $3D
charmap "z", $3E

; Symbols
charmap ".", $3F
charmap ",", $40
charmap "'", $41
charmap "“", $42
charmap "”", $43
charmap ":", $44
charmap ";", $45
charmap "!", $46
charmap "(", $47
charmap ")", $48
charmap "?", $49
charmap "/", $4A
charmap "*", $4B
charmap "+", $4C
charmap "-", $4D
charmap "=", $4E
charmap "_", $4F
charmap "&", $50
charmap "£", $51

; Controller symbols
charmap "_(A)_", $52
charmap "_(B)_", $53
charmap "_DPad_", $54
charmap "_up_", $55
charmap "_down_", $56
charmap "_left_", $57
charmap "_right_", $58

; Danglers
charmap "‡g‡", $59 ; (alt-shift-7)
charmap "‡p‡", $5A ; (alt-shift-7)
charmap "‡q‡", $5B ; (alt-shift-7)

; Corner tiles
NextTextPromptArrow EQU $5C
SaveAnim EQU $5D
LinkAnim EQU $60
