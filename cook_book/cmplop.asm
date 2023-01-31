;cmplop     compare bytes
;=======================================

cmplop  dey             ;decrement pointer
        beq cmpret      ;if zero both values equal
        lda (FMPNT),y   ;fetch compare data
        cmp (TOPNT),y   ;compare to indicated data
        beq cmplop      ;if equal, continue
cmpret  rts             ;return with C and Z flags conditioned