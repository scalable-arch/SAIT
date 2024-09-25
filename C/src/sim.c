#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <time.h>
#include <string.h>
#include "crc32.h"
#include "sim.h"

/*
 *  Function for Monte Carlo simulation.
 */
void simulate(unsigned int numIter)
{
    srand((unsigned int)time(NULL));

    unsigned int totDetError = 0;
    unsigned int totBurst32Error = 0;
    unsigned int detBurst32Error = 0;
    unsigned int totOddError = 0;
    unsigned int detOddError = 0;
    unsigned int totDoubleError = 0;
    unsigned int detDoubleError = 0;

    for (unsigned int i = 0; i < numIter; ++i) {
        // Generate codeword by concatnating data and checksum.
        // The original codeword is all-zero.
        uint8_t codeword[CW_SIZE] = {0};

        // Generate an error vector and apply to the codeword.
        uint8_t error[CW_SIZE] = {0};
        genBurstError(error, CW_SIZE);
        bitwiseXOR(codeword, error, CW_SIZE);

        // Analyze the simulation result.
        bool detected = decodeCRC(codeword, CW_SIZE);

        unsigned int errorCount = countOne(error, CW_SIZE);  // # of error bits

        // 1) Count detected error.
        if (errorCount > 0 && detected) {
            totDetError++;
        }

        // 2) Count odd error.
        if (errorCount % 2) {
            totOddError++;

            if (detected) {
                detOddError++;
            }
        }

        // 3) Count double error.
        if (errorCount == 2) {
            totDoubleError++;

            if (detected) {
                detDoubleError++;
            }
        }

        // 4) Count burst error. (burst length <= 32)
        unsigned int burstLen = getBurstLen(error, CW_SIZE);
        if (burstLen <= 32) {
            totBurst32Error++;

            if (detected) {
                detBurst32Error++;
            }
        }
    }

    // Print the result.
    printf("##### Result #####\n");
    printf("Total detected error       : %d / %d (%.2f%%)\n", 
        totDetError, numIter, (double)totDetError * 100 / numIter);
    printf("Odd error                  : %d / %d (%.2f%%)\n", 
        detOddError, totOddError, (double)detOddError * 100 / totOddError);
    //printf("Double error              : %d / %d (%.2f%%)\n", 
    //    detDoubleError, totDoubleError, (double)detDoubleError * 100 / totDoubleError);
    printf("Burst error (length <= 32) : %d / %d (%.2f%%)\n", 
        detBurst32Error, totBurst32Error, (double)detBurst32Error * 100 / totBurst32Error);
}

/*
 *  Function to detect if the codeword is erroneous.
 */
bool decodeCRC(uint8_t *data, size_t byteLen)
{   
    uint32_t checksum = calcCRC(data, byteLen);

    // Non-zero checksum indicates that an error is detected,
    // as the original codeword was all-zero.
    for (size_t byteIdx = 0; byteIdx < byteLen; ++byteIdx) {
        if (data[byteIdx] != 0x00) {
            return true;
        }
    }
    return false;
}

/*
 *  Function to randomly generate errors in the codeword.
 */
void genError(uint8_t *data, size_t byteLen)
{
    float flipRate = 0.5;

    for (size_t byteIdx = 0; byteIdx < byteLen; ++byteIdx) {
        for (int bitIdx = 0; bitIdx < BYTE; ++bitIdx) {
            if (((float)rand() / (float)RAND_MAX) < flipRate) {
                data[byteIdx] |= (0x01 << bitIdx);  // flip each bit with a 
                                                    // probability of flipRate
            }
        }
    }
}

/*
 *  Function to randomly generate a burst error (length <= 32) in the codeword.
 */
void genBurstError(uint8_t *data, size_t byteLen)
{
    float flipRate = 0.5;

    unsigned int startByteIdx = rand() % DATA_SIZE + 1;

    for (size_t byteIdx = startByteIdx; byteIdx < startByteIdx + (CW_SIZE - DATA_SIZE); ++byteIdx) {
        for (int bitIdx = 0; bitIdx < BYTE; ++bitIdx) {
            if (((float)rand() / (float)RAND_MAX) < flipRate) {
                data[byteIdx] |= (0x01 << bitIdx);  // flip each bit with a 
                                                    // probability of flipRate
            }
        }
    }
}

/*
 *  Function to count the number of 1's in the data.
 */
unsigned int countOne(uint8_t *data, size_t byteLen)
{
    unsigned int errorCount = 0;

    for (size_t byteIdx = 0; byteIdx < byteLen; ++byteIdx) {
        for (int bitIdx = 0; bitIdx < BYTE; ++bitIdx) {
            if (data[byteIdx] & (0x01 << bitIdx)) {
                ++errorCount;
            }
        }
    }
    
    return errorCount;
}

/*
 *  Function to perform bitwise XOR between arrays.
 *
 *  NOTE: The size of two arrays must be same.
 *        The result is stored in the first array.
 */
void bitwiseXOR(uint8_t *data1, uint8_t *data2, size_t byteLen)
{
    for (size_t byteIdx = 0; byteIdx < byteLen; ++byteIdx) {
        data1[byteIdx] ^= data2[byteIdx];
    }
}

/*
 *  Function to get the burst length of an input error vector.
 */
unsigned int getBurstLen(uint8_t *data, size_t byteLen)
{
    int leftIdx = -1;
    int rightIdx = -1;

    // Find the position of the first '1' from the left.
    for (size_t byteIdx = 0; byteIdx < byteLen; ++byteIdx) {
        for (int bitIdx = BYTE-  1; bitIdx >= 0; --bitIdx) {
            if (data[byteIdx] & (0x01 << bitIdx)) {
                leftIdx = byteIdx * BYTE + (BYTE - 1 - bitIdx);
                break;
            }
        }
        if (leftIdx != -1) break;
    }

    // Find the position of the first '1' from the right.
    for (int byteIdx = byteLen - 1; byteIdx >= 0; --byteIdx) {
        for (int bitIdx = 0; bitIdx < BYTE; ++bitIdx) {
            if (data[byteIdx] & (0x01 << bitIdx)) {
                rightIdx = byteIdx * BYTE + (BYTE - 1 - bitIdx);
                break;
            }
        }
        if (rightIdx != -1) break;
    }

    // No '1' found.
    if (leftIdx == -1 || rightIdx == -1) {
        return 0;
    }

    // The burst length is the difference
    // between the positions of the leftmost 1 and the rightmost 1.
    return rightIdx - leftIdx + 1;
}