//
//  chip8.h
//  Chip4iOS
//
//  Created by Rohan Sinha on 9/14/24.
//

#ifndef CHIP_8
#define CHIP_8
#include <stdlib.h>

#ifndef NUM_REGISTERS
#define NUM_REGISTERS 16
#endif

#ifndef MEM_SIZE
#define MEM_SIZE 4096
#endif

#ifndef STACK_SIZE
#define STACK_SIZE 16
#endif

#define KEYPAD_SIZE 16

#ifndef VIDEO_WIDTH
#define VIDEO_WIDTH 64
#endif

#ifndef VIDEO_HEIGHT
#define VIDEO_HEIGHT 32
#endif

#define VIDEO_SIZE VIDEO_WIDTH * VIDEO_HEIGHT

extern const unsigned int FONTSET_START_ADDRESS;

typedef struct chip_8 {
    unsigned char registers[NUM_REGISTERS];
    unsigned char memory[MEM_SIZE];
    unsigned short index;
    unsigned short pc;
    unsigned short stack[STACK_SIZE];
    unsigned char sp;
    unsigned char delayTimer;
    unsigned char soundTimer;
    unsigned char keypad[KEYPAD_SIZE];
    unsigned int video[VIDEO_SIZE];
    unsigned short opcode;
} chip_8;

void ch_initialize(chip_8* proc);
void ch_loadBytes(chip_8* proc, const char* instructions, size_t numBytes);
void ch_cycle(chip_8* proc);
void ch_keyDown(chip_8* proc, int key);
void ch_keyUp(chip_8* proc, int key);
unsigned char getRandomByte();
size_t ch_numBytes();

#endif
