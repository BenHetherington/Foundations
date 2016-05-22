; load from address in 16-bit register to other 16 bit register
ld16ra:	MACRO
__r1    EQUS    STRSUB("\1",1,1)
__r2    EQUS    STRSUB("\1",2,1)
ld __r2,[\2]
inc \2
ld __r1,[\2]
dec \2
PURGE 	__r1
PURGE 	__r2
ENDM
; load from 16-bit register to address in other 16 bit register
ld16ar:	MACRO
__r1    EQUS    STRSUB("\2",1,1)
__r2    EQUS    STRSUB("\2",2,1)
ld [\1],__r2
inc \1
ld [\1],__r1
dec \1
PURGE 	__r1
PURGE 	__r2
ENDM
; load from address to 16 bit register (not HL)
ld16r:	MACRO
__r1    EQUS    STRSUB("\1",1,1)
__r2    EQUS    STRSUB("\1",2,1)
push hl
ld hl, \2
ld __r2,[hl]
inc hl
ld __r1,[hl]
pop hl
PURGE 	__r1
PURGE 	__r2
ENDM
; load from 16-bit register to address (not HL)
ld16a:	MACRO
__r1    EQUS    STRSUB("\2",1,1)
__r2    EQUS    STRSUB("\2",2,1)
push hl
ld hl,\1
ld [hl],__r2
inc hl
ld [hl],__r1
pop hl
PURGE 	__r1
PURGE 	__r2
ENDM
; load from 16-bit register to 16-bit register
ld16rr:	MACRO
__r1a	EQUS 	STRSUB("\1",1,1)
__r1b 	EQUS 	STRSUB("\1",2,1)
__r2a	EQUS 	STRSUB("\2",1,1)
__r2b 	EQUS 	STRSUB("\2",2,1)
ld __r1a,__r2a
ld __r1b,__r2b
PURGE 	__r1a
PURGE 	__r1b
PURGE 	__r2a
PURGE 	__r2b
ENDM
; 16-bit complement
cpl16:	MACRO
__r1    EQUS    STRSUB("\1",1,1)
__r2    EQUS    STRSUB("\1",2,1)
push af
ld a,__r1
cpl
ld __r1,a
ld a,__r2
cpl
ld __r2,a
pop af
PURGE 	__r1
PURGE 	__r2
ENDM
