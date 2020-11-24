AS=64tass
ASFLAGS=--labels=$@.lbl --list=$@.lst
PACK=exomizer
src = $(wildcard *.asm)
prg = $(src:.asm=.prg)
bin = $(src:.asm=.bin)


all: $(prg) $(bin)
#	$(PACK) sfx sys $(prg) -o sinus.prg

%.prg: %.asm
	$(AS) $(ASFLAGS) -o $@ $<

%.bin: %.asm $(prg)
	$(AS) --nostart -o $@ $<

.PHONY: clean
clean:
	rm -f $(prg) *.bin *.lbl *.lst
