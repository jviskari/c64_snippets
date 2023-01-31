;complm     complement multi byte value
;=======================================

complm  sec         ;set carry for two's complement
-       lda #$ff    ;load #$ff for two's complement operation
        eor VALUE,x ;complement byte
        adc #$00    ;if carry=1, two's complement
        sta VALUE,x ;store byte to memory
        inx         ;advance memory pointer
        dey         ;decrement byte conter
        bne -       ;not zero, continue
        rts         ;return