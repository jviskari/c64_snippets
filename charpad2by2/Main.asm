; Example code for using 2x2 multicolor tilemap exported from Charpad
; (c) Joonas Viskari 2020


; 10 SYS2064

*=$0801

        byte $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00
*=$810

;===============================================================================
main
        lda #COLR_SCREEN
        ldx #COLR_CHAR_MC2
        ldy #COLR_CHAR_MC2
        jsr screen.config

        clc                                     ;start from line 2
        ;sec                                    ;start from line 1
        jsr map.decode
@loop
        jmp @loop


;===============================================================================
SCREEN_PAGE = $04                               ;screen at $0400
COLOR_PAGE  = $d8                               ;color ram at $d800

TILES_IN_ROW = 20


;Zero Page Variables
tile.counter = $fa
screen.ptr_l = $fb
screen.ptr_h = $fc
color.ptr_l  = $fd      
color.ptr_h  = $fe
;===============================================================================
; Routine: map.decode
; Input: Exported Charpad 2x2 multicolor tilemap with per tile color scheme
;        Carry=1 start from line 1, Carry=0 start from line 2
; Output: Screen buffer at $0400
; ZP Vars: Destroys $fa-$fe

;Description
;
;         1 2 ......40
; row 1 : A B
; row 2 : C D
; row 25  . . . . . .

; Screen consists of 40x25 characters, so there's blank line either on the top
; of the screen or in the bottom, if 25 row mode is used.
; 20x12 tilemap with 2x2 tiles can represent the screen area of 40x24 chars.
;
;
;
; 2 lines and 2 columns are processed at the time. In each row screen pointer
; grows by 2 between tiles. Adding 40 means moving one row down.

; a=(x,y)     offset = y*40+x       
; b=(x+1,y)   offset = y*40+x+1
; c=(x,y+1)   offset = (y+1)*40+x   
; d=(x+1,y+1) offset = (y+1)*40+x+1

; Multiplications are not needed if screen pointer is increased by 40 for every
; 20 tiles.
; color RAM is used in a similar fashion.

map.decode
        lda #TILES_IN_ROW
        sta tile.counter        

        lda #0
        pha                             ;map tile index to the top of the stack
        bcs @continue
        lda #40                         ;start from the second row in screen
@continue
        sta screen.ptr_l                ;set pointers to the beginning of page
        sta color.ptr_l

        lda #SCREEN_PAGE                ;screen page
        sta screen.ptr_h

        lda #COLOR_PAGE                 ;color ram page
        sta color.ptr_h

@process_map

        pla                             ;get index from the stack to accu
        pha                             ;put it back for later use
       
        tax                             ;move index to x
        lda map_data,x                  ;get tile index from map to a

        tax                             ;index to x
        lda chartile_colour_data,x      ;get tile color  

;modify code here, if per character colors are needed. Now the tile has 
;common color

        pha                             ;store tile color to stack "D"
        pha                             ;store tile color to stack "C"
        pha                             ;store tile color to stack "B"
        pha                             ;store tile color to stack "A"      

        txa                             ;move index from x to accu for shifting
        asl                             ;multiply by 4 to get tile chars
        asl
        tax

;plot "A"
        ldy #0                          ;first row
        lda chartileset_data,x          ;get character
        inx
        sta (screen.ptr_l),y            ;plot screen (x, y) 
        pla                             ;get color from stack  
        sta (color.ptr_l),y

;plot "B"                               ;next column
        iny
        lda chartileset_data,x          ;get character
        inx
        sta (screen.ptr_l),y            ;plot screen (x+1, y) 
        pla                             ;get "A" from stack  
        sta (color.ptr_l),y

;plot "C"
        ldy #40                         ;next row
        lda chartileset_data,x
        inx
        sta (screen.ptr_l),y            ;plot screen (x, y+1) 
        pla                             ;get "A" from stack  
        sta (color.ptr_l),y

;plot "D"                               ;next column
        iny
        lda chartileset_data,x
        sta (screen.ptr_l),y            ;plot screen (x+1, y+1) 
        pla                             ;get "A" from stack  
        sta (color.ptr_l),y

;did we finish the line ?

        dec tile.counter                ;decrease tile counter. 
        bne @old_line                   ;counter > 0 then same line
        lda #TILES_IN_ROW               ;new line, reload counter
        sta tile.counter                
        lda #42                         ;next column, next line
        bpl @new_line
@old_line
        lda #2                          ;just next columnn
@new_line
        clc                             ;always clear carry before adc
        adc screen.ptr_l                ;update lsb of the pointers
        sta screen.ptr_l        
        sta color.ptr_l       
        bcc @check_end                  ;update MSB of the pointers if carry set
        inc screen.ptr_h
        inc color.ptr_h

