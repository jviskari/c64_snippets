;subber      subtract multi byte value
;=======================================

subber  sec             ;set carry
-       lda (TOPNT),y   ;fetch byte
        sbc (FMPNT),y   ;subtract byte from other value
        sta (TOPNT),y   ;store result
        iny             ;increment index pointer
        dex             ;decrement counter
        bne -           ;not zero, continue
        rts 
        
