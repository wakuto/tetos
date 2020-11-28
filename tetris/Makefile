RM = rm -f


ifeq ($(OS),Windows_NT)
	RM = cmd.exe /C del /Q
endif

boot: 
	nasm boot.s -o boot.bin -l boot.lst
	nasm kernel.s -o kernel.bin -l kernel.lst
	cat boot.bin kernel.bin > boot.img
	gcc -c tasks/main.c
	ld -s boot.img main.o

run:
	bochsdbg -q -f ../../env/bochsrc.bxrc -rc ../../env/cmd.init

clean:
	$(RM) *.img
	$(RM) *.bin
	$(RM) *.lst

