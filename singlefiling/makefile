AS=64tass
ASFLAGS=--labels=$@.lbl --list=$@.lst
PACK=exomizer
src = $(wildcard *.asm)
prg = $(src:.asm=.prg)

all:$(prg)
	$(PACK) sfx sys $(prg) -o test.prg

%.prg: %.asm
	$(AS) $(ASFLAGS) -o $@ $<

.PHONY: clean
clean:
	rm -f $(prg) test.prg *.lbl *.lst