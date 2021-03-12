#include "Gayle.h"
#include "config_file/config_file.h"
#include "amiga-registers.h"

uint8_t rtc_emulation_enabled = 1;
extern int gayle_emulation_enabled;

void configure_rtc_emulation_amiga(uint8_t enabled) {
    if (enabled == rtc_emulation_enabled)
        return;

    rtc_emulation_enabled = enabled;
    printf("Amiga RTC emulation is now %s.\n", (enabled) ? "enabled" : "disabled");
}

int handle_register_read_amiga(unsigned int addr, unsigned char type, unsigned int *val) {
    if (gayle_emulation_enabled) {
        if (!rtc_emulation_enabled && addr >= CLOCKBASE && addr < CLOCKBASE + CLOCKSIZE)
            return -1;
        if (addr >= GAYLEBASE && addr < GAYLEBASE + GAYLESIZE) {
            switch(type) {
            case OP_TYPE_BYTE:
                *val = readGayleB(addr);
                return 1;
                break;
            case OP_TYPE_WORD:
                *val = readGayle(addr);
                return 1;
                break;
            case OP_TYPE_LONGWORD:
                *val = readGayleL(addr);
                return 1;
                break;
            case OP_TYPE_MEM:
                return -1;
                break;
            }
        }
    }
    return -1;
}

int handle_register_write_amiga(unsigned int addr, unsigned int value, unsigned char type) {
    if (gayle_emulation_enabled) {
        if (!rtc_emulation_enabled && addr >= CLOCKBASE && addr < CLOCKBASE + CLOCKSIZE)
            return -1;
        if (addr >= GAYLEBASE && addr < GAYLEBASE + GAYLESIZE) {
            switch(type) {
            case OP_TYPE_BYTE:
                writeGayleB(addr, value);
                return 1;
                break;
            case OP_TYPE_WORD:
                writeGayle(addr, value);
                return 1;
                break;
            case OP_TYPE_LONGWORD:
                writeGayleL(addr, value);
                return 1;
                break;
            case OP_TYPE_MEM:
                return -1;
                break;
            }
        }
    }
    return -1;
}
