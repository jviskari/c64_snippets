; clrmem    clear memory area
;=======================================
; TOPNT: zero page pointer to data
; x: length
; 
TOPNT=$fe

clrmem  lda #$0         ;set up zero value
        tay             ;initialize index ptr
-       sta (TOPNT),y  ;clear memory location
        iny             ;advance index pointer
        dex             ;dectrement counter
        bne -   
        rts