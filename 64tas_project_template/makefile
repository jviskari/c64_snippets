all: test.prg
	x64 -moncommands moncmds.txt -autostartprgmode 1 -autostart-warp $<
test.prg: test.tmp
	pucrunch -ffast -x 4096 $< >$@

testmon: test.tmp 
	x64 -moncommands moncmds_test.txt 

test.tmp: source.asm 
	64tass -C -a -B -i $< -o $@ --vice-labels -l $@.lbl -L $@.lst

clean: 
	rm test.*