###
### This program generates CRC coefficient table for Verilog codes.
###
import numpy as np
from functools import reduce

CRC_POLY   = 0x000000AF  # define your generator polynomial here
DATA_WIDTH = 512
CRC_WIDTH  = 32

def gen_crc_table() :
    crc_poly = np.pad(np.array(list(f'{CRC_POLY:0{CRC_WIDTH}b}'), dtype=int), (0, DATA_WIDTH), 'constant')
    crc_coeff_table = np.zeros((CRC_WIDTH, DATA_WIDTH), dtype=int)

    zero = np.zeros(DATA_WIDTH + CRC_WIDTH, dtype=int)

    for bit_pos in range(DATA_WIDTH) :  # 계산할 data
        dividend = zero.copy()
        dividend[bit_pos] = 1

        for _ in range(DATA_WIDTH) :    # 해당 data에 대한 crc 계산
            if dividend[0] == 1 :
                dividend = np.roll(dividend, -1)
                dividend[-1] = 0
                dividend ^= crc_poly
            else :
                dividend = np.roll(dividend, -1)
                dividend[-1] = 0

        for i in range(CRC_WIDTH) :
            if dividend[i] == 1 :
                crc_coeff_table[i][bit_pos] = 1

    return crc_coeff_table

def print_crc_table(crc_coeff_table) :
    f_crc_coeff_table = []
    for row in crc_coeff_table :
        hex_values = [f'{int("".join(map(str, row[i:i+16])), 2):04X}' for i in range(0, len(row), 16)]
        hex_string = '_'.join(hex_values)
        f_crc_coeff_table.append(hex_string)
    
    f_crc_coeff_table = f_crc_coeff_table[::-1]
    for row in f_crc_coeff_table :
        print(f"{DATA_WIDTH}'h{row},")

def calc_crc(input_data) :  # just for test
    data = np.array(list(f'{input_data:0{DATA_WIDTH}b}'), dtype=int)
    checksum = np.zeros(CRC_WIDTH, dtype=int)

    for i in range (CRC_WIDTH) :
        result = reduce(lambda x, y: x ^ y, data & crc_coeff_table[i])
        checksum[i] = result
    return checksum

crc_coeff_table = gen_crc_table()

print("CRC polynomial :0x%X" % CRC_POLY)
print_crc_table(crc_coeff_table)

# input_data = 0x3b29e21369262e70fe9c33fd3d5d03e220adb2970564cbf17a0900c5cea5c6ecf6a47a480947d40c214b2b2c70a8386b51ab091b73a72e45a4d00ef4c333cd6c
# checksum = calc_crc(input_data)
# print(checksum)