@check_end
        clc                             ;clear carry for adc
        pla                             ;get map tile index from stack
        adc #1                          ;increment index
        pha                             ;put it back to stack

        cmp #SZ_MAP_DATA                ;compare to length of MAP data
                                        ; 20x12 (240) cells, 8 bits per cell,
                                        ; total size is 240 ($f0) bytes.
        bne @process_map                ; process next tile

        pla                             ;remove index from the stack
        rts                             ;return

;===============================================================================
;Routine screen.config



screen.config
;screen background
       ;lda #COLR_SCREEN
        sta $d020
        sta $d021

;The color indicated in address 53282/$D022 where the bit pair is "01"
        ;ldx #COLR_CHAR_MC1
        stx $d022

;The color indicated in address 53283/$D023 where the bit pair is "10"
        ;ldy #COLR_CHAR_MC2
        sty $d023


        lda #%0010000
        ora $d016                       ;multicolor character mode
        sta $d016
        lda #$1c                        ;screen $400, chars $3000
        sta $d018


       rts

;===============================================================================
;From Charpad export.
; Character display mode : Multi-colour (MCM).

; Character colouring method : Per-Tile.


; Colour values...

COLR_SCREEN = 9
COLR_CHAR_DEF = 8
COLR_CHAR_MC1 = 15
COLR_CHAR_MC2 = 12


; Quantities and dimensions...

CHAR_COUNT = 109
TILE_COUNT = 19
TILE_WID = 2
TILE_HEI = 2
MAP_WID = 20
MAP_HEI = 12
MAP_WID_CHRS = 40
MAP_HEI_CHRS = 24
MAP_WID_PXLS = 320
MAP_HEI_PXLS = 192


; Data block sizes (in bytes)...

SZ_CHARSET_DATA        = 872
SZ_CHARSET_ATTRIB_DATA = 109
SZ_TILESET_DATA        = 76
SZ_TILESET_ATTRIB_DATA = 19
SZ_MAP_DATA            = 240


; Data block addresses (dummy values)...

ADDR_CHARSET_DATA = $3000            ; block size = $0368, label = 'charset_data'.
ADDR_CHARSET_ATTRIB_DATA = $2000     ; block size = $006d, label = 'charset_attrib_data'.
ADDR_CHARTILESET_DATA = $1000        ; block size = $004c, label = 'chartileset_data'.
ADDR_CHARTILESET_COLOUR_DATA = $4000 ; block size = $0013, label = 'chartileset_colour_data'.
ADDR_MAP_DATA = $5000                ; block size = $00f0, label = 'map_data'.





; * INSERT EXAMPLE PROGRAM HERE! * (Or just include this file in your project).




