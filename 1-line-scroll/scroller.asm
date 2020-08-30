''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


; 10 SYS2064

*=$0801

        BYTE    $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00

*=$810
 
chrout = $ffd2
clr = $93 

shift   = $bf
xscroll = $be
pt_lo = $fb
pt_hi = $fc
screen_row1 = $400

        lda #clr         ; A = {CLR}
        jsr chrout
   
        jsr init_irq
        jsr scroller
         
        jsr *

scroller
      
@restart
        lda #<scrolltext
        sta $fb
        lda #>scrolltext
        sta $fc  

@wait_shift
        lda shift                ;shift chars when 7
        eor #7
        bne @wait_shift

        sta shift 
        tax         
        ldy #39
@shift_chars                 
        lda screen_row1+1,x
        sta screen_row1,x             ;put to screen
        inx                      ;x is destionation
        dey                      ;did we copy 39 characters
        bne @shift_chars         ;next char
@new_char
        ;ldy #0                  ;y is 0 already
        lda ($fb),y
        beq @restart             ;restart on '@'
        sta screen_row1+39            ;update last character
        inc $fb
        bne @wait_shift
        inc $fc
        jmp @wait_shift          ;restart
;------------------------------------------------------------------
irq     
        dec $d019        ; acknowledge IRQ

        lda #7
        tay         
        and $d016
        sbc #1
        bpl @store
        sty shift
        tya  
@store       
        sta $d016         
 
        jmp $ea81        ; return to kernel interrupt routine
        
align 256
scrolltext 

        text 'THERES SOMETHING INSIDE ME'
        text 'ITS, ITS COMING OUT'
        text 'I FEEL LIKE KILLING YOU'
        text 'LET LOOSE THE ANGER, HELD BACK TOO LONG'
        text 'MY BLOOD RUNS COLD'
        text 'THROUGH MY ANATOMY, DWELLS ANOTHER BEING'
        text 'ROOTED IN MY CORTEX, A SERVANT TO ITS BIDDING'
        text 'BRUTALITY NOW BECOMES MY APPETITE'
        text 'VIOLENCE IS NOW A WAY OF LIFE'
        text 'THE SLEDGE MY TOOL TO TORTURE'
        text 'AS IT POUNDS DOWN ON YOUR FOREHEAD'
        text 'EYES BULGING FROM THEIR SOCKETS'
        text 'WITH EVERY SWING OF MY MALLET'
        text 'I SMASH YOUR FUCKING HEAD IN, UNTIL BRAINS SEEP IN
        text 'THROUGH THE CRACKS, BLOOD DOES LEAK'
        text 'DISTORTED BEAUTY, CATASTROPHE'
        text 'STEAMING SLOP, SPLATTERED ALL OVER ME'
        text 'LIFELESS BODY, SLOUCHING DEAD'
        text 'LECHEROUS ABCESS, WHERE YOU ONCE HAD A HEAD'
        text 'AVOIDING THE PROPHECY OF MY NEW FOUND LUST'
        text 'YOU WILL NEVER LIVE AGAIN, SOON YOUR LIFE WILL END'
        text 'ILL SEE YOU DIE AT MY FEET,…'

endtext byte 0

init_irq
        sei         ; set interrupt disable flag
        ldy #$7f    ; $7f = %01111111
        sty $dc0d   ; Turn off CIAs Timer interrupts
        sty $dd0d   ; Turn off CIAs Timer interrupts
        lda $dc0d   ; cancel all CIA-IRQs in queue/unprocessed
        lda $dd0d   ; cancel all CIA-IRQs in queue/unprocessed
        lda #$01    ; Set Interrupt Request Mask...
        sta $d01a   ; ...we want IRQ by Rasterbeam
        lda #<irq   ; point IRQ Vector to our custom irq routine
        ldx #>irq 
        sta $314    ; store in $314/$315
        stx $315   
        lda #$00    ; trigger first interrupt at row zero
        sta $d012
        cli         ; clear interrupt disable flag

        rts




