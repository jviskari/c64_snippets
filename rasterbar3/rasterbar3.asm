*=$0801
          .byte $0b,$08,$00,$00,$9e,$32,$30,$36,$34,$00,$00,$00

*= $810

                    jsr $e544          ; clear screen
                    sei                ; disable interrupts

loop                lda xposa
                    cmp $d012
                    bne *-3            ; we're going to loop until the raster hits the start position
                    jsr wait           ; prevent tearing 
                    lda #2             ; set our new color
                    sta $d020
                    sta $d021          ; set the new colors

                    lda xposb
                    cmp $d012
                    bne *-3            ; wait for the end of the raster
                    jsr wait           ; tearing

                    lda #1             ; main color
                    sta $d020
                    sta $d021          ; set colors

                    jmp loop           ; back to the loop

; --------------------
; wait subroutine
; --------------------
wait                
                .rept 22
                    nop
                .endrept

                    rts


; our variables, set to the screen positions we want the raster to start and stop at
xposa               .byte $49
xposb               .byte $51 