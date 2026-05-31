@echo off

nasm -f bin asm\mbr.asm -o bin\mbr.bin
nasm -f bin asm\knl.asm -o bin\knl.bin

pause