; CHARSET IMAGE DATA...
; 109 images, 8 bytes per image, total size is 872 ($368) bytes.
*=ADDR_CHARSET_DATA
charset_data

    byte $00,$00,$00,$00,$00,$00,$00,$00,$55,$ff,$55,$55,$55,$55,$aa,$55
    byte $5e,$fd,$5e,$5e,$5e,$5e,$a4,$5e,$ff,$ff,$ff,$00,$ff,$00,$00,$00
    byte $ff,$fc,$fc,$00,$f0,$00,$00,$00,$b5,$7f,$b5,$b5,$b5,$b5,$1a,$b5
    byte $ff,$3f,$3f,$00,$0f,$00,$00,$00,$55,$ff,$55,$00,$aa,$aa,$aa,$a9
    byte $55,$ff,$55,$00,$aa,$aa,$aa,$6a,$57,$55,$55,$00,$55,$ff,$55,$00
    byte $d5,$55,$55,$00,$55,$ff,$55,$00,$40,$80,$b0,$b0,$55,$aa,$b0,$bf
    byte $01,$02,$0e,$0e,$55,$aa,$0e,$fe,$b0,$b0,$b0,$b0,$55,$aa,$b0,$bf
    byte $0e,$0e,$0e,$0e,$55,$aa,$0e,$fe,$b0,$b0,$b0,$b0,$55,$aa,$b0,$bf
    byte $0e,$0e,$0e,$0e,$55,$aa,$0e,$fe,$b0,$b0,$b0,$b0,$55,$aa,$b0,$3f
    byte $0e,$0e,$0e,$0e,$55,$aa,$0e,$fc,$00,$00,$00,$00,$00,$00,$09,$26
    byte $00,$00,$00,$00,$00,$00,$60,$98,$1b,$9f,$6f,$7f,$7f,$4c,$73,$80
    byte $e4,$f6,$f9,$fd,$fd,$cd,$31,$02,$c2,$fc,$fc,$ff,$3f,$3c,$3f,$3c
    byte $a5,$2a,$2a,$c2,$0a,$02,$0a,$02,$3f,$3c,$3f,$3c,$3f,$3c,$c2,$fc
    byte $0a,$02,$0a,$02,$0a,$02,$a5,$2a,$df,$55,$55,$a9,$95,$a5,$95,$a5
    byte $f7,$55,$55,$6a,$56,$5a,$56,$5a,$95,$a5,$95,$a5,$95,$a5,$df,$55
    byte $56,$5a,$56,$5a,$56,$5a,$f7,$55,$5a,$a8,$a8,$83,$a0,$80,$a0,$80
    byte $83,$3f,$3f,$ff,$fc,$3c,$fc,$3c,$a0,$80,$a0,$80,$a0,$80,$5a,$a8
    byte $fc,$3c,$fc,$3c,$fc,$3c,$83,$3f,$fc,$ff,$3f,$3c,$3f,$3c,$3f,$3c
    byte $2a,$c2,$0a,$02,$0a,$02,$0a,$02,$3f,$3c,$3f,$3c,$c2,$fc,$fc,$ff
    byte $0a,$02,$0a,$02,$a5,$2a,$2a,$c2,$55,$a9,$95,$a5,$95,$a5,$95,$a5
    byte $55,$6a,$56,$5a,$56,$5a,$56,$5a,$95,$a5,$95,$a5,$df,$55,$55,$a9
    byte $56,$5a,$56,$5a,$f7,$55,$55,$6a,$a8,$83,$a0,$80,$a0,$80,$a0,$80
    byte $3f,$ff,$fc,$3c,$fc,$3c,$fc,$3c,$a0,$80,$a0,$80,$5a,$a8,$a8,$83
    byte $fc,$3c,$fc,$3c,$83,$3f,$3f,$ff,$09,$26,$1b,$9f,$6f,$7f,$7f,$7f
    byte $60,$98,$e4,$f6,$f9,$fd,$fd,$fd,$7f,$7c,$73,$6c,$90,$18,$26,$09
    byte $fd,$cd,$31,$c9,$06,$24,$98,$60,$55,$55,$6b,$6b,$ab,$6b,$bf,$bf
    byte $55,$55,$e9,$e9,$ea,$e9,$fe,$fe,$bf,$bf,$2b,$ab,$2b,$2b,$00,$00
    byte $fe,$fe,$e8,$ea,$e8,$e8,$00,$00,$00,$00,$2a,$25,$24,$24,$24,$24
    byte $25,$0a,$aa,$55,$00,$00,$ff,$ff,$24,$24,$24,$24,$24,$24,$24,$24
    byte $ff,$f5,$f5,$f0,$ff,$ff,$ff,$ff,$58,$a0,$aa,$55,$00,$00,$ff,$ff
    byte $00,$00,$a8,$58,$18,$18,$18,$18,$ff,$5f,$5f,$0f,$ff,$ff,$ff,$ff
    byte $18,$18,$18,$18,$18,$18,$18,$18,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    byte $24,$08,$24,$08,$08,$00,$08,$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
    byte $ff,$ff,$f7,$fb,$fb,$f3,$ff,$ff,$18,$20,$18,$20,$20,$00,$20,$00
    byte $02,$08,$08,$0b,$0b,$0b,$0b,$02,$80,$20,$20,$e0,$e0,$e0,$e0,$80
    byte $15,$25,$24,$26,$25,$25,$25,$0a,$54,$58,$18,$98,$58,$58,$58,$a0
    byte $a4,$6b,$8b,$0b,$cb,$cb,$cb,$cb,$69,$82,$3c,$ff,$c0,$c0,$2a,$2a
    byte $cb,$cb,$cb,$cb,$8b,$6b,$8b,$33,$2a,$2a,$2a,$c0,$96,$28,$c3,$ff
    byte $69,$82,$3c,$ff,$00,$00,$aa,$a9,$69,$82,$3c,$ff,$00,$00,$aa,$6a
    byte $a8,$aa,$aa,$00,$96,$28,$c3,$ff,$2a,$aa,$aa,$00,$96,$28,$c3,$ff
    byte $69,$82,$3c,$ff,$03,$03,$a8,$a8,$1a,$e9,$e2,$e0,$e3,$e3,$e3,$e3
    byte $a8,$a8,$a8,$03,$96,$28,$c3,$ff,$e3,$e3,$e3,$e3,$e2,$e9,$e2,$cc
    byte $00,$00,$00,$00,$00,$02,$09,$0a,$00,$00,$00,$00,$00,$80,$60,$a0
    byte $9f,$a7,$25,$8a,$22,$08,$22,$00,$f6,$da,$58,$a2,$88,$20,$88,$00
    byte $00,$22,$08,$22,$8a,$25,$a7,$9f,$00,$88,$20,$88,$a2,$58,$da,$f6
    byte $0a,$09,$02,$00,$00,$00,$00,$00,$a0,$60,$80,$00,$00,$00,$00,$00
    byte $aa,$55,$aa,$aa,$aa,$aa,$aa,$00,$aa,$15,$2a,$2a,$2a,$2a,$2a,$00
    byte $aa,$54,$a8,$a8,$a8,$a8,$a8,$00,$2a,$15,$2a,$2a,$2a,$2a,$2a,$00
    byte $a8,$54,$a8,$a8,$a8,$a8,$a8,$00,$aa,$55,$aa,$aa,$2a,$2a,$2a,$00
    byte $aa,$55,$aa,$aa,$a8,$a8,$a8,$00,$cf,$33,$0c,$03,$00,$00,$00,$00
    byte $ff,$3f,$cf,$3f,$cf,$33,$0f,$33,$0f,$03,$0c,$03,$00,$03,$00,$03
    byte $ff,$ff,$c0,$ff,$c0,$2a,$c0,$2a,$ff,$ff,$03,$ff,$03,$a8,$03,$a8
    byte $2a,$2a,$95,$2a,$95,$95,$80,$3f,$a8,$a8,$56,$a8,$56,$56,$02,$fc
    byte $ff,$fc,$f3,$fc,$f3,$cc,$f0,$cc,$f3,$cc,$30,$c0,$00,$00,$00,$00
    byte $f0,$c0,$30,$c0,$00,$c0,$00,$c0


