AS=64tass
ASFLAGS=--labels=$@.lbl --list=$@.lst
PACK=exomizer
EMU=x64sc
src = $(wildcard *.asm)
prg = $(src:.asm=.prg)

all:$(prg)
#	$(PACK) sfx sys $(prg) -o test.prg

%.prg: %.asm
	$(AS) $(ASFLAGS) -o $@ $<

run: $(prg)
	$(EMU) $(prg)
.PHONY: clean
clean:
	rm -f $(prg) test.prg *.lbl *.lst