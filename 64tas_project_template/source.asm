;*       = $0801
;        .word (+), 2005  ;pointer, line number
;        .null $9e, format("%4d", start);will be sys 4096
;+       .word 0          ;basic line end
;
*       = $1000
start
                
              ldx #0
              nop
              nop
              nop 
-             jsr flash

              jmp - 


flash

              inc      $d020
              inx
              rts 
       
