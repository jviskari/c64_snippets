
ROWS=25
CHARS=40

* = $c000

             jsr hfill
             jmp *




hfill        
             ldx row
             ldy col 
             jsr set_line_ptr 
             lda chr 
             jsr fill_vert
             rts


vfill
 -           ldx row         
             jsr set_line_ptr 

             lda chr
             ldy #0
             ldx #CHARS

             jsr fill_hor

             inc chr
             ldx row 
             inx 
             stx row
             cpx #ROWS
             bne -
             rts

chr .byte $40
row
    .byte $00
col
    .byte $00


fill_vert
            clc 
        -   sta ($fa),y
            lda $fa
            adc #CHARS
            sta $fa 
            bcc +
            inc $fb 
            clc 
        +   dex
            bne -

            rts


;x : count
;y : column
;a : char
fill_hor
        -   sta ($fa),y
            iny
            dex
            bne -

            rts

;x row
set_line_ptr
            lda line_lo,x
            sta $fa
            lda line_hi,x
            sta $fb

            rts



line_lo
.byte <range(1024, 2048, 40)
line_hi 
.byte >range(1024, 2048, 40) 
