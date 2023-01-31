;rotatr     rotate x bytes right
;=======================================
rotatl  clc         ;clear the carry
rotr    ror VALUE,x ;rotate byte ror
        dey         ;decrement counter
        bne morrtr  ;not zero, continue
        rts         ;return
morrtr  inx         ;advance pointer
        jmp rotr    ;continue rotate right