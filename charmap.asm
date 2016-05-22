; Special characters (must be > $80)
charmap "\\",    $80 ; End of string. Return to code.
charmap "~",     $81 ; Wait.
charmap "\n",    $82 ; Newline
charmap "\t",    $83 ; Tab (move forwards by eight pixels)
charmap "`",     $84 ; Pause for a frame
charmap "_`_",   $85 ; Pause for multiple frames, e.g. db "_`_",n (p = no. of frames)
charmap "^",     $86 ; Pixel advance (move forwards by one pixel)
charmap "_EXEC_",$87 ; Call to executable code, e.g. db "_EXEC_",b; dw a (b = bank, a = address)
charmap " ",     $88 ; Space (move forwards by four pixels)
charmap "§",     $89 ; Set settings, e.g. db "_@_",s (settings byte)
charmap "_@_",   $8A ; Set palette, e.g. db "_@_",p,l,h (p = palette no., l = low byte, h = high byte)
charmap "_#0_",  $8B ; Change palette to #0
charmap "_#1_",  $8C ; Change palette to #1
charmap "_#2_",  $8D ; Change palette to #2
charmap "_#3_",  $8E ; Change palette to #3

; Print variables
charmap "_PLAYER_", $8F ; Print player name

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
; TODO: Try not to have the mappings here if possible
charmap "‡g‡", $59 ; (alt-shift-7)
charmap "‡p‡", $5A ; (alt-shift-7)
charmap "‡q‡", $5B ; (alt-shift-7)

; Corner tiles
; TODO: Seperate these out of the normal characters
NextTextPromptArrow EQU $5C
SaveAnim EQU $5D
LinkAnim EQU $60
