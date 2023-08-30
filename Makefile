ASM=nasm

SRC_KANSIO=src
BUILD_KANSIO=build


.PHONY: all floppy_image kernel bootloader clean always

# Floppy image kopio
floppy_image: $(BUILD_KANSIO)/main_floppy.img

$(BUILD_KANSIO)/main_floppy.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_KANSIO)/main_floppy.img bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(BUILD_KANSIO)/main_floppy.img
	dd if=$(BUILD_KANSIO)/bootloader.bin of=$(BUILD_KANSIO)/main_floppy.img conv=notrunc
	mcopy -i $(BUILD_KANSIO)/main_floppy.img $(BUILD_KANSIO)/kernel.bin "::kernel.bin"

##
#	BootLoader makefile
##
bootloader: $(BUILD_KANSIO)/bootloader.bin

$(BUILD_KANSIO)/bootloader.bin: always
	$(ASM) $(SRC_KANSIO)/bootloader/boot.asm -f bin -o $(BUILD_KANSIO)/bootloader.bin

##
#	Kernel makefile
##
kernel: $(BUILD_KANSIO)/kernel.bin

$(BUILD_KANSIO)/kernel.bin: always
	$(ASM) $(SRC_KANSIO)/kernel/main.asm -f bin -o $(BUILD_KANSIO)/kernel.bin

##
#	Always
##
always:
	mkdir -p $(BUILD_KANSIO)



##
#	Clean
##
clean:
	rm -rf $(BUILD_KANSIO)/*
