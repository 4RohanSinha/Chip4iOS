//
//  chip8.c
//  Chip4iOS
//
//  Created by Rohan Sinha on 9/14/24.
//

#include "chip8.h"
#include "ops.h"
#include <string.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>

#define ZERO_INITIALIZE_ARR(arr, len) for (int i = 0; i < len; i++) arr[i] = 0;

const unsigned int START_ADDRESS = 0x200;
const unsigned int FONTSET_SIZE = 80;
const unsigned int FONTSET_START_ADDRESS = 0x50;

size_t rom_size = 0;

uint8_t fontset[FONTSET_SIZE] =
{
    0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
    0x20, 0x60, 0x20, 0x20, 0x70, // 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
    0x90, 0x90, 0xF0, 0x10, 0x10, // 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
    0xF0, 0x10, 0x20, 0x40, 0x40, // 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
    0xF0, 0x90, 0xF0, 0x90, 0x90, // A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
    0xF0, 0x80, 0x80, 0x80, 0xF0, // C
    0xE0, 0x90, 0x90, 0x90, 0xE0, // D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
    0xF0, 0x80, 0xF0, 0x80, 0x80  // F
};

void ch_initialize(chip_8* proc) {
    ZERO_INITIALIZE_ARR(proc->registers, NUM_REGISTERS);
    ZERO_INITIALIZE_ARR(proc->memory, MEM_SIZE);
    ZERO_INITIALIZE_ARR(proc->stack, STACK_SIZE);
    ZERO_INITIALIZE_ARR(proc->keypad, KEYPAD_SIZE);
    ZERO_INITIALIZE_ARR(proc->video, VIDEO_SIZE);

    proc->index = 0;
    proc->sp = 0;
    proc->delayTimer = 0;
    proc->soundTimer = 0;
    proc->pc = START_ADDRESS;
    memcpy(proc->memory + FONTSET_START_ADDRESS, fontset, FONTSET_SIZE);

    srand(time(NULL));
    initialize_optable();
}

unsigned char getRandomByte() {
    return (unsigned char)(rand() & 0xFF);
}

/*void ch_loadRom(chip_8* proc, char const* filename) {
    FILE* rom = fopen(filename, "rb");
    long startPos, endPos;
    if (!feof(rom)) {
        startPos = ftell(rom);
        if (startPos == -1) {
            printf("Processing error\n");
            exit(1);
        }

        fread(proc->memory + START_ADDRESS, MEM_SIZE - START_ADDRESS, 1, rom);

        endPos = ftell(rom);

        if (endPos == -1) {
            printf("Processing error\n");
            exit(1);
        }

        rom_size = endPos - startPos;
    }

    fclose(rom);


}*/

void ch_loadBytes(chip_8* proc, const char* instructions, size_t numBytes) {
    memcpy(proc->memory + START_ADDRESS, instructions, numBytes);
    rom_size = numBytes;
}

void ch_loadMemory(chip_8* proc, const void* memory, size_t numBytes) {
    memcpy(proc->memory, memory, numBytes);
    rom_size = numBytes;
}

void ch_cycle(chip_8* proc) {
    proc->opcode = (proc->memory[proc->pc] << 8u) | (proc->memory[proc->pc + 1]);
    proc->pc += 2;
    decxec(proc);

    if (proc->delayTimer > 0) --proc->delayTimer;

    if (proc->soundTimer > 0) --proc->soundTimer;
    
}

size_t ch_numBytes() { return rom_size; }


void ch_keyDown(chip_8* proc, int key) {
    proc->keypad[key] = 1;
}
void ch_keyUp(chip_8* proc, int key) {
    proc->keypad[key] = 0;
}
