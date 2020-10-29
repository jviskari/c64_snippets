MAIN_PROG  = $810
GREEN_PROG = $1000
WHITE_PROG = $2000

GREEN = 5
WHITE = 1

.virtual $d020	; base address
    screen  .block
        background .byte ?
        border .byte ?
        .bend
.endv

setcolor .macro
        lda #\1
        sta screen.background
        sta screen.border
        .endm

basic_start .macro
             *=$801
             .byte $0b, $08, $01, $00, $9e
             .text \1
             .byte $00
             .endm
