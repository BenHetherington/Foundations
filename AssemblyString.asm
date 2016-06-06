INCLUDE "Strings/charmap.inc"

SECTION "Assembly Date and Time String", ROM0

AssemblyString::
    db "Last assembled:\n"
    db "{__DATE__}", "\n"
    db "{__TIME__}", "~\\"
