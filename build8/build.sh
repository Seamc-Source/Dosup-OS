dd if=bin/mbr.bin of=dsk/dup.vhd bs=512 count=1 conv=notrunc
dd if=bin/knl.bin of=dsk/dup.vhd bs=512 seek=1 conv=notrunc

