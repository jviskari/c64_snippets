
ROWS=25
CHARS=40

* = $c000

             inc $d020
             lda #0
             sta row
             jsr hline_lr

             inc $d020
             lda #0
             sta row             
             jsr vline_ud

             inc $d020
             lda #24
             sta row             
             jsr hline_rl
             lda #24
             sta row              
             inc $d020
             jsr vline_du             
             jmp *


hline_lr 
             
             ldy #0             ;start point
             lda #1             ;step 
             sta num_add 
             ldx row            ;row
             jsr set_line_ptr 
             lda chr 
             ldx #CHARS         ;number of characters

             jsr fill_add       ;left->right

             rts 

vline_ud 
             ldy #39             ;start point
             lda #40             ;step
             sta num_add 
             ldx row 
             jsr set_line_ptr 
             lda chr 
             ldx #ROWS 

             jsr fill_add       ;up-->down 

             rts

hline_rl 
             
             ldy #39             ;start point
             lda #1             ;step 
             sta num_add 
             ldx row            ;row
             jsr set_line_ptr 
             lda chr 
             ldx #CHARS         ;number of characters

             jsr fill_sub       ;left->right

             rts 

vline_du 
             ldy #0            ;start point
             lda #40            ;step
             sta num_add 
             ldx row 
             jsr set_line_ptr 
             lda chr 
             ldx #ROWS 

             jsr fill_sub       ;up-->down 

             rts





chr         .byte $40
row         .byte $00
col         .byte $00
num_add     .byte ?

fill_add
            pha             ;store char

            clc             ;clear carry
            tya             ;move column to a
            adc $fa         ;add column to low address
            sta $fa         ;update pointer
            ldy #0          ;set y=0

            pla             ;restore char

        -   sta ($fa),y     ;store char from reg a
            pha             ;store a
            lda $fa         ;fetch addres low
            clc             ;clear carry
            adc num_add     ;add step   
            sta $fa         ;store address low
            pla             ;restore a 
            bcc +           
            inc $fb         ;add carry to address high
;---------------------------------------
        +   jsr delay
;---------------------------------------
            dex             ;decrease counter 
            bne -           ;if not zero, continue

            rts

fill_sub
            pha             ;store char

            clc             ;clear carry
            tya             ;move column to a
            adc $fa         ;add column to low address
            sta $fa         ;update pointer
            ldy #0          ;set y=0

            pla             ;restore char

        -   sta ($fa),y     ;store char from reg a
            pha             ;store a
            lda $fa         ;fetch addres low
            sec             ;set carry
            sbc num_add     ;add step   
            sta $fa         ;store address low
            pla             ;restore a
            bcs +           
            dec $fb         ;borrow
;---------------------------------------
        +   jsr delay
;---------------------------------------
            dex             ;decrease counter 
            bne -           ;if not zero, continue

            rts            


;x row
set_line_ptr
            lda line_lo,x
            sta $fa
            lda line_hi,x
            sta $fb

            rts


delay
            pha
            lda #$00 
            sta lo_cntr
            sta hi_cntr

-           clc

            lda lo_cntr
            adc #1
            sta lo_cntr
            lda hi_cntr
            adc #0
            sta hi_cntr
            lda #10
            cmp hi_cntr 
            bne -
            pla
            rts

lo_cntr .byte 0
hi_cntr .byte 0

line_lo
.byte <range(1024, 2048, 40)
line_hi 
.byte >range(1024, 2048, 40) 
