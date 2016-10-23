; Colour Definitions
WhiteColour EQUS "$FF, $7F"
RedColour   EQUS "$1F, $00"
BlueColour  EQUS "$00, $FF"
GreenColour EQUS "$E0, $03"

SpecialCharactersLimit EQU $80
BiggestSpecialCharacter EQU $8F

TileID EQU $25
TilesPosition EQU (TileID << 4) + $9000
TilesPerLine EQU $120

Line1TilePointer EQU TilesPosition + $10
Line2TilePointer EQU TilesPosition + TilesPerLine + $10
Line3TilePointer EQU TilesPosition + (3 * TilesPerLine) + $10
