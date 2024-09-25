/*
 *  This program performs CRC32 checksum generation and error detection
 *  for a given set of data streams. There are three modes available.
 * 
 *    1) Simulation mode:
 *         Performs Monte Carlo simulation to evaluate the effectiveness of CRC32 
 *         error detection. Simulates random errors in codewords and checks 
 *         how well CRC32 can detect these errors.
 *  
 *    2) Table generation mode:
 *         Generates a CRC32 lookup table based on the given polynomial and 
 *         prints the table. Useful for precomputing CRC32 values for efficient 
 *         checksum calculation.
 *  
 *    3) Encoding mode:
 *         Serializes a data stream and computes the CRC32 checksum for the 
 *         serialized data. Outputs both the data and the corresponding checksum.
 */

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <time.h>
#include <string.h>
#include "crc32.h"
#include "sim.h"

uint32_t CRCTable[TABLE_SIZE] = {
    0x00000000, 0x000000AF, 0x0000015E, 0x000001F1, 0x000002BC, 0x00000213, 0x000003E2, 0x0000034D, 
    0x00000578, 0x000005D7, 0x00000426, 0x00000489, 0x000007C4, 0x0000076B, 0x0000069A, 0x00000635, 
    0x00000AF0, 0x00000A5F, 0x00000BAE, 0x00000B01, 0x0000084C, 0x000008E3, 0x00000912, 0x000009BD, 
    0x00000F88, 0x00000F27, 0x00000ED6, 0x00000E79, 0x00000D34, 0x00000D9B, 0x00000C6A, 0x00000CC5, 
    0x000015E0, 0x0000154F, 0x000014BE, 0x00001411, 0x0000175C, 0x000017F3, 0x00001602, 0x000016AD, 
    0x00001098, 0x00001037, 0x000011C6, 0x00001169, 0x00001224, 0x0000128B, 0x0000137A, 0x000013D5, 
    0x00001F10, 0x00001FBF, 0x00001E4E, 0x00001EE1, 0x00001DAC, 0x00001D03, 0x00001CF2, 0x00001C5D, 
    0x00001A68, 0x00001AC7, 0x00001B36, 0x00001B99, 0x000018D4, 0x0000187B, 0x0000198A, 0x00001925, 
    0x00002BC0, 0x00002B6F, 0x00002A9E, 0x00002A31, 0x0000297C, 0x000029D3, 0x00002822, 0x0000288D, 
    0x00002EB8, 0x00002E17, 0x00002FE6, 0x00002F49, 0x00002C04, 0x00002CAB, 0x00002D5A, 0x00002DF5, 
    0x00002130, 0x0000219F, 0x0000206E, 0x000020C1, 0x0000238C, 0x00002323, 0x000022D2, 0x0000227D, 
    0x00002448, 0x000024E7, 0x00002516, 0x000025B9, 0x000026F4, 0x0000265B, 0x000027AA, 0x00002705, 
    0x00003E20, 0x00003E8F, 0x00003F7E, 0x00003FD1, 0x00003C9C, 0x00003C33, 0x00003DC2, 0x00003D6D, 
    0x00003B58, 0x00003BF7, 0x00003A06, 0x00003AA9, 0x000039E4, 0x0000394B, 0x000038BA, 0x00003815, 
    0x000034D0, 0x0000347F, 0x0000358E, 0x00003521, 0x0000366C, 0x000036C3, 0x00003732, 0x0000379D, 
    0x000031A8, 0x00003107, 0x000030F6, 0x00003059, 0x00003314, 0x000033BB, 0x0000324A, 0x000032E5, 
    0x00005780, 0x0000572F, 0x000056DE, 0x00005671, 0x0000553C, 0x00005593, 0x00005462, 0x000054CD, 
    0x000052F8, 0x00005257, 0x000053A6, 0x00005309, 0x00005044, 0x000050EB, 0x0000511A, 0x000051B5, 
    0x00005D70, 0x00005DDF, 0x00005C2E, 0x00005C81, 0x00005FCC, 0x00005F63, 0x00005E92, 0x00005E3D, 
    0x00005808, 0x000058A7, 0x00005956, 0x000059F9, 0x00005AB4, 0x00005A1B, 0x00005BEA, 0x00005B45, 
    0x00004260, 0x000042CF, 0x0000433E, 0x00004391, 0x000040DC, 0x00004073, 0x00004182, 0x0000412D, 
    0x00004718, 0x000047B7, 0x00004646, 0x000046E9, 0x000045A4, 0x0000450B, 0x000044FA, 0x00004455, 
    0x00004890, 0x0000483F, 0x000049CE, 0x00004961, 0x00004A2C, 0x00004A83, 0x00004B72, 0x00004BDD, 
    0x00004DE8, 0x00004D47, 0x00004CB6, 0x00004C19, 0x00004F54, 0x00004FFB, 0x00004E0A, 0x00004EA5, 
    0x00007C40, 0x00007CEF, 0x00007D1E, 0x00007DB1, 0x00007EFC, 0x00007E53, 0x00007FA2, 0x00007F0D, 
    0x00007938, 0x00007997, 0x00007866, 0x000078C9, 0x00007B84, 0x00007B2B, 0x00007ADA, 0x00007A75, 
    0x000076B0, 0x0000761F, 0x000077EE, 0x00007741, 0x0000740C, 0x000074A3, 0x00007552, 0x000075FD, 
    0x000073C8, 0x00007367, 0x00007296, 0x00007239, 0x00007174, 0x000071DB, 0x0000702A, 0x00007085, 
    0x000069A0, 0x0000690F, 0x000068FE, 0x00006851, 0x00006B1C, 0x00006BB3, 0x00006A42, 0x00006AED, 
    0x00006CD8, 0x00006C77, 0x00006D86, 0x00006D29, 0x00006E64, 0x00006ECB, 0x00006F3A, 0x00006F95, 
    0x00006350, 0x000063FF, 0x0000620E, 0x000062A1, 0x000061EC, 0x00006143, 0x000060B2, 0x0000601D, 
    0x00006628, 0x00006687, 0x00006776, 0x000067D9, 0x00006494, 0x0000643B, 0x000065CA, 0x00006565,
};

