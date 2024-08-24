%:
	nasm -f elf -o solution$@/task$@.o solution$@/task$@.asm
	ld -m elf_i386 -o solution$@/task$@ solution$@/task$@.o
	./solution$@/task$@