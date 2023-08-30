ASM=nasm

SRC_KANSIO=src
BUILD_KANSIO=build

$(BUILD_KANSIO)/main_floppy.img: $(BUILD_KANSIO)/main.bin
	cp $(BUILD_KANSIO)/main.bin $(BUILD_KANSIO)/main_floppy.img
	truncate -s 1440k

$(BUILD_KANSIO)/main.bin: $(SRC_KANSIO)/main.asm
	$(ASM) $(SRC_KANSIO)/main.asm -f bin -o $(BUILD_KANSIO)/main.bin

