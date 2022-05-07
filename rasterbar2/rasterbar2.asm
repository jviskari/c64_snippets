; (c) J.Viskari 2018 - 2022
; 0 SYS2064

*=$0801
          .byte $0b,$08,$00,$00,$9e,$32,$30,$36,$34,$00,$00,$00
*=$810
          LDA #$10 
          STA counter 

          JSR init
infinite_loop
          LDA #0      
-
          CMP $D012     
          BNE -    
          DEC counter
          BNE infinite_loop 
          LDA #$10 
          STA counter
          JSR update_lut          

          JMP infinite_loop
counter
          .byte 00
ypos       
          .byte $64
        

irq_handler
          SEI

          LDX  #$00      

-
          LDA $d012
          CLC                 ;make sure carry is clear
          ADC #$01            ;add lines to wait
          CMP $d012
          BNE *-3             ;check *until* we're at the target raster line
    
          LDA work_mem,X     ;get color
          JSR wait
          STA $D020        
          STA $D021     

          INX  
          CPX #$41     
          BNE -    

          ASL $D019     


          ;INC ypos
          ;LDA ypos                 ;set raster interrupt
          ;STA $D012 

          JMP $EA7E     

wait                
      .rept 22
          NOP
      .endrept

          RTS
;===============================================================================
update_lut
          LDX  #$00      
          LDY  #$FF                    ;value gets modified do not move!
_loop
          LDA  lut2,Y   
          STA  work_mem,X   

          LDA  lut2+2,Y   
          STA  work_mem+$08,X   

          LDA  lut2+4,Y   
          STA  work_mem+$10,X   

          LDA  lut2+6,Y   
          STA  work_mem+$18,X   

          LDA  lut2+8,Y   
          STA  work_mem+$20,X   

          LDA  lut2+10,Y   
          STA  work_mem+$28,X   

          LDA  lut2+12,Y   
          STA  work_mem+$30,X   

          LDA  lut2+14,Y   
          STA  work_mem+$38,X   

          INY
          INX
          CPX  #$8       
          BNE  _loop     
          DEC  _loop-1                    ;self modifying code

          RTS
;===============================================================================

; color map
;*=$C300
.align $100
lut2
          .byte $09,$04,$0A,$0F,$07,$01,$01,$01,$01,$01,$01,$07,$0F,$0A,$04,$09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
          .byte $09,$08,$0A,$0F,$07,$01,$01,$01,$01,$01,$01,$07,$0F,$0A,$08,$09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
          .byte $06,$04,$0E,$03,$0D,$01,$01,$01,$01,$01,$01,$0D,$03,$0E,$04,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
          .byte $0B,$0C,$0F,$01,$01,$0F,$0C,$0B,$00,$00,$00,$00,$00,$00,$00,$00,$08,$0A,$0F,$07,$01,$07,$0F,$0A,$08,$00,$00,$00,$00,$00,$00,$00
          .byte $00,$00,$00,$00,$00,$00,$00,$00,$09,$05,$0F,$07,$01,$01,$07,$0F,$05,$09,$00,$00,$00,$00,$00,$00,$09,$0B,$08,$0C,$0F,$07,$01,$01
          .byte $01,$01,$07,$0F,$0C,$08,$0B,$09,$00,$00,$00,$00,$00,$00,$00,$00,$09,$02,$0A,$0F,$07,$01,$07,$0F,$0A,$02,$09,$00,$00,$00,$00,$00
          .byte $06,$0E,$03,$01,$01,$03,$0E,$06,$00,$00,$00,$00,$00,$00,$00,$00,$09,$02,$08,$0A,$0F,$07,$01,$01,$01,$01,$07,$0F,$0A,$08,$02,$09
          .byte $00,$00,$00,$00,$00,$00,$00,$00,$0B,$0C,$0F,$0D,$01,$0D,$0F,$0C,$0B,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
          .byte $09,$04,$0A,$0F,$07,$01,$01,$01,$01,$01,$01,$07,$0F,$0A,$04,$09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
          .byte $09,$08,$0A,$0F,$07,$01,$01,$01,$01,$01,$01,$07,$0F,$0A,$08,$09,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
          .byte $06,$04,$0E,$03,$0D,$01,$01,$01,$01,$01,$01,$0D,$03,$0E,$04,$06,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
          .byte $0B,$0C,$0F,$01,$01,$0F,$0C,$0B,$00,$00,$00,$00,$00,$00,$00,$00,$08,$0A,$0F,$07,$01,$07,$0F,$0A,$08,$00,$00,$00,$00,$00,$00,$00
          .byte $00,$00,$00,$00,$00,$00,$00,$00,$09,$05,$0F,$07,$01,$01,$07,$0F,$05,$09,$00,$00,$00,$00,$00,$00,$09,$0B,$08,$0C,$0F,$07,$01,$01
          .byte $01,$01,$07,$0F,$0C,$08,$0B,$09,$00,$00,$00,$00,$00,$00,$00,$00,$09,$02,$0A,$0F,$07,$01,$07,$0F,$0A,$02,$09,$00,$00,$00,$00,$00
          .byte $06,$0E,$03,$01,$01,$03,$0E,$06,$00,$00,$00,$00,$00,$00,$00,$00,$09,$02,$08,$0A,$0F,$07,$01,$01,$01,$01,$07,$0F,$0A,$08,$02,$09
          .byte $00,$00,$00,$00,$00,$00,$00,$00,$0B,$0C,$0F,$0D,$01,$0D,$0F,$0C,$0B,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;lut2_end
.align $100
work_mem
;this is not needed after start
init
          SEI
          LDA  #$01      
          STA  $D01A     
          STA  $DC0D     
          LDA  #$1B      
          STA  $D011     
          STA  $D012     
          LDA  #<irq_handler
          STA  $0314     
          LDA  #>irq_handler
          STA  $0315

          ASL  $D019     
          LDA  ypos                 ;set raster interrupt
          STA  $D012            

          CLI
 
          RTS


;*=work_mem+$1FF
;          .byte $00
;work_mem_end;