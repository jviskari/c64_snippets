; movind    move memory area
;=======================================
; TOPNT: zero page pointer to destionation
; FMPNT: zero page pointer to source
; x: length of area
; 

movind  ldy $#0         ;initialize index pointer
-       lda (FMPNT),y   ;fetch byte to transfer
        sta (TOPNT),y   ;store byte in new location
        iny             ;advance index pointer
        dex             ;decrement byte counter
        bne -           ;not zero continue
        rts             ;return