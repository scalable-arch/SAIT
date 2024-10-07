# Integration Guide

# Overview

This project provides the synthesis of a CRC32 encoder and decoder, along with the simulation of the CRC32 code's error detection performance.

# CRC32 Encoder & Decoder Synthesis (System Verilog)

This is the System Verilog RTL for synthesizing the CRC32 encoder and decoder logic.

We offer two approaches for implementing CRC32 :

+ **General** : Uses the basic division method.
+ **Table-based** : Utilizes precomputed CRC32 values.

Both methods allow synthesis using any desired CRC32 polynomial.

Refer to https://crccalc.com/?crc=123456789&method=CRC-32&datatype=0&outtype=0 for possible CRC32 codes.

## If you want to use **General** method

### Before you start

Set your desired polynomial value in the `sverilog/general/DEC/rtl/CRC32_GEN.sv` and `sverilog/general/ENC/rtl/CRC32_GEN.sv` :

```
`define     GEN_POLY                    //YOUR_CODE_HERE//
`define     INIT_VAL                    //YOUR_CODE_HERE//
`define     XOR_OUT                     //YOUR_CODE_HERE//
```

### Synthesizing Decoder

```
% cd sverilog/general/DEC
```

## If you want to use **Table-based** method

### Before you start

First you need to generate pre-calculated CRC32 table using `sverilog/table-based/python/gen_table.py`.

Set your desired polynomial value in the `gen_table.py` :

```
CRC_POLY   = //YOUR_CODE_HERE//
```

Run `gen_table.py` and get the table :

```
% python gen_table.py
%
%
```

Copy and paste the result from `gen_table.py` in the `sverilog/table-based/DEC-table/rtl/CRC32_DEC.sv` and `sverilog/table-based/ENC-table/rtl/CRC32_ENC.sv` :

```
localparam [DATA_WIDTH-1:0] CRC_COEFF_TABLE[CRC_WIDTH-1:0] = '{ //YOUR_TABLE_HERE// }
```

### Synthesizing Decoder

```
% cd sverilog/table-based/DEC-table
%
%
```

## Port List

The following tables detail the port specifications for the CRC32 encoder and decoder modules.

### Encoder
| Port           | Direction | Width    | Description                               |
| :---           | :---      | :---     | :---                                      |
| clk            | Input     | 1        | Clock                                     |
| rst_n          | Input     | 1        | Reset (active low) synchronizd to the clk |
| valid_i        | Input     | 1        | Valid signal for data_i                   |
| data_i         | Input     | 512      | Input data                                |
| valid_o        | Output    | 1        | Valid signal for data_o, checksum_o       |
| data_o         | Output    | 512      | Output data (same as data_i)              |
| checksum_o     | Output    | 32       | Calculated checksum for input data        |

### Decoder
| Port           | Direction | Width    | Description                               |
| :---           | :---      | :---     | :---                                      |
| clk            | Input     | 1        | Clock                                     |
| rst_n          | Input     | 1        | Reset (active low) synchronizd to the clk |
| valid_i        | Input     | 1        | Valid signal for data_i, checksum_i       |
| data_i         | Input     | 512      | Input data                                |
| checksum_i     | Input     | 32       | Input checksum                            |
| valid_o        | Output    | 1        | Valid signal for data_o, detected_o       |
| data_o         | Output    | 512      | Output data (same as data_i)              |
| detected_o     | Output    | 32       | Error detection signal ('1' if detected)  |      

# Error Detection Performance Simulation (C)

This is the simple C code to evaluate the error detection capabilities of the CRC32 code.

There are three different modes for different purposes :

+ **Simulation mode** : Evaluates the error detection capabilities of the given CRC32 code using Monte Carlo simulation.
  + You can change the number of iterations by setting `NUM_ITER` in the `crc32.h`.
+ **Table generation mode** : Generates a CRC32 lookup table.
+ **Encoding mode** : Computes the CRC32 checksum for the given data.

## Run

Build :

```
$ cd c/src
% make
```

Run in the simulation mode.

```
$ cd ../bin
% ./crc32 sim
```

Or run in the encoding mode.

```
$ cd ../bin
% ./crc32 enc
```