; CHARSET IMAGE ATTRIBUTE DATA...
; 109 attributes, 1 attribute per image, 8 bits per attribute, total size is 109 ($6d) bytes.
; nb. Upper nybbles = material, lower nybbles = colour.

charset_attrib_data

    byte $03,$13,$13,$03,$03,$13,$03,$13,$13,$13,$13,$33,$33,$33,$33,$03
    byte $03,$33,$33,$03,$03,$43,$43,$13,$13,$13,$13,$13,$13,$13,$13,$13
    byte $13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$43
    byte $43,$43,$43,$53,$53,$53,$53,$03,$03,$03,$03,$03,$03,$03,$03,$03
    byte $03,$03,$03,$03,$63,$63,$63,$63,$13,$23,$13,$23,$23,$23,$23,$23
    byte $23,$13,$23,$13,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
    byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03




; CHARTILESET DATA...
; 19 tiles, 2x2 (4) cells per tile, 8 bits per cell, total size is 76 ($4c) bytes.
*=ADDR_CHARTILESET_DATA
chartileset_data

    byte $00,$00,$00,$00,$23,$24,$25,$26,$2b,$2c,$2d,$2e,$48,$49,$4a,$4b
    byte $4c,$4d,$4e,$4f,$50,$51,$52,$53,$01,$01,$03,$03,$01,$02,$03,$04
    byte $05,$01,$06,$03,$17,$18,$19,$1a,$1f,$20,$21,$22,$13,$14,$15,$16
    byte $27,$28,$29,$2a,$1b,$1c,$1d,$1e,$37,$38,$39,$3a,$3b,$3c,$3d,$3e
    byte $39,$3f,$40,$41,$42,$3e,$41,$43,$07,$08,$09,$0a


; CHARTILESET COLOUR DATA...
; 19 colours, 1 colour per tile, 8 bits per colour, total size is 19 ($13) bytes.
; nb. Lower nybbles = colour, upper nybbles are unused.

*=ADDR_CHARTILESET_COLOUR_DATA
chartile_colour_data

    byte $00,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$09,$09,$0d,$0d
    byte $0d,$0d,$0f



; MAP DATA...
; 20x12 (240) cells, 8 bits per cell, total size is 240 ($f0) bytes.
*=ADDR_MAP_DATA
map_data

    byte $01,$0c,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    byte $00,$01,$0c,$02,$00,$00,$00,$0e,$0f,$00,$00,$00,$00,$00,$00,$00
    byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$11,$00,$00,$00
    byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$04,$05,$06
    byte $06,$07,$00,$00,$00,$00,$00,$00,$00,$00,$08,$06,$06,$03,$04,$05
    byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    byte $00,$00,$00,$00,$00,$00,$00,$00,$09,$0d,$0a,$00,$00,$00,$00,$00
    byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$09,$0d,$0a,$06,$06,$06,$06
    byte $06,$07,$00,$00,$00,$00,$00,$00,$00,$00,$08,$06,$06,$06,$06,$06
    byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    byte $00,$00,$00,$00,$00,$0b,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    byte $00,$00,$00,$00,$00,$00,$0b,$00,$09,$0d,$0a,$00,$00,$00,$00,$00
    byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$09,$0d,$0a,$01,$0c,$02,$12
    byte $12,$12,$00,$00,$00,$00,$00,$00,$00,$00,$12,$12,$12,$01,$0c,$02

