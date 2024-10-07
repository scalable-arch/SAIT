#ifndef __SIM_H__
#define __SIM_H__

#define NUM_ITER 10000000       // number of iterations for simulation

void simulate(unsigned int numIter);
bool decodeCRC(uint8_t *data, size_t byteLen);
void genError(uint8_t *data, size_t byteLen);
void genBurstError(uint8_t *data, size_t byteLen);
unsigned int countOne(uint8_t *data, size_t byteLen);
void bitwiseXOR(uint8_t *data1, uint8_t *data2, size_t byteLen);
unsigned int getBurstLen(uint8_t *data, size_t byteLen);

#endif