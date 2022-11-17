all: diff.txt

diff.txt: output.txt
	diff input.txt output.txt

output.txt: output.bin
	xxd  -l6 -g 1 output.bin  | cut -d '.' -f1 | cat > output.txt

input.bin: input.txt
	cat input.txt | xxd -r > input.bin

output.bin: test.prg input.bin 
	x64 -moncommands monitor_commands.txt

test.prg: source.asm 
	64tass -C -a -B -i $< -o $@ --vice-labels -l $@.lbl -L $@.lst

clean:
	rm *.bin *.lbl output.txt *.prg *.lst diff.txt

.PHONY:
	rm diff.txt output.bin output.txt