// TODO : data input dataStream에 들어오도록
int main(int argc, char *argv[]) {

    ProgramMode mode = getMode(argc, argv);

    switch (mode) {
        // Simulation modes perform MonteCarlo simulation.
        case MODE_SIMULATION : {
            simulate(NUM_ITER);
            break;
        }

        // Table generation modes generates and prints CRC lookup table.
        case MODE_TABLE_GENERATION : {
            genCRCTable();
            printCRCTable();
            break;
        }

        // Encoding mode generate CRC checksum for the input data stream.
        case MODE_ENCODING : {
            uint32_t dataStream[GROUP_SIZE][BL] = {
                {
                    0x12345678, 0x9ABCDEF0, 0x13579BDF, 0x2468ACE0,
                    0x1A2B3C4D, 0x5E6F7A8B, 0xFFFFFFFF, 0x00000000,
                },
                {
                    0x89ABCDEF, 0x01234567, 0x89ABCDEF, 0xFEDCBA98,
                    0x13579BDF, 0x02468ACE, 0xFACEB00C, 0xFEEDFACE,
                }
            };  // TODO

            //uint32_t dataStream[GROUP_SIZE][BL];  // input data chunk
            uint8_t* data = (uint8_t*)calloc(DATA_SIZE, sizeof(uint8_t));

            // Serialize data chunk into data
            serialize(dataStream, data, DQ_SIZE, GROUP_SIZE);

            // Now encoding.
            uint32_t checksum = calcCRCWithTable(data, DATA_SIZE);  // checksum for the received data

            // Show data and the calculated checksum.
            printf("[Data] : ");
            for (size_t byteIdx = 0; byteIdx < DATA_SIZE; ++byteIdx) {
                printf("%02X", data[byteIdx]);
                if (byteIdx % 4 == 3 && byteIdx != DATA_SIZE - 1) {
                    printf("_");
                }
            }
            printf("\n");
            printf("[Checksum] : %08X\n", checksum);

            free(data);
            break;
        }

        default : { // should not reach here
            printf("Invalid program mode.\n");
            exit(EXIT_FAILURE);
        }
    }

    return 0;
}

/*
 *  Function to get mode from program input arguments.
 */
ProgramMode getMode(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <mode>\n\n", argv[0]);
        printf("Available modes: sim, table, enc\n");
        printf("  + sim: simulation mode\n");
        printf("  + table: table generation mode\n");
        printf("  + enc: encoding mode\n");
    }

    if (strcmp(argv[1], "sim") == 0) {
        return MODE_SIMULATION;
    }
    else if (strcmp(argv[1], "table") == 0) {
        return MODE_TABLE_GENERATION;
    }
    else if (strcmp(argv[1], "enc") == 0) {
        return MODE_ENCODING;
    }
    else {
        printf("Unknown mode: %s\n", argv[1]);
        exit(EXIT_FAILURE);
    }
}

/*
 *  Function to serialize a data chunk into a data array.
 *
 *  NOTE : The bits marked with 'O' form a continuous 32-bit sequence.
 *         The next 32-bit sequence consists of the bits marked with 'V', and so on.
 *  
 *                                  32 DQs                              
 *      | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |
 *  T7  X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X   
 *  T6  X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X   
 *  T5  V V V V V V V V X X X X X X X X X X X X X X X X X X X X X X X X 
 *  T4  O O O O O O O O X X X X X X X X X X X X X X X X X X X X X X X X    data
 *  T3  X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X  Stream[1]
 *  T2  X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X
 *  T1  V V V V V V V V X X X X X X X X X X X X X X X X X X X X X X X X
 *  T0  O O O O O O O O X X X X X X X X X X X X X X X X X X X X X X X X
 *
 *  T7  X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X   
 *  T6  X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X   
 *  T5  V V V V V V V V X X X X X X X X X X X X X X X X X X X X X X X X
 *  T4  O O O O O O O O X X X X X X X X X X X X X X X X X X X X X X X X    data
 *  T3  X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X  Stream[0]
 *  T2  X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X
 *  T1  V V V V V V V V X X X X X X X X X X X X X X X X X X X X X X X X
 *  T0  O O O O O O O O X X X X X X X X X X X X X X X X X X X X X X X X
 */
