###
### This program generates CRC coefficient table for Verilog codes.
###
import numpy as np
from functools import reduce

# Define your CRC32 here.
# GEN_POLY : CRC32 generator polynomial (Ignore the highest "1").
CRC_POLY   = 0x814141AB

# Code configuration
DATA_WIDTH = 512
CRC_WIDTH  = 32

def gen_crc_table() :
    # Generate numpy object from parameters.
    crc_poly = np.array(list(f'{CRC_POLY:0{CRC_WIDTH}b}'), dtype=int)
    init_value = np.zeros(CRC_WIDTH, dtype=int)

    crc_coeff_table = np.zeros((CRC_WIDTH, DATA_WIDTH), dtype=int)

    # Calculate CRC checksum for each one 1's data and save it to the table.
    for bit_pos in range(DATA_WIDTH) :

        # Set dividend and initial crc value.
        dividend = np.zeros(DATA_WIDTH, dtype=int)
        dividend[bit_pos] ^= 1
        crc_temp = init_value.copy()

        # Calculate CRC.
        for _ in range(DATA_WIDTH) :  # calculate
            if dividend[0] != crc_temp[0] :
                crc_temp = np.roll(crc_temp, -1)
                crc_temp[-1] = 0
                crc_temp ^= crc_poly
            else :
                crc_temp = np.roll(crc_temp, -1)
                crc_temp[-1] = 0
            
            dividend = np.roll(dividend, -1)
            dividend[-1] = 0

        # Save the output.
        for i in range(CRC_WIDTH) :   # save
            if crc_temp[i] == 1 :
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

print("-----------------------------------------")
print("CRC32 polynomial : 0x%08X" % CRC_POLY)
print("-----------------------------------------")
print("CRC32 Table")
print("-----------------------------------------")

print_crc_table(crc_coeff_table)

#input_data = 0x3b29e21369262e70fe9c33fd3d5d03e220adb2970564cbf17a0900c5cea5c6ecf6a47a480947d40c214b2b2c70a8386b51ab091b73a72e45a4d00ef4c333cd6c
#checksum = calc_crc(input_data)
#print(checksum)