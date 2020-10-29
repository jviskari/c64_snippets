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

basic_loader .macro
             *=$801
             ;1sys2064
             .byte $0b, $08, $01, $00, $9e, $32, $30, $36, $34, $00
             .endm
