INCLUDE "Strings/charmap.inc"

SECTION "Assembly Date and Time String", ROMX

AssemblyString::
    db "Last assembled:\n"
    db "{__DATE__}", "\n"
    db "{__TIME__}", "~\\"