void serialize(const uint32_t (*dataStream)[BL], uint8_t *data, size_t DQLen, size_t groupLen)
{
    unsigned int byteIdx = 0;  // byte index for data array

    for (int dqOffset = 0; dqOffset < DQLen; dqOffset += 8) {
        // Split each consecutive 32-bit sequence into four 8-bit chunks and store them separately.
        for (int tick = 0; tick < 4; ++tick) {
            data[byteIdx++] = (uint8_t)(dataStream[0][tick]   >> (24 - dqOffset));
            data[byteIdx++] = (uint8_t)(dataStream[0][tick+4] >> (24 - dqOffset));
            data[byteIdx++] = (uint8_t)(dataStream[1][tick]   >> (24 - dqOffset));
            data[byteIdx++] = (uint8_t)(dataStream[1][tick+4] >> (24 - dqOffset));
        }
    }
}

/*
 *  Function to generate a CRC lookup table for CRC32.
 */
void genCRCTable()
{
    uint32_t dividend;
    uint32_t MSBit;

    // Calculate CRC of byteValue.
    // byteValue : 0x00 ~ 0xFF
    for (unsigned int byteValue = 0; byteValue < TABLE_SIZE; ++byteValue) {

        // Extend dividend to the size of redundancy.
        dividend = (uint32_t)(byteValue) << (CRC - BYTE);

        // Calculate CRC for each bit in the byteValue.
        for (unsigned int bitIdx = 0; bitIdx < BYTE; ++bitIdx) {
            MSBit = dividend & 0x80000000;

            // If MSB of dividend is 1, XOR with generator polynomial.
            if (MSBit) {
                dividend = (dividend << 1) ^ GEN_POLY;
            }
            else {
                dividend <<= 1;
            }
        }

        // The final dividend is a remainder.
        CRCTable[byteValue] = dividend;
    }
}

/*
 *  Function to print generated CRC32 lookup table.
 */
void printCRCTable()
{
    for (int i = 0; i < CRC; ++i) {
        for (int j = 0; j < BYTE; ++j) {
            printf("0x%08X, ", CRCTable[i*BYTE+j]);
        }
        printf("\n");
    }
}

/*
 *  Function to calculate CRC checksum using CRC lookup table.
 */
uint32_t calcCRCWithTable(const uint8_t *data, size_t byteLen)
{
    uint8_t byte;
    uint32_t crc_temp = INIT_VAL;

    // Calculate CRC for each byte in the data.
    for (unsigned int byteIdx = 0; byteIdx < byteLen; ++byteIdx) {
        // TODO : reflect input
        byte = data[byteIdx];

        // The next crc value is determined by 
        // combining the current crc value with the incoming byte.
        uint8_t tableIdx = (crc_temp >> (CRC - BYTE)) ^ byte;
        crc_temp = (crc_temp << BYTE) ^ CRCTable[tableIdx];
    }

    // Reflect the result if needed.
    crc_temp = REFLECT ? reflect(crc_temp) : crc_temp;

    // XOR to the result value.
    crc_temp ^= XOR_VAL;

    return crc_temp;  // this is the checksum
}

/*
 *  Function to calculate CRC checksum.
 */
uint32_t calcCRC(const uint8_t *data, size_t byteLen)
{
    uint8_t byte;
    uint32_t crc_temp = INIT_VAL;
    uint32_t MSBit;

    // Calculate CRC for each byte in the data.
    for (unsigned int byteIdx = 0; byteIdx < byteLen; ++byteIdx) {
        byte = data[byteIdx];

        crc_temp ^= (byte << (CRC - BYTE));

        // TODO : reflect input
        for (unsigned int bitIdx = 0; bitIdx < BYTE; ++bitIdx) {
            MSBit = crc_temp & 0x80000000;

            if (MSBit) {
                crc_temp = (crc_temp << 1) ^ GEN_POLY;
            }
            else {
                crc_temp <<= 1;
            }
        }
    }

    // Reflect the result if needed.
    crc_temp = REFLECT ? reflect(crc_temp) : crc_temp;

    // XOR to the result value.
    crc_temp ^= XOR_VAL;

    return crc_temp;  // this is the checksum
}

/*
 *  Function to reflect the bits in the input value.
 */
uint32_t reflect(uint32_t value)
{
    uint32_t result = 0;

    for (int i = 0; i < CRC; ++i) {
        if (value & 0x00000001) {
            result |= (0x00000001 << ((CRC - 1) - i));
        }
        value = (value >> 1);
    }

    return result;
}

