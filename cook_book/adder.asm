;adder      add multi byte value
;=======================================

adder   clc             ;clear carry flag
-       lda (TOPNT),y   ;fetch byte
        adc (FMPNT),y   ;add byte to other value
        sta (TOPNT),y   ;store result
        iny             ;increment index pointer
        dex             ;decrement counter
        bne -           ;not zero, continue
        rts 
        
