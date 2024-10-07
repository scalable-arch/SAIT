#ifndef __CRC32_H__
#define __CRC32_H__

/*
 *  CRC32 Specification:
 *      - Generator polynomial            : 0x000000AF
 *      - Initial value of shift register : 0x00000000
 *      - Final XOR value                 : 0x00000000
 *      - Reflect                         : false
 */
#define GEN_POLY 0x000000AF
#define INIT_VAL 0x00000000
#define XOR_VAL 0x00000000
#define REFLECT 0  // false

/*
 *  System settings - these can be modified for customization.
 */
#define CRC 32
#define BYTE 8
#define TABLE_SIZE 256
#define GROUP_SIZE 2            // number of data chunks to group
#define DQ_SIZE 32              // number of DQs
#define DATA_SIZE 64            // size of data in bytes
#define CW_SIZE 68              // size of codeword in bytes
#define BL 8                    // burst length
#define NUM_ITER 10000000       // number of iterations for simulation

extern uint32_t CRCTable[TABLE_SIZE];  // CRC lookup table

/*
 *  Three modes of the program.
 */
typedef enum {
    MODE_SIMULATION,
    MODE_TABLE_GENERATION,
    MODE_ENCODING
} ProgramMode;

ProgramMode getMode(int argc, char *argv[]);
void serialize(const uint32_t (*dataStream)[BL], uint8_t *data, size_t DQLen, size_t groupLen);
void genCRCTable();
void printCRCTable();
uint32_t calcCRCWithTable(const uint8_t *data, size_t byteLen);
uint32_t calcCRC(const uint8_t *data, size_t byteLen);
uint32_t reflect(uint32_t value);

#endif  /* __CRC32_H__ */