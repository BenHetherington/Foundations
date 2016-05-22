; Colour Definitions
WhiteColour EQUS "$FF, $7F"
RedColour   EQUS "$1F, $00"
BlueColour  EQUS "$00, $FF"
GreenColour EQUS "$E0, $03"

SpecialCharactersLimit EQU $80
BiggestSpecialCharacter EQU $8F

TileID EQU $26
TilesPosition EQU (TileID << 4) + $9000
TilesPerLine EQU $120
