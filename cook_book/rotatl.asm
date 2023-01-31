;rotatl     rotate x bytes left
;=======================================
rotatl  clc         ;clear the carry
rotl    rol VALUE,x ;rotate byte left
        dey         ;decrement counter
        bne morrtl  ;not zero, continue
        rts         ;return
morrtl  inx         ;advance pointer
        jmp rotl    ;continue rotate left